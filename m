From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] tcp md5 use of alloc_percpu
Date: Wed, 22 Oct 2014 22:38:08 -0700
Message-ID: <1414042688.2094.30.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5447FDB2.2010906@gmail.com> <544886C4.4020702@gmail.com>
	 <1414041833.2094.28.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Crestez Dan Leonard <cdleonard@gmail.com>, netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:43053 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751036AbaJWFiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 01:38:09 -0400
Received: by mail-pa0-f54.google.com with SMTP id rd3so431163pab.13
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 22:38:09 -0700 (PDT)
In-Reply-To: <1414041833.2094.28.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-10-22 at 22:23 -0700, Eric Dumazet wrote:
> On Wed, 2014-10-22 at 22:40 -0600, David Ahern wrote:
> > On 10/22/14, 12:55 PM, Crestez Dan Leonard wrote:
> > > Hello,
> > >
> > > It seems that the TCP MD5 feature allocates a percpu struct tcp_md5sig_pool and uses part of that memory for a scratch buffer to do crypto on. Here is the relevant code:
> > 
> > This is a forward port of a local change to address the problem (local 
> > kernel version is 3.4 so perhaps my quick bump to top of tree is off but 
> > it shows the general idea). Been on my to-do list to figure out why this 
> > is needed, but it seems related to your problem:
> > 
> > diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> > index 1bec4e76d88c..833a676bd4b0 100644
> > --- a/net/ipv4/tcp.c
> > +++ b/net/ipv4/tcp.c
> > @@ -2941,7 +2941,7 @@ struct tcp_md5sig_pool *tcp_get_md5sig_pool(void)
> >      local_bh_disable();
> >      p = ACCESS_ONCE(tcp_md5sig_pool);
> >      if (p)
> > -       return raw_cpu_ptr(p);
> > +       return __va(per_cpu_ptr_to_phys(raw_cpu_ptr(p)));
> > 
> >      local_bh_enable();
> >      return NULL;
> 
> per_cpu_ptr_to_phys() can be pretty expensive and should not be called
> in fast path.
> 

My updated patch would be :

 net/ipv4/tcp.c |   66 +++++++++++++++++++----------------------------
 1 file changed, 28 insertions(+), 38 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1bec4e76d88c..af4dc16b61f6 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2868,61 +2868,51 @@ EXPORT_SYMBOL(compat_tcp_getsockopt);
 #endif
 
 #ifdef CONFIG_TCP_MD5SIG
-static struct tcp_md5sig_pool __percpu *tcp_md5sig_pool __read_mostly;
+static DEFINE_PER_CPU(struct tcp_md5sig_pool, *tcp_md5sig_pool);
 static DEFINE_MUTEX(tcp_md5sig_mutex);
-
-static void __tcp_free_md5sig_pool(struct tcp_md5sig_pool __percpu *pool)
-{
-	int cpu;
-
-	for_each_possible_cpu(cpu) {
-		struct tcp_md5sig_pool *p = per_cpu_ptr(pool, cpu);
-
-		if (p->md5_desc.tfm)
-			crypto_free_hash(p->md5_desc.tfm);
-	}
-	free_percpu(pool);
-}
+static bool tcp_md5sig_pool_populated = false;
 
 static void __tcp_alloc_md5sig_pool(void)
 {
 	int cpu;
-	struct tcp_md5sig_pool __percpu *pool;
-
-	pool = alloc_percpu(struct tcp_md5sig_pool);
-	if (!pool)
-		return;
 
 	for_each_possible_cpu(cpu) {
+		struct tcp_md5sig_pool *pool;
 		struct crypto_hash *hash;
 
-		hash = crypto_alloc_hash("md5", 0, CRYPTO_ALG_ASYNC);
-		if (IS_ERR_OR_NULL(hash))
-			goto out_free;
-
-		per_cpu_ptr(pool, cpu)->md5_desc.tfm = hash;
+		pool = per_cpu(tcp_md5sig_pool, cpu);
+		if (!pool) {
+			pool = kzalloc_node(sizeof(*pool), GFP_KERNEL,
+					    cpu_to_node(cpu));
+			if (!pool)
+				return;
+			per_cpu(tcp_md5sig_pool, cpu) = pool;
+		}
+		if (!pool->md5_desc.tfm) {
+			hash = crypto_alloc_hash("md5", 0, CRYPTO_ALG_ASYNC);
+			if (IS_ERR_OR_NULL(hash))
+				return;
+			pool->md5_desc.tfm = hash;
+		}
 	}
-	/* before setting tcp_md5sig_pool, we must commit all writes
-	 * to memory. See ACCESS_ONCE() in tcp_get_md5sig_pool()
+	/* before setting tcp_md5sig_pool_populated, we must commit all writes
+	 * to memory. See smp_rmb() in tcp_get_md5sig_pool()
 	 */
 	smp_wmb();
-	tcp_md5sig_pool = pool;
-	return;
-out_free:
-	__tcp_free_md5sig_pool(pool);
+	tcp_md5sig_pool_populated = true;
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
 
@@ -2936,13 +2926,13 @@ EXPORT_SYMBOL(tcp_alloc_md5sig_pool);
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
+		return this_cpu_read(tcp_md5sig_pool);
+	}
 	local_bh_enable();
 	return NULL;
 }
