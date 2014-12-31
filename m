From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: [PATCH net-next v1 1/5] ixgbe: Add a RETA query command to VF-PF channel API
Date: Wed, 31 Dec 2014 11:51:55 +0200
Message-ID: <1420019519-18139-2-git-send-email-vladz@cloudius-systems.com>
References: <1420019519-18139-1-git-send-email-vladz@cloudius-systems.com>
Cc: gleb@cloudius-systems.com, avi@cloudius-systems.com,
	jeffrey.t.kirsher@intel.com,
	Vlad Zolotarov <vladz@cloudius-systems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:43738 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbaLaJwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 04:52:13 -0500
Received: by mail-wi0-f176.google.com with SMTP id ex7so25296011wid.9
        for <netdev@vger.kernel.org>; Wed, 31 Dec 2014 01:52:12 -0800 (PST)
In-Reply-To: <1420019519-18139-1-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

82599 VFs and PF share the same RSS redirection table (RETA). Therefore we
just return it for all VFs.

RETA table is an array of 32 registers and the maximum number of registers
that may be delivered in a single VF-PF channel command is 15. Therefore
we will deliver the whole table in 3 steps: 12, 12 and 8 registers in each
step correspondingly. Thus this patch does the following:

  - Adds a new API version (to specify a new commands set).
  - Adds the IXGBE_VF_GET_RETA_[0,1,2] commands to the VF-PF commands set.

Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
---
New in v1 (compared to RFC):
   - Use "if-else" statement instead of a "switch-case" for a single option case
     (in ixgbe_get_vf_reta()).
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h   |  6 +++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 31 ++++++++++++++++++++++++++
 2 files changed, 37 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
index a5cb755..c1123d9 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
@@ -73,6 +73,7 @@ enum ixgbe_pfvf_api_rev {
 	ixgbe_mbox_api_10,	/* API version 1.0, linux/freebsd VF driver */
 	ixgbe_mbox_api_20,	/* API version 2.0, solaris Phase1 VF driver */
 	ixgbe_mbox_api_11,	/* API version 1.1, linux/freebsd VF driver */
+	ixgbe_mbox_api_12,	/* API version 1.2, linux/freebsd VF driver */
 	/* This value should always be last */
 	ixgbe_mbox_api_unknown,	/* indicates that API version is not known */
 };
@@ -91,6 +92,11 @@ enum ixgbe_pfvf_api_rev {
 /* mailbox API, version 1.1 VF requests */
 #define IXGBE_VF_GET_QUEUES	0x09 /* get queue configuration */
 
+/* mailbox API, version 1.2 VF requests */
+#define IXGBE_VF_GET_RETA_0	0x0a /* get RETA[0..11]  */
+#define IXGBE_VF_GET_RETA_1	0x0b /* get RETA[12..23] */
+#define IXGBE_VF_GET_RETA_2	0x0c /* get RETA[24..31] */
+
 /* GET_QUEUES return data indices within the mailbox */
 #define IXGBE_VF_TX_QUEUES	1	/* number of Tx queues supported */
 #define IXGBE_VF_RX_QUEUES	2	/* number of Rx queues supported */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index c76ba90..b1625c8 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -427,6 +427,7 @@ static s32 ixgbe_set_vf_lpe(struct ixgbe_adapter *adapter, u32 *msgbuf, u32 vf)
 #endif /* CONFIG_FCOE */
 		switch (adapter->vfinfo[vf].vf_api) {
 		case ixgbe_mbox_api_11:
+		case ixgbe_mbox_api_12:
 			/*
 			 * Version 1.1 supports jumbo frames on VFs if PF has
 			 * jumbo frames enabled which means legacy VFs are
@@ -894,6 +895,7 @@ static int ixgbe_negotiate_vf_api(struct ixgbe_adapter *adapter,
 	switch (api) {
 	case ixgbe_mbox_api_10:
 	case ixgbe_mbox_api_11:
+	case ixgbe_mbox_api_12:
 		adapter->vfinfo[vf].vf_api = api;
 		return 0;
 	default:
@@ -917,6 +919,7 @@ static int ixgbe_get_vf_queues(struct ixgbe_adapter *adapter,
 	switch (adapter->vfinfo[vf].vf_api) {
 	case ixgbe_mbox_api_20:
 	case ixgbe_mbox_api_11:
+	case ixgbe_mbox_api_12:
 		break;
 	default:
 		return -1;
@@ -944,6 +947,25 @@ static int ixgbe_get_vf_queues(struct ixgbe_adapter *adapter,
 	return 0;
 }
 
+static int ixgbe_get_vf_reta(struct ixgbe_adapter *adapter,
+			     u32 *msgbuf, u32 vf, int reta_offset_dw,
+			     size_t dwords)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	int i;
+	u32 *reta = &msgbuf[1];
+
+	/* verify the PF is supporting the correct API */
+	if (adapter->vfinfo[vf].vf_api != ixgbe_mbox_api_12)
+		return -EPERM;
+
+	/* Read the appropriate portion of RETA */
+	for (i = 0; i < dwords; i++)
+		reta[i] = IXGBE_READ_REG(hw, IXGBE_RETA(i + reta_offset_dw));
+
+	return 0;
+}
+
 static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 {
 	u32 mbx_size = IXGBE_VFMAILBOX_SIZE;
@@ -1000,6 +1022,15 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 	case IXGBE_VF_GET_QUEUES:
 		retval = ixgbe_get_vf_queues(adapter, msgbuf, vf);
 		break;
+	case IXGBE_VF_GET_RETA_0:
+		retval = ixgbe_get_vf_reta(adapter, msgbuf, vf, 0, 12);
+		break;
+	case IXGBE_VF_GET_RETA_1:
+		retval = ixgbe_get_vf_reta(adapter, msgbuf, vf, 12, 12);
+		break;
+	case IXGBE_VF_GET_RETA_2:
+		retval = ixgbe_get_vf_reta(adapter, msgbuf, vf, 24, 8);
+		break;
 	default:
 		e_err(drv, "Unhandled Msg %8.8x\n", msgbuf[0]);
 		retval = IXGBE_ERR_MBX;
-- 
2.1.0
