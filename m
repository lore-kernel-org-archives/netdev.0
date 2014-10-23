From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: md5: percpu tcp_md5sig_pool must not span pages
Date: Thu, 23 Oct 2014 09:33:18 -0700
Message-ID: <1414081998.20845.18.camel@edumazet-glaptop2.roam.corp.google.com>
References: <5447FDB2.2010906@gmail.com> <544886C4.4020702@gmail.com>
	 <1414041833.2094.28.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1414042688.2094.30.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5448A72D.1050806@cumulusnetworks.com>
	 <1414070490.2094.39.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1414075405.20845.6.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Ahern <dsahern@gmail.com>,
	Crestez Dan Leonard <cdleonard@gmail.com>,
	netdev@vger.kernel.org
To: Jonathan Toppins <jtoppins@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:44948 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751102AbaJWQdV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 12:33:21 -0400
Received: by mail-pa0-f50.google.com with SMTP id eu11so1356895pac.37
        for <netdev@vger.kernel.org>; Thu, 23 Oct 2014 09:33:21 -0700 (PDT)
In-Reply-To: <1414075405.20845.6.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

percpu tcp_md5sig_pool contains memory blobs that ultimately
go through sg_set_buf().

-> sg_set_page(sg, virt_to_page(buf), buflen, offset_in_page(buf));

This requires that whole area is in a physically contiguous portion
of memory.

Given that alloc_percpu() can use vmalloc() areas, we need to make sure
tcp_md5sig_pool is allocated from a single page.


Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: 765cf9976e93 ("tcp: md5: remove one indirection level in tcp_md5sig_pool")
Reported-by: Crestez Dan Leonard <cdleonard@gmail.com>
---

Jonathan, David and Crestez, please test this patch fixes
the issue for good. We might in future kernels avoid the dynamic
memory allocations, but a simple fix for stable kernels is better IMO.

Thanks !

 net/ipv4/tcp.c |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 1bec4e76d88c5852d8ba3392b22aa58d6453ab4d..1f59e4130db99f129279c13f89b3c058ed6167e2 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2886,10 +2886,17 @@ static void __tcp_free_md5sig_pool(struct tcp_md5sig_pool __percpu *pool)
 
 static void __tcp_alloc_md5sig_pool(void)
 {
-	int cpu;
 	struct tcp_md5sig_pool __percpu *pool;
+	size_t align;
+	int cpu;
 
-	pool = alloc_percpu(struct tcp_md5sig_pool);
+	/* sg_set_buf() assumes a contiguous memory area, but alloc_percpu()
+	 * can use vmalloc(). So make sure we request an alignment so that
+	 * whole tcp_md5sig_pool is contained in a single page.
+	 */
+	BUILD_BUG_ON(sizeof(struct tcp_md5sig_pool) > PAGE_SIZE);
+	align = roundup_pow_of_two(sizeof(struct tcp_md5sig_pool));
+	pool = __alloc_percpu(sizeof(struct tcp_md5sig_pool), align);
 	if (!pool)
 		return;
 
