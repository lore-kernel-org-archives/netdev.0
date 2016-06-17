From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH REBASED] brcmfmac: fix lockup when removing P2P interface after event timeout
Date: Fri, 17 Jun 2016 12:29:21 +0200
Message-ID: <1466159371-19968-1-git-send-email-zajec5@gmail.com>
References: <1464378815-23282-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>,
	Arend van Spriel <arend.vanspriel@broadcom.com>,
	Franky Lin <franky.lin@broadcom.com>,
	Hante Meuleman <hante.meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Johannes Berg <johannes.berg@intel.com>,
	linux-wireless@vger.kernel.org (open list:BROADCOM BRCM80211
	IEEE802.11n WIRELESS DRIVER),
	brcm80211-dev-list.pdl@broadcom.com (open list:BROADCOM BRCM80211
	IEEE802.11n WIRELESS DRIVER),
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
	linux-kernel@vger.kernel.org (open list)
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1464378815-23282-1-git-send-email-zajec5@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removing P2P interface is handled by sending a proper request to the
firmware. On success firmware triggers an event and driver's handler
removes a matching interface.

However on event timeout we remove interface directly from the cfg80211
callback. Current code doesn't handle this case correctly as it always
assumes rtnl to be unlocked.

=46ix it by adding an extra rtnl_locked parameter to functions and call=
ing
unregister_netdevice when needed.

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
REBASED on top of wireless-drivers-next. This bug isn't very common and
changes may conflict with other patches, so it makes more sense to pick
it for -next.
---
 .../wireless/broadcom/brcm80211/brcmfmac/core.c    | 29 +++++++++++++-=
--------
 .../wireless/broadcom/brcm80211/brcmfmac/core.h    |  2 +-
 .../wireless/broadcom/brcm80211/brcmfmac/fweh.c    |  2 +-
 .../net/wireless/broadcom/brcm80211/brcmfmac/p2p.c |  4 +--
 4 files changed, 21 insertions(+), 16 deletions(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c b/=
drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
index faf4e46..7b38c2b 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
@@ -548,12 +548,16 @@ fail:
 	return -EBADE;
 }
=20
-static void brcmf_net_detach(struct net_device *ndev)
+static void brcmf_net_detach(struct net_device *ndev, bool rtnl_locked=
)
 {
-	if (ndev->reg_state =3D=3D NETREG_REGISTERED)
-		unregister_netdev(ndev);
-	else
+	if (ndev->reg_state =3D=3D NETREG_REGISTERED) {
+		if (rtnl_locked)
+			unregister_netdevice(ndev);
+		else
+			unregister_netdev(ndev);
+	} else {
 		brcmf_cfg80211_free_netdev(ndev);
+	}
 }
=20
 void brcmf_net_setcarrier(struct brcmf_if *ifp, bool on)
