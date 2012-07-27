From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Thu, 26 Jul 2012 23:02:46 -0700 (PDT)
Message-ID: <20120726.230246.219188476590178857.davem@davemloft.net>
References: <20120726.155327.947597248143903676.davem@davemloft.net>
	<CAKgT0UdhqDQSFZkWw9w8L2qsCS+MM_DLQE+Vq0mKcYZmxhs=8Q@mail.gmail.com>
	<20120726.200846.66786272076299783.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59092 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751941Ab2G0GCu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 02:02:50 -0400
In-Reply-To: <20120726.200846.66786272076299783.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 26 Jul 2012 20:08:46 -0700 (PDT)

> A lot of the overhead comes from write traffic that results from
> filling in the "fib_result" structure onto the callers stack.

Here's the longer analysis of how things are now.

There are several components to a route lookup result, and struct
fib_result tries to encapsulate all of this.

Another aspect is that our route tables are broken up into different
datas tructures which reference each other, in order to save space.

So the actual objects in the FIB trie are fib_alias structures, and
those point to fib_info.  There is a many to one relationship between
FIB trie nodes and fib_info objects.

The idea is that many routes have the same set of nexthops, metrics,
preferred source address, etc.

So one thing we return in the fib_result is a pointer to the fib_info
and an index into the nexthop array (nh_sel).  That's why we have all
of these funny accessor's FIB_RES_X(res) which essentially provide
res.fi->fib_nh[res.nh_sel].X

Therefore one area of simplification would be to just return a pointer
to the FIB nexthop, rather than the fib_info pointer and the nexthop
index.  We can get to the fib_info, if we need to, via the nh_parent
pointer of the nexthop.

It seems also that the res->scope value can be cribbed from the
fib_info as well.

res->type is embedded in the fib_alias we select hanging off of the
FIB trie node.  And the res->prefixlen is taken from the FIB trie
node.

res->tclassid is problematic, because it comes from the FIB rules
tables rather than the FIB trie.  We used to store a full FIB rules
pointer in the fib_result, but I reduced it down to just the u32
tclassid.

This whole area, as well as the FIB trie lookup itself, is an area
ripe for a large number of small micro-optimizations that in the end
make it's overhead much more reasonable.

Another thing I haven't mentioned is that another part of FIB trie's
overhead is that it does backtracking.  The shorter prefixes sit at
the top of the trie, so when it traverses down it does so until it
can't get a match, then it walks back up to the root until it does
have a match.
