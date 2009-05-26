From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: Re: [PATCH RFC] v7 expedited "big hammer" RCU grace periods
Date: Tue, 26 May 2009 09:03:55 +0800
Message-ID: <4A1B3FFB.7090306@cn.fujitsu.com>
References: <20090522190525.GA13286@linux.vnet.ibm.com> <4A1A3C23.8090004@cn.fujitsu.com> <20090525164446.GD7168@linux.vnet.ibm.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63456 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752524AbZEZBHo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 May 2009 21:07:44 -0400
In-Reply-To: <20090525164446.GD7168@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Paul E. McKenney wrote:
> 
> Good point -- I should at the very least add a comment to
> synchronize_sched_expedited() stating that it cannot be called holding
> any lock that is acquired in a CPU hotplug notifier.  If this restriction
> causes any problems, then your approach seems like a promising fix.


Reviewed-by: Lai Jiangshan <laijs@cn.fujitsu.com>

> 
>> The coupling of synchronize_sched_expedited() and migration_req
>> is largely increased:
>>
>> 1) The offline cpu's per_cpu(rcu_migration_req, cpu) is handled.
>>    See migration_call::CPU_DEAD
> 
> Good.  ;-)
> 
>> 2) migration_call() is the highest priority of cpu notifiers,
>>    So even any other cpu notifier calls synchronize_sched_expedited(),
>>    It'll not cause DEADLOCK.
> 
> You mean if using your preempt_disable() approach, right?  Unless I am
> missing something, the current get_online_cpus() approach would deadlock
> in this case.
> 

Yes, I mean if using my preempt_disable() approach. The current
get_online_cpus() approach would NOT deadlock in this case also,
we can require get_online_cpus() in cpu notifiers.

> diff --git a/include/linux/rcupreempt.h b/include/linux/rcupreempt.h
> index fce5227..78117ed 100644
> --- a/include/linux/rcupreempt.h
> +++ b/include/linux/rcupreempt.h
> @@ -74,6 +74,16 @@ extern int rcu_needs_cpu(int cpu);
>  
>  extern void __synchronize_sched(void);
>  
> +static inline void synchronize_rcu_expedited(void)
> +{
> +	synchronize_rcu();  /* Placeholder for new rcupreempt implementation. */
> +}
> +
> +static inline void synchronize_rcu_bh_expedited(void)
> +{
> +	synchronize_rcu();  /* Placeholder for new rcupreempt implementation. */
> +}
> +

Why not synchronize_rcu_bh() ?

In mainline, rcu_read_lock_bh() is not preemptable,
So I think synchronize_sched_expedited() is better.

Anyway, synchronize_rcu() is OK for me, because it is
"Placeholder for new rcupreempt implementation".

Lai

