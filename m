From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/13] igb: Cleanup protocol handling in transmit path
Date: Fri,  7 Oct 2011 00:18:44 -0700
Message-ID: <1317971926-23145-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317971926-23145-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34273 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758795Ab1JGHSy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Oct 2011 03:18:54 -0400
In-Reply-To: <1317971926-23145-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change is meant to cleanup the protocol handling in the transmit path
so that it correctly offloads software VLAN tagged frames.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |   23 +++++++++++------------
 1 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 2c61ec4..3ebeb3e 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3987,8 +3987,8 @@ void igb_tx_ctxtdesc(struct igb_ring *tx_ring, u32 vlan_macip_lens,
 	context_desc->mss_l4len_idx	= cpu_to_le32(mss_l4len_idx);
 }
 
-static inline int igb_tso(struct igb_ring *tx_ring,
-			  struct sk_buff *skb, u32 tx_flags, u8 *hdr_len)
+static inline int igb_tso(struct igb_ring *tx_ring, struct sk_buff *skb,
+			  u32 tx_flags, __be16 protocol, u8 *hdr_len)
 {
 	int err;
 	u32 vlan_macip_lens, type_tucmd;
@@ -4006,7 +4006,7 @@ static inline int igb_tso(struct igb_ring *tx_ring,
 	/* ADV DTYP TUCMD MKRLOC/ISCSIHEDLEN */
 	type_tucmd = E1000_ADVTXD_TUCMD_L4T_TCP;
 
-	if (skb->protocol == htons(ETH_P_IP)) {
+	if (protocol == __constant_htons(ETH_P_IP)) {
 		struct iphdr *iph = ip_hdr(skb);
 		iph->tot_len = 0;
 		iph->check = 0;
@@ -4039,8 +4039,8 @@ static inline int igb_tso(struct igb_ring *tx_ring,
 	return 1;
 }
 
-static inline bool igb_tx_csum(struct igb_ring *tx_ring,
-			       struct sk_buff *skb, u32 tx_flags)
+static inline bool igb_tx_csum(struct igb_ring *tx_ring, struct sk_buff *skb,
+			       u32 tx_flags, __be16 protocol)
 {
 	u32 vlan_macip_lens = 0;
 	u32 mss_l4len_idx = 0;
@@ -4051,7 +4051,7 @@ static inline bool igb_tx_csum(struct igb_ring *tx_ring,
 			return false;
 	} else {
 		u8 l4_hdr = 0;
-		switch (skb->protocol) {
+		switch (protocol) {
 		case __constant_htons(ETH_P_IP):
 			vlan_macip_lens |= skb_network_header_len(skb);
 			type_tucmd |= E1000_ADVTXD_TUCMD_IPV4;
@@ -4065,7 +4065,7 @@ static inline bool igb_tx_csum(struct igb_ring *tx_ring,
 			if (unlikely(net_ratelimit())) {
 				dev_warn(tx_ring->dev,
 				 "partial checksum but proto=%x!\n",
-				 skb->protocol);
+				 protocol);
 			}
 			break;
 		}
@@ -4305,6 +4305,7 @@ netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
 	struct igb_tx_buffer *first;
 	int tso, count;
 	u32 tx_flags = 0;
+	__be16 protocol = vlan_get_protocol(skb);
 	u8 hdr_len = 0;
 
 	/* need: 1 descriptor per page,
@@ -4330,16 +4331,14 @@ netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
 	/* record the location of the first descriptor for this packet */
 	first = &tx_ring->tx_buffer_info[tx_ring->next_to_use];
 
-	tso = igb_tso(tx_ring, skb, tx_flags, &hdr_len);
-
+	tso = igb_tso(tx_ring, skb, tx_flags, protocol, &hdr_len);
 	if (tso < 0) {
 		goto out_drop;
 	} else if (tso) {
 		tx_flags |= IGB_TX_FLAGS_TSO | IGB_TX_FLAGS_CSUM;
-		if (skb->protocol == htons(ETH_P_IP))
+		if (protocol == htons(ETH_P_IP))
 			tx_flags |= IGB_TX_FLAGS_IPV4;
-
-	} else if (igb_tx_csum(tx_ring, skb, tx_flags) &&
+	} else if (igb_tx_csum(tx_ring, skb, tx_flags, protocol) &&
 		   (skb->ip_summed == CHECKSUM_PARTIAL)) {
 		tx_flags |= IGB_TX_FLAGS_CSUM;
 	}
-- 
1.7.6.4
