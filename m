From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v3 23/29] fm10k: Add support for VF
Date: Tue, 23 Sep 2014 04:16:51 -0700
Message-ID: <1411471017-28213-24-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:29323 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755798AbaIWLRY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Sep 2014 07:17:24 -0400
In-Reply-To: <1411471017-28213-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch provides the functions necessary to configure the VF making use
of the same API pointers as the PF.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/Makefile        |   2 +-
 drivers/net/ethernet/intel/fm10k/fm10k.h         |   4 +-
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 114 +++++
 drivers/net/ethernet/intel/fm10k/fm10k_mbx.c     |   4 +
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c  |  15 +
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c     | 102 ++++-
 drivers/net/ethernet/intel/fm10k/fm10k_type.h    |   9 +
 drivers/net/ethernet/intel/fm10k/fm10k_vf.c      | 523 +++++++++++++++++++++++
 drivers/net/ethernet/intel/fm10k/fm10k_vf.h      |  68 +++
 9 files changed, 837 insertions(+), 4 deletions(-)
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_vf.c
 create mode 100644 drivers/net/ethernet/intel/fm10k/fm10k_vf.h

diff --git a/drivers/net/ethernet/intel/fm10k/Makefile b/drivers/net/ethernet/intel/fm10k/Makefile
index b72815e..f70893a 100644
--- a/drivers/net/ethernet/intel/fm10k/Makefile
+++ b/drivers/net/ethernet/intel/fm10k/Makefile
@@ -28,5 +28,5 @@
 obj-$(CONFIG_FM10K) += fm10k.o
 
 fm10k-objs := fm10k_main.o fm10k_common.o fm10k_pci.o \
-	      fm10k_netdev.o fm10k_ethtool.o fm10k_pf.o \
+	      fm10k_netdev.o fm10k_ethtool.o fm10k_pf.o fm10k_vf.o \
 	      fm10k_mbx.o fm10k_tlv.o
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index 58c1475..639698c 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -28,6 +28,7 @@
 #include <linux/pci.h>
 
 #include "fm10k_pf.h"
+#include "fm10k_vf.h"
 
 #define FM10K_MAX_JUMBO_FRAME_SIZE	15358	/* Maximum supported size 15K */
 
@@ -180,12 +181,13 @@ static inline struct netdev_queue *txring_txq(const struct fm10k_ring *ring)
 #define MIN_Q_VECTORS	1
 enum fm10k_non_q_vectors {
 	FM10K_MBX_VECTOR,
+#define NON_Q_VECTORS_VF NON_Q_VECTORS_PF
 	NON_Q_VECTORS_PF
 };
 
 #define NON_Q_VECTORS(hw)	(((hw)->mac.type == fm10k_mac_pf) ? \
 						NON_Q_VECTORS_PF : \
