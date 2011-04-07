From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: problem of "ipv4: revert Set rt->rt_iif more sanely on output routes."
Date: Thu, 07 Apr 2011 17:32:49 +0900
Message-ID: <87wrj6qx5a.fsf@devron.myhome.or.jp>
References: <20110406.132829.116375350.davem@davemloft.net>
	<87ipuqsmwl.fsf@devron.myhome.or.jp>
	<20110406.223400.71127145.davem@davemloft.net>
	<20110406.224244.104071339.davem@davemloft.net>
	<877hb6sf43.fsf@devron.myhome.or.jp>
	<8739lusbvz.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.parknet.co.jp ([210.171.160.6]:50729 "EHLO
	mail.parknet.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754302Ab1DGIcw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 04:32:52 -0400
In-Reply-To: <8739lusbvz.fsf@devron.myhome.or.jp> (OGAWA Hirofumi's message of
	"Thu, 07 Apr 2011 17:29:04 +0900")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> writes:

> OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> writes:
>
>> David Miller <davem@davemloft.net> writes:
>>
>>> So fix is something like:
>>>
>>> 1) Add "int rt_route_iif;" to struct rtable
>>>
>>> 2) For input routes, always set rt_route_iif to same value as rt_iif
>>>
>>> 3) For output routes, always set rt_route_iif to zero.  Set rt_iif
>>>    as it is done currently.
>>>
>>> 4) Change rt_is_{output,input}_route() to test rt_route_iif
>>>
>>> This should fix the bug and not introduce new regressions.
>>>
>>> Can you write and test such a patch with your test case?
>>
>> Ok. I'll try, but I'm not sure I understand the above correctly. Well,
>> I'll send the patch after testing.
>
> This patch seems to work for avahi-daemon without any warning.
>
> BTW, the above meant change from (there was before) "fl.iif" to
> "rt_route_iif"? If so, this patch is not enough. I'm not sure
>
> +	rth->rt_route_iif = 0;
> +	rth->rt_iif	= oldflp4->flowi4_oif ? : dev_out->ifindex;
>
> is correct one or not. Please review.

Forgot the patch.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>


[PATCH] Fix  "Set rt->rt_iif more sanely on output routes."


1018b5c01636c7c6bda31a719bda34fc631db29a breaks rt_is_{output,input}_route.

This became the cause to return "IP_PKTINFO's ->ipi_ifindex == 0".

To fix it, this does

1) Add "int rt_route_iif;" to struct rtable

2) For input routes, always set rt_route_iif to same value as rt_iif

3) For output routes, always set rt_route_iif to zero.  Set rt_iif
   as it is done currently.

4) Change rt_is_{output,input}_route() to test rt_route_iif

Signed-off-by: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
---

 include/net/route.h     |    5 +++--
 net/ipv4/route.c        |    8 ++++++--
 net/ipv4/xfrm4_policy.c |    1 +
 3 files changed, 10 insertions(+), 4 deletions(-)

