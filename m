From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 3/3] bnxt_en: Simplify VLAN receive logic.
Date: Mon,  6 Jun 2016 02:37:16 -0400
Message-ID: <1465195036-4107-4-git-send-email-michael.chan@broadcom.com>
References: <1465195036-4107-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:33769 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208AbcFFGh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 02:37:28 -0400
Received: by mail-pa0-f51.google.com with SMTP id ec8so26683394pac.0
        for <netdev@vger.kernel.org>; Sun, 05 Jun 2016 23:37:28 -0700 (PDT)
In-Reply-To: <1465195036-4107-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since both CTAG and STAG rx acceleration must be enabled together, we
only need to check one feature flag (NETIF_F_HW_VLAN_CTAG_RX) before
calling __vlan_hwaccel_put_tag().

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 29 +++++++++--------------------
 1 file changed, 9 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index ae2b264..c777cde 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -1113,19 +1113,13 @@ static inline struct sk_buff *bnxt_tpa_end(struct bnxt *bp,
 	if (tpa_info->hash_type != PKT_HASH_TYPE_NONE)
 		skb_set_hash(skb, tpa_info->rss_hash, tpa_info->hash_type);
 
-	if (tpa_info->flags2 & RX_CMP_FLAGS2_META_FORMAT_VLAN) {
-		netdev_features_t features = skb->dev->features;
+	if ((tpa_info->flags2 & RX_CMP_FLAGS2_META_FORMAT_VLAN) &&
+	    (skb->dev->features & NETIF_F_HW_VLAN_CTAG_RX)) {
 		u16 vlan_proto = tpa_info->metadata >>
 			RX_CMP_FLAGS2_METADATA_TPID_SFT;
+		u16 vtag = tpa_info->metadata & RX_CMP_FLAGS2_METADATA_VID_MASK;
 
-		if (((features & NETIF_F_HW_VLAN_CTAG_RX) &&
-		     vlan_proto == ETH_P_8021Q) ||
-		    ((features & NETIF_F_HW_VLAN_STAG_RX) &&
-		     vlan_proto == ETH_P_8021AD)) {
-			__vlan_hwaccel_put_tag(skb, htons(vlan_proto),
-					       tpa_info->metadata &
-					       RX_CMP_FLAGS2_METADATA_VID_MASK);
-		}
+		__vlan_hwaccel_put_tag(skb, htons(vlan_proto), vtag);
 	}
 
 	skb_checksum_none_assert(skb);
@@ -1278,19 +1272,14 @@ static int bnxt_rx_pkt(struct bnxt *bp, struct bnxt_napi *bnapi, u32 *raw_cons,
 
 	skb->protocol = eth_type_trans(skb, dev);
 
-	if (rxcmp1->rx_cmp_flags2 &
-	    cpu_to_le32(RX_CMP_FLAGS2_META_FORMAT_VLAN)) {
-		netdev_features_t features = skb->dev->features;
+	if ((rxcmp1->rx_cmp_flags2 &
+	     cpu_to_le32(RX_CMP_FLAGS2_META_FORMAT_VLAN)) &&
+	    (skb->dev->features & NETIF_F_HW_VLAN_CTAG_RX)) {
 		u32 meta_data = le32_to_cpu(rxcmp1->rx_cmp_meta_data);
+		u16 vtag = meta_data & RX_CMP_FLAGS2_METADATA_VID_MASK;
 		u16 vlan_proto = meta_data >> RX_CMP_FLAGS2_METADATA_TPID_SFT;
 
-		if (((features & NETIF_F_HW_VLAN_CTAG_RX) &&
-		     vlan_proto == ETH_P_8021Q) ||
-		    ((features & NETIF_F_HW_VLAN_STAG_RX) &&
-		     vlan_proto == ETH_P_8021AD))
-			__vlan_hwaccel_put_tag(skb, htons(vlan_proto),
-					       meta_data &
-					       RX_CMP_FLAGS2_METADATA_VID_MASK);
+		__vlan_hwaccel_put_tag(skb, htons(vlan_proto), vtag);
 	}
 
 	skb_checksum_none_assert(skb);
-- 
1.8.3.1
