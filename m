From: Gregory CLEMENT <gclement00@gmail.com>
Subject: Re: [PATCH] MACB: clear transmit buffers properly on TX Underrun
Date: Sun, 16 Dec 2007 12:37:25 +0100
Message-ID: <47650DF5.7030402@gmail.com>
References: <4760E49D.5040406@gmail.com> <20071213123308.156ab7dd@dhcp-252-066.norway.atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk
To: Haavard Skinnemoen <hskinnemoen@atmel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:33862 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762270AbXLPLhb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 06:37:31 -0500
Received: by fg-out-1718.google.com with SMTP id e21so168970fga.17
        for <netdev@vger.kernel.org>; Sun, 16 Dec 2007 03:37:29 -0800 (PST)
In-Reply-To: <20071213123308.156ab7dd@dhcp-252-066.norway.atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Haavard Skinnemoen a =E9crit :
> On Thu, 13 Dec 2007 08:51:57 +0100
> Gregory CLEMENT <novexz@gmail.com> wrote:
>=20
>> Hi,
>> I generated this patch for linux 2.6.24-rc5 and test it on AT91SAM92=
63=20
>> with iperf.
>>
>> From: Gregory CLEMENT <gclement00@gmail.com>
>> Date: Wed, 12 Dec 2007 18:10:14 +0100
>> Subject: [PATCH] MACB: clear transmit buffers properly on TX Underru=
n
>>
>> Initially transmit buffer pointers were only reset. But buffer descr=
iptors
>> were possibly still set as ready, and buffer in upper layer was not
>> freed. This caused driver hang under big load.
>> Now reset clean properly the buffer descriptor and freed upper layer=
=2E
>=20
> Nice. I think we want this for 2.6.24.
>=20
> But the patch is a bit mangled, so I don't think it will apply. Pleas=
e
> have a look in Documentation/email-clients.txt for information on how
> to set up Thunderbird to avoid this.

I read it and apply it. Hope it will be OK as I didn't see any problem =
in m first mail...

>=20
>> Signed-off-by: Gregory CLEMENT <gclement00@gmail.com>
>> ---
>>  drivers/net/macb.c |   26 +++++++++++++++++++++++++-
>>  1 files changed, 25 insertions(+), 1 deletions(-)
>>
>> diff --git a/drivers/net/macb.c b/drivers/net/macb.c
>> index 047ea7b..2ee1dab 100644
>> --- a/drivers/net/macb.c
>> +++ b/drivers/net/macb.c
>> @@ -307,9 +307,33 @@ static void macb_tx(struct macb *bp)
>>          (unsigned long)status);
>> =20
>>      if (status & MACB_BIT(UND)) {
>> +        int i;
>>          printk(KERN_ERR "%s: TX underrun, resetting buffers\n",
>> -               bp->dev->name);
>> +               bp->dev->name);
>> +
>> +        head =3D bp->tx_head;
>> +
>> +        /* free transmit buffer in upper layer*/
>> +        for (tail =3D bp->tx_tail; tail !=3D head; tail =3D NEXT_TX=
(tail)) {
>> +            struct ring_info *rp =3D &bp->tx_skb[tail];
>> +            struct sk_buff *skb =3D rp->skb;
>> +
>> +            BUG_ON(skb =3D=3D NULL);
>> +
>> +            rmb();
>> +
>> +            dma_unmap_single(&bp->pdev->dev, rp->mapping, skb->len,
>> +                             DMA_TO_DEVICE);
>> +            rp->skb =3D NULL;
>> +            dev_kfree_skb_irq(skb);
>> +        }
>> +
>> +        /*Mark all the buffer as used to avoid sending a lost buffe=
r*/
>> +        for (i =3D 0; i < RX_RING_SIZE; i++)
>> +            bp->tx_ring[i].ctrl =3D MACB_BIT(TX_USED);
>=20
> That should be TX_RING_SIZE, shouldn't it?

Yes  I fixed it

>=20
> I also think this should be done as part of the previous loop, before
> they are freed. Having free buffers in the ring sounds dangerous, eve=
n
> if it's only for a short time.

OK, I moved this loop before the previous loop, as I wanted to be sure =
that
all buffers are marked.
I did it, but I think we don't really need to do it, as when underrun h=
appen,=20
controller stop transmitting, so it won't transmit a free buffer.

>=20
>> +
>>          bp->tx_head =3D bp->tx_tail =3D 0;
>=20
> Now, I wonder if it would be better to just scan the ring descriptors=
,
> find the one that failed and just move the DMA pointer to the next
> entry. The hardware resets the DMA pointer when an underrun happens, =
so
> I think your code will work, but we're losing more packets than
> strictly necessary. In any case, it's better than the existing code.

As hardware reset the DMA pointer, we have to rewrite all the buffer de=
scriptor.

=46or example if descriptor n=B078 failed, and there is descriptor 79 a=
nd 80 which
are pending. When underrun happen on 78 the hardware reset DMA pointer =
which
will point on descriptor 0. So we have to copy descriptor 79 on 0 and 8=
0 on 1.
The other option is to change Transmit Buffer Queue Pointer Register (T=
BQP), to
make it point on descriptor 79, but on the next descriptor having wrapp=
ed bit set,
the DMA pointer will wrapped on descriptor 79 and not on 0. So I don't =
think it
is a good solution.

> Perhaps we need a check in macb_start_xmit() as well to avoid startin=
g
> a transmission when the ring has just been reset.
>=20

I joined the patch change along your recommendation, if there is no mor=
e error, you
can maybe submit it for 2.6.24 release, and other improvement can be do=
ne later.


=46rom: Gregory CLEMENT <gclement00@gmail.com>
Date: Sun, 16 Dec 2007 11:45:03 +0100
Subject: [PATCH]  MACB: clear transmit buffers properly on transmit und=
errun

Initially transmit buffer pointers were only reset. But buffer descript=
ors
were possibly still set as ready, and buffer in upper layer was not
freed. This caused driver hang under big load.
Now reset clean properly the buffer descriptor and freed upper layer.

Signed-off-by: Gregory CLEMENT <gclement00@gmail.com>
---
 drivers/net/macb.c |   27 ++++++++++++++++++++++++++-
 1 files changed, 26 insertions(+), 1 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index 047ea7b..e898713 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -307,9 +307,34 @@ static void macb_tx(struct macb *bp)
 		(unsigned long)status);
=20
 	if (status & MACB_BIT(UND)) {
+		int i;
 		printk(KERN_ERR "%s: TX underrun, resetting buffers\n",
-		       bp->dev->name);
+			   bp->dev->name);
+
+		head =3D bp->tx_head;
+
+		/*Mark all the buffer as used to avoid sending a lost buffer*/
+		for (i =3D 0; i < TX_RING_SIZE; i++)
+			bp->tx_ring[i].ctrl =3D MACB_BIT(TX_USED);
+
+		/* free transmit buffer in upper layer*/
+		for (tail =3D bp->tx_tail; tail !=3D head; tail =3D NEXT_TX(tail)) {
+			struct ring_info *rp =3D &bp->tx_skb[tail];
+			struct sk_buff *skb =3D rp->skb;
+
+			BUG_ON(skb =3D=3D NULL);
+
+			rmb();
+
+			dma_unmap_single(&bp->pdev->dev, rp->mapping, skb->len,
+							 DMA_TO_DEVICE);
+			rp->skb =3D NULL;
+			dev_kfree_skb_irq(skb);
+		}
+
+
 		bp->tx_head =3D bp->tx_tail =3D 0;
+
 	}
=20
 	if (!(status & MACB_BIT(COMP)))
--=20
1.5.2.5

