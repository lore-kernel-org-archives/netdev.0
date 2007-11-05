From: Robert Schwebel <r.schwebel@pengutronix.de>
Subject: [PATCH] netX: update ethernet driver to firmware 1007
Date: Mon, 5 Nov 2007 14:08:42 +0100
Message-ID: <20071105130842.GJ8087@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.extern.pengutronix.de ([83.236.181.26]:48309 "EHLO
	metis.extern.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754712AbXKENIq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 08:08:46 -0500
Received: from rsc by metis.extern.pengutronix.de with local (Exim 4.63)
	(envelope-from <rsc@pengutronix.de>)
	id 1Ip1h4-0004h5-32
	for netdev@vger.kernel.org; Mon, 05 Nov 2007 14:08:46 +0100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sascha Hauer <s.hauer@pengutronix.de>

The ethernet firmware revision 1007 fixes several issues with the
network chip. This update makes the driver work with that firmware
revision.

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>

---
 drivers/net/netx-eth.c |   91 +++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 73 insertions(+), 18 deletions(-)

Index: drivers/net/netx-eth.c
===================================================================
--- drivers/net/netx-eth.c.orig
+++ drivers/net/netx-eth.c
@@ -71,18 +71,29 @@
 #define FIFO_PTR_ERROR_MASK     (0xf << 28)
 
 #define ISR_LINK_STATUS_CHANGE (1<<4)
-#define ISR_IND_LO             (1<<3)
-#define ISR_CON_LO             (1<<2)
-#define ISR_IND_HI             (1<<1)
-#define ISR_CON_HI             (1<<0)
+#define ISR_IND_LO             (priv->xc_version >= 1007 ? (1<<1) : (1<<3))
+#define ISR_CON_LO             (priv->xc_version >= 1007 ? (1<<3) : (1<<2))
+#define ISR_IND_HI             (priv->xc_version >= 1007 ? (1<<0) : (1<<1))
+#define ISR_CON_HI             (priv->xc_version >= 1007 ? (1<<2) : (1<<0))
 
 #define ETH_MAC_LOCAL_CONFIG 0x1560
-#define ETH_MAC_4321         0x1564
-#define ETH_MAC_65           0x1568
+
+/* Firmware >= 1.007 */
+#define ETH_MAC_IRQ_ENABLE   0x1564
+#define IRQ_ENABLE_IND_HI      (1<<0)
+#define IRQ_ENABLE_IND_LO      (1<<1)
+#define IRQ_ENABLE_CON_HI      (1<<2)
+#define IRQ_ENABLE_CON_LO      (1<<3)
+#define IRQ_ENABLE_LINK_STATUS (1<<4)
+
+#define ETH_MAC_4321         (0x1564 + ((priv->xc_version >= 1007) ? 4 : 0))
+#define ETH_MAC_65           (0x1568 + ((priv->xc_version >= 1007) ? 4 : 0))
 
 #define MAC_TRAFFIC_CLASS_ARRANGEMENT_SHIFT 16
 #define MAC_TRAFFIC_CLASS_ARRANGEMENT_MASK (0xf<<MAC_TRAFFIC_CLASS_ARRANGEMENT_SHIFT)
 #define MAC_TRAFFIC_CLASS_ARRANGEMENT(x) (((x)<<MAC_TRAFFIC_CLASS_ARRANGEMENT_SHIFT) & MAC_TRAFFIC_CLASS_ARRANGEMENT_MASK)
+
+/* Firmware < 1.007 */
 #define LOCAL_CONFIG_LINK_STATUS_IRQ_EN (1<<24)
 #define LOCAL_CONFIG_CON_LO_IRQ_EN (1<<23)
 #define LOCAL_CONFIG_CON_HI_IRQ_EN (1<<22)
@@ -101,6 +112,8 @@ struct netx_eth_priv {
 	u32                     msg_enable;
 	struct xc               *xc;
 	spinlock_t              lock;
+
+	int			xc_version;
 };
 
 static void netx_eth_set_multicast_list(struct net_device *ndev)
@@ -128,8 +141,8 @@ netx_eth_hard_start_xmit(struct sk_buff 
 	           FIFO_PTR_FRAMELEN(len));
 
 	ndev->trans_start = jiffies;
-	dev->stats.tx_packets++;
-	dev->stats.tx_bytes += skb->len;
+	ndev->stats.tx_packets++;
+	ndev->stats.tx_bytes += skb->len;
 
 	netif_stop_queue(ndev);
 	spin_unlock_irq(&priv->lock);
@@ -155,7 +168,7 @@ static void netx_eth_receive(struct net_
 	if (unlikely(skb == NULL)) {
 		printk(KERN_NOTICE "%s: Low memory, packet dropped.\n",
 			ndev->name);
-		dev->stats.rx_dropped++;
+		ndev->stats.rx_dropped++;
 		return;
 	}
 
@@ -169,8 +182,8 @@ static void netx_eth_receive(struct net_
 	ndev->last_rx = jiffies;
 	skb->protocol = eth_type_trans(skb, ndev);
 	netif_rx(skb);
-	dev->stats.rx_packets++;
-	dev->stats.rx_bytes += len;
+	ndev->stats.rx_packets++;
+	ndev->stats.rx_bytes += len;
 }
 
 static irqreturn_t
@@ -226,13 +239,23 @@ static int netx_eth_open(struct net_devi
 	       ndev->dev_addr[5]<<8,
 	       priv->xpec_base + NETX_XPEC_RAM_START_OFS + ETH_MAC_65);
 
-	writel(LOCAL_CONFIG_LINK_STATUS_IRQ_EN |
-		LOCAL_CONFIG_CON_LO_IRQ_EN |
-		LOCAL_CONFIG_CON_HI_IRQ_EN |
-		LOCAL_CONFIG_IND_LO_IRQ_EN |
-		LOCAL_CONFIG_IND_HI_IRQ_EN,
-		priv->xpec_base + NETX_XPEC_RAM_START_OFS +
-		ETH_MAC_LOCAL_CONFIG);
+	if (priv->xc_version >= 1007) {
+		writel(IRQ_ENABLE_LINK_STATUS |
+			IRQ_ENABLE_CON_LO     |
+			IRQ_ENABLE_CON_HI     |
+			IRQ_ENABLE_IND_LO     |
+			IRQ_ENABLE_IND_HI,
+			priv->xpec_base + NETX_XPEC_RAM_START_OFS +
+			ETH_MAC_IRQ_ENABLE);
+	} else {
+		writel(LOCAL_CONFIG_LINK_STATUS_IRQ_EN |
+			LOCAL_CONFIG_CON_LO_IRQ_EN |
+			LOCAL_CONFIG_CON_HI_IRQ_EN |
+			LOCAL_CONFIG_IND_LO_IRQ_EN |
+			LOCAL_CONFIG_IND_HI_IRQ_EN,
+			priv->xpec_base + NETX_XPEC_RAM_START_OFS +
+			ETH_MAC_LOCAL_CONFIG);
+	}
 
 	mii_check_media(&priv->mii, netif_msg_link(priv), 1);
 	netif_start_queue(ndev);
@@ -249,6 +272,9 @@ static int netx_eth_close(struct net_dev
 	writel(0,
 	    priv->xpec_base + NETX_XPEC_RAM_START_OFS + ETH_MAC_LOCAL_CONFIG);
 
+	writel(0,
+	    priv->xpec_base + NETX_XPEC_RAM_START_OFS + ETH_MAC_IRQ_ENABLE);
+
 	free_irq(ndev->irq, ndev);
 
 	return 0;
@@ -303,6 +329,30 @@ netx_eth_phy_write(struct net_device *nd
 	while (readl(NETX_MIIMU) & MIIMU_SNRDY);
 }
 
+static int netx_eth_get_xc_version(struct net_device *ndev)
+{
+	struct netx_eth_priv *priv = netdev_priv(ndev);
+	unsigned long val;
+
+	val = readl(priv->xc->xmac_base + 0x48);
+
+	switch (val) {
+	case 0x20c000c9:
+		priv->xc_version = 1006;
+		break;
+	case 0x0137fe41:
+		priv->xc_version = 1007;
+		break;
+	default:
+		printk(KERN_ERR "%s: could not determine firmware version: 0x%08lx\n", ndev->name, val);
+		return -1;
+	}
+
+	printk(KERN_INFO "%s: found firmware version %d\n", ndev->name, priv->xc_version);
+
+	return 0;
+}
+
 static int netx_eth_enable(struct net_device *ndev)
 {
 	struct netx_eth_priv *priv = netdev_priv(ndev);
@@ -335,6 +385,9 @@ static int netx_eth_enable(struct net_de
 	 * loaded the firmware for us
 	 */
 	if (running) {
+		if (netx_eth_get_xc_version(ndev))
+			return -ENODEV;
+
 		/* get Node Address from hardware */
 		mac4321 = readl(priv->xpec_base +
 			NETX_XPEC_RAM_START_OFS + ETH_MAC_4321);
@@ -352,6 +405,8 @@ static int netx_eth_enable(struct net_de
 			printk(CARDNAME ": requesting firmware failed\n");
 			return -ENODEV;
 		}
+		if (netx_eth_get_xc_version(ndev))
+			return -ENODEV;
 	}
 
 	xc_reset(priv->xc);
