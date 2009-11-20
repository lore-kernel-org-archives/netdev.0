From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: Xmit Packet Steering (XPS)
Date: Fri, 20 Nov 2009 06:08:29 +0100
Message-ID: <4B06244D.9060004@gmail.com>
References: <4B05D8DC.7020907@gmail.com> <65634d660911191641o4210a797mf1e8168dd8dd8b60@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33165 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750803AbZKTFIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 00:08:31 -0500
In-Reply-To: <65634d660911191641o4210a797mf1e8168dd8dd8b60@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert a =E9crit :
>=20
>=20
> On Thu, Nov 19, 2009 at 3:46 PM, Eric Dumazet <eric.dumazet@gmail.com
> <mailto:eric.dumazet@gmail.com>> wrote:
>=20
>     Here is first version of XPS.
>=20
> Very cool!  The infrastructure to move lists of skb's from cpu to
> another and the IPI to kick processing look like something that could=
 be
> consolidated between rps and xps :-)

Sure, but RPS seems quite slow to integrate (no offense Tom) :)
I wanted to cook a patch on top on yours, but got no sign you were
about to release RPS version 4 soon.

>=20
>     Goal of XPS is to free TX completed skbs by the cpu that submitte=
d
>     the transmit.
>=20
>     Because I chose to union skb->iif with skb->sending_cpu, I chose
>     to introduce a new xps_consume_skb(skb), and not generalize
>     consume_skb() itself.
>=20
>     This means that selected drivers must use new function to benefit
>     from XPS
>=20
>=20
> Is this better than modifying consume_skb so this can be used by any =
driver?

consume_skb() is also used by RX side, and this side doesnt want XPS.

Adding a flag in skb to differentiate the use might be possible,
but we add a new test in hot paths...

> =20
>=20
>     =20
>=20
>     Preliminary tests are quite good, especially on NUMA machines.
>=20
>     Only NAPI drivers can use this new infrastructure (xps_consume_sk=
b()
>     cannot
>     be called from hardirq context, only from softirq)
>=20
> Is this a strict requirement, especially considering devices with
> separate TX interrupts?  For a hardirq we could we just put the skb o=
n
> local percpu queue and schedule a softirq to do the ipi.

I chose this way because any sane and up2date driver should really
not use hardirqs TX completion. I want fast processing, without
masking local interrupts in xps_consume_skb(), and wihout testing
our context.

Note : if TX completion and RX are run in different NAPI contexts,
there is no problem using xps_consume_skb().


Thanks for reviewing Tom.
