From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH -next] net/hsr: using kfree_rcu() to simplify the code
Date: Mon, 16 Dec 2013 14:05:50 +0800
Message-ID: <CAPgLHd_doYrTYAHyR4OrDz9B84Abh1H0MBvmi8XfCqAEVFyS_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yongjun_wei@trendmicro.com.cn, netdev@vger.kernel.org
To: davem@davemloft.net, Arvid.Brodin@xdin.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f42.google.com ([209.85.214.42]:39468 "EHLO
	mail-bk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863Ab3LPGFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 01:05:51 -0500
Received: by mail-bk0-f42.google.com with SMTP id w11so2175391bkz.29
        for <netdev@vger.kernel.org>; Sun, 15 Dec 2013 22:05:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

The callback function of call_rcu() just calls a kfree(), so we
can use kfree_rcu() instead of call_rcu() + callback function.

Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
---
 net/hsr/hsr_framereg.c | 13 ++++---------
 1 file changed, 4 insertions(+), 9 deletions(-)

diff --git a/net/hsr/hsr_framereg.c b/net/hsr/hsr_framereg.c
index 003f5bb..a758963 100644
--- a/net/hsr/hsr_framereg.c
+++ b/net/hsr/hsr_framereg.c
@@ -127,11 +127,6 @@ int hsr_create_self_node(struct list_head *self_node_db,
 	return 0;
 }
 
-static void node_entry_reclaim(struct rcu_head *rh)
-{
-	kfree(container_of(rh, struct node_entry, rcu_head));
-}
-
 
 /* Add/merge node to the database of nodes. 'skb' must contain an HSR
  * supervision frame.
@@ -175,7 +170,7 @@ struct node_entry *hsr_merge_node(struct hsr_priv *hsr_priv,
 	if (node && !ether_addr_equal(node->MacAddressA, hsr_sp->MacAddressA)) {
 		/* Node has changed its AddrA, frame was received from SlaveB */
 		list_del_rcu(&node->mac_list);
-		call_rcu(&node->rcu_head, node_entry_reclaim);
+		kfree_rcu(node, rcu_head);
 		node = NULL;
 	}
 
@@ -183,7 +178,7 @@ struct node_entry *hsr_merge_node(struct hsr_priv *hsr_priv,
 	    !ether_addr_equal(node->MacAddressB, hsr_ethsup->ethhdr.h_source)) {
 		/* Cables have been swapped */
 		list_del_rcu(&node->mac_list);
-		call_rcu(&node->rcu_head, node_entry_reclaim);
+		kfree_rcu(node, rcu_head);
 		node = NULL;
 	}
 
@@ -192,7 +187,7 @@ struct node_entry *hsr_merge_node(struct hsr_priv *hsr_priv,
 	    !ether_addr_equal(node->MacAddressA, hsr_ethsup->ethhdr.h_source)) {
 		/* Cables have been swapped */
 		list_del_rcu(&node->mac_list);
-		call_rcu(&node->rcu_head, node_entry_reclaim);
+		kfree_rcu(node, rcu_head);
 		node = NULL;
 	}
 
@@ -416,7 +411,7 @@ void hsr_prune_nodes(struct hsr_priv *hsr_priv)
 			hsr_nl_nodedown(hsr_priv, node->MacAddressA);
 			list_del_rcu(&node->mac_list);
 			/* Note that we need to free this entry later: */
-			call_rcu(&node->rcu_head, node_entry_reclaim);
+			kfree_rcu(node, rcu_head);
 		}
 	}
 	rcu_read_unlock();
