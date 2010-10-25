From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] Enhance AF_PACKET implementation to not require high
 order contiguous memory allocation
Date: Mon, 25 Oct 2010 19:35:58 -0400
Message-ID: <20101025233558.GA30118@hmsreliant.think-freely.org>
References: <E1PAVIx-0001qL-EB@smtp.tuxdriver.com>
 <1288045856.3296.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, jpirko@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55193 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758320Ab0JYXgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 19:36:19 -0400
Content-Disposition: inline
In-Reply-To: <1288045856.3296.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 26, 2010 at 12:30:56AM +0200, Eric Dumazet wrote:
> Le lundi 25 octobre 2010 =E0 18:14 -0400, nhorman@tuxdriver.com a =E9=
crit :
> > I think I remember those changes and IIrc yes,  tcpdump will make
> > several attempts to get buffers of an appropriate size.  But while =
it
> > tries to do that it bogs the system trying to write out pagecahe,
> > swap, etc.  And that activity doesn't guarantee success.  His does
> > either, but getting 5 order 0 pages is far easier and less intrusiv=
e
> > to a loaded system than trying to get 1 order 4 chunk.  That's all =
I'm
> > trying to accomplish here.  Just making it easier to use af_packet
> > sockets without interfering with system performance
> >=20
>=20
> Actually, using vmalloc() would probably hurt performance, because of
> extra TLB pressure.
>=20
> Of course, on recent x86 hardware you dont notice that much...
>=20
Exactly, you notice it a good deal less then you do the swapping that o=
ccurs if
you try to allocate a contiguous order 4 chunk of RAM.  That will bog d=
own the
system, even if the allocation ultimately fails.

> If not, why af_packet would use such convoluted double array of
> 'compound pages' ?
>=20
Gah!  Because I have blinders on, apparently.  The origional implementa=
tion used
a ring of pointer, and apparently I was so focused on keeping with that
implementation, it never occured to me to just use vmalloc.  That was s=
tupid of
me, I'll respin this and get rid of my idiocy.

> Also, on x86_32, vmalloc()/vmap() space is small (128 MB) so you migh=
t
> exhaust it pretty fast with several sniffers running.
>=20
You might, although (assuming no other significant users), 64K * 32 ~=3D=
 1.5Mb.
You could run 10 sniffers and only consume about 10-15% of the vmalloc =
space.=20

> I would try a two level thing : Try to get high order pages, and
> fallback on low order pages, but normally libpcap does this for us ?
>=20
>=20
It does, but it tries them in that order, which causes the problem I'm
describing, which is to say that attempting to get a large high order a=
llocation
causes the system to dig into swap and become unresponsive while it tri=
es to
assemble those allocations.  I would suggest a vmalloc, with a backoff =
to high
order allocation if that fails.

I'll post a new patch shortly.
Neil

>=20
>=20
