From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v3 3/5] net: dsa: mv88e6060: setup random mac address
Date: Fri, 13 Oct 2017 14:18:07 -0400
Message-ID: <20171013181809.14627-4-vivien.didelot@savoirfairelinux.com>
References: <20171013181809.14627-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        David Laight <David.Laight@ACULAB.COM>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171013181809.14627-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As for mv88e6xxx, setup the switch from within the mv88e6060 driver with
a random MAC address, and remove the .set_addr implementation.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 drivers/net/dsa/mv88e6060.c | 43 ++++++++++++++++++++++++++-----------------
 1 file changed, 26 insertions(+), 17 deletions(-)

diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index d64be2b83d3c..6173be889d95 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -9,6 +9,7 @@
  */
 
 #include <linux/delay.h>
+#include <linux/etherdevice.h>
 #include <linux/jiffies.h>
 #include <linux/list.h>
 #include <linux/module.h>
@@ -188,6 +189,27 @@ static int mv88e6060_setup_port(struct dsa_switch *ds, int p)
 	return 0;
 }
 
+static int mv88e6060_setup_addr(struct dsa_switch *ds)
+{
+	u8 addr[ETH_ALEN];
+	u16 val;
+
+	eth_random_addr(addr);
+
+	val = addr[0] << 8 | addr[1];
+
+	/* The multicast bit is always transmitted as a zero, so the switch uses
+	 * bit 8 for "DiffAddr", where 0 means all ports transmit the same SA.
+	 */
+	val &= 0xfeff;
+
+	REG_WRITE(REG_GLOBAL, GLOBAL_MAC_01, val);
+	REG_WRITE(REG_GLOBAL, GLOBAL_MAC_23, (addr[2] << 8) | addr[3]);
+	REG_WRITE(REG_GLOBAL, GLOBAL_MAC_45, (addr[4] << 8) | addr[5]);
+
+	return 0;
+}
+
 static int mv88e6060_setup(struct dsa_switch *ds)
 {
 	int ret;
@@ -203,6 +225,10 @@ static int mv88e6060_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
+	ret = mv88e6060_setup_addr(ds);
+	if (ret < 0)
+		return ret;
+
 	for (i = 0; i < MV88E6060_PORTS; i++) {
 		ret = mv88e6060_setup_port(ds, i);
 		if (ret < 0)
@@ -212,22 +238,6 @@ static int mv88e6060_setup(struct dsa_switch *ds)
 	return 0;
 }
 
-static int mv88e6060_set_addr(struct dsa_switch *ds, u8 *addr)
-{
-	u16 val = addr[0] << 8 | addr[1];
-
-	/* The multicast bit is always transmitted as a zero, so the switch uses
-	 * bit 8 for "DiffAddr", where 0 means all ports transmit the same SA.
-	 */
-	val &= 0xfeff;
-
-	REG_WRITE(REG_GLOBAL, GLOBAL_MAC_01, val);
-	REG_WRITE(REG_GLOBAL, GLOBAL_MAC_23, (addr[2] << 8) | addr[3]);
-	REG_WRITE(REG_GLOBAL, GLOBAL_MAC_45, (addr[4] << 8) | addr[5]);
-
-	return 0;
-}
-
 static int mv88e6060_port_to_phy_addr(int port)
 {
 	if (port >= 0 && port < MV88E6060_PORTS)
@@ -262,7 +272,6 @@ static const struct dsa_switch_ops mv88e6060_switch_ops = {
 	.get_tag_protocol = mv88e6060_get_tag_protocol,
 	.probe		= mv88e6060_drv_probe,
 	.setup		= mv88e6060_setup,
-	.set_addr	= mv88e6060_set_addr,
 	.phy_read	= mv88e6060_phy_read,
 	.phy_write	= mv88e6060_phy_write,
 };
-- 
2.14.2
