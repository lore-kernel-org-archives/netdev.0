From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [UNTESTED] Add hardware-assisted VLAN support for GRO
Date: Fri, 2 Jan 2009 16:47:14 +1100
Message-ID: <20090102054714.GA23106@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.62.148.172] ([64.62.148.172]:53169 "EHLO arnor.apana.org.au"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750869AbZABFry (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jan 2009 00:47:54 -0500
Received: from gondolin.me.apana.org.au ([192.168.0.6])
	by arnor.apana.org.au with esmtp (Exim 4.63 #1 (Debian))
	id 1LIcsN-00077Y-DQ
	for <netdev@vger.kernel.org>; Fri, 02 Jan 2009 16:47:15 +1100
Received: from herbert by gondolin.me.apana.org.au with local (Exim 4.69)
	(envelope-from <herbert@gondor.apana.org.au>)
	id 1LIcsM-000616-FC
	for netdev@vger.kernel.org; Fri, 02 Jan 2009 16:47:14 +1100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

WARNING: These patches haven't been tested yet!

This is the last missing bit for feature parity with LRO.  Please
let me know if you spot any bugs in them.

gro: Add internal interfaces for VLAN

Previously GRO's only entry point from the outside is through
napi_gro_receive and napi_gro_frags.  These interfaces are for
device drivers.

This patch rearranges things to provide a new set of interfaces
for VLANs.  These interfaces are for internal use only.  The
VLAN code itself can then provide a set of entry points for
device drivers.

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c28bbba..114091b 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1373,8 +1373,14 @@ extern int		netif_rx_ni(struct sk_buff *skb);
 #define HAVE_NETIF_RECEIVE_SKB 1
 extern int		netif_receive_skb(struct sk_buff *skb);
 extern void		napi_gro_flush(struct napi_struct *napi);
+extern int		dev_gro_receive(struct napi_struct *napi,
+					struct sk_buff *skb);
 extern int		napi_gro_receive(struct napi_struct *napi,
 					 struct sk_buff *skb);
+extern void		napi_reuse_skb(struct napi_struct *napi,
+				       struct sk_buff *skb);
+extern struct sk_buff *	napi_fraginfo_skb(struct napi_struct *napi,
+					  struct napi_gro_fraginfo *info);
 extern int		napi_gro_frags(struct napi_struct *napi,
 				       struct napi_gro_fraginfo *info);
 extern void		netif_nit_deliver(struct sk_buff *skb);
diff --git a/net/core/dev.c b/net/core/dev.c
index 18be66b..2f393c0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2387,7 +2387,7 @@ void napi_gro_flush(struct napi_struct *napi)
 }
 EXPORT_SYMBOL(napi_gro_flush);
 
-static int __napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
+int dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
 	struct sk_buff **pp = NULL;
 	struct packet_type *ptype;
@@ -2417,11 +2417,14 @@ static int __napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 
 		for (p = napi->gro_list; p; p = p->next) {
 			count++;
-			NAPI_GRO_CB(p)->same_flow =
-				p->mac_len == mac_len &&
-				!memcmp(skb_mac_header(p), skb_mac_header(skb),
-					mac_len);
-			NAPI_GRO_CB(p)->flush = 0;
+
+			if (!NAPI_GRO_CB(p)->same_flow)
+				continue;
+
+			if (p->mac_len != mac_len ||
+			    !memcmp(skb_mac_header(p), skb_mac_header(skb),
+				    mac_len))
+				NAPI_GRO_CB(p)->same_flow = 0;
 		}
 
 		pp = ptype->gro_receive(&napi->gro_list, skb);
@@ -2463,6 +2466,19 @@ ok:
 normal:
 	return -1;
 }
+EXPORT_SYMBOL(dev_gro_receive);
+
+static int __napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
+{
+	struct sk_buff *p;
+
+	for (p = napi->gro_list; p; p = p->next) {
+		NAPI_GRO_CB(p)->same_flow = 1;
+		NAPI_GRO_CB(p)->flush = 0;
+	}
+
+	return dev_gro_receive(napi, skb);
+}
 
 int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
@@ -2479,11 +2495,26 @@ int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(napi_gro_receive);
 
-int napi_gro_frags(struct napi_struct *napi, struct napi_gro_fraginfo *info)
+void napi_reuse_skb(struct napi_struct *napi, struct sk_buff *skb)
+{
+	skb_shinfo(skb)->nr_frags = 0;
+
+	skb->len -= skb->data_len;
+	skb->truesize -= skb->data_len;
+	skb->data_len = 0;
+
+	__skb_pull(skb, skb_headlen(skb));
+	skb_reserve(skb, NET_IP_ALIGN - skb_headroom(skb));
+
+	napi->skb = skb;
+}
+EXPORT_SYMBOL(napi_reuse_skb);
+
+struct sk_buff *napi_fraginfo_skb(struct napi_struct *napi,
+				  struct napi_gro_fraginfo *info)
 {
 	struct net_device *dev = napi->dev;
 	struct sk_buff *skb = napi->skb;
-	int err = NET_RX_DROP;
 
 	napi->skb = NULL;
 
@@ -2503,16 +2534,31 @@ int napi_gro_frags(struct napi_struct *napi, struct napi_gro_fraginfo *info)
 	skb->len += info->len;
 	skb->truesize += info->len;
 
-	if (!pskb_may_pull(skb, ETH_HLEN))
-		goto reuse;
-
-	err = NET_RX_SUCCESS;
+	if (!pskb_may_pull(skb, ETH_HLEN)) {
+		napi_reuse_skb(napi, skb);
+		goto out;
+	}
 
 	skb->protocol = eth_type_trans(skb, dev);
 
 	skb->ip_summed = info->ip_summed;
 	skb->csum = info->csum;
 
+out:
+	return skb;
+}
+EXPORT_SYMBOL(napi_fraginfo_skb);
+
+int napi_gro_frags(struct napi_struct *napi, struct napi_gro_fraginfo *info)
+{
+	struct sk_buff *skb = napi_fraginfo_skb(napi, info);
+	int err = NET_RX_DROP;
+
+	if (!skb)
+		goto out;
+
+	err = NET_RX_SUCCESS;
+
 	switch (__napi_gro_receive(napi, skb)) {
 	case -1:
 		return netif_receive_skb(skb);
@@ -2521,17 +2567,7 @@ int napi_gro_frags(struct napi_struct *napi, struct napi_gro_fraginfo *info)
 		goto out;
 	}
 
-reuse:
-	skb_shinfo(skb)->nr_frags = 0;
-
-	skb->len -= skb->data_len;
-	skb->truesize -= skb->data_len;
-	skb->data_len = 0;
-
-	__skb_pull(skb, skb_headlen(skb));
-	skb_reserve(skb, NET_IP_ALIGN - skb_headroom(skb));
-
-	napi->skb = skb;
+	napi_reuse_skb(napi, skb);
 
 out:
 	return err;

vlan: Add GRO interfaces

This patch adds GRO interfaces for hardware-assisted VLAN reception.
With this in place we're now at parity with LRO as far as the
interface is concerned.  That is, you can now take any LRO driver
and convert it over to GRO.

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index a5cb0c3..f8ff918 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -115,6 +115,11 @@ extern u16 vlan_dev_vlan_id(const struct net_device *dev);
 extern int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 			     u16 vlan_tci, int polling);
 extern int vlan_hwaccel_do_receive(struct sk_buff *skb);
+extern int vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
+			    unsigned int vlan_tci, struct sk_buff *skb);
+extern int vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
+			  unsigned int vlan_tci,
+			  struct napi_gro_fraginfo *info);
 
 #else
 static inline struct net_device *vlan_dev_real_dev(const struct net_device *dev)
