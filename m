From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 07/13] vti6: Remove dst_entry caching
Date: Tue, 18 Mar 2014 08:21:32 +0100
Message-ID: <1395127298-24083-8-git-send-email-steffen.klassert@secunet.com>
References: <1395127298-24083-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53252 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753471AbaCRHV4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Mar 2014 03:21:56 -0400
In-Reply-To: <1395127298-24083-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unlike ip6_tunnel, vti6 can lookup multiple different dst entries,
dependent of the configured xfrm states. Therefore it does not make
sense to cache a dst_entry.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/ip6_vti.c |   42 ++++++++++++++++++------------------------
 1 file changed, 18 insertions(+), 24 deletions(-)

diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index 8649143..f5ba4d4 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -278,7 +278,6 @@ static void vti6_dev_uninit(struct net_device *dev)
 		RCU_INIT_POINTER(ip6n->tnls_wc[0], NULL);
 	else
 		vti6_tnl_unlink(ip6n, t);
-	ip6_tnl_dst_reset(t);
 	dev_put(dev);
 }
 
@@ -356,11 +355,10 @@ vti6_addr_conflict(const struct ip6_tnl *t, const struct ipv6hdr *hdr)
  **/
 static int vti6_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct net *net = dev_net(dev);
 	struct ip6_tnl *t = netdev_priv(dev);
 	struct net_device_stats *stats = &t->dev->stats;
-	struct dst_entry *dst = NULL, *ndst = NULL;
-	struct flowi6 fl6;
+	struct dst_entry *dst = skb_dst(skb);
+	struct flowi fl;
 	struct ipv6hdr *ipv6h = ipv6_hdr(skb);
 	struct net_device *tdev;
 	int err = -1;
@@ -369,21 +367,19 @@ static int vti6_xmit(struct sk_buff *skb, struct net_device *dev)
 	    !ip6_tnl_xmit_ctl(t) || vti6_addr_conflict(t, ipv6h))
 		return err;
 
-	dst = ip6_tnl_dst_check(t);
-	if (!dst) {
-		memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
+	memset(&fl, 0, sizeof(fl));
+	skb->mark = be32_to_cpu(t->parms.o_key);
+	xfrm_decode_session(skb, &fl, AF_INET6);
 
-		ndst = ip6_route_output(net, NULL, &fl6);
+	if (!dst)
+		goto tx_err_link_failure;
 
-		if (ndst->error)
-			goto tx_err_link_failure;
-		ndst = xfrm_lookup(net, ndst, flowi6_to_flowi(&fl6), NULL, 0);
-		if (IS_ERR(ndst)) {
-			err = PTR_ERR(ndst);
-			ndst = NULL;
-			goto tx_err_link_failure;
-		}
-		dst = ndst;
+	dst_hold(dst);
+	dst = xfrm_lookup(t->net, dst, &fl, NULL, 0);
+	if (IS_ERR(dst)) {
+		err = PTR_ERR(dst);
+		dst = NULL;
+		goto tx_err_link_failure;
 	}
 
 	if (!dst->xfrm || dst->xfrm->props.mode != XFRM_MODE_TUNNEL)
@@ -399,21 +395,19 @@ static int vti6_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 
-	skb_dst_drop(skb);
-	skb_dst_set_noref(skb, dst);
+	memset(IP6CB(skb), 0, sizeof(*IP6CB(skb)));
+	skb_scrub_packet(skb, !net_eq(t->net, dev_net(dev)));
+	skb_dst_set(skb, dst);
+	skb->dev = skb_dst(skb)->dev;
 
 	ip6tunnel_xmit(skb, dev);
-	if (ndst) {
-		dev->mtu = dst_mtu(ndst);
-		ip6_tnl_dst_store(t, ndst);
-	}
 
 	return 0;
 tx_err_link_failure:
 	stats->tx_carrier_errors++;
 	dst_link_failure(skb);
 tx_err_dst_release:
-	dst_release(ndst);
+	dst_release(dst);
 	return err;
 }
 
-- 
1.7.9.5
