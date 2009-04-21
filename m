From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v11)
Date: Tue, 21 Apr 2009 14:52:30 +0800
Message-ID: <49ED6D2E.5060808@cn.fujitsu.com>
References: <alpine.LFD.2.00.0904151705120.4042@localhost.localdomain>	<49E72E83.50702@trash.net>	<20090416.153354.170676392.davem@davemloft.net>	<20090416234955.GL6924@linux.vnet.ibm.com>	<20090417012812.GA25534@linux.vnet.ibm.com>	<20090418094001.GA2369@ioremap.net>	<20090418141455.GA7082@linux.vnet.ibm.com>	<20090420103414.1b4c490f@nehalam>	<49ECBE0A.7010303@cosmosbay.com>	<18924.59347.375292.102385@cargo.ozlabs.ibm.com>	<20090420215827.GK6822@linux.vnet.ibm.com>	<18924.64032.103954.171918@cargo.ozlabs.ibm.com>	<20090420160121.268a8226@nehalam>	<49ED406F.2040401@cn.fujitsu.com>	<49ED4407.8010200@cosmosbay.com>	<49ED5813.1000803@cn.fujitsu.com> <20090420224540.30d7b0ed@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	torvalds@linux-foundation.org, jeff.chua.linux@gmail.com,
	mingo@elte.hu, jengelh@medozas.de, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61488 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751088AbZDUGzH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Apr 2009 02:55:07 -0400
In-Reply-To: <20090420224540.30d7b0ed@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
>> xt_info_rdlock_bh() called recursively here will enter the
>> critical region without &__get_cpu_var(xt_info_locks)->lock.
> 
> NO spin_lock_bh always does a preempt_disable
> 
>   xt_info_rdlock_bh            (depth = -1)
> +1         preempt_disable
>            spin_lock_bh
> +1             preempt_disable
> -1         preempt_enable_no_resched
> ---
> +1
> 
> Second call preempt_count=1   (depth = 0)
>        xt_info_rdlock_bh
> +1         preempt_disable
> -1         preempt_enable_no_resched
> ---
> 

I think I had made you mistook my email.

The preempt_count is correct, but I thought about lock-save:
we must hold &__get_cpu_var(xt_info_locks)->lock
when we enter the read-side critical region.

--------------------
xt_info_rdlock_bh() (depth = -1)
  preempt_disable()
  depth++
  ==========>interrupt here
  ==========>
  ==========>xt_info_rdlock_bh() (depth = 0)
  ==========>  preempt_disable()
  ==========>  depth++
  ==========>  preempt_enable_no_resched()
  ==========>
  ==========>enter the read-side critical region *without* lock.
  ==========>  it may get trashy data.
  ==========>
  ==========>xt_info_rdunlock_bh()
  ==========>
  ==========>interrupt return.
  spin_lock_bh()
  preempt_enable_no_resched()

enter the read-side critical region *with* lock.

xt_info_rdunlock_bh().
----------------------

So I asked:
> +void xt_info_rdlock_bh(void)
> > +{
> > +	struct xt_info_lock *lock;
> > +
> > +	preempt_disable();
> > +	lock = &__get_cpu_var(xt_info_locks);
> > +	if (likely(++lock->depth == 0))

So what happen when xt_info_rdlock_bh() called recursively here?

> > +		spin_lock_bh(&lock->lock);
> > +	preempt_enable_no_resched();
> > +}
> > +EXPORT_SYMBOL_GPL(xt_info_rdlock_bh);
> > +

----------
Is this OK? (Now I suppose we can enter the read-side critical region
in irq context)

void xt_info_rdlock_bh(void)
{
	unsigned long flags;
	struct xt_info_lock *lock;

	local_irq_save(flags);
	lock = &__get_cpu_var(xt_info_locks);
	if (likely(++lock->depth == 0))
		spin_lock_bh(&lock->lock);
	local_irq_restore(flags);
}

Lai