@@ -140,6 +145,20 @@ static inline int vlan_hwaccel_do_receive(struct sk_buff *skb)
 {
 	return 0;
 }
+
+static inline int vlan_gro_receive(struct napi_struct *napi,
+				   struct vlan_group *grp,
+				   unsigned int vlan_tci, struct sk_buff *skb)
+{
+	return NET_RX_DROP;
+}
+
+static inline int vlan_gro_frags(struct napi_struct *napi,
+				 struct vlan_group *grp, unsigned int vlan_tci,
+				 struct napi_gro_fraginfo *info)
+{
+	return NET_RX_DROP;
+}
 #endif
 
 /**
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index dd86a1d..fa2f7e9 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -3,45 +3,35 @@
 #include <linux/if_vlan.h>
 #include "vlan.h"
 
-struct vlan_hwaccel_cb {
-	struct net_device	*dev;
-};
-
-static inline struct vlan_hwaccel_cb *vlan_hwaccel_cb(struct sk_buff *skb)
-{
-	return (struct vlan_hwaccel_cb *)skb->cb;
-}
-
 /* VLAN rx hw acceleration helper.  This acts like netif_{rx,receive_skb}(). */
 int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 		      u16 vlan_tci, int polling)
 {
-	struct vlan_hwaccel_cb *cb = vlan_hwaccel_cb(skb);
-
-	if (skb_bond_should_drop(skb)) {
-		dev_kfree_skb_any(skb);
-		return NET_RX_DROP;
-	}
+	if (skb_bond_should_drop(skb))
+		goto drop;
 
 	skb->vlan_tci = vlan_tci;
-	cb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
+	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
+
+	if (!skb->dev)
+		goto drop;
 
 	return (polling ? netif_receive_skb(skb) : netif_rx(skb));
+
+drop:
+	dev_kfree_skb_any(skb);
+	return NET_RX_DROP;
 }
 EXPORT_SYMBOL(__vlan_hwaccel_rx);
 
 int vlan_hwaccel_do_receive(struct sk_buff *skb)
 {
-	struct vlan_hwaccel_cb *cb = vlan_hwaccel_cb(skb);
-	struct net_device *dev = cb->dev;
+	struct net_device *dev = skb->dev;
 	struct net_device_stats *stats;
 
+	skb->dev = vlan_dev_info(dev)->real_dev;
 	netif_nit_deliver(skb);
-
-	if (dev == NULL) {
-		kfree_skb(skb);
-		return -1;
-	}
+	skb->dev = dev;
 
 	skb->dev = dev;
 	skb->priority = vlan_get_ingress_priority(dev, skb->vlan_tci);
@@ -80,3 +70,76 @@ u16 vlan_dev_vlan_id(const struct net_device *dev)
 	return vlan_dev_info(dev)->vlan_id;
 }
 EXPORT_SYMBOL_GPL(vlan_dev_vlan_id);
