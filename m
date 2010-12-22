From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 04/10] bna: Enable pure priority tagged packet reception and rxf uninit cleanup fix
Date: Tue, 21 Dec 2010 23:23:10 -0800
Message-ID: <1293002596-3239-5-git-send-email-rmody@brocade.com>
References: <1293002596-3239-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rasesh Mody <rmody@brocade.com>, Debashis Dutt <ddutt@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:54071 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752230Ab0LVHl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Dec 2010 02:41:26 -0500
Received: from pps.filterd (m0000700 [127.0.0.1])
	by mx0b-000f0801.pphosted.com (8.14.4/8.14.4) with SMTP id oBM7MMDS021251
	for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 23:23:23 -0800
Received: from hq1-exedge.brocade.com (hq1-exedge.brocade.com [144.49.141.11])
	by mx0b-000f0801.pphosted.com with ESMTP id tb71ag48f-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 23:23:22 -0800
In-Reply-To: <1293002596-3239-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
	- Enable reception of pure priority tagged packets by default by turning on VLAN Id = 0
	- Clear the promiscuous mode, all multicast mode flags when bna_rxf_uninit is called

Signed-off-by: Debashis Dutt <ddutt@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bna_txrx.c |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bna/bna_txrx.c b/drivers/net/bna/bna_txrx.c
index fb6cf1f..5076618 100644
--- a/drivers/net/bna/bna_txrx.c
+++ b/drivers/net/bna/bna_txrx.c
@@ -1441,12 +1441,16 @@ bna_rxf_init(struct bna_rxf *rxf,
 	memset(rxf->vlan_filter_table, 0,
 			(sizeof(u32) * ((BFI_MAX_VLAN + 1) / 32)));
 
+	/* Set up VLAN 0 for pure priority tagged packets */
+	rxf->vlan_filter_table[0] |= 1;
+
 	bfa_fsm_set_state(rxf, bna_rxf_sm_stopped);
 }
 
 static void
 bna_rxf_uninit(struct bna_rxf *rxf)
 {
+	struct bna *bna = rxf->rx->bna;
 	struct bna_mac *mac;
 
 	bna_rit_mod_seg_put(&rxf->rx->bna->rit_mod, rxf->rit_segment);
@@ -1473,6 +1477,27 @@ bna_rxf_uninit(struct bna_rxf *rxf)
 		bna_mcam_mod_mac_put(&rxf->rx->bna->mcam_mod, mac);
 	}
 
+	/* Turn off pending promisc mode */
+	if (is_promisc_enable(rxf->rxmode_pending,
+				rxf->rxmode_pending_bitmask)) {
+		/* system promisc state should be pending */
+		BUG_ON(!(bna->rxf_promisc_id == rxf->rxf_id));
+		promisc_inactive(rxf->rxmode_pending,
+				rxf->rxmode_pending_bitmask);
+		 bna->rxf_promisc_id = BFI_MAX_RXF;
+	}
+	/* Promisc mode should not be active */
+	BUG_ON(rxf->rxmode_active & BNA_RXMODE_PROMISC);
+
+	/* Turn off pending all-multi mode */
+	if (is_allmulti_enable(rxf->rxmode_pending,
+				rxf->rxmode_pending_bitmask)) {
+		allmulti_inactive(rxf->rxmode_pending,
+				rxf->rxmode_pending_bitmask);
+	}
+	/* Allmulti mode should not be active */
+	BUG_ON(rxf->rxmode_active & BNA_RXMODE_ALLMULTI);
+
 	rxf->rx = NULL;
 }
 
-- 
1.7.1

