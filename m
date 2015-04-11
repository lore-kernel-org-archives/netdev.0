From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 6/9] ixgbevf: Add a RETA query code
Date: Sat, 11 Apr 2015 12:07:53 -0700
Message-ID: <1428779276-22523-7-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1428779276-22523-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Vlad Zolotarov <vladz@cloudius-systems.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15376 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755458AbbDKTIC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Apr 2015 15:08:02 -0400
In-Reply-To: <1428779276-22523-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Zolotarov <vladz@cloudius-systems.com>

We will currently support only 82599 and x540 devices. Support for other
devices will be added later.

   - Added a new API version support.
   - Added the query implementation in the ixgbevf.

Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  1 +
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  5 +-
 drivers/net/ethernet/intel/ixgbevf/mbx.h          |  4 ++
 drivers/net/ethernet/intel/ixgbevf/vf.c           | 70 +++++++++++++++++++++++
 drivers/net/ethernet/intel/ixgbevf/vf.h           |  1 +
 5 files changed, 80 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index bc939a1..0cea5e9 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -145,6 +145,7 @@ struct ixgbevf_ring {
 #define MAX_RX_QUEUES IXGBE_VF_MAX_RX_QUEUES
 #define MAX_TX_QUEUES IXGBE_VF_MAX_TX_QUEUES
 #define IXGBEVF_MAX_RSS_QUEUES	2
+#define IXGBEVF_82599_RETA_SIZE	128
 
 #define IXGBEVF_DEFAULT_TXD	1024
 #define IXGBEVF_DEFAULT_RXD	512
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
index 6253e93..66e138b 100644
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
@@ -107,6 +108,9 @@ enum ixgbe_pfvf_api_rev {
 #define IXGBE_VF_TRANS_VLAN	3 /* Indication of port VLAN */
 #define IXGBE_VF_DEF_QUEUE	4 /* Default queue offset */
 
+/* mailbox API, version 1.2 VF requests */
+#define IXGBE_VF_GET_RETA	0x0a	/* VF request for RETA */
+
 /* length of permanent address message returned from PF */
 #define IXGBE_VF_PERMADDR_MSG_LEN	4
 /* word in permanent address message with the current multicast type */
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.c b/drivers/net/ethernet/intel/ixgbevf/vf.c
index 2614fd3..7e43f88 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.c
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.c
@@ -257,6 +257,75 @@ static s32 ixgbevf_set_uc_addr_vf(struct ixgbe_hw *hw, u32 index, u8 *addr)
 }
 
 /**
+ * ixgbevf_get_reta_locked - get the RSS redirection table (RETA) contents.
+ * @adapter: pointer to the port handle
+ * @reta: buffer to fill with RETA contents.
+ * @num_rx_queues: Number of Rx queues configured for this port
+ *
+ * The "reta" buffer should be big enough to contain 32 registers.
+ *
+ * Returns: 0 on success.
+ *          if API doesn't support this operation - (-EOPNOTSUPP).
+ */
+int ixgbevf_get_reta_locked(struct ixgbe_hw *hw, u32 *reta, int num_rx_queues)
+{
+	int err, i, j;
+	u32 msgbuf[IXGBE_VFMAILBOX_SIZE];
+	u32 *hw_reta = &msgbuf[1];
+	u32 mask = 0;
+
+	/* We have to use a mailbox for 82599 and x540 devices only.
+	 * For these devices RETA has 128 entries.
+	 * Also these VFs support up to 4 RSS queues. Therefore PF will compress
+	 * 16 RETA entries in each DWORD giving 2 bits to each entry.
+	 */
+	int dwords = IXGBEVF_82599_RETA_SIZE / 16;
+
+	/* We support the RSS querying for 82599 and x540 devices only.
+	 * Thus return an error if API doesn't support RETA querying or querying
+	 * is not supported for this device type.
+	 */
+	if (hw->api_version != ixgbe_mbox_api_12 ||
+	    hw->mac.type >= ixgbe_mac_X550_vf)
+		return -EOPNOTSUPP;
+
+	msgbuf[0] = IXGBE_VF_GET_RETA;
+
+	err = hw->mbx.ops.write_posted(hw, msgbuf, 1);
+
+	if (err)
+		return err;
+
+	err = hw->mbx.ops.read_posted(hw, msgbuf, dwords + 1);
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
+	/* ixgbevf doesn't support more than 2 queues at the moment */
+	if (num_rx_queues > 1)
+		mask = 0x1;
+
+	for (i = 0; i < dwords; i++)
+		for (j = 0; j < 16; j++)
+			reta[i * 16 + j] = (hw_reta[i] >> (2 * j)) & mask;
+
+	return 0;
+}
+
+/**
  *  ixgbevf_set_rar_vf - set device MAC address
  *  @hw: pointer to hardware structure
  *  @index: Receive address register to write
@@ -545,6 +614,7 @@ int ixgbevf_get_queues(struct ixgbe_hw *hw, unsigned int *num_tcs,
 	/* do nothing if API doesn't support ixgbevf_get_queues */
 	switch (hw->api_version) {
 	case ixgbe_mbox_api_11:
+	case ixgbe_mbox_api_12:
 		break;
 	default:
 		return 0;
diff --git a/drivers/net/ethernet/intel/ixgbevf/vf.h b/drivers/net/ethernet/intel/ixgbevf/vf.h
index 6688250..e17f9eb 100644
--- a/drivers/net/ethernet/intel/ixgbevf/vf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/vf.h
@@ -210,4 +210,5 @@ void ixgbevf_rlpml_set_vf(struct ixgbe_hw *hw, u16 max_size);
 int ixgbevf_negotiate_api_version(struct ixgbe_hw *hw, int api);
 int ixgbevf_get_queues(struct ixgbe_hw *hw, unsigned int *num_tcs,
 		       unsigned int *default_tc);
+int ixgbevf_get_reta_locked(struct ixgbe_hw *hw, u32 *reta, int num_rx_queues);
 #endif /* __IXGBE_VF_H__ */
-- 
1.9.3
