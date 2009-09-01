From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 09/19] hdlc: convert to netdev_tx_t
Date: Mon, 31 Aug 2009 22:50:48 -0700
Message-ID: <20090901055129.321442636@vyatta.com>
References: <20090901055039.824876937@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57462 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752292AbZIAF6y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 01:58:54 -0400
Content-Disposition: inline; filename=hdlc-tx.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/char/pcmcia/synclink_cs.c |    7 +++----
 drivers/char/synclink.c           |    7 +++----
 drivers/char/synclink_gt.c        |    7 +++----
 drivers/char/synclinkmp.c         |    7 +++----
 include/linux/hdlc.h              |    8 ++++----
 5 files changed, 16 insertions(+), 20 deletions(-)

--- a/include/linux/hdlc.h	2009-08-31 16:17:52.981107416 -0700
+++ b/include/linux/hdlc.h	2009-08-31 16:27:04.181091272 -0700
@@ -38,7 +38,7 @@ struct hdlc_proto {
 	int (*ioctl)(struct net_device *dev, struct ifreq *ifr);
 	__be16 (*type_trans)(struct sk_buff *skb, struct net_device *dev);
 	int (*netif_rx)(struct sk_buff *skb);
-	int (*xmit)(struct sk_buff *skb, struct net_device *dev);
+	netdev_tx_t (*xmit)(struct sk_buff *skb, struct net_device *dev);
 	struct module *module;
 	struct hdlc_proto *next; /* next protocol in the list */
 };
@@ -51,7 +51,7 @@ typedef struct hdlc_device {
 		      unsigned short encoding, unsigned short parity);
 
 	/* hardware driver must handle this instead of dev->hard_start_xmit */
-	int (*xmit)(struct sk_buff *skb, struct net_device *dev);
+	netdev_tx_t (*xmit)(struct sk_buff *skb, struct net_device *dev);
 
 	/* Things below are for HDLC layer internal use only */
 	const struct hdlc_proto *proto;
@@ -60,7 +60,7 @@ typedef struct hdlc_device {
 	spinlock_t state_lock;
 	void *state;
 	void *priv;
-}hdlc_device;
+} hdlc_device;
 
 
 
@@ -106,7 +106,7 @@ void hdlc_close(struct net_device *dev);
 /* May be used by hardware driver */
 int hdlc_change_mtu(struct net_device *dev, int new_mtu);
 /* Must be pointed to by hw driver's dev->netdev_ops->ndo_start_xmit */
-int hdlc_start_xmit(struct sk_buff *skb, struct net_device *dev);
+netdev_tx_t hdlc_start_xmit(struct sk_buff *skb, struct net_device *dev);
 
 int attach_hdlc_protocol(struct net_device *dev, struct hdlc_proto *proto,
 			 size_t size);
--- a/drivers/char/pcmcia/synclink_cs.c	2009-08-31 16:17:52.961081267 -0700
+++ b/drivers/char/pcmcia/synclink_cs.c	2009-08-31 16:27:04.181091272 -0700
@@ -4005,10 +4005,9 @@ static int hdlcdev_attach(struct net_dev
  *
  * skb  socket buffer containing HDLC frame
  * dev  pointer to network device structure
- *
- * returns 0 if success, otherwise error code
  */
-static int hdlcdev_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t hdlcdev_xmit(struct sk_buff *skb,
+				      struct net_device *dev)
 {
 	MGSLPC_INFO *info = dev_to_port(dev);
 	unsigned long flags;
@@ -4043,7 +4042,7 @@ static int hdlcdev_xmit(struct sk_buff *
 	}
 	spin_unlock_irqrestore(&info->lock,flags);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /**
--- a/drivers/char/synclink.c	2009-08-31 16:17:52.971081211 -0700
+++ b/drivers/char/synclink.c	2009-08-31 16:27:04.181091272 -0700
@@ -7697,10 +7697,9 @@ static int hdlcdev_attach(struct net_dev
  *
  * skb  socket buffer containing HDLC frame
  * dev  pointer to network device structure
- *
- * returns 0 if success, otherwise error code
  */
-static int hdlcdev_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t hdlcdev_xmit(struct sk_buff *skb,
+				      struct net_device *dev)
 {
 	struct mgsl_struct *info = dev_to_port(dev);
 	unsigned long flags;
@@ -7731,7 +7730,7 @@ static int hdlcdev_xmit(struct sk_buff *
 	 	usc_start_transmitter(info);
 	spin_unlock_irqrestore(&info->irq_spinlock,flags);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /**
--- a/drivers/char/synclink_gt.c	2009-08-31 16:17:52.971081211 -0700
+++ b/drivers/char/synclink_gt.c	2009-08-31 16:27:04.191109445 -0700
@@ -1497,10 +1497,9 @@ static int hdlcdev_attach(struct net_dev
  *
  * skb  socket buffer containing HDLC frame
  * dev  pointer to network device structure
- *
- * returns 0 if success, otherwise error code
  */
-static int hdlcdev_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t hdlcdev_xmit(struct sk_buff *skb,
+				      struct net_device *dev)
 {
 	struct slgt_info *info = dev_to_port(dev);
 	unsigned long flags;
@@ -1529,7 +1528,7 @@ static int hdlcdev_xmit(struct sk_buff *
 	update_tx_timer(info);
 	spin_unlock_irqrestore(&info->lock,flags);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /**
--- a/drivers/char/synclinkmp.c	2009-08-31 16:17:52.961081267 -0700
+++ b/drivers/char/synclinkmp.c	2009-08-31 16:27:04.191109445 -0700
@@ -1608,10 +1608,9 @@ static int hdlcdev_attach(struct net_dev
  *
  * skb  socket buffer containing HDLC frame
  * dev  pointer to network device structure
- *
- * returns 0 if success, otherwise error code
  */
-static int hdlcdev_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t hdlcdev_xmit(struct sk_buff *skb,
+				      struct net_device *dev)
 {
 	SLMP_INFO *info = dev_to_port(dev);
 	unsigned long flags;
@@ -1642,7 +1641,7 @@ static int hdlcdev_xmit(struct sk_buff *
 	 	tx_start(info);
 	spin_unlock_irqrestore(&info->lock,flags);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 /**

-- 

