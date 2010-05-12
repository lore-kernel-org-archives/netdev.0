From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH 5/5] sky2: Avoid allocating memory in sky2_resume
Date: Thu, 13 May 2010 08:30:01 +0900
Message-ID: <4BEB39F9.9090004@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:40587 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753147Ab0ELXjC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 19:39:02 -0400
Received: by mail-pw0-f46.google.com with SMTP id 5so332350pwi.19
        for <netdev@vger.kernel.org>; Wed, 12 May 2010 16:39:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allocating memory can fail, and since we have the memory we need
in sky2_resume when sky2_suspend is called, just stop the hardware
without freeing the memory it's using.

This avoids the possibility of failing because we can't allocate
memory in sky2_resume(), and allows sharing code with sky2_restart().

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |   20 +++++---------------
 1 files changed, 5 insertions(+), 15 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index a8060c8..02d9d6f 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -4842,12 +4842,12 @@ static int sky2_suspend(struct pci_dev *pdev, pm_message_t state)
 	cancel_work_sync(&hw->restart_work);
 
 	rtnl_lock();
+
+	sky2_all_down(hw);
 	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];
 		struct sky2_port *sky2 = netdev_priv(dev);
 
-		sky2_detach(dev);
-
 		if (sky2->wol)
 			sky2_wol_init(sky2);
 
@@ -4856,8 +4856,6 @@ static int sky2_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	device_set_wakeup_enable(&pdev->dev, wol != 0);
 
-	sky2_write32(hw, B0_IMSK, 0);
-	napi_disable(&hw->napi);
 	sky2_power_aux(hw);
 	rtnl_unlock();
 
@@ -4872,12 +4870,11 @@ static int sky2_suspend(struct pci_dev *pdev, pm_message_t state)
 static int sky2_resume(struct pci_dev *pdev)
 {
 	struct sky2_hw *hw = pci_get_drvdata(pdev);
-	int i, err;
+	int err;
 
 	if (!hw)
 		return 0;
 
-	rtnl_lock();
 	err = pci_set_power_state(pdev, PCI_D0);
 	if (err)
 		goto out;
@@ -4895,20 +4892,13 @@ static int sky2_resume(struct pci_dev *pdev)
 		goto out;
 	}
 
+	rtnl_lock();
 	sky2_reset(hw);
-	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
-	napi_enable(&hw->napi);
-
-	for (i = 0; i < hw->ports; i++) {
-		err = sky2_reattach(hw->dev[i]);
-		if (err)
-			goto out;
-	}
+	sky2_all_up(hw);
 	rtnl_unlock();
 
 	return 0;
 out:
-	rtnl_unlock();
 
 	dev_err(&pdev->dev, "resume failed (%d)\n", err);
 	pci_disable_device(pdev);
-- 
1.5.6.5

