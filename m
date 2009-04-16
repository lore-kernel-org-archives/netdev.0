From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock and RCU (v5)
Date: Thu, 16 Apr 2009 15:53:15 +0200
Message-ID: <49E7384B.5020707@trash.net>
References: <49E5BDF7.8090502@trash.net>	<20090415135526.2afc4d18@nehalam>	<49E64C91.5020708@cosmosbay.com>	<20090415.164811.19905145.davem@davemloft.net>	<20090415170111.6e1ca264@nehalam>	<alpine.LFD.2.00.0904151705120.4042@localhost.localdomain> <20090415174551.529d241c@nehalam> <49E6BBA9.2030701@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>, jeff.chua.linux@gmail.com,
	paulmck@linux.vnet.ibm.com, paulus@samba.org, mingo@elte.hu,
	laijs@cn.fujitsu.com, jengelh@medozas.de, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49E6BBA9.2030701@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Stephen Hemminger a =E9crit :
>> This is an alternative version of ip/ip6/arp tables locking using
>> per-cpu locks.  This avoids the overhead of synchronize_net() during
>> update but still removes the expensive rwlock in earlier versions.
>>
>> The idea for this came from an earlier version done by Eric Dumazet.
>> Locking is done per-cpu, the fast path locks on the current cpu
>> and updates counters.  The slow case involves acquiring the locks on
>> all cpu's. This version uses RCU for the table->base reference
>> but per-cpu-lock for counters.

> This version is a regression over 2.6.2[0-9], because of two points
>=20
> 1) Much more atomic ops :
>=20
> Because of additional
>=20
>> +			spin_lock(&__get_cpu_var(ip_tables_lock));
>>  			ADD_COUNTER(e->counters, ntohs(ip->tot_len), 1);
>> +			spin_unlock(&__get_cpu_var(ip_tables_lock));
>=20
> added on each counter updates.
>=20
> On many setups, each packet coming in or out of the machine has
> to update between 2 to 20 rule counters. So to avoid *one* atomic ops
> of read_unlock(), this v4 version adds 2 to 20 atomic ops...

I agree, this seems to be a step backwards.

> I still not see the problem between the previous version (2.6.2[0-8])=
 that had a central
>  rwlock, that hurted performance on SMP because of cache line ping po=
ng, and the solution
> having one rwlock per cpu.
>=20
> We wanted to reduce the cache line ping pong first. This *is* the hur=
ting point,
> by an order of magnitude.

Dave doesn't seem to like the rwlock approach. I don't see a way to
do anything asynchronously like call_rcu() to improve this, so to
bring up one of Stephens suggestions again:

>> >   * use on_each_cpu() somehow to do grace periood?

We could use this to replace the counters, presuming it is
indeed faster than waiting for a RCU grace period.

> 2) Second problem : Potential OOM
>=20
> About freeing old rules with call_rcu() and/or schedule_work(), this =
is going
> to OOM pretty fast on small appliances with basic firewall setups loa=
ding
> rules one by one, as done by original topic reporter.
>=20
> We had reports from guys using linux with 4MB of available ram (Frenc=
h provider free.fr on
> their applicance box), and we had to use SLAB_DESTROY_BY_RCU thing on=
 conntrack
>  to avoid OOM for their setups. We dont want to use call_rcu() and qu=
eue 100 or 200 vfree().

Agreed.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
