From: =?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: [PATCH v2 01/16] wl1251: fix scan behaviour while not associated
Date: Sun,  8 Dec 2013 10:24:59 +0100
Message-ID: <1386494714-21070-2-git-send-email-pali.rohar@gmail.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f182.google.com ([209.85.215.182]:45412 "EHLO
	mail-ea0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752065Ab3LHJ1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 04:27:16 -0500
In-Reply-To: <1386494714-21070-1-git-send-email-pali.rohar@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: David Gnedt <david.gnedt@davizone.at>

With a dissacociated card I often encoutered very long scan delays.

My guess is that it has something to do with the cards DTIM handling an=
d
another firmware bug mentioned in the TI WLAN driver, which is describe=
d as
the card may never end scanning if the channel is overloaded because it
can't send probe requests. I think the firmware somehow also tries to
receive DTIM messages when the BSSID is not set. Therefore most of the =
time
it waits for DTIM messages and can't do scanning work.

Anyway we can workaround this misbehaviour by setting the HIGH_PRIORITY
bit for scans in disassociated state.

Signed-off-by: David Gnedt <david.gnedt@davizone.at>
Signed-off-by: Pali Roh=C3=A1r <pali.rohar@gmail.com>
---
 drivers/net/wireless/ti/wl1251/cmd.c  |   13 ++++++++++++-
 drivers/net/wireless/ti/wl1251/cmd.h  |    5 +++++
 drivers/net/wireless/ti/wl1251/main.c |    1 +
 3 files changed, 18 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ti/wl1251/cmd.c b/drivers/net/wireles=
s/ti/wl1251/cmd.c
index 6822b84..16b6479 100644
--- a/drivers/net/wireless/ti/wl1251/cmd.c
+++ b/drivers/net/wireless/ti/wl1251/cmd.c
@@ -3,6 +3,7 @@
 #include <linux/module.h>
 #include <linux/slab.h>
 #include <linux/crc7.h>
+#include <linux/etherdevice.h>
=20
 #include "wl1251.h"
 #include "reg.h"
@@ -410,7 +411,10 @@ int wl1251_cmd_scan(struct wl1251 *wl, u8 *ssid, s=
ize_t ssid_len,
 	struct wl1251_cmd_scan *cmd;
 	int i, ret =3D 0;
=20
-	wl1251_debug(DEBUG_CMD, "cmd scan");
+	wl1251_debug(DEBUG_CMD, "cmd scan channels %d ssid(%d) '%s'",
+		     n_channels, (int)ssid_len, ssid);
+
+	WARN_ON(n_channels > SCAN_MAX_NUM_OF_CHANNELS);
=20
 	cmd =3D kzalloc(sizeof(*cmd), GFP_KERNEL);
 	if (!cmd)
@@ -421,6 +425,13 @@ int wl1251_cmd_scan(struct wl1251 *wl, u8 *ssid, s=
ize_t ssid_len,
 						    CFG_RX_MGMT_EN |
 						    CFG_RX_BCN_EN);
 	cmd->params.scan_options =3D 0;
+	/*
+	 * Use high priority scan when not associated to prevent fw issue
+	 * causing never-ending scans (sometimes 20+ minutes).
+	 * Note: This bug may be caused by the fw's DTIM handling.
+	 */
+	if (is_zero_ether_addr(wl->bssid))
+		cmd->params.scan_options |=3D WL1251_SCAN_OPT_PRIORITY_HIGH;
 	cmd->params.num_channels =3D n_channels;
 	cmd->params.num_probe_requests =3D n_probes;
 	cmd->params.tx_rate =3D cpu_to_le16(1 << 1); /* 2 Mbps */
diff --git a/drivers/net/wireless/ti/wl1251/cmd.h b/drivers/net/wireles=
s/ti/wl1251/cmd.h
index ee4f2b3..126f273 100644
--- a/drivers/net/wireless/ti/wl1251/cmd.h
+++ b/drivers/net/wireless/ti/wl1251/cmd.h
@@ -167,6 +167,11 @@ struct cmd_read_write_memory {
 #define CMDMBOX_HEADER_LEN 4
 #define CMDMBOX_INFO_ELEM_HEADER_LEN 4
=20
+#define WL1251_SCAN_OPT_PASSIVE		1
+#define WL1251_SCAN_OPT_5GHZ_BAND	2
+#define WL1251_SCAN_OPT_TRIGGERD_SCAN	4
+#define WL1251_SCAN_OPT_PRIORITY_HIGH	8
+
 #define WL1251_SCAN_MIN_DURATION 30000
 #define WL1251_SCAN_MAX_DURATION 60000
=20
diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wirele=
ss/ti/wl1251/main.c
index 3291ffa..4d89ac8 100644
--- a/drivers/net/wireless/ti/wl1251/main.c
+++ b/drivers/net/wireless/ti/wl1251/main.c
@@ -930,6 +930,7 @@ static int wl1251_op_hw_scan(struct ieee80211_hw *h=
w,
 	ret =3D wl1251_cmd_scan(wl, ssid, ssid_len, req->channels,
 			      req->n_channels, WL1251_SCAN_NUM_PROBES);
 	if (ret < 0) {
+		wl1251_debug(DEBUG_SCAN, "scan failed %d", ret);
 		wl->scanning =3D false;
 		goto out_idle;
 	}
--=20
1.7.9.5
