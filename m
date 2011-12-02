From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 2/2] Add support for querying and setting private
 flags
Date: Fri, 2 Dec 2011 00:18:50 +0000
Message-ID: <1322785130.2797.28.camel@bwh-desktop>
References: <1322784815.2797.26.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Jean Delvare <jdelvare@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:50976 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755488Ab1LBASy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 19:18:54 -0500
In-Reply-To: <1322784815.2797.26.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.8.in   |   20 +++++++++++
 ethtool.c      |  105 ++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 test-cmdline.c |    4 ++
 3 files changed, 127 insertions(+), 2 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 7c39629..e6e46cc 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -317,6 +317,14 @@ ethtool \- query or control network driver and hardware settings
 .BN tx
 .BN other
 .BN combined
+.HP
+.B ethtool \-\-show\-priv\-flags
+.I devname
+.HP
+.B ethtool \-\-set\-priv\-flags
+.I devname flag
+.A1 on off
+.RB ...
 .
 .\" Adjust lines (i.e. full justification) and hyphenate.
 .ad
@@ -783,6 +791,18 @@ Changes the number of channels used only for other purposes e.g. link interrupts
 .TP
 .BI combined \ N
 Changes the number of multi-purpose channels.
+.TP
+.B \-\-show\-priv\-flags
+Queries the specified network device for its private flags.  The
+names and meanings of private flags (if any) are defined by each
+network device driver.
+.TP
+.B \-\-set\-priv\-flags
+Sets the device's private flags as specified.
+.PP
+.I flag
+.A1 on off
+Sets the state of the named private flag.
 .SH BUGS
 Not supported (in part or whole) on all network drivers.
 .SH AUTHOR
diff --git a/ethtool.c b/ethtool.c
index f0c9d08..d21eaea 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -583,7 +583,8 @@ static int dump_drvinfo(struct ethtool_drvinfo *info)
 		"supports-statistics: %s\n"
 		"supports-test: %s\n"
 		"supports-eeprom-access: %s\n"
-		"supports-register-dump: %s\n",
+		"supports-register-dump: %s\n"
+		"supports-priv-flags: %s\n",
 		info->driver,
 		info->version,
 		info->fw_version,
@@ -591,7 +592,8 @@ static int dump_drvinfo(struct ethtool_drvinfo *info)
 		info->n_stats ? "yes" : "no",
 		info->testinfo_len ? "yes" : "no",
 		info->eedump_len ? "yes" : "no",
-		info->regdump_len ? "yes" : "no");
+		info->regdump_len ? "yes" : "no",
+		info->n_priv_flags ? "yes" : "no");
 
 	return 0;
 }
@@ -3001,6 +3003,102 @@ static int do_setfwdump(struct cmd_context *ctx)
 	return 0;
 }
 
+static int do_gprivflags(struct cmd_context *ctx)
+{
+	struct ethtool_gstrings *strings;
+	struct ethtool_value flags;
+	unsigned int i;
+
+	if (ctx->argc != 0)
+		exit_bad_args();
+
+	strings = get_stringset(ctx, ETH_SS_PRIV_FLAGS,
+				offsetof(struct ethtool_drvinfo, n_priv_flags));
+	if (!strings) {
+		perror("Cannot get private flag names");
+		return 1;
+	}
+	if (strings->len == 0) {
+		fprintf(stderr, "No private flags defined\n");
+		return 1;
+	}
+	if (strings->len > 32) {
+		/* ETHTOOL_GPFLAGS can only cover 32 flags */
+		fprintf(stderr, "Only showing first 32 private flags\n");
+		strings->len = 32;
+	}
+
+	flags.cmd = ETHTOOL_GPFLAGS;
+	if (send_ioctl(ctx, &flags)) {
+		perror("Cannot get private flags");
+		return 1;
+	}
+
+	printf("Private flags for %s:\n", ctx->devname);
+	for (i = 0; i < strings->len; i++)
+		printf("%s: %s\n",
+		       (const char *)strings->data + i * ETH_GSTRING_LEN,
+		       (flags.data & (1U << i)) ? "on" : "off");
+
+	return 0;
+}
+
+static int do_sprivflags(struct cmd_context *ctx)
+{
+	struct ethtool_gstrings *strings;
+	struct cmdline_info *cmdline;
+	struct ethtool_value flags;
+	u32 wanted_flags = 0, seen_flags = 0;
+	int any_changed;
+	unsigned int i;
+
+	strings = get_stringset(ctx, ETH_SS_PRIV_FLAGS,
+				offsetof(struct ethtool_drvinfo, n_priv_flags));
+	if (!strings) {
+		perror("Cannot get private flag names");
+		return 1;
+	}
+	if (strings->len == 0) {
+		fprintf(stderr, "No private flags defined\n");
+		return 1;
+	}
+	if (strings->len > 32) {
+		/* ETHTOOL_{G,S}PFLAGS can only cover 32 flags */
+		fprintf(stderr, "Only setting first 32 private flags\n");
+		strings->len = 32;
+	}
+
+	cmdline = calloc(strings->len, sizeof(*cmdline));
+	if (!cmdline) {
+		perror("Cannot parse arguments");
+		return 1;
+	}
+	for (i = 0; i < strings->len; i++) {
+		cmdline[i].name = ((const char *)strings->data +
+				   i * ETH_GSTRING_LEN);
+		cmdline[i].type = CMDL_FLAG;
+		cmdline[i].wanted_val = &wanted_flags;
+		cmdline[i].flag_val = 1U << i;
+		cmdline[i].seen_val = &seen_flags;
+	}
+	parse_generic_cmdline(ctx, &any_changed, cmdline, strings->len);
+
+	flags.cmd = ETHTOOL_GPFLAGS;
+	if (send_ioctl(ctx, &flags)) {
+		perror("Cannot get private flags");
+		return 1;
+	}
+
+	flags.cmd = ETHTOOL_SPFLAGS;
+	flags.data = (flags.data & ~seen_flags) | wanted_flags;
+	if (send_ioctl(ctx, &flags)) {
+		perror("Cannot set private flags");
+		return 1;
+	}
+
+	return 0;
+}
+
 int send_ioctl(struct cmd_context *ctx, void *cmd)
 {
 #ifndef TEST_ETHTOOL
@@ -3156,6 +3254,9 @@ static const struct option {
 	  "               [ tx N ]\n"
 	  "               [ other N ]\n"
 	  "               [ combined N ]\n" },
+	{ "--show-priv-flags" , 1, do_gprivflags, "Query private flags" },
+	{ "--set-priv-flags", 1, do_sprivflags, "Set private flags",
+	  "		FLAG on|off ...\n" },
 	{ "-h|--help", 0, show_usage, "Show this help" },
 	{ "--version", 0, do_version, "Show version number" },
 	{}
diff --git a/test-cmdline.c b/test-cmdline.c
index 7dd3b7c..56a26d8 100644
--- a/test-cmdline.c
+++ b/test-cmdline.c
@@ -205,6 +205,10 @@ static struct test_case {
 	{ 1, "--set-channels devname rx" },
 	{ 0, "-L devname" },
 	{ 1, "-L" },
+	{ 0, "--show-priv-flags devname" },
+	{ 1, "--show-priv-flags devname foo" },
+	{ 1, "--show-priv-flags" },
+	/* can't test --set-priv-flags yet */
 	{ 0, "-h" },
 	{ 0, "--help" },
 	{ 0, "--version" },
-- 
1.7.4.4


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
