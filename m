From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU (v3)
Date: Fri, 17 Apr 2009 07:16:32 +0200
Message-ID: <49E810B0.9000906@cosmosbay.com>
References: <20090415170111.6e1ca264@nehalam>	<alpine.LFD.2.00.0904151705120.4042@localhost.localdomain>	<49E72E83.50702@trash.net>	<20090416.153354.170676392.davem@davemloft.net>	<20090416234955.GL6924@linux.vnet.ibm.com>	<20090417012812.GA25534@linux.vnet.ibm.com> <20090416215033.3e648a7a@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: paulmck@linux.vnet.ibm.com, David Miller <davem@davemloft.net>,
	kaber@trash.net, torvalds@linux-foundation.org,
	jeff.chua.linux@gmail.com, paulus@samba.org, mingo@elte.hu,
	laijs@cn.fujitsu.com, jengelh@medozas.de, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090416215033.3e648a7a@nehalam>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger a =E9crit :
> On Thu, 16 Apr 2009 18:28:12 -0700
> "Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:
>=20
>> On Thu, Apr 16, 2009 at 04:49:55PM -0700, Paul E. McKenney wrote:
>>> On Thu, Apr 16, 2009 at 03:33:54PM -0700, David Miller wrote:
>>>> From: Patrick McHardy <kaber@trash.net>
>>>> Date: Thu, 16 Apr 2009 15:11:31 +0200
>>>>
>>>>> Linus Torvalds wrote:
>>>>>> On Wed, 15 Apr 2009, Stephen Hemminger wrote:
>>>>>>> The counters are the bigger problem, otherwise we could just fr=
ee
>>>>>>> table
>>>>>>> info via rcu.  Do we really have to support: replace where the =
counter
>>>>>>> values coming out to user space are always exactly accurate, or=
 is it
>>>>>>> allowed to replace a rule and maybe lose some counter ticks (wo=
rst
>>>>>>> case
>>>>>>> NCPU-1).
>>>>>> Why not just read the counters fromt he old one at RCU free time=
 (they
>>>>>> are guaranteed to be stable at that point, since we're all done =
with
>>>>>> those entries), and apply them at that point to the current setu=
p?
>>>>> We need the counters immediately to copy them to userspace, so wa=
iting
>>>>> for an asynchronous RCU free is not going to work.
>>>> It just occurred to me that since all netfilter packet handling
>>>> goes through one place, we could have a sort-of "netfilter RCU"
>>>> of sorts to solve this problem.
>>> OK, I am putting one together...
>>>
>>> It will be needed sooner or later, though I suspect per-CPU locking
>>> would work fine in this case.
>> And here is a crude first cut.  Untested, probably does not even com=
pile.
>>
>> Straight conversion of Mathieu Desnoyers's user-space RCU implementa=
tion
>> at git://lttng.org/userspace-rcu.git to the kernel (and yes, I did h=
elp
>> a little, but he must bear the bulk of the guilt).  Pick on srcu.h
>> and srcu.c out of sheer laziness.  User-space testing gives deep
>> sub-microsecond grace-period latencies, so should be fast enough, at
>> least if you don't mind two smp_call_function() invocations per grac=
e
>> period and spinning on each instance of a per-CPU variable.
>>
>> Again, I believe per-CPU locking should work fine for the netfilter
>> counters, but I guess "friends don't let friends use hashed locks".
>> (I would not know for sure, never having used them myself, except of
>> course to protect hash tables.)
>>
>> Most definitely -not- for inclusion at this point.  Next step is to =
hack
>> up the relevant rcutorture code and watch it explode on contact.  ;-=
)
>>
>> Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
>=20
> I am glad to see this worked on, but would rather not use RCU in this=
 case
> of iptables. It would be good for some of the other long grace period=
 sutff.
>=20
> The code to per-cpu entry consolidation by alloc/flip in 2.6.30-rc2 w=
as
> hard to debug and more convoluted so it probably would be a long term=
 maintaince
> nightmare.  The issue was the variable size skip structure so it made
> for lots of iterators, etc. If the non-RCU per-cpu spinlock version i=
s just
> as fast, it is easier to understand.

I agree that for 2.6.30, we could use a per-cpu spinlock as your last p=
atch did,
this would be very risky to push this new RCU right now.=20

But this new stuff looks very promising, (no more locked ops on fast pa=
th),
and considering new percpu_{add|sub...} infra, very fast :

static inline void rcu_read_unlock_fgp(void)
{
	barrier();
	percpu_sub(rcu_fgp_active_readers, 1); /* one instruction on x86 */
	preempt_enable();
}

I wonder if IPI are really necessary on x86 if we use percpu_sub() sinc=
e
it already contains a barrier, and rcu_read_lock_fgp(void) also ends wi=
th
a barrier() call...

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
