From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: prevent fib6_run_gc() contention
Date: Mon, 10 Jun 2013 14:26:42 -0700 (PDT)
Message-ID: <20130610.142642.161876882927700341.davem@davemloft.net>
References: <20130604111040.CCC9162CB4@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: mkubecek@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59990 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753702Ab3FJV0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 17:26:44 -0400
In-Reply-To: <20130604111040.CCC9162CB4@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kubecek <mkubecek@suse.cz>
Date: Tue, 4 Jun 2013 13:08:59 +0200

> On a high-traffic router with many processors and many IPv6 dst
> entries, soft lockup in fib6_run_gc() can occur when number of
> entries reaches gc_thresh.
> 
> This happens because fib6_run_gc() uses fib6_gc_lock to allow
> only one thread to run the garbage collector but ip6_dst_gc()
> doesn't update net->ipv6.ip6_rt_last_gc until fib6_run_gc()
> returns. On a system with many entries, this can take some time
> so that in the meantime, other threads pass the tests in
> ip6_dst_gc() (ip6_rt_last_gc is still not updated) and wait for
> the lock. They then have to run the garbage collector one after
> another which blocks them for quite long.
> 
> Resolve this by replacing special value ~0UL of expire parameter
> to fib6_run_gc() by explicit "force" parameter to choose between
> spin_lock_bh() and spin_trylock_bh() and call fib6_run_gc() with
> force=false if gc_thresh is reached but not max_size.
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

It seems to me that it would be much simpler to simply update
ip6_rt_last_gc first, that way the other threads would elide the GC
call.

Can you see if simply doing that fixes the problem too?

Thanks.
