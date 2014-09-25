From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 6/6] net: dsa: bcm_sf2: add support for controlling EEE
Date: Wed, 24 Sep 2014 17:05:22 -0700
Message-ID: <1411603522-8384-7-git-send-email-f.fainelli@gmail.com>
References: <1411603522-8384-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:64422 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751543AbaIYAGF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 20:06:05 -0400
Received: by mail-pa0-f46.google.com with SMTP id kx10so9682343pab.19
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 17:06:05 -0700 (PDT)
In-Reply-To: <1411603522-8384-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When EEE is enabled, negotiate this feature with the PHY and make sure
that the capability checking, local EEE advertisement, link partner EEE
advertisement and auto-negotiation resolution returned by phy_init_eee()
is positive, and enable EEE at the switch level.

While querying the current EEE settings, verify the low-power indication
and indicate its status.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/dsa/bcm_sf2.c      | 73 ++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/bcm_sf2.h      |  3 ++
 drivers/net/dsa/bcm_sf2_regs.h |  3 ++
 3 files changed, 79 insertions(+)

diff --git a/drivers/net/dsa/bcm_sf2.c b/drivers/net/dsa/bcm_sf2.c
index 634e44ee8d0d..b9625968daac 100644
--- a/drivers/net/dsa/bcm_sf2.c
+++ b/drivers/net/dsa/bcm_sf2.c
@@ -220,6 +220,19 @@ static void bcm_sf2_imp_setup(struct dsa_switch *ds, int port)
 	core_writel(priv, reg, CORE_STS_OVERRIDE_IMP);
 }
 
+static void bcm_sf2_eee_enable_set(struct dsa_switch *ds, int port, bool enable)
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	u32 reg;
+
+	reg = core_readl(priv, CORE_EEE_EN_CTRL);
+	if (enable)
+		reg |= 1 << port;
+	else
+		reg &= ~(1 << port);
+	core_writel(priv, reg, CORE_EEE_EN_CTRL);
+}
+
 static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
 			      struct phy_device *phy)
 {
@@ -247,6 +260,10 @@ static int bcm_sf2_port_setup(struct dsa_switch *ds, int port,
 
 	bcm_sf2_imp_vlan_setup(ds, cpu_port);
 
+	/* If EEE was enabled, restore it */
+	if (priv->port_sts[port].eee.eee_enabled)
+		bcm_sf2_eee_enable_set(ds, port, true);
+
 	return 0;
 }
 
@@ -279,6 +296,60 @@ static void bcm_sf2_port_disable(struct dsa_switch *ds, int port,
 	core_writel(priv, reg, CORE_MEM_PSM_VDD_CTRL);
 }
 
+/* Returns 0 if EEE was not enabled, or 1 otherwise
+ */
+static int bcm_sf2_eee_init(struct dsa_switch *ds, int port,
+			    struct phy_device *phy)
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct ethtool_eee *p = &priv->port_sts[port].eee;
+	int ret;
+
+	p->supported = (SUPPORTED_1000baseT_Full | SUPPORTED_100baseT_Full);
+
+	ret = phy_init_eee(phy, 0);
+	if (ret)
+		return 0;
+
+	bcm_sf2_eee_enable_set(ds, port, true);
+
+	return 1;
+}
+
+static int bcm_sf2_sw_get_eee(struct dsa_switch *ds, int port,
+			      struct ethtool_eee *e)
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct ethtool_eee *p = &priv->port_sts[port].eee;
+	u32 reg;
+
+	reg = core_readl(priv, CORE_EEE_LPI_INDICATE);
+	e->eee_enabled = p->eee_enabled;
+	e->eee_active = !!(reg & (1 << port));
+
+	return 0;
+}
+
+static int bcm_sf2_sw_set_eee(struct dsa_switch *ds, int port,
+			      struct phy_device *phydev,
+			      struct ethtool_eee *e)
+{
+	struct bcm_sf2_priv *priv = ds_to_priv(ds);
+	struct ethtool_eee *p = &priv->port_sts[port].eee;
+
+	p->eee_enabled = e->eee_enabled;
+
+	if (!p->eee_enabled) {
+		bcm_sf2_eee_enable_set(ds, port, false);
+	} else {
+		p->eee_enabled = bcm_sf2_eee_init(ds, port, phydev);
+		if (!p->eee_enabled)
+			return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
 static irqreturn_t bcm_sf2_switch_0_isr(int irq, void *dev_id)
 {
 	struct bcm_sf2_priv *priv = dev_id;
@@ -792,6 +863,8 @@ static struct dsa_switch_driver bcm_sf2_switch_driver = {
 	.set_wol		= bcm_sf2_sw_set_wol,
 	.port_enable		= bcm_sf2_port_setup,
 	.port_disable		= bcm_sf2_port_disable,
+	.get_eee		= bcm_sf2_sw_get_eee,
+	.set_eee		= bcm_sf2_sw_set_eee,
 };
 
 static int __init bcm_sf2_init(void)
diff --git a/drivers/net/dsa/bcm_sf2.h b/drivers/net/dsa/bcm_sf2.h
index 8fd6c1451a84..ee9f650d5026 100644
--- a/drivers/net/dsa/bcm_sf2.h
+++ b/drivers/net/dsa/bcm_sf2.h
@@ -18,6 +18,7 @@
 #include <linux/spinlock.h>
 #include <linux/mutex.h>
 #include <linux/mii.h>
+#include <linux/ethtool.h>
 
 #include <net/dsa.h>
 
@@ -43,6 +44,8 @@ struct bcm_sf2_hw_params {
 
 struct bcm_sf2_port_status {
 	unsigned int link;
+
+	struct ethtool_eee eee;
 };
 
 struct bcm_sf2_priv {
diff --git a/drivers/net/dsa/bcm_sf2_regs.h b/drivers/net/dsa/bcm_sf2_regs.h
index c65f138c777f..1bb49cb699ab 100644
--- a/drivers/net/dsa/bcm_sf2_regs.h
+++ b/drivers/net/dsa/bcm_sf2_regs.h
@@ -225,4 +225,7 @@
 #define CORE_PORT_VLAN_CTL_PORT(x)	(0xc400 + ((x) * 0x8))
 #define  PORT_VLAN_CTRL_MASK		0x1ff
 
+#define CORE_EEE_EN_CTRL		0x24800
+#define CORE_EEE_LPI_INDICATE		0x24810
+
 #endif /* __BCM_SF2_REGS_H */
-- 
1.9.1
