From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 25/26] atl1: add NAPI support
Date: Mon, 31 Dec 2007 20:22:52 -0600
Message-ID: <1199154173-4058-26-git-send-email-jacliburn@bellsouth.net>
References: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Cc: Jay Cliburn <jacliburn@bellsouth.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost03.isp.att.net ([207.115.11.53]:64476 "EHLO
	fmailhost03.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751980AbYAAC2N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 21:28:13 -0500
In-Reply-To: <1199154173-4058-1-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for NAPI, styled after the e1000 NAPI implementation.  That we
follow the e1000 for NAPI shouldn't come as much of a surprise, since the
entire atl1 driver is based heavily upon it.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/Kconfig     |   14 ++++
 drivers/net/atlx/atl1.c |  151 +++++++++++++++++++++++++++++++++++++++++++++--
 drivers/net/atlx/atl1.h |   20 ++++++
 drivers/net/atlx/atlx.h |    7 ++-
 4 files changed, 186 insertions(+), 6 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index d9107e5..095629f 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2371,6 +2371,20 @@ config ATL1
 	  To compile this driver as a module, choose M here.  The module
 	  will be called atl1.
 
+config ATL1_NAPI
+	bool "Use Rx Polling (NAPI) (EXPERIMENTAL)"
+	depends on ATL1 && EXPERIMENTAL
+	help
+	  NAPI is a new driver API designed to reduce CPU and interrupt load
+	  when the driver is receiving lots of packets from the card. It is
+	  still somewhat experimental and thus not yet enabled by default.
+
+	  If your estimated Rx load is 10kpps or more, or if the card will be
+	  deployed on potentially unfriendly networks (e.g. in a firewall),
+	  then say Y here.
+
+	  If in doubt, say N.
+
 endif # NETDEV_1000
 
 #
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 237622e..10bccf6 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -756,7 +756,16 @@ static void atl1_set_mac_addr(struct atl1_hw *hw)
 
 static int atl1_alloc_queues(struct atl1_adapter *adapter)
 {
-	/* temporary placeholder function for NAPI */
+#ifdef CONFIG_ATL1_NAPI
+	int size;
+
+	size = sizeof(struct net_device) * adapter->num_rx_queues;
+	adapter->polling_netdev = kmalloc(size, GFP_KERNEL);
+	if (!adapter->polling_netdev)
+		return -ENOMEM;
+
+	memset(adapter->polling_netdev, 0, size);
+#endif
 
 	return 0;
 }
@@ -770,6 +779,9 @@ static int __devinit atl1_sw_init(struct atl1_adapter *adapter)
 	struct atl1_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
 	int err;
+#ifdef CONFIG_ATL1_NAPI
+	int i;
+#endif
 
 	hw->max_frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
 	hw->min_frame_size = ETH_ZLEN + ETH_FCS_LEN;
@@ -818,6 +830,14 @@ static int __devinit atl1_sw_init(struct atl1_adapter *adapter)
 		return -ENOMEM;
 	}
 
+#ifdef CONFIG_ATL1_NAPI
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		adapter->polling_netdev[i].priv = adapter;
+		dev_hold(&adapter->polling_netdev[i]);
+		set_bit(__LINK_STATE_START, &adapter->polling_netdev[i].state);
+	}
+#endif
+
 	spin_lock_init(&adapter->lock);
 	spin_lock_init(&adapter->mb_lock);
 	set_bit(__ATL1_DOWN, &adapter->flags);
@@ -1698,7 +1718,12 @@ next:
 	return num_alloc;
 }
 
+#ifdef CONFIG_ATL1_NAPI
+static void atl1_clean_rx_irq(struct atl1_adapter *adapter, int *work_done,
+	int work_to_do)
+#else
 static void atl1_clean_rx_irq(struct atl1_adapter *adapter)
+#endif
 {
 	struct net_device *netdev = adapter->netdev;
 	int i, count;
@@ -1768,6 +1793,11 @@ chk_rrd:
 			break;
 		}
 rrd_ok:
+#ifdef CONFIG_ATL1_NAPI
+		if (*work_done >= work_to_do)
+			break;
+		(*work_done)++;
+#endif
 		/* clean alloc flag for bad rrd */
 		atl1_clean_alloc_flag(adapter, rrd, 0);
 
@@ -1808,6 +1838,16 @@ rrd_ok:
 		atl1_rx_checksum(adapter, rrd, skb);
 		skb->protocol = eth_type_trans(skb, adapter->netdev);
 
