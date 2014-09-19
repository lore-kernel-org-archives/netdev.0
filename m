From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 2/4] net: dsa: bcm_sf2: add suspend/resume callbacks
Date: Thu, 18 Sep 2014 17:31:23 -0700
Message-ID: <1411086685-18684-3-git-send-email-f.fainelli@gmail.com>
References: <1411086685-18684-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:60510 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755787AbaISAbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Sep 2014 20:31:48 -0400
Received: by mail-pa0-f51.google.com with SMTP id eu11so2611409pac.38
        for <netdev@vger.kernel.org>; Thu, 18 Sep 2014 17:31:48 -0700 (PDT)
In-Reply-To: <1411086685-18684-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement the suspend/resume callbacks for the Broadcom Starfighter 2
switch driver. Suspending the switch requires masking interrupts and
shutting down ports. Resuming the switch requires a software reset since
we do not know which power-sate we might be coming from, and re-enabling
the physical ports that are used.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c | 85 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 85 insertions(+)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 02d7db320d90..77b5a64560fa 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -591,6 +591,89 @@ static void bcm_sf2_sw_fixed_link_update(struct dsa_switch *ds, int port,
 		status->pause = 1;
 }
 
+static int bcm_sf2_sw_suspend(struct dsa_switch *ds)
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	unsigned int port;
+
+	intrl2_0_writel(priv, 0xffffffff, INTRL2_CPU_MASK_SET);
+	intrl2_0_writel(priv, 0xffffffff, INTRL2_CPU_CLEAR);
+	intrl2_0_writel(priv, 0, INTRL2_CPU_MASK_CLEAR);
+	intrl2_1_writel(priv, 0xffffffff, INTRL2_CPU_MASK_SET);
+	intrl2_1_writel(priv, 0xffffffff, INTRL2_CPU_CLEAR);
+	intrl2_1_writel(priv, 0, INTRL2_CPU_MASK_CLEAR);
+
+	/* Disable all ports physically present including the IMP
+	 * port, the other ones have already been disabled during
+	 * bcm_sf2_sw_setup
+	 */
+	for (port = 0; port < DSA_MAX_PORTS; port++) {
+		if ((1 << port) & ds->phys_port_mask ||
+		    dsa_is_cpu_port(ds, port))
+			bcm_sf2_port_disable(ds, port);
+	}
+
+	return 0;
+}
+
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
+static int bcm_sf2_sw_resume(struct dsa_switch *ds)
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	unsigned int port;
+	u32 reg;
+	int ret;
+
+	ret = bcm_sf2_sw_rst(priv);
+	if (ret) {
+		pr_err("%s: failed to software reset switch\n", __func__);
+		return ret;
+	}
+
+	/* Reinitialize the single GPHY */
+	if (priv->hw_params.num_gphy == 1) {
+		reg = reg_readl(priv, REG_SPHY_CNTRL);
+		reg |= PHY_RESET;
+		reg &= ~(EXT_PWR_DOWN | IDDQ_BIAS);
+		reg_writel(priv, reg, REG_SPHY_CNTRL);
+		udelay(21);
+		reg = reg_readl(priv, REG_SPHY_CNTRL);
+		reg &= ~PHY_RESET;
+		reg_writel(priv, reg, REG_SPHY_CNTRL);
+	}
+
+	for (port = 0; port < DSA_MAX_PORTS; port++) {
+		if ((1 << port) & ds->phys_port_mask)
+			bcm_sf2_port_setup(ds, port);
+		else if (dsa_is_cpu_port(ds, port))
+			bcm_sf2_imp_setup(ds, port);
+	}
+
+	return 0;
+}
+
 static struct dsa_switch_driver bcm_sf2_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_BRCM,
 	.priv_size		= sizeof(struct bcm_sf2_priv),
@@ -604,6 +687,8 @@ static struct dsa_switch_driver bcm_sf2_switch_driver = {
 	.get_sset_count		= bcm_sf2_sw_get_sset_count,
 	.adjust_link		= bcm_sf2_sw_adjust_link,
 	.fixed_link_update	= bcm_sf2_sw_fixed_link_update,
+	.suspend		= bcm_sf2_sw_suspend,
+	.resume			= bcm_sf2_sw_resume,
 };
 
 static int __init bcm_sf2_init(void)
-- 
1.9.1
