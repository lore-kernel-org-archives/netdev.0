From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Questions on kernel skb send / netdev queue monitoring
Date: Wed, 05 Nov 2008 19:30:57 +0100
Message-ID: <4911E661.6030701@cosmosbay.com>
References: <2009170231@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Andre Schwarz <andre.schwarz@matrix-vision.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:54946 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294AbYKESbL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 13:31:11 -0500
In-Reply-To: <2009170231@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andre Schwarz a =E9crit :
> Hi,
>=20
> we're running 2.6.27 on a MPC8343 based board.
> The board is working as a camera and is supposed to stream image data
> over 1000M Ethernet.
>=20
> Ethernet is connected via 2x Vitesse VSC8601 RGMII PHY, i.e. "eth0" a=
nd
> "eth1" present.
>=20
> Basically the system is running fine for quite some time - starting w=
ith
> kernel 2.6.19.
> Lately I have some trouble regarding performance and errors.
>=20
> Obviously I'm doing something wrong ... hopefully someone can enlight=
en me.
>=20
>=20
> How the system works :
>=20
> - Kernel driver allocates static list of skb to hold a complete image=
=2E
> This can be up to 4k skb depending on mtu.
> - Imaging device (FPGA @ PCI) initiates DMA into skb.
> - driver sends the skb out.
>=20
>=20
> 1. Sending
>=20
> This is my "inner loop" send function and is called for every skb in =
the
> list.
>=20
> static inline int gevss_send_get_ehdr(TGevStream *gevs, struct sk_buf=
f *skb)
> {
>         int result;
>         struct sk_buff *slow_skb =3D skb_clone(skb, GFP_ATOMIC);
>=20
>         atomic_inc(&slow_skb->users);
>         result =3D gevs->rt->u.dst.output(slow_skb);
>         kfree_skb(slow_skb);
>=20
>         return result;
> }
>=20
> Is there really any need for cloning each skb before sending ?
> I'd really like to send the static skb without consuming it. How can
> this be done ?
>=20

You have replied to yourself... you clone skb because you want to keep =
skb.

> Is "gevs->rt->u.dst.output(slow_skb)" reasonable ?
> What about "hard_start_xmit" and/or "dev_queue_xmit" inside netdev ?
> Are these functions supposed to be used by other drivers ?
>=20
> What result can I expect if there's a failure, i.e. the HW-queue is f=
ull ?
> How should this be handled ? retry,i.e. send again after a while ?
> Can I query the xmit queue size/usage ?
>=20
> Actually I'm checking for NETDEV_TX_OK and NETDEV_TX_BUSY.
> Is this reasonable ?
>=20
>=20
> 2. "overruns"
>=20
> I've never seen that before. The overrun counter is incrementing quit=
e
> fast even during proper operation.
> Looks like this is also an issue with not throttling the sender when =
the
> xmit queue is full ...  :-(=20
> How can I avoid this ?
>=20
> eth0      Link encap:Ethernet  HWaddr 00:0C:8D:30:40:25
>           inet addr:192.168.65.55  Bcast:192.168.65.255  Mask:255.255=
=2E255.0
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:929 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:180937 errors:0 dropped:0 overruns:54002 carrier=
:0  =20
>           collisions:0 txqueuelen:1000
>           RX bytes:65212 (63.6 KiB)  TX bytes:262068658 (249.9 MiB)
>           Base address:0xa000

If your driver has to push 4096 skb at once, and you dont want to handl=
e overruns,
you might need to change eth0 settings

ifconfig eth0 txqueuelen 5000


