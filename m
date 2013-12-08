From: =?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: [PATCH v2 10/16] wl1251: enable tx path in monitor mode if necessary for packet injection
Date: Sun,  8 Dec 2013 10:25:08 +0100
Message-ID: <1386494714-21070-11-git-send-email-pali.rohar@gmail.com>
References: <1382819655-30430-1-git-send-email-pali.rohar@gmail.com>
 <1386494714-21070-1-git-send-email-pali.rohar@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, freemangordon@abv.bg,
	aaro.koskinen@iki.fi, pavel@ucw.cz, sre@ring0.de,
	joni.lapilainen@gmail.com,
	Johannes Berg <johannes@sipsolutions.net>,
	Felipe Contreras <felipe.contreras@gmail.com>,
	David Gnedt <david.gnedt@davizone.at>,
	=?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar@gmail.com>
To: Luciano Coelho <luca@coelho.fi>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386494714-21070-1-git-send-email-pali.rohar@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: David Gnedt <david.gnedt@davizone.at>

If necessary enable the tx path in monitor mode for packet injection us=
ing
the JOIN command with BSS_TYPE_STA_BSS and zero BSSID.

Signed-off-by: David Gnedt <david.gnedt@davizone.at>
Signed-off-by: Pali Roh=C3=A1r <pali.rohar@gmail.com>
---
 drivers/net/wireless/ti/wl1251/main.c   |    5 +++++
 drivers/net/wireless/ti/wl1251/tx.c     |   25 +++++++++++++++++++++++=
++
 drivers/net/wireless/ti/wl1251/wl1251.h |    1 +
 3 files changed, 31 insertions(+)

diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wirele=
ss/ti/wl1251/main.c
index b6f11b8..bb6e873 100644
--- a/drivers/net/wireless/ti/wl1251/main.c
+++ b/drivers/net/wireless/ti/wl1251/main.c
@@ -487,6 +487,7 @@ static void wl1251_op_stop(struct ieee80211_hw *hw)
 	wl->rssi_thold =3D 0;
 	wl->channel =3D WL1251_DEFAULT_CHANNEL;
 	wl->monitor_present =3D false;
+	wl->joined =3D false;
=20
 	wl1251_debugfs_reset(wl);
=20
@@ -546,6 +547,7 @@ static void wl1251_op_remove_interface(struct ieee8=
0211_hw *hw,
 	mutex_lock(&wl->mutex);
 	wl1251_debug(DEBUG_MAC80211, "mac80211 remove interface");
 	wl->vif =3D NULL;
+	memset(wl->bssid, 0, ETH_ALEN);
 	mutex_unlock(&wl->mutex);
 }
=20
@@ -624,6 +626,7 @@ static int wl1251_op_config(struct ieee80211_hw *hw=
, u32 changed)
 		 * at firmware level.
 		 */
 		if (wl->vif =3D=3D NULL) {
+			wl->joined =3D false;
 			ret =3D wl1251_cmd_data_path_rx(wl, wl->channel, 1);
 		} else {
 			ret =3D wl1251_join(wl, wl->bss_type, wl->channel,
@@ -1612,7 +1615,9 @@ struct ieee80211_hw *wl1251_alloc_hw(void)
 	INIT_DELAYED_WORK(&wl->elp_work, wl1251_elp_work);
 	wl->channel =3D WL1251_DEFAULT_CHANNEL;
 	wl->monitor_present =3D false;
+	wl->joined =3D false;
 	wl->scanning =3D false;
+	wl->bss_type =3D MAX_BSS_TYPE;
 	wl->default_key =3D 0;
 	wl->listen_int =3D 1;
 	wl->rx_counter =3D 0;
diff --git a/drivers/net/wireless/ti/wl1251/tx.c b/drivers/net/wireless=
/ti/wl1251/tx.c
index 3cc82fd..216334d 100644
--- a/drivers/net/wireless/ti/wl1251/tx.c
+++ b/drivers/net/wireless/ti/wl1251/tx.c
@@ -28,6 +28,7 @@
 #include "tx.h"
 #include "ps.h"
 #include "io.h"
+#include "event.h"
=20
 static bool wl1251_tx_double_buffer_busy(struct wl1251 *wl, u32 data_o=
ut_count)
 {
@@ -277,6 +278,26 @@ static void wl1251_tx_trigger(struct wl1251 *wl)
 		TX_STATUS_DATA_OUT_COUNT_MASK;
 }
=20
+static void enable_tx_for_packet_injection(struct wl1251 *wl)
+{
+	int ret;
+
+	ret =3D wl1251_cmd_join(wl, BSS_TYPE_STA_BSS, wl->channel,
+			      wl->beacon_int, wl->dtim_period);
+	if (ret < 0) {
+		wl1251_warning("join failed");
+		return;
+	}
+
+	ret =3D wl1251_event_wait(wl, JOIN_EVENT_COMPLETE_ID, 100);
+	if (ret < 0) {
+		wl1251_warning("join timeout");
+		return;
+	}
+
+	wl->joined =3D true;
+}
+
 /* caller must hold wl->mutex */
 static int wl1251_tx_frame(struct wl1251 *wl, struct sk_buff *skb)
 {
@@ -298,6 +319,10 @@ static int wl1251_tx_frame(struct wl1251 *wl, stru=
ct sk_buff *skb)
 		}
 	}
=20
+	/* Enable tx path in monitor mode for packet injection */
+	if ((wl->vif =3D=3D NULL) && !wl->joined)
+		enable_tx_for_packet_injection(wl);
+
 	ret =3D wl1251_tx_path_status(wl);
 	if (ret < 0)
 		return ret;
diff --git a/drivers/net/wireless/ti/wl1251/wl1251.h b/drivers/net/wire=
less/ti/wl1251/wl1251.h
index 93c18d2..89f07f6 100644
--- a/drivers/net/wireless/ti/wl1251/wl1251.h
+++ b/drivers/net/wireless/ti/wl1251/wl1251.h
@@ -311,6 +311,7 @@ struct wl1251 {
 	u8 listen_int;
 	int channel;
 	bool monitor_present;
+	bool joined;
=20
 	void *target_mem_map;
 	struct acx_data_path_params_resp *data_path;
--=20
1.7.9.5
