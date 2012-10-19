From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 04/14] ixgbe: Add mailbox API version negotiation support to ixgbe PF
Date: Fri, 19 Oct 2012 04:45:04 -0700
Message-ID: <1350647114-6768-5-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1350647114-6768-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:31782 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758644Ab2JSLpo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2012 07:45:44 -0400
In-Reply-To: <1350647114-6768-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change allows us to add a mailbox versioning API.  This will allow us
to determine the features supported by the VFs from the PF.  For example we
will be implementing a version 1.1 API for the VF that will indicate that
it can support us enabling Jumbo frames as the VF will support buffer
chaining.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Tested-by: Robert Garrett <RobertX.Garrett@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h       |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h   | 21 ++++++++++++++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 33 ++++++++++++++++++++++----
 3 files changed, 48 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 30efc9f..ccb8505 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -135,6 +135,7 @@ struct vf_data_storage {
 	u16 tx_rate;
 	u16 vlan_count;
 	u8 spoofchk_enabled;
+	unsigned int vf_api;
 };
 
 struct vf_macvlans {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
index 310bdd9..d4c842e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
@@ -62,12 +62,29 @@
 /* bits 23:16 are used for exra info for certain messages */
 #define IXGBE_VT_MSGINFO_MASK     (0xFF << IXGBE_VT_MSGINFO_SHIFT)
 
+/* definitions to support mailbox API version negotiation */
+
+/*
+ * Each element denotes a version of the API; existing numbers may not
+ * change; any additions must go at the end
+ */
+enum ixgbe_pfvf_api_rev {
+	ixgbe_mbox_api_10,	/* API version 1.0, linux/freebsd VF driver */
+	ixgbe_mbox_api_20,	/* API version 2.0, solaris Phase1 VF driver */
+	/* This value should always be last */
+	ixgbe_mbox_api_unknown,	/* indicates that API version is not known */
+};
+
+/* mailbox API, legacy requests */
 #define IXGBE_VF_RESET            0x01 /* VF requests reset */
 #define IXGBE_VF_SET_MAC_ADDR     0x02 /* VF requests PF to set MAC addr */
 #define IXGBE_VF_SET_MULTICAST    0x03 /* VF requests PF to set MC addr */
 #define IXGBE_VF_SET_VLAN         0x04 /* VF requests PF to set VLAN */
-#define IXGBE_VF_SET_LPE          0x05 /* VF requests PF to set VMOLR.LPE */
-#define IXGBE_VF_SET_MACVLAN      0x06 /* VF requests PF for unicast filter */
+
+/* mailbox API, version 1.0 VF requests */
+#define IXGBE_VF_SET_LPE	0x05 /* VF requests PF to set VMOLR.LPE */
+#define IXGBE_VF_SET_MACVLAN	0x06 /* VF requests PF for unicast filter */
+#define IXGBE_VF_API_NEGOTIATE	0x08 /* negotiate API version */
 
 /* length of permanent address message returned from PF */
 #define IXGBE_VF_PERMADDR_MSG_LEN 4
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index d641c04..f563625 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -469,6 +469,9 @@ static inline void ixgbe_vf_reset_event(struct ixgbe_adapter *adapter, u32 vf)
 	ixgbe_set_rx_mode(adapter->netdev);
 
 	hw->mac.ops.clear_rar(hw, rar_entry);
+
+	/* reset VF api back to unknown */
+	adapter->vfinfo[vf].vf_api = ixgbe_mbox_api_10;
 }
 
 static int ixgbe_set_vf_mac(struct ixgbe_adapter *adapter,
@@ -717,6 +720,24 @@ static int ixgbe_set_vf_macvlan_msg(struct ixgbe_adapter *adapter,
 	return err;
 }
 
+static int ixgbe_negotiate_vf_api(struct ixgbe_adapter *adapter,
+				  u32 *msgbuf, u32 vf)
+{
+	int api = msgbuf[1];
+
+	switch (api) {
+	case ixgbe_mbox_api_10:
+		adapter->vfinfo[vf].vf_api = api;
+		return 0;
+	default:
+		break;
+	}
+
+	e_info(drv, "VF %d requested invalid api version %u\n", vf, api);
+
+	return -1;
+}
+
 static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 {
 	u32 mbx_size = IXGBE_VFMAILBOX_SIZE;
@@ -738,14 +759,13 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 	/* flush the ack before we write any messages back */
 	IXGBE_WRITE_FLUSH(hw);
 
+	if (msgbuf[0] == IXGBE_VF_RESET)
+		return ixgbe_vf_reset_msg(adapter, vf);
+
 	/*
 	 * until the vf completes a virtual function reset it should not be
 	 * allowed to start any configuration.
 	 */
-
-	if (msgbuf[0] == IXGBE_VF_RESET)
-		return ixgbe_vf_reset_msg(adapter, vf);
-
 	if (!adapter->vfinfo[vf].clear_to_send) {
 		msgbuf[0] |= IXGBE_VT_MSGTYPE_NACK;
 		ixgbe_write_mbx(hw, msgbuf, 1, vf);
@@ -768,6 +788,9 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 	case IXGBE_VF_SET_MACVLAN:
 		retval = ixgbe_set_vf_macvlan_msg(adapter, msgbuf, vf);
 		break;
+	case IXGBE_VF_API_NEGOTIATE:
+		retval = ixgbe_negotiate_vf_api(adapter, msgbuf, vf);
+		break;
 	default:
 		e_err(drv, "Unhandled Msg %8.8x\n", msgbuf[0]);
 		retval = IXGBE_ERR_MBX;
@@ -782,7 +805,7 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 
 	msgbuf[0] |= IXGBE_VT_MSGTYPE_CTS;
 
-	ixgbe_write_mbx(hw, msgbuf, 1, vf);
+	ixgbe_write_mbx(hw, msgbuf, mbx_size, vf);
 
 	return retval;
 }
-- 
1.7.11.7
