From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH v3 3/3] TCPCT part 2g: parse cookie pair and 64-bit timestamp
Date: Thu, 21 Jan 2010 22:55:24 -0500
Message-ID: <4B5921AC.1060408@gmail.com>
References: <4B59163C.2060002@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070007000905050702060108"
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f196.google.com ([209.85.223.196]:38769 "EHLO
	mail-iw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751211Ab0AVDz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 22:55:27 -0500
Received: by iwn34 with SMTP id 34so659915iwn.21
        for <netdev@vger.kernel.org>; Thu, 21 Jan 2010 19:55:26 -0800 (PST)
In-Reply-To: <4B59163C.2060002@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070007000905050702060108
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Parse cookie pair extended option (previously defined).

Define and parse 64-bit timestamp extended option (and minor cleanup).
However, only 32-bits are used at this time.

Requires:
   net: tcp_header_len_th and tcp_option_len_th
   TCPCT part 2f: cleanup tcp_parse_options

Signed-off-by: William.Allen.Simpson@gmail.com
---
  include/linux/tcp.h  |   10 ++++-
  include/net/tcp.h    |   45 +++++++++---------
  net/ipv4/tcp_input.c |  126 ++++++++++++++++++++++++++++++++++++++++++++++----
  3 files changed, 148 insertions(+), 33 deletions(-)

--------------070007000905050702060108
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="TCPCT+2g3.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="TCPCT+2g3.patch"

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 2987ee8..0156dc3 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -260,13 +260,21 @@ struct tcp_options_received {
 	u8	num_sacks;	/* Number of SACK blocks		*/
 	u16	user_mss;	/* mss requested by user in ioctl	*/
 	u16	mss_clamp;	/* Maximal mss, negotiated at connection setup */
+
+	/* When the options are extended beyond the maximum 40 bytes,
+	 * then this holds the additional data offset (in bytes,
+	 * the least significant 2 bits are always zero).
+	 */
+	u16	extended:14,	/* Up to 13 (40/3) by 255 by 4 bytes	*/
+		saw_tstamp64:1,	/* Seen on recent packet		*/
+		tstamp64_ok:1;	/* Verified with cookie pair		*/
 };
 
 static inline void tcp_clear_options(struct tcp_options_received *rx_opt)
 {
 	rx_opt->tstamp_ok = rx_opt->sack_ok = 0;
 	rx_opt->wscale_ok = rx_opt->snd_wscale = 0;
-	rx_opt->cookie_plus = 0;
+	rx_opt->tstamp64_ok = 0;
 }
 
 /* This is the max number of SACKS that we'll generate and process. It's safe
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 420e872..157c97b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -156,9 +156,8 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 /*
  *	TCP option
  */
- 
-#define TCPOPT_NOP		1	/* Padding */
 #define TCPOPT_EOL		0	/* End of options */
+#define TCPOPT_NOP		1	/* Padding */
 #define TCPOPT_MSS		2	/* Segment size negotiating */
 #define TCPOPT_WINDOW		3	/* Window scaling */
 #define TCPOPT_SACK_PERM        4       /* SACK Permitted */
@@ -166,30 +165,32 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOPT_TIMESTAMP	8	/* Better RTT estimations/PAWS */
 #define TCPOPT_MD5SIG		19	/* MD5 Signature (RFC2385) */
 #define TCPOPT_COOKIE		253	/* Cookie extension (experimental) */
-
-/*
- *     TCP option lengths
- */
-
-#define TCPOLEN_MSS            4
-#define TCPOLEN_WINDOW         3
-#define TCPOLEN_SACK_PERM      2
-#define TCPOLEN_TIMESTAMP      10
-#define TCPOLEN_MD5SIG         18
-#define TCPOLEN_COOKIE_BASE    2	/* Cookie-less header extension */
-#define TCPOLEN_COOKIE_PAIR    3	/* Cookie pair header extension */
-#define TCPOLEN_COOKIE_MIN     (TCPOLEN_COOKIE_BASE+TCP_COOKIE_MIN)
-#define TCPOLEN_COOKIE_MAX     (TCPOLEN_COOKIE_BASE+TCP_COOKIE_MAX)
-
-/* But this is what stacks really send out. */
-#define TCPOLEN_TSTAMP_ALIGNED		12
+#define TCPOPT_TSTAMP64		254	/* 64-bit extension (experimental) */
+
+/*	TCP option lengths (same order as above) */
+#define TCPOLEN_MSS		4
+#define TCPOLEN_WINDOW		3
+#define TCPOLEN_SACK_PERM	2
+#define TCPOLEN_SACK_BASE	2
+#define TCPOLEN_SACK_PERBLOCK	8
+#define TCPOLEN_TIMESTAMP	10
+#define TCPOLEN_MD5SIG		18
+#define TCPOLEN_COOKIE_BASE	2	/* Cookie-less header extension */
+#define TCPOLEN_COOKIE_PAIR	3	/* Cookie pair header extension */
+#define TCPOLEN_COOKIE_MIN	(TCPOLEN_COOKIE_BASE+TCP_COOKIE_MIN)
+#define TCPOLEN_COOKIE_MAX	(TCPOLEN_COOKIE_BASE+TCP_COOKIE_MAX)
+#define TCPOLEN_TSTAMP64	3
+
+/*	TCP options 32-bit aligned (same order as above) */
+#define TCPOLEN_MSS_ALIGNED		4
 #define TCPOLEN_WSCALE_ALIGNED		4
 #define TCPOLEN_SACKPERM_ALIGNED	4
-#define TCPOLEN_SACK_BASE		2
 #define TCPOLEN_SACK_BASE_ALIGNED	4
-#define TCPOLEN_SACK_PERBLOCK		8
+#define TCPOLEN_TSTAMP_ALIGNED		12
 #define TCPOLEN_MD5SIG_ALIGNED		20
-#define TCPOLEN_MSS_ALIGNED		4
+
+/*	TCP option extensions (same order as above) */
+#define TCPOEXT_TSTAMP64		16
 
 /* Flags in tp->nonagle */
 #define TCP_NAGLE_OFF		1	/* Nagle's algo is disabled */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index d3c6c7a..a14ce8b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3722,9 +3722,71 @@ old_ack:
 	return 0;
 }
 
