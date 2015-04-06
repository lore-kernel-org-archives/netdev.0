From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 1/2] tcp: RFC7413 option support for Fast Open server
Date: Mon,  6 Apr 2015 14:37:26 -0700
Message-ID: <1428356247-10262-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Daniel Lee <Longinus00@gmail.com>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:36893 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752934AbbDFVie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 17:38:34 -0400
Received: by igblo3 with SMTP id lo3so30093158igb.0
        for <netdev@vger.kernel.org>; Mon, 06 Apr 2015 14:38:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lee <Longinus00@gmail.com>

Fast Open has been using the experimental option with a magic number
(RFC6994) to request and grant Fast Open cookies. This patch enables
the server to support the official IANA option 34 in RFC7413 in
addition.

The change has passed all existing Fast Open tests with both
old and new options at Google.

Signed-off-by: Daniel Lee <Longinus00@gmail.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
---
 include/linux/tcp.h     |  1 +
 include/net/tcp.h       |  2 ++
 net/ipv4/tcp_fastopen.c |  1 +
 net/ipv4/tcp_input.c    | 42 ++++++++++++++++++++++++++++++------------
 net/ipv4/tcp_output.c   | 34 +++++++++++++++++++++++-----------
 5 files changed, 57 insertions(+), 23 deletions(-)

diff --git a/include/linux/tcp.h b/include/linux/tcp.h
index f869ae8..a48d003 100644
--- a/include/linux/tcp.h
+++ b/include/linux/tcp.h
@@ -58,6 +58,7 @@ static inline unsigned int tcp_optlen(const struct sk_buff *skb)
 struct tcp_fastopen_cookie {
 	s8	len;
 	u8	val[TCP_FASTOPEN_COOKIE_MAX];
+	bool	exp;	/* In RFC6994 experimental option format */
 };
 
 /* This defines a selective acknowledgement block. */
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 963303f..7292c3c 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -179,6 +179,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOPT_SACK             5       /* SACK Block */
 #define TCPOPT_TIMESTAMP	8	/* Better RTT estimations/PAWS */
 #define TCPOPT_MD5SIG		19	/* MD5 Signature (RFC2385) */
+#define TCPOPT_FASTOPEN		34	/* Fast open (RFC7413) */
 #define TCPOPT_EXP		254	/* Experimental */
 /* Magic number to be after the option value for sharing TCP
  * experimental options. See draft-ietf-tcpm-experimental-options-00.txt
@@ -194,6 +195,7 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 #define TCPOLEN_SACK_PERM      2
 #define TCPOLEN_TIMESTAMP      10
 #define TCPOLEN_MD5SIG         18
+#define TCPOLEN_FASTOPEN_BASE  2
 #define TCPOLEN_EXP_FASTOPEN_BASE  4
 
 /* But this is what stacks really send out. */
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp_fastopen.c
index 5da55e2..e3d87ac 100644
--- a/net/ipv4/tcp_fastopen.c
+++ b/net/ipv4/tcp_fastopen.c
@@ -303,6 +303,7 @@ fastopen:
 	} else if (foc->len > 0) /* Client presents an invalid cookie */
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPFASTOPENPASSIVEFAIL);
 
+	valid_foc.exp = foc->exp;
 	*foc = valid_foc;
 	return false;
 }
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index df7e7fa..55b0e39 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3602,6 +3602,23 @@ old_ack:
 	return 0;
 }
 
+static void tcp_parse_fastopen_option(int len, const unsigned char *cookie,
+				      bool syn, struct tcp_fastopen_cookie *foc,
+				      bool exp_opt)
+{
+	/* Valid only in SYN or SYN-ACK with an even length.  */
+	if (!foc || !syn || len < 0 || (len & 1))
+		return;
+
+	if (len >= TCP_FASTOPEN_COOKIE_MIN &&
+	    len <= TCP_FASTOPEN_COOKIE_MAX)
+		memcpy(foc->val, cookie, len);
+	else if (len != 0)
+		len = -1;
+	foc->len = len;
+	foc->exp = exp_opt;
+}
+
 /* Look for tcp options. Normally only called on SYN and SYNACK packets.
  * But, this can also be called on packets in the established flow when
  * the fast version below fails.
@@ -3691,21 +3708,22 @@ void tcp_parse_options(const struct sk_buff *skb,
 				 */
 				break;
 #endif
