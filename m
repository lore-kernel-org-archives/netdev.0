From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: introduce alloc_skb_order0
Date: Sat, 09 Oct 2010 17:59:56 +0200
Message-ID: <1286639996.2692.148.camel@edumazet-laptop>
References: <1286547901-10782-1-git-send-email-sgruszka@redhat.com>
	 <20101008145256.GB10393@redhat.com>
	 <1286550247.2959.444.camel@edumazet-laptop>
	 <20101008160341.GC10393@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62402 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754879Ab0JIQAC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Oct 2010 12:00:02 -0400
Received: by wyb28 with SMTP id 28so1910371wyb.19
        for <netdev@vger.kernel.org>; Sat, 09 Oct 2010 09:00:00 -0700 (PDT)
In-Reply-To: <20101008160341.GC10393@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 08 octobre 2010 =C3=A0 18:03 +0200, Stanislaw Gruszka a =C3=
=A9crit :
> On Fri, Oct 08, 2010 at 05:04:07PM +0200, Eric Dumazet wrote:

> > Switch to SLAB -> no more problem ;)
>=20
> yeh, I wish to, but fedora use SLUB because of some debugging
> capabilities.=20

Yes, of course, I was kidding :)

echo 0 >/sys/kernel/slab/kmalloc-2048/order
echo 0 >/sys/kernel/slab/kmalloc-1024/order
echo 0 >/sys/kernel/slab/kmalloc-512/order

Should do the trick : No more high order allocations for MTU=3D1500
frames.


=46or MTU=3D9000 frames, we probably need something like this patch :

(Not yet for inclusion, this is an RFC, this will need two separate
patches)

[PATCH] net: introduce alloc_skb_order0()

Reception of big frames hit a memory allocation problem, because of hig=
h
order pages allocations (order-3 sometimes for MTU=3D9000). This patch
introduces alloc_skb_order0(), to build skbs with order-0 pages only.

Their headlen is at most SKB_MAX_HEAD(NET_SKB_PAD + NET_IP_ALIGN)
(3648 bytes on x86_64, 3840 bytes on x86_32)

As net drivers might use skb_store_bits() to copy data to this newly
allocated skb, we might even use __GFP_HIGHMEM for the fragments ?

Note : Use GFP_NOWAIT | __GFP_NOWARN mask to allocate pages, since we
dont want to let big packets exhaust GFP_ATOMIC pool.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/r8169.c    |   19 ++++++---------
 include/linux/skbuff.h |    1=20
 net/core/skbuff.c      |   47 +++++++++++++++++++++++++++++++++++++++
 3 files changed, 56 insertions(+), 11 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index fe3b762..f4220db 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -4468,27 +4468,24 @@ static inline void rtl8169_rx_csum(struct sk_bu=
ff *skb, u32 opts1)
 		skb_checksum_none_assert(skb);
 }
=20
-static inline bool rtl8169_try_rx_copy(struct sk_buff **sk_buff,
+static inline bool rtl8169_try_rx_copy(struct sk_buff **pskb,
 				       struct rtl8169_private *tp, int pkt_size,
 				       dma_addr_t addr)
 {
 	struct sk_buff *skb;
-	bool done =3D false;
=20
 	if (pkt_size >=3D rx_copybreak)
-		goto out;
+		return false;
=20
-	skb =3D netdev_alloc_skb_ip_align(tp->dev, pkt_size);
+	skb =3D alloc_skb_order0(pkt_size);
 	if (!skb)
-		goto out;
+		return false;
=20
 	pci_dma_sync_single_for_cpu(tp->pci_dev, addr, pkt_size,
 				    PCI_DMA_FROMDEVICE);
-	skb_copy_from_linear_data(*sk_buff, skb->data, pkt_size);
-	*sk_buff =3D skb;
-	done =3D true;
-out:
-	return done;
+	skb_store_bits(skb, 0, (*pskb)->data, pkt_size);
+	*pskb =3D skb;
+	return true;
 }
=20
 /*
@@ -4559,10 +4556,10 @@ static int rtl8169_rx_interrupt(struct net_devi=
ce *dev,
 				pci_unmap_single(pdev, addr, tp->rx_buf_sz,
 						 PCI_DMA_FROMDEVICE);
 				tp->Rx_skbuff[entry] =3D NULL;
+				skb_put(skb, pkt_size);
 			}
=20
 			rtl8169_rx_csum(skb, status);
-			skb_put(skb, pkt_size);
 			skb->protocol =3D eth_type_trans(skb, dev);
=20
 			if (rtl8169_rx_vlan_skb(tp, desc, skb, polling) < 0) {
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 0b53c43..2cc161a 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1841,6 +1841,7 @@ extern int	       skb_copy_bits(const struct sk_b=
uff *skb, int offset,
 				     void *to, int len);
 extern int	       skb_store_bits(struct sk_buff *skb, int offset,
 				      const void *from, int len);
+extern struct sk_buff *alloc_skb_order0(int pkt_size);
 extern __wsum	       skb_copy_and_csum_bits(const struct sk_buff *skb,
 					      int offset, u8 *to, int len,
 					      __wsum csum);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 752c197..4a6195d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1664,6 +1664,53 @@ fault:
 }
 EXPORT_SYMBOL(skb_store_bits);
=20
+/**
+ * alloc_skb_order0 - allocate skb with order-0 requirements
+ * @pkt_size: packet size
+ *=20
+ * Allocate an skb with a head small enough that skb->data should not
+ * require high order page allocation, and complete with fragments if
+ * pkt_size is too big. Might be use in drivers RX path : We reserve
+ * NET_SKB_PAD + NET_IP_ALIGN bytes and use GFP_ATOMIC allocations.
+ * We also set skb->len to pkt_size, so driver should not call skb_put=
()
+ */
+struct sk_buff *alloc_skb_order0(int pkt_size)
+{
+	int head =3D min_t(int, pkt_size, SKB_MAX_HEAD(NET_SKB_PAD + NET_IP_A=
LIGN));
+	struct sk_buff *skb;
+
+	skb =3D alloc_skb(head + NET_SKB_PAD + NET_IP_ALIGN,
+			GFP_ATOMIC | __GFP_NOWARN);
+	if (!skb)
+		return NULL;
+	skb_reserve(skb, NET_SKB_PAD + NET_IP_ALIGN);
+	skb_put(skb, head);
+	pkt_size -=3D head;
+
+	skb->len +=3D pkt_size;
+	skb->data_len +=3D pkt_size;
+	skb->truesize +=3D pkt_size;
+	while (pkt_size) {
+		int i =3D skb_shinfo(skb)->nr_frags++;
+		skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
+		int fragsize =3D min_t(int, pkt_size, PAGE_SIZE);
+		struct page *page =3D alloc_page(GFP_NOWAIT | __GFP_NOWARN);
+
+		if (!page)
+			goto error;
+		frag->page =3D page;
+		frag->size =3D fragsize;
+		frag->page_offset =3D 0;
+		pkt_size -=3D fragsize;
+	}
+	return skb;
+
+error:
+	kfree_skb(skb);
+	return NULL;=09
+}
+EXPORT_SYMBOL(alloc_skb_order0);
+
 /* Checksum skb data. */
=20
 __wsum skb_checksum(const struct sk_buff *skb, int offset,


