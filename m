From: David Miller <davem@davemloft.net>
Subject: [PATCH 00/15] Kill the routing cache.
Date: Wed, 18 Jul 2012 11:22:42 -0700 (PDT)
Message-ID: <20120718.112242.741406262839919498.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36894 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752056Ab2GRSWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 14:22:45 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id C85D9583FC7
	for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 11:22:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


And I'm really serious this time :-)

The general flow of this patch series is that first the routing
cache is removed.  We build a completely new rtable entry every
lookup request.

Next we make some simplifications due to the fact that removing the
routing cache causes several members of struct rtable to become
no longer necessary.

Then we need to make some amends such that we can legally cache
pre-constructed routes in the FIB nexthops.  Firstly, we need to
invalidate routes which are hit with nexthop exceptions.  Secondly we
have to change the semantics of rt->rt_gateway such that zero means
that the destination is on-link and non-zero otherwise.

Now that the preparations are ready, we start caching precomputed
routes in the FIB nexthops.  Output and input routes need different
kinds of care when determining if we can legally do such caching or
not.  The details are in the commit log messages for those changes.

The patch series then winds down with some more struct rtable
simplifications and other tidy ups that remove unnecessary overhead.

On a SPARC-T3 output route lookups are ~870 cycles.  Input route
lookups are ~970 cycles with rpfilter disabled, and about ~1400 with
rpfilter enabled.

These measurements were taken with the kbench_mod test module in the
net_test_tools GIT tree:

git://git.kernel.org/pub/scm/linux/kernel/git/davem/net_test_tools.git

Performance can easily be improved further.  For example
fib_table_lookup() performs a lot of excessive computations with all
the masking and shifting, some of it conditionalized to deal with edge
cases.

Also, Eric's no-ref optimization for input route lookups can be
re-instated for the FIB nexthop caching code path.  I would be really
pleased if someone would work on that.

In fact anyone suitable motivated can just fire up perf on the loading
of the test net_test_tools benchmark kernel module.  I spend much of
my time going:

bash# perf record insmod ./kbench_mod.ko dst=172.30.42.22 src=74.128.0.1 iif=2
bash# perf report

Signed-off-by: David S. Miller <davem@davemloft.net>
