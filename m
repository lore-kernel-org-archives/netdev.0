From: fgao@ikuai8.com
Subject: [PATCH v1 1/1] l2tp: Use existing macros instead of literal number
Date: Fri, 19 Aug 2016 17:55:26 +0800
Message-ID: <1471600526-22584-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: jchapman@katalix.com, davem@davemloft.net, g.nault@alphalink.fr,
        philipp@redfish-solutions.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from SMTPBG132.QQ.COM ([113.108.23.42]:55510 "EHLO smtpbg132.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752067AbcHSJ5V (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 19 Aug 2016 05:57:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

1. Use PPP_ALLSTATIONS/PPP_UI instead of literal 0xff/0x03;
2. Use one static const global fixed_ppphdr instead of two same
static variable ppph in two different functions;
3. Use SEND_SHUTDOWN instead of literal 2;

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v1: Initial patch

 net/l2tp/l2tp_ppp.c | 28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index d9560aa..0e69eb4 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -138,6 +138,8 @@ static const struct ppp_channel_ops pppol2tp_chan_ops = {
 
 static const struct proto_ops pppol2tp_ops;
 
+static const unsigned char fixed_ppphdr[2] = {PPP_ALLSTATIONS, PPP_UI};
+
 /* Helpers to obtain tunnel/session contexts from sockets.
  */
 static inline struct l2tp_session *pppol2tp_sock_to_session(struct sock *sk)
@@ -174,11 +176,11 @@ static int pppol2tp_recv_payload_hook(struct sk_buff *skb)
 	 * Note that skb->data[] isn't dereferenced from a u16 ptr here since
 	 * the field may be unaligned.
 	 */
-	if (!pskb_may_pull(skb, 2))
+	if (!pskb_may_pull(skb, sizeof(fixed_ppphdr)))
 		return 1;
 
-	if ((skb->data[0] == 0xff) && (skb->data[1] == 0x03))
-		skb_pull(skb, 2);
+	if ((PPP_ADDRESS(skb->data) == PPP_ALLSTATIONS) && (PPP_CONTROL(skb->data) == PPP_UI))
+		skb_pull(skb, sizeof(fixed_ppphdr));
 
 	return 0;
 }
@@ -282,7 +284,6 @@ static void pppol2tp_session_sock_put(struct l2tp_session *session)
 static int pppol2tp_sendmsg(struct socket *sock, struct msghdr *m,
 			    size_t total_len)
 {
-	static const unsigned char ppph[2] = { 0xff, 0x03 };
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
 	int error;
@@ -312,7 +313,7 @@ static int pppol2tp_sendmsg(struct socket *sock, struct msghdr *m,
 	error = -ENOMEM;
 	skb = sock_wmalloc(sk, NET_SKB_PAD + sizeof(struct iphdr) +
 			   uhlen + session->hdr_len +
-			   sizeof(ppph) + total_len,
+			   sizeof(fixed_ppphdr) + total_len,
 			   0, GFP_KERNEL);
 	if (!skb)
 		goto error_put_sess_tun;
@@ -325,9 +326,9 @@ static int pppol2tp_sendmsg(struct socket *sock, struct msghdr *m,
 	skb_reserve(skb, uhlen);
 
 	/* Add PPP header */
-	skb->data[0] = ppph[0];
-	skb->data[1] = ppph[1];
-	skb_put(skb, 2);
+	PPP_ADDRESS(skb->data) = fixed_ppphdr[0];
+	PPP_CONTROL(skb->data) = fixed_ppphdr[1];
+	skb_put(skb, sizeof(fixed_ppphdr));
 
 	/* Copy user data into skb */
 	error = memcpy_from_msg(skb_put(skb, total_len), m, total_len);
@@ -369,7 +370,6 @@ error:
  */
 static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 {
-	static const u8 ppph[2] = { 0xff, 0x03 };
 	struct sock *sk = (struct sock *) chan->private;
 	struct sock *sk_tun;
 	struct l2tp_session *session;
@@ -398,14 +398,14 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 		   sizeof(struct iphdr) + /* IP header */
 		   uhlen +		/* UDP header (if L2TP_ENCAPTYPE_UDP) */
 		   session->hdr_len +	/* L2TP header */
-		   sizeof(ppph);	/* PPP header */
+		   sizeof(fixed_ppphdr); /* PPP header */
 	if (skb_cow_head(skb, headroom))
 		goto abort_put_sess_tun;
 
 	/* Setup PPP header */
-	__skb_push(skb, sizeof(ppph));
-	skb->data[0] = ppph[0];
-	skb->data[1] = ppph[1];
+	__skb_push(skb, sizeof(fixed_ppphdr));
+	skb->data[0] = fixed_ppphdr[0];
+	skb->data[1] = fixed_ppphdr[1];
 
 	local_bh_disable();
 	l2tp_xmit_skb(session, skb, session->hdr_len);
@@ -440,7 +440,7 @@ static void pppol2tp_session_close(struct l2tp_session *session)
 	BUG_ON(session->magic != L2TP_SESSION_MAGIC);
 
 	if (sock) {
-		inet_shutdown(sock, 2);
+		inet_shutdown(sock, SEND_SHUTDOWN);
 		/* Don't let the session go away before our socket does */
 		l2tp_session_inc_refcount(session);
 	}
-- 
1.9.1
