From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: problem of "ipv4: revert Set rt->rt_iif more sanely on output routes."
Date: Tue, 05 Apr 2011 23:57:42 +0900
Message-ID: <8739lw7nkp.fsf@devron.myhome.or.jp>
References: <87oc4kj1bt.fsf@devron.myhome.or.jp>
	<877hb87pqi.fsf@devron.myhome.or.jp>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.parknet.co.jp ([210.171.160.6]:52757 "EHLO
	mail.parknet.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753386Ab1DEO5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 10:57:47 -0400
In-Reply-To: <877hb87pqi.fsf@devron.myhome.or.jp> (OGAWA Hirofumi's message of
	"Tue, 05 Apr 2011 23:11:01 +0900")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> writes:

> OGAWA Hirofumi <hirofumi@mail.parknet.co.jp> writes:
>
>> Hi,
>>
>> ipv4: Set rt->rt_iif more sanely on output routes.
>> (1018b5c01636c7c6bda31a719bda34fc631db29a)
>>
>> The above patch seems to be caused of avahi breakage.
>>
>> I'm not debugging fully though, avahi is using IP_PKTINFO and checking
>> in_pktinfo->ipi_ifindex > 0.
>>
>> And if I reverted above patch, it seems to fix avahi's IP_PKTINFO problem.
>>
>> Ideas?
>
> BTW, simple revert seems to break routing or something instead.

Just as FYI, this patch seems to fix the problem. (Only slightly tested
and reviewed. Please don't apply this until someone review. )

 include/net/route.h     |    1 +
 net/ipv4/ip_sockglue.c  |    2 +-
 net/ipv4/route.c        |    6 +++++-
 net/ipv4/xfrm4_policy.c |    1 +
 4 files changed, 8 insertions(+), 2 deletions(-)

diff -puN net/ipv4/route.c~revert-avahi-breaker net/ipv4/route.c
--- linux-2.6/net/ipv4/route.c~revert-avahi-breaker	2011-04-05 22:59:32.000000000 +0900
+++ linux-2.6-hirofumi/net/ipv4/route.c	2011-04-05 23:06:12.000000000 +0900
@@ -1891,6 +1891,7 @@ static int ip_route_input_mc(struct sk_b
 #ifdef CONFIG_IP_ROUTE_CLASSID
 	rth->dst.tclassid = itag;
 #endif
+	rth->rt_user_if	= dev->ifindex;
 	rth->rt_iif	= dev->ifindex;
 	rth->dst.dev	= init_net.loopback_dev;
 	dev_hold(rth->dst.dev);
@@ -2026,6 +2027,7 @@ static int __mkroute_input(struct sk_buf
 	rth->rt_key_src	= saddr;
 	rth->rt_src	= saddr;
 	rth->rt_gateway	= daddr;
+	rth->rt_user_if	= in_dev->dev->ifindex;
 	rth->rt_iif 	= in_dev->dev->ifindex;
 	rth->dst.dev	= (out_dev)->dev;
 	dev_hold(rth->dst.dev);
@@ -2202,6 +2204,7 @@ local_input:
 #ifdef CONFIG_IP_ROUTE_CLASSID
 	rth->dst.tclassid = itag;
 #endif
+	rth->rt_user_if	= dev->ifindex;
 	rth->rt_iif	= dev->ifindex;
 	rth->dst.dev	= net->loopback_dev;
 	dev_hold(rth->dst.dev);
@@ -2401,6 +2404,7 @@ static struct rtable *__mkroute_output(c
 	rth->rt_mark    = oldflp4->flowi4_mark;
 	rth->rt_dst	= fl4->daddr;
 	rth->rt_src	= fl4->saddr;
+	rth->rt_user_if	= oldflp4->flowi4_oif ? : dev_out->ifindex;
 	rth->rt_iif	= 0;
 	/* get references to the devices that are to be hold by the routing
 	   cache entry */
@@ -2716,6 +2720,7 @@ struct dst_entry *ipv4_blackhole_route(s
 		rt->rt_key_dst = ort->rt_key_dst;
 		rt->rt_key_src = ort->rt_key_src;
 		rt->rt_tos = ort->rt_tos;
+		rt->rt_user_if = ort->rt_user_if;
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
diff -puN include/net/route.h~revert-avahi-breaker include/net/route.h
--- linux-2.6/include/net/route.h~revert-avahi-breaker	2011-04-05 23:00:34.000000000 +0900
+++ linux-2.6-hirofumi/include/net/route.h	2011-04-05 23:00:24.000000000 +0900
@@ -64,6 +64,7 @@ struct rtable {
 
 	__be32			rt_dst;	/* Path destination	*/
 	__be32			rt_src;	/* Path source		*/
+	int			rt_user_if;
 	int			rt_iif;
 	int			rt_oif;
 	__u32			rt_mark;
diff -puN net/ipv4/xfrm4_policy.c~revert-avahi-breaker net/ipv4/xfrm4_policy.c
--- linux-2.6/net/ipv4/xfrm4_policy.c~revert-avahi-breaker	2011-04-05 23:03:56.000000000 +0900
+++ linux-2.6-hirofumi/net/ipv4/xfrm4_policy.c	2011-04-05 23:04:02.000000000 +0900
@@ -74,6 +74,7 @@ static int xfrm4_fill_dst(struct xfrm_ds
 	rt->rt_key_dst = fl4->daddr;
 	rt->rt_key_src = fl4->saddr;
 	rt->rt_tos = fl4->flowi4_tos;
+	rt->rt_user_if = fl4->flowi4_iif;
 	rt->rt_iif = fl4->flowi4_iif;
 	rt->rt_oif = fl4->flowi4_oif;
 	rt->rt_mark = fl4->flowi4_mark;
diff -puN net/ipv4/ip_sockglue.c~revert-avahi-breaker net/ipv4/ip_sockglue.c
--- linux-2.6/net/ipv4/ip_sockglue.c~revert-avahi-breaker	2011-04-05 23:04:52.000000000 +0900
+++ linux-2.6-hirofumi/net/ipv4/ip_sockglue.c	2011-04-05 23:04:56.000000000 +0900
@@ -62,7 +62,7 @@ static void ip_cmsg_recv_pktinfo(struct
 
 	info.ipi_addr.s_addr = ip_hdr(skb)->daddr;
 	if (rt) {
-		info.ipi_ifindex = rt->rt_iif;
+		info.ipi_ifindex = rt->rt_user_if;
 		info.ipi_spec_dst.s_addr = rt->rt_spec_dst;
 	} else {
 		info.ipi_ifindex = 0;
_

-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
