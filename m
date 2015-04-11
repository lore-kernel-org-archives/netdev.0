From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/9] ixgbevf: Add RSS Key query code
Date: Sat, 11 Apr 2015 12:07:55 -0700
Message-ID: <1428779276-22523-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1428779276-22523-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Vlad Zolotarov <vladz@cloudius-systems.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:18952 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755404AbbDKTIE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Apr 2015 15:08:04 -0400
In-Reply-To: <1428779276-22523-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Zolotarov <vladz@cloudius-systems.com>

Add the ixgbevf_get_rss_key() function that queries the PF for an RSS
Random Key using a new VF-PF channel IXGBE_VF_GET_RSS_KEY command.

This patch adds the support for 82599 and x540 devices only. Support for
other devices will be added later.

Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h |  1 +
 drivers/net/ethernet/intel/ixgbevf/mbx.h     |  1 +
 drivers/net/ethernet/intel/ixgbevf/vf.c      | 54 ++++++++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbevf/vf.h      |  1 +
 4 files changed, 57 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 0cea5e9..775d089 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -146,6 +146,7 @@ struct ixgbevf_ring {
 #define MAX_TX_QUEUES IXGBE_VF_MAX_TX_QUEUES
 #define IXGBEVF_MAX_RSS_QUEUES	2
 #define IXGBEVF_82599_RETA_SIZE	128
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
1.9.3
