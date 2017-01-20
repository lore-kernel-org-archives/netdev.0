From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 4/7] net: dsa: bcm_sf2: Move code enabling Broadcom tags
Date: Fri, 20 Jan 2017 12:36:31 -0800
Message-ID: <20170120203634.2773-5-f.fainelli@gmail.com>
References: <20170120203634.2773-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34442 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753660AbdATUgr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 15:36:47 -0500
Received: by mail-pg0-f66.google.com with SMTP id t6so7666660pgt.1
        for <netdev@vger.kernel.org>; Fri, 20 Jan 2017 12:36:47 -0800 (PST)
In-Reply-To: <20170120203634.2773-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for enabling Broadcom tags on different ports based on
configuration information, dedicate a function that is responsible for
enabling Broadcom tags for a given port and update the IMP port setup to
call it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 61 ++++++++++++++++++++++++++---------------------
 1 file changed, 34 insertions(+), 27 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 02afa0598b24..571e112c8e34 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -61,34 +61,9 @@ static void bcm_sf2_imp_vlan_setup(struct dsa_switch *ds, int cpu_port)
 	}
 }
 
-static void bcm_sf2_imp_setup(struct dsa_switch *ds, int port)
+static void bcm_sf2_brcm_hdr_setup(struct bcm_sf2_priv *priv, int port)
 {
-	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
-	u32 reg, val, offset;
-
-	if (priv->type == BCM7445_DEVICE_ID)
-		offset = CORE_STS_OVERRIDE_IMP;
-	else
-		offset = CORE_STS_OVERRIDE_IMP2;
-
-	/* Enable the port memories */
-	reg = core_readl(priv, CORE_MEM_PSM_VDD_CTRL);
-	reg &= ~P_TXQ_PSM_VDD(port);
-	core_writel(priv, reg, CORE_MEM_PSM_VDD_CTRL);
-
-	/* Enable Broadcast, Multicast, Unicast forwarding to IMP port */
-	reg = core_readl(priv, CORE_IMP_CTL);
-	reg |= (RX_BCST_EN | RX_MCST_EN | RX_UCST_EN);
-	reg &= ~(RX_DIS | TX_DIS);
-	core_writel(priv, reg, CORE_IMP_CTL);
-
-	/* Enable forwarding */
-	core_writel(priv, SW_FWDG_EN, CORE_SWMODE);
-
-	/* Enable IMP port in dumb mode */
-	reg = core_readl(priv, CORE_SWITCH_CTRL);
-	reg |= MII_DUMB_FWDG_EN;
-	core_writel(priv, reg, CORE_SWITCH_CTRL);
+	u32 reg, val;
 
 	/* Resolve which bit controls the Broadcom tag */
 	switch (port) {
@@ -124,6 +99,38 @@ static void bcm_sf2_imp_setup(struct dsa_switch *ds, int port)
 	reg = core_readl(priv, CORE_BRCM_HDR_TX_DIS);
 	reg &= ~(1 << port);
 	core_writel(priv, reg, CORE_BRCM_HDR_TX_DIS);
+}
+
+static void bcm_sf2_imp_setup(struct dsa_switch *ds, int port)
+{
+	struct bcm_sf2_priv *priv = bcm_sf2_to_priv(ds);
+	u32 reg, offset;
+
+	if (priv->type == BCM7445_DEVICE_ID)
+		offset = CORE_STS_OVERRIDE_IMP;
+	else
+		offset = CORE_STS_OVERRIDE_IMP2;
+
+	/* Enable the port memories */
+	reg = core_readl(priv, CORE_MEM_PSM_VDD_CTRL);
+	reg &= ~P_TXQ_PSM_VDD(port);
+	core_writel(priv, reg, CORE_MEM_PSM_VDD_CTRL);
+
+	/* Enable Broadcast, Multicast, Unicast forwarding to IMP port */
+	reg = core_readl(priv, CORE_IMP_CTL);
+	reg |= (RX_BCST_EN | RX_MCST_EN | RX_UCST_EN);
+	reg &= ~(RX_DIS | TX_DIS);
+	core_writel(priv, reg, CORE_IMP_CTL);
+
+	/* Enable forwarding */
+	core_writel(priv, SW_FWDG_EN, CORE_SWMODE);
+
+	/* Enable IMP port in dumb mode */
+	reg = core_readl(priv, CORE_SWITCH_CTRL);
+	reg |= MII_DUMB_FWDG_EN;
+	core_writel(priv, reg, CORE_SWITCH_CTRL);
+
+	bcm_sf2_brcm_hdr_setup(priv, port);
 
 	/* Force link status for IMP port */
 	reg = core_readl(priv, offset);
-- 
2.9.3
