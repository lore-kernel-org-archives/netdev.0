From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net-next v2 5/6] geneve/vxlan: add support for NETDEV_UDP_TUNNEL_DROP_INFO
Date: Fri, 21 Jul 2017 12:49:32 +0200
Message-ID: <1de22ab71cfbe02ee25c430336f388e863094fd9.1500632570.git.sd@queasysnail.net>
References: <cover.1500632570.git.sd@queasysnail.net>
Cc: Jiri Benc <jbenc@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33812 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753665AbdGUKuA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Jul 2017 06:50:00 -0400
In-Reply-To: <cover.1500632570.git.sd@queasysnail.net>
In-Reply-To: <cover.1500632570.git.sd@queasysnail.net>
References: <cover.1500632570.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/geneve.c | 19 +++++++++++++------
 drivers/net/vxlan.c  | 25 +++++++++++++++++--------
 2 files changed, 30 insertions(+), 14 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index de8156c6b292..ee52233750f7 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1014,16 +1014,22 @@ static struct device_type geneve_type = {
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
 
@@ -1426,8 +1432,9 @@ static int geneve_netdevice_event(struct notifier_block *unused,
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
index 96aa7e6cf214..4642d5be2fa0 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2608,7 +2608,7 @@ static struct device_type vxlan_type = {
  * supply the listening VXLAN udp ports. Callers are expected
  * to implement the ndo_udp_tunnel_add.
  */
-static void vxlan_push_rx_ports(struct net_device *dev)
+static void vxlan_offload_rx_ports(struct net_device *dev, bool push)
 {
 	struct vxlan_sock *vs;
 	struct net *net = dev_net(dev);
@@ -2617,11 +2617,19 @@ static void vxlan_push_rx_ports(struct net_device *dev)
 
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
@@ -3632,8 +3640,9 @@ static int vxlan_netdevice_event(struct notifier_block *unused,
 
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
