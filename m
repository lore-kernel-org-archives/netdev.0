From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipv6 sit: Optimize multiple unregistration
Date: Wed, 28 Oct 2009 15:37:43 +0100
Message-ID: <4AE85737.4000809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52856 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104AbZJ1Ohl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 10:37:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Speedup module unloading by factorizing synchronize_rcu() calls

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv6/sit.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)


diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index b6b1626..2362a33 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -1145,16 +1145,19 @@ static struct xfrm_tunnel sit_handler = {
 	.priority	=	1,
 };
 
-static void sit_destroy_tunnels(struct sit_net *sitn)
+static void sit_destroy_tunnels(struct sit_net *sitn, struct list_head *head)
 {
 	int prio;
 
 	for (prio = 1; prio < 4; prio++) {
 		int h;
 		for (h = 0; h < HASH_SIZE; h++) {
-			struct ip_tunnel *t;
-			while ((t = sitn->tunnels[prio][h]) != NULL)
-				unregister_netdevice(t->dev);
+			struct ip_tunnel *t = sitn->tunnels[prio][h];
+
+			while (t != NULL) {
+				unregister_netdevice_queue(t->dev, head);
+				t = t->next;
+			}
 		}
 	}
 }
@@ -1208,11 +1211,13 @@ err_alloc:
 static void sit_exit_net(struct net *net)
 {
 	struct sit_net *sitn;
+	LIST_HEAD(list);
 
 	sitn = net_generic(net, sit_net_id);
 	rtnl_lock();
-	sit_destroy_tunnels(sitn);
-	unregister_netdevice(sitn->fb_tunnel_dev);
+	sit_destroy_tunnels(sitn, &list);
+	unregister_netdevice_queue(sitn->fb_tunnel_dev, &list);
+	unregister_netdevice_many(&list);
 	rtnl_unlock();
 	kfree(sitn);
 }
