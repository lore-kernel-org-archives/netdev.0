From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH 2/7] ethtool: avoid resource leak of strings in do_gprivflags
Date: Fri, 30 Sep 2016 15:56:16 -0400
Message-ID: <1475265381-28937-3-git-send-email-linville@tuxdriver.com>
References: <1475265381-28937-1-git-send-email-linville@tuxdriver.com>
Cc: "John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38658 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751821AbcI3UAU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 16:00:20 -0400
In-Reply-To: <1475265381-28937-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Coverity issue: 1363119
Fixes: e1ee596326ae ("Add support for querying and setting private flags")

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 ethtool.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index aa3ef5ed2f75..0885a61097ad 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -4205,7 +4205,7 @@ static int do_gprivflags(struct cmd_context *ctx)
 	struct ethtool_gstrings *strings;
 	struct ethtool_value flags;
 	unsigned int i;
-	int max_len = 0, cur_len;
+	int max_len = 0, cur_len, rc;
 
 	if (ctx->argc != 0)
 		exit_bad_args();
@@ -4215,11 +4215,13 @@ static int do_gprivflags(struct cmd_context *ctx)
 				1);
 	if (!strings) {
 		perror("Cannot get private flag names");
-		return 1;
+		rc = 1;
+		goto err;
 	}
 	if (strings->len == 0) {
 		fprintf(stderr, "No private flags defined\n");
-		return 1;
+		rc = 1;
+		goto err;
 	}
 	if (strings->len > 32) {
 		/* ETHTOOL_GPFLAGS can only cover 32 flags */
@@ -4230,7 +4232,8 @@ static int do_gprivflags(struct cmd_context *ctx)
 	flags.cmd = ETHTOOL_GPFLAGS;
 	if (send_ioctl(ctx, &flags)) {
 		perror("Cannot get private flags");
-		return 1;
+		rc = 1;
+		goto err;
 	}
 
 	/* Find longest string and align all strings accordingly */
@@ -4248,7 +4251,12 @@ static int do_gprivflags(struct cmd_context *ctx)
 		       (const char *)strings->data + i * ETH_GSTRING_LEN,
 		       (flags.data & (1U << i)) ? "on" : "off");
 
-	return 0;
+	rc = 0;
+
+err:
+	if (strings)
+		free(strings);
+	return rc;
 }
 
 static int do_sprivflags(struct cmd_context *ctx)
-- 
2.7.4
