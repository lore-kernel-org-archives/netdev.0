From: Jiri Pirko <jpirko@redhat.com>
Subject: [patch net-next-2.6 4/4] bridge: implement [add/del]_slave ops
Date: Sun, 13 Feb 2011 20:33:42 +0100
Message-ID: <20110213193341.GG2740@psychotron.redhat.com>
References: <20110213193105.GD2740@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net, fubar@us.ibm.com, eric.dumazet@gmail.com,
	nicolas.2p.debian@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6249 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754762Ab1BMTdt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 Feb 2011 14:33:49 -0500
Content-Disposition: inline
In-Reply-To: <20110213193105.GD2740@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add possibility to addif/delif via rtnetlink

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 net/bridge/br_device.c |   17 +++++++++++++++++
 net/bridge/br_if.c     |   11 ++++++++++-
 2 files changed, 27 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 5564435..1461b19 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -297,6 +297,21 @@ void br_netpoll_disable(struct net_bridge_port *p)
 
 #endif
 
+static int br_add_slave(struct net_device *dev, struct net_device *slave_dev)
+
+{
+	struct net_bridge *br = netdev_priv(dev);
+
+	return br_add_if(br, slave_dev);
+}
+
+static int br_del_slave(struct net_device *dev, struct net_device *slave_dev)
+{
+	struct net_bridge *br = netdev_priv(dev);
+
+	return br_del_if(br, slave_dev);
+}
+
 static const struct ethtool_ops br_ethtool_ops = {
 	.get_drvinfo    = br_getinfo,
 	.get_link	= ethtool_op_get_link,
@@ -326,6 +341,8 @@ static const struct net_device_ops br_netdev_ops = {
 	.ndo_netpoll_cleanup	 = br_netpoll_cleanup,
 	.ndo_poll_controller	 = br_poll_controller,
 #endif
+	.ndo_add_slave		 = br_add_slave,
+	.ndo_del_slave		 = br_del_slave,
 };
 
 static void br_dev_free(struct net_device *dev)
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 2a6801d..dce8f00 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -148,6 +148,8 @@ static void del_nbp(struct net_bridge_port *p)
 
 	netdev_rx_handler_unregister(dev);
 
+	netdev_set_master(dev, NULL);
+
 	br_multicast_del_port(p);
 
 	kobject_uevent(&p->kobj, KOBJ_REMOVE);
@@ -429,10 +431,14 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	if (br_netpoll_info(br) && ((err = br_netpoll_enable(p))))
 		goto err3;
 
-	err = netdev_rx_handler_register(dev, br_handle_frame, p);
+	err = netdev_set_master(dev, br->dev);
 	if (err)
 		goto err3;
 
+	err = netdev_rx_handler_register(dev, br_handle_frame, p);
+	if (err)
+		goto err4;
+
 	dev->priv_flags |= IFF_BRIDGE_PORT;
 
 	dev_disable_lro(dev);
@@ -455,6 +461,9 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	kobject_uevent(&p->kobj, KOBJ_ADD);
 
 	return 0;
+
+err4:
+	netdev_set_master(dev, NULL);
 err3:
 	sysfs_remove_link(br->ifobj, p->dev->name);
 err2:
-- 
1.7.3.4

