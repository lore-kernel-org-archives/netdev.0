From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: [PATCH 25/26] [REVISED] atl1: add NAPI support
Date: Tue, 1 Jan 2008 12:15:36 -0600
Message-ID: <20080101121536.3df9c497@osprey.hogchain.net>
References: <1199152804-3889-1-git-send-email-jacliburn@bellsouth.net>
	<1199152804-3889-26-git-send-email-jacliburn@bellsouth.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
Cc: jeff@garzik.org, csnook@redhat.com, linux-kernel@vger.kernel.org,
	atl1-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, joonwpark81@gmail.com
To: jacliburn@bellsouth.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756547AbYAASTH@vger.kernel.org>
In-Reply-To: <1199152804-3889-26-git-send-email-jacliburn@bellsouth.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for your comments Stephen and Joonwoo.  Here's the revised
version of the atl1 NAPI patch.



>From 9c3a8944220287671f983557099bc329f02fda9b Mon Sep 17 00:00:00 2001
From: Jay Cliburn <jacliburn@bellsouth.net>
Date: Tue, 1 Jan 2008 11:55:24 -0600
Subject: [PATCH 25/26] atl1: add NAPI support

Add support for NAPI.

Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/Kconfig     |   14 +++++
 drivers/net/atlx/atl1.c |  125 +++++++++++++++++++++++++++++++++++------------
 drivers/net/atlx/atl1.h |   19 +++++++
 drivers/net/atlx/atlx.h |    7 ++-
 4 files changed, 132 insertions(+), 33 deletions(-)

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
index 8b4aa94..88ff000 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -754,13 +754,6 @@ static void atl1_set_mac_addr(struct atl1_hw *hw)
 	iowrite32(value, (hw->hw_addr + REG_MAC_STA_ADDR) + (1 << 2));
 }
 
-static int atl1_alloc_queues(struct atl1_adapter *adapter)
-{
-	/* temporary placeholder function for NAPI */
-
-	return 0;
-}
-
 /*
  * atl1_sw_init - Initialize general software structures (struct atl1_adapter)
  * @adapter: board private structure to initialize
@@ -769,7 +762,6 @@ static int __devinit atl1_sw_init(struct atl1_adapter *adapter)
 {
 	struct atl1_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
-	int err;
 
 	hw->max_frame_size = netdev->mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
 	hw->min_frame_size = ETH_ZLEN + ETH_FCS_LEN;
@@ -811,13 +803,6 @@ static int __devinit atl1_sw_init(struct atl1_adapter *adapter)
 	hw->cmb_tx_timer = 256;	/* about 512us */
 	hw->smb_timer = 100000;	/* about 200ms */
 
-	err = atl1_alloc_queues(adapter);
-	if (err) {
-		dev_printk(KERN_DEBUG, &adapter->pdev->dev,
-			"unable to allocate memory for queues\n");
-		return -ENOMEM;
-	}
-
 	spin_lock_init(&adapter->lock);
 	spin_lock_init(&adapter->mb_lock);
 	set_bit(__ATL1_DOWN, &adapter->flags);
@@ -1209,9 +1194,8 @@ static u32 atl1_check_link(struct atl1_adapter *adapter)
 	}
 
 	/* autoneg, insert timer to reconfig phy */
-	if (!test_and_set_bit(0, &adapter->cfg_phy)) {
+	if (!test_and_set_bit(0, &adapter->cfg_phy))
 		mod_timer(&adapter->phy_config_timer, jiffies + 5 * HZ);
-	}
 
 	return 0;
 }
@@ -1699,18 +1683,21 @@ next:
 	return num_alloc;
 }
 
