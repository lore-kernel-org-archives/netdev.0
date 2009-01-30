From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/4] gro: Move common completion code into helpers
Date: Fri, 30 Jan 2009 11:19:48 +1100
Message-ID: <E1LSh6q-0000O3-VX@gondolin.me.apana.org.au>
References: <20090130001849.GA1272@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:37712 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755678AbZA3ATv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 19:19:51 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gro: Move common completion code into helpers

Currently VLAN still has a bit of common code handling the aftermath
of GRO that's shared with the common path.  This patch moves them
into shared helpers to reduce code duplication.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/netdevice.h |    3 +
 net/8021q/vlan_core.c     |   39 ++---------------------
 net/core/dev.c            |   76 +++++++++++++++++++++++++++++++---------------
 3 files changed, 59 insertions(+), 59 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f245568..c6b7a25 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1372,12 +1372,15 @@ extern int		netif_receive_skb(struct sk_buff *skb);
 extern void		napi_gro_flush(struct napi_struct *napi);
 extern int		dev_gro_receive(struct napi_struct *napi,
 					struct sk_buff *skb);
+extern int		napi_skb_finish(int ret, struct sk_buff *skb);
 extern int		napi_gro_receive(struct napi_struct *napi,
 					 struct sk_buff *skb);
 extern void		napi_reuse_skb(struct napi_struct *napi,
 				       struct sk_buff *skb);
 extern struct sk_buff *	napi_fraginfo_skb(struct napi_struct *napi,
 					  struct napi_gro_fraginfo *info);
+extern int		napi_frags_finish(struct napi_struct *napi,
+					  struct sk_buff *skb, int ret);
 extern int		napi_gro_frags(struct napi_struct *napi,
 				       struct napi_gro_fraginfo *info);
 extern void		netif_nit_deliver(struct sk_buff *skb);
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 6c13239..e9339d0 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -98,22 +98,7 @@ drop:
 int vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
 		     unsigned int vlan_tci, struct sk_buff *skb)
 {
-	int err = NET_RX_SUCCESS;
-
-	switch (vlan_gro_common(napi, grp, vlan_tci, skb)) {
-	case -1:
-		return netif_receive_skb(skb);
-
-	case 2:
-		err = NET_RX_DROP;
-		/* fall through */
-
-	case 1:
-		kfree_skb(skb);
-		break;
-	}
-
-	return err;
+	return napi_skb_finish(vlan_gro_common(napi, grp, vlan_tci, skb), skb);
 }
 EXPORT_SYMBOL(vlan_gro_receive);
 
@@ -121,27 +106,11 @@ int vlan_gro_frags(struct napi_struct *napi, struct vlan_group *grp,
 		   unsigned int vlan_tci, struct napi_gro_fraginfo *info)
 {
 	struct sk_buff *skb = napi_fraginfo_skb(napi, info);
-	int err = NET_RX_DROP;
 
 	if (!skb)
-		goto out;
-
-	err = NET_RX_SUCCESS;
-
-	switch (vlan_gro_common(napi, grp, vlan_tci, skb)) {
-	case -1:
-		return netif_receive_skb(skb);
-
-	case 2:
-		err = NET_RX_DROP;
-		/* fall through */
-
-	case 1:
-		napi_reuse_skb(napi, skb);
-		break;
-	}
+		return NET_RX_DROP;
 
-out:
-	return err;
+	return napi_frags_finish(napi, skb,
+				 vlan_gro_common(napi, grp, vlan_tci, skb));
 }
 EXPORT_SYMBOL(vlan_gro_frags);
diff --git a/net/core/dev.c b/net/core/dev.c
index 2fb3a00..0b44280 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -135,6 +135,14 @@
 /* This should be increased if a protocol with a bigger head is added. */
 #define GRO_MAX_HEAD (MAX_HEADER + 128)
 
