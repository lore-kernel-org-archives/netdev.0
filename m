From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [RFT] lan78xx: FIX use-after-free in lan78xx_write_reg
Date: Wed, 27 Sep 2017 16:48:24 +0530
Message-ID: <d7710b468c6c1b9cf3b3fe2fc986118a2cd2639a.1506510873.git.arvind.yadav.cs@gmail.com>
Cc: linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
        syzkaller@googlegroups.com
To: davem@davemloft.net, woojung.huh@microchip.com,
        UNGLinuxDriver@microchip.com, netdev@vger.kernel.org,
        andreyknvl@google.com, kcc@google.com, dvyukov@google.com,
        Nisar.Sayed@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We are not releasing 'buf' memory on failure or disconnect a device.

Adding 'u8 *buf' as part of 'lan78xx_net' structure to make proper
handle for 'buf'.
Now releasing 'buf' memory on failure. It's allocate first in
lan78xx_probe() and it should be freed last in lan78xx_disconnect().

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 drivers/net/usb/lan78xx.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/usb/lan78xx.c b/drivers/net/usb/lan78xx.c
index b99a7fb..e653982 100644
--- a/drivers/net/usb/lan78xx.c
+++ b/drivers/net/usb/lan78xx.c
@@ -402,6 +402,7 @@ struct lan78xx_net {
 	struct statstage	stats;
 
 	struct irq_domain_data	domain_data;
+	u8 *buf;
 };
 
 /* define external phy id */
@@ -3470,6 +3471,9 @@ static void lan78xx_disconnect(struct usb_interface *intf)
 
 	usb_scuttle_anchored_urbs(&dev->deferred);
 
+	kfree(dev->buf);
+	dev->buf = NULL;
+
 	lan78xx_unbind(dev, intf);
 
 	usb_kill_urb(dev->urb_intr);
@@ -3520,7 +3524,6 @@ static int lan78xx_probe(struct usb_interface *intf,
 	int ret;
 	unsigned maxp;
 	unsigned period;
-	u8 *buf = NULL;
 
 	udev = interface_to_usbdev(intf);
 	udev = usb_get_dev(udev);
@@ -3588,16 +3591,15 @@ static int lan78xx_probe(struct usb_interface *intf,
 	period = dev->ep_intr->desc.bInterval;
 
 	maxp = usb_maxpacket(dev->udev, dev->pipe_intr, 0);
-	buf = kmalloc(maxp, GFP_KERNEL);
-	if (buf) {
+	dev->buf = kmalloc(maxp, GFP_KERNEL);
+	if (dev->buf) {
 		dev->urb_intr = usb_alloc_urb(0, GFP_KERNEL);
 		if (!dev->urb_intr) {
 			ret = -ENOMEM;
-			kfree(buf);
 			goto out3;
 		} else {
 			usb_fill_int_urb(dev->urb_intr, dev->udev,
-					 dev->pipe_intr, buf, maxp,
+					 dev->pipe_intr, dev->buf, maxp,
 					 intr_complete, dev, period);
 		}
 	}
@@ -3626,6 +3628,8 @@ static int lan78xx_probe(struct usb_interface *intf,
 	return 0;
 
 out3:
+	kfree(dev->buf);
+	dev->buf = NULL;
 	lan78xx_unbind(dev, intf);
 out2:
 	free_netdev(netdev);
-- 
1.9.1
