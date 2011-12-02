From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 1/2] Implement and use a generic get_stringset()
 function
Date: Fri, 2 Dec 2011 00:13:35 +0000
Message-ID: <1322784815.2797.26.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Jean Delvare <jdelvare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:50886 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755715Ab1LBANj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 19:13:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
If you apply this and the next patch on top of ethtool 3.1 you should be
able to get and set private flags.  I tried adding some dummy flags to a
driver and it worked as expected.

ethtool 3.1 is currently only tagged in git
(git://git.kernel.org/pub/scm/network/ethtool/ethtool.git); I'll push
these changes there unless you tell me they're broken

Ben.

 ethtool.c |  121 ++++++++++++++++++++++++++++++++++---------------------------
 1 files changed, 67 insertions(+), 54 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 6909827..f0c9d08 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -855,8 +855,8 @@ static int dump_eeprom(int geeprom_dump_raw, struct ethtool_drvinfo *info,
 	return 0;
 }
 
-static int dump_test(struct ethtool_drvinfo *info, struct ethtool_test *test,
-		      struct ethtool_gstrings *strings)
+static int dump_test(struct ethtool_test *test,
+		     struct ethtool_gstrings *strings)
 {
 	int i, rc;
 
@@ -868,10 +868,10 @@ static int dump_test(struct ethtool_drvinfo *info, struct ethtool_test *test,
 			(test->flags & ETH_TEST_FL_EXTERNAL_LB_DONE) ?
 			"" : "not ");
 
-	if (info->testinfo_len)
+	if (strings->len)
 		fprintf(stdout, "The test extra info:\n");
 
-	for (i = 0; i < info->testinfo_len; i++) {
+	for (i = 0; i < strings->len; i++) {
 		fprintf(stdout, "%s\t %d\n",
 			(char *)(strings->data + i * ETH_GSTRING_LEN),
 			(u32) test->data[i]);
@@ -1113,6 +1113,48 @@ static int dump_rxfhash(int fhash, u64 val)
 	return 0;
 }
 
+static struct ethtool_gstrings *
+get_stringset(struct cmd_context *ctx, enum ethtool_stringset set_id,
+	      ptrdiff_t drvinfo_offset)
+{
+	struct {
+		struct ethtool_sset_info hdr;
+		u32 buf[1];
+	} sset_info;
+	struct ethtool_drvinfo drvinfo;
+	u32 len;
+	struct ethtool_gstrings *strings;
+
+	sset_info.hdr.cmd = ETHTOOL_GSSET_INFO;
+	sset_info.hdr.reserved = 0;
+	sset_info.hdr.sset_mask = 1ULL << set_id;
+	if (send_ioctl(ctx, &sset_info) == 0) {
+		len = sset_info.hdr.sset_mask ? sset_info.hdr.data[0] : 0;
+	} else if (errno == EOPNOTSUPP && drvinfo_offset != 0) {
+		/* Fallback for old kernel versions */
+		drvinfo.cmd = ETHTOOL_GDRVINFO;
+		if (send_ioctl(ctx, &drvinfo))
+			return NULL;
+		len = *(u32 *)((char *)&drvinfo + drvinfo_offset);
+	} else {
+		return NULL;
+	}
+
+	strings = calloc(1, sizeof(*strings) + len * ETH_GSTRING_LEN);
+	if (!strings)
+		return NULL;
+
+	strings->cmd = ETHTOOL_GSTRINGS;
+	strings->string_set = set_id;
+	strings->len = len;
+	if (len != 0 && send_ioctl(ctx, strings)) {
+		free(strings);
+		return NULL;
+	}
+
+	return strings;
+}
+
 static int do_gdrv(struct cmd_context *ctx)
 {
 	int err;
@@ -2293,7 +2335,6 @@ static int do_test(struct cmd_context *ctx)
 		EXTERNAL_LB,
 	} test_type;
 	int err;
-	struct ethtool_drvinfo drvinfo;
 	struct ethtool_test *test;
 	struct ethtool_gstrings *strings;
 
@@ -2313,21 +2354,22 @@ static int do_test(struct cmd_context *ctx)
 		test_type = OFFLINE;
 	}
 
-	drvinfo.cmd = ETHTOOL_GDRVINFO;
-	err = send_ioctl(ctx, &drvinfo);
-	if (err < 0) {
-		perror("Cannot get driver information");
-		return 72;
+	strings = get_stringset(ctx, ETH_SS_TEST,
+				offsetof(struct ethtool_drvinfo, testinfo_len));
+	if (!strings) {
+		perror("Cannot get strings");
+		return 74;
 	}
 
-	test = calloc(1, sizeof(*test) + drvinfo.testinfo_len * sizeof(u64));
+	test = calloc(1, sizeof(*test) + strings->len * sizeof(u64));
 	if (!test) {
 		perror("Cannot allocate memory for test info");
+		free(strings);
 		return 73;
 	}
-	memset (test->data, 0, drvinfo.testinfo_len * sizeof(u64));
+	memset(test->data, 0, strings->len * sizeof(u64));
 	test->cmd = ETHTOOL_TEST;
-	test->len = drvinfo.testinfo_len;
+	test->len = strings->len;
 	if (test_type == EXTERNAL_LB)
 		test->flags = (ETH_TEST_FL_OFFLINE | ETH_TEST_FL_EXTERNAL_LB);
 	else if (test_type == OFFLINE)
@@ -2338,28 +2380,11 @@ static int do_test(struct cmd_context *ctx)
 	if (err < 0) {
 		perror("Cannot test");
 		free (test);
+		free(strings);
 		return 74;
 	}
 
-	strings = calloc(1, sizeof(*strings) +
-			    drvinfo.testinfo_len * ETH_GSTRING_LEN);
-	if (!strings) {
-		perror("Cannot allocate memory for strings");
-		free(test);
-		return 73;
-	}
-	memset (strings->data, 0, drvinfo.testinfo_len * ETH_GSTRING_LEN);
-	strings->cmd = ETHTOOL_GSTRINGS;
-	strings->string_set = ETH_SS_TEST;
-	strings->len = drvinfo.testinfo_len;
-	err = send_ioctl(ctx, strings);
-	if (err < 0) {
-		perror("Cannot get strings");
-		free (test);
-		free (strings);
-		return 74;
-	}
-	err = dump_test(&drvinfo, test, strings);
+	err = dump_test(test, strings);
 	free(test);
 	free(strings);
 
@@ -2390,47 +2415,35 @@ static int do_phys_id(struct cmd_context *ctx)
 
 static int do_gstats(struct cmd_context *ctx)
 {
-	struct ethtool_drvinfo drvinfo;
 	struct ethtool_gstrings *strings;
 	struct ethtool_stats *stats;
-	unsigned int n_stats, sz_str, sz_stats, i;
+	unsigned int n_stats, sz_stats, i;
 	int err;
 
 	if (ctx->argc != 0)
 		exit_bad_args();
 
-	drvinfo.cmd = ETHTOOL_GDRVINFO;
-	err = send_ioctl(ctx, &drvinfo);
-	if (err < 0) {
-		perror("Cannot get driver information");
-		return 71;
+	strings = get_stringset(ctx, ETH_SS_STATS,
+				offsetof(struct ethtool_drvinfo, n_stats));
+	if (!strings) {
+		perror("Cannot get stats strings information");
+		return 96;
 	}
 
-	n_stats = drvinfo.n_stats;
+	n_stats = strings->len;
 	if (n_stats < 1) {
 		fprintf(stderr, "no stats available\n");
+		free(strings);
 		return 94;
 	}
 
-	sz_str = n_stats * ETH_GSTRING_LEN;
 	sz_stats = n_stats * sizeof(u64);
 
-	strings = calloc(1, sz_str + sizeof(struct ethtool_gstrings));
 	stats = calloc(1, sz_stats + sizeof(struct ethtool_stats));
-	if (!strings || !stats) {
+	if (!stats) {
 		fprintf(stderr, "no memory available\n");
-		return 95;
-	}
-
-	strings->cmd = ETHTOOL_GSTRINGS;
-	strings->string_set = ETH_SS_STATS;
-	strings->len = n_stats;
-	err = send_ioctl(ctx, strings);
-	if (err < 0) {
-		perror("Cannot get stats strings information");
 		free(strings);
-		free(stats);
-		return 96;
+		return 95;
 	}
 
 	stats->cmd = ETHTOOL_GSTATS;
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
