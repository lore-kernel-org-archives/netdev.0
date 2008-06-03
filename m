From: "Adam Langley" <agl@imperialviolet.org>
Subject: [PATCH] Fix corrupt TCP packets when options space overflows with MD5SIG enabled (v2)
Date: Tue, 3 Jun 2008 14:52:00 -0700
Message-ID: <396556a20805301217k293e5718h6bbf02bfe0683144@europa>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.249]:3308 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920AbYFCWST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 18:18:19 -0400
Received: by hs-out-0708.google.com with SMTP id 4so1181610hsl.5
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2008 15:18:14 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When MD5 signatures are turned on we can end up with syntactically invalid
packets with a header length < 20 bytes. This is because tcp_header_size
overflows with 12 bytes of timestamp, 20 bytes of signature and > 8 bytes of
SACK option.

Since we can't fit any SACK blocks in the final 8 bytes of options space, and
the MD5 signature is more important, we disable including SACK, or even
advertising it, when MD5 is enabled.

Signed-off-by: Adam Langley <agl@imperialviolet.org>

---
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e399bde..ced7241 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -358,7 +358,7 @@ static void tcp_build_and_update_options(__be32 *ptr, struct tcp_sock *tp,
 		*ptr++ = htonl(tstamp);
 		*ptr++ = htonl(tp->rx_opt.ts_recent);
 	}
-	if (tp->rx_opt.eff_sacks) {
+	if (!md5_hash && tp->rx_opt.eff_sacks) {
 		struct tcp_sack_block *sp = tp->rx_opt.dsack ? tp->duplicate_sack : tp->selective_acks;
 		int this_sack;
 
@@ -470,12 +470,12 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 			    gfp_t gfp_mask)
 {
 	const struct inet_connection_sock *icsk = inet_csk(sk);
+	struct tcp_md5sig_key *md5 = NULL;
 	struct inet_sock *inet;
 	struct tcp_sock *tp;
 	struct tcp_skb_cb *tcb;
 	int tcp_header_size;
 #ifdef CONFIG_TCP_MD5SIG
-	struct tcp_md5sig_key *md5;
 	__u8 *md5_hash_location;
 #endif
 	struct tcphdr *th;
@@ -504,13 +504,25 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	tcb = TCP_SKB_CB(skb);
 	tcp_header_size = tp->tcp_header_len;
 
+	if (unlikely(tcb->flags & TCPCB_FLAG_SYN))
+		tcp_header_size = sizeof(struct tcphdr) + TCPOLEN_MSS;
+
+#ifdef CONFIG_TCP_MD5SIG
+	/*
+	 * Are we doing MD5 on this segment? If so - make
+	 * room for it.
+	 */
+	md5 = tp->af_specific->md5_lookup(sk, sk);
+	if (md5)
+		tcp_header_size += TCPOLEN_MD5SIG_ALIGNED;
+#endif
+
 #define SYSCTL_FLAG_TSTAMPS	0x1
 #define SYSCTL_FLAG_WSCALE	0x2
 #define SYSCTL_FLAG_SACK	0x4
 
 	sysctl_flags = 0;
 	if (unlikely(tcb->flags & TCPCB_FLAG_SYN)) {
-		tcp_header_size = sizeof(struct tcphdr) + TCPOLEN_MSS;
 		if (sysctl_tcp_timestamps) {
 			tcp_header_size += TCPOLEN_TSTAMP_ALIGNED;
 			sysctl_flags |= SYSCTL_FLAG_TSTAMPS;
@@ -519,12 +531,15 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 			tcp_header_size += TCPOLEN_WSCALE_ALIGNED;
 			sysctl_flags |= SYSCTL_FLAG_WSCALE;
 		}
-		if (sysctl_tcp_sack) {
+		/* We don't include SACK options if we are going to
+		 * include an MD5 signature because they can't fit
+		 * in the options space */
+		if (sysctl_tcp_sack && !md5) {
 			sysctl_flags |= SYSCTL_FLAG_SACK;
 			if (!(sysctl_flags & SYSCTL_FLAG_TSTAMPS))
 				tcp_header_size += TCPOLEN_SACKPERM_ALIGNED;
 		}
-	} else if (unlikely(tp->rx_opt.eff_sacks)) {
+	} else if (unlikely(tp->rx_opt.eff_sacks && !md5)) {
 		/* A SACK is 2 pad bytes, a 2 byte header, plus
 		 * 2 32-bit sequence numbers for each SACK block.
 		 */
@@ -536,16 +551,6 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	if (tcp_packets_in_flight(tp) == 0)
 		tcp_ca_event(sk, CA_EVENT_TX_START);
 
-#ifdef CONFIG_TCP_MD5SIG
-	/*
-	 * Are we doing MD5 on this segment? If so - make
-	 * room for it.
-	 */
-	md5 = tp->af_specific->md5_lookup(sk, sk);
-	if (md5)
-		tcp_header_size += TCPOLEN_MD5SIG_ALIGNED;
-#endif
-
 	skb_push(skb, tcp_header_size);
 	skb_reset_transport_header(skb);
 	skb_set_owner_w(skb, sk);
@@ -974,6 +979,7 @@ unsigned int tcp_current_mss(struct sock *sk, int large_allowed)
 	u32 mss_now;
 	u16 xmit_size_goal;
 	int doing_tso = 0;
+	int md5_signing = 0;
 
 	mss_now = tp->mss_cache;
 
@@ -986,15 +992,17 @@ unsigned int tcp_current_mss(struct sock *sk, int large_allowed)
 			mss_now = tcp_sync_mss(sk, mtu);
 	}
 
-	if (tp->rx_opt.eff_sacks)
-		mss_now -= (TCPOLEN_SACK_BASE_ALIGNED +
-			    (tp->rx_opt.eff_sacks * TCPOLEN_SACK_PERBLOCK));
-
 #ifdef CONFIG_TCP_MD5SIG
-	if (tp->af_specific->md5_lookup(sk, sk))
+	if (tp->af_specific->md5_lookup(sk, sk)) {
+		md5_signing = 1;
 		mss_now -= TCPOLEN_MD5SIG_ALIGNED;
+	}
 #endif
 
+	if (!md5_signing && tp->rx_opt.eff_sacks)
+		mss_now -= (TCPOLEN_SACK_BASE_ALIGNED +
+			    (tp->rx_opt.eff_sacks * TCPOLEN_SACK_PERBLOCK));
+
 	xmit_size_goal = mss_now;
 
 	if (doing_tso) {
@@ -2193,6 +2201,13 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 
 	skb->dst = dst_clone(dst);
 
+#ifdef CONFIG_TCP_MD5SIG
+	md5 = tcp_rsk(req)->af_specific->md5_lookup(sk, req);
+	/* SACKs don't fit in the option space with MD5 sigs */
+	if (md5)
+		ireq->sack_ok = 0;
+#endif
+
 	tcp_header_size = (sizeof(struct tcphdr) + TCPOLEN_MSS +
 			   (ireq->tstamp_ok ? TCPOLEN_TSTAMP_ALIGNED : 0) +
 			   (ireq->wscale_ok ? TCPOLEN_WSCALE_ALIGNED : 0) +
@@ -2201,7 +2216,6 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 
 #ifdef CONFIG_TCP_MD5SIG
 	/* Are we doing MD5 on this segment? If so - make room for it */
-	md5 = tcp_rsk(req)->af_specific->md5_lookup(sk, req);
 	if (md5)
 		tcp_header_size += TCPOLEN_MD5SIG_ALIGNED;
 #endif
