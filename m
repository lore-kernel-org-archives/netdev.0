From: Zoran Markovic <zoran.markovic-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [RFC PATCH] net: wireless: move regulatory timeout work to power efficient workqueue
Date: Thu, 30 Jan 2014 15:08:30 -0800
Message-ID: <1391123310-6425-1-git-send-email-zoran.markovic@linaro.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Shaibal Dutta <shaibal.dutta-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Zoran Markovic <zoran.markovic-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Shaibal Dutta <shaibal.dutta-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>

For better use of CPU idle time, allow the scheduler to select the CPU
on which the timeout work of regulatory settings would be executed.
This extends CPU idle residency time and saves power.

This functionality is enabled when CONFIG_WQ_POWER_EFFICIENT is selected.

Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Cc: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Signed-off-by: Shaibal Dutta <shaibal.dutta-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
[zoran.markovic-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org: Rebased to latest kernel. Added commit message.]
Signed-off-by: Zoran Markovic <zoran.markovic-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 net/wireless/reg.c |    9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 9b897fc..6e21011 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -1703,7 +1703,8 @@ static void reg_process_hint(struct regulatory_request *reg_request)
 		if (treatment == REG_REQ_OK ||
 		    treatment == REG_REQ_ALREADY_SET)
 			return;
-		schedule_delayed_work(&reg_timeout, msecs_to_jiffies(3142));
+		queue_delayed_work(system_power_efficient_wq,
+				   &reg_timeout, msecs_to_jiffies(3142));
 		return;
 	case NL80211_REGDOM_SET_BY_DRIVER:
 		treatment = reg_process_hint_driver(wiphy, reg_request);
@@ -2294,7 +2295,8 @@ static int reg_set_rd_driver(const struct ieee80211_regdomain *rd,
 
 	request_wiphy = wiphy_idx_to_wiphy(driver_request->wiphy_idx);
 	if (!request_wiphy) {
-		schedule_delayed_work(&reg_timeout, 0);
+		queue_delayed_work(system_power_efficient_wq,
+				   &reg_timeout, 0);
 		return -ENODEV;
 	}
 
@@ -2354,7 +2356,8 @@ static int reg_set_rd_country_ie(const struct ieee80211_regdomain *rd,
 
 	request_wiphy = wiphy_idx_to_wiphy(country_ie_request->wiphy_idx);
 	if (!request_wiphy) {
-		schedule_delayed_work(&reg_timeout, 0);
+		queue_delayed_work(system_power_efficient_wq,
+				   &reg_timeout, 0);
 		return -ENODEV;
 	}
 
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
