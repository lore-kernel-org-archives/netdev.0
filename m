From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [UNTESTED] gro: Add page frag support
Date: Sat, 27 Dec 2008 09:51:57 +1100
Message-ID: <20081226225157.GA22866@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:33432 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751895AbYLZWwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 17:52:01 -0500
Received: from gondolin.me.apana.org.au ([192.168.0.6])
	by arnor.apana.org.au with esmtp (Exim 4.63 #1 (Debian))
	id 1LGLXD-0001Sy-1u
	for <netdev@vger.kernel.org>; Sat, 27 Dec 2008 09:51:59 +1100
Received: from herbert by gondolin.me.apana.org.au with local (Exim 4.69)
	(envelope-from <herbert@gondor.apana.org.au>)
	id 1LGLXC-0005x8-2C
	for netdev@vger.kernel.org; Sat, 27 Dec 2008 09:51:58 +1100
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

This patch is totally untested so please don't apply it.  I need
to hack the e1000e driver to not make skbs before I can test it.

But maybe you guys can spot a few holes in it before I finish
e1000e :)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 41e1224..b31367a 100644
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
@@ -1363,6 +1367,9 @@ extern int		netif_receive_skb(struct sk_buff *skb);
 extern void		napi_gro_flush(struct napi_struct *napi);
 extern int		napi_gro_receive(struct napi_struct *napi,
 					 struct sk_buff *skb);
+extern int		napi_gro_pages(struct napi_struct *napi,
+				       struct skb_shared_info *shinfo,
+				       unsigned int len);
 extern void		netif_nit_deliver(struct sk_buff *skb);
 extern int		dev_valid_name(const char *name);
 extern int		dev_ioctl(struct net *net, unsigned int cmd, void __user *);
diff --git a/net/core/dev.c b/net/core/dev.c
index 9d60941..47a5884 100644
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
@@ -2383,7 +2386,7 @@ void napi_gro_flush(struct napi_struct *napi)
 }
 EXPORT_SYMBOL(napi_gro_flush);
 
-int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
+static int __napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 {
 	struct sk_buff **pp = NULL;
 	struct packet_type *ptype;
@@ -2392,6 +2395,7 @@ int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 	int count = 0;
 	int same_flow;
 	int mac_len;
+	int free;
 
 	if (!(skb->dev->features & NETIF_F_GRO))
 		goto normal;
@@ -2408,6 +2412,7 @@ int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 		skb->mac_len = mac_len;
 		NAPI_GRO_CB(skb)->same_flow = 0;
 		NAPI_GRO_CB(skb)->flush = 0;
+		NAPI_GRO_CB(skb)->free = 0;
 
 		for (p = napi->gro_list; p; p = p->next) {
 			count++;
@@ -2427,6 +2432,7 @@ int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
 		goto normal;
 
 	same_flow = NAPI_GRO_CB(skb)->same_flow;
+	free = NAPI_GRO_CB(skb)->free;
 
 	if (pp) {
 		struct sk_buff *nskb = *pp;
@@ -2450,13 +2456,76 @@ int napi_gro_receive(struct napi_struct *napi, struct sk_buff *skb)
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
+	return __napi_gro_receive(napi, skb) < 0 ?
+	       netif_receive_skb(skb) : NET_RX_SUCCESS;
 }
 EXPORT_SYMBOL(napi_gro_receive);
 
+int napi_gro_pages(struct napi_struct *napi, struct skb_shared_info *shinfo,
+		   unsigned int len)
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
+	BUG_ON(shinfo->nr_frags > MAX_SKB_FRAGS);
+	memcpy(skb_shinfo(skb)->frags, shinfo->frags, sizeof(shinfo->frags));
+	skb_shinfo(skb)->nr_frags = shinfo->nr_frags;
+
+	skb->data_len = len;
+	skb->len += len;
+	skb->truesize += len;
+
+	if (!pskb_may_pull(skb, ETH_HLEN))
+		goto reuse;
+
+	skb->protocol = eth_type_trans(skb, dev);
+
+	switch (__napi_gro_receive(napi, skb)) {
+	case -1:
+		return netif_receive_skb(skb);
+
+	case 0:
+		goto out;
+	}
+
+	err = NET_RX_SUCCESS;
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
+EXPORT_SYMBOL(napi_gro_pages);
+
 static int process_backlog(struct napi_struct *napi, int quota)
 {
 	int work = 0;
@@ -2535,11 +2604,12 @@ void netif_napi_add(struct net_device *dev, struct napi_struct *napi,
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
@@ -2552,6 +2622,7 @@ void netif_napi_del(struct napi_struct *napi)
 	struct sk_buff *skb, *next;
 
 	list_del(&napi->dev_list);
+	kfree(napi->skb);
 
 	for (skb = napi->gro_list; skb; skb = next) {
 		next = skb->next;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index b8d0abb..5eda8a0 100644
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
@@ -2627,11 +2638,12 @@ int skb_gro_receive(struct sk_buff **head, struct sk_buff *skb)
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

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
