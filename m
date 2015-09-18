From: David Ahern <dsa@cumulusnetworks.com>
Subject: [RFC net-next 07/11] net: Remove the now unused vrf_ptr
Date: Fri, 18 Sep 2015 10:06:21 -0700
Message-ID: <1442595985-7049-8-git-send-email-dsa@cumulusnetworks.com>
References: <1442595985-7049-1-git-send-email-dsa@cumulusnetworks.com>
Cc: shm@cumulusnetworks.com, roopa@cumulusnetworks.com,
	nikolay@cumulusnetworks.com, gospo@cumulusnetworks.com,
	David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36309 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752890AbbIRRGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 13:06:47 -0400
Received: by padhk3 with SMTP id hk3so55835332pad.3
        for <netdev@vger.kernel.org>; Fri, 18 Sep 2015 10:06:46 -0700 (PDT)
In-Reply-To: <1442595985-7049-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c         | 32 ++------------------------------
 include/linux/netdevice.h |  2 --
 include/net/vrf.h         |  6 ------
 3 files changed, 2 insertions(+), 38 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 75d34a9b525a..c4f036b400eb 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -395,18 +395,15 @@ static void __vrf_insert_slave(struct slave_queue *queue, struct slave *slave)
 
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
@@ -423,7 +420,6 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 
 	port_dev->flags |= IFF_SLAVE;
 	__vrf_insert_slave(queue, slave);
-	rcu_assign_pointer(port_dev->vrf_ptr, vrf_ptr);
 	cycle_netdev(port_dev);
 
 	return 0;
@@ -431,7 +427,6 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 out_unregister:
 	netdev_rx_handler_unregister(port_dev);
 out_fail:
-	kfree(vrf_ptr);
 	kfree(slave);
 	return ret;
 }
@@ -447,21 +442,15 @@ static int vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
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
@@ -600,10 +589,6 @@ static int vrf_validate(struct nlattr *tb[], struct nlattr *data[])
 
 static void vrf_dellink(struct net_device *dev, struct list_head *head)
 {
-	struct net_vrf_dev *vrf_ptr = rtnl_dereference(dev->vrf_ptr);
-
-	RCU_INIT_POINTER(dev->vrf_ptr, NULL);
-	kfree_rcu(vrf_ptr, rcu);
 	unregister_netdevice_queue(dev, head);
 }
 
@@ -611,7 +596,6 @@ static int vrf_newlink(struct net *src_net, struct net_device *dev,
 		       struct nlattr *tb[], struct nlattr *data[])
 {
 	struct net_vrf *vrf = netdev_priv(dev);
-	struct net_vrf_dev *vrf_ptr;
 	int err;
 
 	if (!data || !data[IFLA_VRF_TABLE])
@@ -621,24 +605,13 @@ static int vrf_newlink(struct net *src_net, struct net_device *dev,
 
 	dev->priv_flags |= IFF_L3MDEV;
 
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
@@ -682,10 +655,9 @@ static int vrf_device_event(struct notifier_block *unused,
 
 	/* only care about unregister events to drop slave references */
 	if (event == NETDEV_UNREGISTER) {
-		struct net_vrf_dev *vrf_ptr = rtnl_dereference(dev->vrf_ptr);
 		struct net_device *vrf_dev;
 
-		if (!vrf_ptr || netif_is_l3_master(dev))
+		if (netif_is_l3_master(dev))
 			goto out;
 
 		vrf_dev = netdev_master_upper_dev_get(dev);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index dc944f431702..796c65dfa0ff 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1426,7 +1426,6 @@ enum netdev_priv_flags {
  *	@dn_ptr:	DECnet specific data
  *	@ip6_ptr:	IPv6 specific data
  *	@ax25_ptr:	AX.25 specific data
- *	@vrf_ptr:	VRF specific data
  *	@ieee80211_ptr:	IEEE 802.11 specific data, assign before registering
  *
  *	@last_rx:	Time of last Rx
@@ -1648,7 +1647,6 @@ struct net_device {
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
