From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH net-next v2] ipv4: include NLM_F_APPEND flag in append route notifications
Date: Wed, 17 Jun 2015 11:07:01 -0700
Message-ID: <1434564421-32047-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, alexander.duyck@gmail.com,
	sfeldma@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:34138 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753033AbbFQSHH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jun 2015 14:07:07 -0400
Received: by pacgb13 with SMTP id gb13so41472729pac.1
        for <netdev@vger.kernel.org>; Wed, 17 Jun 2015 11:07:07 -0700 (PDT)
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
v2: flip if condition around append and change |= to =
(feedback from Alexander Duyck and Scott Feldman)

 net/ipv4/fib_trie.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 3c699c4..6c666a9 100644
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
@@ -1201,7 +1202,9 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 		if (fa_match)
 			goto out;
 
-		if (!(cfg->fc_nlflags & NLM_F_APPEND))
+		if (cfg->fc_nlflags & NLM_F_APPEND)
+			nlflags = NLM_F_APPEND;
+		else
 			fa = fa_first;
 	}
 	err = -ENOENT;
@@ -1238,7 +1241,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 
 	rt_cache_flush(cfg->fc_nlinfo.nl_net);
 	rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen, new_fa->tb_id,
-		  &cfg->fc_nlinfo, 0);
+		  &cfg->fc_nlinfo, nlflags);
 succeeded:
 	return 0;
 
-- 
1.7.10.4
