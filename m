From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH next 5/7] rtl8150: removal of forward declarations.
Date: Fri, 30 Sep 2011 12:38:29 +0200
Message-ID: <20110930103829.GF26727@electric-eye.fr.zoreil.com>
References: <20110930103604.GA26727@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:54244 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755465Ab1I3KkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2011 06:40:03 -0400
Content-Disposition: inline
In-Reply-To: <20110930103604.GA26727@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/usb/rtl8150.c |  111 ++++++++++++++++++++-------------------------
 1 files changed, 50 insertions(+), 61 deletions(-)

diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index b00d692..bf8c84d 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -169,26 +169,8 @@ struct rtl8150 {
 
 typedef struct rtl8150 rtl8150_t;
 
-static void fill_skb_pool(rtl8150_t *);
-static void free_skb_pool(rtl8150_t *);
-static inline struct sk_buff *pull_skb(rtl8150_t *);
-static void rtl8150_disconnect(struct usb_interface *intf);
-static int rtl8150_probe(struct usb_interface *intf,
-			   const struct usb_device_id *id);
-static int rtl8150_suspend(struct usb_interface *intf, pm_message_t message);
-static int rtl8150_resume(struct usb_interface *intf);
-
 static const char driver_name [] = "rtl8150";
 
-static struct usb_driver rtl8150_driver = {
-	.name =		driver_name,
-	.probe =	rtl8150_probe,
-	.disconnect =	rtl8150_disconnect,
-	.id_table =	rtl8150_table,
-	.suspend =	rtl8150_suspend,
-	.resume =	rtl8150_resume
-};
-
 /*
 **
 **	device related part of the code
@@ -333,7 +315,7 @@ static int rtl8150_set_mac_address(struct net_device *netdev, void *p)
 	/* Write the MAC address into eeprom. Eeprom writes must be word-sized,
 	   so we need to split them up. */
 	for (i = 0; i * 2 < netdev->addr_len; i++) {
-		set_registers(dev, IDR_EEPROM + (i * 2), 2, 
+		set_registers(dev, IDR_EEPROM + (i * 2), 2,
 		netdev->dev_addr + (i * 2));
 	}
 	/* Clear the WEPROM bit (preventing accidental eeprom writes). */
@@ -490,44 +472,6 @@ resched:
 	tasklet_schedule(&dev->tl);
 }
 
-static void rx_fixup(unsigned long data)
-{
-	rtl8150_t *dev;
-	struct sk_buff *skb;
-	int status;
-
-	dev = (rtl8150_t *)data;
-
-	spin_lock_irq(&dev->rx_pool_lock);
-	fill_skb_pool(dev);
-	spin_unlock_irq(&dev->rx_pool_lock);
-	if (test_bit(RX_URB_FAIL, &dev->flags))
-		if (dev->rx_skb)
-			goto try_again;
-	spin_lock_irq(&dev->rx_pool_lock);
-	skb = pull_skb(dev);
-	spin_unlock_irq(&dev->rx_pool_lock);
-	if (skb == NULL)
-		goto tlsched;
-	dev->rx_skb = skb;
-	usb_fill_bulk_urb(dev->rx_urb, dev->udev, usb_rcvbulkpipe(dev->udev, 1),
-		      dev->rx_skb->data, RTL8150_MTU, read_bulk_callback, dev);
-try_again:
-	status = usb_submit_urb(dev->rx_urb, GFP_ATOMIC);
-	if (status == -ENODEV) {
-		netif_device_detach(dev->netdev);
-	} else if (status) {
-		set_bit(RX_URB_FAIL, &dev->flags);
-		goto tlsched;
-	} else {
-		clear_bit(RX_URB_FAIL, &dev->flags);
-	}
-
-	return;
-tlsched:
-	tasklet_schedule(&dev->tl);
-}
-
 static void write_bulk_callback(struct urb *urb)
 {
 	rtl8150_t *dev;
@@ -665,6 +609,42 @@ static void free_skb_pool(rtl8150_t *dev)
 			dev_kfree_skb(dev->rx_skb_pool[i]);
 }
 
+static void rx_fixup(unsigned long data)
+{
+	struct rtl8150 *dev = (struct rtl8150 *)data;
+	struct sk_buff *skb;
+	int status;
+
+	spin_lock_irq(&dev->rx_pool_lock);
+	fill_skb_pool(dev);
+	spin_unlock_irq(&dev->rx_pool_lock);
+	if (test_bit(RX_URB_FAIL, &dev->flags))
+		if (dev->rx_skb)
+			goto try_again;
+	spin_lock_irq(&dev->rx_pool_lock);
+	skb = pull_skb(dev);
+	spin_unlock_irq(&dev->rx_pool_lock);
+	if (skb == NULL)
+		goto tlsched;
+	dev->rx_skb = skb;
+	usb_fill_bulk_urb(dev->rx_urb, dev->udev, usb_rcvbulkpipe(dev->udev, 1),
+		      dev->rx_skb->data, RTL8150_MTU, read_bulk_callback, dev);
+try_again:
+	status = usb_submit_urb(dev->rx_urb, GFP_ATOMIC);
+	if (status == -ENODEV) {
+		netif_device_detach(dev->netdev);
+	} else if (status) {
+		set_bit(RX_URB_FAIL, &dev->flags);
+		goto tlsched;
+	} else {
+		clear_bit(RX_URB_FAIL, &dev->flags);
+	}
+
+	return;
+tlsched:
+	tasklet_schedule(&dev->tl);
+}
+
 static int enable_net_traffic(rtl8150_t * dev)
 {
 	u8 cr, tcr, rcr, msr;
@@ -778,7 +758,7 @@ static int rtl8150_open(struct net_device *netdev)
 		return -ENOMEM;
 
 	set_registers(dev, IDR, 6, netdev->dev_addr);
-	
+
 	usb_fill_bulk_urb(dev->rx_urb, dev->udev, usb_rcvbulkpipe(dev->udev, 1),
 		      dev->rx_skb->data, RTL8150_MTU, read_bulk_callback, dev);
 	if ((res = usb_submit_urb(dev->rx_urb, GFP_KERNEL))) {
@@ -898,7 +878,7 @@ static const struct net_device_ops rtl8150_netdev_ops = {
 	.ndo_stop		= rtl8150_close,
 	.ndo_do_ioctl		= rtl8150_ioctl,
 	.ndo_start_xmit		= rtl8150_start_xmit,
-	.ndo_tx_timeout 	= rtl8150_tx_timeout,
+	.ndo_tx_timeout		= rtl8150_tx_timeout,
 	.ndo_set_rx_mode	= rtl8150_set_multicast,
 	.ndo_set_mac_address	= rtl8150_set_mac_address,
 
@@ -929,7 +909,7 @@ static int rtl8150_probe(struct usb_interface *intf,
 
 	tasklet_init(&dev->tl, rx_fixup, (unsigned long)dev);
 	spin_lock_init(&dev->rx_pool_lock);
-	
+
 	dev->udev = udev;
 	dev->netdev = netdev;
 	netdev->netdev_ops = &rtl8150_netdev_ops;
@@ -947,7 +927,7 @@ static int rtl8150_probe(struct usb_interface *intf,
 	}
 	fill_skb_pool(dev);
 	set_ethernet_addr(dev);
-	
+
 	usb_set_intfdata(intf, dev);
 	SET_NETDEV_DEV(netdev, &intf->dev);
 	if (register_netdev(netdev) != 0) {
@@ -989,6 +969,15 @@ static void rtl8150_disconnect(struct usb_interface *intf)
 	}
 }
 
+static struct usb_driver rtl8150_driver = {
+	.name		= driver_name,
+	.probe		= rtl8150_probe,
+	.disconnect	= rtl8150_disconnect,
+	.id_table	= rtl8150_table,
+	.suspend	= rtl8150_suspend,
+	.resume		= rtl8150_resume
+};
+
 static int __init usb_rtl8150_init(void)
 {
 	printk(KERN_INFO KBUILD_MODNAME ": " DRIVER_VERSION ":"
-- 
1.7.6.2
