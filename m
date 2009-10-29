From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 2/4] gro: Change all receive functions to return GRO result
	codes
Date: Thu, 29 Oct 2009 17:18:15 +0000
Message-ID: <1256836695.2827.71.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:41037 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756424AbZJ2RSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 13:18:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will allow drivers to adjust their receive path dynamically
based on whether GRO is being applied successfully.

Currently all in-tree callers ignore the return values of these
functions and do not need to be changed.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/if_vlan.h   |   25 ++++++++++++++-----------
 include/linux/netdevice.h |    8 ++++----
 net/8021q/vlan_core.c     |   16 +++++++++-------
 net/core/dev.c            |   38 +++++++++++++++-----------------------
 4 files changed, 42 insertions(+), 45 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index 7ff9af1..5be7680 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -115,10 +115,12 @@ extern u16 vlan_dev_vlan_id(const struct net_device *dev);
 extern int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 			     u16 vlan_tci, int polling);
 extern int vlan_hwaccel_do_receive(struct sk_buff *skb);
-extern int vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
-			    unsigned int vlan_tci, struct sk_buff *skb);
-extern int vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
-			  unsigned int vlan_tci);
+extern gro_result_t
+vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
+		 unsigned int vlan_tci, struct sk_buff *skb);
+extern gro_result_t
+vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
+	       unsigned int vlan_tci);
 
 #else
 static inline struct net_device *vlan_dev_real_dev(const struct net_device *dev)
@@ -145,17 +147,18 @@ static inline int vlan_hwaccel_do_receive(struct sk_buff *skb)
 	return 0;
 }
 
-static inline int vlan_gro_receive(struct napi_struct *napi,
-				   struct vlan_group *grp,
-				   unsigned int vlan_tci, struct sk_buff *skb)
+static inline gro_result_t
+vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
+		 unsigned int vlan_tci, struct sk_buff *skb)
 {
-	return NET_RX_DROP;
+	return GRO_DROP;
 }
 
-static inline int vlan_gro_frags(struct napi_struct *napi,
-				 struct vlan_group *grp, unsigned int vlan_tci)
+static inline gro_result_t
+vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
+	       unsigned int vlan_tci)
 {
-	return NET_RX_DROP;
+	return GRO_DROP;
 }
 #endif
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 9fdf48e..218a0f6 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1470,17 +1470,17 @@ extern int		netif_receive_skb(struct sk_buff *skb);
 extern void		napi_gro_flush(struct napi_struct *napi);
 extern gro_result_t	dev_gro_receive(struct napi_struct *napi,
 					struct sk_buff *skb);
-extern int		napi_skb_finish(gro_result_t ret, struct sk_buff *skb);
-extern int		napi_gro_receive(struct napi_struct *napi,
+extern gro_result_t	napi_skb_finish(gro_result_t ret, struct sk_buff *skb);
+extern gro_result_t	napi_gro_receive(struct napi_struct *napi,
 					 struct sk_buff *skb);
 extern void		napi_reuse_skb(struct napi_struct *napi,
 				       struct sk_buff *skb);
 extern struct sk_buff *	napi_get_frags(struct napi_struct *napi);
-extern int		napi_frags_finish(struct napi_struct *napi,
+extern gro_result_t	napi_frags_finish(struct napi_struct *napi,
 					  struct sk_buff *skb,
 					  gro_result_t ret);
 extern struct sk_buff *	napi_frags_skb(struct napi_struct *napi);
-extern int		napi_gro_frags(struct napi_struct *napi);
+extern gro_result_t	napi_gro_frags(struct napi_struct *napi);
 
 static inline void napi_free_frags(struct napi_struct *napi)
 {
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 47a80d6..8d5ca2a 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -102,11 +102,12 @@ drop:
 	return GRO_DROP;
 }
 
-int vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
-		     unsigned int vlan_tci, struct sk_buff *skb)
+gro_result_t vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
+			      unsigned int vlan_tci, struct sk_buff *skb)
 {
 	if (netpoll_rx_on(skb))
-		return vlan_hwaccel_receive_skb(skb, grp, vlan_tci);
+		return vlan_hwaccel_receive_skb(skb, grp, vlan_tci)
+			? GRO_DROP : GRO_NORMAL;
 
 	skb_gro_reset_offset(skb);
 
@@ -114,17 +115,18 @@ int vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
 }
 EXPORT_SYMBOL(vlan_gro_receive);
 
