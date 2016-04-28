From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] ip_tunnel: fix preempt warning in ip tunnel creation/updating
Date: Thu, 28 Apr 2016 11:04:51 +0200
Message-ID: <b21056e2495c485a2084d058d03e1f95480b3510.1461834203.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, tgraf@suug.ch,
	pshelar@nicira.com, jbenc@redhat.com, hannes@stressinduktion.org,
	sergei.shtylyov@cogentembedded.com,
	Tom Herbert <tom@herbertland.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33332 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752907AbcD1JFf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2016 05:05:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After the commit e09acddf873b ("ip_tunnel: replace dst_cache with generic
implementation"), a preemption debug warning is triggered on ip4
tunnels updating; the dst cache helper needs to be invoked in unpreemptible
context.

We don't need to load the cache on tunnel update, so this commit fixes
the warning replacing the load with a dst cache reset, which is
preempt safe.

Fixes: e09acddf873b ("ip_tunnel: replace dst_cache with generic
implementation")

Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/ip_tunnel.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 6aad019..a69ed94 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -326,12 +326,12 @@ static int ip_tunnel_bind_dev(struct net_device *dev)
 
 		if (!IS_ERR(rt)) {
 			tdev = rt->dst.dev;
-			dst_cache_set_ip4(&tunnel->dst_cache, &rt->dst,
-					  fl4.saddr);
 			ip_rt_put(rt);
 		}
 		if (dev->type != ARPHRD_ETHER)
 			dev->flags |= IFF_POINTOPOINT;
+
+		dst_cache_reset(&tunnel->dst_cache);
 	}
 
 	if (!tdev && tunnel->parms.link)
-- 
1.8.3.1
