From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool] ethtool: Warn if we cannot set the advertising
 mask for specified speed/duplex
Date: Thu, 17 Feb 2011 19:06:16 +0000
Message-ID: <1297969576.2637.33.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com,
	Naveen Chouksey <nchouksey@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:26945 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755604Ab1BQTGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 14:06:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When autonegotiation is enabled, drivers must determine link speed and
duplex through the autonegotiation process and will generally ignore
the speed and duplex specified in struct ethtool_cmd.  If the user
specifies a recognised combination of speed and duplex, we set the
advertising mask to include only the matching mode.  Otherwise, we
advertise all supported modes.  We should really limit the advertised
modes separately by speed and duplex, but for now we just warn.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This is a longstanding bug in ethtool which people keep getting bitten
by.  Naveen was just the latest to report it.  I have been working on
some changes to improve link advertising and reporting, but until those
are ready I'm adding this warning.

Ben.

 ethtool.c |   46 ++++++++++++++++++++++++++++++++--------------
 1 files changed, 32 insertions(+), 14 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 1afdfe4..a5c70d5 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1126,7 +1126,7 @@ static void parse_cmdline(int argc, char **argp)
 		}
 	}
 
-	if ((autoneg_wanted == AUTONEG_ENABLE) && (advertising_wanted < 0)) {
+	if (advertising_wanted < 0) {
 		if (speed_wanted == SPEED_10 && duplex_wanted == DUPLEX_HALF)
 			advertising_wanted = ADVERTISED_10baseT_Half;
 		else if (speed_wanted == SPEED_10 &&
@@ -2528,19 +2528,37 @@ static int do_sset(int fd, struct ifreq *ifr)
 				ecmd.phy_address = phyad_wanted;
 			if (xcvr_wanted != -1)
 				ecmd.transceiver = xcvr_wanted;
-			if (advertising_wanted != -1) {
-				if (advertising_wanted == 0)
-					ecmd.advertising = ecmd.supported &
-						(ADVERTISED_10baseT_Half |
-						 ADVERTISED_10baseT_Full |
-						 ADVERTISED_100baseT_Half |
-						 ADVERTISED_100baseT_Full |
-						 ADVERTISED_1000baseT_Half |
-						 ADVERTISED_1000baseT_Full |
-						 ADVERTISED_2500baseX_Full |
-						 ADVERTISED_10000baseT_Full);
-				else
-					ecmd.advertising = advertising_wanted;
+			if (advertising_wanted == 0) {
+				/* XXX If autoneg is on and the user
+				 * specified speed or duplex then we
+				 * should mask the advertised modes
+				 * accordingly.  For now, warn that we
+				 * aren't doing that.
+				 */
+				if (ecmd.autoneg &&
+				    (speed_wanted >= 0 || duplex_wanted >= 0)) {
+					fprintf(stderr, "Cannot advertise");
+					if (speed_wanted >= 0)
+						fprintf(stderr, " speed %d",
+							speed_wanted);
+					if (duplex_wanted >= 0)
+						fprintf(stderr, " duplex %s",
+							duplex_wanted ? 
+							"full" : "half");
+					fprintf(stderr,	"; advertising all"
+						" supported modes\n");
+				}
+				ecmd.advertising = ecmd.supported &
+					(ADVERTISED_10baseT_Half |
+					 ADVERTISED_10baseT_Full |
+					 ADVERTISED_100baseT_Half |
+					 ADVERTISED_100baseT_Full |
+					 ADVERTISED_1000baseT_Half |
+					 ADVERTISED_1000baseT_Full |
+					 ADVERTISED_2500baseX_Full |
+					 ADVERTISED_10000baseT_Full);
+			} else if (advertising_wanted != -1) {
+				ecmd.advertising = advertising_wanted;
 			}
 
 			/* Try to perform the update. */
-- 
1.7.3.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

