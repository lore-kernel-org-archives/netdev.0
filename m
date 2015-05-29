From: Mathieu Olivari <mathieu@codeaurora.org>
Subject: [PATCH 3/7] net: dsa: ar8xxx: add regmap support
Date: Thu, 28 May 2015 18:42:18 -0700
Message-ID: <1432863742-18427-4-git-send-email-mathieu@codeaurora.org>
References: <1432863742-18427-1-git-send-email-mathieu@codeaurora.org>
Cc: devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: robh+dt@kernel.org, pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	davem@davemloft.net, mathieu@codeaurora.org, andrew@lunn.ch,
	f.fainelli@gmail.com, linux@roeck-us.net, gang.chen.5i5j@gmail.com,
	jiri@resnulli.us, leitec@staticky.com, fabf@skynet.be,
	alexander.h.duyck@intel.com, pavel.nakonechny@skitlab.ru,
	joe@perches.com, sfeldma@gmail.com, nbd@openwrt.org,
	juhosg@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:37437 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754421AbbE2Bmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 21:42:33 -0400
In-Reply-To: <1432863742-18427-1-git-send-email-mathieu@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All switch registers can now be dumped using regmap/debugfs.

\# cat /sys/kernel/debug/regmap/<mdiobus>/registers
0000: 00001302
0004: ...
...

Signed-off-by: Mathieu Olivari <mathieu@codeaurora.org>
---
 drivers/net/dsa/Kconfig  |  1 +
 drivers/net/dsa/ar8xxx.c | 60 ++++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/dsa/ar8xxx.h |  5 ++++
 3 files changed, 66 insertions(+)

diff --git a/drivers/net/dsa/Kconfig b/drivers/net/dsa/Kconfig
index 2aae541..17fb296 100644
--- a/drivers/net/dsa/Kconfig
+++ b/drivers/net/dsa/Kconfig
@@ -68,6 +68,7 @@ config NET_DSA_BCM_SF2
 config NET_DSA_AR8XXX
 	tristate "Qualcomm Atheros AR8XXX Ethernet switch family support"
 	depends on NET_DSA
+	select REGMAP
 	---help---
 	  This enables support for the Qualcomm Atheros AR8XXX Ethernet
 	  switch chips.
diff --git a/drivers/net/dsa/ar8xxx.c b/drivers/net/dsa/ar8xxx.c
index 2f0fa4d..327abd4 100644
--- a/drivers/net/dsa/ar8xxx.c
+++ b/drivers/net/dsa/ar8xxx.c
@@ -176,6 +176,57 @@ static char *ar8xxx_probe(struct device *host_dev, int sw_addr)
 	}
 }
 
+static int ar8xxx_regmap_read(void *ctx, uint32_t reg, uint32_t *val)
+{
+	struct dsa_switch *ds = (struct dsa_switch *)ctx;
+
+	*val = ar8xxx_read(ds, reg);
+
+	return 0;
+}
+
+static int ar8xxx_regmap_write(void *ctx, uint32_t reg, uint32_t val)
+{
+	struct dsa_switch *ds = (struct dsa_switch *)ctx;
+
+	ar8xxx_write(ds, reg, val);
+
+	return 0;
+}
+
+static const struct regmap_range ar8xxx_readable_ranges[] = {
+	regmap_reg_range(0x0000, 0x00e4), /* Global control */
+	regmap_reg_range(0x0100, 0x0168), /* EEE control */
+	regmap_reg_range(0x0200, 0x0270), /* Parser control */
+	regmap_reg_range(0x0400, 0x0454), /* ACL */
+	regmap_reg_range(0x0600, 0x0718), /* Lookup */
+	regmap_reg_range(0x0800, 0x0b70), /* QM */
+	regmap_reg_range(0x0C00, 0x0c80), /* PKT */
+	regmap_reg_range(0x1000, 0x10ac), /* MIB - Port0 */
+	regmap_reg_range(0x1100, 0x11ac), /* MIB - Port1 */
+	regmap_reg_range(0x1200, 0x12ac), /* MIB - Port2 */
+	regmap_reg_range(0x1300, 0x13ac), /* MIB - Port3 */
+	regmap_reg_range(0x1400, 0x14ac), /* MIB - Port4 */
+	regmap_reg_range(0x1500, 0x15ac), /* MIB - Port5 */
+	regmap_reg_range(0x1600, 0x16ac), /* MIB - Port6 */
+
+};
+
+static struct regmap_access_table ar8xxx_readable_table = {
+	.yes_ranges = ar8xxx_readable_ranges,
+	.n_yes_ranges = ARRAY_SIZE(ar8xxx_readable_ranges),
+};
+
+struct regmap_config ar8xxx_regmap_config = {
+	.reg_bits = 16,
+	.val_bits = 32,
+	.reg_stride = 4,
+	.max_register = 0x16ac, /* end MIB - Port6 range */
+	.reg_read = ar8xxx_regmap_read,
+	.reg_write = ar8xxx_regmap_write,
+	.rd_table = &ar8xxx_readable_table,
+};
+
 static int ar8xxx_set_pad_ctrl(struct dsa_switch *ds, int port, int mode)
 {
 	int reg;
@@ -219,9 +270,17 @@ static int ar8xxx_set_pad_ctrl(struct dsa_switch *ds, int port, int mode)
 
 static int ar8xxx_setup(struct dsa_switch *ds)
 {
+	struct ar8xxx_priv *priv = ds_to_priv(ds);
 	struct net_device *netdev = ds->dst->pd->of_netdev;
 	int ret, i, phy_mode;
 
+	/* Start by setting up the register mapping */
+	priv->regmap = devm_regmap_init(ds->master_dev, NULL, ds,
+					&ar8xxx_regmap_config);
+
+	if (IS_ERR(priv->regmap))
+		pr_warn("regmap initialization failed");
+
 	/* Initialize CPU port pad mode (xMII type, delays...) */
 	phy_mode = of_get_phy_mode(netdev->dev.parent->of_node);
 	if (phy_mode < 0) {
@@ -365,6 +424,7 @@ static void ar8xxx_poll_link(struct dsa_switch *ds)
 
 static struct dsa_switch_driver ar8xxx_switch_driver = {
 	.tag_protocol		= DSA_TAG_PROTO_NONE,
+	.priv_size		= sizeof(struct ar8xxx_priv),
 	.probe			= ar8xxx_probe,
 	.setup			= ar8xxx_setup,
 	.set_addr		= ar8xxx_set_addr,
diff --git a/drivers/net/dsa/ar8xxx.h b/drivers/net/dsa/ar8xxx.h
index 7c7a125..98cc7ed 100644
--- a/drivers/net/dsa/ar8xxx.h
+++ b/drivers/net/dsa/ar8xxx.h
@@ -17,6 +17,11 @@
 #define __AR8XXX_H
 
 #include <linux/delay.h>
+#include <linux/regmap.h>
+
+struct ar8xxx_priv {
+	struct regmap *regmap;
+};
 
 struct ar8xxx_mib_desc {
 	unsigned int size;
-- 
2.1.4
