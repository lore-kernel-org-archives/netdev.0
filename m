From: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
Subject: [PATCH 12/13] net: dsa: lan9303: Added "stp_enable" sysfs attribute
Date: Thu, 20 Jul 2017 15:42:54 +0200
Message-ID: <08c405e265564e47a4649f7fe264a908@nooslMX1.zenitelcss.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <egil.hjelmeland@zenitel.com>
To: <corbet@lwn.net>, <andrew@lunn.ch>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <davem@davemloft.net>, <kernel@pengutronix.de>,
        <linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <netdev@vger.kernel.org>
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Must be set to 1 by user space when STP is used on the lan9303.
If bridging without local STP, leave at 0, so external STP BPDUs
are forwarded.

Hopefully the kernel can be improved so the driver can handle this
without user intervention, and this control can be removed.

Signed-off-by: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
---
 Documentation/networking/dsa/lan9303.txt | 23 ++++++++++++++++++++++
 drivers/net/dsa/lan9303-core.c           | 33 ++++++++++++++++++++++++++++++++
 2 files changed, 56 insertions(+)

diff --git a/Documentation/networking/dsa/lan9303.txt b/Documentation/networking/dsa/lan9303.txt
index ace91c821ce7..0694b6646d2a 100644
--- a/Documentation/networking/dsa/lan9303.txt
+++ b/Documentation/networking/dsa/lan9303.txt
@@ -40,6 +40,10 @@ When a user port is enabled, the driver creates sysfs directory
  - alr_dump (RO): List the 168 first entries of the ALR table.
       Including port 0 entires. This file is identical for both ports.
       Format: MAC; list of ports; (l)earned / (s)tatic
+ - stp_enable (RW): Must be set to 1 when STP is used. Installs an ALR
+      entry so that received STP BPDUs are only sent to port 0.
+      When 0 (default) received STP BPDUs are forwarded to all ports.
+      This file is identical for both ports.
  - swe_bcst_throt (RW): Set/get 6.4.7 Broadcast Storm Control
       Throttle Level for the port. Accesses the corresponding bits of
       the SWE_BCST_THROT register (13.4.3.23).
@@ -49,3 +53,22 @@ Driver limitations
 ==================
 
  - No support for VLAN
+
+
+Bridging notes
+==============
+When the user ports are bridged, broadcasts, multicasts and unknown
+frames with unknown destination are flooded by the chip. Therefore SW
+flooding must be disabled by:
+
+   echo 0 > /sys/class/net/p1/brport/broadcast_flood
+   echo 0 > /sys/class/net/p1/brport/multicast_flood
+   echo 0 > /sys/class/net/p1/brport/unicast_flood
+   echo 0 > /sys/class/net/p2/brport/broadcast_flood
+   echo 0 > /sys/class/net/p2/brport/multicast_flood
+   echo 0 > /sys/class/net/p2/brport/unicast_flood
+
+If enabling local STP, the LAN9303 must be configured to forward
+BPDUs only to port 0, by writing 1 to "stp_enable" of one of the ports:
+
+   echo 1 > /sys/class/net/p1/lan9303/stp_enable
diff --git a/drivers/net/dsa/lan9303-core.c b/drivers/net/dsa/lan9303-core.c
index b682aa4f1fca..54646eb38185 100644
--- a/drivers/net/dsa/lan9303-core.c
+++ b/drivers/net/dsa/lan9303-core.c
@@ -187,6 +187,8 @@
 #define MII_LAN911X_SPECIAL_MODES 0x12
 #define MII_LAN911X_SPECIAL_CONTROL_STATUS 0x1f
 
+#define eth_stp_addr eth_reserved_addr_base
+
 static const struct regmap_range lan9303_valid_regs[] = {
 	regmap_reg_range(0x14, 0x17), /* misc, interrupt */
 	regmap_reg_range(0x19, 0x19), /* endian test */
@@ -988,9 +990,40 @@ alr_dump_show(struct device *dev, struct device_attribute *attr,
 }
 static DEVICE_ATTR_RO(alr_dump);
 
+static ssize_t
+stp_enable_show(struct device *dev, struct device_attribute *attr,
+		char *buf)
+{
+	struct dsa_port *dp = dsa_net_device_to_dsa_port(to_net_dev(dev));
+	struct lan9303 *chip = dp->ds->priv;
+	char result = lan9303_alr_cache_find_mac(chip, eth_stp_addr) ?
+		'1' : '0';
+	return scnprintf(buf, PAGE_SIZE, "%c\n", result);
+}
+
+static ssize_t
+stp_enable_store(struct device *dev, struct device_attribute *attr,
+		 const char *buf, size_t len)
+{
+	struct dsa_port *dp = dsa_net_device_to_dsa_port(to_net_dev(dev));
+	struct lan9303 *chip = dp->ds->priv;
+	unsigned long enable;
+	int ret = kstrtoul(buf, 0, &enable);
+
+	if (ret)
+		return ret;
+	if (enable)
+		lan9303_alr_add_port(chip, eth_stp_addr, 0, true);
+	else
+		lan9303_alr_del_port(chip, eth_stp_addr, 0);
+	return len;
+}
+static DEVICE_ATTR_RW(stp_enable);
+
 static struct attribute *lan9303_attrs[] = {
 	&dev_attr_swe_bcst_throt.attr,
 	&dev_attr_alr_dump.attr,
+	&dev_attr_stp_enable.attr,
 	NULL
 };
 
-- 
2.11.0


DISCLAIMER:
This e-mail may contain confidential and privileged material for the sole use of the intended recipient. Any review, use, distribution or disclosure by others is strictly prohibited. If you are not the intended recipient (or authorized to receive for the recipient), please contact the sender by reply e-mail and delete all copies of this message.
