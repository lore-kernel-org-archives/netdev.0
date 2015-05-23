From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] irda: irda-usb: use msecs_to_jiffies for conversions
Date: Sat, 23 May 2015 14:46:30 +0200
Message-ID: <1432385190-6333-1-git-send-email-hofrat@osadl.org>
Cc: David Miller <davem@davemloft.net>, Joe Perches <joe@perches.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicholas Mc Guire <hofrat@osadl.org>
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.osadl.org ([62.245.132.105]:44996 "EHLO www.osadl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757518AbbEWM4Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 May 2015 08:56:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

API compliance scanning with coccinelle flagged:

Converting milliseconds to jiffies by "val * HZ / 1000" is technically
is not a clean solution as it does not handle all corner cases correctly.
By changing the conversion to use msecs_to_jiffies(val) conversion is
correct in all cases.

in the current code: 
  mod_timer(&self->rx_defer_timer, jiffies + (10 * HZ / 1000));
for HZ < 100 (e.g. CONFIG_HZ == 64|32 in alpha) this effectively results 
in no delay at all.

Patch was compile tested for x86_64_defconfig (implies CONFIG_USB_IRDA=m)

Patch is against 4.1-rc4 (localversion-next is -next-20150522)

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

V2: the unnecessary () flagged by Joe Perches <joe@perches.com>
    was removed - thanks (...once again...) !

 drivers/net/irda/irda-usb.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/irda/irda-usb.c b/drivers/net/irda/irda-usb.c
index f6c9163..f3e4563 100644
--- a/drivers/net/irda/irda-usb.c
+++ b/drivers/net/irda/irda-usb.c
@@ -848,7 +848,9 @@ static void irda_usb_receive(struct urb *urb)
 		 * Jean II */
 		self->rx_defer_timer.function = irda_usb_rx_defer_expired;
 		self->rx_defer_timer.data = (unsigned long) urb;
-		mod_timer(&self->rx_defer_timer, jiffies + (10 * HZ / 1000));
+		mod_timer(&self->rx_defer_timer,
+			  jiffies + msecs_to_jiffies(10));
+
 		return;
 	}
 	
-- 
1.7.10.4
