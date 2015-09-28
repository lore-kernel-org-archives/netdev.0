From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 07/11] net: Remove the now unused vrf_ptr
Date: Mon, 28 Sep 2015 10:16:57 -0700
Message-ID: <1443460621-24855-8-git-send-email-dsa@cumulusnetworks.com>
References: <1443460621-24855-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:34227 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934424AbbI1RRV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 13:17:21 -0400
Received: by padhy16 with SMTP id hy16so179670362pad.1
        for <netdev@vger.kernel.org>; Mon, 28 Sep 2015 10:17:20 -0700 (PDT)
In-Reply-To: <1443460621-24855-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c         | 32 ++------------------------------
 include/linux/netdevice.h |  2 --
 include/net/vrf.h         |  6 ------
 3 files changed, 2 insertions(+), 38 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 72f1892ebad0..df872f4efb0d 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -396,18 +396,15 @@ static void __vrf_insert_slave(struct slave_queue *queue, struct slave *slave)
 
 static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 {
-	struct net_vrf_dev *vrf_ptr = kmalloc(sizeof(*vrf_ptr), GFP_KERNEL);
 	struct slave *slave = kzalloc(sizeof(*slave), GFP_KERNEL);
 	struct net_vrf *vrf = netdev_priv(dev);
 	struct slave_queue *queue = &vrf->queue;
 	int ret = -ENOMEM;
 
-	if (!slave || !vrf_ptr)
+	if (!slave)
 		goto out_fail;
 
 	slave->dev = port_dev;
-	vrf_ptr->ifindex = dev->ifindex;
-	vrf_ptr->tb_id = vrf->tb_id;
 
 	/* register the packet handler for slave ports */
 	ret = netdev_rx_handler_register(port_dev, vrf_handle_frame, dev);
@@ -424,7 +421,6 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 
 	port_dev->flags |= IFF_SLAVE;
 	__vrf_insert_slave(queue, slave);
-	rcu_assign_pointer(port_dev->vrf_ptr, vrf_ptr);
 	cycle_netdev(port_dev);
 
 	return 0;
@@ -432,7 +428,6 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 out_unregister:
 	netdev_rx_handler_unregister(port_dev);
 out_fail:
-	kfree(vrf_ptr);
 	kfree(slave);
 	return ret;
 }
@@ -448,21 +443,15 @@ static int vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 /* inverse of do_vrf_add_slave */
 static int do_vrf_del_slave(struct net_device *dev, struct net_device *port_dev)
 {
-	struct net_vrf_dev *vrf_ptr = rtnl_dereference(port_dev->vrf_ptr);
 	struct net_vrf *vrf = netdev_priv(dev);
 	struct slave_queue *queue = &vrf->queue;
 	struct slave *slave;
 
-	RCU_INIT_POINTER(port_dev->vrf_ptr, NULL);
-
 	netdev_upper_dev_unlink(port_dev, dev);
 	port_dev->flags &= ~IFF_SLAVE;
 
 	netdev_rx_handler_unregister(port_dev);
 
-	/* after netdev_rx_handler_unregister for synchronize_rcu */
-	kfree(vrf_ptr);
-
 	cycle_netdev(port_dev);
 
 	slave = __vrf_find_slave_dev(queue, port_dev);
@@ -601,10 +590,6 @@ static int vrf_validate(struct nlattr *tb[], struct nlattr *data[])
 
 static void vrf_dellink(struct net_device *dev, struct list_head *head)
 {
-	struct net_vrf_dev *vrf_ptr = rtnl_dereference(dev->vrf_ptr);
-
-	RCU_INIT_POINTER(dev->vrf_ptr, NULL);
-	kfree_rcu(vrf_ptr, rcu);
 	unregister_netdevice_queue(dev, head);
 }
 
@@ -612,7 +597,6 @@ static int vrf_newlink(struct net *src_net, struct net_device *dev,
 		       struct nlattr *tb[], struct nlattr *data[])
 {
 	struct net_vrf *vrf = netdev_priv(dev);
-	struct net_vrf_dev *vrf_ptr;
 	int err;
 
 	if (!data || !data[IFLA_VRF_TABLE])
@@ -622,24 +606,13 @@ static int vrf_newlink(struct net *src_net, struct net_device *dev,
 
 	dev->priv_flags |= IFF_L3MDEV_MASTER;
 
-	err = -ENOMEM;
-	vrf_ptr = kmalloc(sizeof(*dev->vrf_ptr), GFP_KERNEL);
-	if (!vrf_ptr)
-		goto out_fail;
-
-	vrf_ptr->ifindex = dev->ifindex;
-	vrf_ptr->tb_id = vrf->tb_id;
-
 	err = register_netdevice(dev);
 	if (err < 0)
 		goto out_fail;
 
-	rcu_assign_pointer(dev->vrf_ptr, vrf_ptr);
-
 	return 0;
 
 out_fail:
-	kfree(vrf_ptr);
 	free_netdev(dev);
 	return err;
 }
@@ -683,10 +656,9 @@ static int vrf_device_event(struct notifier_block *unused,
 
 	/* only care about unregister events to drop slave references */
 	if (event == NETDEV_UNREGISTER) {
-		struct net_vrf_dev *vrf_ptr = rtnl_dereference(dev->vrf_ptr);
 		struct net_device *vrf_dev;
 
-		if (!vrf_ptr || netif_is_l3_master(dev))
+		if (netif_is_l3_master(dev))
 			goto out;
 
 		vrf_dev = netdev_master_upper_dev_get(dev);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c7f14794fe14..72bf9e37a2f0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1427,7 +1427,6 @@ enum netdev_priv_flags {
  *	@dn_ptr:	DECnet specific data
  *	@ip6_ptr:	IPv6 specific data
  *	@ax25_ptr:	AX.25 specific data
- *	@vrf_ptr:	VRF specific data
  *	@ieee80211_ptr:	IEEE 802.11 specific data, assign before registering
  *
  *	@last_rx:	Time of last Rx
@@ -1649,7 +1648,6 @@ struct net_device {
 	struct dn_dev __rcu     *dn_ptr;
 	struct inet6_dev __rcu	*ip6_ptr;
 	void			*ax25_ptr;
-	struct net_vrf_dev __rcu *vrf_ptr;
 	struct wireless_dev	*ieee80211_ptr;
 	struct wpan_dev		*ieee802154_ptr;
 #if IS_ENABLED(CONFIG_MPLS_ROUTING)
diff --git a/include/net/vrf.h b/include/net/vrf.h
index 5bba1535ba73..e83fc38770dd 100644
--- a/include/net/vrf.h
+++ b/include/net/vrf.h
@@ -11,12 +11,6 @@
 #ifndef __LINUX_NET_VRF_H
 #define __LINUX_NET_VRF_H
 
-struct net_vrf_dev {
-	struct rcu_head		rcu;
-	int                     ifindex; /* ifindex of master dev */
-	u32                     tb_id;   /* table id for VRF */
-};
-
 struct slave {
 	struct list_head	list;
 	struct net_device	*dev;
-- 
1.9.1
