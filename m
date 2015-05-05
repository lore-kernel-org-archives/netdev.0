From: Andrew Lunn <andrew@lunn.ch>
Subject: [PATCH net-next 03/10] net: dsa: Converting remaining registers to mnemonics
Date: Wed,  6 May 2015 01:09:49 +0200
Message-ID: <1430867396-2268-4-git-send-email-andrew@lunn.ch>
References: <1430867396-2268-1-git-send-email-andrew@lunn.ch>
Cc: netdev@vger.kernel.org, Andrew Lunn <andrew@lunn.ch>
To: davem@davemloft.net, linux@roeck-us.net,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:44522 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752431AbbEEXPV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 May 2015 19:15:21 -0400
In-Reply-To: <1430867396-2268-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use defines for registers, shifts and bits in the remaining register
accesses in the individual drivers, in order to aid readability.

Signed-off-by: Andrew Lunn <andrew@lunn.ch>
---
 drivers/net/dsa/mv88e6123_61_65.c | 11 ++++++++---
 drivers/net/dsa/mv88e6131.c       | 26 ++++++++++++++++++++------
 drivers/net/dsa/mv88e6171.c       | 26 +++++++++++++++++++++-----
 drivers/net/dsa/mv88e6352.c       | 10 ++++++++--
 drivers/net/dsa/mv88e6xxx.h       | 12 ++++++++++++
 5 files changed, 69 insertions(+), 16 deletions(-)

diff --git a/drivers/net/dsa/mv88e6123_61_65.c b/drivers/net/dsa/mv88e6123_61_65.c
index c7c8b1e232ef..71a29a7ce538 100644
--- a/drivers/net/dsa/mv88e6123_61_65.c
+++ b/drivers/net/dsa/mv88e6123_61_65.c
@@ -54,7 +54,9 @@ static char *mv88e6123_61_65_probe(struct device *host_dev, int sw_addr)
 
 static int mv88e6123_61_65_setup_global(struct dsa_switch *ds)
 {
+	u32 upstream_port = dsa_upstream_port(ds);
 	int ret;
+	u32 reg;
 
 	ret = mv88e6xxx_setup_global(ds);
 	if (ret)
@@ -64,18 +66,21 @@ static int mv88e6123_61_65_setup_global(struct dsa_switch *ds)
 	 * external PHYs to poll), don't discard packets with
 	 * excessive collisions, and mask all interrupt sources.
 	 */
-	REG_WRITE(REG_GLOBAL, 0x04, 0x0000);
+	REG_WRITE(REG_GLOBAL, GLOBAL_CONTROL, 0x0000);
 
 	/* Configure the upstream port, and configure the upstream
 	 * port as the port to which ingress and egress monitor frames
 	 * are to be sent.
 	 */
-	REG_WRITE(REG_GLOBAL, 0x1a, (dsa_upstream_port(ds) * 0x1110));
+	reg = upstream_port << GLOBAL_MONITOR_CONTROL_INGRESS_SHIFT |
+		upstream_port << GLOBAL_MONITOR_CONTROL_EGRESS_SHIFT |
+		upstream_port << GLOBAL_MONITOR_CONTROL_ARP_SHIFT;
+	REG_WRITE(REG_GLOBAL, GLOBAL_MONITOR_CONTROL, reg);
 
 	/* Disable remote management for now, and set the switch's
 	 * DSA device number.
 	 */
-	REG_WRITE(REG_GLOBAL, 0x1c, ds->index & 0x1f);
+	REG_WRITE(REG_GLOBAL, GLOBAL_CONTROL_2, ds->index & 0x1f);
 
 	return 0;
 }
diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 1a5a15bf16df..765de63f59bd 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -44,7 +44,9 @@ static char *mv88e6131_probe(struct device *host_dev, int sw_addr)
 
 static int mv88e6131_setup_global(struct dsa_switch *ds)
 {
+	u32 upstream_port = dsa_upstream_port(ds);
 	int ret;
+	u32 reg;
 
 	ret = mv88e6xxx_setup_global(ds);
 	if (ret)
@@ -55,30 +57,42 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 	 * to arbitrate between packet queues, set the maximum frame
 	 * size to 1632, and mask all interrupt sources.
 	 */
-	REG_WRITE(REG_GLOBAL, 0x04, 0x4400);
+	REG_WRITE(REG_GLOBAL, GLOBAL_CONTROL,
+		  GLOBAL_CONTROL_PPU_ENABLE | GLOBAL_CONTROL_MAX_FRAME_1632);
 
 	/* Set the VLAN ethertype to 0x8100. */
-	REG_WRITE(REG_GLOBAL, 0x19, 0x8100);
+	REG_WRITE(REG_GLOBAL, GLOBAL_CORE_TAG_TYPE, 0x8100);
 
 	/* Disable ARP mirroring, and configure the upstream port as
 	 * the port to which ingress and egress monitor frames are to
 	 * be sent.
 	 */
-	REG_WRITE(REG_GLOBAL, 0x1a, (dsa_upstream_port(ds) * 0x1100) | 0x00f0);
+	reg = upstream_port << GLOBAL_MONITOR_CONTROL_INGRESS_SHIFT |
+		upstream_port << GLOBAL_MONITOR_CONTROL_EGRESS_SHIFT |
+		GLOBAL_MONITOR_CONTROL_ARP_DISABLED;
+	REG_WRITE(REG_GLOBAL, GLOBAL_MONITOR_CONTROL, reg);
 
 	/* Disable cascade port functionality unless this device
 	 * is used in a cascade configuration, and set the switch's
 	 * DSA device number.
 	 */
 	if (ds->dst->pd->nr_chips > 1)
-		REG_WRITE(REG_GLOBAL, 0x1c, 0xf000 | (ds->index & 0x1f));
+		REG_WRITE(REG_GLOBAL, GLOBAL_CONTROL_2,
+			  GLOBAL_CONTROL_2_MULTIPLE_CASCADE |
+			  (ds->index & 0x1f));
 	else
-		REG_WRITE(REG_GLOBAL, 0x1c, 0xe000 | (ds->index & 0x1f));
+		REG_WRITE(REG_GLOBAL, GLOBAL_CONTROL_2,
+			  GLOBAL_CONTROL_2_NO_CASCADE |
+			  (ds->index & 0x1f));
 
 	/* Force the priority of IGMP/MLD snoop frames and ARP frames
 	 * to the highest setting.
 	 */
-	REG_WRITE(REG_GLOBAL2, 0x0f, 0x00ff);
+	REG_WRITE(REG_GLOBAL2, GLOBAL2_PRIO_OVERRIDE,
+		  GLOBAL2_PRIO_OVERRIDE_FORCE_SNOOP |
+		  7 << GLOBAL2_PRIO_OVERRIDE_SNOOP_SHIFT |
+		  GLOBAL2_PRIO_OVERRIDE_FORCE_ARP |
+		  7 << GLOBAL2_PRIO_OVERRIDE_ARP_SHIFT);
 
 	return 0;
 }
diff --git a/drivers/net/dsa/mv88e6171.c b/drivers/net/dsa/mv88e6171.c
index a036d0d15a13..56fad84aded6 100644
--- a/drivers/net/dsa/mv88e6171.c
+++ b/drivers/net/dsa/mv88e6171.c
@@ -38,6 +38,7 @@ static char *mv88e6171_probe(struct device *host_dev, int sw_addr)
 
 static int mv88e6171_setup_global(struct dsa_switch *ds)
 {
+	u32 upstream_port = dsa_upstream_port(ds);
 	int ret;
 
 	ret = mv88e6xxx_setup_global(ds);
@@ -47,21 +48,36 @@ static int mv88e6171_setup_global(struct dsa_switch *ds)
 	/* Discard packets with excessive collisions, mask all
 	 * interrupt sources, enable PPU.
 	 */
-	REG_WRITE(REG_GLOBAL, 0x04, 0x6000);
+	REG_WRITE(REG_GLOBAL, GLOBAL_CONTROL,
+		  GLOBAL_CONTROL_PPU_ENABLE | GLOBAL_CONTROL_DISCARD_EXCESS);
 
 	/* Configure the upstream port, and configure the upstream
 	 * port as the port to which ingress and egress monitor frames
 	 * are to be sent.
 	 */
-	if (REG_READ(REG_PORT(0), 0x03) == 0x1710)
-		REG_WRITE(REG_GLOBAL, 0x1a, (dsa_upstream_port(ds) * 0x1111));
+	if (REG_READ(REG_PORT(0), PORT_SWITCH_ID) == PORT_SWITCH_ID_6171)
+		REG_WRITE(REG_GLOBAL, GLOBAL_MONITOR_CONTROL,
+			  upstream_port <<
+			  GLOBAL_MONITOR_CONTROL_INGRESS_SHIFT |
+			  upstream_port <<
+			  GLOBAL_MONITOR_CONTROL_EGRESS_SHIFT |
+			  upstream_port <<
+			  GLOBAL_MONITOR_CONTROL_ARP_SHIFT |
+			  upstream_port <<
+			  GLOBAL_MONITOR_CONTROL_MIRROR_SHIFT);
 	else
-		REG_WRITE(REG_GLOBAL, 0x1a, (dsa_upstream_port(ds) * 0x1110));
+		REG_WRITE(REG_GLOBAL, GLOBAL_MONITOR_CONTROL,
+			  upstream_port <<
+			  GLOBAL_MONITOR_CONTROL_INGRESS_SHIFT |
+			  upstream_port <<
+			  GLOBAL_MONITOR_CONTROL_EGRESS_SHIFT |
+			  upstream_port <<
+			  GLOBAL_MONITOR_CONTROL_ARP_SHIFT);
 
 	/* Disable remote management for now, and set the switch's
 	 * DSA device number.
 	 */
-	REG_WRITE(REG_GLOBAL, 0x1c, ds->index & 0x1f);
+	REG_WRITE(REG_GLOBAL, GLOBAL_CONTROL_2, ds->index & 0x1f);
 
 	return 0;
 }
