From: Johan Gunnarsson <johan.gunnarsson@axis.com>
Subject: [PATCH] ethtool: don't overwrite useful bits in advertising bitfield
Date: Tue, 14 Aug 2012 16:15:45 +0200
Message-ID: <1344953745-13208-1-git-send-email-johangu@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <starvik@axis.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from anubis.se.axis.com ([195.60.68.12]:36559 "EHLO
	anubis.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756367Ab2HNOXo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 10:23:44 -0400
Received: from localhost (localhost [127.0.0.1])
	by anubis.se.axis.com (Postfix) with ESMTP id 5AE5A19DC8
	for <netdev@vger.kernel.org>; Tue, 14 Aug 2012 16:13:53 +0200 (CEST)
Received: from anubis.se.axis.com ([127.0.0.1])
	by localhost (anubis.se.axis.com [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id RX4BO1vwyyP6 for <netdev@vger.kernel.org>;
	Tue, 14 Aug 2012 16:13:52 +0200 (CEST)
Received: from seth.se.axis.com (seth.se.axis.com [10.0.2.172])
	by anubis.se.axis.com (Postfix) with ESMTP id 936E619DB0
	for <netdev@vger.kernel.org>; Tue, 14 Aug 2012 16:13:52 +0200 (CEST)
Received: from xmail2.se.axis.com (xmail2.se.axis.com [10.0.5.74])
	by seth.se.axis.com (Postfix) with ESMTP id 91E0E3E0B7
	for <netdev@vger.kernel.org>; Tue, 14 Aug 2012 16:13:52 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are bits in this bitfield that we want to leave untouched (PAUSE
and ASYM_PAUSE bits) when changing other bits (speed and duplex bits.)
Previously, these were always overwritten to zero when running commands
like "ethtool -s eth0 speed 10 duplex full autoneg off".

Signed-off-by: Johan Gunnarsson <johangu@axis.com>
---
 ethtool.c |   45 +++++++++++++++++++++++++++++++--------------
 1 file changed, 31 insertions(+), 14 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index e573357..efa12c7 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -46,6 +46,18 @@
 #define MAX_ADDR_LEN	32
 #endif
 
+#define ALL_ADVERTISED_MODES \
+	(ADVERTISED_10baseT_Half | \
+	 ADVERTISED_10baseT_Full | \
+	 ADVERTISED_100baseT_Half | \
+	 ADVERTISED_100baseT_Full | \
+	 ADVERTISED_1000baseT_Half | \
+	 ADVERTISED_1000baseT_Full | \
+	 ADVERTISED_2500baseX_Full | \
+	 ADVERTISED_10000baseT_Full | \
+	 ADVERTISED_20000baseMLD2_Full | \
+	 ADVERTISED_20000baseKR2_Full)
+
 #ifndef HAVE_NETIF_MSG
 enum {
 	NETIF_MSG_DRV		= 0x0001,
@@ -2202,6 +2214,7 @@ static int do_sset(struct cmd_context *ctx)
 	int autoneg_wanted = -1;
 	int phyad_wanted = -1;
 	int xcvr_wanted = -1;
+	int full_advertising_wanted = -1;
 	int advertising_wanted = -1;
 	int gset_changed = 0; /* did anything in GSET change? */
 	u32 wol_wanted = 0;
@@ -2277,7 +2290,7 @@ static int do_sset(struct cmd_context *ctx)
 			i += 1;
 			if (i >= argc)
 				exit_bad_args();
-			advertising_wanted = get_int(argp[i], 16);
+			full_advertising_wanted = get_int(argp[i], 16);
 		} else if (!strcmp(argp[i], "phyad")) {
 			gset_changed = 1;
 			i += 1;
@@ -2334,7 +2347,10 @@ static int do_sset(struct cmd_context *ctx)
 		}
 	}
 
-	if (advertising_wanted < 0) {
+	if (full_advertising_wanted < 0) {
+		/* User didn't supply a full advertisement bitfield:
+		 * construct one from the specified speed and duplex.
+		 */
 		if (speed_wanted == SPEED_10 && duplex_wanted == DUPLEX_HALF)
 			advertising_wanted = ADVERTISED_10baseT_Half;
 		else if (speed_wanted == SPEED_10 &&
@@ -2405,19 +2421,20 @@ static int do_sset(struct cmd_context *ctx)
 			}
 			if (autoneg_wanted == AUTONEG_ENABLE &&
 			    advertising_wanted == 0) {
-				ecmd.advertising = ecmd.supported &
-					(ADVERTISED_10baseT_Half |
-					 ADVERTISED_10baseT_Full |
-					 ADVERTISED_100baseT_Half |
-					 ADVERTISED_100baseT_Full |
-					 ADVERTISED_1000baseT_Half |
-					 ADVERTISED_1000baseT_Full |
-					 ADVERTISED_2500baseX_Full |
-					 ADVERTISED_10000baseT_Full |
-					 ADVERTISED_20000baseMLD2_Full |
-					 ADVERTISED_20000baseKR2_Full);
+				/* Auto negotation enabled, but with
+				 * unspecified speed and duplex: enable all
+				 * supported speeds and duplexes.
+				 */
+				ecmd.advertising = (ecmd.advertising &
+					~ALL_ADVERTISED_MODES) |
+					(ALL_ADVERTISED_MODES & ecmd.supported);
 			} else if (advertising_wanted > 0) {
-				ecmd.advertising = advertising_wanted;
+				/* Enable all requested modes */
+				ecmd.advertising = (ecmd.advertising &
+					~ALL_ADVERTISED_MODES) |
+					(advertising_wanted & ecmd.supported);
+			} else if (full_advertising_wanted > 0) {
+				ecmd.advertising = full_advertising_wanted;
 			}
 
 			/* Try to perform the update. */
-- 
1.7.10
