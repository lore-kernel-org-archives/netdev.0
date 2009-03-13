From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: [RFC v2: Patch 1/3] net: hand off skb list to other cpu to
	submit to upper layer
Date: Fri, 13 Mar 2009 17:06:47 +0800
Message-ID: <1236935207.2567.559.camel@ymzhang>
References: <1236761624.2567.442.camel@ymzhang>
	 <877i2wfh1l.fsf@basil.nowhere.org> <1236845792.2567.484.camel@ymzhang>
	 <20090312143427.GJ11935@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	herbert@gondor.apana.org.au, jesse.brandeburg@intel.com,
	shemminger@vyatta.com, David Miller <davem@davemloft.net>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:12581 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757639AbZCMJHS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 05:07:18 -0400
In-Reply-To: <20090312143427.GJ11935@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-03-12 at 15:34 +0100, Andi Kleen wrote:
> On Thu, Mar 12, 2009 at 04:16:32PM +0800, Zhang, Yanmin wrote:
> >=20
> > > Seems very inconvenient to have to configure this by hand.
> > A little, but not too much, especially when we consider there is in=
terrupt binding.
>=20
> Interrupt binding is something popular for benchmarks, but most users
> don't (and shouldn't need to) care. Having it work well out of the bo=
x
> without special configuration is very important.
Thanks Andi. You tell the truth. Now I understand why David Miller is w=
orking
on auto TX selection.

One thing I want to clarify is, with the default configuration, the pro=
cessing path
still goes to current automation selection. That means my method has li=
ttle impact
on current automation selection with default configuration, except a sm=
all cache miss.
Another exception is IXGBE prefers to getting one packet and sending on=
e packet
immediately instead of backlog.

Even when turning on the new capability to separate packet receiving an=
d packet
processing, TX selection is still following current automatic selection=
=2E The difference
is we use different cpu. Driver still could record RX number into skb w=
hich is used
when sending out.

>=20
> >=20
> > >  How about
> > > auto selecting one that shares the same LLC or somesuch?
> > There are 2 kinds of LLC sharing here.
> > 1) RX/TX share the LLC;
> > 2) All RX share the LLC of some cpus and TX share the LLC of other =
cpus.
> >=20
> > Item 1) is important, but sometimes item 2) is also important when =
the sending speed is
> > very high and huge data is on flight which flushes cpu cache quickl=
y.
> > It's hard to distinguish the 2 different scenarioes automatically.
>=20
> Why is it hard if you know the CPUs?
RX binding depends on interrupt binding totally. If the MSI-X interrupt=
 is sent to cpu A,
cpu A will collect the packets on the RX queue. By default, interrupt i=
sn't bound.=20
=EF=BB=BFSoftware knows the LLC sharing of cpu A. If cpu A receives the=
 interrupt, it couldn't just
throw packets to other cpus which share its LLC, because it doesn't kno=
w whether other cpus
are collecting packets from other RX queues now.

>=20
> > >  and just use the hash function on the
> > > NIC.
> > Sorry. I can't understand what the hash function of NIC is. Perhaps=
 NIC hardware has something
> > like hash function to decide the RX queue number based on SRC/DST?
>=20
> There's a Microsoft spec for a standard hash function that does this
> on NICs and all the serious ones support it these days. The hash=20
> is normally used to select a MSI-X target based on the input header.
Thanks for the explanation. The capability defined by the spec is to ch=
oose
a MSI-X number and provides a hint when sending a cloned packet out. Do=
es the NIC
know how cpu is busy? I assume not. So the hash is trying to distribute=
 packets
into RX queues evenly while also avoiding reorder.=20

We might say irqbalance could balance workload so we expect cpu workloa=
d is
even. My testing shows such evenly distribution of packets on all cpu i=
sn't
good at performance.

>=20
> I think if that works your manual target shouldn't be necessary.
Here are 2 targets with my method. The one is packet collecting cpu and=
 the other
is packet processing cpu.=20
As NIC doesn't know how busy cpu is, why can't we separate the processi=
ng?

>=20
> > >  The trick here would
> > > be to try to avoid reordering inside streams as far as possible,
> > It's not to solve reorder issue. The start point is 10G NIC is very=
 fast. We need some cpu
>=20
> Point was that any solution shouldn't add more reordering. But when a=
 RSS
> hash is used there is no reordering on stream basis.
Yes.

Thanks again.

Yanmin