diff --git a/drivers/net/dsa/mv88e6352.c b/drivers/net/dsa/mv88e6352.c
index 41d113749878..e9aca7f7945e 100644
--- a/drivers/net/dsa/mv88e6352.c
+++ b/drivers/net/dsa/mv88e6352.c
@@ -47,7 +47,9 @@ static char *mv88e6352_probe(struct device *host_dev, int sw_addr)
 
 static int mv88e6352_setup_global(struct dsa_switch *ds)
 {
+	u32 upstream_port = dsa_upstream_port(ds);
 	int ret;
+	u32 reg;
 
 	ret = mv88e6xxx_setup_global(ds);
 	if (ret)
@@ -56,13 +58,17 @@ static int mv88e6352_setup_global(struct dsa_switch *ds)
 	/* Discard packets with excessive collisions,
 	 * mask all interrupt sources, enable PPU (bit 14, undocumented).
 	 */
-	REG_WRITE(REG_GLOBAL, 0x04, 0x6000);
+	REG_WRITE(REG_GLOBAL, GLOBAL_CONTROL,
+		  GLOBAL_CONTROL_PPU_ENABLE | GLOBAL_CONTROL_DISCARD_EXCESS);
 
 	/* Configure the upstream port, and configure the upstream
 	 * port as the port to which ingress and egress monitor frames
 	 * are to be sent.
 	 */
-	REG_WRITE(REG_GLOBAL, 0x1a, (dsa_upstream_port(ds) * 0x1110));
+	reg = upstream_port << GLOBAL_MONITOR_CONTROL_INGRESS_SHIFT |
+		upstream_port << GLOBAL_MONITOR_CONTROL_EGRESS_SHIFT |
+		upstream_port << GLOBAL_MONITOR_CONTROL_ARP_SHIFT;
+	REG_WRITE(REG_GLOBAL, GLOBAL_MONITOR_CONTROL, reg);
 
 	/* Disable remote management for now, and set the switch's
 	 * DSA device number.
diff --git a/drivers/net/dsa/mv88e6xxx.h b/drivers/net/dsa/mv88e6xxx.h
index 46c5ea3801df..aafcb1a0a616 100644
--- a/drivers/net/dsa/mv88e6xxx.h
+++ b/drivers/net/dsa/mv88e6xxx.h
@@ -216,7 +216,15 @@
 #define GLOBAL_IEEE_PRI		0x18
 #define GLOBAL_CORE_TAG_TYPE	0x19
 #define GLOBAL_MONITOR_CONTROL	0x1a
+#define GLOBAL_MONITOR_CONTROL_INGRESS_SHIFT	12
+#define GLOBAL_MONITOR_CONTROL_EGRESS_SHIFT	8
+#define GLOBAL_MONITOR_CONTROL_ARP_SHIFT	4
+#define GLOBAL_MONITOR_CONTROL_MIRROR_SHIFT	0
+#define GLOBAL_MONITOR_CONTROL_ARP_DISABLED	(0xf0)
 #define GLOBAL_CONTROL_2	0x1c
+#define GLOBAL_CONTROL_2_NO_CASCADE		0xe000
+#define GLOBAL_CONTROL_2_MULTIPLE_CASCADE	0xf000
+
 #define GLOBAL_STATS_OP		0x1d
 #define GLOBAL_STATS_OP_BUSY	BIT(15)
 #define GLOBAL_STATS_OP_NOP		(0 << 12)
@@ -259,6 +267,10 @@
 #define GLOBAL2_SWITCH_MAC_BUSY BIT(15)
 #define GLOBAL2_ATU_STATS	0x0e
 #define GLOBAL2_PRIO_OVERRIDE	0x0f
+#define GLOBAL2_PRIO_OVERRIDE_FORCE_SNOOP	BIT(7)
+#define GLOBAL2_PRIO_OVERRIDE_SNOOP_SHIFT	4
+#define GLOBAL2_PRIO_OVERRIDE_FORCE_ARP		BIT(3)
+#define GLOBAL2_PRIO_OVERRIDE_ARP_SHIFT		0
 #define GLOBAL2_EEPROM_OP	0x14
 #define GLOBAL2_EEPROM_OP_BUSY	BIT(15)
 #define GLOBAL2_EEPROM_OP_LOAD	BIT(11)
-- 
2.1.4
