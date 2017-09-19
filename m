From: Douglas Anderson <dianders@chromium.org>
Subject: [RFC PATCH 2/3] usbnet: Avoid potential races in usbnet_deferred_kevent()
Date: Tue, 19 Sep 2017 09:15:21 -0700
Message-ID: <20170919161522.995-2-dianders@chromium.org>
References: <20170919161522.995-1-dianders@chromium.org>
Cc: groeck@chromium.org, grundler@chromium.org,
        Douglas Anderson <dianders@chromium.org>,
        netdev@vger.kernel.org, linux-usb@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Oliver Neukum <oneukum@suse.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170919161522.995-1-dianders@chromium.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In general when you've got a flag communicating that "something needs
to be done" you want to clear that flag _before_ doing the task.  If
you clear the flag _after_ doing the task you end up with the risk
that this will happen:

1. Requester sets flag saying task A needs to be done.
2. Worker comes and stars doing task A.
3. Worker finishes task A but hasn't yet cleared the flag.
4. Requester wants to set flag saying task A needs to be done again.
5. Worker clears the flag without doing anything.

Let's make the usbnet codebase consistently clear the flag _before_ it
does the requested work.  That way if there's another request to do
the work while the work is already in progress it won't be lost.

NOTES:
- No known bugs are fixed by this; it's just found by code inspection.
- This changes the semantics in some of the error conditions.
  -> If we fail to clear the "tx halt" or "rx halt" we still clear the
     flag and thus won't retry the clear next time we happen to be in
     the work function.  Had the old code really wanted to retry these
     events it should have re-scheduled the worker anyway.
  -> If we fail to allocate memory in usb_alloc_urb() we will still
     clear the EVENT_RX_MEMORY flag.  This makes it consistent with
     how we would deal with other failures, including failure to
     allocate a memory chunk in rx_submit().  It can also be noted
     that usb_alloc_urb() in this case is allocating much less than 4K
     worth of data and probably never fails.

Signed-off-by: Douglas Anderson <dianders@chromium.org>
---

 drivers/net/usb/usbnet.c | 50 +++++++++++++++++++++---------------------------
 1 file changed, 22 insertions(+), 28 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index a3e8dbaadcf9..e72547d8d0e6 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1103,8 +1103,6 @@ static void __handle_link_change(struct usbnet *dev)
 
 	/* hard_mtu or rx_urb_size may change during link change */
 	usbnet_update_max_qlen(dev);
-
-	clear_bit(EVENT_LINK_CHANGE, &dev->flags);
 }
 
 static void usbnet_set_rx_mode(struct net_device *net)
@@ -1118,8 +1116,6 @@ static void __handle_set_rx_mode(struct usbnet *dev)
 {
 	if (dev->driver_info->set_rx_mode)
 		(dev->driver_info->set_rx_mode)(dev);
-
-	clear_bit(EVENT_SET_RX_MODE, &dev->flags);
 }
 
 /* work that cannot be done in interrupt context uses keventd.
@@ -1135,7 +1131,7 @@ usbnet_deferred_kevent (struct work_struct *work)
 	int			status;
 
 	/* usb_clear_halt() needs a thread context */
-	if (test_bit (EVENT_TX_HALT, &dev->flags)) {
+	if (test_and_clear_bit (EVENT_TX_HALT, &dev->flags)) {
 		unlink_urbs (dev, &dev->txq);
 		status = usb_autopm_get_interface(dev->intf);
 		if (status < 0)
@@ -1150,12 +1146,11 @@ usbnet_deferred_kevent (struct work_struct *work)
 				netdev_err(dev->net, "can't clear tx halt, status %d\n",
 					   status);
 		} else {
-			clear_bit (EVENT_TX_HALT, &dev->flags);
 			if (status != -ESHUTDOWN)
 				netif_wake_queue (dev->net);
 		}
 	}
-	if (test_bit (EVENT_RX_HALT, &dev->flags)) {
+	if (test_and_clear_bit (EVENT_RX_HALT, &dev->flags)) {
 		unlink_urbs (dev, &dev->rxq);
 		status = usb_autopm_get_interface(dev->intf);
 		if (status < 0)
@@ -1170,41 +1165,39 @@ usbnet_deferred_kevent (struct work_struct *work)
 				netdev_err(dev->net, "can't clear rx halt, status %d\n",
 					   status);
 		} else {
-			clear_bit (EVENT_RX_HALT, &dev->flags);
 			tasklet_schedule (&dev->bh);
 		}
 	}
 
 	/* tasklet could resubmit itself forever if memory is tight */
-	if (test_bit (EVENT_RX_MEMORY, &dev->flags)) {
+	if (test_and_clear_bit (EVENT_RX_MEMORY, &dev->flags)) {
 		struct urb	*urb = NULL;
 		int resched = 1;
 
-		if (netif_running (dev->net))
+		if (netif_running (dev->net)) {
 			urb = usb_alloc_urb (0, GFP_KERNEL);
-		else
-			clear_bit (EVENT_RX_MEMORY, &dev->flags);
-		if (urb != NULL) {
-			clear_bit (EVENT_RX_MEMORY, &dev->flags);
-			status = usb_autopm_get_interface(dev->intf);
-			if (status < 0) {
-				usb_free_urb(urb);
-				goto fail_lowmem;
-			}
-			if (rx_submit (dev, urb, GFP_KERNEL) == -ENOLINK)
-				resched = 0;
-			usb_autopm_put_interface(dev->intf);
+			if (urb != NULL) {
+				status = usb_autopm_get_interface(dev->intf);
+				if (status < 0) {
+					usb_free_urb(urb);
+					goto fail_lowmem;
+				}
+				if (rx_submit (dev, urb, GFP_KERNEL) ==
+				    -ENOLINK)
+					resched = 0;
+				usb_autopm_put_interface(dev->intf);
 fail_lowmem:
-			if (resched)
-				tasklet_schedule (&dev->bh);
+				if (resched)
+					tasklet_schedule (&dev->bh);
+			}
 		}
+
 	}
 
-	if (test_bit (EVENT_LINK_RESET, &dev->flags)) {
+	if (test_and_clear_bit (EVENT_LINK_RESET, &dev->flags)) {
 		struct driver_info	*info = dev->driver_info;
 		int			retval = 0;
 
-		clear_bit (EVENT_LINK_RESET, &dev->flags);
 		status = usb_autopm_get_interface(dev->intf);
 		if (status < 0)
 			goto skip_reset;
@@ -1221,13 +1214,14 @@ usbnet_deferred_kevent (struct work_struct *work)
 		}
 
 		/* handle link change from link resetting */
+		clear_bit(EVENT_LINK_CHANGE, &dev->flags);
 		__handle_link_change(dev);
 	}
 
-	if (test_bit (EVENT_LINK_CHANGE, &dev->flags))
+	if (test_and_clear_bit (EVENT_LINK_CHANGE, &dev->flags))
 		__handle_link_change(dev);
 
-	if (test_bit (EVENT_SET_RX_MODE, &dev->flags))
+	if (test_and_clear_bit (EVENT_SET_RX_MODE, &dev->flags))
 		__handle_set_rx_mode(dev);
 
 
-- 
2.14.1.690.gbb1197296e-goog
