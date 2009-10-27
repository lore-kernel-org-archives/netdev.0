From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 6/6] gre: Optimize multiple unregistration
Date: Tue, 27 Oct 2009 18:07:16 +0100
Message-ID: <4AE728C4.6010309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36651 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754315AbZJ0RH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 13:07:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Speedup module unloading by factorizing synchronize_rcu() calls

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ip_gre.c |   15 ++++++++++-----
 1 files changed, 10 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 40f0439..a77807d 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -1290,16 +1290,19 @@ static const struct net_protocol ipgre_protocol = {
 	.netns_ok	=	1,
 };
 
-static void ipgre_destroy_tunnels(struct ipgre_net *ign)
+static void ipgre_destroy_tunnels(struct ipgre_net *ign, struct list_head *head)
 {
 	int prio;
 
 	for (prio = 0; prio < 4; prio++) {
 		int h;
 		for (h = 0; h < HASH_SIZE; h++) {
-			struct ip_tunnel *t;
-			while ((t = ign->tunnels[prio][h]) != NULL)
-				unregister_netdevice(t->dev);
+			struct ip_tunnel *t = ign->tunnels[prio][h];
+
+			while (t != NULL) {
+				unregister_netdevice_queue(t->dev, head);
+				t = t->next;
+			}
 		}
 	}
 }
@@ -1347,10 +1350,12 @@ err_alloc:
 static void ipgre_exit_net(struct net *net)
 {
 	struct ipgre_net *ign;
+	LIST_HEAD(list);
 
 	ign = net_generic(net, ipgre_net_id);
 	rtnl_lock();
-	ipgre_destroy_tunnels(ign);
+	ipgre_destroy_tunnels(ign, &list);
+	unregister_netdevice_many(&list);
 	rtnl_unlock();
 	kfree(ign);
 }