+/* Process option extension data.
+ *
+ * Extension data in nonlinear skb is Not Yet Implemented!!!
+ *
+ * Returns:
+ *	0 on success
+ *	- on failure
+ */
+int tcp_parse_extension(struct sk_buff *skb, const struct tcphdr *th,
+			struct tcp_options_received *opt_rx, u8 **hvpp)
+{
+	__be32 *tsp = (__be32 *)th + th->doff;
+	int remainder = skb_headlen(skb);
+
+	if (unlikely(th->syn)) {
+		/* Extended options are ignored on SYN or SYNACK, just as other
+		 * malformed or unrecognized options.  Leave the data in place.
+		 */
+		opt_rx->extended = 0;
+		return 0;
+	}
+
+	/* Adjust end_seq, set in tcp_v[4,6]_rcv() */
+	TCP_SKB_CB(skb)->end_seq -= opt_rx->extended;
+
+	/* If present, always first, aligned */
+	if (opt_rx->saw_tstamp64) {
+		if (unlikely(remainder < TCPOEXT_TSTAMP64)) {
+			/* insufficient data */
+			opt_rx->saw_tstamp64 = 0 /* false */;
+			opt_rx->saw_tstamp = 0 /* false */;
+		} else {
+			/* 64-bits not yet implemented */
+			tsp++;
+			opt_rx->rcv_tsval = ntohl(*tsp);
+			tsp += 2;
+			opt_rx->rcv_tsecr = ntohl(*tsp);
+			tsp++;
+		}
+		remainder -= TCPOEXT_TSTAMP64;
+	}
+
+	/* If present, TCPOLEN_COOKIE_PAIR makes this an odd value */
+	if (opt_rx->cookie_plus & 0x1) {
+		int cookie_size = opt_rx->cookie_plus - TCPOLEN_COOKIE_PAIR;
+
+		if (unlikely(remainder < cookie_size)) {
+			/* insufficient data */
+			opt_rx->cookie_plus = 0;
+		} else {
+			*hvpp = (u8 *)tsp;
+			tsp += cookie_size / 4;
+		}
+		remainder -= cookie_size;
+	}
+	return (remainder < 0) ? remainder : 0;
+}
+
 /* Look for tcp options. Normally only called on SYN and SYNACK packets.
  * But, this can also be called on packets in the established flow when
  * the fast version below fails.
+ *
+ * Returns:
+ *	0 on success
+ *	- on failure
  */
 int tcp_parse_options(struct sk_buff *skb, const struct tcphdr *th,
 		      struct tcp_options_received *opt_rx, u8 **hvpp, int estab)
