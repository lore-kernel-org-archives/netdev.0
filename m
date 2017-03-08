From: Gal Pressman <galp@mellanox.com>
Subject: [PATCH ethtool] ethtool: Support for configurable RSS hash function
Date: Wed,  8 Mar 2017 16:03:51 +0200
Message-ID: <1488981831-19376-1-git-send-email-galp@mellanox.com>
Cc: Gal Pressman <galp@mellanox.com>, Eyal Perry <eyalpe@mellanox.com>
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34133 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753425AbdCHOLj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 09:11:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This ethtool patch adds support to set and get the current RSS hash
function for the device through the new hfunc mask field in the
ethtool_rxfh struct. Kernel supported hash function names are queried
with ETHTOOL_GSTRINGS - each string is corresponding with a bit in hfunc
mask according to its index in the string-set.

Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Gal Pressman <galp@mellanox.com>
Reviewed-by: Saeed Mahameed <saeedm@mellanox.com>
---
 ethtool.8.in |  6 ++++++
 ethtool.c    | 66 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 69 insertions(+), 3 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 5c36c06385f6..2cbe3f158b3e 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -301,6 +301,8 @@ ethtool \- query or control network driver and hardware settings
 .BI weight\  W0
 .IR W1
 .RB ...\ | \ default \ ]
+.RB [ hfunc
+.IR FUNC ]
 .HP
 .B ethtool \-f|\-\-flash
 .I devname file
@@ -865,6 +867,10 @@ Sets RSS hash key of the specified network device. RSS hash key should be of dev
 Hash key format must be in xx:yy:zz:aa:bb:cc format meaning both the nibbles of a byte should be mentioned
 even if a nibble is zero.
 .TP
+.BI hfunc
+Sets RSS hash function of the specified network device.
+List of RSS hash functions which kernel supports is shown as a part of the --show-rxfh command output.
+.TP
 .BI equal\  N
 Sets the receive flow hash indirection table to spread flows evenly
 between the first \fIN\fR receive queues.
diff --git a/ethtool.c b/ethtool.c
index 7af039e26b50..61d5714285f9 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -3640,6 +3640,7 @@ static int do_grxfhindir(struct cmd_context *ctx,
 
 static int do_grxfh(struct cmd_context *ctx)
 {
+	struct ethtool_gstrings *hfuncs = NULL;
 	struct ethtool_rxfh rss_head = {0};
 	struct ethtool_rxnfc ring_count;
 	struct ethtool_rxfh *rss;
@@ -3697,6 +3698,26 @@ static int do_grxfh(struct cmd_context *ctx)
 			printf("%02x:", (u8) hkey[i]);
 	}
 
+	printf("RSS hash function:\n");
+	if (!rss->hfunc) {
+		printf("    Operation not supported\n");
+		goto out;
+	}
+
+	hfuncs = get_stringset(ctx, ETH_SS_RSS_HASH_FUNCS, 0, 1);
+	if (!hfuncs) {
+		perror("Cannot get hash functions names");
+		free(rss);
+		return 1;
+	}
+
+	for (i = 0; i < hfuncs->len; i++)
+		printf("    %s: %s\n",
+		       (const char *)hfuncs->data + i * ETH_GSTRING_LEN,
+		       (rss->hfunc & (1 << i)) ? "on" : "off");
+
+out:
+	free(hfuncs);
 	free(rss);
 	return 0;
 }
@@ -3800,11 +3821,16 @@ static int do_srxfh(struct cmd_context *ctx)
 	struct ethtool_rxfh *rss;
 	struct ethtool_rxnfc ring_count;
 	int rxfhindir_equal = 0, rxfhindir_default = 0;
+	struct ethtool_gstrings *hfuncs = NULL;
 	char **rxfhindir_weight = NULL;
 	char *rxfhindir_key = NULL;
+	char *req_hfunc_name = NULL;
+	char *hfunc_name = NULL;
 	char *hkey = NULL;
 	int err = 0;
