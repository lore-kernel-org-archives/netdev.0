From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tcp md5 use of alloc_percpu
Date: Wed, 22 Oct 2014 18:47:57 -0700
Message-ID: <1414028877.2094.4.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5447FDB2.2010906@gmail.com>
	 <54483FF7.4090208@cumulusnetworks.com> <54485337.5040108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jonathan Toppins <jtoppins@cumulusnetworks.com>,
	netdev@vger.kernel.org
To: Crestez Dan Leonard <cdleonard@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:58137 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753344AbaJWBr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 21:47:59 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa1so94468pad.19
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 18:47:58 -0700 (PDT)
In-Reply-To: <54485337.5040108@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-10-23 at 04:00 +0300, Crestez Dan Leonard wrote:
> On 10/23/2014 02:38 AM, Jonathan Toppins wrote:
> > On 10/22/14, 2:55 PM, Crestez Dan Leonard wrote:
> >> sg_init_one does virt_addr on the pointer which assumes it is directly accessible. But the tcp_md5sig_pool pointer comes from alloc_percpu which can return memory from the vmalloc area after the pcpu_first_chunk is exhausted. This looks wrong to me. I'm am getting crashes on mips and I believe this to be the cause.
> >
> > Thinking about this more if the issue really is sg_init_one assumes a
> > directly accessible memory region, can we just modify the zone
> > allocation to GFP_DMA using alloc_percpu_gfp()? Does this satisfy the
> > assumptions made by sg_init_one?
> I don't think that alloc_percpu_gfp can be used that way. Looking at the 
> code it only checks for GFP_KERNEL and behaves "atomically" if it is not 
> present. This means that it fails rather than vmalloc a new percpu_chunk.
> 
> The problem is not that the memory is not allocated with GFP_DMA but 
> rather that the memory is allocated with vmalloc.

Could you try the following patch ?

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1bec4e76d88c..d253ad8ced64 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2868,30 +2868,29 @@ EXPORT_SYMBOL(compat_tcp_getsockopt);
 #endif
 
 #ifdef CONFIG_TCP_MD5SIG
-static struct tcp_md5sig_pool __percpu *tcp_md5sig_pool __read_mostly;
+static DEFINE_PER_CPU(struct tcp_md5sig_pool, tcp_md5sig_pool);
 static DEFINE_MUTEX(tcp_md5sig_mutex);
+static bool tcp_md5sig_pool_populated = false;
 
-static void __tcp_free_md5sig_pool(struct tcp_md5sig_pool __percpu *pool)
+static void tcp_free_md5sig_pool(void)
 {
 	int cpu;
 
 	for_each_possible_cpu(cpu) {
-		struct tcp_md5sig_pool *p = per_cpu_ptr(pool, cpu);
+		struct crypto_hash *hash;
+
+		hash = per_cpu(tcp_md5sig_pool, cpu).md5_desc.tfm;
 
-		if (p->md5_desc.tfm)
-			crypto_free_hash(p->md5_desc.tfm);
+		if (hash) {
+			crypto_free_hash(hash);
+			per_cpu(tcp_md5sig_pool, cpu).md5_desc.tfm = NULL;
+		}
 	}
-	free_percpu(pool);
 }
 
 static void __tcp_alloc_md5sig_pool(void)
 {
 	int cpu;
-	struct tcp_md5sig_pool __percpu *pool;
-
-	pool = alloc_percpu(struct tcp_md5sig_pool);
-	if (!pool)
-		return;
 
 	for_each_possible_cpu(cpu) {
 		struct crypto_hash *hash;
@@ -2900,29 +2899,29 @@ static void __tcp_alloc_md5sig_pool(void)
 		if (IS_ERR_OR_NULL(hash))
 			goto out_free;
 
-		per_cpu_ptr(pool, cpu)->md5_desc.tfm = hash;
+		per_cpu(tcp_md5sig_pool, cpu).md5_desc.tfm = hash;
 	}
-	/* before setting tcp_md5sig_pool, we must commit all writes
-	 * to memory. See ACCESS_ONCE() in tcp_get_md5sig_pool()
+	/* before setting tcp_md5sig_pool_populated, we must commit all writes
+	 * to memory. See smp_rmb() in tcp_get_md5sig_pool()
 	 */
 	smp_wmb();
-	tcp_md5sig_pool = pool;
+	tcp_md5sig_pool_populated = true;
 	return;
 out_free:
-	__tcp_free_md5sig_pool(pool);
+	tcp_free_md5sig_pool();
 }
 
 bool tcp_alloc_md5sig_pool(void)
 {
-	if (unlikely(!tcp_md5sig_pool)) {
+	if (unlikely(!tcp_md5sig_pool_populated)) {
 		mutex_lock(&tcp_md5sig_mutex);
 
-		if (!tcp_md5sig_pool)
+		if (!tcp_md5sig_pool_populated)
 			__tcp_alloc_md5sig_pool();
 
 		mutex_unlock(&tcp_md5sig_mutex);
 	}
-	return tcp_md5sig_pool != NULL;
+	return tcp_md5sig_pool_populated;
 }
 EXPORT_SYMBOL(tcp_alloc_md5sig_pool);
 
@@ -2936,13 +2935,13 @@ EXPORT_SYMBOL(tcp_alloc_md5sig_pool);
  */
 struct tcp_md5sig_pool *tcp_get_md5sig_pool(void)
 {
-	struct tcp_md5sig_pool __percpu *p;
-
 	local_bh_disable();
-	p = ACCESS_ONCE(tcp_md5sig_pool);
-	if (p)
-		return raw_cpu_ptr(p);
 
+	if (tcp_md5sig_pool_populated) {
+		/* coupled with smp_wmb() in __tcp_alloc_md5sig_pool */
+		smp_rmb();
+		return this_cpu_ptr(&tcp_md5sig_pool);
+	}
 	local_bh_enable();
 	return NULL;
 }
