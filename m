From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/3] ipv4: Remove route key identity dependencies in
 ip_rt_get_source().
Date: Fri, 13 May 2011 17:51:42 -0400 (EDT)
Message-ID: <20110513.175142.977249511578251903.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48465 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757238Ab1EMVvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 17:51:45 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4DLphwT021446
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 13 May 2011 14:51:44 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Pass in the sk_buff so that we can fetch the necessary keys from
the packet header when working with input routes.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/route.h   |    2 +-
 net/ipv4/ip_options.c |   12 ++++++------
 net/ipv4/route.c      |   24 ++++++++++++++----------
 3 files changed, 21 insertions(+), 17 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index 9f8070b..ba0e084 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -189,7 +189,7 @@ extern unsigned		inet_addr_type(struct net *net, __be32 addr);
 extern unsigned		inet_dev_addr_type(struct net *net, const struct net_device *dev, __be32 addr);
 extern void		ip_rt_multicast_event(struct in_device *);
 extern int		ip_rt_ioctl(struct net *, unsigned int cmd, void __user *arg);
-extern void		ip_rt_get_source(u8 *src, struct rtable *rt);
+extern void		ip_rt_get_source(u8 *src, struct sk_buff *skb, struct rtable *rt);
 extern int		ip_rt_dump(struct sk_buff *skb,  struct netlink_callback *cb);
 
 struct in_ifaddr;
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index c6474cd..89268ba 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -37,7 +37,7 @@
  */
 
 void ip_options_build(struct sk_buff *skb, struct ip_options *opt,
-			    __be32 daddr, struct rtable *rt, int is_frag)
+		      __be32 daddr, struct rtable *rt, int is_frag)
 {
 	unsigned char *iph = skb_network_header(skb);
 
@@ -50,9 +50,9 @@ void ip_options_build(struct sk_buff *skb, struct ip_options *opt,
 
 	if (!is_frag) {
 		if (opt->rr_needaddr)
-			ip_rt_get_source(iph+opt->rr+iph[opt->rr+2]-5, rt);
+			ip_rt_get_source(iph+opt->rr+iph[opt->rr+2]-5, skb, rt);
 		if (opt->ts_needaddr)
-			ip_rt_get_source(iph+opt->ts+iph[opt->ts+2]-9, rt);
+			ip_rt_get_source(iph+opt->ts+iph[opt->ts+2]-9, skb, rt);
 		if (opt->ts_needtime) {
 			struct timespec tv;
 			__be32 midtime;
@@ -553,7 +553,7 @@ void ip_forward_options(struct sk_buff *skb)
 
 	if (opt->rr_needaddr) {
 		optptr = (unsigned char *)raw + opt->rr;
-		ip_rt_get_source(&optptr[optptr[2]-5], rt);
+		ip_rt_get_source(&optptr[optptr[2]-5], skb, rt);
 		opt->is_changed = 1;
 	}
 	if (opt->srr_is_hit) {
@@ -572,13 +572,13 @@ void ip_forward_options(struct sk_buff *skb)
 		}
 		if (srrptr + 3 <= srrspace) {
 			opt->is_changed = 1;
-			ip_rt_get_source(&optptr[srrptr-1], rt);
+			ip_rt_get_source(&optptr[srrptr-1], skb, rt);
 			optptr[2] = srrptr+4;
 		} else if (net_ratelimit())
 			printk(KERN_CRIT "ip_forward(): Argh! Destination lost!\n");
 		if (opt->ts_needaddr) {
 			optptr = raw + opt->ts;
-			ip_rt_get_source(&optptr[optptr[2]-9], rt);
+			ip_rt_get_source(&optptr[optptr[2]-9], skb, rt);
 			opt->is_changed = 1;
 		}
 	}
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 6a83840..ad141d8 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1699,22 +1699,26 @@ static int ip_rt_bug(struct sk_buff *skb)
    in IP options!
  */
 
-void ip_rt_get_source(u8 *addr, struct rtable *rt)
+void ip_rt_get_source(u8 *addr, struct sk_buff *skb, struct rtable *rt)
 {
 	__be32 src;
-	struct fib_result res;
 
 	if (rt_is_output_route(rt))
 		src = rt->rt_src;
 	else {
-		struct flowi4 fl4 = {
-			.daddr = rt->rt_key_dst,
-			.saddr = rt->rt_key_src,
-			.flowi4_tos = rt->rt_key_tos,
-			.flowi4_oif = rt->rt_oif,
-			.flowi4_iif = rt->rt_iif,
-			.flowi4_mark = rt->rt_mark,
-		};
+		struct fib_result res;
+		struct flowi4 fl4;
+		struct iphdr *iph;
+
+		iph = ip_hdr(skb);
+
+		memset(&fl4, 0, sizeof(fl4));
+		fl4.daddr = iph->daddr;
+		fl4.saddr = iph->saddr;
+		fl4.flowi4_tos = iph->tos;
+		fl4.flowi4_oif = rt->dst.dev->ifindex;
+		fl4.flowi4_iif = skb->dev->ifindex;
+		fl4.flowi4_mark = skb->mark;
 
 		rcu_read_lock();
 		if (fib_lookup(dev_net(rt->dst.dev), &fl4, &res) == 0)
-- 
1.7.4.4

