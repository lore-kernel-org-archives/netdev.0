From: =?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: [PATCH v2 09/16] wl1251: fix channel switching in monitor mode
Date: Sun,  8 Dec 2013 10:25:07 +0100
Message-ID: <1386494714-21070-10-git-send-email-pali.rohar@gmail.com>
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

Use the ENABLE_RX command for channel switching when no interface is pr=
esent
(monitor mode only).
The advantage of ENABLE_RX is that it leaves the tx data path disabled =
in
firmware, whereas the usual JOIN command seems to transmit some frames =
at
firmware level.

Signed-off-by: David Gnedt <david.gnedt@davizone.at>
Signed-off-by: Pali Roh=C3=A1r <pali.rohar@gmail.com>
---
 drivers/net/wireless/ti/wl1251/main.c |   15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wirele=
ss/ti/wl1251/main.c
index 1223bc6..b6f11b8 100644
--- a/drivers/net/wireless/ti/wl1251/main.c
+++ b/drivers/net/wireless/ti/wl1251/main.c
@@ -616,8 +616,19 @@ static int wl1251_op_config(struct ieee80211_hw *h=
w, u32 changed)
 	if (channel !=3D wl->channel) {
 		wl->channel =3D channel;
=20
-		ret =3D wl1251_join(wl, wl->bss_type, wl->channel,
-				  wl->beacon_int, wl->dtim_period);
+		/*
+		 * Use ENABLE_RX command for channel switching when no
+		 * interface is present (monitor mode only).
+		 * This leaves the tx path disabled in firmware, whereas
+		 * the usual JOIN command seems to transmit some frames
+		 * at firmware level.
+		 */
+		if (wl->vif =3D=3D NULL) {
+			ret =3D wl1251_cmd_data_path_rx(wl, wl->channel, 1);
+		} else {
+			ret =3D wl1251_join(wl, wl->bss_type, wl->channel,
+					  wl->beacon_int, wl->dtim_period);
+		}
 		if (ret < 0)
 			goto out_sleep;
 	}
--=20
1.7.9.5
