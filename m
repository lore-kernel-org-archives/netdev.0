From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH v6 6/7] TCPCT part 2f: cleanup tcp_parse_options
Date: Thu, 11 Mar 2010 07:48:47 -0500
Message-ID: <4B98E6AF.1000609@gmail.com>
References: <4B98D592.6040301@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020700010002000608020209"
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f217.google.com ([209.85.217.217]:53315 "EHLO
	mail-gx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757807Ab0CKMsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 07:48:51 -0500
In-Reply-To: <4B98D592.6040301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020700010002000608020209
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Split switch, shift cases to the left, fix most lines beyond column 80.

Add error return.

Harmonize parameter order with other tcp_input functions:
tcp_fast_parse_options() and tcp_validate_incoming().

Harmonize initialization in syncookies.
Fix initialization in tcp_minisocks.

Repair net/ipv4/tcp_ipv4.c errors with goto targets, overlooked by
David Miller in commit bb5b7c11263dbbe78253cd05945a6bf8f55add8e

[updated to latest posted internet draft-simpson-tcpct-00]

Requires:
   TCPCT part 1g: Responder Cookie => Initiator
   net: tcp_header_len_th and tcp_option_len_th

Signed-off-by: William.Allen.Simpson@gmail.com
---
  include/net/tcp.h        |    5 +-
  net/ipv4/syncookies.c    |    9 +-
  net/ipv4/tcp_input.c     |  238 +++++++++++++++++++++++++++-------------------
  net/ipv4/tcp_ipv4.c      |   10 ++-
  net/ipv4/tcp_minisocks.c |   26 ++++--
  net/ipv6/syncookies.c    |    9 +-
  net/ipv6/tcp_ipv6.c      |    6 +-
  7 files changed, 185 insertions(+), 118 deletions(-)

--------------020700010002000608020209
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="TCPCT+2f6+2.6.34-rc1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="TCPCT+2f6+2.6.34-rc1.patch"

diff --git a/include/net/tcp.h b/include/net/tcp.h
index ff2f1c3..f8c99fa 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -410,8 +410,9 @@ extern int			tcp_recvmsg(struct kiocb *iocb, struct sock *sk,
 					    size_t len, int nonblock, 
 					    int flags, int *addr_len);
 
-extern void			tcp_parse_options(struct sk_buff *skb,
-						  struct tcp_options_received *opt_rx,
+extern int			tcp_parse_options(struct tcp_options_received *opt_rx,
+						  struct sk_buff *skb,
+						  const struct tcphdr *th,
 						  u8 **hvpp,
 						  int estab);
 
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 5c24db4..abaa7d7 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -255,15 +255,16 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 {
 	struct tcp_options_received tcp_opt;
 	u8 *hash_location;
+	struct rtable *rt;
+	struct request_sock *req;
 	struct inet_request_sock *ireq;
 	struct tcp_request_sock *treq;
 	struct tcp_sock *tp = tcp_sk(sk);
 	const struct tcphdr *th = tcp_hdr(skb);
 	__u32 cookie = ntohl(th->ack_seq) - 1;
 	struct sock *ret = sk;
-	struct request_sock *req;
 	int mss;
-	struct rtable *rt;
+	int parsed;
 	__u8 rcv_wscale;
 
 	if (!sysctl_tcp_syncookies || !th->ack)
@@ -279,7 +280,9 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 
 	/* check for timestamp cookie support */
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
-	tcp_parse_options(skb, &tcp_opt, &hash_location, 0);
+	parsed = tcp_parse_options(&tcp_opt, skb, th, &hash_location, 0);
+	if (parsed < 0)
+		goto out;
 
 	if (tcp_opt.saw_tstamp)
 		cookie_check_timestamp(&tcp_opt);
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 7371406..cc26090 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3737,123 +3737,154 @@ old_ack:
 /* Look for tcp options. Normally only called on SYN and SYNACK packets.
  * But, this can also be called on packets in the established flow when
  * the fast version below fails.
+ *
+ * Returns:
+ *	0 on success
+ *	- on failure
  */
-void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
-		       u8 **hvpp, int estab)
+int tcp_parse_options(struct tcp_options_received *opt_rx, struct sk_buff *skb,
+		      const struct tcphdr *th, u8 **hvpp, int estab)
 {
-	unsigned char *ptr;
-	struct tcphdr *th = tcp_hdr(skb);
-	int length = (th->doff * 4) - sizeof(struct tcphdr);
+	unsigned char *ptr = (unsigned char *)(th + 1);
+	int length = tcp_option_len_th(th);
+	bool syn = th->syn;
 
-	ptr = (unsigned char *)(th + 1);
-	opt_rx->saw_tstamp = 0;
+	opt_rx->cookie_plus = 0;
+	opt_rx->saw_tstamp = 0; /* false */
 
 	while (length > 0) {
-		int opcode = *ptr++;
 		int opsize;
+		int opcode = *ptr++;
 
 		switch (opcode) {
 		case TCPOPT_EOL:
-			return;
+			length = 0;
+			continue;
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
+			break;
+		}
+
+		switch (opcode) {
+		case TCPOPT_MSS:
+			if (opsize == TCPOLEN_MSS && syn && !estab) {
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
+			if (opsize == TCPOLEN_WINDOW && syn &&
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
+			if (opsize == TCPOLEN_SACK_PERM && syn &&
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
+			 * checked (see tcp_v[4,6]_do_rcv()).
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
+			if (unlikely(opt_rx->cookie_plus > 0)) {
+				/* discard duplicate */
+				return -length;
+			}
+			switch (opsize) {
+			case TCPOLEN_COOKIE_BASE:
+				/* not yet implemented */
+				break;
+			case TCPOLEN_COOKIE_PAIR: {
+				/* not yet implemented */
+				break;
+			}
+			case TCPOLEN_COOKIE_MIN+0:
+			case TCPOLEN_COOKIE_MIN+2:
+			case TCPOLEN_COOKIE_MIN+4:
+			case TCPOLEN_COOKIE_MIN+6:
+			case TCPOLEN_COOKIE_MAX:
+				/* 16-bit multiple */
+				if (syn) {
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
@@ -3872,9 +3903,14 @@ static int tcp_parse_aligned_timestamp(struct tcp_sock *tp, struct tcphdr *th)
 
 /* Fast parse options. This hopes to only see timestamps.
  * If it is wrong it falls back on tcp_parse_options().
+ *
+ * Returns:
+ *	1 on success, fast
+ *	0 on success, slow
+ *	- on failure
  */
-static int tcp_fast_parse_options(struct sk_buff *skb, struct tcphdr *th,
-				  struct tcp_sock *tp, u8 **hvpp)
+static int tcp_fast_parse_options(struct tcp_sock *tp, struct sk_buff *skb,
+				  struct tcphdr *th, u8 **hvpp)
 {
 	/* In the spirit of fast parsing, compare doff directly to constant
 	 * values.  Because equality is used, short doff can be ignored here.
@@ -3887,8 +3923,7 @@ static int tcp_fast_parse_options(struct sk_buff *skb, struct tcphdr *th,
 		if (tcp_parse_aligned_timestamp(tp, th))
 			return 1;
 	}
-	tcp_parse_options(skb, &tp->rx_opt, hvpp, 1);
-	return 1;
+	return tcp_parse_options(&tp->rx_opt, skb, th, hvpp, 1);
 }
 
 #ifdef CONFIG_TCP_MD5SIG
@@ -5135,14 +5170,17 @@ out:
  * play significant role here.
  */
 static int tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
-			      struct tcphdr *th, int syn_inerr)
+				 struct tcphdr *th, int syn_inerr)
 {
 	u8 *hash_location;
 	struct tcp_sock *tp = tcp_sk(sk);
+	int parsed = tcp_fast_parse_options(tp, skb, th, &hash_location);
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
@@ -5424,8 +5462,10 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 	struct tcp_cookie_values *cvp = tp->cookie_values;
 	int saved_clamp = tp->rx_opt.mss_clamp;
 	int queued = 0;
+	int parsed = tcp_parse_options(&tp->rx_opt, skb, th, &hash_location, 0);
 
-	tcp_parse_options(skb, &tp->rx_opt, &hash_location, 0);
+	if (parsed < 0)
+		goto discard;
 
 	if (th->ack) {
 		/* rfc793:
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 1860590..bdfa9c5 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1217,6 +1217,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_extend_values tmp_ext;
 	struct tcp_options_received tmp_opt;
+	int parsed;
 	u8 *hash_location;
 	struct request_sock *req;
 	struct inet_request_sock *ireq;
@@ -1267,7 +1268,10 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	tcp_clear_options(&tmp_opt);
 	tmp_opt.mss_clamp = TCP_MSS_DEFAULT;
 	tmp_opt.user_mss  = tp->rx_opt.user_mss;
-	tcp_parse_options(skb, &tmp_opt, &hash_location, 0);
+	parsed = tcp_parse_options(&tmp_opt, skb, tcp_hdr(skb),
+				   &hash_location, 0);
+	if (parsed < 0)
+		goto drop_and_free;
 
 	if (tmp_opt.cookie_plus > 0 &&
 	    tmp_opt.saw_tstamp &&
@@ -1280,7 +1284,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		int l = tmp_opt.cookie_plus - TCPOLEN_COOKIE_BASE;
 
 		if (tcp_cookie_generator(&tmp_ext.cookie_bakery[0]) != 0)
-			goto drop_and_release;
+			goto drop_and_free;
 
 		/* Secret recipe starts with IP addresses */
 		*mess++ ^= daddr;
@@ -1301,7 +1305,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		tmp_ext.cookie_out_never = 1; /* true */
 		tmp_ext.cookie_plus = 0;
 	} else {
-		goto drop_and_release;
+		goto drop_and_free;
 	}
 	tmp_ext.cookie_in_always = tp->rx_opt.cookie_in_always;
 
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 37b7536..0b764e7 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -95,15 +95,21 @@ tcp_timewait_state_process(struct inet_timewait_sock *tw, struct sk_buff *skb,
 	struct tcp_timewait_sock *tcptw = tcp_twsk((struct sock *)tw);
 	int paws_reject = 0;
 
-	tmp_opt.saw_tstamp = 0;
+	/* Fast check for options, compare doff directly to constant value. */
 	if (th->doff > (sizeof(*th) >> 2) && tcptw->tw_ts_recent_stamp) {
-		tcp_parse_options(skb, &tmp_opt, &hash_location, 0);
+		int parsed = tcp_parse_options(&tmp_opt, skb, th,
+					       &hash_location, 0);
 
-		if (tmp_opt.saw_tstamp) {
+		if (parsed < 0) {
+			paws_reject = 1; /* true */
+		} else if (tmp_opt.saw_tstamp) {
 			tmp_opt.ts_recent	= tcptw->tw_ts_recent;
 			tmp_opt.ts_recent_stamp	= tcptw->tw_ts_recent_stamp;
 			paws_reject = tcp_paws_reject(&tmp_opt, th->rst);
 		}
+	} else {
+		/* otherwise initialized by tcp_parse_options() */
+		tmp_opt.saw_tstamp = 0; /* false */
 	}
 
 	if (tw->tw_substate == TCP_FIN_WAIT2) {
@@ -526,11 +532,14 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	__be32 flg = tcp_flag_word(th) & (TCP_FLAG_RST|TCP_FLAG_SYN|TCP_FLAG_ACK);
 	int paws_reject = 0;
 
-	tmp_opt.saw_tstamp = 0;
-	if (th->doff > (sizeof(struct tcphdr)>>2)) {
-		tcp_parse_options(skb, &tmp_opt, &hash_location, 0);
+	/* Fast check for options, compare doff directly to constant value. */
+	if (th->doff > (sizeof(*th) >> 2)) {
+		int parsed = tcp_parse_options(&tmp_opt, skb, th,
+					       &hash_location, 0);
 
-		if (tmp_opt.saw_tstamp) {
+		if (parsed < 0) {
+			paws_reject = 1; /* true */
+		} else if (tmp_opt.saw_tstamp) {
 			tmp_opt.ts_recent = req->ts_recent;
 			/* We do not store true stamp, but it is not required,
 			 * it can be estimated (approximately)
@@ -539,6 +548,9 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 			tmp_opt.ts_recent_stamp = get_seconds() - ((TCP_TIMEOUT_INIT/HZ)<<req->retrans);
 			paws_reject = tcp_paws_reject(&tmp_opt, th->rst);
 		}
+	} else {
+		/* otherwise initialized by tcp_parse_options() */
+		tmp_opt.saw_tstamp = 0; /* false */
 	}
 
 	/* Check for pure retransmitted SYN. */
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 34d1f06..4f31ba3 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -161,6 +161,8 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_options_received tcp_opt;
 	u8 *hash_location;
+	struct dst_entry *dst;
+	struct request_sock *req;
 	struct inet_request_sock *ireq;
 	struct inet6_request_sock *ireq6;
 	struct tcp_request_sock *treq;
@@ -169,9 +171,8 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	const struct tcphdr *th = tcp_hdr(skb);
 	__u32 cookie = ntohl(th->ack_seq) - 1;
 	struct sock *ret = sk;
-	struct request_sock *req;
 	int mss;
-	struct dst_entry *dst;
+	int parsed;
 	__u8 rcv_wscale;
 
 	if (!sysctl_tcp_syncookies || !th->ack)
@@ -187,7 +188,9 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 
 	/* check for timestamp cookie support */
 	memset(&tcp_opt, 0, sizeof(tcp_opt));
-	tcp_parse_options(skb, &tcp_opt, &hash_location, 0);
+	parsed = tcp_parse_options(&tcp_opt, skb, th, &hash_location, 0);
+	if (parsed < 0)
+		goto out;
 
 	if (tcp_opt.saw_tstamp)
 		cookie_check_timestamp(&tcp_opt);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 39e0d89..1a79782 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1172,6 +1172,7 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 {
 	struct tcp_extend_values tmp_ext;
 	struct tcp_options_received tmp_opt;
+	int parsed;
 	u8 *hash_location;
 	struct request_sock *req;
 	struct inet6_request_sock *treq;
@@ -1215,7 +1216,10 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	tcp_clear_options(&tmp_opt);
 	tmp_opt.mss_clamp = IPV6_MIN_MTU - sizeof(struct tcphdr) - sizeof(struct ipv6hdr);
 	tmp_opt.user_mss = tp->rx_opt.user_mss;
-	tcp_parse_options(skb, &tmp_opt, &hash_location, 0);
+	parsed = tcp_parse_options(&tmp_opt, skb, tcp_hdr(skb),
+				   &hash_location, 0);
+	if (parsed < 0)
+		goto drop_and_free;
 
 	if (tmp_opt.cookie_plus > 0 &&
 	    tmp_opt.saw_tstamp &&
-- 
1.6.3.3


--------------020700010002000608020209--
