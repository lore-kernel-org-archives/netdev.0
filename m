From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/5] ipv4: Kill ip_rt_frag_needed().
Date: Mon, 11 Jun 2012 02:29:11 -0700 (PDT)
Message-ID: <20120611.022911.885347106959530782.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41163 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751732Ab2FKJ3M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 05:29:12 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 3CC4D58426C
	for <netdev@vger.kernel.org>; Mon, 11 Jun 2012 02:29:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


There is zero point to this function.

It's only real substance is to perform an extremely outdated BSD4.2
ICMP check, which we can safely remove.  If you really have a MTU
limited link being routed by a BSD4.2 derived system, here's a nickel
go buy yourself a real router.

The other actions of ip_rt_frag_needed(), checking and conditionally
updating the peer, are done by the per-protocol handlers of the ICMP
event.

TCP, UDP, et al. have a handler which will receive this event and
transmit it back into the associated route via dst_ops->update_pmtu().

This simplification is important, because it eliminates the one place
where we do not have a proper route context in which to make an
inetpeer lookup.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h  |    2 --
 net/ipv4/icmp.c      |    4 +---
 net/ipv4/route.c     |   61 --------------------------------------------------
 net/rxrpc/ar-error.c |    4 ----
 4 files changed, 1 insertion(+), 70 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 6340c37..cc693a5 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -215,8 +215,6 @@ static inline int ip_route_input_noref(struct sk_buff *skb, __be32 dst, __be32 s
 	return ip_route_input_common(skb, dst, src, tos, devin, true);
 }
 
-extern unsigned short	ip_rt_frag_needed(struct net *net, const struct iphdr *iph,
-					  unsigned short new_mtu, struct net_device *dev);
 extern void		ip_rt_send_redirect(struct sk_buff *skb);
 
 extern unsigned int		inet_addr_type(struct net *net, __be32 addr);
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 0c78ef1..e1caa1a 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -673,9 +673,7 @@ static void icmp_unreach(struct sk_buff *skb)
 				LIMIT_NETDEBUG(KERN_INFO pr_fmt("%pI4: fragmentation needed and DF set\n"),
 					       &iph->daddr);
 			} else {
-				info = ip_rt_frag_needed(net, iph,
-							 ntohs(icmph->un.frag.mtu),
-							 skb->dev);
+				info = ntohs(icmph->un.frag.mtu);
 				if (!info)
 					goto out;
 			}
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 03e5b61..4f5834c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1664,67 +1664,6 @@ out:	kfree_skb(skb);
 	return 0;
 }
 
-/*
- *	The last two values are not from the RFC but
- *	are needed for AMPRnet AX.25 paths.
- */
-
-static const unsigned short mtu_plateau[] =
-{32000, 17914, 8166, 4352, 2002, 1492, 576, 296, 216, 128 };
-
-static inline unsigned short guess_mtu(unsigned short old_mtu)
-{
-	int i;
-
-	for (i = 0; i < ARRAY_SIZE(mtu_plateau); i++)
-		if (old_mtu > mtu_plateau[i])
-			return mtu_plateau[i];
-	return 68;
-}
-
-unsigned short ip_rt_frag_needed(struct net *net, const struct iphdr *iph,
-				 unsigned short new_mtu,
-				 struct net_device *dev)
-{
-	unsigned short old_mtu = ntohs(iph->tot_len);
-	unsigned short est_mtu = 0;
-	struct inet_peer *peer;
-
-	peer = inet_getpeer_v4(net->ipv4.peers, iph->daddr, 1);
-	if (peer) {
-		unsigned short mtu = new_mtu;
-
-		if (new_mtu < 68 || new_mtu >= old_mtu) {
-			/* BSD 4.2 derived systems incorrectly adjust
-			 * tot_len by the IP header length, and report
-			 * a zero MTU in the ICMP message.
-			 */
-			if (mtu == 0 &&
-			    old_mtu >= 68 + (iph->ihl << 2))
-				old_mtu -= iph->ihl << 2;
-			mtu = guess_mtu(old_mtu);
-		}
-
-		if (mtu < ip_rt_min_pmtu)
-			mtu = ip_rt_min_pmtu;
-		if (!peer->pmtu_expires || mtu < peer->pmtu_learned) {
-			unsigned long pmtu_expires;
-
-			pmtu_expires = jiffies + ip_rt_mtu_expires;
-			if (!pmtu_expires)
-				pmtu_expires = 1UL;
-
-			est_mtu = mtu;
-			peer->pmtu_learned = mtu;
-			peer->pmtu_expires = pmtu_expires;
-			atomic_inc(&__rt_peer_genid);
-		}
-
-		inet_putpeer(peer);
-	}
-	return est_mtu ? : new_mtu;
-}
-
 static void check_peer_pmtu(struct dst_entry *dst, struct inet_peer *peer)
 {
 	unsigned long expires = ACCESS_ONCE(peer->pmtu_expires);
diff --git a/net/rxrpc/ar-error.c b/net/rxrpc/ar-error.c
index 5d6b572..a920608 100644
--- a/net/rxrpc/ar-error.c
+++ b/net/rxrpc/ar-error.c
@@ -81,10 +81,6 @@ void rxrpc_UDP_error_report(struct sock *sk)
 			_net("I/F MTU %u", mtu);
 		}
 
-		/* ip_rt_frag_needed() may have eaten the info */
-		if (mtu == 0)
-			mtu = ntohs(icmp_hdr(skb)->un.frag.mtu);
-
 		if (mtu == 0) {
 			/* they didn't give us a size, estimate one */
 			if (mtu > 1500) {
-- 
1.7.10
