From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH ethtool] ethtool: print hash function with ethtool -x|--show-rxfh-indir
Date: Tue,  7 Mar 2017 11:19:06 -0800
Message-ID: <20170307191906.63288-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:36266 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754383AbdCGT0T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 14:26:19 -0500
Received: by mail-pg0-f48.google.com with SMTP id 187so3833018pgb.3
        for <netdev@vger.kernel.org>; Tue, 07 Mar 2017 11:26:13 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make ethtool -x|--show-rxfh-indir print the RSS hash function name.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 ethtool.8.in |  3 ++-
 ethtool.c    | 31 +++++++++++++++++++++++++++++++
 2 files changed, 33 insertions(+), 1 deletion(-)

diff --git a/ethtool.8.in b/ethtool.8.in
index 5c36c06385f6..5f5a141c1482 100644
--- a/ethtool.8.in
+++ b/ethtool.8.in
@@ -854,7 +854,8 @@ Show the device's time stamping capabilities and associated PTP
 hardware clock.
 .TP
 .B \-x \-\-show\-rxfh\-indir \-\-show\-rxfh
-Retrieves the receive flow hash indirection table and/or RSS hash key.
+Retrieves the receive flow hash indirection table, hash function and RSS hash
+key.
 .TP
 .B \-X \-\-set\-rxfh\-indir \-\-rxfh
 Configures the receive flow hash indirection table and/or RSS hash key.
diff --git a/ethtool.c b/ethtool.c
index 7af039e26b50..2d8dd54752c4 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -3638,6 +3638,35 @@ static int do_grxfhindir(struct cmd_context *ctx,
 	return 0;
 }
 
+static void print_grxfh_hfunc(struct cmd_context *ctx, __u8 hfunc)
+{
+	unsigned int func_id = ffs(hfunc) - 1;
+	struct ethtool_gstrings *strings;
+
+	printf("RSS hash function: ");
+	if (!hfunc) {
+		printf("unknown\n");
+		return;
+	}
+
+	strings = get_stringset(ctx, ETH_SS_RSS_HASH_FUNCS, 0, 1);
+	if (!strings) {
+		if (errno != EOPNOTSUPP)
+			printf("%s\n", strerror(errno));
+		else
+			printf("unnamed (%d)\n", func_id);
+		return;
+	}
+
+	if (func_id < strings->len)
+		printf("%s\n",
+		       (char *)strings->data + func_id * ETH_GSTRING_LEN);
+	else
+		printf("unnamed (%d)\n", func_id);
+
+	free(strings);
+}
+
 static int do_grxfh(struct cmd_context *ctx)
 {
 	struct ethtool_rxfh rss_head = {0};
@@ -3683,6 +3712,8 @@ static int do_grxfh(struct cmd_context *ctx)
 
 	print_indir_table(ctx, &ring_count, rss->indir_size, rss->rss_config);
 
+	print_grxfh_hfunc(ctx, rss->hfunc);
+
 	indir_bytes = rss->indir_size * sizeof(rss->rss_config[0]);
 	hkey = ((char *)rss->rss_config + indir_bytes);
 
-- 
2.11.0
