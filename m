From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: commit 0bdb0bd0 breaks shutdown/reboot
Date: Mon, 7 Nov 2011 08:13:16 -0800
Message-ID: <20111107081316.2e1cc2cb@nehalam.linuxnetplumber.net>
References: <20111107153119.GA11724@comet.dominikbrodowski.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Dominik Brodowski <linux@dominikbrodowski.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [76.74.103.46] ([76.74.103.46]:60238 "EHLO mail.vyatta.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754747Ab1KGQOa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Nov 2011 11:14:30 -0500
In-Reply-To: <20111107153119.GA11724@comet.dominikbrodowski.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Does this help?

Subject: sky2: block irq's on down

Need to block IRQ's from phy changes to prevent stray IRQ's when
device is down.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/ethernet/marvell/sky2.c	2011-11-04 15:01:51.310888300 -0700
+++ b/drivers/net/ethernet/marvell/sky2.c	2011-11-07 08:10:05.065118917 -0800
@@ -2106,15 +2106,20 @@ static int sky2_down(struct net_device *
 
 	netif_info(sky2, ifdown, dev, "disabling interface\n");
 
-	/* Disable port IRQ */
-	sky2_write32(hw, B0_IMSK,
-		     sky2_read32(hw, B0_IMSK) & ~portirq_msk[sky2->port]);
-	sky2_read32(hw, B0_IMSK);
-
 	if (hw->ports == 1) {
+		sky2_write32(hw, B0_IMSK, 0);
+		sky2_read32(hw, B0_IMSK);
+
 		napi_disable(&hw->napi);
 		free_irq(hw->pdev->irq, hw);
 	} else {
+		/* Disable port IRQ */
+		u32 imsk = sky2_read32(hw, B0_IMSK);
+
+		imsk &= ~portirq_msk[sky2->port];
+		sky2_write32(hw, B0_IMSK, imsk);
+		sky2_read32(hw, B0_IMSK);
+
 		synchronize_irq(hw->pdev->irq);
 		napi_synchronize(&hw->napi);
 	}
@@ -5017,19 +5022,19 @@ static void __devexit sky2_remove(struct
 	for (i = hw->ports-1; i >= 0; --i)
 		unregister_netdev(hw->dev[i]);
 
-	sky2_write32(hw, B0_IMSK, 0);
-	sky2_read32(hw, B0_IMSK);
-
 	sky2_power_aux(hw);
 
-	sky2_write8(hw, B0_CTST, CS_RST_SET);
-	sky2_read8(hw, B0_CTST);
-
 	if (hw->ports > 1) {
+		sky2_write32(hw, B0_IMSK, 0);
+		sky2_read32(hw, B0_IMSK);
+
 		napi_disable(&hw->napi);
 		free_irq(pdev->irq, hw);
 	}
 
+	sky2_write8(hw, B0_CTST, CS_RST_SET);
+	sky2_read8(hw, B0_CTST);
+
 	if (hw->flags & SKY2_HW_USE_MSI)
 		pci_disable_msi(pdev);
 	pci_free_consistent(pdev, hw->st_size * sizeof(struct sky2_status_le),
