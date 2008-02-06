From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates
Date: Wed, 6 Feb 2008 06:49:50 -0500
Message-ID: <20080206114950.GA6444@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:39494 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754535AbYBFLtv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2008 06:49:51 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull from 'upstream-davem' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-davem

to receive the following updates:

 drivers/net/forcedeth.c           |   49 +++++-
 drivers/net/gianfar_mii.c         |    4 +-
 drivers/net/iseries_veth.c        |    2 +-
 drivers/net/ixgbe/ixgbe.h         |    4 +-
 drivers/net/ixgbe/ixgbe_ethtool.c |   91 +++++++-----
 drivers/net/ixgbe/ixgbe_main.c    |  305 ++++++++++++++++++++++++------------
 drivers/net/mv643xx_eth.c         |   11 +-
 drivers/net/sky2.c                |   17 +--
 drivers/net/sky2.h                |    2 +-
 drivers/net/tlan.c                |   25 +++-
 drivers/net/tulip/xircom_cb.c     |    2 +-
 drivers/net/ucc_geth_mii.c        |    4 +-
 drivers/net/virtio_net.c          |   10 +-
 drivers/net/wan/hdlc.c            |   24 +--
 drivers/net/wan/hdlc_cisco.c      |    5 +-
 drivers/net/wan/hdlc_fr.c         |   53 +++----
 drivers/net/wan/hdlc_ppp.c        |    2 +-
 drivers/net/wan/hdlc_raw.c        |    2 +-
 drivers/net/wan/hdlc_raw_eth.c    |    6 +-
 drivers/net/wan/hdlc_x25.c        |   10 +-
 include/linux/hdlc.h              |   25 +---
 21 files changed, 398 insertions(+), 255 deletions(-)

Andy Fleming (1):
      Fix PHY Lib support for gianfar and ucc_geth

Ayaz Abdulla (3):
      forcedeth: restart tx/rx
      forcedeth: phy status fix
      forcedeth: preserve registers

Ayyappan Veeraiyan (8):
      ixgbe: remove obsolete irq_sem, add driver state checking code
      ixbge: remove TX lock and redo TX accounting.
      ixbge: Make ethtool code account for media types
      ixgbe: Fix pause code for ethtool
      ixgbe: Fix FW init/release, make this code a function
      ixgbe: properly return CHECKSUM_NONE, cleanup csum code
      ixgbe: fix several counter register errata
      ixgbe: add real-time traffic counters

Byron Bradley (1):
      mv643xx_eth: fix byte order when checksum offload is enabled

Christian Borntraeger (1):
      virtio net: fix oops on interface-up

Erik Mouw (1):
      xircom_cb should return NETDEV_TX_BUSY when no descriptors available

Krzysztof Halasa (3):
      Generic HDLC - fix kernel panic
      Generic HDLC - remove now unneeded hdlc_device_desc
      Generic HDLC - use random_ether_addr()

Leonardo Potenza (1):
      drivers/net/tlan.c: compilation warning fix

Stephen Hemminger (1):
      sky2: fix for Yukon FE (regression in 2.6.25)