+			case TCPOPT_FASTOPEN:
+				tcp_parse_fastopen_option(
+					opsize - TCPOLEN_FASTOPEN_BASE,
+					ptr, th->syn, foc, false);
+				break;
+
 			case TCPOPT_EXP:
 				/* Fast Open option shares code 254 using a
-				 * 16 bits magic number. It's valid only in
-				 * SYN or SYN-ACK with an even size.
+				 * 16 bits magic number.
 				 */
-				if (opsize < TCPOLEN_EXP_FASTOPEN_BASE ||
-				    get_unaligned_be16(ptr) != TCPOPT_FASTOPEN_MAGIC ||
-				    !foc || !th->syn || (opsize & 1))
-					break;
-				foc->len = opsize - TCPOLEN_EXP_FASTOPEN_BASE;
-				if (foc->len >= TCP_FASTOPEN_COOKIE_MIN &&
-				    foc->len <= TCP_FASTOPEN_COOKIE_MAX)
-					memcpy(foc->val, ptr + 2, foc->len);
-				else if (foc->len != 0)
-					foc->len = -1;
+				if (opsize >= TCPOLEN_EXP_FASTOPEN_BASE &&
+				    get_unaligned_be16(ptr) ==
+				    TCPOPT_FASTOPEN_MAGIC)
+					tcp_parse_fastopen_option(opsize -
+						TCPOLEN_EXP_FASTOPEN_BASE,
+						ptr + 2, th->syn, foc, true);
 				break;
 
 			}
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 7404e52..464bd8c 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -518,17 +518,26 @@ static void tcp_options_write(__be32 *ptr, struct tcp_sock *tp,
 
 	if (unlikely(OPTION_FAST_OPEN_COOKIE & options)) {
 		struct tcp_fastopen_cookie *foc = opts->fastopen_cookie;
+		u8 *p = (u8 *)ptr;
+		u32 len; /* Fast Open option length */
+
+		if (foc->exp) {
+			len = TCPOLEN_EXP_FASTOPEN_BASE + foc->len;
+			*ptr = htonl((TCPOPT_EXP << 24) | (len << 16) |
+				     TCPOPT_FASTOPEN_MAGIC);
+			p += TCPOLEN_EXP_FASTOPEN_BASE;
+		} else {
+			len = TCPOLEN_FASTOPEN_BASE + foc->len;
+			*p++ = TCPOPT_FASTOPEN;
+			*p++ = len;
+		}
 
-		*ptr++ = htonl((TCPOPT_EXP << 24) |
-			       ((TCPOLEN_EXP_FASTOPEN_BASE + foc->len) << 16) |
-			       TCPOPT_FASTOPEN_MAGIC);
-
-		memcpy(ptr, foc->val, foc->len);
-		if ((foc->len & 3) == 2) {
-			u8 *align = ((u8 *)ptr) + foc->len;
-			align[0] = align[1] = TCPOPT_NOP;
+		memcpy(p, foc->val, foc->len);
+		if ((len & 3) == 2) {
+			p[foc->len] = TCPOPT_NOP;
+			p[foc->len + 1] = TCPOPT_NOP;
 		}
-		ptr += (foc->len + 3) >> 2;
+		ptr += (len + 3) >> 2;
 	}
 }
 
@@ -641,8 +650,11 @@ static unsigned int tcp_synack_options(struct sock *sk,
 		if (unlikely(!ireq->tstamp_ok))
 			remaining -= TCPOLEN_SACKPERM_ALIGNED;
 	}
-	if (foc && foc->len >= 0) {
-		u32 need = TCPOLEN_EXP_FASTOPEN_BASE + foc->len;
+	if (foc != NULL && foc->len >= 0) {
+		u32 need = foc->len;
+
+		need += foc->exp ? TCPOLEN_EXP_FASTOPEN_BASE :
+				   TCPOLEN_FASTOPEN_BASE;
 		need = (need + 3) & ~3U;  /* Align to 32 bits */
 		if (remaining >= need) {
 			opts->options |= OPTION_FAST_OPEN_COOKIE;
-- 
2.2.0.rc0.207.ga3a616c
