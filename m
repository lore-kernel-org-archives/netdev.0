From: John Fastabend <john.fastabend@gmail.com>
Subject: [net-next PATCH v1 2/3] net: sched: add direct ring acces via
 af_packet to ixgbe
Date: Sun, 05 Oct 2014 17:07:06 -0700
Message-ID: <20141006000705.32055.35262.stgit@nitbit.x32>
References: <20141006000629.32055.2295.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.ronciak@intel.com, amirv@mellanox.com,
	eric.dumazet@gmail.com, danny.zhou@intel.com
To: dborkman@redhat.com, fw@strlen.de, gerlitz.or@gmail.com,
	hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:63962 "EHLO
	mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751775AbaJFAH3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2014 20:07:29 -0400
Received: by mail-oi0-f50.google.com with SMTP id i138so2892145oig.23
        for <netdev@vger.kernel.org>; Sun, 05 Oct 2014 17:07:29 -0700 (PDT)
In-Reply-To: <20141006000629.32055.2295.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This implements the necessary ndo ops to support the af_packet
interface to directly own and manipulate queues.

Signed-off-by: Danny Zhou <danny.zhou@intel.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         |    3 
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |   23 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  232 ++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |    1 
 4 files changed, 251 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 673d820..2f6eadf 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -678,6 +678,9 @@ struct ixgbe_adapter {
 
 	struct ixgbe_q_vector *q_vector[MAX_Q_VECTORS];
 
+	/* Direct User Space Queues */
+	struct sock *sk_handles[MAX_RX_QUEUES];
+
 	/* DCB parameters */
 	struct ieee_pfc *ixgbe_ieee_pfc;
 	struct ieee_ets *ixgbe_ieee_ets;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index cff383b..01a6e55 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2581,12 +2581,17 @@ static int ixgbe_add_ethtool_fdir_entry(struct ixgbe_adapter *adapter,
 	if (!(adapter->flags & IXGBE_FLAG_FDIR_PERFECT_CAPABLE))
 		return -EOPNOTSUPP;
 
+	if (fsp->ring_cookie > MAX_RX_QUEUES)
+		return -EINVAL;
+
 	/*
 	 * Don't allow programming if the action is a queue greater than
-	 * the number of online Rx queues.
+	 * the number of online Rx queues unless it is a user space
+	 * queue.
 	 */
 	if ((fsp->ring_cookie != RX_CLS_FLOW_DISC) &&
-	    (fsp->ring_cookie >= adapter->num_rx_queues))
+	    (fsp->ring_cookie >= adapter->num_rx_queues) &&
+	    !adapter->sk_handles[fsp->ring_cookie])
 		return -EINVAL;
 
 	/* Don't allow indexes to exist outside of available space */
@@ -2663,12 +2668,18 @@ static int ixgbe_add_ethtool_fdir_entry(struct ixgbe_adapter *adapter,
 	/* apply mask and compute/store hash */
 	ixgbe_atr_compute_perfect_hash_82599(&input->filter, &mask);
 
+	/* Set input action to reg_idx for driver owned queues otherwise
+	 * use the absolute index for user space queues.
+	 */
+	if (fsp->ring_cookie < adapter->num_rx_queues &&
+	    fsp->ring_cookie != IXGBE_FDIR_DROP_QUEUE)
+		input->action = adapter->rx_ring[input->action]->reg_idx;
+
 	/* program filters to filter memory */
 	err = ixgbe_fdir_write_perfect_filter_82599(hw,
-				&input->filter, input->sw_idx,
-				(input->action == IXGBE_FDIR_DROP_QUEUE) ?
-				IXGBE_FDIR_DROP_QUEUE :
-				adapter->rx_ring[input->action]->reg_idx);
+						    &input->filter,
+						    input->sw_idx,
+						    input->action);
 	if (err)
 		goto err_out_w_lock;
 
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 06ef5a3..6506550 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -48,7 +48,9 @@
 #include <linux/if_macvlan.h>
 #include <linux/if_bridge.h>
 #include <linux/prefetch.h>
+#include <linux/mm.h>
 #include <scsi/fc/fc_fcoe.h>
+#include <linux/if_packet.h>
 
 #include "ixgbe.h"
 #include "ixgbe_common.h"
@@ -70,6 +72,8 @@ const char ixgbe_driver_version[] = DRV_VERSION;
 static const char ixgbe_copyright[] =
 				"Copyright (c) 1999-2014 Intel Corporation.";
 
+static unsigned int *dummy_page_buf;
+
 static const struct ixgbe_info *ixgbe_info_tbl[] = {
 	[board_82598] = &ixgbe_82598_info,
 	[board_82599] = &ixgbe_82599_info,
@@ -3122,6 +3126,16 @@ static void ixgbe_enable_rx_drop(struct ixgbe_adapter *adapter,
 	IXGBE_WRITE_REG(hw, IXGBE_SRRCTL(reg_idx), srrctl);
 }
 
+static bool ixgbe_have_user_queues(struct ixgbe_adapter *adapter)
+{
+	int i;
+
+	for (i = 0; i < MAX_RX_QUEUES; i++)
+		if (adapter->sk_handles[i])
+			return true;
+	return false;
+}
+
 static void ixgbe_disable_rx_drop(struct ixgbe_adapter *adapter,
 				  struct ixgbe_ring *ring)
 {
@@ -3156,7 +3170,8 @@ static void ixgbe_set_rx_drop_en(struct ixgbe_adapter *adapter)
 	 *  and performance reasons.
 	 */
 	if (adapter->num_vfs || (adapter->num_rx_queues > 1 &&
-	    !(adapter->hw.fc.current_mode & ixgbe_fc_tx_pause) && !pfc_en)) {
+	    !(adapter->hw.fc.current_mode & ixgbe_fc_tx_pause) && !pfc_en) ||
+	    ixgbe_have_user_queues(adapter)) {
 		for (i = 0; i < adapter->num_rx_queues; i++)
 			ixgbe_enable_rx_drop(adapter, adapter->rx_ring[i]);
 	} else {
@@ -7812,6 +7827,210 @@ static void ixgbe_fwd_del(struct net_device *pdev, void *priv)
 	kfree(fwd_adapter);
 }
 
+static int ixgbe_ndo_split_queue_pairs(struct net_device *dev,
+				       unsigned int start_from,
+				       unsigned int qpairs_num,
+				       struct sock *sk)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	unsigned int qpair_index;
+
+	/* allocate whatever availiable qpairs */
+	if (start_from == PACKET_QPAIRS_START_ANY) {
+		unsigned int count = 0;
+
+		for (qpair_index = adapter->num_rx_queues;
+		     qpair_index < MAX_RX_QUEUES;
+		     qpair_index++) {
+			if (!adapter->sk_handles[qpair_index]) {
+				count++;
+				if (count == qpairs_num) {
+					start_from = qpair_index - count + 1;
+					break;
+				}
+			} else {
+				count = 0;
+			}
+		}
+	}
+
+	/* otherwise the caller specified exact queues */
+	if ((start_from > MAX_TX_QUEUES) ||
+	    (start_from > MAX_RX_QUEUES) ||
+	    (start_from + qpairs_num > MAX_TX_QUEUES) ||
+	    (start_from + qpairs_num > MAX_RX_QUEUES))
+		return -EINVAL;
+
+	/* If the qpairs are being used by the driver do not let user space
+	 * consume the queues. Also if the queue has already been allocated
+	 * to a socket do fail the request.
+	 */
+	for (qpair_index = start_from;
+	     qpair_index < start_from + qpairs_num;
+	     qpair_index++) {
+		if ((qpair_index < adapter->num_tx_queues) ||
+		    (qpair_index < adapter->num_rx_queues))
+			return -EINVAL;
+
+		if (adapter->sk_handles[qpair_index] != NULL)
+			return -EBUSY;
+	}
+
+	/* remember the sk handle for each queue pair */
+	for (qpair_index = start_from;
+	     qpair_index < start_from + qpairs_num;
+	     qpair_index++)
+		adapter->sk_handles[qpair_index] = sk;
+
+	return start_from;
+}
+
+static int ixgbe_ndo_get_queue_pairs(struct net_device *dev,
+				     unsigned int *start_from,
+				     unsigned int *qpairs_num,
+				     struct sock *sk)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	unsigned int qpair_index;
+
+	*qpairs_num = 0;
+
+	for (qpair_index = adapter->num_tx_queues;
+	     qpair_index < MAX_RX_QUEUES;
+	     qpair_index++) {
+		if (adapter->sk_handles[qpair_index] == sk) {
+			if (*qpairs_num == 0)
+				*start_from = qpair_index;
+			*qpairs_num = *qpairs_num + 1;
+		}
+	}
+
+	return 0;
+}
+
+static int ixgbe_ndo_return_queue_pairs(struct net_device *dev, struct sock *sk)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	unsigned int qpair_index;
+
+	for (qpair_index = adapter->num_tx_queues;
+	     qpair_index < MAX_TX_QUEUES;
+	     qpair_index++) {
+		if (adapter->sk_handles[qpair_index] == sk)
+			adapter->sk_handles[qpair_index] = NULL;
+	}
+
+	return 0;
+}
+
+/* Rx descriptor starts from 0x1000 and Tx descriptor starts from 0x6000
+ * both the TX and RX descriptors use 4K pages.
+ */
+#define RX_DESC_ADDR_OFFSET		0x1000
+#define TX_DESC_ADDR_OFFSET		0x6000
+#define PAGE_SIZE_4K			4096
+
+static int
+ixgbe_ndo_qpair_map_region(struct net_device *dev,
+			   struct tpacket_dev_qpair_map_region_info *info)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+
+	/* no need to map systme memory to userspace for ixgbe */
+	info->tp_dev_sysm_sz = 0;
+	info->tp_num_sysm_map_regions = 0;
+
+	info->tp_dev_bar_sz = pci_resource_len(adapter->pdev, 0);
+	info->tp_num_map_regions = 2;
+
+	info->regions[0].page_offset = RX_DESC_ADDR_OFFSET;
+	info->regions[0].page_sz = PAGE_SIZE;
+	info->regions[0].page_cnt = 1;
+	info->regions[1].page_offset = TX_DESC_ADDR_OFFSET;
+	info->regions[1].page_sz = PAGE_SIZE;
+	info->regions[1].page_cnt = 1;
+
+	return 0;
+}
+
+static int ixgbe_ndo_get_device_desc_info(struct net_device *dev,
+					  struct tpacket_dev_info *dev_info)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	int max_queues;
+
+	max_queues = max(adapter->num_rx_queues, adapter->num_tx_queues);
+
+	dev_info->tp_device_id = adapter->hw.device_id;
+	dev_info->tp_vendor_id = adapter->hw.vendor_id;
+	dev_info->tp_subsystem_device_id = adapter->hw.subsystem_device_id;
+	dev_info->tp_subsystem_vendor_id = adapter->hw.subsystem_vendor_id;
+	dev_info->tp_revision_id = adapter->hw.revision_id;
+	dev_info->tp_numa_node = dev_to_node(&dev->dev);
+
+	dev_info->tp_num_total_qpairs = min(MAX_RX_QUEUES, MAX_TX_QUEUES);
+	dev_info->tp_num_inuse_qpairs = max_queues;
+
+	dev_info->tp_rxdesc_size = sizeof(union ixgbe_adv_rx_desc);
+	dev_info->tp_rxdesc_ver = 1;
+	dev_info->tp_txdesc_size = sizeof(union ixgbe_adv_tx_desc);
+	dev_info->tp_txdesc_ver = 1;
+
+	return 0;
+}
+
+static int
+ixgbe_ndo_qpair_page_map(struct vm_area_struct *vma, struct net_device *dev)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+	phys_addr_t phy_addr = pci_resource_start(adapter->pdev, 0);
+	unsigned long pfn_rx = (phy_addr + RX_DESC_ADDR_OFFSET) >> PAGE_SHIFT;
+	unsigned long pfn_tx = (phy_addr + TX_DESC_ADDR_OFFSET) >> PAGE_SHIFT;
+	unsigned long dummy_page_phy;
+	pgprot_t pre_vm_page_prot;
+	unsigned long start;
+	unsigned int i;
+	int err;
+
+	if (!dummy_page_buf) {
+		dummy_page_buf = kzalloc(PAGE_SIZE_4K, GFP_KERNEL);
+		if (!dummy_page_buf)
+			return -ENOMEM;
+
+		for (i = 0; i < PAGE_SIZE_4K / sizeof(unsigned int); i++)
+			dummy_page_buf[i] = 0xdeadbeef;
+	}
+
+	dummy_page_phy = virt_to_phys(dummy_page_buf);
+	pre_vm_page_prot = vma->vm_page_prot;
+	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
+
+	/* assume the vm_start is 4K aligned address */
+	for (start = vma->vm_start;
+	     start < vma->vm_end;
+	     start += PAGE_SIZE_4K) {
+		if (start == vma->vm_start + RX_DESC_ADDR_OFFSET) {
+			err = remap_pfn_range(vma, start, pfn_rx, PAGE_SIZE_4K,
+					      vma->vm_page_prot);
+			if (err)
+				return -EAGAIN;
+		} else if (start == vma->vm_start + TX_DESC_ADDR_OFFSET) {
+			err = remap_pfn_range(vma, start, pfn_tx, PAGE_SIZE_4K,
+					      vma->vm_page_prot);
+			if (err)
+				return -EAGAIN;
+		} else {
+			unsigned long addr = dummy_page_phy > PAGE_SHIFT;
+
+			err = remap_pfn_range(vma, start, addr, PAGE_SIZE_4K,
+					      pre_vm_page_prot);
+			if (err)
+				return -EAGAIN;
+		}
+	}
+	return 0;
+}
+
 static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_open		= ixgbe_open,
 	.ndo_stop		= ixgbe_close,
