From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] amd/lance.c: dev_alloc_skb to netdev_alloc_skb
Date: Wed, 25 Jan 2012 21:16:39 +0100
Message-ID: <1327522599.2605.14.camel@edumazet-laptop>
References: <1327517188-14088-1-git-send-email-netdev@pradeepdalvi.com>
	 <1327517706.2605.7.camel@edumazet-laptop>
	 <CA+Dx6Ha4dnqnkR_Pc+dFZ+Ef_mxRNN_Jk44vJ_R0viuHd0JGHw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+Dx6Ha4dnqnkR_Pc+dFZ+Ef_mxRNN_Jk44vJ_R0viuHd0JGHw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 26 janvier 2012 =C3=A0 01:31 +0530, Pradeep A. Dalvi a =C3=A9c=
rit :

> Thanks Eric! Even if we try to skip NET_SKB_PAD i.e. max of 32 or
> L1_CACHE_BYTES, SKB_DATA_ALIGN is anyway going to add some additional
> bytes for the same reason.
>=20
> And towards the end, as from my current understanding regarding skb
> allocations, for MTU including alignments < 2048, there is not much t=
o
> worry about. As long as, it doesn't cross the boundary.
>=20
> (And in fact, this driver doesn't even get compiled with current
> configs, even after forcefully adding CONFIG_ISA & CONFIG_LANCE, of
> course along with CONFIG_ISA_DMA_API. Had to change the Makefile)

Point is we dont need skbs at all, and we dont need NET_SKB_PAD padding
either.

Also a big blob of DMA memory (rx_buffs) is allocated but never used.

Best is to not touch this, since this driver is probably not anymore
used.=20

Dont bother.

diff --git a/drivers/net/ethernet/amd/lance.c b/drivers/net/ethernet/am=
d/lance.c
index a6e2e84..aa2c6cd 100644
--- a/drivers/net/ethernet/amd/lance.c
+++ b/drivers/net/ethernet/amd/lance.c
@@ -240,9 +240,8 @@ struct lance_private {
 	const char *name;
 	/* The saved address of a sent-in-place packet/buffer, for skfree(). =
*/
 	struct sk_buff* tx_skbuff[TX_RING_SIZE];
-	/* The addresses of receive-in-place skbuffs. */
-	struct sk_buff* rx_skbuff[RX_RING_SIZE];
-	unsigned long rx_buffs;		/* Address of Rx and Tx buffers. */
+	/* The addresses of receive-in-place buffers. */
+	void		*rx_buff[RX_RING_SIZE];
 	/* Tx low-memory "bounce buffer" address. */
 	char (*tx_bounce_buffs)[PKT_BUF_SZ];
 	int cur_rx, cur_tx;			/* The next free ring entry */
@@ -364,7 +363,6 @@ static void cleanup_card(struct net_device *dev)
 		free_dma(dev->dma);
 	release_region(dev->base_addr, LANCE_TOTAL_SIZE);
 	kfree(lp->tx_bounce_buffs);
-	kfree((void*)lp->rx_buffs);
 	kfree(lp);
 }
=20
@@ -552,10 +550,6 @@ static int __init lance_probe1(struct net_device *=
dev, int ioaddr, int irq, int
 	if (lance_debug > 6) printk(" (#0x%05lx)", (unsigned long)lp);
 	dev->ml_priv =3D lp;
 	lp->name =3D chipname;
-	lp->rx_buffs =3D (unsigned long)kmalloc(PKT_BUF_SZ*RX_RING_SIZE,
-						  GFP_DMA | GFP_KERNEL);
-	if (!lp->rx_buffs)
-		goto out_lp;
 	if (lance_need_isa_bounce_buffers) {
 		lp->tx_bounce_buffs =3D kmalloc(PKT_BUF_SZ*TX_RING_SIZE,
 						  GFP_DMA | GFP_KERNEL);
@@ -739,8 +733,6 @@ out_dma:
 out_tx:
 	kfree(lp->tx_bounce_buffs);
 out_rx:
-	kfree((void*)lp->rx_buffs);
-out_lp:
 	kfree(lp);
 	return err;
 }
@@ -842,11 +834,9 @@ lance_purge_ring(struct net_device *dev)
=20
 	/* Free all the skbuffs in the Rx and Tx queues. */
 	for (i =3D 0; i < RX_RING_SIZE; i++) {
-		struct sk_buff *skb =3D lp->rx_skbuff[i];
-		lp->rx_skbuff[i] =3D NULL;
+		kfree(lp->rx_buff[i]);
+		lp->rx_buff[i] =3D NULL;
 		lp->rx_ring[i].base =3D 0;		/* Not owned by LANCE chip. */
-		if (skb)
-			dev_kfree_skb_any(skb);
 	}
 	for (i =3D 0; i < TX_RING_SIZE; i++) {
 		if (lp->tx_skbuff[i]) {
@@ -868,16 +858,9 @@ lance_init_ring(struct net_device *dev, gfp_t gfp)
 	lp->dirty_rx =3D lp->dirty_tx =3D 0;
=20
 	for (i =3D 0; i < RX_RING_SIZE; i++) {
-		struct sk_buff *skb;
-		void *rx_buff;
-
-		skb =3D alloc_skb(PKT_BUF_SZ, GFP_DMA | gfp);
-		lp->rx_skbuff[i] =3D skb;
-		if (skb) {
-			skb->dev =3D dev;
-			rx_buff =3D skb->data;
-		} else
-			rx_buff =3D kmalloc(PKT_BUF_SZ, GFP_DMA | gfp);
+		void *rx_buff =3D kmalloc(PKT_BUF_SZ, GFP_DMA | gfp);
+
+		lp->rx_buff[i] =3D rx_buff;
 		if (rx_buff =3D=3D NULL)
 			lp->rx_ring[i].base =3D 0;
 		else
