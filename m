From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 01/10] tipc: remove obsolete flush of stale reassembly buffer
Date: Fri, 7 Dec 2012 09:28:09 -0500
Message-ID: <1354890498-6448-2-git-send-email-paul.gortmaker@windriver.com>
References: <1354890498-6448-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jon Maloy <jon.maloy@ericsson.com>,
	Erik Hugne <erik.hugne@ericsson.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:62547 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030741Ab2LGO2b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 09:28:31 -0500
In-Reply-To: <1354890498-6448-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

Each link instance has a periodic job checking if there is a stale
ongoing message reassembly associated to the link. If no new
fragment has been received during the last 4*[link_tolerance] period,
it is assumed the missing fragment will never arrive. As a consequence,
the reassembly buffer is discarded, and a gap in the message sequence
occurs.

This assumption is wrong. After we abandoned our ambition to develop
packet routing for multi-cluster networks, only single-hop packet
transfer remains as an option. For those, all packets are guaranteed
to be delivered in sequence to the defragmentation layer. Any failure
to achieve sequenced delivery will eventually lead to link reset, and
the reassembly buffer will be flushed anyway.

So we just remove this periodic check, which is now obsolete.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
[PG: also delete get/inc_timer count, since they are now unused]
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c | 44 --------------------------------------------
 1 file changed, 44 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 87bf5aa..daa6080 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -97,7 +97,6 @@ static int  link_send_sections_long(struct tipc_port *sender,
 				    struct iovec const *msg_sect,
 				    u32 num_sect, unsigned int total_len,
 				    u32 destnode);
-static void link_check_defragm_bufs(struct tipc_link *l_ptr);
 static void link_state_event(struct tipc_link *l_ptr, u32 event);
 static void link_reset_statistics(struct tipc_link *l_ptr);
 static void link_print(struct tipc_link *l_ptr, const char *str);
@@ -271,7 +270,6 @@ static void link_timeout(struct tipc_link *l_ptr)
 	}
 
 	/* do all other link processing performed on a periodic basis */
-	link_check_defragm_bufs(l_ptr);
 
 	link_state_event(l_ptr, TIMEOUT_EVT);
 
@@ -2497,16 +2495,6 @@ static void set_expected_frags(struct sk_buff *buf, u32 exp)
 	msg_set_bcast_ack(buf_msg(buf), exp);
 }
 
-static u32 get_timer_cnt(struct sk_buff *buf)
-{
-	return msg_reroute_cnt(buf_msg(buf));
-}
-
-static void incr_timer_cnt(struct sk_buff *buf)
-{
-	msg_incr_reroute_cnt(buf_msg(buf));
-}
-
 /*
  * tipc_link_recv_fragment(): Called with node lock on. Returns
  * the reassembled buffer if message is complete.
@@ -2585,38 +2573,6 @@ int tipc_link_recv_fragment(struct sk_buff **pending, struct sk_buff **fb,
 	return 0;
 }
 
-/**
- * link_check_defragm_bufs - flush stale incoming message fragments
- * @l_ptr: pointer to link
- */
-static void link_check_defragm_bufs(struct tipc_link *l_ptr)
-{
-	struct sk_buff *prev = NULL;
-	struct sk_buff *next = NULL;
-	struct sk_buff *buf = l_ptr->defragm_buf;
-
-	if (!buf)
-		return;
-	if (!link_working_working(l_ptr))
-		return;
-	while (buf) {
-		u32 cnt = get_timer_cnt(buf);
-
-		next = buf->next;
-		if (cnt < 4) {
-			incr_timer_cnt(buf);
-			prev = buf;
-		} else {
-			if (prev)
-				prev->next = buf->next;
-			else
-				l_ptr->defragm_buf = buf->next;
-			kfree_skb(buf);
-		}
-		buf = next;
-	}
-}
-
 static void link_set_supervision_props(struct tipc_link *l_ptr, u32 tolerance)
 {
 	if ((tolerance < TIPC_MIN_LINK_TOL) || (tolerance > TIPC_MAX_LINK_TOL))
-- 
1.7.12.1
