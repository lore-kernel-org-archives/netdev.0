From: Olivier Sobrie <olivier@sobrie.be>
Subject: [PATCH 07/11] hso: replace reset_device work by usb_queue_reset_device()
Date: Tue, 20 Jan 2015 13:29:34 +0100
Message-ID: <1421756978-4093-8-git-send-email-olivier@sobrie.be>
References: <1421756978-4093-1-git-send-email-olivier@sobrie.be>
 <1421756978-4093-2-git-send-email-olivier@sobrie.be>
 <1421756978-4093-3-git-send-email-olivier@sobrie.be>
 <1421756978-4093-4-git-send-email-olivier@sobrie.be>
 <1421756978-4093-5-git-send-email-olivier@sobrie.be>
 <1421756978-4093-6-git-send-email-olivier@sobrie.be>
 <1421756978-4093-7-git-send-email-olivier@sobrie.be>
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Olivier Sobrie <olivier@sobrie.be>
To: Jan Dumon <j.dumon@option.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421756978-4093-7-git-send-email-olivier@sobrie.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is no need for a dedicated reset work in the hso driver since
there is already a reset work foreseen in usb_interface that does
the same.

Signed-off-by: Olivier Sobrie <olivier@sobrie.be>
---
 drivers/net/usb/hso.c | 25 +------------------------
 1 file changed, 1 insertion(+), 24 deletions(-)

diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 484e423..55074da 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -274,7 +274,6 @@ struct hso_device {
 	u8 usb_gone;
 	struct work_struct async_get_intf;
 	struct work_struct async_put_intf;
-	struct work_struct reset_device;
 
 	struct usb_device *usb;
 	struct usb_interface *interface;
@@ -340,7 +339,6 @@ static void async_put_intf(struct work_struct *data);
 static int hso_put_activity(struct hso_device *hso_dev);
 static int hso_get_activity(struct hso_device *hso_dev);
 static void tiocmget_intr_callback(struct urb *urb);
-static void reset_device(struct work_struct *data);
 /*****************************************************************************/
 /* Helping functions                                                         */
 /*****************************************************************************/
@@ -696,7 +694,7 @@ static void handle_usb_error(int status, const char *function,
 	case -ETIMEDOUT:
 		explanation = "protocol error";
 		if (hso_dev)
-			schedule_work(&hso_dev->reset_device);
+			usb_queue_reset_device(hso_dev->interface);
 		break;
 	default:
 		explanation = "unknown status";
@@ -2347,7 +2345,6 @@ static struct hso_device *hso_create_device(struct usb_interface *intf,
 
 	INIT_WORK(&hso_dev->async_get_intf, async_get_intf);
 	INIT_WORK(&hso_dev->async_put_intf, async_put_intf);
-	INIT_WORK(&hso_dev->reset_device, reset_device);
 
 	return hso_dev;
 }
@@ -3086,26 +3083,6 @@ out:
 	return result;
 }
 
-static void reset_device(struct work_struct *data)
-{
-	struct hso_device *hso_dev =
-	    container_of(data, struct hso_device, reset_device);
-	struct usb_device *usb = hso_dev->usb;
-	int result;
-
-	if (hso_dev->usb_gone) {
-		D1("No reset during disconnect\n");
-	} else {
-		result = usb_lock_device_for_reset(usb, hso_dev->interface);
-		if (result < 0)
-			D1("unable to lock device for reset: %d\n", result);
-		else {
-			usb_reset_device(usb);
-			usb_unlock_device(usb);
-		}
-	}
-}
-
 static void hso_serial_ref_free(struct kref *ref)
 {
 	struct hso_device *hso_dev = container_of(ref, struct hso_device, ref);
-- 
2.2.0
