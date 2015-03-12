From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 2/2] fib_trie: Provide a deterministic order for
 fib_alias w/ tables merged
Date: Thu, 12 Mar 2015 14:46:29 -0700
Message-ID: <20150312214629.1133.83533.stgit@ahduyck-vm-fedora20>
References: <20150312214226.1133.9622.stgit@ahduyck-vm-fedora20>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46140 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751723AbbCLVqf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2015 17:46:35 -0400
In-Reply-To: <20150312214226.1133.9622.stgit@ahduyck-vm-fedora20>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change makes it so that we should always have a deterministic ordering
for the main and local aliases within the merged table when two leaves
overlap.

So for example if we have a leaf with a key of 192.168.254.0.  If we
previously added two aliases with a prefix length of 24 from both local and
main the first entry would be first and the second would be second.  When I
was coding this I had added a WARN_ON should such a situation occur as I
wasn't sure how likely it would be.  However this WARN_ON has been
triggered so this is something that should be addressed.

With this patch the ordering of the aliases is as follows.  First they are
sorted on prefix length, then on their table ID, then tos, and finally
priority.  This way what we end up doing is essentially interleaving the
two tables on what used to be leaf_info structure boundaries.

Fixes: 0ddcf43d5 ("ipv4: FIB Local/MAIN table collapse")
Reported-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 net/ipv4/fib_trie.c |   28 +++++++++++++++++-----------
 1 file changed, 17 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index dd488c1..e3b4aee 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -950,7 +950,7 @@ static struct key_vector *fib_find_node(struct trie *t,
  * priority less than or equal to PRIO.
  */
 static struct fib_alias *fib_find_alias(struct hlist_head *fah, u8 slen,
-					u8 tos, u32 prio)
+					u8 tos, u32 prio, u32 tb_id)
 {
 	struct fib_alias *fa;
 
@@ -962,6 +962,10 @@ static struct fib_alias *fib_find_alias(struct hlist_head *fah, u8 slen,
 			continue;
 		if (fa->fa_slen != slen)
 			break;
+		if (fa->tb_id > tb_id)
+			continue;
+		if (fa->tb_id != tb_id)
+			break;
 		if (fa->fa_tos > tos)
 			continue;
 		if (fa->fa_info->fib_priority >= prio || fa->fa_tos < tos)
@@ -1041,6 +1045,9 @@ static int fib_insert_alias(struct trie *t, struct key_vector *tp,
 		hlist_for_each_entry(last, &l->leaf, fa_list) {
 			if (new->fa_slen < last->fa_slen)
 				break;
+			if ((new->fa_slen == last->fa_slen) &&
+			    (new->tb_id > last->tb_id))
+				break;
 			fa = last;
 		}
 
@@ -1089,7 +1096,8 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 	}
 
 	l = fib_find_node(t, &tp, key);
-	fa = l ? fib_find_alias(&l->leaf, slen, tos, fi->fib_priority) : NULL;
+	fa = l ? fib_find_alias(&l->leaf, slen, tos, fi->fib_priority,
+				tb->tb_id) : NULL;
 
 	/* Now fa, if non-NULL, points to the first fib alias
 	 * with the same keys [prefix,tos,priority], if such key already
@@ -1116,13 +1124,12 @@ int fib_table_insert(struct fib_table *tb, struct fib_config *cfg)
 		fa_match = NULL;
 		fa_first = fa;
 		hlist_for_each_entry_from(fa, fa_list) {
-			if ((fa->fa_slen != slen) || (fa->fa_tos != tos))
+			if ((fa->fa_slen != slen) ||
+			    (fa->tb_id != tb->tb_id) ||
+			    (fa->fa_tos != tos))
 				break;
 			if (fa->fa_info->fib_priority != fi->fib_priority)
 				break;
-			/* duplicate entry from another table */
-			if (WARN_ON(fa->tb_id != tb->tb_id))
-				continue;
 			if (fa->fa_type == cfg->fc_type &&
 			    fa->fa_info == fi) {
 				fa_match = fa;
@@ -1474,7 +1481,7 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 	if (!l)
 		return -ESRCH;
 
-	fa = fib_find_alias(&l->leaf, slen, tos, 0);
+	fa = fib_find_alias(&l->leaf, slen, tos, 0, tb->tb_id);
 	if (!fa)
 		return -ESRCH;
 
@@ -1484,12 +1491,11 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 	hlist_for_each_entry_from(fa, fa_list) {
 		struct fib_info *fi = fa->fa_info;
 
-		if ((fa->fa_slen != slen) || (fa->fa_tos != tos))
+		if ((fa->fa_slen != slen) ||
+		    (fa->tb_id != tb->tb_id) ||
+		    (fa->fa_tos != tos))
 			break;
 
-		if (fa->tb_id != tb->tb_id)
-			continue;
-
 		if ((!cfg->fc_type || fa->fa_type == cfg->fc_type) &&
 		    (cfg->fc_scope == RT_SCOPE_NOWHERE ||
 		     fa->fa_info->fib_scope == cfg->fc_scope) &&
