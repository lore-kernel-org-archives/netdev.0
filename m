From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 02/13] ixgbe: remove open-coded skb_cow_head
Date: Fri, 11 Apr 2014 06:52:52 -0700
Message-ID: <1397224383-19269-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1397224383-19269-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:35182 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757336AbaDKNxK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Apr 2014 09:53:10 -0400
In-Reply-To: <1397224383-19269-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 13 ++++++-------
 1 file changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 00c9308..c4c526b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6510,6 +6510,7 @@ static int ixgbe_tso(struct ixgbe_ring *tx_ring,
 	struct sk_buff *skb = first->skb;
 	u32 vlan_macip_lens, type_tucmd;
 	u32 mss_l4len_idx, l4len;
+	int err;
 
 	if (skb->ip_summed != CHECKSUM_PARTIAL)
 		return 0;
@@ -6517,11 +6518,9 @@ static int ixgbe_tso(struct ixgbe_ring *tx_ring,
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
@@ -7078,8 +7077,8 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
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
