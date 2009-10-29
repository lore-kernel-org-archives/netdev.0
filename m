From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCHv2] gro: Name the GRO result enumeration type
Date: Thu, 29 Oct 2009 18:26:15 +0000
Message-ID: <1256840775.2827.83.camel@achroite>
References: <1256840061.2827.80.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:45452 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751835AbZJ2S0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 14:26:12 -0400
In-Reply-To: <1256840061.2827.80.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This clarifies which return and parameter types are GRO result codes
and not RX result codes.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This replaces the previous patch 1/4 and avoids introducing compiler
warnings.  The original patches 2-4 will still apply on top of it.

Ben.

 include/linux/netdevice.h |   10 ++++++----
 net/8021q/vlan_core.c     |    5 +++--
 net/core/dev.c            |   19 ++++++++++++++-----
 3 files changed, 23 insertions(+), 11 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 8380009..9fdf48e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -348,13 +348,14 @@ enum
 	NAPI_STATE_NPSVC,	/* Netpoll - don't dequeue from poll_list */
 };
 
-enum {
+enum gro_result {
 	GRO_MERGED,
 	GRO_MERGED_FREE,
 	GRO_HELD,
 	GRO_NORMAL,
 	GRO_DROP,
 };
+typedef enum gro_result gro_result_t;
 
 extern void __napi_schedule(struct napi_struct *n);
 
@@ -1467,16 +1468,17 @@ extern int		netif_rx_ni(struct sk_buff *skb);
 #define HAVE_NETIF_RECEIVE_SKB 1
 extern int		netif_receive_skb(struct sk_buff *skb);
 extern void		napi_gro_flush(struct napi_struct *napi);
-extern int		dev_gro_receive(struct napi_struct *napi,
+extern gro_result_t	dev_gro_receive(struct napi_struct *napi,
 					struct sk_buff *skb);
-extern int		napi_skb_finish(int ret, struct sk_buff *skb);
+extern int		napi_skb_finish(gro_result_t ret, struct sk_buff *skb);
 extern int		napi_gro_receive(struct napi_struct *napi,
 					 struct sk_buff *skb);
 extern void		napi_reuse_skb(struct napi_struct *napi,
 				       struct sk_buff *skb);
 extern struct sk_buff *	napi_get_frags(struct napi_struct *napi);
 extern int		napi_frags_finish(struct napi_struct *napi,
-					  struct sk_buff *skb, int ret);
+					  struct sk_buff *skb,
+					  gro_result_t ret);
 extern struct sk_buff *	napi_frags_skb(struct napi_struct *napi);
 extern int		napi_gro_frags(struct napi_struct *napi);
 
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 7f7de1a..47a80d6 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -74,8 +74,9 @@ u16 vlan_dev_vlan_id(const struct net_device *dev)
 }
 EXPORT_SYMBOL(vlan_dev_vlan_id);
 
-static int vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
-			   unsigned int vlan_tci, struct sk_buff *skb)
+static gro_result_t
+vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
+		unsigned int vlan_tci, struct sk_buff *skb)
 {
 	struct sk_buff *p;
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 28b0b9e..be32051 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2439,7 +2439,7 @@ void napi_gro_flush(struct napi_struct *napi)
 }
 EXPORT_SYMBOL(napi_gro_flush);
 
-int dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
+enum gro_result dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
 	struct sk_buff **pp = NULL;
 	struct packet_type *ptype;
@@ -2447,7 +2447,7 @@ int dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	struct list_head *head = &ptype_base[ntohs(type) & PTYPE_HASH_MASK];
 	int same_flow;
 	int mac_len;
-	int ret;
+	enum gro_result ret;
 
 	if (!(skb->dev->features & NETIF_F_GRO))
 		goto normal;
@@ -2531,7 +2531,8 @@ normal:
 }
 EXPORT_SYMBOL(dev_gro_receive);
 
-static int __napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
+static gro_result_t
+__napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
 	struct sk_buff *p;
 
@@ -2548,7 +2549,7 @@ static int __napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	return dev_gro_receive(napi, skb);
 }
 
-int napi_skb_finish(int ret, struct sk_buff *skb)
+int napi_skb_finish(gro_result_t ret, struct sk_buff *skb)
 {
 	int err = NET_RX_SUCCESS;
 
@@ -2563,6 +2564,10 @@ int napi_skb_finish(int ret, struct sk_buff *skb)
 	case GRO_MERGED_FREE:
 		kfree_skb(skb);
 		break;
+
+	case GRO_HELD:
+	case GRO_MERGED:
+		break;
 	}
 
 	return err;
@@ -2615,7 +2620,8 @@ struct sk_buff *napi_get_frags(struct napi_struct *napi)
 }
 EXPORT_SYMBOL(napi_get_frags);
 
-int napi_frags_finish(struct napi_struct *napi, struct sk_buff *skb, int ret)
+int napi_frags_finish(struct napi_struct *napi, struct sk_buff *skb,
+		      gro_result_t ret)
 {
 	int err = NET_RX_SUCCESS;
 
@@ -2637,6 +2643,9 @@ int napi_frags_finish(struct napi_struct *napi, struct sk_buff *skb, int ret)
 	case GRO_MERGED_FREE:
 		napi_reuse_skb(napi, skb);
 		break;
+
+	case GRO_MERGED:
+		break;
 	}
 
 	return err;

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

