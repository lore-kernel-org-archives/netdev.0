From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ip6tnl: Optimize multiple unregistration
Date: Wed, 28 Oct 2009 16:16:51 +0100
Message-ID: <4AE86063.3080005@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:35581 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754503AbZJ1PQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 11:16:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Speedup module unloading by factorizing synchronize_rcu() calls

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/ip6_tunnel.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 670c291..6c1b5c9 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1393,14 +1393,19 @@ static void ip6_tnl_destroy_tunnels(struct ip6_tnl_net *ip6n)
 {
 	int h;
 	struct ip6_tnl *t;
+	LIST_HEAD(list);
 
 	for (h = 0; h < HASH_SIZE; h++) {
-		while ((t = ip6n->tnls_r_l[h]) != NULL)
-			unregister_netdevice(t->dev);
+		t = ip6n->tnls_r_l[h];
+		while (t != NULL) {
+			unregister_netdevice_queue(t->dev, &list);
+			t = t->next;
+		}
 	}
 
 	t = ip6n->tnls_wc[0];
-	unregister_netdevice(t->dev);
+	unregister_netdevice_queue(t->dev, &list);
+	unregister_netdevice_many(&list);
 }
 
 static int ip6_tnl_init_net(struct net *net)
