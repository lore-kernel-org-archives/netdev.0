From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipv4: some rt_iif -> rt_route_iif conversions
Date: Tue, 9 Aug 2011 17:01:16 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1108091651290.1527@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:58073 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750758Ab1HIN4T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Aug 2011 09:56:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	As rt_iif represents input device even for packets
coming from loopback with output route, it is not an unique
key specific to input routes. Now rt_route_iif has such role,
it was fl.iif in 2.6.38, so better to change the checks at
some places to save CPU cycles and to restore 2.6.38 semantics.

compare_keys:
	- input routes: only rt_route_iif matters, rt_iif is same
	- output routes: only rt_oif matters, rt_iif is not
		used for matching in __ip_route_output_key
	- now we are back to 2.6.38 state

ip_route_input_common:
	- matching rt_route_iif implies input route
	- compared to 2.6.38 we eliminated one rth->fl.oif check
	because it was not needed even for 2.6.38

compare_hash_inputs:
	Only the change here is not an optimization, it has
	effect only for output routes. I assume I'm restoring
	the original intention to ignore oif, it was using fl.iif
	- now we are back to 2.6.38 state

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---

diff -urp linux/net/ipv4/route.c linux/net/ipv4/route.c
--- linux/net/ipv4/route.c	2011-08-09 12:40:43.000000000 +0300
+++ linux/net/ipv4/route.c	2011-08-09 12:46:16.880358197 +0300
@@ -716,7 +716,7 @@ static inline bool compare_hash_inputs(c
 {
 	return ((((__force u32)rt1->rt_key_dst ^ (__force u32)rt2->rt_key_dst) |
 		((__force u32)rt1->rt_key_src ^ (__force u32)rt2->rt_key_src) |
-		(rt1->rt_iif ^ rt2->rt_iif)) == 0);
+		(rt1->rt_route_iif ^ rt2->rt_route_iif)) == 0);
 }
 
 static inline int compare_keys(struct rtable *rt1, struct rtable *rt2)
@@ -726,8 +726,7 @@ static inline int compare_keys(struct rt
 		(rt1->rt_mark ^ rt2->rt_mark) |
 		(rt1->rt_key_tos ^ rt2->rt_key_tos) |
 		(rt1->rt_route_iif ^ rt2->rt_route_iif) |
-		(rt1->rt_oif ^ rt2->rt_oif) |
-		(rt1->rt_iif ^ rt2->rt_iif)) == 0;
+		(rt1->rt_oif ^ rt2->rt_oif)) == 0;
 }
 
 static inline int compare_netns(struct rtable *rt1, struct rtable *rt2)
@@ -2281,9 +2280,8 @@ int ip_route_input_common(struct sk_buff
 	     rth = rcu_dereference(rth->dst.rt_next)) {
 		if ((((__force u32)rth->rt_key_dst ^ (__force u32)daddr) |
 		     ((__force u32)rth->rt_key_src ^ (__force u32)saddr) |
-		     (rth->rt_iif ^ iif) |
+		     (rth->rt_route_iif ^ iif) |
 		     (rth->rt_key_tos ^ tos)) == 0 &&
-		    rt_is_input_route(rth) &&
 		    rth->rt_mark == skb->mark &&
 		    net_eq(dev_net(rth->dst.dev), net) &&
 		    !rt_is_expired(rth)) {
