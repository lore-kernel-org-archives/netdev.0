From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/10] ixgbe: Update ixgbe Tx flags to improve code efficiency
Date: Sat, 19 Jan 2013 05:14:53 -0800
Message-ID: <1358601299-10404-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1358601299-10404-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:39020 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751309Ab3ASNPH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Jan 2013 08:15:07 -0500
In-Reply-To: <1358601299-10404-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change is meant to improve the efficiency of the Tx flags in ixgbe by
aligning them with the values that will later be written into either the
cmd_type or olinfo.  By doing this we are able to reduce most of these
functions to either just a simple shift followed by an or in the case of
cmd_type, or an and followed by an or in the case of olinfo.

To do this I also needed to change the logic and/or drop some flags.  I
dropped the IXGBE_TX_FLAGS_FSO and it was replaced by IXGBE_TX_FLAGS_TSO since
the only place it was ever checked was in conjunction with IXGBE_TX_FLAGS_TSO.
I replaced IXGBE_TX_FLAGS_TXSW with IXGBE_TX_FLAGS_CC, this way we have a
clear point for what the flag is meant to do.  Finally the
IXGBE_TX_FLAGS_NO_IFCS was dropped since were are already carrying the data
for that flag in the skb.  Instead we can just check the bitflag in the skb.

In order to avoid type conversion errors I also adjusted the locations
where we were switching between CPU and little endian.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h      | 27 +++++----
 drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c |  4 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 79 +++++++++++++--------------
 3 files changed, 57 insertions(+), 53 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 8e78676..f94c085 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -96,16 +96,23 @@
 /* How many Rx Buffers do we bundle into one write to the hardware ? */
 #define IXGBE_RX_BUFFER_WRITE	16	/* Must be power of 2 */
 
-#define IXGBE_TX_FLAGS_CSUM		(u32)(1)
-#define IXGBE_TX_FLAGS_HW_VLAN		(u32)(1 << 1)
-#define IXGBE_TX_FLAGS_SW_VLAN		(u32)(1 << 2)
-#define IXGBE_TX_FLAGS_TSO		(u32)(1 << 3)
-#define IXGBE_TX_FLAGS_IPV4		(u32)(1 << 4)
-#define IXGBE_TX_FLAGS_FCOE		(u32)(1 << 5)
-#define IXGBE_TX_FLAGS_FSO		(u32)(1 << 6)
-#define IXGBE_TX_FLAGS_TXSW		(u32)(1 << 7)
-#define IXGBE_TX_FLAGS_TSTAMP		(u32)(1 << 8)
-#define IXGBE_TX_FLAGS_NO_IFCS		(u32)(1 << 9)
+enum ixgbe_tx_flags {
+	/* cmd_type flags */
+	IXGBE_TX_FLAGS_HW_VLAN	= 0x01,
+	IXGBE_TX_FLAGS_TSO	= 0x02,
+	IXGBE_TX_FLAGS_TSTAMP	= 0x04,
+
+	/* olinfo flags */
+	IXGBE_TX_FLAGS_CC	= 0x08,
+	IXGBE_TX_FLAGS_IPV4	= 0x10,
+	IXGBE_TX_FLAGS_CSUM	= 0x20,
+
+	/* software defined flags */
+	IXGBE_TX_FLAGS_SW_VLAN	= 0x40,
+	IXGBE_TX_FLAGS_FCOE	= 0x80,
+};
+
+/* VLAN info */
 #define IXGBE_TX_FLAGS_VLAN_MASK	0xffff0000
 #define IXGBE_TX_FLAGS_VLAN_PRIO_MASK	0xe0000000
 #define IXGBE_TX_FLAGS_VLAN_PRIO_SHIFT  29
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
index c88aa1c..4968367 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_fcoe.c
@@ -544,11 +544,11 @@ int ixgbe_fso(struct ixgbe_ring *tx_ring,
 		first->gso_segs = DIV_ROUND_UP(skb->len - *hdr_len,
 					       skb_shinfo(skb)->gso_size);
 		first->bytecount += (first->gso_segs - 1) * *hdr_len;
-		first->tx_flags |= IXGBE_TX_FLAGS_FSO;
+		first->tx_flags |= IXGBE_TX_FLAGS_TSO;
 	}
 
 	/* set flag indicating FCOE to ixgbe_tx_map call */