-						0)
+						NON_Q_VECTORS_VF)
 #define MIN_MSIX_COUNT(hw)	(MIN_Q_VECTORS + NON_Q_VECTORS(hw))
 
 struct fm10k_q_vector {
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index 54e8ebd..42beb89 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -102,6 +102,17 @@ static const struct fm10k_stats fm10k_gstrings_stats[] = {
 			 FM10K_NETDEV_STATS_LEN + \
 			 FM10K_QUEUE_STATS_LEN)
 
+static const char fm10k_gstrings_test[][ETH_GSTRING_LEN] = {
+	"Mailbox test (on/offline)"
+};
+
+#define FM10K_TEST_LEN (sizeof(fm10k_gstrings_test) / ETH_GSTRING_LEN)
+
+enum fm10k_self_test_types {
+	FM10K_TEST_MBX,
+	FM10K_TEST_MAX = FM10K_TEST_LEN
+};
+
 static void fm10k_get_strings(struct net_device *dev, u32 stringset,
 			      u8 *data)
 {
@@ -109,6 +120,10 @@ static void fm10k_get_strings(struct net_device *dev, u32 stringset,
 	int i;
 
 	switch (stringset) {
+	case ETH_SS_TEST:
+		memcpy(data, *fm10k_gstrings_test,
+		       FM10K_TEST_LEN * ETH_GSTRING_LEN);
+		break;
 	case ETH_SS_STATS:
 		for (i = 0; i < FM10K_NETDEV_STATS_LEN; i++) {
 			memcpy(p, fm10k_gstrings_net_stats[i].stat_string,
@@ -138,6 +153,8 @@ static void fm10k_get_strings(struct net_device *dev, u32 stringset,
 static int fm10k_get_sset_count(struct net_device *dev, int sset)
 {
 	switch (sset) {
+	case ETH_SS_TEST:
+		return FM10K_TEST_LEN;
 	case ETH_SS_STATS:
 		return FM10K_STATS_LEN;
 	default:
@@ -288,6 +305,28 @@ static void fm10k_get_regs(struct net_device *netdev,
 			*(buff++) = fm10k_read_reg(hw, FM10K_ITR(i));
 
 		break;
+	case fm10k_mac_vf:
+		/* General VF registers */
+		*(buff++) = fm10k_read_reg(hw, FM10K_VFCTRL);
+		*(buff++) = fm10k_read_reg(hw, FM10K_VFINT_MAP);
+		*(buff++) = fm10k_read_reg(hw, FM10K_VFSYSTIME);
+
+		/* Interrupt Throttling Registers */
+		for (i = 0; i < 8; i++)
+			*(buff++) = fm10k_read_reg(hw, FM10K_VFITR(i));
+
+		fm10k_get_reg_vsi(hw, buff, 0);
+		buff += FM10K_REGS_LEN_VSI;
+
+		for (i = 0; i < FM10K_MAX_QUEUES_POOL; i++) {
+			if (i < hw->mac.max_queues)
+				fm10k_get_reg_q(hw, buff, i);
+			else
+				memset(buff, 0, sizeof(u32) * FM10K_REGS_LEN_Q);
+			buff += FM10K_REGS_LEN_Q;
+		}
+
+		break;
 	default:
 		return;
 	}
@@ -296,6 +335,8 @@ static void fm10k_get_regs(struct net_device *netdev,
 /* If function above adds more registers these define need to be updated */
 #define FM10K_REGS_LEN_PF \
 (162 + (65 * FM10K_REGS_LEN_VSI) + (FM10K_MAX_QUEUES_PF * FM10K_REGS_LEN_Q))
+#define FM10K_REGS_LEN_VF \
+(11 + FM10K_REGS_LEN_VSI + (FM10K_MAX_QUEUES_POOL * FM10K_REGS_LEN_Q))
 
 static int fm10k_get_regs_len(struct net_device *netdev)
 {
@@ -305,6 +346,8 @@ static int fm10k_get_regs_len(struct net_device *netdev)
 	switch (hw->mac.type) {
 	case fm10k_mac_pf:
 		return FM10K_REGS_LEN_PF * sizeof(u32);
+	case fm10k_mac_vf:
+		return FM10K_REGS_LEN_VF * sizeof(u32);
 	default:
 		return 0;
 	}
@@ -734,6 +777,76 @@ static int fm10k_set_rxnfc(struct net_device *dev, struct ethtool_rxnfc *cmd)
 	return ret;
 }
 
+static int fm10k_mbx_test(struct fm10k_intfc *interface, u64 *data)
+{
+	struct fm10k_hw *hw = &interface->hw;
+	struct fm10k_mbx_info *mbx = &hw->mbx;
+	u32 attr_flag, test_msg[6];
+	unsigned long timeout;
+	int err;
+
+	/* For now this is a VF only feature */
+	if (hw->mac.type != fm10k_mac_vf)
+		return 0;
+
+	/* loop through both nested and unnested attribute types */
+	for (attr_flag = (1 << FM10K_TEST_MSG_UNSET);
+	     attr_flag < (1 << (2 * FM10K_TEST_MSG_NESTED));
+	     attr_flag += attr_flag) {
+		/* generate message to be tested */
+		fm10k_tlv_msg_test_create(test_msg, attr_flag);
+
+		fm10k_mbx_lock(interface);
+		mbx->test_result = FM10K_NOT_IMPLEMENTED;
+		err = mbx->ops.enqueue_tx(hw, mbx, test_msg);
+		fm10k_mbx_unlock(interface);
+
+		/* wait up to 1 second for response */
+		timeout = jiffies + HZ;
+		do {
+			if (err < 0)
+				goto err_out;
+
+			usleep_range(500, 1000);
+
+			fm10k_mbx_lock(interface);
+			mbx->ops.process(hw, mbx);
+			fm10k_mbx_unlock(interface);
+
+			err = mbx->test_result;
+			if (!err)
+				break;
+		} while (time_is_after_jiffies(timeout));
+
+		/* reporting errors */
+		if (err)
+			goto err_out;
+	}
+
+err_out:
+	*data = err < 0 ? (attr_flag) : (err > 0);
+	return err;
+}
+
+static void fm10k_self_test(struct net_device *dev,
+			    struct ethtool_test *eth_test, u64 *data)
+{
+	struct fm10k_intfc *interface = netdev_priv(dev);
+	struct fm10k_hw *hw = &interface->hw;
+
+	memset(data, 0, sizeof(*data) * FM10K_TEST_LEN);
+
+	if (FM10K_REMOVED(hw)) {
+		netif_err(interface, drv, dev,
+			  "Interface removed - test blocked\n");
+		eth_test->flags |= ETH_TEST_FL_FAILED;
+		return;
+	}
+
+	if (fm10k_mbx_test(interface, &data[FM10K_TEST_MBX]))
+		eth_test->flags |= ETH_TEST_FL_FAILED;
+}
+
 static u32 fm10k_get_reta_size(struct net_device *netdev)
 {
 	return FM10K_RETA_SIZE * FM10K_RETA_ENTRIES_PER_REG;
@@ -911,6 +1024,7 @@ static const struct ethtool_ops fm10k_ethtool_ops = {
 	.set_rxnfc		= fm10k_set_rxnfc,
 	.get_regs               = fm10k_get_regs,
 	.get_regs_len           = fm10k_get_regs_len,
+	.self_test		= fm10k_self_test,
 	.get_rxfh_indir_size	= fm10k_get_reta_size,
 	.get_rxfh_key_size	= fm10k_get_rssrk_size,
 	.get_rxfh		= fm10k_get_rssh,
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
index a6a66fd..14a4ea7 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_mbx.c
@@ -1517,6 +1517,10 @@ s32 fm10k_pfvf_mbx_init(struct fm10k_hw *hw, struct fm10k_mbx_info *mbx,
 {
 	/* initialize registers */
 	switch (hw->mac.type) {
+	case fm10k_mac_vf:
+		mbx->mbx_reg = FM10K_VFMBX;
+		mbx->mbmem_reg = FM10K_VFMBMEM(FM10K_VFMBMEM_VF_XOR);
+		break;
 	case fm10k_mac_pf:
 		/* there are only 64 VF <-> PF mailboxes */
 		if (id < 64) {
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index 268966b..c0d6758 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -976,6 +976,21 @@ void fm10k_restore_rx_state(struct fm10k_intfc *interface)
 	int xcast_mode;
 	u16 vid, glort;
 
+	/* restore our address if perm_addr is set */
+	if (hw->mac.type == fm10k_mac_vf) {
+		if (is_valid_ether_addr(hw->mac.perm_addr)) {
+			ether_addr_copy(hw->mac.addr, hw->mac.perm_addr);
+			ether_addr_copy(netdev->perm_addr, hw->mac.perm_addr);
+			ether_addr_copy(netdev->dev_addr, hw->mac.perm_addr);
+			netdev->addr_assign_type &= ~NET_ADDR_RANDOM;
+		}
+
+		if (hw->mac.vlan_override)
+			netdev->features &= ~NETIF_F_HW_VLAN_CTAG_RX;
+		else
+			netdev->features |= NETIF_F_HW_VLAN_CTAG_RX;
+	}
+
 	/* record glort for this interface */
 	glort = interface->glort;
 
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
index d647814..9cc4d62 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_pci.c
@@ -25,6 +25,7 @@
 
 static const struct fm10k_info *fm10k_info_tbl[] = {
 	[fm10k_device_pf] = &fm10k_pf_info,
+	[fm10k_device_vf] = &fm10k_vf_info,
 };
 
 /**
@@ -38,6 +39,7 @@ static const struct fm10k_info *fm10k_info_tbl[] = {
  */
 static const struct pci_device_id fm10k_pci_tbl[] = {
 	{ PCI_VDEVICE(INTEL, FM10K_DEV_ID_PF), fm10k_device_pf },
+	{ PCI_VDEVICE(INTEL, FM10K_DEV_ID_VF), fm10k_device_vf },
 	/* required last entry */
 	{ 0, }
 };
@@ -805,6 +807,28 @@ static irqreturn_t fm10k_msix_clean_rings(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
+static irqreturn_t fm10k_msix_mbx_vf(int irq, void *data)
+{
+	struct fm10k_intfc *interface = data;
+	struct fm10k_hw *hw = &interface->hw;
+	struct fm10k_mbx_info *mbx = &hw->mbx;
+
+	/* re-enable mailbox interrupt and indicate 20us delay */
+	fm10k_write_reg(hw, FM10K_VFITR(FM10K_MBX_VECTOR),
+			FM10K_ITR_ENABLE | FM10K_MBX_INT_DELAY);
+
+	/* service upstream mailbox */
+	if (fm10k_mbx_trylock(interface)) {
+		mbx->ops.process(hw, mbx);
+		fm10k_mbx_unlock(interface);
+	}
+
+	hw->mac.get_host_state = 1;
+	fm10k_service_event_schedule(interface);
+
+	return IRQ_HANDLED;
+}
+
 #define FM10K_ERR_MSG(type) case (type): error = #type; break
 static void fm10k_print_fault(struct fm10k_intfc *interface, int type,
 			      struct fm10k_fault *fault)
@@ -996,6 +1020,8 @@ void fm10k_mbx_free_irq(struct fm10k_intfc *interface)
 				FM10K_EIMR_DISABLE(VFLR) |
 				FM10K_EIMR_DISABLE(MAXHOLDTIME));
 		itr_reg = FM10K_ITR(FM10K_MBX_VECTOR);
+	} else {
+		itr_reg = FM10K_VFITR(FM10K_MBX_VECTOR);
 	}
 
 	fm10k_write_reg(hw, itr_reg, FM10K_ITR_MASK_SET);
@@ -1003,6 +1029,33 @@ void fm10k_mbx_free_irq(struct fm10k_intfc *interface)
 	free_irq(entry->vector, interface);
 }
 
+static s32 fm10k_mbx_mac_addr(struct fm10k_hw *hw, u32 **results,
+			      struct fm10k_mbx_info *mbx)
+{
+	bool vlan_override = hw->mac.vlan_override;
+	u16 default_vid = hw->mac.default_vid;
+	struct fm10k_intfc *interface;
+	s32 err;
+
+	err = fm10k_msg_mac_vlan_vf(hw, results, mbx);
+	if (err)
+		return err;
+
+	interface = container_of(hw, struct fm10k_intfc, hw);
+
+	/* MAC was changed so we need reset */
+	if (is_valid_ether_addr(hw->mac.perm_addr) &&
+	    memcmp(hw->mac.perm_addr, hw->mac.addr, ETH_ALEN))
+		interface->flags |= FM10K_FLAG_RESET_REQUESTED;
+
+	/* VLAN override was changed, or default VLAN changed */
+	if ((vlan_override != hw->mac.vlan_override) ||
+	    (default_vid != hw->mac.default_vid))
+		interface->flags |= FM10K_FLAG_RESET_REQUESTED;
+
+	return 0;
+}
+
 /* generic error handler for mailbox issues */
 static s32 fm10k_mbx_error(struct fm10k_hw *hw, u32 **results,
 			   struct fm10k_mbx_info *mbx)
@@ -1019,6 +1072,46 @@ static s32 fm10k_mbx_error(struct fm10k_hw *hw, u32 **results,
 	return 0;
 }
 
+static const struct fm10k_msg_data vf_mbx_data[] = {
+	FM10K_TLV_MSG_TEST_HANDLER(fm10k_tlv_msg_test),
+	FM10K_VF_MSG_MAC_VLAN_HANDLER(fm10k_mbx_mac_addr),
+	FM10K_VF_MSG_LPORT_STATE_HANDLER(fm10k_msg_lport_state_vf),
+	FM10K_TLV_MSG_ERROR_HANDLER(fm10k_mbx_error),
+};
+
+static int fm10k_mbx_request_irq_vf(struct fm10k_intfc *interface)
+{
+	struct msix_entry *entry = &interface->msix_entries[FM10K_MBX_VECTOR];
+	struct net_device *dev = interface->netdev;
+	struct fm10k_hw *hw = &interface->hw;
+	int err;
+
+	/* Use timer0 for interrupt moderation on the mailbox */
+	u32 itr = FM10K_INT_MAP_TIMER0 | entry->entry;
+
+	/* register mailbox handlers */
+	err = hw->mbx.ops.register_handlers(&hw->mbx, vf_mbx_data);
+	if (err)
+		return err;
+
+	/* request the IRQ */
+	err = request_irq(entry->vector, fm10k_msix_mbx_vf, 0,
+			  dev->name, interface);
+	if (err) {
+		netif_err(interface, probe, dev,
+			  "request_irq for msix_mbx failed: %d\n", err);
+		return err;
+	}
+
+	/* map all of the interrupt sources */
+	fm10k_write_reg(hw, FM10K_VFINT_MAP, itr);
+
+	/* enable interrupt */
+	fm10k_write_reg(hw, FM10K_VFITR(entry->entry), FM10K_ITR_ENABLE);
+
+	return 0;
+}
+
 static s32 fm10k_lport_map(struct fm10k_hw *hw, u32 **results,
 			   struct fm10k_mbx_info *mbx)
 {
@@ -1142,7 +1235,10 @@ int fm10k_mbx_request_irq(struct fm10k_intfc *interface)
 	int err;
 
 	/* enable Mailbox cause */
-	err = fm10k_mbx_request_irq_pf(interface);
+	if (hw->mac.type == fm10k_mac_pf)
+		err = fm10k_mbx_request_irq_pf(interface);
+	else
+		err = fm10k_mbx_request_irq_vf(interface);
 
 	/* connect mailbox */
 	if (!err)
@@ -1220,7 +1316,9 @@ int fm10k_qv_request_irq(struct fm10k_intfc *interface)
 		}
 
 		/* Assign ITR register to q_vector */
-		q_vector->itr = &interface->uc_addr[FM10K_ITR(entry->entry)];
+		q_vector->itr = (hw->mac.type == fm10k_mac_pf) ?
+				&interface->uc_addr[FM10K_ITR(entry->entry)] :
+				&interface->uc_addr[FM10K_VFITR(entry->entry)];
 
 		/* request the IRQ */
 		err = request_irq(entry->vector, &fm10k_msix_clean_rings, 0,
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_type.h b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
index eda0c7c..cc1df60 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_type.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_type.h
@@ -351,6 +351,13 @@ struct fm10k_hw;
 #define FM10K_QUEUE_DISABLE_TIMEOUT		100
 #define FM10K_RESET_TIMEOUT			100
 
+/* VF registers */
+#define FM10K_VFCTRL		0x00000
+#define FM10K_VFCTRL_RST			0x00000008
+#define FM10K_VFINT_MAP		0x00030
+#define FM10K_VFSYSTIME		0x00040
+#define FM10K_VFITR(_n)		((_n) + 0x00060)
+
 enum fm10k_int_source {
 	fm10k_int_Mailbox	= 0,
 	fm10k_int_PCIeFault	= 1,
@@ -522,6 +529,7 @@ struct fm10k_mac_ops {
 enum fm10k_mac_type {
 	fm10k_mac_unknown = 0,
 	fm10k_mac_pf,
+	fm10k_mac_vf,
 	fm10k_num_macs
 };
 
@@ -561,6 +569,7 @@ enum fm10k_xcast_modes {
 
 enum fm10k_devices {
 	fm10k_device_pf,
+	fm10k_device_vf,
 };
 
 struct fm10k_info {
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_vf.c b/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
new file mode 100644
index 0000000..25c23fc
--- /dev/null
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_vf.c
@@ -0,0 +1,523 @@
+/* Intel Ethernet Switch Host Interface Driver
+ * Copyright(c) 2013 - 2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
+
+#include "fm10k_vf.h"
+
+/**
+ *  fm10k_stop_hw_vf - Stop Tx/Rx units
+ *  @hw: pointer to hardware structure
+ *
+ **/
+static s32 fm10k_stop_hw_vf(struct fm10k_hw *hw)
+{
+	u8 *perm_addr = hw->mac.perm_addr;
+	u32 bal = 0, bah = 0;
+	s32 err;
+	u16 i;
+
+	/* we need to disable the queues before taking further steps */
+	err = fm10k_stop_hw_generic(hw);
+	if (err)
+		return err;
+
+	/* If permenant address is set then we need to restore it */
+	if (is_valid_ether_addr(perm_addr)) {
+		bal = (((u32)perm_addr[3]) << 24) |
+		      (((u32)perm_addr[4]) << 16) |
+		      (((u32)perm_addr[5]) << 8);
+		bah = (((u32)0xFF)	   << 24) |
+		      (((u32)perm_addr[0]) << 16) |
+		      (((u32)perm_addr[1]) << 8) |
+		       ((u32)perm_addr[2]);
+	}
+
+	/* The queues have already been disabled so we just need to
+	 * update their base address registers
+	 */
+	for (i = 0; i < hw->mac.max_queues; i++) {
+		fm10k_write_reg(hw, FM10K_TDBAL(i), bal);
+		fm10k_write_reg(hw, FM10K_TDBAH(i), bah);
+		fm10k_write_reg(hw, FM10K_RDBAL(i), bal);
+		fm10k_write_reg(hw, FM10K_RDBAH(i), bah);
+	}
+
+	return 0;
+}
+
+/**
+ *  fm10k_reset_hw_vf - VF hardware reset
+ *  @hw: pointer to hardware structure
+ *
+ *  This function should return the hardare to a state similar to the
+ *  one it is in after just being initialized.
+ **/
+static s32 fm10k_reset_hw_vf(struct fm10k_hw *hw)
+{
+	s32 err;
+
+	/* shut down queues we own and reset DMA configuration */
+	err = fm10k_stop_hw_vf(hw);
+	if (err)
+		return err;
+
+	/* Inititate VF reset */
+	fm10k_write_reg(hw, FM10K_VFCTRL, FM10K_VFCTRL_RST);
+
+	/* Flush write and allow 100us for reset to complete */
+	fm10k_write_flush(hw);
+	udelay(FM10K_RESET_TIMEOUT);
+
+	/* Clear reset bit and verify it was cleared */
+	fm10k_write_reg(hw, FM10K_VFCTRL, 0);
+	if (fm10k_read_reg(hw, FM10K_VFCTRL) & FM10K_VFCTRL_RST)
+		err = FM10K_ERR_RESET_FAILED;
+
+	return err;
+}
+
+/**
+ *  fm10k_init_hw_vf - VF hardware initialization
+ *  @hw: pointer to hardware structure
+ *
+ **/
+static s32 fm10k_init_hw_vf(struct fm10k_hw *hw)
+{
+	u32 tqdloc, tqdloc0 = ~fm10k_read_reg(hw, FM10K_TQDLOC(0));
+	s32 err;
+	u16 i;
+
+	/* assume we always have at least 1 queue */
+	for (i = 1; tqdloc0 && (i < FM10K_MAX_QUEUES_POOL); i++) {
+		/* verify the Descriptor cache offsets are increasing */
+		tqdloc = ~fm10k_read_reg(hw, FM10K_TQDLOC(i));
+		if (!tqdloc || (tqdloc == tqdloc0))
+			break;
+
+		/* check to verify the PF doesn't own any of our queues */
+		if (!~fm10k_read_reg(hw, FM10K_TXQCTL(i)) ||
+		    !~fm10k_read_reg(hw, FM10K_RXQCTL(i)))
+			break;
+	}
+
+	/* shut down queues we own and reset DMA configuration */
+	err = fm10k_disable_queues_generic(hw, i);
+	if (err)
+		return err;
+
+	/* record maximum queue count */
+	hw->mac.max_queues = i;
+
+	return 0;
+}
+
+/**
+ *  fm10k_is_slot_appropriate_vf - Indicate appropriate slot for this SKU
+ *  @hw: pointer to hardware structure
+ *
+ *  Looks at the PCIe bus info to confirm whether or not this slot can support
+ *  the necessary bandwidth for this device. Since the VF has no control over
+ *  the "slot" it is in, always indicate that the slot is appropriate.
+ **/
+static bool fm10k_is_slot_appropriate_vf(struct fm10k_hw *hw)
+{
+	return true;
+}
+
+/* This structure defines the attibutes to be parsed below */
+const struct fm10k_tlv_attr fm10k_mac_vlan_msg_attr[] = {
+	FM10K_TLV_ATTR_U32(FM10K_MAC_VLAN_MSG_VLAN),
+	FM10K_TLV_ATTR_BOOL(FM10K_MAC_VLAN_MSG_SET),
+	FM10K_TLV_ATTR_MAC_ADDR(FM10K_MAC_VLAN_MSG_MAC),
+	FM10K_TLV_ATTR_MAC_ADDR(FM10K_MAC_VLAN_MSG_DEFAULT_MAC),
+	FM10K_TLV_ATTR_MAC_ADDR(FM10K_MAC_VLAN_MSG_MULTICAST),
+	FM10K_TLV_ATTR_LAST
+};
+
+/**
+ *  fm10k_update_vlan_vf - Update status of VLAN ID in VLAN filter table
+ *  @hw: pointer to hardware structure
+ *  @vid: VLAN ID to add to table
+ *  @vsi: Reserved, should always be 0
+ *  @set: Indicates if this is a set or clear operation
+ *
+ *  This function adds or removes the corresponding VLAN ID from the VLAN
+ *  filter table for this VF.
+ **/
+static s32 fm10k_update_vlan_vf(struct fm10k_hw *hw, u32 vid, u8 vsi, bool set)
+{
+	struct fm10k_mbx_info *mbx = &hw->mbx;
+	u32 msg[4];
+
+	/* verify the index is not set */
+	if (vsi)
+		return FM10K_ERR_PARAM;
+
+	/* verify upper 4 bits of vid and length are 0 */
+	if ((vid << 16 | vid) >> 28)
+		return FM10K_ERR_PARAM;
+
+	/* encode set bit into the VLAN ID */
+	if (!set)
+		vid |= FM10K_VLAN_CLEAR;
+
+	/* generate VLAN request */
+	fm10k_tlv_msg_init(msg, FM10K_VF_MSG_ID_MAC_VLAN);
+	fm10k_tlv_attr_put_u32(msg, FM10K_MAC_VLAN_MSG_VLAN, vid);
+
+	/* load onto outgoing mailbox */
+	return mbx->ops.enqueue_tx(hw, mbx, msg);
+}
+
+/**
+ *  fm10k_msg_mac_vlan_vf - Read device MAC address from mailbox message
+ *  @hw: pointer to the HW structure
+ *  @results: Attributes for message
+ *  @mbx: unused mailbox data
+ *
+ *  This function should determine the MAC address for the VF
+ **/
+s32 fm10k_msg_mac_vlan_vf(struct fm10k_hw *hw, u32 **results,
+			  struct fm10k_mbx_info *mbx)
+{
+	u8 perm_addr[ETH_ALEN];
+	u16 vid;
+	s32 err;
+
+	/* record MAC address requested */
+	err = fm10k_tlv_attr_get_mac_vlan(
+					results[FM10K_MAC_VLAN_MSG_DEFAULT_MAC],
+					perm_addr, &vid);
+	if (err)
+		return err;
+
+	ether_addr_copy(hw->mac.perm_addr, perm_addr);
+	hw->mac.default_vid = vid & (FM10K_VLAN_TABLE_VID_MAX - 1);
+	hw->mac.vlan_override = !!(vid & FM10K_VLAN_CLEAR);
+
+	return 0;
+}
+
+/**
+ *  fm10k_read_mac_addr_vf - Read device MAC address
+ *  @hw: pointer to the HW structure
+ *
+ *  This function should determine the MAC address for the VF
+ **/
+static s32 fm10k_read_mac_addr_vf(struct fm10k_hw *hw)
+{
+	u8 perm_addr[ETH_ALEN];
+	u32 base_addr;
+
+	base_addr = fm10k_read_reg(hw, FM10K_TDBAL(0));
+
+	/* last byte should be 0 */
+	if (base_addr << 24)
+		return  FM10K_ERR_INVALID_MAC_ADDR;
+
+	perm_addr[3] = (u8)(base_addr >> 24);
+	perm_addr[4] = (u8)(base_addr >> 16);
+	perm_addr[5] = (u8)(base_addr >> 8);
+
+	base_addr = fm10k_read_reg(hw, FM10K_TDBAH(0));
+
+	/* first byte should be all 1's */
+	if ((~base_addr) >> 24)
+		return  FM10K_ERR_INVALID_MAC_ADDR;
+
+	perm_addr[0] = (u8)(base_addr >> 16);
+	perm_addr[1] = (u8)(base_addr >> 8);
+	perm_addr[2] = (u8)(base_addr);
+
+	ether_addr_copy(hw->mac.perm_addr, perm_addr);
+	ether_addr_copy(hw->mac.addr, perm_addr);
+
+	return 0;
+}
+
+/**
+ *  fm10k_update_uc_addr_vf - Update device unicast address
+ *  @hw: pointer to the HW structure
+ *  @glort: unused
+ *  @mac: MAC address to add/remove from table
+ *  @vid: VLAN ID to add/remove from table
+ *  @add: Indicates if this is an add or remove operation
+ *  @flags: flags field to indicate add and secure - unused
+ *
+ *  This function is used to add or remove unicast MAC addresses for
+ *  the VF.
+ **/
+static s32 fm10k_update_uc_addr_vf(struct fm10k_hw *hw, u16 glort,
+				   const u8 *mac, u16 vid, bool add, u8 flags)
+{
+	struct fm10k_mbx_info *mbx = &hw->mbx;
+	u32 msg[7];
+
+	/* verify VLAN ID is valid */
+	if (vid >= FM10K_VLAN_TABLE_VID_MAX)
+		return FM10K_ERR_PARAM;
+
+	/* verify MAC address is valid */
+	if (!is_valid_ether_addr(mac))
+		return FM10K_ERR_PARAM;
+
+	/* verify we are not locked down on the MAC address */
+	if (is_valid_ether_addr(hw->mac.perm_addr) &&
+	    memcmp(hw->mac.perm_addr, mac, ETH_ALEN))
+		return FM10K_ERR_PARAM;
+
+	/* add bit to notify us if this is a set of clear operation */
+	if (!add)
+		vid |= FM10K_VLAN_CLEAR;
+
+	/* generate VLAN request */
+	fm10k_tlv_msg_init(msg, FM10K_VF_MSG_ID_MAC_VLAN);
+	fm10k_tlv_attr_put_mac_vlan(msg, FM10K_MAC_VLAN_MSG_MAC, mac, vid);
+
+	/* load onto outgoing mailbox */
+	return mbx->ops.enqueue_tx(hw, mbx, msg);
+}
+
+/**
+ *  fm10k_update_mc_addr_vf - Update device multicast address
+ *  @hw: pointer to the HW structure
+ *  @glort: unused
+ *  @mac: MAC address to add/remove from table
+ *  @vid: VLAN ID to add/remove from table
+ *  @add: Indicates if this is an add or remove operation
+ *
+ *  This function is used to add or remove multicast MAC addresses for
+ *  the VF.
+ **/
+static s32 fm10k_update_mc_addr_vf(struct fm10k_hw *hw, u16 glort,
+				   const u8 *mac, u16 vid, bool add)
+{
+	struct fm10k_mbx_info *mbx = &hw->mbx;
+	u32 msg[7];
+
+	/* verify VLAN ID is valid */
+	if (vid >= FM10K_VLAN_TABLE_VID_MAX)
+		return FM10K_ERR_PARAM;
+
+	/* verify multicast address is valid */
+	if (!is_multicast_ether_addr(mac))
+		return FM10K_ERR_PARAM;
+
+	/* add bit to notify us if this is a set of clear operation */
+	if (!add)
+		vid |= FM10K_VLAN_CLEAR;
+
+	/* generate VLAN request */
+	fm10k_tlv_msg_init(msg, FM10K_VF_MSG_ID_MAC_VLAN);
+	fm10k_tlv_attr_put_mac_vlan(msg, FM10K_MAC_VLAN_MSG_MULTICAST,
+				    mac, vid);
+
+	/* load onto outgoing mailbox */
+	return mbx->ops.enqueue_tx(hw, mbx, msg);
+}
+
+/**
+ *  fm10k_update_int_moderator_vf - Request update of interrupt moderator list
+ *  @hw: pointer to hardware structure
+ *
+ *  This function will issue a request to the PF to rescan our MSI-X table
+ *  and to update the interrupt moderator linked list.
+ **/
+static void fm10k_update_int_moderator_vf(struct fm10k_hw *hw)
+{
+	struct fm10k_mbx_info *mbx = &hw->mbx;
+	u32 msg[1];
+
+	/* generate MSI-X request */
+	fm10k_tlv_msg_init(msg, FM10K_VF_MSG_ID_MSIX);
+
+	/* load onto outgoing mailbox */
+	mbx->ops.enqueue_tx(hw, mbx, msg);
+}
+
+/* This structure defines the attibutes to be parsed below */
+const struct fm10k_tlv_attr fm10k_lport_state_msg_attr[] = {
+	FM10K_TLV_ATTR_BOOL(FM10K_LPORT_STATE_MSG_DISABLE),
+	FM10K_TLV_ATTR_U8(FM10K_LPORT_STATE_MSG_XCAST_MODE),
+	FM10K_TLV_ATTR_BOOL(FM10K_LPORT_STATE_MSG_READY),
+	FM10K_TLV_ATTR_LAST
+};
+
+/**
+ *  fm10k_msg_lport_state_vf - Message handler for lport_state message from PF
+ *  @hw: Pointer to hardware structure
+ *  @results: pointer array containing parsed data
+ *  @mbx: Pointer to mailbox information structure
+ *
+ *  This handler is meant to capture the indication from the PF that we
+ *  are ready to bring up the interface.
+ **/
+s32 fm10k_msg_lport_state_vf(struct fm10k_hw *hw, u32 **results,
+			     struct fm10k_mbx_info *mbx)
+{
+	hw->mac.dglort_map = !results[FM10K_LPORT_STATE_MSG_READY] ?
+			     FM10K_DGLORTMAP_NONE : FM10K_DGLORTMAP_ZERO;
+
+	return 0;
+}
+
+/**
+ *  fm10k_update_lport_state_vf - Update device state in lower device
+ *  @hw: pointer to the HW structure
+ *  @glort: unused
+ *  @count: number of logical ports to enable - unused (always 1)
+ *  @enable: boolean value indicating if this is an enable or disable request
+ *
+ *  Notify the lower device of a state change.  If the lower device is
+ *  enabled we can add filters, if it is disabled all filters for this
+ *  logical port are flushed.
+ **/
+static s32 fm10k_update_lport_state_vf(struct fm10k_hw *hw, u16 glort,
+				       u16 count, bool enable)
+{
+	struct fm10k_mbx_info *mbx = &hw->mbx;
+	u32 msg[2];
+
+	/* reset glort mask 0 as we have to wait to be enabled */
+	hw->mac.dglort_map = FM10K_DGLORTMAP_NONE;
+
+	/* generate port state request */
+	fm10k_tlv_msg_init(msg, FM10K_VF_MSG_ID_LPORT_STATE);
+	if (!enable)
+		fm10k_tlv_attr_put_bool(msg, FM10K_LPORT_STATE_MSG_DISABLE);
+
+	/* load onto outgoing mailbox */
+	return mbx->ops.enqueue_tx(hw, mbx, msg);
+}
+
+/**
+ *  fm10k_update_xcast_mode_vf - Request update of multicast mode
+ *  @hw: pointer to hardware structure
+ *  @glort: unused
+ *  @mode: integer value indicating mode being requested
+ *
+ *  This function will attempt to request a higher mode for the port
+ *  so that it can enable either multicast, multicast promiscuous, or
+ *  promiscuous mode of operation.
+ **/
+static s32 fm10k_update_xcast_mode_vf(struct fm10k_hw *hw, u16 glort, u8 mode)
+{
+	struct fm10k_mbx_info *mbx = &hw->mbx;
+	u32 msg[3];
+
+	if (mode > FM10K_XCAST_MODE_NONE)
+		return FM10K_ERR_PARAM;
+	/* generate message requesting to change xcast mode */
+	fm10k_tlv_msg_init(msg, FM10K_VF_MSG_ID_LPORT_STATE);
+	fm10k_tlv_attr_put_u8(msg, FM10K_LPORT_STATE_MSG_XCAST_MODE, mode);
+
+	/* load onto outgoing mailbox */
+	return mbx->ops.enqueue_tx(hw, mbx, msg);
+}
+
+/**
+ *  fm10k_update_hw_stats_vf - Updates hardware related statistics of VF
+ *  @hw: pointer to hardware structure
+ *  @stats: pointer to statistics structure
+ *
+ *  This function collects and aggregates per queue hardware statistics.
+ **/
+static void fm10k_update_hw_stats_vf(struct fm10k_hw *hw,
+				     struct fm10k_hw_stats *stats)
+{
+	fm10k_update_hw_stats_q(hw, stats->q, 0, hw->mac.max_queues);
+}
+
+/**
+ *  fm10k_rebind_hw_stats_vf - Resets base for hardware statistics of VF
+ *  @hw: pointer to hardware structure
+ *  @stats: pointer to the stats structure to update
+ *
+ *  This function resets the base for queue hardware statistics.
+ **/
+static void fm10k_rebind_hw_stats_vf(struct fm10k_hw *hw,
+				     struct fm10k_hw_stats *stats)
+{
+	/* Unbind Queue Statistics */
+	fm10k_unbind_hw_stats_q(stats->q, 0, hw->mac.max_queues);
+
+	/* Reinitialize bases for all stats */
+	fm10k_update_hw_stats_vf(hw, stats);
+}
+
+/**
+ *  fm10k_configure_dglort_map_vf - Configures GLORT entry and queues
+ *  @hw: pointer to hardware structure
+ *  @dglort: pointer to dglort configuration structure
+ *
+ *  Reads the configuration structure contained in dglort_cfg and uses
+ *  that information to then populate a DGLORTMAP/DEC entry and the queues
+ *  to which it has been assigned.
+ **/
+static s32 fm10k_configure_dglort_map_vf(struct fm10k_hw *hw,
+					 struct fm10k_dglort_cfg *dglort)
+{
+	/* verify the dglort pointer */
+	if (!dglort)
+		return FM10K_ERR_PARAM;
+
+	/* stub for now until we determine correct message for this */
+
+	return 0;
+}
+
+static const struct fm10k_msg_data fm10k_msg_data_vf[] = {
+	FM10K_TLV_MSG_TEST_HANDLER(fm10k_tlv_msg_test),
+	FM10K_VF_MSG_MAC_VLAN_HANDLER(fm10k_msg_mac_vlan_vf),
+	FM10K_VF_MSG_LPORT_STATE_HANDLER(fm10k_msg_lport_state_vf),
+	FM10K_TLV_MSG_ERROR_HANDLER(fm10k_tlv_msg_error),
+};
+
+static struct fm10k_mac_ops mac_ops_vf = {
+	.get_bus_info		= &fm10k_get_bus_info_generic,
+	.reset_hw		= &fm10k_reset_hw_vf,
+	.init_hw		= &fm10k_init_hw_vf,
+	.start_hw		= &fm10k_start_hw_generic,
+	.stop_hw		= &fm10k_stop_hw_vf,
+	.is_slot_appropriate	= &fm10k_is_slot_appropriate_vf,
+	.update_vlan		= &fm10k_update_vlan_vf,
+	.read_mac_addr		= &fm10k_read_mac_addr_vf,
+	.update_uc_addr		= &fm10k_update_uc_addr_vf,
+	.update_mc_addr		= &fm10k_update_mc_addr_vf,
+	.update_xcast_mode	= &fm10k_update_xcast_mode_vf,
+	.update_int_moderator	= &fm10k_update_int_moderator_vf,
+	.update_lport_state	= &fm10k_update_lport_state_vf,
+	.update_hw_stats	= &fm10k_update_hw_stats_vf,
+	.rebind_hw_stats	= &fm10k_rebind_hw_stats_vf,
+	.configure_dglort_map	= &fm10k_configure_dglort_map_vf,
+	.get_host_state		= &fm10k_get_host_state_generic,
+};
+
+static s32 fm10k_get_invariants_vf(struct fm10k_hw *hw)
+{
+	fm10k_get_invariants_generic(hw);
+
+	return fm10k_pfvf_mbx_init(hw, &hw->mbx, fm10k_msg_data_vf, 0);
+}
+
+struct fm10k_info fm10k_vf_info = {
+	.mac		= fm10k_mac_vf,
+	.get_invariants	= &fm10k_get_invariants_vf,
+	.mac_ops	= &mac_ops_vf,
+};
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_vf.h b/drivers/net/ethernet/intel/fm10k/fm10k_vf.h
new file mode 100644
index 0000000..8e96ee5
--- /dev/null
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_vf.h
@@ -0,0 +1,68 @@
+/* Intel Ethernet Switch Host Interface Driver
+ * Copyright(c) 2013 - 2014 Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * The full GNU General Public License is included in this distribution in
+ * the file called "COPYING".
+ *
+ * Contact Information:
+ * e1000-devel Mailing List <e1000-devel@lists.sourceforge.net>
+ * Intel Corporation, 5200 N.E. Elam Young Parkway, Hillsboro, OR 97124-6497
+ */
+
+#ifndef _FM10K_VF_H_
+#define _FM10K_VF_H_
+
+#include "fm10k_type.h"
+#include "fm10k_common.h"
+
+enum fm10k_vf_tlv_msg_id {
+	FM10K_VF_MSG_ID_TEST = 0,	/* msg ID reserved for testing */
+	FM10K_VF_MSG_ID_MSIX,
+	FM10K_VF_MSG_ID_MAC_VLAN,
+	FM10K_VF_MSG_ID_LPORT_STATE,
+	FM10K_VF_MSG_ID_MAX,
+};
+
+enum fm10k_tlv_mac_vlan_attr_id {
+	FM10K_MAC_VLAN_MSG_VLAN,
+	FM10K_MAC_VLAN_MSG_SET,
+	FM10K_MAC_VLAN_MSG_MAC,
+	FM10K_MAC_VLAN_MSG_DEFAULT_MAC,
+	FM10K_MAC_VLAN_MSG_MULTICAST,
+	FM10K_MAC_VLAN_MSG_ID_MAX
+};
+
+enum fm10k_tlv_lport_state_attr_id {
+	FM10K_LPORT_STATE_MSG_DISABLE,
+	FM10K_LPORT_STATE_MSG_XCAST_MODE,
+	FM10K_LPORT_STATE_MSG_READY,
+	FM10K_LPORT_STATE_MSG_MAX
+};
+
+#define FM10K_VF_MSG_MSIX_HANDLER(func) \
+	 FM10K_MSG_HANDLER(FM10K_VF_MSG_ID_MSIX, NULL, func)
+
+s32 fm10k_msg_mac_vlan_vf(struct fm10k_hw *, u32 **, struct fm10k_mbx_info *);
+extern const struct fm10k_tlv_attr fm10k_mac_vlan_msg_attr[];
+#define FM10K_VF_MSG_MAC_VLAN_HANDLER(func) \
+	FM10K_MSG_HANDLER(FM10K_VF_MSG_ID_MAC_VLAN, \
+			  fm10k_mac_vlan_msg_attr, func)
+
+s32 fm10k_msg_lport_state_vf(struct fm10k_hw *, u32 **,
+			     struct fm10k_mbx_info *);
+extern const struct fm10k_tlv_attr fm10k_lport_state_msg_attr[];
+#define FM10K_VF_MSG_LPORT_STATE_HANDLER(func) \
+	FM10K_MSG_HANDLER(FM10K_VF_MSG_ID_LPORT_STATE, \
+			  fm10k_lport_state_msg_attr, func)
+
+extern struct fm10k_info fm10k_vf_info;
+#endif /* _FM10K_VF_H */
-- 
1.9.3
