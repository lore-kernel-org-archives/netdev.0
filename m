From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: neighbour: add neighbour dead check for
 neigh_timer_handler()
Date: Tue, 03 Dec 2013 23:21:22 -0500 (EST)
Message-ID: <20131203.232122.852236751455974887.davem@davemloft.net>
References: <529DE13D.2070509@huawei.com>
	<529E9579.7090201@cn.fujitsu.com>
	<529EA9CF.2090008@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gaofeng@cn.fujitsu.com, yoshfuji@linux-ipv6.org, joe@perches.com,
	vfalico@redhat.com, netdev@vger.kernel.org
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39217 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752477Ab3LDEVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 23:21:24 -0500
In-Reply-To: <529EA9CF.2090008@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Wed, 4 Dec 2013 12:04:31 +0800

> The destroying neigh could be trigger by userspace, just like set the ip address which
> in arp table to the local device ip, some I could not control it, it maybe anytime,
> but the timer handler is execute by logic, this is normal, so I think the logic
> is no problem, and the process of destroying neigh may conflict with the timer handler,
> it is a synchronous problem to make sure the timer should be finished before the
> reference neigh is freed.

The more I think about this, the more none of the explanations for this bug
make any sense.

neigh_destroy() _ONLY_ runs when:

	if (atomic_dec_and_test(&neigh->refcnt))

triggers in neigh_release().

This means it triggers if, and only if, neigh_refcnt goes to zero.

If the refcnt goes to zero, NO TIMER can be running.  If the timer is
running, then there refcnt must be at least '1'.

The only plausible theory would be that something is releasing a neigh
too early, when references to the neigh still actually exist.

And that's a bug that should be fixed.
