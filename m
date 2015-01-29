From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net 2/4] igbvf: Fix checksum error when using stacked vlan
Date: Thu, 29 Jan 2015 20:37:08 +0900
Message-ID: <1422531430-32012-3-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1422531430-32012-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
	Linux NICS <linux.nics@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:52275 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754571AbbA2LiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 06:38:03 -0500
In-Reply-To: <1422531430-32012-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a skb has multiple vlans and it is CHECKSUM_PARTIAL,
igbvf_tx_csum() fails to get the network protocol and checksum related
descriptor fields are not configured correctly because skb->protocol
doesn't show the L3 protocol in this case.

Use vlan_get_protocol() to get the proper network protocol.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 drivers/net/ethernet/intel/igbvf/netdev.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/igbvf/netdev.c b/drivers/net/ethernet/intel/igbvf/netdev.c
index 63c807c..edea13b 100644
--- a/drivers/net/ethernet/intel/igbvf/netdev.c
+++ b/drivers/net/ethernet/intel/igbvf/netdev.c
@@ -1907,7 +1907,8 @@ static void igbvf_watchdog_task(struct work_struct *work)
 
 static int igbvf_tso(struct igbvf_adapter *adapter,
                      struct igbvf_ring *tx_ring,
-                     struct sk_buff *skb, u32 tx_flags, u8 *hdr_len)
+		     struct sk_buff *skb, u32 tx_flags, u8 *hdr_len,
+		     __be16 protocol)
 {
 	struct e1000_adv_tx_context_desc *context_desc;
 	struct igbvf_buffer *buffer_info;
@@ -1927,7 +1928,7 @@ static int igbvf_tso(struct igbvf_adapter *adapter,
 	l4len = tcp_hdrlen(skb);
 	*hdr_len += l4len;
 
-	if (skb->protocol == htons(ETH_P_IP)) {
+	if (protocol == htons(ETH_P_IP)) {
 		struct iphdr *iph = ip_hdr(skb);
 		iph->tot_len = 0;
 		iph->check = 0;
@@ -1958,7 +1959,7 @@ static int igbvf_tso(struct igbvf_adapter *adapter,
 	/* ADV DTYP TUCMD MKRLOC/ISCSIHEDLEN */
 	tu_cmd |= (E1000_TXD_CMD_DEXT | E1000_ADVTXD_DTYP_CTXT);
 
-	if (skb->protocol == htons(ETH_P_IP))
+	if (protocol == htons(ETH_P_IP))
 		tu_cmd |= E1000_ADVTXD_TUCMD_IPV4;
 	tu_cmd |= E1000_ADVTXD_TUCMD_L4T_TCP;
 
@@ -1984,7 +1985,8 @@ static int igbvf_tso(struct igbvf_adapter *adapter,
 
 static inline bool igbvf_tx_csum(struct igbvf_adapter *adapter,
                                  struct igbvf_ring *tx_ring,
-                                 struct sk_buff *skb, u32 tx_flags)
+				 struct sk_buff *skb, u32 tx_flags,
+				 __be16 protocol)
 {
 	struct e1000_adv_tx_context_desc *context_desc;
 	unsigned int i;
@@ -2011,7 +2013,7 @@ static inline bool igbvf_tx_csum(struct igbvf_adapter *adapter,
 		tu_cmd |= (E1000_TXD_CMD_DEXT | E1000_ADVTXD_DTYP_CTXT);
 
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
-			switch (skb->protocol) {
+			switch (protocol) {
 			case htons(ETH_P_IP):
 				tu_cmd |= E1000_ADVTXD_TUCMD_IPV4;
 				if (ip_hdr(skb)->protocol == IPPROTO_TCP)
@@ -2211,6 +2213,7 @@ static netdev_tx_t igbvf_xmit_frame_ring_adv(struct sk_buff *skb,
 	u8 hdr_len = 0;
 	int count = 0;
 	int tso = 0;
+	__be16 protocol = vlan_get_protocol(skb);
 
 	if (test_bit(__IGBVF_DOWN, &adapter->state)) {
 		dev_kfree_skb_any(skb);
@@ -2239,13 +2242,13 @@ static netdev_tx_t igbvf_xmit_frame_ring_adv(struct sk_buff *skb,
 		tx_flags |= (vlan_tx_tag_get(skb) << IGBVF_TX_FLAGS_VLAN_SHIFT);
 	}
 
-	if (skb->protocol == htons(ETH_P_IP))
+	if (protocol == htons(ETH_P_IP))
 		tx_flags |= IGBVF_TX_FLAGS_IPV4;
 
 	first = tx_ring->next_to_use;
 
 	tso = skb_is_gso(skb) ?
-		igbvf_tso(adapter, tx_ring, skb, tx_flags, &hdr_len) : 0;
+		igbvf_tso(adapter, tx_ring, skb, tx_flags, &hdr_len, protocol) : 0;
 	if (unlikely(tso < 0)) {
 		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
@@ -2253,7 +2256,7 @@ static netdev_tx_t igbvf_xmit_frame_ring_adv(struct sk_buff *skb,
 
 	if (tso)
 		tx_flags |= IGBVF_TX_FLAGS_TSO;
-	else if (igbvf_tx_csum(adapter, tx_ring, skb, tx_flags) &&
+	else if (igbvf_tx_csum(adapter, tx_ring, skb, tx_flags, protocol) &&
 	         (skb->ip_summed == CHECKSUM_PARTIAL))
 		tx_flags |= IGBVF_TX_FLAGS_CSUM;
 
-- 
1.8.1.2
