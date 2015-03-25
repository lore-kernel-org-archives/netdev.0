From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: [PATCH net-next v8 6/7] ixgbevf: Add RSS Key query code
Date: Wed, 25 Mar 2015 19:42:41 +0200
Message-ID: <1427305362-23948-7-git-send-email-vladz@cloudius-systems.com>
References: <1427305362-23948-1-git-send-email-vladz@cloudius-systems.com>
Cc: jeffrey.t.kirsher@intel.com, avi@cloudius-systems.com,
	gleb@cloudius-systems.com, intel-wired-lan@lists.osuosl.org,
	Vlad Zolotarov <vladz@cloudius-systems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:37418 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754841AbbCYRm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 13:42:59 -0400
Received: by wixw10 with SMTP id w10so49291952wix.0
        for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 10:42:58 -0700 (PDT)
In-Reply-To: <1427305362-23948-1-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the ixgbevf_get_rss_key() function that queries the PF for an RSS Random Key
using a new VF-PF channel IXGBE_VF_GET_RSS_KEY command.

Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
---
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
 drivers/net/ethernet/intel/ixgbevf/mbx.h |  2 ++
 drivers/net/ethernet/intel/ixgbevf/vf.c  | 60 ++++++++++++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbevf/vf.h  |  1 +
 3 files changed, 63 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/mbx.h b/drivers/net/ethernet/intel/ixgbevf/mbx.h
index 7342554..923bb0f 100644
--- a/drivers/net/ethernet/intel/ixgbevf/mbx.h
+++ b/drivers/net/ethernet/intel/ixgbevf/mbx.h
@@ -115,6 +115,8 @@ enum ixgbe_pfvf_api_rev {
 #define IXGBE_VF_RETA_SZ        1	/* Number of RETA DWs to bring */
 #define IXGBE_VF_RETA_OFFSET    2	/* Offset in RETA */
 
+#define IXGBE_VF_GET_RSS_KEY	0x0b	/* get RSS hash key */
+
 /* length of permanent address message returned from PF */
 #define IXGBE_VF_PERMADDR_MSG_LEN	4
 /* word in permanent address message with the current multicast type */
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index 2e468a6..4ca0304 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -325,6 +325,66 @@ static inline int _ixgbevf_get_reta(struct ixgbevf_adapter *a,
 	return rc;
 }
 
+static inline int ixgbevf_get_rss_key_locked(struct ixgbe_hw *hw, u8 *rss_key)
+{
+	int err;
+	u32 msgbuf[IXGBE_VFMAILBOX_SIZE];
+
+	/* Return and error if API doesn't support RSS Random Key retrieval */
+	if (hw->api_version != ixgbe_mbox_api_12)
+		return -EPERM;
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
+	memcpy(rss_key, msgbuf + 1, 40);
+
+	return 0;
+}
+
+/**
+ * ixgbevf_get_rss_key - get the RSS Random Key
+ * @hw: pointer to the HW structure
+ * @reta: buffer to fill with RETA contents.
+ *
+ * The "rss_key" buffer should be big enough to contain 10 registers.
+ * Ensures the atomicy of a mailbox access using the adapter.mbx_lock spinlock.
+ *
+ * Returns: 0 on success.
+ *          if API doesn't support this operation - (-EPERM).
+ */
+int ixgbevf_get_rss_key(struct ixgbevf_adapter *a, u8 *rss_key)
+{
+	int rc;
+
+	spin_lock_bh(&a->mbx_lock);
+	rc = ixgbevf_get_rss_key_locked(&a->hw, rss_key);
+	spin_unlock_bh(&a->mbx_lock);
+
+	return rc;
+}
+
 /**
  * ixgbevf_get_reta - get the RSS redirection table (RETA) contents.
  * @adapter: pointer to the port handle
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
index 7944962..a054716 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
@@ -212,4 +212,5 @@ int ixgbevf_negotiate_api_version(struct ixgbe_hw *hw, int api);
 int ixgbevf_get_queues(struct ixgbe_hw *hw, unsigned int *num_tcs,
 		       unsigned int *default_tc);
 int ixgbevf_get_reta(struct ixgbevf_adapter *adapter, u32 *reta);
+int ixgbevf_get_rss_key(struct ixgbevf_adapter *adapter, u8 *rss_key);
 #endif /* __IXGBE_VF_H__ */
-- 
2.1.0
