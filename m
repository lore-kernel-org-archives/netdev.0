From: David Miller <davem@davemloft.net>
Subject: [PATCH 00/16]: Kill the ipv4 routing cache.
Date: Thu, 19 Jul 2012 14:34:03 -0700 (PDT)
Message-ID: <20120719.143403.1702333347618917729.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48239 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751966Ab2GSVeG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 17:34:06 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 138E058459F
	for <netdev@vger.kernel.org>; Thu, 19 Jul 2012 14:34:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The ipv4 routing cache is non-deterministic, performance wise, and is
subject to reasonably easy to launch denial of service attacks.

The routing cache works great for well behaved traffic, and the world
was a much friendlier place when the tradeoffs that led to the routing
cache's design were considered.

What it boils down to is that the performance of the routing cache is
a product of the traffic patterns seen by a system rather than being a
product of the contents of the routing tables.  The former of which is
controllable by external entitites.

Even for "well behaved" legitimate traffic, high volume sites can see
hit rates in the routing cache of only ~%10.

The general flow of this patch series is that first the routing cache
is removed.  We build a completely new rtable entry every lookup
request.

Next we make some simplifications due to the fact that removing the
routing cache causes several members of struct rtable to become no
longer necessary.

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

That GIT tree also includes a udpflood tester tool and stresses
route lookups on packet output.

For example, on the same SPARC-T3 system we can run:

	time ./udpflood -l 10000000 10.2.2.11

with routing cache:
real    1m20.662s       user    0m6.460s        sys     1m14.170s
real    1m19.325s       user    0m6.130s        sys     1m13.180s
real    1m20.683s       user    0m6.180s        sys     1m14.490s

without routing cache:
real    1m34.644s       user    0m7.200s        sys     1m27.410s
real    1m33.204s       user    0m6.670s        sys     1m26.520s
real    1m34.945s       user    0m6.650s        sys     1m28.280s

Performance undoubtedly can easily be improved further.

For example fib_table_lookup() performs a lot of excessive
computations with all the masking and shifting, some of it
conditionalized to deal with edge cases.

Also, Eric's no-ref optimization for input route lookups can be
re-instated for the FIB nexthop caching code path.  I would be really
pleased if someone would work on that.

In fact anyone suitable motivated can just fire up perf on the loading
of the test net_test_tools benchmark kernel module.  I spend much of
my time going:

bash# perf record insmod ./kbench_mod.ko dst=172.30.42.22 src=74.128.0.1 iif=2
bash# perf report

Thanks to helpful feedback from Joe Perches, Eric Dumazet, Ben
Hutchings, and others.

Signed-off-by: David S. Miller <davem@davemloft.net>
