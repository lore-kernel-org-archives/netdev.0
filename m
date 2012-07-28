From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ipv6: BUG: unable to handle kernel paging request at
 0000000101bca2be
Date: Sat, 28 Jul 2012 21:21:27 +0200
Message-ID: <1343503287.2626.13180.camel@edumazet-glaptop>
References: <50141C95.3030602@opensuse.org>
	 <1343502509.2626.13172.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Gao feng <gaofeng@cn.fujitsu.com>
To: Cristian =?ISO-8859-1?Q?Rodr=EDguez?= <crrodriguez@opensuse.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:48519 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752322Ab2G1TVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jul 2012 15:21:32 -0400
Received: by wgbfm10 with SMTP id fm10so1452061wgb.1
        for <netdev@vger.kernel.org>; Sat, 28 Jul 2012 12:21:31 -0700 (PDT)
In-Reply-To: <1343502509.2626.13172.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-07-28 at 21:08 +0200, Eric Dumazet wrote:

> This looks like an error coming from commit
> 1716a96101c49186bb0b8491922fd3e69030235f
> (ipv6: fix problem with expired dst cache)
> 
> dst_release() is called with a bogus dst pointer : 0000000101bca23e
> 
> rt6_clean_expires() seems to be called where it shouldnt.
> 
> Could you try reverting it ?
> 

Or try following patch instead :

diff --git a/include/net/ip6_fib.h b/include/net/ip6_fib.h
index 0ae759a..a85a865 100644
--- a/include/net/ip6_fib.h
+++ b/include/net/ip6_fib.h
@@ -123,13 +123,18 @@ static inline struct inet6_dev *ip6_dst_idev(struct dst_entry *dst)
 	return ((struct rt6_info *)dst)->rt6i_idev;
 }
 
+static inline void __rt6_clean_expires(struct rt6_info *rt)
+{
+	rt->rt6i_flags &= ~RTF_EXPIRES;
+	rt->dst.from = NULL;
+}
+
 static inline void rt6_clean_expires(struct rt6_info *rt)
 {
 	if (!(rt->rt6i_flags & RTF_EXPIRES) && rt->dst.from)
 		dst_release(rt->dst.from);
 
-	rt->rt6i_flags &= ~RTF_EXPIRES;
-	rt->dst.from = NULL;
+	__rt6_clean_expires(rt);
 }
 
 static inline void rt6_set_expires(struct rt6_info *rt, unsigned long expires)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index becb048..965f315 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -969,7 +969,7 @@ struct dst_entry *ip6_blackhole_route(struct net *net, struct dst_entry *dst_ori
 
 		rt->rt6i_gateway = ort->rt6i_gateway;
 		rt->rt6i_flags = ort->rt6i_flags;
-		rt6_clean_expires(rt);
+		__rt6_clean_expires(rt);
 		rt->rt6i_metric = 0;
 
 		memcpy(&rt->rt6i_dst, &ort->rt6i_dst, sizeof(struct rt6key));
@@ -1305,7 +1305,7 @@ int ip6_route_add(struct fib6_config *cfg)
 		rt6_set_expires(rt, jiffies +
 				clock_t_to_jiffies(cfg->fc_expires));
 	else
-		rt6_clean_expires(rt);
+		__rt6_clean_expires(rt);
 
 	if (cfg->fc_protocol == RTPROT_UNSPEC)
 		cfg->fc_protocol = RTPROT_BOOT;
@@ -1837,7 +1837,7 @@ static struct rt6_info *ip6_rt_copy(struct rt6_info *ort,
 		    (RTF_DEFAULT | RTF_ADDRCONF))
 			rt6_set_from(rt, ort);
 		else
-			rt6_clean_expires(rt);
+			__rt6_clean_expires(rt);
 		rt->rt6i_metric = 0;
 
 #ifdef CONFIG_IPV6_SUBTREES
