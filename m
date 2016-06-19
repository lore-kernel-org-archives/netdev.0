From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH V2 RFC 2/2] brcmfmac: support removing AP interfaces with "interface_remove"
Date: Sun, 19 Jun 2016 18:23:25 +0200
Message-ID: <1466353420-30998-2-git-send-email-zajec5@gmail.com>
References: <1466273932-11554-1-git-send-email-zajec5@gmail.com>
 <1466353420-30998-1-git-send-email-zajec5@gmail.com>
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
In-Reply-To: <1466353420-30998-1-git-send-email-zajec5@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

New firmwares (e.g. 10.10.69.36 for BCM4366) support "interface_remove"
for removing interfaces. Try to use this method on cfg80211 request. In
case of older firmwares (e.g. 7.35.177.56 for BCM43602 as I tested) thi=
s
will just result in firmware rejecting command and this won't change an=
y
behavior.

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
V2: Add extra chcek for ndev. Thanks Arend.
---
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         | 39 ++++++++++++++=
+++++++-
 1 file changed, 38 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.=
c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
index 502b0a0..1e411dc 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
@@ -785,12 +785,48 @@ s32 brcmf_notify_escan_complete(struct brcmf_cfg8=
0211_info *cfg,
 	return err;
 }
=20
+static int brcmf_cfg80211_del_ap_iface(struct wiphy *wiphy,
+				       struct wireless_dev *wdev)
+{
+	struct brcmf_cfg80211_info *cfg =3D wiphy_priv(wiphy);
+	struct net_device *ndev =3D wdev->netdev;
+	struct brcmf_if *ifp =3D netdev_priv(ndev);
+	int ret;
+	int err;
+
+	brcmf_cfg80211_arm_vif_event(cfg, ifp->vif);
+
+	err =3D brcmf_fil_bsscfg_data_set(ifp, "interface_remove", NULL, 0);
+	if (err) {
+		brcmf_err("interface_remove failed %d\n", err);
+		goto err_unarm;
+	}
+
+	/* wait for firmware event */
+	ret =3D brcmf_cfg80211_wait_vif_event(cfg, BRCMF_E_IF_DEL,
+					    BRCMF_VIF_EVENT_TIMEOUT);
+	if (!ret) {
+		brcmf_err("timeout occurred\n");
+		err =3D -EIO;
+		goto err_unarm;
+	}
+
+	brcmf_remove_interface(ifp, true);
+
+err_unarm:
+	brcmf_cfg80211_arm_vif_event(cfg, NULL);
+	return err;
+}
+
 static
 int brcmf_cfg80211_del_iface(struct wiphy *wiphy, struct wireless_dev =
*wdev)
 {
 	struct brcmf_cfg80211_info *cfg =3D wiphy_priv(wiphy);
 	struct net_device *ndev =3D wdev->netdev;
=20
+	if (ndev && ndev =3D=3D cfg_to_ndev(cfg))
+		return -ENOTSUPP;
+
 	/* vif event pending in firmware */
 	if (brcmf_cfg80211_vif_event_armed(cfg))
 		return -EBUSY;
@@ -807,12 +843,13 @@ int brcmf_cfg80211_del_iface(struct wiphy *wiphy,=
 struct wireless_dev *wdev)
 	switch (wdev->iftype) {
 	case NL80211_IFTYPE_ADHOC:
 	case NL80211_IFTYPE_STATION:
-	case NL80211_IFTYPE_AP:
 	case NL80211_IFTYPE_AP_VLAN:
 	case NL80211_IFTYPE_WDS:
 	case NL80211_IFTYPE_MONITOR:
 	case NL80211_IFTYPE_MESH_POINT:
 		return -EOPNOTSUPP;
+	case NL80211_IFTYPE_AP:
+		return brcmf_cfg80211_del_ap_iface(wiphy, wdev);
 	case NL80211_IFTYPE_P2P_CLIENT:
 	case NL80211_IFTYPE_P2P_GO:
 	case NL80211_IFTYPE_P2P_DEVICE:
--=20
1.8.4.5
