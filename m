From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net-next 5/6] geneve/vxlan: add support for NETDEV_UDP_TUNNEL_DROP_INFO
Date: Fri, 30 Jun 2017 15:19:49 +0200
Message-ID: <de09271021107735e83f2ce4f604ac5d340149e1.1498743778.git.sd@queasysnail.net>
References: <cover.1498743778.git.sd@queasysnail.net>
Cc: Jiri Benc <jbenc@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60406 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752009AbdF3NUa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Jun 2017 09:20:30 -0400
In-Reply-To: <cover.1498743778.git.sd@queasysnail.net>
In-Reply-To: <cover.1498743778.git.sd@queasysnail.net>
References: <cover.1498743778.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And call udp_tunnel_drop_rx_port() to handle that event.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/geneve.c | 19 +++++++++++++------
 drivers/net/vxlan.c  | 25 +++++++++++++++++--------
 2 files changed, 30 insertions(+), 14 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index eb77201cb718..ba89dc69cb07 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -998,16 +998,22 @@ static struct device_type geneve_type = {
  * supply the listening GENEVE udp ports. Callers are expected
  * to implement the ndo_udp_tunnel_add.
  */
-static void geneve_push_rx_ports(struct net_device *dev)
+static void geneve_offload_rx_ports(struct net_device *dev, bool push)
 {
 	struct net *net = dev_net(dev);
 	struct geneve_net *gn = net_generic(net, geneve_net_id);
 	struct geneve_sock *gs;
 
 	rcu_read_lock();
-	list_for_each_entry_rcu(gs, &gn->sock_list, list)
-		udp_tunnel_push_rx_port(dev, gs->sock,
-					UDP_TUNNEL_TYPE_GENEVE);
+	list_for_each_entry_rcu(gs, &gn->sock_list, list) {
+		if (push) {
+			udp_tunnel_push_rx_port(dev, gs->sock,
+						UDP_TUNNEL_TYPE_GENEVE);
+		} else {
+			udp_tunnel_drop_rx_port(dev, gs->sock,
+						UDP_TUNNEL_TYPE_GENEVE);
+		}
+	}
 	rcu_read_unlock();
 }
 
@@ -1410,8 +1416,9 @@ static int geneve_netdevice_event(struct notifier_block *unused,
 {
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 
-	if (event == NETDEV_UDP_TUNNEL_PUSH_INFO)
-		geneve_push_rx_ports(dev);
+	if (event == NETDEV_UDP_TUNNEL_PUSH_INFO ||
+	    event == NETDEV_UDP_TUNNEL_DROP_INFO)
+		geneve_offload_rx_ports(dev, event == NETDEV_UDP_TUNNEL_PUSH_INFO);
 
 	return NOTIFY_DONE;
 }
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index fd0ff97e3d81..03baa87a70f7 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2603,7 +2603,7 @@ static struct device_type vxlan_type = {
  * supply the listening VXLAN udp ports. Callers are expected
  * to implement the ndo_udp_tunnel_add.
  */
-static void vxlan_push_rx_ports(struct net_device *dev)
+static void vxlan_offload_rx_ports(struct net_device *dev, bool push)
 {
 	struct vxlan_sock *vs;
 	struct net *net = dev_net(dev);
@@ -2612,11 +2612,19 @@ static void vxlan_push_rx_ports(struct net_device *dev)
 
 	spin_lock(&vn->sock_lock);
 	for (i = 0; i < PORT_HASH_SIZE; ++i) {
-		hlist_for_each_entry_rcu(vs, &vn->sock_list[i], hlist)
-			udp_tunnel_push_rx_port(dev, vs->sock,
-						(vs->flags & VXLAN_F_GPE) ?
-						UDP_TUNNEL_TYPE_VXLAN_GPE :
-						UDP_TUNNEL_TYPE_VXLAN);
+		hlist_for_each_entry_rcu(vs, &vn->sock_list[i], hlist) {
+			unsigned short type;
+
+			if (vs->flags & VXLAN_F_GPE)
+				type = UDP_TUNNEL_TYPE_VXLAN_GPE;
+			else
+				type = UDP_TUNNEL_TYPE_VXLAN;
+
+			if (push)
+				udp_tunnel_push_rx_port(dev, vs->sock, type);
+			else
+				udp_tunnel_drop_rx_port(dev, vs->sock, type);
+		}
 	}
 	spin_unlock(&vn->sock_lock);
 }
@@ -3619,8 +3627,9 @@ static int vxlan_netdevice_event(struct notifier_block *unused,
 
 	if (event == NETDEV_UNREGISTER)
 		vxlan_handle_lowerdev_unregister(vn, dev);
-	else if (event == NETDEV_UDP_TUNNEL_PUSH_INFO)
-		vxlan_push_rx_ports(dev);
+	else if (event == NETDEV_UDP_TUNNEL_PUSH_INFO ||
+		 event == NETDEV_UDP_TUNNEL_DROP_INFO)
+		vxlan_offload_rx_ports(dev, event == NETDEV_UDP_TUNNEL_PUSH_INFO);
 
 	return NOTIFY_DONE;
 }
-- 
2.13.2
