From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/6] sky2: Avoid allocating memory in sky2_resume
Date: Thu, 13 May 2010 09:12:52 -0700
Message-ID: <20100513161351.340600937@vyatta.com>
References: <20100513161247.833356588@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Mike McCormack <mikem@ring3k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:39377 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757227Ab0EMXaZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 19:30:25 -0400
Content-Disposition: inline; filename=sky2-mike5.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike McCormack <mikem@ring3k.org>

Allocating memory can fail, and since we have the memory we need
in sky2_resume when sky2_suspend is called, just stop the hardware
without freeing the memory it's using.

This avoids the possibility of failing because we can't allocate
memory in sky2_resume(), and allows sharing code with sky2_restart().

Signed-off-by: Mike McCormack <mikem@ring3k.org>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>

---
Not a regression

 drivers/net/sky2.c |   20 +++++---------------
 1 files changed, 5 insertions(+), 15 deletions(-)

--- a/drivers/net/sky2.c	2010-05-13 08:57:33.337275609 -0700
+++ b/drivers/net/sky2.c	2010-05-13 08:57:33.907302370 -0700
@@ -4926,12 +4926,12 @@ static int sky2_suspend(struct pci_dev *
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
 
@@ -4940,8 +4940,6 @@ static int sky2_suspend(struct pci_dev *
 
 	device_set_wakeup_enable(&pdev->dev, wol != 0);
 
-	sky2_write32(hw, B0_IMSK, 0);
-	napi_disable(&hw->napi);
 	sky2_power_aux(hw);
 	rtnl_unlock();
 
@@ -4956,12 +4954,11 @@ static int sky2_suspend(struct pci_dev *
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
@@ -4979,20 +4976,13 @@ static int sky2_resume(struct pci_dev *p
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


