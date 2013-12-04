From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net] net: neighbour: add neighbour dead check for neigh_timer_handler()
Date: Wed, 4 Dec 2013 14:19:06 +0800
Message-ID: <529EC95A.5080908@huawei.com>
References: <529DE13D.2070509@huawei.com>	<529E9579.7090201@cn.fujitsu.com>	<529EA9CF.2090008@huawei.com> <20131203.232122.852236751455974887.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <gaofeng@cn.fujitsu.com>, <yoshfuji@linux-ipv6.org>,
	<joe@perches.com>, <vfalico@redhat.com>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:9272 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400Ab3LDGT3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Dec 2013 01:19:29 -0500
In-Reply-To: <20131203.232122.852236751455974887.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/12/4 12:21, David Miller wrote:
> From: Ding Tianhong <dingtianhong@huawei.com>
> Date: Wed, 4 Dec 2013 12:04:31 +0800
> 
>> The destroying neigh could be trigger by userspace, just like set the ip address which
>> in arp table to the local device ip, some I could not control it, it maybe anytime,
>> but the timer handler is execute by logic, this is normal, so I think the logic
>> is no problem, and the process of destroying neigh may conflict with the timer handler,
>> it is a synchronous problem to make sure the timer should be finished before the
>> reference neigh is freed.
> 
> The more I think about this, the more none of the explanations for this bug
> make any sense.
> 
> neigh_destroy() _ONLY_ runs when:
> 
> 	if (atomic_dec_and_test(&neigh->refcnt))
> 
> triggers in neigh_release().
> 
> This means it triggers if, and only if, neigh_refcnt goes to zero.
> 
> If the refcnt goes to zero, NO TIMER can be running.  If the timer is
> running, then there refcnt must be at least '1'.

Hi David:

Yes, you are right, but when the timer is running and prior to get the neigh->lock, the refcnt
could be dec to 0, you could not stop it by existing mechanism.

the refcnt of neighbour could only be inc by these actions:

1.create neighbour, the refcnt will be set to 1.
2.add timer, the refcnt++.
3.neigh_lookup, if found the neigh, refcnt++.

I can show the whole process of my analysis:

		CPU 0				CPU 1
		-----				-----
	create_neigh() => refcnt = 1;		
	add timer =>	refcnt++;
						<SOFTIRQ>
						base->running_timer = neigh->timer;
						neigh_timer_handler() => at this time, refcnt is 2;

user->	neigh_changeaddr()
	neigh_flush_dev();
	neigh_del_imer, refcnt dec to 1;
	release_neigh(), refcnt is 0,
	destroy_neigh()
	kfree(neighbour);
						write(neigh->lock)

So in my opinion, the point of the problem is that I should not kfree the neighbour until
the timer is not running on CPUs and not pending.

If I miss someghing, pls point out.

Regards
Ding

> 
> The only plausible theory would be that something is releasing a neigh
> too early, when references to the neigh still actually exist.
> 
> And that's a bug that should be fixed.
> 
> 