+#ifdef CONFIG_ATL1_NAPI
+		if (adapter->vlgrp && (rrd->pkt_flg & PACKET_FLAG_VLAN_INS)) {
+			u16 vlan_tag = (rrd->vlan_tag >> 4) |
+					((rrd->vlan_tag & 7) << 13) |
+					((rrd->vlan_tag & 8) << 9);
+			vlan_hwaccel_receive_skb(skb, adapter->vlgrp, vlan_tag);
+		} else
+			netif_receive_skb(skb);
+
+#else
 		if (adapter->vlgrp && (rrd->pkt_flg & PACKET_FLAG_VLAN_INS)) {
 			u16 vlan_tag = (rrd->vlan_tag >> 4) |
 					((rrd->vlan_tag & 7) << 13) |
@@ -1815,6 +1855,7 @@ rrd_ok:
 			vlan_hwaccel_rx(skb, adapter->vlgrp, vlan_tag);
 		} else
 			netif_rx(skb);
+#endif
 
 		/* let protocol layer free skb */
 		buffer_info->skb = NULL;
@@ -1837,6 +1878,9 @@ static bool atl1_clean_tx_irq(struct atl1_adapter *adapter)
 	struct atl1_buffer *buffer_info;
 	u16 sw_tpd_next_to_clean;
 	u16 cmb_tpd_next_to_clean;
+#ifdef CONFIG_ATL1_NAPI
+	unsigned int count = 0;
+#endif
 
 	sw_tpd_next_to_clean = atomic_read(&tpd_ring->next_to_clean);
 	cmb_tpd_next_to_clean = le16_to_cpu(adapter->cmb.cmb->tpd_cons_idx);
@@ -1859,6 +1903,10 @@ static bool atl1_clean_tx_irq(struct atl1_adapter *adapter)
 
 		if (++sw_tpd_next_to_clean == tpd_ring->count)
 			sw_tpd_next_to_clean = 0;
+#ifdef CONFIG_ATL1_NAPI
+		if (count++ == ATL1_NAPI_WEIGHT)
+			break;
+#endif
 	}
 	atomic_set(&tpd_ring->next_to_clean, sw_tpd_next_to_clean);
 
@@ -1872,6 +1920,40 @@ static bool atl1_clean_tx_irq(struct atl1_adapter *adapter)
 		return false;
 }
 
+#ifdef CONFIG_ATL1_NAPI
+static int atl1_clean(struct napi_struct *napi, int budget)
+{
+	struct atl1_adapter *adapter = container_of(napi, struct atl1_adapter,
+		napi);
+	struct net_device *poll_dev = adapter->netdev;
+	int work_done = 0;
+	int tx_cleaned = 0;
+
+	adapter = poll_dev->priv;
+
+	if (!netif_carrier_ok(poll_dev))
+		goto quit_polling;
+
+	if (spin_trylock(&adapter->lock)) {
+		tx_cleaned = atl1_clean_tx_irq(adapter);
+		spin_unlock(&adapter->lock);
+	}
+
+	atl1_clean_rx_irq(adapter, &work_done, budget);
+
+	if ((!tx_cleaned && (work_done == 0)) ||
+		!netif_running(poll_dev)) {
+quit_polling:
+		netif_rx_complete(poll_dev, napi);
+
+		if (!test_bit(__ATL1_DOWN, &adapter->flags))
+			atlx_irq_enable(adapter);
+	}
+
+	return work_done;
+}
+#endif
+
 static u16 atl1_tpd_avail(struct atl1_tpd_ring *tpd_ring)
 {
 	u16 next_to_clean = atomic_read(&tpd_ring->next_to_clean);
@@ -2175,7 +2257,6 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	if (!spin_trylock_irqsave(&adapter->lock, flags)) {
 		/* Can't get lock - tell upper layer to requeue */
-		dev_printk(KERN_DEBUG, &adapter->pdev->dev, "tx locked\n");
 		return NETDEV_TX_LOCKED;
 	}
 
@@ -2183,7 +2264,6 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		/* not enough descriptors */
 		netif_stop_queue(netdev);
 		spin_unlock_irqrestore(&adapter->lock, flags);
-		dev_printk(KERN_DEBUG, &adapter->pdev->dev, "tx busy\n");
 		return NETDEV_TX_BUSY;
 	}
 
