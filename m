From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH] net: blackhole route should always be recalculated
Date: Fri, 27 Aug 2010 17:47:40 +0200
Message-ID: <4C77DE1C.4080506@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060207040400040904060405"
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:39876 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291Ab0H0Pro (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Aug 2010 11:47:44 -0400
Received: by eyg5 with SMTP id 5so2162719eyg.19
        for <netdev@vger.kernel.org>; Fri, 27 Aug 2010 08:47:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060207040400040904060405
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Hi all,

I got a problem with IKE when the first packet is dropped, kernel does not 
invalidate the routing cache for next packets.

It seems to come from commit d11a4dc18bf41719c9f0d7ed494d295dd2973b92, which 
check validy of routes. With this patch, blackhole routes are not recalculated 
(when route table is not updated).
But this kind of routes are used when xfrm_lookup() returns -EREMOTE, so it 
seems logical to check the route again for next packets, and then get the right 
route.

Maybe my approach is wrong, any comments are welcome.


Regards,
Nicolas

--------------060207040400040904060405
Content-Type: text/x-diff;
 name="0001-net-blackhole-route-should-always-be-recalculated.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="0001-net-blackhole-route-should-always-be-recalculated.patch"

>From 1683b838a42429af30d6ab76d2d15d267c93c455 Mon Sep 17 00:00:00 2001
From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Fri, 27 Aug 2010 17:22:17 +0200
Subject: [PATCH] net: blackhole route should always be recalculated

Blackhole routes are used when xfrm_lookup() returns -EREMOTE (error
triggered by IKE for example), hence this kind of route is always
temporary and so we should check if a better route exists for next
packets.
Bug has been introduced by commit d11a4dc18bf41719c9f0d7ed494d295dd2973b92.

Signed-off-by: Jianzhao Wang <jianzhao.wang@6wind.com>
Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv4/route.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 3f56b6e..6298f75 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2738,6 +2738,11 @@ slow_output:
 }
 EXPORT_SYMBOL_GPL(__ip_route_output_key);
 
+static struct dst_entry *ipv4_blackhole_dst_check(struct dst_entry *dst, u32 cookie)
+{
+	return NULL;
+}
+
 static void ipv4_rt_blackhole_update_pmtu(struct dst_entry *dst, u32 mtu)
 {
 }
@@ -2746,7 +2751,7 @@ static struct dst_ops ipv4_dst_blackhole_ops = {
 	.family			=	AF_INET,
 	.protocol		=	cpu_to_be16(ETH_P_IP),
 	.destroy		=	ipv4_dst_destroy,
-	.check			=	ipv4_dst_check,
+	.check			=	ipv4_blackhole_dst_check,
 	.update_pmtu		=	ipv4_rt_blackhole_update_pmtu,
 	.entries		=	ATOMIC_INIT(0),
 };
-- 
1.5.4.5


--------------060207040400040904060405--
