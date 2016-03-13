From: Ben Hutchings <ben@decadent.org.uk>
Subject: [PATCH ethtool 2/2] Refactor do_gstats() and do_gphystats() to avoid
 code duplication
Date: Sun, 13 Mar 2016 16:01:49 +0000
Message-ID: <20160313160149.GC21187@decadent.org.uk>
References: <1450871911-19509-3-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Lunn <andrew@lunn.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:40726 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752961AbcCMQBv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 12:01:51 -0400
Content-Disposition: inline
In-Reply-To: <1450871911-19509-3-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new do_gphystats() function is almost exactly the same as
do_gstats(), which is silly.

* Add parameters to do_gstats() for the command number, string set
  number and heading
* Introduce do_gnicstats() as a wrapper for do_gstats() that does
  what do_gstats() used to
* Change do_gphystats() into a wrapper for do_gstats()

Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 ethtool.c | 71 +++++++++++----------------------------------------------------
 1 file changed, 12 insertions(+), 59 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 1c988f7d8a9d..4f69a825849a 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -2937,7 +2937,8 @@ static int do_phys_id(struct cmd_context *ctx)
 	return err;
 }
 
-static int do_gstats(struct cmd_context *ctx)
+static int do_gstats(struct cmd_context *ctx, int cmd, int stringset,
+		    const char *name)
 {
 	struct ethtool_gstrings *strings;
 	struct ethtool_stats *stats;
@@ -2947,7 +2948,7 @@ static int do_gstats(struct cmd_context *ctx)
 	if (ctx->argc != 0)
 		exit_bad_args();
 
-	strings = get_stringset(ctx, ETH_SS_STATS,
+	strings = get_stringset(ctx, stringset,
 				offsetof(struct ethtool_drvinfo, n_stats),
 				0);
 	if (!strings) {
@@ -2971,7 +2972,7 @@ static int do_gstats(struct cmd_context *ctx)
 		return 95;
 	}
 
-	stats->cmd = ETHTOOL_GSTATS;
+	stats->cmd = cmd;
 	stats->n_stats = n_stats;
 	err = send_ioctl(ctx, stats);
 	if (err < 0) {
@@ -2982,7 +2983,7 @@ static int do_gstats(struct cmd_context *ctx)
 	}
 
 	/* todo - pretty-print the strings per-driver */
-	fprintf(stdout, "NIC statistics:\n");
+	fprintf(stdout, "%s statistics:\n", name);
 	for (i = 0; i < n_stats; i++) {
 		fprintf(stdout, "     %.*s: %llu\n",
 			ETH_GSTRING_LEN,
@@ -2995,62 +2996,14 @@ static int do_gstats(struct cmd_context *ctx)
 	return 0;
 }
 
-static int do_gphystats(struct cmd_context *ctx)
+static int do_gnicstats(struct cmd_context *ctx)
 {
-	struct ethtool_gstrings *strings;
-	struct ethtool_stats *stats;
-	unsigned int n_stats, sz_stats, i;
-	int err;
-
-	if (ctx->argc != 0)
-		exit_bad_args();
-
-	strings = get_stringset(ctx, ETH_SS_PHY_STATS,
-				offsetof(struct ethtool_drvinfo, n_stats),
-				0);
-	if (!strings) {
-		perror("Cannot get stats strings information");
-		return 96;
-	}
-
-	n_stats = strings->len;
-	if (n_stats < 1) {
-		fprintf(stderr, "no stats available\n");
-		free(strings);
-		return 94;
-	}
-
-	sz_stats = n_stats * sizeof(u64);
-
-	stats = calloc(1, sz_stats + sizeof(struct ethtool_stats));
-	if (!stats) {
-		fprintf(stderr, "no memory available\n");
-		free(strings);
-		return 95;
-	}
-
-	stats->cmd = ETHTOOL_GPHYSTATS;
-	stats->n_stats = n_stats;
-	err = send_ioctl(ctx, stats);
-	if (err < 0) {
-		perror("Cannot get stats information");
-		free(strings);
-		free(stats);
-		return 97;
-	}
-
-	/* todo - pretty-print the strings per-driver */
-	fprintf(stdout, "PHY statistics:\n");
-	for (i = 0; i < n_stats; i++) {
-		fprintf(stdout, "     %.*s: %llu\n",
-			ETH_GSTRING_LEN,
-			&strings->data[i * ETH_GSTRING_LEN],
-			stats->data[i]);
-	}
-	free(strings);
-	free(stats);
+	return do_gstats(ctx, ETHTOOL_GSTATS, ETH_SS_STATS, "NIC");
+}
 
-	return 0;
+static int do_gphystats(struct cmd_context *ctx)
+{
+	return do_gstats(ctx, ETHTOOL_GPHYSTATS, ETH_SS_PHY_STATS, "PHY");
 }
 
 static int do_srxntuple(struct cmd_context *ctx,
@@ -4135,7 +4088,7 @@ static const struct option {
 	  "               [ TIME-IN-SECONDS ]\n" },
 	{ "-t|--test", 1, do_test, "Execute adapter self test",
 	  "               [ online | offline | external_lb ]\n" },
-	{ "-S|--statistics", 1, do_gstats, "Show adapter statistics" },
+	{ "-S|--statistics", 1, do_gnicstats, "Show adapter statistics" },
 	{ "--phy-statistics", 1, do_gphystats,
 	  "Show phy statistics" },
 	{ "-n|-u|--show-nfc|--show-ntuple", 1, do_grxclass,
