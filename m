From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH v6 4/9] bgmac: simplify/optimize rx DMA error handling
Date: Tue, 14 Apr 2015 11:26:48 +0200
Message-ID: <552CDD58.5030904@openwrt.org>
References: <1428968537-6181-1-git-send-email-nbd@openwrt.org>	<1428968537-6181-4-git-send-email-nbd@openwrt.org>	<CACna6ry7yD4jb2ph1EOvOrmdWiqOU8+yFQKvH0OCS=haH4dUqA@mail.gmail.com>	<552CDA4D.6080702@openwrt.org> <CACna6rz-b2TXMPpPdRCiyS45mfZ2pgLRNiCyPpd4XLVDfwfbEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:42009 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753676AbbDNJ04 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 05:26:56 -0400
In-Reply-To: <CACna6rz-b2TXMPpPdRCiyS45mfZ2pgLRNiCyPpd4XLVDfwfbEA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-04-14 11:19, Rafa=C5=82 Mi=C5=82ecki wrote:
> On 14 April 2015 at 11:13, Felix Fietkau <nbd@openwrt.org> wrote:
>> On 2015-04-14 07:55, Rafa=C5=82 Mi=C5=82ecki wrote:
>>> On 14 April 2015 at 01:42, Felix Fietkau <nbd@openwrt.org> wrote:
>>>> @@ -528,14 +524,14 @@ static void bgmac_dma_rx_ring_free(struct bg=
mac *bgmac,
>>>>
>>>>         for (i =3D 0; i < ring->num_slots; i++) {
>>>>                 slot =3D &ring->slots[i];
>>>> -               if (!slot->buf)
>>>> +               if (!slot->dma_addr)
>>>>                         continue;
>>>
>>> I think it breaks error path of bgmac_dma_alloc. It may happen that
>>> during DMA alloc we alloc skb and then we fail to map it. In such c=
ase
>>> buf should be freed. Please trace how bgmac_dma_free is used in
>>> bgmac_dma_alloc.
>> I don't think so: bgmac_dma_rx_skb_for_slot handles both buffer
>> allocation and dma mapping. If dma mapping fails, the buffer is free=
d
>> before any part of the slot is overwritten.
>=20
> Oops, I think I just spotted a memory leak then.
>=20
> If bgmac_dma_rx_skb_for_slot fails to do DMA mapping it returns an
> error without freeing a skb.
It neither allocates, nor frees an skb - I should probably rename that
function in a later patch round.

Allocation does:
	buf =3D netdev_alloc_frag(BGMAC_RX_ALLOC_SIZE);

When handling a DMA mapping error, it does this:
	put_page(virt_to_head_page(buf));

Where's the memory leak?

- Felix
