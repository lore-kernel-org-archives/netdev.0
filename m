From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH RFC] brcmfmac: support deleting MBSS AP interfaces
Date: Wed,  1 Jun 2016 16:36:56 +0200
Message-ID: <1464791845-23944-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>,
	Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	Franky Lin <franky.lin@broadcom.com>,
	brcm80211-dev-list@broadcom.com (open list:BROADCOM BRCM80211
	IEEE802.11n WIRELESS DRIVER),
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
	linux-kernel@vger.kernel.org (open list)
To: linux-wireless@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We already support adding extra (AP) interfaces so it also makes an
obvious sense to allow deleting them.

Adding a new interface is implemented by sending request to firmware fo=
r
creating a new BSS and waiting for a proper event. Ideally deleting
interface should be handled in a similar way. There should be a request
to firmware for deleting BSS and firmware should respond with an event.

Unfortunately it doesn't seem to work with recent firmwares. They never
seem to delete BSS and never send BRCMF_E_IF_DEL. As a workaround this
patch deletes Linux interface while keeping a track of BSSes present in
a firmware. If there is request for adding a new interface this code is
capable of reusing existing BSS-es.

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         | 84 ++++++++++++++=
+-------
 .../wireless/broadcom/brcm80211/brcmfmac/core.c    |  6 +-
 .../wireless/broadcom/brcm80211/brcmfmac/core.h    |  4 +-
 .../wireless/broadcom/brcm80211/brcmfmac/fweh.c    |  4 +-
 4 files changed, 71 insertions(+), 27 deletions(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.=
c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
index d23b95e..ce35ada 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
@@ -35,6 +35,7 @@
 #include "cfg80211.h"
 #include "feature.h"
 #include "fwil.h"
+#include "fwsignal.h"
 #include "proto.h"
 #include "vendor.h"
 #include "bus.h"
@@ -556,10 +557,10 @@ static int brcmf_get_first_free_bsscfgidx(struct =
brcmf_pub *drvr)
 	return -ENOMEM;
 }
