From: Adam Lee <adam.lee@canonical.com>
Subject: [PATCH v3 1/2] rtlwifi: add MSI interrupts mode support
Date: Fri, 28 Mar 2014 11:36:18 +0800
Message-ID: <1395977779-16093-1-git-send-email-adam.lee@canonical.com>
References: <1395715732-9545-1-git-send-email-adam.lee@canonical.com>
Cc: netdev@vger.kernel.org, Larry Finger <Larry.Finger@lwfinger.net>,
	"John W. Linville" <linville@tuxdriver.com>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:40567 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757242AbaC1Dgb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 23:36:31 -0400
Received: by mail-pd0-f173.google.com with SMTP id z10so4261040pdj.32
        for <netdev@vger.kernel.org>; Thu, 27 Mar 2014 20:36:31 -0700 (PDT)
In-Reply-To: <1395715732-9545-1-git-send-email-adam.lee@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add MSI interrupts mode support, enable it when submodules' msi_support
flag is true, also could fallback to pin-based interrupts mode if MSI
interrupts mode fails.

RealTek's policy(on modules which work well with MSI interrupts mode) is:

> If the platform supports both MSI and pin-based, use MSI.
> If the platform supports MSI only, use MSI.
> If the platform supports pin-based only, use pin-based.

Also as RealTek's testing results, RTL8188EE and RTL8723BE work well
with both MSI mode and pin-based mode fallback.

Signed-off-by: Adam Lee <adam.lee@canonical.com>
---
 drivers/net/wireless/rtlwifi/pci.c | 65 ++++++++++++++++++++++++++++++++++++--
 1 file changed, 63 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index 7d71170..dae5525 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -1853,6 +1853,65 @@ static bool _rtl_pci_find_adapter(struct pci_dev *pdev,
 	return true;
 }
 
+static int rtl_pci_intr_mode_msi(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
+	struct rtl_pci *rtlpci = rtl_pcidev(pcipriv);
+	int ret;
+
+	ret = pci_enable_msi(rtlpci->pdev);
+	if (ret < 0)
+		return ret;
+
+	ret = request_irq(rtlpci->pdev->irq, &_rtl_pci_interrupt,
+			  IRQF_SHARED, KBUILD_MODNAME, hw);
+	if (ret < 0) {
+		pci_disable_msi(rtlpci->pdev);
+		return ret;
+	}
+
+	rtlpci->using_msi = true;
+
+	RT_TRACE(rtlpriv, COMP_INIT|COMP_INTR, DBG_DMESG,
+		 "MSI Interrupt Mode!\n");
+	return 0;
+}
+
+static int rtl_pci_intr_mode_legacy(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
+	struct rtl_pci *rtlpci = rtl_pcidev(pcipriv);
+	int ret;
+
+	ret = request_irq(rtlpci->pdev->irq, &_rtl_pci_interrupt,
+			  IRQF_SHARED, KBUILD_MODNAME, hw);
+	if (ret < 0)
+		return ret;
+
+	rtlpci->using_msi = false;
+	RT_TRACE(rtlpriv, COMP_INIT|COMP_INTR, DBG_DMESG,
+		 "Pin-based Interrupt Mode!\n");
+	return 0;
+}
+
+static int rtl_pci_intr_mode_decide(struct ieee80211_hw *hw)
+{
+	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
+	struct rtl_pci *rtlpci = rtl_pcidev(pcipriv);
+	int ret;
+
+	if (rtlpci->msi_support) {
+		ret = rtl_pci_intr_mode_msi(hw);
+		if (ret < 0)
+			ret = rtl_pci_intr_mode_legacy(hw);
+	} else {
+		ret = rtl_pci_intr_mode_legacy(hw);
+	}
+	return ret;
+}
+
 int rtl_pci_probe(struct pci_dev *pdev,
 			    const struct pci_device_id *id)
 {
@@ -1995,8 +2054,7 @@ int rtl_pci_probe(struct pci_dev *pdev,
 	}
 
 	rtlpci = rtl_pcidev(pcipriv);
-	err = request_irq(rtlpci->pdev->irq, &_rtl_pci_interrupt,
-			  IRQF_SHARED, KBUILD_MODNAME, hw);
+	err = rtl_pci_intr_mode_decide(hw);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 			 "%s: failed to register IRQ handler\n",
@@ -2064,6 +2122,9 @@ void rtl_pci_disconnect(struct pci_dev *pdev)
 		rtlpci->irq_alloc = 0;
 	}
 
+	if (rtlpci->using_msi)
+		pci_disable_msi(rtlpci->pdev);
+
 	list_del(&rtlpriv->list);
 	if (rtlpriv->io.pci_mem_start != 0) {
 		pci_iounmap(pdev, (void __iomem *)rtlpriv->io.pci_mem_start);
-- 
1.9.1
