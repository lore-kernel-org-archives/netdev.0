From: James Hughes <james.hughes@raspberrypi.org>
Subject: [PATCH v2] brcmfmac: Make skb header writable before use
Date: Mon, 24 Apr 2017 14:03:22 +0100
Message-ID: <20170424130322.476-1-james.hughes@raspberrypi.org>
Cc: James Hughes <james.hughes@raspberrypi.org>
To: Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00252a01.pphosted.com ([62.209.51.214]:9826 "EHLO
        mx07-00252a01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934111AbdDXNDf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 09:03:35 -0400
Received: from pps.filterd (m0102628.ppops.net [127.0.0.1])
        by mx07-00252a01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3OD1PRt022361
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 14:03:34 +0100
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
        by mx07-00252a01.pphosted.com with ESMTP id 29yvjys2wm-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=OK)
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 14:03:33 +0100
Received: by mail-wm0-f71.google.com with SMTP id n198so4697028wmg.9
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 06:03:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver was making changes to the skb_header without
ensuring it was writable (i.e. uncloned).
This patch also removes some boiler plate header size
checking/adjustment code as that is also handled by the
skb_cow_header function used to make header writable.

This patch depends on
brcmfmac: Ensure pointer correctly set if skb data location changes

Signed-off-by: James Hughes <james.hughes@raspberrypi.org>
---
Changes in v2
  Makes the _cow_ call at the entry point of the skb in to the
  stack, means only needs to be done once, and error handling
  is easier.
  Split a separate minor bug fix off to a separate patch (which
  this patch depends on)



 .../net/wireless/broadcom/brcm80211/brcmfmac/core.c   | 19 ++++---------------
 1 file changed, 4 insertions(+), 15 deletions(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
index 9b7c19a508ac..88f8675a94c2 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
@@ -211,22 +211,11 @@ static netdev_tx_t brcmf_netdev_start_xmit(struct sk_buff *skb,
 		goto done;
 	}
 
-	/* Make sure there's enough room for any header */
-	if (skb_headroom(skb) < drvr->hdrlen) {
-		struct sk_buff *skb2;
-
-		brcmf_dbg(INFO, "%s: insufficient headroom\n",
-			  brcmf_ifname(ifp));
-		drvr->bus_if->tx_realloc++;
-		skb2 = skb_realloc_headroom(skb, drvr->hdrlen);
+	/* Make sure there's enough room for any header, and make it writable */
+	if (skb_cow_head(skb, drvr->hdrlen)) {
 		dev_kfree_skb(skb);
-		skb = skb2;
-		if (skb == NULL) {
-			brcmf_err("%s: skb_realloc_headroom failed\n",
-				  brcmf_ifname(ifp));
-			ret = -ENOMEM;
-			goto done;
-		}
+		ret = -ENOMEM;
+		goto done;
 	}
 
 	/* validate length for ether packet */
-- 
2.11.0
