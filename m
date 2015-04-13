From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH v4 1/9] bgmac: simplify tx ring index handling
Date: Mon, 13 Apr 2015 20:05:43 +0200
Message-ID: <CACna6rwvjgHDA65S_SzV51XWavFXKNMAWWot=PN-mv6Ej82wOw@mail.gmail.com>
References: <1428933162-26763-1-git-send-email-nbd@openwrt.org>
	<CACna6rxeBNuSq8OJTBH1Yr75o79q9CDqc2JTW4=kEk+HQt5JRg@mail.gmail.com>
	<552BDA2E.3060909@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Network Development <netdev@vger.kernel.org>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:38241 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273AbbDMSFo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 14:05:44 -0400
Received: by igbqf9 with SMTP id qf9so51056910igb.1
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 11:05:43 -0700 (PDT)
In-Reply-To: <552BDA2E.3060909@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13 April 2015 at 17:01, Felix Fietkau <nbd@openwrt.org> wrote:
> On 2015-04-13 16:21, Rafa=C5=82 Mi=C5=82ecki wrote:
>>> @@ -158,13 +157,7 @@ static netdev_tx_t bgmac_dma_tx_add(struct bgm=
ac *bgmac,
>>>                 skb_checksum_help(skb);
>>>
>>>         nr_frags =3D skb_shinfo(skb)->nr_frags;
>>> -
>>> -       if (ring->start <=3D ring->end)
>>> -               free_slots =3D ring->start - ring->end + BGMAC_TX_R=
ING_SLOTS;
>>> -       else
>>> -               free_slots =3D ring->start - ring->end;
>>> -
>>> -       if (free_slots <=3D nr_frags + 1) {
>>> +       if (ring->end - ring->start + nr_frags + 1 >=3D BGMAC_TX_RI=
NG_SLOTS) {
>>>                 bgmac_err(bgmac, "TX ring is full, queue should be =
stopped!\n");
>>>                 netif_stop_queue(net_dev);
>>>                 return NETDEV_TX_BUSY;
>>
>> How is this going to work with ring->end lower than ring->start? Let=
's
>> say you have 2 empty slots at the end of ring and 2 empty slots at t=
he
>> beginning. In total 4 free slots. Doing ring->end - ring->start will
>> give you some big negative number (depending on the ring size), won'=
t
>> it?
> It won't, because the resulting data type is limited to 32 bit. I'm
> pretty sure there are other places in the kernel that rely on the sam=
e
> behavior.

I'm not really sure about this.

I modified driver in the following way to test ring behavior better:
#define BGMAC_TX_RING_SLOTS 16
#define BGMAC_RX_RING_SLOTS 32
u8 start;
u8 end;

And then I added following code to bgmac.c for debugging:
if (ring->end < ring->start)
pr_info("ring->end:0x%08x ring->start:0x%02x (ring->end - ring->start
+ nr_frags + 1):%d\n", ring->end, ring->start, ring->end - ring->start
+ nr_frags + 1);

This is what I got:
[   35.516290] bgmac: ring->end:0x00000000 ring->start:0xfd (ring->end
- ring->start + nr_frags + 1):-252
[   58.058634] bgmac: ring->end:0x00000000 ring->start:0xff (ring->end
- ring->start + nr_frags + 1):-254
[   62.190323] bgmac: ring->end:0x00000000 ring->start:0xff (ring->end
- ring->start + nr_frags + 1):-254
[   71.659957] bgmac: ring->end:0x00000000 ring->start:0xff (ring->end
- ring->start + nr_frags + 1):-254
[   83.029964] bgmac: ring->end:0x00000000 ring->start:0xfe (ring->end
- ring->start + nr_frags + 1):-253
[   99.519693] bgmac: ring->end:0x00000000 ring->start:0xff (ring->end
- ring->start + nr_frags + 1):-254
[  105.751245] bgmac: ring->end:0x00000000 ring->start:0xfe (ring->end
- ring->start + nr_frags + 1):-253
[  139.006470] bgmac: ring->end:0x00000000 ring->start:0xfd (ring->end
- ring->start + nr_frags + 1):-252
[  143.496619] bgmac: ring->end:0x00000000 ring->start:0xfd (ring->end
- ring->start + nr_frags + 1):-252
