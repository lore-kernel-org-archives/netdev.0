From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 07/17] ixgbe: remove open-coded skb_cow_head.
Date: Sat, 29 Mar 2014 12:26:20 +0100
Message-ID: <f62f13a9c37b77ad0141bf759143b8da88d264cf.1396090802.git.romieu@fr.zoreil.com>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
Cc: netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:60867 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751684AbaC2L0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 07:26:51 -0400
In-Reply-To: <cover.1396090802.git.romieu@fr.zoreil.com>
In-Reply-To: <cover.1396090802.git.romieu@fr.zoreil.com>
References: <cover.1396090802.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 9e5a366..878b226 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6506,6 +6506,7 @@ static int ixgbe_tso(struct ixgbe_ring *tx_ring,
 	struct sk_buff *skb = first->skb;
 	u32 vlan_macip_lens, type_tucmd;
 	u32 mss_l4len_idx, l4len;
+	int err;
 
 	if (skb->ip_summed != CHECKSUM_PARTIAL)
 		return 0;
@@ -6513,11 +6514,9 @@ static int ixgbe_tso(struct ixgbe_ring *tx_ring,
 	if (!skb_is_gso(skb))
 		return 0;
 
-	if (skb_header_cloned(skb)) {
-		int err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
-		if (err)
-			return err;
-	}
+	err = skb_cow_head(skb, 0);
+	if (err < 0)
+		return err;
 
 	/* ADV DTYP TUCMD MKRLOC/ISCSIHEDLEN */
 	type_tucmd = IXGBE_ADVTXD_TUCMD_L4T_TCP;
@@ -7072,8 +7071,8 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 					IXGBE_TX_FLAGS_VLAN_PRIO_SHIFT;
 		if (tx_flags & IXGBE_TX_FLAGS_SW_VLAN) {
 			struct vlan_ethhdr *vhdr;
-			if (skb_header_cloned(skb) &&
-			    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+
+			if (skb_cow_head(skb, 0))
 				goto out_drop;
 			vhdr = (struct vlan_ethhdr *)skb->data;
 			vhdr->h_vlan_TCI = htons(tx_flags >>
-- 
1.9.0
