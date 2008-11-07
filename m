From: David Brownell <david-b@pacbell.net>
Subject: [patch 2.6.28-rc3-git] pegasus: minor resource shrinkage
Date: Fri, 7 Nov 2008 14:34:07 -0800
Message-ID: <200811071434.08047.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>
To: Network development list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp124.sbc.mail.sp1.yahoo.com ([69.147.64.97]:21833 "HELO
	smtp124.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751636AbYKGWeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 17:34:10 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Brownell <dbrownell@users.sourceforge.net>

Make pegasus driver not allocate a workqueue until the driver
is bound to some device, which will need that workqueue if
the device is brought up.  This conserves resources when the
driver is linked but there's no pegasus device connected.

Also shrink the runtime footprint a smidgeon by moving some
init-only code into its proper section, and move an obnoxious
(frequent and meaningless) message to be debug-only.

Signed-off-by: David Brownell <dbrownell@users.sourceforge.net>
---
 drivers/net/usb/pegasus.c |   36 ++++++++++++++++++++++++++----------
 1 file changed, 26 insertions(+), 10 deletions(-)

--- a/drivers/net/usb/pegasus.c
+++ b/drivers/net/usb/pegasus.c
@@ -1213,7 +1213,7 @@ static void pegasus_set_multicast(struct
 		pegasus->eth_regs[EthCtrl0] |= RX_MULTICAST;
 		pegasus->eth_regs[EthCtrl2] &= ~RX_PROMISCUOUS;
 		if (netif_msg_link(pegasus))
-			pr_info("%s: set allmulti\n", net->name);
+			pr_debug("%s: set allmulti\n", net->name);
 	} else {
 		pegasus->eth_regs[EthCtrl0] &= ~RX_MULTICAST;
 		pegasus->eth_regs[EthCtrl2] &= ~RX_PROMISCUOUS;
@@ -1273,6 +1273,7 @@ static inline void setup_pegasus_II(pega
 }
 
 
+static int pegasus_count;
 static struct workqueue_struct *pegasus_workqueue = NULL;
 #define CARRIER_CHECK_DELAY (2 * HZ)
 
@@ -1301,6 +1302,18 @@ static int pegasus_blacklisted(struct us
 	return 0;
 }
 
+/* we rely on probe() and remove() being serialized so we
+ * don't need extra locking on pegasus_count.
+ */
+static void pegasus_dec_workqueue(void)
+{
+	pegasus_count--;
+	if (pegasus_count == 0) {
+		destroy_workqueue(pegasus_workqueue);
+		pegasus_workqueue = NULL;
+	}
+}
+
 static int pegasus_probe(struct usb_interface *intf,
 			 const struct usb_device_id *id)
 {
@@ -1311,12 +1324,17 @@ static int pegasus_probe(struct usb_inte
 	int res = -ENOMEM;
 	DECLARE_MAC_BUF(mac);
 
-	usb_get_dev(dev);
+	if (pegasus_blacklisted(dev))
+		return -ENODEV;
 
-	if (pegasus_blacklisted(dev)) {
-		res = -ENODEV;
-		goto out;
+	if (pegasus_count == 0) {
+		pegasus_workqueue = create_singlethread_workqueue("pegasus");
+		if (!pegasus_workqueue)
+			return -ENOMEM;
 	}
+	pegasus_count++;
+
+	usb_get_dev(dev);
 
 	net = alloc_etherdev(sizeof(struct pegasus));
 	if (!net) {
@@ -1401,6 +1419,7 @@ out1:
 	free_netdev(net);
 out:
 	usb_put_dev(dev);
+	pegasus_dec_workqueue();
 	return res;
 }
 
@@ -1426,6 +1445,7 @@ static void pegasus_disconnect(struct us
 		pegasus->rx_skb = NULL;
 	}
 	free_netdev(pegasus->net);
+	pegasus_dec_workqueue();
 }
 
 static int pegasus_suspend (struct usb_interface *intf, pm_message_t message)
@@ -1469,7 +1489,7 @@ static struct usb_driver pegasus_driver 
 	.resume = pegasus_resume,
 };
 
-static void parse_id(char *id)
+static void __init parse_id(char *id)
 {
 	unsigned int vendor_id=0, device_id=0, flags=0, i=0;
 	char *token, *name=NULL;
@@ -1505,15 +1525,11 @@ static int __init pegasus_init(void)
 	pr_info("%s: %s, " DRIVER_DESC "\n", driver_name, DRIVER_VERSION);
 	if (devid)
 		parse_id(devid);
-	pegasus_workqueue = create_singlethread_workqueue("pegasus");
-	if (!pegasus_workqueue)
-		return -ENOMEM;
 	return usb_register(&pegasus_driver);
 }
 
 static void __exit pegasus_exit(void)
 {
-	destroy_workqueue(pegasus_workqueue);
 	usb_deregister(&pegasus_driver);
 }
 
