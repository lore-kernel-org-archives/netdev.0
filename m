From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 7/9] ixgbe: Add GET_RSS_KEY command to VF-PF channel commands set
Date: Sat, 11 Apr 2015 12:07:54 -0700
Message-ID: <1428779276-22523-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1428779276-22523-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Vlad Zolotarov <vladz@cloudius-systems.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:32506 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755454AbbDKTID (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Apr 2015 15:08:03 -0400
In-Reply-To: <1428779276-22523-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Zolotarov <vladz@cloudius-systems.com>

For 82599 and x540 VFs and PF share the same RSS Key. Therefore we will
return the same RSS key for all VFs.

Support for other devices will be added later.

Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
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
index 58566a1..1d17b58 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -983,6 +983,24 @@ static int ixgbe_get_vf_reta(struct ixgbe_adapter *adapter, u32 *msgbuf, u32 vf)
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
@@ -1042,6 +1060,9 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
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
1.9.3
