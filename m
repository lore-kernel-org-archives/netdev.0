From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v11)
Date: Tue, 21 Apr 2009 13:22:23 +0400
Message-ID: <20090421092223.GA19049@ioremap.net>
References: <20090420215827.GK6822@linux.vnet.ibm.com> <18924.64032.103954.171918@cargo.ozlabs.ibm.com> <20090420160121.268a8226@nehalam> <49ED406F.2040401@cn.fujitsu.com> <49ED4407.8010200@cosmosbay.com> <49ED5813.1000803@cn.fujitsu.com> <20090420224540.30d7b0ed@nehalam> <49ED6D2E.5060808@cn.fujitsu.com> <20090421081649.GA16782@ioremap.net> <49ED8A1F.7090506@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	torvalds@linux-foundation.org, jeff.chua.linux@gmail.com,
	mingo@elte.hu, jengelh@medozas.de, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kandzendo.ru ([195.178.208.66]:45991 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752852AbZDUJWZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Apr 2009 05:22:25 -0400
Content-Disposition: inline
In-Reply-To: <49ED8A1F.7090506@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 21, 2009 at 10:55:59AM +0200, Eric Dumazet (dada1@cosmosbay.com) wrote:
> Maybe just dont care about calling several time local_bh_disable()
> (since we were doing this in previous kernels anyway, we used to call read_lock_bh())
> 
> This shortens fastpath, is faster than local_irq_save()/local_irq_restore(),
> and looks better.

Yeah, given that non-nested locking is more likely condition, it will be
even faster than preemption case.

> void xt_info_rdlock_bh(void)
> {
> 	struct xt_info_lock *lock;
> 
> 	local_bh_disable();
>  	lock = &__get_cpu_var(xt_info_locks);
>  	if (likely(++lock->depth == 0))
>  		spin_lock(&lock->lock);
> }
> 
> void xt_info_rdunlock_bh(void)
> {
> 	struct xt_info_lock *lock = &__get_cpu_var(xt_info_locks);
> 
> 	BUG_ON(lock->depth < 0);
> 	if (likely(--lock->depth < 0))
> 		 spin_unlock(&lock->lock);
> 	local_bh_enable();
> }
> 
> 

-- 
	Evgeniy Polyakov
