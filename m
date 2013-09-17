From: Hong Zhiguo <honkiko@gmail.com>
Subject: [PATCH net-next] bridge: change the order of actions in addif/delif
Date: Tue, 17 Sep 2013 15:44:43 +0800
Message-ID: <1379403883-16219-1-git-send-email-zhiguohong@tencent.com>
Cc: stephen@networkplumber.org, davem@davemloft.net,
	eric.dumazet@gmail.com, vyasevic@redhat.com,
	Hong Zhiguo <zhiguohong@tencent.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f47.google.com ([209.85.160.47]:64361 "EHLO
	mail-pb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751475Ab3IQHsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 03:48:12 -0400
Received: by mail-pb0-f47.google.com with SMTP id rr4so5136900pbb.20
        for <netdev@vger.kernel.org>; Tue, 17 Sep 2013 00:48:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hong Zhiguo <zhiguohong@tencent.com>

netdev_rx_handler_register turns on the bridge traffic. It should
be the last action of br_add_if, after the installation of fdb and
stp staff. _Maybe_ traffic coming in before preparation of fdb and
stp is taken care of, but we could make it easier.

Vise versa, netdev_rx_handler_unregister actually turns off bridge
traffic from the dev. It should be the first action of br_del_if,
before fdb and stp staff is uninstalled.

Signed-off-by: Hong Zhiguo <zhiguohong@tencent.com>
---
 net/bridge/br_if.c | 20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index c41d5fb..6544154 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -133,6 +133,8 @@ static void del_nbp(struct net_bridge_port *p)
 
 	sysfs_remove_link(br->ifobj, p->dev->name);
 
+	netdev_rx_handler_unregister(dev);
+
 	dev_set_promiscuity(dev, -1);
 
 	spin_lock_bh(&br->lock);
@@ -148,8 +150,6 @@ static void del_nbp(struct net_bridge_port *p)
 
 	dev->priv_flags &= ~IFF_BRIDGE_PORT;
 
-	netdev_rx_handler_unregister(dev);
-
 	netdev_upper_dev_unlink(dev, br->dev);
 
 	br_multicast_del_port(p);
@@ -336,8 +336,8 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	if (dev->netdev_ops->ndo_start_xmit == br_dev_xmit)
 		return -ELOOP;
 
-	/* Device is already being bridged */
-	if (br_port_exists(dev))
+	/* Device is already being bridged or registered with other handler */
+	if (br_port_exists(dev) || dev->rx_handler)
 		return -EBUSY;
 
 	/* No bridging devices that dislike that (e.g. wireless) */
@@ -371,10 +371,6 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	if (err)
 		goto err4;
 
-	err = netdev_rx_handler_register(dev, br_handle_frame, p);
-	if (err)
-		goto err5;
-
 	dev->priv_flags |= IFF_BRIDGE_PORT;
 
 	dev_disable_lro(dev);
@@ -394,8 +390,6 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 		br_stp_enable_port(p);
 	spin_unlock_bh(&br->lock);
 
-	br_ifinfo_notify(RTM_NEWLINK, p);
-
 	if (changed_addr)
 		call_netdevice_notifiers(NETDEV_CHANGEADDR, br->dev);
 
@@ -404,12 +398,14 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	if (br_fdb_insert(br, p, dev->dev_addr, 0))
 		netdev_err(dev, "failed insert local address bridge forwarding table\n");
 
+	/* rx_handler is already tested, no fail here */
+	netdev_rx_handler_register(dev, br_handle_frame, p);
+
+	br_ifinfo_notify(RTM_NEWLINK, p);
 	kobject_uevent(&p->kobj, KOBJ_ADD);
 
 	return 0;
 
-err5:
-	netdev_upper_dev_unlink(dev, br->dev);
 err4:
 	br_netpoll_disable(p);
 err3:
-- 
1.8.1.2
