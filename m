From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Kernel Oops in UDP w/ ARM architecture
Date: Mon, 09 Mar 2009 22:19:35 +0100
Message-ID: <49B587E7.2060203@cosmosbay.com>
References: <93d1fdd10903090852g268b4141h31dc39a5848fcf32@mail.gmail.com>	 <49B54F00.5090706@cosmosbay.com>	 <93d1fdd10903091046w2d426226sfcb2a0d52c94a114@mail.gmail.com>	 <49B55E45.3040902@cosmosbay.com>	 <93d1fdd10903091218g17d65ea2r89a9b2a50fae7f11@mail.gmail.com>	 <49B57AEA.6000704@cosmosbay.com> <93d1fdd10903091357i51d2a883r45efeb662a6859eb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ron Yorgason <yorgasor@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:53988 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751444AbZCIVTn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 17:19:43 -0400
In-Reply-To: <93d1fdd10903091357i51d2a883r45efeb662a6859eb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ron Yorgason a =E9crit :
> On Mon, Mar 9, 2009 at 3:24 PM, Eric Dumazet <dada1@cosmosbay.com> wr=
ote:
>> Ron Yorgason a =E9crit :
>> - Show quoted text -
>>> On Mon, Mar 9, 2009 at 1:21 PM, Eric Dumazet <dada1@cosmosbay.com> =
wrote:
>>>> Please dont top post on this mailing list
>>>>
>>>> Ron Yorgason a =E9crit :
>>>>> We're using the fec driver, found in drivers/net/fec.c.  I modifi=
ed
>>>>> this driver slightly to get the MAC address from the redboot
>>>>> configuration stored in flash memory, but it's otherwise untouche=
d.  I
>>>>> can send my version of the file if that would help.
>>>>>
>>>>> --Ron
>>>>>
>>>>>
>>>> Given that ARM seems to be picky about non aligned accesses, you m=
ight
>>>> try this patch. This should force IP header to be aligned.
>>>>
>>>> diff -u linux-2.6.19/drivers/net/fec.c.old linux-2.6.19/drivers/ne=
t/fec.c
>>>> --- linux-2.6.19/drivers/net/fec.c.old
>>>> +++ linux-2.6.19/drivers/net/fec.c
>>>> @@ -641,13 +641,14 @@
>>>>         * include that when passing upstream as it messes up
>>>>         * bridging applications.
>>>>         */
>>>> -       skb =3D dev_alloc_skb(pkt_len-4);
>>>> +       skb =3D dev_alloc_skb((pkt_len - 4) + 2);
>>>>
>>>>        if (skb =3D=3D NULL) {
>>>>                printk("%s: Memory squeeze, dropping packet.\n", de=
v->name);
>>>>                fep->stats.rx_dropped++;
>>>>        } else {
>>>>                skb->dev =3D dev;
>>>> +               skb_reserve(skb, 2); /* Align IP on 16 byte bounda=
ries */
>>>>                skb_put(skb,pkt_len-4); /* Make room */
>>>>                eth_copy_and_sum(skb, data, pkt_len-4, 0);
>>>>                skb->protocol=3Deth_type_trans(skb,dev);
>>>>
>>>>
>>> Thanks for the patch.  It looks like Freescale modified this sectio=
n
>>> of the code in our BSP, so I'm looking at how to best merge things =
in.
>>>  Also, since we're allocating an extra 2 bytes in dev_alloc_skb(), =
do
>>> we need to account for those bytes in skb_put() and
>>> eth_copy_and_sum(), or does the skb_reserve() call handle that?
>> We allocate 2 extra bytes, because skb_reserve() will advance skb->d=
ata pointer
>> by two bytes. Those two bytes plus 14 bytes ethernet header : total =
16 bytes,
>> so that IP header is aligned on 16 byte boundaries.
>>
>> No other changes are necessary.
>>
>> Then, maybe this patch is not necessary at all on your platform, sin=
ce crash happens
>> a *long* time after boot. It may be a shoot in the dark...
>>
>>
>>
>=20
> The code as supplied by Freescale looks like this:
>=20
> 	if ((pkt_len - 4) < fec_copy_threshold) {
> 		skb =3D dev_alloc_skb(pkt_len);
> 	} else {
> 		skb =3D dev_alloc_skb(FEC_ENET_RX_FRSIZE);
> 	}
>=20
> 	if (skb =3D=3D NULL) {
> 		printk("%s: Memory squeeze, dropping packet.\n", dev->name);
> 		fep->stats.rx_dropped++;
> 	} else {
> 		if ((pkt_len - 4) < fec_copy_threshold) {
> 			skb_reserve(skb, 2);    /*skip 2bytes, so ipheader is align 4bytes=
*/
> 			skb_put(skb,pkt_len-4); /* Make room */
> 			eth_copy_and_sum(skb, (unsigned char *)data,
> 					pkt_len-4, 0);
> 		} else {
> 			struct sk_buff *pskb =3D fep->rx_skbuff[rx_index];
> 		=09
> 			fep->rx_skbuff[rx_index] =3D skb;
> 			skb->data =3D FEC_ADDR_ALIGNMENT(skb->data);
=2E..
> 			bdp->cbd_bufaddr =3D __pa(skb->data);
=2E..
>                         skb_put(pskb,pkt_len-4);        /* Make room =
*/
>                         skb =3D pskb;
>                 }
> 		skb->dev =3D dev;
> 		skb->protocol=3Deth_type_trans(skb,dev);
> 		netif_rx(skb);
> 	}
>=20
>=20
> fec_copy_threshold was defined with this comment:
> /*
>  *  fec_copy_threshold controls the copy when recieving ethernet fram=
e.
>  *     If ethernet header aligns 4bytes, the ip header and upper
> header will not aligns 4bytes.
>  *     The resean is ethernet header is 14bytes.
>  *     And the max size of tcp & ip header is 128bytes. Normally it i=
s 40bytes.
>  *     So I set the default value between 128 to 256.
>  */
> static int fec_copy_threshold =3D 192;
>=20
>=20
> And the FEC_ADDR_ALIGNMENT uses these definitions:
>=20
> ...
> #elif defined(CONFIG_ARCH_MXC)
> #include <asm/arch/hardware.h>
> #include <asm/arch/iim.h>
> #include "fec.h"
> #define FEC_ALIGNMENT  (0x0F)          /*FEC needs 128bits(32bytes) a=
lignment*/=09
> #else
> ...
>=20
> #define FEC_ADDR_ALIGNMENT(x) ((unsigned char *)(((unsigned long )(x)
> + (FEC_ALIGNMENT)) & (~FEC_ALIGNMENT)))
>=20
>=20
> It looks like for a packet smaller than 196 byes will get allocated
> with its actual size, but skb_reserve() skips 2 bytes and now it's a
> little short.  For a larger packet, they just allocate 2k, they're no=
t
> skipping 2 bytes and they're aligning the data but not the ip headers=
=2E
>  However, everything works 99.999% of the time, so I assume there's
> just some border condition that's not being covered correctly.
>=20
>=20

This driver seems bugy, and not part of standard kernel tree.

It should not change skb->data without changing skb->tail.
=46ortunatly, dev_alloc_skb() already provides an address with a 16byte=
s alignement
(unless patched by Freescale...)

I suggest you redefine fec_copy_threshold to 1600 to get back a working=
 driver.

My patch is not necessary on this driver (skb_reserve() already called)

