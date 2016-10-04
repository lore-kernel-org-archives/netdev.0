From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH v2 2/7] ethtool: avoid resource leak of strings in do_gprivflags
Date: Tue,  4 Oct 2016 10:05:17 -0400
Message-ID: <1475589917-20882-1-git-send-email-linville@tuxdriver.com>
References: <1475265381-28937-3-git-send-email-linville@tuxdriver.com>
Cc: Jarod Wilson <jarod@redhat.com>,
        "John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:43351 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751404AbcJDOPO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 10:15:14 -0400
In-Reply-To: <1475265381-28937-3-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Coverity issue: 1363119
Fixes: e1ee596326ae ("Add support for querying and setting private flags")

Signed-off-by: John W. Linville <linville@tuxdriver.com>
Reviewed-by: Greg Rose <grose@lightfleet.com>
---
 ethtool.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index aa3ef5ed2f75..7ce5667fcdd7 100644
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
@@ -4219,7 +4219,8 @@ static int do_gprivflags(struct cmd_context *ctx)
 	}
 	if (strings->len == 0) {
 		fprintf(stderr, "No private flags defined\n");
-		return 1;
+		rc = 1;
+		goto err;
 	}
 	if (strings->len > 32) {
 		/* ETHTOOL_GPFLAGS can only cover 32 flags */
@@ -4230,7 +4231,8 @@ static int do_gprivflags(struct cmd_context *ctx)
 	flags.cmd = ETHTOOL_GPFLAGS;
 	if (send_ioctl(ctx, &flags)) {
 		perror("Cannot get private flags");
-		return 1;
+		rc = 1;
+		goto err;
 	}
 
 	/* Find longest string and align all strings accordingly */
@@ -4248,7 +4250,11 @@ static int do_gprivflags(struct cmd_context *ctx)
 		       (const char *)strings->data + i * ETH_GSTRING_LEN,
 		       (flags.data & (1U << i)) ? "on" : "off");
 
-	return 0;
+	rc = 0;
+
+err:
+	free(strings);
+	return rc;
 }
 
 static int do_sprivflags(struct cmd_context *ctx)
-- 
2.7.4
