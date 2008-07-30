From: Jaswinder Singh <jaswinder@infradead.org>
Subject: Re: [PATCH] typhoon: use request_firmware
Date: Wed, 30 Jul 2008 12:14:11 +0530
Message-ID: <1217400251.2595.3.camel@jaswinder.satnam>
References: <1217170232.3537.6.camel@jaswinder.satnam>
	 <1217209400.22789.47.camel@obelisk.thedillows.org>
	 <1217215009.2970.7.camel@jaswinder.satnam>
	 <1217248585.22789.58.camel@obelisk.thedillows.org>
	 <1217253260.17632.6.camel@jaswinder.satnam>
	 <1217295498.28682.16.camel@obelisk.thedillows.org>
	 <1217347786.2885.11.camel@jaswinder.satnam>
	 <1217395511.31350.6.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>, becker@scyld.com,
	davidpmclean@yahoo.com, Jeff Garzik <jeff@garzik.org>,
	netdev <netdev@vger.kernel.org>,
	David Woodhouse <dwmw2@infradead.org>
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:34978 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751428AbYG3Gpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 02:45:36 -0400
In-Reply-To: <1217395511.31350.6.camel@obelisk.thedillows.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave,

On Wed, 2008-07-30 at 01:25 -0400, David Dillow wrote:

> That's fine, and makes sense. However, you need to check if you've
> already loaded it (typhoon_fw != NULL), so you don't leak memory if
> there is more than one NIC. Part of me feels like there should be a
> mutex around loading the firmware, to avoid surprises if PCI probing
> gets multi-threaded again, but a comment to that effect may suffice for
> now.
> 

OK, fixed.

diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index a57941a..50f1943 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -2461,9 +2461,17 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 */
 	tp->name = pci_name(pdev);
 
-	err = typhoon_init_firmware(tp);
-	if (err)
-		goto error_out_reset;
+	/*
+	 * Need to check request_firmware should be called only once
+	 * so you don't leak memory if there is more than one NIC.
+	 * Need to check if PCI probing gets multi-threaded as
+	 * mutex is used while loading the firmware.
+	 */
+	if (typhoon_fw != NULL) {
+		err = typhoon_init_firmware(tp);
+		if (err)
+			goto error_out_reset;
+	}
 
 	typhoon_init_interface(tp);
 	typhoon_init_rings(tp);

> Also, if not adding a mutex, then this can be folded into
> typhoon_init_one(), rather than living in a separate function. 
> 

request_firmware is using mutex.

> All in all, this is getting better, my reservations about the goal
> aside.
> 

Without you help this was not possible :)

Thank you,

Jaswinder Singh.

