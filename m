From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Regression: Wake on LAN doesn't work in sky2 with
 2.6.33-rc4-git2
Date: Tue, 19 Jan 2010 10:51:05 -0800
Message-ID: <20100119105105.184c3f01@nehalam>
References: <20100115091053.GA5477@mac.home>
	<201001180136.45823.rjw@sisk.pl>
	<20100118083757.GA2619@mac.home>
	<201001182234.55113.rjw@sisk.pl>
	<20100118144340.100c9544@nehalam>
	<20100119103248.GA8527@mac.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tino Keitel <tino.keitel@tikei.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755166Ab0ASSvS@vger.kernel.org>
In-Reply-To: <20100119103248.GA8527@mac.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Is this better worse or the same? It make sure that some
registers are set on resume that might matter.


--- a/drivers/net/sky2.c	2010-01-19 10:32:47.549541152 -0800
+++ b/drivers/net/sky2.c	2010-01-19 10:49:06.726853816 -0800
@@ -3002,11 +3002,17 @@ static void sky2_reset(struct sky2_hw *h
 	u32 hwe_mask = Y2_HWE_ALL_MASK;
 
 	/* disable ASF */
-	if (hw->chip_id == CHIP_ID_YUKON_EX) {
+	if (hw->chip_id == CHIP_ID_YUKON_EX ||
+	    hw->chip_id == CHIP_ID_YUKON_SUPR) {
+		/* stop the watchdog */
+		sky2_write32(hw, CPU_WDOG, 0);
+
 		status = sky2_read16(hw, HCU_CCSR);
 		status &= ~(HCU_CCSR_AHB_RST | HCU_CCSR_CPU_RST_MODE |
 			    HCU_CCSR_UC_STATE_MSK);
+		status &= ~HCU_CCSR_CPU_CLK_DIVIDE_MSK;
 		sky2_write16(hw, HCU_CCSR, status);
+		sky2_write32(hw, CPU_WDOG, 0);
 	} else
 		sky2_write8(hw, B28_Y2_ASF_STAT_CMD, Y2_ASF_RESET);
 	sky2_write16(hw, B0_CTST, Y2_ASF_DISABLE);
@@ -4807,11 +4813,12 @@ static int sky2_resume(struct pci_dev *p
 
 	pci_enable_wake(pdev, PCI_D0, 0);
 
-	/* Re-enable all clocks */
-	if (hw->chip_id == CHIP_ID_YUKON_EX ||
-	    hw->chip_id == CHIP_ID_YUKON_EC_U ||
-	    hw->chip_id == CHIP_ID_YUKON_FE_P)
-		sky2_pci_write32(hw, PCI_DEV_REG3, 0);
+	/* Enable all clocks and check for bad PCI access */
+	err = pci_write_config_dword(pdev, PCI_DEV_REG3, 0);
+	if (err)
+		goto out;
+
+	sky2_write8(hw, B0_CTST, CS_RST_CLR);
 
 	sky2_reset(hw);
 	sky2_write32(hw, B0_IMSK, Y2_IS_BASE);
