From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/4] gre: Use needed_headroom
Date: Thu, 09 Oct 2008 15:05:25 +0800
Message-ID: <E1KnpaP-0004PF-Fq@gondolin.me.apana.org.au>
References: <20081009070424.GA16684@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34533 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751272AbYJIHF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 03:05:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gre: Use needed_headroom

Now that we have dev->needed_headroom, we can use it instead of
having a bogus dev->hard_header_len.  This also allows us to
include dev->hard_header_len in the MTU computation so that when
we do have a meaningful hard_harder_len in future it is included
automatically in figuring out the MTU.

Incidentally, this fixes a bug where we ignored the needed_headroom
field of the underlying device in calculating our own hard_header_len.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/ip_gre.c |   15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 2a61158..fd192d6 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -637,7 +637,7 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	df = tiph->frag_off;
 	if (df)
-		mtu = dst_mtu(&rt->u.dst) - tunnel->hlen;
+		mtu = dst_mtu(&rt->u.dst) - dev->hard_header_len - tunnel->hlen;
 	else
 		mtu = skb->dst ? dst_mtu(skb->dst) : dev->mtu;
 
@@ -785,7 +785,7 @@ static void ipgre_tunnel_bind_dev(struct net_device *dev)
 	tunnel = netdev_priv(dev);
 	iph = &tunnel->parms.iph;
 
-	/* Guess output device to choose reasonable mtu and hard_header_len */
+	/* Guess output device to choose reasonable mtu and needed_headroom */
 
 	if (iph->daddr) {
 		struct flowi fl = { .oif = tunnel->parms.link,
@@ -806,7 +806,7 @@ static void ipgre_tunnel_bind_dev(struct net_device *dev)
 		tdev = __dev_get_by_index(dev_net(dev), tunnel->parms.link);
 
 	if (tdev) {
-		hlen = tdev->hard_header_len;
+		hlen = tdev->hard_header_len + tdev->needed_headroom;
 		mtu = tdev->mtu;
 	}
 	dev->iflink = tunnel->parms.link;
@@ -820,8 +820,8 @@ static void ipgre_tunnel_bind_dev(struct net_device *dev)
 		if (tunnel->parms.o_flags&GRE_SEQ)
 			addend += 4;
 	}
-	dev->hard_header_len = hlen + addend;
-	dev->mtu = mtu - addend;
+	dev->needed_headroom = addend + hlen;
+	dev->mtu = mtu - dev->hard_header_len - addend;
 	tunnel->hlen = addend;
 
 }
@@ -959,7 +959,8 @@ done:
 static int ipgre_tunnel_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	if (new_mtu < 68 || new_mtu > 0xFFF8 - tunnel->hlen)
+	if (new_mtu < 68 ||
+	    new_mtu > 0xFFF8 - dev->hard_header_len - tunnel->hlen)
 		return -EINVAL;
 	dev->mtu = new_mtu;
 	return 0;
@@ -1085,7 +1086,7 @@ static void ipgre_tunnel_setup(struct net_device *dev)
 	dev->change_mtu		= ipgre_tunnel_change_mtu;
 
 	dev->type		= ARPHRD_IPGRE;
-	dev->hard_header_len 	= LL_MAX_HEADER + sizeof(struct iphdr) + 4;
+	dev->needed_headroom 	= LL_MAX_HEADER + sizeof(struct iphdr) + 4;
 	dev->mtu		= ETH_DATA_LEN - sizeof(struct iphdr) - 4;
 	dev->flags		= IFF_NOARP;
 	dev->iflink		= 0;
