From: Hemant Kumar <hemantk@codeaurora.org>
Subject: [PATCH] net: usb: Fix memory leak on Tx data path
Date: Thu, 25 Oct 2012 21:17:54 -0700
Message-ID: <1351225074-2078-1-git-send-email-hemantk@codeaurora.org>
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-msm@vger.kernel.org,
	Hemant Kumar <hemantk@codeaurora.org>
To: oneukum@suse.de
Return-path: <linux-arm-msm-owner@vger.kernel.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Driver anchors the tx urbs and defers the urb submission if
a transmit request comes when the interface is suspended.
Anchoring urb increments the urb reference count. These
deferred urbs are later accessed by calling usb_get_from_anchor()
for submission during interface resume. usb_get_from_anchor()
unanchors the urb but urb reference count remains same.
This causes the urb reference count to remain non-zero
after usb_free_urb() gets called and urb never gets freed.
Hence call usb_put_urb() after anchoring the urb to properly
balance the reference count for these deferred urbs. Also,
unanchor these deferred urbs during disconnect, to free them
up.

Signed-off-by: Hemant Kumar <hemantk@codeaurora.org>
---
 drivers/net/usb/usbnet.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 1867fe2..00b7598 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1168,6 +1168,7 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 		usb_anchor_urb(urb, &dev->deferred);
 		/* no use to process more packets */
 		netif_stop_queue(net);
+		usb_put_urb(urb);
 		spin_unlock_irqrestore(&dev->txq.lock, flags);
 		netdev_dbg(dev->net, "Delaying transmission for resumption\n");
 		goto deferred;
@@ -1317,6 +1318,8 @@ void usbnet_disconnect (struct usb_interface *intf)
 
 	cancel_work_sync(&dev->kevent);
 
+	usb_scuttle_anchored_urbs(&dev->deferred);
+
 	if (dev->driver_info->unbind)
 		dev->driver_info->unbind (dev, intf);
 
-- 
The Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, hosted by The Linux Foundation
