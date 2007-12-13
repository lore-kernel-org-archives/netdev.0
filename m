From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: [PATCH 07/12] [DCCP]: Add (missing) option parsing to request_sock processing
Date: Thu, 13 Dec 2007 13:06:00 -0200
Message-ID: <1197558365-31134-8-git-send-email-acme@redhat.com>
References: <1197558365-31134-1-git-send-email-acme@redhat.com>
 <1197558365-31134-2-git-send-email-acme@redhat.com>
 <1197558365-31134-3-git-send-email-acme@redhat.com>
 <1197558365-31134-4-git-send-email-acme@redhat.com>
 <1197558365-31134-5-git-send-email-acme@redhat.com>
 <1197558365-31134-6-git-send-email-acme@redhat.com>
 <1197558365-31134-7-git-send-email-acme@redhat.com>
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Ian McDonald <ian.mcdonald@jandi.co.nz>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.245]:3971 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757541AbXLMPG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 10:06:26 -0500
Received: by an-out-0708.google.com with SMTP id d31so185763and.103
        for <netdev@vger.kernel.org>; Thu, 13 Dec 2007 07:06:25 -0800 (PST)
In-Reply-To: <1197558365-31134-7-git-send-email-acme@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This adds option-parsing code to processing of Acks in the listening state
on request_socks on the server, serving two purposes
 (i)  resolves a FIXME (removed);
 (ii) paves the way for feature-negotiation during connection-setup.

There is an intended subtlety here with regard to dccp_check_req:

 Parsing options happens only after testing whether the received packet is
 a retransmitted Request.  Otherwise, if the Request contained (a possibly
 large number of) feature-negotiation options, recomputing state would have to
 happen each time a retransmitted Request arrives, which opens the door to an
 easy DoS attack.  Since in a genuine retransmission the options should not be
 different from the original, reusing the already computed state seems better.

 The other point is - if there are timestamp options on the Request, they will
 not be answered; which means that in the presence of retransmission (likely
 due to loss and/or other problems), the use of Request/Response RTT sampling
 is suspended, so that startup problems here do not propagate.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/minisocks.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 831b76e..b1d5da6 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -200,10 +200,10 @@ struct sock *dccp_check_req(struct sock *sk, struct sk_buff *skb,
 			    struct request_sock **prev)
 {
 	struct sock *child = NULL;
+	struct dccp_request_sock *dreq = dccp_rsk(req);
 
 	/* Check for retransmitted REQUEST */
 	if (dccp_hdr(skb)->dccph_type == DCCP_PKT_REQUEST) {
-		struct dccp_request_sock *dreq = dccp_rsk(req);
 
 		if (after48(DCCP_SKB_CB(skb)->dccpd_seq, dreq->dreq_isr)) {
 			dccp_pr_debug("Retransmitted REQUEST\n");
@@ -227,22 +227,22 @@ struct sock *dccp_check_req(struct sock *sk, struct sk_buff *skb,
 		goto drop;
 
 	/* Invalid ACK */
-	if (DCCP_SKB_CB(skb)->dccpd_ack_seq != dccp_rsk(req)->dreq_iss) {
+	if (DCCP_SKB_CB(skb)->dccpd_ack_seq != dreq->dreq_iss) {
 		dccp_pr_debug("Invalid ACK number: ack_seq=%llu, "
 			      "dreq_iss=%llu\n",
 			      (unsigned long long)
 			      DCCP_SKB_CB(skb)->dccpd_ack_seq,
-			      (unsigned long long)
-			      dccp_rsk(req)->dreq_iss);
+			      (unsigned long long) dreq->dreq_iss);
 		goto drop;
 	}
 
+	if (dccp_parse_options(sk, dreq, skb))
+		 goto drop;
+
 	child = inet_csk(sk)->icsk_af_ops->syn_recv_sock(sk, skb, req, NULL);
 	if (child == NULL)
 		goto listen_overflow;
 
-	/* FIXME: deal with options */
-
 	inet_csk_reqsk_queue_unlink(sk, req, prev);
 	inet_csk_reqsk_queue_removed(sk, req);
 	inet_csk_reqsk_queue_add(sk, req, child);
-- 
1.5.3.4

