From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: prevent fib6_run_gc() contention
Date: Tue, 11 Jun 2013 13:01:14 -0700 (PDT)
Message-ID: <20130611.130114.764345999553478927.davem@davemloft.net>
References: <20130604111040.CCC9162CB4@unicorn.suse.cz>
	<20130610.142642.161876882927700341.davem@davemloft.net>
	<20130611100718.GA7581@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: mkubecek@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44859 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754684Ab3FKUBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 16:01:15 -0400
In-Reply-To: <20130611100718.GA7581@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kubecek <mkubecek@suse.cz>
Date: Tue, 11 Jun 2013 12:07:18 +0200

> On Mon, Jun 10, 2013 at 02:26:42PM -0700, David Miller wrote:
>> From: Michal Kubecek <mkubecek@suse.cz>
>> Date: Tue, 4 Jun 2013 13:08:59 +0200
>> 
>> > On a high-traffic router with many processors and many IPv6 dst
>> > entries, soft lockup in fib6_run_gc() can occur when number of
>> > entries reaches gc_thresh.
>> > 
>> > This happens because fib6_run_gc() uses fib6_gc_lock to allow
>> > only one thread to run the garbage collector but ip6_dst_gc()
>> > doesn't update net->ipv6.ip6_rt_last_gc until fib6_run_gc()
>> > returns. On a system with many entries, this can take some time
>> > so that in the meantime, other threads pass the tests in
>> > ip6_dst_gc() (ip6_rt_last_gc is still not updated) and wait for
>> > the lock. They then have to run the garbage collector one after
>> > another which blocks them for quite long.
>> > 
>> > Resolve this by replacing special value ~0UL of expire parameter
>> > to fib6_run_gc() by explicit "force" parameter to choose between
>> > spin_lock_bh() and spin_trylock_bh() and call fib6_run_gc() with
>> > force=false if gc_thresh is reached but not max_size.
>> > 
>> > Signed-off-by: Michal Kubecek <mkubecek@suse.cz>
>> 
>> It seems to me that it would be much simpler to simply update
>> ip6_rt_last_gc first, that way the other threads would elide the GC
>> call.
> 
> That was my original idea but I was afraid that while the remaining
> window in ip6_dst_gc() would be very short and probably safe, we could
> still run into problem if fib6_gc_lock was locked by some other caller
> of fib6_run_gc() which doesn't update net->ipv6.ip6_rt_last_gc,
> especially via a timer.

Why don't you simply try it and find out?
