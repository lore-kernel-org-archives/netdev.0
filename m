From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] NET : convert ip_rt_acct to per_cpu variables
Date: Fri, 16 Nov 2007 09:59:03 +0100
Message-ID: <20071116095903.d2ef9c14.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:42032 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752311AbXKPI7F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2007 03:59:05 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David

I am chasing NR_CPUS syndrom for your NR_CPUS=4096 machines :)

(Feel free to give me an account on one of them just for fun)

I made this patch but have no idea if it actually works 
(only compile tested) because I dont know how to use this
CONFIG_NET_CLS_ROUTE stuff

Thank you

[PATCH] NET : NET_CLS_ROUTE : convert ip_rt_acct to per_cpu variables

ip_rt_acct needs 4096 bytes per cpu to perform some accounting.
It is actually allocated as a single huge array [4096*NR_CPUS]
(rounded up to a power of two)

Converting it to a per cpu variable is wanted to :
 - Save space on machines were num_possible_cpus() < NR_CPUS
 - Better NUMA placement (each cpu gets memory on its node)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

 include/net/route.h |    2 +-
 net/ipv4/ip_input.c |    2 +-
 net/ipv4/route.c    |   17 ++---------------
 3 files changed, 4 insertions(+), 17 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index f7ce625..3044fd1 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -103,7 +103,7 @@ struct rt_cache_stat
         unsigned int out_hlist_search;
 };
 
-extern struct ip_rt_acct *ip_rt_acct;
+DECLARE_PER_CPU(struct ip_rt_acct[256], ip_rt_acct);
 
 struct in_device;
 extern int		ip_rt_init(void);
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 5b8a760..82f9a52 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -347,7 +347,7 @@ static int ip_rcv_finish(struct sk_buff *skb)
 
 #ifdef CONFIG_NET_CLS_ROUTE
 	if (unlikely(skb->dst->tclassid)) {
-		struct ip_rt_acct *st = ip_rt_acct + 256*smp_processor_id();
+		struct ip_rt_acct *st = __get_cpu_var(ip_rt_acct);
 		u32 idx = skb->dst->tclassid;
 		st[idx&0xFF].o_packets++;
 		st[idx&0xFF].o_bytes+=skb->len;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f0b28f9..83b319a 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2855,12 +2855,12 @@ ctl_table ipv4_route_table[] = {
 #endif
 
 #ifdef CONFIG_NET_CLS_ROUTE
-struct ip_rt_acct *ip_rt_acct;
+DEFINE_PER_CPU(struct ip_rt_acct [256], ip_rt_acct);
 
 /* This code sucks.  But you should have seen it before! --RR */
 
 /* IP route accounting ptr for this logical cpu number. */
-#define IP_RT_ACCT_CPU(i) (ip_rt_acct + i * 256)
+#define IP_RT_ACCT_CPU(i) (per_cpu(ip_rt_acct, i))
 
 #ifdef CONFIG_PROC_FS
 static int ip_rt_acct_read(char *buffer, char **start, off_t offset,
@@ -2923,19 +2923,6 @@ int __init ip_rt_init(void)
 	rt_hash_rnd = (int) ((num_physpages ^ (num_physpages>>8)) ^
 			     (jiffies ^ (jiffies >> 7)));
 
-#ifdef CONFIG_NET_CLS_ROUTE
-	{
-	int order;
-	for (order = 0;
-	     (PAGE_SIZE << order) < 256 * sizeof(struct ip_rt_acct) * NR_CPUS; order++)
-		/* NOTHING */;
-	ip_rt_acct = (struct ip_rt_acct *)__get_free_pages(GFP_KERNEL, order);
-	if (!ip_rt_acct)
-		panic("IP: failed to allocate ip_rt_acct\n");
-	memset(ip_rt_acct, 0, PAGE_SIZE << order);
-	}
-#endif
-
 	ipv4_dst_ops.kmem_cachep =
 		kmem_cache_create("ip_dst_cache", sizeof(struct rtable), 0,
 				  SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL);
