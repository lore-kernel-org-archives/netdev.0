From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 6/7] Report when offload feature changes are not
 exactly as requested
Date: Sat, 2 Jun 2012 01:39:38 +0100
Message-ID: <1338597578.2770.19.camel@bwh-desktop.uk.solarflarecom.com>
References: <1338597227.2770.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Mahesh Bandewar <maheshb@google.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:35867 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1760249Ab2FBAjl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2012 20:39:41 -0400
In-Reply-To: <1338597227.2770.13.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When an offload feature is enabled or disabled, this can change the
state of other features that depend on it, or may itself be deferred
if it depends on a feature that is disabled.  Report when this
happens, and fail if no offload features could be changed.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c       |   65 ++++++++++++++++++++++++++++++++++++++-----------------
 test-features.c |   34 +++++++++++++++++++++++++++-
 2 files changed, 77 insertions(+), 22 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 34d8b90..1cb708f 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1069,13 +1069,15 @@ static int dump_coalesce(const struct ethtool_coalesce *ecoal)
 	return 0;
 }
 
-static int dump_offload(u32 active)
+static int dump_offload(u32 active, u32 mask)
 {
 	u32 value;
 	int i;
 
 	for (i = 0; i < ARRAY_SIZE(off_flag_def); i++) {
 		value = off_flag_def[i].value;
+		if (!(mask & value))
+			continue;
 		printf("%s: %s\n",
 		       off_flag_def[i].long_name,
 		       (active & value) ? "on" : "off");
@@ -1647,17 +1649,14 @@ static int do_scoalesce(struct cmd_context *ctx)
 	return 0;
 }
 
-static int do_goffload(struct cmd_context *ctx)
+static int get_offload(struct cmd_context *ctx, u32 *flags)
 {
 	struct ethtool_value eval;
 	int err, allfail = 1;
-	u32 flags = 0, value;
+	u32 value;
 	int i;
 
-	if (ctx->argc != 0)
-		exit_bad_args();
-
-	fprintf(stdout, "Offload parameters for %s:\n", ctx->devname);
+	*flags = 0; 
 
 	for (i = 0; i < ARRAY_SIZE(off_flag_def); i++) {
 		value = off_flag_def[i].value;
@@ -1671,7 +1670,7 @@ static int do_goffload(struct cmd_context *ctx)
 				off_flag_def[i].long_name);
 		} else {
 			if (eval.data)
-				flags |= value;
+				*flags |= value;
 			allfail = 0;
 		}
 	}
@@ -1681,16 +1680,28 @@ static int do_goffload(struct cmd_context *ctx)
 	if (err) {
 		perror("Cannot get device flags");
 	} else {
-		flags |= eval.data & ETH_FLAG_EXT_MASK;
+		*flags |= eval.data & ETH_FLAG_EXT_MASK;
 		allfail = 0;
 	}
 
-	if (allfail) {
+	return allfail;
+}
+
+static int do_goffload(struct cmd_context *ctx)
+{
+	u32 flags;
+
+	if (ctx->argc != 0)
+		exit_bad_args();
+
+	fprintf(stdout, "Offload parameters for %s:\n", ctx->devname);
+
+	if (get_offload(ctx, &flags)) {
 		fprintf(stdout, "no offload info available\n");
 		return 83;
 	}
 
-	return dump_offload(flags);
+	return dump_offload(flags, ~(u32)0);
 }
 
 static int do_soffload(struct cmd_context *ctx)
@@ -1699,6 +1710,7 @@ static int do_soffload(struct cmd_context *ctx)
 	u32 off_flags_wanted = 0;
 	u32 off_flags_mask = 0;
 	struct cmdline_info cmdline_offload[ARRAY_SIZE(off_flag_def)];
+	u32 old_flags, new_flags, diff;
 	struct ethtool_value eval;
 	int err;
 	int i;
@@ -1712,6 +1724,11 @@ static int do_soffload(struct cmd_context *ctx)
 	parse_generic_cmdline(ctx, &goffload_changed,
 			      cmdline_offload, ARRAY_SIZE(cmdline_offload));
 
