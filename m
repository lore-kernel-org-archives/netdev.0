From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC v3 11/12] vti4: Check the tunnel endpoints of the xfrm state and the vti interface
Date: Mon, 27 Jan 2014 11:29:36 +0100
Message-ID: <1390818577-19589-12-git-send-email-steffen.klassert@secunet.com>
References: <1390818577-19589-1-git-send-email-steffen.klassert@secunet.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Christophe Gouault <christophe.gouault@6wind.com>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:43203 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753848AbaA0KaS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jan 2014 05:30:18 -0500
In-Reply-To: <1390818577-19589-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tunnel endpoints of the xfrm_state we got from the xfrm_lookup
must match the tunnel endpoints of the vti interface. This patch
ensures this matching.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ip_vti.c |   29 ++++++++++++++++++++++++-----
 1 file changed, 24 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index 1708fc1..1415c4a 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -106,10 +106,32 @@ static int vti_rcv_cb(struct sk_buff *skb, int err)
 	return 0;
 }
 
+static bool vti_state_check(const struct xfrm_state *x, __be32 dst, __be32 src)
+{
+	xfrm_address_t *daddr = (xfrm_address_t *)&dst;
+	xfrm_address_t *saddr = (xfrm_address_t *)&src;
+
+	/* if there is no transform then this tunnel is not functional.
+	 * Or if the xfrm is not mode tunnel.
+	 */
+	if (!x || x->props.mode != XFRM_MODE_TUNNEL ||
+	    x->props.family != AF_INET)
+		return false;
+
+	if (!dst)
+		return xfrm_addr_equal(saddr, &x->props.saddr, AF_INET);
+
+	if (!xfrm_state_addr_check(x, daddr, saddr, AF_INET))
+		return false;
+
+	return true;
+}
+
 static netdev_tx_t vti_xmit(struct sk_buff *skb, struct net_device *dev,
 			    struct flowi *fl)
 {
 	struct ip_tunnel *tunnel = netdev_priv(dev);
+	struct ip_tunnel_parm *parms = &tunnel->parms;
 	struct dst_entry *dst = skb_dst(skb);
 	struct net_device *tdev;	/* Device to other host */
 	int err;
@@ -126,15 +148,12 @@ static netdev_tx_t vti_xmit(struct sk_buff *skb, struct net_device *dev,
 		goto tx_error_icmp;
 	}
 
-	/* if there is no transform then this tunnel is not functional.
-	 * Or if the xfrm is not mode tunnel.
-	 */
-	if (!dst->xfrm ||
-	    dst->xfrm->props.mode != XFRM_MODE_TUNNEL) {
+	if (!vti_state_check(dst->xfrm, parms->iph.daddr, parms->iph.saddr)) {
 		dev->stats.tx_carrier_errors++;
 		dst_release(dst);
 		goto tx_error_icmp;
 	}
+
 	tdev = dst->dev;
 
 	if (tdev == dev) {
-- 
1.7.9.5
