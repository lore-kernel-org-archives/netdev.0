From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Kill spurious write to iph->daddr in
 ip_forward_options().
Date: Fri, 13 May 2011 17:16:50 -0400 (EDT)
Message-ID: <20110513.171650.1823166136379184877.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56150 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756561Ab1EMVQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 17:16:53 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4DLGpbH015404
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 13 May 2011 14:16:52 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This code block executes when opt->srr_is_hit is set.  It will be
set only by ip_options_rcv_srr().

ip_options_rcv_srr() walks until it hits a matching nexthop in the SRR
option addresses, and when it matches one 1) looks up the route for
that nexthop and 2) on route lookup success it writes that nexthop
value into iph->daddr.

ip_forward_options() runs later, and again walks the SRR option
addresses looking for the option matching the destination of the route
stored in skb_rtable().  This route will be the same exact one looked
up for the nexthop by ip_options_rcv_srr().

Therefore "rt->rt_dst == iph->daddr" must be true.

All it really needs to do is record the route's source address in the
matching SRR option adddress.  It need not write iph->daddr again,
since that has already been done by ip_options_rcv_srr() as detailed
above.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ip_options.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index c5c2619..c6474cd 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -573,7 +573,6 @@ void ip_forward_options(struct sk_buff *skb)
 		if (srrptr + 3 <= srrspace) {
 			opt->is_changed = 1;
 			ip_rt_get_source(&optptr[srrptr-1], rt);
-			ip_hdr(skb)->daddr = rt->rt_dst;
 			optptr[2] = srrptr+4;
 		} else if (net_ratelimit())
 			printk(KERN_CRIT "ip_forward(): Argh! Destination lost!\n");
-- 
1.7.4.4

