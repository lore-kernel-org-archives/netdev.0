From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH 5/7] bridge: Correctly manage promiscuity when user requested it.
Date: Wed, 26 Feb 2014 10:18:23 -0500
Message-ID: <1393427905-6811-6-git-send-email-vyasevic@redhat.com>
References: <1393427905-6811-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, shemminger@vyatta.com,
	mst@redhat.com, jhs@mojatatu.com, john.r.fastabend@intel.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9199 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750813AbaBZPSv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Feb 2014 10:18:51 -0500
In-Reply-To: <1393427905-6811-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the user places the bridge device in promiscuous mode,
all ports are placed in promisc mode regardless of the number
of flooding ports configured.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_device.c  |  7 +++++++
 net/bridge/br_if.c      | 18 +++++++++++++-----
 net/bridge/br_private.h |  1 +
 3 files changed, 21 insertions(+), 5 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 1521db6..0af9d6c 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -121,6 +121,12 @@ static void br_dev_set_multicast_list(struct net_device *dev)
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
@@ -319,6 +325,7 @@ static const struct net_device_ops br_netdev_ops = {
 	.ndo_get_stats64	 = br_get_stats64,
 	.ndo_set_mac_address	 = br_set_mac_address,
 	.ndo_set_rx_mode	 = br_dev_set_multicast_list,
+	.ndo_change_rx_flags	 = br_dev_change_rx_flags,
 	.ndo_change_mtu		 = br_change_mtu,
 	.ndo_do_ioctl		 = br_dev_ioctl,
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 51df642..7e92bd0 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -494,16 +494,24 @@ static void br_port_clear_promisc(struct net_bridge_port *p)
  * promiscuity setting of all the bridge ports.  We are always called
  * under RTNL so can skip using rcu primitives.
  */
-static void br_manage_promisc(struct net_bridge *br)
+void br_manage_promisc(struct net_bridge *br)
 {
 	struct net_bridge_port *p;
 
 	list_for_each_entry(p, &br->port_list, list) {
-		if (!br_port_exists(p->dev) ||
-		    (br->n_flood_ports == 1 && br->c_flood_port == p))
-			br_port_clear_promisc(p);
-		else
+		if (br->dev->flags & IFF_PROMISC) {
+			/* PROMISC flag has been turned on for the bridge
+			 * itself.  Turn on promisc on all ports.
+			 */
 			br_port_set_promisc(p);
+
+		} else {
+			if (!br_port_exists(p->dev) ||
+			    (br->n_flood_ports == 1 && br->c_flood_port == p))
+				br_port_clear_promisc(p);
+			else if (br_port_exists(p->dev))
+				br_port_set_promisc(p);
+		}
 	}
 }
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 6670cb3..4042f86 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -423,6 +423,7 @@ netdev_features_t br_features_recompute(struct net_bridge *br,
 					netdev_features_t features);
 void br_port_flags_change(struct net_bridge_port *port,
 			  unsigned long mask);
+void br_manage_promisc(struct net_bridge *br);
 
 /* br_input.c */
 int br_handle_frame_finish(struct sk_buff *skb);
-- 
1.8.5.3