@@ -3733,6 +3795,8 @@ int tcp_parse_options(struct sk_buff *skb, const struct tcphdr *th,
 	int length = tcp_option_len_th(th);
 
 	opt_rx->cookie_plus = 0;
+	opt_rx->extended = 0;
+	opt_rx->saw_tstamp64 = 0; /* false */
 	opt_rx->saw_tstamp = 0; /* false */
 
 	while (length > 0) {
@@ -3741,6 +3805,9 @@ int tcp_parse_options(struct sk_buff *skb, const struct tcphdr *th,
 
 		switch (opcode) {
 		case TCPOPT_EOL:
+			if (opt_rx->extended > 0)
+				return tcp_parse_extension(skb, th, opt_rx,
+							   hvpp);
 			return 0;
 		case TCPOPT_NOP:	/* Ref: RFC 793 section 3.1 */
 			length--;
@@ -3753,6 +3820,9 @@ int tcp_parse_options(struct sk_buff *skb, const struct tcphdr *th,
 		opsize = *ptr++;
 		if (opsize < 2 || opsize > length) {
 			/* don't parse partial options */
+			if (opt_rx->extended > 0)
+				return tcp_parse_extension(skb, th, opt_rx,
+							   hvpp);
 			return 0;
 		}
 
@@ -3828,9 +3898,21 @@ int tcp_parse_options(struct sk_buff *skb, const struct tcphdr *th,
 			case TCPOLEN_COOKIE_BASE:
 				/* not yet implemented */
 				break;
-			case TCPOLEN_COOKIE_PAIR:
-				/* not yet implemented */
+			case TCPOLEN_COOKIE_PAIR: {
+				int extend = *ptr * 4;
+
+				if (extend >= TCPOLEN_COOKIE_MIN &&
+				    extend <= TCPOLEN_COOKIE_MAX &&
+				    !th->syn && opt_rx->saw_tstamp &&
+				    opt_rx->cookie_plus == 0 &&
+				    (opt_rx->extended == 0 ||
+				     (opt_rx->extended == TCPOEXT_TSTAMP64 &&
+				      opt_rx->saw_tstamp64))) {
+					opt_rx->cookie_plus = opsize + extend;
+				}
+				opt_rx->extended += extend;
 				break;
+			}
 			case TCPOLEN_COOKIE_MIN+0:
 			case TCPOLEN_COOKIE_MIN+2:
 			case TCPOLEN_COOKIE_MIN+4:
@@ -3849,6 +3931,20 @@ int tcp_parse_options(struct sk_buff *skb, const struct tcphdr *th,
 			};
 			break;
 
+		case TCPOPT_TSTAMP64:
+			if (opsize == TCPOLEN_TSTAMP64) {
+				int extend = *ptr * 4;
+
+				if (extend == TCPOEXT_TSTAMP64 &&
+				    !th->syn && !opt_rx->saw_tstamp &&
+				    opt_rx->extended == 0) {
+					opt_rx->saw_tstamp64 = 1; /* true */
+					opt_rx->saw_tstamp = 1; /* true */
+				}
+				opt_rx->extended += extend;
+			}
+			break;
+
 		default:
 			/* skip unrecognized options */
 			break;
@@ -3857,6 +3953,8 @@ int tcp_parse_options(struct sk_buff *skb, const struct tcphdr *th,
 		ptr += opsize - 2;
 		length -= opsize;
 	}
+	if (opt_rx->extended > 0)
+		return tcp_parse_extension(skb, th, opt_rx, hvpp);
 	return 0;
 }
 
@@ -3883,6 +3981,11 @@ static int tcp_parse_aligned_timestamp(struct tcp_sock *tp, struct tcphdr *th)
 
 /* Fast parse options. This hopes to only see timestamps.
  * If it is wrong it falls back on tcp_parse_options().
+ *
+ * Returns:
+ *	1 on success, fast
+ *	0 on success, slow
+ *	- on failure
  */
 static int tcp_fast_parse_options(struct sk_buff *skb, struct tcphdr *th,
 				  struct tcp_sock *tp, u8 **hvpp)
@@ -3892,11 +3995,14 @@ static int tcp_fast_parse_options(struct sk_buff *skb, struct tcphdr *th,
 	 */
 	if (th->doff == (sizeof(*th) / 4)) {
 		tp->rx_opt.saw_tstamp = 0;
+		tp->rx_opt.extended = 0;
 		return 0;
-	} else if (tp->rx_opt.tstamp_ok &&
-		   th->doff == ((sizeof(*th) + TCPOLEN_TSTAMP_ALIGNED) / 4)) {
-		if (tcp_parse_aligned_timestamp(tp, th))
-			return 1;
+	}
+	if (th->doff == ((sizeof(*th) + TCPOLEN_TSTAMP_ALIGNED) / 4) &&
+	    tp->rx_opt.tstamp_ok &&
+	    tcp_parse_aligned_timestamp(tp, th)) {
+		tp->rx_opt.extended = 0;
+		return 1;
 	}
 	return tcp_parse_options(skb, th, &tp->rx_opt, hvpp, 1);
 }
@@ -3907,8 +4013,8 @@ static int tcp_fast_parse_options(struct sk_buff *skb, struct tcphdr *th,
  */
 u8 *tcp_parse_md5sig_option(struct tcphdr *th)
 {
-	int length = (th->doff << 2) - sizeof (*th);
 	u8 *ptr = (u8*)(th + 1);
+	int length = tcp_option_len_th(th);
 
 	/* If the TCP option is too short, we can short cut */
 	if (length < TCPOLEN_MD5SIG)
@@ -4373,7 +4479,7 @@ static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 	if (TCP_SKB_CB(skb)->seq == TCP_SKB_CB(skb)->end_seq)
 		goto drop;
 
-	__skb_pull(skb, th->doff * 4);
+	__skb_pull(skb, tcp_header_len_th(th) + tp->rx_opt.extended);
 
 	TCP_ECN_accept_cwr(tp, skb);
 
@@ -5034,8 +5140,8 @@ static void tcp_urg(struct sock *sk, struct sk_buff *skb, struct tcphdr *th)
 
 	/* Do we wait for any urgent data? - normally not... */
 	if (tp->urg_data == TCP_URG_NOTYET) {
-		u32 ptr = tp->urg_seq - ntohl(th->seq) + (th->doff * 4) -
-			  th->syn;
+		u32 ptr = tp->urg_seq - ntohl(th->seq) - th->syn
+			+ tcp_header_len_th(th) + tp->rx_opt.extended;
 
 		/* Is the urgent pointer pointing into this packet? */
 		if (ptr < skb->len) {
-- 
1.6.3.3


--------------070007000905050702060108--
