From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [IPV4] route: Dynamic hash table sizing.
Date: Wed, 09 Aug 2006 02:09:39 -0700 (PDT)
Message-ID: <20060809.020939.106265428.davem@davemloft.net>
References: <20060809.004920.59469729.davem@davemloft.net>
	<20060809.005337.104642177.davem@davemloft.net>
	<200608091032.55232.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:5065
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030599AbWHIJJf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Aug 2006 05:09:35 -0400
To: dada1@cosmosbay.com
In-Reply-To: <200608091032.55232.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Wed, 9 Aug 2006 10:32:54 +0200

> On Wednesday 09 August 2006 09:53, David Miller wrote:
> > [IPV4] route: Dynamic hash table sizing.
> >
> 
>  Excellent work David, Thank you !!!

No problem.  It's much more productive than all the pure-talk that
usually occurs on these topics.

Here is a patch implementing fixes for the problems you found, thanks
for reviewing.

commit fc03f220a20f0fef0567e7427d0e06d234b98531
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Wed Aug 9 02:06:33 2006 -0700

    [IPV4] route: Fix 3 bugs in dynamic hash table code.
    
    All problems were spotted by Eric Dumazet.
    
    1) During rehashing, the hash function was wrong.
       It should "xor" in the iface number not "and" it.
    
    2) Mark ip_rt_hashsz_limit __read_mostly
    
    3) Instead of rejecting non-power-of-2 rhash_entries
       values, round them up just like the alloc_large_system_hash
       function was doing for us previously
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 897e67c..a9216e2 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -123,7 +123,6 @@ #define RT_GC_TIMEOUT (300*HZ)
 static int ip_rt_min_delay		= 2 * HZ;
 static int ip_rt_max_delay		= 10 * HZ;
 static int ip_rt_max_size;
-static int ip_rt_hashsz_limit		= (8 * 1024 * 1024) / sizeof(void *);
 static int ip_rt_gc_timeout		= RT_GC_TIMEOUT;
 static int ip_rt_gc_interval		= 60 * HZ;
 static int ip_rt_gc_min_interval	= HZ / 2;
@@ -253,6 +252,8 @@ static seqlock_t rt_hash_seq __read_most
 static struct rt_hash_bucket 	*__rt_hash_table __read_mostly;
 static unsigned			__rt_hash_mask __read_mostly;
 static unsigned int		rt_hash_rnd __read_mostly;
+static int ip_rt_hashsz_limit __read_mostly =
+	(8 * 1024 * 1024) / sizeof(void *);
 
 static DEFINE_PER_CPU(struct rt_cache_stat, rt_cache_stat);
 #define RT_CACHE_STAT_INC(field) \
@@ -351,7 +352,7 @@ static void rtcache_transfer(struct rtab
 		if (!iface)
 			iface = list->fl.oif;
 		hash = __rt_hash_code(list->fl.fl4_dst,
-				      list->fl.fl4_src &
+				      list->fl.fl4_src ^
 				      (iface << 5),
 				      nhashmask);
 		ent = &new_table[hash];
@@ -3338,9 +3339,7 @@ static int __init set_rhash_entries(char
 		return 0;
 	val = simple_strtoul(str, &str, 0);
 
-	/* Only use it if it's a power-of-2. */
-	if (!(val & (val - 1)))
-		rhash_entries = val;
+	rhash_entries = roundup_pow_of_two(val);
 
 	return 1;
 }
