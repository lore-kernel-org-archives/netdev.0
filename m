From: <richard.alpe@ericsson.com>
Subject: [PATCH net-next] tipc: fix socket list regression in new nl api
Date: Fri, 16 Jan 2015 12:30:40 +0100
Message-ID: <1421407840-30726-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
	Richard Alpe <richard.alpe@ericsson.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg23.ericsson.net ([193.180.251.37]:42695 "EHLO
	sesbmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751952AbbAPLt5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 06:49:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Alpe <richard.alpe@ericsson.com>

Commit 07f6c4bc (tipc: convert tipc reference table to use generic
rhashtable) introduced a problem with port listing in the new netlink
API. It broke the resume functionality resulting in a never ending
loop. This was caused by starting with the first hash table every time
subsequently never returning an empty skb (terminating).

This patch fixes the resume mechanism by keeping a logical reference
to the last hash table along with a logical reference to the socket
(port) that didn't fit in the previous message.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/socket.c | 30 ++++++++++++++++++------------
 1 file changed, 18 insertions(+), 12 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 720fda6..679a220 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2749,29 +2749,35 @@ int tipc_nl_sk_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	struct tipc_sock *tsk;
 	const struct bucket_table *tbl;
 	struct rhash_head *pos;
-	u32 prev_portid = cb->args[0];
-	u32 portid = prev_portid;
 	struct net *net = sock_net(skb->sk);
 	struct tipc_net *tn = net_generic(net, tipc_net_id);
-	int i;
+	u32 tbl_id = cb->args[0];
+	u32 prev_portid = cb->args[1];
 
 	rcu_read_lock();
 	tbl = rht_dereference_rcu((&tn->sk_rht)->tbl, &tn->sk_rht);
-	for (i = 0; i < tbl->size; i++) {
-		rht_for_each_entry_rcu(tsk, pos, tbl, i, node) {
+	for (; tbl_id < tbl->size; tbl_id++) {
+		rht_for_each_entry_rcu(tsk, pos, tbl, tbl_id, node) {
 			spin_lock_bh(&tsk->sk.sk_lock.slock);
-			portid = tsk->portid;
+			if (prev_portid && prev_portid != tsk->portid) {
+				spin_unlock_bh(&tsk->sk.sk_lock.slock);
+				continue;
+			}
+
 			err = __tipc_nl_add_sk(skb, cb, tsk);
+			if (err) {
+				prev_portid = tsk->portid;
+				spin_unlock_bh(&tsk->sk.sk_lock.slock);
+				goto out;
+			}
+			prev_portid = 0;
 			spin_unlock_bh(&tsk->sk.sk_lock.slock);
-			if (err)
-				break;
-
-			prev_portid = portid;
 		}
 	}
+out:
 	rcu_read_unlock();
-
-	cb->args[0] = prev_portid;
+	cb->args[0] = tbl_id;
+	cb->args[1] = prev_portid;
 
 	return skb->len;
 }
-- 
2.1.3
