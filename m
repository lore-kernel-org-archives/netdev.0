From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool] Make link mode listing in dump_link_caps() a
 data-driven loop
Date: Fri, 8 Jun 2012 19:25:12 +0100
Message-ID: <1339179912.2648.10.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56247 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756367Ab2FHSZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 14:25:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've committed the following change.

Ben.
---
This removes lots of repeated code and makes it trivial to support
additional modes.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |   99 +++++++++++++++++++------------------------------------------
 1 files changed, 31 insertions(+), 68 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index f09a032..3576f4c 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -444,8 +444,25 @@ static void dump_supported(struct ethtool_cmd *ep)
 static void
 dump_link_caps(const char *prefix, const char *an_prefix, u32 mask)
 {
+	static const struct {
+		int same_line; /* print on same line as previous */
+		u32 value;
+		const char *name;
+	} mode_defs[] = {
+		{ 0, ADVERTISED_10baseT_Half,       "10baseT/Half" },
+		{ 1, ADVERTISED_10baseT_Full,       "10baseT/Full" },
+		{ 0, ADVERTISED_100baseT_Half,      "100baseT/Half" },
+		{ 1, ADVERTISED_100baseT_Full,      "100baseT/Full" },
+		{ 0, ADVERTISED_1000baseT_Half,     "1000baseT/Half" },
+		{ 1, ADVERTISED_1000baseT_Full,     "1000baseT/Full" },
+		{ 0, ADVERTISED_1000baseKX_Full,    "1000baseKX/Full" },
+		{ 0, ADVERTISED_2500baseX_Full,     "2500baseX/Full" },
+		{ 0, ADVERTISED_10000baseT_Full,    "10000baseT/Full" },
+		{ 0, ADVERTISED_10000baseKX4_Full,  "10000baseKX4/Full" },
+		{ 0, ADVERTISED_20000baseMLD2_Full, "20000baseMLD2/Full" },
+	};
 	int indent;
-	int did1;
+	int did1, new_line_pend, i;
 
 	/* Indent just like the separate functions used to */
 	indent = strlen(prefix) + 14;
@@ -455,73 +472,19 @@ dump_link_caps(const char *prefix, const char *an_prefix, u32 mask)
 	fprintf(stdout, "	%s link modes:%*s", prefix,
 		indent - (int)strlen(prefix) - 12, "");
 	did1 = 0;
-	if (mask & ADVERTISED_10baseT_Half) {
-		did1++; fprintf(stdout, "10baseT/Half ");
-	}
-	if (mask & ADVERTISED_10baseT_Full) {
-		did1++; fprintf(stdout, "10baseT/Full ");
-	}
-	if (did1 && (mask & (ADVERTISED_100baseT_Half|ADVERTISED_100baseT_Full))) {
-		fprintf(stdout, "\n");
-		fprintf(stdout, "	%*s", indent, "");
-	}
-	if (mask & ADVERTISED_100baseT_Half) {
-		did1++; fprintf(stdout, "100baseT/Half ");
-	}
-	if (mask & ADVERTISED_100baseT_Full) {
-		did1++; fprintf(stdout, "100baseT/Full ");
-	}
-	if (did1 && (mask & (ADVERTISED_1000baseT_Half|ADVERTISED_1000baseT_Full))) {
-		fprintf(stdout, "\n");
-		fprintf(stdout, "	%*s", indent, "");
-	}
-	if (mask & ADVERTISED_1000baseT_Half) {
-		did1++; fprintf(stdout, "1000baseT/Half ");
-	}
-	if (mask & ADVERTISED_1000baseT_Full) {
-		did1++; fprintf(stdout, "1000baseT/Full ");
-	}
-	if (did1 && (mask & ADVERTISED_1000baseKX_Full)) {
-		fprintf(stdout, "\n");
-		fprintf(stdout, "	%*s", indent, "");
-	}
-	if (mask & ADVERTISED_1000baseKX_Full) {
-		did1++; fprintf(stdout, "1000baseKX/Full ");
-	}
-	if (did1 && (mask & ADVERTISED_2500baseX_Full)) {
-		fprintf(stdout, "\n");
-		fprintf(stdout, "	%*s", indent, "");
-	}
-	if (mask & ADVERTISED_2500baseX_Full) {
-		did1++; fprintf(stdout, "2500baseX/Full ");
-	}
-	if (did1 && (mask & ADVERTISED_10000baseT_Full)) {
-		fprintf(stdout, "\n");
-		fprintf(stdout, "	%*s", indent, "");
-	}
-	if (mask & ADVERTISED_10000baseT_Full) {
-		did1++; fprintf(stdout, "10000baseT/Full ");
-	}
-	if (did1 && (mask & ADVERTISED_10000baseKX4_Full)) {
-		fprintf(stdout, "\n");
-		fprintf(stdout, "	%*s", indent, "");
-	}
-	if (mask & ADVERTISED_10000baseKX4_Full) {
-		did1++; fprintf(stdout, "10000baseKX4/Full ");
-	}
-	if (did1 && (mask & ADVERTISED_20000baseMLD2_Full)) {
-		fprintf(stdout, "\n");
-		fprintf(stdout, "	%*s", indent, "");
-	}
-	if (mask & ADVERTISED_20000baseMLD2_Full) {
-		did1++; fprintf(stdout, "20000baseMLD2/Full ");
-	}
-	if (did1 && (mask & ADVERTISED_20000baseKR2_Full)) {
-		fprintf(stdout, "\n");
-		fprintf(stdout, "	%*s", indent, "");
-	}
-	if (mask & ADVERTISED_20000baseKR2_Full) {
-		did1++; fprintf(stdout, "20000baseKR2/Full ");
+	new_line_pend = 0;
+	for (i = 0; i < ARRAY_SIZE(mode_defs); i++) {
+		if (did1 && !mode_defs[i].same_line)
+			new_line_pend = 1;
+		if (mask & mode_defs[i].value) {
+			if (new_line_pend) {
+				fprintf(stdout, "\n");
+				fprintf(stdout, "	%*s", indent, "");
+				new_line_pend = 0;
+			}
+			did1++;
+			fprintf(stdout, "%s ", mode_defs[i].name);
+		}
 	}
 	if (did1 == 0)
 		 fprintf(stdout, "Not reported");
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
