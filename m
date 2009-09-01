From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 06/19] usbnet: convert to netdev_tx_t
Date: Mon, 31 Aug 2009 22:50:45 -0700
Message-ID: <20090901055128.980638707@vyatta.com>
References: <20090901055039.824876937@vyatta.com>
Cc: netdev@vger.kernel.org,
	David Brownell <dbrownell@users.sourceforge.net>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:57484 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752726AbZIAF67 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2009 01:58:59 -0400
Content-Disposition: inline; filename=usb-tx.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/usb/catc.c       |    3 ++-
 drivers/net/usb/cdc-phonet.c |    6 +++---
 drivers/net/usb/hso.c        |    3 ++-
 drivers/net/usb/kaweth.c     |    3 ++-
 drivers/net/usb/pegasus.c    |    3 ++-
 drivers/net/usb/rtl8150.c    |    3 ++-
 drivers/net/usb/usbnet.c     |    8 ++++----
 drivers/usb/gadget/u_ether.c |    3 ++-
 include/linux/usb/usbnet.h   |    3 ++-
 9 files changed, 21 insertions(+), 14 deletions(-)

--- a/drivers/net/usb/catc.c	2009-08-31 16:17:53.251107228 -0700
+++ b/drivers/net/usb/catc.c	2009-08-31 16:26:12.571081682 -0700
@@ -411,7 +411,8 @@ static void catc_tx_done(struct urb *urb
 	spin_unlock_irqrestore(&catc->tx_lock, flags);
 }
 
