From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH v8 7/7] TCPCT part 2g: parse cookie pair and 64-bit timestamp
Date: Thu, 11 Mar 2010 08:06:54 -0500
Message-ID: <4B98EAEE.4020400@gmail.com>
References: <4B98D592.6040301@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030205000207020505050100"
Cc: Linux Kernel Developers <linux-kernel@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B98D592.6040301@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030205000207020505050100
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Every bit is sacred.  Use as few bits as possible in tcp_options_received.
Group related timestamp flag bits for cache line memory efficiency.

Fix #define spacing for TCP options.

Define and parse 64-bit timestamp extended option (and minor cleanup).
However, only 32-bits are used at this time (permitted by specification).

Parse cookie pair extended option (previously defined).

Handle header extension.

Fix initialization in tcp_minisocks.

[updated to latest posted internet draft-simpson-tcpct-00]

Requires:
   net: tcp_header_len_th and tcp_option_len_th
   TCPCT part 2f: cleanup tcp_parse_options

Signed-off-by: William.Allen.Simpson@gmail.com
---
  include/linux/tcp.h      |   12 ++++-
  include/net/tcp.h        |   45 ++++++++--------
  net/ipv4/tcp_input.c     |  127 ++++++++++++++++++++++++++++++++++++++++++----
  net/ipv4/tcp_minisocks.c |    6 ++
  4 files changed, 155 insertions(+), 35 deletions(-)

