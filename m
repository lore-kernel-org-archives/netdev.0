From: Adam Lee <adam.lee@canonical.com>
Subject: [PATCH] rtlwifi: add MSI interrupts support
Date: Mon, 24 Mar 2014 19:34:44 +0800
Message-ID: <1395660884-15042-1-git-send-email-adam.lee@canonical.com>
References: <1395640841-14477-1-git-send-email-adam.lee@canonical.com>
Cc: netdev@vger.kernel.org, Larry Finger <Larry.Finger@lwfinger.net>,
	stable@kernel.org, "John W. Linville" <linville@tuxdriver.com>,
	Chaoming Li <chaoming_li@realsil.com.cn>
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:46089 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752385AbaCXLfB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 07:35:01 -0400
Received: by mail-pa0-f48.google.com with SMTP id hz1so5332841pad.35
        for <netdev@vger.kernel.org>; Mon, 24 Mar 2014 04:35:00 -0700 (PDT)
In-Reply-To: <1395640841-14477-1-git-send-email-adam.lee@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add MSI interrupts support, enable it when msi_support flag is true,
also could fallback to pin-based interrupts mode if MSI mode fails.

Signed-off-by: Adam Lee <adam.lee@canonical.com>
---
 drivers/net/wireless/rtlwifi/pci.c | 63 ++++++++++++++++++++++++++++++++++++--
 1 file changed, 61 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index f26f4ff..dd8497a 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -1853,6 +1853,63 @@ static bool _rtl_pci_find_adapter(struct pci_dev *pdev,
 	return true;
 }
 
+static int rtl_pci_intr_mode_msi(struct ieee80211_hw *hw)
+{
+	struct rtl_priv *rtlpriv = rtl_priv(hw);
+	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
+	struct rtl_pci *rtlpci = rtl_pcidev(pcipriv);
+	int ret;
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
+			("MSI Interrupt Mode!\n"));
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
+		 ("Pin-based Interrupt Mode!\n"));
+	return 0;
+}
+
+static int rtl_pci_intr_mode_decide(struct ieee80211_hw *hw)
+{
+	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
+	struct rtl_pci *rtlpci = rtl_pcidev(pcipriv);
+	int ret;
+	if (rtlpci->msi_support == true) {
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
@@ -1995,8 +2052,7 @@ int rtl_pci_probe(struct pci_dev *pdev,
 	}
 
 	rtlpci = rtl_pcidev(pcipriv);
-	err = request_irq(rtlpci->pdev->irq, &_rtl_pci_interrupt,
-			  IRQF_SHARED, KBUILD_MODNAME, hw);
+	err = rtl_pci_intr_mode_decide(hw);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG,
 			 "%s: failed to register IRQ handler\n",
@@ -2064,6 +2120,9 @@ void rtl_pci_disconnect(struct pci_dev *pdev)
 		rtlpci->irq_alloc = 0;
 	}
 
+	if (rtlpci->using_msi == true)
+		pci_disable_msi(rtlpci->pdev);
+
 	list_del(&rtlpriv->list);
 	if (rtlpriv->io.pci_mem_start != 0) {
 		pci_iounmap(pdev, (void __iomem *)rtlpriv->io.pci_mem_start);
-- 
1.9.1