-static int catc_start_xmit(struct sk_buff *skb, struct net_device *netdev)
+static netdev_tx_t catc_start_xmit(struct sk_buff *skb,
+					 struct net_device *netdev)
 {
 	struct catc *catc = netdev_priv(netdev);
 	unsigned long flags;
--- a/drivers/net/usb/cdc-phonet.c	2009-08-31 16:17:53.231091626 -0700
+++ b/drivers/net/usb/cdc-phonet.c	2009-08-31 16:26:12.571081682 -0700
@@ -55,7 +55,7 @@ static void rx_complete(struct urb *req)
 /*
  * Network device callbacks
  */
-static int usbpn_xmit(struct sk_buff *skb, struct net_device *dev)
+static netdev_tx_t usbpn_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct usbpn_dev *pnd = netdev_priv(dev);
 	struct urb *req = NULL;
@@ -82,12 +82,12 @@ static int usbpn_xmit(struct sk_buff *sk
 	if (pnd->tx_queue >= dev->tx_queue_len)
 		netif_stop_queue(dev);
 	spin_unlock_irqrestore(&pnd->tx_lock, flags);
-	return 0;
+	return NETDEV_TX_OK;
 
 drop:
 	dev_kfree_skb(skb);
 	dev->stats.tx_dropped++;
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static void tx_complete(struct urb *req)
--- a/drivers/net/usb/hso.c	2009-08-31 16:17:53.241081443 -0700
+++ b/drivers/net/usb/hso.c	2009-08-31 16:26:12.571081682 -0700
@@ -771,7 +771,8 @@ static void write_bulk_callback(struct u
 }
 
 /* called by kernel when we need to transmit a packet */
-static int hso_net_start_xmit(struct sk_buff *skb, struct net_device *net)
+static netdev_tx_t hso_net_start_xmit(struct sk_buff *skb,
+					    struct net_device *net)
 {
 	struct hso_net *odev = netdev_priv(net);
 	int result;
--- a/drivers/net/usb/kaweth.c	2009-08-31 16:17:53.241081443 -0700
+++ b/drivers/net/usb/kaweth.c	2009-08-31 16:26:12.571081682 -0700
@@ -803,7 +803,8 @@ static void kaweth_usb_transmit_complete
 /****************************************************************
  *     kaweth_start_xmit
  ****************************************************************/
-static int kaweth_start_xmit(struct sk_buff *skb, struct net_device *net)
+static netdev_tx_t kaweth_start_xmit(struct sk_buff *skb,
+					   struct net_device *net)
 {
 	struct kaweth_device *kaweth = netdev_priv(net);
 	__le16 *private_header;
--- a/drivers/net/usb/pegasus.c	2009-08-31 16:17:53.251107228 -0700
+++ b/drivers/net/usb/pegasus.c	2009-08-31 16:26:12.571081682 -0700
@@ -876,7 +876,8 @@ static void pegasus_tx_timeout(struct ne
 	pegasus->stats.tx_errors++;
 }
 
-static int pegasus_start_xmit(struct sk_buff *skb, struct net_device *net)
+static netdev_tx_t pegasus_start_xmit(struct sk_buff *skb,
+					    struct net_device *net)
 {
 	pegasus_t *pegasus = netdev_priv(net);
 	int count = ((skb->len + 2) & 0x3f) ? skb->len + 2 : skb->len + 3;
--- a/drivers/net/usb/rtl8150.c	2009-08-31 16:17:53.261106055 -0700
+++ b/drivers/net/usb/rtl8150.c	2009-08-31 16:26:12.571081682 -0700
@@ -727,7 +727,8 @@ static void rtl8150_set_multicast(struct
 	netif_wake_queue(netdev);
 }
 
-static int rtl8150_start_xmit(struct sk_buff *skb, struct net_device *netdev)
+static netdev_tx_t rtl8150_start_xmit(struct sk_buff *skb,
+					    struct net_device *netdev)
 {
 	rtl8150_t *dev = netdev_priv(netdev);
 	int count, res;
--- a/drivers/net/usb/usbnet.c	2009-08-31 16:17:53.241081443 -0700
+++ b/drivers/net/usb/usbnet.c	2009-08-31 16:26:12.571081682 -0700
@@ -1007,15 +1007,16 @@ EXPORT_SYMBOL_GPL(usbnet_tx_timeout);
 
 /*-------------------------------------------------------------------------*/
 
-int usbnet_start_xmit (struct sk_buff *skb, struct net_device *net)
+netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
+				     struct net_device *net)
 {
 	struct usbnet		*dev = netdev_priv(net);
 	int			length;
-	int			retval = NET_XMIT_SUCCESS;
 	struct urb		*urb = NULL;
 	struct skb_data		*entry;
 	struct driver_info	*info = dev->driver_info;
 	unsigned long		flags;
+	int retval;
 
 	// some devices want funky USB-level framing, for
 	// win32 driver (usually) and/or hardware quirks
@@ -1079,7 +1080,6 @@ int usbnet_start_xmit (struct sk_buff *s
 		if (netif_msg_tx_err (dev))
 			devdbg (dev, "drop, code %d", retval);
 drop:
-		retval = NET_XMIT_SUCCESS;
 		dev->net->stats.tx_dropped++;
 		if (skb)
 			dev_kfree_skb_any (skb);
@@ -1088,7 +1088,7 @@ drop:
 		devdbg (dev, "> tx, len %d, type 0x%x",
 			length, skb->protocol);
 	}
-	return retval;
+	return NETDEV_TX_OK;
 }
 EXPORT_SYMBOL_GPL(usbnet_start_xmit);
 
--- a/include/linux/usb/usbnet.h	2009-08-31 16:17:53.281109296 -0700
+++ b/include/linux/usb/usbnet.h	2009-08-31 16:26:53.171108362 -0700
@@ -182,7 +182,8 @@ struct skb_data {	/* skb->cb is one of t
 
 extern int usbnet_open (struct net_device *net);
 extern int usbnet_stop (struct net_device *net);
-extern int usbnet_start_xmit (struct sk_buff *skb, struct net_device *net);
+extern netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
+				      struct net_device *net);
 extern void usbnet_tx_timeout (struct net_device *net);
 extern int usbnet_change_mtu (struct net_device *net, int new_mtu);
 
--- a/drivers/usb/gadget/u_ether.c	2009-08-31 16:17:53.271081695 -0700
+++ b/drivers/usb/gadget/u_ether.c	2009-08-31 16:26:12.571081682 -0700
@@ -465,7 +465,8 @@ static inline int is_promisc(u16 cdc_fil
 	return cdc_filter & USB_CDC_PACKET_TYPE_PROMISCUOUS;
 }
 
-static int eth_start_xmit(struct sk_buff *skb, struct net_device *net)
+static netdev_tx_t eth_start_xmit(struct sk_buff *skb,
+					struct net_device *net)
 {
 	struct eth_dev		*dev = netdev_priv(net);
 	int			length = skb->len;

-- 

