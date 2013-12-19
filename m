From: roy.qing.li@gmail.com
Subject: [PATCH net-next] ipv6: trival improvements
Date: Thu, 19 Dec 2013 14:18:52 +0800
Message-ID: <1387433932-2745-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:63263 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751315Ab3LSGSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Dec 2013 01:18:51 -0500
Received: by mail-pa0-f47.google.com with SMTP id kq14so717757pab.34
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 22:18:51 -0800 (PST)
Received: from localhost ([1.202.252.122])
        by mx.google.com with ESMTPSA id pe3sm4492128pbc.23.2013.12.18.22.18.48
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Wed, 18 Dec 2013 22:18:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

1. remove the unnecessary setting rt.rt6i_metric to 0 since memset() has clear
them.
2. call ip6_rt_put to release rt only when rt is not null in addrconf_prefix_rcv.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/addrconf.c |    3 ++-
 net/ipv6/route.c    |    2 --
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 3c3425e..6ef2e11 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2167,6 +2167,8 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
 			} else {
 				rt6_clean_expires(rt);
 			}
+
+			ip6_rt_put(rt);
 		} else if (valid_lft) {
 			clock_t expires = 0;
 			int flags = RTF_ADDRCONF | RTF_PREFIX_RT;
@@ -2178,7 +2180,6 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
 			addrconf_prefix_route(&pinfo->prefix, pinfo->prefix_len,
 					      dev, expires, flags);
 		}
-		ip6_rt_put(rt);
 	}
 
 	/* Try to figure out our local address for this prefix */
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index a1a5752..b962f29 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1060,7 +1060,6 @@ struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_ori
 
 		rt->rt6i_gateway = ort->rt6i_gateway;
 		rt->rt6i_flags = ort->rt6i_flags;
-		rt->rt6i_metric = 0;
 
 		memcpy(&rt->rt6i_dst, &ort->rt6i_dst, sizeof(struct rt6key));
 #ifdef CONFIG_IPV6_SUBTREES
@@ -1912,7 +1911,6 @@ static struct rt6_info *ip6_rt_copy(struct rt6_info *ort,
 		if ((ort->rt6i_flags & (RTF_DEFAULT | RTF_ADDRCONF)) ==
 		    (RTF_DEFAULT | RTF_ADDRCONF))
 			rt6_set_from(rt, ort);
-		rt->rt6i_metric = 0;
 
 #ifdef CONFIG_IPV6_SUBTREES
 		memcpy(&rt->rt6i_src, &ort->rt6i_src, sizeof(struct rt6key));
-- 
1.7.10.4