=20
-static int brcmf_cfg80211_request_ap_if(struct brcmf_if *ifp)
+static int brcmf_cfg80211_request_ap_if(struct brcmf_cfg80211_info *cf=
g, int bsscfgidx)
 {
+	struct brcmf_if *ifp =3D netdev_priv(cfg_to_ndev(cfg));
 	struct brcmf_mbss_ssid_le mbss_ssid_le;
-	int bsscfgidx;
 	int err;
=20
 	memset(&mbss_ssid_le, 0, sizeof(mbss_ssid_le));
@@ -594,6 +595,7 @@ struct wireless_dev *brcmf_ap_add_vif(struct wiphy =
*wiphy, const char *name,
 	struct brcmf_cfg80211_info *cfg =3D wiphy_to_cfg(wiphy);
 	struct brcmf_if *ifp =3D netdev_priv(cfg_to_ndev(cfg));
 	struct brcmf_cfg80211_vif *vif;
+	int bsscfgidx;
 	int err;
=20
 	if (brcmf_cfg80211_vif_event_armed(cfg))
@@ -605,30 +607,49 @@ struct wireless_dev *brcmf_ap_add_vif(struct wiph=
y *wiphy, const char *name,
 	if (IS_ERR(vif))
 		return (struct wireless_dev *)vif;
=20
-	brcmf_cfg80211_arm_vif_event(cfg, vif);
+	bsscfgidx =3D brcmf_get_first_free_bsscfgidx(cfg->pub);
+	brcmf_err("bsscfgidx:%d cfg->pub->bss2if[bsscfgidx]:%d\n", bsscfgidx,=
 cfg->pub->bss2if[bsscfgidx]);
+	if (cfg->pub->bss2if[bsscfgidx] !=3D BRCMF_IDX_INVALID) {
+		ifp =3D brcmf_add_if(cfg->pub, bsscfgidx, cfg->pub->bss2if[bsscfgidx=
], false, "wlan%d", params->macaddr);
+		if (IS_ERR(ifp)) {
+			err =3D PTR_ERR(ifp);
+			goto fail;
+		}
+		brcmf_fws_add_interface(ifp);
=20
-	err =3D brcmf_cfg80211_request_ap_if(ifp);
-	if (err) {
-		brcmf_cfg80211_arm_vif_event(cfg, NULL);
-		goto fail;
-	}
+		ifp->vif =3D vif;
+		vif->ifp =3D ifp;
+		if (ifp->ndev) {
+			vif->wdev.netdev =3D ifp->ndev;
+			ifp->ndev->ieee80211_ptr =3D &vif->wdev;
+			SET_NETDEV_DEV(ifp->ndev, wiphy_dev(cfg->wiphy));
+		}
+	} else {
+		brcmf_cfg80211_arm_vif_event(cfg, vif);
=20
-	/* wait for firmware event */
-	err =3D brcmf_cfg80211_wait_vif_event(cfg, BRCMF_E_IF_ADD,
-					    BRCMF_VIF_EVENT_TIMEOUT);
-	brcmf_cfg80211_arm_vif_event(cfg, NULL);
-	if (!err) {
-		brcmf_err("timeout occurred\n");
-		err =3D -EIO;
-		goto fail;
-	}
+		err =3D brcmf_cfg80211_request_ap_if(cfg, bsscfgidx);
+		if (err) {
+			brcmf_cfg80211_arm_vif_event(cfg, NULL);
+			goto fail;
+		}
=20
-	/* interface created in firmware */
-	ifp =3D vif->ifp;
-	if (!ifp) {
-		brcmf_err("no if pointer provided\n");
-		err =3D -ENOENT;
-		goto fail;
+		/* wait for firmware event */
+		err =3D brcmf_cfg80211_wait_vif_event(cfg, BRCMF_E_IF_ADD,
+						BRCMF_VIF_EVENT_TIMEOUT);
+		brcmf_cfg80211_arm_vif_event(cfg, NULL);
+		if (!err) {
+			brcmf_err("timeout occurred\n");
+			err =3D -EIO;
+			goto fail;
+		}
+
+		/* interface created in firmware */
+		ifp =3D vif->ifp;
+		if (!ifp) {
+			brcmf_err("no if pointer provided\n");
+			err =3D -ENOENT;
+			goto fail;
+		}
 	}
=20
 	strncpy(ifp->ndev->name, name, sizeof(ifp->ndev->name) - 1);
@@ -781,12 +802,26 @@ s32 brcmf_notify_escan_complete(struct brcmf_cfg8=
0211_info *cfg,
 	return err;
 }
=20
+static int brcmf_cfg80211_del_ap_iface(struct wiphy *wiphy,
+				       struct wireless_dev *wdev)
+{
+	struct net_device *ndev =3D wdev->netdev;
+	struct brcmf_if *ifp =3D netdev_priv(ndev);
+
+	brcmf_remove_interface(ifp);
+
+	return 0;
+}
+
 static
 int brcmf_cfg80211_del_iface(struct wiphy *wiphy, struct wireless_dev =
*wdev)
 {
 	struct brcmf_cfg80211_info *cfg =3D wiphy_priv(wiphy);
 	struct net_device *ndev =3D wdev->netdev;
=20
+	if (ndev =3D=3D cfg_to_ndev(cfg))
+		return -ENOTSUPP;
+
 	/* vif event pending in firmware */
 	if (brcmf_cfg80211_vif_event_armed(cfg))
 		return -EBUSY;
@@ -803,12 +838,13 @@ int brcmf_cfg80211_del_iface(struct wiphy *wiphy,=
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
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c b/=
drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
index 6a76480..1208c21 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
@@ -634,7 +634,7 @@ fail:
 }
=20
 struct brcmf_if *brcmf_add_if(struct brcmf_pub *drvr, s32 bsscfgidx, s=
32 ifidx,
-			      bool is_p2pdev, char *name, u8 *mac_addr)
+			      bool is_p2pdev, const char *name, u8 *mac_addr)
 {
 	struct brcmf_if *ifp;
 	struct net_device *ndev;
@@ -680,6 +680,8 @@ struct brcmf_if *brcmf_add_if(struct brcmf_pub *drv=
r, s32 bsscfgidx, s32 ifidx,
 		/* store mapping ifidx to bsscfgidx */
 		if (drvr->if2bss[ifidx] =3D=3D BRCMF_BSSIDX_INVALID)
 			drvr->if2bss[ifidx] =3D bsscfgidx;
+		if (drvr->bss2if[bsscfgidx] =3D=3D BRCMF_IDX_INVALID)
+			drvr->bss2if[bsscfgidx] =3D ifidx;
 	}
=20
 	ifp->drvr =3D drvr;
@@ -910,6 +912,8 @@ int brcmf_attach(struct device *dev, struct brcmf_m=
p_device *settings)
=20
 	for (i =3D 0; i < ARRAY_SIZE(drvr->if2bss); i++)
 		drvr->if2bss[i] =3D BRCMF_BSSIDX_INVALID;
+	for (i =3D 0; i < ARRAY_SIZE(drvr->bss2if); i++)
+		drvr->bss2if[i] =3D BRCMF_IDX_INVALID;
=20
 	mutex_init(&drvr->proto_block);
=20
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h b/=
drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h
index 2a075c5..edd322a 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h
@@ -29,6 +29,7 @@
=20
 /* For supporting multiple interfaces */
 #define BRCMF_MAX_IFS	16
+#define BRCMF_IDX_INVALID	-1
=20
 /* Small, medium and maximum buffer size for dcmd
  */
@@ -125,6 +126,7 @@ struct brcmf_pub {
=20
 	struct brcmf_if *iflist[BRCMF_MAX_IFS];
 	s32 if2bss[BRCMF_MAX_IFS];
+	s32 bss2if[BRCMF_MAX_IFS];
=20
 	struct mutex proto_block;
 	unsigned char proto_buf[BRCMF_DCMD_MAXLEN];
@@ -215,7 +217,7 @@ char *brcmf_ifname(struct brcmf_if *ifp);
 struct brcmf_if *brcmf_get_ifp(struct brcmf_pub *drvr, int ifidx);
 int brcmf_net_attach(struct brcmf_if *ifp, bool rtnl_locked);
 struct brcmf_if *brcmf_add_if(struct brcmf_pub *drvr, s32 bsscfgidx, s=
32 ifidx,
-			      bool is_p2pdev, char *name, u8 *mac_addr);
+			      bool is_p2pdev, const char *name, u8 *mac_addr);
 void brcmf_remove_interface(struct brcmf_if *ifp);
 void brcmf_txflowblock_if(struct brcmf_if *ifp,
 			  enum brcmf_netif_stop_reason reason, bool state);
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c b/=
drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c
index b390561..5bde857 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c
@@ -182,8 +182,10 @@ static void brcmf_fweh_handle_if_event(struct brcm=
f_pub *drvr,
=20
 	err =3D brcmf_fweh_call_event_handler(ifp, emsg->event_code, emsg, da=
ta);
=20
-	if (ifp && ifevent->action =3D=3D BRCMF_E_IF_DEL)
+	if (ifp && ifevent->action =3D=3D BRCMF_E_IF_DEL) {
 		brcmf_remove_interface(ifp);
+		drvr->bss2if[ifp->bsscfgidx] =3D BRCMF_IDX_INVALID;
+	}
 }
=20
 /**
--=20
1.8.4.5
