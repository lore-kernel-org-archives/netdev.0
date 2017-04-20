From: James Hughes <james.hughes@raspberrypi.org>
Subject: [PATCH] brcm80211: brcmfmac: Ensure that incoming skb's are writable
Date: Thu, 20 Apr 2017 12:16:51 +0100
Message-ID: <20170420111651.10213-1-james.hughes@raspberrypi.org>
Cc: James Hughes <james.hughes@raspberrypi.org>
To: netdev@vger.kernel.org,
        Arend van Spriel <arend.vanspriel@broadcom.com>,
        Franky Lin <franky.lin@broadcom.com>,
        Hante Meuleman <hante.meuleman@broadcom.com>,
        Kalle Valo <kvalo@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx08-00252a01.pphosted.com ([91.207.212.211]:52500 "EHLO
        mx08-00252a01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S944421AbdDTLRM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 07:17:12 -0400
Received: from pps.filterd (m0102629.ppops.net [127.0.0.1])
        by mx08-00252a01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3KB7wBO020565
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 12:17:11 +0100
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
        by mx08-00252a01.pphosted.com with ESMTP id 29wqp28saq-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=OK)
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 12:17:11 +0100
Received: by mail-wr0-f199.google.com with SMTP id 18so5274926wrz.4
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 04:17:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver was adding header information to incoming skb
without ensuring the head was uncloned and hence writable.

skb_cow_head has been used to ensure they are writable, however,
this required some changes to error handling to ensure that
if skb_cow_head failed it was not ignored.

This really needs to be reviewed by someone who is more familiar
with this code base to ensure any deallocation of skb's is
still correct.

