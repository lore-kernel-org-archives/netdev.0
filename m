From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH ethtool] ethtool.c: fix memory leaks
Date: Fri, 18 Mar 2016 13:24:15 +0100
Message-ID: <1458303855-4976-1-git-send-email-ivecera@redhat.com>
Cc: bwh@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44816 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753653AbcCRMYR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Mar 2016 08:24:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Memory allocated at several places is not appropriately freed.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 ethtool.c | 60 +++++++++++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 45 insertions(+), 15 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 0cd0d4f..ca0bf28 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -2065,10 +2065,14 @@ static int do_gfeatures(struct cmd_context *ctx)
 	features = get_features(ctx, defs);
 	if (!features) {
 		fprintf(stdout, "no feature info available\n");
+		free(defs);
 		return 1;
 	}
 
 	dump_features(defs, features, NULL);
+
+	free(features);
+	free(defs);
 	return 0;
 }
 
@@ -2078,11 +2082,11 @@ static int do_sfeatures(struct cmd_context *ctx)
 	int any_changed = 0, any_mismatch = 0;
 	u32 off_flags_wanted = 0;
 	u32 off_flags_mask = 0;
-	struct ethtool_sfeatures *efeatures;
+	struct ethtool_sfeatures *efeatures = NULL;
 	struct cmdline_info *cmdline_features;
-	struct feature_state *old_state, *new_state;
+	struct feature_state *old_state = NULL, *new_state = NULL;
 	struct ethtool_value eval;
-	int err;
+	int err, retval = 1;
 	int i, j;
 
 	defs = get_feature_defs(ctx);
@@ -2096,7 +2100,7 @@ static int do_sfeatures(struct cmd_context *ctx)
 				   sizeof(efeatures->features[0]));
 		if (!efeatures) {
 			perror("Cannot parse arguments");
-			return 1;
+			goto finish;
 		}
 		efeatures->cmd = ETHTOOL_SFEATURES;
 		efeatures->size = FEATURE_BITS_TO_BLOCKS(defs->n_features);
