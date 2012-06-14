From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool] Don't trust drivers to null-terminate strings
Date: Thu, 14 Jun 2012 20:52:35 +0100
Message-ID: <1339703555.2719.29.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Phil Sutter <phil.sutter@viprinet.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:11281 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755409Ab2FNTwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2012 15:52:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've committed the following change to ethtool.

Ben.
---
Some drivers have been seen to fill all bytes of
ethtool_drvinfo::fw_version without including a null terminator, which
effectively concatenates the following bytes to the string.  We've
already dealt with a similar problem in dump_stats() (commit
7764430a139e4a089127f5616b0d56f497be1036).  Try to cover all the
remaining string fields:

- In dump_drvinfo(), limit the length using printf() modifiers
- Add an option to get_stringset() to null-terminate all strings
- Change all callers except dump_stats() to set that option

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |   38 +++++++++++++++++++++++---------------
 1 files changed, 23 insertions(+), 15 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index a5dce44..9e50640 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -615,19 +615,19 @@ static int dump_ecmd(struct ethtool_cmd *ep)
 static int dump_drvinfo(struct ethtool_drvinfo *info)
 {
 	fprintf(stdout,
-		"driver: %s\n"
-		"version: %s\n"
-		"firmware-version: %s\n"
-		"bus-info: %s\n"
+		"driver: %.*s\n"
+		"version: %.*s\n"
+		"firmware-version: %.*s\n"
+		"bus-info: %.*s\n"
 		"supports-statistics: %s\n"
 		"supports-test: %s\n"
 		"supports-eeprom-access: %s\n"
 		"supports-register-dump: %s\n"
 		"supports-priv-flags: %s\n",
-		info->driver,
-		info->version,
-		info->fw_version,
-		info->bus_info,
+		(int)sizeof(info->driver), info->driver,
+		(int)sizeof(info->version), info->version,
+		(int)sizeof(info->fw_version), info->fw_version,
+		(int)sizeof(info->bus_info), info->bus_info,
 		info->n_stats ? "yes" : "no",
 		info->testinfo_len ? "yes" : "no",
 		info->eedump_len ? "yes" : "no",
@@ -1317,14 +1317,14 @@ static int dump_tsinfo(const struct ethtool_ts_info *info)
 
 static struct ethtool_gstrings *
 get_stringset(struct cmd_context *ctx, enum ethtool_stringset set_id,
-	      ptrdiff_t drvinfo_offset)
+	      ptrdiff_t drvinfo_offset, int null_terminate)
 {
 	struct {
 		struct ethtool_sset_info hdr;
 		u32 buf[1];
 	} sset_info;
 	struct ethtool_drvinfo drvinfo;
-	u32 len;
+	u32 len, i;
 	struct ethtool_gstrings *strings;
 
 	sset_info.hdr.cmd = ETHTOOL_GSSET_INFO;
@@ -1354,6 +1354,10 @@ get_stringset(struct cmd_context *ctx, enum ethtool_stringset set_id,
 		return NULL;
 	}
 
+	if (null_terminate)
+		for (i = 0; i < len; i++)
+			strings->data[(i + 1) * ETH_GSTRING_LEN - 1] = 0;
+
 	return strings;
 }
 
@@ -1364,7 +1368,7 @@ static struct feature_defs *get_feature_defs(struct cmd_context *ctx)
 	u32 n_features;
 	int i, j;
 
-	names = get_stringset(ctx, ETH_SS_FEATURES, 0);
+	names = get_stringset(ctx, ETH_SS_FEATURES, 0, 1);
 	if (names) {
 		n_features = names->len;
 	} else if (errno == EOPNOTSUPP || errno == EINVAL) {
@@ -2640,7 +2644,8 @@ static int do_test(struct cmd_context *ctx)
 	}
 
 	strings = get_stringset(ctx, ETH_SS_TEST,
-				offsetof(struct ethtool_drvinfo, testinfo_len));
+				offsetof(struct ethtool_drvinfo, testinfo_len),
+				1);
 	if (!strings) {
 		perror("Cannot get strings");
 		return 74;
@@ -2709,7 +2714,8 @@ static int do_gstats(struct cmd_context *ctx)
 		exit_bad_args();
 
 	strings = get_stringset(ctx, ETH_SS_STATS,
-				offsetof(struct ethtool_drvinfo, n_stats));
+				offsetof(struct ethtool_drvinfo, n_stats),
+				0);
 	if (!strings) {
 		perror("Cannot get stats strings information");
 		return 96;
@@ -3274,7 +3280,8 @@ static int do_gprivflags(struct cmd_context *ctx)
 		exit_bad_args();
 
 	strings = get_stringset(ctx, ETH_SS_PRIV_FLAGS,
-				offsetof(struct ethtool_drvinfo, n_priv_flags));
+				offsetof(struct ethtool_drvinfo, n_priv_flags),
+				1);
 	if (!strings) {
 		perror("Cannot get private flag names");
 		return 1;
@@ -3314,7 +3321,8 @@ static int do_sprivflags(struct cmd_context *ctx)
 	unsigned int i;
 
 	strings = get_stringset(ctx, ETH_SS_PRIV_FLAGS,
-				offsetof(struct ethtool_drvinfo, n_priv_flags));
+				offsetof(struct ethtool_drvinfo, n_priv_flags),
+				1);
 	if (!strings) {
 		perror("Cannot get private flag names");
 		return 1;
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
