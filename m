From: akpm@linux-foundation.org
Subject: [patch 13/15] irda_device_dongle_init: fix kzalloc(GFP_KERNEL) in spinlock
Date: Thu, 26 Apr 2007 00:27:35 -0700
Message-ID: <200704260727.l3Q7RZr7023981@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	matthias.kaehlcke@gmail.com, samuel@sortiz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:34227 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933599AbXDZH74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 03:59:56 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>

Fix http://bugzilla.kernel.org/show_bug.cgi?id=8343

Cc: Samuel Ortiz <samuel@sortiz.org>
Cc: <matthias.kaehlcke@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/irda/irda_device.c |   21 ++++++++-------------
 1 file changed, 8 insertions(+), 13 deletions(-)

diff -puN net/irda/irda_device.c~irda_device_dongle_init-fix-kzallocgfp_kernel-in-spinlock net/irda/irda_device.c
--- a/net/irda/irda_device.c~irda_device_dongle_init-fix-kzallocgfp_kernel-in-spinlock
+++ a/net/irda/irda_device.c
@@ -375,7 +375,7 @@ EXPORT_SYMBOL(alloc_irdadev);
 dongle_t *irda_device_dongle_init(struct net_device *dev, int type)
 {
 	struct dongle_reg *reg;
-	dongle_t *dongle = NULL;
+	dongle_t *dongle = kzalloc(sizeof(dongle_t), GFP_KERNEL);
 
 	might_sleep();
 
@@ -397,19 +397,14 @@ dongle_t *irda_device_dongle_init(struct
 	if (!reg || !try_module_get(reg->owner) ) {
 		IRDA_ERROR("IrDA: Unable to find requested dongle type %x\n",
 			   type);
-		goto out;
+		kfree(dongle);
+		dongle = NULL;
+	}
+	if (dongle) {
+		/* Bind the registration info to this particular instance */
+		dongle->issue = reg;
+		dongle->dev = dev;
 	}
-
-	/* Allocate dongle info for this instance */
-	dongle = kzalloc(sizeof(dongle_t), GFP_KERNEL);
-	if (!dongle)
-		goto out;
-
-	/* Bind the registration info to this particular instance */
-	dongle->issue = reg;
-	dongle->dev = dev;
-
- out:
 	spin_unlock(&dongles->hb_spinlock);
 	return dongle;
 }
_
