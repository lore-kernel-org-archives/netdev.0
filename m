From: Vikas Bansal <vikas.bansal@samsung.com>
Subject: [PATCH] Adding Reset resume support for CDC-EEM driver.
Date: Mon, 21 Dec 2015 17:38:51 +0530
Message-ID: <1450699731-4666-1-git-send-email-vikas.bansal@samsung.com>
Cc: sumit.batra@samsung.com, Vikas Bansal <vikas.bansal@samsung.com>
To: oneukum@suse.de, netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pre-Condition
At the time of reset resume of a USB device, both self and bus powered devices might go to a low power state or power off state depending on the acceptable suspend time power of the system.    
In case the device experiences a power glitch or completely powers off during suspend-resume, the device will lose its internal state and hence it'll again need a set interface from class driver on reset resume operation.

Issue 
So far our experiments were based on a USB gadget working on cdc_eem protocol. 
We have seen that device is unable to continue the packet transfer on bulk endpoints after the reset resume operation.

Solution
We have added a .reset_resume function for cdc_eem protocol which sends a set interface command on the Control endpoint. And calls the existing usbnet_resume thereafter


Signed-off-by: Vikas Bansal <vikas.bansal@samsung.com>
Signed-off-by: Sumit Batra <sumit.batra@samsung.com>
diff --git a/drivers/net/usb/cdc_eem.c b/drivers/net/usb/cdc_eem.c
index f7180f8..1f6f7ea 100644
--- a/drivers/net/usb/cdc_eem.c
+++ b/drivers/net/usb/cdc_eem.c
@@ -342,6 +342,19 @@ next:
 	return 1;
 }
 
+static int cdc_eem_resume(struct usb_interface *intf)
+{
+	int ret = 0;
+	struct usbnet *dev = usb_get_intfdata(intf);
+
+	ret = usbnet_get_endpoints(dev, intf);
+	if(ret < 0)
+		goto err;
+	ret = usbnet_resume(intf);
+err:
+	return ret;
+}
+
 static const struct driver_info eem_info = {
 	.description =	"CDC EEM Device",
 	.flags =	FLAG_ETHER | FLAG_POINTTOPOINT,
@@ -371,6 +384,7 @@ static struct usb_driver eem_driver = {
 	.disconnect =	usbnet_disconnect,
 	.suspend =	usbnet_suspend,
 	.resume =	usbnet_resume,
+	.reset_resume =	cdc_eem_resume,
 	.disable_hub_initiated_lpm = 1,
 };
 
