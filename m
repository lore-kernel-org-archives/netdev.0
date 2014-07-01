From: <erik.hugne@ericsson.com>
Subject: [PATCH net-next 2/2] tipc: fix link acknowledge logic in receive path
Date: Tue, 1 Jul 2014 10:22:41 +0200
Message-ID: <1404202961-30262-3-git-send-email-erik.hugne@ericsson.com>
References: <1404202961-30262-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tipc-discussion@lists.sourceforge.net>,
	<carl.sigurjonsson@ericsson.com>,
	Erik Hugne <erik.hugne@ericsson.com>
To: <netdev@vger.kernel.org>, <jon.maloy@ericsson.com>,
	<ying.xue@windriver.com>, <richard.alpe@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:57388 "EHLO
	sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755903AbaGAITr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 04:19:47 -0400
In-Reply-To: <1404202961-30262-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erik Hugne <erik.hugne@ericsson.com>

Link state acks triggered from the receive path is done before
the last received packet have been processed by the link layer.
The effect of this is that the last received packet will not be
included in the ack. This causes problems if the link window is
set to TIPC_MIN_LINK_WIN, where the ack interval will be equal to
the link tolerance, and the link enters a stop-and-go behavior.
We move the ack logic to after link state processing, just before
the packet is delivered to higher layers.

Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>
Signed-off-by: Carl Sigurjonsson <carl.sigurjonsson@ericsson.com>
Reviewed-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/link.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 18b1524..a235b24 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1422,11 +1422,6 @@ void tipc_rcv(struct sk_buff *head, struct tipc_bearer *b_ptr)
 		if (unlikely(!list_empty(&l_ptr->waiting_ports)))
 			tipc_link_wakeup_ports(l_ptr, 0);
 
-		if (unlikely(++l_ptr->unacked_window >= TIPC_MIN_LINK_WIN)) {
-			l_ptr->stats.sent_acks++;
-			tipc_link_proto_xmit(l_ptr, STATE_MSG, 0, 0, 0, 0, 0);
-		}
-
 		/* Process the incoming packet */
 		if (unlikely(!link_working_working(l_ptr))) {
 			if (msg_user(msg) == LINK_PROTOCOL) {
@@ -1460,6 +1455,11 @@ void tipc_rcv(struct sk_buff *head, struct tipc_bearer *b_ptr)
 		if (unlikely(l_ptr->oldest_deferred_in))
 			head = link_insert_deferred_queue(l_ptr, head);
 
+		if (unlikely(++l_ptr->unacked_window >= TIPC_MIN_LINK_WIN)) {
+			l_ptr->stats.sent_acks++;
+			tipc_link_proto_xmit(l_ptr, STATE_MSG, 0, 0, 0, 0, 0);
+		}
+
 		if (tipc_link_prepare_input(l_ptr, &buf)) {
 			tipc_node_unlock(n_ptr);
 			continue;
-- 
1.8.3.2
