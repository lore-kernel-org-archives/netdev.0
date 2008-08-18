From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: net-2.6 [BUG-FIX] [PATCH 1/1]  dccp: Fix panic in retransmission
	mechanism
Date: Mon, 18 Aug 2008 18:00:29 +0200
Message-ID: <20080818160029.GA30056@gerrit.erg.abdn.ac.uk>
References: <488FF324.6050706@cn.fujitsu.com> <20080730165141.GA10381@gerrit.erg.abdn.ac.uk> <489131B4.3090505@cn.fujitsu.com> <20080804104632.GC3482@gerrit.erg.abdn.ac.uk> <48A9027B.6090109@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Yongjun <yjwei@cn.fujitsu.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:60927 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752933AbYHRQAt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Aug 2008 12:00:49 -0400
Content-Disposition: inline
In-Reply-To: <48A9027B.6090109@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave, 

can you please consider this net-2.6 bug fix - this fixes a panic()
triggered for some packet exchanges.

Many thanks,
Gerrit

----------------------------> Patch <-----------------------------------
dccp: Fix panic caused by too early termination of retransmission mechanism

Thanks is due to Wei Yongjun for the detailed analysis and description of this
bug at http://marc.info/?l=dccp&m=121739364909199&w=2

The problem is that invalid packets received by a client in state REQUEST cause
the retransmission timer for the DCCP-Request to be reset. This includes freeing
the Request-skb ( in dccp_rcv_request_sent_state_process() ). As a consequence,
 * the arrival of further packets cause a double-free, triggering a panic(),
 * the connection then may hang, since further retransmissions are blocked.

This patch changes the order of statements so that the retransmission timer is
reset, and the pending Request freed, only if a valid Response has arrived (or
the number of sysctl-retries has been exhausted).

Further changes:
----------------
To be on the safe side, replaced __kfree_skb with kfree_skb so that if due to
unexpected circumstances the sk_send_head is NULL the WARN_ON is used instead.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/input.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -411,12 +411,6 @@ static int dccp_rcv_request_sent_state_p
 		struct dccp_sock *dp = dccp_sk(sk);
 		long tstamp = dccp_timestamp();
 
-		/* Stop the REQUEST timer */
-		inet_csk_clear_xmit_timer(sk, ICSK_TIME_RETRANS);
-		WARN_ON(sk->sk_send_head == NULL);
-		__kfree_skb(sk->sk_send_head);
-		sk->sk_send_head = NULL;
-
 		if (!between48(DCCP_SKB_CB(skb)->dccpd_ack_seq,
 			       dp->dccps_awl, dp->dccps_awh)) {
 			dccp_pr_debug("invalid ackno: S.AWL=%llu, "
@@ -441,6 +435,12 @@ static int dccp_rcv_request_sent_state_p
 				    DCCP_ACKVEC_STATE_RECEIVED))
 			goto out_invalid_packet; /* FIXME: change error code */
 
+		/* Stop the REQUEST timer */
+		inet_csk_clear_xmit_timer(sk, ICSK_TIME_RETRANS);
+		WARN_ON(sk->sk_send_head == NULL);
+		kfree_skb(sk->sk_send_head);
+		sk->sk_send_head = NULL;
+
 		dp->dccps_isr = DCCP_SKB_CB(skb)->dccpd_seq;
 		dccp_update_gsr(sk, dp->dccps_isr);
 		/*
