From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 12/45] arcnet: convert to net_device_ops
Date: Fri, 09 Jan 2009 15:01:09 -0800
Message-ID: <20090109230137.604410756@linux-foundation.org>
References: <20090109230057.575650817@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42176 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753960AbZAIXRz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jan 2009 18:17:55 -0500
Content-Disposition: inline; filename=arcnet-netdev.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/arcnet/arcnet.c |   33 ++++++++++++++++-----------------
 include/linux/arcdevice.h   |    7 ++++++-
 2 files changed, 22 insertions(+), 18 deletions(-)

--- a/drivers/net/arcnet/arcnet.c	2009-01-09 09:41:04.000000000 -0800
+++ b/drivers/net/arcnet/arcnet.c	2009-01-09 09:54:39.000000000 -0800
@@ -95,12 +95,12 @@ EXPORT_SYMBOL(arcnet_unregister_proto);
 EXPORT_SYMBOL(arcnet_debug);
 EXPORT_SYMBOL(alloc_arcdev);
 EXPORT_SYMBOL(arcnet_interrupt);
+EXPORT_SYMBOL(arcnet_open);
+EXPORT_SYMBOL(arcnet_close);
+EXPORT_SYMBOL(arcnet_send_packet);
+EXPORT_SYMBOL(arcnet_timeout);
 
 /* Internal function prototypes */
-static int arcnet_open(struct net_device *dev);
-static int arcnet_close(struct net_device *dev);
-static int arcnet_send_packet(struct sk_buff *skb, struct net_device *dev);
-static void arcnet_timeout(struct net_device *dev);
 static int arcnet_header(struct sk_buff *skb, struct net_device *dev,
 			 unsigned short type, const void *daddr,
 			 const void *saddr, unsigned len);
@@ -321,11 +321,18 @@ static const struct header_ops arcnet_he
 	.rebuild = arcnet_rebuild_header,
 };
 
+static const struct net_device_ops arcnet_netdev_ops = {
+	.ndo_open	= arcnet_open,
+	.ndo_stop	= arcnet_close,
+	.ndo_start_xmit = arcnet_send_packet,
+	.ndo_tx_timeout = arcnet_timeout,
+};
 
 /* Setup a struct device for ARCnet. */
 static void arcdev_setup(struct net_device *dev)
 {
 	dev->type = ARPHRD_ARCNET;
+	dev->netdev_ops = &arcnet_netdev_ops;
 	dev->header_ops = &arcnet_header_ops;
 	dev->hard_header_len = sizeof(struct archdr);
 	dev->mtu = choose_mtu();
@@ -338,17 +345,9 @@ static void arcdev_setup(struct net_devi
 	/* New-style flags. */
 	dev->flags = IFF_BROADCAST;
 
-	/*
-	 * Put in this stuff here, so we don't have to export the symbols to
-	 * the chipset drivers.
-	 */
-	dev->open = arcnet_open;
-	dev->stop = arcnet_close;
-	dev->hard_start_xmit = arcnet_send_packet;
-	dev->tx_timeout = arcnet_timeout;
 }
 
-struct net_device *alloc_arcdev(char *name)
+struct net_device *alloc_arcdev(const char *name)
 {
 	struct net_device *dev;
 
@@ -370,7 +369,7 @@ struct net_device *alloc_arcdev(char *na
  * that "should" only need to be set once at boot, so that there is
  * non-reboot way to recover if something goes wrong.
  */
-static int arcnet_open(struct net_device *dev)
+int arcnet_open(struct net_device *dev)
 {
 	struct arcnet_local *lp = netdev_priv(dev);
 	int count, newmtu, error;
@@ -470,7 +469,7 @@ static int arcnet_open(struct net_device
 
 
 /* The inverse routine to arcnet_open - shuts down the card. */
-static int arcnet_close(struct net_device *dev)
+int arcnet_close(struct net_device *dev)
 {
 	struct arcnet_local *lp = netdev_priv(dev);
 
@@ -599,7 +598,7 @@ static int arcnet_rebuild_header(struct 
 
 
 /* Called by the kernel in order to transmit a packet. */
-static int arcnet_send_packet(struct sk_buff *skb, struct net_device *dev)
+int arcnet_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	struct arcnet_local *lp = netdev_priv(dev);
 	struct archdr *pkt;
@@ -718,7 +717,7 @@ static int go_tx(struct net_device *dev)
 
 
 /* Called by the kernel when transmit times out */
-static void arcnet_timeout(struct net_device *dev)
+void arcnet_timeout(struct net_device *dev)
 {
 	unsigned long flags;
 	struct arcnet_local *lp = netdev_priv(dev);
--- a/include/linux/arcdevice.h	2009-01-09 09:41:04.000000000 -0800
+++ b/include/linux/arcdevice.h	2009-01-09 09:48:14.000000000 -0800
@@ -333,7 +333,12 @@ void arcnet_dump_skb(struct net_device *
 
 void arcnet_unregister_proto(struct ArcProto *proto);
 irqreturn_t arcnet_interrupt(int irq, void *dev_id);
-struct net_device *alloc_arcdev(char *name);
+struct net_device *alloc_arcdev(const char *name);
+
+int arcnet_open(struct net_device *dev);
+int arcnet_close(struct net_device *dev);
+int arcnet_send_packet(struct sk_buff *skb, struct net_device *dev);
+void arcnet_timeout(struct net_device *dev);
 
 #endif				/* __KERNEL__ */
 #endif				/* _LINUX_ARCDEVICE_H */


