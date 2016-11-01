From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net-next v2 08/16] tipc: remove probing_intv from tipc_sock
Date: Tue, 1 Nov 2016 14:02:41 +0100
Message-ID: <1478005369-17239-9-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1478005369-17239-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>, <jon.maloy@ericsson.com>,
        <maloy@donjonn.com>, <ying.xue@windriver.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg23.ericsson.net ([193.180.251.45]:65510 "EHLO
        sessmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1423512AbcKANDp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 09:03:45 -0400
In-Reply-To: <1478005369-17239-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Until now, probing_intv is a variable in struct tipc_sock but is
always set to a constant CONN_PROBING_INTERVAL. The socket
connection is probed based on this value.

In this commit, we remove this variable and setup the socket
timer based on the constant CONN_PROBING_INTERVAL.

There is no functional change in this commit.

Acked-by: Ying Xue <ying.xue@windriver.com>
Acked-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
---
 net/tipc/socket.c | 19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 7b6a1847cf8a..1b1aa941cd06 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -67,7 +67,6 @@
  * @publications: list of publications for port
  * @pub_count: total # of publications port has made during its lifetime
  * @probing_state:
- * @probing_intv:
  * @conn_timeout: the time we can wait for an unresponded setup request
  * @dupl_rcvcnt: number of bytes counted twice, in both backlog and rcv queue
  * @link_cong: non-zero if owner must sleep because of link congestion
@@ -89,7 +88,6 @@ struct tipc_sock {
 	struct list_head publications;
 	u32 pub_count;
 	u32 probing_state;
-	unsigned long probing_intv;
 	uint conn_timeout;
 	atomic_t dupl_rcvcnt;
 	bool link_cong;
@@ -1153,9 +1151,8 @@ static void tipc_sk_finish_conn(struct tipc_sock *tsk, u32 peer_port,
 	msg_set_lookup_scope(msg, 0);
 	msg_set_hdr_sz(msg, SHORT_H_SIZE);
 
-	tsk->probing_intv = CONN_PROBING_INTERVAL;
 	tsk->probing_state = TIPC_CONN_OK;
-	sk_reset_timer(sk, &sk->sk_timer, jiffies + tsk->probing_intv);
+	sk_reset_timer(sk, &sk->sk_timer, jiffies + CONN_PROBING_INTERVAL);
 	tipc_node_add_conn(net, peer_node, tsk->portid, peer_port);
 	tsk->max_pkt = tipc_node_get_mtu(net, peer_node, tsk->portid);
 	tsk->peer_caps = tipc_node_get_capabilities(net, peer_node);
@@ -2240,13 +2237,15 @@ static void tipc_sk_timeout(unsigned long data)
 			sk_reset_timer(sk, &sk->sk_timer, (HZ / 20));
 		}
 
-	} else {
-		skb = tipc_msg_create(CONN_MANAGER, CONN_PROBE,
-				      INT_H_SIZE, 0, peer_node, own_node,
-				      peer_port, tsk->portid, TIPC_OK);
-		tsk->probing_state = TIPC_CONN_PROBING;
-		sk_reset_timer(sk, &sk->sk_timer, jiffies + tsk->probing_intv);
+		bh_unlock_sock(sk);
+		goto exit;
 	}
+
+	skb = tipc_msg_create(CONN_MANAGER, CONN_PROBE,
+			      INT_H_SIZE, 0, peer_node, own_node,
+			      peer_port, tsk->portid, TIPC_OK);
+	tsk->probing_state = TIPC_CONN_PROBING;
+	sk_reset_timer(sk, &sk->sk_timer, jiffies + CONN_PROBING_INTERVAL);
 	bh_unlock_sock(sk);
 	if (skb)
 		tipc_node_xmit_skb(sock_net(sk), skb, peer_node, tsk->portid);
-- 
2.1.4
