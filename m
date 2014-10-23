From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net] tcp: md5: do not use alloc_percpu()
Date: Thu, 23 Oct 2014 12:58:58 -0700
Message-ID: <1414094338.20845.30.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5447FDB2.2010906@gmail.com> <544886C4.4020702@gmail.com>
	 <1414041833.2094.28.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1414042688.2094.30.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5448A72D.1050806@cumulusnetworks.com>
	 <1414070490.2094.39.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1414075405.20845.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1414081998.20845.18.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsahern@gmail.com>,
	Crestez Dan Leonard <cdleonard@gmail.com>,
	netdev@vger.kernel.org,
	Jonathan Toppins <jtoppins@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:52688 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754070AbaJWT7A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 15:59:00 -0400
Received: by mail-pa0-f49.google.com with SMTP id hz1so1686325pad.36
        for <netdev@vger.kernel.org>; Thu, 23 Oct 2014 12:58:59 -0700 (PDT)
In-Reply-To: <1414081998.20845.18.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

percpu tcp_md5sig_pool contains memory blobs that ultimately
go through sg_set_buf().

-> sg_set_page(sg, virt_to_page(buf), buflen, offset_in_page(buf));

This requires that whole area is in a physically contiguous portion
of memory. And that @buf is not backed by vmalloc().

Given that alloc_percpu() can use vmalloc() areas, this does not
fit the requirements.

Replace alloc_percpu() by a static DEFINE_PER_CPU() as tcp_md5sig_pool
is small anyway, there is no gain to dynamically allocate it.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: 765cf9976e93 ("tcp: md5: remove one indirection level in tcp_md5sig_pool")
Reported-by: Crestez Dan Leonard <cdleonard@gmail.com>
---
 net/ipv4/tcp.c |   59 +++++++++++++++--------------------------------
 1 file changed, 20 insertions(+), 39 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1bec4e76d88c..39ec0c379545 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2868,61 +2868,42 @@ EXPORT_SYMBOL(compat_tcp_getsockopt);
 #endif
 
 #ifdef CONFIG_TCP_MD5SIG
-static struct tcp_md5sig_pool __percpu *tcp_md5sig_pool __read_mostly;
+static DEFINE_PER_CPU(struct tcp_md5sig_pool, tcp_md5sig_pool);
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
-		struct crypto_hash *hash;
-
-		hash = crypto_alloc_hash("md5", 0, CRYPTO_ALG_ASYNC);
-		if (IS_ERR_OR_NULL(hash))
-			goto out_free;
+		if (!per_cpu(tcp_md5sig_pool, cpu).md5_desc.tfm) {
+			struct crypto_hash *hash;
 
-		per_cpu_ptr(pool, cpu)->md5_desc.tfm = hash;
+			hash = crypto_alloc_hash("md5", 0, CRYPTO_ALG_ASYNC);
+			if (IS_ERR_OR_NULL(hash))
+				return;
+			per_cpu(tcp_md5sig_pool, cpu).md5_desc.tfm = hash;
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
 
@@ -2936,13 +2917,13 @@ EXPORT_SYMBOL(tcp_alloc_md5sig_pool);
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
+		/* coupled with smp_wmb() in __tcp_alloc_md5sig_pool() */
+		smp_rmb();
+		return this_cpu_ptr(&tcp_md5sig_pool);
+	}
 	local_bh_enable();
 	return NULL;
 }
