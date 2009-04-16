From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock and RCU (v5)
Date: Thu, 16 Apr 2009 07:47:48 -0700
Message-ID: <20090416144748.GB6924@linux.vnet.ibm.com>
References: <49E5BDF7.8090502@trash.net> <20090415135526.2afc4d18@nehalam> <49E64C91.5020708@cosmosbay.com> <20090415.164811.19905145.davem@davemloft.net> <20090415170111.6e1ca264@nehalam> <alpine.LFD.2.00.0904151705120.4042@localhost.localdomain> <20090415174551.529d241c@nehalam> <49E6BBA9.2030701@cosmosbay.com> <49E7384B.5020707@trash.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>, jeff.chua.linux@gmail.com,
	paulus@samba.org, mingo@elte.hu, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49E7384B.5020707@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 16, 2009 at 03:53:15PM +0200, Patrick McHardy wrote:
> Eric Dumazet wrote:
>> Stephen Hemminger a =E9crit :
>>> This is an alternative version of ip/ip6/arp tables locking using
>>> per-cpu locks.  This avoids the overhead of synchronize_net() durin=
g
>>> update but still removes the expensive rwlock in earlier versions.
>>>
>>> The idea for this came from an earlier version done by Eric Dumazet=
=2E
>>> Locking is done per-cpu, the fast path locks on the current cpu
>>> and updates counters.  The slow case involves acquiring the locks o=
n
>>> all cpu's. This version uses RCU for the table->base reference
>>> but per-cpu-lock for counters.
>
>> This version is a regression over 2.6.2[0-9], because of two points
>> 1) Much more atomic ops :
>> Because of additional
>>> +			spin_lock(&__get_cpu_var(ip_tables_lock));
>>>  			ADD_COUNTER(e->counters, ntohs(ip->tot_len), 1);
>>> +			spin_unlock(&__get_cpu_var(ip_tables_lock));
>> added on each counter updates.
>> On many setups, each packet coming in or out of the machine has
>> to update between 2 to 20 rule counters. So to avoid *one* atomic op=
s
>> of read_unlock(), this v4 version adds 2 to 20 atomic ops...
>
> I agree, this seems to be a step backwards.
>
>> I still not see the problem between the previous version (2.6.2[0-8]=
) that=20
>> had a central
>>  rwlock, that hurted performance on SMP because of cache line ping p=
ong,=20
>> and the solution
>> having one rwlock per cpu.
>> We wanted to reduce the cache line ping pong first. This *is* the hu=
rting=20
>> point,
>> by an order of magnitude.
>
> Dave doesn't seem to like the rwlock approach.

Well, we don't really need an rwlock, especially given that we really
don't want two "readers" incrementing the same counter concurrently.

A safer approach would be to maintain a flag in the task structure
tracking which (if any) of the per-CPU locks you hold.  Also maintain
a recursion-depth counter.  If the flag says you don't already hold
the lock, set it and acquire the lock.  Either way, increment the
recursion-depth counter:

	if (current->netfilter_lock_held !=3D cur_cpu) {
		BUG_ON(current->netfilter_lock_held !=3D CPU_NONE);
		spin_lock(per_cpu(..., cur_cpu));
		current->netfilter_lock_held =3D cur_cpu;
	}
	current->netfilter_lock_nesting++;

And reverse the process to unlock:

	if (--current->netfilter_lock_nesting =3D=3D 0) {
		spin_unlock(per_cpu(..., cur_cpu));
		current->netfilter_lock_held =3D CPU_NONE;
	}

>                                                I don't see a way to
> do anything asynchronously like call_rcu() to improve this, so to
> bring up one of Stephens suggestions again:
>
>>> >   * use on_each_cpu() somehow to do grace periood?
>
> We could use this to replace the counters, presuming it is
> indeed faster than waiting for a RCU grace period.

One way to accomplish this is to take Mathieu Desnoyers's user-level
RCU implementation and drop it into the kernel, replacing the POSIX
signal handling with on_each_cpu(), smp_call_function(), or whatever.

>> 2) Second problem : Potential OOM
>> About freeing old rules with call_rcu() and/or schedule_work(), this=
 is=20
>> going
>> to OOM pretty fast on small appliances with basic firewall setups lo=
ading
>> rules one by one, as done by original topic reporter.
>> We had reports from guys using linux with 4MB of available ram (Fren=
ch=20
>> provider free.fr on
>> their applicance box), and we had to use SLAB_DESTROY_BY_RCU thing o=
n=20
>> conntrack
>>  to avoid OOM for their setups. We dont want to use call_rcu() and q=
ueue=20
>> 100 or 200 vfree().
>
> Agreed.

This is not a real problem be handled by doing a synchronize_rcu() ever=
y
so often as noted in a prior email elsewhere in this thread:

	call_rcu(...);
	if (++count > 50) {
		synchronize_rcu();
		count =3D 0;
	}

This choice of constant would reduce the grace-period pain to 2% of the
full effect, which should be acceptable, at least if I remember the
original problem report of 0.2 seconds growing to 6.0 seconds -- this
would give you:

	(6.0-0.2)/50+0.2 =3D .316

I would argue that 100 milliseconds is an OK penalty for a deprecated
feature.  But of course the per-CPU lock approach should avoid even tha=
t
penalty, albeit at some per-packet penalty.  However, my guess is that
this per-packet penalty is not measureable at the system level.

And if the penalty of a single uncontended lock -is- measureable, I wil=
l
be very quick to offer my congratulations, at least once I get my jaw
off my keyboard.  ;-)

							Thanx, Paul
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
