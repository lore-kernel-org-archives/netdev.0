From: Scott Wood <scottwood@freescale.com>
Subject: [PATCH 8/8] gianfar: Magic Packet and suspend/resume support.
Date: Wed, 12 Dec 2007 11:36:07 -0600
Message-ID: <20071212173607.GG5596@loki.buserror.net>
References: <20071212173519.GA5577@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org
To: paulus@samba.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:35217 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772AbXLLRgh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 12:36:37 -0500
Content-Disposition: inline
In-Reply-To: <20071212173519.GA5577@loki.buserror.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Scott Wood <scottwood@freescale.com>
---
Jeff, can you ack this to go through Paul's tree
(assuming nothing wrong with it)?

 drivers/net/gianfar.c         |  137 ++++++++++++++++++++++++++++++++++++++++-
 drivers/net/gianfar.h         |   13 +++-
 drivers/net/gianfar_ethtool.c |   41 ++++++++++++-
 3 files changed, 185 insertions(+), 6 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 0431e9e..2c1b8d5 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -142,6 +142,7 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit);
 static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb, int length);
 static void gfar_vlan_rx_register(struct net_device *netdev,
 		                struct vlan_group *grp);
+static void gfar_halt_nodisable(struct net_device *dev);
 void gfar_halt(struct net_device *dev);
 void gfar_start(struct net_device *dev);
 static void gfar_clear_exact_match(struct net_device *dev);
@@ -216,6 +217,7 @@ static int gfar_probe(struct platform_device *pdev)
 
 	spin_lock_init(&priv->txlock);
 	spin_lock_init(&priv->rxlock);
+	spin_lock_init(&priv->bflock);
 
 	platform_set_drvdata(pdev, dev);
 
@@ -393,6 +395,122 @@ static int gfar_remove(struct platform_device *pdev)
 	return 0;
 }
 
+#ifdef CONFIG_PM
+static int gfar_suspend(struct platform_device *pdev, pm_message_t state)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+	struct gfar_private *priv = netdev_priv(dev);
+	unsigned long flags;
+	u32 tempval;
+
+	int magic_packet = priv->wol_en &&
+		(priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
+
+	netif_device_detach(dev);
+
+	if (netif_running(dev)) {
+		spin_lock_irqsave(&priv->txlock, flags);
+		spin_lock(&priv->rxlock);
+
+		gfar_halt_nodisable(dev);
+
+		/* Disable Tx, and Rx if wake-on-LAN is disabled. */
+		tempval = gfar_read(&priv->regs->maccfg1);
+
+		tempval &= ~MACCFG1_TX_EN;
+
+		if (!magic_packet)
+			tempval &= ~MACCFG1_RX_EN;
+
+		gfar_write(&priv->regs->maccfg1, tempval);
+
+		spin_unlock(&priv->rxlock);
+		spin_unlock_irqrestore(&priv->txlock, flags);
+
+#ifdef CONFIG_GFAR_NAPI
+		napi_disable(&priv->napi);
+#endif
+
+		if (magic_packet) {
+			/* Enable interrupt on Magic Packet */
+			gfar_write(&priv->regs->imask, IMASK_MAG);
+
+			/* Enable Magic Packet mode */
+			tempval = gfar_read(&priv->regs->maccfg2);
+			tempval |= MACCFG2_MPEN;
+			gfar_write(&priv->regs->maccfg2, tempval);
+		} else {
+			phy_stop(priv->phydev);
+		}
+	}
+
+	if (!magic_packet || !netif_running(dev)) {
+		/* The device with the MDIO in its register block must
+		 * not be put to sleep if any other network devices
+		 * using the same MDIO are active.  Ideally, some sort
+		 * of reference counting could be done, but for now
+		 * just don't put the MDIO-containing dev to sleep
+		 * at all.
+		 */
+		if (!(priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_MDIO)) {
+			fsl_sleep_device(&priv->einfo->sleep);
+			priv->suspended = 1;
+		}
+	}
+
+	return 0;
+}
+
+static int gfar_resume(struct platform_device *pdev)
+{
+	struct net_device *dev = platform_get_drvdata(pdev);
+	struct gfar_private *priv = netdev_priv(dev);
+	unsigned long flags;
+	u32 tempval;
+	int magic_packet = priv->wol_en &&
+		(priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
+
+	if (priv->suspended) {
+		fsl_wake_device(&priv->einfo->sleep);
+		priv->suspended = 0;
+	}
+
+	if (!netif_running(dev)) {
+		netif_device_attach(dev);
+		return 0;
+	}
+
+	if (!magic_packet && priv->phydev)
+		phy_start(priv->phydev);
+
+	/* Disable Magic Packet mode, in case something
+	 * else woke us up.
+	 */
+
+	spin_lock_irqsave(&priv->txlock, flags);
+	spin_lock(&priv->rxlock);
+
+	tempval = gfar_read(&priv->regs->maccfg2);
+	tempval &= ~MACCFG2_MPEN;
+	gfar_write(&priv->regs->maccfg2, tempval);
+
+	gfar_start(dev);
+
+	spin_unlock(&priv->rxlock);
+	spin_unlock_irqrestore(&priv->txlock, flags);
+
+	netif_device_attach(dev);
+
+#ifdef CONFIG_GFAR_NAPI
+	napi_enable(&priv->napi);
+#endif
+
+	return 0;
+}
+#else
+#define gfar_suspend NULL
+#define gfar_resume NULL
+#endif
 
 /* Reads the controller's registers to determine what interface
  * connects it to the PHY.
@@ -547,7 +665,7 @@ static void init_registers(struct net_device *dev)
 
 
 /* Halt the receive and transmit queues */
-void gfar_halt(struct net_device *dev)
+static void gfar_halt_nodisable(struct net_device *dev)
 {
 	struct gfar_private *priv = netdev_priv(dev);
 	struct gfar __iomem *regs = priv->regs;
@@ -570,6 +688,14 @@ void gfar_halt(struct net_device *dev)
 			 (IEVENT_GRSC | IEVENT_GTSC)))
 			cpu_relax();
 	}
