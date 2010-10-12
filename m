From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net:  allocate skbs on local node
Date: Tue, 12 Oct 2010 07:05:25 +0200
Message-ID: <1286859925.30423.184.camel@edumazet-laptop>
References: <1286838210.30423.128.camel@edumazet-laptop>
	 <1286839363.30423.130.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Christoph Hellwig <hch@lst.de>,
	Christoph Lameter <cl@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:60901 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999Ab0JLFFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 01:05:47 -0400
Received: by wwj40 with SMTP id 40so4570403wwj.1
        for <netdev@vger.kernel.org>; Mon, 11 Oct 2010 22:05:46 -0700 (PDT)
In-Reply-To: <1286839363.30423.130.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 12 octobre 2010 =C3=A0 01:22 +0200, Eric Dumazet a =C3=A9crit =
:
> Le mardi 12 octobre 2010 =C3=A0 01:03 +0200, Eric Dumazet a =C3=A9cri=
t :
> >=20
> > For multi queue devices, it makes more sense to allocate skb on loc=
al
> > node of the cpu handling RX interrupts. This allow each cpu to
> > manipulate its own slub/slab queues/structures without doing expens=
ive
> > cross-node business.
> >=20
> > For non multi queue devices, IRQ affinity should be set so that a c=
pu
> > close to the device services interrupts. Even if not set, using
> > dev_alloc_skb() is faster.
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Or maybe revert :
>=20
> commit b30973f877fea1a3fb84e05599890fcc082a88e5
> Author: Christoph Hellwig <hch@lst.de>
> Date:   Wed Dec 6 20:32:36 2006 -0800
>=20
>     [PATCH] node-aware skb allocation
>    =20
>     Node-aware allocation of skbs for the receive path.
>    =20
>     Details:
>    =20
>       - __alloc_skb gets a new node argument and cals the node-aware
>         slab functions with it.
>       - netdev_alloc_skb passed the node number it gets from dev_to_n=
ode
>         to it, everyone else passes -1 (any node)
>    =20
>     Signed-off-by: Christoph Hellwig <hch@lst.de>
>     Cc: Christoph Lameter <clameter@engr.sgi.com>
>     Cc: "David S. Miller" <davem@davemloft.net>
>     Signed-off-by: Andrew Morton <akpm@osdl.org>
>=20
>=20
> Apparently, only Christoph and Andrew signed it.
>=20
>=20

[PATCH net-next] net: allocate skbs on local node

commit b30973f877 (node-aware skb allocation) spread a wrong habit of
allocating net drivers skbs on a given memory node : The one closest to
the NIC hardware. This is wrong because as soon as we try to scale
network stack, we need to use many cpus to handle traffic and hit
slub/slab management on cross-node allocations/frees when these cpus
have to alloc/free skbs bound to a central node.

skb allocated in RX path are ephemeral, they have a very short
lifetime : Extra cost to maintain NUMA affinity is too expensive. What
appeared as a nice idea four years ago is in fact a bad one.

In 2010, NIC hardwares are multiqueue, or we use RPS to spread the load=
,
and two 10Gb NIC might deliver more than 28 million packets per second,
needing all the available cpus.

Cost of cross-node handling in network and vm stacks outperforms the
small benefit hardware had when doing its DMA transfert in its 'local'
memory node at RX time. Even trying to differentiate the two allocation=
s
done for one skb (the sk_buff on local node, the data part on NIC
hardware node) is not enough to bring good performance.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/skbuff.h |   20 ++++++++++++++++----
 net/core/skbuff.c      |   13 +------------
 2 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 0b53c43..05a358f 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -496,13 +496,13 @@ extern struct sk_buff *__alloc_skb(unsigned int s=
ize,
 static inline struct sk_buff *alloc_skb(unsigned int size,
 					gfp_t priority)
 {
-	return __alloc_skb(size, priority, 0, -1);
+	return __alloc_skb(size, priority, 0, NUMA_NO_NODE);
 }
=20
 static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 					       gfp_t priority)
 {
-	return __alloc_skb(size, priority, 1, -1);
+	return __alloc_skb(size, priority, 1, NUMA_NO_NODE);
 }
=20
 extern bool skb_recycle_check(struct sk_buff *skb, int skb_size);
@@ -1563,13 +1563,25 @@ static inline struct sk_buff *netdev_alloc_skb_=
ip_align(struct net_device *dev,
 	return skb;
 }
=20
-extern struct page *__netdev_alloc_page(struct net_device *dev, gfp_t =
gfp_mask);
+/**
+ *	__netdev_alloc_page - allocate a page for ps-rx on a specific devic=
e
+ *	@dev: network device to receive on
+ *	@gfp_mask: alloc_pages_node mask
+ *
+ * 	Allocate a new page. dev currently unused.
+ *
+ * 	%NULL is returned if there is no free memory.
+ */
+static inline struct page *__netdev_alloc_page(struct net_device *dev,=
 gfp_t gfp_mask)
+{
+	return alloc_pages_node(NUMA_NO_NODE, gfp_mask, 0);
+}
=20
 /**
  *	netdev_alloc_page - allocate a page for ps-rx on a specific device
  *	@dev: network device to receive on
  *
- * 	Allocate a new page node local to the specified device.
+ * 	Allocate a new page. dev currently unused.
  *
  * 	%NULL is returned if there is no free memory.
  */
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 752c197..4e8b82e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -247,10 +247,9 @@ EXPORT_SYMBOL(__alloc_skb);
 struct sk_buff *__netdev_alloc_skb(struct net_device *dev,
 		unsigned int length, gfp_t gfp_mask)
 {
-	int node =3D dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
 	struct sk_buff *skb;
=20
-	skb =3D __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, node);
+	skb =3D __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, NUMA_NO_NODE);
 	if (likely(skb)) {
 		skb_reserve(skb, NET_SKB_PAD);
 		skb->dev =3D dev;
@@ -259,16 +258,6 @@ struct sk_buff *__netdev_alloc_skb(struct net_devi=
ce *dev,
 }
 EXPORT_SYMBOL(__netdev_alloc_skb);
=20
-struct page *__netdev_alloc_page(struct net_device *dev, gfp_t gfp_mas=
k)
-{
-	int node =3D dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
-	struct page *page;
-
-	page =3D alloc_pages_node(node, gfp_mask, 0);
-	return page;
-}
-EXPORT_SYMBOL(__netdev_alloc_page);
-
 void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page, in=
t off,
 		int size)
 {


