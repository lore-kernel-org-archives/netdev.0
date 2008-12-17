From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.29 v2 3/5] gianfar: Use interface name in interrupt name to distinguish the source.
Date: Wed, 17 Dec 2008 12:52:59 -0600
Message-ID: <1229539981-14041-4-git-send-email-afleming@freescale.com>
References: <1229539981-14041-1-git-send-email-afleming@freescale.com>
 <1229539981-14041-2-git-send-email-afleming@freescale.com>
 <1229539981-14041-3-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org, Haruki Dai <Dai.Haruki@freescale.com>,
	Dai Haruki <dai.haruki@freescale.com>,
	Andy Fleming <afleming@freescale.com>
To: davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:58734 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751323AbYLQSxS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 13:53:18 -0500
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id mBHIr2jF011179
	for <netdev@vger.kernel.org>; Wed, 17 Dec 2008 11:53:13 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id mBHIr2og015945
	for <netdev@vger.kernel.org>; Wed, 17 Dec 2008 12:53:02 -0600 (CST)
In-Reply-To: <1229539981-14041-3-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Haruki Dai <Dai.Haruki@freescale.com>

Interface name (ex. eth0) is used as the prefix for the interrupt name,
with _rx, _tx, and _er appended to distinguish multiple interrupts on
the same interface.

Signed-off-by: Dai Haruki <dai.haruki@freescale.com>
Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c |   30 ++++++++++++++++++++++++------
 drivers/net/gianfar.h |    7 +++++++
 2 files changed, 31 insertions(+), 6 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 094387f..4d7c225 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -304,8 +304,9 @@ static int gfar_probe(struct of_device *ofdev,
 	u32 tempval;
 	struct net_device *dev = NULL;
 	struct gfar_private *priv = NULL;
-	int err = 0;
 	DECLARE_MAC_BUF(mac);
+	int err = 0;
+	int len_devname;
 
 	/* Create an ethernet device instance */
 	dev = alloc_etherdev(sizeof (*priv));
@@ -447,6 +448,23 @@ static int gfar_probe(struct of_device *ofdev,
 		goto register_fail;
 	}
 
+	/* fill out IRQ number and name fields */
+	len_devname = strlen(dev->name);
+	strncpy(&priv->int_name_tx[0], dev->name, len_devname);
+	if (priv->device_flags & FSL_GIANFAR_DEV_HAS_MULTI_INTR) {
+		strncpy(&priv->int_name_tx[len_devname],
+			"_tx", sizeof("_tx") + 1);
+
+		strncpy(&priv->int_name_rx[0], dev->name, len_devname);
+		strncpy(&priv->int_name_rx[len_devname],
+			"_rx", sizeof("_rx") + 1);
+
+		strncpy(&priv->int_name_er[0], dev->name, len_devname);
+		strncpy(&priv->int_name_er[len_devname],
+			"_er", sizeof("_er") + 1);
+	} else
+		priv->int_name_tx[len_devname] = '\0';
+
 	/* Create all the sysfs files */
 	gfar_init_sysfs(dev);
 
@@ -1020,7 +1038,7 @@ int startup_gfar(struct net_device *dev)
 		/* Install our interrupt handlers for Error,
 		 * Transmit, and Receive */
 		if (request_irq(priv->interruptError, gfar_error,
-				0, "enet_error", dev) < 0) {
+				0, priv->int_name_er, dev) < 0) {
 			if (netif_msg_intr(priv))
 				printk(KERN_ERR "%s: Can't get IRQ %d\n",
 					dev->name, priv->interruptError);
@@ -1030,7 +1048,7 @@ int startup_gfar(struct net_device *dev)
 		}
 
 		if (request_irq(priv->interruptTransmit, gfar_transmit,
-				0, "enet_tx", dev) < 0) {
+				0, priv->int_name_tx, dev) < 0) {
 			if (netif_msg_intr(priv))
 				printk(KERN_ERR "%s: Can't get IRQ %d\n",
 					dev->name, priv->interruptTransmit);
@@ -1041,7 +1059,7 @@ int startup_gfar(struct net_device *dev)
 		}
 
 		if (request_irq(priv->interruptReceive, gfar_receive,
-				0, "enet_rx", dev) < 0) {
+				0, priv->int_name_rx, dev) < 0) {
 			if (netif_msg_intr(priv))
 				printk(KERN_ERR "%s: Can't get IRQ %d (receive0)\n",
 						dev->name, priv->interruptReceive);
@@ -1051,10 +1069,10 @@ int startup_gfar(struct net_device *dev)
 		}
 	} else {
 		if (request_irq(priv->interruptTransmit, gfar_interrupt,
-				0, "gfar_interrupt", dev) < 0) {
+				0, priv->int_name_tx, dev) < 0) {
 			if (netif_msg_intr(priv))
 				printk(KERN_ERR "%s: Can't get IRQ %d\n",
-					dev->name, priv->interruptError);
+					dev->name, priv->interruptTransmit);
 
 			err = -1;
 			goto err_irq_fail;
diff --git a/drivers/net/gianfar.h b/drivers/net/gianfar.h
index 7ef3cc5..06bac34 100644
--- a/drivers/net/gianfar.h
+++ b/drivers/net/gianfar.h
@@ -374,6 +374,8 @@ extern const char gfar_driver_version[];
 #define RXFCB_PERR_MASK		0x000c
 #define RXFCB_PERR_BADL3	0x0008
 
+#define GFAR_INT_NAME_MAX	IFNAMSIZ + 4
+
 struct txbd8
 {
 	union {
@@ -796,6 +798,11 @@ struct gfar_private {
 	uint32_t msg_enable;
 
 	struct work_struct reset_task;
+
+	char int_name_tx[GFAR_INT_NAME_MAX];
+	char int_name_rx[GFAR_INT_NAME_MAX];
+	char int_name_er[GFAR_INT_NAME_MAX];
+
 	/* Network Statistics */
 	struct gfar_extra_stats extra_stats;
 };
-- 
1.5.4.GIT

