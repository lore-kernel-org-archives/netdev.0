From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] net/ip6_tunnel: fix dst leak
Date: Wed, 18 Nov 2015 16:40:19 +0100
Message-ID: <9dd416a82166a27f5cf5eda71a63222a0eb96c04.1447859978.git.pabeni@redhat.com>
Cc: Martin KaFai Lau <kafai@fb.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40689 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932892AbbKRPkc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2015 10:40:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the commit cdf3464e6c6b ("ipv6: Fix dst_entry refcnt bugs in ip6_tunnel")
introduced percpu storage for ip6_tunnel dst cache, but while clearing
such cache it used raw_cpu_ptr to walk the per cpu entries, so cached
dst on non current cpu are not actually reset.

This patch replaces raw_cpu_ptr with per_cpu_ptr, properly cleaning
such storage.

Fixes: cdf3464e6c6b ("ipv6: Fix dst_entry refcnt bugs in ip6_tunnel")

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv6/ip6_tunnel.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index eabffbb..137fca4 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -177,7 +177,7 @@ void ip6_tnl_dst_reset(struct ip6_tnl *t)
 	int i;
 
 	for_each_possible_cpu(i)
-		ip6_tnl_per_cpu_dst_set(raw_cpu_ptr(t->dst_cache), NULL);
+		ip6_tnl_per_cpu_dst_set(per_cpu_ptr(t->dst_cache, i), NULL);
 }
 EXPORT_SYMBOL_GPL(ip6_tnl_dst_reset);
 
-- 
1.8.3.1
