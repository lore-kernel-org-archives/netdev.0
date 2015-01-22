From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [next-next PATCH 6/7] fib_trie: Move fib_find_alias to file where
 it is used
Date: Thu, 22 Jan 2015 15:51:39 -0800
Message-ID: <20150122235139.5779.21116.stgit@ahduyck-vm-fedora20>
References: <20150122234652.5779.44251.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52563 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754431AbbAVXvl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jan 2015 18:51:41 -0500
In-Reply-To: <20150122234652.5779.44251.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function fib_find_alias is only accessed by functions in fib_trie.c as
such it makes sense to relocate it and cast it as static so that the
compiler can take advantage of optimizations it can do to it as a local
function.

Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_lookup.h    |    1 -
 net/ipv4/fib_semantics.c |   18 ------------------
 net/ipv4/fib_trie.c      |   20 ++++++++++++++++++++
 3 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/net/ipv4/fib_lookup.h b/net/ipv4/fib_lookup.h
index 1e4f660..825981b 100644
--- a/net/ipv4/fib_lookup.h
+++ b/net/ipv4/fib_lookup.h
@@ -32,7 +32,6 @@ int fib_dump_info(struct sk_buff *skb, u32 pid, u32 seq, int event, u32 tb_id,
 		  unsigned int);
 void rtmsg_fib(int event, __be32 key, struct fib_alias *fa, int dst_len,
 	       u32 tb_id, const struct nl_info *info, unsigned int nlm_flags);
-struct fib_alias *fib_find_alias(struct list_head *fah, u8 tos, u32 prio);
 
 static inline void fib_result_assign(struct fib_result *res,
 				     struct fib_info *fi)
diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 265cb72..1e2090e 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -411,24 +411,6 @@ errout:
 		rtnl_set_sk_err(info->nl_net, RTNLGRP_IPV4_ROUTE, err);
 }
 
-/* Return the first fib alias matching TOS with
- * priority less than or equal to PRIO.
- */
-struct fib_alias *fib_find_alias(struct list_head *fah, u8 tos, u32 prio)
-{
-	if (fah) {
-		struct fib_alias *fa;
-		list_for_each_entry(fa, fah, fa_list) {
-			if (fa->fa_tos > tos)
-				continue;
-			if (fa->fa_info->fib_priority >= prio ||
-			    fa->fa_tos < tos)
-				return fa;
-		}
-	}
-	return NULL;
-}
-
 static int fib_detect_death(struct fib_info *fi, int order,
 			    struct fib_info **last_resort, int *last_idx,
 			    int dflt)
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 90654bb..7f34226 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -998,6 +998,26 @@ static struct tnode *fib_find_node(struct trie *t, u32 key)
 	return n;
 }
 
+/* Return the first fib alias matching TOS with
+ * priority less than or equal to PRIO.
+ */
+static struct fib_alias *fib_find_alias(struct list_head *fah, u8 tos, u32 prio)
+{
+	struct fib_alias *fa;
+
+	if (!fah)
+		return NULL;
+
+	list_for_each_entry(fa, fah, fa_list) {
+		if (fa->fa_tos > tos)
+			continue;
+		if (fa->fa_info->fib_priority >= prio || fa->fa_tos < tos)
+			return fa;
+	}
+
+	return NULL;
+}
+
 static void trie_rebalance(struct trie *t, struct tnode *tn)
 {
 	struct tnode *tp;
