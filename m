From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Fri, 20 Jul 2012 16:13:31 -0700 (PDT)
Message-ID: <20120720.161331.2251326254024647237.davem@davemloft.net>
References: <1342824166.2626.8112.camel@edumazet-glaptop>
	<20120720.155021.1919200619716435427.davem@davemloft.net>
	<20120720.155412.1512575922394612084.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56392 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508Ab2GTXNc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 19:13:32 -0400
In-Reply-To: <20120720.155412.1512575922394612084.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 20 Jul 2012 15:54:12 -0700 (PDT)

> From: David Miller <davem@davemloft.net>
> Date: Fri, 20 Jul 2012 15:50:21 -0700 (PDT)
> 
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Sat, 21 Jul 2012 00:42:46 +0200
>> 
>>> (Apparently we choke on neighbour entries count.
>>> 
>>> entries = atomic_inc_return(&tbl->entries) - 1;
>>> 
>>> We need a percpu_counter ? Or something is wrong ?
>> 
>> What do you mean we choke on it?  Does it exceed the thresholds
>> and we start garbage-collecting?
>> 
>> That would indicate a leak, or we are creating new neigh entries when
>> we shouldn't be, ie. we're not comparing the keys in the hash table
>> entries correctly during the lookup in net/ipv4/ip_output.c
> 
> I see the problem, we get the key wrong during neigh creation for
> loopback.
> 
> I'll fix this, thanks.

This should do it:

====================
[PATCH] ipv4: Fix neigh lookup keying over loopback/point-to-point devices.

We were using a special key "0" for all loopback and point-to-point
device neigh lookups under ipv4, but we wouldn't use that special
key for the neigh creation.

So basically we'd make a new neigh at each and every lookup :-)

This special case to use only one neigh for these device types
is of dubious value, so just remove it entirely.

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/arp.h |    3 ---
 1 file changed, 3 deletions(-)

diff --git a/include/net/arp.h b/include/net/arp.h
index 4617d98..7f7df93 100644
--- a/include/net/arp.h
+++ b/include/net/arp.h
@@ -21,9 +21,6 @@ static inline struct neighbour *__ipv4_neigh_lookup_noref(struct net_device *dev
 	struct neighbour *n;
 	u32 hash_val;
 
-	if (dev->flags & (IFF_LOOPBACK | IFF_POINTOPOINT))
-		key = 0;
-
 	hash_val = arp_hashfn(key, dev, nht->hash_rnd[0]) >> (32 - nht->hash_shift);
 	for (n = rcu_dereference_bh(nht->hash_buckets[hash_val]);
 	     n != NULL;
-- 
1.7.10.4
