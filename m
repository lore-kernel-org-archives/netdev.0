From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] NET : convert ip_rt_acct to per_cpu variables
Date: Fri, 16 Nov 2007 11:58:52 +0100
Message-ID: <20071116115852.518b696d.dada1@cosmosbay.com>
References: <20071116095903.d2ef9c14.dada1@cosmosbay.com>
	<20071116.011243.48184084.davem@davemloft.net>
	<20071116103546.8320d985.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:43608 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755429AbXKPK6w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2007 05:58:52 -0500
In-Reply-To: <20071116103546.8320d985.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 16 Nov 2007 10:35:46 +0100
Eric Dumazet <dada1@cosmosbay.com> wrote:

> On Fri, 16 Nov 2007 01:12:43 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Eric Dumazet <dada1@cosmosbay.com>
> > Date: Fri, 16 Nov 2007 09:59:03 +0100
> > 
> > > [PATCH] NET : NET_CLS_ROUTE : convert ip_rt_acct to per_cpu variables
> > > 
> > > ip_rt_acct needs 4096 bytes per cpu to perform some accounting.
> > > It is actually allocated as a single huge array [4096*NR_CPUS]
> > > (rounded up to a power of two)
> > > 
> > > Converting it to a per cpu variable is wanted to :
> > >  - Save space on machines were num_possible_cpus() < NR_CPUS
> > >  - Better NUMA placement (each cpu gets memory on its node)
> > > 
> > > Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> > 
> > This is better in one sense but worse in another.
> > 
> > At least the previous code dynamically allocated the thing,
> > now at least one copy is taking up core kernel text image
> > space.
> 
> Oh I see, you think that adding 4096 null bytes to the static percpu area might be a problem.
> 
> > 
> > I think it's an alloc_percpu() candidate, what do you think?
> > 
> 
> Yes absolutely, I will submit a new version.
> 
> Thank you

[PATCH] NET : NET_CLS_ROUTE : convert ip_rt_acct to per_cpu variables

ip_rt_acct needs 4096 bytes per cpu to perform some accounting.
It is actually allocated as a single huge array [4096*NR_CPUS]
(rounded up to a power of two)

Converting it to a per cpu variable is wanted to :
 - Save space on machines were num_possible_cpus() < NR_CPUS
 - Better NUMA placement (each cpu gets memory on its node)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

 net/ipv4/ip_input.c |    2 +-
 net/ipv4/route.c    |   15 +++------------
 2 files changed, 4 insertions(+), 13 deletions(-)


diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 5b8a760..4068e17 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -347,7 +347,7 @@ static int ip_rcv_finish(struct sk_buff *skb)
 
 #ifdef CONFIG_NET_CLS_ROUTE
 	if (unlikely(skb->dst->tclassid)) {
-		struct ip_rt_acct *st = ip_rt_acct + 256*smp_processor_id();
+		struct ip_rt_acct *st = per_cpu_ptr(ip_rt_acct, smp_processor_id());
 		u32 idx = skb->dst->tclassid;
 		st[idx&0xFF].o_packets++;
 		st[idx&0xFF].o_bytes+=skb->len;
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 70529a9..856807c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2855,12 +2855,10 @@ ctl_table ipv4_route_table[] = {
 #endif
 
 #ifdef CONFIG_NET_CLS_ROUTE
-struct ip_rt_acct *ip_rt_acct;
-
-/* This code sucks.  But you should have seen it before! --RR */
+struct ip_rt_acct *ip_rt_acct __read_mostly;
 
 /* IP route accounting ptr for this logical cpu number. */
-#define IP_RT_ACCT_CPU(i) (ip_rt_acct + i * 256)
+#define IP_RT_ACCT_CPU(cpu) (per_cpu_ptr(ip_rt_acct, cpu))
 
 #ifdef CONFIG_PROC_FS
 static int ip_rt_acct_read(char *buffer, char **start, off_t offset,
@@ -2920,16 +2918,9 @@ int __init ip_rt_init(void)
 			     (jiffies ^ (jiffies >> 7)));
 
 #ifdef CONFIG_NET_CLS_ROUTE
-	{
-	int order;
-	for (order = 0;
-	     (PAGE_SIZE << order) < 256 * sizeof(struct ip_rt_acct) * NR_CPUS; order++)
-		/* NOTHING */;
-	ip_rt_acct = (struct ip_rt_acct *)__get_free_pages(GFP_KERNEL, order);
+	ip_rt_acct = __alloc_percpu(256 * sizeof(struct ip_rt_acct));
 	if (!ip_rt_acct)
 		panic("IP: failed to allocate ip_rt_acct\n");
-	memset(ip_rt_acct, 0, PAGE_SIZE << order);
-	}
 #endif
 
 	ipv4_dst_ops.kmem_cachep =

