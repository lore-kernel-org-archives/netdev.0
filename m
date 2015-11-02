From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [RFC PATCH net-next 6/6] net: dsa: mv88e6060: replace magic values
 with register defines
Date: Mon, 2 Nov 2015 11:57:32 +0100
Message-ID: <5637419C.8060206@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Guenter Roeck <linux@roeck-us.net>,
	Neil Armstrong <narmstrong@baylibre.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To align with the mv88e6xxx code, use the register defines to
access all the register addresses and bit fields.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 drivers/net/dsa/mv88e6060.c | 64 ++++++++++++++++++++++++++-------------------
 1 file changed, 37 insertions(+), 27 deletions(-)

diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
index 1ccfd7a..6b5353e 100644
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c
@@ -15,9 +15,7 @@
 #include <linux/netdevice.h>
 #include <linux/phy.h>
 #include <net/dsa.h>
-
-#define REG_PORT(p)		(8 + (p))
-#define REG_GLOBAL		0x0f
+#include "mv88e6060.h"

 static int reg_read(struct dsa_switch *ds, int addr, int reg)
 {
@@ -67,13 +65,14 @@ static char *mv88e6060_probe(struct device *host_dev, int sw_addr)
 	if (bus == NULL)
 		return NULL;

-	ret = mdiobus_read(bus, sw_addr + REG_PORT(0), 0x03);
+	ret = mdiobus_read(bus, sw_addr + REG_PORT(0), PORT_SWITCH_ID);
 	if (ret >= 0) {
-		if (ret == 0x0600)
+		if (ret == PORT_SWITCH_ID_6060)
 			return "Marvell 88E6060 (A0)";
-		if (ret == 0x0601 || ret == 0x0602)
+		if (ret == PORT_SWITCH_ID_6060_R1 ||
+		    ret == PORT_SWITCH_ID_6060_R2)
 			return "Marvell 88E6060 (B0)";
-		if ((ret & 0xfff0) == 0x0600)
+		if ((ret & PORT_SWITCH_ID_6060_MASK) == PORT_SWITCH_ID_6060)
 			return "Marvell 88E6060";
 	}

@@ -87,22 +86,26 @@ static int mv88e6060_switch_reset(struct dsa_switch *ds)
 	unsigned long timeout;

 	/* Set all ports to the disabled state. */
-	for (i = 0; i < 6; i++) {
-		ret = REG_READ(REG_PORT(i), 0x04);
-		REG_WRITE(REG_PORT(i), 0x04, ret & 0xfffc);
+	for (i = 0; i < MV88E6060_PORTS; i++) {
+		ret = REG_READ(REG_PORT(i), PORT_CONTROL);
+		REG_WRITE(REG_PORT(i), PORT_CONTROL,
+			  ret & ~PORT_CONTROL_STATE_MASK);
 	}

 	/* Wait for transmit queues to drain. */
 	usleep_range(2000, 4000);

 	/* Reset the switch. */
-	REG_WRITE(REG_GLOBAL, 0x0a, 0xa130);
+	REG_WRITE(REG_GLOBAL, GLOBAL_ATU_CONTROL,
+		  GLOBAL_ATU_CONTROL_SWRESET |
+		  GLOBAL_ATU_CONTROL_ATUSIZE_1024 |
+		  GLOBAL_ATU_CONTROL_ATE_AGE_5MIN);

 	/* Wait up to one second for reset to complete. */
 	timeout = jiffies + 1 * HZ;
 	while (time_before(jiffies, timeout)) {
-		ret = REG_READ(REG_GLOBAL, 0x00);
-		if ((ret & 0x800) != 0x0000)
+		ret = REG_READ(REG_GLOBAL, GLOBAL_STATUS);
+		if ((ret & GLOBAL_STATUS_INIT_READY))
 			break;

 		usleep_range(1000, 2000);
@@ -119,13 +122,15 @@ static int mv88e6060_setup_global(struct dsa_switch *ds)
 	 * set the maximum frame size to 1536 bytes, and mask all
 	 * interrupt sources.
 	 */
-	REG_WRITE(REG_GLOBAL, 0x04, 0x400);
+	REG_WRITE(REG_GLOBAL, GLOBAL_CONTROL, GLOBAL_CONTROL_MAX_FRAME_1536);

 	/* Enable automatic address learning, set the address
 	 * database size to 1024 entries, and set the default aging
 	 * time to 5 minutes.
 	 */
-	REG_WRITE(REG_GLOBAL, 0x0a, 0x2130);
+	REG_WRITE(REG_GLOBAL, GLOBAL_ATU_CONTROL,
+		  GLOBAL_ATU_CONTROL_ATUSIZE_1024 |
+		  GLOBAL_ATU_CONTROL_ATE_AGE_5MIN);

 	return 0;
 }
@@ -139,25 +144,30 @@ static int mv88e6060_setup_port(struct dsa_switch *ds, int p)
 	 * state to Forwarding.  Additionally, if this is the CPU
 	 * port, enable Ingress and Egress Trailer tagging mode.
 	 */
-	REG_WRITE(addr, 0x04, dsa_is_cpu_port(ds, p) ?  0x4103 : 0x0003);
+	REG_WRITE(addr, PORT_CONTROL,
+		  dsa_is_cpu_port(ds, p) ?
+			PORT_CONTROL_TRAILER |
+			PORT_CONTROL_INGRESS_MODE |
+			PORT_CONTROL_STATE_FORWARDING :
+			PORT_CONTROL_STATE_FORWARDING);

 	/* Port based VLAN map: give each port its own address
 	 * database, allow the CPU port to talk to each of the 'real'
 	 * ports, and allow each of the 'real' ports to only talk to
 	 * the CPU port.
 	 */
-	REG_WRITE(addr, 0x06,
-			((p & 0xf) << 12) |
-			 (dsa_is_cpu_port(ds, p) ?
-				ds->phys_port_mask :
-				(1 << ds->dst->cpu_port)));
+	REG_WRITE(addr, PORT_VLAN_MAP,
+		  ((p & 0xf) << PORT_VLAN_MAP_DBNUM_SHIFT) |
+		   (dsa_is_cpu_port(ds, p) ?
+			ds->phys_port_mask :
+			BIT(ds->dst->cpu_port)));

 	/* Port Association Vector: when learning source addresses
 	 * of packets, add the address to the address database using
 	 * a port bitmap that has only the bit for this port set and
 	 * the other bits clear.
 	 */
-	REG_WRITE(addr, 0x0b, 1 << p);
+	REG_WRITE(addr, PORT_ASSOC_VECTOR, BIT(p));

 	return 0;
 }
@@ -177,7 +187,7 @@ static int mv88e6060_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;

-	for (i = 0; i < 6; i++) {
+	for (i = 0; i < MV88E6060_PORTS; i++) {
 		ret = mv88e6060_setup_port(ds, i);
 		if (ret < 0)
 			return ret;
@@ -189,16 +199,16 @@ static int mv88e6060_setup(struct dsa_switch *ds)
 static int mv88e6060_set_addr(struct dsa_switch *ds, u8 *addr)
 {
 	/* Use the same MAC Address as FD Pause frames for all ports */
-	REG_WRITE(REG_GLOBAL, 0x01, (addr[0] << 9) | addr[1]);
-	REG_WRITE(REG_GLOBAL, 0x02, (addr[2] << 8) | addr[3]);
-	REG_WRITE(REG_GLOBAL, 0x03, (addr[4] << 8) | addr[5]);
+	REG_WRITE(REG_GLOBAL, GLOBAL_MAC_01, (addr[0] << 9) | addr[1]);
+	REG_WRITE(REG_GLOBAL, GLOBAL_MAC_23, (addr[2] << 8) | addr[3]);
+	REG_WRITE(REG_GLOBAL, GLOBAL_MAC_45, (addr[4] << 8) | addr[5]);

 	return 0;
 }

 static int mv88e6060_port_to_phy_addr(int port)
 {
-	if (port >= 0 && port <= 5)
+	if (port >= 0 && port < MV88E6060_PORTS)
 		return port;
 	return -1;
 }
-- 
1.9.1
