From: Andrew Bresticker <abrestic@chromium.org>
Subject: [PATCH] mac80211_hwsim: fix compiler warning on MIPS
Date: Tue, 22 Jul 2014 14:43:51 -0700
Message-ID: <1406065431-20813-1-git-send-email-abrestic@chromium.org>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Andrew Bresticker <abrestic@chromium.org>
To: "John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes.berg@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dividend in do_div() is expected to be an unsigned 64-bit integer,
which leads to the following warning when building for 32-bit MIPS:

  drivers/net/wireless/mac80211_hwsim.c: In function 'mac80211_hwsim_set_tsf':
  drivers/net/wireless/mac80211_hwsim.c:664:98: warning: comparison of distinct pointer types lacks a cast [enabled by default]
    data->bcn_delta = do_div(delta, bcn_int);

Since we care about the signedness of delta when adjusting tsf_offset
and bcm_delta, use the absolute value for the division and compare
the two timestamps to determine the sign.

Signed-off-by: Andrew Bresticker <abrestic@chromium.org>
---
 drivers/net/wireless/mac80211_hwsim.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 5ea65fc..1326f61 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -685,11 +685,16 @@ static void mac80211_hwsim_set_tsf(struct ieee80211_hw *hw,
 	struct mac80211_hwsim_data *data = hw->priv;
 	u64 now = mac80211_hwsim_get_tsf(hw, vif);
 	u32 bcn_int = data->beacon_int;
-	s64 delta = tsf - now;
+	u64 delta = abs64(tsf - now);
 
-	data->tsf_offset += delta;
 	/* adjust after beaconing with new timestamp at old TBTT */
-	data->bcn_delta = do_div(delta, bcn_int);
+	if (tsf > now) {
+		data->tsf_offset += delta;
+		data->bcn_delta = do_div(delta, bcn_int);
+	} else {
+		data->tsf_offset -= delta;
+		data->bcn_delta = -do_div(delta, bcn_int);
+	}
 }
 
 static void mac80211_hwsim_monitor_rx(struct ieee80211_hw *hw,
-- 
2.0.0.526.g5318336
