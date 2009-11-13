From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [net-next-2.6 PATCH v6 7/7 RFC] TCPCT part 1g: Responder Cookie =>
 Initiator
Date: Fri, 13 Nov 2009 00:53:19 -0500
Message-ID: <4AFCF44F.4000705@gmail.com>
References: <4AFCDA9E.8050003@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090604030205090005030005"
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f202.google.com ([209.85.211.202]:52981 "EHLO
	mail-yw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753243AbZKMFxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 00:53:19 -0500
Received: by ywh40 with SMTP id 40so1033942ywh.33
        for <netdev@vger.kernel.org>; Thu, 12 Nov 2009 21:53:24 -0800 (PST)
In-Reply-To: <4AFCDA9E.8050003@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------090604030205090005030005
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Calculate and format TCP_COOKIE SYNACK option.

Process optional SYNACK data.

This is a significantly revised implementation of an earlier (year-old)
patch that no longer applies cleanly, with permission of the original
author (Adam Langley):

    http://thread.gmane.org/gmane.linux.network/102586

Requires:
   TCPCT part 1a: add request_values parameter for sending SYNACK
   TCPCT part 1b: generate Responder Cookie
   TCPCT part 1c: sysctl_tcp_cookie_size, socket option TCP_COOKIE_TRANSACTIONS
   TCPCT part 1d: define TCP cookie option, extend existing struct's
   TCPCT part 1e: implement socket option TCP_COOKIE_TRANSACTIONS
   TCPCT part 1f: Initiator Cookie => Responder

Signed-off-by: William.Allen.Simpson@gmail.com
---
  include/linux/tcp.h      |   11 ++++++
  include/net/tcp.h        |    1 +
  net/ipv4/syncookies.c    |    5 ++-
  net/ipv4/tcp_input.c     |   84 ++++++++++++++++++++++++++++++++++++++++------
  net/ipv4/tcp_ipv4.c      |   46 +++++++++++++++++++++++--
  net/ipv4/tcp_minisocks.c |   14 ++++---
  net/ipv4/tcp_output.c    |   75 ++++++++++++++++++++++++++++++++++++++--
  net/ipv6/syncookies.c    |    5 ++-
  net/ipv6/tcp_ipv6.c      |   51 +++++++++++++++++++++++++++-
  9 files changed, 261 insertions(+), 31 deletions(-)

--------------090604030205090005030005
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="TCPCT+1g6.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="TCPCT+1g6.patch"

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 6c5ff66..bbedc80 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -223,6 +223,17 @@ static inline unsigned int tcp_optlen(const struct sk_buff *skb)
 	return (tcp_hdr(skb)->doff - 5) * 4;
 }
 
+static inline unsigned int tcp_header_len_th(const struct tcphdr *th)
+{
+	return th->doff * 4;
+}
+
+/* When doff is bad, this could be negative. */
+static inline int tcp_option_len_th(const struct tcphdr *th)
+{
+	return (int)(th->doff * 4) - sizeof(*th);
+}
+
 /* This defines a selective acknowledgement block. */
 struct tcp_sack_block_wire {
 	__be32	start_seq;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 3a4c840..14796c4 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -407,6 +407,7 @@ extern int			tcp_recvmsg(struct kiocb *iocb, struct sock *sk,
 
 extern void			tcp_parse_options(struct sk_buff *skb,
 						  struct tcp_options_received *opt_rx,
+						  u8 **hvpp,
 						  int estab,
 						  struct dst_entry *dst);
 
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 3146cc4..26399ad 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -253,6 +253,8 @@ EXPORT_SYMBOL(cookie_check_timestamp);
 struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 			     struct ip_options *opt)
 {
+	struct tcp_options_received tcp_opt;
+	u8 *hash_location;
 	struct inet_request_sock *ireq;
 	struct tcp_request_sock *treq;
 	struct tcp_sock *tp = tcp_sk(sk);
@@ -263,7 +265,6 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	int mss;
 	struct rtable *rt;
 	__u8 rcv_wscale;
-	struct tcp_options_received tcp_opt;
 
 	if (!sysctl_tcp_syncookies || !th->ack)
 		goto out;
@@ -341,7 +342,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 
 	/* check for timestamp cookie support */
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
-	tcp_parse_options(skb, &tcp_opt, 0, &rt->u.dst);
+	tcp_parse_options(skb, &tcp_opt, &hash_location, 0, &rt->u.dst);
 
 	if (tcp_opt.saw_tstamp)
 		cookie_check_timestamp(&tcp_opt);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index cc306ac..104fe2d 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3698,7 +3698,7 @@ old_ack:
  * the fast version below fails.
  */
 void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
-		       int estab,  struct dst_entry *dst)
+		       u8 **hvpp, int estab,  struct dst_entry *dst)
 {
 	unsigned char *ptr;
 	struct tcphdr *th = tcp_hdr(skb);
@@ -3785,6 +3785,19 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
 				 */
 				break;
 #endif
+			case TCPOPT_COOKIE:
+				/* This option carries 3 different lengths.
+				 */
+				if (TCPOLEN_COOKIE_MAX >= opsize
+				 && TCPOLEN_COOKIE_MIN <= opsize) {
+					opt_rx->cookie_plus = opsize;
+					*hvpp = ptr;
+				} else if (TCPOLEN_COOKIE_PAIR == opsize) {
+					/* not yet implemented */
+				} else if (TCPOLEN_COOKIE_BASE == opsize) {
+					/* not yet implemented */
+				}
+				break;
 			}
 
 			ptr += opsize-2;
