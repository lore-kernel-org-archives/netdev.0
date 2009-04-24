From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: Re: [PATCH RFC] v1 expedited "big hammer" RCU grace periods
Date: Fri, 24 Apr 2009 08:39:26 +0800
Message-ID: <49F10A3E.3030102@cn.fujitsu.com>
References: <20090423052520.GA13036@linux.vnet.ibm.com> <49F006AE.5040104@cn.fujitsu.com> <20090423151509.GB6877@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, mingo@elte.hu,
	akpm@linux-foundation.org, torvalds@linux-foundation.org,
	davem@davemloft.net, dada1@cosmosbay.com, zbr@ioremap.net,
	jeff.chua.linux@gmail.com, paulus@samba.org, jengelh@medozas.de,
	r000n@r000n.net, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: paulmck@linux.vnet.ibm.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090423151509.GB6877@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul E. McKenney wrote:
> On Thu, Apr 23, 2009 at 02:11:58PM +0800, Lai Jiangshan wrote:
>> Paul E. McKenney wrote:
> 
> [ . . . ]
> 
>> Hi, Paul
>>
>> I just typed codes in email, very like these two pathes:
>>
>> [PATCH 1/2] sched: Introduce APIs for waiting multi events
>> http://lkml.org/lkml/2009/4/14/733
>>
>> [PATCH 2/2] rcupdate: use struct ref_completion
>> http://lkml.org/lkml/2009/4/14/734
>>
>> Lai.
>> --------------
> 
> Interesting approach!  This would get a second use for your multi-events
> waiting code above.  ;-)
> 
> Looks like the idea is to have the task doing the
> synchronize_rcu_bh_expedited() hold a reference across the process,
> and have each rcu_bh_fast_qs() also acquire a reference, which would
> be released in the softirq handler synchronize_rcu_bh_expedited_help().
> 
> One question -- does this approach correctly handle all the CPU hotplug
> scenarios?  (I think that it might, but am not completely certain.)
> 
> 							Thanx, Paul

Ah, raise_softirq(RCU_EXPEDITED_SOFTIRQ) can not ensure the softirq
will be called when hotplug.

It needs get_online_cpus() and put_online_cpus().

> 
>> #ifndef CONFIG_SMP
>>
>> static void __init synchronize_rcu_expedited_init(void)
>> {
>> }
>>
>> void synchronize_rcu_bh_expedited(void)
>> {
>> 	cond_resched();
>> }
>>
>> #else /* #ifndef CONFIG_SMP */
>>
>> static DEFINE_MUTEX(synchronize_rcu_bh_mutex);
>> static DEFINE_PER_CPU(int, call_only_once); /* is it need ? */
>> static struct ref_completion rcu_bh_expedited_completion
>>
>> static void synchronize_rcu_bh_expedited_help(struct softirq_action *unused)
>> {
>> 	if (__get_cpu_var(call_only_once)) {
>> 		smp_mb();
>> 		ref_completion_put(&rcu_bh_expedited_completion);
>> 		__get_cpu_var(call_only_once) = 0;
>> 	}
>> }
>>
>> static void rcu_bh_fast_qs(void *unused)
>> {
>> 	__get_cpu_var(call_only_once) = 1;
>> 	ref_completion_get(&rcu_bh_expedited_completion);
>> 	raise_softirq(RCU_EXPEDITED_SOFTIRQ);
>> }
>>
>> static void __init synchronize_rcu_expedited_init(void)
>> {
>> 	open_softirq(RCU_EXPEDITED_SOFTIRQ, synchronize_rcu_bh_expedited_help);
>> }
>>
>> void synchronize_rcu_bh_expedited(void)
>> {
>> 	mutex_lock(&synchronize_rcu_bh_mutex);
>>
>> 	ref_completion_get_init(&rcu_bh_expedited_completion);
>>
>> 	smp_call_function(rcu_bh_fast_qs, NULL, 1);
>>
>> 	ref_completion_put_init(&rcu_bh_expedited_completion);
>> 	ref_completion_wait(&rcu_bh_expedited_completion);
>>
>> 	mutex_unlock(&synchronize_rcu_bh_mutex);
>> }
>>
>> #endif /* #else #ifndef CONFIG_SMP */
>>
> 
> 
> 


