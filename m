From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [6/6]: jenkins hash for neigh
Date: Sun, 26 Sep 2004 19:11:27 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040926.191127.96477984.yoshfuji@linux-ipv6.org>
References: <20040924142702.62a2b23d.davem@davemloft.net>
	<20040925064406.GL3236@sunbeam.de.gnumonks.org>
	<20040925005623.2faf8faf.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: laforge@gnumonks.org, netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net
In-Reply-To: <20040925005623.2faf8faf.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20040925005623.2faf8faf.davem@davemloft.net> (at Sat, 25 Sep 2004 00:56:23 -0700), "David S. Miller" <davem@davemloft.net> says:

> So let's discuss #4.  It is the first idea I had to combat the
> "problem", but honestly right now I am beginning to think that
> the real solution is to simply remove the INCOMPLETE checks
> altogether.
> 
> Neighbours are a sub-cache of the routing cache.  Therefore when
> a neigh entry has a singular refcount, no routing cache entry
> points to it.  No routing cache entry, we're not sending packets
> to that neighbour any time soon, so there is no reason (especially
> during strong pressure) to hold onto such entries.

First, in IPv6, we usually do not create cache entries for now.
(I assume it is rt6_info with RTF_CACHE flag set.)
We create one if we receives
 - redirect
or
 - too big (for pmtu).

Personally, I agree to change this; always to create routing cache.

Second, we should free only STALE entries first for specification
conformity; lifetime of stale entries is not standardized,
but ones of others are.
We will be broken especially for neighbour-cache reachable-time is
longer than routing-cache lifetime) case.

So, I would say
 - stage 1: if num_entries > low_thresh,
             try purge STALE entries (with refcnt == 1).
             if not enough, schedule flushing routing cache.
 - stage 2: if num_entries > high_thresh,
             try to purge all states (except for permanent entries, 
             but including 1 second-old INCOMPLETE entries.)
             if not enough, schedule flushing routing cache.
 - stage 3: if num_entries > ultimate_thresh, we fail.
or something.

So, I cannot agree simiply removing the "INCOMPLETE" test.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
