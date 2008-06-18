From: "Adam Langley" <agl@imperialviolet.org>
Subject: Comments requested: Long options and MD5 options
Date: Wed, 18 Jun 2008 16:24:33 -0700
Message-ID: <396556a20805301217k293e5718h6bbf02bfe0683145@europa>
References: <20080618023446.aba6516c.billfink@mindspring.com>
	<20080618.015206.22767411.davem@davemloft.net>
	<396556a20806181239q30024b8bv551f76a890befb0e@mail.gmail.com>
	<20080618.150104.147203818.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:6169 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753632AbYFRXaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 19:30:30 -0400
Received: by yw-out-2324.google.com with SMTP id 9so281380ywe.1
        for <netdev@vger.kernel.org>; Wed, 18 Jun 2008 16:30:29 -0700 (PDT)
In-Reply-To: <20080618.150104.147203818.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The retransmit timeout timer has to fire eventually, and when
> that happens we should clear all of our SACK state.

Ok, that's good at least. There were other variables in my test that could have
screwed that up.

Attached is a patch which pulls the options logic together into a single
function of SYN/SYNACK and one for established. At the moment, it chooses
SACK over timestamps for MD5 connections, but it's very easy to change. (And
that's the point of this patch - the logic isn't spread out)

Not signed off, because I want to do more testing, and to sleep on it first,
but pretty close to final.

 include/net/tcp.h     |    3 
 net/ipv4/tcp_output.c |  401 +++++++++++++++++++++++++++----------------------
 2 files changed, 222 insertions(+), 182 deletions(-)

---

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 633147c..35037d5 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -154,6 +154,9 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 					 * timestamps. It must be less than
 					 * minimal timewait lifetime.
 					 */
+
+#define TCP_MAX_OPTION_SPACE	40	/* Max bytes of options */
+
 /*
  *	TCP option
  */
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e399bde..7aba4f4 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -347,112 +347,163 @@ static void tcp_init_nondata_skb(struct sk_buff *skb, u32 seq, u8 flags)
 	TCP_SKB_CB(skb)->end_seq = seq;
 }
 
