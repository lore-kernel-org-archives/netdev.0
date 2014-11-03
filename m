From: Florian Westphal <fw@strlen.de>
Subject: [PATCH -next v4 1/3] syncookies: avoid magic values and document which-bit-is-what-option
Date: Mon,  3 Nov 2014 17:35:01 +0100
Message-ID: <1415032503-4936-2-git-send-email-fw@strlen.de>
References: <1415032503-4936-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:45432 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752385AbaKCQfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 11:35:09 -0500
In-Reply-To: <1415032503-4936-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Was a bit more difficult to read than needed due to magic shifts;
add defines and document the used encoding scheme.

Joint work with Daniel Borkmann.

Acked-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 no changes since v3, added preserved Erics Acked-by tag.

 net/ipv4/syncookies.c | 50 +++++++++++++++++++++++++++++++++++---------------
 1 file changed, 35 insertions(+), 15 deletions(-)

diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 4ac7bca..c3792c0 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -19,10 +19,6 @@
 #include <net/tcp.h>
 #include <net/route.h>
 
-/* Timestamps: lowest bits store TCP options */
-#define TSBITS 6
-#define TSMASK (((__u32)1 << TSBITS) - 1)
-
 extern int sysctl_tcp_syncookies;
 
 static u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS] __read_mostly;
@@ -30,6 +26,30 @@ static u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS] __read_mostly;
 #define COOKIEBITS 24	/* Upper bits store count */
 #define COOKIEMASK (((__u32)1 << COOKIEBITS) - 1)
 
+/* TCP Timestamp: 6 lowest bits of timestamp sent in the cookie SYN-ACK
+ * stores TCP options:
+ *
+ * MSB                               LSB
+ * | 31 ...   6 |  5  |  4   | 3 2 1 0 |
+ * |  Timestamp | ECN | SACK | WScale  |
+ *
+ * When we receive a valid cookie-ACK, we look at the echoed tsval (if
+ * any) to figure out which TCP options we should use for the rebuilt
+ * connection.
+ *
+ * A WScale setting of '0xf' (which is an invalid scaling value)
+ * means that original syn did not include the TCP window scaling option.
+ */
+#define TS_OPT_WSCALE_MASK	0xf
+#define TS_OPT_SACK		BIT(4)
+#define TS_OPT_ECN		BIT(5)
+/* There is no TS_OPT_TIMESTAMP:
+ * if ACK contains timestamp option, we already know it was
+ * requested/supported by the syn/synack exchange.
+ */
+#define TSBITS	6
+#define TSMASK	(((__u32)1 << TSBITS) - 1)
+
 static DEFINE_PER_CPU(__u32 [16 + 5 + SHA_WORKSPACE_WORDS],
 		      ipv4_cookie_scratch);
 
@@ -67,9 +87,11 @@ __u32 cookie_init_timestamp(struct request_sock *req)
 
 	ireq = inet_rsk(req);
 
-	options = ireq->wscale_ok ? ireq->snd_wscale : 0xf;
-	options |= ireq->sack_ok << 4;
-	options |= ireq->ecn_ok << 5;
+	options = ireq->wscale_ok ? ireq->snd_wscale : TS_OPT_WSCALE_MASK;
+	if (ireq->sack_ok)
+		options |= TS_OPT_SACK;
+	if (ireq->ecn_ok)
+		options |= TS_OPT_ECN;
 
 	ts = ts_now & ~TSMASK;
 	ts |= options;
@@ -219,16 +241,13 @@ static inline struct sock *get_cookie_sock(struct sock *sk, struct sk_buff *skb,
  * additional tcp options in the timestamp.
  * This extracts these options from the timestamp echo.
  *
- * The lowest 4 bits store snd_wscale.
- * next 2 bits indicate SACK and ECN support.
- *
  * return false if we decode an option that should not be.
  */
 bool cookie_check_timestamp(struct tcp_options_received *tcp_opt,
 			struct net *net, bool *ecn_ok)
 {
 	/* echoed timestamp, lowest bits contain options */
-	u32 options = tcp_opt->rcv_tsecr & TSMASK;
+	u32 options = tcp_opt->rcv_tsecr;
 
 	if (!tcp_opt->saw_tstamp)  {
 		tcp_clear_options(tcp_opt);
@@ -238,19 +257,20 @@ bool cookie_check_timestamp(struct tcp_options_received *tcp_opt,
 	if (!sysctl_tcp_timestamps)
 		return false;
 
-	tcp_opt->sack_ok = (options & (1 << 4)) ? TCP_SACK_SEEN : 0;
-	*ecn_ok = (options >> 5) & 1;
+	tcp_opt->sack_ok = (options & TS_OPT_SACK) ? TCP_SACK_SEEN : 0;
+	*ecn_ok = options & TS_OPT_ECN;
 	if (*ecn_ok && !net->ipv4.sysctl_tcp_ecn)
 		return false;
 
 	if (tcp_opt->sack_ok && !sysctl_tcp_sack)
 		return false;
 
-	if ((options & 0xf) == 0xf)
+	if ((options & TS_OPT_WSCALE_MASK) == TS_OPT_WSCALE_MASK)
 		return true; /* no window scaling */
 
 	tcp_opt->wscale_ok = 1;
-	tcp_opt->snd_wscale = options & 0xf;
+	tcp_opt->snd_wscale = options & TS_OPT_WSCALE_MASK;
+
 	return sysctl_tcp_window_scaling != 0;
 }
 EXPORT_SYMBOL(cookie_check_timestamp);
-- 
2.0.4
