From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH v2 net-next 11/21] ipv6: call dst_dev_put() properly
Date: Sat, 17 Jun 2017 10:42:34 -0700
Message-ID: <20170617174244.132862-12-tracywwnj@gmail.com>
References: <20170617174244.132862-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:35896 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752802AbdFQRnw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Jun 2017 13:43:52 -0400
Received: by mail-pg0-f68.google.com with SMTP id e187so1835254pgc.3
        for <netdev@vger.kernel.org>; Sat, 17 Jun 2017 10:43:52 -0700 (PDT)
In-Reply-To: <20170617174244.132862-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

As the intend of this patch series is to completely remove dst gc,
we need to call dst_dev_put() to release the reference to dst->dev
when removing routes from fib because we won't keep the gc list anymore
and will lose the dst pointer right after removing the routes.
Without the gc list, there is no way to find all the dst's that have
dst->dev pointing to the going-down dev.
Hence, we are doing dst_dev_put() immediately before we lose the last
reference of the dst from the routing code. The next dst_check() will
trigger a route re-lookup to find another route (if there is any).

Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 net/ipv6/ip6_fib.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 3b728bcb1301..265401abb98e 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -172,6 +172,7 @@ static void rt6_free_pcpu(struct rt6_info *non_pcpu_rt)
 		ppcpu_rt = per_cpu_ptr(non_pcpu_rt->rt6i_pcpu, cpu);
 		pcpu_rt = *ppcpu_rt;
 		if (pcpu_rt) {
+			dst_dev_put(&pcpu_rt->dst);
 			dst_release(&pcpu_rt->dst);
 			rt6_rcu_free(pcpu_rt);
 			*ppcpu_rt = NULL;
@@ -186,6 +187,7 @@ static void rt6_release(struct rt6_info *rt)
 {
 	if (atomic_dec_and_test(&rt->rt6i_ref)) {
 		rt6_free_pcpu(rt);
+		dst_dev_put(&rt->dst);
 		dst_release(&rt->dst);
 		rt6_rcu_free(rt);
 	}
-- 
2.13.1.518.g3df882009-goog
