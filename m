From: Weongyo Jeong <weongyo.linux@gmail.com>
Subject: [PATCH] net: removes duplicate skb_mark_napi_id() calls.
Date: Wed, 16 Mar 2016 10:04:53 -0700
Message-ID: <20160316170450.GA30365@jwg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33453 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932570AbcCPRFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 13:05:08 -0400
Received: by mail-pf0-f172.google.com with SMTP id 124so82559328pfg.0
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 10:04:55 -0700 (PDT)
Received: from jwg ([64.235.157.5])
        by smtp.gmail.com with ESMTPSA id v7sm6985096pfi.56.2016.03.16.10.04.54
        for <netdev@vger.kernel.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 16 Mar 2016 10:04:54 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Because napi_gro_receive() function calls skb_mark_napi_id() function,
it doesn't need to set it twice.

Signed-off-by: Weongyo Jeong <weongyo.linux@gmail.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 14 ++++++++------
 drivers/net/ethernet/cisco/enic/enic_main.c       |  7 ++++---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |  7 ++++---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  3 +--
 4 files changed, 17 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 82f1913..f6aa24f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -1112,11 +1112,12 @@ static int bnxt_rx_pkt(struct bnxt *bp, struct bnxt_napi *bnapi, u32 *raw_cons,
 		rc = -ENOMEM;
 		if (likely(skb)) {
 			skb_record_rx_queue(skb, bnapi->index);
-			skb_mark_napi_id(skb, &bnapi->napi);
-			if (bnxt_busy_polling(bnapi))
+			if (bnxt_busy_polling(bnapi)) {
+				skb_mark_napi_id(skb, &bnapi->napi);
 				netif_receive_skb(skb);
-			else
+			} else {
 				napi_gro_receive(&bnapi->napi, skb);
+			}
 			rc = 1;
 		}
 		goto next_rx_no_prod;
@@ -1215,11 +1216,12 @@ static int bnxt_rx_pkt(struct bnxt *bp, struct bnxt_napi *bnapi, u32 *raw_cons,
 	}
 
 	skb_record_rx_queue(skb, bnapi->index);
-	skb_mark_napi_id(skb, &bnapi->napi);
-	if (bnxt_busy_polling(bnapi))
+	if (bnxt_busy_polling(bnapi)) {
+		skb_mark_napi_id(skb, &bnapi->napi);
 		netif_receive_skb(skb);
-	else
+	} else {
 		napi_gro_receive(&bnapi->napi, skb);
+	}
 	rc = 1;
 
 next_rx:
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index b2182d3..1b15323 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -1186,12 +1186,13 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 		if (vlan_stripped)
 			__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tci);
 
-		skb_mark_napi_id(skb, &enic->napi[rq->index]);
 		if (enic_poll_busy_polling(rq) ||
-		    !(netdev->features & NETIF_F_GRO))
+		    !(netdev->features & NETIF_F_GRO)) {
+			skb_mark_napi_id(skb, &enic->napi[rq->index]);
 			netif_receive_skb(skb);
-		else
+		} else {
 			napi_gro_receive(&enic->napi[q_number], skb);
+		}
 		if (enic->rx_coalesce_setting.use_adaptive_rx_coalesce)
 			enic_intr_update_pkt_size(&cq->pkt_size_counter,
 						  bytes_written);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index c4003a8..18067e1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -1659,11 +1659,12 @@ static void ixgbe_process_skb_fields(struct ixgbe_ring *rx_ring,
 static void ixgbe_rx_skb(struct ixgbe_q_vector *q_vector,
 			 struct sk_buff *skb)
 {
-	skb_mark_napi_id(skb, &q_vector->napi);
-	if (ixgbe_qv_busy_polling(q_vector))
+	if (ixgbe_qv_busy_polling(q_vector)) {
+		skb_mark_napi_id(skb, &q_vector->napi);
 		netif_receive_skb(skb);
-	else
+	} else {
 		napi_gro_receive(&q_vector->napi, skb);
+	}
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 3558f01..a2955fd 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -447,9 +447,8 @@ static void ixgbevf_rx_skb(struct ixgbevf_q_vector *q_vector,
 			   struct sk_buff *skb)
 {
 #ifdef CONFIG_NET_RX_BUSY_POLL
-	skb_mark_napi_id(skb, &q_vector->napi);
-
 	if (ixgbevf_qv_busy_polling(q_vector)) {
+		skb_mark_napi_id(skb, &q_vector->napi);
 		netif_receive_skb(skb);
 		/* exit early if we busy polled */
 		return;
-- 
2.1.3