+	if (get_offload(ctx, &old_flags)) {
+		fprintf(stderr, "no offload info available\n");
+		return 1;
+	}
+
 	for (i = 0; i < ARRAY_SIZE(off_flag_def); i++) {
 		if (!off_flag_def[i].set_cmd)
 			continue;
@@ -1729,16 +1746,8 @@ static int do_soffload(struct cmd_context *ctx)
 		}
 	}
 	if (off_flags_mask & ETH_FLAG_EXT_MASK) {
-		eval.cmd = ETHTOOL_GFLAGS;
-		eval.data = 0;
-		err = send_ioctl(ctx, &eval);
-		if (err) {
-			perror("Cannot get device flag settings");
-			return 91;
-		}
-
 		eval.cmd = ETHTOOL_SFLAGS;
-		eval.data &= ~(off_flags_mask & ETH_FLAG_EXT_MASK);
+		eval.data = old_flags & ~off_flags_mask & ETH_FLAG_EXT_MASK;
 		eval.data |= off_flags_wanted & ETH_FLAG_EXT_MASK;
 
 		err = send_ioctl(ctx, &eval);
@@ -1750,6 +1759,22 @@ static int do_soffload(struct cmd_context *ctx)
 
 	if (off_flags_mask == 0) {
 		fprintf(stdout, "no offload settings changed\n");
+		return 0;
+	}
+
+	/* Compare new state with requested state */
+	if (get_offload(ctx, &new_flags)) {
+		fprintf(stderr, "no offload info available\n");
+		return 1;
+	}
+	if (new_flags != ((old_flags & ~off_flags_mask) | off_flags_wanted)) {
+		if (new_flags == old_flags) {
+			fprintf(stderr,
+				"Could not change any device offload settings\n");
+			return 1;
+		}
+		printf("Actual changes:\n");
+		dump_offload(new_flags, new_flags ^ old_flags);
 	}
 
 	return 0;
diff --git a/test-features.c b/test-features.c
index 349bc23..409b3d2 100644
--- a/test-features.c
+++ b/test-features.c
@@ -68,6 +68,14 @@ static const struct cmd_expect cmd_expect_get_features_off[] = {
 };
 
 static const struct cmd_expect cmd_expect_set_features_off[] = {
+	{ &cmd_grxcsum_on, 4, 0, &cmd_grxcsum_on, sizeof(cmd_grxcsum_on) },
+	{ &cmd_gtxcsum_on, 4, 0, &cmd_gtxcsum_on, sizeof(cmd_gtxcsum_on) },
+	{ &cmd_gsg_on, 4, 0, &cmd_gsg_on, sizeof(cmd_gsg_on) },
+	{ &cmd_gtso_on, 4, 0, &cmd_gtso_on, sizeof(cmd_gtso_on) },
+	{ &cmd_gufo_on, 4, 0, &cmd_gufo_on, sizeof(cmd_gufo_on) },
+	{ &cmd_ggso_on, 4, 0, &cmd_ggso_on, sizeof(cmd_ggso_on) },
+	{ &cmd_ggro_on, 4,0, &cmd_ggro_on, sizeof(cmd_ggro_on) },
+	{ &cmd_gflags_on, 4, 0, &cmd_gflags_on, sizeof(cmd_sflags_on) },
 	{ &cmd_srxcsum_off, sizeof(cmd_srxcsum_off), 0, 0, 0 },
 	{ &cmd_stxcsum_off, sizeof(cmd_stxcsum_off), 0, 0, 0 },
 	{ &cmd_ssg_off, sizeof(cmd_ssg_off), 0, 0, 0 },
@@ -75,12 +83,27 @@ static const struct cmd_expect cmd_expect_set_features_off[] = {
 	{ &cmd_sufo_off, sizeof(cmd_sufo_off), 0, 0, 0 },
 	{ &cmd_sgso_off, sizeof(cmd_sgso_off), 0, 0, 0 },
 	{ &cmd_sgro_off, sizeof(cmd_sgro_off), 0, 0, 0 },
-	{ &cmd_gflags_on, 4, 0, &cmd_gflags_on, sizeof(cmd_sflags_on) },
 	{ &cmd_sflags_off, sizeof(cmd_sflags_off), 0, 0, 0 },
+	{ &cmd_grxcsum_off, 4, 0, &cmd_grxcsum_off, sizeof(cmd_grxcsum_off) },
+	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
+	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
+	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
+	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
+	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
+	{ &cmd_ggro_off, 4,0, &cmd_ggro_off, sizeof(cmd_ggro_off) },
+	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_sflags_off) },
 	{ 0, 0, 0, 0, 0 }
 };
 
 static const struct cmd_expect cmd_expect_set_features_on[] = {
+	{ &cmd_grxcsum_off, 4, 0, &cmd_grxcsum_off, sizeof(cmd_grxcsum_off) },
+	{ &cmd_gtxcsum_off, 4, 0, &cmd_gtxcsum_off, sizeof(cmd_gtxcsum_off) },
+	{ &cmd_gsg_off, 4, 0, &cmd_gsg_off, sizeof(cmd_gsg_off) },
+	{ &cmd_gtso_off, 4, 0, &cmd_gtso_off, sizeof(cmd_gtso_off) },
+	{ &cmd_gufo_off, 4, 0, &cmd_gufo_off, sizeof(cmd_gufo_off) },
+	{ &cmd_ggso_off, 4, 0, &cmd_ggso_off, sizeof(cmd_ggso_off) },
+	{ &cmd_ggro_off, 4,0, &cmd_ggro_off, sizeof(cmd_ggro_off) },
+	{ &cmd_gflags_off, 4, 0, &cmd_gflags_off, sizeof(cmd_gflags_off) },
 	{ &cmd_srxcsum_on, sizeof(cmd_srxcsum_on), 0, 0, 0 },
 	{ &cmd_stxcsum_on, sizeof(cmd_stxcsum_on), 0, 0, 0 },
 	{ &cmd_ssg_on, sizeof(cmd_ssg_on), 0, 0, 0 },
@@ -88,8 +111,15 @@ static const struct cmd_expect cmd_expect_set_features_on[] = {
 	{ &cmd_sufo_on, sizeof(cmd_sufo_on), 0, 0, 0 },
 	{ &cmd_sgso_on, sizeof(cmd_sgso_on), 0, 0, 0 },
 	{ &cmd_sgro_on, sizeof(cmd_sgro_on), 0, 0, 0 },
-	{ &cmd_gflags_off, 4, 0, &cmd_gflags_on, sizeof(cmd_sflags_off) },
 	{ &cmd_sflags_on, sizeof(cmd_sflags_on), 0, 0, 0 },
+	{ &cmd_grxcsum_on, 4, 0, &cmd_grxcsum_on, sizeof(cmd_grxcsum_on) },
+	{ &cmd_gtxcsum_on, 4, 0, &cmd_gtxcsum_on, sizeof(cmd_gtxcsum_on) },
+	{ &cmd_gsg_on, 4, 0, &cmd_gsg_on, sizeof(cmd_gsg_on) },
+	{ &cmd_gtso_on, 4, 0, &cmd_gtso_on, sizeof(cmd_gtso_on) },
+	{ &cmd_gufo_on, 4, 0, &cmd_gufo_on, sizeof(cmd_gufo_on) },
+	{ &cmd_ggso_on, 4, 0, &cmd_ggso_on, sizeof(cmd_ggso_on) },
+	{ &cmd_ggro_on, 4,0, &cmd_ggro_on, sizeof(cmd_ggro_on) },
+	{ &cmd_gflags_on, 4, 0, &cmd_gflags_on, sizeof(cmd_sflags_on) },
 	{ 0, 0, 0, 0, 0 }
 };
 
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
