From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 3/7] ipv4: fib: Send notification before deleting FIB alias
Date: Thu,  9 Feb 2017 10:28:40 +0100
Message-ID: <1486632524-5588-4-git-send-email-jiri@resnulli.us>
References: <1486632524-5588-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com, Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35288 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752274AbdBIJ2u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 04:28:50 -0500
Received: by mail-wm0-f41.google.com with SMTP id v186so74451435wmd.0
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 01:28:50 -0800 (PST)
In-Reply-To: <1486632524-5588-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When a FIB alias is replaced following NLM_F_REPLACE, the ENTRY_ADD
notification is sent after the reference on the previous FIB info was
dropped. This is problematic as potential listeners might need to access
it in their notification blocks.

Solve this by sending the notification prior to the deletion of the
replaced FIB alias. This is consistent with ENTRY_DEL notifications.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
CC: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/fib_trie.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index b0bfb1c..1c4d42e 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1295,6 +1295,13 @@ int fib_table_insert(struct net *net, struct fib_table *tb,
 			new_fa->tb_id = tb->tb_id;
 			new_fa->fa_default = -1;
 
+			call_fib_entry_notifiers(net, FIB_EVENT_ENTRY_ADD,
+						 key, plen, fi,
+						 new_fa->fa_tos, cfg->fc_type,
+						 tb->tb_id, nlflags);
+			rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen,
+				  tb->tb_id, &cfg->fc_nlinfo, nlflags);
+
 			hlist_replace_rcu(&fa->fa_list, &new_fa->fa_list);
 
 			alias_free_mem_rcu(fa);
@@ -1303,13 +1310,6 @@ int fib_table_insert(struct net *net, struct fib_table *tb,
 			if (state & FA_S_ACCESSED)
 				rt_cache_flush(cfg->fc_nlinfo.nl_net);
 
-			call_fib_entry_notifiers(net, FIB_EVENT_ENTRY_ADD,
-						 key, plen, fi,
-						 new_fa->fa_tos, cfg->fc_type,
-						 tb->tb_id, cfg->fc_nlflags);
-			rtmsg_fib(RTM_NEWROUTE, htonl(key), new_fa, plen,
-				tb->tb_id, &cfg->fc_nlinfo, nlflags);
-
 			goto succeeded;
 		}
 		/* Error if we find a perfect match which
-- 
2.7.4
