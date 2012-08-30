From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH] ipv6: fix handling of blackhole and prohibit routes
Date: Thu, 30 Aug 2012 16:29:28 +0200
Message-ID: <503F78C8.3070807@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080801060909060302040707"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:42624 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752298Ab2H3O3c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 10:29:32 -0400
Received: by eekc1 with SMTP id c1so757803eek.19
        for <netdev@vger.kernel.org>; Thu, 30 Aug 2012 07:29:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------080801060909060302040707
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

enclosed is a patch to fix addition of blackhole and prohibit routes.

Comments are welcome.

Regards,
Nicolas

--------------080801060909060302040707
Content-Type: text/x-patch;
 name="0001-ipv6-fix-handling-of-blackhole-and-prohibit-routes.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-ipv6-fix-handling-of-blackhole-and-prohibit-routes.patc";
 filename*1="h"

>From 0131261ac3947631b96036ffafb30ee2e95604f2 Mon Sep 17 00:00:00 2001
From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 30 Aug 2012 07:07:30 -0400
Subject: [PATCH] ipv6: fix handling of blackhole and prohibit routes

When adding a blackhole or a prohibit route, they were handling like classic
routes. Moreover, it was only possible to add this kind of routes by specifying
an interface.

Bug already reported here:
  http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=498498

Before the patch:
  $ ip route add blackhole 2001::1/128
  RTNETLINK answers: No such device
  $ ip route add blackhole 2001::1/128 dev eth0
  $ ip -6 route | grep 2001
  2001::1 dev eth0  metric 1024

After:
  $ ip route add blackhole 2001::1/128
  $ ip -6 route | grep 2001
  blackhole 2001::1 dev lo  metric 1024  error -22

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 include/linux/route.h |    2 ++
 net/ipv6/route.c      |   27 ++++++++++++++++++++++-----
 2 files changed, 24 insertions(+), 5 deletions(-)

diff --git a/include/linux/route.h b/include/linux/route.h
index 6600708..166fb68 100644
--- a/include/linux/route.h
+++ b/include/linux/route.h
@@ -58,6 +58,8 @@ struct rtentry {
 #define RTF_WINDOW	0x0080		/* per route window clamping	*/
 #define RTF_IRTT	0x0100		/* Initial round trip time	*/
 #define RTF_REJECT	0x0200		/* Reject route			*/
+#define RTF_BLACKHOLE	0x0400		/* Blackhole route		*/
+#define RTF_PROHIBIT	0x0800		/* Prohibit route		*/
 
 /*
  *	<linux/ipv6_route.h> uses RTF values >= 64k
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 8e80fd2..69369b0 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -251,7 +251,7 @@ static struct rt6_info ip6_prohibit_entry_template = {
 		.input		= ip6_pkt_prohibit,
 		.output		= ip6_pkt_prohibit_out,
 	},
-	.rt6i_flags	= (RTF_REJECT | RTF_NONEXTHOP),
+	.rt6i_flags	= (RTF_REJECT | RTF_NONEXTHOP | RTF_PROHIBIT),
 	.rt6i_protocol  = RTPROT_KERNEL,
 	.rt6i_metric	= ~(u32) 0,
 	.rt6i_ref	= ATOMIC_INIT(1),
@@ -266,7 +266,7 @@ static struct rt6_info ip6_blk_hole_entry_template = {
 		.input		= dst_discard,
 		.output		= dst_discard,
 	},
-	.rt6i_flags	= (RTF_REJECT | RTF_NONEXTHOP),
+	.rt6i_flags	= (RTF_REJECT | RTF_NONEXTHOP | RTF_BLACKHOLE),
 	.rt6i_protocol  = RTPROT_KERNEL,
 	.rt6i_metric	= ~(u32) 0,
 	.rt6i_ref	= ATOMIC_INIT(1),
@@ -1463,8 +1463,15 @@ int ip6_route_add(struct fib6_config *cfg)
 		}
 		rt->dst.output = ip6_pkt_discard_out;
 		rt->dst.input = ip6_pkt_discard;
-		rt->dst.error = -ENETUNREACH;
 		rt->rt6i_flags = RTF_REJECT|RTF_NONEXTHOP;
+		if (cfg->fc_flags & RTF_BLACKHOLE) {
+			rt->dst.error = -EINVAL;
+			rt->rt6i_flags |= RTF_BLACKHOLE;
+		} else if (cfg->fc_flags & RTF_PROHIBIT) {
+			rt->dst.error = -EACCES;
+			rt->rt6i_flags |= RTF_PROHIBIT;
+		} else
+			rt->dst.error = -ENETUNREACH;
 		goto install_route;
 	}
 
@@ -2264,6 +2271,10 @@ static int rtm_to_fib6_config(struct sk_buff *skb, struct nlmsghdr *nlh,
 
 	if (rtm->rtm_type == RTN_UNREACHABLE)
 		cfg->fc_flags |= RTF_REJECT;
+	if (rtm->rtm_type == RTN_BLACKHOLE)
+		cfg->fc_flags |= RTF_REJECT | RTF_BLACKHOLE;
+	if (rtm->rtm_type == RTN_PROHIBIT)
+		cfg->fc_flags |= RTF_REJECT | RTF_PROHIBIT;
 
 	if (rtm->rtm_type == RTN_LOCAL)
 		cfg->fc_flags |= RTF_LOCAL;
@@ -2391,8 +2402,14 @@ static int rt6_fill_node(struct net *net,
 	rtm->rtm_table = table;
 	if (nla_put_u32(skb, RTA_TABLE, table))
 		goto nla_put_failure;
-	if (rt->rt6i_flags & RTF_REJECT)
-		rtm->rtm_type = RTN_UNREACHABLE;
+	if (rt->rt6i_flags & RTF_REJECT) {
+		if (rt->rt6i_flags & RTF_BLACKHOLE)
+			rtm->rtm_type = RTN_BLACKHOLE;
+		else if (rt->rt6i_flags & RTF_PROHIBIT)
+			rtm->rtm_type = RTN_PROHIBIT;
+		else
+			rtm->rtm_type = RTN_UNREACHABLE;
+	}
 	else if (rt->rt6i_flags & RTF_LOCAL)
 		rtm->rtm_type = RTN_LOCAL;
 	else if (rt->dst.dev && (rt->dst.dev->flags & IFF_LOOPBACK))
-- 
1.7.10.4


--------------080801060909060302040707--
