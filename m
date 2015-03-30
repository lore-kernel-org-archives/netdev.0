From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: [PATCH net-next v10 6/7] ixgbevf: Add RSS Key query code
Date: Mon, 30 Mar 2015 21:35:28 +0300
Message-ID: <1427740529-9605-7-git-send-email-vladz@cloudius-systems.com>
References: <1427740529-9605-1-git-send-email-vladz@cloudius-systems.com>
Cc: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
	avi@cloudius-systems.com, gleb@cloudius-systems.com,
	Vlad Zolotarov <vladz@cloudius-systems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:38086 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753419AbbC3Sfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 14:35:47 -0400
Received: by wibgn9 with SMTP id gn9so142223870wib.1
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 11:35:45 -0700 (PDT)
In-Reply-To: <1427740529-9605-1-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the ixgbevf_get_rss_key() function that queries the PF for an RSS Random Key
using a new VF-PF channel IXGBE_VF_GET_RSS_KEY command.

This patch adds the support for 82599 and x540 devices only. Support for other
devices will be added later.

Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
---
New in v10:
   - Expose the _locked function in the vf.h interface according
     to the current ixgbevf layering model.
   - Return EOPNOTSUPP in cases then operation is not supported.

New in v9:
   - Reduce the support to 82599 and x540 devices only.
   - Added IXGBEVF_RSS_HASH_KEY_SIZE macro.

New in v8:
   - Protect a mailbox access.

New in v6:
   - Return a proper return code when an operation is blocked by PF.

New in v2:
   - Added a more detailed patch description.

New in v1 (compared to RFC):
   - Use "if-else" statement instead of a "switch-case" for a single option case
     (in ixgbevf_get_rss_key()).
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h |  1 +
 drivers/net/ethernet/intel/ixgbevf/mbx.h     |  1 +
 drivers/net/ethernet/intel/ixgbevf/vf.c      | 54 ++++++++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbevf/vf.h      |  1 +
 4 files changed, 57 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index f317f77..31089a1 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -146,6 +146,7 @@ struct ixgbevf_ring {
 #define MAX_TX_QUEUES IXGBE_VF_MAX_TX_QUEUES
 #define IXGBEVF_MAX_RSS_QUEUES	2
 #define IXGBEVF_82599_RETA_SIZE		128
+#define IXGBEVF_RSS_HASH_KEY_SIZE	40
 
 #define IXGBEVF_DEFAULT_TXD	1024
 #define IXGBEVF_DEFAULT_RXD	512
diff --git a/drivers/net/ethernet/intel/ixgbevf/mbx.h b/drivers/net/ethernet/intel/ixgbevf/mbx.h
index 66e138b..82f44e0 100644
--- a/drivers/net/ethernet/intel/ixgbevf/mbx.h
+++ b/drivers/net/ethernet/intel/ixgbevf/mbx.h
@@ -110,6 +110,7 @@ enum ixgbe_pfvf_api_rev {
 
 /* mailbox API, version 1.2 VF requests */
 #define IXGBE_VF_GET_RETA	0x0a	/* VF request for RETA */
+#define IXGBE_VF_GET_RSS_KEY	0x0b	/* get RSS hash key */
 
 /* length of permanent address message returned from PF */
 #define IXGBE_VF_PERMADDR_MSG_LEN	4
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index 7e43f88..d1339b0 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -326,6 +326,60 @@ int ixgbevf_get_reta_locked(struct ixgbe_hw *hw, u32 *reta, int num_rx_queues)
 }
 
 /**
+ * ixgbevf_get_rss_key_locked - get the RSS Random Key
+ * @hw: pointer to the HW structure
+ * @rss_key: buffer to fill with RSS Hash Key contents.
+ *
+ * The "rss_key" buffer should be big enough to contain 10 registers.
+ *
+ * Returns: 0 on success.
+ *          if API doesn't support this operation - (-EOPNOTSUPP).
+ */
+int ixgbevf_get_rss_key_locked(struct ixgbe_hw *hw, u8 *rss_key)
+{
+	int err;
+	u32 msgbuf[IXGBE_VFMAILBOX_SIZE];
+
+	/* We currently support the RSS Random Key retrieval for 82599 and x540
+	 * devices only.
+	 *
+	 * Thus return an error if API doesn't support RSS Random Key retrieval
+	 * or if the operation is not supported for this device type.
+	 */
+	if (hw->api_version != ixgbe_mbox_api_12 ||
+	    hw->mac.type >= ixgbe_mac_X550_vf)
+		return -EOPNOTSUPP;
+
+	msgbuf[0] = IXGBE_VF_GET_RSS_KEY;
+	err = hw->mbx.ops.write_posted(hw, msgbuf, 1);
+
+	if (err)
+		return err;
+
+	err = hw->mbx.ops.read_posted(hw, msgbuf, 11);
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
+	if (msgbuf[0] != (IXGBE_VF_GET_RSS_KEY | IXGBE_VT_MSGTYPE_ACK))
+		return IXGBE_ERR_MBX;
+
+	memcpy(rss_key, msgbuf + 1, IXGBEVF_RSS_HASH_KEY_SIZE);
+
+	return 0;
+}
+
+/**
  *  ixgbevf_set_rar_vf - set device MAC address
  *  @hw: pointer to hardware structure
  *  @index: Receive address register to write
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
index e17f9eb..d40f036 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
@@ -211,4 +211,5 @@ int ixgbevf_negotiate_api_version(struct ixgbe_hw *hw, int api);
 int ixgbevf_get_queues(struct ixgbe_hw *hw, unsigned int *num_tcs,
 		       unsigned int *default_tc);
 int ixgbevf_get_reta_locked(struct ixgbe_hw *hw, u32 *reta, int num_rx_queues);
+int ixgbevf_get_rss_key_locked(struct ixgbe_hw *hw, u8 *rss_key);
 #endif /* __IXGBE_VF_H__ */
-- 
2.1.0
