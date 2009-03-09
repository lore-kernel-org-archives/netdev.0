From: Ron Yorgason <yorgasor@gmail.com>
Subject: Re: Kernel Oops in UDP w/ ARM architecture
Date: Mon, 9 Mar 2009 14:18:24 -0500
Message-ID: <93d1fdd10903091218g17d65ea2r89a9b2a50fae7f11@mail.gmail.com>
References: <93d1fdd10903090852g268b4141h31dc39a5848fcf32@mail.gmail.com>
	 <49B54F00.5090706@cosmosbay.com>
	 <93d1fdd10903091046w2d426226sfcb2a0d52c94a114@mail.gmail.com>
	 <49B55E45.3040902@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f122.google.com ([209.85.221.122]:38344 "EHLO
	mail-qy0-f122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751162AbZCITS3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 15:18:29 -0400
Received: by qyk28 with SMTP id 28so1280611qyk.33
        for <netdev@vger.kernel.org>; Mon, 09 Mar 2009 12:18:26 -0700 (PDT)
In-Reply-To: <49B55E45.3040902@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 9, 2009 at 1:21 PM, Eric Dumazet <dada1@cosmosbay.com> wrot=
e:
> Please dont top post on this mailing list
>
> Ron Yorgason a =E9crit :
>> We're using the fec driver, found in drivers/net/fec.c. =A0I modifie=
d
>> this driver slightly to get the MAC address from the redboot
>> configuration stored in flash memory, but it's otherwise untouched. =
=A0I
>> can send my version of the file if that would help.
>>
>> --Ron
>>
>>
>
> Given that ARM seems to be picky about non aligned accesses, you migh=
t
> try this patch. This should force IP header to be aligned.
>
> diff -u linux-2.6.19/drivers/net/fec.c.old linux-2.6.19/drivers/net/f=
ec.c
> --- linux-2.6.19/drivers/net/fec.c.old
> +++ linux-2.6.19/drivers/net/fec.c
> @@ -641,13 +641,14 @@
> =A0 =A0 =A0 =A0 * include that when passing upstream as it messes up
> =A0 =A0 =A0 =A0 * bridging applications.
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 skb =3D dev_alloc_skb(pkt_len-4);
> + =A0 =A0 =A0 skb =3D dev_alloc_skb((pkt_len - 4) + 2);
>
> =A0 =A0 =A0 =A0if (skb =3D=3D NULL) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk("%s: Memory squeeze, dropping p=
acket.\n", dev->name);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0fep->stats.rx_dropped++;
> =A0 =A0 =A0 =A0} else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb->dev =3D dev;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb_reserve(skb, 2); /* Align IP on 16 =
byte boundaries */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb_put(skb,pkt_len-4); /* Make room *=
/
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0eth_copy_and_sum(skb, data, pkt_len-4,=
 0);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb->protocol=3Deth_type_trans(skb,dev=
);
>
>

Thanks for the patch.  It looks like Freescale modified this section
of the code in our BSP, so I'm looking at how to best merge things in.
 Also, since we're allocating an extra 2 bytes in dev_alloc_skb(), do
we need to account for those bytes in skb_put() and
eth_copy_and_sum(), or does the skb_reserve() call handle that?

Ron
