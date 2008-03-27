From: Valentine Barshak <vbarshak@ru.mvista.com>
Subject: [PATCH 2/2] ibm_newemac: PowerPC 440EP/440GR EMAC PHY clock workaround
Date: Thu, 27 Mar 2008 17:42:11 +0300
Message-ID: <20080327144211.GA9088@ru.mvista.com>
References: <20080327085353.6ac04886@zod.rchland.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: benh@kernel.crashing.org, jwboyer@linux.vnet.ibm.com,
	jeff@garzik.org, netdev@vger.kernel.org
To: linuxppc-dev@ozlabs.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [212.176.242.38] ([212.176.242.38]:56387 "EHLO
	vaxon.spb.rtsoft.ru" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752772AbYC0PFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 11:05:06 -0400
Content-Disposition: inline
In-Reply-To: <20080327085353.6ac04886@zod.rchland.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds ibm_newemac PHY clock workaround for 440EP/440GR EMAC
attached to a PHY which doesn't generate RX clock if there is no link.
The code is based on the previous ibm_emac driver stuff. The 440EP/440GR
allows controlling each EMAC clock separately as opposed to global clock
selection for 440GX.

Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
---
 drivers/net/ibm_newemac/core.c |   34 ++++++++++++++++++++++++++++++++--
 drivers/net/ibm_newemac/core.h |    6 +++++-
 2 files changed, 37 insertions(+), 3 deletions(-)

diff -pruN linux-2.6.orig/drivers/net/ibm_newemac/core.c linux-2.6/drivers/net/ibm_newemac/core.c
--- linux-2.6.orig/drivers/net/ibm_newemac/core.c	2008-02-26 16:32:33.000000000 +0300
+++ linux-2.6/drivers/net/ibm_newemac/core.c	2008-02-26 16:37:52.000000000 +0300
@@ -129,10 +129,29 @@ static struct device_node *emac_boot_lis
 static inline void emac_report_timeout_error(struct emac_instance *dev,
 					     const char *error)
 {
-	if (net_ratelimit())
+	if (emac_has_feature(dev, EMAC_FTR_440GX_PHY_CLK_FIX |
+				  EMAC_FTR_440EP_PHY_CLK_FIX))
+		DBG(dev, "%s" NL, error);
+	else if (net_ratelimit())
 		printk(KERN_ERR "%s: %s\n", dev->ndev->name, error);
 }
 
+/* EMAC PHY clock workaround:
+ * 440EP/440GR has more sane SDR0_MFR register implementation than 440GX,
+ * which allows controlling each EMAC clock
+ */
+static inline void emac_rx_clk_tx(struct emac_instance *dev)
+{
+	if (emac_has_feature(dev, EMAC_FTR_440EP_PHY_CLK_FIX))
+		dcri_clrset(SDR0, SDR0_MFR, 0, SDR0_MFR_ECS >> dev->cell_index);
+}
+
+static inline void emac_rx_clk_default(struct emac_instance *dev)
+{
+	if (emac_has_feature(dev, EMAC_FTR_440EP_PHY_CLK_FIX))
+		dcri_clrset(SDR0, SDR0_MFR, SDR0_MFR_ECS >> dev->cell_index, 0);
+}
+
 /* PHY polling intervals */
 #define PHY_POLL_LINK_ON	HZ
 #define PHY_POLL_LINK_OFF	(HZ / 5)
@@ -1089,9 +1112,11 @@ static int emac_open(struct net_device *
 		int link_poll_interval;
 		if (dev->phy.def->ops->poll_link(&dev->phy)) {
 			dev->phy.def->ops->read_link(&dev->phy);
+			emac_rx_clk_default(dev);
 			netif_carrier_on(dev->ndev);
 			link_poll_interval = PHY_POLL_LINK_ON;
 		} else {
+			emac_rx_clk_tx(dev);
 			netif_carrier_off(dev->ndev);
 			link_poll_interval = PHY_POLL_LINK_OFF;
 		}
@@ -1169,6 +1194,7 @@ static void emac_link_timer(struct work_
 
 	if (dev->phy.def->ops->poll_link(&dev->phy)) {
 		if (!netif_carrier_ok(dev->ndev)) {
+			emac_rx_clk_default(dev);
 			/* Get new link parameters */
 			dev->phy.def->ops->read_link(&dev->phy);
 
@@ -1181,6 +1207,7 @@ static void emac_link_timer(struct work_
 		link_poll_interval = PHY_POLL_LINK_ON;
 	} else {
 		if (netif_carrier_ok(dev->ndev)) {
+			emac_rx_clk_tx(dev);
 			netif_carrier_off(dev->ndev);
 			netif_tx_disable(dev->ndev);
 			emac_reinitialize(dev);
@@ -2325,9 +2352,12 @@ static int __devinit emac_init_phy(struc
 	dev->phy.mdio_read = emac_mdio_read;
 	dev->phy.mdio_write = emac_mdio_write;
 
-	/* Enable internal clock source */
+	/* EMAC PHY clock workaround */
 	if (emac_has_feature(dev, EMAC_FTR_440GX_PHY_CLK_FIX))
+		/* Enable internal clock source */
 		dcri_clrset(SDR0, SDR0_MFR, 0, SDR0_MFR_ECS);
+	else
+		emac_rx_clk_tx(dev);
 
 	/* Configure EMAC with defaults so we can at least use MDIO
 	 * This is needed mostly for 440GX
@@ -2495,6 +2525,10 @@ static int __devinit emac_init_config(st
 		dev->features |= EMAC_FTR_EMAC4;
 		if (of_device_is_compatible(np, "ibm,emac-440gx"))
 			dev->features |= EMAC_FTR_440GX_PHY_CLK_FIX;
+	} else {
+		if (of_device_is_compatible(np, "ibm,emac-440ep") ||
+		    of_device_is_compatible(np, "ibm,emac-440gr"))
+			dev->features |= EMAC_FTR_440EP_PHY_CLK_FIX;
 	}
 
 	/* Fixup some feature bits based on the device tree */
diff -pruN linux-2.6.orig/drivers/net/ibm_newemac/core.h linux-2.6/drivers/net/ibm_newemac/core.h
--- linux-2.6.orig/drivers/net/ibm_newemac/core.h	2008-02-26 16:32:33.000000000 +0300
+++ linux-2.6/drivers/net/ibm_newemac/core.h	2008-02-26 16:37:52.000000000 +0300
@@ -305,6 +305,10 @@ struct emac_instance {
  * Set if we need phy clock workaround for 440gx
  */
 #define EMAC_FTR_440GX_PHY_CLK_FIX	0x00000080
+/*
+ * Set if we need phy clock workaround for 440ep or 440gr
+ */
+#define EMAC_FTR_440EP_PHY_CLK_FIX	0x00000100
 
 
 /* Right now, we don't quite handle the always/possible masks on the
@@ -328,7 +332,7 @@ enum {
 #ifdef CONFIG_IBM_NEW_EMAC_RGMII
 	    EMAC_FTR_HAS_RGMII	|
 #endif
-	    0,
+	EMAC_FTR_440EP_PHY_CLK_FIX,
 };
 
 static inline int emac_has_feature(struct emac_instance *dev,

