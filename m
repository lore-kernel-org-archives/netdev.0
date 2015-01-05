From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: [PATCH net-next v4 4/5] ixgbevf: Add RSS Key query code
Date: Mon,  5 Jan 2015 16:46:41 +0200
Message-ID: <1420469202-1847-5-git-send-email-vladz@cloudius-systems.com>
References: <1420469202-1847-1-git-send-email-vladz@cloudius-systems.com>
Cc: gleb@cloudius-systems.com, avi@cloudius-systems.com,
	jeffrey.t.kirsher@intel.com,
	Vlad Zolotarov <vladz@cloudius-systems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:59260 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753804AbbAEOq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 09:46:58 -0500
Received: by mail-we0-f175.google.com with SMTP id k11so7994676wes.20
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 06:46:57 -0800 (PST)
In-Reply-To: <1420469202-1847-1-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the ixgbevf_get_rss_key() function that queries the PF for an RSS Random Key
using a new VF-PF channel IXGBE_VF_GET_RSS_KEY command.

Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
---
New in v2:
   - Added a more detailed patch description.

New in v1 (compared to RFC):
   - Use "if-else" statement instead of a "switch-case" for a single option case
     (in ixgbevf_get_rss_key()).
---
 drivers/net/ethernet/intel/ixgbevf/mbx.h |  2 ++
 drivers/net/ethernet/intel/ixgbevf/vf.c  | 44 ++++++++++++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbevf/vf.h  |  1 +
 3 files changed, 47 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/mbx.h b/drivers/net/ethernet/intel/ixgbevf/mbx.h
index 951a506..f79432e 100644
--- a/drivers/net/ethernet/intel/ixgbevf/mbx.h
+++ b/drivers/net/ethernet/intel/ixgbevf/mbx.h
@@ -118,6 +118,8 @@ enum ixgbe_pfvf_api_rev {
 #define IXGBE_VF_RETA_SZ        1	/* Number of RETA DWs to bring */
 #define IXGBE_VF_RETA_OFFSET    2	/* Offset in RETA */
 
+#define IXGBE_VF_GET_RSS_KEY	0x0b	/* get RSS hash key */
+
 /* length of permanent address message returned from PF */
 #define IXGBE_VF_PERMADDR_MSG_LEN 4
 /* word in permanent address message with the current multicast type */
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index cb5a4cf..f42a67d 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -292,6 +292,50 @@ static inline int _ixgbevf_get_reta(struct ixgbe_hw *hw, u32 *msgbuf,
 }
 
 /**
+ * ixgbevf_get_rss_key - get the RSS Random Key
+ * @hw: pointer to the HW structure
+ * @reta: buffer to fill with RETA contents.
+ *
+ * The "rss_key" buffer should be big enough to contain 10 registers.
+ *
+ * Returns: 0 on success.
+ *          if API doesn't support this operation - (-EPERM).
+ */
+int ixgbevf_get_rss_key(struct ixgbe_hw *hw, u8 *rss_key)
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
  * ixgbevf_get_reta - get the RSS redirection table (RETA) contents.
  * @hw: pointer to the HW structure
  * @reta: buffer to fill with RETA contents.
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
index 73c1b33..54f53f2b8 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
@@ -209,5 +209,6 @@ int ixgbevf_negotiate_api_version(struct ixgbe_hw *hw, int api);
 int ixgbevf_get_queues(struct ixgbe_hw *hw, unsigned int *num_tcs,
 		       unsigned int *default_tc);
 int ixgbevf_get_reta(struct ixgbe_hw *hw, u32 *reta);
+int ixgbevf_get_rss_key(struct ixgbe_hw *hw, u8 *rss_key);
 #endif /* __IXGBE_VF_H__ */
 
-- 
2.1.0
