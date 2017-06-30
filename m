From: Sabrina Dubroca <sd@queasysnail.net>
Subject: [PATCH net-next 6/6] geneve/vxlan: offload ports on register/unregister events
Date: Fri, 30 Jun 2017 15:19:50 +0200
Message-ID: <36e32dd9026c63b876b5f2bc96964020bd14719b.1498743778.git.sd@queasysnail.net>
References: <cover.1498743778.git.sd@queasysnail.net>
Cc: Jiri Benc <jbenc@redhat.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Sabrina Dubroca <sd@queasysnail.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59350 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752059AbdF3NUb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Jun 2017 09:20:31 -0400
In-Reply-To: <cover.1498743778.git.sd@queasysnail.net>
In-Reply-To: <cover.1498743778.git.sd@queasysnail.net>
References: <cover.1498743778.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This improves consistency of handling when moving a netdev to another
netns. Most drivers currently do a full reset when the device goes up,
so that will flush the offload state anyway.

Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
---
 drivers/net/geneve.c |  7 ++++++-
 drivers/net/vxlan.c  | 10 +++++++---
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index ba89dc69cb07..258c07a94915 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -1417,8 +1417,13 @@ static int geneve_netdevice_event(struct notifier_block *unused,
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 
 	if (event == NETDEV_UDP_TUNNEL_PUSH_INFO ||
-	    event == NETDEV_UDP_TUNNEL_DROP_INFO)
+	    event == NETDEV_UDP_TUNNEL_DROP_INFO) {
 		geneve_offload_rx_ports(dev, event == NETDEV_UDP_TUNNEL_PUSH_INFO);
+	} else if (event == NETDEV_UNREGISTER) {
+		geneve_offload_rx_ports(dev, false);
+	} else if (event == NETDEV_REGISTER) {
+		geneve_offload_rx_ports(dev, true);
+	}
 
 	return NOTIFY_DONE;
 }
diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 03baa87a70f7..805db76b6e7e 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -3625,11 +3625,15 @@ static int vxlan_netdevice_event(struct notifier_block *unused,
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
 
-	if (event == NETDEV_UNREGISTER)
+	if (event == NETDEV_UNREGISTER) {
+		vxlan_offload_rx_ports(dev, false);
 		vxlan_handle_lowerdev_unregister(vn, dev);
-	else if (event == NETDEV_UDP_TUNNEL_PUSH_INFO ||
-		 event == NETDEV_UDP_TUNNEL_DROP_INFO)
+	} else if (event == NETDEV_REGISTER) {
+		vxlan_offload_rx_ports(dev, true);
+	} else if (event == NETDEV_UDP_TUNNEL_PUSH_INFO ||
+		   event == NETDEV_UDP_TUNNEL_DROP_INFO) {
 		vxlan_offload_rx_ports(dev, event == NETDEV_UDP_TUNNEL_PUSH_INFO);
+	}
 
 	return NOTIFY_DONE;
 }
-- 
2.13.2
