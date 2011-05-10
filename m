From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 12/21] tipc: Fix sk_buff leaks when link congestion is detected
Date: Tue, 10 May 2011 16:44:28 -0400
Message-ID: <1305060277-15600-13-git-send-email-paul.gortmaker@windriver.com>
References: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Allan Stephens <allan.stephens@windriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:52408 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752597Ab1EJUpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 16:45:05 -0400
In-Reply-To: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Modifies a TIPC send routine that did not discard the outgoing sk_buff
if it was not transmitted because of link congestion; this eliminates
the potential for buffer leakage in the many callers who did not clean up
the unsent buffer. (The two routines that previously did discard the unsent
buffer have been updated to eliminate their now-redundant clean up.)

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bcast.c |    4 +---
 net/tipc/link.c  |    7 +++----
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 08e3216..fa68d1e 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -407,9 +407,7 @@ int tipc_bclink_send_msg(struct sk_buff *buf)
 	spin_lock_bh(&bc_lock);
 
 	res = tipc_link_send_buf(bcl, buf);
-	if (unlikely(res == -ELINKCONG))
-		buf_discard(buf);
-	else
+	if (likely(res > 0))
 		bclink_set_last_sent();
 
 	bcl->stats.queue_sz_counts++;
diff --git a/net/tipc/link.c b/net/tipc/link.c
index 02b083e..2a9f44a 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -864,8 +864,9 @@ int tipc_link_send_buf(struct link *l_ptr, struct sk_buff *buf)
 
 	if (unlikely(queue_size >= queue_limit)) {
 		if (imp <= TIPC_CRITICAL_IMPORTANCE) {
-			return link_schedule_port(l_ptr, msg_origport(msg),
-						  size);
+			link_schedule_port(l_ptr, msg_origport(msg), size);
+			buf_discard(buf);
+			return -ELINKCONG;
 		}
 		buf_discard(buf);
 		if (imp > CONN_MANAGER) {
@@ -1069,8 +1070,6 @@ again:
 			if (likely(buf)) {
 				res = link_send_buf_fast(l_ptr, buf,
 							 &sender->max_pkt);
-				if (unlikely(res < 0))
-					buf_discard(buf);
 exit:
 				tipc_node_unlock(node);
 				read_unlock_bh(&tipc_net_lock);
-- 
1.7.4.4

