From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH] brcmfmac: respect hidden_ssid for AP interfaces
Date: Wed,  6 Jul 2016 12:22:54 +0200
Message-ID: <1467800585-10678-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>,
	Arend van Spriel <arend.vanspriel@broadcom.com>,
	Franky Lin <franky.lin@broadcom.com>,
	Hante Meuleman <hante.meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	linux-wireless@vger.kernel.org (open list:BROADCOM BRCM80211
	IEEE802.11n WIRELESS DRIVER),
	brcm80211-dev-list.pdl@broadcom.com (open list:BROADCOM BRCM80211
	IEEE802.11n WIRELESS DRIVER),
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
	linux-kernel@vger.kernel.org (open list)
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This was succesfully tested with 4366B1. A small workaround is needed
for the main interface otherwise it would stuck at the hidden state.

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c | 13 +++++=
++++++++
 1 file changed, 13 insertions(+)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.=
c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
index 6e6066a..8d1328f 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
@@ -4662,6 +4662,15 @@ brcmf_cfg80211_start_ap(struct wiphy *wiphy, str=
uct net_device *ndev,
 			brcmf_err("SET SSID error (%d)\n", err);
 			goto exit;
 		}
+
+		if (settings->hidden_ssid) {
+			err =3D brcmf_fil_iovar_int_set(ifp, "closednet", 1);
+			if (err) {
+				brcmf_err("closednet error (%d)\n", err);
+				goto exit;
+			}
+		}
+
 		brcmf_dbg(TRACE, "AP mode configuration complete\n");
 	} else if (dev_role =3D=3D NL80211_IFTYPE_P2P_GO) {
 		err =3D brcmf_fil_iovar_int_set(ifp, "chanspec", chanspec);
@@ -4720,6 +4729,10 @@ static int brcmf_cfg80211_stop_ap(struct wiphy *=
wiphy, struct net_device *ndev)
 			return err;
 		}
=20
+		/* First BSS doesn't get a full reset */
+		if (ifp->bsscfgidx =3D=3D 0)
+			brcmf_fil_iovar_int_set(ifp, "closednet", 0);
+
 		memset(&join_params, 0, sizeof(join_params));
 		err =3D brcmf_fil_cmd_data_set(ifp, BRCMF_C_SET_SSID,
 					     &join_params, sizeof(join_params));
--=20
1.8.4.5
