From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net] bna: fix interrupts storm caused by erroneous packets
Date: Thu,  6 Aug 2015 22:48:23 +0200
Message-ID: <1438894103-10597-1-git-send-email-ivecera@redhat.com>
Cc: rasesh.mody@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47018 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932285AbbHFUsX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2015 16:48:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit "e29aa33 bna: Enable Multi Buffer RX" moved packets counter
increment from the beginning of the NAPI processing loop after the check
for erroneous packets so they are never accounted. This counter is used
to inform firmware about number of processed completions (packets).
As these packets are never acked the firmware fires IRQs for them again
and again.

Fixes: e29aa33 bna: Enable Multi Buffer RX
Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bnad.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad.c b/drivers/net/ethernet/brocade/bna/bnad.c
index 0612b19..506047c 100644
--- a/drivers/net/ethernet/brocade/bna/bnad.c
+++ b/drivers/net/ethernet/brocade/bna/bnad.c
@@ -676,6 +676,7 @@ bnad_cq_process(struct bnad *bnad, struct bna_ccb *ccb, int budget)
 			if (!next_cmpl->valid)
 				break;
 		}
+		packets++;
 
 		/* TODO: BNA_CQ_EF_LOCAL ? */
 		if (unlikely(flags & (BNA_CQ_EF_MAC_ERROR |
@@ -692,7 +693,6 @@ bnad_cq_process(struct bnad *bnad, struct bna_ccb *ccb, int budget)
 		else
 			bnad_cq_setup_skb_frags(rcb, skb, sop_ci, nvecs, len);
 
-		packets++;
 		rcb->rxq->rx_packets++;
 		rcb->rxq->rx_bytes += totlen;
 		ccb->bytes_per_intr += totlen;
-- 
2.4.6
