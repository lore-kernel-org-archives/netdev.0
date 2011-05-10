From: David Miller <davem@davemloft.net>
Subject: [PATCH 3/10] ipv4: udp: Eliminate remaining uses of rt->rt_src
Date: Mon, 09 May 2011 22:31:16 -0700 (PDT)
Message-ID: <20110509.223116.48500459.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53401
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752993Ab1EJFbr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 01:31:47 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 3195824C087
	for <netdev@vger.kernel.org>; Mon,  9 May 2011 22:31:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We already track and pass around the correct flow key,
so simply use it in udp_send_skb().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/udp.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 66341a3..599374f 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -706,12 +706,11 @@ static void udp4_hwcsum(struct sk_buff *skb, __be32 src, __be32 dst)
 	}
 }
 
-static int udp_send_skb(struct sk_buff *skb, __be32 daddr, __be32 dport)
+static int udp_send_skb(struct sk_buff *skb, struct flowi4 *fl4)
 {
 	struct sock *sk = skb->sk;
 	struct inet_sock *inet = inet_sk(sk);
 	struct udphdr *uh;
-	struct rtable *rt = (struct rtable *)skb_dst(skb);
 	int err = 0;
 	int is_udplite = IS_UDPLITE(sk);
 	int offset = skb_transport_offset(skb);
@@ -723,7 +722,7 @@ static int udp_send_skb(struct sk_buff *skb, __be32 daddr, __be32 dport)
 	 */
 	uh = udp_hdr(skb);
 	uh->source = inet->inet_sport;
-	uh->dest = dport;
+	uh->dest = fl4->fl4_dport;
 	uh->len = htons(len);
 	uh->check = 0;
 
@@ -737,14 +736,14 @@ static int udp_send_skb(struct sk_buff *skb, __be32 daddr, __be32 dport)
 
 	} else if (skb->ip_summed == CHECKSUM_PARTIAL) { /* UDP hardware csum */
 
-		udp4_hwcsum(skb, rt->rt_src, daddr);
+		udp4_hwcsum(skb, fl4->saddr, fl4->daddr);
 		goto send;
 
 	} else
 		csum = udp_csum(skb);
 
 	/* add protocol-dependent pseudo-header */
-	uh->check = csum_tcpudp_magic(rt->rt_src, daddr, len,
+	uh->check = csum_tcpudp_magic(fl4->saddr, fl4->daddr, len,
 				      sk->sk_protocol, csum);
 	if (uh->check == 0)
 		uh->check = CSUM_MANGLED_0;
@@ -778,7 +777,7 @@ static int udp_push_pending_frames(struct sock *sk)
 	if (!skb)
 		goto out;
 
-	err = udp_send_skb(skb, fl4->daddr, fl4->fl4_dport);
+	err = udp_send_skb(skb, fl4);
 
 out:
 	up->len = 0;
@@ -963,7 +962,7 @@ back_from_confirm:
 				  msg->msg_flags);
 		err = PTR_ERR(skb);
 		if (skb && !IS_ERR(skb))
-			err = udp_send_skb(skb, daddr, dport);
+			err = udp_send_skb(skb, fl4);
 		goto out;
 	}
 
-- 
1.7.5.1