Stephen Rothwell (1):
      iSeries: fix section mismatch in iseries_veth

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 3634223..d4843d0 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -323,8 +323,8 @@ enum {
 	NvRegMIIStatus = 0x180,
 #define NVREG_MIISTAT_ERROR		0x0001
 #define NVREG_MIISTAT_LINKCHANGE	0x0008
-#define NVREG_MIISTAT_MASK		0x000f
-#define NVREG_MIISTAT_MASK2		0x000f
+#define NVREG_MIISTAT_MASK_RW		0x0007
+#define NVREG_MIISTAT_MASK_ALL		0x000f
 	NvRegMIIMask = 0x184,
 #define NVREG_MII_LINKCHANGE		0x0008
 
@@ -624,6 +624,9 @@ union ring_type {
 #define NV_MSI_X_VECTOR_TX    0x1
 #define NV_MSI_X_VECTOR_OTHER 0x2
 
+#define NV_RESTART_TX         0x1
+#define NV_RESTART_RX         0x2
+
 /* statistics */
 struct nv_ethtool_str {
 	char name[ETH_GSTRING_LEN];
@@ -1061,7 +1064,7 @@ static int mii_rw(struct net_device *dev, int addr, int miireg, int value)
 	u32 reg;
 	int retval;
 
-	writel(NVREG_MIISTAT_MASK, base + NvRegMIIStatus);
+	writel(NVREG_MIISTAT_MASK_RW, base + NvRegMIIStatus);
 
 	reg = readl(base + NvRegMIIControl);
 	if (reg & NVREG_MIICTL_INUSE) {
@@ -1432,16 +1435,30 @@ static void nv_mac_reset(struct net_device *dev)
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
+	u32 temp1, temp2, temp3;
 
 	dprintk(KERN_DEBUG "%s: nv_mac_reset\n", dev->name);
+
 	writel(NVREG_TXRXCTL_BIT2 | NVREG_TXRXCTL_RESET | np->txrxctl_bits, base + NvRegTxRxControl);
 	pci_push(base);
+
+	/* save registers since they will be cleared on reset */
+	temp1 = readl(base + NvRegMacAddrA);
+	temp2 = readl(base + NvRegMacAddrB);
+	temp3 = readl(base + NvRegTransmitPoll);
+
 	writel(NVREG_MAC_RESET_ASSERT, base + NvRegMacReset);
 	pci_push(base);
 	udelay(NV_MAC_RESET_DELAY);
 	writel(0, base + NvRegMacReset);
 	pci_push(base);
 	udelay(NV_MAC_RESET_DELAY);
+
+	/* restore saved registers */
+	writel(temp1, base + NvRegMacAddrA);
+	writel(temp2, base + NvRegMacAddrB);
+	writel(temp3, base + NvRegTransmitPoll);
+
 	writel(NVREG_TXRXCTL_BIT2 | np->txrxctl_bits, base + NvRegTxRxControl);
 	pci_push(base);
 }
@@ -2767,6 +2784,7 @@ static int nv_update_linkspeed(struct net_device *dev)
 	int mii_status;
 	int retval = 0;
 	u32 control_1000, status_1000, phyreg, pause_flags, txreg;
+	u32 txrxFlags = 0;
 
 	/* BMSR_LSTATUS is latched, read it twice:
 	 * we want the current value.
@@ -2862,6 +2880,16 @@ set_speed:
 	np->duplex = newdup;
 	np->linkspeed = newls;
 
+	/* The transmitter and receiver must be restarted for safe update */
+	if (readl(base + NvRegTransmitterControl) & NVREG_XMITCTL_START) {
+		txrxFlags |= NV_RESTART_TX;
+		nv_stop_tx(dev);
+	}
+	if (readl(base + NvRegReceiverControl) & NVREG_RCVCTL_START) {
+		txrxFlags |= NV_RESTART_RX;
+		nv_stop_rx(dev);
+	}
+
 	if (np->gigabit == PHY_GIGABIT) {
 		phyreg = readl(base + NvRegRandomSeed);
 		phyreg &= ~(0x3FF00);
@@ -2950,6 +2978,11 @@ set_speed:
 	}
 	nv_update_pause(dev, pause_flags);
 
+	if (txrxFlags & NV_RESTART_TX)
+		nv_start_tx(dev);
+	if (txrxFlags & NV_RESTART_RX)
+		nv_start_rx(dev);
+
 	return retval;
 }
 
@@ -2976,7 +3009,7 @@ static void nv_link_irq(struct net_device *dev)
 	u32 miistat;
 
 	miistat = readl(base + NvRegMIIStatus);
-	writel(NVREG_MIISTAT_MASK, base + NvRegMIIStatus);
+	writel(NVREG_MIISTAT_LINKCHANGE, base + NvRegMIIStatus);
 	dprintk(KERN_INFO "%s: link change irq, status 0x%x.\n", dev->name, miistat);
 
 	if (miistat & (NVREG_MIISTAT_LINKCHANGE))
@@ -4851,7 +4884,7 @@ static int nv_open(struct net_device *dev)
 
 	writel(0, base + NvRegMIIMask);
 	writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
-	writel(NVREG_MIISTAT_MASK2, base + NvRegMIIStatus);
+	writel(NVREG_MIISTAT_MASK_ALL, base + NvRegMIIStatus);
 
 	writel(NVREG_MISC1_FORCE | NVREG_MISC1_HD, base + NvRegMisc1);
 	writel(readl(base + NvRegTransmitterStatus), base + NvRegTransmitterStatus);
@@ -4889,7 +4922,7 @@ static int nv_open(struct net_device *dev)
 
 	nv_disable_hw_interrupts(dev, np->irqmask);
 	pci_push(base);
-	writel(NVREG_MIISTAT_MASK2, base + NvRegMIIStatus);
+	writel(NVREG_MIISTAT_MASK_ALL, base + NvRegMIIStatus);
 	writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
 	pci_push(base);
 
@@ -4912,7 +4945,7 @@ static int nv_open(struct net_device *dev)
 	{
 		u32 miistat;
 		miistat = readl(base + NvRegMIIStatus);
-		writel(NVREG_MIISTAT_MASK, base + NvRegMIIStatus);
+		writel(NVREG_MIISTAT_MASK_ALL, base + NvRegMIIStatus);
 		dprintk(KERN_INFO "startup: got 0x%08x.\n", miistat);
 	}
 	/* set linkspeed to invalid value, thus force nv_update_linkspeed
@@ -5280,7 +5313,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		phystate &= ~NVREG_ADAPTCTL_RUNNING;
 		writel(phystate, base + NvRegAdapterControl);
 	}
-	writel(NVREG_MIISTAT_MASK, base + NvRegMIIStatus);
+	writel(NVREG_MIISTAT_MASK_ALL, base + NvRegMIIStatus);
 
 	if (id->driver_data & DEV_HAS_MGMT_UNIT) {
 		/* management unit running on the mac? */
diff --git a/drivers/net/gianfar_mii.c b/drivers/net/gianfar_mii.c
index 100bf41..6a647d9 100644
--- a/drivers/net/gianfar_mii.c
+++ b/drivers/net/gianfar_mii.c
@@ -127,7 +127,7 @@ int gfar_mdio_reset(struct mii_bus *bus)
 	struct gfar_mii __iomem *regs = (void __iomem *)bus->priv;
 	unsigned int timeout = PHY_INIT_TIMEOUT;
 
-	spin_lock_bh(&bus->mdio_lock);
+	mutex_lock(&bus->mdio_lock);
 
 	/* Reset the management interface */
 	gfar_write(&regs->miimcfg, MIIMCFG_RESET);
@@ -140,7 +140,7 @@ int gfar_mdio_reset(struct mii_bus *bus)
 			timeout--)
 		cpu_relax();
 
-	spin_unlock_bh(&bus->mdio_lock);
+	mutex_unlock(&bus->mdio_lock);
 
 	if(timeout <= 0) {
 		printk(KERN_ERR "%s: The MII Bus is stuck!\n",
diff --git a/drivers/net/iseries_veth.c b/drivers/net/iseries_veth.c
index 419861c..58d3bb6 100644
--- a/drivers/net/iseries_veth.c
+++ b/drivers/net/iseries_veth.c
@@ -1020,7 +1020,7 @@ static const struct ethtool_ops ops = {
 	.get_link = veth_get_link,
 };
 
-static struct net_device * __init veth_probe_one(int vlan,
+static struct net_device *veth_probe_one(int vlan,
 		struct vio_dev *vio_dev)
 {
 	struct net_device *dev;
diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index a021a6e..d0bf206 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -136,8 +136,6 @@ struct ixgbe_ring {
 	u16 head;
 	u16 tail;
 
-	/* To protect race between sender and clean_tx_irq */
-	spinlock_t tx_lock;
 
 	struct ixgbe_queue_stats stats;
 
@@ -174,7 +172,6 @@ struct ixgbe_adapter {
 	struct vlan_group *vlgrp;
 	u16 bd_number;
 	u16 rx_buf_len;
-	atomic_t irq_sem;
 	struct work_struct reset_task;
 
 	/* TX */
@@ -244,6 +241,7 @@ extern const char ixgbe_driver_version[];
 
 extern int ixgbe_up(struct ixgbe_adapter *adapter);
 extern void ixgbe_down(struct ixgbe_adapter *adapter);
+extern void ixgbe_reinit_locked(struct ixgbe_adapter *adapter);
 extern void ixgbe_reset(struct ixgbe_adapter *adapter);
 extern void ixgbe_update_stats(struct ixgbe_adapter *adapter);
 extern void ixgbe_set_ethtool_ops(struct net_device *netdev);
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 3635344..a119cbd 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -103,21 +103,41 @@ static int ixgbe_get_settings(struct net_device *netdev,
 			      struct ethtool_cmd *ecmd)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
+	u32 link_speed = 0;
+	bool link_up;
 
-	ecmd->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
-	ecmd->advertising = (ADVERTISED_10000baseT_Full | ADVERTISED_FIBRE);
-	ecmd->port = PORT_FIBRE;
+	ecmd->supported = SUPPORTED_10000baseT_Full;
+	ecmd->autoneg = AUTONEG_ENABLE;
 	ecmd->transceiver = XCVR_EXTERNAL;
+	if (hw->phy.media_type == ixgbe_media_type_copper) {
+		ecmd->supported |= (SUPPORTED_1000baseT_Full |
+				    SUPPORTED_TP | SUPPORTED_Autoneg);
+
+		ecmd->advertising = (ADVERTISED_TP | ADVERTISED_Autoneg);
+		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_10GB_FULL)
+			ecmd->advertising |= ADVERTISED_10000baseT_Full;
+		if (hw->phy.autoneg_advertised & IXGBE_LINK_SPEED_1GB_FULL)
+			ecmd->advertising |= ADVERTISED_1000baseT_Full;
+
+		ecmd->port = PORT_TP;
+	} else {
+		ecmd->supported |= SUPPORTED_FIBRE;
+		ecmd->advertising = (ADVERTISED_10000baseT_Full |
+				     ADVERTISED_FIBRE);
+		ecmd->port = PORT_FIBRE;
+	}
 
-	if (netif_carrier_ok(adapter->netdev)) {
-		ecmd->speed = SPEED_10000;
+	adapter->hw.mac.ops.check_link(hw, &(link_speed), &link_up);
+	if (link_up) {
+		ecmd->speed = (link_speed == IXGBE_LINK_SPEED_10GB_FULL) ?
+				SPEED_10000 : SPEED_1000;
 		ecmd->duplex = DUPLEX_FULL;
 	} else {
 		ecmd->speed = -1;
 		ecmd->duplex = -1;
 	}
 
-	ecmd->autoneg = AUTONEG_DISABLE;
 	return 0;
 }
 
@@ -125,17 +145,17 @@ static int ixgbe_set_settings(struct net_device *netdev,
 			      struct ethtool_cmd *ecmd)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_hw *hw = &adapter->hw;
 
-	if (ecmd->autoneg == AUTONEG_ENABLE ||
-	    ecmd->speed + ecmd->duplex != SPEED_10000 + DUPLEX_FULL)
-		return -EINVAL;
-
-	if (netif_running(adapter->netdev)) {
-		ixgbe_down(adapter);
-		ixgbe_reset(adapter);
-		ixgbe_up(adapter);
-	} else {
-		ixgbe_reset(adapter);
+	switch (hw->phy.media_type) {
+	case ixgbe_media_type_fiber:
+		if ((ecmd->autoneg == AUTONEG_ENABLE) ||
+		    (ecmd->speed + ecmd->duplex != SPEED_10000 + DUPLEX_FULL))
+			return -EINVAL;
+		/* in this case we currently only support 10Gb/FULL */
+		break;
+	default:
+		break;
 	}
 
 	return 0;
@@ -147,7 +167,7 @@ static void ixgbe_get_pauseparam(struct net_device *netdev,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 
-	pause->autoneg = AUTONEG_DISABLE;
+	pause->autoneg = (hw->fc.type == ixgbe_fc_full ? 1 : 0);
 
 	if (hw->fc.type == ixgbe_fc_rx_pause) {
 		pause->rx_pause = 1;
@@ -165,10 +185,8 @@ static int ixgbe_set_pauseparam(struct net_device *netdev,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
 
-	if (pause->autoneg == AUTONEG_ENABLE)
-		return -EINVAL;
-
-	if (pause->rx_pause && pause->tx_pause)
+	if ((pause->autoneg == AUTONEG_ENABLE) ||
+	    (pause->rx_pause && pause->tx_pause))
 		hw->fc.type = ixgbe_fc_full;
 	else if (pause->rx_pause && !pause->tx_pause)
 		hw->fc.type = ixgbe_fc_rx_pause;
@@ -176,15 +194,15 @@ static int ixgbe_set_pauseparam(struct net_device *netdev,
 		hw->fc.type = ixgbe_fc_tx_pause;
 	else if (!pause->rx_pause && !pause->tx_pause)
 		hw->fc.type = ixgbe_fc_none;
+	else
+		return -EINVAL;
 
 	hw->fc.original_type = hw->fc.type;
 
-	if (netif_running(adapter->netdev)) {
-		ixgbe_down(adapter);
-		ixgbe_up(adapter);
-	} else {
+	if (netif_running(netdev))
+		ixgbe_reinit_locked(adapter);
+	else
 		ixgbe_reset(adapter);
-	}
 
 	return 0;
 }
@@ -203,12 +221,10 @@ static int ixgbe_set_rx_csum(struct net_device *netdev, u32 data)
 	else
 		adapter->flags &= ~IXGBE_FLAG_RX_CSUM_ENABLED;
 
-	if (netif_running(netdev)) {
-		ixgbe_down(adapter);
-		ixgbe_up(adapter);
-	} else {
+	if (netif_running(netdev))
+		ixgbe_reinit_locked(adapter);
+	else
 		ixgbe_reset(adapter);
-	}
 
 	return 0;
 }
@@ -662,7 +678,10 @@ static int ixgbe_set_ringparam(struct net_device *netdev,
 		return 0;
 	}
 
-	if (netif_running(adapter->netdev))
+	while (test_and_set_bit(__IXGBE_RESETTING, &adapter->state))
+		msleep(1);
+
+	if (netif_running(netdev))
 		ixgbe_down(adapter);
 
 	/*
@@ -733,6 +752,7 @@ err_setup:
 	if (netif_running(adapter->netdev))
 		ixgbe_up(adapter);
 
+	clear_bit(__IXGBE_RESETTING, &adapter->state);
 	return err;
 }
 
@@ -820,11 +840,8 @@ static int ixgbe_nway_reset(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
-	if (netif_running(netdev)) {
-		ixgbe_down(adapter);
-		ixgbe_reset(adapter);
-		ixgbe_up(adapter);
-	}
+	if (netif_running(netdev))
+		ixgbe_reinit_locked(adapter);
 
 	return 0;
 }
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 3732dd6..ead49e5 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -87,6 +87,25 @@ MODULE_VERSION(DRV_VERSION);
 
 #define DEFAULT_DEBUG_LEVEL_SHIFT 3
 
+static void ixgbe_release_hw_control(struct ixgbe_adapter *adapter)
+{
+	u32 ctrl_ext;
+
+	/* Let firmware take over control of h/w */
+	ctrl_ext = IXGBE_READ_REG(&adapter->hw, IXGBE_CTRL_EXT);
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_CTRL_EXT,
+			ctrl_ext & ~IXGBE_CTRL_EXT_DRV_LOAD);
+}
+
+static void ixgbe_get_hw_control(struct ixgbe_adapter *adapter)
+{
+	u32 ctrl_ext;
+
+	/* Let firmware know the driver has taken over */
+	ctrl_ext = IXGBE_READ_REG(&adapter->hw, IXGBE_CTRL_EXT);
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_CTRL_EXT,
+			ctrl_ext | IXGBE_CTRL_EXT_DRV_LOAD);
+}
 
 #ifdef DEBUG
 /**
@@ -165,6 +184,15 @@ static inline bool ixgbe_check_tx_hang(struct ixgbe_adapter *adapter,
 	return false;
 }
 
+#define IXGBE_MAX_TXD_PWR	14
+#define IXGBE_MAX_DATA_PER_TXD	(1 << IXGBE_MAX_TXD_PWR)
+
+/* Tx Descriptors needed, worst case */
+#define TXD_USE_COUNT(S) (((S) >> IXGBE_MAX_TXD_PWR) + \
+			 (((S) & (IXGBE_MAX_DATA_PER_TXD - 1)) ? 1 : 0))
+#define DESC_NEEDED (TXD_USE_COUNT(IXGBE_MAX_DATA_PER_TXD) /* skb->data */ + \
+	MAX_SKB_FRAGS * TXD_USE_COUNT(PAGE_SIZE) + 1)	/* for context */
+
 /**
  * ixgbe_clean_tx_irq - Reclaim resources after transmit completes
  * @adapter: board private structure
@@ -177,18 +205,34 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_adapter *adapter,
 	struct ixgbe_tx_buffer *tx_buffer_info;
 	unsigned int i, eop;
 	bool cleaned = false;
-	int count = 0;
+	unsigned int total_tx_bytes = 0, total_tx_packets = 0;
 
 	i = tx_ring->next_to_clean;
 	eop = tx_ring->tx_buffer_info[i].next_to_watch;
 	eop_desc = IXGBE_TX_DESC_ADV(*tx_ring, eop);
 	while (eop_desc->wb.status & cpu_to_le32(IXGBE_TXD_STAT_DD)) {
-		for (cleaned = false; !cleaned;) {
+		cleaned = false;
+		while (!cleaned) {
 			tx_desc = IXGBE_TX_DESC_ADV(*tx_ring, i);
 			tx_buffer_info = &tx_ring->tx_buffer_info[i];
 			cleaned = (i == eop);
 
 			tx_ring->stats.bytes += tx_buffer_info->length;
+			if (cleaned) {
+				struct sk_buff *skb = tx_buffer_info->skb;
+#ifdef NETIF_F_TSO
+				unsigned int segs, bytecount;
+				segs = skb_shinfo(skb)->gso_segs ?: 1;
+				/* multiply data chunks by size of headers */
+				bytecount = ((segs - 1) * skb_headlen(skb)) +
+					    skb->len;
+				total_tx_packets += segs;
+				total_tx_bytes += bytecount;
+#else
+				total_tx_packets++;
+				total_tx_bytes += skb->len;
+#endif
+			}
 			ixgbe_unmap_and_free_tx_resource(adapter,
 							 tx_buffer_info);
 			tx_desc->wb.status = 0;
@@ -204,29 +248,36 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_adapter *adapter,
 		eop_desc = IXGBE_TX_DESC_ADV(*tx_ring, eop);
 
 		/* weight of a sort for tx, avoid endless transmit cleanup */
-		if (count++ >= tx_ring->work_limit)
+		if (total_tx_packets >= tx_ring->work_limit)
 			break;
 	}
 
 	tx_ring->next_to_clean = i;
 
-#define TX_WAKE_THRESHOLD 32
-	spin_lock(&tx_ring->tx_lock);
-
-	if (cleaned && netif_carrier_ok(netdev) &&
-	    (IXGBE_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD) &&
-	    !test_bit(__IXGBE_DOWN, &adapter->state))
-		netif_wake_queue(netdev);
-
-	spin_unlock(&tx_ring->tx_lock);
+#define TX_WAKE_THRESHOLD (DESC_NEEDED * 2)
+	if (total_tx_packets && netif_carrier_ok(netdev) &&
+	    (IXGBE_DESC_UNUSED(tx_ring) >= TX_WAKE_THRESHOLD)) {
+		/* Make sure that anybody stopping the queue after this
+		 * sees the new next_to_clean.
+		 */
+		smp_mb();
+		if (netif_queue_stopped(netdev) &&
+		    !test_bit(__IXGBE_DOWN, &adapter->state)) {
+			netif_wake_queue(netdev);
+			adapter->restart_queue++;
+		}
+	}
 
 	if (adapter->detect_tx_hung)
 		if (ixgbe_check_tx_hang(adapter, tx_ring, eop, eop_desc))
 			netif_stop_queue(netdev);
 
-	if (count >= tx_ring->work_limit)
+	if (total_tx_packets >= tx_ring->work_limit)
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EICS, tx_ring->eims_value);
 
+	adapter->net_stats.tx_bytes += total_tx_bytes;
+	adapter->net_stats.tx_packets += total_tx_packets;
+	cleaned = total_tx_packets ? true : false;
 	return cleaned;
 }
 