-int vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
-		   unsigned int vlan_tci)
+gro_result_t vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
+			    unsigned int vlan_tci)
 {
 	struct sk_buff *skb = napi_frags_skb(napi);
 
 	if (!skb)
-		return NET_RX_DROP;
+		return GRO_DROP;
 
 	if (netpoll_rx_on(skb)) {
 		skb->protocol = eth_type_trans(skb, skb->dev);
-		return vlan_hwaccel_receive_skb(skb, grp, vlan_tci);
+		return vlan_hwaccel_receive_skb(skb, grp, vlan_tci)
+			? GRO_DROP : GRO_NORMAL;
 	}
 
 	return napi_frags_finish(napi, skb,
diff --git a/net/core/dev.c b/net/core/dev.c
index 421dc93..f1bf49f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2549,24 +2549,21 @@ __napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	return dev_gro_receive(napi, skb);
 }
 
-int napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
+gro_result_t napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
 {
-	int err = NET_RX_SUCCESS;
-
 	switch (ret) {
 	case GRO_NORMAL:
-		return netif_receive_skb(skb);
+		if (netif_receive_skb(skb))
+			ret = GRO_DROP;
+		break;
 
 	case GRO_DROP:
-		err = NET_RX_DROP;
-		/* fall through */
-
 	case GRO_MERGED_FREE:
 		kfree_skb(skb);
 		break;
 	}
 
-	return err;
+	return ret;
 }
 EXPORT_SYMBOL(napi_skb_finish);
 
@@ -2586,7 +2583,7 @@ void skb_gro_reset_offset(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(skb_gro_reset_offset);
 
-int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
+gro_result_t napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
 	skb_gro_reset_offset(skb);
 
@@ -2616,32 +2613,27 @@ struct sk_buff *napi_get_frags(struct napi_struct *napi)
 }
 EXPORT_SYMBOL(napi_get_frags);
 
-int napi_frags_finish(struct napi_struct *napi, struct sk_buff *skb,
-		      gro_result_t ret)
+gro_result_t napi_frags_finish(struct napi_struct *napi, struct sk_buff *skb,
+			       gro_result_t ret)
 {
-	int err = NET_RX_SUCCESS;
-
 	switch (ret) {
 	case GRO_NORMAL:
 	case GRO_HELD:
 		skb->protocol = eth_type_trans(skb, napi->dev);
 
-		if (ret == GRO_NORMAL)
-			return netif_receive_skb(skb);
-
-		skb_gro_pull(skb, -ETH_HLEN);
+		if (ret == GRO_HELD)
+			skb_gro_pull(skb, -ETH_HLEN);
+		else if (netif_receive_skb(skb))
+			ret = GRO_DROP;
 		break;
 
 	case GRO_DROP:
-		err = NET_RX_DROP;
-		/* fall through */
-
 	case GRO_MERGED_FREE:
 		napi_reuse_skb(napi, skb);
 		break;
 	}
 
-	return err;
+	return ret;
 }
 EXPORT_SYMBOL(napi_frags_finish);
 
@@ -2682,12 +2674,12 @@ out:
 }
 EXPORT_SYMBOL(napi_frags_skb);
 
-int napi_gro_frags(struct napi_struct *napi)
+gro_result_t napi_gro_frags(struct napi_struct *napi)
 {
 	struct sk_buff *skb = napi_frags_skb(napi);
 
 	if (!skb)
-		return NET_RX_DROP;
+		return GRO_DROP;
 
 	return napi_frags_finish(napi, skb, __napi_gro_receive(napi, skb));
 }

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

