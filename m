From: David Miller <davem@davemloft.net>
Subject: Re: ip_rt_bug route.c:1677 in 3.0
Date: Tue, 06 Sep 2011 16:51:35 -0400 (EDT)
Message-ID: <20110906.165135.572835380555941402.davem@davemloft.net>
References: <20110906204545.GA29628@tassilo.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: andi@firstfloor.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55695 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754921Ab1IFUvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2011 16:51:45 -0400
In-Reply-To: <20110906204545.GA29628@tassilo.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <andi@firstfloor.org>
Date: Tue, 6 Sep 2011 13:45:45 -0700

> My 3.0 workstation just spew:

"3.0.what?"

> I wonder if a application could have caused this?

It's the routing cache hashing bug, fixed by:

commit d547f727df86059104af2234804fdd538e112015
Author: Julian Anastasov <ja@ssi.bg>
Date:   Sun Aug 7 22:20:20 2011 -0700

    ipv4: fix the reusing of routing cache entries
    
    	compare_keys and ip_route_input_common rely on
    rt_oif for distinguishing of input and output routes
    with same keys values. But sometimes the input route has
    also same hash chain (keyed by iif != 0) with the output
    routes (keyed by orig_oif=0). Problem visible if running
    with small number of rhash_entries.
    
    	Fix them to use rt_route_iif instead. By this way
    input route can not be returned to users that request
    output route.
    
    	The patch fixes the ip_rt_bug errors that were
    reported in ip_local_out context, mostly for 255.255.255.255
    destinations.
    
    Signed-off-by: Julian Anastasov <ja@ssi.bg>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index e3dec1c..cb7efe0 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -731,6 +731,7 @@ static inline int compare_keys(struct rtable *rt1, struct rtable *rt2)
 		((__force u32)rt1->rt_key_src ^ (__force u32)rt2->rt_key_src) |
 		(rt1->rt_mark ^ rt2->rt_mark) |
 		(rt1->rt_key_tos ^ rt2->rt_key_tos) |
+		(rt1->rt_route_iif ^ rt2->rt_route_iif) |
 		(rt1->rt_oif ^ rt2->rt_oif) |
 		(rt1->rt_iif ^ rt2->rt_iif)) == 0;
 }
@@ -2321,8 +2322,8 @@ int ip_route_input_common(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		if ((((__force u32)rth->rt_key_dst ^ (__force u32)daddr) |
 		     ((__force u32)rth->rt_key_src ^ (__force u32)saddr) |
 		     (rth->rt_iif ^ iif) |
-		     rth->rt_oif |
 		     (rth->rt_key_tos ^ tos)) == 0 &&
+		    rt_is_input_route(rth) &&
 		    rth->rt_mark == skb->mark &&
 		    net_eq(dev_net(rth->dst.dev), net) &&
 		    !rt_is_expired(rth)) {
