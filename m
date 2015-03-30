From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: [PATCH net-next v10 5/7] ixgbe: Add GET_RSS_KEY command to VF-PF channel commands set
Date: Mon, 30 Mar 2015 21:35:27 +0300
Message-ID: <1427740529-9605-6-git-send-email-vladz@cloudius-systems.com>
References: <1427740529-9605-1-git-send-email-vladz@cloudius-systems.com>
Cc: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
	avi@cloudius-systems.com, gleb@cloudius-systems.com,
	Vlad Zolotarov <vladz@cloudius-systems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f45.google.com ([74.125.82.45]:34502 "EHLO
	mail-wg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753410AbbC3Sfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2015 14:35:45 -0400
Received: by wgbdm7 with SMTP id dm7so78691177wgb.1
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2015 11:35:43 -0700 (PDT)
In-Reply-To: <1427740529-9605-1-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For 82599 and x540 VFs and PF share the same RSS Key. Therefore we will return
the same RSS key for all VFs.

Support for other devices will be added later.

Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
---
New in v10:
   - Return more self-explaining values.

New in v9:
   - Reduce the support to 82599 and x540 devices only.
   - Get rid of registers access in GET_VF_RSS_KEY flow:
      - Get the RSS HASH Key value from the PF's adapter->rss_key[].

New in v5:
   - Use a newly added netdev op to allow/prevent the RSS Hash Key querying on a per-VF
     basis.

New in v3:
   - Added a support for x550 devices.

New in v1 (compared to RFC):
   - Use "if-else" statement instead of a "switch-case" for a single option case
     (in ixgbe_get_vf_rss_key()).
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h   |  1 +
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 21 +++++++++++++++++++++
 2 files changed, 22 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
index 3522f53..b1e4703 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
@@ -100,6 +100,7 @@ enum ixgbe_pfvf_api_rev {
 
 /* mailbox API, version 1.2 VF requests */
 #define IXGBE_VF_GET_RETA	0x0a	/* VF request for RETA */
+#define IXGBE_VF_GET_RSS_KEY	0x0b	/* get RSS key */
 
 /* length of permanent address message returned from PF */
 #define IXGBE_VF_PERMADDR_MSG_LEN 4
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 81f54c3..d03b592 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -982,6 +982,24 @@ static int ixgbe_get_vf_reta(struct ixgbe_adapter *adapter, u32 *msgbuf, u32 vf)
 	return 0;
 }
 
+static int ixgbe_get_vf_rss_key(struct ixgbe_adapter *adapter,
+				u32 *msgbuf, u32 vf)
+{
+	u32 *rss_key = &msgbuf[1];
+
+	/* Check if the operation is permitted */
+	if (!adapter->vfinfo[vf].rss_query_enabled)
+		return -EPERM;
+
+	/* verify the PF is supporting the correct API */
+	if (adapter->vfinfo[vf].vf_api != ixgbe_mbox_api_12)
+		return -EOPNOTSUPP;
+
+	memcpy(rss_key, adapter->rss_key, sizeof(adapter->rss_key));
+
+	return 0;
+}
+
 static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 {
 	u32 mbx_size = IXGBE_VFMAILBOX_SIZE;
@@ -1041,6 +1059,9 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
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
