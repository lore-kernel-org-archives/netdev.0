From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 6/6] ibm_newemac: PowerPC 440EP/440GR EMAC PHY clock workaround
Date: Tue, 22 Apr 2008 10:46:48 +1000
Message-ID: <20080422004804.F3288DE254@ozlabs.org>
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@ozlabs.org>
To: <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:43577 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761130AbYDVAsI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 20:48:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Valentine Barshak <vbarshak@ru.mvista.com>

This patch adds ibm_newemac PHY clock workaround for 440EP/440GR EMAC
attached to a PHY which doesn't generate RX clock if there is no link.
The code is based on the previous ibm_emac driver stuff. The 440EP/440GR
allows controlling each EMAC clock separately as opposed to global clock
selection for 440GX.

BenH: Made that #ifdef CONFIG_PPC_DCR_NATIVE for now as dcri_* stuff doesn't
exist for MMIO type DCRs like Cell. Some future rework & improvements of the
DCR infrastructure will make that cleaner but for now, this makes it work.

Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>

---
 drivers/net/ibm_newemac/core.c |   43 ++++++++++++++++++++++++++++++++++++++++-
 drivers/net/ibm_newemac/core.h |    6 ++++-
 2 files changed, 47 insertions(+), 2 deletions(-)

--- linux-work.orig/drivers/net/ibm_newemac/core.c	2008-04-22 10:31:18.000000000 +1000
+++ linux-work/drivers/net/ibm_newemac/core.c	2008-04-22 10:38:49.000000000 +1000
@@ -129,10 +129,35 @@ static struct device_node *emac_boot_lis
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
+#ifdef CONFIG_PPC_DCR_NATIVE
+	if (emac_has_feature(dev, EMAC_FTR_440EP_PHY_CLK_FIX))
+		dcri_clrset(SDR0, SDR0_MFR,
+			    0, SDR0_MFR_ECS >> dev->cell_index);
+#endif
+}
+
+static inline void emac_rx_clk_default(struct emac_instance *dev)
+{
+#ifdef CONFIG_PPC_DCR_NATIVE
+	if (emac_has_feature(dev, EMAC_FTR_440EP_PHY_CLK_FIX))
+		dcri_clrset(SDR0, SDR0_MFR,
+			    SDR0_MFR_ECS >> dev->cell_index, 0);
+#endif
+}
+
 /* PHY polling intervals */
 #define PHY_POLL_LINK_ON	HZ
 #define PHY_POLL_LINK_OFF	(HZ / 5)
@@ -1099,9 +1124,11 @@ static int emac_open(struct net_device *
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
@@ -1179,6 +1206,7 @@ static void emac_link_timer(struct work_
 
 	if (dev->phy.def->ops->poll_link(&dev->phy)) {
 		if (!netif_carrier_ok(dev->ndev)) {
+			emac_rx_clk_default(dev);
 			/* Get new link parameters */
 			dev->phy.def->ops->read_link(&dev->phy);
 
@@ -1191,6 +1219,7 @@ static void emac_link_timer(struct work_
 		link_poll_interval = PHY_POLL_LINK_ON;
 	} else {
 		if (netif_carrier_ok(dev->ndev)) {
+			emac_rx_clk_tx(dev);
 			netif_carrier_off(dev->ndev);
 			netif_tx_disable(dev->ndev);
 			emac_reinitialize(dev);
@@ -2340,6 +2369,14 @@ static int __devinit emac_init_phy(struc
 	if (emac_has_feature(dev, EMAC_FTR_440GX_PHY_CLK_FIX))
 		dcri_clrset(SDR0, SDR0_MFR, 0, SDR0_MFR_ECS);
 #endif
+	/* PHY clock workaround */
+	emac_rx_clk_tx(dev);
+
+	/* Enable internal clock source on 440GX*/
+#ifdef CONFIG_PPC_DCR_NATIVE
+	if (emac_has_feature(dev, EMAC_FTR_440GX_PHY_CLK_FIX))
+		dcri_clrset(SDR0, SDR0_MFR, 0, SDR0_MFR_ECS);
+#endif
 	/* Configure EMAC with defaults so we can at least use MDIO
 	 * This is needed mostly for 440GX
 	 */
@@ -2507,6 +2544,10 @@ static int __devinit emac_init_config(st
 		dev->features |= EMAC_FTR_EMAC4;
 		if (of_device_is_compatible(np, "ibm,emac-440gx"))
 			dev->features |= EMAC_FTR_440GX_PHY_CLK_FIX;
+	} else {
+		if (of_device_is_compatible(np, "ibm,emac-440ep") ||
+		    of_device_is_compatible(np, "ibm,emac-440gr"))
+			dev->features |= EMAC_FTR_440EP_PHY_CLK_FIX;
 	}
 
 	/* Fixup some feature bits based on the device tree */
Index: linux-work/drivers/net/ibm_newemac/core.h
===================================================================
--- linux-work.orig/drivers/net/ibm_newemac/core.h	2008-04-22 10:30:03.000000000 +1000
+++ linux-work/drivers/net/ibm_newemac/core.h	2008-04-22 10:33:12.000000000 +1000
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
