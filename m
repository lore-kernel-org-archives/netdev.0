From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [net-next-2.6 PATCH v6 6/7 RFC] TCPCT part 1f: Initiator Cookie =>
 Responder
Date: Fri, 13 Nov 2009 00:40:04 -0500
Message-ID: <4AFCF134.2060208@gmail.com>
References: <4AFCDA9E.8050003@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080900040100080908010508"
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f202.google.com ([209.85.211.202]:57502 "EHLO
	mail-yw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355AbZKMFre (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 00:47:34 -0500
Received: by ywh40 with SMTP id 40so1031417ywh.33
        for <netdev@vger.kernel.org>; Thu, 12 Nov 2009 21:47:38 -0800 (PST)
In-Reply-To: <4AFCDA9E.8050003@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080900040100080908010508
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Calculate and format TCP_COOKIE SYN option.

Create (and destroy) cookie data structures.

This is a significantly revised implementation of an earlier (year-old)
patch that no longer applies cleanly, with permission of the original
author (Adam Langley):

    http://thread.gmane.org/gmane.linux.network/102586

Requires:
   TCPCT part 1c: sysctl_tcp_cookie_size, socket option TCP_COOKIE_TRANSACTIONS
   TCPCT part 1d: define TCP cookie option, extend existing struct's

Signed-off-by: William.Allen.Simpson@gmail.com
---
  net/ipv4/tcp_ipv4.c      |   20 +++++
  net/ipv4/tcp_minisocks.c |   45 +++++++++--
  net/ipv4/tcp_output.c    |  182 ++++++++++++++++++++++++++++++++++++++++------
  net/ipv6/tcp_ipv6.c      |   13 +++
  4 files changed, 228 insertions(+), 32 deletions(-)

--------------080900040100080908010508
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="TCPCT+1f6.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="TCPCT+1f6.patch"

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 094231b..2ae1985 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1834,6 +1834,19 @@ static int tcp_v4_init_sock(struct sock *sk)
 	tp->af_specific = &tcp_sock_ipv4_specific;
 #endif
 
+	/* TCP Cookie Transactions */
+	if (sysctl_tcp_cookie_size > 0) {
+		/* Default, cookies without s_data. */
+		tp->cookie_values =
+			kzalloc(sizeof(*tp->cookie_values),
+				sk->sk_allocation);
+		if (tp->cookie_values != NULL)
+			kref_init(&tp->cookie_values->kref);
+	}
+	/* Presumed zeroed, in order of appearance:
+	 *	cookie_in_always, cookie_out_never,
+	 *	s_data_constant, s_data_in, s_data_out
+	 */
 	sk->sk_sndbuf = sysctl_tcp_wmem[1];
 	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
 
@@ -1887,6 +1900,13 @@ void tcp_v4_destroy_sock(struct sock *sk)
 		sk->sk_sndmsg_page = NULL;
 	}
 
+	/* TCP Cookie Transactions */
+	if (tp->cookie_values != NULL) {
+		kref_put(&tp->cookie_values->kref,
+			 tcp_cookie_values_release);
+		tp->cookie_values = NULL;
+	}
+
 	percpu_counter_dec(&tcp_sockets_allocated);
 }
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 7a42990..2b50da8 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -389,14 +389,42 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		const struct inet_request_sock *ireq = inet_rsk(req);
 		struct tcp_request_sock *treq = tcp_rsk(req);
 		struct inet_connection_sock *newicsk = inet_csk(newsk);
