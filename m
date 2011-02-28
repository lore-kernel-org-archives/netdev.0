From: Thomas Graf <tgraf@infradead.org>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Mon, 28 Feb 2011 11:37:42 -0500
Message-ID: <20110228163742.GH9763@canuck.infradead.org>
References: <20110225.112019.48513284.davem@davemloft.net>
 <20110226005718.GA19889@gondor.apana.org.au>
 <20110227110205.GE9763@canuck.infradead.org>
 <20110227110614.GA6246@gondor.apana.org.au>
 <20110228113659.GA20726@gondor.apana.org.au>
 <20110228141322.GF9763@canuck.infradead.org>
 <1298910174.2941.585.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:53193 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755565Ab1B1Qhs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 11:37:48 -0500
Content-Disposition: inline
In-Reply-To: <1298910174.2941.585.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 28, 2011 at 05:22:54PM +0100, Eric Dumazet wrote:
> Le lundi 28 f=E9vrier 2011 =E0 09:13 -0500, Thomas Graf a =E9crit :
> > On Mon, Feb 28, 2011 at 07:36:59PM +0800, Herbert Xu wrote:
> > > But please do test them heavily, especially if you have an AMD
> > > NUMA machine as that's where scalability problems really show
> > > up.  Intel tends to be a lot more forgiving.  My last AMD machine
> > > blew up years ago :)
> >=20
> > This is just a preliminary test result and not 100% reliable
> > because half through the testing the machine reported memory
> > issues and disabled a DIMM before booting the tested kernels.
> >=20
> > Nevertheless, bind 9.7.3:
> >=20
> > 2.6.38-rc5+: 62kqps
> > 2.6.38-rc5+ w/ Herbert's patch: 442kqps
> >=20
> > This is on a 2 NUMA Intel Xeon X5560 @ 2.80GHz with 16 cores
> >=20
> > Again, this number is not 100% reliably but clearly shows that
> > the concept of the patch is working very well.
> >=20
> > Will test Herbert's patch on the machine that did 650kqps with
> > SO_REUSEPORT and also on some AMD machines.
> > --
>=20
> I suspect your queryperf input file hits many zones ?

No, we use a simple example.com zone with host[1-4] A records
resolving to 10.[1-4].0.1

> With a single zone, my machine is able to give 250kps : most of the t=
ime
> is consumed in bind code, dealing with rwlocks and false sharing
> things...
>=20
> (bind-9.7.2-P3)
> Using two remote machines to perform queries, on bnx2x adapter, RSS
> enabled : two cpus receive UDP frames for the same socket, so we also
> hit false sharing in kernel receive path.

How do you measure the qps? The output of queryperf? That is not always
accurate. I run rdnc stats twice and then calculate the qps based on th=
e
counter "queries resulted in successful answer" diff and timestamp diff=
=2E

The numbers differ a lot depending on the architecture we test on.

=46.e. on a 12 core AMD with 2 NUMA nodes:

2.6.32   named -n 1: 37.0kqps
         named:       3.8kqps (yes, no joke, the socket receive buffer =
is
                               always full and the kernel drops pkts)

2.6.38-rc5+ with Herbert's patches:
        named -n 1:  36.9kqps
        named:      222.0kqps
