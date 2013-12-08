From: =?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: [PATCH v2 12/16] wl1251: enforce changed hw encryption support on monitor state change
Date: Sun,  8 Dec 2013 10:25:10 +0100
Message-ID: <1386494714-21070-13-git-send-email-pali.rohar@gmail.com>
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

The firmware doesn't support per packet encryption selection, so disabl=
e hw
encryption support completely while a monitor interface is present to s=
upport
injection of packets (which shouldn't get encrypted by hw).
To enforce the changed hw encryption support force a disassociation on
non-monitor interfaces.
=46or disassociation a workaround using hw connection monitor is employ=
ed,
which temporary enables hw connection manager flag.

Signed-off-by: David Gnedt <david.gnedt@davizone.at>
Signed-off-by: Pali Roh=C3=A1r <pali.rohar@gmail.com>
---
 drivers/net/wireless/ti/wl1251/main.c |   13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wirele=
ss/ti/wl1251/main.c
index bb6e873..1ef264c 100644
--- a/drivers/net/wireless/ti/wl1251/main.c
+++ b/drivers/net/wireless/ti/wl1251/main.c
@@ -688,6 +688,16 @@ static int wl1251_op_config(struct ieee80211_hw *h=
w, u32 changed)
 		wl->power_level =3D conf->power_level;
 	}
=20
+	/*
+	 * Tell stack that connection is lost because hw encryption isn't
+	 * supported in monitor mode.
+	 * This requires temporary enabling of the hw connection monitor flag
+	 */
+	if ((changed & IEEE80211_CONF_CHANGE_MONITOR) && wl->vif) {
+		wl->hw->flags |=3D IEEE80211_HW_CONNECTION_MONITOR;
+		ieee80211_connection_loss(wl->vif);
+	}
+
 out_sleep:
 	wl1251_ps_elp_sleep(wl);
=20
@@ -1120,6 +1130,9 @@ static void wl1251_op_bss_info_changed(struct iee=
e80211_hw *hw,
 	}
=20
 	if (changed & BSS_CHANGED_ASSOC) {
+		/* Disable temporary enabled hw connection monitor flag */
+		wl->hw->flags &=3D ~IEEE80211_HW_CONNECTION_MONITOR;
+
 		if (bss_conf->assoc) {
 			wl->beacon_int =3D bss_conf->beacon_int;
=20
--=20
1.7.9.5
