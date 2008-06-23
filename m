From: "Adam Langley" <agl@imperialviolet.org>
Subject: [PATCH] TCP options clean up
Date: Mon, 23 Jun 2008 15:20:57 -0700
Message-ID: <396556a20805301217k293e5718h6bbf02bfe0683148@europa>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hs-out-0708.google.com ([64.233.178.243]:10061 "EHLO
	hs-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755416AbYFWXJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 19:09:17 -0400
Received: by hs-out-0708.google.com with SMTP id 4so416876hsl.5
        for <netdev@vger.kernel.org>; Mon, 23 Jun 2008 16:09:16 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adam Langley <agl@imperialviolet.org>

TCP: options clean up

This should fix the following bugs:
  * Connections with MD5 signatures produce invalid packets whenever SACK
    options are included
  * MD5 signatures are counted twice in the MSS calculations

Behaviour changes:
  * A SYN with MD5 + SACK + TS elicits a SYNACK with MD5 + SACK

    This is because we can't fit any SACK blocks in a packet with MD5 + TS
    options. There was discussion about disabling SACK rather than TS in order
    to fit in better with old, buggy kernels, but that was deemed to be
    unnecessary.

  * SYNs with MD5 don't include a TS option

    See above.

Additionally, it removes a bunch of duplicated logic for calculating options,
which should help avoid these sort of issues in the future.

Signed-off-by: Adam Langley <agl@imperialviolet.org>

---

I wish that I could get diff to output bigger chunks. This diff is
pretty hard to read because of the many small chunks that diff finds.

Also, there will be a future patch to remove all of the max() calls in
tcp_input.c which are trying to calculate the number of SACK blocks that will
fit in a packet. This code subsumes that.

 include/net/tcp.h     |    2
 net/ipv4/tcp_output.c |  426 +++++++++++++++++++++++++++----------------------
 2 files changed, 234 insertions(+), 194 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 633147c..9164d2f 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -50,6 +50,7 @@ extern atomic_t tcp_orphan_count;
 extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 
 #define MAX_TCP_HEADER	(128 + MAX_HEADER)
+#define MAX_TCP_OPTION_SPACE 40
 
 /* 
  * Never offer a window over 32767 without using window scaling. Some
@@ -185,6 +186,7 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOLEN_SACK_BASE_ALIGNED	4
 #define TCPOLEN_SACK_PERBLOCK		8
 #define TCPOLEN_MD5SIG_ALIGNED		20
+#define TCPOLEN_MSS_ALIGNED		4
 
 /* Flags in tp->nonagle */
 #define TCP_NAGLE_OFF		1	/* Nagle's algo is disabled */
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e399bde..7ada03d 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -347,28 +347,81 @@ static void tcp_init_nondata_skb(struct sk_buff *skb, u32 seq, u8 flags)
 	TCP_SKB_CB(skb)->end_seq = seq;
 }
 
