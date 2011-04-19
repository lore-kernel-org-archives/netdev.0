From: Paul Stewart <pstew-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCHv3] usbnet: Resubmit interrupt URB once if halted
Date: Tue, 19 Apr 2011 10:44:12 -0700
Message-ID: <20110420193844.3C095201B8@glenhelen.mtv.corp.google.com>
References: <20110420.012431.104074243.davem@davemloft.net>
	<20110420182234.GB8143@kroah.com>
	<Pine.LNX.4.44L0.1104201252010.2159-100000@iolanthe.rowland.org>
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org, greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110420.012431.104074243.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Set a flag if the interrupt URB completes with ENOENT as this
occurs legitimately during system suspend.  When the usbnet_bh
is called after resume, test this flag and try once to resubmit
the interrupt URB.

Signed-off-by: Paul Stewart <pstew-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
---
 drivers/net/usb/usbnet.c   |    8 ++++++++
 include/linux/usb/usbnet.h |    1 +
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 02d25c7..9ac4bae 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -482,6 +482,7 @@ static void intr_complete (struct urb *urb)
 	case -ESHUTDOWN:	/* hardware gone */
 		if (netif_msg_ifdown (dev))
 			devdbg (dev, "intr shutdown, code %d", status);
+		set_bit(EVENT_INTR_HALT, &dev->flags);
 		return;
 
 	/* NOTE:  not throttling like RX/TX, since this endpoint
@@ -1065,6 +1066,13 @@ static void usbnet_bh (unsigned long param)
 		if (dev->txq.qlen < TX_QLEN (dev))
 			netif_wake_queue (dev->net);
 	}
+
+	// try once to resume interrupt URBs if they were halted before
+	if (dev->interrupt && netif_running(dev->net) &&
+	    test_bit(EVENT_INTR_HALT, &dev->flags)) {
+		clear_bit(EVENT_INTR_HALT, &dev->flags);
+		usb_submit_urb(dev->interrupt, GFP_KERNEL);
+	}
 }
 
 
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index ba09fe8..6c4b5f8 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -64,6 +64,7 @@ struct usbnet {
 #		define EVENT_RX_MEMORY	2
 #		define EVENT_STS_SPLIT	3
 #		define EVENT_LINK_RESET	4
+#		define EVENT_INTR_HALT	5
 };
 
 static inline struct usb_driver *driver_of(struct usb_interface *intf)
-- 
1.7.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
