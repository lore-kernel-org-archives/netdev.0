From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 4/6] bnxt_en: Workaround Nitro A0 hardware RX bug (part 3).
Date: Mon, 18 Jul 2016 07:15:23 -0400
Message-ID: <1468840525-340-5-git-send-email-michael.chan@broadcom.com>
References: <1468840525-340-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f53.google.com ([209.85.218.53]:35836 "EHLO
	mail-oi0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751937AbcGRLPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 07:15:39 -0400
Received: by mail-oi0-f53.google.com with SMTP id l72so101068223oig.2
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 04:15:38 -0700 (PDT)
In-Reply-To: <1468840525-340-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prashant Sreedharan <prashant.sreedharan@broadcom.com>

Allocate napi for special vnic, packets arriving on this
napi will simply be dropped and the buffers will be replenished back
to the HW.

Signed-off-by: Prashant Sreedharan <prashant.sreedharan@broadcom.com>
Signed-off-by: Vasundhara Volam <vasundhara-v.volam@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 81 ++++++++++++++++++++++++++++++-
 1 file changed, 80 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 75a8b30..f0aa582 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -1668,6 +1668,76 @@ static int bnxt_poll_work(struct bnxt *bp, struct bnxt_napi *bnapi, int budget)
 	return rx_pkts;
 }
 
+static int bnxt_poll_nitroa0(struct napi_struct *napi, int budget)
+{
+	struct bnxt_napi *bnapi = container_of(napi, struct bnxt_napi, napi);
+	struct bnxt *bp = bnapi->bp;
+	struct bnxt_cp_ring_info *cpr = &bnapi->cp_ring;
+	struct bnxt_rx_ring_info *rxr = bnapi->rx_ring;
+	struct tx_cmp *txcmp;
+	struct rx_cmp_ext *rxcmp1;
+	u32 cp_cons, tmp_raw_cons;
+	u32 raw_cons = cpr->cp_raw_cons;
+	u32 rx_pkts = 0;
+	bool agg_event = false;
+
+	while (1) {
+		int rc;
+
+		cp_cons = RING_CMP(raw_cons);
+		txcmp = &cpr->cp_desc_ring[CP_RING(cp_cons)][CP_IDX(cp_cons)];
+
+		if (!TX_CMP_VALID(txcmp, raw_cons))
+			break;
+
+		if ((TX_CMP_TYPE(txcmp) & 0x30) == 0x10) {
+			tmp_raw_cons = NEXT_RAW_CMP(raw_cons);
+			cp_cons = RING_CMP(tmp_raw_cons);
+			rxcmp1 = (struct rx_cmp_ext *)
+			  &cpr->cp_desc_ring[CP_RING(cp_cons)][CP_IDX(cp_cons)];
+
+			if (!RX_CMP_VALID(rxcmp1, tmp_raw_cons))
+				break;
+
+			/* force an error to recycle the buffer */
+			rxcmp1->rx_cmp_cfa_code_errors_v2 |=
+				cpu_to_le32(RX_CMPL_ERRORS_CRC_ERROR);
+
+			rc = bnxt_rx_pkt(bp, bnapi, &raw_cons, &agg_event);
+			if (likely(rc == -EIO))
+				rx_pkts++;
+			else if (rc == -EBUSY)	/* partial completion */
+				break;
+		} else if (unlikely(TX_CMP_TYPE(txcmp) ==
+				    CMPL_BASE_TYPE_HWRM_DONE)) {
+			bnxt_hwrm_handler(bp, txcmp);
+		} else {
+			netdev_err(bp->dev,
+				   "Invalid completion received on special ring\n");
+		}
+		raw_cons = NEXT_RAW_CMP(raw_cons);
+
+		if (rx_pkts == budget)
+			break;
+	}
+
+	cpr->cp_raw_cons = raw_cons;
+	BNXT_CP_DB(cpr->cp_doorbell, cpr->cp_raw_cons);
+	writel(DB_KEY_RX | rxr->rx_prod, rxr->rx_doorbell);
+	writel(DB_KEY_RX | rxr->rx_prod, rxr->rx_doorbell);
+
+	if (agg_event) {
+		writel(DB_KEY_RX | rxr->rx_agg_prod, rxr->rx_agg_doorbell);
+		writel(DB_KEY_RX | rxr->rx_agg_prod, rxr->rx_agg_doorbell);
+	}
+
+	if (!bnxt_has_work(bp, cpr) && rx_pkts < budget) {
+		napi_complete(napi);
+		BNXT_CP_DB_REARM(cpr->cp_doorbell, cpr->cp_raw_cons);
+	}
+	return rx_pkts;
+}
+
 static int bnxt_poll(struct napi_struct *napi, int budget)
 {
 	struct bnxt_napi *bnapi = container_of(napi, struct bnxt_napi, napi);
@@ -4758,14 +4828,23 @@ static void bnxt_del_napi(struct bnxt *bp)
 static void bnxt_init_napi(struct bnxt *bp)
 {
 	int i;
+	unsigned int cp_nr_rings = bp->cp_nr_rings;
 	struct bnxt_napi *bnapi;
 
 	if (bp->flags & BNXT_FLAG_USING_MSIX) {
-		for (i = 0; i < bp->cp_nr_rings; i++) {
+		if (BNXT_CHIP_TYPE_NITRO_A0(bp))
+			cp_nr_rings--;
+		for (i = 0; i < cp_nr_rings; i++) {
 			bnapi = bp->bnapi[i];
 			netif_napi_add(bp->dev, &bnapi->napi,
 				       bnxt_poll, 64);
 		}
+		if (BNXT_CHIP_TYPE_NITRO_A0(bp)) {
+			bnapi = bp->bnapi[cp_nr_rings];
+			netif_napi_add(bp->dev, &bnapi->napi,
+				       bnxt_poll_nitroa0, 64);
+			napi_hash_add(&bnapi->napi);
+		}
 	} else {
 		bnapi = bp->bnapi[0];
 		netif_napi_add(bp->dev, &bnapi->napi, bnxt_poll, 64);
-- 
1.8.3.1
