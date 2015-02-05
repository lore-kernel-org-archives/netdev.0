From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/2] net: dsa: bcm_sf2: implement GPHY power down
Date: Thu,  5 Feb 2015 11:40:42 -0800
Message-ID: <1423165242-6042-3-git-send-email-f.fainelli@gmail.com>
References: <1423165242-6042-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:64092 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753893AbbBETk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 14:40:56 -0500
Received: by mail-pa0-f51.google.com with SMTP id hz1so7267588pad.10
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 11:40:56 -0800 (PST)
In-Reply-To: <1423165242-6042-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement the power on/off recommended procedure for the Single GPHY we
have on our Starfighter 2 switch. In order to make sure we get proper
LED link/activity signaling during suspend, switch the link indication
from the Switch/MAC to the PHY.

Finally, since the GPHY needs to be reset to be put in low power mode,
we will loose any context applied to it: workarounds, EEE etc.. so we
need to call phy_init_hw() to get our fixups re-applied successfully.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c      | 50 ++++++++++++++++++++++++++++++++++--------
 drivers/net/dsa/bcm_sf2_regs.h |  4 ++++
 2 files changed, 45 insertions(+), 9 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 45c0e2b97f5f..4daffb284931 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -238,17 +238,28 @@ static void bcm_sf2_gphy_enable_set(struct dsa_switch *ds, bool enable)
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
 	u32 reg;
 
-	if (!enable)
-		return;
-
-	reg = reg_readl(priv, REG_SPHY_CNTRL);
-	reg |= PHY_RESET;
-	reg &= ~(EXT_PWR_DOWN | IDDQ_BIAS);
-	reg_writel(priv, reg, REG_SPHY_CNTRL);
-	udelay(21);
 	reg = reg_readl(priv, REG_SPHY_CNTRL);
-	reg &= ~PHY_RESET;
+	if (enable) {
+		reg |= PHY_RESET;
+		reg &= ~(EXT_PWR_DOWN | IDDQ_BIAS | CK25_DIS);
+		reg_writel(priv, reg, REG_SPHY_CNTRL);
+		udelay(21);
+		reg = reg_readl(priv, REG_SPHY_CNTRL);
+		reg &= ~PHY_RESET;
+	} else {
+		reg |= EXT_PWR_DOWN | IDDQ_BIAS | PHY_RESET;
+		reg_writel(priv, reg, REG_SPHY_CNTRL);
+		mdelay(1);
+		reg |= CK25_DIS;
+	}
 	reg_writel(priv, reg, REG_SPHY_CNTRL);
+
+	/* Use PHY-driven LED signaling */
+	if (!enable) {
+		reg = reg_readl(priv, REG_LED_CNTRL(0));
+		reg |= SPDLNK_SRC_SEL;
+		reg_writel(priv, reg, REG_LED_CNTRL(0));
+	}
 }
 
 static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
@@ -266,6 +277,24 @@ static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
 	/* Clear the Rx and Tx disable bits and set to no spanning tree */
 	core_writel(priv, 0, CORE_G_PCTL_PORT(port));
 
+	/* Re-enable the GPHY and re-apply workarounds */
+	if (port == 0 && priv->hw_params.num_gphy == 1) {
+		bcm_sf2_gphy_enable_set(ds, true);
+		if (phy) {
+			/* if phy_stop() has been called before, phy
+			 * will be in halted state, and phy_start()
+			 * will call resume.
+			 *
+			 * the resume path does not configure back
+			 * autoneg settings, and since we hard reset
+			 * the phy manually here, we need to reset the
+			 * state machine also.
+			 */
+			phy->state = PHY_READY;
+			phy_init_hw(phy);
+		}
+	}
+
 	/* Enable port 7 interrupts to get notified */
 	if (port == 7)
 		intrl2_1_mask_clear(priv, P_IRQ_MASK(P7_IRQ_OFF));
@@ -299,6 +328,9 @@ static void bcm_sf2_port_disable(struct dsa_switch *ds, int port,
 		intrl2_1_writel(priv, P_IRQ_MASK(P7_IRQ_OFF), INTRL2_CPU_CLEAR);
 	}
 
+	if (port == 0 && priv->hw_params.num_gphy == 1)
+		bcm_sf2_gphy_enable_set(ds, false);
+
 	if (dsa_is_cpu_port(ds, port))
 		off = CORE_IMP_CTL;
 	else
diff --git a/drivers/net/dsa/bcm_sf2_regs.h b/drivers/net/dsa/bcm_sf2_regs.h
index 1bb49cb699ab..cabdfa5e217a 100644
--- a/drivers/net/dsa/bcm_sf2_regs.h
+++ b/drivers/net/dsa/bcm_sf2_regs.h
@@ -61,6 +61,10 @@
 #define  LPI_COUNT_SHIFT		9
 #define  LPI_COUNT_MASK			0x3F
 
+#define REG_LED_CNTRL_BASE		0x90
+#define REG_LED_CNTRL(x)		(REG_LED_CNTRL_BASE + (x) * 4)
+#define  SPDLNK_SRC_SEL			(1 << 24)
+
 /* Register set relative to 'INTRL2_0' and 'INTRL2_1' */
 #define INTRL2_CPU_STATUS		0x00
 #define INTRL2_CPU_SET			0x04
-- 
2.1.0