@@ -2232,16 +2312,21 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
  */
 static irqreturn_t atl1_intr(int irq, void *data)
 {
+	struct net_device *netdev = data;
 	struct atl1_adapter *adapter = netdev_priv(data);
 	struct atl1_hw *hw = &adapter->hw;
 	u32 status;
-	int max_ints = 10;
+#ifndef CONFIG_ATL1_NAPI
+	int max_ints = 12;
+#endif
 
 	status = adapter->cmb.cmb->int_stats;
 	if (!status)
 		return IRQ_NONE;
 
+#ifndef CONFIG_ATL1_NAPI
 loopint:
+#endif
 	/* clear CMB interrupt status at once */
 	adapter->cmb.cmb->int_stats = 0;
 
@@ -2256,7 +2341,7 @@ loopint:
 	if (status & ISR_PHY_LINKDOWN) {
 		dev_printk(KERN_DEBUG, &adapter->pdev->dev,
 			"pcie phy link down %x\n", status);
-		if (netif_running(adapter->netdev)) {
+		if (netif_running(netdev)) {
 			/* reset MAC */
 			iowrite32(0, hw->hw_addr + REG_ISR);
 			iowrite32(0, hw->hw_addr + REG_IMR);
@@ -2292,6 +2377,24 @@ loopint:
 	if (status & ISR_TX_EVENT)
 		atl1_clean_tx_irq(adapter);
 
+#ifdef CONFIG_ATL1_NAPI
+	if (status & ISR_RX_EVENT) {
+		struct atl1_rrd_ring *rrd_ring = &adapter->rrd_ring;
+		struct rx_return_desc *rrd;
+		rrd = ATL1_RRD_DESC(rrd_ring,
+			((u16) atomic_read(&rrd_ring->next_to_clean)));
+		if (rrd->xsz.valid) {
+			/* valid packet */
+			iowrite32(IMR_NONRX_MASK, hw->hw_addr + REG_IMR);
+			ioread32(hw->hw_addr + REG_IMR);
+
+			if (netif_rx_schedule_prep(netdev, &adapter->napi))
+				__netif_rx_schedule(netdev, &adapter->napi);
+			else
+				atlx_irq_enable(adapter);
+		}
+	}
+#else
 	/* rx event */
 	if (status & ISR_RX_EVENT)
 		atl1_clean_rx_irq(adapter);
@@ -2299,6 +2402,7 @@ loopint:
 	status = adapter->cmb.cmb->int_stats;
 	if ((--max_ints > 0) && status)
 		goto loopint;
+#endif
 
 	/* re-enable interrupts */
 	iowrite32((ISR_DIS_SMB | ISR_DIS_DMA), adapter->hw.hw_addr + REG_ISR);
@@ -2375,6 +2479,10 @@ static s32 atl1_up(struct atl1_adapter *adapter)
 	retval = ioread32(&adapter->hw + REG_MASTER_CTRL);
 	retval |= MASTER_CTRL_MANUAL_INT;
 	iowrite32(retval, &adapter->hw + REG_MASTER_CTRL);
+
+#ifdef CONFIG_ATL1_NAPI
+	napi_enable(&adapter->napi);
+#endif
 	atlx_irq_enable(adapter);
 
 	return 0;
@@ -2389,6 +2497,10 @@ void atl1_down(struct atl1_adapter *adapter)
 	atl1_reset_hw(&adapter->hw);
 	adapter->cmb.cmb->int_stats = 0;
 	msleep(1);
+
+#ifdef CONFIG_ATL1_NAPI
+	napi_disable(&adapter->napi);
+#endif
 	atlx_irq_disable(adapter);
 	del_timer_sync(&adapter->watchdog_timer);
 	del_timer_sync(&adapter->phy_config_timer);
@@ -2528,6 +2640,10 @@ static int atl1_open(struct net_device *netdev)
 		goto err_open;
 
 	clear_bit(__ATL1_DOWN, &adapter->flags);
+
+#ifdef CONFIG_ATL1_NAPI
+	napi_enable(&adapter->napi);
+#endif
 	mod_timer(&adapter->watchdog_timer, jiffies + (4 * HZ));
 	val = ioread32(hw->hw_addr + REG_MASTER_CTRL);
 	val |= MASTER_CTRL_MANUAL_INT;
@@ -2736,6 +2852,9 @@ static void atl1_netpoll(struct net_device *netdev)
 	disable_irq(adapter->pdev->irq);
 	atl1_intr(netdev->irq, netdev);
 	atl1_clean_tx_irq(adapter);
+#ifndef CONFIG_ATL1_NAPI
+	atl1_clean_rx_irq(adapter);
+#endif
 	enable_irq(adapter->pdev->irq);
 }
 #endif
@@ -2758,6 +2877,9 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	struct atl1_adapter *adapter;
 	static int cards_found = 0;
 	int err;
+#ifdef CONFIG_ATL1_NAPI
+	int i;
+#endif
 
 	err = pci_enable_device(pdev);
 	if (err)
@@ -2836,6 +2958,9 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	netdev->do_ioctl = &atlx_ioctl;
 	netdev->tx_timeout = &atlx_tx_timeout;
 	netdev->watchdog_timeo = 5 * HZ;
+#ifdef CONFIG_ATL1_NAPI
+	netif_napi_add(netdev, &adapter->napi, &atl1_clean, ATL1_NAPI_WEIGHT);
+#endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	netdev->poll_controller = atl1_netpoll;
 #endif
@@ -2893,6 +3018,13 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	return 0;
 
 err_common:
+#ifdef CONFIG_ATL1_NAPI
+	if (adapter->polling_netdev) {
+		for (i = 0; i < adapter->num_rx_queues; i++)
+			dev_put(&adapter->polling_netdev[i]);
+		kfree(adapter->polling_netdev);
+	}
+#endif
 	pci_iounmap(pdev, adapter->hw.hw_addr);
 err_pci_iomap:
 	free_netdev(netdev);
@@ -2917,6 +3049,9 @@ static void __devexit atl1_remove(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct atl1_adapter *adapter = netdev_priv(netdev);
+#ifdef CONFIG_ATL1_NAPI
+	int i;
+#endif
 
 	/*
 	 * Some atl1 boards lack persistent storage for their MAC, and get it
@@ -2934,6 +3069,12 @@ static void __devexit atl1_remove(struct pci_dev *pdev)
 	del_timer_sync(&adapter->phy_config_timer);
 	flush_scheduled_work();
 	unregister_netdev(netdev);
+
+#ifdef CONFIG_ATL1_NAPI
+	for (i = 0; i < adapter->num_rx_queues; i++)
+		dev_put(&adapter->polling_netdev[i]);
+	kfree(adapter->polling_netdev);
+#endif
 	atl1_force_ps(&adapter->hw);
 	pci_iounmap(pdev, adapter->hw.hw_addr);
 	pci_release_regions(pdev);
diff --git a/drivers/net/atlx/atl1.h b/drivers/net/atlx/atl1.h
index 5187f74..a1757a9 100644
--- a/drivers/net/atlx/atl1.h
+++ b/drivers/net/atlx/atl1.h
@@ -63,6 +63,9 @@ static void atl1_set_mac_addr(struct atl1_hw *hw);
 static int atl1_mii_ioctl(struct net_device *netdev, struct ifreq *ifr,
 	int cmd);
 static u32 atl1_check_link(struct atl1_adapter *adapter);
+#ifdef CONFIG_ATL1_NAPI
+static int atl1_clean(struct napi_struct *napi, int budget);
+#endif
 
 extern const struct ethtool_ops atl1_ethtool_ops;
 
@@ -288,6 +291,15 @@ extern const struct ethtool_ops atl1_ethtool_ops;
 	ISR_CMB_TX	|\
 	ISR_CMB_RX)
 
+#define IMR_NONRX_MASK	(\
+	ISR_MANUAL	|\
+	ISR_SMB		|\
+	ISR_GPHY	|\
+	ISR_PHY_LINKDOWN|\
+	ISR_DMAR_TO_RST	|\
+	ISR_DMAW_TO_RST	|\
+	ISR_CMB_TX)
+
 #define ISR_TX_EVENT	(\
 	ISR_TXF_UNRUN	|\
 	ISR_TX_PKT	|\
@@ -606,6 +618,10 @@ enum atl1_dma_req_block {
 #define ATL1_MAX_RFD		2048
 #define ATL1_REG_COUNT		1538
 
+#ifdef CONFIG_ATL1_NAPI
+#define ATL1_NAPI_WEIGHT 64
+#endif
+
 #define ATL1_GET_DESC(R, i, type)	(&(((type *)((R)->desc))[i]))
 #define ATL1_RFD_DESC(R, i)	ATL1_GET_DESC(R, i, struct rx_free_desc)
 #define ATL1_TPD_DESC(R, i)	ATL1_GET_DESC(R, i, struct tx_packet_desc)
@@ -818,6 +834,10 @@ struct atl1_adapter {
 	struct atl1_cmb cmb;
 	unsigned long flags;
 	int num_rx_queues;
+#ifdef CONFIG_ATL1_NAPI
+	struct napi_struct napi;
+	struct net_device *polling_netdev;
+#endif
 };
 
 enum atl1_state {
diff --git a/drivers/net/atlx/atlx.h b/drivers/net/atlx/atlx.h
index 352432e..18021d9 100644
--- a/drivers/net/atlx/atlx.h
+++ b/drivers/net/atlx/atlx.h
@@ -29,7 +29,12 @@
 #include <linux/module.h>
 #include <linux/types.h>
 
-#define ATLX_DRIVER_VERSION "2.1.1"
+#ifndef CONFIG_ATL1_NAPI
+#define DRIVERNAPI
+#else
+#define DRIVERNAPI "-NAPI"
+#endif
+#define ATLX_DRIVER_VERSION "2.1.1"DRIVERNAPI
 MODULE_AUTHOR("Xiong Huang <xiong.huang@atheros.com>, \
 	Chris Snook <csnook@redhat.com>, Jay Cliburn <jcliburn@gmail.com>");
 MODULE_LICENSE("GPL");
-- 
1.5.3.3