@@ -2114,7 +2118,7 @@ static int do_sfeatures(struct cmd_context *ctx)
 				  sizeof(cmdline_features[0]));
 	if (!cmdline_features) {
 		perror("Cannot parse arguments");
-		return 1;
+		goto finish;
 	}
 	for (i = 0; i < ARRAY_SIZE(off_flag_def); i++)
 		flag_to_cmdline_info(off_flag_def[i].short_name,
@@ -2133,12 +2137,13 @@ static int do_sfeatures(struct cmd_context *ctx)
 
 	if (!any_changed) {
 		fprintf(stdout, "no features changed\n");
-		return 0;
+		retval = 0;
+		goto finish;
 	}
 
 	old_state = get_features(ctx, defs);
 	if (!old_state)
-		return 1;
+		goto finish;
 
 	if (efeatures) {
 		/* For each offload that the user specified, update any
@@ -2182,7 +2187,7 @@ static int do_sfeatures(struct cmd_context *ctx)
 		err = send_ioctl(ctx, efeatures);
 		if (err < 0) {
 			perror("Cannot set device feature settings");
-			return 1;
+			goto finish;
 		}
 	} else {
 		for (i = 0; i < ARRAY_SIZE(off_flag_def); i++) {
@@ -2197,7 +2202,7 @@ static int do_sfeatures(struct cmd_context *ctx)
 					fprintf(stderr,
 						"Cannot set device %s settings: %m\n",
 						off_flag_def[i].long_name);
-					return 1;
+					goto finish;
 				}
 			}
 		}
@@ -2211,7 +2216,8 @@ static int do_sfeatures(struct cmd_context *ctx)
 			err = send_ioctl(ctx, &eval);
 			if (err) {
 				perror("Cannot set device flag settings");
-				return 92;
+				retval = 92;
+				goto finish;
 			}
 		}
 	}
@@ -2219,7 +2225,7 @@ static int do_sfeatures(struct cmd_context *ctx)
 	/* Compare new state with requested state */
 	new_state = get_features(ctx, defs);
 	if (!new_state)
-		return 1;
+		goto finish;
 	any_changed = new_state->off_flags != old_state->off_flags;
 	any_mismatch = (new_state->off_flags !=
 			((old_state->off_flags & ~off_flags_mask) |
@@ -2238,13 +2244,19 @@ static int do_sfeatures(struct cmd_context *ctx)
 		if (!any_changed) {
 			fprintf(stderr,
 				"Could not change any device features\n");
-			return 1;
+			goto finish;
 		}
 		printf("Actual changes:\n");
 		dump_features(defs, new_state, old_state);
 	}
 
-	return 0;
+	retval = 0;
+finish:
+	free(new_state);
+	free(old_state);
+	free(efeatures);
+	free(defs);
+	return retval;
 }
 
 static int do_gset(struct cmd_context *ctx)
@@ -2705,8 +2717,18 @@ static int do_gregs(struct cmd_context *ctx)
 			return 75;
 		}
 
-		regs = realloc(regs, sizeof(*regs) + st.st_size);
-		regs->len = st.st_size;
+		if (regs->len != st.st_size) {
+			struct ethtool_regs *new_regs;
+			new_regs = realloc(regs, sizeof(*regs) + st.st_size);
+			if (!new_regs) {
+				perror("Cannot allocate memory for register "
+				       "dump");
+				free(regs);
+				return 73;
+			}
+			regs = new_regs;
+			regs->len = st.st_size;
+		}
 		nread = fread(regs->data, regs->len, 1, f);
 		fclose(f);
 		if (nread != 1) {
@@ -3775,6 +3797,7 @@ static int do_gprivflags(struct cmd_context *ctx)
 	}
 	if (strings->len == 0) {
 		fprintf(stderr, "No private flags defined\n");
+		free(strings);
 		return 1;
 	}
 	if (strings->len > 32) {
@@ -3786,6 +3809,7 @@ static int do_gprivflags(struct cmd_context *ctx)
 	flags.cmd = ETHTOOL_GPFLAGS;
 	if (send_ioctl(ctx, &flags)) {
 		perror("Cannot get private flags");
+		free(strings);
 		return 1;
 	}
 
@@ -3804,6 +3828,7 @@ static int do_gprivflags(struct cmd_context *ctx)
 		       (const char *)strings->data + i * ETH_GSTRING_LEN,
 		       (flags.data & (1U << i)) ? "on" : "off");
 
+	free(strings);
 	return 0;
 }
 
@@ -3825,6 +3850,7 @@ static int do_sprivflags(struct cmd_context *ctx)
 	}
 	if (strings->len == 0) {
 		fprintf(stderr, "No private flags defined\n");
+		free(strings);
 		return 1;
 	}
 	if (strings->len > 32) {
@@ -3836,6 +3862,7 @@ static int do_sprivflags(struct cmd_context *ctx)
 	cmdline = calloc(strings->len, sizeof(*cmdline));
 	if (!cmdline) {
 		perror("Cannot parse arguments");
+		free(strings);
 		return 1;
 	}
 	for (i = 0; i < strings->len; i++) {
@@ -3852,6 +3879,7 @@ static int do_sprivflags(struct cmd_context *ctx)
 	flags.cmd = ETHTOOL_GPFLAGS;
 	if (send_ioctl(ctx, &flags)) {
 		perror("Cannot get private flags");
+		free(strings);
 		return 1;
 	}
 
@@ -3859,9 +3887,11 @@ static int do_sprivflags(struct cmd_context *ctx)
 	flags.data = (flags.data & ~seen_flags) | wanted_flags;
 	if (send_ioctl(ctx, &flags)) {
 		perror("Cannot set private flags");
+		free(strings);
 		return 1;
 	}
 
+	free(strings);
 	return 0;
 }
 
-- 
2.7.3
