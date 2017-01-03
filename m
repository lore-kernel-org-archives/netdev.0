From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next v1] ipvlan: assign unique dev-id for each slave device.
Date: Tue,  3 Jan 2017 12:47:16 -0800
Message-ID: <20170103204716.9436-1-mahesh@bandewar.net>
Cc: netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <maheshb@google.com>
To: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34289 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934875AbdACUrW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 15:47:22 -0500
Received: by mail-pf0-f194.google.com with SMTP id y68so26052574pfb.1
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2017 12:47:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

IPvlan setup uses one mac-address (of master). The IPv6 link-local
addresses are derived using the mac-address on the link. Lack of
dev-ids makes these link-local addresses same for all slaves including
that of master device. dev-ids are necessary to add differentiation
when L2 address is shared.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/ipvlan/ipvlan.h      |  1 +
 drivers/net/ipvlan/ipvlan_main.c | 17 ++++++++++++++++-
 2 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
index dbfbb33ac66c..0a9068fdee0f 100644
--- a/drivers/net/ipvlan/ipvlan.h
+++ b/drivers/net/ipvlan/ipvlan.h
@@ -97,6 +97,7 @@ struct ipvl_port {
 	struct work_struct	wq;
 	struct sk_buff_head	backlog;
 	int			count;
+	struct ida		ida;
 };
 
 struct ipvl_skb_cb {
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 975f9ddb9908..ce7ca6a5aa8a 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -119,6 +119,7 @@ static int ipvlan_port_create(struct net_device *dev)
 
 	skb_queue_head_init(&port->backlog);
 	INIT_WORK(&port->wq, ipvlan_process_multicast);
+	ida_init(&port->ida);
 
 	err = netdev_rx_handler_register(dev, ipvlan_handle_frame, port);
 	if (err)
@@ -150,6 +151,7 @@ static void ipvlan_port_destroy(struct net_device *dev)
 			dev_put(skb->dev);
 		kfree_skb(skb);
 	}
+	ida_destroy(&port->ida);
 	kfree(port);
 }
 
@@ -533,6 +535,16 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 	ipvlan_adjust_mtu(ipvlan, phy_dev);
 	INIT_LIST_HEAD(&ipvlan->addrs);
 
+	/* Since L2 address is shared among all IPvlan slaves including
+	 * master, use unique 16 bit dev-ids to diffentiate among them.
+	 * Assign IDs between 0x1 and 0xFFFE (used by the master) to each
+	 * slave link [see addrconf_ifid_eui48()].
+	 */
+	err = ida_simple_get(&port->ida, 1, 0xFFFE, GFP_KERNEL);
+	if (err < 0)
+		goto destroy_ipvlan_port;
+	dev->dev_id = err;
+
 	/* TODO Probably put random address here to be presented to the
 	 * world but keep using the physical-dev address for the outgoing
 	 * packets.
@@ -543,7 +555,7 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 
 	err = register_netdevice(dev);
 	if (err < 0)
-		goto destroy_ipvlan_port;
+		goto remove_ida;
 
 	err = netdev_upper_dev_link(phy_dev, dev);
 	if (err) {
@@ -562,6 +574,8 @@ static int ipvlan_link_new(struct net *src_net, struct net_device *dev,
 	netdev_upper_dev_unlink(phy_dev, dev);
 unregister_netdev:
 	unregister_netdevice(dev);
+remove_ida:
+	ida_simple_remove(&port->ida, dev->dev_id);
 destroy_ipvlan_port:
 	if (create)
 		ipvlan_port_destroy(phy_dev);
@@ -579,6 +593,7 @@ static void ipvlan_link_delete(struct net_device *dev, struct list_head *head)
 		kfree_rcu(addr, rcu);
 	}
 
+	ida_simple_remove(&ipvlan->port->ida, dev->dev_id);
 	list_del_rcu(&ipvlan->pnode);
 	unregister_netdevice_queue(dev, head);
 	netdev_upper_dev_unlink(ipvlan->phy_dev, dev);
-- 
2.11.0.390.gc69c2f50cf-goog