@@ -255,25 +306,40 @@ static void ixgbe_receive_skb(struct ixgbe_adapter *adapter,
 	}
 }
 
+/**
+ * ixgbe_rx_checksum - indicate in skb if hw indicated a good cksum
+ * @adapter: address of board private structure
+ * @status_err: hardware indication of status of receive
+ * @skb: skb currently being received and modified
+ **/
 static inline void ixgbe_rx_checksum(struct ixgbe_adapter *adapter,
 					 u32 status_err,
 					 struct sk_buff *skb)
 {
 	skb->ip_summed = CHECKSUM_NONE;
 
-	/* Ignore Checksum bit is set */
+	/* Ignore Checksum bit is set, or rx csum disabled */
 	if ((status_err & IXGBE_RXD_STAT_IXSM) ||
-		     !(adapter->flags & IXGBE_FLAG_RX_CSUM_ENABLED))
+	    !(adapter->flags & IXGBE_FLAG_RX_CSUM_ENABLED))
 		return;
-	/* TCP/UDP checksum error bit is set */
-	if (status_err & (IXGBE_RXDADV_ERR_TCPE | IXGBE_RXDADV_ERR_IPE)) {
-		/* let the stack verify checksum errors */
+
+	/* if IP and error */
+	if ((status_err & IXGBE_RXD_STAT_IPCS) &&
+	    (status_err & IXGBE_RXDADV_ERR_IPE)) {
 		adapter->hw_csum_rx_error++;
 		return;
 	}
+
+	if (!(status_err & IXGBE_RXD_STAT_L4CS))
+		return;
+
+	if (status_err & IXGBE_RXDADV_ERR_TCPE) {
+		adapter->hw_csum_rx_error++;
+		return;
+	}
+
 	/* It must be a TCP or UDP packet with a valid checksum */
-	if (status_err & (IXGBE_RXD_STAT_L4CS | IXGBE_RXD_STAT_UDPCS))
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	adapter->hw_csum_rx_good++;
 }
 
@@ -379,6 +445,7 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
 	u16 hdr_info, vlan_tag;
 	bool is_vlan, cleaned = false;
 	int cleaned_count = 0;
+	unsigned int total_rx_bytes = 0, total_rx_packets = 0;
 
 	i = rx_ring->next_to_clean;
 	upper_len = 0;
@@ -458,6 +525,11 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_adapter *adapter,
 		}
 
 		ixgbe_rx_checksum(adapter, staterr, skb);
+
+		/* probably a little skewed due to removing CRC */
+		total_rx_bytes += skb->len;
+		total_rx_packets++;
+
 		skb->protocol = eth_type_trans(skb, netdev);
 		ixgbe_receive_skb(adapter, skb, is_vlan, vlan_tag);
 		netdev->last_rx = jiffies;
@@ -486,6 +558,9 @@ next_desc:
 	if (cleaned_count)
 		ixgbe_alloc_rx_buffers(adapter, rx_ring, cleaned_count);
 
+	adapter->net_stats.rx_bytes += total_rx_bytes;
+	adapter->net_stats.rx_packets += total_rx_packets;
+
 	return cleaned;
 }
 
@@ -535,7 +610,9 @@ static irqreturn_t ixgbe_msix_lsc(int irq, void *data)
 		if (!test_bit(__IXGBE_DOWN, &adapter->state))
 			mod_timer(&adapter->watchdog_timer, jiffies);
 	}
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS, IXGBE_EIMS_OTHER);
+
+	if (!test_bit(__IXGBE_DOWN, &adapter->state))
+		IXGBE_WRITE_REG(hw, IXGBE_EIMS, IXGBE_EIMS_OTHER);
 
 	return IRQ_HANDLED;
 }
@@ -713,7 +790,6 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 	if (netif_rx_schedule_prep(netdev, &adapter->napi)) {
 		/* Disable interrupts and register for poll. The flush of the
 		 * posted write is intentionally left out. */
-		atomic_inc(&adapter->irq_sem);
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, ~0);
 		__netif_rx_schedule(netdev, &adapter->napi);
 	}
@@ -801,7 +877,6 @@ static void ixgbe_free_irq(struct ixgbe_adapter *adapter)
  **/
 static inline void ixgbe_irq_disable(struct ixgbe_adapter *adapter)
 {
-	atomic_inc(&adapter->irq_sem);
 	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMC, ~0);
 	IXGBE_WRITE_FLUSH(&adapter->hw);
 	synchronize_irq(adapter->pdev->irq);