@@ -7856,6 +8075,12 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 	.ndo_bridge_getlink	= ixgbe_ndo_bridge_getlink,
 	.ndo_dfwd_add_station	= ixgbe_fwd_add,
 	.ndo_dfwd_del_station	= ixgbe_fwd_del,
+	.ndo_split_queue_pairs	= ixgbe_ndo_split_queue_pairs,
+	.ndo_get_queue_pairs	= ixgbe_ndo_get_queue_pairs,
+	.ndo_return_queue_pairs = ixgbe_ndo_return_queue_pairs,
+	.ndo_get_device_qpair_map_region_info = ixgbe_ndo_qpair_map_region,
+	.ndo_get_device_desc_info  = ixgbe_ndo_get_device_desc_info,
+	.ndo_direct_qpair_page_map = ixgbe_ndo_qpair_page_map,
 };
 
 /**
@@ -8054,7 +8279,9 @@ static int ixgbe_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	hw->back = adapter;
 	adapter->msg_enable = netif_msg_init(debug, DEFAULT_MSG_ENABLE);
 
-	hw->hw_addr = ioremap(pci_resource_start(pdev, 0),
+	hw->pci_hw_addr = pci_resource_start(pdev, 0);
+
+	hw->hw_addr = ioremap(hw->pci_hw_addr,
 			      pci_resource_len(pdev, 0));
 	adapter->io_addr = hw->hw_addr;
 	if (!hw->hw_addr) {
@@ -8705,6 +8932,7 @@ module_init(ixgbe_init_module);
  **/
 static void __exit ixgbe_exit_module(void)
 {
+	kfree(dummy_page_buf);
 #ifdef CONFIG_IXGBE_DCA
 	dca_unregister_notify(&dca_notifier);
 #endif
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
index dfd55d8..26e9163 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_type.h
@@ -3022,6 +3022,7 @@ struct ixgbe_mbx_info {
 
 struct ixgbe_hw {
 	u8 __iomem			*hw_addr;
+	phys_addr_t			pci_hw_addr;
 	void				*back;
 	struct ixgbe_mac_info		mac;
 	struct ixgbe_addr_filter_info	addr_ctrl;
