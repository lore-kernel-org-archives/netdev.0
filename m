From: Shahin Ghazinouri <shahin.ghazinouri@pelagicore.com>
Subject: Possible to support usbnet device with two IN endpoints?
Date: Thu, 19 Feb 2015 13:53:40 +0100
Message-ID: <CAKA7KT=4zndqSaPDj+szofMVtth01TbgyJ4uaWTDjO7yaw6=KQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:53437 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752472AbbBSMxl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 07:53:41 -0500
Received: by mail-qc0-f175.google.com with SMTP id b13so5973977qcw.6
        for <netdev@vger.kernel.org>; Thu, 19 Feb 2015 04:53:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
I'm developing a driver for a USB network device that filters received
network packets into two separate USB IN endpoints. This means a
second rx urb has to be allocated and submitted.

Right now, the implementation relies on patching usbnet.c (see below),
so that a second urb is allocated and rx_submit_fixup is called in
addition to rx_submit. This function is a copy of rx_submit, except it
submits an urb to receive data from the second endpoint.

Since I don't think this patch is a good idea, I would appreciate any
ideas on how to support a usbnet device with two IN endpoints within
the current framework.

Kind regards,
Shahin

diff -Naur a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
--- a/drivers/net/usb/usbnet.c 2014-11-03 21:49:29.000000000 +0100
+++ b/drivers/net/usb/usbnet.c 2014-11-05 11:13:37.824809365 +0100
@@ -1068,30 +1070,65 @@
  }
  }

- /* tasklet could resubmit itself forever if memory is tight */
- if (test_bit (EVENT_RX_MEMORY, &dev->flags)) {
- struct urb *urb = NULL;
- int resched = 1;
-
- if (netif_running (dev->net))
- urb = usb_alloc_urb (0, GFP_KERNEL);
- else
- clear_bit (EVENT_RX_MEMORY, &dev->flags);
- if (urb != NULL) {
- clear_bit (EVENT_RX_MEMORY, &dev->flags);
- status = usb_autopm_get_interface(dev->intf);
- if (status < 0) {
- usb_free_urb(urb);
- goto fail_lowmem;
- }
- if (rx_submit (dev, urb, GFP_KERNEL) == -ENOLINK)
- resched = 0;
- usb_autopm_put_interface(dev->intf);
+    if(!dev->driver_info->rx_submit_fixup)
+    {
+        /* tasklet could resubmit itself forever if memory is tight */
+        if (test_bit (EVENT_RX_MEMORY, &dev->flags)) {
+            struct urb *urb = NULL;
+            int resched = 1;
+
+            if (netif_running (dev->net))
+                urb = usb_alloc_urb (0, GFP_KERNEL);
+            else
+                clear_bit (EVENT_RX_MEMORY, &dev->flags);
+            if (urb != NULL) {
+                clear_bit (EVENT_RX_MEMORY, &dev->flags);
+                status = usb_autopm_get_interface(dev->intf);
+                if (status < 0) {
+                    usb_free_urb(urb);
+                    goto fail_lowmem;
+                }
+                if (rx_submit (dev, urb, GFP_KERNEL) == -ENOLINK)
+                    resched = 0;
+                usb_autopm_put_interface(dev->intf);
 fail_lowmem:
- if (resched)
- tasklet_schedule (&dev->bh);
- }
- }
+                if (resched)
+                    tasklet_schedule (&dev->bh);
+            }
+        }
+    }
+    else
+    {
+        /* tasklet could resubmit itself forever if memory is tight */
+        if (test_bit (EVENT_RX_MEMORY, &dev->flags)) {
+            struct urb *urb = NULL;
+            int resched = 1;
+            struct urb *aux_urb = NULL;
+            if (netif_running (dev->net))
+            {
+                urb = usb_alloc_urb (0, GFP_KERNEL);
+                aux_urb = usb_alloc_urb (0, GFP_KERNEL);
+            }
+            else
+                clear_bit (EVENT_RX_MEMORY, &dev->flags);
+            if ( (urb != NULL) && (aux_urb != NULL) ) {
+                clear_bit (EVENT_RX_MEMORY, &dev->flags);
+                status = usb_autopm_get_interface(dev->intf);
+                if (status < 0) {
+                    usb_free_urb(urb);
+                    usb_free_urb(aux_urb);
+                    goto fail_lowmem_1;
+                }
+                if ( (rx_submit (dev, urb, GFP_KERNEL) == -ENOLINK)
+                        || (dev->driver_info->rx_submit_fixup (dev,
aux_urb, GFP_KERNEL) == -ENOLINK) )
+                    resched = 0;
+                usb_autopm_put_interface(dev->intf);
+fail_lowmem_1:
+                if (resched)
+                    tasklet_schedule (&dev->bh);
+            }
+        }
+    }

  if (test_bit (EVENT_LINK_RESET, &dev->flags)) {
  struct driver_info *info = dev->driver_info;
@@ -1313,6 +1350,7 @@
  struct urb *urb;
  int i;
  int ret = 0;
+    struct urb *aux_urb;

  /* don't refill the queue all at once */
  for (i = 0; i < 10 && dev->rxq.qlen < RX_QLEN(dev); i++) {
@@ -1325,6 +1363,18 @@
  ret = -ENOMEM;
  goto err;
  }
+        if(dev->driver_info->rx_submit_fixup)
+        {
+            aux_urb = usb_alloc_urb(0, flags);
+            if (aux_urb != NULL) {
+                ret = dev->driver_info->rx_submit_fixup(dev, aux_urb, flags);
+                if (ret)
+                    goto err;
+            } else {
+                ret = -ENOMEM;
+                goto err;
+            }
+        }
  }
 err:
  return ret;
