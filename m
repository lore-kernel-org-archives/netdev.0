From: Guillaume Nault <g.nault@alphalink.fr>
Subject: [PATCH net 1/2] ipv4: fix value of ->nlmsg_flags reported in
 RTM_NEWROUTE events
Date: Wed, 7 Sep 2016 17:20:46 +0200
Message-ID: <20160907152046.wxzy3ivsi7n4y52b@alphalink.fr>
References: <20160907151850.g3mzjrkhtqddqzwg@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roopa Prabhu <roopa@cumulusnetworks.com>,
        Milan Kocian <milon@wq.cz>,
        Michal =?utf-8?Q?Kube=C4=8Dek?= <mkubecek@suse.cz>,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:39790 "EHLO
        zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756868AbcIGPUx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Sep 2016 11:20:53 -0400
Content-Disposition: inline
In-Reply-To: <20160907151850.g3mzjrkhtqddqzwg@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fib_table_insert() inconsistently fills the nlmsg_flags field in its
notification messages.

Since commit b8f558313506 ("[RTNETLINK]: Fix sending netlink message
when replace route."), the netlink message has its nlmsg_flags set to
NLM_F_REPLACE if the route replaced a preexisting one.

Then commit a2bb6d7d6f42 ("ipv4: include NLM_F_APPEND flag in append
route notifications") started setting nlmsg_flags to NLM_F_APPEND if
the route matched a preexisting one but was appended.

In other cases (exclusive creation or prepend), nlmsg_flags is 0.

This patch sets ->nlmsg_flags in all situations, preserving the
semantic of the NLM_F_* bits:

  * NLM_F_CREATE: a new fib entry has been created for this route.
  * NLM_F_EXCL: no other fib entry existed for this route.
  * NLM_F_REPLACE: this route has overwritten a preexisting fib entry.
  * NLM_F_APPEND: the new fib entry was added after other entries for
    the same route.

As a result, the possible flag combination can now be reported
(iproute2's terminology into parentheses):

  * NLM_F_CREATE | NLM_F_EXCL: route didn't exist, exclusive creation
    ("add").
  * NLM_F_CREATE | NLM_F_APPEND: route did already exist, new route
    added after preexisting ones ("append").
  * NLM_F_CREATE: route did already exist, new route added before
    preexisting ones ("prepend").
  * NLM_F_REPLACE: route did already exist, new route replaced the
    first preexisting one ("change").

Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
---
 net/ipv4/fib_trie.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index e2ffc2a..241f27b 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1081,7 +1081,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 	struct trie *t = (struct trie *)tb->tb_data;
 	struct fib_alias *fa, *new_fa;
 	struct key_vector *l, *tp;
-	unsigned int nlflags = 0;
+	u16 nlflags = NLM_F_EXCL;
 	struct fib_info *fi;
 	u8 plen = cfg->fc_dst_len;
 	u8 slen = KEYLENGTH - plen;
@@ -1126,6 +1126,8 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 		if (cfg->fc_nlflags & NLM_F_EXCL)
 			goto out;
 
+		nlflags &= ~NLM_F_EXCL;
+
 		/* We have 2 goals:
 		 * 1. Find exact match for type, scope, fib_info to avoid
 		 * duplicate routes
@@ -1151,6 +1153,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 			struct fib_info *fi_drop;
 			u8 state;
 
+			nlflags |= NLM_F_REPLACE;
 			fa = fa_first;
 			if (fa_match) {
 				if (fa == fa_match)
@@ -1191,7 +1194,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 			if (state & FA_S_ACCESSED)
 				rt_cache_flush(cfg->fc_nlinfo.nl_net);
 			rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen,
-				tb->tb_id, &cfg->fc_nlinfo, NLM_F_REPLACE);
+				tb->tb_id, &cfg->fc_nlinfo, nlflags);
 
 			goto succeeded;
 		}
@@ -1203,7 +1206,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 			goto out;
 
 		if (cfg->fc_nlflags & NLM_F_APPEND)
-			nlflags = NLM_F_APPEND;
+			nlflags |= NLM_F_APPEND;
 		else
 			fa = fa_first;
 	}
@@ -1211,6 +1214,7 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 	if (!(cfg->fc_nlflags & NLM_F_CREATE))
 		goto out;
 
+	nlflags |= NLM_F_CREATE;
 	err = -ENOBUFS;
 	new_fa = kmem_cache_alloc(fn_alias_kmem, GFP_KERNEL);
 	if (!new_fa)
-- 
2.9.3
