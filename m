From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: [PATCH v2 RFC 4/5] TCPCT part 2d: cleanup tcp_parse_options
Date: Thu, 31 Dec 2009 14:58:18 -0500
Message-ID: <4B3D025A.4010006@gmail.com>
References: <4B3CFC73.3070204@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010803080907080105020905"
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f187.google.com ([209.85.210.187]:42682 "EHLO
	mail-yx0-f187.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714AbZLaT6W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Dec 2009 14:58:22 -0500
Received: by yxe17 with SMTP id 17so11808425yxe.33
        for <netdev@vger.kernel.org>; Thu, 31 Dec 2009 11:58:20 -0800 (PST)
In-Reply-To: <4B3CFC73.3070204@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010803080907080105020905
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Split switch, shift cases to the left, fix most lines beyond column 80.

Requires:
   TCPCT part 1g: Responder Cookie => Initiator
   TCPCT part 2a: TCP header pointer functions

Signed-off-by: William.Allen.Simpson@gmail.com
---
  net/ipv4/tcp_input.c |  191 +++++++++++++++++++++++++++----------------------
  1 files changed, 105 insertions(+), 86 deletions(-)

--------------010803080907080105020905
Content-Type: text/plain; x-mac-type="54455854"; x-mac-creator="522A6368";
 name="TCPCT+2d2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="TCPCT+2d2.patch"

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 78604bd..7f8c6ac 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3729,12 +3729,12 @@ old_ack:
 void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
 		       u8 **hvpp, int estab)
 {
-	unsigned char *ptr;
 	struct tcphdr *th = tcp_hdr(skb);
-	int length = (th->doff * 4) - sizeof(struct tcphdr);
+	unsigned char *ptr = (unsigned char *)(th + 1);
+	int length = tcp_option_len_th(th);
 
-	ptr = (unsigned char *)(th + 1);
-	opt_rx->saw_tstamp = 0;
+	opt_rx->cookie_plus = 0;
+	opt_rx->saw_tstamp = 0; /* false */
 
 	while (length > 0) {
 		int opcode = *ptr++;
@@ -3747,98 +3747,117 @@ void tcp_parse_options(struct sk_buff *skb, struct tcp_options_received *opt_rx,
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
+		if (opsize < 2) /* "silly options" */
+			return;
+		if (opsize > length)
+			return;	/* don't parse partial options */
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
+				if (opt_rx->cookie_plus == 0 &&
+				    opt_rx->saw_tstamp &&
+				    th->syn) {
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
 }
 
-- 
1.6.3.3

--------------010803080907080105020905--
