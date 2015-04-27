From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net V1] ethtool: Support for configurable RSS hash function
Date: Mon, 27 Apr 2015 14:22:53 +0300
Message-ID: <1430133773-11613-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:47089 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752846AbbD0LXb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Apr 2015 07:23:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Perry <eyalpe@mellanox.com>

This ethtool patch adds support to set and get the current RSS hash
function for the device through through the new hfunc field in the
ethtool_rxfh struct. Kernel supported hash function names are queried
with ETHTOOL_GSTRINGS (value 0 is reserved and skipped).

Although currently no device supports a combination of hash
functions/attributes, this ethtool implementation will support it. Both in the
set and in the get.
The device driver declares the functions and/or attributes that it supports,
and ethtool will show it correctly and enable the user to set those
combinations.
If a combination is not supported - the device driver will fail the operation
and ethtool will print an error message.

Signed-off-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
Changes from V1:
- Fixed some English mistakes
- Fixed the complicated way to write '= req_hfunc;'...
- Better support in combination of hash functions/attributes

 ethtool.8.in |  7 ++++++
 ethtool.c    | 73 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 78 insertions(+), 2 deletions(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index ae56293..0f43b9b 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -297,6 +297,8 @@ ethtool \- query or control network driver and hardware settings
 .BI weight\  W0
 .IR W1
 .RB ...\ ]
+.RB [ hfunc
+.IR FUNC[,FUNC...] ]
 .HP
 .B ethtool \-f|\-\-flash
 .I devname file
@@ -796,6 +798,11 @@ Sets RSS hash key of the specified network device. RSS hash key should be of dev
 Hash key format must be in xx:yy:zz:aa:bb:cc format meaning both the nibbles of a byte should be mentioned
 even if a nibble is zero.
 .TP
+.BI hfunc
+List of RSS hash functions/attributes of the specified network device. A list
+of RSS hash functions and attributes which the device supports is shown as a
+part of the --show-rxfh command output.
+.TP
 .BI equal\  N
 Sets the receive flow hash indirection table to spread flows evenly
 between the first \fIN\fR receive queues.
diff --git a/ethtool.c b/ethtool.c
index 01b13a6..bdf61f7 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -3167,6 +3167,7 @@ static int do_grxfh(struct cmd_context *ctx)
 {
 	struct ethtool_rxfh rss_head = {0};
 	struct ethtool_rxnfc ring_count;
+	struct ethtool_gstrings *hfuncs;
 	struct ethtool_rxfh *rss;
 	u32 i, indir_bytes;
 	char *hkey;
@@ -3222,6 +3223,23 @@ static int do_grxfh(struct cmd_context *ctx)
 			printf("%02x:", (u8) hkey[i]);
 	}
 
+	printf("Supported RSS hash functions: ");
+	if (!rss->hfunc) {
+		printf("    Operation not supported\n");
+		goto out;
+	}
+
+	hfuncs = get_stringset(ctx, ETH_SS_RSS_HASH_FUNCS, 0, 1);
+	for (i = 0; i < hfuncs->len; i++)
+		printf("%s ", (char *)hfuncs->data + i * ETH_GSTRING_LEN);
+	printf("\n");
+
+	printf("Selected RSS hash function: ");
+	for (i = 0; i < hfuncs->len; i++)
+		if (rss->hfunc & (1 << i))
+			printf("%s ", (char *)hfuncs->data + i * ETH_GSTRING_LEN);
+	printf("\n");
+out:
 	free(rss);
 	return 0;
 }
@@ -3316,6 +3334,40 @@ static int do_srxfhindir(struct cmd_context *ctx, int rxfhindir_equal,
 	return 0;
 }
 
+
+static int get_hfunc(struct cmd_context *ctx, char *req_hfunc_names)
+{
+	struct ethtool_gstrings *hfuncs;
+	char *req_hfunc_name;
+	char *saveptr;
+	int i;
+	int ret = 0;
+
+	hfuncs = get_stringset(ctx, ETH_SS_RSS_HASH_FUNCS, 0, 1);
+
+	for (; ; req_hfunc_names = NULL) {
+		req_hfunc_name = strtok_r(req_hfunc_names, ",", &saveptr);
+		if (req_hfunc_name == NULL)
+			break;
+
+		for (i = 0; i < hfuncs->len; i++) {
+			char *hfunc_name = (char *)(hfuncs->data + i *
+						    ETH_GSTRING_LEN);
+			if (!strncmp(hfunc_name, req_hfunc_name, ETH_GSTRING_LEN)) {
+				ret |= 1 << i;
+				break;
+			}
+		}
+
+		if (i == hfuncs->len)
+			fprintf(stderr, "Unknown hash function: %s\n",
+				req_hfunc_name);
+	}
+
+
+	return ret;
+}
+
 static int do_srxfh(struct cmd_context *ctx)
 {
 	struct ethtool_rxfh rss_head = {0};
@@ -3324,9 +3376,11 @@ static int do_srxfh(struct cmd_context *ctx)
 	int rxfhindir_equal = 0;
 	char **rxfhindir_weight = NULL;
 	char *rxfhindir_key = NULL;
+	char *req_hfunc_name = NULL;
 	char *hkey = NULL;
 	int err = 0;
 	u32 arg_num = 0, indir_bytes = 0;
+	int req_hfunc = 0;
 	u32 entry_size = sizeof(rss_head.rss_config[0]);
 	u32 num_weights = 0;
 
@@ -3355,6 +3409,12 @@ static int do_srxfh(struct cmd_context *ctx)
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
@@ -3375,7 +3435,8 @@ static int do_srxfh(struct cmd_context *ctx)
 
 	rss_head.cmd = ETHTOOL_GRSSH;
 	err = send_ioctl(ctx, &rss_head);
-	if (err < 0 && errno == EOPNOTSUPP && !rxfhindir_key) {
+	if (err < 0 && errno == EOPNOTSUPP &&
+	    !rxfhindir_key && !req_hfunc_name) {
 		return do_srxfhindir(ctx, rxfhindir_equal, rxfhindir_weight,
 				     num_weights);
 	} else if (err < 0) {
@@ -3393,6 +3454,12 @@ static int do_srxfh(struct cmd_context *ctx)
 	if (rxfhindir_equal || rxfhindir_weight)
 		indir_bytes = rss_head.indir_size * entry_size;
 
+	if (rss_head.hfunc && req_hfunc_name) {
+		req_hfunc = get_hfunc(ctx, req_hfunc_name);
+		if (!req_hfunc)
+			return 1;
+	}
+
 	rss = calloc(1, sizeof(*rss) + indir_bytes + rss_head.key_size);
 	if (!rss) {
 		perror("Cannot allocate memory for RX flow hash config");
@@ -3401,6 +3468,7 @@ static int do_srxfh(struct cmd_context *ctx)
 	rss->cmd = ETHTOOL_SRSSH;
 	rss->indir_size = rss_head.indir_size;
 	rss->key_size = rss_head.key_size;
+	rss->hfunc = req_hfunc;
 
 	if (fill_indir_table(&rss->indir_size, rss->rss_config, rxfhindir_equal,
 			     rxfhindir_weight, num_weights)) {
@@ -4110,7 +4178,8 @@ static const struct option {
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
