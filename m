From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC v3 05/12] xfrm: Add xfrm_tunnel_skb_cb to the skb common buffer
Date: Mon, 27 Jan 2014 11:29:30 +0100
Message-ID: <1390818577-19589-6-git-send-email-steffen.klassert@secunet.com>
References: <1390818577-19589-1-git-send-email-steffen.klassert@secunet.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>,
	Christophe Gouault <christophe.gouault@6wind.com>,
	Saurabh Mohan <saurabh.mohan@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:43171 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753747AbaA0KaK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jan 2014 05:30:10 -0500
In-Reply-To: <1390818577-19589-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPsec vti_rcv needs to remind the tunnel pointer to
check it later at the vti_rcv_cb callback. So add
this pointer to the IPsec common buffer.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h    |   29 +++++++++++++++++------------
 net/xfrm/xfrm_input.c |    6 ++----
 2 files changed, 19 insertions(+), 16 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 34aef6f..c8f84171 100644
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
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 9bf7559..aea3a90 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -200,10 +200,8 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 
 		nexthdr = x->type->input(x, skb);
 
-		if (nexthdr == -EINPROGRESS) {
-			xfrm_rcv_cb(skb, family, x->type->proto, nexthdr);
+		if (nexthdr == -EINPROGRESS) 
 			return 0;
-		}
 
 resume:
 		spin_lock(&x->lock);
@@ -281,7 +279,7 @@ resume:
 drop_unlock:
 	spin_unlock(&x->lock);
 drop:
-	xfrm_rcv_cb(skb, family, x ? x->type->proto : nexthdr, -1);
+	xfrm_rcv_cb(skb, family, x && x->type ? x->type->proto : nexthdr, -1);
 	kfree_skb(skb);
 	return 0;
 }
-- 
1.7.9.5
