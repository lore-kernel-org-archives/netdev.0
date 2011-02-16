From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: [PATCH v3] sh: sh_eth: Add support ethtool
Date: Wed, 16 Feb 2011 16:17:32 +0900
Message-ID: <1297840652-20883-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
Cc: linux-sh@vger.kernel.org, bhutchings@solarflare.com,
	eric.dumazet@gmail.com,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This commit supports following functions.
  - get_settings
  - set_settings
  - nway_reset
  - get_msglevel
  - set_msglevel
  - get_link
  - get_strings
  - get_ethtool_stats
  - get_sset_count

About other function, the device does not support.

Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
---
>From v2:
 - Remove get function of standard device stats.
 - Remove get_drvinfo function.
 - Change mdelay 100ms to 1ms in reset fucntion
 - Change function name from sh_eth_link* to sh_eth_rcv_snd_*.
   Because sh_eth_link* function does not linkup/down.
 - Add netif_msg_* function.

 drivers/net/sh_eth.c |  208 +++++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 189 insertions(+), 19 deletions(-)

diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 819c175..095e525 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -32,10 +32,17 @@
 #include <linux/io.h>
 #include <linux/pm_runtime.h>
 #include <linux/slab.h>
+#include <linux/ethtool.h>
 #include <asm/cacheflush.h>
 
 #include "sh_eth.h"
 
+#define SH_ETH_DEF_MSG_ENABLE \
+		(NETIF_MSG_LINK	| \
+		NETIF_MSG_TIMER	| \
+		NETIF_MSG_RX_ERR| \
+		NETIF_MSG_TX_ERR)
+
 /* There is CPU dependent code */
 #if defined(CONFIG_CPU_SUBTYPE_SH7724)
 #define SH_ETH_RESET_DEFAULT	1
@@ -817,6 +824,20 @@ static int sh_eth_rx(struct net_device *ndev)
 	return 0;
 }
 
+static void sh_eth_rcv_snd_disable(u32 ioaddr)
+{
+	/* disable tx and rx */
+	writel(readl(ioaddr + ECMR) &
+		~(ECMR_RE | ECMR_TE), ioaddr + ECMR);
+}
+
+static void sh_eth_rcv_snd_enable(u32 ioaddr)
+{
+	/* enable tx and rx */
+	writel(readl(ioaddr + ECMR) |
+		(ECMR_RE | ECMR_TE), ioaddr + ECMR);
+}
+
 /* error control function */
 static void sh_eth_error(struct net_device *ndev, int intr_status)
 {
@@ -843,11 +864,9 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 				if (mdp->ether_link_active_low)
 					link_stat = ~link_stat;
 			}
-			if (!(link_stat & PHY_ST_LINK)) {
-				/* Link Down : disable tx and rx */
-				writel(readl(ioaddr + ECMR) &
-					  ~(ECMR_RE | ECMR_TE), ioaddr + ECMR);
-			} else {
+			if (!(link_stat & PHY_ST_LINK))
+				sh_eth_rcv_snd_disable(ioaddr);
+			else {
 				/* Link Up */
 				writel(readl(ioaddr + EESIPR) &
 					  ~DMAC_M_ECI, ioaddr + EESIPR);
@@ -857,8 +876,7 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 				writel(readl(ioaddr + EESIPR) |
 					  DMAC_M_ECI, ioaddr + EESIPR);
 				/* enable tx and rx */
-				writel(readl(ioaddr + ECMR) |
-					  (ECMR_RE | ECMR_TE), ioaddr + ECMR);
+				sh_eth_rcv_snd_enable(ioaddr);
 			}
 		}
 	}
@@ -867,6 +885,8 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 		/* Write buck end. unused write back interrupt */
 		if (intr_status & EESR_TABT)	/* Transmit Abort int */
 			mdp->stats.tx_aborted_errors++;
+			if (netif_msg_tx_err(mdp))
+				dev_err(&ndev->dev, "Transmit Abort\n");
 	}
 
 	if (intr_status & EESR_RABT) {
@@ -874,14 +894,23 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 		if (intr_status & EESR_RFRMER) {
 			/* Receive Frame Overflow int */
 			mdp->stats.rx_frame_errors++;
-			dev_err(&ndev->dev, "Receive Frame Overflow\n");
+			if (netif_msg_rx_err(mdp))
+				dev_err(&ndev->dev, "Receive Abort\n");
 		}
 	}
 
