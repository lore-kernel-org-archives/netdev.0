From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: allocate skbs on local node
Date: Thu, 14 Oct 2010 18:05:52 +0200
Message-ID: <1287072352.2712.84.camel@edumazet-laptop>
References: <1286838210.30423.128.camel@edumazet-laptop>
	 <1286839363.30423.130.camel@edumazet-laptop>
	 <1286859925.30423.184.camel@edumazet-laptop>
	 <20101011230322.f0f6dd47.akpm@linux-foundation.org>
	 <AANLkTin8FczYpPvi79w7iuKOZz3uZtYFfTPitAgQFxzD@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Christoph Hellwig <hch@lst.de>,
	Christoph Lameter <cl@linux-foundation.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58525 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752038Ab0JNQGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 12:06:00 -0400
Received: by wyb28 with SMTP id 28so2264381wyb.19
        for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 09:05:59 -0700 (PDT)
In-Reply-To: <AANLkTin8FczYpPvi79w7iuKOZz3uZtYFfTPitAgQFxzD@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 14 octobre 2010 =C3=A0 08:31 -0700, Tom Herbert a =C3=A9crit :
> > This is all conspicuously hand-wavy and unquantified.  (IOW: prove =
it!)
> >
> > The mooted effects should be tested for on both slab and slub, I
> > suggest.  They're pretty different beasts.
> > --
>=20
> Some results running netper TCP_RR test with 200 instances, 1 byte
> request and response on 16 core AMD using bnx2x with one 16 queues,
> one for each CPU.
>=20
> SLAB
>=20
> Without patch 553570 tps at 86% CPU
> With patch 791883 tps at 93% CPU
>=20
> SLUB
>=20
> Without patch 704879 tps at 95% CPU
> With patch 775278 tps at 92% CPU
>=20
> I believe both show good benfits with patch, and it actually looks
> like the impact is more pronounced for SLAB.  I would also note, that
> we have actually already internally patched __netdev_alloc_skb to do
> local node allocation which we have been running in production for
> quite some time.

Excellent ! I was not sure I could do this before NFWS...

Thanks Tom !

Small note : last user of 'allocate skb on a given node, not local one'
is pktgen.

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

Some numbers, courtesy from Tom Herbert :

Some results running netper TCP_RR test with 200 instances, 1 byte
request and response on 16 core AMD using bnx2x with one 16 queues,
one for each CPU.

SLAB

Without patch 553570 tps at 86% CPU
With patch 791883 tps at 93% CPU

SLUB

Without patch 704879 tps at 95% CPU
With patch 775278 tps at 92% CPU

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Acked-by: Tom Herbert <therbert@google.com>
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


