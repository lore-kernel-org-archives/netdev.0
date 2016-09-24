From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH 1/2] brcmfmac: initialize fws(ignal) for BCDC protocol only
Date: Sat, 24 Sep 2016 22:44:18 +0200
Message-ID: <20160924204419.10213-1-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Pieter-Paul Giesberts <pieter-paul.giesberts@broadcom.com>,
        Franky Lin <frankyl@broadcom.com>,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <rafal@milecki.pl>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rafał Miłecki <rafal@milecki.pl>

There are two protocols used by Broadcom FullMAC devices: BCDC and
msgbuf. They use different ways for (some part of) communication with
the firmware. Firmware Signaling is required for the first one only
(BCDC).

So far we were always initializing fws and always calling it's skb
processing function. It was fws that was passing skb processing to the
protocol specific function. It was redundant for the msgbuf case.

Simply taking few lines of code out of fws allows us to totally avoid
using it. This simplifies code flow, saves some memory & will allow
further optimizations like not compiling fwsignal.c.

Signed-off-by: Rafał Miłecki <rafal@milecki.pl>
---
 .../wireless/broadcom/brcm80211/brcmfmac/core.c    | 24 ++++++++++++++++------
 .../broadcom/brcm80211/brcmfmac/fwsignal.c         | 17 ++++++---------
 .../broadcom/brcm80211/brcmfmac/fwsignal.h         |  1 +
 3 files changed, 25 insertions(+), 17 deletions(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
index 27cd50a..bc3d8ab 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
@@ -250,7 +250,17 @@ static netdev_tx_t brcmf_netdev_start_xmit(struct sk_buff *skb,
 	if (eh->h_proto == htons(ETH_P_PAE))
 		atomic_inc(&ifp->pend_8021x_cnt);
 
-	ret = brcmf_fws_process_skb(ifp, skb);
+	/* determine the priority */
+	if (skb->priority == 0 || skb->priority > 7)
+		skb->priority = cfg80211_classify8021d(skb, NULL);
+
+	if (drvr->fws && brcmf_fws_skbs_queueing(drvr->fws)) {
+		ret = brcmf_fws_process_skb(ifp, skb);
+	} else {
+		ret = brcmf_proto_txdata(drvr, ifp->ifidx, 0, skb);
+		if (ret < 0)
+			brcmf_txfinalize(ifp, skb, false);
+	}
 
 done:
 	if (ret) {
@@ -405,7 +415,7 @@ void brcmf_txcomplete(struct device *dev, struct sk_buff *txp, bool success)
 	struct brcmf_if *ifp;
 
 	/* await txstatus signal for firmware if active */
-	if (brcmf_fws_fc_active(drvr->fws)) {
+	if (drvr->fws && brcmf_fws_fc_active(drvr->fws)) {
 		if (!success)
 			brcmf_fws_bustxfail(drvr->fws, txp);
 	} else {
@@ -1006,11 +1016,13 @@ int brcmf_bus_start(struct device *dev)
 	}
 	brcmf_feat_attach(drvr);
 
-	ret = brcmf_fws_init(drvr);
-	if (ret < 0)
-		goto fail;
+	if (bus_if->proto_type == BRCMF_PROTO_BCDC) {
+		ret = brcmf_fws_init(drvr);
+		if (ret < 0)
+			goto fail;
 
-	brcmf_fws_add_interface(ifp);
+		brcmf_fws_add_interface(ifp);
+	}
 
 	drvr->config = brcmf_cfg80211_attach(drvr, bus_if->dev,
 					     drvr->settings->p2p_enable);
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.c
index a190f53..495eaf8 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.c
@@ -2100,16 +2100,6 @@ int brcmf_fws_process_skb(struct brcmf_if *ifp, struct sk_buff *skb)
 	int rc = 0;
 
 	brcmf_dbg(DATA, "tx proto=0x%X\n", ntohs(eh->h_proto));
-	/* determine the priority */
-	if ((skb->priority == 0) || (skb->priority > 7))
-		skb->priority = cfg80211_classify8021d(skb, NULL);
-
-	if (fws->avoid_queueing) {
-		rc = brcmf_proto_txdata(drvr, ifp->ifidx, 0, skb);
-		if (rc < 0)
-			brcmf_txfinalize(ifp, skb, false);
-		return rc;
-	}
 
 	/* set control buffer information */
 	skcb->if_flags = 0;
@@ -2155,7 +2145,7 @@ void brcmf_fws_add_interface(struct brcmf_if *ifp)
 	struct brcmf_fws_info *fws = ifp->drvr->fws;
 	struct brcmf_fws_mac_descriptor *entry;
 
-	if (!ifp->ndev)
+	if (!fws || !ifp->ndev)
 		return;
 
 	entry = &fws->desc.iface[ifp->ifidx];
@@ -2442,6 +2432,11 @@ void brcmf_fws_deinit(struct brcmf_pub *drvr)
 	kfree(fws);
 }
 
+bool brcmf_fws_skbs_queueing(struct brcmf_fws_info *fws)
+{
+	return !fws->avoid_queueing;
+}
+
 bool brcmf_fws_fc_active(struct brcmf_fws_info *fws)
 {
 	if (!fws->creditmap_received)
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.h b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.h
index ef0ad85..8f7c1d7 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.h
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.h
@@ -20,6 +20,7 @@
 
 int brcmf_fws_init(struct brcmf_pub *drvr);
 void brcmf_fws_deinit(struct brcmf_pub *drvr);
+bool brcmf_fws_skbs_queueing(struct brcmf_fws_info *fws);
 bool brcmf_fws_fc_active(struct brcmf_fws_info *fws);
 void brcmf_fws_hdrpull(struct brcmf_if *ifp, s16 siglen, struct sk_buff *skb);
 int brcmf_fws_process_skb(struct brcmf_if *ifp, struct sk_buff *skb);
-- 
2.9.3