+}
+
+/* Halt the receive and transmit queues */
+void gfar_halt(struct net_device *dev)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	struct gfar __iomem *regs = priv->regs;
+	u32 tempval;
 
 	/* Disable Rx and Tx */
 	tempval = gfar_read(&regs->maccfg1);
@@ -1909,7 +2035,12 @@ static irqreturn_t gfar_error(int irq, void *dev_id)
 	u32 events = gfar_read(&priv->regs->ievent);
 
 	/* Clear IEVENT */
-	gfar_write(&priv->regs->ievent, IEVENT_ERR_MASK);
+	gfar_write(&priv->regs->ievent, events & IEVENT_ERR_MASK);
+
+	/* Magic Packet is not an error. */
+	if ((priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET) &&
+	    (events & IEVENT_MAG))
+		events &= ~IEVENT_MAG;
 
 	/* Hmm... */
 	if (netif_msg_rx_err(priv) || netif_msg_tx_err(priv))
@@ -1979,6 +2110,8 @@ static irqreturn_t gfar_error(int irq, void *dev_id)
 static struct platform_driver gfar_driver = {
 	.probe = gfar_probe,
 	.remove = gfar_remove,
+	.suspend = gfar_suspend,
+	.resume = gfar_resume,
 	.driver	= {
 		.name = "fsl-gianfar",
 	},
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 46cd773..922ed36 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -162,6 +162,7 @@ extern const char gfar_driver_version[];
 #define MACCFG2_GMII            0x00000200
 #define MACCFG2_HUGEFRAME	0x00000020
 #define MACCFG2_LENGTHCHECK	0x00000010
+#define MACCFG2_MPEN		0x00000008
 
 #define ECNTRL_INIT_SETTINGS	0x00001000
 #define ECNTRL_TBI_MODE         0x00000020
@@ -234,6 +235,7 @@ extern const char gfar_driver_version[];
 #define IEVENT_CRL		0x00020000
 #define IEVENT_XFUN		0x00010000
 #define IEVENT_RXB0		0x00008000
+#define IEVENT_MAG		0x00000800
 #define IEVENT_GRSC		0x00000100
 #define IEVENT_RXF0		0x00000080
 #define IEVENT_FIR		0x00000008
@@ -245,7 +247,8 @@ extern const char gfar_driver_version[];
 #define IEVENT_ERR_MASK         \
 (IEVENT_RXC | IEVENT_BSY | IEVENT_EBERR | IEVENT_MSRO | \
  IEVENT_BABT | IEVENT_TXC | IEVENT_TXE | IEVENT_LC \
- | IEVENT_CRL | IEVENT_XFUN | IEVENT_DPE | IEVENT_PERR)
+ | IEVENT_CRL | IEVENT_XFUN | IEVENT_DPE | IEVENT_PERR \
+ | IEVENT_MAG)
 
 #define IMASK_INIT_CLEAR	0x00000000
 #define IMASK_BABR              0x80000000
