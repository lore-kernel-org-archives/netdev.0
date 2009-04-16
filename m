From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU (v3)
Date: Thu, 16 Apr 2009 07:33:04 -0700
Message-ID: <20090416143303.GA6924@linux.vnet.ibm.com>
References: <49E5BDF7.8090502@trash.net> <20090415135526.2afc4d18@nehalam> <49E64C91.5020708@cosmosbay.com> <20090415.164811.19905145.davem@davemloft.net> <49E6CFB2.2020905@cosmosbay.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	kaber@trash.net, jeff.chua.linux@gmail.com, paulus@samba.org,
	mingo@elte.hu, torvalds@linux-foundation.org, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757132AbZDPOd3@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49E6CFB2.2020905@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 16, 2009 at 08:26:58AM +0200, Eric Dumazet wrote:
> David Miller a =E9crit :
> > From: Eric Dumazet <dada1@cosmosbay.com>
> > Date: Wed, 15 Apr 2009 23:07:29 +0200
> >=20
> >> Well, it seems original patch was not so bad after all
> >>
> >> http://lists.netfilter.org/pipermail/netfilter-devel/2006-January/=
023175.html
> >>
> >> So change per-cpu spinlocks to per-cpu rwlocks=20
> >>
> >> and use read_lock() in ipt_do_table() to allow recursion...
> >=20
> > Grumble, one more barrier to getting rid of rwlocks in the whole
> > tree. :-/
> >=20
> > I really think we should entertain the idea where we don't RCU quie=
sce
> > when adding rules.  That was dismissed as not workable because the =
new
> > rule must be "visible" as soon as we return to userspace but let's =
get
> > real, effectively it will be.
>=20
> We had to RCU quiesce to be sure old rules were not any more used bef=
ore
> freeing them. Alternative is to defer freeing via call_rcu() but
> subject to OOM.
>=20
> With 200 basic rules, size of rules table is about 40960 bytes per cp=
u.
> (88 pages taken on vmalloc virtual space on my 8 cpus machine)
> 0xfcaf8000-0xfcb03000   45056 xt_alloc_table_info+0xa8/0xd0 pages=3D1=
0 vmalloc
> 0xfcb04000-0xfcb0f000   45056 xt_alloc_table_info+0xa8/0xd0 pages=3D1=
0 vmalloc
> 0xfcb10000-0xfcb1b000   45056 xt_alloc_table_info+0xa8/0xd0 pages=3D1=
0 vmalloc
> 0xfcb1c000-0xfcb27000   45056 xt_alloc_table_info+0xa8/0xd0 pages=3D1=
0 vmalloc
> 0xfcb28000-0xfcb33000   45056 xt_alloc_table_info+0xa8/0xd0 pages=3D1=
0 vmalloc
> 0xfcb34000-0xfcb3f000   45056 xt_alloc_table_info+0xa8/0xd0 pages=3D1=
0 vmalloc
> 0xfcb40000-0xfcb4b000   45056 xt_alloc_table_info+0xa8/0xd0 pages=3D1=
0 vmalloc
> 0xfcb4c000-0xfcb57000   45056 xt_alloc_table_info+0xa8/0xd0 pages=3D1=
0 vmalloc
>=20
> This kind of monolithic huge object is hard to handle with RCU semant=
ic,
> more suitable for handling set of small objects (struct file for exam=
ple),
> even if RCU can have a backoff of 10000 elements in its queue...

To be honest, the per-CPU-locking approach looks pretty good to me for
this particular case.  That said, the problem you mention above does
have some straightforward solutions.

One solution to consider would be to do the call_rcu(), but to keep a
counter of the number of calls, perhaps something like the following:

	call_rcu(...);
	if (++count > 50) {
		synchronize_rcu();
		count =3D 0;
	}

Of course, you might (or might not) need to atomically increment count,
and you of course would want to replace the "50" with some symbolic
constant, or perhaps even a variable whose value might be determined by
the size of the object and/or the amount of memory available.

Would this help?

> > If there are any stale object reference issues, we can use RCU obje=
ct
> > destruction to handle that kind of thing.
> >=20
> > I almost cringed when the per-spinlock idea was proposed, but per-c=
pu
> > rwlocks just takes things too far for my tastes.
>=20
> In my humble opinion, this is a reasonnable compromise, and Stephen p=
atch
> version 4 is ok for me.

Again, the per-CPU-locking approach looks good to me, as well.

But if it turns out that we really do need an RCU implementation with
really short grace periods (tens of microseconds typical latency on
mid-range multiprocessors, those with SGI Altix systems would suffer
a bit more), then it can be done.  It would need to be yet another
implementation of RCU for the following reasons:

o	High update-side overhead (broadcast IPIs via
	smp_call_function().  This is not a problem in this case,
	but would be a showstopper for (say) dcache.  I don't know
	of any way of fixing this.

o	Defeats power-conservation measures by waking up every CPU
	at every grace period.	(Might be fixable, for example, by using
	the same dyntick tricks used by preemptable and hierarchical RCU.
	But not recommended for first implementation.)

o	Poor update-side scalability.  (Definitely fixable, but the
	fix should be to the underlying smp_call_function() primitives.)

o	No ability to share grace periods among concurrent
	synchronize_rcu() primitves.  (Definitely fixable, but not
	recommended until needed.  Unlikely to be needed -- after all,
	if your grace period completes in 10 microseconds, just how many
	concurrent updates do you expect there to be???)

o	No call_rcu() style primtive.  (Definitely fixable, but not
	recommended until needed.  Besides, if the grace period only
	takes a few tens of microseconds, why exactly do you need an
	asynchronous interface?

If this is needed, one good starting point would be Mathieu Desnoyers's
user-level RCU primitive.  The main change would be replacing the POSIX
signals with smp_call_function().

Yet again, I don't see a real problem with the per-CPU locking approach
in this case, but anything to prevent Dave Miller from having to suffer
the pain of hashed locks!  (Can't say that I have ever used hashed lock=
s
myself, but I could imagine that they might impose cache-thrashing and
deadlock issues.)

							Thanx, Paul
