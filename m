From: Alexey Khoroshilov <khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org>
Subject: [PATCH] carl9170: Fix mismatch in carl9170_op_set_key mutex lock-unlock
Date: Wed, 24 Aug 2011 00:44:32 +0400
Message-ID: <1314132272-7357-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ldv-project-ufN2psIa012HXe+LvDLADg@public.gmane.org
To: Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

If is_main_vif(ar, vif) reports that we have to fall back
to software encryption, we goto err_softw; before locking ar->mutex.
As a result, we have unprotected call to carl9170_set_operating_mode
and unmatched mutex_unlock.

The patch fix the issue by adding mutex_lock before goto.

Found by Linux Driver Verification project (linuxtesting.org).

Signed-off-by: Alexey Khoroshilov <khoroshilov-ufN2psIa012HXe+LvDLADg@public.gmane.org>
---
 drivers/net/wireless/ath/carl9170/main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/ath/carl9170/main.c b/drivers/net/wireless/ath/carl9170/main.c
index 0122930..0474e663 100644
--- a/drivers/net/wireless/ath/carl9170/main.c
+++ b/drivers/net/wireless/ath/carl9170/main.c
@@ -1066,8 +1066,10 @@ static int carl9170_op_set_key(struct ieee80211_hw *hw, enum set_key_cmd cmd,
 	 * the high througput speed in 802.11n networks.
 	 */
 
-	if (!is_main_vif(ar, vif))
+	if (!is_main_vif(ar, vif)) {
+		mutex_lock(&ar->mutex);
 		goto err_softw;
+	}
 
 	/*
 	 * While the hardware supports *catch-all* key, for offloading
-- 
1.7.4.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
