From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net v1 1/6] tipc: fix nametbl_lock soft lockup at node/link events
Date: Tue, 24 Jan 2017 13:00:43 +0100
Message-ID: <1485259248-21812-2-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1485259248-21812-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>, <jon.maloy@ericsson.com>,
        <ying.xue@windriver.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:64317 "EHLO
        sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750974AbdAXMBz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 07:01:55 -0500
In-Reply-To: <1485259248-21812-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We trigger a soft lockup as we grab nametbl_lock twice if the node
has a pending node up/down or link up/down event while:
- we process an incoming named message in tipc_named_rcv() and
  perform an tipc_update_nametbl().
- we have pending backlog items in the name distributor queue
  during a nametable update using tipc_nametbl_publish() or
  tipc_nametbl_withdraw().

The following are the call chain associated:
tipc_named_rcv() Grabs nametbl_lock
   tipc_update_nametbl() (publish/withdraw)
     tipc_node_subscribe()/unsubscribe()
       tipc_node_write_unlock()
          << lockup occurs if an outstanding node/link event
             exits, as we grabs nametbl_lock again >>

tipc_nametbl_withdraw() Grab nametbl_lock
  tipc_named_process_backlog()
    tipc_update_nametbl()
      << rest as above >>

The function tipc_node_write_unlock(), in addition to releasing the
lock processes the outstanding node/link up/down events. To do this,
we need to grab the nametbl_lock again leading to the lockup.

In this commit we fix the soft lockup by introducing a fast variant of
node_unlock(), where we just release the lock. We adapt the
node_subscribe()/node_unsubscribe() to use the fast variants.

Reported-and-Tested-by: John Thompson <thompa.atl@gmail.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/node.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/tipc/node.c b/net/tipc/node.c
index 9d2f4c2b08ab..27753325e06e 100644
--- a/net/tipc/node.c
+++ b/net/tipc/node.c
@@ -263,6 +263,11 @@ static void tipc_node_write_lock(struct tipc_node *n)
 	write_lock_bh(&n->lock);
 }
 
+static void tipc_node_write_unlock_fast(struct tipc_node *n)
+{
+	write_unlock_bh(&n->lock);
+}
+
 static void tipc_node_write_unlock(struct tipc_node *n)
 {
 	struct net *net = n->net;
@@ -417,7 +422,7 @@ void tipc_node_subscribe(struct net *net, struct list_head *subscr, u32 addr)
 	}
 	tipc_node_write_lock(n);
 	list_add_tail(subscr, &n->publ_list);
-	tipc_node_write_unlock(n);
+	tipc_node_write_unlock_fast(n);
 	tipc_node_put(n);
 }
 
@@ -435,7 +440,7 @@ void tipc_node_unsubscribe(struct net *net, struct list_head *subscr, u32 addr)
 	}
 	tipc_node_write_lock(n);
 	list_del_init(subscr);
-	tipc_node_write_unlock(n);
+	tipc_node_write_unlock_fast(n);
 	tipc_node_put(n);
 }
 
-- 
2.1.4
