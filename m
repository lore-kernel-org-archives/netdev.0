From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] igb: fix legacy mode irq issue
Date: Fri, 15 Feb 2008 14:05:25 -0800
Message-ID: <20080215220525.28483.30217.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	andy@greyhouse.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:59105 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753462AbYBOWHW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2008 17:07:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <andy@greyhouse.net>

I booted an igb kernel with the option pci=nomsi and instantly noticed
that interrupts no longer worked on my igb device.  I took a look at the
interrupt initialization and quickly discovered a comment stating:

"DO NOT USE EIAME or IAME in legacy mode"

It seemed a bit odd that bits to enable IAM were being set in legacy
interrupt mode, so I dropped out the following parts and interrupts
began working fine again.

[Updated code flow and a nitpick spelling error --Auke]

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/igb/igb_main.c |    9 ++-------
 1 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index bff280e..3480cc7 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -439,7 +439,7 @@ static int igb_request_irq(struct igb_adapter *adapter)
 		err = igb_request_msix(adapter);
 		if (!err) {
 			/* enable IAM, auto-mask,
-			 * DO NOT USE EIAME or IAME in legacy mode */
+			 * DO NOT USE EIAM or IAM in legacy mode */
 			wr32(E1000_IAM, IMS_ENABLE_MASK);
 			goto request_done;
 		}
@@ -465,14 +465,9 @@ static int igb_request_irq(struct igb_adapter *adapter)
 	err = request_irq(adapter->pdev->irq, &igb_intr, IRQF_SHARED,
 			  netdev->name, netdev);
 
-	if (err) {
+	if (err)
 		dev_err(&adapter->pdev->dev, "Error %d getting interrupt\n",
 			err);
-		goto request_done;
-	}
-
-	/* enable IAM, auto-mask */
-	wr32(E1000_IAM, IMS_ENABLE_MASK);
 
 request_done:
 	return err;

