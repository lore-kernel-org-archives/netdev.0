From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: [PATCH net-next v1 3/5] ixgbe: Add GET_RSS_KEY command to VF-PF channel commands set
Date: Wed, 31 Dec 2014 11:51:57 +0200
Message-ID: <1420019519-18139-4-git-send-email-vladz@cloudius-systems.com>
References: <1420019519-18139-1-git-send-email-vladz@cloudius-systems.com>
Cc: gleb@cloudius-systems.com, avi@cloudius-systems.com,
	jeffrey.t.kirsher@intel.com,
	Vlad Zolotarov <vladz@cloudius-systems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:39809 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751210AbaLaJwP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 04:52:15 -0500
Received: by mail-wi0-f179.google.com with SMTP id ex7so25306143wid.12
        for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 01:52:14 -0800 (PST)
In-Reply-To: <1420019519-18139-1-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

82599 VFs and PF share the same RSS Key. Therefore we will return
the same RSS key for all VFs.

Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
---
New in v1 (compared to RFC):
   - Use "if-else" statement instead of a "switch-case" for a single option case
     (in ixgbe_get_vf_rss_key()).
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h   |  2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 21 +++++++++++++++++++++
 2 files changed, 23 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
index c1123d9..52e775b 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
@@ -97,6 +97,8 @@ enum ixgbe_pfvf_api_rev {
 #define IXGBE_VF_GET_RETA_1	0x0b /* get RETA[12..23] */
 #define IXGBE_VF_GET_RETA_2	0x0c /* get RETA[24..31] */
 
+#define IXGBE_VF_GET_RSS_KEY	0x0d /* get RSS key */
+
 /* GET_QUEUES return data indices within the mailbox */
 #define IXGBE_VF_TX_QUEUES	1	/* number of Tx queues supported */
 #define IXGBE_VF_RX_QUEUES	2	/* number of Rx queues supported */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index b1625c8..d79415e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -966,6 +966,24 @@ static int ixgbe_get_vf_reta(struct ixgbe_adapter *adapter,
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
+	for (i = 0; i < 10; i++)
+		rss_key[i] = IXGBE_READ_REG(hw, IXGBE_RSSRK(i));
+
+	return 0;
+}
+
 static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 {
 	u32 mbx_size = IXGBE_VFMAILBOX_SIZE;
@@ -1031,6 +1049,9 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 	case IXGBE_VF_GET_RETA_2:
 		retval = ixgbe_get_vf_reta(adapter, msgbuf, vf, 24, 8);
 		break;
+	case IXGBE_VF_GET_RSS_KEY:
+		retval = ixgbe_get_vf_rss_key(adapter, msgbuf, vf);
+		break;
 	default:
 		e_err(drv, "Unhandled Msg %8.8x\n", msgbuf[0]);
 		retval = IXGBE_ERR_MBX;
-- 
2.1.0