-	if (!mdp->cd->no_ade) {
-		if (intr_status & EESR_ADE && intr_status & EESR_TDE &&
-		    intr_status & EESR_TFE)
-			mdp->stats.tx_fifo_errors++;
+	if (intr_status & EESR_TDE) {
+		/* Transmit Descriptor Empty int */
+		mdp->stats.tx_fifo_errors++;
+		if (netif_msg_tx_err(mdp))
+			dev_err(&ndev->dev, "Transmit Descriptor Empty\n");
+	}
+
+	if (intr_status & EESR_TFE) {
+		/* FIFO under flow */
+		mdp->stats.tx_fifo_errors++;
+		if (netif_msg_tx_err(mdp))
+			dev_err(&ndev->dev, "Transmit FIFO Under flow\n");
 	}
 
 	if (intr_status & EESR_RDE) {
@@ -890,12 +919,22 @@ static void sh_eth_error(struct net_device *ndev, int intr_status)
 
 		if (readl(ioaddr + EDRRR) ^ EDRRR_R)
 			writel(EDRRR_R, ioaddr + EDRRR);
-		dev_err(&ndev->dev, "Receive Descriptor Empty\n");
+		if (netif_msg_rx_err(mdp))
+			dev_err(&ndev->dev, "Receive Descriptor Empty\n");
 	}
+
 	if (intr_status & EESR_RFE) {
 		/* Receive FIFO Overflow int */
 		mdp->stats.rx_fifo_errors++;
-		dev_err(&ndev->dev, "Receive FIFO Overflow\n");
+		if (netif_msg_rx_err(mdp))
+			dev_err(&ndev->dev, "Receive FIFO Overflow\n");
+	}
+
+	if (!mdp->cd->no_ade && (intr_status & EESR_ADE)) {
+		/* Address Error */
+		mdp->stats.tx_fifo_errors++;
+		if (netif_msg_tx_err(mdp))
+			dev_err(&ndev->dev, "Address Error\n");
 	}
 
 	mask = EESR_TWB | EESR_TABT | EESR_ADE | EESR_TDE | EESR_TFE;
@@ -1012,7 +1051,7 @@ static void sh_eth_adjust_link(struct net_device *ndev)
 		mdp->duplex = -1;
 	}
 
-	if (new_state)
+	if (new_state && netif_msg_link(mdp))
 		phy_print_status(phydev);
 }
 
@@ -1063,6 +1102,132 @@ static int sh_eth_phy_start(struct net_device *ndev)
 	return 0;
 }
 
