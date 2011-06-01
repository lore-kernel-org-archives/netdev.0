From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool] Combine code to display supported and advertised
 link capabilities
Date: Wed, 01 Jun 2011 23:49:29 +0100
Message-ID: <1306968569.2758.54.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Esa-Pekka =?ISO-8859-1?Q?Py=F6kkimies?=
	<esa-pekka.pyokkimies@stonesoft.com>,
	Yaniv Rosner <yanivr@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:53896 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756127Ab1FAWtc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 18:49:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rename dump_advertised() to dump_link_caps(), and change
dump_supported() to call it instead of repeating nearly identical
code.  Add a separate prefix parameter and adjust indentation
so that the output is unchanged except for added lines.

Deleted unused parameter and variables.

As an immediate benefit, this adds the display of supported pause
frame use.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
I've just committed and pushed out this change to ethtool.

Esa-Pekka, I think this covers what you wanted.

Yaniv, this should allow you to add the 20G flags in just one function.
But I still want you to update the manual page at the same time.

Ben.

 ethtool.c |   80 ++++++++++++++++---------------------------------------------
 1 files changed, 21 insertions(+), 59 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index edfbe3d..b6fa6bd 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1132,10 +1132,11 @@ static void parse_cmdline(int argc, char **argp)
 		exit_bad_args();
 }
 
+static void dump_link_caps(const char *prefix, const char *an_prefix, u32 mask);
+
 static void dump_supported(struct ethtool_cmd *ep)
 {
-	u_int32_t mask = ep->supported;
-	int did1;
+	u32 mask = ep->supported;
 
 	fprintf(stdout, "	Supported ports: [ ");
 	if (mask & SUPPORTED_TP)
@@ -1150,64 +1151,25 @@ static void dump_supported(struct ethtool_cmd *ep)
 		fprintf(stdout, "FIBRE ");
 	fprintf(stdout, "]\n");
 
-	fprintf(stdout, "	Supported link modes:   ");
-	did1 = 0;
-	if (mask & SUPPORTED_10baseT_Half) {
-		did1++; fprintf(stdout, "10baseT/Half ");
-	}
-	if (mask & SUPPORTED_10baseT_Full) {
-		did1++; fprintf(stdout, "10baseT/Full ");
-	}
-	if (did1 && (mask & (SUPPORTED_100baseT_Half|SUPPORTED_100baseT_Full))) {
-		fprintf(stdout, "\n");
-		fprintf(stdout, "	                        ");
-	}
-	if (mask & SUPPORTED_100baseT_Half) {
-		did1++; fprintf(stdout, "100baseT/Half ");
-	}
-	if (mask & SUPPORTED_100baseT_Full) {
-		did1++; fprintf(stdout, "100baseT/Full ");
-	}
-	if (did1 && (mask & (SUPPORTED_1000baseT_Half|SUPPORTED_1000baseT_Full))) {
-		fprintf(stdout, "\n");
-		fprintf(stdout, "	                        ");
-	}
-	if (mask & SUPPORTED_1000baseT_Half) {
-		did1++; fprintf(stdout, "1000baseT/Half ");
-	}
-	if (mask & SUPPORTED_1000baseT_Full) {
-		did1++; fprintf(stdout, "1000baseT/Full ");
-	}
-	if (did1 && (mask & SUPPORTED_2500baseX_Full)) {
-		fprintf(stdout, "\n");
-		fprintf(stdout, "	                        ");
-	}
-	if (mask & SUPPORTED_2500baseX_Full) {
-		did1++; fprintf(stdout, "2500baseX/Full ");
-	}
-	if (did1 && (mask & SUPPORTED_10000baseT_Full)) {
-		fprintf(stdout, "\n");
-		fprintf(stdout, "	                        ");
-	}
-	if (mask & SUPPORTED_10000baseT_Full) {
-		did1++; fprintf(stdout, "10000baseT/Full ");
-	}
-	fprintf(stdout, "\n");
-
-	fprintf(stdout, "	Supports auto-negotiation: ");
-	if (mask & SUPPORTED_Autoneg)
-		fprintf(stdout, "Yes\n");
-	else
-		fprintf(stdout, "No\n");
+	dump_link_caps("Supported", "Supports", mask);
 }
 
-static void dump_advertised(struct ethtool_cmd *ep,
-			    const char *prefix, u_int32_t mask)
+/* Print link capability flags (supported, advertised or lp_advertised).
+ * Assumes that the corresponding SUPPORTED and ADVERTISED flags are equal.
+ */
+static void
+dump_link_caps(const char *prefix, const char *an_prefix, u32 mask)
 {
-	int indent = strlen(prefix) + 14;
+	int indent;
 	int did1;
 
-	fprintf(stdout, "	%s link modes:  ", prefix);
+	/* Indent just like the separate functions used to */
+	indent = strlen(prefix) + 14;
+	if (indent < 24)
+		indent = 24;
+
+	fprintf(stdout, "	%s link modes:%*s", prefix,
+		indent - strlen(prefix) - 12, "");
 	did1 = 0;
 	if (mask & ADVERTISED_10baseT_Half) {
 		did1++; fprintf(stdout, "10baseT/Half ");
@@ -1266,7 +1228,7 @@ static void dump_advertised(struct ethtool_cmd *ep,
 			fprintf(stdout, "No\n");
 	}
 
-	fprintf(stdout, "	%s auto-negotiation: ", prefix);
+	fprintf(stdout, "	%s auto-negotiation: ", an_prefix);
 	if (mask & ADVERTISED_Autoneg)
 		fprintf(stdout, "Yes\n");
 	else
@@ -1278,10 +1240,10 @@ static int dump_ecmd(struct ethtool_cmd *ep)
 	u32 speed;
 
 	dump_supported(ep);
-	dump_advertised(ep, "Advertised", ep->advertising);
+	dump_link_caps("Advertised", "Advertised", ep->advertising);
 	if (ep->lp_advertising)
-		dump_advertised(ep, "Link partner advertised",
-				ep->lp_advertising);
+		dump_link_caps("Link partner advertised",
+			       "Link partner advertised", ep->lp_advertising);
 
 	fprintf(stdout, "	Speed: ");
 	speed = ethtool_cmd_speed(ep);
-- 
1.7.4.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

