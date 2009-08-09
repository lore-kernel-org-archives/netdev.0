From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH] sky2: Serialize access to PCI config space
Date: Sun, 09 Aug 2009 20:37:19 +0900
Message-ID: <4A7EB4EF.3030106@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.228]:28146 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833AbZHILka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Aug 2009 07:40:30 -0400
Received: by rv-out-0506.google.com with SMTP id f6so768687rvb.1
        for <netdev@vger.kernel.org>; Sun, 09 Aug 2009 04:40:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Disable NAPI when powering up or down the phy, as sky2_err_intr
 may also access the PCI config space.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 8e05d29..824a319 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1448,7 +1448,9 @@ static int sky2_up(struct net_device *dev)
 	if (!sky2->rx_ring)
 		goto err_out;
 
+	napi_disable(&hw->napi);
 	sky2_mac_init(hw, port);
+	napi_enable(&hw->napi);
 
 	/* Register is number of 4K blocks on internal RAM buffer. */
 	ramsize = sky2_read8(hw, B2_E_0) * 4;
@@ -1880,13 +1882,16 @@ static int sky2_down(struct net_device *dev)
 	sky2_write32(hw, B0_IMSK, imask);
 	sky2_read32(hw, B0_IMSK);
 
+	/* after this, there should be no more interrupts for this port */
 	synchronize_irq(hw->pdev->irq);
-	napi_synchronize(&hw->napi);
+	napi_disable(&hw->napi);
 
 	spin_lock_bh(&sky2->phy_lock);
 	sky2_phy_power_down(hw, port);
 	spin_unlock_bh(&sky2->phy_lock);
 
+	napi_enable(&hw->napi);
+
 	/* turn off LED's */
 	sky2_write16(hw, B0_Y2LED, LED_STAT_OFF);
 
-- 
1.5.6.5


