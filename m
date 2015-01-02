From: sfeldma@gmail.com
Subject: [PATCH net-next 2/3] net: call swdev fib del for flushed routes
Date: Thu,  1 Jan 2015 19:29:20 -0800
Message-ID: <1420169361-31767-3-git-send-email-sfeldma@gmail.com>
To: netdev@vger.kernel.org, jiri@resnulli.us, john.fastabend@gmail.com,
	tgraf@suug.ch, jhs@mojatatu.com, andy@greyhouse.net,
	roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:62236 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751874AbbABD25 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jan 2015 22:28:57 -0500
Received: by mail-pa0-f54.google.com with SMTP id fb1so23528296pad.27
        for <netdev@vger.kernel.org>; Thu, 01 Jan 2015 19:28:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

This is essentially the same patch Nicolas Dichtel posted, but was rejected.
The difference here is rather than calling netlink to notify, this patch
calls swdev to del the fib entry.  Without this patch, when routes are flushed,
for example when an interface goes down, the normal route delete paths aren't
called, so we need to hook the flush path so swdev get's called.

Nicolas' patch is here:

http://marc.info/?l=linux-netdev&m=135161909714545&w=2

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/ipv4/fib_trie.c |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index ea2dc17..c7a5947 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1565,15 +1565,19 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 	return 0;
 }
 
-static int trie_flush_list(struct list_head *head)
+static int trie_flush_list(struct fib_table *tb, struct tnode *l,
+			   struct leaf_info *li)
 {
 	struct fib_alias *fa, *fa_node;
 	int found = 0;
 
-	list_for_each_entry_safe(fa, fa_node, head, fa_list) {
+	list_for_each_entry_safe(fa, fa_node, &li->falh, fa_list) {
 		struct fib_info *fi = fa->fa_info;
 
 		if (fi && (fi->fib_flags & RTNH_F_DEAD)) {
+			netdev_switch_fib_ipv4_del(l->key, li->plen, fi,
+						   fa->fa_tos, fa->fa_type,
+						   tb->tb_id);
 			list_del_rcu(&fa->fa_list);
 			fib_release_info(fa->fa_info);
 			alias_free_mem_rcu(fa);
@@ -1583,7 +1587,7 @@ static int trie_flush_list(struct list_head *head)
 	return found;
 }
 
-static int trie_flush_leaf(struct tnode *l)
+static int trie_flush_leaf(struct fib_table *tb, struct tnode *l)
 {
 	int found = 0;
 	struct hlist_head *lih = &l->list;
@@ -1591,7 +1595,7 @@ static int trie_flush_leaf(struct tnode *l)
 	struct leaf_info *li = NULL;
 
 	hlist_for_each_entry_safe(li, tmp, lih, hlist) {
-		found += trie_flush_list(&li->falh);
+		found += trie_flush_list(tb, l, li);
 
 		if (list_empty(&li->falh)) {
 			hlist_del_rcu(&li->hlist);
@@ -1674,7 +1678,7 @@ int fib_table_flush(struct fib_table *tb)
 	int found = 0;
 
 	for (l = trie_firstleaf(t); l; l = trie_nextleaf(l)) {
-		found += trie_flush_leaf(l);
+		found += trie_flush_leaf(tb, l);
 
 		if (ll && hlist_empty(&ll->list))
 			trie_leaf_remove(t, ll);
-- 
1.7.10.4
