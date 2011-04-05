From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] dsa/mv88e6131: add support for mv88e6085 switch
Date: Tue,  5 Apr 2011 15:03:56 +0200
Message-ID: <1302008636-6544-1-git-send-email-jacmet@sunsite.dk>
Cc: Peter Korsgaard <jacmet@sunsite.dk>
To: davem@davemloft.net, buytenh@wantstofly.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46814 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751954Ab1DENED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 09:04:03 -0400
Received: by wya21 with SMTP id 21so301138wya.19
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2011 06:04:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mv88e6085 is identical to the mv88e6095, except that all ports are
10/100 Mb/s, so use the existing setup code except for the cpu/dsa speed
selection in _setup_port().

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
---
 net/dsa/mv88e6131.c |   23 +++++++++++++++++++----
 net/dsa/mv88e6xxx.h |    2 ++
 2 files changed, 21 insertions(+), 4 deletions(-)

diff --git a/net/dsa/mv88e6131.c b/net/dsa/mv88e6131.c
index bb2b41b..a8e4f8c 100644
--- a/net/dsa/mv88e6131.c
+++ b/net/dsa/mv88e6131.c
@@ -14,6 +14,13 @@
 #include "dsa_priv.h"
 #include "mv88e6xxx.h"
 
+/*
+ * Switch product IDs
+ */
+#define ID_6085		0x04a0
+#define ID_6095		0x0950
+#define ID_6131		0x1060
+
 static char *mv88e6131_probe(struct mii_bus *bus, int sw_addr)
 {
 	int ret;
@@ -21,9 +28,11 @@ static char *mv88e6131_probe(struct mii_bus *bus, int sw_addr)
 	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), 0x03);
 	if (ret >= 0) {
 		ret &= 0xfff0;
-		if (ret == 0x0950)
+		if (ret == ID_6085)
+			return "Marvell 88E6085";
+		if (ret == ID_6095)
 			return "Marvell 88E6095/88E6095F";
-		if (ret == 0x1060)
+		if (ret == ID_6131)
 			return "Marvell 88E6131";
 	}
 
@@ -164,6 +173,7 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 
 static int mv88e6131_setup_port(struct dsa_switch *ds, int p)
 {
+	struct mv88e6xxx_priv_state *ps = (void *)(ds + 1);
 	int addr = REG_PORT(p);
 	u16 val;
 
@@ -171,10 +181,13 @@ static int mv88e6131_setup_port(struct dsa_switch *ds, int p)
 	 * MAC Forcing register: don't force link, speed, duplex
 	 * or flow control state to any particular values on physical
 	 * ports, but force the CPU port and all DSA ports to 1000 Mb/s
-	 * full duplex.
+	 * (100 Mb/s on 6085) full duplex.
 	 */
 	if (dsa_is_cpu_port(ds, p) || ds->dsa_port_mask & (1 << p))
-		REG_WRITE(addr, 0x01, 0x003e);
+		if (ps->id == ID_6085)
+			REG_WRITE(addr, 0x01, 0x003d); /* 100 Mb/s */
+		else
+			REG_WRITE(addr, 0x01, 0x003e); /* 1000 Mb/s */
 	else
 		REG_WRITE(addr, 0x01, 0x0003);
 
@@ -286,6 +299,8 @@ static int mv88e6131_setup(struct dsa_switch *ds)
 	mv88e6xxx_ppu_state_init(ds);
 	mutex_init(&ps->stats_mutex);
 
+	ps->id = REG_READ(REG_PORT(0), 0x03) & 0xfff0;
+
 	ret = mv88e6131_switch_reset(ds);
 	if (ret < 0)
 		return ret;
diff --git a/net/dsa/mv88e6xxx.h b/net/dsa/mv88e6xxx.h
index eb0e0aa..61156ca2 100644
--- a/net/dsa/mv88e6xxx.h
+++ b/net/dsa/mv88e6xxx.h
@@ -39,6 +39,8 @@ struct mv88e6xxx_priv_state {
 	 * Hold this mutex over snapshot + dump sequences.
 	 */
 	struct mutex	stats_mutex;
+
+	int		id; /* switch product id */
 };
 
 struct mv88e6xxx_hw_stat {
-- 
1.7.2.3