-static void tcp_build_and_update_options(__be32 *ptr, struct tcp_sock *tp,
-					 __u32 tstamp, __u8 **md5_hash)
-{
+/* Build, or calculate the size of the TCP options for a SYN or SYNACK.
+ *   ptr: (maybe NULL) Location to write the options
+ *   synack: if non-zero, this is a SYNACK, otherwise a SYN.
+ *   md5_hash: If non-NULL, space is left for a MD5 signature and its location
+ *     is written here
+ *   prev_written: the return value of calling this function, immediately
+ *     prior. First time round, pass 0 here. */
+static unsigned tcp_build_syn_options(__be32 *ptr,
+				      char synack, int mss, int ts, int sack,
+				      int offer_wscale, int wscale,
+				      __u32 tstamp, __u32 ts_recent,
+				      __u8 **md5_hash, unsigned prev_written) {
+	/* No SACK blocks can fit in a packet with timestamps and MD5
+	 * signatures. Older Linux kernels have a bug where they try anyway
+	 * and corrupt the packets. We want to assuage this, so if we saw a SYN
+	 * packet with MD5 + SACK + TS, we assume it's an old kernel and reply
+	 * with MD5 + TS. However, SACK is more important than TS so we send
+	 * SYNs with MD5 + SACK. */
+	const char doing_sack = sack && (!synack || !(md5_hash && sack && ts));
+	const char doing_ts = ts && !(md5_hash && doing_sack);
+
+	unsigned written = 0;
+	__be32 temp;
+	const unsigned n = !ptr ? 0 : 1;
+	BUG_ON(prev_written == 0 && ptr);
+	if (!ptr)
+		ptr = &temp;
+
+	if (md5_hash) {
+		*ptr = htonl((TCPOPT_NOP << 24) |
+			     (TCPOPT_NOP << 16) |
+			     (TCPOPT_MD5SIG << 8) |
+			     TCPOLEN_MD5SIG);
+		ptr += n;
+		*md5_hash = (__u8 *) ptr;
+		ptr += n * 4;
+		written += 4 + 16;
+	}
+
+	*ptr = htonl((TCPOPT_MSS << 24) |
+		     (TCPOLEN_MSS << 16) |
+		     mss);
+	ptr += n;
+	written += 4;
+
+	if (doing_ts) {
+		if (doing_sack) {
+			*ptr = htonl((TCPOPT_SACK_PERM << 24) |
+				(TCPOLEN_SACK_PERM << 16) |
+				(TCPOPT_TIMESTAMP << 8) |
+				TCPOLEN_TIMESTAMP);
+			ptr += n;
+		} else {
+			*ptr = htonl((TCPOPT_NOP << 24) |
+				(TCPOPT_NOP << 16) |
+				(TCPOPT_TIMESTAMP << 8) |
+				TCPOLEN_TIMESTAMP);
+			ptr += n;
+		}
+
+		*ptr = htonl(tstamp);
+		ptr += n;
+		*ptr = htonl(ts_recent);
+		ptr += n;
+		written += 4 * 3;
+	} else if (doing_sack) {
+		*ptr = htonl((TCPOPT_NOP << 24) |
+			     (TCPOPT_NOP << 16) |
+			     (TCPOPT_SACK_PERM << 8) |
+			     (TCPOLEN_SACK_PERM));
+		ptr += n;
+		written += 4;
+	}
+	if (offer_wscale) {
+		*ptr = htonl((TCPOPT_NOP << 24) |
+			     (TCPOPT_WINDOW << 16) |
+			     (TCPOLEN_WINDOW << 8) |
+			     wscale);
+		ptr += n;
+		written += 4;
+	}
+
+	return written;
+}
+
+/* Build, or calculate the size of the TCP options.
+ *   ptr: (maybe NULL) Location to write the options
+ *   md5_hash: If non-NULL, space is left for a MD5 signature and its location
+ *     is written here
+ *   prev_written: the return value of calling this function, immediately
+ *     prior. First time round, pass 0 here. */
+static unsigned tcp_build_options(__be32 *ptr, const struct sock *sk,
+				  __u32 tstamp, __u8 **md5_hash,
+				  unsigned prev_written) {
+	struct tcp_sock *tp = tcp_sk(sk);
+	const unsigned sack_bytes = TCPOLEN_SACK_BASE_ALIGNED +
+	  (tp->rx_opt.eff_sacks * TCPOLEN_SACK_PERBLOCK);
+	unsigned written = 0;
+	__be32 temp;
+	const unsigned n = !ptr ? 0 : 1;
+	BUG_ON(prev_written == 0 && ptr);
+	if (!ptr)
+		ptr = &temp;
+
+	if (md5_hash) {
+		*ptr = htonl((TCPOPT_NOP << 24) |
+			     (TCPOPT_NOP << 16) |
+			     (TCPOPT_MD5SIG << 8) |
+			     TCPOLEN_MD5SIG);
+		ptr += n;
+		*md5_hash = (__u8 *) ptr;
+		ptr += n * 4;
+		written += 4 + 16;
+	}
+
 	if (tp->rx_opt.tstamp_ok) {
-		*ptr++ = htonl((TCPOPT_NOP << 24) |
-			       (TCPOPT_NOP << 16) |
-			       (TCPOPT_TIMESTAMP << 8) |
-			       TCPOLEN_TIMESTAMP);
-		*ptr++ = htonl(tstamp);
-		*ptr++ = htonl(tp->rx_opt.ts_recent);
+		*ptr = htonl((TCPOPT_NOP << 24) |
+			     (TCPOPT_NOP << 16) |
+			     (TCPOPT_TIMESTAMP << 8) |
+			     TCPOLEN_TIMESTAMP);
+		ptr += n;
+		*ptr = htonl(tstamp);
+		ptr += n;
+		*ptr = htonl(tp->rx_opt.ts_recent);
+		ptr += n;
+
+		written += 4 * 3;
 	}
-	if (tp->rx_opt.eff_sacks) {
-		struct tcp_sack_block *sp = tp->rx_opt.dsack ? tp->duplicate_sack : tp->selective_acks;
+
+	if (tp->rx_opt.eff_sacks &&
+	    (TCP_MAX_OPTION_SPACE - written >= sack_bytes)) {
+		const struct tcp_sack_block *sp =
+		  tp->rx_opt.dsack ? tp->duplicate_sack : tp->selective_acks;
 		int this_sack;
 
-		*ptr++ = htonl((TCPOPT_NOP  << 24) |
-			       (TCPOPT_NOP  << 16) |
-			       (TCPOPT_SACK <<  8) |
-			       (TCPOLEN_SACK_BASE + (tp->rx_opt.eff_sacks *
-						     TCPOLEN_SACK_PERBLOCK)));
+		*ptr = htonl((TCPOPT_NOP  << 24) |
+			     (TCPOPT_NOP  << 16) |
+			     (TCPOPT_SACK <<  8) |
+			     (sack_bytes - 2));
+		ptr += n;
 
 		for (this_sack = 0; this_sack < tp->rx_opt.eff_sacks; this_sack++) {
-			*ptr++ = htonl(sp[this_sack].start_seq);
-			*ptr++ = htonl(sp[this_sack].end_seq);
+			*ptr = htonl(sp[this_sack].start_seq);
+			ptr += n;
+			*ptr = htonl(sp[this_sack].end_seq);
+			ptr += n;
 		}
 
-		if (tp->rx_opt.dsack) {
+		if (prev_written && tp->rx_opt.dsack) {
 			tp->rx_opt.dsack = 0;
 			tp->rx_opt.eff_sacks--;
 		}
-	}
-#ifdef CONFIG_TCP_MD5SIG
-	if (md5_hash) {
-		*ptr++ = htonl((TCPOPT_NOP << 24) |
-			       (TCPOPT_NOP << 16) |
-			       (TCPOPT_MD5SIG << 8) |
-			       TCPOLEN_MD5SIG);
-		*md5_hash = (__u8 *)ptr;
-	}
-#endif
-}
 
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
-#ifdef CONFIG_TCP_MD5SIG
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
+		written += sack_bytes;
 	}
-#endif
+
+	return written;
 }
 
 /* This routine actually transmits TCP packets queued in by
@@ -473,15 +524,22 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	struct inet_sock *inet;
 	struct tcp_sock *tp;
 	struct tcp_skb_cb *tcb;
-	int tcp_header_size;
-#ifdef CONFIG_TCP_MD5SIG
-	struct tcp_md5sig_key *md5;
+	unsigned tcp_options_size, tcp_header_size;
+	struct tcp_md5sig_key *md5 = NULL;
 	__u8 *md5_hash_location;
-#endif
 	struct tcphdr *th;
-	int sysctl_flags;
 	int err;
 
+#define SYSCTL_FLAG_TSTAMPS  0x1
+#define SYSCTL_FLAG_WSCALE   0x2
+#define SYSCTL_FLAG_SACK  0x4
+
+	/* We can't have these changing during the duration of this function */
+	const int sysctl_flags =
+	  (sysctl_tcp_timestamps ? SYSCTL_FLAG_TSTAMPS : 0) |
+	  (sysctl_tcp_window_scaling ? SYSCTL_FLAG_WSCALE : 0) |
+	  (sysctl_tcp_sack ? SYSCTL_FLAG_SACK : 0);
+
 	BUG_ON(!skb || !tcp_skb_pcount(skb));
 
 	/* If congestion control is doing timestamping, we must
@@ -502,50 +560,32 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	inet = inet_sk(sk);
 	tp = tcp_sk(sk);
 	tcb = TCP_SKB_CB(skb);
-	tcp_header_size = tp->tcp_header_len;
 
-#define SYSCTL_FLAG_TSTAMPS	0x1
-#define SYSCTL_FLAG_WSCALE	0x2
-#define SYSCTL_FLAG_SACK	0x4
+#ifdef CONFIG_TCP_MD5SIG
+	md5 = tp->af_specific->md5_lookup(sk, sk);
+#endif
 
-	sysctl_flags = 0;
 	if (unlikely(tcb->flags & TCPCB_FLAG_SYN)) {
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
+		tcp_options_size =
+		  tcp_build_syn_options(NULL, 0,
+					tcp_advertise_mss(sk),
+					sysctl_flags & SYSCTL_FLAG_TSTAMPS,
+					sysctl_flags & SYSCTL_FLAG_SACK,
+					sysctl_flags & SYSCTL_FLAG_WSCALE,
+					tp->rx_opt.rcv_wscale,
+					tcb->when,
+					tp->rx_opt.ts_recent,
+					md5 ? &md5_hash_location : NULL, 0);
+	} else {
+		tcp_options_size =
+		  tcp_build_options(NULL, sk, tcb->when,
+				    md5 ? &md5_hash_location : NULL, 0);
 	}
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
@@ -577,26 +617,20 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	}
 
 	if (unlikely(tcb->flags & TCPCB_FLAG_SYN)) {
-		tcp_syn_build_options((__be32 *)(th + 1),
+		tcp_build_syn_options((__be32 *)(th + 1), 0,
 				      tcp_advertise_mss(sk),
-				      (sysctl_flags & SYSCTL_FLAG_TSTAMPS),
-				      (sysctl_flags & SYSCTL_FLAG_SACK),
-				      (sysctl_flags & SYSCTL_FLAG_WSCALE),
+				      sysctl_flags & SYSCTL_FLAG_TSTAMPS,
+				      sysctl_flags & SYSCTL_FLAG_SACK,
+				      sysctl_flags & SYSCTL_FLAG_WSCALE,
 				      tp->rx_opt.rcv_wscale,
 				      tcb->when,
 				      tp->rx_opt.ts_recent,
-
-#ifdef CONFIG_TCP_MD5SIG
-				      md5 ? &md5_hash_location :
-#endif
-				      NULL);
+				      md5 ? &md5_hash_location : NULL,
+				      tcp_options_size);
 	} else {
-		tcp_build_and_update_options((__be32 *)(th + 1),
-					     tp, tcb->when,
-#ifdef CONFIG_TCP_MD5SIG
-					     md5 ? &md5_hash_location :
-#endif
-					     NULL);
+		tcp_build_options((__be32 *)(th + 1), sk, tcb->when,
+				  md5 ? &md5_hash_location : NULL,
+				  tcp_options_size);
 		TCP_ECN_send(sk, skb, tcp_header_size);
 	}
 
@@ -974,6 +1008,8 @@ unsigned int tcp_current_mss(struct sock *sk, int large_allowed)
 	u32 mss_now;
 	u16 xmit_size_goal;
 	int doing_tso = 0;
+	unsigned header_len;
+	__u8 **md5_ptr = NULL, *md5_hash;
 
 	mss_now = tp->mss_cache;
 
@@ -986,22 +1022,29 @@ unsigned int tcp_current_mss(struct sock *sk, int large_allowed)
 			mss_now = tcp_sync_mss(sk, mtu);
 	}
 
-	if (tp->rx_opt.eff_sacks)
-		mss_now -= (TCPOLEN_SACK_BASE_ALIGNED +
-			    (tp->rx_opt.eff_sacks * TCPOLEN_SACK_PERBLOCK));
-
 #ifdef CONFIG_TCP_MD5SIG
 	if (tp->af_specific->md5_lookup(sk, sk))
-		mss_now -= TCPOLEN_MD5SIG_ALIGNED;
+		md5_ptr = &md5_hash;
 #endif
 
+	header_len = tcp_build_options(NULL, sk, 0, md5_ptr, 0) +
+		     sizeof(struct tcphdr);
+	/* The mss_cache is sized based on tp->tcp_header_len, which assumes
+	 * some common options. If this is an odd packet (because we have SACK
+	 * blocks etc) then our calculated header_len will be different, and
+	 * we have to adjust mss_now correspondingly */
+	if (header_len != tp->tcp_header_len) {
+		int delta = (int) header_len - tp->tcp_header_len;
+		mss_now -= delta;
+	}
+
 	xmit_size_goal = mss_now;
 
 	if (doing_tso) {
 		xmit_size_goal = ((sk->sk_gso_max_size - 1) -
 				  inet_csk(sk)->icsk_af_ops->net_header_len -
 				  inet_csk(sk)->icsk_ext_hdr_len -
-				  tp->tcp_header_len);
+				  header_len);
 
 		xmit_size_goal = tcp_bound_to_half_wnd(tp, xmit_size_goal);
 		xmit_size_goal -= (xmit_size_goal % mss_now);
@@ -2177,12 +2220,10 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	struct inet_request_sock *ireq = inet_rsk(req);
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcphdr *th;
-	int tcp_header_size;
+	int tcp_options_size, tcp_header_size;
 	struct sk_buff *skb;
-#ifdef CONFIG_TCP_MD5SIG
-	struct tcp_md5sig_key *md5;
+	struct tcp_md5sig_key *md5 = NULL;
 	__u8 *md5_hash_location;
-#endif
 
 	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15, 1, GFP_ATOMIC);
 	if (skb == NULL)
