From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU (v3)
Date: Thu, 16 Apr 2009 22:40:32 -0700
Message-ID: <20090417054032.GD6885@linux.vnet.ibm.com>
References: <20090415170111.6e1ca264@nehalam> <alpine.LFD.2.00.0904151705120.4042@localhost.localdomain> <49E72E83.50702@trash.net> <20090416.153354.170676392.davem@davemloft.net> <20090416234955.GL6924@linux.vnet.ibm.com> <20090417012812.GA25534@linux.vnet.ibm.com> <20090416215033.3e648a7a@nehalam> <49E810B0.9000906@cosmosbay.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	torvalds@linux-foundation.org, jeff.chua.linux@gmail.com,
	paulus@samba.org, mingo@elte.hu, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49E810B0.9000906@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 17, 2009 at 07:16:32AM +0200, Eric Dumazet wrote:
> Stephen Hemminger a =E9crit :
> > On Thu, 16 Apr 2009 18:28:12 -0700
> > "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
> >=20
> >> On Thu, Apr 16, 2009 at 04:49:55PM -0700, Paul E. McKenney wrote:
> >>> On Thu, Apr 16, 2009 at 03:33:54PM -0700, David Miller wrote:
> >>>> From: Patrick McHardy <kaber@trash.net>
> >>>> Date: Thu, 16 Apr 2009 15:11:31 +0200
> >>>>
> >>>>> Linus Torvalds wrote:
> >>>>>> On Wed, 15 Apr 2009, Stephen Hemminger wrote:
> >>>>>>> The counters are the bigger problem, otherwise we could just =
free
> >>>>>>> table
> >>>>>>> info via rcu.  Do we really have to support: replace where th=
e counter
> >>>>>>> values coming out to user space are always exactly accurate, =
or is it
> >>>>>>> allowed to replace a rule and maybe lose some counter ticks (=
worst
> >>>>>>> case
> >>>>>>> NCPU-1).
> >>>>>> Why not just read the counters fromt he old one at RCU free ti=
me (they
> >>>>>> are guaranteed to be stable at that point, since we're all don=
e with
> >>>>>> those entries), and apply them at that point to the current se=
tup?
> >>>>> We need the counters immediately to copy them to userspace, so =
waiting
> >>>>> for an asynchronous RCU free is not going to work.
> >>>> It just occurred to me that since all netfilter packet handling
> >>>> goes through one place, we could have a sort-of "netfilter RCU"
> >>>> of sorts to solve this problem.
> >>> OK, I am putting one together...
> >>>
> >>> It will be needed sooner or later, though I suspect per-CPU locki=
ng
> >>> would work fine in this case.
> >> And here is a crude first cut.  Untested, probably does not even c=
ompile.
> >>
> >> Straight conversion of Mathieu Desnoyers's user-space RCU implemen=
tation
> >> at git://lttng.org/userspace-rcu.git to the kernel (and yes, I did=
 help
> >> a little, but he must bear the bulk of the guilt).  Pick on srcu.h
> >> and srcu.c out of sheer laziness.  User-space testing gives deep
> >> sub-microsecond grace-period latencies, so should be fast enough, =
at
> >> least if you don't mind two smp_call_function() invocations per gr=
ace
> >> period and spinning on each instance of a per-CPU variable.
> >>
> >> Again, I believe per-CPU locking should work fine for the netfilte=
r
> >> counters, but I guess "friends don't let friends use hashed locks"=
=2E
> >> (I would not know for sure, never having used them myself, except =
of
> >> course to protect hash tables.)
> >>
> >> Most definitely -not- for inclusion at this point.  Next step is t=
o hack
> >> up the relevant rcutorture code and watch it explode on contact.  =
;-)
> >>
> >> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> >=20
> > I am glad to see this worked on, but would rather not use RCU in th=
is case
> > of iptables. It would be good for some of the other long grace peri=
od sutff.
> >=20
> > The code to per-cpu entry consolidation by alloc/flip in 2.6.30-rc2=
 was
> > hard to debug and more convoluted so it probably would be a long te=
rm maintaince
> > nightmare.  The issue was the variable size skip structure so it ma=
de
> > for lots of iterators, etc. If the non-RCU per-cpu spinlock version=
 is just
> > as fast, it is easier to understand.
>=20
> I agree that for 2.6.30, we could use a per-cpu spinlock as your last=
 patch did,
> this would be very risky to push this new RCU right now.=20

I completely agree that this RCU is absolutely -not- 2.6.30 material.  =
;-)

> But this new stuff looks very promising, (no more locked ops on fast =
path),
> and considering new percpu_{add|sub...} infra, very fast :
>=20
> static inline void rcu_read_unlock_fgp(void)
> {
> 	barrier();
> 	percpu_sub(rcu_fgp_active_readers, 1); /* one instruction on x86 */
> 	preempt_enable();
> }

Very cool!!!  If I had seen this, I had forgotten about it.  I will
give it a try, but only after getting it working the old way.  (What,
me paranoid?)

> I wonder if IPI are really necessary on x86 if we use percpu_sub() si=
nce
> it already contains a barrier, and rcu_read_lock_fgp(void) also ends =
with
> a barrier() call...

Hmmmm...  But x86 can still execute a later load before an earlier
store, so it seems to me that there would be the potential for even
an x86 CPU to pull loads from the critical section up before the final
store of the percpu_sub(), right?  If so, we really do still need the
IPIs on x86.

							Thanx, Paul
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
