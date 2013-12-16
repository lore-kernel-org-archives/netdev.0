From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC v2 12/13] vti4: Use the on xfrm_lookup returned dst_entry
 directly
Date: Mon, 16 Dec 2013 10:27:27 +0100
Message-ID: <20131216092727.GC31491@secunet.com>
References: <20131216091835.GQ31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christophe Gouault <christophe.gouault@6wind.com>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:52067 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752314Ab3LPJ1a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Dec 2013 04:27:30 -0500
Content-Disposition: inline
In-Reply-To: <20131216091835.GQ31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to be protocol family indepenent to support
inter addresss family tunneling with vti. So use a
dst_entry instead of the ipv4 rtable in vti_tunnel_xmit.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ip_vti.c |   18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 17ec174..f269310 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -116,7 +116,7 @@ static int vti_rcv_cb(struct sk_buff *skb, int err)
 static netdev_tx_t vti_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	struct rtable *rt;		/* Route to the other host */
+	struct dst_entry *dst;
 	struct net_device *tdev;	/* Device to other host */
 	struct flowi fl;
 	int err;
@@ -129,8 +129,8 @@ static netdev_tx_t vti_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	xfrm_decode_session(skb, &fl, AF_INET);
 
 	dst_hold(skb_dst(skb));
-	rt = (struct rtable *)xfrm_lookup(tunnel->net, skb_dst(skb), &fl, NULL, 0);
-	if (IS_ERR(rt)) {
+	dst = xfrm_lookup(tunnel->net, skb_dst(skb), &fl, NULL, 0);
+	if (IS_ERR(dst)) {
 		dev->stats.tx_carrier_errors++;
 		goto tx_error_icmp;
 	}
@@ -138,16 +138,16 @@ static netdev_tx_t vti_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 	/* if there is no transform then this tunnel is not functional.
 	 * Or if the xfrm is not mode tunnel.
 	 */
-	if (!rt->dst.xfrm ||
-	    rt->dst.xfrm->props.mode != XFRM_MODE_TUNNEL) {
+	if (!dst->xfrm ||
+	    dst->xfrm->props.mode != XFRM_MODE_TUNNEL) {
 		dev->stats.tx_carrier_errors++;
-		ip_rt_put(rt);
+		dst_release(dst);
 		goto tx_error_icmp;
 	}
-	tdev = rt->dst.dev;
+	tdev = dst->dev;
 
 	if (tdev == dev) {
-		ip_rt_put(rt);
+		dst_release(dst);
 		dev->stats.collisions++;
 		goto tx_error;
 	}
@@ -163,7 +163,7 @@ static netdev_tx_t vti_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
 	skb_scrub_packet(skb, !net_eq(tunnel->net, dev_net(dev)));
-	skb_dst_set(skb, &rt->dst);
+	skb_dst_set(skb, dst);
 	skb->dev = skb_dst(skb)->dev;
 
 	err = dst_output(skb);
-- 
1.7.9.5
