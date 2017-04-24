From: James Hughes <james.hughes@raspberrypi.org>
Subject: [PATCH v2] brcmfmac: Ensure pointer correctly set if skb data location changes
Date: Mon, 24 Apr 2017 12:40:50 +0100
Message-ID: <20170424114050.24948-1-james.hughes@raspberrypi.org>
Cc: James Hughes <james.hughes@raspberrypi.org>
To: Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org,
        brcm80211-dev-list.pdl@broadcom.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00252a01.pphosted.com ([62.209.51.214]:9039 "EHLO
        mx07-00252a01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1169138AbdDXLlD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 07:41:03 -0400
Received: from pps.filterd (m0102628.ppops.net [127.0.0.1])
        by mx07-00252a01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3OBe6lm009014
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 12:41:02 +0100
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
        by mx07-00252a01.pphosted.com with ESMTP id 29yvjys1vs-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=OK)
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 12:41:01 +0100
Received: by mail-wm0-f69.google.com with SMTP id 65so1744667wmi.2
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 04:41:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The incoming skb header may be resized if header space is
insufficient, which might change the data adddress in the skb.
Ensure that a cached pointer to that data is correctly set by
moving assignment to after any possible changes.

Signed-off-by: James Hughes <james.hughes@raspberrypi.org>

Acked-by: Arend van Spriel <arend.vanspriel@broadcom.com>
---
Changes in v2

Moved the assignment below the len check - saves a few cycles 
if the length check fails. 


 drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
index 5eaac13e2317..9b7c19a508ac 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
@@ -198,7 +198,7 @@ static netdev_tx_t brcmf_netdev_start_xmit(struct sk_buff *skb,
 	int ret;
 	struct brcmf_if *ifp = netdev_priv(ndev);
 	struct brcmf_pub *drvr = ifp->drvr;
-	struct ethhdr *eh = (struct ethhdr *)(skb->data);
+	struct ethhdr *eh;
 
 	brcmf_dbg(DATA, "Enter, bsscfgidx=%d\n", ifp->bsscfgidx);
 
@@ -236,6 +236,8 @@ static netdev_tx_t brcmf_netdev_start_xmit(struct sk_buff *skb,
 		goto done;
 	}
 
+	eh = (struct ethhdr *)(skb->data);
+
 	if (eh->h_proto == htons(ETH_P_PAE))
 		atomic_inc(&ifp->pend_8021x_cnt);
 
-- 
2.11.0
