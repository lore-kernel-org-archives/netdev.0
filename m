From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net-next 3/4] ipvlan: move the device check function into netdevice.h
Date: Sat,  6 Dec 2014 15:53:33 -0800
Message-ID: <1417910013-13274-1-git-send-email-maheshb@google.com>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Mahesh Bandewar <maheshb@google.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f73.google.com ([209.85.192.73]:47882 "EHLO
	mail-qg0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734AbaLFXxh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Dec 2014 18:53:37 -0500
Received: by mail-qg0-f73.google.com with SMTP id z60so145815qgd.2
        for <netdev@vger.kernel.org>; Sat, 06 Dec 2014 15:53:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the port check [ipvlan_dev_master()] and device check
[ipvlan_dev_slave()] functions to netdevice.h and rename them
netif_is_ipvlan_port() and netif_is_ipvlan() resp. to be
consistent with macvlan api naming.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/ipvlan/ipvlan.h      | 10 ----------
 drivers/net/ipvlan/ipvlan_main.c | 10 +++++-----
 include/linux/netdevice.h        | 10 ++++++++++
 3 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
index c44d29eca6c0..2729f64b3e7e 100644
--- a/drivers/net/ipvlan/ipvlan.h
+++ b/drivers/net/ipvlan/ipvlan.h
@@ -107,16 +107,6 @@ static inline struct ipvl_port *ipvlan_port_get_rtnl(const struct net_device *d)
 	return rtnl_dereference(d->rx_handler_data);
 }
 
-static inline bool ipvlan_dev_master(struct net_device *d)
-{
-	return d->priv_flags & IFF_IPVLAN_MASTER;
-}
-
-static inline bool ipvlan_dev_slave(struct net_device *d)
-{
-	return d->priv_flags & IFF_IPVLAN_SLAVE;
-}
-
 void ipvlan_adjust_mtu(struct ipvl_dev *ipvlan, struct net_device *dev);
 void ipvlan_set_port_mode(struct ipvl_port *port, u32 nval);
 void ipvlan_init_secret(void);
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index a706a547d811..83cf9fb0804d 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -447,11 +447,11 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 	if (!phy_dev)
 		return -ENODEV;
 
-	if (ipvlan_dev_slave(phy_dev)) {
+	if (netif_is_ipvlan(phy_dev)) {
 		struct ipvl_dev *tmp = netdev_priv(phy_dev);
 
 		phy_dev = tmp->phy_dev;
-	} else if (!ipvlan_dev_master(phy_dev)) {
+	} else if (!netif_is_ipvlan_port(phy_dev)) {
 		err = ipvlan_port_create(phy_dev);
 		if (err < 0)
 			return err;
@@ -561,7 +561,7 @@ static int ipvlan_device_event(struct notifier_block *unused,
 	struct ipvl_port *port;
 	LIST_HEAD(lst_kill);
 
-	if (!ipvlan_dev_master(dev))
+	if (!netif_is_ipvlan_port(dev))
 		return NOTIFY_DONE;
 
 	port = ipvlan_port_get_rtnl(dev);
@@ -652,7 +652,7 @@ static int ipvlan_addr6_event(struct notifier_block *unused,
 	struct net_device *dev = (struct net_device *)if6->idev->dev;
 	struct ipvl_dev *ipvlan = netdev_priv(dev);
 
-	if (!ipvlan_dev_slave(dev))
+	if (!netif_is_ipvlan(dev))
 		return NOTIFY_DONE;
 
 	if (!ipvlan || !ipvlan->port)
@@ -724,7 +724,7 @@ static int ipvlan_addr4_event(struct notifier_block *unused,
 	struct ipvl_dev *ipvlan = netdev_priv(dev);
 	struct in_addr ip4_addr;
 
-	if (!ipvlan_dev_slave(dev))
+	if (!netif_is_ipvlan(dev))
 		return NOTIFY_DONE;
 
 	if (!ipvlan || !ipvlan->port)
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1f49aac258f9..c31f74d76ebd 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3646,6 +3646,16 @@ static inline bool netif_is_macvlan_port(struct net_device *dev)
 	return dev->priv_flags & IFF_MACVLAN_PORT;
 }
 
+static inline bool netif_is_ipvlan(struct net_device *dev)
+{
+	return dev->priv_flags & IFF_IPVLAN_SLAVE;
+}
+
+static inline bool netif_is_ipvlan_port(struct net_device *dev)
+{
+	return dev->priv_flags & IFF_IPVLAN_MASTER;
+}
+
 static inline bool netif_is_bond_master(struct net_device *dev)
 {
 	return dev->flags & IFF_MASTER && dev->priv_flags & IFF_BONDING;
-- 
2.2.0.rc0.207.ga3a616c
