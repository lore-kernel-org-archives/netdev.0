From: Levitsky Maxim <maximlevitsky@yahoo.com>
Subject: [PATCH] [NETDEV] [002] dmfe : Fix possible oops
Date: Wed, 7 Feb 2007 10:30:17 -0800 (PST)
Message-ID: <38301.22381.qm@web38504.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tori@unhappy.mine.nu, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422691AbXBGSaV@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Maxim Levitsky <maximlevitsky@yahoo.com>
Subject: [PATCH] [NET] [002] dmfe : Fix possible oops

Deallocate memory after driver is unregistred to prevent oops
Don't dereference NULL pointer that can be returned by dev_alloc_skb in=
 case of oom

Signed-off-by: Maxim Levitsky <maximlevitsky@yahoo.com>

---

--- linux-2.6.20-mod/drivers/net/tulip/dmfe.c=A0=A0=A02007-02-07 18:27:=
07.000000000 +0200
+++ linux-2.6.20-test/drivers/net/tulip/dmfe.c=A0=A02007-02-07 18:27:59=
=2E000000000 +0200
@@ -497,13 +497,16 @@ static void __devexit dmfe_remove_one (s
=A0=A0=A0=A0=A0=A0=A0=A0DMFE_DBUG(0, "dmfe_remove_one()", 0);
=A0
=A0 =A0=A0=A0=A0=A0=A0if (dev) {
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0unregister_netdev(dev);
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0pci_release_regions(pdev)=
;
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0pci_free_consistent(db-=
>pdev, sizeof(struct tx_desc) *
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0DESC_ALL_CNT + 0x20, db=
->desc_pool_ptr,
=A0 =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0db->desc_pool_dma_ptr);
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0pci_free_consistent(db-=
>pdev, TX_BUF_ALLOC * TX_DESC_CNT + 4,
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0db->buf_pool_ptr, db->b=
uf_pool_dma_ptr);
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0unregister_netdev(dev);
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0pci_release_regions(pdev)=
;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0free_netdev(dev);=A0=A0=
=A0=A0=A0=A0=A0/* free board information */
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0pci_set_drvdata(pdev, N=
ULL);
=A0=A0=A0=A0=A0=A0=A0=A0}
@@ -921,7 +924,7 @@ static inline u32 cal_CRC(unsigned char=20
=A0static void dmfe_rx_packet(struct DEVICE *dev, struct dmfe_board_inf=
o * db)
=A0{
=A0=A0=A0=A0=A0=A0=A0=A0struct rx_desc *rxptr;
-=A0=A0=A0=A0=A0=A0=A0struct sk_buff *skb;
+=A0=A0=A0=A0=A0=A0=A0struct sk_buff *skb, *newskb;
=A0=A0=A0=A0=A0=A0=A0=A0int rxlen;
=A0=A0=A0=A0=A0=A0=A0=A0u32 rdes0;
=A0
@@ -974,8 +977,10 @@ static void dmfe_rx_packet(struct DEVICE
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0/* Good packet, send to=
 upper layer */
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0/* Shorst packet used n=
ew SKB */
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0if ( (rxlen < RX_COPY_S=
IZE) &&
-=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0( =
(skb =3D dev_alloc_skb(rxlen + 2) )
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0( =
(newskb =3D dev_alloc_skb(rxlen + 2) )
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
!=3D NULL) ) {
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0
+=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0sk=
b =3D newskb;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
/* size less than COPY_SIZE, allocate a rxlen SKB
*/
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
skb->dev =3D dev;
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
skb_reserve(skb, 2); /* 16byte align */



=20
_______________________________________________________________________=
_____________
8:00? 8:25? 8:40? Find a flick in no time=20
with the Yahoo! Search movie showtime shortcut.
http://tools.search.yahoo.com/shortcuts/#news
