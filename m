From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 37/42] synclink: convert devices to new API
Date: Tue, 06 Jan 2009 16:33:53 -0800
Message-ID: <20090107003349.468715485@vyatta.com>
References: <20090107003316.784424362@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:60731 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757206AbZAGAyV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2009 19:54:21 -0500
Content-Disposition: inline; filename=synclink.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert to net_device_ops and internal net_device_stats.

Remove unneeded last_rx update.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/char/pcmcia/synclink_cs.c |   15 +++++++++------
 drivers/char/synclink.c           |   15 +++++++++------
 drivers/char/synclink_gt.c        |   15 +++++++++------
 drivers/char/synclinkmp.c         |   15 +++++++++------
 drivers/net/wan/hdlc.c            |   17 +++--------------
 include/linux/hdlc.h              |    2 ++
 6 files changed, 41 insertions(+), 38 deletions(-)

--- a/drivers/char/pcmcia/synclink_cs.c	2009-01-04 21:53:17.002282444 -0800
+++ b/drivers/char/pcmcia/synclink_cs.c	2009-01-04 21:53:51.974533932 -0800
@@ -4311,10 +4311,16 @@ static void hdlcdev_rx(MGSLPC_INFO *info
 	dev->stats.rx_bytes += size;
 
 	netif_rx(skb);
-
-	dev->last_rx = jiffies;
 }
 
+static const struct net_device_ops hdlcdev_ops = {
+	.ndo_open       = hdlcdev_open,
+	.ndo_stop       = hdlcdev_close,
+	.ndo_change_mtu = hdlc_change_mtu,
+	.ndo_do_ioctl	= hdlcdev_ioctl,
+	.ndo_tx_timeout = hdlcdev_tx_timeout,
+};
+
 /**
  * called by device driver when adding device instance
  * do generic HDLC initialization
@@ -4341,10 +4347,7 @@ static int hdlcdev_init(MGSLPC_INFO *inf
 	dev->irq       = info->irq_level;
 
 	/* network layer callbacks and settings */
-	dev->do_ioctl       = hdlcdev_ioctl;
-	dev->open           = hdlcdev_open;
-	dev->stop           = hdlcdev_close;
-	dev->tx_timeout     = hdlcdev_tx_timeout;
+	dev->netdev_ops	    = &hdlcdev_ops;
 	dev->watchdog_timeo = 10*HZ;
 	dev->tx_queue_len   = 50;
 
--- a/drivers/char/synclink.c	2009-01-04 21:53:17.010282322 -0800
+++ b/drivers/char/synclink.c	2009-01-04 21:53:51.978533634 -0800
@@ -8007,10 +8007,16 @@ static void hdlcdev_rx(struct mgsl_struc
 	dev->stats.rx_bytes += size;
 
 	netif_rx(skb);
-
-	dev->last_rx = jiffies;
 }
 
+static const struct net_device_ops hdlcdev_ops = {
+	.ndo_open       = hdlcdev_open,
+	.ndo_stop       = hdlcdev_close,
+	.ndo_change_mtu = hdlc_change_mtu,
+	.ndo_do_ioctl	= hdlcdev_ioctl,
+	.ndo_tx_timeout = hdlcdev_tx_timeout,
+};
+
 /**
  * called by device driver when adding device instance
  * do generic HDLC initialization
@@ -8033,15 +8039,12 @@ static int hdlcdev_init(struct mgsl_stru
 	}
 
 	/* for network layer reporting purposes only */
+	dev->netdev_ops = &hdlcdev_ops;
 	dev->base_addr = info->io_base;
 	dev->irq       = info->irq_level;
 	dev->dma       = info->dma_level;
 
 	/* network layer callbacks and settings */
-	dev->do_ioctl       = hdlcdev_ioctl;
-	dev->open           = hdlcdev_open;
-	dev->stop           = hdlcdev_close;
-	dev->tx_timeout     = hdlcdev_tx_timeout;
 	dev->watchdog_timeo = 10*HZ;
 	dev->tx_queue_len   = 50;
 
--- a/drivers/char/synclink_gt.c	2009-01-04 21:53:17.010282322 -0800
+++ b/drivers/char/synclink_gt.c	2009-01-04 21:53:51.982533169 -0800
@@ -1766,10 +1766,16 @@ static void hdlcdev_rx(struct slgt_info 
 	dev->stats.rx_bytes += size;
 
 	netif_rx(skb);
-
-	dev->last_rx = jiffies;
 }
 
+static const struct net_device_ops hdlcdev_ops = {
+	.ndo_open       = hdlcdev_open,
+	.ndo_stop       = hdlcdev_close,
+	.ndo_change_mtu = hdlc_change_mtu,
+	.ndo_do_ioctl	= hdlcdev_ioctl,
+	.ndo_tx_timeout = hdlcdev_tx_timeout,
+};
+
 /**
  * called by device driver when adding device instance
  * do generic HDLC initialization
@@ -1797,10 +1803,7 @@ static int hdlcdev_init(struct slgt_info
 	dev->irq       = info->irq_level;
 
 	/* network layer callbacks and settings */
