From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/13] i40e: Drop dead code and flags from Tx hotpath
Date: Wed,  9 Oct 2013 23:41:04 -0700
Message-ID: <1381387271-29605-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1381387271-29605-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:14054 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753165Ab3JJGlV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Oct 2013 02:41:21 -0400
In-Reply-To: <1381387271-29605-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Drop Tx flag and TXSW which is tested but never set.

As a result of this change we can drop a complicated check that always
resulted in the final result of i40e_tx_csum being equal to the
CHECKSUM_PARTIAL value.  As such we can replace the entire function call
with just a check for skb->summed == CHECKSUM_PARTIAL.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 31 +++++------------------------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h |  1 -
 2 files changed, 5 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index e96de75..52dfac2 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1300,27 +1300,6 @@ static int i40e_tx_prepare_vlan_flags(struct sk_buff *skb,
 }
 
 /**
- * i40e_tx_csum - is checksum offload requested
- * @tx_ring:  ptr to the ring to send
- * @skb:      ptr to the skb we're sending
- * @tx_flags: the collected send information
- * @protocol: the send protocol
- *
- * Returns true if checksum offload is requested
- **/
-static bool i40e_tx_csum(struct i40e_ring *tx_ring, struct sk_buff *skb,
-			 u32 tx_flags, __be16 protocol)
-{
-	if ((skb->ip_summed != CHECKSUM_PARTIAL) &&
-	    !(tx_flags & I40E_TX_FLAGS_TXSW)) {
-		if (!(tx_flags & I40E_TX_FLAGS_HW_VLAN))
-			return false;
-	}
-
-	return skb->ip_summed == CHECKSUM_PARTIAL;
-}
-
-/**
  * i40e_tso - set up the tso context descriptor
  * @tx_ring:  ptr to the ring to send
  * @skb:      ptr to the skb we're sending
@@ -1785,16 +1764,16 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 
 	skb_tx_timestamp(skb);
 
+	/* always enable CRC insertion offload */
+	td_cmd |= I40E_TX_DESC_CMD_ICRC;
+
 	/* Always offload the checksum, since it's in the data descriptor */
-	if (i40e_tx_csum(tx_ring, skb, tx_flags, protocol))
+	if (skb->ip_summed == CHECKSUM_PARTIAL) {
 		tx_flags |= I40E_TX_FLAGS_CSUM;
 
-	/* always enable offload insertion */
-	td_cmd |= I40E_TX_DESC_CMD_ICRC;
-
-	if (tx_flags & I40E_TX_FLAGS_CSUM)
 		i40e_tx_enable_csum(skb, tx_flags, &td_cmd, &td_offset,
 				    tx_ring, &cd_tunneling);
+	}
 
 	i40e_create_tx_ctx(tx_ring, cd_type_cmd_tso_mss,
 			   cd_tunneling, cd_l2tag2);
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index 2cb1338..e514247 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -102,7 +102,6 @@
 #define I40E_TX_FLAGS_IPV6		(u32)(1 << 5)
 #define I40E_TX_FLAGS_FCCRC		(u32)(1 << 6)
 #define I40E_TX_FLAGS_FSO		(u32)(1 << 7)
-#define I40E_TX_FLAGS_TXSW		(u32)(1 << 8)
 #define I40E_TX_FLAGS_VLAN_MASK		0xffff0000
 #define I40E_TX_FLAGS_VLAN_PRIO_MASK	0xe0000000
 #define I40E_TX_FLAGS_VLAN_PRIO_SHIFT	29
-- 
1.8.3.1
