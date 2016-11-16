From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/8] net: ipv4: Send notifications only after removing FIB alias
Date: Wed, 16 Nov 2016 15:09:00 +0100
Message-ID: <1479305343-13167-6-git-send-email-jiri@resnulli.us>
References: <1479305343-13167-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35370 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932346AbcKPOJM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 09:09:12 -0500
Received: by mail-wm0-f66.google.com with SMTP id a20so11531451wme.2
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 06:09:11 -0800 (PST)
In-Reply-To: <1479305343-13167-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When removing a FIB alias we should send a notification (both to user
space and in kernel) only after the fact, or otherwise we could end up
in problematic situations.

For example, assume we have two tasks:
a) Task A - Removing a FIB alias (fa1) following RTM_DELROUTE
b) Task B - Replaying FIB tables under RCU for listener (l) following
   fib_notifier_dump() (to be introduced in the next patch).

Timeline:
t0 - Task A calls FIB_EVENT_ENTRY_DEL for fa1. Will be ignored by
     listener l since it's not aware of fa1.
t1 - Task B reaches fa1 in the trie and replays it to listener l using
     FIB_EVENT_ENTRY_ADD.
t2 - Task A removes fa1 from the trie.

The above will result in listener l (f.e., some capable device) having
fa1 in its tables whereas fa1 isn't present in the kernel's table
anymore.

If we always send notifications after the fact, then we can avoid such
races. During insertion, if we traversed the trie when fa1 wasn't
present, then we'll eventually get the notification and process it.
During deletion, if we traversed the trie when fa1 was still present,
then the notification will let us know that it actually needs to be
removed.

The above is consistent with insertion of a FIB alias, where
notifications are sent only after the fact.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/ipv4/fib_trie.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index 64a51ec..2195601 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -1569,17 +1569,17 @@ int fib_table_delete(struct net *net, struct fib_table *tb,
 	if (!fa_to_delete)
 		return -ESRCH;
 
+	if (!plen)
+		tb->tb_num_default--;
+
+	fib_remove_alias(t, tp, l, fa_to_delete);
+
 	call_fib_entry_notifiers(net, FIB_EVENT_ENTRY_DEL, key, plen,
 				 fa_to_delete->fa_info, tos, cfg->fc_type,
 				 tb->tb_id, 0);
 	rtmsg_fib(RTM_DELROUTE, htonl(key), fa_to_delete, plen, tb->tb_id,
 		  &cfg->fc_nlinfo, 0);
 
-	if (!plen)
-		tb->tb_num_default--;
-
-	fib_remove_alias(t, tp, l, fa_to_delete);
-
 	if (fa_to_delete->fa_state & FA_S_ACCESSED)
 		rt_cache_flush(cfg->fc_nlinfo.nl_net);
 
@@ -1810,12 +1810,12 @@ int fib_table_flush(struct net *net, struct fib_table *tb)
 				continue;
 			}
 
+			hlist_del_rcu(&fa->fa_list);
 			call_fib_entry_notifiers(net, FIB_EVENT_ENTRY_DEL,
 						 n->key,
 						 KEYLENGTH - fa->fa_slen,
 						 fi, fa->fa_tos, fa->fa_type,
 						 tb->tb_id, 0);
-			hlist_del_rcu(&fa->fa_list);
 			fib_release_info(fa->fa_info);
 			alias_free_mem_rcu(fa);
 			found++;
-- 
2.7.4
