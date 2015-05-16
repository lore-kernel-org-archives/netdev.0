From: David Miller <davem@davemloft.net>
Subject: Re: [net] netlink: Make autobind rover an atomic_t
Date: Sat, 16 May 2015 17:08:19 -0400 (EDT)
Message-ID: <20150516.170819.1082459707799000658.davem@davemloft.net>
References: <20150515.130219.331336809636676892.davem@redhat.com>
	<20150516123242.GA683@gondor.apana.org.au>
	<20150516134007.GA1152@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, tgraf@suug.ch, netdev@vger.kernel.org,
	ying.xue@windriver.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37762 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750709AbbEPVIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 May 2015 17:08:21 -0400
In-Reply-To: <20150516134007.GA1152@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 16 May 2015 21:40:07 +0800

> The commit 21e4902aea80ef35afc00ee8d2abdea4f519b7f7 ("netlink:
> Lockless lookup with RCU grace period in socket release") removed
> the locks around the autobind rover without making the rover itself
> safe for use by multiple threads.
> 
> This patch converts rover to an atomic_t to make it at least
> somewhat safe to use locklessly.  The tricky bit is when the
> rover wraps around.  This patch simply deals with it by blindly
> doing an atomic_set.  So if many threads encounter the wraparound
> simultaneously then they'll all step on each other's toes and
> all try to bind to -4097.  But this should eventually sort itself
> out as they loop around and try the atomic_dec_return after the
> last thread does an atomic_set.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

As far as I can tell, this ought to be fine as-is.

Everyone synchronizes on the netlink_insert().

And the rover is just a heuristic to find a free negative
portid quickly.  If the cpus walk on top of eachother, it
will sort itself out in the end.

There is one part of your patch we certainly do need, and
that's the correction of 'portid' when rover rolls over.

Something like the following.

What do you think?

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index dbe8859..bd26e69 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1305,7 +1305,7 @@ retry:
 		/* Bind collision, search negative portid values. */
 		portid = rover--;
 		if (rover > -4097)
-			rover = -4097;
+			portid = rover = -4097;
 		rcu_read_unlock();
 		goto retry;
 	}