@@ -3813,17 +3826,20 @@ static int tcp_parse_aligned_timestamp(struct tcp_sock *tp, struct tcphdr *th)
  * If it is wrong it falls back on tcp_parse_options().
  */
 static int tcp_fast_parse_options(struct sk_buff *skb, struct tcphdr *th,
-				  struct tcp_sock *tp)
+				  struct tcp_sock *tp, u8 **hvpp)
 {
-	if (th->doff == sizeof(struct tcphdr) >> 2) {
+	/* In the spirit of fast parsing, compare doff directly to constant
+	 * values.  Because equality is used, short doff can be ignored here.
+	 */
+	if (th->doff == (sizeof(*th) / 4)) {
 		tp->rx_opt.saw_tstamp = 0;
 		return 0;
 	} else if (tp->rx_opt.tstamp_ok &&
-		   th->doff == (sizeof(struct tcphdr)>>2)+(TCPOLEN_TSTAMP_ALIGNED>>2)) {
+		   th->doff == ((sizeof(*th) + TCPOLEN_TSTAMP_ALIGNED) / 4)) {
 		if (tcp_parse_aligned_timestamp(tp, th))
 			return 1;
 	}
-	tcp_parse_options(skb, &tp->rx_opt, 1, NULL);
+	tcp_parse_options(skb, &tp->rx_opt, hvpp, 1, NULL);
 	return 1;
 }
 
@@ -5077,11 +5093,13 @@ out:
 static int tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
 			      struct tcphdr *th, int syn_inerr)
 {
+	u8 *hash_location;
 	struct tcp_sock *tp = tcp_sk(sk);
 
 	/* RFC1323: H1. Apply PAWS check first. */
-	if (tcp_fast_parse_options(skb, th, tp) && tp->rx_opt.saw_tstamp &&
-	    tcp_paws_discard(sk, skb)) {
+	if (tcp_fast_parse_options(skb, th, tp, &hash_location)
+	 && tp->rx_opt.saw_tstamp
+	 && tcp_paws_discard(sk, skb)) {
 		if (!th->rst) {
 			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSESTABREJECTED);
 			tcp_send_dupack(sk, skb);
@@ -5368,12 +5386,15 @@ discard:
 static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 					 struct tcphdr *th, unsigned len)
 {
-	struct tcp_sock *tp = tcp_sk(sk);
+	u8 *hash_location;
 	struct inet_connection_sock *icsk = inet_csk(sk);
-	int saved_clamp = tp->rx_opt.mss_clamp;
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct dst_entry *dst = __sk_dst_get(sk);
+	struct tcp_cookie_values *cvp = tp->cookie_values;
+	int saved_clamp = tp->rx_opt.mss_clamp;
+	int queued = 0;
 
-	tcp_parse_options(skb, &tp->rx_opt, 0, dst);
+	tcp_parse_options(skb, &tp->rx_opt, &hash_location, 0, dst);
 
 	if (th->ack) {
 		/* rfc793:
@@ -5470,6 +5491,44 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 		 * Change state from SYN-SENT only after copied_seq
 		 * is initialized. */
 		tp->copied_seq = tp->rcv_nxt;
+
+		if (cvp != NULL
+		 && cvp->cookie_pair_size > 0
+		 && tp->rx_opt.cookie_plus > 0) {
+			int cookie_size = tp->rx_opt.cookie_plus
+					- TCPOLEN_COOKIE_BASE;
+			int cookie_pair_size = cookie_size
+					     + cvp->cookie_desired;
+
+			/* A cookie extension option was sent and returned.
+			 * Note that each incoming SYNACK replaces the
+			 * Responder cookie.  The initial exchange is most
+			 * fragile, as protection against spoofing relies
+			 * entirely upon the sequence and timestamp (above).
+			 * This replacement strategy allows the correct pair to
+			 * pass through, while any others will be filtered via
+			 * Responder verification later.
+			 */
+			if (sizeof(cvp->cookie_pair) >= cookie_pair_size) {
+				memcpy(&cvp->cookie_pair[cvp->cookie_desired],
+				       hash_location, cookie_size);
+				cvp->cookie_pair_size = cookie_pair_size;
+			}
+
+			if (tcp_header_len_th(th) < skb->len) {
+				/* Queue incoming transaction data. */
+				__skb_pull(skb, tcp_header_len_th(th));
+				__skb_queue_tail(&sk->sk_receive_queue, skb);
+				skb_set_owner_r(skb, sk);
+				sk->sk_data_ready(sk, 0);
+				cvp->s_data_in = 1; /* true */
+				queued = 1; /* should be amount? */
+				tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
+				tp->rcv_wup = TCP_SKB_CB(skb)->end_seq;
+				tp->copied_seq = TCP_SKB_CB(skb)->seq + 1;
+			}
+		}
+
 		smp_mb();
 		tcp_set_state(sk, TCP_ESTABLISHED);
 
@@ -5521,11 +5580,14 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 						  TCP_DELACK_MAX, TCP_RTO_MAX);
 
 discard:
-			__kfree_skb(skb);
+			if (queued == 0)
+				__kfree_skb(skb);
 			return 0;
 		} else {
 			tcp_send_ack(sk);
 		}
+		if (queued > 0)
+			return 0; /* amount queued? */
 		return -1;
 	}
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 2ae1985..1597b66 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1213,9 +1213,12 @@ static struct timewait_sock_ops tcp_timewait_sock_ops = {
 
 int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 {
+	struct tcp_extend_values tmp_ext;
 	struct tcp_options_received tmp_opt;
+	u8 *hash_location;
 	struct request_sock *req;
 	struct inet_request_sock *ireq;
+	struct tcp_sock *tp = tcp_sk(sk);
 	struct dst_entry *dst = NULL;
 	__be32 saddr = ip_hdr(skb)->saddr;
 	__be32 daddr = ip_hdr(skb)->daddr;
@@ -1271,15 +1274,49 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 
 	tcp_clear_options(&tmp_opt);
 	tmp_opt.mss_clamp = TCP_MSS_DEFAULT;
-	tmp_opt.user_mss  = tcp_sk(sk)->rx_opt.user_mss;
+	tmp_opt.user_mss  = tp->rx_opt.user_mss;
+	tcp_parse_options(skb, &tmp_opt, &hash_location, 0, dst);
+
+	if (tmp_opt.cookie_plus > 0
+	 && tmp_opt.saw_tstamp
+	 && !tp->rx_opt.cookie_out_never
+	 && (sysctl_tcp_cookie_size > 0
+	  || (tp->cookie_values != NULL
+	   && tp->cookie_values->cookie_desired > 0))) {
+		u8 *c;
+		u32 *mess = &tmp_ext.cookie_bakery[COOKIE_DIGEST_WORDS];
+		int l = tmp_opt.cookie_plus - TCPOLEN_COOKIE_BASE;
+
+		if (tcp_cookie_generator(&tmp_ext.cookie_bakery[0]) != 0)
+			goto drop_and_release;
+
+		/* Secret recipe starts with IP addresses */
+		*mess++ ^= daddr;
+		*mess++ ^= saddr;
 
-	tcp_parse_options(skb, &tmp_opt, 0, dst);
+		/* plus variable length Initiator Cookie */
+		c = (u8 *)mess;
+		while (l-- > 0)
+			*c++ ^= *hash_location++;
+
+#ifdef CONFIG_SYN_COOKIES
+		want_cookie = 0;	/* not our kind of cookie */
+#endif
+		tmp_ext.cookie_out_never = 0; /* false */
+		tmp_ext.cookie_plus = tmp_opt.cookie_plus;
+	} else if (!tp->rx_opt.cookie_in_always) {
+		/* redundant indications, but ensure initialization. */
+		tmp_ext.cookie_out_never = 1; /* true */
+		tmp_ext.cookie_plus = 0;
+	} else {
+		goto drop_and_release;
+	}
+	tmp_ext.cookie_in_always = tp->rx_opt.cookie_in_always;
 
 	if (want_cookie && !tmp_opt.saw_tstamp)
 		tcp_clear_options(&tmp_opt);
 
 	tmp_opt.tstamp_ok = tmp_opt.saw_tstamp;
-
 	tcp_openreq_init(req, &tmp_opt, skb);
 
 	if (security_inet_conn_request(sk, skb, req))
@@ -1339,7 +1376,8 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	}
 	tcp_rsk(req)->snt_isn = isn;
 
-	if (__tcp_v4_send_synack(sk, dst, req, NULL)
+	if (__tcp_v4_send_synack(sk, dst, req,
+				 (struct request_values *)&tmp_ext)
 	 || want_cookie)
 		goto drop_and_free;
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 2b50da8..7b01ea0 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -96,13 +96,14 @@ enum tcp_tw_status
 tcp_timewait_state_process(struct inet_timewait_sock *tw, struct sk_buff *skb,
 			   const struct tcphdr *th)
 {
-	struct tcp_timewait_sock *tcptw = tcp_twsk((struct sock *)tw);
 	struct tcp_options_received tmp_opt;
+	u8 *hash_location;
+	struct tcp_timewait_sock *tcptw = tcp_twsk((struct sock *)tw);
 	int paws_reject = 0;
 
 	if (th->doff > (sizeof(*th) >> 2) && tcptw->tw_ts_recent_stamp) {
 		tmp_opt.tstamp_ok = 1;
-		tcp_parse_options(skb, &tmp_opt, 1, NULL);
+		tcp_parse_options(skb, &tmp_opt, &hash_location, 1, NULL);
 
 		if (tmp_opt.saw_tstamp) {
 			tmp_opt.ts_recent	= tcptw->tw_ts_recent;
@@ -523,15 +524,16 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 			   struct request_sock *req,
 			   struct request_sock **prev)
 {
+	struct tcp_options_received tmp_opt;
+	u8 *hash_location;
+	struct sock *child;
 	const struct tcphdr *th = tcp_hdr(skb);
 	__be32 flg = tcp_flag_word(th) & (TCP_FLAG_RST|TCP_FLAG_SYN|TCP_FLAG_ACK);
 	int paws_reject = 0;
-	struct tcp_options_received tmp_opt;
-	struct sock *child;
 
-	if ((th->doff > (sizeof(struct tcphdr)>>2)) && (req->ts_recent)) {
+	if ((th->doff > (sizeof(*th) >> 2)) && (req->ts_recent)) {
 		tmp_opt.tstamp_ok = 1;
-		tcp_parse_options(skb, &tmp_opt, 1, NULL);
+		tcp_parse_options(skb, &tmp_opt, &hash_location, 1, NULL);
 
 		if (tmp_opt.saw_tstamp) {
 			tmp_opt.ts_recent = req->ts_recent;
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e1553d3..18708d3 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -661,9 +661,14 @@ static unsigned tcp_synack_options(struct sock *sk,
 				   struct request_sock *req,
 				   unsigned mss, struct sk_buff *skb,
 				   struct tcp_out_options *opts,
-				   struct tcp_md5sig_key **md5) {
-	unsigned size = 0;
+				   struct tcp_md5sig_key **md5,
+				   struct tcp_extend_values *xvp)
+{
 	struct inet_request_sock *ireq = inet_rsk(req);
+	unsigned size = 0;
+	u8 cookie_plus = (xvp != NULL && !xvp->cookie_out_never)
+			 ? xvp->cookie_plus
+			 : 0;
 	char doing_ts;
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -702,6 +707,28 @@ static unsigned tcp_synack_options(struct sock *sk,
 			size += TCPOLEN_SACKPERM_ALIGNED;
 	}
 
+	/* Similar rationale to tcp_syn_options() applies here, too.
+	 * If the <SYN> options fit, the same options should fit now!
+	 */
+	if (*md5 == NULL
+	 && doing_ts
+	 && cookie_plus > TCPOLEN_COOKIE_BASE) {
+		int need = cookie_plus; /* has TCPOLEN_COOKIE_BASE */
+		int remaining = MAX_TCP_OPTION_SPACE - size;
+
+		if (0x2 & need) {
+			/* 32-bit multiple */
+			need += 2; /* NOPs */
+		}
+		if (need <= remaining) {
+			opts->options |= OPTION_COOKIE_EXTENSION;
+			opts->hash_size = cookie_plus - TCPOLEN_COOKIE_BASE;
+			size += need;
+		} else {
+			/* There's no error return, so flag it. */
+			xvp->cookie_out_never = 1; /* true */
+		}
+	}
 	return size;
 }
 
@@ -2371,6 +2398,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 				struct request_values *rvp)
 {
 	struct tcp_out_options opts;
+	struct tcp_extend_values *xvp = tcp_xv(rvp);
 	struct inet_request_sock *ireq = inet_rsk(req);
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcphdr *th;
@@ -2414,8 +2442,8 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 #endif
 	TCP_SKB_CB(skb)->when = tcp_time_stamp;
 	tcp_header_size = tcp_synack_options(sk, req, mss,
-					     skb, &opts, &md5) +
-			  sizeof(struct tcphdr);
+					     skb, &opts, &md5, xvp)
+			+ sizeof(*th);
 
 	skb_push(skb, tcp_header_size);
 	skb_reset_transport_header(skb);
@@ -2432,6 +2460,45 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	 */
 	tcp_init_nondata_skb(skb, tcp_rsk(req)->snt_isn,
 			     TCPCB_FLAG_SYN | TCPCB_FLAG_ACK);
+
+	if (OPTION_COOKIE_EXTENSION & opts.options) {
+		const struct tcp_cookie_values *cvp = tp->cookie_values;
+
+		if (cvp != NULL
+		 && cvp->s_data_constant
+		 && cvp->s_data_desired > 0) {
+			u8 *buf = skb_put(skb, cvp->s_data_desired);
+
+			/* copy data directly from the listening socket. */
+			memcpy(buf, cvp->s_data_payload, cvp->s_data_desired);
+			TCP_SKB_CB(skb)->end_seq += cvp->s_data_desired;
+		}
+
+		if (opts.hash_size > 0) {
+			__u32 workspace[SHA_WORKSPACE_WORDS];
+			u32 *mess = &xvp->cookie_bakery[COOKIE_DIGEST_WORDS];
+			u32 *tail = &mess[COOKIE_MESSAGE_WORDS-1];
+
+			/* Secret recipe depends on the Timestamp, (future)
+			 * Sequence and Acknowledgment Numbers, Initiator
+			 * Cookie, and others handled by IP variant caller.
+			 */
+			*tail-- ^= opts.tsval;
+			*tail-- ^= tcp_rsk(req)->rcv_isn + 1;
+			*tail-- ^= TCP_SKB_CB(skb)->seq + 1;
+
+			/* recommended */
+			*tail-- ^= ((th->dest << 16) | th->source);
+			*tail-- ^= (u32)cvp; /* per sockopt */
+
+			sha_transform((__u32 *)&xvp->cookie_bakery[0],
+				      (char *)mess,
+				      &workspace[0]);
+			opts.hash_location =
+				(__u8 *)&xvp->cookie_bakery[0];
+		}
+	}
+
 	th->seq = htonl(TCP_SKB_CB(skb)->seq);
 	th->ack_seq = htonl(tcp_rsk(req)->rcv_isn + 1);
 
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 612fc53..5b9af50 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -159,6 +159,8 @@ static inline int cookie_check(struct sk_buff *skb, __u32 cookie)
 
 struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 {
+	struct tcp_options_received tcp_opt;
+	u8 *hash_location;
 	struct inet_request_sock *ireq;
 	struct inet6_request_sock *ireq6;
 	struct tcp_request_sock *treq;
@@ -171,7 +173,6 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	int mss;
 	struct dst_entry *dst;
 	__u8 rcv_wscale;
-	struct tcp_options_received tcp_opt;
 
 	if (!sysctl_tcp_syncookies || !th->ack)
 		goto out;
@@ -254,7 +255,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 
 	/* check for timestamp cookie support */
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
-	tcp_parse_options(skb, &tcp_opt, 0, dst);
+	tcp_parse_options(skb, &tcp_opt, &hash_location, 0, dst);
 
 	if (tcp_opt.saw_tstamp)
 		cookie_check_timestamp(&tcp_opt);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 2b16f9a..5005ba2 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1162,7 +1162,9 @@ static struct sock *tcp_v6_hnd_req(struct sock *sk,struct sk_buff *skb)
  */
 static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 {
+	struct tcp_extend_values tmp_ext;
 	struct tcp_options_received tmp_opt;
+	u8 *hash_location;
 	struct request_sock *req;
 	struct inet6_request_sock *treq;
 	struct ipv6_pinfo *np = inet6_sk(sk);
@@ -1206,8 +1208,52 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	tcp_clear_options(&tmp_opt);
 	tmp_opt.mss_clamp = IPV6_MIN_MTU - sizeof(struct tcphdr) - sizeof(struct ipv6hdr);
 	tmp_opt.user_mss = tp->rx_opt.user_mss;
+	tcp_parse_options(skb, &tmp_opt, &hash_location, 0, dst);
+
+	if (tmp_opt.cookie_plus > 0
+	 && tmp_opt.saw_tstamp
+	 && !tp->rx_opt.cookie_out_never
+	 && (sysctl_tcp_cookie_size > 0
+	  || (tp->cookie_values != NULL
+	   && tp->cookie_values->cookie_desired > 0))) {
+		u8 *c;
+		u32 *d;
+		u32 *mess = &tmp_ext.cookie_bakery[COOKIE_DIGEST_WORDS];
+		int l = tmp_opt.cookie_plus - TCPOLEN_COOKIE_BASE;
+
+		if (tcp_cookie_generator(&tmp_ext.cookie_bakery[0]) != 0)
+			goto drop_and_free;
+
+		/* Secret recipe starts with IP addresses */
+		d = &ipv6_hdr(skb)->daddr.s6_addr32[0];
+		*mess++ ^= *d++;
+		*mess++ ^= *d++;
+		*mess++ ^= *d++;
+		*mess++ ^= *d++;
+		d = &ipv6_hdr(skb)->saddr.s6_addr32[0];
+		*mess++ ^= *d++;
+		*mess++ ^= *d++;
+		*mess++ ^= *d++;
+		*mess++ ^= *d++;
+
+		/* plus variable length Initiator Cookie */
+		c = (u8 *)mess;
+		while (l-- > 0)
+			*c++ ^= *hash_location++;
 
-	tcp_parse_options(skb, &tmp_opt, 0, dst);
+#ifdef CONFIG_SYN_COOKIES
+		want_cookie = 0;	/* not our kind of cookie */
+#endif
+		tmp_ext.cookie_out_never = 0; /* false */
+		tmp_ext.cookie_plus = tmp_opt.cookie_plus;
+	} else if (!tp->rx_opt.cookie_in_always) {
+		/* redundant indications, but ensure initialization. */
+		tmp_ext.cookie_out_never = 1; /* true */
+		tmp_ext.cookie_plus = 0;
+	} else {
+		goto drop_and_free;
+	}
+	tmp_ext.cookie_in_always = tp->rx_opt.cookie_in_always;
 
 	if (want_cookie && !tmp_opt.saw_tstamp)
 		tcp_clear_options(&tmp_opt);
@@ -1244,7 +1290,8 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 
 	security_inet_conn_request(sk, skb, req);
 
-	if (tcp_v6_send_synack(sk, req, NULL)
+	if (tcp_v6_send_synack(sk, req,
+			       (struct request_values *)&tmp_ext)
 	 || want_cookie)
 		goto drop_and_free;
 
-- 
1.6.3.3


--------------090604030205090005030005--
