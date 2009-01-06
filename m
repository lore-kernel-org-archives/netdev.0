From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [1/2] gro: Add internal interfaces for VLAN
Date: Tue, 6 Jan 2009 18:11:42 +1100
Message-ID: <20090106071142.GA27281@gondor.apana.org.au>
References: <20090102054714.GA23106@gondor.apana.org.au> <20090102054921.GA23174@gondor.apana.org.au> <20090104.225727.236263263.davem@davemloft.net> <20090105094730.GA15756@gondor.apana.org.au> <20090105095131.GA15851@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:38865 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751444AbZAFHLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 02:11:47 -0500
Content-Disposition: inline
In-Reply-To: <20090105095131.GA15851@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 05, 2009 at 08:51:31PM +1100, Herbert Xu wrote:
> 
> Well to be honest the hack won't disappear completely but at
> least it will be hidden in netif_nit_deliver :)

On second thought, it looks like this doesn't really change much
since VLAN is the only user of netif_nit_deliver.  So I'm going
to stick with this hack for now.

Anyway, after testing and debugging, here is the final version
of the patches.

gro: Add internal interfaces for VLAN

Previously GRO's only entry point from the outside is through
napi_gro_receive and napi_gro_frags.  These interfaces are for
device drivers.

This patch rearranges things to provide a new set of interfaces
for VLANs.  These interfaces are for internal use only.  The
VLAN code itself can then provide a set of entry points for
device drivers.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

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
index 18be66b..865588f 100644
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
+			    memcmp(skb_mac_header(p), skb_mac_header(skb),
+				   mac_len))
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

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
