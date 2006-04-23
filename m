From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Van Jacobson's net channels and real-time
Date: Sat, 22 Apr 2006 22:50:11 -0700 (PDT)
Message-ID: <20060422.225011.122273760.davem@davemloft.net>
References: <200604221529.59899.ioe-lkml@rameria.de>
	<20060422134956.GC6629@wohnheim.fh-wedel.de>
	<200604230205.33668.ioe-lkml@rameria.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: joern@wohnheim.fh-wedel.de, netdev@axxeo.de, simlo@phys.au.dk,
	linux-kernel@vger.kernel.org, mingo@elte.hu, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:16091
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751287AbWDWFub convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Apr 2006 01:50:31 -0400
To: ioe-lkml@rameria.de
In-Reply-To: <200604230205.33668.ioe-lkml@rameria.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Ingo Oeser <ioe-lkml@rameria.de>
Date: Sun, 23 Apr 2006 02:05:32 +0200

> On Saturday, 22. April 2006 15:49, J=F6rn Engel wrote:
> > That was another main point, yes.  And the endpoints should be as
> > little burden on the bottlenecks as possible.  One bottleneck is th=
e
> > receive interrupt, which shouldn't wait for cachelines from other c=
pus
> > too much.
>=20
> Thats right. This will be made a non issue with early demuxing
> on the NIC and MSI (or was it MSI-X?) which will select
> the right CPU based on hardware channels.

It is not clear that MSI'ing the RX interrupt to multiple cpus is the
answer.

Consider the fact that by doing so you're reducing the amount of batch
work each interrupt does by a factor N.  One of the biggest gains of
NAPI btw is that it batches patcket receive, if you don't believe the
benefits of this put a simply cycle counter sample around
netif_receive_skb() calls, and note the difference between the first
packet processed and subsequent ones, it's several orders of magnitude
faster to process subsequent packets within a batch.  I've done this
before on tg3 with sparc64 and posted the numbers on netdev about a
year or so ago.

If you are doing something like netchannels, it helps to batch so that
the demuxing table stays hot in the cpu cache.

There is even talk of dedicating a thread on enormously multi-
threaded cpus just to the NIC hardware interrupt, so it could net
channel to the socket processes running on the other strands.
