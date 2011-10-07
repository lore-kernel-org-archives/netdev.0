From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] l2tp: give proper headroom in pppol2tp_xmit()
Date: Fri, 07 Oct 2011 17:45:57 +0200
Message-ID: <1318002357.3207.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:48192 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752258Ab1JGPpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 11:45:42 -0400
Received: by wwn22 with SMTP id 22so1116618wwn.1
        for <netdev@vger.kernel.org>; Fri, 07 Oct 2011 08:45:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pppol2tp_xmit() calls skb_cow_head(skb, 2) before calling
l2tp_xmit_skb()

Then l2tp_xmit_skb() calls again skb_cow_head(skb, large_headroom)

This patchs changes the first skb_cow_head() call to supply the needed
headroom to make sure at most one (expensive) pskb_expand_head() is
done.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
Maybe we should add a counter to help diagnose too many
pskb_expand_head() calls...

 net/l2tp/l2tp_ppp.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index f42cd09..8a90d75 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -395,6 +395,7 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	struct pppol2tp_session *ps;
 	int old_headroom;
 	int new_headroom;
+	int uhlen, headroom;
 
 	if (sock_flag(sk, SOCK_DEAD) || !(sk->sk_state & PPPOX_CONNECTED))
 		goto abort;
@@ -413,7 +414,13 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 		goto abort_put_sess;
 
 	old_headroom = skb_headroom(skb);
-	if (skb_cow_head(skb, sizeof(ppph)))
+	uhlen = (tunnel->encap == L2TP_ENCAPTYPE_UDP) ? sizeof(struct udphdr) : 0;
+	headroom = NET_SKB_PAD +
+		   sizeof(struct iphdr) + /* IP header */
+		   uhlen +		/* UDP header (if L2TP_ENCAPTYPE_UDP) */
+		   session->hdr_len +	/* L2TP header */
+		   sizeof(ppph);	/* PPP header */
+	if (skb_cow_head(skb, headroom))
 		goto abort_put_sess_tun;
 
 	new_headroom = skb_headroom(skb);
