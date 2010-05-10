From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH 6/9] netdev: bfin_mac: add support for wake-on-lan magic packets
Date: Mon, 10 May 2010 11:39:11 -0400
Message-ID: <1273505954-32588-6-git-send-email-vapier@gentoo.org>
References: <1273505954-32588-1-git-send-email-vapier@gentoo.org>
Cc: uclinux-dist-devel@blackfin.uclinux.org,
	Michael Hennerich <michael.hennerich@analog.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:43495 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753102Ab0EJPgZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 May 2010 11:36:25 -0400
In-Reply-To: <1273505954-32588-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Hennerich <michael.hennerich@analog.com>

Note that WOL works only in PM Suspend Standby Mode (Sleep Mode).

Signed-off-by: Michael Hennerich <michael.hennerich@analog.com>
Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 drivers/net/bfin_mac.c |   76 +++++++++++++++++++++++++++++++++++++++++++++--
 drivers/net/bfin_mac.h |    3 ++
 2 files changed, 75 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index bee5d7a..967d018 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -464,6 +464,14 @@ static int mii_probe(struct net_device *dev)
  * Ethtool support
  */
 
+/*
+ * interrupt routine for magic packet wakeup
+ */
+static irqreturn_t bfin_mac_wake_interrupt(int irq, void *dev_id)
+{
+	return IRQ_HANDLED;
+}
+
 static int
 bfin_mac_ethtool_getsettings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
@@ -498,11 +506,57 @@ static void bfin_mac_ethtool_getdrvinfo(struct net_device *dev,
 	strcpy(info->bus_info, dev_name(&dev->dev));
 }
 
+static void bfin_mac_ethtool_getwol(struct net_device *dev,
+	struct ethtool_wolinfo *wolinfo)
+{
+	struct bfin_mac_local *lp = netdev_priv(dev);
+
+	wolinfo->supported = WAKE_MAGIC;
+	wolinfo->wolopts = lp->wol;
+}
+
+static int bfin_mac_ethtool_setwol(struct net_device *dev,
+	struct ethtool_wolinfo *wolinfo)
+{
+	struct bfin_mac_local *lp = netdev_priv(dev);
+	int rc;
+
+	if (wolinfo->wolopts & (WAKE_MAGICSECURE |
+				WAKE_UCAST |
+				WAKE_MCAST |
+				WAKE_BCAST |
+				WAKE_ARP))
+		return -EOPNOTSUPP;
+
+	lp->wol = wolinfo->wolopts;
+
+	if (lp->wol && !lp->irq_wake_requested) {
+		/* register wake irq handler */
+		rc = request_irq(IRQ_MAC_WAKEDET, bfin_mac_wake_interrupt,
+				 IRQF_DISABLED, "EMAC_WAKE", dev);
+		if (rc)
+			return rc;
+		lp->irq_wake_requested = true;
+	}
+
+	if (!lp->wol && lp->irq_wake_requested) {
+		free_irq(IRQ_MAC_WAKEDET, dev);
+		lp->irq_wake_requested = false;
+	}
+
+	/* Make sure the PHY driver doesn't suspend */
+	device_init_wakeup(&dev->dev, lp->wol);
+
+	return 0;
+}
+
 static const struct ethtool_ops bfin_mac_ethtool_ops = {
 	.get_settings = bfin_mac_ethtool_getsettings,
 	.set_settings = bfin_mac_ethtool_setsettings,
 	.get_link = ethtool_op_get_link,
 	.get_drvinfo = bfin_mac_ethtool_getdrvinfo,
+	.get_wol = bfin_mac_ethtool_getwol,
+	.set_wol = bfin_mac_ethtool_setwol,
 };
 
 /**************************************************************************/
@@ -1477,9 +1531,16 @@ static int __devexit bfin_mac_remove(struct platform_device *pdev)
 static int bfin_mac_suspend(struct platform_device *pdev, pm_message_t mesg)
 {
 	struct net_device *net_dev = platform_get_drvdata(pdev);
+	struct bfin_mac_local *lp = netdev_priv(net_dev);
 
-	if (netif_running(net_dev))
-		bfin_mac_close(net_dev);
+	if (lp->wol) {
+		bfin_write_EMAC_OPMODE((bfin_read_EMAC_OPMODE() & ~TE) | RE);
+		bfin_write_EMAC_WKUP_CTL(MPKE);
+		enable_irq_wake(IRQ_MAC_WAKEDET);
+	} else {
+		if (netif_running(net_dev))
+			bfin_mac_close(net_dev);
+	}
 
 	return 0;
 }
@@ -1487,9 +1548,16 @@ static int bfin_mac_suspend(struct platform_device *pdev, pm_message_t mesg)
 static int bfin_mac_resume(struct platform_device *pdev)
 {
 	struct net_device *net_dev = platform_get_drvdata(pdev);
+	struct bfin_mac_local *lp = netdev_priv(net_dev);
 
-	if (netif_running(net_dev))
-		bfin_mac_open(net_dev);
+	if (lp->wol) {
+		bfin_write_EMAC_OPMODE(bfin_read_EMAC_OPMODE() | TE);
+		bfin_write_EMAC_WKUP_CTL(0);
+		disable_irq_wake(IRQ_MAC_WAKEDET);
+	} else {
+		if (netif_running(net_dev))
+			bfin_mac_open(net_dev);
+	}
 
 	return 0;
 }
diff --git a/drivers/net/bfin_mac.h b/drivers/net/bfin_mac.h
index 87c454f..1ae7b82 100644
--- a/drivers/net/bfin_mac.h
+++ b/drivers/net/bfin_mac.h
@@ -66,6 +66,9 @@ struct bfin_mac_local {
 	unsigned char Mac[6];	/* MAC address of the board */
 	spinlock_t lock;
 
+	int wol;		/* Wake On Lan */
+	int irq_wake_requested;
+
 	/* MII and PHY stuffs */
 	int old_link;          /* used by bf537_adjust_link */
 	int old_speed;
-- 
1.7.1

