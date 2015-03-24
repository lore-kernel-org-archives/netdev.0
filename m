From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: [PATCH net-next v7 4/7] ixgbevf: Add a RETA query code
Date: Tue, 24 Mar 2015 15:05:43 +0200
Message-ID: <1427202346-12502-5-git-send-email-vladz@cloudius-systems.com>
References: <1427202346-12502-1-git-send-email-vladz@cloudius-systems.com>
Cc: jeffrey.t.kirsher@intel.com, avi@cloudius-systems.com,
	gleb@cloudius-systems.com,
	Vlad Zolotarov <vladz@cloudius-systems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:37783 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752302AbbCXNF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 09:05:59 -0400
Received: by wixw10 with SMTP id w10so95287498wix.0
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 06:05:57 -0700 (PDT)
In-Reply-To: <1427202346-12502-1-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

   - Added a new API version support.
   - Added the query implementation in the ixgbevf.

Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
---
New in v7:
   - Add ixgbe_mbox_api_12 case in ixgbevf_set_num_queues().
   - Properly expand HW RETA into the ethtool buffer.

New in v6:
   - Add a proper return code when an operation is blocked by PF.

New in v3:
   - Adjusted to the new interface IXGBE_VF_GET_RETA command.
   - Added a proper support for x550 devices.

