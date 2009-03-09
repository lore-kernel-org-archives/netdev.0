From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Kernel Oops in UDP w/ ARM architecture
Date: Mon, 09 Mar 2009 19:21:57 +0100
Message-ID: <49B55E45.3040902@cosmosbay.com>
References: <93d1fdd10903090852g268b4141h31dc39a5848fcf32@mail.gmail.com>	 <49B54F00.5090706@cosmosbay.com> <93d1fdd10903091046w2d426226sfcb2a0d52c94a114@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ron Yorgason <yorgasor@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60982 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751928AbZCISWH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 14:22:07 -0400
In-Reply-To: <93d1fdd10903091046w2d426226sfcb2a0d52c94a114@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please dont top post on this mailing list

Ron Yorgason a =E9crit :
> We're using the fec driver, found in drivers/net/fec.c.  I modified
> this driver slightly to get the MAC address from the redboot
> configuration stored in flash memory, but it's otherwise untouched.  =
I
> can send my version of the file if that would help.
>=20
> --Ron
>=20
>=20

Given that ARM seems to be picky about non aligned accesses, you might
try this patch. This should force IP header to be aligned.

diff -u linux-2.6.19/drivers/net/fec.c.old linux-2.6.19/drivers/net/fec=
=2Ec
--- linux-2.6.19/drivers/net/fec.c.old
+++ linux-2.6.19/drivers/net/fec.c
@@ -641,13 +641,14 @@
         * include that when passing upstream as it messes up
         * bridging applications.
         */
-       skb =3D dev_alloc_skb(pkt_len-4);
+       skb =3D dev_alloc_skb((pkt_len - 4) + 2);

        if (skb =3D=3D NULL) {
                printk("%s: Memory squeeze, dropping packet.\n", dev->n=
ame);
                fep->stats.rx_dropped++;
        } else {
                skb->dev =3D dev;
+               skb_reserve(skb, 2); /* Align IP on 16 byte boundaries =
*/
                skb_put(skb,pkt_len-4); /* Make room */
                eth_copy_and_sum(skb, data, pkt_len-4, 0);
                skb->protocol=3Deth_type_trans(skb,dev);

