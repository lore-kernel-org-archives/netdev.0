From: Sridhar Samudrala <sri@us.ibm.com>
Subject: [PATCH 1/1] [SCTP]: Force update of the rto when processing HB-ACK
Date: Tue, 30 Jan 2007 14:32:51 -0800
Message-ID: <1170196371.15598.34.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:54659 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751192AbXA3Wcy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jan 2007 17:32:54 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l0UMXVCL031095
	for <netdev@vger.kernel.org>; Tue, 30 Jan 2007 17:33:31 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0UMWqHG281902
	for <netdev@vger.kernel.org>; Tue, 30 Jan 2007 17:32:52 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0UMWqL8009740
	for <netdev@vger.kernel.org>; Tue, 30 Jan 2007 17:32:52 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[SCTP]: Force update of the rto when processing HB-ACK

When processing a HEARTBEAT-ACK it's possible that the transport rto
timers will not be updated because a prior T3-RTX processing would
have cleared the rto_pending flag on the transport.  However, if
we received a valid HEARTBEAT-ACK, we want to force update the
rto variables, so re-set the rto_pending flag before calling
sctp_transport_update_rto().

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
---
 net/sctp/sm_sideeffect.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
index 8bd3097..25c0277 100644
--- a/net/sctp/sm_sideeffect.c
+++ b/net/sctp/sm_sideeffect.c
@@ -621,7 +621,13 @@ static void sctp_cmd_transport_on(sctp_cmd_seq_t *cmds,
 	/* The receiver of the HEARTBEAT ACK should also perform an
 	 * RTT measurement for that destination transport address
 	 * using the time value carried in the HEARTBEAT ACK chunk.
+	 * If the transport's rto_pending variable has been cleared,
+	 * it was most likely due to a retransmit.  However, we want
+	 * to re-enable it to properly update the rto.
 	 */
+	if (t->rto_pending == 0)
+		t->rto_pending = 1;
+
 	hbinfo = (sctp_sender_hb_info_t *) chunk->skb->data;
 	sctp_transport_update_rto(t, (jiffies - hbinfo->sent_at));



