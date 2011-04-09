From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Sat, 09 Apr 2011 08:36:38 +0200
Message-ID: <1302330998.2656.113.camel@edumazet-laptop>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>
	 <1302152327.2701.50.camel@edumazet-laptop>
	 <1302153412.2701.64.camel@edumazet-laptop>
	 <1302157012.2701.73.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48B9E82@ESGSCCMS0001.eapac.ericsson.se>
	 <1302163650.3357.8.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48B9F23@ESGSCCMS0001.eapac.ericsson.se>
	 <1302167168.3357.12.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA027@ESGSCCMS0001.eapac.ericsson.se>
	 <1302176811.3357.15.camel@edumazet-laptop>  <4D9DDF43.9080302@intel.com>
	 <1302192218.3357.47.camel@edumazet-laptop> <4D9DE465.1080008@intel.com>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA58D@ESGSCCMS0001.eapac.ericsson.se>
	 <1302253651.4409.2.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA66B@ESGSCCMS0001.eapac.ericsson.se>
	 <1302267400.4409.22.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA682@ESGSCCMS0001.eapac.ericsson.se>
	 <1302275223.4409.36.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA6AE@ESGSCCMS0001.eapac.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Wei Gu <wei.gu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56456 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752489Ab1DIGgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2011 02:36:45 -0400
Received: by wya21 with SMTP id 21so3609512wya.19
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2011 23:36:43 -0700 (PDT)
In-Reply-To: <D12839161ADD3A4B8DA63D1A134D084026E48BA6AE@ESGSCCMS0001.eapac.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 09 avril 2011 =C3=A0 11:27 +0800, Wei Gu a =C3=A9crit :
> HI Eric,
> If I try to bind the 8 tx&rx queue to different NUMA Node to (core 3,=
7,11,15,19,23,27,31), looks doesn't help on the rx_missing_error anymor=
e.
>=20
> I still think the best performance would be binding NIC to one sock o=
f CPU with it's local memory node.
> I did a lot of combination on 2.6.32 kernel, by bind the eth10 to NOD=
E2/3 could gain 20% more performance compare to NODE0/1.
> So I guess the CPU Socket 2&3 was locally with the eth10.
>=20

Ideally, you would need to split memory loads on several nodes, because
you have a workload on a single NIC, located on a given node Nx.


1) Let the buffers where NIC performs DMA be on Nx,
so that DMA is fast.

2) And everything else on other nodes, so that cpus can steal some
memory bandwidth from other nodes, and free Nx memory bandwidth for NIC
use. (Processors only need to fetch first cache line of packets to
perform routing decision)

alloc_skb() would need to use memory from node Ny for "struct sk_buff",
and memory from node Nx for "skb->data" and skb frags
[ netdev_alloc_page() in ixgbe case]

In your case, you have 4 nodes, so Ny would be in a set of 3 nodes.

So commit 564824b0c52c34692d804b would need a litle tweak in your
case [ where your cpus need to bring only one cache line from the packe=
t payload ]

Please try following patch :



 include/linux/skbuff.h |   14 +-------------
 net/core/skbuff.c      |   19 +++++++++++++++++++
 2 files changed, 20 insertions(+), 13 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d0ae90a..b43626d 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1567,19 +1567,7 @@ static inline struct sk_buff *netdev_alloc_skb_i=
p_align(struct net_device *dev,
 	return skb;
 }
=20
-/**
- *	__netdev_alloc_page - allocate a page for ps-rx on a specific devic=
e
- *	@dev: network device to receive on
- *	@gfp_mask: alloc_pages_node mask
- *
- * 	Allocate a new page. dev currently unused.
- *
- * 	%NULL is returned if there is no free memory.
- */
-static inline struct page *__netdev_alloc_page(struct net_device *dev,=
 gfp_t gfp_mask)
-{
-	return alloc_pages_node(NUMA_NO_NODE, gfp_mask, 0);
-}
+extern struct page *__netdev_alloc_page(struct net_device *dev, gfp_t =
gfp_mask);
=20
 /**
  *	netdev_alloc_page - allocate a page for ps-rx on a specific device
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 7ebeed0..877797e 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -259,6 +259,25 @@ struct sk_buff *__netdev_alloc_skb(struct net_devi=
ce *dev,
 }
 EXPORT_SYMBOL(__netdev_alloc_skb);
=20
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
+struct page *__netdev_alloc_page(struct net_device *dev, gfp_t gfp_mas=
k)
+{
+	int node =3D dev->dev.parent ? dev_to_node(dev->dev.parent) : NUMA_NO=
_NODE;
+	struct page *page;
+
+	page =3D alloc_pages_node(node, gfp_mask, 0);
+	return page;
+}
+EXPORT_SYMBOL(__netdev_alloc_page);
+
 void skb_add_rx_frag(struct sk_buff *skb, int i, struct page *page, in=
t off,
 		int size)
 {