-static void atl1_clean_rx_irq(struct atl1_adapter *adapter)
+#ifdef CONFIG_ATL1_NAPI
+static int atl1_clean_rx_irq(struct atl1_adapter *adapter, int work_to_do)
+#else
+static int atl1_clean_rx_irq(struct atl1_adapter *adapter)
+#endif
 {
 	struct net_device *netdev = adapter->netdev;
-	int i, count;
+	int i, count = 0;
 	u16 length, rrd_next_to_clean;
 	struct atl1_rfd_ring *rfd_ring = &adapter->rfd_ring;
 	struct atl1_rrd_ring *rrd_ring = &adapter->rrd_ring;
 	struct atl1_buffer *buffer_info;
 	struct rx_return_desc *rrd;
 	struct sk_buff *skb;
-
-	count = 0;
+	int work_done = 0;
 
 	rrd_next_to_clean = (u16) atomic_read(&rrd_ring->next_to_clean);
 
@@ -1809,6 +1796,18 @@ rrd_ok:
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
+		if (++work_done >= work_to_do)
+			break;
+#else
 		if (adapter->vlgrp && (rrd->pkt_flg & PACKET_FLAG_VLAN_INS)) {
 			u16 vlan_tag = (rrd->vlan_tag >> 4) |
 					((rrd->vlan_tag & 7) << 13) |
@@ -1816,6 +1815,7 @@ rrd_ok:
 			vlan_hwaccel_rx(skb, adapter->vlgrp, vlan_tag);
 		} else
 			netif_rx(skb);
+#endif
 
 		/* let protocol layer free skb */
 		buffer_info->skb = NULL;
@@ -1830,9 +1830,11 @@ rrd_ok:
 
 	if (count)
 		atl1_update_mailbox(adapter);
+
+	return work_done;
 }
 
-static bool atl1_clean_tx_irq(struct atl1_adapter *adapter)
+static void atl1_clean_tx_irq(struct atl1_adapter *adapter)
 {
 	struct atl1_tpd_ring *tpd_ring = &adapter->tpd_ring;
 	struct atl1_buffer *buffer_info;
@@ -1866,12 +1868,34 @@ static bool atl1_clean_tx_irq(struct atl1_adapter *adapter)
 	if (netif_queue_stopped(adapter->netdev)
 	    && netif_carrier_ok(adapter->netdev))
 		netif_wake_queue(adapter->netdev);
+}
 
-	if (sw_tpd_next_to_clean == (u16) atomic_read(&tpd_ring->next_to_use))
-		return true;
-	else
-		return false;
+#ifdef CONFIG_ATL1_NAPI
+static int atl1_clean(struct napi_struct *napi, int budget)
+{
+	struct atl1_adapter *adapter = container_of(napi, struct atl1_adapter,
+		napi);
+	struct net_device *poll_dev = adapter->netdev;
+	int work_done = 0;
+
+	adapter = poll_dev->priv;
+
+	if (!netif_carrier_ok(poll_dev))
+		goto quit_polling;
+
+	work_done = atl1_clean_rx_irq(adapter, budget);
+
+	if ((work_done < budget) || !netif_running(poll_dev)) {
+quit_polling:
+		netif_rx_complete(poll_dev, napi);
+
+		if (!test_bit(__ATL1_DOWN, &adapter->flags))
+			atlx_irq_enable(adapter);
+	}
+
+	return work_done;
 }
+#endif
 
 static u16 atl1_tpd_avail(struct atl1_tpd_ring *tpd_ring)
 {
@@ -2176,7 +2200,6 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	if (!spin_trylock_irqsave(&adapter->lock, flags)) {
 		/* Can't get lock - tell upper layer to requeue */
-		dev_printk(KERN_DEBUG, &adapter->pdev->dev, "tx locked\n");
 		return NETDEV_TX_LOCKED;
 	}
 
@@ -2184,7 +2207,6 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		/* not enough descriptors */
 		netif_stop_queue(netdev);
 		spin_unlock_irqrestore(&adapter->lock, flags);
-		dev_printk(KERN_DEBUG, &adapter->pdev->dev, "tx busy\n");
 		return NETDEV_TX_BUSY;
 	}
 
@@ -2233,16 +2255,21 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
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
 
