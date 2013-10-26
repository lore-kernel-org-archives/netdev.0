From: =?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: [PATCH 10/16] wl1251: fix channel switching in monitor mode
Date: Sat, 26 Oct 2013 22:34:09 +0200
Message-ID: <1382819655-30430-11-git-send-email-pali.rohar@gmail.com>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, pavel@ucw.cz, sre@ring0.de,
	joni.lapilainen@gmail.com, pali.rohar@gmail.com,
	David Gnedt <david.gnedt@davizone.at>
To: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Gnedt <david.gnedt@davizone.at>

Use the ENABLE_RX command for channel switching when no interface is present
(monitor mode only).
The advantage of ENABLE_RX is that it leaves the tx data path disabled in
firmware, whereas the usual JOIN command seems to transmit some frames at
firmware level.

Signed-off-by: David Gnedt <david.gnedt@davizone.at>
---
 drivers/net/wireless/ti/wl1251/main.c |   15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wireless/ti/wl1251/main.c
index 62cb374..7e6b6d1 100644
--- a/drivers/net/wireless/ti/wl1251/main.c
+++ b/drivers/net/wireless/ti/wl1251/main.c
@@ -611,8 +611,19 @@ static int wl1251_op_config(struct ieee80211_hw *hw, u32 changed)
 	if (channel != wl->channel) {
 		wl->channel = channel;
 
-		ret = wl1251_join(wl, wl->bss_type, wl->channel,
-				  wl->beacon_int, wl->dtim_period);
+		/*
+		 * Use ENABLE_RX command for channel switching when no
+		 * interface is present (monitor mode only).
+		 * This leaves the tx path disabled in firmware, whereas
+		 * the usual JOIN command seems to transmit some frames
+		 * at firmware level.
+		 */
+		if (wl->vif == NULL) {
+			ret = wl1251_cmd_data_path_rx(wl, wl->channel, 1);
+		} else {
+			ret = wl1251_join(wl, wl->bss_type, wl->channel,
+					  wl->beacon_int, wl->dtim_period);
+		}
 		if (ret < 0)
 			goto out_sleep;
 	}
-- 
1.7.10.4
