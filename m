From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCH v2 net-next 6/7] bridge: Correctly manage promiscuity when user requested it.
Date: Tue, 29 Apr 2014 17:20:27 -0400
Message-ID: <1398806428-640-7-git-send-email-vyasevic@redhat.com>
References: <1398806428-640-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, shemminger@vyatta.com,
	jhs@mojatatu.com, john.r.fastabend@intel.com, mst@redhat.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3178 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755944AbaD2VUy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2014 17:20:54 -0400
In-Reply-To: <1398806428-640-1-git-send-email-vyasevic@redhat.com>
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
 net/bridge/br_if.c      | 17 ++++++++++++-----
 net/bridge/br_private.h |  1 +
 3 files changed, 20 insertions(+), 5 deletions(-)

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
index 5a26ca2..d227ad6 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -123,7 +123,7 @@ static void br_port_clear_promisc(struct net_bridge_port *p)
  * promiscuity setting of all the bridge ports.  We are always called
  * under RTNL so can skip using rcu primitives.
  */
-static void br_manage_promisc(struct net_bridge *br)
+void br_manage_promisc(struct net_bridge *br)
 {
 	struct net_bridge_port *p;
 
@@ -135,11 +135,18 @@ static void br_manage_promisc(struct net_bridge *br)
 	 * to this one automatic port and still make non-promisc.
 	 */
 	list_for_each_entry(p, &br->port_list, list) {
-		if (br->auto_cnt == 0 ||
-		    (br->auto_cnt == 1 && br_is_auto_port(p)))
-			br_port_clear_promisc(p);
-		else
+		if (br->dev->flags & IFF_PROMISC) {
+			/* PROMISC flag has been turned on for the bridge
+			 * itself.  Turn on promisc on all ports.
+			 */
 			br_port_set_promisc(p);
+		} else {
+			if (br->auto_cnt == 0 ||
+			(br->auto_cnt == 1 && br_is_auto_port(p)))
+				br_port_clear_promisc(p);
+			else
+				br_port_set_promisc(p);
+		}
 	}
 }
 
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 1c794fef..f2d93d7 100644
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