@@ -263,6 +266,7 @@ extern const char gfar_driver_version[];
 #define IMASK_CRL		0x00020000
 #define IMASK_XFUN		0x00010000
 #define IMASK_RXB0              0x00008000
+#define IMASK_MAG		0x00000800
 #define IMASK_GTSC              0x00000100
 #define IMASK_RXFEN0		0x00000080
 #define IMASK_FIR		0x00000008
@@ -726,10 +730,15 @@ struct gfar_private {
 	unsigned int fifo_starve;
 	unsigned int fifo_starve_off;
 
+	/* Bitfield update lock */
+	spinlock_t bflock;
+
 	unsigned char vlan_enable:1,
 		rx_csum_enable:1,
 		extended_hash:1,
-		bd_stash_en:1;
+		bd_stash_en:1,
+		wol_en:1, /* Wake-on-LAN enabled */
+		suspended:1;
 	unsigned short padding;
 
 	unsigned int interruptTransmit;
diff --git a/drivers/net/gianfar_ethtool.c b/drivers/net/gianfar_ethtool.c
index 6007147..fb7d3cc 100644
--- a/drivers/net/gianfar_ethtool.c
+++ b/drivers/net/gianfar_ethtool.c
@@ -479,14 +479,13 @@ static int gfar_sringparam(struct net_device *dev, struct ethtool_ringparam *rva
 static int gfar_set_rx_csum(struct net_device *dev, uint32_t data)
 {
 	struct gfar_private *priv = netdev_priv(dev);
+	unsigned long flags;
 	int err = 0;
 
 	if (!(priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_CSUM))
 		return -EOPNOTSUPP;
 
 	if (dev->flags & IFF_UP) {
-		unsigned long flags;
-
 		/* Halt TX and RX, and process the frames which
 		 * have already been received */
 		spin_lock_irqsave(&priv->txlock, flags);
@@ -502,7 +501,9 @@ static int gfar_set_rx_csum(struct net_device *dev, uint32_t data)
 		stop_gfar(dev);
 	}
 
+	spin_lock_irqsave(&priv->bflock, flags);
 	priv->rx_csum_enable = data;
+	spin_unlock_irqrestore(&priv->bflock, flags);
 
 	if (dev->flags & IFF_UP)
 		err = startup_gfar(dev);
@@ -564,6 +565,38 @@ static void gfar_set_msglevel(struct net_device *dev, uint32_t data)
 	priv->msg_enable = data;
 }
 
+#ifdef CONFIG_PM
+static void gfar_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+
+	if (priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET) {
+		wol->supported = WAKE_MAGIC;
+		wol->wolopts = priv->wol_en ? WAKE_MAGIC : 0;
+	} else {
+		wol->supported = wol->wolopts = 0;
+	}
+}
+
+static int gfar_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
+{
+	struct gfar_private *priv = netdev_priv(dev);
+	unsigned long flags;
+
+	if (!(priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET) &&
+	    wol->wolopts != 0)
+		return -EINVAL;
+
+	if (wol->wolopts & ~WAKE_MAGIC)
+		return -EINVAL;
+
+	spin_lock_irqsave(&priv->bflock, flags);
+	priv->wol_en = wol->wolopts & WAKE_MAGIC ? 1 : 0;
+	spin_unlock_irqrestore(&priv->bflock, flags);
+
+	return 0;
+}
+#endif
 
 const struct ethtool_ops gfar_ethtool_ops = {
 	.get_settings = gfar_gsettings,
@@ -585,4 +618,8 @@ const struct ethtool_ops gfar_ethtool_ops = {
 	.set_tx_csum = gfar_set_tx_csum,
 	.get_msglevel = gfar_get_msglevel,
 	.set_msglevel = gfar_set_msglevel,
+#ifdef CONFIG_PM
+	.get_wol = gfar_get_wol,
+	.set_wol = gfar_set_wol,
+#endif
 };
-- 
1.5.3.7
