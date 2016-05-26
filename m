From: Christoph Fritz <chf.fritz@googlemail.com>
Subject: usbnet: smsc95xx: fix link detection for disabled autonegotiation
Date: Thu, 26 May 2016 04:06:47 +0200
Message-ID: <1464228407.5421.34.camel@googlemail.com>
Reply-To: chf.fritz@googlemail.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Steve Glendinning <steve.glendinning@shawell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36504 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752668AbcEZCGu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 May 2016 22:06:50 -0400
Received: by mail-wm0-f66.google.com with SMTP id q62so728876wmg.3
        for <netdev@vger.kernel.org>; Wed, 25 May 2016 19:06:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To detect link status up/down for connections where autonegotiation is
explicitly disabled, we don't get an irq but need to poll the status
register for link up/down detection.
This patch adds a workqueue to poll for link status.

Signed-off-by: Christoph Fritz <chf.fritz@googlemail.com>
---
 drivers/net/usb/smsc95xx.c | 51 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 51 insertions(+)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index d9d2806..dc989a8 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -61,6 +61,8 @@
 #define SUSPEND_ALLMODES		(SUSPEND_SUSPEND0 | SUSPEND_SUSPEND1 | \
 					 SUSPEND_SUSPEND2 | SUSPEND_SUSPEND3)
 
+#define CARRIER_CHECK_DELAY (2 * HZ)
+
 struct smsc95xx_priv {
 	u32 mac_cr;
 	u32 hash_hi;
@@ -69,6 +71,9 @@ struct smsc95xx_priv {
 	spinlock_t mac_cr_lock;
 	u8 features;
 	u8 suspend_flags;
+	bool link_ok;
+	struct delayed_work carrier_check;
+	struct usbnet *dev;
 };
 
 static bool turbo_mode = true;
@@ -624,6 +629,44 @@ static void smsc95xx_status(struct usbnet *dev, struct urb *urb)
 			    intdata);
 }
 
+static void set_carrier(struct usbnet *dev, bool link)
+{
+	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
+
+	if (pdata->link_ok == link)
+		return;
+
+	pdata->link_ok = link;
+
+	if (link)
+		usbnet_link_change(dev, 1, 0);
+	else
+		usbnet_link_change(dev, 0, 0);
+}
+
+static void check_carrier(struct work_struct *work)
+{
+	struct smsc95xx_priv *pdata = container_of(work, struct smsc95xx_priv,
+						carrier_check.work);
+	struct usbnet *dev = pdata->dev;
+	int ret;
+
+	if (pdata->suspend_flags != 0)
+		return;
+
+	ret = smsc95xx_mdio_read(dev->net, dev->mii.phy_id, MII_BMSR);
+	if (ret < 0) {
+		netdev_warn(dev->net, "Failed to read MII_BMSR\n");
+		return;
+	}
+	if (ret & BMSR_LSTATUS)
+		set_carrier(dev, 1);
+	else
+		set_carrier(dev, 0);
+
+	schedule_delayed_work(&pdata->carrier_check, CARRIER_CHECK_DELAY);
+}
+
 /* Enable or disable Tx & Rx checksum offload engines */
 static int smsc95xx_set_features(struct net_device *netdev,
 	netdev_features_t features)
@@ -1165,13 +1208,20 @@ static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
 	dev->net->flags |= IFF_MULTICAST;
 	dev->net->hard_header_len += SMSC95XX_TX_OVERHEAD_CSUM;
 	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
+
+	pdata->dev = dev;
+	INIT_DELAYED_WORK(&pdata->carrier_check, check_carrier);
+	schedule_delayed_work(&pdata->carrier_check, CARRIER_CHECK_DELAY);
+
 	return 0;
 }
 
 static void smsc95xx_unbind(struct usbnet *dev, struct usb_interface *intf)
 {
 	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
+
 	if (pdata) {
+		cancel_delayed_work(&pdata->carrier_check);
 		netif_dbg(dev, ifdown, dev->net, "free pdata\n");
 		kfree(pdata);
 		pdata = NULL;
@@ -1695,6 +1745,7 @@ static int smsc95xx_resume(struct usb_interface *intf)
 
 	/* do this first to ensure it's cleared even in error case */
 	pdata->suspend_flags = 0;
+	schedule_delayed_work(&pdata->carrier_check, CARRIER_CHECK_DELAY);
 
 	if (suspend_flags & SUSPEND_ALLMODES) {
 		/* clear wake-up sources */
-- 
2.1.4
