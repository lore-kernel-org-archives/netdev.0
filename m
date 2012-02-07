From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 09/15] tipc: Add missing locks in broadcast link statistics accumulation
Date: Mon,  6 Feb 2012 19:52:42 -0500
Message-ID: <1328575968-20643-10-git-send-email-paul.gortmaker@windriver.com>
References: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50193 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756468Ab2BGAxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 19:53:15 -0500
In-Reply-To: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Ensures that all attempts to update broadcast link statistics are done
only while holding the lock that protects the link's main data structures,
to prevent interference by simultaneous updates caused by messages
arriving on other interfaces.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 035b350..facc216 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -520,6 +520,7 @@ void tipc_bclink_recv_pkt(struct sk_buff *buf)
 
 	if (likely(seqno == next_in)) {
 receive:
+		spin_lock_bh(&bc_lock);
 		bcl->stats.recv_info++;
 		node->bclink.last_in++;
 		bclink_set_gap(node);
@@ -527,7 +528,9 @@ receive:
 			bclink_send_ack(node);
 			bcl->stats.sent_acks++;
 		}
+
 		if (likely(msg_isdata(msg))) {
+			spin_unlock_bh(&bc_lock);
 			tipc_node_unlock(node);
 			if (likely(msg_mcast(msg)))
 				tipc_port_recv_mcast(buf, NULL);
@@ -536,6 +539,7 @@ receive:
 		} else if (msg_user(msg) == MSG_BUNDLER) {
 			bcl->stats.recv_bundles++;
 			bcl->stats.recv_bundled += msg_msgcnt(msg);
+			spin_unlock_bh(&bc_lock);
 			tipc_node_unlock(node);
 			tipc_link_recv_bundle(buf);
 		} else if (msg_user(msg) == MSG_FRAGMENTER) {
@@ -543,12 +547,15 @@ receive:
 			if (tipc_link_recv_fragment(&node->bclink.defragm,
 						    &buf, &msg))
 				bcl->stats.recv_fragmented++;
+			spin_unlock_bh(&bc_lock);
 			tipc_node_unlock(node);
 			tipc_net_route_msg(buf);
 		} else if (msg_user(msg) == NAME_DISTRIBUTOR) {
+			spin_unlock_bh(&bc_lock);
 			tipc_node_unlock(node);
 			tipc_named_recv(buf);
 		} else {
+			spin_unlock_bh(&bc_lock);
 			tipc_node_unlock(node);
 			buf_discard(buf);
 		}
@@ -601,11 +608,15 @@ receive:
 	} else
 		deferred = 0;
 
+	spin_lock_bh(&bc_lock);
+
 	if (deferred)
 		bcl->stats.deferred_recv++;
 	else
 		bcl->stats.duplicates++;
 
+	spin_unlock_bh(&bc_lock);
+
 unlock:
 	tipc_node_unlock(node);
 exit:
-- 
1.7.9
