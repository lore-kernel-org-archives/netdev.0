From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] b44: GFP_DMA skb should not escape from driver
Date: Thu, 15 Jan 2009 17:49:14 +0100
Message-ID: <496F690A.2090606@cosmosbay.com>
References: <20090115111537.GA994@gondor.apana.org.au> <200901151527.43646.mihai.dontu@gmail.com> <20090115134055.GA15551@ee.oulu.fi> <496F4AD4.9080201@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?TWloYWkgRG9uyJt1?= <mihai.dontu@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Pekka Pietikainen <pp@ee.oulu.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw2.cosmosbay.com ([86.64.20.130]:37196 "EHLO gw2.cosmosbay.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753135AbZAOQt3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2009 11:49:29 -0500
In-Reply-To: <496F4AD4.9080201@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =C3=A9crit :
> Pekka Pietikainen a =C3=A9crit :
>> On Thu, Jan 15, 2009 at 03:27:43PM +0200, Mihai Don=C8=9Bu wrote:
>>>>> A friend of mine just booted 2.6.28 and when someone else tried t=
o send
>>>>> something to him over ssh (scp), the transfer failed and the foll=
owing
>>>>> appeared in dmesg:
>>>> You missed the all important order line before the stack trace.
>>> Right, sorry for that. Here it is:
>>> swapper: page allocation failure. order:0, mode:0x21
>>>> If it's order 0, then you're just out of memory, if it's greater
>>>> than order 0, then either you're using jumbo frames or b44 is
>>>> broken.
>>> It is order zero, but he's not out of memory. He has just booted 2.=
6.28 (no X,=20
>>> no thing), has 3GB of RAM and 2GB of swap.
>> b44 uses GFP_DMA bounce buffers in some situations (x86_64 with > 1G=
B of
>> memory would do the trick I think, as does x86 with 4:4 memory split=
),
>> and that's a very limited resource (Memory < 16MB ).=20
>>
>> Lovely hardware feature requiring nasty workarounds
>> (the chip can't do DMA for addresses > 1GB).
>>
>> Maybe something else sucks up GFP_DMA memory with 2.6.28?
>=20
> Normal tcp queues (in this case, since a single scp is enough
> to trigger the bug)
>=20
> If a rx buffer was allocated using GFP_DMA, then b44_rx()
> should copy it to a new skb, (like done by copybreak algo),
> regardless of frame size, to not consume DMA memory in protocol
> queues.
>=20
> Better be slow (because of extra copy) then risking exhausting DMA zo=
ne
>=20
> easy way to test would be to redefine RX_COPY_THRESHOLD to 16000

Or try following patch (I dont have this hardware)

[PATCH] b44: GFP_DMA skb should not escape from driver

b44 chip has some hardware limitations, that need GFP_DMA bounce
buffers in some situations.

In order to not deplete DMA zone, we should keep allocated GFP_DMA skb
only for driver use. At rx time, we copy such skb to newly allocated
skb, reusing existing copybreak infrastructure.

On machines with low amount of memory, all skb meet the hardware limita=
tion,
so no copy is needed. We detect this situation using a new device flag,=
 set
to one if one GFP_DMA skb was ever allocated by b44_alloc_rx_skb().

Previously allocated skb, even outside from DMA zone will then be recyc=
led,
to have minimal impact on DMA zone use.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
diff --git a/drivers/net/b44.c b/drivers/net/b44.c
index 5ae131c..c38512e 100644
--- a/drivers/net/b44.c
+++ b/drivers/net/b44.c
@@ -679,6 +679,7 @@ static int b44_alloc_rx_skb(struct b44 *bp, int src=
_idx, u32 dest_idx_unmasked)
 			dev_kfree_skb_any(skb);
 			return -ENOMEM;
 		}
+		bp->force_copybreak =3D 1;
 	}
=20
 	rh =3D (struct rx_header *) skb->data;
@@ -800,7 +801,7 @@ static int b44_rx(struct b44 *bp, int budget)
 		/* Omit CRC. */
 		len -=3D 4;
=20
-		if (len > RX_COPY_THRESHOLD) {
+		if (!bp->force_copybreak && len > RX_COPY_THRESHOLD) {
 			int skb_size;
 			skb_size =3D b44_alloc_rx_skb(bp, cons, bp->rx_prod);
 			if (skb_size < 0)
@@ -2152,6 +2153,7 @@ static int __devinit b44_init_one(struct ssb_devi=
ce *sdev,
 	bp =3D netdev_priv(dev);
 	bp->sdev =3D sdev;
 	bp->dev =3D dev;
+	bp->force_copybreak =3D 0;
=20
 	bp->msg_enable =3D netif_msg_init(b44_debug, B44_DEF_MSG_ENABLE);
=20
diff --git a/drivers/net/b44.h b/drivers/net/b44.h
index 7db0c84..e678498 100644
--- a/drivers/net/b44.h
+++ b/drivers/net/b44.h
@@ -395,7 +395,7 @@ struct b44 {
 	u32			rx_pending;
 	u32			tx_pending;
 	u8			phy_addr;
-
+	u8			force_copybreak;
 	struct mii_if_info	mii_if;
 };
=20