-	first->tx_flags |= IXGBE_TX_FLAGS_FCOE;
+	first->tx_flags |= IXGBE_TX_FLAGS_FCOE | IXGBE_TX_FLAGS_CC;
 
 	/* mss_l4len_id: use 0 for FSO as TSO, no need for L4LEN */
 	mss_l4len_idx = skb_shinfo(skb)->gso_size << IXGBE_ADVTXD_MSS_SHIFT;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 2e2bf33..f7a314f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5968,12 +5968,9 @@ static void ixgbe_tx_csum(struct ixgbe_ring *tx_ring,
 	u32 type_tucmd = 0;
 
 	if (skb->ip_summed != CHECKSUM_PARTIAL) {
-		if (!(first->tx_flags & IXGBE_TX_FLAGS_HW_VLAN)) {
-			if (unlikely(skb->no_fcs))
-				first->tx_flags |= IXGBE_TX_FLAGS_NO_IFCS;
-			if (!(first->tx_flags & IXGBE_TX_FLAGS_TXSW))
-				return;
-		}
+		if (!(first->tx_flags & IXGBE_TX_FLAGS_HW_VLAN) &&
+		    !(first->tx_flags & IXGBE_TX_FLAGS_CC))
+			return;
 	} else {
 		u8 l4_hdr = 0;
 		switch (first->protocol) {
@@ -6031,30 +6028,32 @@ static void ixgbe_tx_csum(struct ixgbe_ring *tx_ring,
 			  type_tucmd, mss_l4len_idx);
 }
 
-static __le32 ixgbe_tx_cmd_type(u32 tx_flags)
+#define IXGBE_SET_FLAG(_input, _flag, _result) \
+	((_flag <= _result) ? \
+	 ((u32)(_input & _flag) * (_result / _flag)) : \
+	 ((u32)(_input & _flag) / (_flag / _result)))
+
+static u32 ixgbe_tx_cmd_type(struct sk_buff *skb, u32 tx_flags)
 {
 	/* set type for advanced descriptor with frame checksum insertion */
-	__le32 cmd_type = cpu_to_le32(IXGBE_ADVTXD_DTYP_DATA |
-				      IXGBE_ADVTXD_DCMD_DEXT);
+	u32 cmd_type = IXGBE_ADVTXD_DTYP_DATA |
+		       IXGBE_ADVTXD_DCMD_DEXT |
+		       IXGBE_ADVTXD_DCMD_IFCS;
 
 	/* set HW vlan bit if vlan is present */
-	if (tx_flags & IXGBE_TX_FLAGS_HW_VLAN)
-		cmd_type |= cpu_to_le32(IXGBE_ADVTXD_DCMD_VLE);
-
-	if (tx_flags & IXGBE_TX_FLAGS_TSTAMP)
-		cmd_type |= cpu_to_le32(IXGBE_ADVTXD_MAC_TSTAMP);
+	cmd_type |= IXGBE_SET_FLAG(tx_flags, IXGBE_TX_FLAGS_HW_VLAN,
+				   IXGBE_ADVTXD_DCMD_VLE);
 
 	/* set segmentation enable bits for TSO/FSO */
-#ifdef IXGBE_FCOE
-	if (tx_flags & (IXGBE_TX_FLAGS_TSO | IXGBE_TX_FLAGS_FSO))
-#else
-	if (tx_flags & IXGBE_TX_FLAGS_TSO)
-#endif
-		cmd_type |= cpu_to_le32(IXGBE_ADVTXD_DCMD_TSE);
+	cmd_type |= IXGBE_SET_FLAG(tx_flags, IXGBE_TX_FLAGS_TSO,
+				   IXGBE_ADVTXD_DCMD_TSE);
+
+	/* set timestamp bit if present */
+	cmd_type |= IXGBE_SET_FLAG(tx_flags, IXGBE_TX_FLAGS_TSTAMP,
+				   IXGBE_ADVTXD_MAC_TSTAMP);
 
 	/* insert frame checksum */
-	if (!(tx_flags & IXGBE_TX_FLAGS_NO_IFCS))
-		cmd_type |= cpu_to_le32(IXGBE_ADVTXD_DCMD_IFCS);
+	cmd_type ^= IXGBE_SET_FLAG(skb->no_fcs, 1, IXGBE_ADVTXD_DCMD_IFCS);
 
 	return cmd_type;
 }
@@ -6062,28 +6061,27 @@ static __le32 ixgbe_tx_cmd_type(u32 tx_flags)
 static void ixgbe_tx_olinfo_status(union ixgbe_adv_tx_desc *tx_desc,
 				   u32 tx_flags, unsigned int paylen)
 {
-	__le32 olinfo_status = cpu_to_le32(paylen << IXGBE_ADVTXD_PAYLEN_SHIFT);
+	u32 olinfo_status = paylen << IXGBE_ADVTXD_PAYLEN_SHIFT;
 
 	/* enable L4 checksum for TSO and TX checksum offload */
-	if (tx_flags & IXGBE_TX_FLAGS_CSUM)
-		olinfo_status |= cpu_to_le32(IXGBE_ADVTXD_POPTS_TXSM);
+	olinfo_status |= IXGBE_SET_FLAG(tx_flags,
+					IXGBE_TX_FLAGS_CSUM,
+					IXGBE_ADVTXD_POPTS_TXSM);
 
 	/* enble IPv4 checksum for TSO */
-	if (tx_flags & IXGBE_TX_FLAGS_IPV4)
-		olinfo_status |= cpu_to_le32(IXGBE_ADVTXD_POPTS_IXSM);
+	olinfo_status |= IXGBE_SET_FLAG(tx_flags,
+					IXGBE_TX_FLAGS_IPV4,
+					IXGBE_ADVTXD_POPTS_IXSM);
 
 	/*
 	 * Check Context must be set if Tx switch is enabled, which it
 	 * always is for case where virtual functions are running
 	 */
-#ifdef IXGBE_FCOE
-	if (tx_flags & (IXGBE_TX_FLAGS_TXSW | IXGBE_TX_FLAGS_FCOE))
-#else
-	if (tx_flags & IXGBE_TX_FLAGS_TXSW)
-#endif
-		olinfo_status |= cpu_to_le32(IXGBE_ADVTXD_CC);
+	olinfo_status |= IXGBE_SET_FLAG(tx_flags,
+					IXGBE_TX_FLAGS_CC,
+					IXGBE_ADVTXD_CC);
 
-	tx_desc->read.olinfo_status = olinfo_status;
+	tx_desc->read.olinfo_status = cpu_to_le32(olinfo_status);
 }
 
 #define IXGBE_TXD_CMD (IXGBE_TXD_CMD_EOP | \
@@ -6102,13 +6100,12 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 	unsigned int size = skb_headlen(skb);
 	unsigned int paylen = skb->len - hdr_len;
 	u32 tx_flags = first->tx_flags;
-	__le32 cmd_type;
+	u32 cmd_type = ixgbe_tx_cmd_type(skb, tx_flags);
 	u16 i = tx_ring->next_to_use;
 
 	tx_desc = IXGBE_TX_DESC(tx_ring, i);
 
 	ixgbe_tx_olinfo_status(tx_desc, tx_flags, paylen);
-	cmd_type = ixgbe_tx_cmd_type(tx_flags);
 
 #ifdef IXGBE_FCOE
 	if (tx_flags & IXGBE_TX_FLAGS_FCOE) {
@@ -6134,7 +6131,7 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 	for (;;) {
 		while (unlikely(size > IXGBE_MAX_DATA_PER_TXD)) {
 			tx_desc->read.cmd_type_len =
-				cmd_type | cpu_to_le32(IXGBE_MAX_DATA_PER_TXD);
+				cpu_to_le32(cmd_type ^ IXGBE_MAX_DATA_PER_TXD);
 
 			i++;
 			tx_desc++;
@@ -6153,7 +6150,7 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 		if (likely(!data_len))
 			break;
 
-		tx_desc->read.cmd_type_len = cmd_type | cpu_to_le32(size);
+		tx_desc->read.cmd_type_len = cpu_to_le32(cmd_type ^ size);
 
 		i++;
 		tx_desc++;
@@ -6185,8 +6182,8 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 	}
 
 	/* write last descriptor with RS and EOP bits */
-	cmd_type |= cpu_to_le32(size) | cpu_to_le32(IXGBE_TXD_CMD);
-	tx_desc->read.cmd_type_len = cmd_type;
+	cmd_type |= size | IXGBE_TXD_CMD;
+	tx_desc->read.cmd_type_len = cpu_to_le32(cmd_type);
 
 	netdev_tx_sent_queue(txring_txq(tx_ring), first->bytecount);
 
@@ -6447,7 +6444,7 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 	 * Tx switch had been disabled.
 	 */
 	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
-		tx_flags |= IXGBE_TX_FLAGS_TXSW;
+		tx_flags |= IXGBE_TX_FLAGS_CC;
 
 #endif
 	/* DCB maps skb priorities 0-7 onto 3 bit PCP of VLAN tag. */
-- 
1.7.11.7