@@ -813,15 +888,13 @@ static inline void ixgbe_irq_disable(struct ixgbe_adapter *adapter)
  **/
 static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter)
 {
-	if (atomic_dec_and_test(&adapter->irq_sem)) {
-		if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED)
-			IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIAC,
-					(IXGBE_EIMS_ENABLE_MASK &
-					 ~(IXGBE_EIMS_OTHER | IXGBE_EIMS_LSC)));
-		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS,
-				IXGBE_EIMS_ENABLE_MASK);
-		IXGBE_WRITE_FLUSH(&adapter->hw);
-	}
+	if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED)
+		IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIAC,
+				(IXGBE_EIMS_ENABLE_MASK &
+				 ~(IXGBE_EIMS_OTHER | IXGBE_EIMS_LSC)));
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_EIMS,
+			IXGBE_EIMS_ENABLE_MASK);
+	IXGBE_WRITE_FLUSH(&adapter->hw);
 }
 
 /**
@@ -1040,7 +1113,8 @@ static void ixgbe_vlan_rx_register(struct net_device *netdev,
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	u32 ctrl;
 
-	ixgbe_irq_disable(adapter);
+	if (!test_bit(__IXGBE_DOWN, &adapter->state))
+		ixgbe_irq_disable(adapter);
 	adapter->vlgrp = grp;
 
 	if (grp) {
@@ -1051,7 +1125,8 @@ static void ixgbe_vlan_rx_register(struct net_device *netdev,
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_VLNCTRL, ctrl);
 	}
 
-	ixgbe_irq_enable(adapter);
+	if (!test_bit(__IXGBE_DOWN, &adapter->state))
+		ixgbe_irq_enable(adapter);
 }
 
 static void ixgbe_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
@@ -1066,9 +1141,13 @@ static void ixgbe_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
-	ixgbe_irq_disable(adapter);
+	if (!test_bit(__IXGBE_DOWN, &adapter->state))
+		ixgbe_irq_disable(adapter);
+
 	vlan_group_set_device(adapter->vlgrp, vid, NULL);
-	ixgbe_irq_enable(adapter);
+
+	if (!test_bit(__IXGBE_DOWN, &adapter->state))
+		ixgbe_irq_enable(adapter);
 
 	/* remove VID from filter table */
 	ixgbe_set_vfta(&adapter->hw, vid, 0, false);
@@ -1170,6 +1249,8 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	u32 txdctl, rxdctl, mhadd;
 	int max_frame = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
 
+	ixgbe_get_hw_control(adapter);
+
 	if (adapter->flags & (IXGBE_FLAG_MSIX_ENABLED |
 			      IXGBE_FLAG_MSI_ENABLED)) {
 		if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
@@ -1224,6 +1305,16 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	return 0;
 }
 
+void ixgbe_reinit_locked(struct ixgbe_adapter *adapter)
+{
+	WARN_ON(in_interrupt());
+	while (test_and_set_bit(__IXGBE_RESETTING, &adapter->state))
+		msleep(1);
+	ixgbe_down(adapter);
+	ixgbe_up(adapter);
+	clear_bit(__IXGBE_RESETTING, &adapter->state);
+}
+
 int ixgbe_up(struct ixgbe_adapter *adapter)
 {
 	/* hardware has been reset, we need to reload some things */
@@ -1408,7 +1499,6 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	msleep(10);
 
 	napi_disable(&adapter->napi);
-	atomic_set(&adapter->irq_sem, 0);
 
 	ixgbe_irq_disable(adapter);
 
@@ -1447,6 +1537,8 @@ static int ixgbe_suspend(struct pci_dev *pdev, pm_message_t state)
 	pci_enable_wake(pdev, PCI_D3hot, 0);
 	pci_enable_wake(pdev, PCI_D3cold, 0);
 
+	ixgbe_release_hw_control(adapter);
+
 	pci_disable_device(pdev);
 
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
@@ -1481,7 +1573,8 @@ static int ixgbe_clean(struct napi_struct *napi, int budget)
 	/* If budget not fully consumed, exit the polling mode */
 	if (work_done < budget) {
 		netif_rx_complete(netdev, napi);
-		ixgbe_irq_enable(adapter);
+		if (!test_bit(__IXGBE_DOWN, &adapter->state))
+			ixgbe_irq_enable(adapter);
 	}
 
 	return work_done;
@@ -1506,8 +1599,7 @@ static void ixgbe_reset_task(struct work_struct *work)
 
 	adapter->tx_timeout_count++;
 
-	ixgbe_down(adapter);
-	ixgbe_up(adapter);
+	ixgbe_reinit_locked(adapter);
 }
 
 /**
@@ -1590,7 +1682,6 @@ static int __devinit ixgbe_sw_init(struct ixgbe_adapter *adapter)
 		return -ENOMEM;
 	}
 
-	atomic_set(&adapter->irq_sem, 1);
 	set_bit(__IXGBE_DOWN, &adapter->state);
 
 	return 0;
@@ -1634,7 +1725,6 @@ int ixgbe_setup_tx_resources(struct ixgbe_adapter *adapter,
 	txdr->next_to_use = 0;
 	txdr->next_to_clean = 0;
 	txdr->work_limit = txdr->count;
-	spin_lock_init(&txdr->tx_lock);
 
 	return 0;
 }
@@ -1828,10 +1918,8 @@ static int ixgbe_change_mtu(struct net_device *netdev, int new_mtu)
 
 	netdev->mtu = new_mtu;
 
-	if (netif_running(netdev)) {
-		ixgbe_down(adapter);
-		ixgbe_up(adapter);
-	}
+	if (netif_running(netdev))
+		ixgbe_reinit_locked(adapter);
 
 	return 0;
 }
@@ -1852,14 +1940,8 @@ static int ixgbe_open(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	int err;
-	u32 ctrl_ext;
 	u32 num_rx_queues = adapter->num_rx_queues;
 
-	/* Let firmware know the driver has taken over */
-	ctrl_ext = IXGBE_READ_REG(&adapter->hw, IXGBE_CTRL_EXT);
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_CTRL_EXT,
-			ctrl_ext | IXGBE_CTRL_EXT_DRV_LOAD);
-
 try_intr_reinit:
 	/* allocate transmit descriptors */
 	err = ixgbe_setup_all_tx_resources(adapter);
@@ -1910,6 +1992,7 @@ try_intr_reinit:
 	return 0;
 
 err_up:
+	ixgbe_release_hw_control(adapter);
 	ixgbe_free_irq(adapter);
 err_req_irq:
 	ixgbe_free_all_rx_resources(adapter);
@@ -1935,7 +2018,6 @@ err_setup_tx:
 static int ixgbe_close(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	u32 ctrl_ext;
 
 	ixgbe_down(adapter);
 	ixgbe_free_irq(adapter);
@@ -1943,9 +2025,7 @@ static int ixgbe_close(struct net_device *netdev)
 	ixgbe_free_all_tx_resources(adapter);
 	ixgbe_free_all_rx_resources(adapter);
 
-	ctrl_ext = IXGBE_READ_REG(&adapter->hw, IXGBE_CTRL_EXT);
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_CTRL_EXT,
-			ctrl_ext & ~IXGBE_CTRL_EXT_DRV_LOAD);
+	ixgbe_release_hw_control(adapter);
 
 	return 0;
 }
@@ -1957,22 +2037,26 @@ static int ixgbe_close(struct net_device *netdev)
 void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	u64 good_rx, missed_rx, bprc;
+	u64 total_mpc = 0;
+	u32 i, missed_rx = 0, mpc, bprc, lxon, lxoff, xon_off_tot;
 
 	adapter->stats.crcerrs += IXGBE_READ_REG(hw, IXGBE_CRCERRS);
-	good_rx = IXGBE_READ_REG(hw, IXGBE_GPRC);
-	missed_rx = IXGBE_READ_REG(hw, IXGBE_MPC(0));
-	missed_rx += IXGBE_READ_REG(hw, IXGBE_MPC(1));
-	missed_rx += IXGBE_READ_REG(hw, IXGBE_MPC(2));
-	missed_rx += IXGBE_READ_REG(hw, IXGBE_MPC(3));
-	missed_rx += IXGBE_READ_REG(hw, IXGBE_MPC(4));
-	missed_rx += IXGBE_READ_REG(hw, IXGBE_MPC(5));
-	missed_rx += IXGBE_READ_REG(hw, IXGBE_MPC(6));
-	missed_rx += IXGBE_READ_REG(hw, IXGBE_MPC(7));
-	adapter->stats.gprc += (good_rx - missed_rx);
-
-	adapter->stats.mpc[0] += missed_rx;
+	for (i = 0; i < 8; i++) {
+		/* for packet buffers not used, the register should read 0 */
+		mpc = IXGBE_READ_REG(hw, IXGBE_MPC(i));
+		missed_rx += mpc;
+		adapter->stats.mpc[i] += mpc;
+		total_mpc += adapter->stats.mpc[i];
+		adapter->stats.rnbc[i] += IXGBE_READ_REG(hw, IXGBE_RNBC(i));
+	}
+	adapter->stats.gprc += IXGBE_READ_REG(hw, IXGBE_GPRC);
+	/* work around hardware counting issue */
+	adapter->stats.gprc -= missed_rx;
+
+	/* 82598 hardware only has a 32 bit counter in the high register */
 	adapter->stats.gorc += IXGBE_READ_REG(hw, IXGBE_GORCH);
