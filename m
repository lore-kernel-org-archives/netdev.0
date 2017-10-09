From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: avoid zeroing per cpu data again
Date: Mon, 09 Oct 2017 06:01:37 -0700
Message-ID: <1507554097.31614.11.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Martin KaFai Lau <kafai@fb.com>,
        Tejun Heo <tj@kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:37078 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754668AbdJINBk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 09:01:40 -0400
Received: by mail-pf0-f193.google.com with SMTP id z80so9063114pff.4
        for <netdev@vger.kernel.org>; Mon, 09 Oct 2017 06:01:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

per cpu allocations are already zeroed, no need to clear them again.

Fixes: d52d3997f843f ("ipv6: Create percpu rt6_info")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Martin KaFai Lau <kafai@fb.com>
Cc: Tejun Heo <tj@kernel.org>
---
 net/ipv6/route.c |   12 +-----------
 1 file changed, 1 insertion(+), 11 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 606e80325b21c0e10a02e9c7d5b3fcfbfc26a003..3d7d4e09301ef4deae1985412599c6f4e973c46f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -377,17 +377,7 @@ struct rt6_info *ip6_dst_alloc(struct net *net,
 
 	if (rt) {
 		rt->rt6i_pcpu = alloc_percpu_gfp(struct rt6_info *, GFP_ATOMIC);
-		if (rt->rt6i_pcpu) {
-			int cpu;
-
-			for_each_possible_cpu(cpu) {
-				struct rt6_info **p;
-
-				p = per_cpu_ptr(rt->rt6i_pcpu, cpu);
-				/* no one shares rt */
-				*p =  NULL;
-			}
-		} else {
+		if (!rt->rt6i_pcpu) {
 			dst_release_immediate(&rt->dst);
 			return NULL;
 		}