Signed-off-by: James Hughes <james.hughes@raspberrypi.org>
---
 .../wireless/broadcom/brcm80211/brcmfmac/bcdc.c    | 15 ++++++++--
 .../wireless/broadcom/brcm80211/brcmfmac/core.c    | 23 +++++-----------
 .../broadcom/brcm80211/brcmfmac/fwsignal.c         | 32 +++++++++++++++++-----
 .../wireless/broadcom/brcm80211/brcmfmac/sdio.c    |  7 ++++-
 4 files changed, 51 insertions(+), 26 deletions(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcdc.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcdc.c
index 038a960..b9d7d08 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcdc.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/bcdc.c
@@ -249,14 +249,19 @@ brcmf_proto_bcdc_set_dcmd(struct brcmf_pub *drvr, int ifidx, uint cmd,
 	return ret;
 }
 
-static void
+static int
 brcmf_proto_bcdc_hdrpush(struct brcmf_pub *drvr, int ifidx, u8 offset,
 			 struct sk_buff *pktbuf)
 {
 	struct brcmf_proto_bcdc_header *h;
+	int err;
 
 	brcmf_dbg(BCDC, "Enter\n");
 
+	err = skb_cow_head(pktbuf, BCDC_HEADER_LEN);
+	if (err)
+		return err;
+
 	/* Push BDC header used to convey priority for buses that don't */
 	skb_push(pktbuf, BCDC_HEADER_LEN);
 
@@ -271,6 +276,8 @@ brcmf_proto_bcdc_hdrpush(struct brcmf_pub *drvr, int ifidx, u8 offset,
 	h->data_offset = offset;
 	BCDC_SET_IF_IDX(h, ifidx);
 	trace_brcmf_bcdchdr(pktbuf->data);
+
+	return 0;
 }
 
 static int
@@ -330,7 +337,11 @@ static int
 brcmf_proto_bcdc_txdata(struct brcmf_pub *drvr, int ifidx, u8 offset,
 			struct sk_buff *pktbuf)
 {
-	brcmf_proto_bcdc_hdrpush(drvr, ifidx, offset, pktbuf);
+	int err = brcmf_proto_bcdc_hdrpush(drvr, ifidx, offset, pktbuf);
+
+	if (err)
+		return err;
+
 	return brcmf_bus_txdata(drvr->bus_if, pktbuf);
 }
 
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
index 5eaac13..08272e8 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/core.c
@@ -198,7 +198,7 @@ static netdev_tx_t brcmf_netdev_start_xmit(struct sk_buff *skb,
 	int ret;
 	struct brcmf_if *ifp = netdev_priv(ndev);
 	struct brcmf_pub *drvr = ifp->drvr;
-	struct ethhdr *eh = (struct ethhdr *)(skb->data);
+	struct ethhdr *eh;
 
 	brcmf_dbg(DATA, "Enter, bsscfgidx=%d\n", ifp->bsscfgidx);
 
@@ -212,23 +212,14 @@ static netdev_tx_t brcmf_netdev_start_xmit(struct sk_buff *skb,
 	}
 
 	/* Make sure there's enough room for any header */
-	if (skb_headroom(skb) < drvr->hdrlen) {
-		struct sk_buff *skb2;
-
-		brcmf_dbg(INFO, "%s: insufficient headroom\n",
-			  brcmf_ifname(ifp));
-		drvr->bus_if->tx_realloc++;
-		skb2 = skb_realloc_headroom(skb, drvr->hdrlen);
-		dev_kfree_skb(skb);
-		skb = skb2;
-		if (skb == NULL) {
-			brcmf_err("%s: skb_realloc_headroom failed\n",
-				  brcmf_ifname(ifp));
-			ret = -ENOMEM;
-			goto done;
-		}
+	ret = skb_cow_head(skb, drvr->hdrlen);
+	if (ret) {
+		dev_kfree_skb_any(skb);
+		goto done;
 	}
 
+	eh = (struct ethhdr *)(skb->data);
+
 	/* validate length for ether packet */
 	if (skb->len < sizeof(*eh)) {
 		ret = -EINVAL;
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.c
index a190f53..2510408 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/fwsignal.c
@@ -877,12 +877,15 @@ static void brcmf_fws_cleanup(struct brcmf_fws_info *fws, int ifidx)
 	brcmf_fws_hanger_cleanup(fws, matchfn, ifidx);
 }
 
-static u8 brcmf_fws_hdrpush(struct brcmf_fws_info *fws, struct sk_buff *skb)
+static int brcmf_fws_hdrpush(struct brcmf_fws_info *fws, struct sk_buff *skb,
+			     u8 *offset)
 {
 	struct brcmf_fws_mac_descriptor *entry = brcmf_skbcb(skb)->mac;
 	u8 *wlh;
 	u16 data_offset = 0;
 	u8 fillers;
+	int err;
+
 	__le32 pkttag = cpu_to_le32(brcmf_skbcb(skb)->htod);
 	__le16 pktseq = cpu_to_le16(brcmf_skbcb(skb)->htod_seq);
 
@@ -899,6 +902,11 @@ static u8 brcmf_fws_hdrpush(struct brcmf_fws_info *fws, struct sk_buff *skb)
 	fillers = round_up(data_offset, 4) - data_offset;
 	data_offset += fillers;
 
+	err = skb_cow_head(skb, data_offset);
+
+	if (err)
+		return err;
+
 	skb_push(skb, data_offset);
 	wlh = skb->data;
 
@@ -926,7 +934,9 @@ static u8 brcmf_fws_hdrpush(struct brcmf_fws_info *fws, struct sk_buff *skb)
 	if (fillers)
 		memset(wlh, BRCMF_FWS_TYPE_FILLER, fillers);
 
-	return (u8)(data_offset >> 2);
+	*offset = (u8)(data_offset >> 2);
+
+	return 0;
 }
 
 static bool brcmf_fws_tim_update(struct brcmf_fws_info *fws,
@@ -966,7 +976,8 @@ static bool brcmf_fws_tim_update(struct brcmf_fws_info *fws,
 		skcb->state = BRCMF_FWS_SKBSTATE_TIM;
 		skcb->htod = 0;
 		skcb->htod_seq = 0;
-		data_offset = brcmf_fws_hdrpush(fws, skb);
+		if (brcmf_fws_hdrpush(fws, skb, &data_offset))
+			return false;
 		ifidx = brcmf_skb_if_flags_get_field(skb, INDEX);
 		brcmf_fws_unlock(fws);
 		err = brcmf_proto_txdata(fws->drvr, ifidx, data_offset, skb);
@@ -1945,12 +1956,13 @@ void brcmf_fws_hdrpull(struct brcmf_if *ifp, s16 siglen, struct sk_buff *skb)
 		fws->stats.header_only_pkt++;
 }
 
-static u8 brcmf_fws_precommit_skb(struct brcmf_fws_info *fws, int fifo,
-				   struct sk_buff *p)
+static int brcmf_fws_precommit_skb(struct brcmf_fws_info *fws, int fifo,
+				   struct sk_buff *p, u8 *offset)
 {
 	struct brcmf_skbuff_cb *skcb = brcmf_skbcb(p);
 	struct brcmf_fws_mac_descriptor *entry = skcb->mac;
 	u8 flags;
+	int err;
 
 	if (skcb->state != BRCMF_FWS_SKBSTATE_SUPPRESSED)
 		brcmf_skb_htod_tag_set_field(p, GENERATION, entry->generation);
@@ -1963,7 +1975,10 @@ static u8 brcmf_fws_precommit_skb(struct brcmf_fws_info *fws, int fifo,
 		flags |= BRCMF_FWS_HTOD_FLAG_PKT_REQUESTED;
 	}
 	brcmf_skb_htod_tag_set_field(p, FLAGS, flags);
-	return brcmf_fws_hdrpush(fws, p);
+
+	err = brcmf_fws_hdrpush(fws, p, offset);
+
+	return err;
 }
 
 static void brcmf_fws_rollback_toq(struct brcmf_fws_info *fws,
@@ -2039,7 +2054,9 @@ static int brcmf_fws_commit_skb(struct brcmf_fws_info *fws, int fifo,
 	if (IS_ERR(entry))
 		return PTR_ERR(entry);
 
-	data_offset = brcmf_fws_precommit_skb(fws, fifo, skb);
+	if (!brcmf_fws_precommit_skb(fws, fifo, skb, &data_offset))
+		return PTR_ERR(entry);
+
 	entry->transit_count++;
 	if (entry->suppressed)
 		entry->suppr_transit_count++;
@@ -2100,6 +2117,7 @@ int brcmf_fws_process_skb(struct brcmf_if *ifp, struct sk_buff *skb)
 	int rc = 0;
 
 	brcmf_dbg(DATA, "tx proto=0x%X\n", ntohs(eh->h_proto));
+
 	/* determine the priority */
 	if ((skb->priority == 0) || (skb->priority > 7))
 		skb->priority = cfg80211_classify8021d(skb, NULL);
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
index d138260..0e53c8a 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/sdio.c
@@ -2719,7 +2719,7 @@ static bool brcmf_sdio_prec_enq(struct pktq *q, struct sk_buff *pkt, int prec)
 
 static int brcmf_sdio_bus_txdata(struct device *dev, struct sk_buff *pkt)
 {
-	int ret = -EBADE;
+	int ret = -EBADE, err;
 	uint prec;
 	struct brcmf_bus *bus_if = dev_get_drvdata(dev);
 	struct brcmf_sdio_dev *sdiodev = bus_if->bus_priv.sdio;
@@ -2729,6 +2729,11 @@ static int brcmf_sdio_bus_txdata(struct device *dev, struct sk_buff *pkt)
 	if (sdiodev->state != BRCMF_SDIOD_DATA)
 		return -EIO;
 
+	err = skb_cow_head(pkt, bus->tx_hdrlen);
+
+	if (err)
+		return err;
+
 	/* Add space for the header */
 	skb_push(pkt, bus->tx_hdrlen);
 	/* precondition: IS_ALIGNED((unsigned long)(pkt->data), 2) */
-- 
2.9.3
