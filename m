From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 12/16] net: Add a xfrm validate function to validate_xmit_skb
Date: Thu, 20 Apr 2017 10:55:11 +0200
Message-ID: <1492678515-14347-13-git-send-email-steffen.klassert@secunet.com>
References: <1492678515-14347-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:51636 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S970093AbdDTI5o (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 20 Apr 2017 04:57:44 -0400
In-Reply-To: <1492678515-14347-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we do IPsec offloading, we need a fallback for
packets that were targeted to be IPsec offloaded but
rerouted to a device that does not support IPsec offload.
For that we add a function that checks the offloading
features of the sending device and and flags the
requirement of a fallback before it calls the IPsec
output function. The IPsec output function adds the IPsec
trailer and does encryption if needed.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h     |  6 ++++++
 net/core/dev.c         |  3 +++
 net/xfrm/xfrm_device.c | 29 +++++++++++++++++++++++++++++
 3 files changed, 38 insertions(+)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 17603bf..6793a30c 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1862,6 +1862,7 @@ static inline struct xfrm_offload *xfrm_offload(struct sk_buff *skb)
 
 #ifdef CONFIG_XFRM_OFFLOAD
 void __net_init xfrm_dev_init(void);
+int validate_xmit_xfrm(struct sk_buff *skb, netdev_features_t features);
 int xfrm_dev_state_add(struct net *net, struct xfrm_state *x,
 		       struct xfrm_user_offload *xuo);
 bool xfrm_dev_offload_ok(struct sk_buff *skb, struct xfrm_state *x);
@@ -1890,6 +1891,11 @@ static inline void __net_init xfrm_dev_init(void)
 {
 }
 
+static inline int validate_xmit_xfrm(struct sk_buff *skb, netdev_features_t features)
+{
+	return 0;
+}
+
 static inline int xfrm_dev_state_add(struct net *net, struct xfrm_state *x, struct xfrm_user_offload *xuo)
 {
 	return 0;
diff --git a/net/core/dev.c b/net/core/dev.c
index ef9fe60e..5f0a864 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2972,6 +2972,9 @@ static struct sk_buff *validate_xmit_skb(struct sk_buff *skb, struct net_device
 		    __skb_linearize(skb))
 			goto out_kfree_skb;
 
+		if (validate_xmit_xfrm(skb, features))
+			goto out_kfree_skb;
+
 		/* If packet is not checksummed and device does not
 		 * support checksumming for this protocol, complete
 		 * checksumming here.
diff --git a/net/xfrm/xfrm_device.c b/net/xfrm/xfrm_device.c
index 9bac2ba..8ec8a3f 100644
--- a/net/xfrm/xfrm_device.c
+++ b/net/xfrm/xfrm_device.c
@@ -22,6 +22,35 @@
 #include <net/xfrm.h>
 #include <linux/notifier.h>
 
+int validate_xmit_xfrm(struct sk_buff *skb, netdev_features_t features)
+{
+	int err;
+	struct xfrm_state *x;
+	struct xfrm_offload *xo = xfrm_offload(skb);
+
+	if (skb_is_gso(skb))
+		return 0;
+
+	if (xo) {
+		x = skb->sp->xvec[skb->sp->len - 1];
+		if (xo->flags & XFRM_GRO || x->xso.flags & XFRM_OFFLOAD_INBOUND)
+			return 0;
+
+		x->outer_mode->xmit(x, skb);
+
+		err = x->type_offload->xmit(x, skb, features);
+		if (err) {
+			XFRM_INC_STATS(xs_net(x), LINUX_MIB_XFRMOUTSTATEPROTOERROR);
+			return err;
+		}
+
+		skb_push(skb, skb->data - skb_mac_header(skb));
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(validate_xmit_xfrm);
+
 int xfrm_dev_state_add(struct net *net, struct xfrm_state *x,
 		       struct xfrm_user_offload *xuo)
 {
-- 
2.7.4
