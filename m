From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] l2tp: dont play with skb->truesize
Date: Thu, 07 Feb 2013 16:00:34 -0800
Message-ID: <1360281634.28557.71.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	James Chapman <jchapman@katalix.com>,
	Andrew Savchenko <bircoph@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f178.google.com ([209.85.210.178]:50658 "EHLO
	mail-ia0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751501Ab3BHAAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Feb 2013 19:00:42 -0500
Received: by mail-ia0-f178.google.com with SMTP id y26so3518601iab.37
        for <netdev@vger.kernel.org>; Thu, 07 Feb 2013 16:00:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Andrew Savchenko reported a DNS failure and we diagnosed that
some UDP sockets were unable to send more packets because their
sk_wmem_alloc was corrupted after a while (tx_queue column in
following trace)

$ cat /proc/net/udp
  sl  local_address rem_address   st tx_queue rx_queue tr tm->when retrnsmt   uid  timeout inode ref pointer drops             
...
  459: 00000000:0270 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 4507 2 ffff88003d612380 0          
  466: 00000000:0277 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 4802 2 ffff88003d613180 0          
  470: 076A070A:007B 00000000:0000 07 FFFF4600:00000000 00:00000000 00000000   123        0 5552 2 ffff880039974380 0          
  470: 010213AC:007B 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 4986 2 ffff88003dbd3180 0          
  470: 010013AC:007B 00000000:0000 07 00000000:00000000 00:00000000 00000000     0        0 4985 2 ffff88003dbd2e00 0          
  470: 00FCA8C0:007B 00000000:0000 07 FFFFFB00:00000000 00:00000000 00000000     0        0 4984 2 ffff88003dbd2a80 0        
...

Playing with skb->truesize is tricky, especially when
skb is attached to a socket, as we can fool memory charging.

Just remove this code, its not worth trying to be ultra
precise in xmit path.

Reported-by: Andrew Savchenko <bircoph@gmail.com>
Tested-by: Andrew Savchenko <bircoph@gmail.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_core.c |    6 ------
 net/l2tp/l2tp_ppp.c  |    6 ------
 2 files changed, 12 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 06389d5..2ac884d 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1168,8 +1168,6 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
 	struct udphdr *uh;
 	struct inet_sock *inet;
 	__wsum csum;
-	int old_headroom;
-	int new_headroom;
 	int headroom;
 	int uhlen = (tunnel->encap == L2TP_ENCAPTYPE_UDP) ? sizeof(struct udphdr) : 0;
 	int udp_len;
@@ -1181,16 +1179,12 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
 	 */
 	headroom = NET_SKB_PAD + sizeof(struct iphdr) +
 		uhlen + hdr_len;
-	old_headroom = skb_headroom(skb);
 	if (skb_cow_head(skb, headroom)) {
 		kfree_skb(skb);
 		return NET_XMIT_DROP;
 	}
 
-	new_headroom = skb_headroom(skb);
 	skb_orphan(skb);
-	skb->truesize += new_headroom - old_headroom;
-
 	/* Setup L2TP header */
 	session->build_header(session, __skb_push(skb, hdr_len));
 
diff --git a/net/l2tp/l2tp_ppp.c b/net/l2tp/l2tp_ppp.c
index 286366e..716605c 100644
--- a/net/l2tp/l2tp_ppp.c
+++ b/net/l2tp/l2tp_ppp.c
@@ -388,8 +388,6 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	struct l2tp_session *session;
 	struct l2tp_tunnel *tunnel;
 	struct pppol2tp_session *ps;
-	int old_headroom;
-	int new_headroom;
 	int uhlen, headroom;
 
 	if (sock_flag(sk, SOCK_DEAD) || !(sk->sk_state & PPPOX_CONNECTED))
@@ -408,7 +406,6 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	if (tunnel == NULL)
 		goto abort_put_sess;
 
-	old_headroom = skb_headroom(skb);
 	uhlen = (tunnel->encap == L2TP_ENCAPTYPE_UDP) ? sizeof(struct udphdr) : 0;
 	headroom = NET_SKB_PAD +
 		   sizeof(struct iphdr) + /* IP header */
@@ -418,9 +415,6 @@ static int pppol2tp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	if (skb_cow_head(skb, headroom))
 		goto abort_put_sess_tun;
 
-	new_headroom = skb_headroom(skb);
-	skb->truesize += new_headroom - old_headroom;
-
 	/* Setup PPP header */
 	__skb_push(skb, sizeof(ppph));
 	skb->data[0] = ppph[0];