+	adapter->stats.gotc += IXGBE_READ_REG(hw, IXGBE_GOTCH);
+	adapter->stats.tor += IXGBE_READ_REG(hw, IXGBE_TORH);
 	bprc = IXGBE_READ_REG(hw, IXGBE_BPRC);
 	adapter->stats.bprc += bprc;
 	adapter->stats.mprc += IXGBE_READ_REG(hw, IXGBE_MPRC);
@@ -1984,35 +2068,37 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 	adapter->stats.prc511 += IXGBE_READ_REG(hw, IXGBE_PRC511);
 	adapter->stats.prc1023 += IXGBE_READ_REG(hw, IXGBE_PRC1023);
 	adapter->stats.prc1522 += IXGBE_READ_REG(hw, IXGBE_PRC1522);
-
 	adapter->stats.rlec += IXGBE_READ_REG(hw, IXGBE_RLEC);
 	adapter->stats.lxonrxc += IXGBE_READ_REG(hw, IXGBE_LXONRXC);
-	adapter->stats.lxontxc += IXGBE_READ_REG(hw, IXGBE_LXONTXC);
 	adapter->stats.lxoffrxc += IXGBE_READ_REG(hw, IXGBE_LXOFFRXC);
-	adapter->stats.lxofftxc += IXGBE_READ_REG(hw, IXGBE_LXOFFTXC);
+	lxon = IXGBE_READ_REG(hw, IXGBE_LXONTXC);
+	adapter->stats.lxontxc += lxon;
+	lxoff = IXGBE_READ_REG(hw, IXGBE_LXOFFTXC);
+	adapter->stats.lxofftxc += lxoff;
 	adapter->stats.ruc += IXGBE_READ_REG(hw, IXGBE_RUC);
 	adapter->stats.gptc += IXGBE_READ_REG(hw, IXGBE_GPTC);
-	adapter->stats.gotc += IXGBE_READ_REG(hw, IXGBE_GOTCH);
-	adapter->stats.rnbc[0] += IXGBE_READ_REG(hw, IXGBE_RNBC(0));
+	adapter->stats.mptc += IXGBE_READ_REG(hw, IXGBE_MPTC);
+	/*
+	 * 82598 errata - tx of flow control packets is included in tx counters
+	 */
+	xon_off_tot = lxon + lxoff;
+	adapter->stats.gptc -= xon_off_tot;
+	adapter->stats.mptc -= xon_off_tot;
+	adapter->stats.gotc -= (xon_off_tot * (ETH_ZLEN + ETH_FCS_LEN));
 	adapter->stats.ruc += IXGBE_READ_REG(hw, IXGBE_RUC);
 	adapter->stats.rfc += IXGBE_READ_REG(hw, IXGBE_RFC);
 	adapter->stats.rjc += IXGBE_READ_REG(hw, IXGBE_RJC);
-	adapter->stats.tor += IXGBE_READ_REG(hw, IXGBE_TORH);
 	adapter->stats.tpr += IXGBE_READ_REG(hw, IXGBE_TPR);
 	adapter->stats.ptc64 += IXGBE_READ_REG(hw, IXGBE_PTC64);
+	adapter->stats.ptc64 -= xon_off_tot;
 	adapter->stats.ptc127 += IXGBE_READ_REG(hw, IXGBE_PTC127);
 	adapter->stats.ptc255 += IXGBE_READ_REG(hw, IXGBE_PTC255);
 	adapter->stats.ptc511 += IXGBE_READ_REG(hw, IXGBE_PTC511);
 	adapter->stats.ptc1023 += IXGBE_READ_REG(hw, IXGBE_PTC1023);
 	adapter->stats.ptc1522 += IXGBE_READ_REG(hw, IXGBE_PTC1522);
-	adapter->stats.mptc += IXGBE_READ_REG(hw, IXGBE_MPTC);
 	adapter->stats.bptc += IXGBE_READ_REG(hw, IXGBE_BPTC);
 
 	/* Fill out the OS statistics structure */
-	adapter->net_stats.rx_packets = adapter->stats.gprc;
-	adapter->net_stats.tx_packets = adapter->stats.gptc;
-	adapter->net_stats.rx_bytes = adapter->stats.gorc;
-	adapter->net_stats.tx_bytes = adapter->stats.gotc;
 	adapter->net_stats.multicast = adapter->stats.mprc;
 
 	/* Rx Errors */
@@ -2021,8 +2107,7 @@ void ixgbe_update_stats(struct ixgbe_adapter *adapter)
 	adapter->net_stats.rx_dropped = 0;
 	adapter->net_stats.rx_length_errors = adapter->stats.rlec;
 	adapter->net_stats.rx_crc_errors = adapter->stats.crcerrs;
-	adapter->net_stats.rx_missed_errors = adapter->stats.mpc[0];
-
+	adapter->net_stats.rx_missed_errors = total_mpc;
 }
 
 /**
@@ -2076,15 +2161,6 @@ static void ixgbe_watchdog(unsigned long data)
 			  round_jiffies(jiffies + 2 * HZ));
 }
 
-#define IXGBE_MAX_TXD_PWR	14
-#define IXGBE_MAX_DATA_PER_TXD	(1 << IXGBE_MAX_TXD_PWR)
-
-/* Tx Descriptors needed, worst case */
-#define TXD_USE_COUNT(S) (((S) >> IXGBE_MAX_TXD_PWR) + \
-			 (((S) & (IXGBE_MAX_DATA_PER_TXD - 1)) ? 1 : 0))
-#define DESC_NEEDED (TXD_USE_COUNT(IXGBE_MAX_DATA_PER_TXD) /* skb->data */ + \
-	MAX_SKB_FRAGS * TXD_USE_COUNT(PAGE_SIZE) + 1)	/* for context */
-
 static int ixgbe_tso(struct ixgbe_adapter *adapter,
 			 struct ixgbe_ring *tx_ring, struct sk_buff *skb,
 			 u32 tx_flags, u8 *hdr_len)
@@ -2356,6 +2432,37 @@ static void ixgbe_tx_queue(struct ixgbe_adapter *adapter,
 	writel(i, adapter->hw.hw_addr + tx_ring->tail);
 }
 
+static int __ixgbe_maybe_stop_tx(struct net_device *netdev,
+				 struct ixgbe_ring *tx_ring, int size)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+
+	netif_stop_queue(netdev);
+	/* Herbert's original patch had:
+	 *  smp_mb__after_netif_stop_queue();
+	 * but since that doesn't exist yet, just open code it. */
+	smp_mb();
+
+	/* We need to check again in a case another CPU has just
+	 * made room available. */
+	if (likely(IXGBE_DESC_UNUSED(tx_ring) < size))
+		return -EBUSY;
+
+	/* A reprieve! - use start_queue because it doesn't call schedule */
+	netif_wake_queue(netdev);
+	++adapter->restart_queue;
+	return 0;
+}
+
+static int ixgbe_maybe_stop_tx(struct net_device *netdev,
+			       struct ixgbe_ring *tx_ring, int size)
+{
+	if (likely(IXGBE_DESC_UNUSED(tx_ring) >= size))
+		return 0;
+	return __ixgbe_maybe_stop_tx(netdev, tx_ring, size);
+}
+
+
 static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
@@ -2363,7 +2470,6 @@ static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	unsigned int len = skb->len;
 	unsigned int first;
 	unsigned int tx_flags = 0;
-	unsigned long flags = 0;
 	u8 hdr_len;
 	int tso;
 	unsigned int mss = 0;
@@ -2389,14 +2495,10 @@ static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	for (f = 0; f < nr_frags; f++)
 		count += TXD_USE_COUNT(skb_shinfo(skb)->frags[f].size);
 
-	spin_lock_irqsave(&tx_ring->tx_lock, flags);
-	if (IXGBE_DESC_UNUSED(tx_ring) < (count + 2)) {
+	if (ixgbe_maybe_stop_tx(netdev, tx_ring, count)) {
 		adapter->tx_busy++;
-		netif_stop_queue(netdev);
-		spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
 		return NETDEV_TX_BUSY;
 	}
-	spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
 	if (adapter->vlgrp && vlan_tx_tag_present(skb)) {
 		tx_flags |= IXGBE_TX_FLAGS_VLAN;
 		tx_flags |= (vlan_tx_tag_get(skb) << IXGBE_TX_FLAGS_VLAN_SHIFT);
@@ -2423,11 +2525,7 @@ static int ixgbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 
 	netdev->trans_start = jiffies;
 
-	spin_lock_irqsave(&tx_ring->tx_lock, flags);
-	/* Make sure there is space in the ring for the next send. */
-	if (IXGBE_DESC_UNUSED(tx_ring) < DESC_NEEDED)
-		netif_stop_queue(netdev);
-	spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
+	ixgbe_maybe_stop_tx(netdev, tx_ring, DESC_NEEDED);
 
 	return NETDEV_TX_OK;
 }
@@ -2697,6 +2795,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	return 0;
 
 err_register:
+	ixgbe_release_hw_control(adapter);
 err_hw_init:
 err_sw_init:
 err_eeprom:
@@ -2732,6 +2831,8 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 
 	unregister_netdev(netdev);
 
+	ixgbe_release_hw_control(adapter);
+
 	kfree(adapter->tx_ring);
 	kfree(adapter->rx_ring);
 
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 651c269..b528ce7 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1652,6 +1652,11 @@ static void eth_tx_fill_frag_descs(struct mv643xx_private *mp,
 	}
 }
 