-	dev->do_ioctl       = hdlcdev_ioctl;
-	dev->open           = hdlcdev_open;
-	dev->stop           = hdlcdev_close;
-	dev->tx_timeout     = hdlcdev_tx_timeout;
+	dev->netdev_ops	    = &hdlcdev_ops;
 	dev->watchdog_timeo = 10*HZ;
 	dev->tx_queue_len   = 50;
 
--- a/drivers/char/synclinkmp.c	2009-01-04 21:53:17.010282322 -0800
+++ b/drivers/char/synclinkmp.c	2009-01-04 21:53:51.986533063 -0800
@@ -1907,10 +1907,16 @@ static void hdlcdev_rx(SLMP_INFO *info, 
 	dev->stats.rx_bytes += size;
 
 	netif_rx(skb);
-
-	dev->last_rx = jiffies;
 }
 
+static const struct net_device_ops hdlcdev_ops = {
+	.ndo_open       = hdlcdev_open,
+	.ndo_stop       = hdlcdev_close,
+	.ndo_change_mtu = hdlc_change_mtu,
+	.ndo_do_ioctl	= hdlcdev_ioctl,
+	.ndo_tx_timeout = hdlcdev_tx_timeout,
+};
+
 /**
  * called by device driver when adding device instance
  * do generic HDLC initialization
@@ -1938,10 +1944,7 @@ static int hdlcdev_init(SLMP_INFO *info)
 	dev->irq       = info->irq_level;
 
 	/* network layer callbacks and settings */
-	dev->do_ioctl       = hdlcdev_ioctl;
-	dev->open           = hdlcdev_open;
-	dev->stop           = hdlcdev_close;
-	dev->tx_timeout     = hdlcdev_tx_timeout;
+	dev->netdev_ops	    = &hdlcdev_ops;
 	dev->watchdog_timeo = 10*HZ;
 	dev->tx_queue_len   = 50;
 
--- a/drivers/net/wan/hdlc.c	2009-01-04 21:43:07.402034096 -0800
+++ b/drivers/net/wan/hdlc.c	2009-01-04 21:53:51.986533063 -0800
@@ -44,22 +44,14 @@ static const char* version = "HDLC suppo
 
 static struct hdlc_proto *first_proto;
 
-static int hdlc_change_mtu(struct net_device *dev, int new_mtu)
+int hdlc_change_mtu(struct net_device *dev, int new_mtu)
 {
 	if ((new_mtu < 68) || (new_mtu > HDLC_MAX_MTU))
 		return -EINVAL;
 	dev->mtu = new_mtu;
 	return 0;
 }
-
-
-
-static struct net_device_stats *hdlc_get_stats(struct net_device *dev)
-{
-	return &dev->stats;
-}
-
-
+EXPORT_SYMBOL(hdlc_change_mtu);
 
 static int hdlc_rcv(struct sk_buff *skb, struct net_device *dev,
 		    struct packet_type *p, struct net_device *orig_dev)
@@ -106,7 +98,7 @@ static int hdlc_device_event(struct noti
 	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
-	if (dev->get_stats != hdlc_get_stats)
+	if (dev->header_ops != &hdlc_null_ops)
 		return NOTIFY_DONE; /* not an HDLC device */
 
 	if (event != NETDEV_CHANGE)
@@ -233,15 +225,12 @@ static void hdlc_setup_dev(struct net_de
 	/* Re-init all variables changed by HDLC protocol drivers,
 	 * including ether_setup() called from hdlc_raw_eth.c.
 	 */
-	dev->get_stats		 = hdlc_get_stats;
 	dev->flags		 = IFF_POINTOPOINT | IFF_NOARP;
 	dev->mtu		 = HDLC_MAX_MTU;
 	dev->type		 = ARPHRD_RAWHDLC;
 	dev->hard_header_len	 = 16;
 	dev->addr_len		 = 0;
 	dev->header_ops		 = &hdlc_null_ops;
-
-	dev->change_mtu		 = hdlc_change_mtu;
 }
 
 static void hdlc_setup(struct net_device *dev)
--- a/include/linux/hdlc.h	2009-01-04 21:43:07.466037830 -0800
+++ b/include/linux/hdlc.h	2009-01-04 21:53:51.986533063 -0800
@@ -103,6 +103,8 @@ int hdlc_open(struct net_device *dev);
 /* Must be called by hardware driver when HDLC device is being closed */
 void hdlc_close(struct net_device *dev);
 
+int hdlc_change_mtu(struct net_device *dev, int new_mtu);
+
 int attach_hdlc_protocol(struct net_device *dev, struct hdlc_proto *proto,
 			 size_t size);
 /* May be used by hardware driver to gain control over HDLC device */

-- 

