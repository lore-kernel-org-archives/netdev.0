From: Tim Gardner <tim.gardner@canonical.com>
Subject: [PATCH] rtlwifi: Fix PCI probe error path orphaned memory
Date: Thu,  2 Feb 2012 13:48:06 -0700
Message-ID: <1328215686-126550-1-git-send-email-tim.gardner@canonical.com>
Cc: Tim Gardner <tim.gardner@canonical.com>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Larry.Finger@lwfinger.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Memory allocated by ieee80211_alloc_hw() will get orphaned
if any subsequent initializations fail.

Also don't pci_set_drvdata(pdev, NULL) until just before disabling
the PCI device. Functions called by rtl_deinit_core(hw) may eventually need
the context (when its actually implemented).

Cc: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Chaoming Li <chaoming_li@realsil.com.cn>
Cc: John W. Linville <linville@tuxdriver.com>
Cc: linux-wireless@vger.kernel.org
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
---
 drivers/net/wireless/rtlwifi/pci.c |   19 ++++++++++++-------
 1 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index 5cb2199..6b18063 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -1760,8 +1760,8 @@ int __devinit rtl_pci_probe(struct pci_dev *pdev,
 		if (pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32))) {
 			RT_ASSERT(false,
 				  "Unable to obtain 32bit DMA for consistent allocations\n");
-			pci_disable_device(pdev);
-			return -ENOMEM;
+			err = -ENOMEM;
+			goto fail1;
 		}
 	}
 
@@ -1803,7 +1803,7 @@ int __devinit rtl_pci_probe(struct pci_dev *pdev,
 	err = pci_request_regions(pdev, KBUILD_MODNAME);
 	if (err) {
 		RT_ASSERT(false, "Can't obtain PCI resources\n");
-		goto fail2;
+		goto fail1;
 	}
 
 	pmem_start = pci_resource_start(pdev, rtlpriv->cfg->bar_id);
@@ -1816,6 +1816,7 @@ int __devinit rtl_pci_probe(struct pci_dev *pdev,
 			rtlpriv->cfg->bar_id, pmem_len);
 	if (rtlpriv->io.pci_mem_start == 0) {
 		RT_ASSERT(false, "Can't map PCI mem\n");
+		err = -ENOMEM;
 		goto fail2;
 	}
 
@@ -1832,8 +1833,10 @@ int __devinit rtl_pci_probe(struct pci_dev *pdev,
 	pci_write_config_byte(pdev, 0x04, 0x07);
 
 	/* find adapter */
-	if (!_rtl_pci_find_adapter(pdev, hw))
+	if (!_rtl_pci_find_adapter(pdev, hw)) {
+		err = -ENODEV;
 		goto fail3;
+	}
 
 	/* Init IO handler */
 	_rtl_pci_io_handler_init(&pdev->dev, hw);
@@ -1843,6 +1846,7 @@ int __devinit rtl_pci_probe(struct pci_dev *pdev,
 
 	if (rtlpriv->cfg->ops->init_sw_vars(hw)) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Can't init_sw_vars\n");
+		err = -ENODEV;
 		goto fail3;
 	}
 
@@ -1887,7 +1891,6 @@ int __devinit rtl_pci_probe(struct pci_dev *pdev,
 	return 0;
 
 fail3:
-	pci_set_drvdata(pdev, NULL);
 	rtl_deinit_core(hw);
 	_rtl_pci_io_handler_release(hw);
 
@@ -1899,10 +1902,12 @@ fail2:
 	complete(&rtlpriv->firmware_loading_complete);
 
 fail1:
-
+	if (hw)
+		ieee80211_free_hw(hw);
+	pci_set_drvdata(pdev, NULL);
 	pci_disable_device(pdev);
 
-	return -ENODEV;
+	return err;
 
 }
 EXPORT_SYMBOL(rtl_pci_probe);
-- 
1.7.8.3
