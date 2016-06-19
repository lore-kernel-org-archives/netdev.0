From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH V2 RFC 1/2] brcmfmac: delete interface directly in code that sent fw request
Date: Sun, 19 Jun 2016 18:23:24 +0200
Message-ID: <1466353420-30998-1-git-send-email-zajec5@gmail.com>
References: <1466273932-11554-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Arend van Spriel <arend.vanspriel-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Franky Lin <franky.lin-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Hante Meuleman <hante.meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Pieter-Paul Giesberts <pieter-paul.giesberts-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Franky (Zhenhui) Lin" <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:BROADCOM BRCM80211
	IEEE802.11n WIRELESS DRIVER),
	brcm80211-dev-list.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org (open list:BROADCOM BRCM80211
	IEEE802.11n WIRELESS DRIVER),
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:NETWORKING DRIVERS),
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list)
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1466273932-11554-1-git-send-email-zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

So far when receiving event about in-firmware-interface removal our
event worker was notifying listener and afterwards it was removing Linu=
x
interface.

=46irst of all it was resulting in slightly unexpected order. The liste=
ner
(del_virtual_intf callback) was (usually) returning with success before
we even called unregister_netdev(ice).

Please note this couldn't be simply fixed by changing order of calls in
brcmf_fweh_handle_if_event as unregistering interface earlier could fre=
e
struct brcmf_if.

Another problem of current implementation are possible lockups. Focus o=
n
the time slot between calling event handler and removing Linux
interface. During that time original caller may leave (unlocking rtnl
semaphore) *and* another call to the same code may be done (locking it
again). If that happens our event handler will stuck at removing Linux
interface, it won't handle another event and will block process holding
rtnl lock.

This can be simply solved by unregistering interface in a proper
callback, right after receiving confirmation event from firmware. This
only required modifying worker to don't unregister on its own if there
is someone waiting for the event.

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
V2: Modification of brcmf_fweh_handle_if_event done in V1 was a wrong
    idea as it could result in use-after-free regarding struct brcmf_if=
=2E
    Thanks Arend for noticing that!
---
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c | 10 ++++++++-=
-
 drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c  |  3 +--
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c b/=
drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c
index 9da7a4c..79c081f 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fweh.c
@@ -18,6 +18,7 @@
 #include "brcmu_wifi.h"
 #include "brcmu_utils.h"
=20
+#include "cfg80211.h"
 #include "core.h"
 #include "debug.h"
 #include "tracepoint.h"
@@ -182,8 +183,13 @@ static void brcmf_fweh_handle_if_event(struct brcm=
f_pub *drvr,
=20
 	err =3D brcmf_fweh_call_event_handler(ifp, emsg->event_code, emsg, da=
ta);
=20
-	if (ifp && ifevent->action =3D=3D BRCMF_E_IF_DEL)
-		brcmf_remove_interface(ifp, false);
+	if (ifp && ifevent->action =3D=3D BRCMF_E_IF_DEL) {
+		bool armed =3D brcmf_cfg80211_vif_event_armed(drvr->config);
+
+		/* Default handling in case no-one waits for this event */
+		if (!armed)
+			brcmf_remove_interface(ifp, false);
+	}
 }
=20
 /**
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c b/d=
rivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
index f6241fd..66f942f 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
@@ -2288,8 +2288,7 @@ int brcmf_p2p_del_vif(struct wiphy *wiphy, struct=
 wireless_dev *wdev)
 		else
 			err =3D 0;
 	}
-	if (err)
-		brcmf_remove_interface(vif->ifp, true);
+	brcmf_remove_interface(vif->ifp, true);
=20
 	brcmf_cfg80211_arm_vif_event(cfg, NULL);
 	if (vif->wdev.iftype !=3D NL80211_IFTYPE_P2P_DEVICE)
--=20
1.8.4.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
