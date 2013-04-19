From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH v2 net-next 6/6] bridge: Store bridge mac to uplinks
Date: Fri, 19 Apr 2013 16:52:50 -0400
Message-ID: <1366404770-28523-7-git-send-email-vyasevic@redhat.com>
References: <1366404770-28523-1-git-send-email-vyasevic@redhat.com>
Cc: bridge@lists.linux-foundation.org, mst@redhat.com,
	Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17411 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932560Ab3DSUw7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Apr 2013 16:52:59 -0400
In-Reply-To: <1366404770-28523-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bridge mac address can change for many reasons.  Since now some ports
may be non-promisc, we need to keep track of the bridge mac and program
it onto ports that may need that information.  We do that by writing
to any port that turns non-promisc and delete it from any port that
turns back to promisc.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/bridge/br_device.c  |   21 ++++++++++++++++++++-
 net/bridge/br_private.h |    2 ++
 net/bridge/br_stp_if.c  |    2 +-
 3 files changed, 23 insertions(+), 2 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 470fb1b..2521fb8 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -141,9 +141,23 @@ static void br_dev_set_rx_mode(struct net_device *dev)
 			if (promisc) {
 				port->flags |= BR_PROMISC;
 				dev_set_promiscuity(dev, 1);
+
+				/* Remove the bridge mac from port since it
+				 * is now promisc.
+				 */
+				if (memcmp(dev->dev_addr, port->dev->dev_addr,
+					   dev->addr_len))
+					dev_uc_del(port->dev, dev->dev_addr);
 			} else {
 				port->flags &= ~BR_PROMISC;
 				dev_set_promiscuity(dev, -1);
+
+				/* Add bridge mac address to the port since
+				 * it is non-promisc.
+				 */
+				if (memcmp(dev->dev_addr, port->dev->dev_addr,
+					   dev->addr_len))
+					dev_uc_add(port->dev, dev->dev_addr);
 			}
 		}
 	}
@@ -207,6 +221,12 @@ static int br_change_mtu(struct net_device *dev, int new_mtu)
 	return 0;
 }
 
+void br_change_mac_address(struct net_device *dev, const unsigned char *addr)
+{
+	memcpy(dev->dev_addr, addr, ETH_ALEN);
+	dev_set_rx_mode(dev);
+}
+
 /* Allow setting mac address to any valid ethernet address. */
 static int br_set_mac_address(struct net_device *dev, void *p)
 {
@@ -218,7 +238,6 @@ static int br_set_mac_address(struct net_device *dev, void *p)
 
 	spin_lock_bh(&br->lock);
 	if (!ether_addr_equal(dev->dev_addr, addr->sa_data)) {
-		memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
 		br_fdb_change_mac_address(br, addr->sa_data);
 		br_stp_change_bridge_id(br, addr->sa_data);
 	}
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 40ac501..ace976f 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -334,6 +334,8 @@ extern void br_dev_setup(struct net_device *dev);
 extern void br_dev_delete(struct net_device *dev, struct list_head *list);
 extern netdev_tx_t br_dev_xmit(struct sk_buff *skb,
 			       struct net_device *dev);
+extern void br_change_mac_address(struct net_device *dev,
+				  const unsigned char *addr);
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static inline struct netpoll_info *br_netpoll_info(struct net_bridge *br)
 {
diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 0bdb4eb..5a5b894 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -186,9 +186,9 @@ void br_stp_change_bridge_id(struct net_bridge *br, const unsigned char *addr)
 
 	wasroot = br_is_root_bridge(br);
 
+	br_change_mac_address(br->dev, addr);
 	memcpy(oldaddr, br->bridge_id.addr, ETH_ALEN);
 	memcpy(br->bridge_id.addr, addr, ETH_ALEN);
-	memcpy(br->dev->dev_addr, addr, ETH_ALEN);
 
 	list_for_each_entry(p, &br->port_list, list) {
 		if (ether_addr_equal(p->designated_bridge.addr, oldaddr))
-- 
1.7.7.6
