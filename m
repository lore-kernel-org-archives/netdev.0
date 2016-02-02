From: Jacob Keller <jacob.e.keller@intel.com>
Subject: [PATCH] ethtool: add support for dynamic mode in {SG}RXFH commands
Date: Tue,  2 Feb 2016 15:22:08 -0800
Message-ID: <1454455328-706-4-git-send-email-jacob.e.keller@intel.com>
References: <1454455328-706-1-git-send-email-jacob.e.keller@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:60506 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753786AbcBBXWW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 18:22:22 -0500
In-Reply-To: <1454455328-706-1-git-send-email-jacob.e.keller@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
---
 ethtool-copy.h |  8 +++++++-
 ethtool.c      | 36 +++++++++++++++++++++++++++++++++++-
 2 files changed, 42 insertions(+), 2 deletions(-)

diff --git a/ethtool-copy.h b/ethtool-copy.h
index d23ffc4c38b4..620dcea06d25 100644
--- a/ethtool-copy.h
+++ b/ethtool-copy.h
@@ -890,6 +890,10 @@ struct ethtool_rxfh_indir {
  *	hardware hash key.
  * @hfunc: Defines the current RSS hash function used by HW (or to be set to).
  *	Valid values are one of the %ETH_RSS_HASH_*.
+ * @dynamic: Indicate whether the device driver may use dynamic RSS settings
+ *	which change due to various run time factors, such as number of
+ *	queues. When false driver must attempt to preserve RSS settings when
+ *	possible. When true driver may override any requested RSS settings.
  * @rsvd:	Reserved for future extensions.
  * @rss_config: RX ring/queue index for each hash value i.e., indirection table
  *	of @indir_size __u32 elements, followed by hash key of @key_size
@@ -900,6 +904,7 @@ struct ethtool_rxfh_indir {
  * %ETH_RXFH_INDIR_NO_CHANGE means that indir table setting is not requested
  * and a @indir_size of zero means the indir table should be reset to default
  * values. An hfunc of zero means that hash function setting is not requested.
+ * If dynamic is true, driver may ignore any other settings requested.
  */
 struct ethtool_rxfh {
 	__u32   cmd;
@@ -907,7 +912,8 @@ struct ethtool_rxfh {
 	__u32   indir_size;
 	__u32   key_size;
 	__u8	hfunc;
-	__u8	rsvd8[3];
+	__u8	dynamic;
+	__u8	rsvd8[2];
 	__u32	rsvd32;
 	__u32   rss_config[0];
 };
diff --git a/ethtool.c b/ethtool.c
index 92c40b823f2c..29b9279b6b1c 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -917,6 +917,19 @@ static int convert_string_to_hashkey(char *rss_hkey, u32 key_size,
 	return 2;
 }
 
+static u8 parse_dynamic(const char *rss_dynamic, u8 *dynamic)
+{
+	if (!strcmp(rss_dynamic, "on")) {
+		*dynamic = 1;
+		return 0;
+	} else if (!strcmp(rss_dynamic, "off")) {
+		*dynamic = 0;
+		return 0;
+	} else {
+		return 2;
+	}
+}
+
 static int parse_hkey(char **rss_hkey, u32 key_size,
 		      const char *rss_hkey_string)
 {
@@ -3213,6 +3226,11 @@ static int do_grxfh(struct cmd_context *ctx)
 	indir_bytes = rss->indir_size * sizeof(rss->rss_config[0]);
 	hkey = ((char *)rss->rss_config + indir_bytes);
 
+	if (rss->dynamic)
+		printf("Dynamic mode enabled\n");
+	else
+		printf("Static mode enabled\n");
+
 	printf("RSS hash key:\n");
 	if (!rss->key_size)
 		printf("Operation not supported\n");
@@ -3326,11 +3344,13 @@ static int do_srxfh(struct cmd_context *ctx)
 	int rxfhindir_equal = 0;
 	char **rxfhindir_weight = NULL;
 	char *rxfhindir_key = NULL;
+	char *rxfh_dynamic = NULL;
 	char *hkey = NULL;
 	int err = 0;
 	u32 arg_num = 0, indir_bytes = 0;
 	u32 entry_size = sizeof(rss_head.rss_config[0]);
 	u32 num_weights = 0;
+	u8 dynamic = 0;
 
 	if (ctx->argc < 2)
 		exit_bad_args();
@@ -3357,6 +3377,12 @@ static int do_srxfh(struct cmd_context *ctx)
 			if (!rxfhindir_key)
 				exit_bad_args();
 			++arg_num;
+		} else if (!strcmp(ctx->argp[arg_num], "dynamic")) {
+			++arg_num;
+			rxfh_dynamic = ctx->argp[arg_num];
+			if (!rxfhindir_key)
+				exit_bad_args();
+			++arg_num;
 		} else {
 			exit_bad_args();
 		}
@@ -3392,6 +3418,12 @@ static int do_srxfh(struct cmd_context *ctx)
 			return err;
 	}
 
+	if (rxfh_dynamic) {
+		err = parse_dynamic(rxfh_dynamic, &dynamic);
+		if (err)
+			return err;
+	}
+
 	if (rxfhindir_equal || rxfhindir_weight)
 		indir_bytes = rss_head.indir_size * entry_size;
 
@@ -3403,6 +3435,7 @@ static int do_srxfh(struct cmd_context *ctx)
 	rss->cmd = ETHTOOL_SRSSH;
 	rss->indir_size = rss_head.indir_size;
 	rss->key_size = rss_head.key_size;
+	rss->dynamic = dynamic;
 
 	if (fill_indir_table(&rss->indir_size, rss->rss_config, rxfhindir_equal,
 			     rxfhindir_weight, num_weights)) {
@@ -4112,7 +4145,8 @@ static const struct option {
 	{ "-X|--set-rxfh-indir|--rxfh", 1, do_srxfh,
 	  "Set Rx flow hash indirection and/or hash key",
 	  "		[ equal N | weight W0 W1 ... ]\n"
-	  "		[ hkey %x:%x:%x:%x:%x:.... ]\n" },
+	  "		[ hkey %x:%x:%x:%x:%x:.... ]\n"
+	  "		[ dynamic on|off ]\n" },
 	{ "-f|--flash", 1, do_flash,
 	  "Flash firmware image from the specified file to a region on the device",
 	  "               FILENAME [ REGION-NUMBER-TO-FLASH ]\n" },
-- 
2.6.3.505.g5cc1fd1
