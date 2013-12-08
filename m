From: =?UTF-8?q?Pali=20Roh=C3=A1r?= <pali.rohar@gmail.com>
Subject: [PATCH v2 11/16] wl1251: disable retry and ACK policy for injected packets
Date: Sun,  8 Dec 2013 10:25:09 +0100
Message-ID: <1386494714-21070-12-git-send-email-pali.rohar@gmail.com>
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
Received: from mail-ea0-f179.google.com ([209.85.215.179]:45439 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754614Ab3LHJ1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 04:27:30 -0500
In-Reply-To: <1386494714-21070-1-git-send-email-pali.rohar@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: David Gnedt <david.gnedt@davizone.at>

Set the retry limit to 0 and disable the ACK policy for injected packet=
s.

Signed-off-by: David Gnedt <david.gnedt@davizone.at>
Signed-off-by: Pali Roh=C3=A1r <pali.rohar@gmail.com>
---
 drivers/net/wireless/ti/wl1251/acx.c |    8 +++++++-
 drivers/net/wireless/ti/wl1251/tx.c  |    7 ++++++-
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ti/wl1251/acx.c b/drivers/net/wireles=
s/ti/wl1251/acx.c
index f772e62..8f420d0 100644
--- a/drivers/net/wireless/ti/wl1251/acx.c
+++ b/drivers/net/wireless/ti/wl1251/acx.c
@@ -943,12 +943,18 @@ int wl1251_acx_rate_policies(struct wl1251 *wl)
 	}
=20
 	/* configure one default (one-size-fits-all) rate class */
-	acx->rate_class_cnt =3D 1;
+	acx->rate_class_cnt =3D 2;
 	acx->rate_class[0].enabled_rates =3D ACX_RATE_MASK_UNSPECIFIED;
 	acx->rate_class[0].short_retry_limit =3D ACX_RATE_RETRY_LIMIT;
 	acx->rate_class[0].long_retry_limit =3D ACX_RATE_RETRY_LIMIT;
 	acx->rate_class[0].aflags =3D 0;
=20
+	/* no-retry rate class */
+	acx->rate_class[1].enabled_rates =3D ACX_RATE_MASK_UNSPECIFIED;
+	acx->rate_class[1].short_retry_limit =3D 0;
+	acx->rate_class[1].long_retry_limit =3D 0;
+	acx->rate_class[1].aflags =3D 0;
+
 	ret =3D wl1251_cmd_configure(wl, ACX_RATE_POLICY, acx, sizeof(*acx));
 	if (ret < 0) {
 		wl1251_warning("Setting of rate policies failed: %d", ret);
diff --git a/drivers/net/wireless/ti/wl1251/tx.c b/drivers/net/wireless=
/ti/wl1251/tx.c
index 216334d..4516180 100644
--- a/drivers/net/wireless/ti/wl1251/tx.c
+++ b/drivers/net/wireless/ti/wl1251/tx.c
@@ -90,8 +90,12 @@ static void wl1251_tx_control(struct tx_double_buffe=
r_desc *tx_hdr,
 	/* 802.11 packets */
 	tx_hdr->control.packet_type =3D 0;
=20
-	if (control->flags & IEEE80211_TX_CTL_NO_ACK)
+	/* Also disable retry and ACK policy for injected packets */
+	if ((control->flags & IEEE80211_TX_CTL_NO_ACK) ||
+	    (control->flags & IEEE80211_TX_CTL_INJECTED)) {
+		tx_hdr->control.rate_policy =3D 1;
 		tx_hdr->control.ack_policy =3D 1;
+	}
=20
 	tx_hdr->control.tx_complete =3D 1;
=20
@@ -422,6 +426,7 @@ static void wl1251_tx_packet_cb(struct wl1251 *wl,
 	info =3D IEEE80211_SKB_CB(skb);
=20
 	if (!(info->flags & IEEE80211_TX_CTL_NO_ACK) &&
+	    !(info->flags & IEEE80211_TX_CTL_INJECTED) &&
 	    (result->status =3D=3D TX_SUCCESS))
 		info->flags |=3D IEEE80211_TX_STAT_ACK;
=20
--=20
1.7.9.5
