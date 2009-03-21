From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 27/77] usbnet: support net_device_ops
Date: Fri, 20 Mar 2009 22:35:54 -0700
Message-ID: <20090321053714.584310988@vyatta.com>
References: <20090321053527.316395697@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, dbrownell@users.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36589 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760814AbZCUFsQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Mar 2009 01:48:16 -0400
Content-Disposition: inline; filename=usbnet-ops.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use net_device_ops for usbnet device, and export for use
by other derived drivers.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/usb/usbnet.c   |   31 +++++++++++++++++++++++--------
 include/linux/usb/usbnet.h |    5 +++++
 2 files changed, 28 insertions(+), 8 deletions(-)

--- a/drivers/net/usb/usbnet.c	2009-03-20 09:39:11.001839596 -0700
+++ b/drivers/net/usb/usbnet.c	2009-03-20 09:57:37.178776906 -0700
@@ -223,7 +223,7 @@ EXPORT_SYMBOL_GPL(usbnet_skb_return);
  *
  *-------------------------------------------------------------------------*/
 
-static int usbnet_change_mtu (struct net_device *net, int new_mtu)
+int usbnet_change_mtu (struct net_device *net, int new_mtu)
 {
 	struct usbnet	*dev = netdev_priv(net);
 	int		ll_mtu = new_mtu + net->hard_header_len;
@@ -246,6 +246,7 @@ static int usbnet_change_mtu (struct net
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(usbnet_change_mtu);
 
 /*-------------------------------------------------------------------------*/
 
@@ -540,7 +541,7 @@ EXPORT_SYMBOL_GPL(usbnet_unlink_rx_urbs)
 
 // precondition: never called in_interrupt
 
-static int usbnet_stop (struct net_device *net)
+int usbnet_stop (struct net_device *net)
 {
 	struct usbnet		*dev = netdev_priv(net);
 	int			temp;
@@ -584,6 +585,7 @@ static int usbnet_stop (struct net_devic
 
 	return 0;
 }
+EXPORT_SYMBOL_GPL(usbnet_stop);
 
 /*-------------------------------------------------------------------------*/
 
@@ -591,7 +593,7 @@ static int usbnet_stop (struct net_devic
 
 // precondition: never called in_interrupt
 
-static int usbnet_open (struct net_device *net)
+int usbnet_open (struct net_device *net)
 {
 	struct usbnet		*dev = netdev_priv(net);
 	int			retval;
@@ -666,6 +668,7 @@ done:
 done_nopm:
 	return retval;
 }
+EXPORT_SYMBOL_GPL(usbnet_open);
 
 /*-------------------------------------------------------------------------*/
 
@@ -900,7 +903,7 @@ static void tx_complete (struct urb *urb
 
 /*-------------------------------------------------------------------------*/
 
-static void usbnet_tx_timeout (struct net_device *net)
+void usbnet_tx_timeout (struct net_device *net)
 {
 	struct usbnet		*dev = netdev_priv(net);
 
@@ -909,10 +912,11 @@ static void usbnet_tx_timeout (struct ne
 
 	// FIXME: device recovery -- reset?
 }
+EXPORT_SYMBOL_GPL(usbnet_tx_timeout);
 
 /*-------------------------------------------------------------------------*/
 
-static int usbnet_start_xmit (struct sk_buff *skb, struct net_device *net)
+int usbnet_start_xmit (struct sk_buff *skb, struct net_device *net)
 {
 	struct usbnet		*dev = netdev_priv(net);
 	int			length;
@@ -995,7 +999,7 @@ drop:
 	}
 	return retval;
 }
-
+EXPORT_SYMBOL_GPL(usbnet_start_xmit);
 
 /*-------------------------------------------------------------------------*/
 
@@ -1102,6 +1106,15 @@ void usbnet_disconnect (struct usb_inter
 }
 EXPORT_SYMBOL_GPL(usbnet_disconnect);
 
+static const struct net_device_ops usbnet_netdev_ops = {
+	.ndo_open		= usbnet_open,
+	.ndo_stop		= usbnet_stop,
+	.ndo_start_xmit		= usbnet_start_xmit,
+	.ndo_tx_timeout		= usbnet_tx_timeout,
+	.ndo_change_mtu		= usbnet_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+};
 
 /*-------------------------------------------------------------------------*/
 
@@ -1171,12 +1184,14 @@ usbnet_probe (struct usb_interface *udev
 		net->features |= NETIF_F_HIGHDMA;
 #endif
 
-	net->change_mtu = usbnet_change_mtu;
+	net->netdev_ops = &usbnet_netdev_ops;
+#ifdef CONFIG_COMPAT_NET_DEV_OPS
 	net->hard_start_xmit = usbnet_start_xmit;
 	net->open = usbnet_open;
 	net->stop = usbnet_stop;
-	net->watchdog_timeo = TX_TIMEOUT_JIFFIES;
 	net->tx_timeout = usbnet_tx_timeout;
+#endif
+	net->watchdog_timeo = TX_TIMEOUT_JIFFIES;
 	net->ethtool_ops = &usbnet_ethtool_ops;
 
 	// allow device-specific bind/init procedures
--- a/include/linux/usb/usbnet.h	2009-03-20 09:54:30.657965414 -0700
+++ b/include/linux/usb/usbnet.h	2009-03-20 09:57:31.417699745 -0700
@@ -176,6 +176,11 @@ struct skb_data {	/* skb->cb is one of t
 	size_t			length;
 };
 
+extern int usbnet_open (struct net_device *net);
+extern int usbnet_stop (struct net_device *net);
+extern int usbnet_start_xmit (struct sk_buff *skb, struct net_device *net);
+extern void usbnet_tx_timeout (struct net_device *net);
+extern int usbnet_change_mtu (struct net_device *net, int new_mtu);
 
 extern int usbnet_get_endpoints(struct usbnet *, struct usb_interface *);
 extern void usbnet_defer_kevent (struct usbnet *, int);

-- 

