From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH ethtool 5/5] ethtool: Support for configurable RSS hash function
Date: Sun, 25 Jan 2015 15:51:23 +0200
Message-ID: <1422193883-30504-6-git-send-email-amirv@mellanox.com>
References: <1422193883-30504-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:55375 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753516AbbAYNwJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Jan 2015 08:52:09 -0500
In-Reply-To: <1422193883-30504-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Perry <eyalpe@mellanox.com>

This ethtool patch adds support to set and get the current RSS hash
function for the device through through the new hfunc mask field in the
ethtool_rxfh struct. Kernel supported hash function names are queried
with ETHTOOL_GSTRINGS - each string is corresponding with a bit in hfunc
mask according to its index in the string-set.

Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 ethtool.8.in |  7 +++++++
 ethtool.c    | 56 +++++++++++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 58 insertions(+), 5 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index ae56293..bdc77e0 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -297,6 +297,8 @@ ethtool \- query or control network driver and hardware settings
 .BI weight\  W0
 .IR W1
 .RB ...\ ]
+.RB [ hfunc
+.IR FUNC ]
 .HP
 .B ethtool \-f|\-\-flash
 .I devname file
@@ -796,6 +798,11 @@ Sets RSS hash key of the specified network device. RSS hash key should be of dev
 Hash key format must be in xx:yy:zz:aa:bb:cc format meaning both the nibbles of a byte should be mentioned
 even if a nibble is zero.
 .TP
+.BI hfunc
+Sets RSS hash function of the specified network device. Requested hash function
+should be supported by the kernel and the device. List of RSS hash functions
+which kernel supports is shown as a part of the --show-rxfh comand output.
+.TP
 .BI equal\  N
 Sets the receive flow hash indirection table to spread flows evenly
 between the first \fIN\fR receive queues.
diff --git a/ethtool.c b/ethtool.c
index c2f4164..c584333 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -3176,10 +3176,11 @@ static int do_grxfh(struct cmd_context *ctx)
 {
 	struct ethtool_rxfh rss_head = {0};
 	struct ethtool_rxnfc ring_count;
+	struct ethtool_gstrings *hfuncs;
 	struct ethtool_rxfh *rss;
 	u32 i, indir_bytes;
 	char *hkey;
-	int err;
+	int err, cur_len, max_len = 0;
 
 	ring_count.cmd = ETHTOOL_GRXRINGS;
 	err = send_ioctl(ctx, &ring_count);
@@ -3231,6 +3232,23 @@ static int do_grxfh(struct cmd_context *ctx)
 			printf("%02x:", (u8) hkey[i]);
 	}
 
+	printf("RSS hash function:\n");
+	if (!rss->hfunc) {
+		printf("    Operation not supported\n");
+		goto out;
+	}
+	hfuncs = get_stringset(ctx, ETH_SS_RSS_HASH_FUNCS, 0, 1);
+	for (i = 0; i < hfuncs->len; i++) {
+		cur_len = strlen((const char *)hfuncs->data +
+				 i * ETH_GSTRING_LEN);
+		if (cur_len > max_len)
+			max_len = cur_len;
+	}
+	for (i = 0; i < hfuncs->len; i++)
+		printf("    %-*s: %s\n", max_len,
+		       (const char *)hfuncs->data + i * ETH_GSTRING_LEN,
+		       (rss->hfunc & (1 << i)) ? "on" : "off");
+out:
 	free(rss);
 	return 0;
 }
@@ -3330,12 +3348,15 @@ static int do_srxfh(struct cmd_context *ctx)
 	struct ethtool_rxfh rss_head = {0};
 	struct ethtool_rxfh *rss;
 	struct ethtool_rxnfc ring_count;
+	struct ethtool_gstrings *hfuncs;
 	int rxfhindir_equal = 0;
 	char **rxfhindir_weight = NULL;
 	char *rxfhindir_key = NULL;
