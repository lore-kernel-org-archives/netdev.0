From: Debabrata Banerjee <dbanerje@akamai.com>
Subject: [PATCH net-next v2] macvlan: Support interface operstate properly
Date: Wed,  6 Apr 2016 18:36:13 -0400
Message-ID: <1459982173-791-1-git-send-email-dbanerje@akamai.com>
Cc: Debabrata Banerjee <dbanerje@akamai.com>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179]:53629 "EHLO
	prod-mail-xrelay05.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752233AbcDFWgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 18:36:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set appropriate macvlan interface status based on lower device and our
status. Can be up, down, or lowerlayerdown.

de7d244d0 improved operstate by setting it from unknown to up, however
it did not handle transferring down or lowerlayerdown.

Signed-off-by: Debabrata Banerjee <dbanerje@akamai.com>
---
v2: Fix locking and update commit message

 drivers/net/macvlan.c | 47 +++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 45 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 2bcf1f3..306124ba 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -91,6 +91,7 @@ static struct macvlan_port *macvlan_port_get_rtnl(const struct net_device *dev)
 }
 
 #define macvlan_port_exists(dev) (dev->priv_flags & IFF_MACVLAN_PORT)
+#define is_macvlan(dev) (dev->priv_flags & IFF_MACVLAN)
 
 static struct macvlan_dev *macvlan_hash_lookup(const struct macvlan_port *port,
 					       const unsigned char *addr)
@@ -1242,6 +1243,28 @@ static int macvlan_changelink_sources(struct macvlan_dev *vlan, u32 mode,
 	return 0;
 }
 
+static void macvlan_set_operstate(struct net_device *lowerdev,
+				  struct net_device *dev)
+{
+	unsigned char newstate = dev->operstate;
+
+	if (!(dev->flags & IFF_UP))
+		newstate = IF_OPER_DOWN;
+	else if ((lowerdev->flags & IFF_UP) && netif_oper_up(lowerdev))
+		newstate = IF_OPER_UP;
+	else
+		newstate = IF_OPER_LOWERLAYERDOWN;
+
+	write_lock_bh(&dev_base_lock);
+	if (dev->operstate != newstate) {
+		dev->operstate = newstate;
+		write_unlock_bh(&dev_base_lock);
+		netdev_state_change(dev);
+	} else {
+		write_unlock_bh(&dev_base_lock);
+	}
+}
+
 int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 			   struct nlattr *tb[], struct nlattr *data[])
 {
@@ -1324,6 +1347,7 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
 
 	list_add_tail_rcu(&vlan->list, &port->vlans);
 	netif_stacked_transfer_operstate(lowerdev, dev);
+	macvlan_set_operstate(lowerdev, dev);
 	linkwatch_fire_event(dev);
 
 	return 0;
@@ -1518,17 +1542,36 @@ static int macvlan_device_event(struct notifier_block *unused,
 	struct macvlan_port *port;
 	LIST_HEAD(list_kill);
 
-	if (!macvlan_port_exists(dev))
+	if (!macvlan_port_exists(dev) && !is_macvlan(dev))
+		return NOTIFY_DONE;
+
+	if (is_macvlan(dev)) {
+		vlan = netdev_priv(dev);
+
+		switch (event) {
+		case NETDEV_UP:
+		case NETDEV_DOWN:
+		case NETDEV_CHANGE:
+			netif_stacked_transfer_operstate(vlan->lowerdev,
+							 vlan->dev);
+			macvlan_set_operstate(vlan->lowerdev, vlan->dev);
+			break;
+		}
+
 		return NOTIFY_DONE;
+	}
 
 	port = macvlan_port_get_rtnl(dev);
 
 	switch (event) {
 	case NETDEV_UP:
+	case NETDEV_DOWN:
 	case NETDEV_CHANGE:
-		list_for_each_entry(vlan, &port->vlans, list)
+		list_for_each_entry(vlan, &port->vlans, list) {
 			netif_stacked_transfer_operstate(vlan->lowerdev,
 							 vlan->dev);
+			macvlan_set_operstate(vlan->lowerdev, vlan->dev);
+		}
 		break;
 	case NETDEV_FEAT_CHANGE:
 		list_for_each_entry(vlan, &port->vlans, list) {
-- 
2.8.0
