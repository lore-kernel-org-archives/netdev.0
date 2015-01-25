From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH ethtool 3/5] ethtool: Return bad status when send_ioctl fails
Date: Sun, 25 Jan 2015 15:51:21 +0200
Message-ID: <1422193883-30504-4-git-send-email-amirv@mellanox.com>
References: <1422193883-30504-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	Eyal Grossman <eyalgr@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:55349 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753868AbbAYNvy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Jan 2015 08:51:54 -0500
In-Reply-To: <1422193883-30504-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Grossman <eyalgr@mellanox.com>

Added to ethtool return code(rc != 0) when an error occurs after send_ioctl has fails.

Signed-off-by: Eyal Grossman <eyalgr@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 ethtool.c | 18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 7b873d3..8d53a53 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -2352,6 +2352,7 @@ static int do_sset(struct cmd_context *ctx)
 	char **argp = ctx->argp;
 	int i;
 	int err;
+	int status = 0;
 
 	for (i = 0; i < ARRAY_SIZE(flags_msglvl); i++)
 		flag_to_cmdline_info(flags_msglvl[i].name,
@@ -2523,6 +2524,7 @@ static int do_sset(struct cmd_context *ctx)
 		err = send_ioctl(ctx, &ecmd);
 		if (err < 0) {
 			perror("Cannot get current device settings");
+			status += err;
 		} else {
 			/* Change everything the user specified. */
 			if (speed_wanted != -1)
@@ -2593,8 +2595,10 @@ static int do_sset(struct cmd_context *ctx)
 			/* Try to perform the update. */
 			ecmd.cmd = ETHTOOL_SSET;
 			err = send_ioctl(ctx, &ecmd);
-			if (err < 0)
+			if (err < 0) {
 				perror("Cannot set new settings");
+				status += err;
+			}
 		}
 		if (err < 0) {
 			if (speed_wanted != -1)
@@ -2621,6 +2625,7 @@ static int do_sset(struct cmd_context *ctx)
 		err = send_ioctl(ctx, &wol);
 		if (err < 0) {
 			perror("Cannot get current wake-on-lan settings");
+			status += err;
 		} else {
 			/* Change everything the user specified. */
 			if (wol_change) {
@@ -2636,8 +2641,10 @@ static int do_sset(struct cmd_context *ctx)
 			/* Try to perform the update. */
 			wol.cmd = ETHTOOL_SWOL;
 			err = send_ioctl(ctx, &wol);
-			if (err < 0)
+			if (err < 0) {
 				perror("Cannot set new wake-on-lan settings");
+				status += err;
+			}
 		}
 		if (err < 0) {
 			if (wol_change)
@@ -2654,17 +2661,20 @@ static int do_sset(struct cmd_context *ctx)
 		err = send_ioctl(ctx, &edata);
 		if (err < 0) {
 			perror("Cannot get msglvl");
+			status += err;
 		} else {
 			edata.cmd = ETHTOOL_SMSGLVL;
 			edata.data = ((edata.data & ~msglvl_mask) |
 				      msglvl_wanted);
 			err = send_ioctl(ctx, &edata);
-			if (err < 0)
+			if (err < 0) {
 				perror("Cannot set new msglvl");
+				status += err;
+			}
 		}
 	}
 
-	return 0;
+	return status;
 }
 
 static int do_gregs(struct cmd_context *ctx)
-- 
1.9.3
