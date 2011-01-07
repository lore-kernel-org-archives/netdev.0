From: jeffrey.t.kirsher@intel.com
Subject: [net-next 11/12] ixgbe: further flow director performance optimizations
Date: Thu,  6 Jan 2011 16:29:58 -0800
Message-ID: <1294360199-9860-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gosp@redhat.com, bphilips@novell.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:64375 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754124Ab1AGAax (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Jan 2011 19:30:53 -0500
To: davem@davemloft.net
In-Reply-To: <1294360199-9860-1-git-send-email-jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change adds a compressed input type for atr signature hash
computation.  It also drops the use of the set functions when setting up
the ATR input since we can then directly setup the hash input as two dwords
that can be stored and passed as registers.

With these changes the cost of computing the has is low enough that we can
perform a hash computation on each TCP SYN flagged packet allowing us to
drop the number of flow director misses considerably in tests such as
netperf TCP_CRR.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ixgbe/ixgbe.h       |    3 +-
 drivers/net/ixgbe/ixgbe_82599.c |  112 ++++++++++++++++++++++++++++++++++-----
 drivers/net/ixgbe/ixgbe_main.c  |  107 +++++++++++++++++++++++++++----------
 drivers/net/ixgbe/ixgbe_type.h  |   16 ++++++
 4 files changed, 194 insertions(+), 44 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 2666e69..341b3db 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -526,7 +526,8 @@ extern s32 ixgbe_reinit_fdir_tables_82599(struct ixgbe_hw *hw);
 extern s32 ixgbe_init_fdir_signature_82599(struct ixgbe_hw *hw, u32 pballoc);
 extern s32 ixgbe_init_fdir_perfect_82599(struct ixgbe_hw *hw, u32 pballoc);
 extern s32 ixgbe_fdir_add_signature_filter_82599(struct ixgbe_hw *hw,
-                                                 union ixgbe_atr_input *input,
+						 union ixgbe_atr_hash_dword input,
+						 union ixgbe_atr_hash_dword common,
                                                  u8 queue);
 extern s32 ixgbe_fdir_add_perfect_filter_82599(struct ixgbe_hw *hw,
                                       union ixgbe_atr_input *input,
diff --git a/drivers/net/ixgbe/ixgbe_82599.c b/drivers/net/ixgbe/ixgbe_82599.c
index 40aa3c2..d41931f 100644
--- a/drivers/net/ixgbe/ixgbe_82599.c
+++ b/drivers/net/ixgbe/ixgbe_82599.c
@@ -1331,6 +1331,96 @@ static u32 ixgbe_atr_compute_hash_82599(union ixgbe_atr_input *atr_input,
 	return hash_result & IXGBE_ATR_HASH_MASK;
 }
 
+/*
+ * These defines allow us to quickly generate all of the necessary instructions
+ * in the function below by simply calling out IXGBE_COMPUTE_SIG_HASH_ITERATION
+ * for values 0 through 15
+ */
+#define IXGBE_ATR_COMMON_HASH_KEY \
+		(IXGBE_ATR_BUCKET_HASH_KEY & IXGBE_ATR_SIGNATURE_HASH_KEY)
+#define IXGBE_COMPUTE_SIG_HASH_ITERATION(_n) \
+do { \
+	u32 n = (_n); \
+	if (IXGBE_ATR_COMMON_HASH_KEY & (0x01 << n)) \
+		common_hash ^= lo_hash_dword >> n; \
+	else if (IXGBE_ATR_BUCKET_HASH_KEY & (0x01 << n)) \
+		bucket_hash ^= lo_hash_dword >> n; \
+	else if (IXGBE_ATR_SIGNATURE_HASH_KEY & (0x01 << n)) \
+		sig_hash ^= lo_hash_dword << (16 - n); \
+	if (IXGBE_ATR_COMMON_HASH_KEY & (0x01 << (n + 16))) \
+		common_hash ^= hi_hash_dword >> n; \
+	else if (IXGBE_ATR_BUCKET_HASH_KEY & (0x01 << (n + 16))) \
+		bucket_hash ^= hi_hash_dword >> n; \
+	else if (IXGBE_ATR_SIGNATURE_HASH_KEY & (0x01 << (n + 16))) \
+		sig_hash ^= hi_hash_dword << (16 - n); \
+} while (0);
+
+/**
+ *  ixgbe_atr_compute_sig_hash_82599 - Compute the signature hash
+ *  @stream: input bitstream to compute the hash on
+ *
+ *  This function is almost identical to the function above but contains
+ *  several optomizations such as unwinding all of the loops, letting the
+ *  compiler work out all of the conditional ifs since the keys are static
+ *  defines, and computing two keys at once since the hashed dword stream
+ *  will be the same for both keys.
+ **/
+static u32 ixgbe_atr_compute_sig_hash_82599(union ixgbe_atr_hash_dword input,
+					    union ixgbe_atr_hash_dword common)
+{
+	u32 hi_hash_dword, lo_hash_dword, flow_vm_vlan;
+	u32 sig_hash = 0, bucket_hash = 0, common_hash = 0;
+
+	/* record the flow_vm_vlan bits as they are a key part to the hash */
+	flow_vm_vlan = ntohl(input.dword);
+
+	/* generate common hash dword */
+	hi_hash_dword = ntohl(common.dword);
+
+	/* low dword is word swapped version of common */
+	lo_hash_dword = (hi_hash_dword >> 16) | (hi_hash_dword << 16);
+
+	/* apply flow ID/VM pool/VLAN ID bits to hash words */
+	hi_hash_dword ^= flow_vm_vlan ^ (flow_vm_vlan >> 16);
+
+	/* Process bits 0 and 16 */
+	IXGBE_COMPUTE_SIG_HASH_ITERATION(0);
+
+	/*
+	 * apply flow ID/VM pool/VLAN ID bits to lo hash dword, we had to
+	 * delay this because bit 0 of the stream should not be processed
+	 * so we do not add the vlan until after bit 0 was processed
+	 */
+	lo_hash_dword ^= flow_vm_vlan ^ (flow_vm_vlan << 16);
+
+	/* Process remaining 30 bit of the key */
+	IXGBE_COMPUTE_SIG_HASH_ITERATION(1);
+	IXGBE_COMPUTE_SIG_HASH_ITERATION(2);
+	IXGBE_COMPUTE_SIG_HASH_ITERATION(3);
+	IXGBE_COMPUTE_SIG_HASH_ITERATION(4);
+	IXGBE_COMPUTE_SIG_HASH_ITERATION(5);
+	IXGBE_COMPUTE_SIG_HASH_ITERATION(6);
+	IXGBE_COMPUTE_SIG_HASH_ITERATION(7);
+	IXGBE_COMPUTE_SIG_HASH_ITERATION(8);
+	IXGBE_COMPUTE_SIG_HASH_ITERATION(9);
+	IXGBE_COMPUTE_SIG_HASH_ITERATION(10);
+	IXGBE_COMPUTE_SIG_HASH_ITERATION(11);
+	IXGBE_COMPUTE_SIG_HASH_ITERATION(12);
+	IXGBE_COMPUTE_SIG_HASH_ITERATION(13);
+	IXGBE_COMPUTE_SIG_HASH_ITERATION(14);
+	IXGBE_COMPUTE_SIG_HASH_ITERATION(15);
+
+	/* combine common_hash result with signature and bucket hashes */
+	bucket_hash ^= common_hash;
+	bucket_hash &= IXGBE_ATR_HASH_MASK;
+
+	sig_hash ^= common_hash << 16;
+	sig_hash &= IXGBE_ATR_HASH_MASK << 16;
+
+	/* return completed signature hash */
+	return sig_hash ^ bucket_hash;
+}
+
 /**
  *  ixgbe_atr_set_vlan_id_82599 - Sets the VLAN id in the ATR input stream
  *  @input: input stream to modify
@@ -1539,22 +1629,23 @@ static s32 ixgbe_atr_get_l4type_82599(union ixgbe_atr_input *input,
 /**
  *  ixgbe_atr_add_signature_filter_82599 - Adds a signature hash filter
  *  @hw: pointer to hardware structure
- *  @stream: input bitstream
+ *  @input: unique input dword
+ *  @common: compressed common input dword
  *  @queue: queue index to direct traffic to
  **/
 s32 ixgbe_fdir_add_signature_filter_82599(struct ixgbe_hw *hw,
-                                          union ixgbe_atr_input *input,
+                                          union ixgbe_atr_hash_dword input,
+                                          union ixgbe_atr_hash_dword common,
                                           u8 queue)
 {
 	u64  fdirhashcmd;
 	u32  fdircmd;
-	u32  bucket_hash, sig_hash;
 
 	/*
 	 * Get the flow_type in order to program FDIRCMD properly
 	 * lowest 2 bits are FDIRCMD.L4TYPE, third lowest bit is FDIRCMD.IPV6
 	 */
-	switch (input->formatted.flow_type) {
+	switch (input.formatted.flow_type) {
 	case IXGBE_ATR_FLOW_TYPE_TCPV4:
 	case IXGBE_ATR_FLOW_TYPE_UDPV4:
 	case IXGBE_ATR_FLOW_TYPE_SCTPV4:
@@ -1570,7 +1661,7 @@ s32 ixgbe_fdir_add_signature_filter_82599(struct ixgbe_hw *hw,
 	/* configure FDIRCMD register */
 	fdircmd = IXGBE_FDIRCMD_CMD_ADD_FLOW | IXGBE_FDIRCMD_FILTER_UPDATE |
 	          IXGBE_FDIRCMD_LAST | IXGBE_FDIRCMD_QUEUE_EN;
-	fdircmd |= input->formatted.flow_type << IXGBE_FDIRCMD_FLOW_TYPE_SHIFT;
+	fdircmd |= input.formatted.flow_type << IXGBE_FDIRCMD_FLOW_TYPE_SHIFT;
 	fdircmd |= (u32)queue << IXGBE_FDIRCMD_RX_QUEUE_SHIFT;
 
 	/*
@@ -1578,17 +1669,12 @@ s32 ixgbe_fdir_add_signature_filter_82599(struct ixgbe_hw *hw,
 	 * is for FDIRCMD.  Then do a 64-bit register write from FDIRHASH.
 	 */
 	fdirhashcmd = (u64)fdircmd << 32;
-
-	sig_hash = ixgbe_atr_compute_hash_82599(input,
-	                                        IXGBE_ATR_SIGNATURE_HASH_KEY);
-	fdirhashcmd |= sig_hash << IXGBE_FDIRHASH_SIG_SW_INDEX_SHIFT;
-
-	bucket_hash = ixgbe_atr_compute_hash_82599(input,
-	                                           IXGBE_ATR_BUCKET_HASH_KEY);
-	fdirhashcmd |= bucket_hash;
+	fdirhashcmd |= ixgbe_atr_compute_sig_hash_82599(input, common);
 
 	IXGBE_WRITE_REG64(hw, IXGBE_FDIRHASH, fdirhashcmd);
 
+	hw_dbg(hw, "Tx Queue=%x hash=%x\n", queue, (u32)fdirhashcmd);
+
 	return 0;
 }
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 26718ab..490818c 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6506,37 +6506,92 @@ static void ixgbe_tx_queue(struct ixgbe_ring *tx_ring,
 	writel(i, tx_ring->tail);
 }
 
-static void ixgbe_atr(struct ixgbe_adapter *adapter, struct sk_buff *skb,
-		      u8 queue, u32 tx_flags, __be16 protocol)
-{
-	union ixgbe_atr_input atr_input;
-	struct iphdr *iph = ip_hdr(skb);
-	struct ethhdr *eth = (struct ethhdr *)skb->data;
+static void ixgbe_atr(struct ixgbe_ring *ring, struct sk_buff *skb,
+		      u32 tx_flags, __be16 protocol)
+{
+	struct ixgbe_q_vector *q_vector = ring->q_vector;
+	union ixgbe_atr_hash_dword input = { .dword = 0 };
+	union ixgbe_atr_hash_dword common = { .dword = 0 };
+	union {
+		unsigned char *network;
+		struct iphdr *ipv4;
+		struct ipv6hdr *ipv6;
+	} hdr;
 	struct tcphdr *th;
 	__be16 vlan_id;
 
-	/* Right now, we support IPv4 w/ TCP only */
-	if (protocol != htons(ETH_P_IP) ||
-	    iph->protocol != IPPROTO_TCP)
+	/* if ring doesn't have a interrupt vector, cannot perform ATR */
+	if (!q_vector)
+		return;
+
+	/* do nothing if sampling is disabled */
+	if (!ring->atr_sample_rate)
 		return;
 
-	memset(&atr_input, 0, sizeof(union ixgbe_atr_input));
+	ring->atr_count++;
 
-	vlan_id = htons(tx_flags >> IXGBE_TX_FLAGS_VLAN_SHIFT);
+	/* snag network header to get L4 type and address */
+	hdr.network = skb_network_header(skb);
+
+	/* Currently only IPv4/IPv6 with TCP is supported */
+	if ((protocol != __constant_htons(ETH_P_IPV6) ||
+	     hdr.ipv6->nexthdr != IPPROTO_TCP) &&
+	    (protocol != __constant_htons(ETH_P_IP) ||
+	     hdr.ipv4->protocol != IPPROTO_TCP))
+		return;
 
 	th = tcp_hdr(skb);
 
-	ixgbe_atr_set_vlan_id_82599(&atr_input, vlan_id);
-	ixgbe_atr_set_src_port_82599(&atr_input, th->dest);
-	ixgbe_atr_set_dst_port_82599(&atr_input, th->source);
-	ixgbe_atr_set_flex_byte_82599(&atr_input, eth->h_proto);
-	ixgbe_atr_set_l4type_82599(&atr_input, IXGBE_ATR_FLOW_TYPE_TCPV4);
-	/* src and dst are inverted, think how the receiver sees them */
-	ixgbe_atr_set_src_ipv4_82599(&atr_input, iph->daddr);
-	ixgbe_atr_set_dst_ipv4_82599(&atr_input, iph->saddr);
+	/* skip this packet since the socket is closing */
+	if (th->fin)
+		return;
+
+	/* sample on all syn packets or once every atr sample count */
+	if (!th->syn && (ring->atr_count < ring->atr_sample_rate))
+		return;
+
+	/* reset sample count */
+	ring->atr_count = 0;
+
+	vlan_id = htons(tx_flags >> IXGBE_TX_FLAGS_VLAN_SHIFT);
+
+	/*
+	 * src and dst are inverted, think how the receiver sees them
+	 *
+	 * The input is broken into two sections, a non-compressed section
+	 * containing vm_pool, vlan_id, and flow_type.  The rest of the data
+	 * is XORed together and stored in the compressed dword.
+	 */
+	input.formatted.vlan_id = vlan_id;
+
+	/*
+	 * since src port and flex bytes occupy the same word XOR them together
+	 * and write the value to source port portion of compressed dword
+	 */
+	if (vlan_id)
+		common.port.src ^= th->dest ^ __constant_htons(ETH_P_8021Q);
+	else
+		common.port.src ^= th->dest ^ protocol;
+	common.port.dst ^= th->source;
+
+	if (protocol == __constant_htons(ETH_P_IP)) {
+		input.formatted.flow_type = IXGBE_ATR_FLOW_TYPE_TCPV4;
+		common.ip ^= hdr.ipv4->saddr ^ hdr.ipv4->daddr;
+	} else {
+		input.formatted.flow_type = IXGBE_ATR_FLOW_TYPE_TCPV6;
+		common.ip ^= hdr.ipv6->saddr.s6_addr32[0] ^
+			     hdr.ipv6->saddr.s6_addr32[1] ^
+			     hdr.ipv6->saddr.s6_addr32[2] ^
+			     hdr.ipv6->saddr.s6_addr32[3] ^
+			     hdr.ipv6->daddr.s6_addr32[0] ^
+			     hdr.ipv6->daddr.s6_addr32[1] ^
+			     hdr.ipv6->daddr.s6_addr32[2] ^
+			     hdr.ipv6->daddr.s6_addr32[3];
+	}
 
 	/* This assumes the Rx queue and Tx queue are bound to the same CPU */
-	ixgbe_fdir_add_signature_filter_82599(&adapter->hw, &atr_input, queue);
+	ixgbe_fdir_add_signature_filter_82599(&q_vector->adapter->hw,
+					      input, common, ring->queue_index);
 }
 
 static int __ixgbe_maybe_stop_tx(struct ixgbe_ring *tx_ring, int size)
@@ -6707,16 +6762,8 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 	count = ixgbe_tx_map(adapter, tx_ring, skb, tx_flags, first, hdr_len);
 	if (count) {
 		/* add the ATR filter if ATR is on */
-		if (tx_ring->atr_sample_rate) {
-			++tx_ring->atr_count;
-			if ((tx_ring->atr_count >= tx_ring->atr_sample_rate) &&
-			     test_bit(__IXGBE_TX_FDIR_INIT_DONE,
-				      &tx_ring->state)) {
-				ixgbe_atr(adapter, skb, tx_ring->queue_index,
-					  tx_flags, protocol);
-				tx_ring->atr_count = 0;
-			}
-		}
+		if (test_bit(__IXGBE_TX_FDIR_INIT_DONE, &tx_ring->state))
+			ixgbe_atr(tx_ring, skb, tx_flags, protocol);
 		txq = netdev_get_tx_queue(netdev, tx_ring->queue_index);
 		txq->tx_bytes += skb->len;
 		txq->tx_packets++;
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index c56a712..0d9392d 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -2198,6 +2198,22 @@ union ixgbe_atr_input {
 	__be32 dword_stream[11];
 };
 
+/* Flow Director compressed ATR hash input struct */
+union ixgbe_atr_hash_dword {
+	struct {
+		u8 vm_pool;
+		u8 flow_type;
+		__be16 vlan_id;
+	} formatted;
+	__be32 ip;
+	struct {
+		__be16 src;
+		__be16 dst;
+	} port;
+	__be16 flex_bytes;
+	__be32 dword;
+};
+
 struct ixgbe_atr_input_masks {
 	__be32 src_ip_mask;
 	__be32 dst_ip_mask;
-- 
1.7.3.4

