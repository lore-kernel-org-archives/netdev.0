From: Mike McCormack <mikem@ring3k.org>
Subject: [PATCH resend] sky2: Make sure both ports initialize correctly
Date: Mon, 14 Sep 2009 08:08:54 +0900
Message-ID: <4AAD7B86.6060300@ring3k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f189.google.com ([209.85.216.189]:48392 "EHLO
	mail-px0-f189.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753841AbZIMXNS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Sep 2009 19:13:18 -0400
Received: by pxi27 with SMTP id 27so1956270pxi.15
        for <netdev@vger.kernel.org>; Sun, 13 Sep 2009 16:13:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rework sky2_probe() so that both ports are allocated and deallocated in the
 same way.  Fail if allocating either port fails as both are assumed to be
 allocated in many places.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
---
 drivers/net/sky2.c |   71 +++++++++++++++++++++++++--------------------------
 1 files changed, 35 insertions(+), 36 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index c8ebc03..9c3fa49 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -4422,11 +4422,11 @@ static const char *sky2_name(u8 chipid, char *buf, int sz)
 static int __devinit sky2_probe(struct pci_dev *pdev,
 				const struct pci_device_id *ent)
 {
-	struct net_device *dev;
 	struct sky2_hw *hw;
 	int err, using_dac = 0, wol_default;
 	u32 reg;
 	char buf1[16];
+	int i;
 
 	err = pci_enable_device(pdev);
 	if (err) {
@@ -4512,17 +4512,30 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 
 	err = sky2_init(hw);
 	if (err)
-		goto err_out_iounmap;
+		goto err_out_free_pci;
 
 	dev_info(&pdev->dev, "Yukon-2 %s chip revision %d\n",
 		 sky2_name(hw->chip_id, buf1, sizeof(buf1)), hw->chip_rev);
 
 	sky2_reset(hw);
 
-	dev = sky2_init_netdev(hw, 0, using_dac, wol_default);
-	if (!dev) {
-		err = -ENOMEM;
-		goto err_out_free_pci;
+	for (i=0; i<hw->ports; i++)
+	{
+		struct net_device *dev;
+
+		dev = sky2_init_netdev(hw, 0, using_dac, wol_default);
+		if (!dev) {
+			err = -ENOMEM;
+			goto err_out_free_netdev;
+		}
+
+		err = register_netdev(dev);
+		if (err) {
+			dev_err(&pdev->dev, "cannot register net device\n");
+			goto err_out_free_netdev;
+		}
+
+		sky2_show_addr(dev);
 	}
 
 	if (!disable_msi && pci_enable_msi(pdev) == 0) {
@@ -4530,44 +4543,21 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 		if (err == -EOPNOTSUPP)
  			pci_disable_msi(pdev);
 		else if (err)
-			goto err_out_free_netdev;
+			goto err_out_disable_msi;
  	}
 
-	err = register_netdev(dev);
-	if (err) {
-		dev_err(&pdev->dev, "cannot register net device\n");
-		goto err_out_free_netdev;
-	}
-
-	netif_napi_add(dev, &hw->napi, sky2_poll, NAPI_WEIGHT);
+	netif_napi_add(hw->dev[0], &hw->napi, sky2_poll, NAPI_WEIGHT);
 
 	err = request_irq(pdev->irq, sky2_intr,
 			  (hw->flags & SKY2_HW_USE_MSI) ? 0 : IRQF_SHARED,
-			  dev->name, hw);
+			  hw->dev[0]->name, hw);
 	if (err) {
 		dev_err(&pdev->dev, "cannot assign irq %d\n", pdev->irq);
-		goto err_out_unregister;
+		goto err_out_disable_msi;
 	}
 	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
 	napi_enable(&hw->napi);
 
-	sky2_show_addr(dev);
-
-	if (hw->ports > 1) {
-		struct net_device *dev1;
-
-		dev1 = sky2_init_netdev(hw, 1, using_dac, wol_default);
-		if (!dev1)
-			dev_warn(&pdev->dev, "allocation for second device failed\n");
-		else if ((err = register_netdev(dev1))) {
-			dev_warn(&pdev->dev,
-				 "register of second port failed (%d)\n", err);
-			hw->dev[1] = NULL;
-			free_netdev(dev1);
-		} else
-			sky2_show_addr(dev1);
-	}
-
 	setup_timer(&hw->watchdog_timer, sky2_watchdog, (unsigned long) hw);
 	INIT_WORK(&hw->restart_work, sky2_restart);
 
@@ -4575,12 +4565,21 @@ static int __devinit sky2_probe(struct pci_dev *pdev,
 
 	return 0;
 
-err_out_unregister:
+err_out_disable_msi:
 	if (hw->flags & SKY2_HW_USE_MSI)
 		pci_disable_msi(pdev);
-	unregister_netdev(dev);
+
 err_out_free_netdev:
-	free_netdev(dev);
+	for (i=0; i<hw->ports; i++) {
+		struct net_device *dev = hw->dev[i];
+
+		if (dev) {
+			if (dev->reg_state == NETREG_REGISTERED)
+				unregister_netdev(dev);
+			free_netdev(dev);
+		}
+	}
+
 err_out_free_pci:
 	sky2_write8(hw, B0_CTST, CS_RST_SET);
 	pci_free_consistent(pdev, STATUS_LE_BYTES, hw->st_le, hw->st_dma);
-- 
1.5.6.5

