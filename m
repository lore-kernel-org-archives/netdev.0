From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] dsa/mv88e6131: fix unknown multicast/broadcast forwarding on mv88e6085
Date: Tue, 26 Apr 2011 13:45:41 +0200
Message-ID: <1303818341-13839-1-git-send-email-jacmet@sunsite.dk>
Cc: Peter Korsgaard <jacmet@sunsite.dk>
To: davem@davemloft.net, buytenh@wantstofly.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:50048 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754564Ab1DZLpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 07:45:51 -0400
Received: by wya21 with SMTP id 21so369176wya.19
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 04:45:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 88e6085 has a few differences from the other devices in the port
control registers, causing unknown multicast/broadcast packets to get
dropped when using the standard port setup.

At the same time update kconfig to clarify that the mv88e6085 is now
supported.

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
---
 net/dsa/Kconfig     |    4 ++--
 net/dsa/mv88e6131.c |   26 +++++++++++++++++++++-----
 2 files changed, 23 insertions(+), 7 deletions(-)

diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index 87bb5f4..c53ded2 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -41,12 +41,12 @@ config NET_DSA_MV88E6XXX_NEED_PPU
 	default n
 
 config NET_DSA_MV88E6131
-	bool "Marvell 88E6095/6095F/6131 ethernet switch chip support"
+	bool "Marvell 88E6085/6095/6095F/6131 ethernet switch chip support"
 	select NET_DSA_MV88E6XXX
 	select NET_DSA_MV88E6XXX_NEED_PPU
 	select NET_DSA_TAG_DSA
 	---help---
-	  This enables support for the Marvell 88E6095/6095F/6131
+	  This enables support for the Marvell 88E6085/6095/6095F/6131
 	  ethernet switch chips.
 
 config NET_DSA_MV88E6123_61_65
diff --git a/net/dsa/mv88e6131.c b/net/dsa/mv88e6131.c
index 3da4188..45f7411 100644
--- a/net/dsa/mv88e6131.c
+++ b/net/dsa/mv88e6131.c
@@ -207,8 +207,15 @@ static int mv88e6131_setup_port(struct dsa_switch *ds, int p)
 	 * mode, but do not enable forwarding of unknown unicasts.
 	 */
 	val = 0x0433;
-	if (p == dsa_upstream_port(ds))
+	if (p == dsa_upstream_port(ds)) {
 		val |= 0x0104;
+		/*
+		 * On 6085, unknown multicast forward is controlled
+		 * here rather than in Port Control 2 register.
+		 */
+		if (ps->id == ID_6085)
+			val |= 0x0008;
+	}
 	if (ds->dsa_port_mask & (1 << p))
 		val |= 0x0100;
 	REG_WRITE(addr, 0x04, val);
@@ -251,10 +258,19 @@ static int mv88e6131_setup_port(struct dsa_switch *ds, int p)
 	 * If this is the upstream port for this switch, enable
 	 * forwarding of unknown multicast addresses.
 	 */
-	val = 0x0080 | dsa_upstream_port(ds);
-	if (p == dsa_upstream_port(ds))
-		val |= 0x0040;
-	REG_WRITE(addr, 0x08, val);
+	if (ps->id == ID_6085)
+		/*
+		 * on 6085, bits 3:0 are reserved, bit 6 control ARP
+		 * mirroring, and multicast forward is handled in
+		 * Port Control register.
+		 */
+		REG_WRITE(addr, 0x08, 0x0080);
+	else {
+		val = 0x0080 | dsa_upstream_port(ds);
+		if (p == dsa_upstream_port(ds))
+			val |= 0x0040;
+		REG_WRITE(addr, 0x08, val);
+	}
 
 	/*
 	 * Rate Control: disable ingress rate limiting.
-- 
1.7.2.3

