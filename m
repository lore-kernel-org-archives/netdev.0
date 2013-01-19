From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/10] ixgbe: Always use context 0, even for FCoE and TSO
Date: Sat, 19 Jan 2013 05:14:52 -0800
Message-ID: <1358601299-10404-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1358601299-10404-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:4331 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751219Ab3ASNPG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Jan 2013 08:15:06 -0500
In-Reply-To: <1358601299-10404-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

We were spending cycles separating the FCoE and TSO contexts even though we
always overwriting the context anyway.  Instead of doing that we can just
use context 0 for all descriptors.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c |  3 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 11 +----------
 2 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
index 252850d..c88aa1c 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
@@ -550,9 +550,8 @@ int ixgbe_fso(struct ixgbe_ring *tx_ring,
 	/* set flag indicating FCOE to ixgbe_tx_map call */
 	first->tx_flags |= IXGBE_TX_FLAGS_FCOE;
 
-	/* mss_l4len_id: use 1 for FSO as TSO, no need for L4LEN */
+	/* mss_l4len_id: use 0 for FSO as TSO, no need for L4LEN */
 	mss_l4len_idx = skb_shinfo(skb)->gso_size << IXGBE_ADVTXD_MSS_SHIFT;
-	mss_l4len_idx |= 1 << IXGBE_ADVTXD_IDX_SHIFT;
 
 	/* vlan_macip_lens: HEADLEN, MACLEN, VLAN tag */
 	vlan_macip_lens = skb_transport_offset(skb) +
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index e197cc2..2e2bf33 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5944,10 +5944,9 @@ static int ixgbe_tso(struct ixgbe_ring *tx_ring,
 	first->gso_segs = skb_shinfo(skb)->gso_segs;
 	first->bytecount += (first->gso_segs - 1) * *hdr_len;
 
-	/* mss_l4len_id: use 1 as index for TSO */
+	/* mss_l4len_id: use 0 as index for TSO */
 	mss_l4len_idx = l4len << IXGBE_ADVTXD_L4LEN_SHIFT;
 	mss_l4len_idx |= skb_shinfo(skb)->gso_size << IXGBE_ADVTXD_MSS_SHIFT;
-	mss_l4len_idx |= 1 << IXGBE_ADVTXD_IDX_SHIFT;
 
 	/* vlan_macip_lens: HEADLEN, MACLEN, VLAN tag */
 	vlan_macip_lens = skb_network_header_len(skb);
@@ -6073,14 +6072,6 @@ static void ixgbe_tx_olinfo_status(union ixgbe_adv_tx_desc *tx_desc,
 	if (tx_flags & IXGBE_TX_FLAGS_IPV4)
 		olinfo_status |= cpu_to_le32(IXGBE_ADVTXD_POPTS_IXSM);
 
-	/* use index 1 context for TSO/FSO/FCOE */
-#ifdef IXGBE_FCOE
-	if (tx_flags & (IXGBE_TX_FLAGS_TSO | IXGBE_TX_FLAGS_FCOE))
-#else
-	if (tx_flags & IXGBE_TX_FLAGS_TSO)
-#endif
-		olinfo_status |= cpu_to_le32(1 << IXGBE_ADVTXD_IDX_SHIFT);
-
 	/*
 	 * Check Context must be set if Tx switch is enabled, which it
 	 * always is for case where virtual functions are running
-- 
1.7.11.7