@@ -2257,7 +2284,7 @@ loopint:
 	if (status & ISR_PHY_LINKDOWN) {
 		dev_printk(KERN_DEBUG, &adapter->pdev->dev,
 			"pcie phy link down %x\n", status);
-		if (netif_running(adapter->netdev)) {
+		if (netif_running(netdev)) {
 			/* reset MAC */
 			iowrite32(0, hw->hw_addr + REG_ISR);
 			iowrite32(0, hw->hw_addr + REG_IMR);
@@ -2293,13 +2320,29 @@ loopint:
 	if (status & ISR_TX_EVENT)
 		atl1_clean_tx_irq(adapter);
 
-	/* rx event */
+#ifdef CONFIG_ATL1_NAPI
+	/* rx event with NAPI */
+	if (status & ISR_RX_EVENT) {
+		struct atl1_rrd_ring *rrd_ring = &adapter->rrd_ring;
+		struct rx_return_desc *rrd;
+		rrd = ATL1_RRD_DESC(rrd_ring,
+			((u16) atomic_read(&rrd_ring->next_to_clean)));
+		if (rrd->xsz.valid) {
+			/* valid packet; disable interrupts */
+			iowrite32(IMR_NONRX_MASK, hw->hw_addr + REG_IMR);
+			ioread32(hw->hw_addr + REG_IMR);
+			napi_schedule(&adapter->napi);
+		}
+	}
+#else
+	/* rx event no NAPI */
 	if (status & ISR_RX_EVENT)
 		atl1_clean_rx_irq(adapter);
 
 	status = adapter->cmb.cmb->int_stats;
 	if ((--max_ints > 0) && status)
 		goto loopint;
+#endif
 
 	/* re-enable interrupts */
 	iowrite32((ISR_DIS_SMB | ISR_DIS_DMA), adapter->hw.hw_addr + REG_ISR);
@@ -2376,6 +2419,10 @@ static s32 atl1_up(struct atl1_adapter *adapter)
 	retval = ioread32(&adapter->hw + REG_MASTER_CTRL);
 	retval |= MASTER_CTRL_MANUAL_INT;
 	iowrite32(retval, &adapter->hw + REG_MASTER_CTRL);
+
+#ifdef CONFIG_ATL1_NAPI
+	napi_enable(&adapter->napi);
+#endif
 	atlx_irq_enable(adapter);
 
 	return 0;
@@ -2390,6 +2437,10 @@ void atl1_down(struct atl1_adapter *adapter)
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
@@ -2529,6 +2580,10 @@ static int atl1_open(struct net_device *netdev)
 		goto err_open;
 
 	clear_bit(__ATL1_DOWN, &adapter->flags);
+
+#ifdef CONFIG_ATL1_NAPI
+	napi_enable(&adapter->napi);
+#endif
 	mod_timer(&adapter->watchdog_timer, jiffies + (4 * HZ));
 	val = ioread32(hw->hw_addr + REG_MASTER_CTRL);
 	val |= MASTER_CTRL_MANUAL_INT;
@@ -2615,7 +2670,7 @@ static int atl1_suspend(struct pci_dev *pdev, pm_message_t state)
 	if ((ctrl & BMSR_LSTATUS) && wufc) {
 		retval = atl1_get_speed_and_duplex(hw, &speed, &duplex);
 		if (retval) {
-			dev_printk (KERN_DEBUG, &adapter->pdev->dev,
+			dev_printk(KERN_DEBUG, &adapter->pdev->dev,
 				"speed/duplex error during suspend\n");
 			goto wol_dis;
 		}
@@ -2737,6 +2792,9 @@ static void atl1_netpoll(struct net_device *netdev)
 	disable_irq(adapter->pdev->irq);
 	atl1_intr(netdev->irq, netdev);
 	atl1_clean_tx_irq(adapter);
+#ifndef CONFIG_ATL1_NAPI
+	atl1_clean_rx_irq(adapter);
+#endif
 	enable_irq(adapter->pdev->irq);
 }
 #endif
@@ -2837,6 +2895,9 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	netdev->do_ioctl = &atlx_ioctl;
 	netdev->tx_timeout = &atlx_tx_timeout;
 	netdev->watchdog_timeo = 5 * HZ;
+#ifdef CONFIG_ATL1_NAPI
+	netif_napi_add(netdev, &adapter->napi, &atl1_clean, ATL1_NAPI_WEIGHT);
+#endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	netdev->poll_controller = atl1_netpoll;
 #endif
diff --git a/drivers/net/atlx/atl1.h b/drivers/net/atlx/atl1.h
index 5187f74..c1ae519 100644
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
@@ -818,6 +834,9 @@ struct atl1_adapter {
 	struct atl1_cmb cmb;
 	unsigned long flags;
 	int num_rx_queues;
+#ifdef CONFIG_ATL1_NAPI
+	struct napi_struct napi;
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
