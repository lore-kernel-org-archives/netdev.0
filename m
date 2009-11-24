From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: Re: [PATCH] irq: Add node_affinity CPU masks for smarter
 irqbalance hints
Date: Tue, 24 Nov 2009 11:53:14 -0800
Message-ID: <1259092394.2631.64.camel@ppwaskie-mobl2>
References: <1258995923.4531.715.camel@laptop>
	 <4B0B782A.4030901@linux.intel.com>	<1259051986.4531.1057.camel@laptop>
	 <20091124.093956.247147202.davem@davemloft.net>
	 <1259085412.2631.48.camel@ppwaskie-mobl2>  <4B0C2547.8030408@gmail.com>
	 <1259087601.2631.56.camel@ppwaskie-mobl2>  <4B0C2D85.7020200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"arjan@linux.intel.com" <arjan@linux.intel.com>,
	"yong.zhang0@gmail.com" <yong.zhang0@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"arjan@linux.jf.intel.com" <arjan@linux.jf.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932572AbZKXTxH@vger.kernel.org>
In-Reply-To: <4B0C2D85.7020200@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-11-24 at 11:01 -0800, Eric Dumazet wrote:
> Peter P Waskiewicz Jr a =C3=A9crit :
>=20
> > That's exactly what we're doing in our 10GbE driver right now (isn'=
t
> > pushed upstream yet, still finalizing our testing).  We spread to a=
ll
> > NUMA nodes in a semi-intelligent fashion when allocating our rings =
and
> > buffers.  The last piece is ensuring the interrupts tied to the var=
ious
> > queues all route to the NUMA nodes those CPUs belong to.  irqbalanc=
e
> > needs some kind of hint to make sure it does the right thing, which
> > today it does not.
>=20
> sk_buff allocations should be done on the node of the cpu handling rx=
 interrupts.

Yes, but we preallocate the buffers to minimize overhead when running
our interrupt routines.  Regardless, whatever queue we're filling with
those sk_buff's has an interrupt vector attached.  So wherever the
descriptor ring/queue and its associated buffers were allocated, that i=
s
where the interrupt's affinity needs to be set to.

> For rings, I am ok for irqbalance and driver cooperation, in case adm=
in
>  doesnt want to change the defaults.
>=20
> >=20
> > I don't see how this is complex though.  Driver loads, allocates ac=
ross
> > the NUMA nodes for optimal throughput, then writes CPU masks for th=
e
> > NUMA nodes each interrupt belongs to.  irqbalance comes along and l=
ooks
> > at the new mask "hint," and then balances that interrupt within tha=
t
> > hinted mask.
>=20
> So NUMA policy is given by the driver at load time ?

I think it would have to.  Nobody else has insight how the driver
allocated its resources.  So the driver can be told where to allocate
(see below), or the driver needs to indicate upwards how it allocated
resources.

> An admin might chose to direct all NIC trafic to a given node, becaus=
e
> its machine has mixed workload. 3 nodes out of 4 for database workloa=
d,
> one node for network IO...
>=20
> So if an admin changes smp_affinity, is your driver able to reconfigu=
re itself
> and re-allocate all its rings to be on NUMA node chosen by admin ? Th=
is is
> what I qualify as complex.

No, we don't want to go this route of reallocation.  This, I agree, is
very complex, and can be very devastating.  We'd basically be resetting
the driver whenever an interrupt moved, so this could be a terrible DoS
vulnerability.

Jesse Brandeburg has a set of patches he's working on that will allow u=
s
to bind an interface to a single node.  So in your example of 3 nodes
for DB workload and 1 for network I/O, the driver can be loaded and
directly bound to that 4th node.  Then the node_affinity mask would be
set by the driver for the CPU mask of that single node.  But in these
deployments, a sysadmin changing affinity that will fly directly in the
face of how resources are laid out is poor system administration.  I
know it will happen, but I don't know how far we need to protect the
sysadmin from shooting themselves in the foot in terms of performance
tuning.

Cheers,
-PJ
