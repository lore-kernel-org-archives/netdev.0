From: David Miller <davem@davemloft.net>
Subject: [PATCH 9/13 net-3.1-stable] route: fix ICMP redirect validation
Date: Tue, 06 Dec 2011 16:33:39 -0500 (EST)
Message-ID: <20111206.163339.676278798295465327.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33979 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754487Ab1LFVdl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 16:33:41 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pB6LXd8Y024230
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 6 Dec 2011 13:33:40 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Flavio Leitner <fbl@redhat.com>

[ Upstream commit 7cc9150ebe8ec06cafea9f1c10d92ddacf88d8ae ]

The commit f39925dbde7788cfb96419c0f092b086aa325c0f
(ipv4: Cache learned redirect information in inetpeer.)
removed some ICMP packet validations which are required by
RFC 1122, section 3.2.2.2:
...
  A Redirect message SHOULD be silently discarded if the new
  gateway address it specifies is not on the same connected
  (sub-) net through which the Redirect arrived [INTRO:2,
  Appendix A], or if the source of the Redirect is not the
  current first-hop gateway for the specified destination (see
  Section 3.3.1).

Signed-off-by: Flavio Leitner <fbl@redhat.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |   36 +++++++++++++++++++++++++++++++-----
 1 files changed, 31 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index c3fcdb4..e9b273b 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1313,7 +1313,12 @@ static void rt_del(unsigned hash, struct rtable *rt)
 void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 		    __be32 saddr, struct net_device *dev)
 {
+	int s, i;
 	struct in_device *in_dev = __in_dev_get_rcu(dev);
+	struct rtable *rt;
+	__be32 skeys[2] = { saddr, 0 };
+	int    ikeys[2] = { dev->ifindex, 0 };
+	struct flowi4 fl4;
 	struct inet_peer *peer;
 	struct net *net;
 
@@ -1336,13 +1341,34 @@ void ip_rt_redirect(__be32 old_gw, __be32 daddr, __be32 new_gw,
 			goto reject_redirect;
 	}
 
-	peer = inet_getpeer_v4(daddr, 1);
-	if (peer) {
-		peer->redirect_learned.a4 = new_gw;
+	memset(&fl4, 0, sizeof(fl4));
+	fl4.daddr = daddr;
+	for (s = 0; s < 2; s++) {
+		for (i = 0; i < 2; i++) {
+			fl4.flowi4_oif = ikeys[i];
+			fl4.saddr = skeys[s];
+			rt = __ip_route_output_key(net, &fl4);
+			if (IS_ERR(rt))
+				continue;
 
-		inet_putpeer(peer);
+			if (rt->dst.error || rt->dst.dev != dev ||
+			    rt->rt_gateway != old_gw) {
+				ip_rt_put(rt);
+				continue;
+			}
+
+			if (!rt->peer)
+				rt_bind_peer(rt, rt->rt_dst, 1);
+
+			peer = rt->peer;
+			if (peer) {
+				peer->redirect_learned.a4 = new_gw;
+				atomic_inc(&__rt_peer_genid);
+			}
 
-		atomic_inc(&__rt_peer_genid);
+			ip_rt_put(rt);
+			return;
+		}
 	}
 	return;
 
-- 
1.7.7.3
