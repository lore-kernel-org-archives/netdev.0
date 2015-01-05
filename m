From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: [PATCH net-next v3 1/5] ixgbe: Add a RETA query command to VF-PF channel API
Date: Mon,  5 Jan 2015 16:15:07 +0200
Message-ID: <1420467311-6680-2-git-send-email-vladz@cloudius-systems.com>
References: <1420467311-6680-1-git-send-email-vladz@cloudius-systems.com>
Cc: gleb@cloudius-systems.com, avi@cloudius-systems.com,
	jeffrey.t.kirsher@intel.com,
	Vlad Zolotarov <vladz@cloudius-systems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:54503 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753814AbbAEOPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2015 09:15:34 -0500
Received: by mail-wi0-f169.google.com with SMTP id r20so4198381wiv.2
        for <netdev@vger.kernel.org>; Mon, 05 Jan 2015 06:15:33 -0800 (PST)
In-Reply-To: <1420467311-6680-1-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

82599 and x540 VFs and PF share the same RSS redirection table (RETA). Therefore we
just return it for all VFs. x550 on the other hand provides a separate redirection
table for each VF (there is a per-pool RETA table).

For 82599 and x540 RETA table is an array of 32 registers (128 bytes) and the maximum number of
registers that may be delivered in a single VF-PF channel command is 15. Therefore
we will deliver the whole table in 3 steps: 12, 12 and 8 registers in each
step correspondingly.

For x550 VFs RETA is a 64 byte array, so we may deliver it in two steps: 12 and 4 registers
correspondingly.

Thus this patch does the following:

  - Adds a new API version (to specify a new commands set).
  - Adds the IXGBE_VF_GET_RETA command to the VF-PF commands set.

Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
---
New in v3:
   - Pass the number of dwords and offset in RETA in the IXGBE_VF_GET_RETA request message.
     This allows to reduce the added command set to a single command.
   - Added a support for all devices supported by the ixgbe driver that have
     SR-IOV functions support: 82599, x540 and x550. The original code supported
     only 82599 and x540.
   - Added the masking of the RETA entries according to the PSRTYPE[n].RQPL
     value.

New in v1 (compared to RFC):
   - Use "if-else" statement instead of a "switch-case" for a single option case
     (in ixgbe_get_vf_reta()).
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h   |  8 ++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 65 ++++++++++++++++++++++++++
 2 files changed, 73 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
index a5cb755..f9b5eae 100644
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
@@ -97,6 +98,13 @@ enum ixgbe_pfvf_api_rev {
 #define IXGBE_VF_TRANS_VLAN	3	/* Indication of port vlan */
 #define IXGBE_VF_DEF_QUEUE	4	/* Default queue offset */
 
+/* mailbox API, version 1.2 VF requests */
+#define IXGBE_VF_GET_RETA	0x0a	/* VF request for RETA */
+
+/* GET_RETA request data indices within the mailbox */
+#define IXGBE_VF_RETA_SZ        1	/* Number of RETA DWs to bring */
+#define IXGBE_VF_RETA_OFFSET    2	/* Offset in RETA */
+
 /* length of permanent address message returned from PF */
 #define IXGBE_VF_PERMADDR_MSG_LEN 4
 /* word in permanent address message with the current multicast type */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index c76ba90..d4f095d 100644
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
@@ -944,6 +947,65 @@ static int ixgbe_get_vf_queues(struct ixgbe_adapter *adapter,
 	return 0;
 }
 
+static int ixgbe_get_vf_reta(struct ixgbe_adapter *adapter, u32 *msgbuf, u32 vf)
+{
+	struct ixgbe_hw *hw = &adapter->hw;
+	int i, j;
+	u32 *reta = &msgbuf[1];
+	u32 mask = 0;
+	u32 psrtype;
+	u32 reta_offset_dw = msgbuf[IXGBE_VF_RETA_OFFSET];
+	u32 dwords = msgbuf[IXGBE_VF_RETA_SZ];
+
+	/* verify the PF is supporting the correct API */
+	if (adapter->vfinfo[vf].vf_api != ixgbe_mbox_api_12)
+		return -EPERM;
+
+	psrtype = IXGBE_READ_REG(hw, IXGBE_PSRTYPE(vf));
+
+	/* The redirection table is composed as follows:
+	 * 82598: 128 (8 bit wide) entries containing pair of 4 bit RSS indices
+	 * 82599/X540: 128 (8 bit wide) entries containing 4 bit RSS index X550:
+	 * 512 (8 bit wide) entries containing 6 bit RSS index
+	 *
+	 * PSRTYPE[n].RQPL defines if 0, 1 or 2 bits from the redirection table
+	 * value should be used.
+	 */
+
+	if ((psrtype & (1 << 29)) == (1 << 29))
+		mask = 0x01010101;
+	else if ((psrtype & (2 << 29)) == (2 << 29))
+		mask = 0x03030303;
+	else
+		mask = 0;
+
+	switch (hw->mac.type) {
+	case ixgbe_mac_82599EB:
+	case ixgbe_mac_X540:
+		/* Read the appropriate portion of RETA */
+		for (i = 0; i < dwords; i++)
+			reta[i] = IXGBE_READ_REG(hw,
+						IXGBE_RETA(i + reta_offset_dw));
+		break;
+	case ixgbe_mac_X550:
+	case ixgbe_mac_X550EM_x:
+		/* X550 has a per-VF RETA */
+		for (i = 0, j = reta_offset_dw; i < dwords; i++, j++)
+			reta[i] = IXGBE_READ_REG(hw,
+						IXGBE_PFVFRETA(j, vf));
+		break;
+	default:
+		return -1;
+
+	}
+
+	/* Mask the relevant bits */
+	for (i = 0; i < dwords; i++)
+		reta[i] &= mask;
+
+	return 0;
+}
+
 static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 {
 	u32 mbx_size = IXGBE_VFMAILBOX_SIZE;
@@ -1000,6 +1062,9 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 	case IXGBE_VF_GET_QUEUES:
 		retval = ixgbe_get_vf_queues(adapter, msgbuf, vf);
 		break;
+	case IXGBE_VF_GET_RETA:
+		retval = ixgbe_get_vf_reta(adapter, msgbuf, vf);
+		break;
 	default:
 		e_err(drv, "Unhandled Msg %8.8x\n", msgbuf[0]);
 		retval = IXGBE_ERR_MBX;
-- 
2.1.0
