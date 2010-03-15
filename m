From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] tipc: Allow retransmission of cloned buffers
Date: Mon, 15 Mar 2010 13:58:45 -0400
Message-ID: <20100315175845.GB24528@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, allan.stephens@windriver.com,
	nhorman@tuxdriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51588 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932963Ab0COR6v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 13:58:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Forward port commit
fc477e160af086f6e30c3d4fdf5f5c000d29beb5
from git://tipc.cslab.ericsson.net/pub/git/people/allan/tipc.git

Origional commit message:

Allow retransmission of cloned buffers

This patch fixes an issue with TIPC's message retransmission logic
that prevented retransmission of clone sk_buffs.  Originally intended
as a means of avoiding wasted work in retransmitting messages that
were still on the driver's outbound queue, it also prevented TIPC
from retransmitting messages through other means -- such as the
secondary bearer of the broadcast link, or another interface in a
set of bonded interfaces.  This fix removes existing checks for
cloned sk_buffs that prevented such retransmission.

Origionally-Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 1a7e466..49f2be8 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1553,7 +1553,7 @@ u32 tipc_link_push_packet(struct link *l_ptr)
 
 	/* Continue retransmission now, if there is anything: */
 
-	if (r_q_size && buf && !skb_cloned(buf)) {
+	if (r_q_size && buf) {
 		msg_set_ack(buf_msg(buf), mod(l_ptr->next_in_no - 1));
 		msg_set_bcast_ack(buf_msg(buf), l_ptr->owner->bclink.last_in);
 		if (tipc_bearer_send(l_ptr->b_ptr, buf, &l_ptr->media_addr)) {
@@ -1722,15 +1722,16 @@ void tipc_link_retransmit(struct link *l_ptr, struct sk_buff *buf,
 	dbg("Retransmitting %u in link %x\n", retransmits, l_ptr);
 
 	if (tipc_bearer_congested(l_ptr->b_ptr, l_ptr)) {
-		if (!skb_cloned(buf)) {
+		if (l_ptr->retransm_queue_size == 0) {
 			msg_dbg(msg, ">NO_RETR->BCONG>");
 			dbg_print_link(l_ptr, "   ");
 			l_ptr->retransm_queue_head = msg_seqno(msg);
 			l_ptr->retransm_queue_size = retransmits;
-			return;
 		} else {
-			/* Don't retransmit if driver already has the buffer */
+			err("Unexpected retransmit on link %s (qsize=%d)\n",
+			    l_ptr->name, l_ptr->retransm_queue_size);
 		}
+		return;
 	} else {
 		/* Detect repeated retransmit failures on uncongested bearer */
 
@@ -1745,7 +1746,7 @@ void tipc_link_retransmit(struct link *l_ptr, struct sk_buff *buf,
 		}
 	}
 
-	while (retransmits && (buf != l_ptr->next_out) && buf && !skb_cloned(buf)) {
+	while (retransmits && (buf != l_ptr->next_out) && buf) {
 		msg = buf_msg(buf);
 		msg_set_ack(msg, mod(l_ptr->next_in_no - 1));
 		msg_set_bcast_ack(msg, l_ptr->owner->bclink.last_in);