@@ -2193,18 +2234,18 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 
 	skb->dst = dst_clone(dst);
 
-	tcp_header_size = (sizeof(struct tcphdr) + TCPOLEN_MSS +
-			   (ireq->tstamp_ok ? TCPOLEN_TSTAMP_ALIGNED : 0) +
-			   (ireq->wscale_ok ? TCPOLEN_WSCALE_ALIGNED : 0) +
-			   /* SACK_PERM is in the place of NOP NOP of TS */
-			   ((ireq->sack_ok && !ireq->tstamp_ok) ? TCPOLEN_SACKPERM_ALIGNED : 0));
-
 #ifdef CONFIG_TCP_MD5SIG
-	/* Are we doing MD5 on this segment? If so - make room for it */
 	md5 = tcp_rsk(req)->af_specific->md5_lookup(sk, req);
-	if (md5)
-		tcp_header_size += TCPOLEN_MD5SIG_ALIGNED;
 #endif
+
+	tcp_options_size =
+	  tcp_build_syn_options(NULL, 1, dst_metric(dst, RTAX_ADVMSS),
+				ireq->tstamp_ok, ireq->sack_ok,
+				ireq->wscale_ok, ireq->rcv_wscale,
+				TCP_SKB_CB(skb)->when, req->ts_recent,
+				md5 ? &md5_hash_location : NULL, 0);
+	tcp_header_size = tcp_options_size + sizeof(struct tcphdr);
+
 	skb_push(skb, tcp_header_size);
 	skb_reset_transport_header(skb);
 
@@ -2244,18 +2285,14 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	else
 #endif
 	TCP_SKB_CB(skb)->when = tcp_time_stamp;
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
-	th->doff = (tcp_header_size >> 2);
+	tcp_build_syn_options((__be32 *)(th + 1), 1, dst_metric(dst, RTAX_ADVMSS),
+			      ireq->tstamp_ok, ireq->sack_ok,
+			      ireq->wscale_ok, ireq->rcv_wscale,
+			      TCP_SKB_CB(skb)->when, req->ts_recent,
+			      md5 ? &md5_hash_location : NULL,
+			      tcp_options_size);
+
+	th->doff = tcp_header_size >> 2;
 	TCP_INC_STATS(TCP_MIB_OUTSEGS);
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -2264,8 +2301,8 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 		tp->af_specific->calc_md5_hash(md5_hash_location,
 					       md5,
 					       NULL, dst, req,
-					       tcp_hdr(skb), sk->sk_protocol,
-					       skb->len);
+					       tcp_hdr(skb),
+					       sk->sk_protocol, skb->len);
 	}
 #endif
 
