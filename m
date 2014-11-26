From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 2/2] net: dsa: bcm_sf2: reset switch prior to initialization
Date: Tue, 25 Nov 2014 18:08:49 -0800
Message-ID: <1416967729-717-3-git-send-email-f.fainelli@gmail.com>
References: <1416967729-717-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:43523 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751389AbaKZCIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 21:08:54 -0500
Received: by mail-pd0-f169.google.com with SMTP id fp1so1771475pdb.0
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 18:08:54 -0800 (PST)
In-Reply-To: <1416967729-717-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Our boot agent may have left the switch in an certain configuration
state, make sure we issue a software reset prior to configuring the
switch in order to ensure the HW is in a consistent state, in particular
transmit queues and internal buffers.

Fixes: 246d7f773c13 ("net: dsa: add Broadcom SF2 switch driver")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 52 ++++++++++++++++++++++++++---------------------
 1 file changed, 29 insertions(+), 23 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 46632e8b6336..4f4c2a7888e5 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -377,6 +377,29 @@ static irqreturn_t bcm_sf2_switch_1_isr(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
+static int bcm_sf2_sw_rst(struct bcm_sf2_priv *priv)
+{
+	unsigned int timeout = 1000;
+	u32 reg;
+
+	reg = core_readl(priv, CORE_WATCHDOG_CTRL);
+	reg |= SOFTWARE_RESET | EN_CHIP_RST | EN_SW_RESET;
+	core_writel(priv, reg, CORE_WATCHDOG_CTRL);
+
+	do {
+		reg = core_readl(priv, CORE_WATCHDOG_CTRL);
+		if (!(reg & SOFTWARE_RESET))
+			break;
+
+		usleep_range(1000, 2000);
+	} while (timeout-- > 0);
+
+	if (timeout == 0)
+		return -ETIMEDOUT;
+
+	return 0;
+}
+
 static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 {
 	const char *reg_names[BCM_SF2_REGS_NUM] = BCM_SF2_REGS_NAME;
@@ -410,6 +433,12 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 		base++;
 	}
 
+	ret = bcm_sf2_sw_rst(priv);
+	if (ret) {
+		pr_err("unable to software reset switch: %d\n", ret);
+		goto out_unmap;
+	}
+
 	/* Disable all interrupts and request them */
 	intrl2_0_writel(priv, 0xffffffff, INTRL2_CPU_MASK_SET);
 	intrl2_0_writel(priv, 0xffffffff, INTRL2_CPU_CLEAR);
@@ -735,29 +764,6 @@ static int bcm_sf2_sw_suspend(struct dsa_switch *ds)
 	return 0;
 }
 
-static int bcm_sf2_sw_rst(struct bcm_sf2_priv *priv)
-{
-	unsigned int timeout = 1000;
-	u32 reg;
-
-	reg = core_readl(priv, CORE_WATCHDOG_CTRL);
-	reg |= SOFTWARE_RESET | EN_CHIP_RST | EN_SW_RESET;
-	core_writel(priv, reg, CORE_WATCHDOG_CTRL);
-
-	do {
-		reg = core_readl(priv, CORE_WATCHDOG_CTRL);
-		if (!(reg & SOFTWARE_RESET))
-			break;
-
-		usleep_range(1000, 2000);
-	} while (timeout-- > 0);
-
-	if (timeout == 0)
-		return -ETIMEDOUT;
-
-	return 0;
-}
-
 static int bcm_sf2_sw_resume(struct dsa_switch *ds)
 {
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
-- 
2.1.0
