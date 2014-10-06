From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net] bna: allow transmit tagged frames
Date: Mon,  6 Oct 2014 19:02:37 +0200
Message-ID: <1412614957-18549-1-git-send-email-ivecera@redhat.com>
Cc: Rasesh Mody <rasesh.mody@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51529 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752067AbaJFRCp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Oct 2014 13:02:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When Tx VLAN offloading is disabled frames with size ~ MTU are not
transmitted as the driver does not account 4 bytes of VLAN header added
by stack. It should use VLAN_ETH_HLEN instead of ETH_HLEN.

The second problem is with newer BNA chips (BNA 1860). These chips filter
out any VLAN tagged frames in Tx path. This is a problem when Tx VLAN
offloading is disabled and frames are tagged by stack. Older chips like
1010/1020 are not affected as they probably don't do such filtering.

Cc: Rasesh Mody <rasesh.mody@qlogic.com>
Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bna_tx_rx.c | 2 +-
 drivers/net/ethernet/brocade/bna/bnad.c      | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
index 85e6354..9949bd9 100644
--- a/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
+++ b/drivers/net/ethernet/brocade/bna/bna_tx_rx.c
@@ -3410,7 +3410,7 @@ bna_bfi_tx_enet_start(struct bna_tx *tx)
 
 	cfg_req->tx_cfg.vlan_mode = BFI_ENET_TX_VLAN_WI;
 	cfg_req->tx_cfg.vlan_id = htons((u16)tx->txf_vlan_id);
-	cfg_req->tx_cfg.admit_tagged_frame = BNA_STATUS_T_DISABLED;
+	cfg_req->tx_cfg.admit_tagged_frame = BNA_STATUS_T_ENABLED;
 	cfg_req->tx_cfg.apply_vlan_filter = BNA_STATUS_T_DISABLED;
 
 	bfa_msgq_cmd_set(&tx->msgq_cmd, NULL, NULL,
diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index ffc92a4..153cafa 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -2864,7 +2864,7 @@ bnad_txq_wi_prepare(struct bnad *bnad, struct bna_tcb *tcb,
 		txqent->hdr.wi.opcode =	htons(BNA_TXQ_WI_SEND);
 		txqent->hdr.wi.lso_mss = 0;
 
-		if (unlikely(skb->len > (bnad->netdev->mtu + ETH_HLEN))) {
+		if (unlikely(skb->len > (bnad->netdev->mtu + VLAN_ETH_HLEN))) {
 			BNAD_UPDATE_CTR(bnad, tx_skb_non_tso_too_long);
 			return -EINVAL;
 		}
-- 
2.0.4
