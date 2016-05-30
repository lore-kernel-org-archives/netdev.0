From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH V2 next] brcmfmac: don't remove interface on link down firmware event
Date: Mon, 30 May 2016 06:40:54 +0200
Message-ID: <1464583269-30255-1-git-send-email-zajec5@gmail.com>
References: <1464557989-20003-1-git-send-email-zajec5@gmail.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f193.google.com ([209.85.217.193]:32819 "EHLO
	mail-lb0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890AbcE3ElV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 May 2016 00:41:21 -0400
In-Reply-To: <1464557989-20003-1-git-send-email-zajec5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are two firmware events we handle similarly in brcmfmac:
BRCMF_E_LINK and BRCMF_E_IF. The difference from firmware point of view
is that the first one means BSS remains present in the firmware. Trying
to (re)create it (e.g. when adding new virtual interface) will result i=
n
an error.

Current code treats both events in a similar way. It removes Linux
interface for each of them. It works OK with e.g. BCM43602. Its firmwar=
e
generates both events for each interface. It means we get BRCMF_E_LINK
and remove interface. That is soon followed by BRCMF_E_IF which means
BSS was also removed in a firmware. The only downside of this is a
harmless error like:
[  208.643180] brcmfmac: brcmf_fweh_call_event_handler: no interface ob=
ject

Unfortunately BCM4366 firmware doesn't automatically remove BSS and so
it doesn't generate BRCMF_E_IF. In such case we incorrectly remove Linu=
x
interface on BRCMF_E_LINK as BSS is still present in the firmware. It
results in an error when trying to re-create virtual interface, e.g.:
> iw phy phy1 interface add wlan1-1 type __ap
[ 3602.929199] brcmfmac: brcmf_ap_add_vif: timeout occurred
command failed: I/O error (-5)

With this patch we don't remove Linux interface while firmware keeps
BSS. Thanks to this we keep a consistent states of host driver and
device firmware.

=46urther improvement should be to mark BSS as disabled and remove
interface on BRCMF_E_LINK. Then we should add support for reusing
BSS-es.

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
---
V2: Fix drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c:543=
1:19: warning: unused variable =E2=80=98ifp=E2=80=99 [-Wunused-variable=
]
---
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.=
c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
index 38df1be..d23b95e 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
@@ -5428,7 +5428,6 @@ brcmf_notify_connect_status_ap(struct brcmf_cfg80=
211_info *cfg,
 			       struct net_device *ndev,
 			       const struct brcmf_event_msg *e, void *data)
 {
-	struct brcmf_if *ifp =3D netdev_priv(ndev);
 	static int generation;
 	u32 event =3D e->event_code;
 	u32 reason =3D e->reason;
@@ -5439,8 +5438,6 @@ brcmf_notify_connect_status_ap(struct brcmf_cfg80=
211_info *cfg,
 	    ndev !=3D cfg_to_ndev(cfg)) {
 		brcmf_dbg(CONN, "AP mode link down\n");
 		complete(&cfg->vif_disabled);
-		if (ifp->vif->mbss)
-			brcmf_remove_interface(ifp);
 		return 0;
 	}
=20
--=20
1.8.4.5