-		struct tcp_sock *newtp;
+		struct tcp_sock *newtp = tcp_sk(newsk);
+		struct tcp_sock *oldtp = tcp_sk(sk);
+		struct tcp_cookie_values *oldcvp = oldtp->cookie_values;
+
+		/* TCP Cookie Transactions require space for the cookie pair,
+		 * as it differs for each connection.  There is no need to
+		 * copy any s_data stored at the original socket.  Failure
+		 * will prevent resuming the connection.
+		 *
+		 * Presumed copied, in order of appearance:
+		 *	cookie_in_always, cookie_out_never
+		 */
+		if (oldcvp != NULL) {
+			struct tcp_cookie_values *newcvp =
+				kzalloc(sizeof(*newtp->cookie_values),
+					GFP_ATOMIC);
+
+			if (newcvp != NULL) {
+				kref_init(&newcvp->kref);
+				newcvp->cookie_desired =
+						oldcvp->cookie_desired;
+				newtp->cookie_values = newcvp;
+			} else {
+				/* Not Yet Implemented */
+				newtp->cookie_values = NULL;
+			}
+		}
 
 		/* Now setup tcp_sock */
-		newtp = tcp_sk(newsk);
 		newtp->pred_flags = 0;
-		newtp->rcv_wup = newtp->copied_seq = newtp->rcv_nxt = treq->rcv_isn + 1;
-		newtp->snd_sml = newtp->snd_una = newtp->snd_nxt = treq->snt_isn + 1;
-		newtp->snd_up = treq->snt_isn + 1;
+
+		newtp->rcv_wup = newtp->copied_seq =
+		newtp->rcv_nxt = treq->rcv_isn + 1;
+
+		newtp->snd_sml = newtp->snd_una = newtp->snd_nxt =
+		newtp->snd_up = treq->snt_isn + 1 + tcp_s_data_size(oldtp);
 
 		tcp_prequeue_init(newtp);
 
@@ -429,8 +457,8 @@ struct sock *tcp_create_openreq_child(struct sock *sk, struct request_sock *req,
 		tcp_set_ca_state(newsk, TCP_CA_Open);
 		tcp_init_xmit_timers(newsk);
 		skb_queue_head_init(&newtp->out_of_order_queue);
-		newtp->write_seq = treq->snt_isn + 1;
-		newtp->pushed_seq = newtp->write_seq;
+		newtp->write_seq = newtp->pushed_seq =
+			treq->snt_isn + 1 + tcp_s_data_size(oldtp);
 
 		newtp->rx_opt.saw_tstamp = 0;
 
@@ -596,7 +624,8 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	 * Invalid ACK: reset will be sent by listening socket
 	 */
 	if ((flg & TCP_FLAG_ACK) &&
-	    (TCP_SKB_CB(skb)->ack_seq != tcp_rsk(req)->snt_isn + 1))
+	    (TCP_SKB_CB(skb)->ack_seq != tcp_rsk(req)->snt_isn + 1 +
+					 tcp_s_data_size(tcp_sk(sk))))
 		return sk;
 
 	/* Also, it would be not so bad idea to check rcv_tsecr, which
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e59fa5a..e1553d3 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -370,15 +370,45 @@ static inline int tcp_urg_mode(const struct tcp_sock *tp)
 #define OPTION_TS		(1 << 1)
 #define OPTION_MD5		(1 << 2)
 #define OPTION_WSCALE		(1 << 3)
+#define OPTION_COOKIE_EXTENSION	(1 << 4)
 
 struct tcp_out_options {
 	u8 options;		/* bit field of OPTION_* */
 	u8 ws;			/* window scale, 0 to disable */
+	u8 hash_size;		/* bytes in hash */
 	u8 num_sack_blocks;	/* number of SACK blocks to include */
 	u16 mss;		/* 0 to disable */
 	__u32 tsval, tsecr;	/* need to include OPTION_TS */
+	__u8 *hash_location;	/* temporary pointer, overloaded */
 };
 
