From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/7] ipv4: fib: Add events for FIB replace and append
Date: Thu,  9 Feb 2017 10:28:41 +0100
Message-ID: <1486632524-5588-5-git-send-email-jiri@resnulli.us>
References: <1486632524-5588-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com, Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35384 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752279AbdBIJ2w (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 04:28:52 -0500
Received: by mail-wr0-f196.google.com with SMTP id o16so11297204wra.2
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 01:28:51 -0800 (PST)
In-Reply-To: <1486632524-5588-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The FIB notification chain currently uses the NLM_F_{REPLACE,APPEND}
flags to signal routes being replaced or appended.

Instead of using netlink flags for in-kernel notifications we can simply
introduce two new events in the FIB notification chain. This has the
added advantage of making the API cleaner, thereby making it clear that
these events should be supported by listeners of the notification chain.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
CC: Patrick McHardy <kaber@trash.net>
---
 include/net/ip_fib.h |  3 ++-
 net/ipv4/fib_trie.c  | 27 ++++++++++++++-------------
 2 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 45a184e..368bb40 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -211,7 +211,6 @@ struct fib_entry_notifier_info {
 	u8 tos;
 	u8 type;
 	u32 tb_id;
-	u32 nlflags;
 };
 
 struct fib_nh_notifier_info {
@@ -220,6 +219,8 @@ struct fib_nh_notifier_info {
 };
 
 enum fib_event_type {
+	FIB_EVENT_ENTRY_REPLACE,
+	FIB_EVENT_ENTRY_APPEND,
 	FIB_EVENT_ENTRY_ADD,
 	FIB_EVENT_ENTRY_DEL,
 	FIB_EVENT_RULE_ADD,
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 1c4d42e..d8cea21 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -124,7 +124,7 @@ static void fib_notify(struct net *net, struct notifier_block *nb,
 static int call_fib_entry_notifier(struct notifier_block *nb, struct net *net,
 				   enum fib_event_type event_type, u32 dst,
 				   int dst_len, struct fib_info *fi,
-				   u8 tos, u8 type, u32 tb_id, u32 nlflags)
+				   u8 tos, u8 type, u32 tb_id)
 {
 	struct fib_entry_notifier_info info = {
 		.dst = dst,
@@ -133,7 +133,6 @@ static int call_fib_entry_notifier(struct notifier_block *nb, struct net *net,
 		.tos = tos,
 		.type = type,
 		.tb_id = tb_id,
-		.nlflags = nlflags,
 	};
 	return call_fib_notifier(nb, net, event_type, &info.info);
 }
@@ -197,7 +196,7 @@ int call_fib_notifiers(struct net *net, enum fib_event_type event_type,
 static int call_fib_entry_notifiers(struct net *net,
 				    enum fib_event_type event_type, u32 dst,
 				    int dst_len, struct fib_info *fi,
-				    u8 tos, u8 type, u32 tb_id, u32 nlflags)
+				    u8 tos, u8 type, u32 tb_id)
 {
 	struct fib_entry_notifier_info info = {
 		.dst = dst,
@@ -206,7 +205,6 @@ static int call_fib_entry_notifiers(struct net *net,
 		.tos = tos,
 		.type = type,
 		.tb_id = tb_id,
-		.nlflags = nlflags,
 	};
 	return call_fib_notifiers(net, event_type, &info.info);
 }
@@ -1198,6 +1196,7 @@ static int fib_insert_alias(struct trie *t, struct key_vector *tp,
 int fib_table_insert(struct net *net, struct fib_table *tb,
 		     struct fib_config *cfg)
 {
+	enum fib_event_type event = FIB_EVENT_ENTRY_ADD;
 	struct trie *t = (struct trie *)tb->tb_data;
 	struct fib_alias *fa, *new_fa;
 	struct key_vector *l, *tp;
@@ -1295,10 +1294,10 @@ int fib_table_insert(struct net *net, struct fib_table *tb,
 			new_fa->tb_id = tb->tb_id;
 			new_fa->fa_default = -1;
 
-			call_fib_entry_notifiers(net, FIB_EVENT_ENTRY_ADD,
+			call_fib_entry_notifiers(net, FIB_EVENT_ENTRY_REPLACE,
 						 key, plen, fi,
 						 new_fa->fa_tos, cfg->fc_type,
-						 tb->tb_id, nlflags);
+						 tb->tb_id);
 			rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen,
 				  tb->tb_id, &cfg->fc_nlinfo, nlflags);
 
@@ -1319,10 +1318,12 @@ int fib_table_insert(struct net *net, struct fib_table *tb,
 		if (fa_match)
 			goto out;
 
-		if (cfg->fc_nlflags & NLM_F_APPEND)
+		if (cfg->fc_nlflags & NLM_F_APPEND) {
+			event = FIB_EVENT_ENTRY_APPEND;
 			nlflags |= NLM_F_APPEND;
-		else
+		} else {
 			fa = fa_first;
+		}
 	}
 	err = -ENOENT;
 	if (!(cfg->fc_nlflags & NLM_F_CREATE))
@@ -1351,8 +1352,8 @@ int fib_table_insert(struct net *net, struct fib_table *tb,
 		tb->tb_num_default++;
 
 	rt_cache_flush(cfg->fc_nlinfo.nl_net);
-	call_fib_entry_notifiers(net, FIB_EVENT_ENTRY_ADD, key, plen, fi, tos,
-				 cfg->fc_type, tb->tb_id, cfg->fc_nlflags);
+	call_fib_entry_notifiers(net, event, key, plen, fi, tos, cfg->fc_type,
+				 tb->tb_id);
 	rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen, new_fa->tb_id,
 		  &cfg->fc_nlinfo, nlflags);
 succeeded:
@@ -1654,7 +1655,7 @@ int fib_table_delete(struct net *net, struct fib_table *tb,
 
 	call_fib_entry_notifiers(net, FIB_EVENT_ENTRY_DEL, key, plen,
 				 fa_to_delete->fa_info, tos,
-				 fa_to_delete->fa_type, tb->tb_id, 0);
+				 fa_to_delete->fa_type, tb->tb_id);
 	rtmsg_fib(RTM_DELROUTE, htonl(key), fa_to_delete, plen, tb->tb_id,
 		  &cfg->fc_nlinfo, 0);
 
@@ -1973,7 +1974,7 @@ int fib_table_flush(struct net *net, struct fib_table *tb)
 						 n->key,
 						 KEYLENGTH - fa->fa_slen,
 						 fi, fa->fa_tos, fa->fa_type,
-						 tb->tb_id, 0);
+						 tb->tb_id);
 			hlist_del_rcu(&fa->fa_list);
 			fib_release_info(fa->fa_info);
 			alias_free_mem_rcu(fa);
@@ -2013,7 +2014,7 @@ static void fib_leaf_notify(struct net *net, struct key_vector *l,
 
 		call_fib_entry_notifier(nb, net, event_type, l->key,
 					KEYLENGTH - fa->fa_slen, fi, fa->fa_tos,
-					fa->fa_type, fa->tb_id, 0);
+					fa->fa_type, fa->tb_id);
 	}
 }
 
-- 
2.7.4
