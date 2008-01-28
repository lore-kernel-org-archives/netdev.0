From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH 5/6] [DCCP]: Merge now-reduced connect_init() function
Date: Mon, 28 Jan 2008 10:16:15 +0000
Message-ID: <1201515376-8280-6-git-send-email-gerrit@erg.abdn.ac.uk>
References: dccp_ccid3_dccp_probe__bug_fixes
 <1201515376-8280-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1201515376-8280-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1201515376-8280-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <1201515376-8280-4-git-send-email-gerrit@erg.abdn.ac.uk>
 <1201515376-8280-5-git-send-email-gerrit@erg.abdn.ac.uk>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
	Gerrit Renker <gerrit@erg.abdn.ac.uk>
To: acme@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:60508 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755157AbYA1KSD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2008 05:18:03 -0500
In-Reply-To: <1201515376-8280-5-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After moving the assignment of GAR/ISS from dccp_connect_init() to
dccp_transmit_skb(), the former function becomes very small, so that
a merger with dccp_connect() suggested itself.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/output.c |   18 +++++-------------
 1 files changed, 5 insertions(+), 13 deletions(-)

--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -444,8 +444,9 @@ int dccp_send_reset(struct sock *sk, enum dccp_reset_codes code)
 /*
  * Do all connect socket setups that can be done AF independent.
  */
-static inline void dccp_connect_init(struct sock *sk)
+int dccp_connect(struct sock *sk)
 {
+	struct sk_buff *skb;
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct dst_entry *dst = __sk_dst_get(sk);
 	struct inet_connection_sock *icsk = inet_csk(sk);
@@ -455,22 +456,12 @@ static inline void dccp_connect_init(struct sock *sk)
 
 	dccp_sync_mss(sk, dst_mtu(dst));
 
-	/* Initialise GAR as per 8.5; AWL/AWH are set in dccp_transmit_skb() */
-	dp->dccps_gar = dp->dccps_iss;
-
-	icsk->icsk_retransmits = 0;
-}
-
-int dccp_connect(struct sock *sk)
-{
-	struct sk_buff *skb;
-	struct inet_connection_sock *icsk = inet_csk(sk);
-
 	/* do not connect if feature negotiation setup fails */
 	if (dccp_feat_finalise_settings(dccp_sk(sk)))
 		return -EPROTO;
 
-	dccp_connect_init(sk);
+	/* Initialise GAR as per 8.5; AWL/AWH are set in dccp_transmit_skb() */
+	dp->dccps_gar = dp->dccps_iss;
 
 	skb = alloc_skb(sk->sk_prot->max_header, sk->sk_allocation);
 	if (unlikely(skb == NULL))
@@ -486,6 +477,7 @@ int dccp_connect(struct sock *sk)
 	DCCP_INC_STATS(DCCP_MIB_ACTIVEOPENS);
 
 	/* Timer for repeating the REQUEST until an answer. */
+	icsk->icsk_retransmits = 0;
 	inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
 				  icsk->icsk_rto, DCCP_RTO_MAX);
 	return 0;
