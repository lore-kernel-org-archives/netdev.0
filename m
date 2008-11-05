From: Andre Schwarz <andre.schwarz@matrix-vision.de>
Subject: Questions on kernel skb send / netdev queue monitoring
Date: Wed, 05 Nov 2008 18:53:23 +0100
Message-ID: <2009170231@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate04.web.de ([217.72.192.242]:39353 "EHLO
	fmmailgate04.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753004AbYKERx0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 12:53:26 -0500
Received: from web.de
	by fmmailgate04.web.de (Postfix) with SMTP id D4BAF5F3C22D
	for <netdev@vger.kernel.org>; Wed,  5 Nov 2008 18:53:24 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

we're running 2.6.27 on a MPC8343 based board.
The board is working as a camera and is supposed to stream image data
over 1000M Ethernet.

Ethernet is connected via 2x Vitesse VSC8601 RGMII PHY, i.e. "eth0" and
"eth1" present.

Basically the system is running fine for quite some time - starting wit=
h
kernel 2.6.19.
Lately I have some trouble regarding performance and errors.

Obviously I'm doing something wrong ... hopefully someone can enlighten=
 me.


How the system works :

- Kernel driver allocates static list of skb to hold a complete image.
This can be up to 4k skb depending on mtu.
- Imaging device (FPGA @ PCI) initiates DMA into skb.
- driver sends the skb out.


1. Sending

This is my "inner loop" send function and is called for every skb in th=
e
list.

static inline int gevss_send_get_ehdr(TGevStream *gevs, struct sk_buff =
*skb)
{
        int result;
        struct sk_buff *slow_skb =3D skb_clone(skb, GFP_ATOMIC);

        atomic_inc(&slow_skb->users);
        result =3D gevs->rt->u.dst.output(slow_skb);
        kfree_skb(slow_skb);

        return result;
}

Is there really any need for cloning each skb before sending ?
I'd really like to send the static skb without consuming it. How can
this be done ?

Is "gevs->rt->u.dst.output(slow_skb)" reasonable ?
What about "hard_start_xmit" and/or "dev_queue_xmit" inside netdev ?
Are these functions supposed to be used by other drivers ?

What result can I expect if there's a failure, i.e. the HW-queue is ful=
l ?
How should this be handled ? retry,i.e. send again after a while ?
Can I query the xmit queue size/usage ?

Actually I'm checking for NETDEV_TX_OK and NETDEV_TX_BUSY.
Is this reasonable ?


2. "overruns"

I've never seen that before. The overrun counter is incrementing quite
fast even during proper operation.
Looks like this is also an issue with not throttling the sender when th=
e
xmit queue is full ...  :-(=20
How can I avoid this ?

eth0      Link encap:Ethernet  HWaddr 00:0C:8D:30:40:25
          inet addr:192.168.65.55  Bcast:192.168.65.255  Mask:255.255.2=
55.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:929 errors:0 dropped:0 overruns:0 frame:0
          TX packets:180937 errors:0 dropped:0 overruns:54002 carrier:0=
  =20
          collisions:0 txqueuelen:1000
          RX bytes:65212 (63.6 KiB)  TX bytes:262068658 (249.9 MiB)
          Base address:0xa000




Any help is welcome.

regards,
Andre

____________________________________________________________________
Psssst! Schon vom neuen WEB.DE MultiMessenger geh=F6rt?=20
Der kann`s mit allen: http://www.produkte.web.de/messenger/?did=3D3123

