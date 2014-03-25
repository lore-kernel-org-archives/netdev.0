From: Adam Lee <adam.lee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH v2] rtlwifi: add MSI interrupts support
Date: Tue, 25 Mar 2014 10:48:52 +0800
Message-ID: <1395715732-9545-1-git-send-email-adam.lee@canonical.com>
References: <1395660884-15042-1-git-send-email-adam.lee@canonical.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1395660884-15042-1-git-send-email-adam.lee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add MSI interrupts support, enable it when msi_support flag is true,
also could fallback to pin-based interrupts mode if MSI mode fails.

Signed-off-by: Adam Lee <adam.lee-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Cc: <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org> [3.10+]
---
 drivers/net/wireless/rtlwifi/pci.c | 65 ++++++++++++++++++++++++++++++++++++--
 1 file changed, 63 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index f26f4ff..155d010 100644
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

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
