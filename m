From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 06/12] vxlan: move freecpu to uninit
Date: Mon, 10 Jun 2013 13:24:48 -0700
Message-ID: <20130610132448.3f3c5d93@nehalam.linuxnetplumber.net>
References: <20130610200524.721617349@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:50171 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752966Ab3FJUZz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 16:25:55 -0400
Received: by mail-pd0-f178.google.com with SMTP id w11so3403048pde.37
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 13:25:54 -0700 (PDT)
In-Reply-To: <20130610200524.721617349@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use ndo_uninit to avoid having to override destructor.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/drivers/net/vxlan.c	2013-06-10 12:19:59.522092022 -0700
+++ b/drivers/net/vxlan.c	2013-06-10 12:20:00.590079878 -0700
@@ -1272,6 +1272,17 @@ static int vxlan_init(struct net_device
 	return 0;
 }
 
+static void vxlan_uninit(struct net_device *dev)
+{
+	struct vxlan_dev *vxlan = netdev_priv(dev);
+	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
+	struct vxlan_sock *vs = vxlan->vn_sock;
+
+	if (vs)
+		vxlan_sock_release(vn, vs);
+	free_percpu(dev->tstats);
+}
+
 /* Start ageing timer and join group when device is brought up */
 static int vxlan_open(struct net_device *dev)
 {
@@ -1337,6 +1348,7 @@ static void vxlan_set_multicast_list(str
 
 static const struct net_device_ops vxlan_netdev_ops = {
 	.ndo_init		= vxlan_init,
+	.ndo_uninit		= vxlan_uninit,
 	.ndo_open		= vxlan_open,
 	.ndo_stop		= vxlan_stop,
 	.ndo_start_xmit		= vxlan_xmit,
@@ -1355,12 +1367,6 @@ static struct device_type vxlan_type = {
 	.name = "vxlan",
 };
 
-static void vxlan_free(struct net_device *dev)
-{
-	free_percpu(dev->tstats);
-	free_netdev(dev);
-}
-
 /* Initialize the device structure. */
 static void vxlan_setup(struct net_device *dev)
 {
@@ -1373,7 +1379,7 @@ static void vxlan_setup(struct net_devic
 	dev->hard_header_len = ETH_HLEN + VXLAN_HEADROOM;
 
 	dev->netdev_ops = &vxlan_netdev_ops;
-	dev->destructor = vxlan_free;
+	dev->destructor = free_netdev;
 	SET_NETDEV_DEVTYPE(dev, &vxlan_type);
 
 	dev->tx_queue_len = 0;
@@ -1676,14 +1682,10 @@ static int vxlan_newlink(struct net *net
 static void vxlan_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct vxlan_dev *vxlan = netdev_priv(dev);
-	struct vxlan_net *vn = net_generic(dev_net(dev), vxlan_net_id);
-	struct vxlan_sock *vs = vxlan->vn_sock;
 
 	hlist_del_rcu(&vxlan->hlist);
 	list_del(&vxlan->next);
 	unregister_netdevice_queue(dev, head);
-	if (vs)
-		vxlan_sock_release(vn, vs);
 }
 
 static size_t vxlan_get_size(const struct net_device *dev)