+static int sh_eth_get_settings(struct net_device *ndev,
+			struct ethtool_cmd *ecmd)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	unsigned long flags;
+	int ret;
+
+	spin_lock_irqsave(&mdp->lock, flags);
+	ret = phy_ethtool_gset(mdp->phydev, ecmd);
+	spin_unlock_irqrestore(&mdp->lock, flags);
+
+	return ret;
+}
+
+static int sh_eth_set_settings(struct net_device *ndev,
+		struct ethtool_cmd *ecmd)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	unsigned long flags;
+	int ret;
+	u32 ioaddr = ndev->base_addr;
+
+	spin_lock_irqsave(&mdp->lock, flags);
+
+	/* disable tx and rx */
+	sh_eth_rcv_snd_disable(ioaddr);
+
+	ret = phy_ethtool_sset(mdp->phydev, ecmd);
+	if (ret)
+		goto error_exit;
+
+	if (ecmd->duplex == DUPLEX_FULL)
+		mdp->duplex = 1;
+	else
+		mdp->duplex = 0;
+
+	if (mdp->cd->set_duplex)
+		mdp->cd->set_duplex(ndev);
+
+error_exit:
+	mdelay(1);
+
+	/* enable tx and rx */
+	sh_eth_rcv_snd_enable(ioaddr);
+
+	spin_unlock_irqrestore(&mdp->lock, flags);
+
+	return ret;
+}
+
+static int sh_eth_nway_reset(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	unsigned long flags;
+	int ret;
+
+	spin_lock_irqsave(&mdp->lock, flags);
+	ret = phy_start_aneg(mdp->phydev);
+	spin_unlock_irqrestore(&mdp->lock, flags);
+
+	return ret;
+}
+
+static u32 sh_eth_get_msglevel(struct net_device *ndev)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	return mdp->msg_enable;
+}
+
+static void sh_eth_set_msglevel(struct net_device *ndev, u32 value)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	mdp->msg_enable = value;
+}
+
+static const char sh_eth_gstrings_stats[][ETH_GSTRING_LEN] = {
+	"rx_current", "tx_current",
+	"rx_dirty", "tx_dirty",
+};
+#define SH_ETH_STATS_LEN  ARRAY_SIZE(sh_eth_gstrings_stats)
+
+static int sh_eth_get_sset_count(struct net_device *netdev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return SH_ETH_STATS_LEN;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static void sh_eth_get_ethtool_stats(struct net_device *ndev,
+			struct ethtool_stats *stats, u64 *data)
+{
+	struct sh_eth_private *mdp = netdev_priv(ndev);
+	int i = 0;
+
+	/* device-specific stats */
+	data[i++] = mdp->cur_rx;
+	data[i++] = mdp->cur_tx;
+	data[i++] = mdp->dirty_rx;
+	data[i++] = mdp->dirty_tx;
+}
+
+static void sh_eth_get_strings(struct net_device *ndev, u32 stringset, u8 *data)
+{
+	switch (stringset) {
+	case ETH_SS_STATS:
+		memcpy(data, *sh_eth_gstrings_stats,
+					sizeof(sh_eth_gstrings_stats));
+		break;
+	}
+}
+
+static struct ethtool_ops sh_eth_ethtool_ops = {
+	.get_settings	= sh_eth_get_settings,
+	.set_settings	= sh_eth_set_settings,
+	.nway_reset		= sh_eth_nway_reset,
+	.get_msglevel	= sh_eth_get_msglevel,
+	.set_msglevel	= sh_eth_set_msglevel,
+	.get_link		= ethtool_op_get_link,
+	.get_strings	= sh_eth_get_strings,
+	.get_ethtool_stats  = sh_eth_get_ethtool_stats,
+	.get_sset_count     = sh_eth_get_sset_count,
+};
+
 /* network device open function */
 static int sh_eth_open(struct net_device *ndev)
 {
@@ -1073,8 +1238,8 @@ static int sh_eth_open(struct net_device *ndev)
 
 	ret = request_irq(ndev->irq, sh_eth_interrupt,
 #if defined(CONFIG_CPU_SUBTYPE_SH7763) || \
-    defined(CONFIG_CPU_SUBTYPE_SH7764) || \
-    defined(CONFIG_CPU_SUBTYPE_SH7757)
+	defined(CONFIG_CPU_SUBTYPE_SH7764) || \
+	defined(CONFIG_CPU_SUBTYPE_SH7757)
 				IRQF_SHARED,
 #else
 				0,
@@ -1123,8 +1288,8 @@ static void sh_eth_tx_timeout(struct net_device *ndev)
 
 	netif_stop_queue(ndev);
 
-	/* worning message out. */
-	printk(KERN_WARNING "%s: transmit timed out, status %8.8x,"
+	if (netif_msg_timer(mdp))
+		dev_err(&ndev->dev, "%s: transmit timed out, status %8.8x,"
 	       " resetting...\n", ndev->name, (int)readl(ioaddr + EESR));
 
 	/* tx_errors count up */
@@ -1167,6 +1332,8 @@ static int sh_eth_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 	spin_lock_irqsave(&mdp->lock, flags);
 	if ((mdp->cur_tx - mdp->dirty_tx) >= (TX_RING_SIZE - 4)) {
 		if (!sh_eth_txfree(ndev)) {
+			if (netif_msg_tx_queued(mdp))
+				dev_warn(&ndev->dev, "TxFD exhausted.\n");
 			netif_stop_queue(ndev);
 			spin_unlock_irqrestore(&mdp->lock, flags);
 			return NETDEV_TX_BUSY;
@@ -1497,8 +1664,11 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
 
 	/* set function */
 	ndev->netdev_ops = &sh_eth_netdev_ops;
+	SET_ETHTOOL_OPS(ndev, &sh_eth_ethtool_ops);
 	ndev->watchdog_timeo = TX_TIMEOUT;
 
+	/* debug message level */
+	mdp->msg_enable = SH_ETH_DEF_MSG_ENABLE;
 	mdp->post_rx = POST_RX >> (devno << 1);
 	mdp->post_fw = POST_FW >> (devno << 1);
 
-- 
1.7.2.3

