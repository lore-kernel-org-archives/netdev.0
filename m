From: Huajun Li <huajun.li.lee@gmail.com>
Subject: Re: [PATCH] usbnet: Activate the halt interrupt endpoint to fix
 endless "XactErr" error
Date: Mon, 11 Jun 2012 22:41:03 +0800
Message-ID: <CA+v9cxaLERjFKdE7joGgmpbxCUotdh=Nn4F4f-KeOXwp8nqMPg@mail.gmail.com>
References: <CA+v9cxYHq4gcy11SDmsuHUhTSdLJM-G0sugYnOjSthbYWA+1Yg@mail.gmail.com>
	<20120607.145438.1351539405712214173.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Ming Lei <tom.leiming@gmail.com>,
	Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:34758 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752040Ab2FKOlE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 10:41:04 -0400
In-Reply-To: <20120607.145438.1351539405712214173.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 8, 2012 at 5:54 AM, David Miller <davem@davemloft.net> wrot=
e:
> From: Huajun Li <huajun.li.lee@gmail.com>
> Date: Tue, 5 Jun 2012 22:12:17 +0800
>
>> There prints endless "XactErr" error msg once switch my device to th=
e
>> configuration
>> =A0which needs cdc_ether driver, the root cause is the interrupt end=
point halts.
>> Maybe this is a common issue, so fix it by activating the endpoint
>> once the error occurs.
>>
>> Signed-off-by: Huajun Li <huajun.li.lee@gmail.com>
>
> A USB expert needs to review this as I lack the knowledge to adequate=
ly
> go over this patch.


Update the patch according to Ming and Alan's comments, it only
handles "-EPIPE" error of interrupt endpoint. Welcome comments:
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 9f58330..bd8ebef 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -537,6 +537,10 @@ static void intr_complete (struct urb *urb)
 			  "intr shutdown, code %d\n", status);
 		return;

+	case -EPIPE:
+		usbnet_defer_kevent(dev, EVENT_STS_HALT);
+		return;
+
 	/* NOTE:  not throttling like RX/TX, since this endpoint
 	 * already polls infrequently
 	 */
@@ -967,6 +971,33 @@ fail_halt:
 		}
 	}

+	if (test_bit(EVENT_STS_HALT, &dev->flags)) {
+		unsigned pipe;
+		struct usb_endpoint_descriptor *desc;
+
+		desc =3D &dev->status->desc;
+		pipe =3D usb_rcvintpipe(dev->udev,
+			desc->bEndpointAddress & USB_ENDPOINT_NUMBER_MASK);
+		status =3D usb_autopm_get_interface(dev->intf);
+		if (status < 0)
+			goto fail_sts;
+		status =3D usb_clear_halt(dev->udev, pipe);
+		if (status < 0) {
+			usb_autopm_put_interface(dev->intf);
+fail_sts:
+			netdev_err(dev->net,
+				"can't clear intr halt, status %d\n", status);
+		} else {
+			clear_bit(EVENT_STS_HALT, &dev->flags);
+			status =3D usb_submit_urb(dev->interrupt, GFP_KERNEL);
+			if (status !=3D 0)
+				netif_err(dev, timer, dev->net,
+					"intr resubmit --> %d\n", status);
+
+			usb_autopm_put_interface(dev->intf);
+		}
+	}
+
 	/* tasklet could resubmit itself forever if memory is tight */
 	if (test_bit (EVENT_RX_MEMORY, &dev->flags)) {
 		struct urb	*urb =3D NULL;
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 76f4396..c0bcb61 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -62,13 +62,14 @@ struct usbnet {
 	unsigned long		flags;
 #		define EVENT_TX_HALT	0
 #		define EVENT_RX_HALT	1
-#		define EVENT_RX_MEMORY	2
-#		define EVENT_STS_SPLIT	3
-#		define EVENT_LINK_RESET	4
-#		define EVENT_RX_PAUSED	5
-#		define EVENT_DEV_WAKING 6
-#		define EVENT_DEV_ASLEEP 7
-#		define EVENT_DEV_OPEN	8
+#		define EVENT_STS_HALT	2
+#		define EVENT_RX_MEMORY	3
+#		define EVENT_STS_SPLIT	4
+#		define EVENT_LINK_RESET	5
+#		define EVENT_RX_PAUSED	6
+#		define EVENT_DEV_WAKING 7
+#		define EVENT_DEV_ASLEEP 8
+#		define EVENT_DEV_OPEN	9
 };

 static inline struct usb_driver *driver_of(struct usb_interface *intf)
