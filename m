From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 6/9] hippi: convert driver to net_device_ops
Date: Thu, 20 Nov 2008 09:59:19 -0800
Message-ID: <20081120175934.009148987@vyatta.com>
References: <20081120175913.943543638@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:53078 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753925AbYKTSEO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Nov 2008 13:04:14 -0500
Content-Disposition: inline; filename=hippi-netdev_ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert the HIPPI infrastructure for use with net_device_ops.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/rrunner.c       |   15 +++++++++++----
 include/linux/hippidevice.h |    4 +++-
 net/802/hippi.c             |   14 +++++++++-----
 3 files changed, 23 insertions(+), 10 deletions(-)

--- a/include/linux/hippidevice.h	2008-11-19 22:10:52.000000000 -0800
+++ b/include/linux/hippidevice.h	2008-11-20 09:19:03.000000000 -0800
@@ -32,7 +32,9 @@ struct hippi_cb {
 };
 
 extern __be16 hippi_type_trans(struct sk_buff *skb, struct net_device *dev);
-
+extern int hippi_change_mtu(struct net_device *dev, int new_mtu);
+extern int hippi_mac_addr(struct net_device *dev, void *p);
+extern int hippi_neigh_setup_dev(struct net_device *dev, struct neigh_parms *p);
 extern struct net_device *alloc_hippi_dev(int sizeof_priv);
 #endif
 
--- a/net/802/hippi.c	2008-11-19 22:10:52.000000000 -0800
+++ b/net/802/hippi.c	2008-11-20 09:19:03.000000000 -0800
@@ -144,7 +144,7 @@ __be16 hippi_type_trans(struct sk_buff *
 
 EXPORT_SYMBOL(hippi_type_trans);
 
-static int hippi_change_mtu(struct net_device *dev, int new_mtu)
+int hippi_change_mtu(struct net_device *dev, int new_mtu)
 {
 	/*
 	 * HIPPI's got these nice large MTUs.
@@ -154,12 +154,13 @@ static int hippi_change_mtu(struct net_d
 	dev->mtu = new_mtu;
 	return(0);
 }
+EXPORT_SYMBOL(hippi_change_mtu);
 
 /*
  * For HIPPI we will actually use the lower 4 bytes of the hardware
  * address as the I-FIELD rather than the actual hardware address.
  */
-static int hippi_mac_addr(struct net_device *dev, void *p)
+int hippi_mac_addr(struct net_device *dev, void *p)
 {
 	struct sockaddr *addr = p;
 	if (netif_running(dev))
@@ -167,8 +168,9 @@ static int hippi_mac_addr(struct net_dev
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 	return 0;
 }
+EXPORT_SYMBOL(hippi_mac_addr);
 
-static int hippi_neigh_setup_dev(struct net_device *dev, struct neigh_parms *p)
+int hippi_neigh_setup_dev(struct net_device *dev, struct neigh_parms *p)
 {
 	/* Never send broadcast/multicast ARP messages */
 	p->mcast_probes = 0;
@@ -181,6 +183,7 @@ static int hippi_neigh_setup_dev(struct 
 		p->ucast_probes = 0;
 	return 0;
 }
+EXPORT_SYMBOL(hippi_neigh_setup_dev);
 
 static const struct header_ops hippi_header_ops = {
 	.create		= hippi_header,
@@ -190,11 +193,12 @@ static const struct header_ops hippi_hea
 
 static void hippi_setup(struct net_device *dev)
 {
-	dev->set_multicast_list		= NULL;
+#ifdef CONFIG_COMPAT_NET_DEV_OPS
 	dev->change_mtu			= hippi_change_mtu;
-	dev->header_ops			= &hippi_header_ops;
 	dev->set_mac_address 		= hippi_mac_addr;
 	dev->neigh_setup 		= hippi_neigh_setup_dev;
+#endif
+	dev->header_ops			= &hippi_header_ops;
 
 	/*
 	 * We don't support HIPPI `ARP' for the time being, and probably
--- a/drivers/net/rrunner.c	2008-11-20 09:40:37.000000000 -0800
+++ b/drivers/net/rrunner.c	2008-11-20 09:41:29.000000000 -0800
@@ -63,6 +63,16 @@ MODULE_LICENSE("GPL");
 
 static char version[] __devinitdata = "rrunner.c: v0.50 11/11/2002  Jes Sorensen (jes@wildopensource.com)\n";
 
+
+static const struct net_device_ops rr_netdev_ops = {
+	.ndo_open 		= rr_open,
+	.ndo_stop		= rr_close,
+	.ndo_do_ioctl		= rr_ioctl,
+	.ndo_start_xmit		= rr_start_xmit,
+	.ndo_change_mtu		= hippi_change_mtu,
+	.ndo_set_mac_address	= hippi_mac_addr,
+};
+
 /*
  * Implementation notes:
  *
@@ -115,10 +125,7 @@ static int __devinit rr_init_one(struct 
 	spin_lock_init(&rrpriv->lock);
 
 	dev->irq = pdev->irq;
-	dev->open = &rr_open;
-	dev->hard_start_xmit = &rr_start_xmit;
-	dev->stop = &rr_close;
-	dev->do_ioctl = &rr_ioctl;
+	dev->netdev_ops = &rr_netdev_ops;
 
 	dev->base_addr = pci_resource_start(pdev, 0);
 

-- 

