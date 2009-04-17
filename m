From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] netfilter: per-cpu spin-lock with recursion (v0.8)
Date: Fri, 17 Apr 2009 07:55:37 +0200
Message-ID: <1239947737.23397.4018.camel@laptop>
References: <20090415170111.6e1ca264@nehalam>
	 <alpine.LFD.2.00.0904151705120.4042@localhost.localdomain>
	 <49E72E83.50702@trash.net> <20090416.153354.170676392.davem@davemloft.net>
	 <20090416234955.GL6924@linux.vnet.ibm.com>
	 <20090416165233.5d8bbfb5@nehalam>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, David Miller <davem@davemloft.net>,
	kaber@trash.net, torvalds@linux-foundation.org,
	dada1@cosmosbay.com, jeff.chua.linux@gmail.com, paulus@samba.org,
	mingo@elte.hu, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:49045 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752251AbZDQF4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 01:56:20 -0400
In-Reply-To: <20090416165233.5d8bbfb5@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-04-16 at 16:52 -0700, Stephen Hemminger wrote:

>   - Lockdep doesn't really handle this well

> +/**
> + * xt_table_info_lock_all - lock xt table info for update
> + *
> + * Locks out all readers, and blocks bottom half
> + */
> +void xt_table_info_lock_all(void)
> +{
> +	int i;
> +
> +	local_bh_disable();
> +	for_each_possible_cpu(i) {
> +		struct xt_lock *lock = &per_cpu(xt_info_locks, i);
> +		spin_lock(&lock->lock);
> +		BUG_ON(lock->depth != -1);
> +	}
> +}
> +EXPORT_SYMBOL_GPL(xt_table_info_lock_all);

Quite so, this is the old MAX_LOCK_DEPTH < NR_CPUS issue for large
systems.

Last time this came up David found another way of solving the problem.
Not having fully read this thread, I cannot suggest one myself -- except
that RCU domains as suggested by David sound good.



