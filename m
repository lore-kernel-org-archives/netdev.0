From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] bgmac: driver for GBit MAC core on BCMA bus
Date: Thu, 3 Jan 2013 16:57:00 +0100
Message-ID: <CACna6rydCnf9tjsueOQRvxPQz5_u_h6b=q9j_pTQN+j7_+6uLA@mail.gmail.com>
References: <1356363222-16672-1-git-send-email-zajec5@gmail.com>
	<20121226231721.GA8243@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:53692 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753261Ab3ACP5C convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jan 2013 10:57:02 -0500
Received: by mail-oa0-f43.google.com with SMTP id k1so14094639oag.2
        for <netdev@vger.kernel.org>; Thu, 03 Jan 2013 07:57:01 -0800 (PST)
In-Reply-To: <20121226231721.GA8243@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/12/27 Francois Romieu <romieu@fr.zoreil.com>:
> Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com> :
> [...]
>> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/eth=
ernet/broadcom/bgmac.c
> [...]
>> +static void bgmac_dma_tx_reset(struct bgmac *bgmac, struct bgmac_dm=
a_ring *ring)
>> +{
>> +     u32 val;
>> +     int i;
>> +
>> +     if (!ring->mmio_base)
>> +             return;
>
> static int bgmac_probe(struct bcma_device *core)
> [...]
>         bgmac_chip_reset(bgmac);
>
>         err =3D bgmac_dma_alloc(bgmac);
>
> mmio_base is only set in bgmac_dma_alloc.
>
> -> remove the useless bgmac_chip_reset() in bgmac_probe() and the dri=
ver
> won't need to test for !ring->mmio_base.

bgmac_chip_reset also does different things, so I can't just remove
bgmac_chip_reset from bgmac_probe. I could add some parameter to
bgmac_chip_reset to let it know if DMA should be reset as well, but
I'm note sure about the advantage.


>> +     if (skb->len > BGMAC_DESC_CTL1_LEN) {
>> +             bgmac_err(bgmac, "Too long skb (%d)\n", skb->len);
>> +             return NETDEV_TX_BUSY;
>> +     }
>
> The driver will loop if you don't stop queuing. It won't help.

I hoped net layer will drop the packed after few failed xmit. OK, I'll
add netif_stop_queue here.


>> +
>> +     if (ring->start <=3D ring->end)
>> +             free_slots =3D ring->start - ring->end + BGMAC_TX_RING=
_SLOTS;
>> +     else
>> +             free_slots =3D ring->start - ring->end;
>> +     if (free_slots <=3D 1) {
>> +             bgmac_err(bgmac, "No free slots on ring 0x%X!\n", ring=
->mmio_base);
>> +             netif_stop_queue(bgmac->net_dev);
>> +             return NETDEV_TX_BUSY;
>> +     }
>
> The driver should stop queueing after its processing if it detects th=
at
> it can't handle more requests.

I think it's what the code does... netif_stop_queue and return
NETDEV_TX_BUSY. Anything wrong about it?


>> +     slot =3D &ring->slots[ring->end];
>> +     slot->skb =3D skb;
>> +     slot->dma_addr =3D dma_map_single(dma_dev, skb->data, skb->len=
, DMA_TO_DEVICE);
>> +     if (dma_mapping_error(dma_dev, slot->dma_addr)) {
>> +             bgmac_err(bgmac, "Mapping error of skb on ring 0x%X\n"=
, ring->mmio_base);
>> +             return NETDEV_TX_BUSY;
>> +     }
>
> Why don't you drop the packet and return TX_OK ?

Didn't know about that and there isn't any nice NAPI tutorial for devel=
opers :(


>> +     dma_desc->addr_low =3D cpu_to_le32(lower_32_bits(slot->dma_add=
r));
>> +     dma_desc->addr_high =3D cpu_to_le32(upper_32_bits(slot->dma_ad=
dr));
>> +     dma_desc->ctl0 =3D cpu_to_le32(ctl0);
>> +     dma_desc->ctl1 =3D cpu_to_le32(ctl1);
>> +
>> +     wmb();
>
> Are we sure that the hardware will never read a descriptor where ctl0=
 is
> set and ctl1 is not (start_xmit, dma starts, competing start_xmit, oo=
ps) ?

Do you mean more that one ->ndo_start_xmit(...) can be executed at a
time? So I need mutex for it?


--=20
Rafa=C5=82
