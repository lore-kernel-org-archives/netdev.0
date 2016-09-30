From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH 4/7] ethtool: fix leakage of defs resources in do_sfeatures
Date: Fri, 30 Sep 2016 15:56:18 -0400
Message-ID: <1475265381-28937-5-git-send-email-linville@tuxdriver.com>
References: <1475265381-28937-1-git-send-email-linville@tuxdriver.com>
Cc: "John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38661 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751866AbcI3UAX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 16:00:23 -0400
In-Reply-To: <1475265381-28937-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Coverity issue: 1363123
Fixes: 6042804cf6ecc ("Change -k/-K options to use ETHTOOL_{G,S}FEATURES")

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 ethtool.c | 41 ++++++++++++++++++++++++++++-------------
 1 file changed, 28 insertions(+), 13 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 09486615a5bb..2fd3393ca5f6 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -2253,7 +2253,7 @@ static int do_sfeatures(struct cmd_context *ctx)
 	struct cmdline_info *cmdline_features;
 	struct feature_state *old_state, *new_state;
 	struct ethtool_value eval;
-	int err;
+	int err, rc;
 	int i, j;
 
 	defs = get_feature_defs(ctx);
@@ -2267,7 +2267,8 @@ static int do_sfeatures(struct cmd_context *ctx)
 				   sizeof(efeatures->features[0]));
 		if (!efeatures) {
 			perror("Cannot parse arguments");
-			return 1;
+			rc = 1;
+			goto err;
 		}
 		efeatures->cmd = ETHTOOL_SFEATURES;
 		efeatures->size = FEATURE_BITS_TO_BLOCKS(defs->n_features);
@@ -2285,7 +2286,8 @@ static int do_sfeatures(struct cmd_context *ctx)
 				  sizeof(cmdline_features[0]));
 	if (!cmdline_features) {
 		perror("Cannot parse arguments");
-		return 1;
+		rc = 1;
+		goto err;
 	}
 	for (i = 0; i < ARRAY_SIZE(off_flag_def); i++)
 		flag_to_cmdline_info(off_flag_def[i].short_name,
@@ -2304,12 +2306,15 @@ static int do_sfeatures(struct cmd_context *ctx)
 
 	if (!any_changed) {
 		fprintf(stdout, "no features changed\n");
-		return 0;
+		rc = 0;
+		goto err;
 	}
 
 	old_state = get_features(ctx, defs);
-	if (!old_state)
-		return 1;
+	if (!old_state) {
+		rc = 1;
+		goto err;
+	}
 
 	if (efeatures) {
 		/* For each offload that the user specified, update any
@@ -2353,7 +2358,8 @@ static int do_sfeatures(struct cmd_context *ctx)
 		err = send_ioctl(ctx, efeatures);
 		if (err < 0) {
 			perror("Cannot set device feature settings");
-			return 1;
+			rc = 1;
+			goto err;
 		}
 	} else {
 		for (i = 0; i < ARRAY_SIZE(off_flag_def); i++) {
@@ -2368,7 +2374,8 @@ static int do_sfeatures(struct cmd_context *ctx)
 					fprintf(stderr,
 						"Cannot set device %s settings: %m\n",
 						off_flag_def[i].long_name);
-					return 1;
+					rc = 1;
+					goto err;
 				}
 			}
 		}
@@ -2382,15 +2389,18 @@ static int do_sfeatures(struct cmd_context *ctx)
 			err = send_ioctl(ctx, &eval);
 			if (err) {
 				perror("Cannot set device flag settings");
-				return 92;
+				rc = 92;
+				goto err;
 			}
 		}
 	}
 
 	/* Compare new state with requested state */
 	new_state = get_features(ctx, defs);
-	if (!new_state)
-		return 1;
+	if (!new_state) {
+		rc = 1;
+		goto err;
+	}
 	any_changed = new_state->off_flags != old_state->off_flags;
 	any_mismatch = (new_state->off_flags !=
 			((old_state->off_flags & ~off_flags_mask) |
@@ -2409,13 +2419,18 @@ static int do_sfeatures(struct cmd_context *ctx)
 		if (!any_changed) {
 			fprintf(stderr,
 				"Could not change any device features\n");
-			return 1;
+			rc = 1;
+			goto err;
 		}
 		printf("Actual changes:\n");
 		dump_features(defs, new_state, old_state);
 	}
 
-	return 0;
+	rc = 0;
+
+err:
+	free(defs);
+	return rc;
 }
 
 static struct ethtool_link_usettings *
-- 
2.7.4
