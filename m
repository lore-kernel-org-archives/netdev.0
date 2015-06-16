From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next] ipv4: include NLM_F_APPEND flag in append route notifications
Date: Tue, 16 Jun 2015 09:16:32 -0700
Message-ID: <1434471392-26824-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:35221 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750806AbbFPQQi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 12:16:38 -0400
Received: by pacyx8 with SMTP id yx8so15684021pac.2
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2015 09:16:38 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch adds NLM_F_APPEND flag to struct nlmsg_hdr->nlmsg_flags
in newroute notifications if the route add was an append.
(This is similar to how NLM_F_REPLACE is already part of new
route replace notifications today)

This helps userspace determine if the route add operation was
an append.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 net/ipv4/fib_trie.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 3c699c4..38ffc20 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1082,6 +1082,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 	struct trie *t = (struct trie *)tb->tb_data;
 	struct fib_alias *fa, *new_fa;
 	struct key_vector *l, *tp;
+	unsigned int nlflags = 0;
 	struct fib_info *fi;
 	u8 plen = cfg->fc_dst_len;
 	u8 slen = KEYLENGTH - plen;
@@ -1203,6 +1204,8 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 
 		if (!(cfg->fc_nlflags & NLM_F_APPEND))
 			fa = fa_first;
+		else
+			nlflags |= NLM_F_APPEND;
 	}
 	err = -ENOENT;
 	if (!(cfg->fc_nlflags & NLM_F_CREATE))
@@ -1238,7 +1241,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 
 	rt_cache_flush(cfg->fc_nlinfo.nl_net);
 	rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen, new_fa->tb_id,
-		  &cfg->fc_nlinfo, 0);
+		  &cfg->fc_nlinfo, nlflags);
 succeeded:
 	return 0;
 
-- 
1.7.10.4
