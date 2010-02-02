From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH v3 6/7] TCPCT part 2f: cleanup tcp_parse_options
Date: Tue, 02 Feb 2010 11:37:52 -0500
Message-ID: <4B6854E0.7000009@gmail.com>
References: <4B684DE7.3020601@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000306050604030105070404"
Cc: Andrew Morton <akpm@linux-foundation.org>
To: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B684DE7.3020601@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000306050604030105070404
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Split switch, shift cases to the left, fix most lines beyond column 80.

Prepare (future) error return.

Requires:
   TCPCT part 1g: Responder Cookie => Initiator
   net: tcp_header_len_th and tcp_option_len_th

Signed-off-by: William.Allen.Simpson@gmail.com
---
  include/net/tcp.h        |    3 +-
  net/ipv4/syncookies.c    |    5 +-
  net/ipv4/tcp_input.c     |  217 ++++++++++++++++++++++++++--------------------
  net/ipv4/tcp_ipv4.c      |   10 ++-
  net/ipv4/tcp_minisocks.c |   14 ++-
  net/ipv6/syncookies.c    |    5 +-
  net/ipv6/tcp_ipv6.c      |    6 +-
  7 files changed, 154 insertions(+), 106 deletions(-)

--------------000306050604030105070404
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="TCPCT+2f3+2.6.33-rc6.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="TCPCT+2f3+2.6.33-rc6.patch"

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 6b0d7e9..420e872 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -403,7 +403,8 @@ extern int			tcp_recvmsg(struct kiocb *iocb, struct sock *sk,
 					    size_t len, int nonblock, 
 					    int flags, int *addr_len);
 
