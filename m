From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 6/8] net: dsa: bcm_sf2: factor interrupt disabling in a function
Date: Mon, 12 Jan 2015 13:57:44 -0800
Message-ID: <1421099866-3184-7-git-send-email-f.fainelli@gmail.com>
References: <1421099866-3184-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, buytenh@wantstofly.org,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:62329 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751813AbbALV6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2015 16:58:00 -0500
Received: by mail-pa0-f42.google.com with SMTP id et14so34485507pad.1
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2015 13:58:00 -0800 (PST)
In-Reply-To: <1421099866-3184-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Factor the interrupt disabling in a function: bcm_sf2_intr_disable()
since we are doing the same thing in the setup and suspend paths.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index feb29c4526f7..09f6b3cc1f66 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -400,6 +400,16 @@ static int bcm_sf2_sw_rst(struct bcm_sf2_priv *priv)
 	return 0;
 }
 
+static void bcm_sf2_intr_disable(struct bcm_sf2_priv *priv)
+{
+	intrl2_0_writel(priv, 0xffffffff, INTRL2_CPU_MASK_SET);
+	intrl2_0_writel(priv, 0xffffffff, INTRL2_CPU_CLEAR);
+	intrl2_0_writel(priv, 0, INTRL2_CPU_MASK_CLEAR);
+	intrl2_1_writel(priv, 0xffffffff, INTRL2_CPU_MASK_SET);
+	intrl2_1_writel(priv, 0xffffffff, INTRL2_CPU_CLEAR);
+	intrl2_1_writel(priv, 0, INTRL2_CPU_MASK_CLEAR);
+}
+
 static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 {
 	const char *reg_names[BCM_SF2_REGS_NUM] = BCM_SF2_REGS_NAME;
@@ -440,12 +450,7 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 	}
 
 	/* Disable all interrupts and request them */
-	intrl2_0_writel(priv, 0xffffffff, INTRL2_CPU_MASK_SET);
-	intrl2_0_writel(priv, 0xffffffff, INTRL2_CPU_CLEAR);
-	intrl2_0_writel(priv, 0, INTRL2_CPU_MASK_CLEAR);
-	intrl2_1_writel(priv, 0xffffffff, INTRL2_CPU_MASK_SET);
-	intrl2_1_writel(priv, 0xffffffff, INTRL2_CPU_CLEAR);
-	intrl2_1_writel(priv, 0, INTRL2_CPU_MASK_CLEAR);
+	bcm_sf2_intr_disable(priv);
 
 	ret = request_irq(priv->irq0, bcm_sf2_switch_0_isr, 0,
 			  "switch_0", priv);
@@ -747,12 +752,7 @@ static int bcm_sf2_sw_suspend(struct dsa_switch *ds)
 	struct bcm_sf2_priv *priv = ds_to_priv(ds);
 	unsigned int port;
 
-	intrl2_0_writel(priv, 0xffffffff, INTRL2_CPU_MASK_SET);
-	intrl2_0_writel(priv, 0xffffffff, INTRL2_CPU_CLEAR);
-	intrl2_0_writel(priv, 0, INTRL2_CPU_MASK_CLEAR);
-	intrl2_1_writel(priv, 0xffffffff, INTRL2_CPU_MASK_SET);
-	intrl2_1_writel(priv, 0xffffffff, INTRL2_CPU_CLEAR);
-	intrl2_1_writel(priv, 0, INTRL2_CPU_MASK_CLEAR);
+	bcm_sf2_intr_disable(priv);
 
 	/* Disable all ports physically present including the IMP
 	 * port, the other ones have already been disabled during
-- 
2.1.0
