From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH V2] brcmfmac: fix setting AP channel with new firmwares
Date: Fri, 27 May 2016 21:07:19 +0200
Message-ID: <1464376045-8220-1-git-send-email-zajec5@gmail.com>
References: <1464080979-12150-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>,
	Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	linux-wireless@vger.kernel.org (open list:BROADCOM BRCM80211
	IEEE802.11n WIRELESS DRIVER),
	brcm80211-dev-list@broadcom.com (open list:BROADCOM BRCM80211
	IEEE802.11n WIRELESS DRIVER),
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
	linux-kernel@vger.kernel.org (open list)
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464080979-12150-1-git-send-email-zajec5@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46irmware for new chipsets is based on a new major version of code
internally maintained at Broadcom. E.g. brcmfmac4366b-pcie.bin (used fo=
r
BCM4366B1) is based on 10.10.69.3309 while brcmfmac43602-pcie.ap.bin wa=
s
based on 7.35.177.56.

Currently setting AP 5 GHz channel doesn't work reliably with BCM4366B1=
=2E
When setting e.g. 36 control channel with VHT80 (center channel 42)
firmware may randomly pick one of:
1) 52 control channel with 58 as center one
2) 100 control channel with 106 as center one
3) 116 control channel with 122 as center one
4) 149 control channel with 155 as center one

It seems new firmwares require setting AP mode (BRCMF_C_SET_AP) before
specifying a channel. Changing an order of firmware calls fixes the
problem. This requirement resulted in two separated "chanspec" calls,
one in AP code path and one in P2P path.

This fix was verified with BCM4366B1 and tested for regressions on
BCM43602.

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
V2: Avoid checking AP vs. P2P at two different places, just add code se=
tting
    "chanspec" to existing paths.
---
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         | 36 ++++++++++++++=
+-------
 1 file changed, 25 insertions(+), 11 deletions(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.=
c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
index 1e2527f..38df1be 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
@@ -4438,7 +4438,7 @@ brcmf_cfg80211_start_ap(struct wiphy *wiphy, stru=
ct net_device *ndev,
 	struct brcmf_join_params join_params;
 	enum nl80211_iftype dev_role;
 	struct brcmf_fil_bss_enable_le bss_enable;
-	u16 chanspec;
+	u16 chanspec =3D chandef_to_chanspec(&cfg->d11inf, &settings->chandef=
);
 	bool mbss;
 	int is_11d;
=20
@@ -4514,16 +4514,8 @@ brcmf_cfg80211_start_ap(struct wiphy *wiphy, str=
uct net_device *ndev,
=20
 	brcmf_config_ap_mgmt_ie(ifp->vif, &settings->beacon);
=20
+	/* Parameters shared by all radio interfaces */
 	if (!mbss) {
-		chanspec =3D chandef_to_chanspec(&cfg->d11inf,
-					       &settings->chandef);
-		err =3D brcmf_fil_iovar_int_set(ifp, "chanspec", chanspec);
-		if (err < 0) {
-			brcmf_err("Set Channel failed: chspec=3D%d, %d\n",
-				  chanspec, err);
-			goto exit;
-		}
-
 		if (is_11d !=3D ifp->vif->is_11d) {
 			err =3D brcmf_fil_cmd_int_set(ifp, BRCMF_C_SET_REGULATORY,
 						    is_11d);
@@ -4571,6 +4563,8 @@ brcmf_cfg80211_start_ap(struct wiphy *wiphy, stru=
ct net_device *ndev,
 		err =3D -EINVAL;
 		goto exit;
 	}
+
+	/* Interface specific setup */
 	if (dev_role =3D=3D NL80211_IFTYPE_AP) {
 		if ((brcmf_feat_is_enabled(ifp, BRCMF_FEAT_MBSS)) && (!mbss))
 			brcmf_fil_iovar_int_set(ifp, "mbss", 1);
@@ -4580,6 +4574,17 @@ brcmf_cfg80211_start_ap(struct wiphy *wiphy, str=
uct net_device *ndev,
 			brcmf_err("setting AP mode failed %d\n", err);
 			goto exit;
 		}
+		if (!mbss) {
+			/* Firmware 10.x requires setting channel after enabling
+			 * AP and before bringing interface up.
+			 */
+			err =3D brcmf_fil_iovar_int_set(ifp, "chanspec", chanspec);
+			if (err < 0) {
+				brcmf_err("Set Channel failed: chspec=3D%d, %d\n",
+					  chanspec, err);
+				goto exit;
+			}
+		}
 		err =3D brcmf_fil_cmd_int_set(ifp, BRCMF_C_UP, 1);
 		if (err < 0) {
 			brcmf_err("BRCMF_C_UP error (%d)\n", err);
@@ -4601,7 +4606,13 @@ brcmf_cfg80211_start_ap(struct wiphy *wiphy, str=
uct net_device *ndev,
 			goto exit;
 		}
 		brcmf_dbg(TRACE, "AP mode configuration complete\n");
-	} else {
+	} else if (dev_role =3D=3D NL80211_IFTYPE_P2P_GO) {
+		err =3D brcmf_fil_iovar_int_set(ifp, "chanspec", chanspec);
+		if (err < 0) {
+			brcmf_err("Set Channel failed: chspec=3D%d, %d\n",
+				  chanspec, err);
+			goto exit;
+		}
 		err =3D brcmf_fil_bsscfg_data_set(ifp, "ssid", &ssid_le,
 						sizeof(ssid_le));
 		if (err < 0) {
@@ -4618,7 +4629,10 @@ brcmf_cfg80211_start_ap(struct wiphy *wiphy, str=
uct net_device *ndev,
 		}
=20
 		brcmf_dbg(TRACE, "GO mode configuration complete\n");
+	} else {
+		WARN_ON(1);
 	}
+
 	set_bit(BRCMF_VIF_STATUS_AP_CREATED, &ifp->vif->sme_state);
 	brcmf_net_setcarrier(ifp, true);
=20
--=20
1.8.4.5
