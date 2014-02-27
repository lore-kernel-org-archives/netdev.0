From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 05/12] xfrm: Add xfrm_tunnel_skb_cb to the skb common buffer
Date: Thu, 27 Feb 2014 09:00:33 +0100
Message-ID: <1393488040-22005-6-git-send-email-steffen.klassert@secunet.com>
References: <1393488040-22005-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:59036 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751370AbaB0IA7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 03:00:59 -0500
In-Reply-To: <1393488040-22005-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPsec vti_rcv needs to remind the tunnel pointer to
check it later at the vti_rcv_cb callback. So add
this pointer to the IPsec common buffer, initialize
it and check it to avoid transport state matching of
a tunneled packet.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h        |   50 ++++++++++++++++++++++++++++++++++-----------
 net/ipv4/xfrm4_protocol.c |    7 +++++++
 net/xfrm/xfrm_input.c     |    5 +++++
 3 files changed, 50 insertions(+), 12 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 345a150..3311259 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -599,16 +599,27 @@ struct xfrm_mgr {
 int xfrm_register_km(struct xfrm_mgr *km);
 int xfrm_unregister_km(struct xfrm_mgr *km);
 
+struct xfrm_tunnel_skb_cb {
+	union {
+		struct inet_skb_parm h4;
+		struct inet6_skb_parm h6;
+	} header;
+
+	union {
+		struct ip_tunnel *ip4;
+		struct ip6_tnl *ip6;
+	} tunnel;
+};
+
+#define XFRM_TUNNEL_SKB_CB(__skb) ((struct xfrm_tunnel_skb_cb *)&((__skb)->cb[0]))
+
 /*
  * This structure is used for the duration where packets are being
  * transformed by IPsec.  As soon as the packet leaves IPsec the
  * area beyond the generic IP part may be overwritten.
  */
 struct xfrm_skb_cb {
-	union {
-		struct inet_skb_parm h4;
-		struct inet6_skb_parm h6;
-        } header;
+	struct xfrm_tunnel_skb_cb header;
 
         /* Sequence number for replay protection. */
 	union {
@@ -630,10 +641,7 @@ struct xfrm_skb_cb {
  * to transmit header information to the mode input/output functions.
  */
 struct xfrm_mode_skb_cb {
-	union {
-		struct inet_skb_parm h4;
-		struct inet6_skb_parm h6;
-	} header;
+	struct xfrm_tunnel_skb_cb header;
 
 	/* Copied from header for IPv4, always set to zero and DF for IPv6. */
 	__be16 id;
@@ -665,10 +673,7 @@ struct xfrm_mode_skb_cb {
  * related information.
  */
 struct xfrm_spi_skb_cb {
-	union {
-		struct inet_skb_parm h4;
-		struct inet6_skb_parm h6;
-	} header;
+	struct xfrm_tunnel_skb_cb header;
 
 	unsigned int daddroff;
 	unsigned int family;
@@ -1510,6 +1515,7 @@ int xfrm4_rcv(struct sk_buff *skb);
 
 static inline int xfrm4_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
 {
+	XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip4 = NULL;
 	XFRM_SPI_SKB_CB(skb)->family = AF_INET;
 	XFRM_SPI_SKB_CB(skb)->daddroff = offsetof(struct iphdr, daddr);
 	return xfrm_input(skb, nexthdr, spi, 0);
@@ -1781,4 +1787,24 @@ static inline int xfrm_rcv_cb(struct sk_buff *skb, unsigned int family,
 	return 0;
 }
 
+static inline int xfrm_tunnel_check(struct sk_buff *skb, struct xfrm_state *x,
+				    unsigned int family)
+{
+	bool tunnel = false;
+
+	switch(family) {
+	case AF_INET:
+		if (XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip4)
+			tunnel = true;
+		break;
+	case AF_INET6:
+		if (XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip6)
+			tunnel = true;
+		break;
+	}
+	if (tunnel && !(x->outer_mode->flags & XFRM_MODE_FLAG_TUNNEL))
+		return -EINVAL;
+
+	return 0;
+}
 #endif	/* _NET_XFRM_H */
diff --git a/net/ipv4/xfrm4_protocol.c b/net/ipv4/xfrm4_protocol.c
index 862a26c..cdc09ef 100644
--- a/net/ipv4/xfrm4_protocol.c
+++ b/net/ipv4/xfrm4_protocol.c
@@ -65,6 +65,7 @@ int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
 	int ret;
 	struct xfrm4_protocol *handler;
 
+	XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip4 = NULL;
 	XFRM_SPI_SKB_CB(skb)->family = AF_INET;
 	XFRM_SPI_SKB_CB(skb)->daddroff = offsetof(struct iphdr, daddr);
 
@@ -84,6 +85,8 @@ static int xfrm4_esp_rcv(struct sk_buff *skb)
 	int ret;
 	struct xfrm4_protocol *handler;
 
+	XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip4 = NULL;
+
 	for_each_protocol_rcu(esp4_handlers, handler)
 		if ((ret = handler->handler(skb)) != -EINVAL)
 			return ret;
@@ -108,6 +111,8 @@ static int xfrm4_ah_rcv(struct sk_buff *skb)
 	int ret;
 	struct xfrm4_protocol *handler;
 
+	XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip4 = NULL;
+
 	for_each_protocol_rcu(ah4_handlers, handler)
 		if ((ret = handler->handler(skb)) != -EINVAL)
 			return ret;;
@@ -132,6 +137,8 @@ static int xfrm4_ipcomp_rcv(struct sk_buff *skb)
 	int ret;
 	struct xfrm4_protocol *handler;
 
+	XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip4 = NULL;
+
 	for_each_protocol_rcu(ipcomp4_handlers, handler)
 		if ((ret = handler->handler(skb)) != -EINVAL)
 			return ret;
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 99e3a9e..4218164 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -163,6 +163,11 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 
 		skb->sp->xvec[skb->sp->len++] = x;
 
+		if (xfrm_tunnel_check(skb, x, family)) {
+			XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATEMODEERROR);
+			goto drop;
+		}
+
 		spin_lock(&x->lock);
 		if (unlikely(x->km.state == XFRM_STATE_ACQ)) {
 			XFRM_INC_STATS(net, LINUX_MIB_XFRMACQUIREERROR);
-- 
1.7.9.5