-extern void			tcp_parse_options(struct sk_buff *skb,
+extern int			tcp_parse_options(struct sk_buff *skb,
+						  const struct tcphdr *th,
 						  struct tcp_options_received *opt_rx,
 						  u8 **hvpp,
 						  int estab);
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 66fd80e..3bed530 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -254,6 +254,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 			     struct ip_options *opt)
 {
 	struct tcp_options_received tcp_opt;
+	int parsed;
 	u8 *hash_location;
 	struct inet_request_sock *ireq;
 	struct tcp_request_sock *treq;
@@ -279,7 +280,9 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 
 	/* check for timestamp cookie support */
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
-	tcp_parse_options(skb, &tcp_opt, &hash_location, 0);
+	parsed = tcp_parse_options(skb, th, &tcp_opt, &hash_location, 0);
+	if (parsed < 0)
+		goto out;
 
 	if (tcp_opt.saw_tstamp)
 		cookie_check_timestamp(&tcp_opt);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 165040e..d3c6c7a 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3726,15 +3726,14 @@ old_ack:
  * But, this can also be called on packets in the established flow when
  * the fast version below fails.
  */
-void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
-		       u8 **hvpp, int estab)
+int tcp_parse_options(struct sk_buff *skb, const struct tcphdr *th,
+		      struct tcp_options_received *opt_rx, u8 **hvpp, int estab)
 {
-	unsigned char *ptr;
-	struct tcphdr *th = tcp_hdr(skb);
-	int length = (th->doff * 4) - sizeof(struct tcphdr);
+	unsigned char *ptr = (unsigned char *)(th + 1);
+	int length = tcp_option_len_th(th);
 
-	ptr = (unsigned char *)(th + 1);
-	opt_rx->saw_tstamp = 0;
+	opt_rx->cookie_plus = 0;
+	opt_rx->saw_tstamp = 0; /* false */
 
 	while (length > 0) {
 		int opcode = *ptr++;
@@ -3742,106 +3741,130 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
 
 		switch (opcode) {
 		case TCPOPT_EOL:
-			return;
+			return 0;
 		case TCPOPT_NOP:	/* Ref: RFC 793 section 3.1 */
 			length--;
 			continue;
 		default:
-			opsize = *ptr++;
-			if (opsize < 2) /* "silly options" */
-				return;
-			if (opsize > length)
-				return;	/* don't parse partial options */
-			switch (opcode) {
-			case TCPOPT_MSS:
-				if (opsize == TCPOLEN_MSS && th->syn && !estab) {
-					u16 in_mss = get_unaligned_be16(ptr);
-					if (in_mss) {
-						if (opt_rx->user_mss &&
-						    opt_rx->user_mss < in_mss)
-							in_mss = opt_rx->user_mss;
-						opt_rx->mss_clamp = in_mss;
-					}
-				}
-				break;
-			case TCPOPT_WINDOW:
-				if (opsize == TCPOLEN_WINDOW && th->syn &&
-				    !estab && sysctl_tcp_window_scaling) {
-					__u8 snd_wscale = *(__u8 *)ptr;
-					opt_rx->wscale_ok = 1;
-					if (snd_wscale > 14) {
-						if (net_ratelimit())
-							printk(KERN_INFO "tcp_parse_options: Illegal window "
-							       "scaling value %d >14 received.\n",
-							       snd_wscale);
-						snd_wscale = 14;
-					}
-					opt_rx->snd_wscale = snd_wscale;
-				}
-				break;
-			case TCPOPT_TIMESTAMP:
-				if ((opsize == TCPOLEN_TIMESTAMP) &&
-				    ((estab && opt_rx->tstamp_ok) ||
-				     (!estab && sysctl_tcp_timestamps))) {
-					opt_rx->saw_tstamp = 1;
-					opt_rx->rcv_tsval = get_unaligned_be32(ptr);
-					opt_rx->rcv_tsecr = get_unaligned_be32(ptr + 4);
-				}
-				break;
-			case TCPOPT_SACK_PERM:
-				if (opsize == TCPOLEN_SACK_PERM && th->syn &&
-				    !estab && sysctl_tcp_sack) {
-					opt_rx->sack_ok = 1;
-					tcp_sack_reset(opt_rx);
+			/* fallthru */
+			break;
+		};
+
+		opsize = *ptr++;
+		if (opsize < 2 || opsize > length) {
+			/* don't parse partial options */
+			return 0;
+		}
+
+		switch (opcode) {
+		case TCPOPT_MSS:
+			if (opsize == TCPOLEN_MSS && th->syn && !estab) {
+				u16 in_mss = get_unaligned_be16(ptr);
+				if (in_mss) {
+					if (opt_rx->user_mss &&
+					    opt_rx->user_mss < in_mss)
+						in_mss = opt_rx->user_mss;
+					opt_rx->mss_clamp = in_mss;
 				}
-				break;
+			}
+			break;
 
-			case TCPOPT_SACK:
-				if ((opsize >= (TCPOLEN_SACK_BASE + TCPOLEN_SACK_PERBLOCK)) &&
-				   !((opsize - TCPOLEN_SACK_BASE) % TCPOLEN_SACK_PERBLOCK) &&
-				   opt_rx->sack_ok) {
-					TCP_SKB_CB(skb)->sacked = (ptr - 2) - (unsigned char *)th;
+		case TCPOPT_WINDOW:
+			if (opsize == TCPOLEN_WINDOW && th->syn &&
+			    !estab && sysctl_tcp_window_scaling) {
+				__u8 snd_wscale = *(__u8 *)ptr;
+				opt_rx->wscale_ok = 1;
+				if (snd_wscale > 14) {
+					if (net_ratelimit())
+						printk(KERN_INFO
+						       "tcp_parse_options: "
+						       "window scaling value "
+						       "%d > 14 received.\n",
+						       snd_wscale);
+					snd_wscale = 14;
 				}
-				break;
+				opt_rx->snd_wscale = snd_wscale;
+			}
+			break;
+
+		case TCPOPT_SACK_PERM:
+			if (opsize == TCPOLEN_SACK_PERM && th->syn &&
+			    !estab && sysctl_tcp_sack) {
+				opt_rx->sack_ok = 1;
+				tcp_sack_reset(opt_rx);
+			}
+			break;
+
+		case TCPOPT_SACK:
+			if ((opsize >= (TCPOLEN_SACK_BASE + TCPOLEN_SACK_PERBLOCK)) &&
+			    !((opsize - TCPOLEN_SACK_BASE) % TCPOLEN_SACK_PERBLOCK) &&
+			    opt_rx->sack_ok) {
+				TCP_SKB_CB(skb)->sacked = (ptr - 2)
+							- (unsigned char *)th;
+			}
+			break;
+
+		case TCPOPT_TIMESTAMP:
+			if ((opsize == TCPOLEN_TIMESTAMP) &&
+			    ((estab && opt_rx->tstamp_ok) ||
+			     (!estab && sysctl_tcp_timestamps))) {
+				opt_rx->saw_tstamp = 1;
+				opt_rx->rcv_tsval = get_unaligned_be32(ptr);
+				opt_rx->rcv_tsecr = get_unaligned_be32(ptr + 4);
+			}
+			break;
 #ifdef CONFIG_TCP_MD5SIG
-			case TCPOPT_MD5SIG:
-				/*
-				 * The MD5 Hash has already been
-				 * checked (see tcp_v{4,6}_do_rcv()).
-				 */
-				break;
+		case TCPOPT_MD5SIG:
+			/*
+			 * The MD5 Hash has already been
+			 * checked (see tcp_v{4,6}_do_rcv()).
+			 */
+			break;
 #endif
-			case TCPOPT_COOKIE:
-				/* This option is variable length.
-				 */
-				switch (opsize) {
-				case TCPOLEN_COOKIE_BASE:
-					/* not yet implemented */
-					break;
-				case TCPOLEN_COOKIE_PAIR:
-					/* not yet implemented */
-					break;
-				case TCPOLEN_COOKIE_MIN+0:
-				case TCPOLEN_COOKIE_MIN+2:
-				case TCPOLEN_COOKIE_MIN+4:
-				case TCPOLEN_COOKIE_MIN+6:
-				case TCPOLEN_COOKIE_MAX:
-					/* 16-bit multiple */
+		case TCPOPT_COOKIE:
+			/* This option is variable length.
+			 */
+			switch (opsize) {
+			case TCPOLEN_COOKIE_BASE:
+				/* not yet implemented */
+				break;
+			case TCPOLEN_COOKIE_PAIR:
+				/* not yet implemented */
+				break;
+			case TCPOLEN_COOKIE_MIN+0:
+			case TCPOLEN_COOKIE_MIN+2:
+			case TCPOLEN_COOKIE_MIN+4:
+			case TCPOLEN_COOKIE_MIN+6:
+			case TCPOLEN_COOKIE_MAX:
+				/* 16-bit multiple */
+				if (th->syn && opt_rx->saw_tstamp &&
+				    opt_rx->cookie_plus == 0) {
 					opt_rx->cookie_plus = opsize;
 					*hvpp = ptr;
-				default:
-					/* ignore option */
-					break;
-				};
+				}
+				break;
+			default:
+				/* ignore option */
 				break;
 			};
+			break;
 
-			ptr += opsize-2;
-			length -= opsize;
-		}
+		default:
+			/* skip unrecognized options */
+			break;
+		};
+
+		ptr += opsize - 2;
+		length -= opsize;
 	}
+	return 0;
 }
 
+/*
+ * Returns:
+ *	1 on success
+ *	0 on failure
+ */
 static int tcp_parse_aligned_timestamp(struct tcp_sock *tp, struct tcphdr *th)
 {
 	__be32 *ptr = (__be32 *)(th + 1);
@@ -3875,8 +3898,7 @@ static int tcp_fast_parse_options(struct sk_buff *skb, struct tcphdr *th,
 		if (tcp_parse_aligned_timestamp(tp, th))
 			return 1;
 	}
-	tcp_parse_options(skb, &tp->rx_opt, hvpp, 1);
-	return 1;
+	return tcp_parse_options(skb, th, &tp->rx_opt, hvpp, 1);
 }
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -5127,10 +5149,13 @@ static int tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
 {
 	u8 *hash_location;
 	struct tcp_sock *tp = tcp_sk(sk);
+	int parsed = tcp_fast_parse_options(skb, th, tp, &hash_location);
+
+	if (parsed < 0)
+		goto discard;
 
 	/* RFC1323: H1. Apply PAWS check first. */
-	if (tcp_fast_parse_options(skb, th, tp, &hash_location) &&
-	    tp->rx_opt.saw_tstamp &&
+	if (tp->rx_opt.saw_tstamp &&
 	    tcp_paws_discard(sk, skb)) {
 		if (!th->rst) {
 			NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_PAWSESTABREJECTED);
@@ -5410,8 +5435,10 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 	struct tcp_cookie_values *cvp = tp->cookie_values;
 	int saved_clamp = tp->rx_opt.mss_clamp;
 	int queued = 0;
+	int parsed = tcp_parse_options(skb, th, &tp->rx_opt, &hash_location, 0);
 
-	tcp_parse_options(skb, &tp->rx_opt, &hash_location, 0);
+	if (parsed < 0)
+		goto discard;
 
 	if (th->ack) {
 		/* rfc793:
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index f999e06..3f0813f 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1215,6 +1215,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_extend_values tmp_ext;
 	struct tcp_options_received tmp_opt;
+	int parsed;
 	u8 *hash_location;
 	struct request_sock *req;
 	struct inet_request_sock *ireq;
@@ -1265,7 +1266,10 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	tcp_clear_options(&tmp_opt);
 	tmp_opt.mss_clamp = TCP_MSS_DEFAULT;
 	tmp_opt.user_mss  = tp->rx_opt.user_mss;
-	tcp_parse_options(skb, &tmp_opt, &hash_location, 0);
+	parsed = tcp_parse_options(skb, tcp_hdr(skb), &tmp_opt, &hash_location,
+				   0);
+	if (parsed < 0)
+		goto drop_and_free;
 
 	if (tmp_opt.cookie_plus > 0 &&
 	    tmp_opt.saw_tstamp &&
@@ -1278,7 +1282,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		int l = tmp_opt.cookie_plus - TCPOLEN_COOKIE_BASE;
 
 		if (tcp_cookie_generator(&tmp_ext.cookie_bakery[0]) != 0)
-			goto drop_and_release;
+			goto drop_and_free;
 
 		/* Secret recipe starts with IP addresses */
 		*mess++ ^= daddr;
@@ -1299,7 +1303,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		tmp_ext.cookie_out_never = 1; /* true */
 		tmp_ext.cookie_plus = 0;
 	} else {
-		goto drop_and_release;
+		goto drop_and_free;
 	}
 	tmp_ext.cookie_in_always = tp->rx_opt.cookie_in_always;
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 37b7536..0d42635 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -97,9 +97,12 @@ tcp_timewait_state_process(struct inet_timewait_sock *tw, struct sk_buff *skb,
 
 	tmp_opt.saw_tstamp = 0;
 	if (th->doff > (sizeof(*th) >> 2) && tcptw->tw_ts_recent_stamp) {
-		tcp_parse_options(skb, &tmp_opt, &hash_location, 0);
+		int parsed = tcp_parse_options(skb, th, &tmp_opt,
+					       &hash_location, 0);
 
-		if (tmp_opt.saw_tstamp) {
+		if (parsed < 0) {
+			paws_reject = 1; /* true */
+		} else if (tmp_opt.saw_tstamp) {
 			tmp_opt.ts_recent	= tcptw->tw_ts_recent;
 			tmp_opt.ts_recent_stamp	= tcptw->tw_ts_recent_stamp;
 			paws_reject = tcp_paws_reject(&tmp_opt, th->rst);
@@ -528,9 +531,12 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 
 	tmp_opt.saw_tstamp = 0;
 	if (th->doff > (sizeof(struct tcphdr)>>2)) {
-		tcp_parse_options(skb, &tmp_opt, &hash_location, 0);
+		int parsed = tcp_parse_options(skb, th, &tmp_opt,
+					       &hash_location, 0);
 
-		if (tmp_opt.saw_tstamp) {
+		if (parsed < 0) {
+			paws_reject = 1; /* true */
+		} else if (tmp_opt.saw_tstamp) {
 			tmp_opt.ts_recent = req->ts_recent;
 			/* We do not store true stamp, but it is not required,
 			 * it can be estimated (approximately)
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 7208a06..3072500 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -160,6 +160,7 @@ static inline int cookie_check(struct sk_buff *skb, __u32 cookie)
 struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_options_received tcp_opt;
+	int parsed;
 	u8 *hash_location;
 	struct inet_request_sock *ireq;
 	struct inet6_request_sock *ireq6;
@@ -187,7 +188,9 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 
 	/* check for timestamp cookie support */
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
-	tcp_parse_options(skb, &tcp_opt, &hash_location, 0);
+	parsed = tcp_parse_options(skb, th, &tcp_opt, &hash_location, 0);
+	if (parsed < 0)
+		goto out;
 
 	if (tcp_opt.saw_tstamp)
 		cookie_check_timestamp(&tcp_opt);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 3d08a4d..e15e4f6 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1164,6 +1164,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_extend_values tmp_ext;
 	struct tcp_options_received tmp_opt;
+	int parsed;
 	u8 *hash_location;
 	struct request_sock *req;
 	struct inet6_request_sock *treq;
@@ -1207,7 +1208,10 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	tcp_clear_options(&tmp_opt);
 	tmp_opt.mss_clamp = IPV6_MIN_MTU - sizeof(struct tcphdr) - sizeof(struct ipv6hdr);
 	tmp_opt.user_mss = tp->rx_opt.user_mss;
-	tcp_parse_options(skb, &tmp_opt, &hash_location, 0);
+	parsed = tcp_parse_options(skb, tcp_hdr(skb), &tmp_opt, &hash_location,
+				   0);
+	if (parsed < 0)
+		goto drop_and_free;
 
 	if (tmp_opt.cookie_plus > 0 &&
 	    tmp_opt.saw_tstamp &&
-- 
1.6.3.3


--------------000306050604030105070404--
