From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH 5/6] ipip: Optimize multiple unregistration
Date: Tue, 27 Oct 2009 18:06:59 +0100
Message-ID: <4AE728B3.5010201@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36648 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754237AbZJ0RHM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 13:07:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Speedup module unloading by factorizing synchronize_rcu() calls

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ipip.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 3bd6998..a2ca53d 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -754,16 +754,19 @@ static struct xfrm_tunnel ipip_handler = {
 static const char banner[] __initconst =
 	KERN_INFO "IPv4 over IPv4 tunneling driver\n";
 
-static void ipip_destroy_tunnels(struct ipip_net *ipn)
+static void ipip_destroy_tunnels(struct ipip_net *ipn, struct list_head *head)
 {
 	int prio;
 
 	for (prio = 1; prio < 4; prio++) {
 		int h;
 		for (h = 0; h < HASH_SIZE; h++) {
-			struct ip_tunnel *t;
-			while ((t = ipn->tunnels[prio][h]) != NULL)
-				unregister_netdevice(t->dev);
+			struct ip_tunnel *t = ipn->tunnels[prio][h];
+
+			while (t != NULL) {
+				unregister_netdevice_queue(t->dev, head);
+				t = t->next;
+			}
 		}
 	}
 }
@@ -816,11 +819,13 @@ err_alloc:
 static void ipip_exit_net(struct net *net)
 {
 	struct ipip_net *ipn;
+	LIST_HEAD(list);
 
 	ipn = net_generic(net, ipip_net_id);
 	rtnl_lock();
-	ipip_destroy_tunnels(ipn);
-	unregister_netdevice(ipn->fb_tunnel_dev);
+	ipip_destroy_tunnels(ipn, &list);
+	unregister_netdevice_queue(ipn->fb_tunnel_dev, &list);
+	unregister_netdevice_many(&list);
 	rtnl_unlock();
 	kfree(ipn);
 }
