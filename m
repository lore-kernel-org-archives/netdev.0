From: fgao@ikuai8.com
Subject: [PATCH v5 net-next] l2tp: Refactor the codes with existing macros instead of literal number
Date: Mon, 22 Aug 2016 22:50:02 +0800
Message-ID: <1471877402-31384-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: jchapman@katalix.com, g.nault@alphalink.fr,
        philipp@redfish-solutions.com, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg292.qq.com ([113.108.11.231]:48058 "EHLO smtpbg292.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755470AbcHVOvA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 22 Aug 2016 10:51:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

Use PPP_ALLSTATIONS, PPP_UI, and SEND_SHUTDOWN instead of 0xff,
0x03, and 2 separately.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v5: Remove tail space;
 v4: Remove two static ppph variables;
 v3: Modify the subject;
 v2: Only replace the literal number with macros according to Guillaume's advice
 v1: Inital patch

 net/l2tp/l2tp_ppp.c | 20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index d9560aa..0c071c4 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -177,7 +177,7 @@ static int pppol2tp_recv_payload_hook(struct sk_buff *skb)
 	if (!pskb_may_pull(skb, 2))
 		return 1;
 
-	if ((skb->data[0] == 0xff) && (skb->data[1] == 0x03))
+	if ((skb->data[0] == PPP_ALLSTATIONS) && (skb->data[1] == PPP_UI))
 		skb_pull(skb, 2);
 
 	return 0;
@@ -282,7 +282,6 @@ static void pppol2tp_session_sock_put(struct l2tp_session *session)
 static int pppol2tp_sendmsg(struct socket *sock, struct msghdr *m,
 			    size_t total_len)
 {
-	static const unsigned char ppph[2] = { 0xff, 0x03 };
 	struct sock *sk = sock->sk;
 	struct sk_buff *skb;
 	int error;
@@ -312,7 +311,7 @@ static int pppol2tp_sendmsg(struct socket *sock, struct msghdr *m,
 	error = -ENOMEM;
 	skb = sock_wmalloc(sk, NET_SKB_PAD + sizeof(struct iphdr) +
 			   uhlen + session->hdr_len +
-			   sizeof(ppph) + total_len,
+			   2 + total_len, /* 2 bytes for PPP_ALLSTATIONS & PPP_UI */
 			   0, GFP_KERNEL);
 	if (!skb)
 		goto error_put_sess_tun;
@@ -325,8 +324,8 @@ static int pppol2tp_sendmsg(struct socket *sock, struct msghdr *m,
 	skb_reserve(skb, uhlen);
 
 	/* Add PPP header */
-	skb->data[0] = ppph[0];
-	skb->data[1] = ppph[1];
+	skb->data[0] = PPP_ALLSTATIONS;
+	skb->data[1] = PPP_UI;
 	skb_put(skb, 2);
 
 	/* Copy user data into skb */
@@ -369,7 +368,6 @@ error:
  */
 static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 {
-	static const u8 ppph[2] = { 0xff, 0x03 };
 	struct sock *sk = (struct sock *) chan->private;
 	struct sock *sk_tun;
 	struct l2tp_session *session;
@@ -398,14 +396,14 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 		   sizeof(struct iphdr) + /* IP header */
 		   uhlen +		/* UDP header (if L2TP_ENCAPTYPE_UDP) */
 		   session->hdr_len +	/* L2TP header */
-		   sizeof(ppph);	/* PPP header */
+		   2;			/* 2 bytes for PPP_ALLSTATIONS & PPP_UI */
 	if (skb_cow_head(skb, headroom))
 		goto abort_put_sess_tun;
 
 	/* Setup PPP header */
-	__skb_push(skb, sizeof(ppph));
-	skb->data[0] = ppph[0];
-	skb->data[1] = ppph[1];
+	__skb_push(skb, 2);
+	skb->data[0] = PPP_ALLSTATIONS;
+	skb->data[1] = PPP_UI;
 
 	local_bh_disable();
 	l2tp_xmit_skb(session, skb, session->hdr_len);
@@ -440,7 +438,7 @@ static void pppol2tp_session_close(struct l2tp_session *session)
 	BUG_ON(session->magic != L2TP_SESSION_MAGIC);
 
 	if (sock) {
-		inet_shutdown(sock, 2);
+		inet_shutdown(sock, SEND_SHUTDOWN);
 		/* Don't let the session go away before our socket does */
 		l2tp_session_inc_refcount(session);
 	}
-- 
1.9.1
