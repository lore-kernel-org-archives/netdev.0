From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC v4 11/12] vti4: Check the tunnel endpoints of the xfrm state and the vti interface
Date: Fri, 14 Feb 2014 09:30:19 +0100
Message-ID: <1392366620-31923-12-git-send-email-steffen.klassert@secunet.com>
References: <1392366620-31923-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Christophe Gouault <christophe.gouault@6wind.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:39155 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752154AbaBNIaz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Feb 2014 03:30:55 -0500
In-Reply-To: <1392366620-31923-1-git-send-email-steffen.klassert@secunet.com>
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
index 9369b7c..9471893 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -123,10 +123,32 @@ static int vti_rcv_cb(struct sk_buff *skb, int err)
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
@@ -143,15 +165,12 @@ static netdev_tx_t vti_xmit(struct sk_buff *skb, struct net_device *dev,
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
