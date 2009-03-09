From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Kernel Oops in UDP w/ ARM architecture
Date: Mon, 09 Mar 2009 21:24:10 +0100
Message-ID: <49B57AEA.6000704@cosmosbay.com>
References: <93d1fdd10903090852g268b4141h31dc39a5848fcf32@mail.gmail.com>	 <49B54F00.5090706@cosmosbay.com>	 <93d1fdd10903091046w2d426226sfcb2a0d52c94a114@mail.gmail.com>	 <49B55E45.3040902@cosmosbay.com> <93d1fdd10903091218g17d65ea2r89a9b2a50fae7f11@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ron Yorgason <yorgasor@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59568 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751743AbZCIUYR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 16:24:17 -0400
In-Reply-To: <93d1fdd10903091218g17d65ea2r89a9b2a50fae7f11@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ron Yorgason a =E9crit :
> On Mon, Mar 9, 2009 at 1:21 PM, Eric Dumazet <dada1@cosmosbay.com> wr=
ote:
>> Please dont top post on this mailing list
>>
>> Ron Yorgason a =E9crit :
>>> We're using the fec driver, found in drivers/net/fec.c.  I modified
>>> this driver slightly to get the MAC address from the redboot
>>> configuration stored in flash memory, but it's otherwise untouched.=
  I
>>> can send my version of the file if that would help.
>>>
>>> --Ron
>>>
>>>
>> Given that ARM seems to be picky about non aligned accesses, you mig=
ht
>> try this patch. This should force IP header to be aligned.
>>
>> diff -u linux-2.6.19/drivers/net/fec.c.old linux-2.6.19/drivers/net/=
fec.c
>> --- linux-2.6.19/drivers/net/fec.c.old
>> +++ linux-2.6.19/drivers/net/fec.c
>> @@ -641,13 +641,14 @@
>>         * include that when passing upstream as it messes up
>>         * bridging applications.
>>         */
>> -       skb =3D dev_alloc_skb(pkt_len-4);
>> +       skb =3D dev_alloc_skb((pkt_len - 4) + 2);
>>
>>        if (skb =3D=3D NULL) {
>>                printk("%s: Memory squeeze, dropping packet.\n", dev-=
>name);
>>                fep->stats.rx_dropped++;
>>        } else {
>>                skb->dev =3D dev;
>> +               skb_reserve(skb, 2); /* Align IP on 16 byte boundari=
es */
>>                skb_put(skb,pkt_len-4); /* Make room */
>>                eth_copy_and_sum(skb, data, pkt_len-4, 0);
>>                skb->protocol=3Deth_type_trans(skb,dev);
>>
>>
>=20
> Thanks for the patch.  It looks like Freescale modified this section
> of the code in our BSP, so I'm looking at how to best merge things in=
=2E
>  Also, since we're allocating an extra 2 bytes in dev_alloc_skb(), do
> we need to account for those bytes in skb_put() and
> eth_copy_and_sum(), or does the skb_reserve() call handle that?

We allocate 2 extra bytes, because skb_reserve() will advance skb->data=
 pointer
by two bytes. Those two bytes plus 14 bytes ethernet header : total 16 =
bytes,
so that IP header is aligned on 16 byte boundaries.

No other changes are necessary.

Then, maybe this patch is not necessary at all on your platform, since =
crash happens
a *long* time after boot. It may be a shoot in the dark...


