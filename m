From: Johan Gunnarsson <johan.gunnarsson@axis.com>
Subject: [PATCH v2] ethtool: don't overwrite useful bits in advertising bitfield
Date: Fri, 24 Aug 2012 13:32:45 +0200
Message-ID: <1345807965-16236-1-git-send-email-johangu@axis.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <bhutchings@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from anubis.se.axis.com ([195.60.68.12]:33055 "EHLO
	anubis.se.axis.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752896Ab2HXLaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 07:30:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are bits in this bitfield that we want to leave untouched (PAUSE
and ASYM_PAUSE bits) when changing other bits (speed and duplex bits.)
Previously, these were always overwritten to zero when running commands
like "ethtool -s eth0 speed 10 duplex full autoneg off".

Signed-off-by: Johan Gunnarsson <johangu@axis.com>
---
Changes since v1:

* Added missing 10G and 40G link modes.
* Warn when drivers supports advertising flags that we don't know about.
* Removed "& ecmd.supported" in the advertising_wanted > 0 case.

 ethtool.c |   89 +++++++++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 75 insertions(+), 14 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index e573357..9cbe231 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -46,6 +46,53 @@
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
+	 ADVERTISED_10000baseKX4_Full | \
+	 ADVERTISED_10000baseKR_Full | \
+	 ADVERTISED_10000baseR_FEC | \
+	 ADVERTISED_20000baseMLD2_Full | \
+	 ADVERTISED_20000baseKR2_Full | \
+	 ADVERTISED_40000baseKR4_Full | \
+	 ADVERTISED_40000baseCR4_Full | \
+	 ADVERTISED_40000baseSR4_Full | \
+	 ADVERTISED_40000baseLR4_Full)
+
+#define ALL_ADVERTISED_FLAGS \
+	(ADVERTISED_10baseT_Half | \
+	 ADVERTISED_10baseT_Full | \
+	 ADVERTISED_100baseT_Half | \
+	 ADVERTISED_100baseT_Full | \
+	 ADVERTISED_1000baseT_Half | \
+	 ADVERTISED_1000baseT_Full | \
+	 ADVERTISED_Autoneg | \
+	 ADVERTISED_TP | \
+	 ADVERTISED_AUI | \
+	 ADVERTISED_MII | \
+	 ADVERTISED_FIBRE | \
+	 ADVERTISED_BNC | \
+	 ADVERTISED_10000baseT_Full | \
+	 ADVERTISED_Pause | \
+	 ADVERTISED_Asym_Pause | \
+	 ADVERTISED_2500baseX_Full | \
+	 ADVERTISED_Backplane | \
+	 ADVERTISED_1000baseKX_Full | \
+	 ADVERTISED_10000baseKX4_Full | \
+	 ADVERTISED_10000baseKR_Full | \
+	 ADVERTISED_10000baseR_FEC | \
+	 ADVERTISED_20000baseMLD2_Full | \
+	 ADVERTISED_20000baseKR2_Full | \
+	 ADVERTISED_40000baseKR4_Full | \
+	 ADVERTISED_40000baseCR4_Full | \
+	 ADVERTISED_40000baseSR4_Full | \
+	 ADVERTISED_40000baseLR4_Full)
+
 #ifndef HAVE_NETIF_MSG
 enum {
 	NETIF_MSG_DRV		= 0x0001,
@@ -2202,6 +2249,7 @@ static int do_sset(struct cmd_context *ctx)
 	int autoneg_wanted = -1;
 	int phyad_wanted = -1;
 	int xcvr_wanted = -1;
+	int full_advertising_wanted = -1;
 	int advertising_wanted = -1;
 	int gset_changed = 0; /* did anything in GSET change? */
 	u32 wol_wanted = 0;
@@ -2277,7 +2325,7 @@ static int do_sset(struct cmd_context *ctx)
 			i += 1;
 			if (i >= argc)
 				exit_bad_args();
-			advertising_wanted = get_int(argp[i], 16);
+			full_advertising_wanted = get_int(argp[i], 16);
 		} else if (!strcmp(argp[i], "phyad")) {
 			gset_changed = 1;
 			i += 1;
@@ -2334,7 +2382,10 @@ static int do_sset(struct cmd_context *ctx)
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
@@ -2405,19 +2456,29 @@ static int do_sset(struct cmd_context *ctx)
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
+
+				/* If driver supports unknown flags, we can not
+				 * be sure that we enable all link modes.
+				 */
+				if ((ecmd.supported & ALL_ADVERTISED_FLAGS) !=
+				    ecmd.supported) {
+					fprintf(stderr, "Drivers supports one "
+					        "or more unknown flags\n");
+				}
 			} else if (advertising_wanted > 0) {
-				ecmd.advertising = advertising_wanted;
+				/* Enable all requested modes */
+				ecmd.advertising = (ecmd.advertising &
+					~ALL_ADVERTISED_MODES) |
+					advertising_wanted;
+			} else if (full_advertising_wanted > 0) {
+				ecmd.advertising = full_advertising_wanted;
 			}
 
 			/* Try to perform the update. */
-- 
1.7.10