-static void tcp_build_and_update_options(__be32 *ptr, struct tcp_sock *tp,
-					 __u32 tstamp, __u8 **md5_hash)
-{
-	if (tp->rx_opt.tstamp_ok) {
+#define OPTION_SACK_ADVERTISE	(1 << 0)
+#define OPTION_TS		(1 << 1)
+#define OPTION_MD5		(1 << 2)
+
+struct tcp_out_options {
+	unsigned options;		/* bit field of OPTION_* */
+	unsigned mss;			/* 0 to disable */
+	unsigned ws;			/* window scale, 0 to disable */
+	__u32 tsval, tsecr;		/* need to include OPTION_TS */
+	unsigned num_sack_blocks;	/* number of SACK blocks to include */
+};
+
+static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
+			      const struct tcp_out_options *opts,
+			      __u8 **md5_hash) {
+	if (unlikely(OPTION_MD5 & opts->options)) {
 		*ptr++ = htonl((TCPOPT_NOP << 24) |
 			       (TCPOPT_NOP << 16) |
-			       (TCPOPT_TIMESTAMP << 8) |
-			       TCPOLEN_TIMESTAMP);
-		*ptr++ = htonl(tstamp);
-		*ptr++ = htonl(tp->rx_opt.ts_recent);
+			       (TCPOPT_MD5SIG << 8) |
+			       TCPOLEN_MD5SIG);
+		*md5_hash = (__u8 *)ptr;
+		ptr += 4;
+	} else {
+		*md5_hash = NULL;
+	}
+
+	if (likely(OPTION_TS & opts->options)) {
+		if (unlikely(OPTION_SACK_ADVERTISE & opts->options)) {
+			*ptr++ = htonl((TCPOPT_SACK_PERM << 24) |
+				       (TCPOLEN_SACK_PERM << 16) |
+				       (TCPOPT_TIMESTAMP << 8) |
+				       TCPOLEN_TIMESTAMP);
+		} else {
+			*ptr++ = htonl((TCPOPT_NOP << 24) |
+				       (TCPOPT_NOP << 16) |
+				       (TCPOPT_TIMESTAMP << 8) |
+				       TCPOLEN_TIMESTAMP);
+		}
+		*ptr++ = htonl(opts->tsval);
+		*ptr++ = htonl(opts->tsecr);
 	}
-	if (tp->rx_opt.eff_sacks) {
-		struct tcp_sack_block *sp = tp->rx_opt.dsack ? tp->duplicate_sack : tp->selective_acks;
+
+	if (unlikely(opts->mss)) {
+		*ptr++ = htonl((TCPOPT_MSS << 24) |
+			       (TCPOLEN_MSS << 16) |
+			       opts->mss);
+	}
+
+	if (unlikely(OPTION_SACK_ADVERTISE & opts->options &&
+		     !(OPTION_TS & opts->options))) {
+		*ptr++ = htonl((TCPOPT_NOP << 24) |
+			       (TCPOPT_NOP << 16) |
+			       (TCPOPT_SACK_PERM << 8) |
+			       TCPOLEN_SACK_PERM);
+	}
+
+	if (unlikely(opts->ws)) {
+		*ptr++ = htonl((TCPOPT_NOP << 24) |
+			       (TCPOPT_WINDOW << 16) |
+			       (TCPOLEN_WINDOW << 8) |
+			       opts->ws);
+	}
+
+	if (unlikely(opts->num_sack_blocks)) {
+		struct tcp_sack_block *sp = tp->rx_opt.dsack ?
+			tp->duplicate_sack : tp->selective_acks;
 		int this_sack;
 
 		*ptr++ = htonl((TCPOPT_NOP  << 24) |
 			       (TCPOPT_NOP  << 16) |
 			       (TCPOPT_SACK <<  8) |
-			       (TCPOLEN_SACK_BASE + (tp->rx_opt.eff_sacks *
+			       (TCPOLEN_SACK_BASE + (opts->num_sack_blocks *
 						     TCPOLEN_SACK_PERBLOCK)));
 
-		for (this_sack = 0; this_sack < tp->rx_opt.eff_sacks; this_sack++) {
+		for (this_sack = 0; this_sack < opts->num_sack_blocks; ++this_sack) {
 			*ptr++ = htonl(sp[this_sack].start_seq);
 			*ptr++ = htonl(sp[this_sack].end_seq);
 		}
@@ -378,81 +431,137 @@ static void tcp_build_and_update_options(__be32 *ptr, struct tcp_sock *tp,
 			tp->rx_opt.eff_sacks--;
 		}
 	}
+}
+
+static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
+				struct tcp_out_options *opts,
+				struct tcp_md5sig_key **md5) {
+	struct tcp_sock *tp = tcp_sk(sk);
+	unsigned size = 0;
+
 #ifdef CONFIG_TCP_MD5SIG
-	if (md5_hash) {
-		*ptr++ = htonl((TCPOPT_NOP << 24) |
-			       (TCPOPT_NOP << 16) |
-			       (TCPOPT_MD5SIG << 8) |
-			       TCPOLEN_MD5SIG);
-		*md5_hash = (__u8 *)ptr;
+	*md5 = tp->af_specific->md5_lookup(sk, sk);
+	if (*md5) {
+		opts->options |= OPTION_MD5;
+		size += TCPOLEN_MD5SIG_ALIGNED;
 	}
+#else
+	*md5 = NULL;
 #endif
+
+	/* We always get an MSS option.  The option bytes which will be seen in
+	 * normal data packets should timestamps be used, must be in the MSS
+	 * advertised.  But we subtract them from tp->mss_cache so that
+	 * calculations in tcp_sendmsg are simpler etc.  So account for this
+	 * fact here if necessary.  If we don't do this correctly, as a
+	 * receiver we won't recognize data packets as being full sized when we
+	 * should, and thus we won't abide by the delayed ACK rules correctly.
+	 * SACKs don't matter, we never delay an ACK when we have any of those
+	 * going out.  */
+	opts->mss = tcp_advertise_mss(sk);
+	size += TCPOLEN_MSS_ALIGNED;
+
+	if (likely(sysctl_tcp_timestamps && *md5 == NULL)) {
+		opts->options |= OPTION_TS;
+		opts->tsval = TCP_SKB_CB(skb)->when;
+		opts->tsecr = tp->rx_opt.ts_recent;
+		size += TCPOLEN_TSTAMP_ALIGNED;
+	}
+	if (likely(sysctl_tcp_window_scaling)) {
+		opts->ws = tp->rx_opt.rcv_wscale;
+		size += TCPOLEN_WSCALE_ALIGNED;
+	}
+	if (likely(sysctl_tcp_sack)) {
+		opts->options |= OPTION_SACK_ADVERTISE;
+		if (unlikely(!OPTION_TS & opts->options))
+			size += TCPOLEN_SACKPERM_ALIGNED;
+	}
+
+	return size;
 }
 
-/* Construct a tcp options header for a SYN or SYN_ACK packet.
- * If this is every changed make sure to change the definition of
- * MAX_SYN_SIZE to match the new maximum number of options that you
- * can generate.
- *
- * Note - that with the RFC2385 TCP option, we make room for the
- * 16 byte MD5 hash. This will be filled in later, so the pointer for the
- * location to be filled is passed back up.
- */
-static void tcp_syn_build_options(__be32 *ptr, int mss, int ts, int sack,
-				  int offer_wscale, int wscale, __u32 tstamp,
-				  __u32 ts_recent, __u8 **md5_hash)
-{
-	/* We always get an MSS option.
-	 * The option bytes which will be seen in normal data
-	 * packets should timestamps be used, must be in the MSS
-	 * advertised.  But we subtract them from tp->mss_cache so
-	 * that calculations in tcp_sendmsg are simpler etc.
-	 * So account for this fact here if necessary.  If we
-	 * don't do this correctly, as a receiver we won't
-	 * recognize data packets as being full sized when we
-	 * should, and thus we won't abide by the delayed ACK
-	 * rules correctly.
-	 * SACKs don't matter, we never delay an ACK when we
-	 * have any of those going out.
-	 */
-	*ptr++ = htonl((TCPOPT_MSS << 24) | (TCPOLEN_MSS << 16) | mss);
-	if (ts) {
-		if (sack)
-			*ptr++ = htonl((TCPOPT_SACK_PERM << 24) |
-				       (TCPOLEN_SACK_PERM << 16) |
-				       (TCPOPT_TIMESTAMP << 8) |
-				       TCPOLEN_TIMESTAMP);
-		else
-			*ptr++ = htonl((TCPOPT_NOP << 24) |
-				       (TCPOPT_NOP << 16) |
-				       (TCPOPT_TIMESTAMP << 8) |
-				       TCPOLEN_TIMESTAMP);
-		*ptr++ = htonl(tstamp);		/* TSVAL */
-		*ptr++ = htonl(ts_recent);	/* TSECR */
-	} else if (sack)
-		*ptr++ = htonl((TCPOPT_NOP << 24) |
-			       (TCPOPT_NOP << 16) |
-			       (TCPOPT_SACK_PERM << 8) |
-			       TCPOLEN_SACK_PERM);
-	if (offer_wscale)
-		*ptr++ = htonl((TCPOPT_NOP << 24) |
-			       (TCPOPT_WINDOW << 16) |
-			       (TCPOLEN_WINDOW << 8) |
-			       (wscale));
+static unsigned tcp_synack_options(struct sock *sk,
+				   struct request_sock *req,
+				   unsigned mss, struct sk_buff *skb,
+				   struct tcp_out_options *opts,
+				   struct tcp_md5sig_key **md5) {
+	unsigned size = 0;
+	struct inet_request_sock *ireq = inet_rsk(req);
+	char doing_ts;
+	
 #ifdef CONFIG_TCP_MD5SIG
-	/*
-	 * If MD5 is enabled, then we set the option, and include the size
-	 * (always 18). The actual MD5 hash is added just before the
-	 * packet is sent.
-	 */
-	if (md5_hash) {
-		*ptr++ = htonl((TCPOPT_NOP << 24) |
-			       (TCPOPT_NOP << 16) |
-			       (TCPOPT_MD5SIG << 8) |
-			       TCPOLEN_MD5SIG);
-		*md5_hash = (__u8 *)ptr;
+	*md5 = tcp_rsk(req)->af_specific->md5_lookup(sk, req);
+	if (*md5) {
+		opts->options |= OPTION_MD5;
+		size += TCPOLEN_MD5SIG_ALIGNED;
+	}
+#else
+	*md5 = NULL;
+#endif
+
+	/* we can't fit any SACK blocks in a packet with MD5 + TS
+	   options. There was discussion about disabling SACK rather than TS in
+	   order to fit in better with old, buggy kernels, but that was deemed
+	   to be unnecessary. */
+	doing_ts = ireq->tstamp_ok && !(*md5 && ireq->sack_ok);
+
+	opts->mss = mss;
+	size += TCPOLEN_MSS_ALIGNED;
+
+	if (likely(ireq->wscale_ok)) {
+		opts->ws = ireq->rcv_wscale;
+		size += TCPOLEN_WSCALE_ALIGNED;
+	}
+	if (likely(doing_ts)) {
+		opts->options |= OPTION_TS;
+		opts->tsval = TCP_SKB_CB(skb)->when;
+		opts->tsecr = req->ts_recent;
+		size += TCPOLEN_TSTAMP_ALIGNED;
 	}
+	if (likely(ireq->sack_ok)) {
+		opts->options |= OPTION_SACK_ADVERTISE;
+		if (unlikely(!doing_ts))
+			size += TCPOLEN_SACKPERM_ALIGNED;
+	}
+
+	return size;
+}
+
+static unsigned tcp_established_options(struct sock *sk, struct sk_buff *skb,
+					struct tcp_out_options *opts,
+					struct tcp_md5sig_key **md5) {
+	struct tcp_skb_cb *tcb = skb ? TCP_SKB_CB(skb) : NULL;
+	struct tcp_sock *tp = tcp_sk(sk);
+	unsigned size = 0;
+
+#ifdef CONFIG_TCP_MD5SIG
+	*md5 = tp->af_specific->md5_lookup(sk, sk);
+	if (unlikely(*md5)) {
+		opts->options |= OPTION_MD5;
+		size += TCPOLEN_MD5SIG_ALIGNED;
+	}
+#else
+	*md5 = NULL;
 #endif
+
+	if (likely(tp->rx_opt.tstamp_ok)) {
+		opts->options |= OPTION_TS;
+		opts->tsval = tcb ? tcb->when : 0;
+		opts->tsecr = tp->rx_opt.ts_recent;
+		size += TCPOLEN_TSTAMP_ALIGNED;
+	}
+
+	if (unlikely(tp->rx_opt.eff_sacks)) {
+		const unsigned remaining = MAX_TCP_OPTION_SPACE - size;
+		opts->num_sack_blocks =
+			min_t(unsigned, tp->rx_opt.eff_sacks,
+			      (remaining - TCPOLEN_SACK_BASE_ALIGNED) /
+			      TCPOLEN_SACK_PERBLOCK);
+		size += TCPOLEN_SACK_BASE_ALIGNED +
+			opts->num_sack_blocks * TCPOLEN_SACK_PERBLOCK;
+	}
+
+	return size;
 }
 
 /* This routine actually transmits TCP packets queued in by
@@ -473,13 +582,11 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	struct inet_sock *inet;
 	struct tcp_sock *tp;
 	struct tcp_skb_cb *tcb;
-	int tcp_header_size;
-#ifdef CONFIG_TCP_MD5SIG
+	struct tcp_out_options opts;
+	unsigned tcp_options_size, tcp_header_size;
 	struct tcp_md5sig_key *md5;
 	__u8 *md5_hash_location;
-#endif
 	struct tcphdr *th;
-	int sysctl_flags;
 	int err;
 
 	BUG_ON(!skb || !tcp_skb_pcount(skb));
@@ -502,50 +609,17 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	inet = inet_sk(sk);
 	tp = tcp_sk(sk);
 	tcb = TCP_SKB_CB(skb);
-	tcp_header_size = tp->tcp_header_len;
-
-#define SYSCTL_FLAG_TSTAMPS	0x1
-#define SYSCTL_FLAG_WSCALE	0x2
-#define SYSCTL_FLAG_SACK	0x4
+	memset(&opts, 0, sizeof(opts));
 
-	sysctl_flags = 0;
-	if (unlikely(tcb->flags & TCPCB_FLAG_SYN)) {
-		tcp_header_size = sizeof(struct tcphdr) + TCPOLEN_MSS;
-		if (sysctl_tcp_timestamps) {
-			tcp_header_size += TCPOLEN_TSTAMP_ALIGNED;
-			sysctl_flags |= SYSCTL_FLAG_TSTAMPS;
-		}
-		if (sysctl_tcp_window_scaling) {
-			tcp_header_size += TCPOLEN_WSCALE_ALIGNED;
-			sysctl_flags |= SYSCTL_FLAG_WSCALE;
-		}
-		if (sysctl_tcp_sack) {
-			sysctl_flags |= SYSCTL_FLAG_SACK;
-			if (!(sysctl_flags & SYSCTL_FLAG_TSTAMPS))
-				tcp_header_size += TCPOLEN_SACKPERM_ALIGNED;
-		}
-	} else if (unlikely(tp->rx_opt.eff_sacks)) {
-		/* A SACK is 2 pad bytes, a 2 byte header, plus
-		 * 2 32-bit sequence numbers for each SACK block.
-		 */
-		tcp_header_size += (TCPOLEN_SACK_BASE_ALIGNED +
-				    (tp->rx_opt.eff_sacks *
-				     TCPOLEN_SACK_PERBLOCK));
-	}
+	if (unlikely(tcb->flags & TCPCB_FLAG_SYN))
+		tcp_options_size = tcp_syn_options(sk, skb, &opts, &md5);
+	else
+		tcp_options_size = tcp_established_options(sk, skb, &opts, &md5);
+	tcp_header_size = tcp_options_size + sizeof(struct tcphdr);
 
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
@@ -576,29 +650,9 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 		th->urg			= 1;
 	}
 
-	if (unlikely(tcb->flags & TCPCB_FLAG_SYN)) {
-		tcp_syn_build_options((__be32 *)(th + 1),
-				      tcp_advertise_mss(sk),
-				      (sysctl_flags & SYSCTL_FLAG_TSTAMPS),
-				      (sysctl_flags & SYSCTL_FLAG_SACK),
-				      (sysctl_flags & SYSCTL_FLAG_WSCALE),
-				      tp->rx_opt.rcv_wscale,
-				      tcb->when,
-				      tp->rx_opt.ts_recent,
-
-#ifdef CONFIG_TCP_MD5SIG
-				      md5 ? &md5_hash_location :
-#endif
-				      NULL);
-	} else {
-		tcp_build_and_update_options((__be32 *)(th + 1),
-					     tp, tcb->when,
-#ifdef CONFIG_TCP_MD5SIG
-					     md5 ? &md5_hash_location :
-#endif
-					     NULL);
+	tcp_options_write((__be32 *)(th + 1), tp, &opts, &md5_hash_location);
+	if (likely((tcb->flags & TCPCB_FLAG_SYN) == 0))
 		TCP_ECN_send(sk, skb, tcp_header_size);
-	}
 
 #ifdef CONFIG_TCP_MD5SIG
 	/* Calculate the MD5 hash, as we have all we need now */
@@ -630,10 +684,6 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	tcp_enter_cwr(sk, 1);
 
 	return net_xmit_eval(err);
-
-#undef SYSCTL_FLAG_TSTAMPS
-#undef SYSCTL_FLAG_WSCALE
-#undef SYSCTL_FLAG_SACK
 }
 
 /* This routine just queue's the buffer
@@ -974,6 +1024,9 @@ unsigned int tcp_current_mss(struct sock *sk, int large_allowed)
 	u32 mss_now;
 	u16 xmit_size_goal;
 	int doing_tso = 0;
+	unsigned header_len;
+	struct tcp_out_options opts;
+	struct tcp_md5sig_key *md5;
 
 	mss_now = tp->mss_cache;
 
@@ -986,14 +1039,16 @@ unsigned int tcp_current_mss(struct sock *sk, int large_allowed)
 			mss_now = tcp_sync_mss(sk, mtu);
 	}
 
-	if (tp->rx_opt.eff_sacks)
-		mss_now -= (TCPOLEN_SACK_BASE_ALIGNED +
-			    (tp->rx_opt.eff_sacks * TCPOLEN_SACK_PERBLOCK));
-
-#ifdef CONFIG_TCP_MD5SIG
-	if (tp->af_specific->md5_lookup(sk, sk))
-		mss_now -= TCPOLEN_MD5SIG_ALIGNED;
-#endif
+	header_len = tcp_established_options(sk, NULL, &opts, &md5) +
+	             sizeof(struct tcphdr);
+	/* The mss_cache is sized based on tp->tcp_header_len, which assumes
+	 * some common options. If this is an odd packet (because we have SACK
+	 * blocks etc) then our calculated header_len will be different, and
+	 * we have to adjust mss_now correspondingly */
+	if (header_len != tp->tcp_header_len) {
+	        int delta = (int) header_len - tp->tcp_header_len;
+	        mss_now -= delta;
+	}
 
 	xmit_size_goal = mss_now;
 
@@ -2178,11 +2233,10 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcphdr *th;
 	int tcp_header_size;
+	struct tcp_out_options opts;
 	struct sk_buff *skb;
-#ifdef CONFIG_TCP_MD5SIG
 	struct tcp_md5sig_key *md5;
 	__u8 *md5_hash_location;
-#endif
 
 	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15, 1, GFP_ATOMIC);
 	if (skb == NULL)
@@ -2193,18 +2247,26 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 
 	skb->dst = dst_clone(dst);
 
-	tcp_header_size = (sizeof(struct tcphdr) + TCPOLEN_MSS +
-			   (ireq->tstamp_ok ? TCPOLEN_TSTAMP_ALIGNED : 0) +
-			   (ireq->wscale_ok ? TCPOLEN_WSCALE_ALIGNED : 0) +
-			   /* SACK_PERM is in the place of NOP NOP of TS */
-			   ((ireq->sack_ok && !ireq->tstamp_ok) ? TCPOLEN_SACKPERM_ALIGNED : 0));
+	if (req->rcv_wnd == 0) { /* ignored for retransmitted syns */
+		__u8 rcv_wscale;
+		/* Set this up on the first call only */
+		req->window_clamp = tp->window_clamp ? : dst_metric(dst, RTAX_WINDOW);
+		/* tcp_full_space because it is guaranteed to be the first packet */
+		tcp_select_initial_window(tcp_full_space(sk),
+			dst_metric(dst, RTAX_ADVMSS) - (ireq->tstamp_ok ? TCPOLEN_TSTAMP_ALIGNED : 0),
+			&req->rcv_wnd,
+			&req->window_clamp,
+			ireq->wscale_ok,
+			&rcv_wscale);
+		ireq->rcv_wscale = rcv_wscale;
+	}
+
+	memset(&opts, 0, sizeof(opts));
+	TCP_SKB_CB(skb)->when = tcp_time_stamp;
+	tcp_header_size = tcp_synack_options(sk, req, dst_metric(dst, RTAX_ADVMSS),
+					     skb, &opts, &md5) +
+			  sizeof(struct tcphdr);
 
-#ifdef CONFIG_TCP_MD5SIG
-	/* Are we doing MD5 on this segment? If so - make room for it */
-	md5 = tcp_rsk(req)->af_specific->md5_lookup(sk, req);
-	if (md5)
-		tcp_header_size += TCPOLEN_MD5SIG_ALIGNED;
-#endif
 	skb_push(skb, tcp_header_size);
 	skb_reset_transport_header(skb);
 
@@ -2222,19 +2284,6 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 			     TCPCB_FLAG_SYN | TCPCB_FLAG_ACK);
 	th->seq = htonl(TCP_SKB_CB(skb)->seq);
 	th->ack_seq = htonl(tcp_rsk(req)->rcv_isn + 1);
-	if (req->rcv_wnd == 0) { /* ignored for retransmitted syns */
-		__u8 rcv_wscale;
-		/* Set this up on the first call only */
-		req->window_clamp = tp->window_clamp ? : dst_metric(dst, RTAX_WINDOW);
-		/* tcp_full_space because it is guaranteed to be the first packet */
-		tcp_select_initial_window(tcp_full_space(sk),
-			dst_metric(dst, RTAX_ADVMSS) - (ireq->tstamp_ok ? TCPOLEN_TSTAMP_ALIGNED : 0),
-			&req->rcv_wnd,
-			&req->window_clamp,
-			ireq->wscale_ok,
-			&rcv_wscale);
-		ireq->rcv_wscale = rcv_wscale;
-	}
 
 	/* RFC1323: The window in SYN & SYN/ACK segments is never scaled. */
 	th->window = htons(min(req->rcv_wnd, 65535U));
@@ -2243,18 +2292,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 		TCP_SKB_CB(skb)->when = cookie_init_timestamp(req);
 	else
 #endif
-	TCP_SKB_CB(skb)->when = tcp_time_stamp;
-	tcp_syn_build_options((__be32 *)(th + 1), dst_metric(dst, RTAX_ADVMSS), ireq->tstamp_ok,
-			      ireq->sack_ok, ireq->wscale_ok, ireq->rcv_wscale,
-			      TCP_SKB_CB(skb)->when,
-			      req->ts_recent,
-			      (
-#ifdef CONFIG_TCP_MD5SIG
-			       md5 ? &md5_hash_location :
-#endif
-			       NULL)
-			      );
-
+	tcp_options_write((__be32 *)(th + 1), tp, &opts, &md5_hash_location);
 	th->doff = (tcp_header_size >> 2);
 	TCP_INC_STATS(TCP_MIB_OUTSEGS);
 
