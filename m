From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 2/2 3.18] rtlwifi: Change order in device startup
Date: Tue, 25 Nov 2014 10:32:07 -0600
Message-ID: <1416933127-25912-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1416933127-25912-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Valerio Passini <valerio.passini@unicam.it>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:64393 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151AbaKYQcT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 11:32:19 -0500
In-Reply-To: <1416933127-25912-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The existing order of steps when starting the PCI devices works for
2.4G devices, but fails to initialize the 5G section of the RTL8821AE
hardware.

This patch is needed to fix the regression reported in Bug #88811
(https://bugzilla.kernel.org/show_bug.cgi?id=88811).

Reported-by: Valerio Passini <valerio.passini@unicam.it>
Tested-by: Valerio Passini <valerio.passini@unicam.it>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Valerio Passini <valerio.passini@unicam.it>
---
 drivers/net/wireless/rtlwifi/pci.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index 61f5d36..846a2e6 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -2249,6 +2249,16 @@ int rtl_pci_probe(struct pci_dev *pdev,
 	/*like read eeprom and so on */
 	rtlpriv->cfg->ops->read_eeprom_info(hw);
 
+	if (rtlpriv->cfg->ops->init_sw_vars(hw)) {
+		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Can't init_sw_vars\n");
+		err = -ENODEV;
+		goto fail3;
+	}
+	rtlpriv->cfg->ops->init_sw_leds(hw);
+
+	/*aspm */
+	rtl_pci_init_aspm(hw);
+
 	/* Init mac80211 sw */
 	err = rtl_init_core(hw);
 	if (err) {
@@ -2264,16 +2274,6 @@ int rtl_pci_probe(struct pci_dev *pdev,
 		goto fail3;
 	}
 
-	if (rtlpriv->cfg->ops->init_sw_vars(hw)) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG, "Can't init_sw_vars\n");
-		err = -ENODEV;
-		goto fail3;
-	}
-	rtlpriv->cfg->ops->init_sw_leds(hw);
-
-	/*aspm */
-	rtl_pci_init_aspm(hw);
-
 	err = ieee80211_register_hw(hw);
 	if (err) {
 		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-- 
2.1.2
