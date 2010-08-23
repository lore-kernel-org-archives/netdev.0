From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] Fix deadlock between boomerang_interrupt and
 boomerang_start_tx in 3c59x
Date: Mon, 23 Aug 2010 19:41:44 -0400
Message-ID: <20100823234006.GA8976@hmsreliant.think-freely.org>
References: <20100811151257.GB23317@hmsreliant.think-freely.org>
 <1282593694.2378.230.camel@edumazet-laptop>
 <20100823202452.GC12906@hmsreliant.think-freely.org>
 <1282596538.2378.340.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53361 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752140Ab0HWXrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 19:47:24 -0400
Content-Disposition: inline
In-Reply-To: <1282596538.2378.340.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 23, 2010 at 10:48:58PM +0200, Eric Dumazet wrote:
> Le lundi 23 ao=FBt 2010 =E0 16:24 -0400, Neil Horman a =E9crit :
>=20
> >=20
> > Faster I agree with, although I'm not sure if speed is really a big=
 issue here,
> > given that this is a ancient (but fairly well used) 10/100 adapter.=
  And we
> > still have space in the octet that that bitfield is living in, so I=
 figured I'd
> > use that anyway.
> >=20
> > As for safe, I'm not sure I follow you on that point.  Is there som=
ething
> > inherently dangerous about using a bitfield in this case?
> >=20
>=20
> A bitfield is not SMP safe.
>=20
> Are you sure another cpu is not changing another bit, using a non ato=
mic
> RMW sequence, and your bit change is lost ?
>=20
> Quite tricky to check I suppose, so just add an "int" ;)
>=20
>=20
>=20
>=20

Ah, I see what your saying.  Since bitfield access is not a single inst=
ruction
you get races when multiple accesses take place at once, since the assi=
gnment is
non-atomic, nor is the read.

In this case, thats ok.  I say that because in the only time we really =
care what
the value of this bitfield is, is when we've recursed from the interrup=
t handler
to the netconsole module, back into the transmit path on the same cpu. =
 In that
case the read is guaranteed to be ordered after the write, since its a =
linear
code path.  In the case where cpu 0 is in the interrupt handler and cpu=
1 is
going into the transmit method for this driver, we don't really care wh=
at the
value of the bitfield is, its a don't care.  If we read it as a zero, t=
hats ok,
we have the driver-internal sempahore still protecting us (the one that
deadlocks if you recurse via netconsole on the same cpu).  And if we re=
ad it as
a 1, thats ok too, because we simply cause the network scheduler to que=
ue the
frame and send it again as soon as we're out of the interrupt handler.

Theres still the size vs. speed issue with the conversion to int though=
=2E  I
figured since it was already using bitfields in lots of places, there w=
ouldn't
be much performance impact.  But if you feel really strongly about it, =
let me
know, and I'll make the conversion.

Neil


