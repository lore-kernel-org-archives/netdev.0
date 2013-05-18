From: Petko Manolov <petkan@nucleusys.com>
Subject: [PATCH 3/5] drivers: net: usb: rtl8150: bug fixing and cleanup
Date: Sat, 18 May 2013 19:24:16 +0300 (EEST)
Message-ID: <alpine.DEB.2.02.1305181904110.7518@fry.nucleusys.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Petko Manolov <petkan@nucleusys.com>

removing socket buffer pre-allocation pool;

Signed-off-by: Petko Manolov <petkan@nucleusys.com>
---
 drivers/net/usb/rtl8150.c |   60 +++--------------------------------
 drivers/net/usb/rtl8150.h |    3 --
 2 files changed, 5 insertions(+), 58 deletions(-)

diff --git a/drivers/net/usb/rtl8150.c b/drivers/net/usb/rtl8150.c
index 7d1897b..fd4bc2a 100644
--- a/drivers/net/usb/rtl8150.c
+++ b/drivers/net/usb/rtl8150.c
@@ -240,21 +240,6 @@ static void unlink_all_urbs(rtl8150_t * dev)
 	usb_kill_urb(dev->ctrl_urb);
 }
 
-static inline struct sk_buff *pull_skb(rtl8150_t *dev)
-{
-	struct sk_buff *skb;
-	int i;
-
-	for (i = 0; i < RX_SKB_POOL_SIZE; i++) {
-		if (dev->rx_skb_pool[i]) {
-			skb = dev->rx_skb_pool[i];
-			dev->rx_skb_pool[i] = NULL;
-			return skb;
-		}
-	}
-	return NULL;
-}
-
 static void read_bulk_callback(struct urb *urb)
 {
 	rtl8150_t *dev;
@@ -305,9 +290,7 @@ static void read_bulk_callback(struct urb *urb)
 	netdev->stats.rx_packets++;
 	netdev->stats.rx_bytes += pkt_len;
 
-	spin_lock(&dev->rx_pool_lock);
-	skb = pull_skb(dev);
-	spin_unlock(&dev->rx_pool_lock);
+	skb = __netdev_alloc_skb_ip_align(dev->netdev, RTL8150_MTU, GFP_ATOMIC);
 	if (!skb)
 		goto resched;
 
@@ -441,47 +424,16 @@ static int rtl8150_resume(struct usb_interface *intf)
 **
 */
 
-static void fill_skb_pool(rtl8150_t *dev)
-{
-	struct sk_buff *skb;
-	int i;
-
-	for (i = 0; i < RX_SKB_POOL_SIZE; i++) {
-		if (dev->rx_skb_pool[i])
-			continue;
-		skb = dev_alloc_skb(RTL8150_MTU + 2);
-		if (!skb) {
-			return;
-		}
-		skb_reserve(skb, 2);
-		dev->rx_skb_pool[i] = skb;
-	}
-}
-
-static void free_skb_pool(rtl8150_t *dev)
-{
-	int i;
-
-	for (i = 0; i < RX_SKB_POOL_SIZE; i++)
-		if (dev->rx_skb_pool[i])
-			dev_kfree_skb(dev->rx_skb_pool[i]);
-}
-
 static void rx_fixup(unsigned long data)
 {
 	struct rtl8150 *dev = (struct rtl8150 *)data;
 	struct sk_buff *skb;
 	int status;
 
-	spin_lock_irq(&dev->rx_pool_lock);
-	fill_skb_pool(dev);
-	spin_unlock_irq(&dev->rx_pool_lock);
 	if (test_bit(RX_URB_FAIL, &dev->flags))
 		if (dev->rx_skb)
 			goto try_again;
-	spin_lock_irq(&dev->rx_pool_lock);
-	skb = pull_skb(dev);
-	spin_unlock_irq(&dev->rx_pool_lock);
+	skb = __netdev_alloc_skb_ip_align(dev->netdev, RTL8150_MTU, GFP_ATOMIC);
 	if (skb == NULL)
 		goto tlsched;
 	dev->rx_skb = skb;
@@ -611,7 +563,9 @@ static int rtl8150_open(struct net_device *netdev)
 	int res;
 
 	if (dev->rx_skb == NULL)
-		dev->rx_skb = pull_skb(dev);
+		dev->rx_skb = __netdev_alloc_skb_ip_align(dev->netdev,
+							  RTL8150_MTU,
+							  GFP_ATOMIC);
 	if (!dev->rx_skb)
 		return -ENOMEM;
 
@@ -764,7 +718,6 @@ static int rtl8150_probe(struct usb_interface *intf,
 	}
 
 	tasklet_init(&dev->tl, rx_fixup, (unsigned long)dev);
-	spin_lock_init(&dev->rx_pool_lock);
 
 	dev->udev = udev;
 	dev->netdev = netdev;
@@ -781,7 +734,6 @@ static int rtl8150_probe(struct usb_interface *intf,
 		dev_err(&intf->dev, "couldn't reset the device\n");
 		goto out1;
 	}
-	fill_skb_pool(dev);
 	set_ethernet_addr(dev);
 
 	usb_set_intfdata(intf, dev);
@@ -797,7 +749,6 @@ static int rtl8150_probe(struct usb_interface *intf,
 
 out2:
 	usb_set_intfdata(intf, NULL);
-	free_skb_pool(dev);
 out1:
 	free_all_urbs(dev);
 out:
@@ -817,7 +768,6 @@ static void rtl8150_disconnect(struct usb_interface *intf)
 		unregister_netdev(dev->netdev);
 		unlink_all_urbs(dev);
 		free_all_urbs(dev);
-		free_skb_pool(dev);
 		if (dev->rx_skb)
 			dev_kfree_skb(dev->rx_skb);
 		kfree(dev->intr_buff);
diff --git a/drivers/net/usb/rtl8150.h b/drivers/net/usb/rtl8150.h
index cfb1e74..a29410c 100644
--- a/drivers/net/usb/rtl8150.h
+++ b/drivers/net/usb/rtl8150.h
@@ -75,7 +75,6 @@
 
 #define	RTL8150_MTU		1540
 #define	RTL8150_TX_TIMEOUT	(HZ)
-#define	RX_SKB_POOL_SIZE	4
 
 /* rtl8150 flags */
 #define	RTL8150_HW_CRC		0
@@ -117,8 +116,6 @@ struct rtl8150 {
 	struct net_device *netdev;
 	struct urb *rx_urb, *tx_urb, *intr_urb, *ctrl_urb;
 	struct sk_buff *tx_skb, *rx_skb;
-	struct sk_buff *rx_skb_pool[RX_SKB_POOL_SIZE];
-	spinlock_t rx_pool_lock;
 	struct usb_ctrlrequest dr;
 	int intr_interval;
 	__le16 rx_creg;
