From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH V4.2] rtlwifi: Fix NULL dereference when PCI driver used as an AP
Date: Wed, 29 Jul 2015 21:11:20 -0500
Message-ID: <1438222280-4146-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Luis Felipe Dominguez Vega <lfdominguez-UMrjrmwGhSo@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Luis Felipe Dominguez Vega <lfdominguez-UMrjrmwGhSo@public.gmane.org>

In commit 33511b157bbcebaef853cc1811992b664a2e5862 ("rtlwifi: add support to
send beacon frame"), the mechanism for sending beacons was established. That
patch works correctly for rtl8192cu, but there is a possibility of getting
the following warnings in the PCI drivers:

WARNING: CPU: 1 PID: 2439 at net/mac80211/driver-ops.h:12
ieee80211_bss_info_change_notify+0x179/0x1d0 [mac80211]()
wlp5s0:  Failed check-sdata-in-driver check, flags: 0x0

The warning is followed by a NULL pointer dereference as follows:

BUG: unable to handle kernel NULL pointer dereference at 0000000000000006
IP: [<ffffffffc073998e>] rtl_get_tcb_desc+0x5e/0x760 [rtlwifi]

This problem was reported at http://thread.gmane.org/gmane.linux.kernel.wireless.general/138645,
but no solution was found at that time.

The problem was also reported at https://bugzilla.kernel.org/show_bug.cgi?id=9744
and this solution was developed and tested there.

The USB driver works with a NULL final argument in the adapter_tx() callback;
however, the PCI drivers need a struct rtl_tcb_desc in that position.

Signed-off-by: Luis Felipe Dominguez Vega <lfdominguez-UMrjrmwGhSo@public.gmane.org>
Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Cc: Stable <stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org> [3.19+]
---

Kalle,

I have marked this fix for V4.2, and I hope it will make it.

Thanks,

Larry
---
 drivers/net/wireless/rtlwifi/core.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/core.c b/drivers/net/wireless/rtlwifi/core.c
index 3b3a88b..585d088 100644
--- a/drivers/net/wireless/rtlwifi/core.c
+++ b/drivers/net/wireless/rtlwifi/core.c
@@ -1015,9 +1015,12 @@ static void send_beacon_frame(struct ieee80211_hw *hw,
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct sk_buff *skb = ieee80211_beacon_get(hw, vif);
+	struct rtl_tcb_desc tcb_desc;
 
-	if (skb)
-		rtlpriv->intf_ops->adapter_tx(hw, NULL, skb, NULL);
+	if (skb) {
+		memset(&tcb_desc, 0, sizeof(struct rtl_tcb_desc));
+		rtlpriv->intf_ops->adapter_tx(hw, NULL, skb, &tcb_desc);
+	}
 }
 
 static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
