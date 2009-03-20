From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 2/3] dsa: add support for the Marvell 88E6095/6095F switch chips
Date: Fri, 20 Mar 2009 20:50:39 +0100
Message-ID: <20090320195039.GV4738@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gary Thomas <gary@mlbassoc.com>,
	Jesper Dangaard Brouer <hawk@diku.dk>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:35455 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755264AbZCTTum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 15:50:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the Marvell 88E6095/6095F switch chips.  These
chips are similar to the 88e6131, so we can add the support to
mv88e6131.c easily.

Thanks to Gary Thomas <gary@mlbassoc.com> and Jesper Dangaard
Brouer <hawk@diku.dk> for testing various patches.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
Tested-by: Gary Thomas <gary@mlbassoc.com>
---
 net/dsa/Kconfig     |    6 +++---
 net/dsa/mv88e6131.c |   22 ++++++++++++++--------
 2 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index 49211b3..c51b554 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -41,13 +41,13 @@ config NET_DSA_MV88E6XXX_NEED_PPU
 	default n
 
 config NET_DSA_MV88E6131
-	bool "Marvell 88E6131 ethernet switch chip support"
+	bool "Marvell 88E6095/6095F/6131 ethernet switch chip support"
 	select NET_DSA_MV88E6XXX
 	select NET_DSA_MV88E6XXX_NEED_PPU
 	select NET_DSA_TAG_DSA
 	---help---
-	  This enables support for the Marvell 88E6131 ethernet switch
-	  chip.
+	  This enables support for the Marvell 88E6095/6095F/6131
+	  ethernet switch chips.
 
 config NET_DSA_MV88E6123_61_65
 	bool "Marvell 88E6123/6161/6165 ethernet switch chip support"
diff --git a/net/dsa/mv88e6131.c b/net/dsa/mv88e6131.c
index 374d46a..4e24eca 100644
--- a/net/dsa/mv88e6131.c
+++ b/net/dsa/mv88e6131.c
@@ -1,6 +1,6 @@
 /*
- * net/dsa/mv88e6131.c - Marvell 88e6131 switch chip support
- * Copyright (c) 2008 Marvell Semiconductor
+ * net/dsa/mv88e6131.c - Marvell 88e6095/6095f/6131 switch chip support
+ * Copyright (c) 2008-2009 Marvell Semiconductor
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -21,6 +21,8 @@ static char *mv88e6131_probe(struct mii_bus *bus, int sw_addr)
 	ret = __mv88e6xxx_reg_read(bus, sw_addr, REG_PORT(0), 0x03);
 	if (ret >= 0) {
 		ret &= 0xfff0;
+		if (ret == 0x0950)
+			return "Marvell 88E6095/88E6095F";
 		if (ret == 0x1060)
 			return "Marvell 88E6131";
 	}
@@ -36,7 +38,7 @@ static int mv88e6131_switch_reset(struct dsa_switch *ds)
 	/*
 	 * Set all ports to the disabled state.
 	 */
-	for (i = 0; i < 8; i++) {
+	for (i = 0; i < 11; i++) {
 		ret = REG_READ(REG_PORT(i), 0x04);
 		REG_WRITE(REG_PORT(i), 0x04, ret & 0xfffc);
 	}
@@ -136,7 +138,7 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 	 * Clear all trunk masks.
 	 */
 	for (i = 0; i < 8; i++)
-		REG_WRITE(REG_GLOBAL2, 0x07, 0x8000 | (i << 12) | 0xff);
+		REG_WRITE(REG_GLOBAL2, 0x07, 0x8000 | (i << 12) | 0x7ff);
 
 	/*
 	 * Clear all trunk mappings.
@@ -159,9 +161,13 @@ static int mv88e6131_setup_port(struct dsa_switch *ds, int p)
 
 	/*
 	 * MAC Forcing register: don't force link, speed, duplex
-	 * or flow control state to any particular values.
+	 * or flow control state to any particular values on physical
+	 * ports, but force the CPU port to 1000 Mb/s full duplex.
 	 */
-	REG_WRITE(addr, 0x01, 0x0003);
+	if (p == ds->cpu_port)
+		REG_WRITE(addr, 0x01, 0x003e);
+	else
+		REG_WRITE(addr, 0x01, 0x0003);
 
 	/*
 	 * Port Control: disable Core Tag, disable Drop-on-Lock,
@@ -268,7 +274,7 @@ static int mv88e6131_setup(struct dsa_switch *ds)
 	if (ret < 0)
 		return ret;
 
-	for (i = 0; i < 6; i++) {
+	for (i = 0; i < 11; i++) {
 		ret = mv88e6131_setup_port(ds, i);
 		if (ret < 0)
 			return ret;
@@ -279,7 +285,7 @@ static int mv88e6131_setup(struct dsa_switch *ds)
 
 static int mv88e6131_port_to_phy_addr(int port)
 {
-	if (port >= 0 && port != 3 && port <= 7)
+	if (port >= 0 && port <= 11)
 		return port;
 	return -1;
 }
-- 
1.5.6.4