+static inline __be16 sum16_as_be(__sum16 sum)
+{
+	return (__force __be16)sum;
+}
+
 /**
  * eth_tx_submit_descs_for_skb - submit data from an skb to the tx hw
  *
@@ -1689,7 +1694,7 @@ static void eth_tx_submit_descs_for_skb(struct mv643xx_private *mp,
 	desc->buf_ptr = dma_map_single(NULL, skb->data, length, DMA_TO_DEVICE);
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		BUG_ON(skb->protocol != ETH_P_IP);
+		BUG_ON(skb->protocol != htons(ETH_P_IP));
 
 		cmd_sts |= ETH_GEN_TCP_UDP_CHECKSUM |
 			   ETH_GEN_IP_V_4_CHECKSUM  |
@@ -1698,10 +1703,10 @@ static void eth_tx_submit_descs_for_skb(struct mv643xx_private *mp,
 		switch (ip_hdr(skb)->protocol) {
 		case IPPROTO_UDP:
 			cmd_sts |= ETH_UDP_FRAME;
-			desc->l4i_chk = udp_hdr(skb)->check;
+			desc->l4i_chk = ntohs(sum16_as_be(udp_hdr(skb)->check));
 			break;
 		case IPPROTO_TCP:
-			desc->l4i_chk = tcp_hdr(skb)->check;
+			desc->l4i_chk = ntohs(sum16_as_be(tcp_hdr(skb)->check));
 			break;
 		default:
 			BUG();
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index dc06236..9a62959 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -857,7 +857,7 @@ static void sky2_mac_init(struct sky2_hw *hw, unsigned port)
 	sky2_write16(hw, SK_REG(port, TX_GMF_CTRL_T), GMF_OPER_ON);
 
 	/* On chips without ram buffer, pause is controled by MAC level */
