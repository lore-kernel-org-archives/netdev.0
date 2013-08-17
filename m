From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v1 33/49] wireless: zd1211rw: prepare for enabling irq in complete()
Date: Sun, 18 Aug 2013 00:24:58 +0800
Message-ID: <1376756714-25479-34-git-send-email-ming.lei@canonical.com>
References: <1376756714-25479-1-git-send-email-ming.lei@canonical.com>
Cc: linux-usb@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Alan Stern <stern@rowland.harvard.edu>,
	Ming Lei <ming.lei@canonical.com>,
	Daniel Drake <dsd@gentoo.org>,
	Ulrich Kunitz <kune@deine-taler.de>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f52.google.com ([209.85.160.52]:62010 "EHLO
	mail-pb0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754366Ab3HQQam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Aug 2013 12:30:42 -0400
In-Reply-To: <1376756714-25479-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Complete() will be run with interrupt enabled, so change to
spin_lock_irqsave().

Cc: Daniel Drake <dsd@gentoo.org>
Cc: Ulrich Kunitz <kune@deine-taler.de>
Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/wireless/zd1211rw/zd_usb.c |   21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index 7ef0b4a..8169ee0 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -372,14 +372,15 @@ static inline void handle_regs_int_override(struct urb *urb)
 {
 	struct zd_usb *usb = urb->context;
 	struct zd_usb_interrupt *intr = &usb->intr;
+	unsigned long flags;
 
-	spin_lock(&intr->lock);
+	spin_lock_irqsave(&intr->lock, flags);
 	if (atomic_read(&intr->read_regs_enabled)) {
 		atomic_set(&intr->read_regs_enabled, 0);
 		intr->read_regs_int_overridden = 1;
 		complete(&intr->read_regs.completion);
 	}
-	spin_unlock(&intr->lock);
+	spin_unlock_irqrestore(&intr->lock, flags);
 }
 
 static inline void handle_regs_int(struct urb *urb)
@@ -388,9 +389,10 @@ static inline void handle_regs_int(struct urb *urb)
 	struct zd_usb_interrupt *intr = &usb->intr;
 	int len;
 	u16 int_num;
+	unsigned long flags;
 
 	ZD_ASSERT(in_interrupt());
-	spin_lock(&intr->lock);
+	spin_lock_irqsave(&intr->lock, flags);
 
 	int_num = le16_to_cpu(*(__le16 *)(urb->transfer_buffer+2));
 	if (int_num == CR_INTERRUPT) {
@@ -426,7 +428,7 @@ static inline void handle_regs_int(struct urb *urb)
 	}
 
 out:
-	spin_unlock(&intr->lock);
+	spin_unlock_irqrestore(&intr->lock, flags);
 
 	/* CR_INTERRUPT might override read_reg too. */
 	if (int_num == CR_INTERRUPT && atomic_read(&intr->read_regs_enabled))
@@ -666,6 +668,7 @@ static void rx_urb_complete(struct urb *urb)
 	struct zd_usb_rx *rx;
 	const u8 *buffer;
 	unsigned int length;
+	unsigned long flags;
 
 	switch (urb->status) {
 	case 0:
@@ -694,14 +697,14 @@ static void rx_urb_complete(struct urb *urb)
 		/* If there is an old first fragment, we don't care. */
 		dev_dbg_f(urb_dev(urb), "*** first fragment ***\n");
 		ZD_ASSERT(length <= ARRAY_SIZE(rx->fragment));
-		spin_lock(&rx->lock);
+		spin_lock_irqsave(&rx->lock, flags);
 		memcpy(rx->fragment, buffer, length);
 		rx->fragment_length = length;
-		spin_unlock(&rx->lock);
+		spin_unlock_irqrestore(&rx->lock, flags);
 		goto resubmit;
 	}
 
-	spin_lock(&rx->lock);
+	spin_lock_irqsave(&rx->lock, flags);
 	if (rx->fragment_length > 0) {
 		/* We are on a second fragment, we believe */
 		ZD_ASSERT(length + rx->fragment_length <=
@@ -711,9 +714,9 @@ static void rx_urb_complete(struct urb *urb)
 		handle_rx_packet(usb, rx->fragment,
 			         rx->fragment_length + length);
 		rx->fragment_length = 0;
-		spin_unlock(&rx->lock);
+		spin_unlock_irqrestore(&rx->lock, flags);
 	} else {
-		spin_unlock(&rx->lock);
+		spin_unlock_irqrestore(&rx->lock, flags);
 		handle_rx_packet(usb, buffer, length);
 	}
 
-- 
1.7.9.5
