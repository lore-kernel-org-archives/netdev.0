From: Paul Stewart <pstew@chromium.org>
Subject: [PATCHv4] usbnet: Resubmit interrupt URB once if halted
Date: Tue, 19 Apr 2011 10:44:12 -0700
Message-ID: <20110420195015.20A96201B8@glenhelen.mtv.corp.google.com>
References: <20110420.012431.104074243.davem@davemloft.net>
	<20110420182234.GB8143@kroah.com>
	<Pine.LNX.4.44L0.1104201252010.2159-100000@iolanthe.rowland.org>
Cc: linux-usb@vger.kernel.org, davem@davemloft.net,
	stern@rowland.harvard.edu, greg@kroah.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:36029 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753910Ab1DTTuf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 15:50:35 -0400
In-Reply-To: <20110420.012431.104074243.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set a flag if the interrupt URB completes with ENOENT as this
occurs legitimately during system suspend.  When the usbnet_bh
is called after resume, test this flag and try once to resubmit
the interrupt URB.

Signed-off-by: Paul Stewart <pstew@chromium.org>
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
+	/* try once to resume interrupt URBs if they were halted before */
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