-	if (sky2_read8(hw, B2_E_0) == 0) {
+	if (!(hw->flags & SKY2_HW_RAM_BUFFER)) {
 		sky2_write8(hw, SK_REG(port, RX_GMF_LP_THR), 768/8);
 		sky2_write8(hw, SK_REG(port, RX_GMF_UP_THR), 1024/8);
 
@@ -1194,7 +1194,7 @@ static struct sk_buff *sky2_rx_alloc(struct sky2_port *sky2)
 	struct sk_buff *skb;
 	int i;
 
-	if (sky2->hw->flags & SKY2_HW_FIFO_HANG_CHECK) {
+	if (sky2->hw->flags & SKY2_HW_RAM_BUFFER) {
 		unsigned char *start;
 		/*
 		 * Workaround for a bug in FIFO that cause hang
@@ -1387,6 +1387,7 @@ static int sky2_up(struct net_device *dev)
 	if (ramsize > 0) {
 		u32 rxspace;
 
+		hw->flags |= SKY2_HW_RAM_BUFFER;
 		pr_debug(PFX "%s: ram buffer %dK\n", dev->name, ramsize);
 		if (ramsize < 16)
 			rxspace = ramsize / 2;
@@ -2026,7 +2027,7 @@ static int sky2_change_mtu(struct net_device *dev, int new_mtu)
 
 	synchronize_irq(hw->pdev->irq);
 
-	if (sky2_read8(hw, B2_E_0) == 0)
+	if (!(hw->flags & SKY2_HW_RAM_BUFFER))
 		sky2_set_tx_stfwd(hw, port);
 
 	ctl = gma_read16(hw, port, GM_GP_CTRL);
@@ -2566,7 +2567,7 @@ static void sky2_watchdog(unsigned long arg)
 			++active;
 
 			/* For chips with Rx FIFO, check if stuck */
-			if ((hw->flags & SKY2_HW_FIFO_HANG_CHECK) &&
+			if ((hw->flags & SKY2_HW_RAM_BUFFER) &&
 			     sky2_rx_hung(dev)) {
 				pr_info(PFX "%s: receiver hang detected\n",
 					dev->name);
@@ -2722,11 +2723,7 @@ static int __devinit sky2_init(struct sky2_hw *hw)
 
 	switch(hw->chip_id) {
 	case CHIP_ID_YUKON_XL:
-		hw->flags = SKY2_HW_GIGABIT
-			| SKY2_HW_NEWER_PHY;
-		if (hw->chip_rev < 3)
-			hw->flags |= SKY2_HW_FIFO_HANG_CHECK;
-
+		hw->flags = SKY2_HW_GIGABIT | SKY2_HW_NEWER_PHY;
 		break;
 
 	case CHIP_ID_YUKON_EC_U:
@@ -2752,7 +2749,7 @@ static int __devinit sky2_init(struct sky2_hw *hw)
 			dev_err(&hw->pdev->dev, "unsupported revision Yukon-EC rev A1\n");
 			return -EOPNOTSUPP;
 		}
-		hw->flags = SKY2_HW_GIGABIT | SKY2_HW_FIFO_HANG_CHECK;
+		hw->flags = SKY2_HW_GIGABIT;
 		break;
 
 	case CHIP_ID_YUKON_FE:
diff --git a/drivers/net/sky2.h b/drivers/net/sky2.h
index 2bced1a..5ab5c1c 100644
--- a/drivers/net/sky2.h
+++ b/drivers/net/sky2.h
@@ -2045,7 +2045,7 @@ struct sky2_hw {
 #define SKY2_HW_FIBRE_PHY	0x00000002
 #define SKY2_HW_GIGABIT		0x00000004
 #define SKY2_HW_NEWER_PHY	0x00000008
-#define SKY2_HW_FIFO_HANG_CHECK	0x00000010
+#define SKY2_HW_RAM_BUFFER	0x00000010
 #define SKY2_HW_NEW_LE		0x00000020	/* new LSOv2 format */
 #define SKY2_HW_AUTO_TX_SUM	0x00000040	/* new IP decode for Tx */
 #define SKY2_HW_ADV_POWER_CTL	0x00000080	/* additional PHY power regs */
diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index c99ce74..3af5b92 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -465,7 +465,7 @@ static struct pci_driver tlan_driver = {
 
 static int __init tlan_probe(void)
 {
-	static int	pad_allocated;
+	int rc = -ENODEV;
 
 	printk(KERN_INFO "%s", tlan_banner);
 
@@ -473,17 +473,22 @@ static int __init tlan_probe(void)
 
 	if (TLanPadBuffer == NULL) {
 		printk(KERN_ERR "TLAN: Could not allocate memory for pad buffer.\n");
-		return -ENOMEM;
+		rc = -ENOMEM;
+		goto err_out;
 	}
 
 	memset(TLanPadBuffer, 0, TLAN_MIN_FRAME_SIZE);
-	pad_allocated = 1;
 
 	TLAN_DBG(TLAN_DEBUG_PROBE, "Starting PCI Probe....\n");
 
 	/* Use new style PCI probing. Now the kernel will
 	   do most of this for us */
-	pci_register_driver(&tlan_driver);
+	rc = pci_register_driver(&tlan_driver);
+
+	if (rc != 0) {
+		printk(KERN_ERR "TLAN: Could not register pci driver.\n");
+		goto err_out_pci_free;
+	}
 
 	TLAN_DBG(TLAN_DEBUG_PROBE, "Starting EISA Probe....\n");
 	TLan_EisaProbe();
@@ -493,11 +498,17 @@ static int __init tlan_probe(void)
 		 tlan_have_pci, tlan_have_eisa);
 
 	if (TLanDevicesInstalled == 0) {
-		pci_unregister_driver(&tlan_driver);
-		pci_free_consistent(NULL, TLAN_MIN_FRAME_SIZE, TLanPadBuffer, TLanPadBufferDMA);
-		return -ENODEV;
+		rc = -ENODEV;
+		goto  err_out_pci_unreg;
 	}
 	return 0;
+
+err_out_pci_unreg:
+	pci_unregister_driver(&tlan_driver);
+err_out_pci_free:
+	pci_free_consistent(NULL, TLAN_MIN_FRAME_SIZE, TLanPadBuffer, TLanPadBufferDMA);
+err_out:
+	return rc;
 }
 
 
diff --git a/drivers/net/tulip/xircom_cb.c b/drivers/net/tulip/xircom_cb.c
index 8fc7274..6b93d01 100644
--- a/drivers/net/tulip/xircom_cb.c
+++ b/drivers/net/tulip/xircom_cb.c
@@ -441,7 +441,7 @@ static int xircom_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	spin_unlock_irqrestore(&card->lock,flags);
 	trigger_transmit(card);
 
-	return -EIO;
+	return NETDEV_TX_BUSY;
 }
 
 
diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
index e3ba14a..c69e654 100644
--- a/drivers/net/ucc_geth_mii.c
+++ b/drivers/net/ucc_geth_mii.c
@@ -109,7 +109,7 @@ int uec_mdio_reset(struct mii_bus *bus)
 	struct ucc_mii_mng __iomem *regs = (void __iomem *)bus->priv;
 	unsigned int timeout = PHY_INIT_TIMEOUT;
 
-	spin_lock_bh(&bus->mdio_lock);
+	mutex_lock(&bus->mdio_lock);
 
 	/* Reset the management interface */
 	out_be32(&regs->miimcfg, MIIMCFG_RESET_MANAGEMENT);
@@ -121,7 +121,7 @@ int uec_mdio_reset(struct mii_bus *bus)
 	while ((in_be32(&regs->miimind) & MIIMIND_BUSY) && timeout--)
 		cpu_relax();
 
-	spin_unlock_bh(&bus->mdio_lock);
+	mutex_unlock(&bus->mdio_lock);
 
 	if (timeout <= 0) {
 		printk(KERN_ERR "%s: The MII Bus is stuck!\n", bus->name);
diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index e66de0c..fdc2367 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -302,10 +302,12 @@ static int virtnet_open(struct net_device *dev)
 
 	/* If all buffers were filled by other side before we napi_enabled, we
 	 * won't get another interrupt, so process any outstanding packets
-	 * now.  virtnet_poll wants re-enable the queue, so we disable here. */
-	vi->rvq->vq_ops->disable_cb(vi->rvq);
-	netif_rx_schedule(vi->dev, &vi->napi);
-
+	 * now.  virtnet_poll wants re-enable the queue, so we disable here.
+	 * We synchronize against interrupts via NAPI_STATE_SCHED */
+	if (netif_rx_schedule_prep(dev, &vi->napi)) {
+		vi->rvq->vq_ops->disable_cb(vi->rvq);
+		__netif_rx_schedule(dev, &vi->napi);
+	}
 	return 0;
 }
 
diff --git a/drivers/net/wan/hdlc.c b/drivers/net/wan/hdlc.c
index d553e6f..39951d0 100644
--- a/drivers/net/wan/hdlc.c
+++ b/drivers/net/wan/hdlc.c
@@ -1,7 +1,7 @@
 /*
  * Generic HDLC support routines for Linux
  *
- * Copyright (C) 1999 - 2006 Krzysztof Halasa <khc@pm.waw.pl>
+ * Copyright (C) 1999 - 2008 Krzysztof Halasa <khc@pm.waw.pl>
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of version 2 of the GNU General Public License
@@ -39,7 +39,7 @@
 #include <net/net_namespace.h>
 
 
-static const char* version = "HDLC support module revision 1.21";
+static const char* version = "HDLC support module revision 1.22";
 
 #undef DEBUG_LINK
 
@@ -66,19 +66,15 @@ static struct net_device_stats *hdlc_get_stats(struct net_device *dev)
 static int hdlc_rcv(struct sk_buff *skb, struct net_device *dev,
 		    struct packet_type *p, struct net_device *orig_dev)
 {
-	struct hdlc_device_desc *desc = dev_to_desc(dev);
+	struct hdlc_device *hdlc = dev_to_hdlc(dev);
 
 	if (dev->nd_net != &init_net) {
 		kfree_skb(skb);
 		return 0;
 	}
 
-	if (desc->netif_rx)
-		return desc->netif_rx(skb);
-
-	desc->stats.rx_dropped++; /* Shouldn't happen */
-	dev_kfree_skb(skb);
-	return NET_RX_DROP;
+	BUG_ON(!hdlc->proto->netif_rx);
+	return hdlc->proto->netif_rx(skb);
 }
 
 
@@ -87,7 +83,7 @@ static inline void hdlc_proto_start(struct net_device *dev)
 {
 	hdlc_device *hdlc = dev_to_hdlc(dev);
 	if (hdlc->proto->start)
-		return hdlc->proto->start(dev);
+		hdlc->proto->start(dev);
 }
 
 
@@ -96,7 +92,7 @@ static inline void hdlc_proto_stop(struct net_device *dev)
 {
 	hdlc_device *hdlc = dev_to_hdlc(dev);
 	if (hdlc->proto->stop)
-		return hdlc->proto->stop(dev);
+		hdlc->proto->stop(dev);
 }
 
 
@@ -263,8 +259,7 @@ static void hdlc_setup(struct net_device *dev)
 struct net_device *alloc_hdlcdev(void *priv)
 {
 	struct net_device *dev;
-	dev = alloc_netdev(sizeof(struct hdlc_device_desc) +
-			   sizeof(hdlc_device), "hdlc%d", hdlc_setup);
+	dev = alloc_netdev(sizeof(struct hdlc_device), "hdlc%d", hdlc_setup);
 	if (dev)
 		dev_to_hdlc(dev)->priv = priv;
 	return dev;
@@ -281,7 +276,7 @@ void unregister_hdlc_device(struct net_device *dev)
 
 
 int attach_hdlc_protocol(struct net_device *dev, struct hdlc_proto *proto,
-			 int (*rx)(struct sk_buff *skb), size_t size)
+			 size_t size)
 {
 	detach_hdlc_protocol(dev);
 
@@ -297,7 +292,6 @@ int attach_hdlc_protocol(struct net_device *dev, struct hdlc_proto *proto,
 			return -ENOBUFS;
 		}
 	dev_to_hdlc(dev)->proto = proto;
-	dev_to_desc(dev)->netif_rx = rx;
 	return 0;
 }
 
diff --git a/drivers/net/wan/hdlc_cisco.c b/drivers/net/wan/hdlc_cisco.c
index 038a6e7..7133c68 100644
--- a/drivers/net/wan/hdlc_cisco.c
+++ b/drivers/net/wan/hdlc_cisco.c
@@ -250,7 +250,7 @@ static int cisco_rx(struct sk_buff *skb)
 	return NET_RX_DROP;
 
  rx_error:
-	dev_to_desc(dev)->stats.rx_errors++; /* Mark error */
+	dev_to_hdlc(dev)->stats.rx_errors++; /* Mark error */
 	dev_kfree_skb_any(skb);
 	return NET_RX_DROP;
 }
@@ -314,6 +314,7 @@ static struct hdlc_proto proto = {
 	.stop		= cisco_stop,
 	.type_trans	= cisco_type_trans,
 	.ioctl		= cisco_ioctl,
+	.netif_rx	= cisco_rx,
 	.module		= THIS_MODULE,
 };
 
@@ -360,7 +361,7 @@ static int cisco_ioctl(struct net_device *dev, struct ifreq *ifr)
 		if (result)
 			return result;
 
-		result = attach_hdlc_protocol(dev, &proto, cisco_rx,
+		result = attach_hdlc_protocol(dev, &proto,
 					      sizeof(struct cisco_state));
 		if (result)
 			return result;
diff --git a/drivers/net/wan/hdlc_fr.c b/drivers/net/wan/hdlc_fr.c
index 071a64c..c4ab032 100644
--- a/drivers/net/wan/hdlc_fr.c
+++ b/drivers/net/wan/hdlc_fr.c
@@ -42,7 +42,6 @@
 #include <linux/init.h>
 #include <linux/skbuff.h>
 #include <linux/pkt_sched.h>
-#include <linux/random.h>
 #include <linux/inetdevice.h>
 #include <linux/lapb.h>
 #include <linux/rtnetlink.h>
@@ -136,6 +135,10 @@ typedef struct pvc_device_struct {
 	}state;
 }pvc_device;
 
+struct pvc_desc {
+	struct net_device_stats stats;
+	pvc_device *pvc;
+};
 
 struct frad_state {
 	fr_proto settings;
@@ -171,17 +174,20 @@ static inline void dlci_to_q922(u8 *hdr, u16 dlci)
 }
 
 
-static inline struct frad_state * state(hdlc_device *hdlc)
+static inline struct frad_state* state(hdlc_device *hdlc)
 {
 	return(struct frad_state *)(hdlc->state);
 }
 
-
-static __inline__ pvc_device* dev_to_pvc(struct net_device *dev)
+static inline struct pvc_desc* pvcdev_to_desc(struct net_device *dev)
 {
 	return dev->priv;
 }
 
+static inline struct net_device_stats* pvc_get_stats(struct net_device *dev)
+{
+	return &pvcdev_to_desc(dev)->stats;
+}
 
 static inline pvc_device* find_pvc(hdlc_device *hdlc, u16 dlci)
 {
@@ -351,7 +357,7 @@ static int fr_hard_header(struct sk_buff **skb_p, u16 dlci)
 
 static int pvc_open(struct net_device *dev)
 {
-	pvc_device *pvc = dev_to_pvc(dev);
+	pvc_device *pvc = pvcdev_to_desc(dev)->pvc;
 
 	if ((pvc->frad->flags & IFF_UP) == 0)
 		return -EIO;  /* Frad must be UP in order to activate PVC */
@@ -371,7 +377,7 @@ static int pvc_open(struct net_device *dev)
 
 static int pvc_close(struct net_device *dev)
 {
-	pvc_device *pvc = dev_to_pvc(dev);
+	pvc_device *pvc = pvcdev_to_desc(dev)->pvc;
 
 	if (--pvc->open_count == 0) {
 		hdlc_device *hdlc = dev_to_hdlc(pvc->frad);
@@ -390,7 +396,7 @@ static int pvc_close(struct net_device *dev)
 
 static int pvc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	pvc_device *pvc = dev_to_pvc(dev);
+	pvc_device *pvc = pvcdev_to_desc(dev)->pvc;
 	fr_proto_pvc_info info;
 
 	if (ifr->ifr_settings.type == IF_GET_PROTO) {
@@ -416,17 +422,9 @@ static int pvc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	return -EINVAL;
 }
 
-
-static inline struct net_device_stats *pvc_get_stats(struct net_device *dev)
-{
-	return &dev_to_desc(dev)->stats;
-}
-
-
-
 static int pvc_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	pvc_device *pvc = dev_to_pvc(dev);
+	pvc_device *pvc = pvcdev_to_desc(dev)->pvc;
 	struct net_device_stats *stats = pvc_get_stats(dev);
 
 	if (pvc->state.active) {
@@ -957,7 +955,7 @@ static int fr_rx(struct sk_buff *skb)
 
 
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL) {
-		dev_to_desc(frad)->stats.rx_dropped++;
+		dev_to_hdlc(frad)->stats.rx_dropped++;
 		return NET_RX_DROP;
 	}
 
@@ -1018,7 +1016,7 @@ static int fr_rx(struct sk_buff *skb)
 	}
 
  rx_error:
-	dev_to_desc(frad)->stats.rx_errors++; /* Mark error */
+	dev_to_hdlc(frad)->stats.rx_errors++; /* Mark error */
 	dev_kfree_skb_any(skb);
 	return NET_RX_DROP;
 }
@@ -1109,11 +1107,10 @@ static int fr_add_pvc(struct net_device *frad, unsigned int dlci, int type)
 	used = pvc_is_used(pvc);
 
 	if (type == ARPHRD_ETHER)
-		dev = alloc_netdev(sizeof(struct net_device_stats),
-				   "pvceth%d", ether_setup);
+		dev = alloc_netdev(sizeof(struct pvc_desc), "pvceth%d",
+				   ether_setup);
 	else
-		dev = alloc_netdev(sizeof(struct net_device_stats),
-				   "pvc%d", pvc_setup);
+		dev = alloc_netdev(sizeof(struct pvc_desc), "pvc%d", pvc_setup);
 
 	if (!dev) {
 		printk(KERN_WARNING "%s: Memory squeeze on fr_pvc()\n",
@@ -1122,10 +1119,9 @@ static int fr_add_pvc(struct net_device *frad, unsigned int dlci, int type)
 		return -ENOBUFS;
 	}
 
-	if (type == ARPHRD_ETHER) {
-		memcpy(dev->dev_addr, "\x00\x01", 2);
-                get_random_bytes(dev->dev_addr + 2, ETH_ALEN - 2);
-	} else {
+	if (type == ARPHRD_ETHER)
+		random_ether_addr(dev->dev_addr);
+	else {
 		*(__be16*)dev->dev_addr = htons(dlci);
 		dlci_to_q922(dev->broadcast, dlci);
 	}
@@ -1137,7 +1133,7 @@ static int fr_add_pvc(struct net_device *frad, unsigned int dlci, int type)
 	dev->change_mtu = pvc_change_mtu;
 	dev->mtu = HDLC_MAX_MTU;
 	dev->tx_queue_len = 0;
-	dev->priv = pvc;
+	pvcdev_to_desc(dev)->pvc = pvc;
 
 	result = dev_alloc_name(dev, dev->name);
 	if (result < 0) {
@@ -1219,6 +1215,7 @@ static struct hdlc_proto proto = {
 	.stop		= fr_stop,
 	.detach		= fr_destroy,
 	.ioctl		= fr_ioctl,
+	.netif_rx	= fr_rx,
 	.module		= THIS_MODULE,
 };
 
@@ -1277,7 +1274,7 @@ static int fr_ioctl(struct net_device *dev, struct ifreq *ifr)
 			return result;
 
 		if (dev_to_hdlc(dev)->proto != &proto) { /* Different proto */
-			result = attach_hdlc_protocol(dev, &proto, fr_rx,
+			result = attach_hdlc_protocol(dev, &proto,
 						      sizeof(struct frad_state));
 			if (result)
 				return result;
diff --git a/drivers/net/wan/hdlc_ppp.c b/drivers/net/wan/hdlc_ppp.c
index 519e155..10396d9 100644
--- a/drivers/net/wan/hdlc_ppp.c
+++ b/drivers/net/wan/hdlc_ppp.c
@@ -122,7 +122,7 @@ static int ppp_ioctl(struct net_device *dev, struct ifreq *ifr)
 		if (result)
 			return result;
 
-		result = attach_hdlc_protocol(dev, &proto, NULL,
+		result = attach_hdlc_protocol(dev, &proto,
 					      sizeof(struct ppp_state));
 		if (result)
 			return result;
diff --git a/drivers/net/wan/hdlc_raw.c b/drivers/net/wan/hdlc_raw.c
index e23bc66..bbbb819 100644
--- a/drivers/net/wan/hdlc_raw.c
+++ b/drivers/net/wan/hdlc_raw.c
@@ -82,7 +82,7 @@ static int raw_ioctl(struct net_device *dev, struct ifreq *ifr)
 		if (result)
 			return result;
 
-		result = attach_hdlc_protocol(dev, &proto, NULL,
+		result = attach_hdlc_protocol(dev, &proto,
 					      sizeof(raw_hdlc_proto));
 		if (result)
 			return result;
diff --git a/drivers/net/wan/hdlc_raw_eth.c b/drivers/net/wan/hdlc_raw_eth.c
index 8895394..d20c685 100644
--- a/drivers/net/wan/hdlc_raw_eth.c
+++ b/drivers/net/wan/hdlc_raw_eth.c
@@ -18,7 +18,6 @@
 #include <linux/init.h>
 #include <linux/skbuff.h>
 #include <linux/pkt_sched.h>
-#include <linux/random.h>
 #include <linux/inetdevice.h>
 #include <linux/lapb.h>
 #include <linux/rtnetlink.h>
@@ -96,7 +95,7 @@ static int raw_eth_ioctl(struct net_device *dev, struct ifreq *ifr)
 		if (result)
 			return result;
 
-		result = attach_hdlc_protocol(dev, &proto, NULL,
+		result = attach_hdlc_protocol(dev, &proto,
 					      sizeof(raw_hdlc_proto));
 		if (result)
 			return result;
@@ -107,8 +106,7 @@ static int raw_eth_ioctl(struct net_device *dev, struct ifreq *ifr)
 		ether_setup(dev);
 		dev->change_mtu = old_ch_mtu;
 		dev->tx_queue_len = old_qlen;
-		memcpy(dev->dev_addr, "\x00\x01", 2);
-                get_random_bytes(dev->dev_addr + 2, ETH_ALEN - 2);
+		random_ether_addr(dev->dev_addr);
 		netif_dormant_off(dev);
 		return 0;
 	}
diff --git a/drivers/net/wan/hdlc_x25.c b/drivers/net/wan/hdlc_x25.c
index cd7b22f..c15cc11 100644
--- a/drivers/net/wan/hdlc_x25.c
+++ b/drivers/net/wan/hdlc_x25.c
@@ -164,17 +164,17 @@ static void x25_close(struct net_device *dev)
 
 static int x25_rx(struct sk_buff *skb)
 {
-	struct hdlc_device_desc *desc = dev_to_desc(skb->dev);
+	struct hdlc_device *hdlc = dev_to_hdlc(skb->dev);
 
 	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL) {
-		desc->stats.rx_dropped++;
+		hdlc->stats.rx_dropped++;
 		return NET_RX_DROP;
 	}
 
 	if (lapb_data_received(skb->dev, skb) == LAPB_OK)
 		return NET_RX_SUCCESS;
 
-	desc->stats.rx_errors++;
+	hdlc->stats.rx_errors++;
 	dev_kfree_skb_any(skb);
 	return NET_RX_DROP;
 }
@@ -184,6 +184,7 @@ static struct hdlc_proto proto = {
 	.open		= x25_open,
 	.close		= x25_close,
 	.ioctl		= x25_ioctl,
+	.netif_rx	= x25_rx,
 	.module		= THIS_MODULE,
 };
 
@@ -211,8 +212,7 @@ static int x25_ioctl(struct net_device *dev, struct ifreq *ifr)
 		if (result)
 			return result;
 
-		if ((result = attach_hdlc_protocol(dev, &proto,
-						   x25_rx, 0)) != 0)
+		if ((result = attach_hdlc_protocol(dev, &proto, 0)))
 			return result;
 		dev->hard_start_xmit = x25_xmit;
 		dev->type = ARPHRD_X25;
diff --git a/include/linux/hdlc.h b/include/linux/hdlc.h
index db390c5..6115545 100644
--- a/include/linux/hdlc.h
+++ b/include/linux/hdlc.h
@@ -26,13 +26,6 @@
 #include <linux/netdevice.h>
 #include <linux/hdlc/ioctl.h>
 
-
-/* Used by all network devices here, pointed to by netdev_priv(dev) */
-struct hdlc_device_desc {
-	int (*netif_rx)(struct sk_buff *skb);
-	struct net_device_stats stats;
-};
-
 /* This structure is a private property of HDLC protocols.
    Hardware drivers have no interest here */
 
@@ -44,12 +37,15 @@ struct hdlc_proto {
 	void (*detach)(struct net_device *dev);
 	int (*ioctl)(struct net_device *dev, struct ifreq *ifr);
 	__be16 (*type_trans)(struct sk_buff *skb, struct net_device *dev);
+	int (*netif_rx)(struct sk_buff *skb);
 	struct module *module;
 	struct hdlc_proto *next; /* next protocol in the list */
 };
 
 
+/* Pointed to by dev->priv */
 typedef struct hdlc_device {
+	struct net_device_stats stats;
 	/* used by HDLC layer to take control over HDLC device from hw driver*/
 	int (*attach)(struct net_device *dev,
 		      unsigned short encoding, unsigned short parity);
@@ -83,18 +79,11 @@ void unregister_hdlc_protocol(struct hdlc_proto *proto);
 
 struct net_device *alloc_hdlcdev(void *priv);
 
-
-static __inline__ struct hdlc_device_desc* dev_to_desc(struct net_device *dev)
-{
-	return netdev_priv(dev);
-}
-
-static __inline__ hdlc_device* dev_to_hdlc(struct net_device *dev)
+static inline struct hdlc_device* dev_to_hdlc(struct net_device *dev)
 {
-	return netdev_priv(dev) + sizeof(struct hdlc_device_desc);
+	return dev->priv;
 }
 
-
 static __inline__ void debug_frame(const struct sk_buff *skb)
 {
 	int i;
@@ -116,13 +105,13 @@ int hdlc_open(struct net_device *dev);
 void hdlc_close(struct net_device *dev);
 
 int attach_hdlc_protocol(struct net_device *dev, struct hdlc_proto *proto,
-			 int (*rx)(struct sk_buff *skb), size_t size);
+			 size_t size);
 /* May be used by hardware driver to gain control over HDLC device */
 void detach_hdlc_protocol(struct net_device *dev);
 
 static __inline__ struct net_device_stats *hdlc_stats(struct net_device *dev)
 {
-	return &dev_to_desc(dev)->stats;
+	return &dev_to_hdlc(dev)->stats;
 }
 
 