+/* The sysctl int routines are generic, so check consistency here.
+ */
+static u8 tcp_cookie_size_check(u8 desired)
+{
+	if (desired > 0) {
+		/* previously specified */
+		return desired;
+	}
+	if (sysctl_tcp_cookie_size <= 0) {
+		/* no default specified */
+		return 0;
+	}
+	if (sysctl_tcp_cookie_size < TCP_COOKIE_MIN) {
+		/* value too small, increase to minimum */
+		return TCP_COOKIE_MIN;
+	}
+	if (sysctl_tcp_cookie_size > TCP_COOKIE_MAX) {
+		/* value too large, decrease to maximum */
+		return TCP_COOKIE_MAX;
+	}
+	if (0x1 & sysctl_tcp_cookie_size) {
+		/* 8-bit multiple, illegal, fix it */
+		return (u8)(sysctl_tcp_cookie_size + 0x1);
+	}
+	return (u8)sysctl_tcp_cookie_size;
+}
+
 /* Write previously computed TCP options to the packet.
  *
  * Beware: Something in the Internet is very sensitive to the ordering of
@@ -393,17 +423,34 @@ struct tcp_out_options {
  * (but it may well be that other scenarios fail similarly).
  */
 static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
-			      const struct tcp_out_options *opts,
-			      __u8 **md5_hash) {
-	if (unlikely(OPTION_MD5 & opts->options)) {
-		*ptr++ = htonl((TCPOPT_NOP << 24) |
-			       (TCPOPT_NOP << 16) |
-			       (TCPOPT_MD5SIG << 8) |
-			       TCPOLEN_MD5SIG);
-		*md5_hash = (__u8 *)ptr;
+			      struct tcp_out_options *opts)
+{
+	u8 options = opts->options;	/* mungable copy */
+
+	/* Having both authentication and cookies for security is redundant,
+	 * and there's certainly not enough room.  Instead, the cookie-less
+	 * extension variant is proposed.
+	 *
+	 * Consider the pessimal case with authentication.  The options
+	 * could look like:
+	 *   COOKIE|MD5(20) + MSS(4) + SACK|TS(12) + WSCALE(4) == 40
+	 */
+	if (unlikely(OPTION_MD5 & options)) {
+		if (unlikely(OPTION_COOKIE_EXTENSION & options)) {
+			*ptr++ = htonl((TCPOPT_COOKIE << 24) |
+				       (TCPOLEN_COOKIE_BASE << 16) |
+				       (TCPOPT_MD5SIG << 8) |
+				       TCPOLEN_MD5SIG);
+		} else {
+			*ptr++ = htonl((TCPOPT_NOP << 24) |
+				       (TCPOPT_NOP << 16) |
+				       (TCPOPT_MD5SIG << 8) |
+				       TCPOLEN_MD5SIG);
+		}
+		options &= ~OPTION_COOKIE_EXTENSION;
+		/* overload cookie hash location */
+		opts->hash_location = (__u8 *)ptr;
 		ptr += 4;
-	} else {
-		*md5_hash = NULL;
 	}
 
 	if (unlikely(opts->mss)) {
@@ -412,12 +459,13 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 			       opts->mss);
 	}
 
-	if (likely(OPTION_TS & opts->options)) {
-		if (unlikely(OPTION_SACK_ADVERTISE & opts->options)) {
+	if (likely(OPTION_TS & options)) {
+		if (unlikely(OPTION_SACK_ADVERTISE & options)) {
 			*ptr++ = htonl((TCPOPT_SACK_PERM << 24) |
 				       (TCPOLEN_SACK_PERM << 16) |
 				       (TCPOPT_TIMESTAMP << 8) |
 				       TCPOLEN_TIMESTAMP);
+			options &= ~OPTION_SACK_ADVERTISE;
 		} else {
 			*ptr++ = htonl((TCPOPT_NOP << 24) |
 				       (TCPOPT_NOP << 16) |
@@ -428,15 +476,52 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 		*ptr++ = htonl(opts->tsecr);
 	}
 
-	if (unlikely(OPTION_SACK_ADVERTISE & opts->options &&
-		     !(OPTION_TS & opts->options))) {
+	/* Specification requires after timestamp, so do it now.
+	 *
+	 * Consider the pessimal case without authentication.  The options
+	 * could look like:
+	 *   MSS(4) + SACK|TS(12) + COOKIE(20) + WSCALE(4) == 40
+	 */
+	if (unlikely(OPTION_COOKIE_EXTENSION & options)) {
+		__u8 *cookie_copy = opts->hash_location;
+		u8 cookie_size = opts->hash_size;
+
+		if (unlikely(0x1 & cookie_size)) {
+			/* 8-bit multiple, illegal, ignore */
+			cookie_size = 0;
+		} else if (likely(0x2 & cookie_size)) {
+			__u8 *p = (__u8 *)ptr;
+
+			/* 16-bit multiple */
+			*p++ = TCPOPT_COOKIE;
+			*p++ = TCPOLEN_COOKIE_BASE + cookie_size;
+			*p++ = *cookie_copy++;
+			*p++ = *cookie_copy++;
+			ptr++;
+			cookie_size -= 2;
+		} else {
+			/* 32-bit multiple */
+			*ptr++ = htonl(((TCPOPT_NOP << 24) |
+					(TCPOPT_NOP << 16) |
+					(TCPOPT_COOKIE << 8) |
+					TCPOLEN_COOKIE_BASE) +
+				       cookie_size);
+		}
+
+		if (cookie_size > 0) {
+			memcpy(ptr, cookie_copy, cookie_size);
+			ptr += (cookie_size >> 2);
+		}
+	}
+
+	if (unlikely(OPTION_SACK_ADVERTISE & options)) {
 		*ptr++ = htonl((TCPOPT_NOP << 24) |
 			       (TCPOPT_NOP << 16) |
 			       (TCPOPT_SACK_PERM << 8) |
 			       TCPOLEN_SACK_PERM);
 	}
 
-	if (unlikely(OPTION_WSCALE & opts->options)) {
+	if (unlikely(OPTION_WSCALE & options)) {
 		*ptr++ = htonl((TCPOPT_NOP << 24) |
 			       (TCPOPT_WINDOW << 16) |
 			       (TCPOLEN_WINDOW << 8) |
@@ -471,8 +556,12 @@ static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 				struct tcp_out_options *opts,
 				struct tcp_md5sig_key **md5) {
 	struct tcp_sock *tp = tcp_sk(sk);
-	unsigned size = 0;
+	struct tcp_cookie_values *cvp = tp->cookie_values;
 	struct dst_entry *dst = __sk_dst_get(sk);
+	unsigned size = 0;
+	u8 cookie_size = (!tp->rx_opt.cookie_out_never && cvp != NULL)
+			 ? tcp_cookie_size_check(cvp->cookie_desired)
+			 : 0;
 
 #ifdef CONFIG_TCP_MD5SIG
 	*md5 = tp->af_specific->md5_lookup(sk, sk);
@@ -517,6 +606,53 @@ static unsigned tcp_syn_options(struct sock *sk, struct sk_buff *skb,
 			size += TCPOLEN_SACKPERM_ALIGNED;
 	}
 
+	/* Note that timestamps are required by the specification.
+	 *
+	 * Odd numbers of bytes are prohibited by the specification, ensuring
+	 * that the cookie is 16-bit aligned, and the resulting cookie pair is
+	 * 32-bit aligned.
+	 */
+	if (*md5 == NULL
+	 && (OPTION_TS & opts->options)
+	 && cookie_size > 0) {
+		int need = TCPOLEN_COOKIE_BASE + cookie_size;
+		int remaining = MAX_TCP_OPTION_SPACE - size;
+
+		if (0x2 & need) {
+			/* 32-bit multiple */
+			need += 2; /* NOPs */
+
+			if (need > remaining) {
+				/* try shrinking cookie to fit */
+				cookie_size -= 2;
+				need -= 4;
+			}
+		}
+		while (need > remaining && TCP_COOKIE_MIN <= cookie_size) {
+			cookie_size -= 4;
+			need -= 4;
+		}
+		if (TCP_COOKIE_MIN <= cookie_size) {
+			opts->options |= OPTION_COOKIE_EXTENSION;
+			opts->hash_location = (__u8 *)&cvp->cookie_pair[0];
+			opts->hash_size = cookie_size;
+
+			/* Remember for future incarnations. */
+			cvp->cookie_desired = cookie_size;
+
+			if (cvp->cookie_desired != cvp->cookie_pair_size) {
+				/* Currently use random bytes as a nonce,
+				 * assuming these are completely unpredictable
+				 * by hostile users of the same system.
+				 */
+				get_random_bytes(&cvp->cookie_pair[0],
+						 cookie_size);
+				cvp->cookie_pair_size = cookie_size;
+			}
+
+			size += need;
+		}
+	}
 	return size;
 }
 
@@ -632,7 +768,6 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	struct tcp_out_options opts;
 	unsigned tcp_options_size, tcp_header_size;
 	struct tcp_md5sig_key *md5;
-	__u8 *md5_hash_location;
 	struct tcphdr *th;
 	int err;
 
@@ -703,7 +838,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 		}
 	}
 
-	tcp_options_write((__be32 *)(th + 1), tp, &opts, &md5_hash_location);
+	tcp_options_write((__be32 *)(th + 1), tp, &opts);
 	if (likely((tcb->flags & TCPCB_FLAG_SYN) == 0))
 		TCP_ECN_send(sk, skb, tcp_header_size);
 
@@ -711,7 +846,7 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	/* Calculate the MD5 hash, as we have all we need now */
 	if (md5) {
 		sk->sk_route_caps &= ~NETIF_F_GSO_MASK;
-		tp->af_specific->calc_md5_hash(md5_hash_location,
+		tp->af_specific->calc_md5_hash(opts.hash_location,
 					       md5, sk, NULL, skb);
 	}
 #endif
@@ -2235,14 +2370,13 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 				struct request_sock *req,
 				struct request_values *rvp)
 {
+	struct tcp_out_options opts;
 	struct inet_request_sock *ireq = inet_rsk(req);
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcphdr *th;
-	int tcp_header_size;
-	struct tcp_out_options opts;
 	struct sk_buff *skb;
 	struct tcp_md5sig_key *md5;
-	__u8 *md5_hash_location;
+	int tcp_header_size;
 	int mss;
 
 	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15, 1, GFP_ATOMIC);
@@ -2303,14 +2437,14 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 
 	/* RFC1323: The window in SYN & SYN/ACK segments is never scaled. */
 	th->window = htons(min(req->rcv_wnd, 65535U));
-	tcp_options_write((__be32 *)(th + 1), tp, &opts, &md5_hash_location);
+	tcp_options_write((__be32 *)(th + 1), tp, &opts);
 	th->doff = (tcp_header_size >> 2);
 	TCP_INC_STATS(sock_net(sk), TCP_MIB_OUTSEGS);
 
 #ifdef CONFIG_TCP_MD5SIG
 	/* Okay, we have all we need - do the md5 hash if needed */
 	if (md5) {
-		tcp_rsk(req)->af_specific->calc_md5_hash(md5_hash_location,
+		tcp_rsk(req)->af_specific->calc_md5_hash(opts.hash_location,
 					       md5, NULL, req, skb);
 	}
 #endif
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 3e327bc..2b16f9a 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1865,6 +1865,19 @@ static int tcp_v6_init_sock(struct sock *sk)
 	tp->af_specific = &tcp_sock_ipv6_specific;
 #endif
 
+	/* TCP Cookie Transactions */
+	if (sysctl_tcp_cookie_size > 0) {
+		/* Default, cookies without s_data. */
+		tp->cookie_values =
+			kzalloc(sizeof(*tp->cookie_values),
+				sk->sk_allocation);
+		if (tp->cookie_values != NULL)
+			kref_init(&tp->cookie_values->kref);
+	}
+	/* Presumed zeroed, in order of appearance:
+	 *	cookie_in_always, cookie_out_never,
+	 *	s_data_constant, s_data_in, s_data_out
+	 */
 	sk->sk_sndbuf = sysctl_tcp_wmem[1];
 	sk->sk_rcvbuf = sysctl_tcp_rmem[1];
 
-- 
1.6.3.3


--------------080900040100080908010508--
