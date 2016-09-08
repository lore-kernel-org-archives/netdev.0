From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 2/6] sctp: do not return the transmit err back to sctp_sendmsg
Date: Thu,  8 Sep 2016 17:31:46 +0800
Message-ID: <ad1ec83498ce1305938a36c634fd470b37dc274d.1473326067.git.lucien.xin@gmail.com>
References: <cover.1473326067.git.lucien.xin@gmail.com>
 <1718155e984f63995d1be9b053c58aa1a645718e.1473326067.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net
To: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34457 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758673AbcIHJcG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 05:32:06 -0400
In-Reply-To: <1718155e984f63995d1be9b053c58aa1a645718e.1473326067.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1473326067.git.lucien.xin@gmail.com>
References: <cover.1473326067.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Once a chunk is enqueued successfully, sctp queues can take care of it.
Even if it is failed to transmit (like because of nomem), it should be
put into retransmit queue.

If sctp report this error to users, it confuses them, they may resend
that msg, but actually in kernel sctp stack is in charge of retransmit
it already.

Besides, this error probably is not from the failure of transmitting
current msg, but transmitting or retransmitting another msg's chunks,
as sctp_outq_flush just tries to send out all transports' chunks.

This patch is to make sctp_cmd_send_msg return avoid, and not return the
transmit err back to sctp_sendmsg

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/sctp/sm_sideeffect.c | 16 +++++-----------
 1 file changed, 5 insertions(+), 11 deletions(-)

diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 12d4519..cf6e4f0 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -1020,19 +1020,13 @@ static void sctp_cmd_t1_timer_update(struct sctp_association *asoc,
  * This way the whole message is queued up and bundling if
  * encouraged for small fragments.
  */
-static int sctp_cmd_send_msg(struct sctp_association *asoc,
-				struct sctp_datamsg *msg, gfp_t gfp)
+static void sctp_cmd_send_msg(struct sctp_association *asoc,
+			      struct sctp_datamsg *msg, gfp_t gfp)
 {
 	struct sctp_chunk *chunk;
-	int error = 0;
-
-	list_for_each_entry(chunk, &msg->chunks, frag_list) {
-		error = sctp_outq_tail(&asoc->outqueue, chunk, gfp);
-		if (error)
-			break;
-	}
 
-	return error;
+	list_for_each_entry(chunk, &msg->chunks, frag_list)
+		sctp_outq_tail(&asoc->outqueue, chunk, gfp);
 }
 
 
@@ -1709,7 +1703,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
 				sctp_outq_cork(&asoc->outqueue);
 				local_cork = 1;
 			}
-			error = sctp_cmd_send_msg(asoc, cmd->obj.msg, gfp);
+			sctp_cmd_send_msg(asoc, cmd->obj.msg, gfp);
 			break;
 		case SCTP_CMD_SEND_NEXT_ASCONF:
 			sctp_cmd_send_asconf(asoc);
-- 
2.1.0
