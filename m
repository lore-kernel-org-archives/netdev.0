From: Wei Wang <tracywwnj@gmail.com>
Subject: [PATCH v2 net-next 01/21] ipv6: remove unnecessary dst_hold() in ip6_fragment()
Date: Sat, 17 Jun 2017 10:42:24 -0700
Message-ID: <20170617174244.132862-2-tracywwnj@gmail.com>
References: <20170617174244.132862-1-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35853 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752276AbdFQRnb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Jun 2017 13:43:31 -0400
Received: by mail-pg0-f67.google.com with SMTP id e187so1834993pgc.3
        for <netdev@vger.kernel.org>; Sat, 17 Jun 2017 10:43:31 -0700 (PDT)
In-Reply-To: <20170617174244.132862-1-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

In ipv6 tx path, rcu_read_lock() is taken so that dst won't get freed
during the execution of ip6_fragment(). Hence, no need to hold dst in
it.

Signed-off-by: Wei Wang <weiwan@google.com>
Acked-by: Martin KaFai Lau <kafai@fb.com>
---
 net/ipv6/ip6_output.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 8b8efb0e55bf..5baa6fab4b97 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -698,8 +698,6 @@ int ip6_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 		ipv6_hdr(skb)->payload_len = htons(first_len -
 						   sizeof(struct ipv6hdr));
 
-		dst_hold(&rt->dst);
-
 		for (;;) {
 			/* Prepare header of the next frame,
 			 * before previous one went down. */
@@ -742,7 +740,6 @@ int ip6_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 		if (err == 0) {
 			IP6_INC_STATS(net, ip6_dst_idev(&rt->dst),
 				      IPSTATS_MIB_FRAGOKS);
-			ip6_rt_put(rt);
 			return 0;
 		}
 
@@ -750,7 +747,6 @@ int ip6_fragment(struct net *net, struct sock *sk, struct sk_buff *skb,
 
 		IP6_INC_STATS(net, ip6_dst_idev(&rt->dst),
 			      IPSTATS_MIB_FRAGFAILS);
-		ip6_rt_put(rt);
 		return err;
 
 slow_path_clean:
-- 
2.13.1.518.g3df882009-goog
