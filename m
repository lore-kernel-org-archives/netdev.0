From: Ron Yorgason <yorgasor@gmail.com>
Subject: Re: Kernel Oops in UDP w/ ARM architecture
Date: Mon, 9 Mar 2009 15:57:37 -0500
Message-ID: <93d1fdd10903091357i51d2a883r45efeb662a6859eb@mail.gmail.com>
References: <93d1fdd10903090852g268b4141h31dc39a5848fcf32@mail.gmail.com>
	 <49B54F00.5090706@cosmosbay.com>
	 <93d1fdd10903091046w2d426226sfcb2a0d52c94a114@mail.gmail.com>
	 <49B55E45.3040902@cosmosbay.com>
	 <93d1fdd10903091218g17d65ea2r89a9b2a50fae7f11@mail.gmail.com>
	 <49B57AEA.6000704@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f122.google.com ([209.85.221.122]:63304 "EHLO
	mail-qy0-f122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752002AbZCIU5u convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 16:57:50 -0400
Received: by qyk28 with SMTP id 28so1330432qyk.33
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2009 13:57:47 -0700 (PDT)
In-Reply-To: <49B57AEA.6000704@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 9, 2009 at 3:24 PM, Eric Dumazet <dada1@cosmosbay.com> wrot=
e:
> Ron Yorgason a =E9crit :
> - Show quoted text -
>> On Mon, Mar 9, 2009 at 1:21 PM, Eric Dumazet <dada1@cosmosbay.com> w=
rote:
>>> Please dont top post on this mailing list
>>>
>>> Ron Yorgason a =E9crit :
>>>> We're using the fec driver, found in drivers/net/fec.c. =A0I modif=
ied
>>>> this driver slightly to get the MAC address from the redboot
>>>> configuration stored in flash memory, but it's otherwise untouched=
=2E =A0I
>>>> can send my version of the file if that would help.
>>>>
>>>> --Ron
>>>>
>>>>
>>> Given that ARM seems to be picky about non aligned accesses, you mi=
ght
>>> try this patch. This should force IP header to be aligned.
>>>
>>> diff -u linux-2.6.19/drivers/net/fec.c.old linux-2.6.19/drivers/net=
/fec.c
>>> --- linux-2.6.19/drivers/net/fec.c.old
>>> +++ linux-2.6.19/drivers/net/fec.c
>>> @@ -641,13 +641,14 @@
>>> =A0 =A0 =A0 =A0 * include that when passing upstream as it messes u=
p
>>> =A0 =A0 =A0 =A0 * bridging applications.
>>> =A0 =A0 =A0 =A0 */
>>> - =A0 =A0 =A0 skb =3D dev_alloc_skb(pkt_len-4);
>>> + =A0 =A0 =A0 skb =3D dev_alloc_skb((pkt_len - 4) + 2);
>>>
>>> =A0 =A0 =A0 =A0if (skb =3D=3D NULL) {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk("%s: Memory squeeze, dropping=
 packet.\n", dev->name);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fep->stats.rx_dropped++;
>>> =A0 =A0 =A0 =A0} else {
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb->dev =3D dev;
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_reserve(skb, 2); /* Align IP on 1=
6 byte boundaries */
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb_put(skb,pkt_len-4); /* Make room=
 */
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0eth_copy_and_sum(skb, data, pkt_len-=
4, 0);
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb->protocol=3Deth_type_trans(skb,d=
ev);
>>>
>>>
>>
>> Thanks for the patch. =A0It looks like Freescale modified this secti=
on
>> of the code in our BSP, so I'm looking at how to best merge things i=
n.
>> =A0Also, since we're allocating an extra 2 bytes in dev_alloc_skb(),=
 do
>> we need to account for those bytes in skb_put() and
>> eth_copy_and_sum(), or does the skb_reserve() call handle that?
>
> We allocate 2 extra bytes, because skb_reserve() will advance skb->da=
ta pointer
> by two bytes. Those two bytes plus 14 bytes ethernet header : total 1=
6 bytes,
> so that IP header is aligned on 16 byte boundaries.
>
> No other changes are necessary.
>
> Then, maybe this patch is not necessary at all on your platform, sinc=
e crash happens
> a *long* time after boot. It may be a shoot in the dark...
>
>
>

The code as supplied by Freescale looks like this:

	if ((pkt_len - 4) < fec_copy_threshold) {
		skb =3D dev_alloc_skb(pkt_len);
	} else {
		skb =3D dev_alloc_skb(FEC_ENET_RX_FRSIZE);
	}

	if (skb =3D=3D NULL) {
		printk("%s: Memory squeeze, dropping packet.\n", dev->name);
		fep->stats.rx_dropped++;
	} else {
		if ((pkt_len - 4) < fec_copy_threshold) {
			skb_reserve(skb, 2);    /*skip 2bytes, so ipheader is align 4bytes*/
			skb_put(skb,pkt_len-4); /* Make room */
			eth_copy_and_sum(skb, (unsigned char *)data,
					pkt_len-4, 0);
		} else {
			struct sk_buff *pskb =3D fep->rx_skbuff[rx_index];
		=09
			fep->rx_skbuff[rx_index] =3D skb;
			skb->data =3D FEC_ADDR_ALIGNMENT(skb->data);
			bdp->cbd_bufaddr =3D __pa(skb->data);
                        skb_put(pskb,pkt_len-4);        /* Make room */
                        skb =3D pskb;
                }
		skb->dev =3D dev;
		skb->protocol=3Deth_type_trans(skb,dev);
		netif_rx(skb);
	}


fec_copy_threshold was defined with this comment:
/*
 *  fec_copy_threshold controls the copy when recieving ethernet frame.
 *     If ethernet header aligns 4bytes, the ip header and upper
header will not aligns 4bytes.
 *     The resean is ethernet header is 14bytes.
 *     And the max size of tcp & ip header is 128bytes. Normally it is =
40bytes.
 *     So I set the default value between 128 to 256.
 */
static int fec_copy_threshold =3D 192;


And the FEC_ADDR_ALIGNMENT uses these definitions:

=2E..
#elif defined(CONFIG_ARCH_MXC)
#include <asm/arch/hardware.h>
#include <asm/arch/iim.h>
#include "fec.h"
#define FEC_ALIGNMENT  (0x0F)          /*FEC needs 128bits(32bytes) ali=
gnment*/=09
#else
=2E..

#define FEC_ADDR_ALIGNMENT(x) ((unsigned char *)(((unsigned long )(x)
+ (FEC_ALIGNMENT)) & (~FEC_ALIGNMENT)))


It looks like for a packet smaller than 196 byes will get allocated
with its actual size, but skb_reserve() skips 2 bytes and now it's a
little short.  For a larger packet, they just allocate 2k, they're not
skipping 2 bytes and they're aligning the data but not the ip headers.
 However, everything works 99.999% of the time, so I assume there's
just some border condition that's not being covered correctly.
