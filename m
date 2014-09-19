From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 7/8] net: dsa: bcm_sf2: communicate integrated PHY revision to PHY driver
Date: Fri, 19 Sep 2014 13:07:55 -0700
Message-ID: <1411157276-18260-8-git-send-email-f.fainelli@gmail.com>
References: <1411157276-18260-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33384 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932361AbaISUIU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 16:08:20 -0400
Received: by mail-pa0-f49.google.com with SMTP id lf10so746910pab.22
        for <netdev@vger.kernel.org>; Fri, 19 Sep 2014 13:08:20 -0700 (PDT)
In-Reply-To: <1411157276-18260-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The integrated BCM7xxx PHY contains no useful revision information
in its MII_PHYSID2 bits 3:0, that information is instead contained in
the SWITCH_REG_PHY_REVISION register.

Read this register, store its value, and return it by implementing the
dsa_switch::get_phy_flags() callback accordingly. The register layout is
already matching what the BCM7xxx PHY driver is expecting to find.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c      | 16 ++++++++++++++++
 drivers/net/dsa/bcm_sf2.h      |  1 +
 drivers/net/dsa/bcm_sf2_regs.h |  1 +
 3 files changed, 18 insertions(+)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 02d7db320d90..a97ba2548ea5 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -376,6 +376,9 @@ static int bcm_sf2_sw_setup(struct dsa_switch *ds)
 					SWITCH_TOP_REV_MASK;
 	priv->hw_params.core_rev = (rev & SF2_REV_MASK);
 
+	rev = reg_readl(priv, REG_PHY_REVISION);
+	priv->hw_params.gphy_rev = rev & PHY_REVISION_MASK;
+
 	pr_info("Starfighter 2 top: %x.%02x, core: %x.%02x base: 0x%p, IRQs: %d, %d\n",
 		priv->hw_params.top_rev >> 8, priv->hw_params.top_rev & 0xff,
 		priv->hw_params.core_rev >> 8, priv->hw_params.core_rev & 0xff,
@@ -399,6 +402,18 @@ static int bcm_sf2_sw_set_addr(struct dsa_switch *ds, u8 *addr)
 	return 0;
 }
 
+static u32 bcm_sf2_sw_get_phy_flags(struct dsa_switch *ds, int port)
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+
+	/* The BCM7xxx PHY driver expects to find the integrated PHY revision
+	 * in bits 15:8 and the patch level in bits 7:0 which is exactly what
+	 * the REG_PHY_REVISION register layout is.
+	 */
+
+	return priv->hw_params.gphy_rev;
+}
+
 static int bcm_sf2_sw_indir_rw(struct dsa_switch *ds, int op, int addr,
 			       int regnum, u16 val)
 {
@@ -597,6 +612,7 @@ static struct dsa_switch_driver bcm_sf2_switch_driver = {
 	.probe			= bcm_sf2_sw_probe,
 	.setup			= bcm_sf2_sw_setup,
 	.set_addr		= bcm_sf2_sw_set_addr,
+	.get_phy_flags		= bcm_sf2_sw_get_phy_flags,
 	.phy_read		= bcm_sf2_sw_phy_read,
 	.phy_write		= bcm_sf2_sw_phy_write,
 	.get_strings		= bcm_sf2_sw_get_strings,
diff --git a/drivers/net/dsa/bcm_sf2.h b/drivers/net/dsa/bcm_sf2.h
index 260bab313e58..d3bd52dc40d2 100644
--- a/drivers/net/dsa/bcm_sf2.h
+++ b/drivers/net/dsa/bcm_sf2.h
@@ -26,6 +26,7 @@
 struct bcm_sf2_hw_params {
 	u16	top_rev;
 	u16	core_rev;
+	u16	gphy_rev;
 	u32	num_gphy;
 	u8	num_acb_queue;
 	u8	num_rgmii;
diff --git a/drivers/net/dsa/bcm_sf2_regs.h b/drivers/net/dsa/bcm_sf2_regs.h
index 885c231b03b5..c65f138c777f 100644
--- a/drivers/net/dsa/bcm_sf2_regs.h
+++ b/drivers/net/dsa/bcm_sf2_regs.h
@@ -25,6 +25,7 @@
 #define  SWITCH_TOP_REV_MASK		0xffff
 
 #define REG_PHY_REVISION		0x1C
+#define  PHY_REVISION_MASK		0xffff
 
 #define REG_SPHY_CNTRL			0x2C
 #define  IDDQ_BIAS			(1 << 0)
-- 
1.9.1
