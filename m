From: David Miller <davem@davemloft.net>
Subject: [PATCH 00/16] Remove the ipv4 routing cache
Date: Fri, 20 Jul 2012 14:25:02 -0700 (PDT)
Message-ID: <20120720.142502.1144557295933737451.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55651 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752268Ab2GTVZF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 17:25:05 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 2205A583612
	for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 14:25:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[ Ok I'm going to be a little bit cranky, and I think I deserve it.

  I'm basically not going to go through the multi-hour rebase and
  retest process again, as it's hit the point of diminishing returns
  as NOBODY is giving me test results but I can guarentee that
  EVERYONE will bitch and complain when I push this into net-next and
  it breaks their favorite feature.  If you can't be bothered to test
  these changes, I'm honestly going to tell people to take a hike and
  fix it themselves.  I simply don't care if you don't care enough to
  test changes of this magnitude to make sure your favorite setup
  still works.

  To say that I'm disappointed with the amount of testing feedback
  after posting more than a dozen iterations of this delicate patch
  set would be an understatement.  I can think of only one person who
  actually tested one iteration of these patches and gave feedback.

  And meanwhile I've personally reviewed, tested, and signed off on
  everyone else's work WITHOUT DELAY during this entire process.

  I've pulled 25 hour long hacking shifts to make that a reality, so
  that my routing cache removal work absolutely would not impact or
  delay the patch submissions of any other networking developer.  And
  I can't even get a handful of testers with some feedback?  You
  really have to be kidding me.. ]

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

On a SPARC-T3 output route lookups are ~876 cycles.  Input route
lookups are ~1169 cycles with rpfilter disabled, and about ~1468
cycles with rpfilter enabled.

These measurements were taken with the kbench_mod test module in the
net_test_tools GIT tree:

git://git.kernel.org/pub/scm/linux/kernel/git/davem/net_test_tools.git

That GIT tree also includes a udpflood tester tool and stresses
route lookups on packet output.

For example, on the same SPARC-T3 system we can run:

	time ./udpflood -l 10000000 10.2.2.11

with routing cache:
real    1m21.955s       user    0m6.530s        sys     1m15.390s

without routing cache:
real    1m31.678s       user    0m6.520s        sys     1m25.140s

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
