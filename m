From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [2/2] gro: Add page frag support
Date: Fri, 2 Jan 2009 15:20:11 +1100
Message-ID: <20090102042011.GA20920@gondor.apana.org.au>
References: <20081226225157.GA22866@gondor.apana.org.au> <20081229122445.GA11161@gondor.apana.org.au> <20081229.230703.265458431.davem@davemloft.net> <20081230100705.GA31741@gondor.apana.org.au> <20081230100819.GA31787@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.62.148.172] ([64.62.148.172]:38469 "EHLO arnor.apana.org.au"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750911AbZABEU5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Jan 2009 23:20:57 -0500
Content-Disposition: inline
In-Reply-To: <20081230100819.GA31787@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

Here's an updated version with a redundant blank line removed.

gro: Add page frag support

This patch allows GRO to merge page frags (skb_shinfo(skb)->frags)
in one skb, rather than using the less efficient frag_list.

It also adds a new interface, napi_gro_frags to allow drivers
to inject page frags directly into the stack without allocating
an skb.  This is intended to be the GRO equivalent for LRO's
lro_receive_frags interface.

The existing GSO interface can already handle page frags with
or without an appended frag_list so nothing needs to be changed
there.

The merging itself is rather simple.  We store any new frag entries
after the last existing entry, without checking whether the first
new entry can be merged with the last existing entry.  Making this
check would actually be easy but since no existing driver can
produce contiguous frags anyway it would just be mental masturbation.

If the total number of entries would exceed the capacity of a
single skb, we simply resort to using frag_list as we do now.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 41e1224..c28bbba 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -313,10 +313,11 @@ struct napi_struct {
 #ifdef CONFIG_NETPOLL
 	spinlock_t		poll_lock;
 	int			poll_owner;
-	struct net_device	*dev;
 #endif
+	struct net_device	*dev;
 	struct list_head	dev_list;
 	struct sk_buff		*gro_list;
+	struct sk_buff		*skb;
 };
 
 enum
@@ -990,6 +991,9 @@ struct napi_gro_cb {
 
 	/* Number of segments aggregated. */
 	int count;
+
+	/* Free the skb? */
+	int free;
 };
 
 #define NAPI_GRO_CB(skb) ((struct napi_gro_cb *)(skb)->cb)
@@ -1011,6 +1015,14 @@ struct packet_type {
 	struct list_head	list;
 };
 
+struct napi_gro_fraginfo {
+	skb_frag_t frags[MAX_SKB_FRAGS];
+	unsigned int nr_frags;
+	unsigned int ip_summed;
+	unsigned int len;
+	__wsum csum;
+};
+
 #include <linux/interrupt.h>
 #include <linux/notifier.h>
 
@@ -1363,6 +1375,8 @@ extern int		netif_receive_skb(struct sk_buff *skb);
 extern void		napi_gro_flush(struct napi_struct *napi);
 extern int		napi_gro_receive(struct napi_struct *napi,
 					 struct sk_buff *skb);
+extern int		napi_gro_frags(struct napi_struct *napi,
+				       struct napi_gro_fraginfo *info);
 extern void		netif_nit_deliver(struct sk_buff *skb);
 extern int		dev_valid_name(const char *name);
 extern int		dev_ioctl(struct net *net, unsigned int cmd, void __user *);
diff --git a/net/core/dev.c b/net/core/dev.c
index 67a6ff4..18be66b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -132,6 +132,9 @@
 /* Instead of increasing this, you should create a hash table. */
 #define MAX_GRO_SKBS 8
 
+/* This should be increased if a protocol with a bigger head is added. */
+#define GRO_MAX_HEAD (MAX_HEADER + 128)
+
 /*
  *	The list of packet types we will receive (as opposed to discard)
  *	and the routines to invoke.
@@ -2345,7 +2348,7 @@ static int napi_gro_complete(struct sk_buff *skb)
 	struct list_head *head = &ptype_base[ntohs(type) & PTYPE_HASH_MASK];
 	int err = -ENOENT;
 
-	if (!skb_shinfo(skb)->frag_list)
+	if (NAPI_GRO_CB(skb)->count == 1)
 		goto out;
 
 	rcu_read_lock();
@@ -2384,7 +2387,7 @@ void napi_gro_flush(struct napi_struct *napi)
 }
 EXPORT_SYMBOL(napi_gro_flush);
 
-int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
+static int __napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
 	struct sk_buff **pp = NULL;
 	struct packet_type *ptype;
@@ -2393,6 +2396,7 @@ int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	int count = 0;
 	int same_flow;
 	int mac_len;
+	int free;
 
 	if (!(skb->dev->features & NETIF_F_GRO))
 		goto normal;
@@ -2409,6 +2413,7 @@ int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 		skb->mac_len = mac_len;
 		NAPI_GRO_CB(skb)->same_flow = 0;
 		NAPI_GRO_CB(skb)->flush = 0;
+		NAPI_GRO_CB(skb)->free = 0;
 
 		for (p = napi->gro_list; p; p = p->next) {
 			count++;
@@ -2428,6 +2433,7 @@ int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 		goto normal;
 
 	same_flow = NAPI_GRO_CB(skb)->same_flow;
+	free = NAPI_GRO_CB(skb)->free;
 
 	if (pp) {
 		struct sk_buff *nskb = *pp;
@@ -2452,13 +2458,86 @@ int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	napi->gro_list = skb;
 
 ok:
-	return NET_RX_SUCCESS;
+	return free;
 
 normal:
-	return netif_receive_skb(skb);
+	return -1;
+}
+
+int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
+{
+	switch (__napi_gro_receive(napi, skb)) {
+	case -1:
+		return netif_receive_skb(skb);
+
+	case 1:
+		kfree_skb(skb);
+		break;
+	}
+
+	return NET_RX_SUCCESS;
 }
 EXPORT_SYMBOL(napi_gro_receive);
 
+int napi_gro_frags(struct napi_struct *napi, struct napi_gro_fraginfo *info)
+{
+	struct net_device *dev = napi->dev;
+	struct sk_buff *skb = napi->skb;
+	int err = NET_RX_DROP;
+
+	napi->skb = NULL;
+
+	if (!skb) {
+		skb = netdev_alloc_skb(dev, GRO_MAX_HEAD + NET_IP_ALIGN);
+		if (!skb)
+			goto out;
+
+		skb_reserve(skb, NET_IP_ALIGN);
+	}
+
+	BUG_ON(info->nr_frags > MAX_SKB_FRAGS);
+	skb_shinfo(skb)->nr_frags = info->nr_frags;
+	memcpy(skb_shinfo(skb)->frags, info->frags, sizeof(info->frags));
+
+	skb->data_len = info->len;
+	skb->len += info->len;
+	skb->truesize += info->len;
+
+	if (!pskb_may_pull(skb, ETH_HLEN))
+		goto reuse;
+
+	err = NET_RX_SUCCESS;
+
+	skb->protocol = eth_type_trans(skb, dev);
+
+	skb->ip_summed = info->ip_summed;
+	skb->csum = info->csum;
+
+	switch (__napi_gro_receive(napi, skb)) {
+	case -1:
+		return netif_receive_skb(skb);
+
+	case 0:
+		goto out;
+	}
+
+reuse:
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
+
+out:
+	return err;
+}
+EXPORT_SYMBOL(napi_gro_frags);
+
 static int process_backlog(struct napi_struct *napi, int quota)
 {
 	int work = 0;
@@ -2537,11 +2616,12 @@ void netif_napi_add(struct net_device *dev, struct napi_struct *napi,
 {
 	INIT_LIST_HEAD(&napi->poll_list);
 	napi->gro_list = NULL;
+	napi->skb = NULL;
 	napi->poll = poll;
 	napi->weight = weight;
 	list_add(&napi->dev_list, &dev->napi_list);
-#ifdef CONFIG_NETPOLL
 	napi->dev = dev;
+#ifdef CONFIG_NETPOLL
 	spin_lock_init(&napi->poll_lock);
 	napi->poll_owner = -1;
 #endif
@@ -2554,6 +2634,7 @@ void netif_napi_del(struct napi_struct *napi)
 	struct sk_buff *skb, *next;
 
 	list_del_init(&napi->dev_list);
+	kfree(napi->skb);
 
 	for (skb = napi->gro_list; skb; skb = next) {
 		next = skb->next;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 3aafb10..5110b35 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2594,6 +2594,17 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 
 	if (skb_shinfo(p)->frag_list)
 		goto merge;
+	else if (!skb_headlen(p) && !skb_headlen(skb) &&
+		 skb_shinfo(p)->nr_frags + skb_shinfo(skb)->nr_frags <
+		 MAX_SKB_FRAGS) {
+		memcpy(skb_shinfo(p)->frags + skb_shinfo(p)->nr_frags,
+		       skb_shinfo(skb)->frags,
+		       skb_shinfo(skb)->nr_frags * sizeof(skb_frag_t));
+
+		skb_shinfo(p)->nr_frags += skb_shinfo(skb)->nr_frags;
+		NAPI_GRO_CB(skb)->free = 1;
+		goto done;
+	}
 
 	headroom = skb_headroom(p);
 	nskb = netdev_alloc_skb(p->dev, headroom);
@@ -2628,11 +2639,12 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 	p = nskb;
 
 merge:
-	NAPI_GRO_CB(p)->count++;
 	p->prev->next = skb;
 	p->prev = skb;
 	skb_header_release(skb);
 
+done:
+	NAPI_GRO_CB(p)->count++;
 	p->data_len += skb->len;
 	p->truesize += skb->len;
 	p->len += skb->len;

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
