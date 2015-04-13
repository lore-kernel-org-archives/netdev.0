From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH v4 1/9] bgmac: simplify tx ring index handling
Date: Mon, 13 Apr 2015 17:01:02 +0200
Message-ID: <552BDA2E.3060909@openwrt.org>
References: <1428933162-26763-1-git-send-email-nbd@openwrt.org> <CACna6rxeBNuSq8OJTBH1Yr75o79q9CDqc2JTW4=kEk+HQt5JRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arrakis.dune.hu ([78.24.191.176]:46111 "EHLO arrakis.dune.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754200AbbDMPBe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Apr 2015 11:01:34 -0400
In-Reply-To: <CACna6rxeBNuSq8OJTBH1Yr75o79q9CDqc2JTW4=kEk+HQt5JRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2015-04-13 16:21, Rafa=C5=82 Mi=C5=82ecki wrote:
>> @@ -158,13 +157,7 @@ static netdev_tx_t bgmac_dma_tx_add(struct bgma=
c *bgmac,
>>                 skb_checksum_help(skb);
>>
>>         nr_frags =3D skb_shinfo(skb)->nr_frags;
>> -
>> -       if (ring->start <=3D ring->end)
>> -               free_slots =3D ring->start - ring->end + BGMAC_TX_RI=
NG_SLOTS;
>> -       else
>> -               free_slots =3D ring->start - ring->end;
>> -
>> -       if (free_slots <=3D nr_frags + 1) {
>> +       if (ring->end - ring->start + nr_frags + 1 >=3D BGMAC_TX_RIN=
G_SLOTS) {
>>                 bgmac_err(bgmac, "TX ring is full, queue should be s=
topped!\n");
>>                 netif_stop_queue(net_dev);
>>                 return NETDEV_TX_BUSY;
>=20
> How is this going to work with ring->end lower than ring->start? Let'=
s
> say you have 2 empty slots at the end of ring and 2 empty slots at th=
e
> beginning. In total 4 free slots. Doing ring->end - ring->start will
> give you some big negative number (depending on the ring size), won't
> it?
It won't, because the resulting data type is limited to 32 bit. I'm
pretty sure there are other places in the kernel that rely on the same
behavior.

>> @@ -284,10 +276,8 @@ static void bgmac_dma_tx_free(struct bgmac *bgm=
ac, struct bgmac_dma_ring *ring)
>>                         slot->skb =3D NULL;
>>                 }
>>
>> -next:
>>                 slot->dma_addr =3D 0;
>> -               if (++ring->start >=3D BGMAC_TX_RING_SLOTS)
>> -                       ring->start =3D 0;
>> +               ring->start++;
>>                 freed =3D true;
>>         }
>>
>=20
> Do I understand correctly you're using u32 overflow here? Is this
> OK/allowed in kernel to knowingly use overflows?
I think so.

>> diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/eth=
ernet/broadcom/bgmac.h
>> index 3ad965f..5a198d5 100644
>> --- a/drivers/net/ethernet/broadcom/bgmac.h
>> +++ b/drivers/net/ethernet/broadcom/bgmac.h
>> @@ -414,10 +414,10 @@ enum bgmac_dma_ring_type {
>>   * empty.
>>   */
>>  struct bgmac_dma_ring {
>> -       u16 num_slots;
>> -       u16 start;
>> -       u16 end;
>> +       u32 start;
>> +       u32 end;
>>
>> +       u16 num_slots;
>>         u16 mmio_base;
>>         struct bgmac_dma_desc *cpu_base;
>>         dma_addr_t dma_base;
>=20
> Any reason for u32 instead of u16?
To avoid writes touching other fields close to it.

- Felix
