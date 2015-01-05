From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: [PATCH net-next v3 3/5] ixgbe: Add GET_RSS_KEY command to VF-PF channel commands set
Date: Mon,  5 Jan 2015 16:15:09 +0200
Message-ID: <1420467311-6680-4-git-send-email-vladz@cloudius-systems.com>
References: <1420467311-6680-1-git-send-email-vladz@cloudius-systems.com>
Cc: gleb@cloudius-systems.com, avi@cloudius-systems.com,
	jeffrey.t.kirsher@intel.com,
	Vlad Zolotarov <vladz@cloudius-systems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:34972 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753830AbbAEOPl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 09:15:41 -0500
Received: by mail-we0-f177.google.com with SMTP id q59so7906182wes.36
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 06:15:40 -0800 (PST)
In-Reply-To: <1420467311-6680-1-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For 82599 and x540 VFs and PF share the same RSS Key. Therefore we will return
the same RSS key for all VFs.

x550 on the other hand has a separate RSS Key for every pool.

Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
---
New in v3:
   - Added a support for x550 devices.

New in v1 (compared to RFC):
   - Use "if-else" statement instead of a "switch-case" for a single option case
     (in ixgbe_get_vf_rss_key()).
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h   |  2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 26 ++++++++++++++++++++++++++
 2 files changed, 28 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
index f9b5eae..3f14373 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
@@ -105,6 +105,8 @@ enum ixgbe_pfvf_api_rev {
 #define IXGBE_VF_RETA_SZ        1	/* Number of RETA DWs to bring */
 #define IXGBE_VF_RETA_OFFSET    2	/* Offset in RETA */
 
+#define IXGBE_VF_GET_RSS_KEY	0x0b	/* get RSS key */
+
 /* length of permanent address message returned from PF */
 #define IXGBE_VF_PERMADDR_MSG_LEN 4
 /* word in permanent address message with the current multicast type */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index d4f095d..9a6a112 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -1006,6 +1006,29 @@ static int ixgbe_get_vf_reta(struct ixgbe_adapter *adapter, u32 *msgbuf, u32 vf)
 	return 0;
 }
 
+static int ixgbe_get_vf_rss_key(struct ixgbe_adapter *adapter,
+				u32 *msgbuf, u32 vf)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	int i;
+	u32 *rss_key = &msgbuf[1];
+
+	/* verify the PF is supporting the correct API */
+	if (adapter->vfinfo[vf].vf_api != ixgbe_mbox_api_12)
+		return -EPERM;
+
+	/* Read the RSS KEY */
+	if (hw->mac.type >= ixgbe_mac_X550) {
+		for (i = 0; i < 10; i++)
+			rss_key[i] = IXGBE_READ_REG(hw,
+						IXGBE_PFVFRSSRK(i, vf));
+	} else
+		for (i = 0; i < 10; i++)
+			rss_key[i] = IXGBE_READ_REG(hw, IXGBE_RSSRK(i));
+
+	return 0;
+}
+
 static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 {
 	u32 mbx_size = IXGBE_VFMAILBOX_SIZE;
@@ -1065,6 +1088,9 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 	case IXGBE_VF_GET_RETA:
 		retval = ixgbe_get_vf_reta(adapter, msgbuf, vf);
 		break;
+	case IXGBE_VF_GET_RSS_KEY:
+		retval = ixgbe_get_vf_rss_key(adapter, msgbuf, vf);
+		break;
 	default:
 		e_err(drv, "Unhandled Msg %8.8x\n", msgbuf[0]);
 		retval = IXGBE_ERR_MBX;
-- 
2.1.0