+enum {
+	GRO_MERGED,
+	GRO_MERGED_FREE,
+	GRO_HELD,
+	GRO_NORMAL,
+	GRO_DROP,
+};
+
 /*
  *	The list of packet types we will receive (as opposed to discard)
  *	and the routines to invoke.
@@ -2377,7 +2385,7 @@ int dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	int count = 0;
 	int same_flow;
 	int mac_len;
-	int free;
+	int ret;
 
 	if (!(skb->dev->features & NETIF_F_GRO))
 		goto normal;
@@ -2420,7 +2428,7 @@ int dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 		goto normal;
 
 	same_flow = NAPI_GRO_CB(skb)->same_flow;
-	free = NAPI_GRO_CB(skb)->free;
+	ret = NAPI_GRO_CB(skb)->free ? GRO_MERGED_FREE : GRO_MERGED;
 
 	if (pp) {
 		struct sk_buff *nskb = *pp;
@@ -2443,12 +2451,13 @@ int dev_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	skb_shinfo(skb)->gso_size = skb->len;
 	skb->next = napi->gro_list;
 	napi->gro_list = skb;
+	ret = GRO_HELD;
 
 ok:
-	return free;
+	return ret;
 
 normal:
-	return -1;
+	return GRO_NORMAL;
 }
 EXPORT_SYMBOL(dev_gro_receive);
 
@@ -2464,18 +2473,30 @@ static int __napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	return dev_gro_receive(napi, skb);
 }
 
-int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
+int napi_skb_finish(int ret, struct sk_buff *skb)
 {
-	switch (__napi_gro_receive(napi, skb)) {
-	case -1:
+	int err = NET_RX_SUCCESS;
+
+	switch (ret) {
+	case GRO_NORMAL:
 		return netif_receive_skb(skb);
 
-	case 1:
+	case GRO_DROP:
+		err = NET_RX_DROP;
+		/* fall through */
+
+	case GRO_MERGED_FREE:
 		kfree_skb(skb);
 		break;
 	}
 
-	return NET_RX_SUCCESS;
+	return err;
+}
+EXPORT_SYMBOL(napi_skb_finish);
+
+int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
+{
+	return napi_skb_finish(__napi_gro_receive(napi, skb), skb);
 }
 EXPORT_SYMBOL(napi_gro_receive);
 
@@ -2528,29 +2549,36 @@ out:
 }
 EXPORT_SYMBOL(napi_fraginfo_skb);
 
-int napi_gro_frags(struct napi_struct *napi, struct napi_gro_fraginfo *info)
+int napi_frags_finish(struct napi_struct *napi, struct sk_buff *skb, int ret)
 {
-	struct sk_buff *skb = napi_fraginfo_skb(napi, info);
-	int err = NET_RX_DROP;
-
-	if (!skb)
-		goto out;
+	int err = NET_RX_SUCCESS;
 
-	err = NET_RX_SUCCESS;
-
-	switch (__napi_gro_receive(napi, skb)) {
-	case -1:
+	switch (ret) {
+	case GRO_NORMAL:
 		return netif_receive_skb(skb);
 
-	case 0:
-		goto out;
-	}
+	case GRO_DROP:
+		err = NET_RX_DROP;
+		/* fall through */
 
-	napi_reuse_skb(napi, skb);
+	case GRO_MERGED_FREE:
+		napi_reuse_skb(napi, skb);
+		break;
+	}
 
-out:
 	return err;
 }
+EXPORT_SYMBOL(napi_frags_finish);
+
+int napi_gro_frags(struct napi_struct *napi, struct napi_gro_fraginfo *info)
+{
+	struct sk_buff *skb = napi_fraginfo_skb(napi, info);
+
+	if (!skb)
+		return NET_RX_DROP;
+
+	return napi_frags_finish(napi, skb, __napi_gro_receive(napi, skb));
+}
 EXPORT_SYMBOL(napi_gro_frags);
 
 static int process_backlog(struct napi_struct *napi, int quota)
