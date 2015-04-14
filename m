From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH v6 4/9] bgmac: simplify/optimize rx DMA error handling
Date: Tue, 14 Apr 2015 11:13:49 +0200
Message-ID: <552CDA4D.6080702@openwrt.org>
References: <1428968537-6181-1-git-send-email-nbd@openwrt.org>	<1428968537-6181-4-git-send-email-nbd@openwrt.org> <CACna6ry7yD4jb2ph1EOvOrmdWiqOU8+yFQKvH0OCS=haH4dUqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:41776 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753298AbbDNJN5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 05:13:57 -0400
In-Reply-To: <CACna6ry7yD4jb2ph1EOvOrmdWiqOU8+yFQKvH0OCS=haH4dUqA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-04-14 07:55, Rafa=C5=82 Mi=C5=82ecki wrote:
> On 14 April 2015 at 01:42, Felix Fietkau <nbd@openwrt.org> wrote:
>> @@ -382,6 +382,19 @@ static void bgmac_dma_rx_setup_desc(struct bgma=
c *bgmac,
>>         dma_desc->ctl1 =3D cpu_to_le32(ctl1);
>>  }
>>
>> +static void bgmac_dma_rx_poison_buf(struct device *dma_dev,
>> +                                   struct bgmac_slot_info *slot)
>> +{
>> +       struct bgmac_rx_header *rx =3D slot->buf + BGMAC_RX_BUF_OFFS=
ET;
>> +
>> +       dma_sync_single_for_cpu(dma_dev, slot->dma_addr, BGMAC_RX_BU=
=46_SIZE,
>> +                               DMA_FROM_DEVICE);
>> +       rx->len =3D cpu_to_le16(0xdead);
>> +       rx->flags =3D cpu_to_le16(0xdead);
>> +       dma_sync_single_for_device(dma_dev, slot->dma_addr, BGMAC_RX=
_BUF_SIZE,
>> +                                  DMA_FROM_DEVICE);
>> +}
>=20
> flags should be 0xbeef
Right.

>> @@ -404,51 +417,32 @@ static int bgmac_dma_rx_read(struct bgmac *bgm=
ac, struct bgmac_dma_ring *ring,
>>                 void *buf =3D slot->buf;
>>                 u16 len, flags;
>>
>> -               /* Unmap buffer to make it accessible to the CPU */
>> -               dma_sync_single_for_cpu(dma_dev, slot->dma_addr,
>> -                                       BGMAC_RX_BUF_SIZE, DMA_FROM_=
DEVICE);
>> +               do {
>> +                       /* Prepare new skb as replacement */
>> +                       if (bgmac_dma_rx_skb_for_slot(bgmac, slot)) =
{
>> +                               bgmac_dma_rx_poison_buf(dma_dev, slo=
t);
>> +                               break;
>> +                       }
>=20
> So you just replaced slot->dma_addr with a mapping of new skb data.
>=20
>=20
>>
>> -               /* Get info from the header */
>> -               len =3D le16_to_cpu(rx->len);
>> -               flags =3D le16_to_cpu(rx->flags);
>> +                       /* Unmap buffer to make it accessible to the=
 CPU */
>> +                       dma_unmap_single(dma_dev, slot->dma_addr,
>> +                                        BGMAC_RX_BUF_SIZE, DMA_FROM=
_DEVICE);
>=20
> Now you unmap the new sbk data instead of the old one you want to acc=
ess.
> That's why the old code included old_dma_addr.
Stupid mistake, I should be more careful with late night coding ;)

>> @@ -528,14 +524,14 @@ static void bgmac_dma_rx_ring_free(struct bgma=
c *bgmac,
>>
>>         for (i =3D 0; i < ring->num_slots; i++) {
>>                 slot =3D &ring->slots[i];
>> -               if (!slot->buf)
>> +               if (!slot->dma_addr)
>>                         continue;
>=20
> I think it breaks error path of bgmac_dma_alloc. It may happen that
> during DMA alloc we alloc skb and then we fail to map it. In such cas=
e
> buf should be freed. Please trace how bgmac_dma_free is used in
> bgmac_dma_alloc.
I don't think so: bgmac_dma_rx_skb_for_slot handles both buffer
allocation and dma mapping. If dma mapping fails, the buffer is freed
before any part of the slot is overwritten.

>> -               if (slot->dma_addr)
>> -                       dma_unmap_single(dma_dev, slot->dma_addr,
>> -                                        BGMAC_RX_BUF_SIZE,
>> -                                        DMA_FROM_DEVICE);
>> +               dma_unmap_single(dma_dev, slot->dma_addr,
>> +                                BGMAC_RX_BUF_SIZE,
>> +                                DMA_FROM_DEVICE);
>>                 put_page(virt_to_head_page(slot->buf));
>> +               slot->dma_addr =3D 0;
>>         }
>>  }

- Felix
