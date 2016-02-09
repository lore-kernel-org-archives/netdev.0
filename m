From: Jacob Keller <jacob.e.keller@intel.com>
Subject: [PATCH v2 4/4] ethtool: support setting default Rx flow indirection table
Date: Mon,  8 Feb 2016 16:05:06 -0800
Message-ID: <1454976306-23523-5-git-send-email-jacob.e.keller@intel.com>
References: <1454976306-23523-1-git-send-email-jacob.e.keller@intel.com>
Cc: Jakub Kicinski <moorray3@wp.pl>,
	David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:21883 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932962AbcBIAFO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2016 19:05:14 -0500
In-Reply-To: <1454976306-23523-1-git-send-email-jacob.e.keller@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
---
 ethtool.8.in |  5 ++++-
 ethtool.c    | 46 ++++++++++++++++++++++++++++++++--------------
 2 files changed, 36 insertions(+), 15 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index eeffa70415b5..b7d56fbe4484 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -296,7 +296,7 @@ ethtool \- query or control network driver and hardware settings
 .IR N \ |
 .BI weight\  W0
 .IR W1
-.RB ...\ ]
+.RB ...\ | \ default \ ]
 .HP
 .B ethtool \-f|\-\-flash
 .I devname file
@@ -805,6 +805,9 @@ Sets the receive flow hash indirection table to spread flows between
 receive queues according to the given weights.  The sum of the weights
 must be non-zero and must not exceed the size of the indirection table.
 .TP
+.BI default
+Sets the receive flow hash indirection table to its default value.
+.TP
 .B \-f \-\-flash
 Write a firmware image to flash or other non-volatile memory on the
 device.
diff --git a/ethtool.c b/ethtool.c
index 92c40b823f2c..c05b50f830a7 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -3228,13 +3228,11 @@ static int do_grxfh(struct cmd_context *ctx)
 	return 0;
 }
 
-static int fill_indir_table(u32 *indir_size, u32 *indir, int rxfhindir_equal,
-			    char **rxfhindir_weight, u32 num_weights)
+static int fill_indir_table(u32 *indir_size, u32 *indir, int rxfhindir_default,
+			    int rxfhindir_equal, char **rxfhindir_weight,
+			    u32 num_weights)
 {
 	u32 i;
-	/*
-	 * "*indir_size == 0" ==> reset indir to default
-	 */
 	if (rxfhindir_equal) {
 		for (i = 0; i < *indir_size; i++)
 			indir[i] = i % rxfhindir_equal;
@@ -3268,6 +3266,9 @@ static int fill_indir_table(u32 *indir_size, u32 *indir, int rxfhindir_equal,
 			}
 			indir[i] = j;
 		}
+	} else if (rxfhindir_default) {
+		/* "*indir_size == 0" ==> reset indir to default */
+		*indir_size = 0;
 	} else {
 		*indir_size = ETH_RXFH_INDIR_NO_CHANGE;
 	}
@@ -3275,8 +3276,9 @@ static int fill_indir_table(u32 *indir_size, u32 *indir, int rxfhindir_equal,
 	return 0;
 }
 
-static int do_srxfhindir(struct cmd_context *ctx, int rxfhindir_equal,
-			 char **rxfhindir_weight, u32 num_weights)
+static int do_srxfhindir(struct cmd_context *ctx, int rxfhindir_default,
+			 int rxfhindir_equal, char **rxfhindir_weight,
+			 u32 num_weights)
 {
 	struct ethtool_rxfh_indir indir_head;
 	struct ethtool_rxfh_indir *indir;
@@ -3301,7 +3303,8 @@ static int do_srxfhindir(struct cmd_context *ctx, int rxfhindir_equal,
 	indir->cmd = ETHTOOL_SRXFHINDIR;
 	indir->size = indir_head.size;
 
-	if (fill_indir_table(&indir->size, indir->ring_index, rxfhindir_equal,
+	if (fill_indir_table(&indir->size, indir->ring_index,
+			     rxfhindir_default, rxfhindir_equal,
 			     rxfhindir_weight, num_weights)) {
 		free(indir);
 		return 1;
@@ -3323,7 +3326,7 @@ static int do_srxfh(struct cmd_context *ctx)
 	struct ethtool_rxfh rss_head = {0};
 	struct ethtool_rxfh *rss;
 	struct ethtool_rxnfc ring_count;
-	int rxfhindir_equal = 0;
+	int rxfhindir_equal = 0, rxfhindir_default = 0;
 	char **rxfhindir_weight = NULL;
 	char *rxfhindir_key = NULL;
 	char *hkey = NULL;
@@ -3332,7 +3335,7 @@ static int do_srxfh(struct cmd_context *ctx)
 	u32 entry_size = sizeof(rss_head.rss_config[0]);
 	u32 num_weights = 0;
 
-	if (ctx->argc < 2)
+	if (ctx->argc < 1)
 		exit_bad_args();
 
 	while (arg_num < ctx->argc) {
@@ -3357,6 +3360,9 @@ static int do_srxfh(struct cmd_context *ctx)
 			if (!rxfhindir_key)
 				exit_bad_args();
 			++arg_num;
+		} else if (!strcmp(ctx->argp[arg_num], "default")) {
+			++arg_num;
+			rxfhindir_default = 1;
 		} else {
 			exit_bad_args();
 		}
@@ -3368,6 +3374,18 @@ static int do_srxfh(struct cmd_context *ctx)
 		return 1;
 	}
 
+	if (rxfhindir_equal && rxfhindir_default) {
+		fprintf(stderr,
+			"Equal and default options are mutually exclusive\n");
+		return 1;
+	}
+
+	if (rxfhindir_weight && rxfhindir_default) {
+		fprintf(stderr,
+			"Weight and default options are mutually exclusive\n");
+		return 1;
+	}
+
 	ring_count.cmd = ETHTOOL_GRXRINGS;
 	err = send_ioctl(ctx, &ring_count);
 	if (err < 0) {
@@ -3378,8 +3396,8 @@ static int do_srxfh(struct cmd_context *ctx)
 	rss_head.cmd = ETHTOOL_GRSSH;
 	err = send_ioctl(ctx, &rss_head);
 	if (err < 0 && errno == EOPNOTSUPP && !rxfhindir_key) {
-		return do_srxfhindir(ctx, rxfhindir_equal, rxfhindir_weight,
-				     num_weights);
+		return do_srxfhindir(ctx, rxfhindir_default, rxfhindir_equal,
+				     rxfhindir_weight, num_weights);
 	} else if (err < 0) {
 		perror("Cannot get RX flow hash indir size and key size");
 		return 1;
@@ -3404,8 +3422,8 @@ static int do_srxfh(struct cmd_context *ctx)
 	rss->indir_size = rss_head.indir_size;
 	rss->key_size = rss_head.key_size;
 
-	if (fill_indir_table(&rss->indir_size, rss->rss_config, rxfhindir_equal,
-			     rxfhindir_weight, num_weights)) {
+	if (fill_indir_table(&rss->indir_size, rss->rss_config, rxfhindir_default,
+			     rxfhindir_equal, rxfhindir_weight, num_weights)) {
 		err = 1;
 		goto free;
 	}
-- 
2.7.0.236.gda096a0.dirty
