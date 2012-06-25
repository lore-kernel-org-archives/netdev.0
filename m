From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] netfilter: ipvs: fix dst leak in __ip_vs_addr_is_local_v6
Date: Mon, 25 Jun 2012 09:58:23 +0200
Message-ID: <1340611103.10893.14.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	David Miller <davem@davemloft.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <edumazet@google.com>

After call to ip6_route_output() we must release dst or we leak it.

Also should test dst->error, as ip6_route_output() never returns NULL.

Use boolean while we are at it.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/netfilter/ipvs/ip_vs_ctl.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index dd811b8..d43e3c1 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -76,19 +76,19 @@ static void __ip_vs_del_service(struct ip_vs_service *svc);
 
 #ifdef CONFIG_IP_VS_IPV6
 /* Taken from rt6_fill_node() in net/ipv6/route.c, is there a better way? */
-static int __ip_vs_addr_is_local_v6(struct net *net,
-				    const struct in6_addr *addr)
+static bool __ip_vs_addr_is_local_v6(struct net *net,
+				     const struct in6_addr *addr)
 {
-	struct rt6_info *rt;
 	struct flowi6 fl6 = {
 		.daddr = *addr,
 	};
+	struct dst_entry *dst = ip6_route_output(net, NULL, &fl6);
+	bool is_local;
 
-	rt = (struct rt6_info *)ip6_route_output(net, NULL, &fl6);
-	if (rt && rt->dst.dev && (rt->dst.dev->flags & IFF_LOOPBACK))
-		return 1;
+	is_local = !dst->error && dst->dev && (dst->dev->flags & IFF_LOOPBACK);
 
-	return 0;
+	dst_release(dst);
+	return is_local;
 }
 #endif
 


