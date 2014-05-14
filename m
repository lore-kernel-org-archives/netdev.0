From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next 7/8] bridge: Correctly manage promiscuity when user requested it.
Date: Wed, 14 May 2014 11:09:27 -0400
Message-ID: <1400080168-16625-8-git-send-email-vyasevic@redhat.com>
References: <1400080168-16625-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, shemminger@vyatta.com,
	mst@redhat.com, john.r.fastabend@intel.com, jhs@mojatatu.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58117 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755462AbaENPJq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 May 2014 11:09:46 -0400
In-Reply-To: <1400080168-16625-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the user places the bridge device in promiscuous mode,
all ports are placed in promisc mode regardless of the number
of flooding ports configured.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>

Conflicts:
	net/bridge/br_if.c
	net/bridge/br_private.h
---
 net/bridge/br_device.c  |  7 +++++++
 net/bridge/br_if.c      | 34 +++++++++++++++++++++-------------
 net/bridge/br_private.h |  1 +
 3 files changed, 29 insertions(+), 13 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 3e2da2c..64f8112 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -112,6 +112,12 @@ static void br_dev_set_multicast_list(struct net_device *dev)
 {
 }
 
+static void br_dev_change_rx_flags(struct net_device *dev, int change)
+{
+	if (change & IFF_PROMISC)
+		br_manage_promisc(netdev_priv(dev));
+}
+
 static int br_dev_stop(struct net_device *dev)
 {
 	struct net_bridge *br = netdev_priv(dev);
@@ -309,6 +315,7 @@ static const struct net_device_ops br_netdev_ops = {
 	.ndo_get_stats64	 = br_get_stats64,
 	.ndo_set_mac_address	 = br_set_mac_address,
 	.ndo_set_rx_mode	 = br_dev_set_multicast_list,
+	.ndo_change_rx_flags	 = br_dev_change_rx_flags,
 	.ndo_change_mtu		 = br_change_mtu,
 	.ndo_do_ioctl		 = br_dev_ioctl,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index df0351f..7759144 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -128,24 +128,32 @@ static void br_port_clear_promisc(struct net_bridge_port *p)
  * promiscuity setting of all the bridge ports.  We are always called
  * under RTNL so can skip using rcu primitives.
  */
-static void br_manage_promisc(struct net_bridge *br)
+void br_manage_promisc(struct net_bridge *br)
 {
 	struct net_bridge_port *p;
 
 	list_for_each_entry(p, &br->port_list, list) {
-		/* If the number of auto-ports is <= 1, then all other
-		 * ports will have their output configuration statically
-		 * specified through fdbs.  Since ingress on the auto-port
-		 * becomes forwarding/egress to other ports and egress
-		 * configuration is statically know, we can say that ingress
-		 * configuration of the auto-port is also statically knows.
-		 * This lets us disable promiscuous mode and write this config
-		 * to hw.
-		 */
-		if (br->auto_cnt <= br_auto_port(p))
-			br_port_clear_promisc(p);
-		else
+		if (br->dev->flags & IFF_PROMISC) {
+			/* PROMISC flag has been turned on for the bridge
+			 * itself.  Turn on promisc on all ports.
+			 */
 			br_port_set_promisc(p);
+		} else {
+			/* If the number of auto-ports is <= 1, then all other
+			 * ports will have their output configuration
+			 * statically specified through fdbs.  Since ingress
+			 * on the auto-port becomes forwarding/egress to other
+			 * ports and egress configuration is statically know,
+			 * we can say that ingress configuration of the
+			 * auto-port is also statically knows.
+			 * This lets us disable promiscuous mode and write
+			 * this config to hw.
+			 */
+			if (br->auto_cnt <= br_auto_port(p))
+				br_port_clear_promisc(p);
+			else
+				br_port_set_promisc(p);
+		}
 	}
 }
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 420e88b..9c1fda0 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -425,6 +425,7 @@ netdev_features_t br_features_recompute(struct net_bridge *br,
 					netdev_features_t features);
 void br_port_flags_change(struct net_bridge_port *port,
 			  unsigned long old_flags);
+void br_manage_promisc(struct net_bridge *br);
 
 /* br_input.c */
 int br_handle_frame_finish(struct sk_buff *skb);
-- 
1.9.0
