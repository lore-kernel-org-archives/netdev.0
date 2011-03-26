From: Mariusz Kozlowski <mk@lab.zgora.pl>
Subject: [PATCH] cfg80211:: fix possible NULL pointer dereference
Date: Sat, 26 Mar 2011 19:26:55 +0100
Message-ID: <1301164015-7978-1-git-send-email-mk@lab.zgora.pl>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Mariusz Kozlowski <mk@lab.zgora.pl>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In cfg80211_inform_bss_frame() wiphy is first dereferenced on privsz
initialisation and then it is checked for NULL. This patch fixes that.

Signed-off-by: Mariusz Kozlowski <mk@lab.zgora.pl>
---
 net/wireless/scan.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/wireless/scan.c b/net/wireless/scan.c
index ea427f4..300c11d 100644
--- a/net/wireless/scan.c
+++ b/net/wireless/scan.c
@@ -585,16 +585,23 @@ cfg80211_inform_bss_frame(struct wiphy *wiphy,
 	struct cfg80211_internal_bss *res;
 	size_t ielen = len - offsetof(struct ieee80211_mgmt,
 				      u.probe_resp.variable);
-	size_t privsz = wiphy->bss_priv_size;
+	size_t privsz;
+
+	if (WARN_ON(!mgmt))
+		return NULL;
+
+	if (WARN_ON(!wiphy))
+		return NULL;
 
 	if (WARN_ON(wiphy->signal_type == CFG80211_SIGNAL_TYPE_UNSPEC &&
 	            (signal < 0 || signal > 100)))
 		return NULL;
 
-	if (WARN_ON(!mgmt || !wiphy ||
-		    len < offsetof(struct ieee80211_mgmt, u.probe_resp.variable)))
+	if (WARN_ON(len < offsetof(struct ieee80211_mgmt, u.probe_resp.variable)))
 		return NULL;
 
+	privsz = wiphy->bss_priv_size;
+
 	res = kzalloc(sizeof(*res) + privsz + ielen, gfp);
 	if (!res)
 		return NULL;
-- 
1.7.0.4