diff -puN include/net/route.h~revert-avahi-breaker include/net/route.h
--- linux-2.6/include/net/route.h~revert-avahi-breaker	2011-04-07 17:12:05.000000000 +0900
+++ linux-2.6-hirofumi/include/net/route.h	2011-04-07 17:12:05.000000000 +0900
@@ -64,6 +64,7 @@ struct rtable {
 
 	__be32			rt_dst;	/* Path destination	*/
 	__be32			rt_src;	/* Path source		*/
+	int			rt_route_iif;
 	int			rt_iif;
 	int			rt_oif;
 	__u32			rt_mark;
@@ -80,12 +81,12 @@ struct rtable {
 
 static inline bool rt_is_input_route(struct rtable *rt)
 {
-	return rt->rt_iif != 0;
+	return rt->rt_route_iif != 0;
 }
 
 static inline bool rt_is_output_route(struct rtable *rt)
 {
-	return rt->rt_iif == 0;
+	return rt->rt_route_iif == 0;
 }
 
 struct ip_rt_acct {
diff -puN net/ipv4/route.c~revert-avahi-breaker net/ipv4/route.c
--- linux-2.6/net/ipv4/route.c~revert-avahi-breaker	2011-04-07 17:12:05.000000000 +0900
+++ linux-2.6-hirofumi/net/ipv4/route.c	2011-04-07 17:12:05.000000000 +0900
@@ -1891,6 +1891,7 @@ static int ip_route_input_mc(struct sk_b
 #ifdef CONFIG_IP_ROUTE_CLASSID
 	rth->dst.tclassid = itag;
 #endif
+	rth->rt_route_iif = dev->ifindex;
 	rth->rt_iif	= dev->ifindex;
 	rth->dst.dev	= init_net.loopback_dev;
 	dev_hold(rth->dst.dev);
@@ -2026,6 +2027,7 @@ static int __mkroute_input(struct sk_buf
 	rth->rt_key_src	= saddr;
 	rth->rt_src	= saddr;
 	rth->rt_gateway	= daddr;
+	rth->rt_route_iif = in_dev->dev->ifindex;
 	rth->rt_iif 	= in_dev->dev->ifindex;
 	rth->dst.dev	= (out_dev)->dev;
 	dev_hold(rth->dst.dev);
@@ -2202,6 +2204,7 @@ local_input:
 #ifdef CONFIG_IP_ROUTE_CLASSID
 	rth->dst.tclassid = itag;
 #endif
+	rth->rt_route_iif = dev->ifindex;
 	rth->rt_iif	= dev->ifindex;
 	rth->dst.dev	= net->loopback_dev;
 	dev_hold(rth->dst.dev);
@@ -2401,7 +2404,8 @@ static struct rtable *__mkroute_output(c
 	rth->rt_mark    = oldflp4->flowi4_mark;
 	rth->rt_dst	= fl4->daddr;
 	rth->rt_src	= fl4->saddr;
-	rth->rt_iif	= 0;
+	rth->rt_route_iif = 0;
+	rth->rt_iif	= oldflp4->flowi4_oif ? : dev_out->ifindex;
 	/* get references to the devices that are to be hold by the routing
 	   cache entry */
 	rth->dst.dev	= dev_out;
@@ -2716,6 +2720,7 @@ struct dst_entry *ipv4_blackhole_route(s
 		rt->rt_key_dst = ort->rt_key_dst;
 		rt->rt_key_src = ort->rt_key_src;
 		rt->rt_tos = ort->rt_tos;
+		rt->rt_route_iif = ort->rt_route_iif;
 		rt->rt_iif = ort->rt_iif;
 		rt->rt_oif = ort->rt_oif;
 		rt->rt_mark = ort->rt_mark;
@@ -2725,7 +2730,6 @@ struct dst_entry *ipv4_blackhole_route(s
 		rt->rt_type = ort->rt_type;
 		rt->rt_dst = ort->rt_dst;
 		rt->rt_src = ort->rt_src;
-		rt->rt_iif = ort->rt_iif;
 		rt->rt_gateway = ort->rt_gateway;
 		rt->rt_spec_dst = ort->rt_spec_dst;
 		rt->peer = ort->peer;
diff -puN net/ipv4/xfrm4_policy.c~revert-avahi-breaker net/ipv4/xfrm4_policy.c
--- linux-2.6/net/ipv4/xfrm4_policy.c~revert-avahi-breaker	2011-04-07 17:12:05.000000000 +0900
+++ linux-2.6-hirofumi/net/ipv4/xfrm4_policy.c	2011-04-07 17:12:05.000000000 +0900
@@ -74,6 +74,7 @@ static int xfrm4_fill_dst(struct xfrm_ds
 	rt->rt_key_dst = fl4->daddr;
 	rt->rt_key_src = fl4->saddr;
 	rt->rt_tos = fl4->flowi4_tos;
+	rt->rt_route_iif = fl4->flowi4_iif;
 	rt->rt_iif = fl4->flowi4_iif;
 	rt->rt_oif = fl4->flowi4_oif;
 	rt->rt_mark = fl4->flowi4_mark;
_
