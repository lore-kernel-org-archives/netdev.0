From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH net-next v2 06/10] net: dsa: lan9303: added sysfs node swe_bcst_throt
Date: Tue, 25 Jul 2017 18:15:49 +0200
Message-ID: <20170725161553.30147-7-privat@egil-hjelmeland.no>
References: <20170725161553.30147-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: corbet@lwn.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        davem@davemloft.net, kernel@pengutronix.de,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170725161553.30147-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Allowing per-port access to Switch Engine Broadcast Throttling Register

Also added lan9303_write_switch_reg_mask()

Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
---
 drivers/net/dsa/lan9303-core.c | 83 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 83 insertions(+)

diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index be6d78f45a5f..b70acb73aad6 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -154,6 +154,7 @@
 # define LAN9303_SWE_PORT_MIRROR_ENABLE_RX_MIRRORING BIT(1)
 # define LAN9303_SWE_PORT_MIRROR_ENABLE_TX_MIRRORING BIT(0)
 #define LAN9303_SWE_INGRESS_PORT_TYPE 0x1847
+#define LAN9303_SWE_BCST_THROT 0x1848
 #define LAN9303_BM_CFG 0x1c00
 #define LAN9303_BM_EGRSS_PORT_TYPE 0x1c0c
 # define LAN9303_BM_EGRSS_PORT_TYPE_SPECIAL_TAG_PORT2 (BIT(17) | BIT(16))
@@ -426,6 +427,20 @@ static int lan9303_read_switch_reg(struct lan9303 *chip, u16 regnum, u32 *val)
 	return ret;
 }
 
+static int lan9303_write_switch_reg_mask(
+	struct lan9303 *chip, u16 regnum, u32 val, u32 mask)
+{
+	int ret;
+	u32 reg;
+
+	ret = lan9303_read_switch_reg(chip, regnum, &reg);
+	if (ret)
+		return ret;
+	reg = (reg & ~mask) | val;
+
+	return lan9303_write_switch_reg(chip, regnum, reg);
+}
+
 static int lan9303_detect_phy_setup(struct lan9303 *chip)
 {
 	int reg;
@@ -614,6 +629,66 @@ static int lan9303_check_device(struct lan9303 *chip)
 	return 0;
 }
 
+/* ---------------------- Sysfs on slave port --------------------------*/
+/*13.4.3.23 Switch Engine Broadcast Throttling Register (SWE_BCST_THROT)*/
+static ssize_t
+swe_bcst_throt_show(struct device *dev, struct device_attribute *attr,
+		    char *buf)
+{
+	struct dsa_port *dp = dsa_net_device_to_dsa_port(to_net_dev(dev));
+	struct lan9303 *chip = dp->ds->priv;
+	int port = dp->index;
+	int reg;
+
+	if (lan9303_read_switch_reg(chip, LAN9303_SWE_BCST_THROT, &reg))
+		return 0;
+
+	reg = (reg >> (9 * port)) & 0x1ff; /*extract port N*/
+	if (reg & 0x100)
+		reg &= 0xff; /* remove enable bit */
+	else
+		reg = 0;     /* not enabled*/
+
+	return scnprintf(buf, PAGE_SIZE, "%d\n", reg);
+}
+
+static ssize_t
+swe_bcst_throt_store(struct device *dev, struct device_attribute *attr,
+		     const char *buf, size_t len)
+{
+	struct dsa_port *dp = dsa_net_device_to_dsa_port(to_net_dev(dev));
+	struct lan9303 *chip = dp->ds->priv;
+	int port = dp->index;
+	int ret;
+	unsigned long level;
+
+	ret = kstrtoul(buf, 0, &level);
+	if (ret)
+		return ret;
+	level &= 0xff; /* ensure valid range */
+	if (level)
+		level |= 0x100; /* Set enable bit  */
+
+	ret = lan9303_write_switch_reg_mask(chip, LAN9303_SWE_BCST_THROT,
+					    level << (9 * port),
+					    0x1ff << (9 * port));
+	if (ret)
+		return ret;
+	return len;
+}
+
+static DEVICE_ATTR_RW(swe_bcst_throt);
+
+static struct attribute *lan9303_attrs[] = {
+	&dev_attr_swe_bcst_throt.attr,
+	NULL
+};
+
+static struct attribute_group lan9303_group = {
+	.name = "lan9303",
+	.attrs = lan9303_attrs,
+};
+
 /* ---------------------------- DSA -----------------------------------*/
 
 static enum dsa_tag_protocol lan9303_get_tag_protocol(struct dsa_switch *ds)
@@ -787,6 +862,11 @@ static int lan9303_port_enable(struct dsa_switch *ds, int port,
 	switch (port) {
 	case 1:
 	case 2:
+		/* lan9303_setup is too early to attach sysfs nodes... */
+		if (sysfs_create_group(
+				&ds->ports[port].netdev->dev.kobj,
+				&lan9303_group))
+			dev_dbg(chip->dev, "cannot create sysfs group\n");
 		return lan9303_enable_packet_processing(chip, port);
 	default:
 		dev_dbg(chip->dev,
@@ -805,6 +885,9 @@ static void lan9303_port_disable(struct dsa_switch *ds, int port,
 	switch (port) {
 	case 1:
 	case 2:
+		sysfs_remove_group(&ds->ports[port].netdev->dev.kobj,
+				   &lan9303_group);
+
 		lan9303_disable_packet_processing(chip, port);
 		lan9303_phy_write(ds, chip->phy_addr_sel_strap + port,
 				  MII_BMCR, BMCR_PDOWN);
-- 
2.11.0
