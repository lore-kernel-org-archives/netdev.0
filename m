From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH 6/7] ethtool: fix leakage of strings resources in do_sprivflags
Date: Fri, 30 Sep 2016 15:56:20 -0400
Message-ID: <1475265381-28937-7-git-send-email-linville@tuxdriver.com>
References: <1475265381-28937-1-git-send-email-linville@tuxdriver.com>
Cc: "John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38657 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751668AbcI3UAT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 16:00:19 -0400
In-Reply-To: <1475265381-28937-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Coverity issue: 1363124
Fixes: e1ee596326ae ("Add support for querying and setting private flags")

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 ethtool.c | 19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 840a5da157a9..406cfd2f95a5 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -4285,7 +4285,7 @@ static int do_sprivflags(struct cmd_context *ctx)
 	struct cmdline_info *cmdline;
 	struct ethtool_value flags;
 	u32 wanted_flags = 0, seen_flags = 0;
-	int any_changed;
+	int any_changed, rc;
 	unsigned int i;
 
 	strings = get_stringset(ctx, ETH_SS_PRIV_FLAGS,
@@ -4297,7 +4297,8 @@ static int do_sprivflags(struct cmd_context *ctx)
 	}
 	if (strings->len == 0) {
 		fprintf(stderr, "No private flags defined\n");
-		return 1;
+		rc = 1;
+		goto err;
 	}
 	if (strings->len > 32) {
 		/* ETHTOOL_{G,S}PFLAGS can only cover 32 flags */
@@ -4308,7 +4309,8 @@ static int do_sprivflags(struct cmd_context *ctx)
 	cmdline = calloc(strings->len, sizeof(*cmdline));
 	if (!cmdline) {
 		perror("Cannot parse arguments");
-		return 1;
+		rc = 1;
+		goto err;
 	}
 	for (i = 0; i < strings->len; i++) {
 		cmdline[i].name = ((const char *)strings->data +
@@ -4324,17 +4326,22 @@ static int do_sprivflags(struct cmd_context *ctx)
 	flags.cmd = ETHTOOL_GPFLAGS;
 	if (send_ioctl(ctx, &flags)) {
 		perror("Cannot get private flags");
-		return 1;
+		rc = 1;
+		goto err;
 	}
 
 	flags.cmd = ETHTOOL_SPFLAGS;
 	flags.data = (flags.data & ~seen_flags) | wanted_flags;
 	if (send_ioctl(ctx, &flags)) {
 		perror("Cannot set private flags");
-		return 1;
+		rc = 1;
+		goto err;
 	}
 
-	return 0;
+	rc = 0;
+err:
+	free(strings);
+	return rc;
 }
 
 static int do_tsinfo(struct cmd_context *ctx)
-- 
2.7.4