--------------030205000207020505050100
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="0";
 name="TCPCT+2g8+2.6.34-rc1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="TCPCT+2g8+2.6.34-rc1.patch"

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index a97ca8f..8fdc64e 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -249,7 +249,7 @@ struct tcp_options_received {
 	u32	ts_recent;	/* Time stamp to echo next		*/
 	u32	rcv_tsval;	/* Time stamp value             	*/
 	u32	rcv_tsecr;	/* Time stamp echo reply        	*/
-	u16 	saw_tstamp : 1,	/* Saw TIMESTAMP on last packet		*/
+	u16	tstamp64_ok:1,	/* Verified with cookie pair		*/
 		tstamp_ok : 1,	/* TIMESTAMP seen on SYN packet		*/
 		dsack : 1,	/* D-SACK is scheduled			*/
 		wscale_ok : 1,	/* Wscale seen on SYN packet		*/
@@ -262,13 +262,21 @@ struct tcp_options_received {
 	u8	num_sacks;	/* Number of SACK blocks		*/
 	u16	user_mss;	/* mss requested by user in ioctl	*/
 	u16	mss_clamp;	/* Maximal mss, negotiated at connection setup */
+
+	/* When the options are extended beyond the standard 40 bytes,
+	 * this holds the additional data offset (up to 1,020 bytes).
+	 */
+	u8	extended;	/* in 32-bit words			*/
+	u8	saw_tstamp64:1,	/* 64-bit TIMESTAMP seen on last packet	*/
+		saw_tstamp:1,	/* TIMESTAMP seen on last packet	*/
+		__unused:6;
 };
 
 static inline void tcp_clear_options(struct tcp_options_received *rx_opt)
 {
+	rx_opt->tstamp64_ok = 0;
 	rx_opt->tstamp_ok = rx_opt->sack_ok = 0;
 	rx_opt->wscale_ok = rx_opt->snd_wscale = 0;
-	rx_opt->cookie_plus = 0;
 }
 
 /* This is the max number of SACKS that we'll generate and process. It's safe
diff --git a/include/net/tcp.h b/include/net/tcp.h
index f8c99fa..1399c86 100644
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
+#define TCPOPT_TIMESTAMP64	254	/* 64-bit extension (experimental) */
+
+/*	TCP option lengths (same order as above) */
+#define TCPOLEN_MSS		4
+#define TCPOLEN_WINDOW		3
+#define TCPOLEN_SACK_PERM	2
+#define TCPOLEN_SACK_BASE	2
+#define TCPOLEN_SACK_PERBLOCK	8
+#define TCPOLEN_TIMESTAMP	10
+#define TCPOLEN_MD5SIG		18
+#define TCPOLEN_COOKIE_BASE	2	/* Cookie-less negotiation */
+#define TCPOLEN_COOKIE_PLUS	4	/* Cookie pair header extension */
+#define TCPOLEN_COOKIE_MIN	(TCPOLEN_COOKIE_BASE+TCP_COOKIE_MIN)
+#define TCPOLEN_COOKIE_MAX	(TCPOLEN_COOKIE_BASE+TCP_COOKIE_MAX)
+#define TCPOLEN_TSTAMP64_PLUS	3	/* Timestamped header extension */
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
+#define TCPOEXT_TSTAMP64_PLUS		16
 
 /* Flags in tp->nonagle */
 #define TCP_NAGLE_OFF		1	/* Nagle's algo is disabled */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index cc26090..1e07eb7 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3745,13 +3745,19 @@ old_ack:
 int tcp_parse_options(struct tcp_options_received *opt_rx, struct sk_buff *skb,
 		      const struct tcphdr *th, u8 **hvpp, int estab)
 {
+	__be32 *xdp = (__be32 *)th + th->doff;
 	unsigned char *ptr = (unsigned char *)(th + 1);
+	int remaining = skb_headlen(skb) - tcp_header_len_th(th);
 	int length = tcp_option_len_th(th);
+	int extending = 0;
 	bool syn = th->syn;
 
 	opt_rx->cookie_plus = 0;
+	opt_rx->extended = 0;
+	opt_rx->saw_tstamp64 = 0; /* false */
 	opt_rx->saw_tstamp = 0; /* false */
 
+repeat:
 	while (length > 0) {
 		int opsize;
 		int opcode = *ptr++;
@@ -3823,6 +3829,10 @@ int tcp_parse_options(struct tcp_options_received *opt_rx, struct sk_buff *skb,
 			break;
 
 		case TCPOPT_TIMESTAMP:
+			if (unlikely(opt_rx->saw_tstamp)) {
+				/* discard duplicate */
+				return -length;
+			}
 			if ((opsize == TCPOLEN_TIMESTAMP) &&
 			    ((estab && opt_rx->tstamp_ok) ||
 			     (!estab && sysctl_tcp_timestamps))) {
@@ -3848,27 +3858,112 @@ int tcp_parse_options(struct tcp_options_received *opt_rx, struct sk_buff *skb,
 			case TCPOLEN_COOKIE_BASE:
 				/* not yet implemented */
 				break;
-			case TCPOLEN_COOKIE_PAIR: {
-				/* not yet implemented */
+			case TCPOLEN_COOKIE_PLUS: {
+				int words = ptr[1] & 0xf;
+
+				if (unlikely(opt_rx->extended > 0)) {
+					/* discard conflicting */
+					return -length;
+				}
+				if (!syn &&
+				    *ptr >= words &&
+				    words >= (TCP_COOKIE_MIN / 4) &&
+				    words <= (TCP_COOKIE_MAX / 4)) {
+					int bytes = words * 4;
+
+					extending = *ptr * 4;
+
+					if (unlikely(extending > remaining)) {
+						/* missing data!!! */
+						return -length;
+					}
+					opt_rx->extended = *ptr;
+
+					/* Adjust end_seq, set in
+					 * tcp_v[4,6]_rcv()
+					 */
+					TCP_SKB_CB(skb)->end_seq -= extending;
+					extending -= bytes;
+
+					opt_rx->cookie_plus = bytes
+						+ TCPOLEN_COOKIE_BASE;
+					*hvpp = (u8 *)xdp;
+					xdp += words;
+				}
 				break;
 			}
 			case TCPOLEN_COOKIE_MIN+0:
 			case TCPOLEN_COOKIE_MIN+2:
 			case TCPOLEN_COOKIE_MIN+4:
 			case TCPOLEN_COOKIE_MIN+6:
-			case TCPOLEN_COOKIE_MAX:
 				/* 16-bit multiple */
 				if (syn) {
 					opt_rx->cookie_plus = opsize;
 					*hvpp = ptr;
 				}
 				break;
+			case TCPOLEN_COOKIE_MAX+0:
+				/* either cookie or cookie pair */
+				if (syn || opt_rx->saw_tstamp64) {
+					opt_rx->cookie_plus = opsize;
+					*hvpp = ptr;
+				}
+				break;
+			case TCPOLEN_COOKIE_MAX+4:
+			case TCPOLEN_COOKIE_MAX+8:
+			case TCPOLEN_COOKIE_MAX+12:
+			case TCPOLEN_COOKIE_MAX+TCP_COOKIE_MAX:
+				/* 32-bit multiple (pair) */
+				if (opt_rx->saw_tstamp64) {
+					opt_rx->cookie_plus = opsize;
+					*hvpp = ptr;
+				}
+				break;
 			default:
 				/* ignore option */
 				break;
 			};
 			break;
 
+		case TCPOPT_TIMESTAMP64:
+			if (unlikely(opt_rx->saw_tstamp)) {
+				/* discard duplicate */
+				return -length;
+			}
+			if (opsize == TCPOLEN_TSTAMP64_PLUS) {
+				if (unlikely(opt_rx->extended > 0)) {
+					/* discard conflicting */
+					return -length;
+				}
+				if (!syn &&
+				    *ptr >= (TCPOEXT_TSTAMP64_PLUS / 4)) {
+					extending = *ptr * 4;
+
+					if (unlikely(extending > remaining)) {
+						/* missing data!!! */
+						return -length;
+					}
+					opt_rx->extended = *ptr;
+
+					/* Adjust end_seq, set in
+					 * tcp_v[4,6]_rcv()
+					 */
+					TCP_SKB_CB(skb)->end_seq -= extending;
+					extending -= TCPOEXT_TSTAMP64_PLUS;
+
+					/* 64-bits not yet implemented */
+					xdp++;
+					opt_rx->rcv_tsval = ntohl(*xdp);
+					xdp += 2;
+					opt_rx->rcv_tsecr = ntohl(*xdp);
+					xdp++;
+
+					opt_rx->saw_tstamp64 = 1; /* true */
+					opt_rx->saw_tstamp = 1; /* true */
+				}
+			}
+			break;
+
 		default:
 			/* skip unrecognized options */
 			break;
@@ -3877,6 +3972,13 @@ int tcp_parse_options(struct tcp_options_received *opt_rx, struct sk_buff *skb,
 		ptr += opsize - 2;
 		length -= opsize;
 	}
+
+	if (unlikely(extending != 0)) {
+		ptr = (unsigned char *)xdp;
+		length = extending;
+		extending = 0;
+		goto repeat;
+	}
 	return 0;
 }
 
@@ -3917,11 +4019,14 @@ static int tcp_fast_parse_options(struct tcp_sock *tp, struct sk_buff *skb,
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
 	return tcp_parse_options(&tp->rx_opt, skb, th, hvpp, 1);
 }
@@ -3932,8 +4037,8 @@ static int tcp_fast_parse_options(struct tcp_sock *tp, struct sk_buff *skb,
  */
 u8 *tcp_parse_md5sig_option(struct tcphdr *th)
 {
-	int length = (th->doff << 2) - sizeof (*th);
 	u8 *ptr = (u8*)(th + 1);
+	int length = tcp_option_len_th(th);
 
 	/* If the TCP option is too short, we can short cut */
 	if (length < TCPOLEN_MD5SIG)
@@ -4398,7 +4503,7 @@ static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 	if (TCP_SKB_CB(skb)->seq == TCP_SKB_CB(skb)->end_seq)
 		goto drop;
 
-	__skb_pull(skb, th->doff * 4);
+	__skb_pull(skb, (th->doff + tp->rx_opt.extended) * 4);
 
 	TCP_ECN_accept_cwr(tp, skb);
 
@@ -5059,8 +5164,8 @@ static void tcp_urg(struct sock *sk, struct sk_buff *skb, struct tcphdr *th)
 
 	/* Do we wait for any urgent data? - normally not... */
 	if (tp->urg_data == TCP_URG_NOTYET) {
-		u32 ptr = tp->urg_seq - ntohl(th->seq) + (th->doff * 4) -
-			  th->syn;
+		u32 ptr = ((th->doff + tp->rx_opt.extended) * 4)
+			+ tp->urg_seq - ntohl(th->seq) - th->syn;
 
 		/* Is the urgent pointer pointing into this packet? */
 		if (ptr < skb->len) {
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 0b764e7..613325d 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -109,6 +109,9 @@ tcp_timewait_state_process(struct inet_timewait_sock *tw, struct sk_buff *skb,
 		}
 	} else {
 		/* otherwise initialized by tcp_parse_options() */
+		tmp_opt.cookie_plus = 0;
+		tmp_opt.extended = 0;
+		tmp_opt.saw_tstamp64 = 0; /* false */
 		tmp_opt.saw_tstamp = 0; /* false */
 	}
 
@@ -550,6 +553,9 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 		}
 	} else {
 		/* otherwise initialized by tcp_parse_options() */
+		tmp_opt.cookie_plus = 0;
+		tmp_opt.extended = 0;
+		tmp_opt.saw_tstamp64 = 0; /* false */
 		tmp_opt.saw_tstamp = 0; /* false */
 	}
 
-- 
1.6.3.3


--------------030205000207020505050100--
