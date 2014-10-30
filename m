From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 2/6 V3.18] rtlwifi: rtl8192se: Fix duplicate calls to ieee80211_register_hw()
Date: Wed, 29 Oct 2014 23:17:09 -0500
Message-ID: <1414642633-3700-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1414642633-3700-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Murilo Opsfelder Araujo <mopsfelder-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1414642633-3700-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Driver rtlwifi has been modified to call ieee80211_register_hw()
from the probe routine; however, the existing call in the callback
routine for deferred firmware loading was not removed.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Cc: Murilo Opsfelder Araujo <mopsfelder-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c | 17 -----------------
 1 file changed, 17 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
index 5e16984..1fd2208 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
@@ -87,11 +87,8 @@ static void rtl92s_init_aspm_vars(struct ieee80211_hw *hw)
 static void rtl92se_fw_cb(const struct firmware *firmware, void *context)
 {
 	struct ieee80211_hw *hw = context;
-	struct rtl_pci_priv *pcipriv = rtl_pcipriv(hw);
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
-	struct rtl_pci *rtlpci = rtl_pcidev(pcipriv);
 	struct rt_firmware *pfirmware = NULL;
-	int err;
 
 	RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
 			 "Firmware callback routine entered!\n");
@@ -112,20 +109,6 @@ static void rtl92se_fw_cb(const struct firmware *firmware, void *context)
 	memcpy(pfirmware->sz_fw_tmpbuffer, firmware->data, firmware->size);
 	pfirmware->sz_fw_tmpbufferlen = firmware->size;
 	release_firmware(firmware);
-
-	err = ieee80211_register_hw(hw);
-	if (err) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "Can't register mac80211 hw\n");
-		return;
-	} else {
-		rtlpriv->mac80211.mac80211_registered = 1;
-	}
-	rtlpci->irq_alloc = 1;
-	set_bit(RTL_STATUS_INTERFACE_START, &rtlpriv->status);
