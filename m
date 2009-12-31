From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH v2 RFC 5/5] TCPCT part 2e: parse cookie pair and 64-bit timestamp
Date: Thu, 31 Dec 2009 15:06:05 -0500
Message-ID: <4B3D042D.20307@gmail.com>
References: <4B3CFC73.3070204@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050508060207080400010206"
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:34076 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751129AbZLaUGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Dec 2009 15:06:07 -0500
Received: by yxe17 with SMTP id 17so11813067yxe.33
        for <netdev@vger.kernel.org>; Thu, 31 Dec 2009 12:06:07 -0800 (PST)
In-Reply-To: <4B3CFC73.3070204@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050508060207080400010206
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Parse cookie pair extended option (previously defined).

Define and parse 64-bit timestamp extended option (and minor cleanup).
However, only 32-bits are used at this time.

Requires:
   TCPCT part 2a: TCP header pointer functions
   TCPCT part 2d: cleanup tcp_parse_options

Signed-off-by: William.Allen.Simpson@gmail.com
---
  include/linux/tcp.h  |   10 +++++++++-
  include/net/tcp.h    |   15 ++++++++-------
  net/ipv4/tcp_input.c |   45 +++++++++++++++++++++++++++++++++++++++++++--
  3 files changed, 60 insertions(+), 10 deletions(-)

--------------050508060207080400010206
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="522A6368";
 name="TCPCT+2e2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="TCPCT+2e2.patch"

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index 74728f7..a14639a 100644
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
+		tstamp64:1,	/* Seen on recent packet		*/
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
index 34f5cc2..ed0ef2b 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -156,21 +156,20 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
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
 #define TCPOPT_SACK             5       /* SACK Block */
 #define TCPOPT_TIMESTAMP	8	/* Better RTT estimations/PAWS */
 #define TCPOPT_MD5SIG		19	/* MD5 Signature (RFC2385) */
-#define TCPOPT_COOKIE		253	/* Cookie extension (experimental) */
+#define TCPOPT_COOKIE		31	/* Cookie extension (experimental) */
+#define TCPOPT_TSTAMP64		32	/* 64-bit extension (experimental) */
 
 /*
- *     TCP option lengths
+ *	TCP option lengths (same order as above)
  */
-
 #define TCPOLEN_MSS            4
 #define TCPOLEN_WINDOW         3
 #define TCPOLEN_SACK_PERM      2
@@ -180,16 +179,18 @@ extern void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOLEN_COOKIE_PAIR    3	/* Cookie pair header extension */
 #define TCPOLEN_COOKIE_MIN     (TCPOLEN_COOKIE_BASE+TCP_COOKIE_MIN)
 #define TCPOLEN_COOKIE_MAX     (TCPOLEN_COOKIE_BASE+TCP_COOKIE_MAX)
+#define TCPOLEN_TSTAMP64       3
 
 /* But this is what stacks really send out. */
-#define TCPOLEN_TSTAMP_ALIGNED		12
+#define TCPOLEN_MSS_ALIGNED		4
 #define TCPOLEN_WSCALE_ALIGNED		4
 #define TCPOLEN_SACKPERM_ALIGNED	4
 #define TCPOLEN_SACK_BASE		2
 #define TCPOLEN_SACK_BASE_ALIGNED	4
 #define TCPOLEN_SACK_PERBLOCK		8
+#define TCPOLEN_TSTAMP_ALIGNED		12
 #define TCPOLEN_MD5SIG_ALIGNED		20
-#define TCPOLEN_MSS_ALIGNED		4
+#define TCPOLEN_TSTAMP64_EXTEND		16
 
 /* Flags in tp->nonagle */
 #define TCP_NAGLE_OFF		1	/* Nagle's algo is disabled */
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 7f8c6ac..6b9eabe 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3734,6 +3734,8 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
 	int length = tcp_option_len_th(th);
 
 	opt_rx->cookie_plus = 0;
+	opt_rx->extended = 0;
+	opt_rx->tstamp64 = 0; /* false */
 	opt_rx->saw_tstamp = 0; /* false */
 
 	while (length > 0) {
@@ -3829,9 +3831,23 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
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
+				    opt_rx->cookie_plus == 0 &&
+				    opt_rx->saw_tstamp &&
+				    !th->syn) {
+					opt_rx->cookie_plus =
+						TCPOLEN_COOKIE_BASE + extend;
+					*hvpp = (u8 *)th
+					      + tcp_header_len_th(th)
+					      + opt_rx->extended;
+				}
+				opt_rx->extended += extend;
 				break;
+			}
 			case TCPOLEN_COOKIE_MIN+0:
 			case TCPOLEN_COOKIE_MIN+2:
 			case TCPOLEN_COOKIE_MIN+4:
@@ -3851,6 +3867,31 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
 			};
 			break;
 
+		case TCPOPT_TSTAMP64:
+			if (opsize == TCPOLEN_TSTAMP64) {
+				int extend = *ptr * 4;
+
+				if (extend == TCPOLEN_TSTAMP64_EXTEND &&
+				    opt_rx->extended == 0 &&
+				    !opt_rx->saw_tstamp &&
+				    !th->syn) {
+					u8 *tsp = (u8 *)(th)
+						+ tcp_header_len_th(th)
+						+ 4; /* low 32-bits */
+
+					opt_rx->tstamp64 = 1; /* true */
+					opt_rx->saw_tstamp = 1; /* true */
+
+					/* 64-bits not yet implemented */
+					opt_rx->rcv_tsval =
+						get_unaligned_be32(tsp);
+					opt_rx->rcv_tsecr =
+						get_unaligned_be32(tsp + 8);
+				}
+				opt_rx->extended += extend;
+			}
+			break;
+
 		default:
 			/* skip unrecognized options */
 			break;
-- 
1.6.3.3

--------------050508060207080400010206--
