From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH] skge: Make sure both ports initialize correctly
Date: Wed, 23 Sep 2009 22:50:36 +0900
Message-ID: <4ABA27AC.7030207@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f194.google.com ([209.85.216.194]:49795 "EHLO
	mail-px0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911AbZIWNum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2009 09:50:42 -0400
Received: by pxi32 with SMTP id 32so600782pxi.4
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2009 06:50:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If allocation of the second ports fails, make sure that hw->ports
 is not 2 otherwise we'll crash trying to access the second port.

This fix is copied from a similar fix in the sky2 driver (ca519274...),
but is untested, as I don't have a skge card.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/skge.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/skge.c b/drivers/net/skge.c
index 62e852e..21b816f 100644
--- a/drivers/net/skge.c
+++ b/drivers/net/skge.c
@@ -3982,14 +3982,17 @@ static int __devinit skge_probe(struct pci_dev *pdev,
 	}
 	skge_show_addr(dev);
 
-	if (hw->ports > 1 && (dev1 = skge_devinit(hw, 1, using_dac))) {
-		if (register_netdev(dev1) == 0)
+	if (hw->ports > 1) {
+		dev1 = skge_devinit(hw, 1, using_dac);
+		if (dev1 && register_netdev(dev1) == 0)
 			skge_show_addr(dev1);
 		else {
 			/* Failure to register second port need not be fatal */
 			dev_warn(&pdev->dev, "register of second port failed\n");
 			hw->dev[1] = NULL;
-			free_netdev(dev1);
+			hw->ports = 1;
+			if (dev1)
+				free_netdev(dev1);
 		}
 	}
 	pci_set_drvdata(pdev, hw);
-- 
1.5.6.5