+	int i;
 	u32 arg_num = 0, indir_bytes = 0;
+	u32 req_hfunc = 0;
 	u32 entry_size = sizeof(rss_head.rss_config[0]);
 	u32 num_weights = 0;
 
@@ -3836,6 +3862,12 @@ static int do_srxfh(struct cmd_context *ctx)
 		} else if (!strcmp(ctx->argp[arg_num], "default")) {
 			++arg_num;
 			rxfhindir_default = 1;
+		} else if (!strcmp(ctx->argp[arg_num], "hfunc")) {
+			++arg_num;
+			req_hfunc_name = ctx->argp[arg_num];
+			if (!req_hfunc_name)
+				exit_bad_args();
+			++arg_num;
 		} else {
 			exit_bad_args();
 		}
@@ -3868,7 +3900,8 @@ static int do_srxfh(struct cmd_context *ctx)
 
 	rss_head.cmd = ETHTOOL_GRSSH;
 	err = send_ioctl(ctx, &rss_head);
-	if (err < 0 && errno == EOPNOTSUPP && !rxfhindir_key) {
+	if (err < 0 && errno == EOPNOTSUPP && !rxfhindir_key &&
+	    !req_hfunc_name) {
 		return do_srxfhindir(ctx, rxfhindir_default, rxfhindir_equal,
 				     rxfhindir_weight, num_weights);
 	} else if (err < 0) {
@@ -3886,14 +3919,39 @@ static int do_srxfh(struct cmd_context *ctx)
 	if (rxfhindir_equal || rxfhindir_weight)
 		indir_bytes = rss_head.indir_size * entry_size;
 
+	if (rss_head.hfunc && req_hfunc_name) {
+		hfuncs = get_stringset(ctx, ETH_SS_RSS_HASH_FUNCS, 0, 1);
+		if (!hfuncs) {
+			perror("Cannot get hash functions names");
+			return 1;
+		}
+
+		for (i = 0; i < hfuncs->len && !req_hfunc ; i++) {
+			hfunc_name = (char *)(hfuncs->data +
+					      i * ETH_GSTRING_LEN);
+			if (!strncmp(hfunc_name, req_hfunc_name,
+				     ETH_GSTRING_LEN))
+				req_hfunc = (u32)1 << i;
+		}
+
+		if (!req_hfunc) {
+			fprintf(stderr,
+				"Unknown hash function: %s\n", req_hfunc_name);
+			free(hfuncs);
+			return 1;
+		}
+	}
+
 	rss = calloc(1, sizeof(*rss) + indir_bytes + rss_head.key_size);
 	if (!rss) {
 		perror("Cannot allocate memory for RX flow hash config");
-		return 1;
+		err = 1;
+		goto free;
 	}
 	rss->cmd = ETHTOOL_SRSSH;
 	rss->indir_size = rss_head.indir_size;
 	rss->key_size = rss_head.key_size;
+	rss->hfunc = req_hfunc;
 
 	if (fill_indir_table(&rss->indir_size, rss->rss_config, rxfhindir_default,
 			     rxfhindir_equal, rxfhindir_weight, num_weights)) {
@@ -3918,6 +3976,7 @@ free:
 		free(hkey);
 
 	free(rss);
+	free(hfuncs);
 	return err;
 }
 
@@ -4790,7 +4849,8 @@ static const struct option {
 	{ "-X|--set-rxfh-indir|--rxfh", 1, do_srxfh,
 	  "Set Rx flow hash indirection and/or hash key",
 	  "		[ equal N | weight W0 W1 ... ]\n"
-	  "		[ hkey %x:%x:%x:%x:%x:.... ]\n" },
+	  "		[ hkey %x:%x:%x:%x:%x:.... ]\n"
+	  "		[ hfunc FUNC ]\n" },
 	{ "-f|--flash", 1, do_flash,
 	  "Flash firmware image from the specified file to a region on the device",
 	  "               FILENAME [ REGION-NUMBER-TO-FLASH ]\n" },
-- 
2.7.4