+
+int vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
+		     unsigned int vlan_tci, struct sk_buff *skb)
+{
+	struct sk_buff *p;
+
+	if (skb_bond_should_drop(skb))
+		goto drop;
+
+	skb->vlan_tci = vlan_tci;
+	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
+
+	if (!skb->dev)
+		goto drop;
+
+	for (p = napi->gro_list; p; p = p->next) {
+		NAPI_GRO_CB(p)->same_flow = p->vlan_tci == skb->vlan_tci &&
+					    p->dev == skb->dev;
+		NAPI_GRO_CB(p)->flush = 0;
+	}
+
+	switch (dev_gro_receive(napi, skb)) {
+	case -1:
+		return netif_receive_skb(skb);
+
+	case 1:
+		kfree_skb(skb);
+		break;
+	}
+
+	return NET_RX_SUCCESS;
+
+drop:
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+EXPORT_SYMBOL(vlan_gro_receive);
+
+int vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
+		   unsigned int vlan_tci, struct napi_gro_fraginfo *info)
+{
+	struct sk_buff *skb = napi_fraginfo_skb(napi, info);
+	int err = NET_RX_DROP;
+
+	if (!skb)
+		goto out;
+
+	if (skb_bond_should_drop(skb))
+		goto reuse;
+
+	skb->vlan_tci = vlan_tci;
+	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
+
+	if (!skb->dev)
+		goto reuse;
+
+	err = NET_RX_SUCCESS;
+
+	switch (dev_gro_receive(napi, skb)) {
+	case -1:
+		return netif_receive_skb(skb);
+
+	case 0:
+		goto out;
+	}
+
+reuse:
+	napi_reuse_skb(napi, skb);
+
+out:
+	return err;
+}
+EXPORT_SYMBOL(vlan_gro_frags);

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
