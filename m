From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 4/9] fddi: convert to new network device ops
Date: Thu, 20 Nov 2008 09:59:17 -0800
Message-ID: <20081120175933.837997092@vyatta.com>
References: <20081120175913.943543638@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:53072 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753348AbYKTSEN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2008 13:04:13 -0500
Content-Disposition: inline; filename=fddi-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to ethernet. Convert infrastructure and the one lone FDDI
driver (for the one lone user of that hardware??). Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/skfp/skfddi.c  |   19 ++++++++++++-------
 include/linux/fddidevice.h |    1 +
 net/802/fddi.c             |    8 ++++++--
 3 files changed, 19 insertions(+), 9 deletions(-)

--- a/net/802/fddi.c	2008-11-20 09:08:10.000000000 -0800
+++ b/net/802/fddi.c	2008-11-20 09:16:02.000000000 -0800
@@ -167,23 +167,27 @@ __be16 fddi_type_trans(struct sk_buff *s
 
 EXPORT_SYMBOL(fddi_type_trans);
 
-static int fddi_change_mtu(struct net_device *dev, int new_mtu)
+int fddi_change_mtu(struct net_device *dev, int new_mtu)
 {
 	if ((new_mtu < FDDI_K_SNAP_HLEN) || (new_mtu > FDDI_K_SNAP_DLEN))
 		return(-EINVAL);
 	dev->mtu = new_mtu;
 	return(0);
 }
+EXPORT_SYMBOL(fddi_change_mtu);
 
 static const struct header_ops fddi_header_ops = {
 	.create		= fddi_header,
 	.rebuild	= fddi_rebuild_header,
 };
 
+
 static void fddi_setup(struct net_device *dev)
 {
-	dev->change_mtu		= fddi_change_mtu;
 	dev->header_ops		= &fddi_header_ops;
+#ifdef CONFIG_COMPAT_NET_DEV_OPS
+	dev->change_mtu		= fddi_change_mtu,
+#endif
 
 	dev->type		= ARPHRD_FDDI;
 	dev->hard_header_len	= FDDI_K_SNAP_HLEN+3;	/* Assume 802.2 SNAP hdr len + 3 pad bytes */
--- a/include/linux/fddidevice.h	2008-11-20 09:08:10.000000000 -0800
+++ b/include/linux/fddidevice.h	2008-11-20 09:16:02.000000000 -0800
@@ -27,6 +27,7 @@
 #ifdef __KERNEL__
 extern __be16	fddi_type_trans(struct sk_buff *skb,
 				struct net_device *dev);
+extern int fddi_change_mtu(struct net_device *dev, int new_mtu);
 extern struct net_device *alloc_fddidev(int sizeof_priv);
 #endif
 
--- a/drivers/net/skfp/skfddi.c	2008-11-20 09:08:10.000000000 -0800
+++ b/drivers/net/skfp/skfddi.c	2008-11-20 09:17:53.000000000 -0800
@@ -168,6 +168,17 @@ static int num_boards;	/* total number o
 #define PRINTK(s, args...)
 #endif				// DRIVERDEBUG
 
+static const struct net_device_ops skfp_netdev_ops = {
+	.ndo_open		= skfp_open,
+	.ndo_stop		= skfp_close,
+	.ndo_start_xmit		= skfp_send_pkt,
+	.ndo_get_stats		= skfp_ctl_get_stats,
+	.ndo_change_mtu		= fddi_change_mtu,
+	.ndo_set_multicast_list = skfp_ctl_set_multicast_list,
+	.ndo_set_mac_address	= skfp_ctl_set_mac_address,
+	.ndo_do_ioctl		= skfp_ioctl,
+};
+
 /*
  * =================
  * = skfp_init_one =
@@ -253,13 +264,7 @@ static int skfp_init_one(struct pci_dev 
 	}
 
 	dev->irq = pdev->irq;
-	dev->get_stats = &skfp_ctl_get_stats;
-	dev->open = &skfp_open;
-	dev->stop = &skfp_close;
-	dev->hard_start_xmit = &skfp_send_pkt;
-	dev->set_multicast_list = &skfp_ctl_set_multicast_list;
-	dev->set_mac_address = &skfp_ctl_set_mac_address;
-	dev->do_ioctl = &skfp_ioctl;
+	dev->netdev_ops = &skfp_netdev_ops;
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 

-- 

