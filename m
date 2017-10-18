From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next] net: ipv4: Change fib notifiers to take a fib_alias
Date: Wed, 18 Oct 2017 11:39:13 -0700
Message-ID: <1508351953-26442-1-git-send-email-dsahern@gmail.com>
Cc: jiri@mellanox.com, idosch@mellanox.com,
        David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:50062 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750730AbdJRSjT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 14:39:19 -0400
Received: by mail-pg0-f67.google.com with SMTP id g6so4972561pgn.6
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:39:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All of the notifier data (fib_info, tos, type and table id) are
contained in the fib_alias. Pass it to the notifier instead of
each data separately shortening the argument list by 3.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 net/ipv4/fib_trie.c | 39 +++++++++++++++------------------------
 1 file changed, 15 insertions(+), 24 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index c636650a6a70..aaa1ba09afaa 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -87,32 +87,30 @@
 
 static int call_fib_entry_notifier(struct notifier_block *nb, struct net *net,
 				   enum fib_event_type event_type, u32 dst,
-				   int dst_len, struct fib_info *fi,
-				   u8 tos, u8 type, u32 tb_id)
+				   int dst_len, struct fib_alias *fa)
 {
 	struct fib_entry_notifier_info info = {
 		.dst = dst,
 		.dst_len = dst_len,
-		.fi = fi,
-		.tos = tos,
-		.type = type,
-		.tb_id = tb_id,
+		.fi = fa->fa_info,
+		.tos = fa->fa_tos,
+		.type = fa->fa_type,
+		.tb_id = fa->tb_id,
 	};
 	return call_fib4_notifier(nb, net, event_type, &info.info);
 }
 
 static int call_fib_entry_notifiers(struct net *net,
 				    enum fib_event_type event_type, u32 dst,
-				    int dst_len, struct fib_info *fi,
-				    u8 tos, u8 type, u32 tb_id)
+				    int dst_len, struct fib_alias *fa)
 {
 	struct fib_entry_notifier_info info = {
 		.dst = dst,
 		.dst_len = dst_len,
-		.fi = fi,
-		.tos = tos,
-		.type = type,
-		.tb_id = tb_id,
+		.fi = fa->fa_info,
+		.tos = fa->fa_tos,
+		.type = fa->fa_type,
+		.tb_id = fa->tb_id,
 	};
 	return call_fib4_notifiers(net, event_type, &info.info);
 }
@@ -1216,9 +1214,7 @@ int fib_table_insert(struct net *net, struct fib_table *tb,
 			new_fa->fa_default = -1;
 
 			call_fib_entry_notifiers(net, FIB_EVENT_ENTRY_REPLACE,
-						 key, plen, fi,
-						 new_fa->fa_tos, cfg->fc_type,
-						 tb->tb_id);
+						 key, plen, new_fa);
 			rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen,
 				  tb->tb_id, &cfg->fc_nlinfo, nlflags);
 
@@ -1273,8 +1269,7 @@ int fib_table_insert(struct net *net, struct fib_table *tb,
 		tb->tb_num_default++;
 
 	rt_cache_flush(cfg->fc_nlinfo.nl_net);
-	call_fib_entry_notifiers(net, event, key, plen, fi, tos, cfg->fc_type,
-				 tb->tb_id);
+	call_fib_entry_notifiers(net, event, key, plen, new_fa);
 	rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen, new_fa->tb_id,
 		  &cfg->fc_nlinfo, nlflags);
 succeeded:
@@ -1574,8 +1569,7 @@ int fib_table_delete(struct net *net, struct fib_table *tb,
 		return -ESRCH;
 
 	call_fib_entry_notifiers(net, FIB_EVENT_ENTRY_DEL, key, plen,
-				 fa_to_delete->fa_info, tos,
-				 fa_to_delete->fa_type, tb->tb_id);
+				 fa_to_delete);
 	rtmsg_fib(RTM_DELROUTE, htonl(key), fa_to_delete, plen, tb->tb_id,
 		  &cfg->fc_nlinfo, 0);
 
@@ -1892,9 +1886,7 @@ int fib_table_flush(struct net *net, struct fib_table *tb)
 
 			call_fib_entry_notifiers(net, FIB_EVENT_ENTRY_DEL,
 						 n->key,
-						 KEYLENGTH - fa->fa_slen,
-						 fi, fa->fa_tos, fa->fa_type,
-						 tb->tb_id);
+						 KEYLENGTH - fa->fa_slen, fa);
 			hlist_del_rcu(&fa->fa_list);
 			fib_release_info(fa->fa_info);
 			alias_free_mem_rcu(fa);
@@ -1932,8 +1924,7 @@ static void fib_leaf_notify(struct net *net, struct key_vector *l,
 			continue;
 
 		call_fib_entry_notifier(nb, net, FIB_EVENT_ENTRY_ADD, l->key,
-					KEYLENGTH - fa->fa_slen, fi, fa->fa_tos,
-					fa->fa_type, fa->tb_id);
+					KEYLENGTH - fa->fa_slen, fa);
 	}
 }
 
-- 
2.1.4