+	char *req_hfunc_name = NULL;
+	char *hfunc_name = NULL;
 	char *hkey = NULL;
-	int err = 0;
-	u32 arg_num = 0, indir_bytes = 0;
+	int i, err = 0;
+	u32 arg_num = 0, indir_bytes = 0, req_hfunc = 0;
 	u32 entry_size = sizeof(rss_head.rss_config[0]);
 	u32 num_weights = 0;
 
@@ -3364,6 +3385,12 @@ static int do_srxfh(struct cmd_context *ctx)
 			if (!rxfhindir_key)
 				exit_bad_args();
 			++arg_num;
+		} else if (!strcmp(ctx->argp[arg_num], "hfunc")) {
+			++arg_num;
+			req_hfunc_name = ctx->argp[arg_num];
+			if (!req_hfunc_name)
+				exit_bad_args();
+			++arg_num;
 		} else {
 			exit_bad_args();
 		}
@@ -3384,7 +3411,8 @@ static int do_srxfh(struct cmd_context *ctx)
 
 	rss_head.cmd = ETHTOOL_GRSSH;
 	err = send_ioctl(ctx, &rss_head);
-	if (err < 0 && errno == EOPNOTSUPP && !rxfhindir_key) {
+	if (err < 0 && errno == EOPNOTSUPP &&
+	    !rxfhindir_key && !req_hfunc_name) {
 		return do_srxfhindir(ctx, rxfhindir_equal, rxfhindir_weight,
 				     num_weights);
 	} else if (err < 0) {
@@ -3402,6 +3430,22 @@ static int do_srxfh(struct cmd_context *ctx)
 	if (rxfhindir_equal || rxfhindir_weight)
 		indir_bytes = rss_head.indir_size * entry_size;
 
+	if (rss_head.hfunc && req_hfunc_name) {
+		hfuncs = get_stringset(ctx, ETH_SS_RSS_HASH_FUNCS, 0, 1);
+		for (i = 0; i < hfuncs->len && !req_hfunc ; i++) {
+			hfunc_name = (char *)(hfuncs->data +
+					      i * ETH_GSTRING_LEN);
+			if (!strncmp(hfunc_name, req_hfunc_name,
+				     ETH_GSTRING_LEN))
+				req_hfunc = (u32)1 << i;
+		}
+		if (!req_hfunc) {
+			fprintf(stderr,
+				"Unknown hash function: %s\n", req_hfunc_name);
+			return 1;
+		}
+	}
+
 	rss = calloc(1, sizeof(*rss) + indir_bytes + rss_head.key_size);
 	if (!rss) {
 		perror("Cannot allocate memory for RX flow hash config");
@@ -3410,6 +3454,7 @@ static int do_srxfh(struct cmd_context *ctx)
 	rss->cmd = ETHTOOL_SRSSH;
 	rss->indir_size = rss_head.indir_size;
 	rss->key_size = rss_head.key_size;
+	rss->hfunc = req_hfunc ? req_hfunc : 0;
 
 	if (fill_indir_table(&rss->indir_size, rss->rss_config, rxfhindir_equal,
 			     rxfhindir_weight, num_weights)) {
@@ -4119,7 +4164,8 @@ static const struct option {
 	{ "-X|--set-rxfh-indir|--rxfh", 1, do_srxfh,
 	  "Set Rx flow hash indirection and/or hash key",
 	  "		[ equal N | weight W0 W1 ... ]\n"
-	  "		[ hkey %x:%x:%x:%x:%x:.... ]\n" },
+	  "		[ hkey %x:%x:%x:%x:%x:.... ]\n"
+	  "		[ hfunc FUNC ]\n"},
 	{ "-f|--flash", 1, do_flash,
 	  "Flash firmware image from the specified file to a region on the device",
 	  "               FILENAME [ REGION-NUMBER-TO-FLASH ]\n" },
-- 
1.9.3
