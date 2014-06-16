From: "Fu, Zhonghui" <zhonghui.fu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Subject: [PATCH] brcmfmac: prevent watchdog from interfering with scanning
 and connecting
Date: Mon, 16 Jun 2014 13:49:13 +0800
Message-ID: <539E8559.3010601@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
	meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, dekim-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, mcgrof-3uybbJdB1yH774rrrx3eTA@public.gmane.org,
	antonio-2BnEqQcu77q1Z/+hSey0Gg@public.gmane.org, johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

>From 14485894add32aedacb3e486ebb2cc2b73861abf Mon Sep 17 00:00:00 2001
From: Fu zhonghui <zhonghui.fu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Date: Wed, 11 Jun 2014 11:06:55 +0800
Subject: [PATCH] brcmfmac: prevent watchdog from interfering with scanning and connecting

Watchdog in brcmfmac driver may make WiFi chip enter sleep mode
before completion of scanning or connecting.

This will lead to scanning or connecting failure.

Increasing temporarily idle-time threshold during scanning or
connecting can ensure scanning or connecting success without
watchdog interference.

Signed-off-by: Fu zhonghui <zhonghui.fu-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
---
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |   18 ++++++++++++++++--
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |    3 ++-
 2 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
index 13c89a0..729deab 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
@@ -34,6 +34,7 @@
 #include <linux/vmalloc.h>
 #include <linux/platform_data/brcmfmac-sdio.h>
 #include <linux/moduleparam.h>
+#include <net/cfg80211.h>
 #include <asm/unaligned.h>
 #include <defs.h>
 #include <brcmu_wifi.h>
@@ -43,6 +44,10 @@
 #include "sdio_host.h"
 #include "chip.h"
 #include "nvram.h"
+#include "dhd.h"
+#include "fwil_types.h"
+#include "p2p.h"
+#include "wl_cfg80211.h"
 
 #define DCMD_RESP_TIMEOUT  2000	/* In milli second */
 
@@ -307,6 +312,7 @@ struct rte_console {
 					 * when idle
 					 */
 #define BRCMF_IDLE_INTERVAL	1
+#define BRCMF_IDLE_INTERVAL_SCANNING_CONNECTING	100
 
 #define KSO_WAIT_US 50
 #define MAX_KSO_ATTEMPTS (PMU_MAX_TRANSITION_DLY/KSO_WAIT_US)
@@ -3613,9 +3619,9 @@ void brcmf_sdio_isr(struct brcmf_sdio *bus)
 
 static bool brcmf_sdio_bus_watchdog(struct brcmf_sdio *bus)
 {
-#ifdef DEBUG
 	struct brcmf_bus *bus_if = dev_get_drvdata(bus->sdiodev->dev);
-#endif	/* DEBUG */
+	struct brcmf_cfg80211_info *cfg = bus_if->drvr->config;
+	struct brcmf_if *ifp = cfg->pub->iflist[0];
 
 	brcmf_dbg(TIMER, "Enter\n");
 
@@ -3678,6 +3684,14 @@ static bool brcmf_sdio_bus_watchdog(struct brcmf_sdio *bus)
 
 	/* On idle timeout clear activity flag and/or turn off clock */
 	if ((bus->idletime > 0) && (bus->clkstate == CLK_AVAIL)) {
+
+		if (test_bit(BRCMF_SCAN_STATUS_BUSY, &cfg->scan_status) ||
+		    test_bit(BRCMF_VIF_STATUS_CONNECTING, &ifp->vif->sme_state)) {
+			bus->idletime = BRCMF_IDLE_INTERVAL_SCANNING_CONNECTING;
+		} else {
+			bus->idletime = BRCMF_IDLE_INTERVAL;
+		}
+
 		if (++bus->idlecount >= bus->idletime) {
 			bus->idlecount = 0;
 			if (bus->activity) {
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
index be19852..e76517e 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
@@ -913,6 +913,8 @@ brcmf_cfg80211_escan(struct wiphy *wiphy, struct brcmf_cfg80211_vif *vif,
 		return -EAGAIN;
 	}
 
+	set_bit(BRCMF_SCAN_STATUS_BUSY, &cfg->scan_status);
+
 	/* If scan req comes for p2p0, send it over primary I/F */
 	if (vif == cfg->p2p.bss_idx[P2PAPI_BSSCFG_DEVICE].vif)
 		vif = cfg->p2p.bss_idx[P2PAPI_BSSCFG_PRIMARY].vif;
@@ -933,7 +935,6 @@ brcmf_cfg80211_escan(struct wiphy *wiphy, struct brcmf_cfg80211_vif *vif,
 	}
 
 	cfg->scan_request = request;
-	set_bit(BRCMF_SCAN_STATUS_BUSY, &cfg->scan_status);
 	if (escan_req) {
 		cfg->escan_info.run = brcmf_run_escan;
 		err = brcmf_p2p_scan_prep(wiphy, request, vif);
-- 1.7.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