New in v1 (compared to RFC):
   - Use "if-else" statement instead of a "switch-case" for a single option case
     (in ixgbevf_get_reta()).
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  5 +-
 drivers/net/ethernet/intel/ixgbevf/mbx.h          |  8 ++
 drivers/net/ethernet/intel/ixgbevf/vf.c           | 97 +++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbevf/vf.h           |  1 +
 4 files changed, 110 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 4ee15ad..a16d267 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -2030,7 +2030,8 @@ static void ixgbevf_init_last_counter_stats(struct ixgbevf_adapter *adapter)
 static void ixgbevf_negotiate_api(struct ixgbevf_adapter *adapter)
 {
 	struct ixgbe_hw *hw = &adapter->hw;
-	int api[] = { ixgbe_mbox_api_11,
+	int api[] = { ixgbe_mbox_api_12,
+		      ixgbe_mbox_api_11,
 		      ixgbe_mbox_api_10,
 		      ixgbe_mbox_api_unknown };
 	int err = 0, idx = 0;
@@ -2332,6 +2333,7 @@ static void ixgbevf_set_num_queues(struct ixgbevf_adapter *adapter)
 
 		switch (hw->api_version) {
 		case ixgbe_mbox_api_11:
+		case ixgbe_mbox_api_12:
 			adapter->num_rx_queues = rss;
 			adapter->num_tx_queues = rss;
 		default:
@@ -3712,6 +3714,7 @@ static int ixgbevf_change_mtu(struct net_device *netdev, int new_mtu)
 
 	switch (adapter->hw.api_version) {
 	case ixgbe_mbox_api_11:
+	case ixgbe_mbox_api_12:
 		max_possible_frame = IXGBE_MAX_JUMBO_FRAME_SIZE;
 		break;
 	default:
diff --git a/drivers/net/ethernet/intel/ixgbevf/mbx.h b/drivers/net/ethernet/intel/ixgbevf/mbx.h
index 6253e93..7342554 100644
--- a/drivers/net/ethernet/intel/ixgbevf/mbx.h
+++ b/drivers/net/ethernet/intel/ixgbevf/mbx.h
@@ -83,6 +83,7 @@ enum ixgbe_pfvf_api_rev {
 	ixgbe_mbox_api_10,	/* API version 1.0, linux/freebsd VF driver */
 	ixgbe_mbox_api_20,	/* API version 2.0, solaris Phase1 VF driver */
 	ixgbe_mbox_api_11,	/* API version 1.1, linux/freebsd VF driver */
+	ixgbe_mbox_api_12,	/* API version 1.2, linux/freebsd VF driver */
 	/* This value should always be last */
 	ixgbe_mbox_api_unknown,	/* indicates that API version is not known */
 };
@@ -107,6 +108,13 @@ enum ixgbe_pfvf_api_rev {
 #define IXGBE_VF_TRANS_VLAN	3 /* Indication of port VLAN */
 #define IXGBE_VF_DEF_QUEUE	4 /* Default queue offset */
 
+/* mailbox API, version 1.2 VF requests */
+#define IXGBE_VF_GET_RETA	0x0a	/* VF request for RETA */
+
+/* GET_RETA request data indices within the mailbox */
+#define IXGBE_VF_RETA_SZ        1	/* Number of RETA DWs to bring */
+#define IXGBE_VF_RETA_OFFSET    2	/* Offset in RETA */
+
 /* length of permanent address message returned from PF */
 #define IXGBE_VF_PERMADDR_MSG_LEN	4
 /* word in permanent address message with the current multicast type */
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index 2614fd3..3e51db6 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -256,6 +256,102 @@ static s32 ixgbevf_set_uc_addr_vf(struct ixgbe_hw *hw, u32 index, u8 *addr)
 	return ret_val;
 }
 
+static inline int _ixgbevf_get_reta(struct ixgbe_hw *hw, u32 *msgbuf,
+				    u32 *reta, u32 reta_offset_dw, u32 dwords)
+{
+	int err, i;
+	u8 *hw_reta = (u8 *)&msgbuf[1];
+
+	msgbuf[0]                    = IXGBE_VF_GET_RETA;
+	msgbuf[IXGBE_VF_RETA_SZ]     = dwords;
+	msgbuf[IXGBE_VF_RETA_OFFSET] = reta_offset_dw;
+
+	err = hw->mbx.ops.write_posted(hw, msgbuf, 3);
+
+	if (err)
+		return err;
+
+	err = hw->mbx.ops.read_posted(hw, msgbuf, 1 + dwords);
+
+	if (err)
+		return err;
+
+	msgbuf[0] &= ~IXGBE_VT_MSGTYPE_CTS;
+
+	/* If the operation has been refused by a PF return -EPERM */
+	if (msgbuf[0] == (IXGBE_VF_GET_RETA | IXGBE_VT_MSGTYPE_NACK))
+		return -EPERM;
+
+	/* If we didn't get an ACK there must have been
+	 * some sort of mailbox error so we should treat it
+	 * as such.
+	 */
+	if (msgbuf[0] != (IXGBE_VF_GET_RETA | IXGBE_VT_MSGTYPE_ACK))
+		return IXGBE_ERR_MBX;
+
+	/* HW RETA is an array of u8, while ethtool buffer is an array of u32.
+	 * Therefore we need to "expand" the HW RETA into the ethtool buffer.
+	 */
+	for (i = 0; i < dwords * 4; i++)
+		reta[reta_offset_dw * 4 + i] = hw_reta[i];
+
+	return 0;
+}
+
+/**
+ * ixgbevf_get_reta - get the RSS redirection table (RETA) contents.
+ * @hw: pointer to the HW structure
+ * @reta: buffer to fill with RETA contents.
+ *
+ * The "reta" buffer should be big enough to contain 32 registers.
+ *
+ * Returns: 0 on success.
+ *          if API doesn't support this operation - (-EPERM).
+ */
+int ixgbevf_get_reta(struct ixgbe_hw *hw, u32 *reta)
+{
+	int err;
+	u32 msgbuf[IXGBE_VFMAILBOX_SIZE];
+
+	/* Return an error if API doesn't RETA querying. */
+	if (hw->api_version != ixgbe_mbox_api_12)
+		return -EPERM;
+
+	/* x550 devices have a separate RETA for each VF: 64 bytes each.
+	 *
+	 * We'll get it in 2 steps due to mailbox size limitation - we can bring
+	 * up to 15 dwords every time. Therefore we'll bring 12 and 4 dwords.
+	 *
+	 * Older devices share a RETA table with the PF: 128 bytes.
+	 *
+	 * For them we do it in 3 steps. Therefore we'll bring it in 3 steps:
+	 * 12, 12 and 8 dwords in each step correspondingly.
+	 */
+
+	/* RETA[0..11] */
+	err = _ixgbevf_get_reta(hw, msgbuf, reta, 0, 12);
+	if (err)
+		return err;
+
+	if (hw->mac.type >= ixgbe_mac_X550_vf) {
+		/* RETA[12..15] */
+		err = _ixgbevf_get_reta(hw, msgbuf, reta, 12, 4);
+		if (err)
+			return err;
+
+	} else {
+		/* RETA[12..23] */
+		err = _ixgbevf_get_reta(hw, msgbuf, reta, 12, 12);
+		if (err)
+			return err;
+
+		/* RETA[24..31] */
+		err = _ixgbevf_get_reta(hw, msgbuf, reta, 24, 8);
+	}
+
+	return err;
+}
+
 /**
  *  ixgbevf_set_rar_vf - set device MAC address
  *  @hw: pointer to hardware structure
@@ -545,6 +641,7 @@ int ixgbevf_get_queues(struct ixgbe_hw *hw, unsigned int *num_tcs,
 	/* do nothing if API doesn't support ixgbevf_get_queues */
 	switch (hw->api_version) {
 	case ixgbe_mbox_api_11:
+	case ixgbe_mbox_api_12:
 		break;
 	default:
 		return 0;
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
index 6688250..89bc88e 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
@@ -210,4 +210,5 @@ void ixgbevf_rlpml_set_vf(struct ixgbe_hw *hw, u16 max_size);
 int ixgbevf_negotiate_api_version(struct ixgbe_hw *hw, int api);
 int ixgbevf_get_queues(struct ixgbe_hw *hw, unsigned int *num_tcs,
 		       unsigned int *default_tc);
+int ixgbevf_get_reta(struct ixgbe_hw *hw, u32 *reta);
 #endif /* __IXGBE_VF_H__ */
-- 
2.1.0
