From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: BUG ? ipip unregister_netdevice_many()
Date: Wed, 13 Oct 2010 22:20:28 -0700
Message-ID: <m162x5492h.fsf@fess.ebiederm.org>
References: <m11v801tfr.fsf@fess.ebiederm.org>
	<20101012.130520.48517464.davem@davemloft.net>
	<m1fww94ca6.fsf@fess.ebiederm.org>
	<20101013.215013.104074480.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hans.schillstrom@ericsson.com, daniel.lezcano@free.fr,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:60583 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754578Ab0JNFuW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 01:50:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Wed, 13 Oct 2010 21:40:49 -0700
>
>> However I think the test should still be rt_is_expired(), because
>> that is what rt_do_flush() is doing removing the expired entries
>> from the list.
>
> I can't see a reason for that test.
>
> Everything calling into this code path has created a condition
> that requires that all routing cache entries for that namespace
> be deleted.
>
> This function is meant to unconditionally flush the entire table.
>
> I believe you added that extraneous test, and it never existed there
> before.

At the point network namespaces entered the picture the logic was:

	void rt_cache_flush(struct net *net, int delay)
	{
		rt_cache_invalidate();
		if (delay >= 0)
			rt_do_flush(!in_softirq());
	}
	
	/* Strictly speaking rt_is_expired was just open coded in
	 * rt_check_expire. But this is the check that was used.
	 */
	static inline int rt_is_expired(struct rtable *rth)
	{
		return rth->rt_genid != atomic_read(&rt_genid);
	}
	
	static void rt_cache_invalidate(void)
	{
	        unsigned char shuffle;
	 
		get_random_bytes(&shuffle, sizeof(shuffle));
		atomic_add(shuffle + 1U, &rt_genid);
	}
	
	static void rt_do_flush(int process_context)
	{
	        unsigned int i;
	        struct rtable *rth, *next;
	
	        for (i = 0; i <= rt_hash_mask; i++) {
			if (process_context && need_resched())
				cond_resched();
			rth = rt_hash_table[i].chain;
			if (!rth)
				continue;
			
			spin_lock_bh(rt_hash_lock_addr(i));
			rth = rt_hash_table[i].chain;
			rt_hash_table[i].chain = NULL;
			tail = NULL;
			spin_unlock_bh(rt_hash_lock_addr(i));
			
			for(; rth != tail; rth = next)
			{
				next = rth->dst.rt_next;
				rt_free(rth);
			}
		}
	}

Because of the rt_cache_invalidate() in rt_cache_flush() this
guaranteed that rt_is_expired() was true for every route cache entry,
and this also guaranteed that every routing cache entry we were flush
atomically became inaccessible.

So rt_is_expired() has always been valid, but in practice it was just
always optimized out as being redundant.

With the network namespace support we limit the scope of the test of
the invalidate to just a single network namespace, and as such
rt_is_expired stops being true for every cache entry.  So we cannot
unconditionally throw away entire chains.

All of which can be either done by network namespace equality or by
rt_is_expired().  Although Denis picked rt_is_expired() when he made
his change.

The only place it makes a noticable difference in practice is what
happens when we do batched deleletes of lots of network devices in
different network namespaces.

During batched network device deletes in fib_netdev_event we do
rt_cache_flush(dev_net(dev), -1) for each network device.  and then a
final rt_cache_flush_batch() to remove the invalidated entries.  These
devices can be from multiple network namespaces, so I suspect that is
a savings worth having.

So if we are going to change the tests we need to do something with
rt_cache_flush_batch().  Further I do not see what is confusing about
a test that asks if the routing cache entry is unusable.  Is
rt_cache_expired() a bad name?

Eric

