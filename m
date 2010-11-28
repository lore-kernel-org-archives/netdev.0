From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] kthread: NUMA aware kthread_create_on_cpu()
Date: Sun, 28 Nov 2010 23:51:51 +0100
Message-ID: <1290984712.29196.100.camel@edumazet-laptop>
References: <1290972833.29196.90.camel@edumazet-laptop>
	 <20101128224024.GA12300@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101128224024.GA12300@basil.fritz.box>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le dimanche 28 novembre 2010 =C3=A0 23:40 +0100, Andi Kleen a =C3=A9cri=
t :
> On Sun, Nov 28, 2010 at 08:33:53PM +0100, Eric Dumazet wrote:
> > @@ -101,7 +103,15 @@ static int kthread(void *_create)
> >  static void create_kthread(struct kthread_create_info *create)
> >  {
> >  	int pid;
> > -
> > +	static int last_cpu_pref =3D -1;
> > +
> > +	if (create->cpu !=3D last_cpu_pref) {
>=20
> Is that actually thread-safe?

Yes, we use one dedicated task to create all kthreads.

This task runs kthreadd(void *unused) in kernel/kthread.c

This only duty is to create tasks.


>=20
> > +void numa_cpubind_policy(int cpu)
> > +{
> > +	nodemask_t mask;
> > +
> > +	init_nodemask_of_node(&mask, cpu_to_node(cpu));
> > +	do_set_mempolicy(MPOL_BIND, 0, &mask);
>=20
> You don't want bind, you want preferred, otherwise this
> will explode if the node is empty.
>=20

OK thanks, I'll test the patch with BIND or PREFERRED on x86_32 mode
since I have one machine with two sockets, 2GB on each socket, so 2nd
node only have HIGHMEM, no LOWMEM.

> Also this messes up the policy of the caller process. You really
> need to save/restore it.

Well, caller process duty is to create kthreads in a loop.

>=20
> And if the slab is configured for slab interleaving in
> the cpuset this will be ignored I think.
>=20



> Also I think the slab fast path ignores the policy anyways,
> the policy only acts when slab has to grab new pages.
> Are you sure this works at all?
>=20

It works on x86 at least, I tested this patch and got correct stacks fo=
r
pktgen and ksoftirqd kthreads for sure.

> It would be probably better to pass through the node
> to the low level allocation functions and use them
> there directly.
>=20

It would be difficult, because do_fork() is arch dependant

> Problem is that this ends up in architecture specific code
> for the stack, so may be a larger patch.

I suggest arches that need slab to allocate kthread stacks do the
appropriate changes, because I am not able to make them myself.

On x86, we use page allocator only, so NUMA mempolicy is used.
