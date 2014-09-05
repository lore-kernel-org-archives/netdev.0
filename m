From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/5] bridge: switch order of rx_handler reg and upper dev link
Date: Fri,  5 Sep 2014 15:51:28 +0200
Message-ID: <1409925092-17808-2-git-send-email-jiri@resnulli.us>
References: <1409925092-17808-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	sfeldma@cumulusnetworks.com, arvid.brodin@alten.se,
	sucheta.chakraborty@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:61283 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757003AbaIENvr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 09:51:47 -0400
Received: by mail-wi0-f179.google.com with SMTP id q5so3014591wiv.0
        for <netdev@vger.kernel.org>; Fri, 05 Sep 2014 06:51:41 -0700 (PDT)
In-Reply-To: <1409925092-17808-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The thing is that netdev_master_upper_dev_link calls
call_netdevice_notifiers(NETDEV_CHANGEUPPER, dev). That generates rtnl
link message and during that, rtnl_link_ops->fill_slave_info is called.
But with current ordering, rx_handler and IFF_BRIDGE_PORT are not set
yet so there would have to be check for that in fill_slave_info callback.

Resolve this by reordering to similar what bonding and team does to
avoid the check.

Also add removal of IFF_BRIDGE_PORT flag into error path.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/bridge/br_if.c | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 078d336..a9f54a9 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -252,12 +252,12 @@ static void del_nbp(struct net_bridge_port *p)
 	br_fdb_delete_by_port(br, p, 1);
 	nbp_update_port_count(br);
 
+	netdev_upper_dev_unlink(dev, br->dev);
+
 	dev->priv_flags &= ~IFF_BRIDGE_PORT;
 
 	netdev_rx_handler_unregister(dev);
 
-	netdev_upper_dev_unlink(dev, br->dev);
-
 	br_multicast_del_port(p);
 
 	kobject_uevent(&p->kobj, KOBJ_REMOVE);
@@ -476,16 +476,16 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	if (err)
 		goto err3;
 
-	err = netdev_master_upper_dev_link(dev, br->dev);
+	err = netdev_rx_handler_register(dev, br_handle_frame, p);
 	if (err)
 		goto err4;
 
-	err = netdev_rx_handler_register(dev, br_handle_frame, p);
+	dev->priv_flags |= IFF_BRIDGE_PORT;
+
+	err = netdev_master_upper_dev_link(dev, br->dev);
 	if (err)
 		goto err5;
 
-	dev->priv_flags |= IFF_BRIDGE_PORT;
-
 	dev_disable_lro(dev);
 
 	list_add_rcu(&p->list, &br->port_list);
@@ -520,7 +520,8 @@ int br_add_if(struct net_bridge *br, struct net_device *dev)
 	return 0;
 
 err5:
-	netdev_upper_dev_unlink(dev, br->dev);
+	dev->priv_flags &= ~IFF_BRIDGE_PORT;
+	netdev_rx_handler_unregister(dev);
 err4:
 	br_netpoll_disable(p);
 err3:
-- 
1.9.3