@@ -651,7 +655,7 @@ struct brcmf_if *brcmf_add_if(struct brcmf_pub *drv=
r, s32 bsscfgidx, s32 ifidx,
 			brcmf_err("ERROR: netdev:%s already exists\n",
 				  ifp->ndev->name);
 			netif_stop_queue(ifp->ndev);
-			brcmf_net_detach(ifp->ndev);
+			brcmf_net_detach(ifp->ndev, false);
 			drvr->iflist[bsscfgidx] =3D NULL;
 		} else {
 			brcmf_dbg(INFO, "netdev:%s ignore IF event\n",
@@ -699,7 +703,8 @@ struct brcmf_if *brcmf_add_if(struct brcmf_pub *drv=
r, s32 bsscfgidx, s32 ifidx,
 	return ifp;
 }
=20
-static void brcmf_del_if(struct brcmf_pub *drvr, s32 bsscfgidx)
+static void brcmf_del_if(struct brcmf_pub *drvr, s32 bsscfgidx,
+			 bool rtnl_locked)
 {
 	struct brcmf_if *ifp;
=20
@@ -729,7 +734,7 @@ static void brcmf_del_if(struct brcmf_pub *drvr, s3=
2 bsscfgidx)
 			cancel_work_sync(&ifp->multicast_work);
 			cancel_work_sync(&ifp->ndoffload_work);
 		}
-		brcmf_net_detach(ifp->ndev);
+		brcmf_net_detach(ifp->ndev, rtnl_locked);
 	} else {
 		/* Only p2p device interfaces which get dynamically created
 		 * end up here. In this case the p2p module should be informed
@@ -743,14 +748,14 @@ static void brcmf_del_if(struct brcmf_pub *drvr, =
s32 bsscfgidx)
 	}
 }
=20
-void brcmf_remove_interface(struct brcmf_if *ifp)
+void brcmf_remove_interface(struct brcmf_if *ifp, bool rtnl_locked)
 {
 	if (!ifp || WARN_ON(ifp->drvr->iflist[ifp->bsscfgidx] !=3D ifp))
 		return;
 	brcmf_dbg(TRACE, "Enter, bsscfgidx=3D%d, ifidx=3D%d\n", ifp->bsscfgid=
x,
 		  ifp->ifidx);
 	brcmf_fws_del_interface(ifp);
-	brcmf_del_if(ifp->drvr, ifp->bsscfgidx);
+	brcmf_del_if(ifp->drvr, ifp->bsscfgidx, rtnl_locked);
 }
=20
 #ifdef CONFIG_INET
@@ -1057,9 +1062,9 @@ fail:
 		brcmf_fws_deinit(drvr);
 	}
 	if (ifp)
-		brcmf_net_detach(ifp->ndev);
+		brcmf_net_detach(ifp->ndev, false);
 	if (p2p_ifp)
-		brcmf_net_detach(p2p_ifp->ndev);
+		brcmf_net_detach(p2p_ifp->ndev, false);
 	drvr->iflist[0] =3D NULL;
 	drvr->iflist[1] =3D NULL;
 	if (drvr->settings->ignore_probe_fail)
@@ -1128,7 +1133,7 @@ void brcmf_detach(struct device *dev)
=20
 	/* make sure primary interface removed last */
 	for (i =3D BRCMF_MAX_IFS-1; i > -1; i--)
-		brcmf_remove_interface(drvr->iflist[i]);
+		brcmf_remove_interface(drvr->iflist[i], false);
=20
 	brcmf_cfg80211_detach(drvr->config);
=20
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h b/=
drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h
index 2a075c5..a0a6f7f 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.h
@@ -216,7 +216,7 @@ struct brcmf_if *brcmf_get_ifp(struct brcmf_pub *dr=
vr, int ifidx);
 int brcmf_net_attach(struct brcmf_if *ifp, bool rtnl_locked);
 struct brcmf_if *brcmf_add_if(struct brcmf_pub *drvr, s32 bsscfgidx, s=
32 ifidx,
 			      bool is_p2pdev, char *name, u8 *mac_addr);
-void brcmf_remove_interface(struct brcmf_if *ifp);
+void brcmf_remove_interface(struct brcmf_if *ifp, bool rtnl_locked);
 void brcmf_txflowblock_if(struct brcmf_if *ifp,
 			  enum brcmf_netif_stop_reason reason, bool state);
 void brcmf_txfinalize(struct brcmf_if *ifp, struct sk_buff *txp, bool =
success);
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c b/=
drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c
index b390561..9da7a4c 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c
@@ -183,7 +183,7 @@ static void brcmf_fweh_handle_if_event(struct brcmf=
_pub *drvr,
 	err =3D brcmf_fweh_call_event_handler(ifp, emsg->event_code, emsg, da=
ta);
=20
 	if (ifp && ifevent->action =3D=3D BRCMF_E_IF_DEL)
-		brcmf_remove_interface(ifp);
+		brcmf_remove_interface(ifp, false);
 }
=20
 /**
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c b/d=
rivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
index f38a821..426ff05 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
@@ -2287,7 +2287,7 @@ int brcmf_p2p_del_vif(struct wiphy *wiphy, struct=
 wireless_dev *wdev)
 			err =3D 0;
 	}
 	if (err)
-		brcmf_remove_interface(vif->ifp);
+		brcmf_remove_interface(vif->ifp, true);
=20
 	brcmf_cfg80211_arm_vif_event(cfg, NULL);
 	if (vif->wdev.iftype !=3D NL80211_IFTYPE_P2P_DEVICE)
@@ -2393,7 +2393,7 @@ void brcmf_p2p_detach(struct brcmf_p2p_info *p2p)
 	if (vif !=3D NULL) {
 		brcmf_p2p_cancel_remain_on_channel(vif->ifp);
 		brcmf_p2p_deinit_discovery(p2p);
-		brcmf_remove_interface(vif->ifp);
+		brcmf_remove_interface(vif->ifp, false);
 	}
 	/* just set it all to zero */
 	memset(p2p, 0, sizeof(*p2p));
--=20
1.8.4.5
