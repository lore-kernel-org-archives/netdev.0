From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: [PATCH net-next] fib_trie: Send RTM_DELROUTE when link goes down
Date: Thu, 17 Oct 2013 18:54:54 +0200
Message-ID: <1382028894-14236-1-git-send-email-kristian.evensen@gmail.com>
References: <CAKfDRXizw1TaK-oHrAQv8Hi80gKiUHjQ6d21o3MOQpuVkcXSow@mail.gmail.com>
Cc: Kristian Evensen <kristian.evensen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:40368 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757256Ab3JQQzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 12:55:11 -0400
Received: by mail-la0-f46.google.com with SMTP id eh20so2080567lab.19
        for <netdev@vger.kernel.org>; Thu, 17 Oct 2013 09:55:09 -0700 (PDT)
In-Reply-To: <CAKfDRXizw1TaK-oHrAQv8Hi80gKiUHjQ6d21o3MOQpuVkcXSow@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kristian Evensen <kristian.evensen@gmail.com>

When a link is set as down using for example "ip link set dev X down", routes
are deleted, but RTM_DELROUTE messages are not sent to RTNLGRP_IPV4_ROUTE. This
patch makes trie_flush_list() send a RTM_DELROUTE for each route that is
removed, and makes rtnelink route deletion behavior consistent across commands.
The parameter lists for trie_flush_list() and trie_flush_leaf() are expanded to
include required information otherwise unavailable in trie_flush_list().

One use case that is simplified by this patch is IPv4 WAN connection monitoring.
Instead of listening for and handling both RTM_*ROUTE and RTM_*LINK-messages, it
is sufficient to handle RTM_*ROUTE.

Signed-off-by: Kristian Evensen <kristian.evensen@gmail.com>

---
 net/ipv4/fib_trie.c | 16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index ec9a9ef..629747a 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1698,15 +1698,23 @@ int fib_table_delete(struct fib_table *tb, struct fib_config *cfg)
 	return 0;
 }
 
-static int trie_flush_list(struct list_head *head)
+static int trie_flush_list(struct list_head *head, u32 tb_id, t_key key,
+			    int plen)
 {
 	struct fib_alias *fa, *fa_node;
 	int found = 0;
+	struct nl_info cfg;
+
+	memset(&cfg, 0, sizeof(cfg));
 
 	list_for_each_entry_safe(fa, fa_node, head, fa_list) {
 		struct fib_info *fi = fa->fa_info;
 
 		if (fi && (fi->fib_flags & RTNH_F_DEAD)) {
+			cfg.nl_net = fi->fib_net;
+			rtmsg_fib(RTM_DELROUTE, htonl(key), fa, plen, tb_id,
+				  &cfg, 0);
+
 			list_del_rcu(&fa->fa_list);
 			fib_release_info(fa->fa_info);
 			alias_free_mem_rcu(fa);
@@ -1716,7 +1724,7 @@ static int trie_flush_list(struct list_head *head)
 	return found;
 }
 
-static int trie_flush_leaf(struct leaf *l)
+static int trie_flush_leaf(struct leaf *l, u32 tb_id)
 {
 	int found = 0;
 	struct hlist_head *lih = &l->list;
@@ -1724,7 +1732,7 @@ static int trie_flush_leaf(struct leaf *l)
 	struct leaf_info *li = NULL;
 
 	hlist_for_each_entry_safe(li, tmp, lih, hlist) {
-		found += trie_flush_list(&li->falh);
+		found += trie_flush_list(&li->falh, tb_id, l->key, li->plen);
 
 		if (list_empty(&li->falh)) {
 			hlist_del_rcu(&li->hlist);
@@ -1813,7 +1821,7 @@ int fib_table_flush(struct fib_table *tb)
 	int found = 0;
 
 	for (l = trie_firstleaf(t); l; l = trie_nextleaf(l)) {
-		found += trie_flush_leaf(l);
+		found += trie_flush_leaf(l, tb->tb_id);
 
 		if (ll && hlist_empty(&ll->list))
 			trie_leaf_remove(t, ll);
-- 
1.8.1.2
