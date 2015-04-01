From: Vlad Zolotarov <vladz@cloudius-systems.com>
Subject: [PATCH net-next v11 3/7] ixgbe: Add a RETA query command to VF-PF channel API
Date: Wed,  1 Apr 2015 11:24:54 +0300
Message-ID: <1427876694-19821-1-git-send-email-vladz@cloudius-systems.com>
Cc: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
	avi@cloudius-systems.com, gleb@cloudius-systems.com,
	Vlad Zolotarov <vladz@cloudius-systems.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:34846 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752107AbbDAIZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 04:25:03 -0400
Received: by widdi4 with SMTP id di4so36060239wid.0
        for <netdev@vger.kernel.org>; Wed, 01 Apr 2015 01:25:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add this new command for 82599 and x540 devices only. Support for other devices
will be added later.

82599 and x540 VFs and PF share the same RSS redirection table (RETA). Therefore we
just return it for all VFs.

For 82599 and x540 RETA table is an array of 32 registers (128 bytes) and the maximum number of
registers that may be delivered in a single VF-PF channel command is 15. On the other hand VFs
of these devices can be configured to have up to 4 RSS queues. Therefore we will "compress"
the RETA by transfering only 2 bits per entry and thereby it will take only 8 registers (DWORDS)
to transfer the whole VF RETA.

Thus this patch does the following:

  - Adds a new API version (to specify a new commands set).
  - Adds the IXGBE_VF_GET_RETA command to the VF-PF commands set.

Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
---
New in v11:
   - Updated the patch description.

New in v10:
   - Drop the PRSTYPE reading since it's VF that finally modifies it (via VFPSRTYPE)
     and we will add the proper masking at the VF driver level.
   - Return more self-explaining values.

New in v9:
   - Reduce the support to 82599 and x540 devices only.
   - Improvements in query RETA VF-PF command implementation:
      - Use the cached RETA contents.
      - Compress the mailbox message.

New in v5:
   - Use the newly added netdev op to allow/prevent the RETA query on a per-VF basis.

New in v4:
   - Deleted an empty line in ixgbe_get_vf_reta() switch-case.

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
 drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h   |  4 +++
 drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 35 ++++++++++++++++++++++++++
 2 files changed, 39 insertions(+)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h b/drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h
index a5cb755..3522f53 100644
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
@@ -97,6 +98,9 @@ enum ixgbe_pfvf_api_rev {
 #define IXGBE_VF_TRANS_VLAN	3	/* Indication of port vlan */
 #define IXGBE_VF_DEF_QUEUE	4	/* Default queue offset */
 
+/* mailbox API, version 1.2 VF requests */
+#define IXGBE_VF_GET_RETA	0x0a	/* VF request for RETA */
+
 /* length of permanent address message returned from PF */
 #define IXGBE_VF_PERMADDR_MSG_LEN 4
 /* word in permanent address message with the current multicast type */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
index 2de5335..81f54c3 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c
@@ -433,6 +433,7 @@ static s32 ixgbe_set_vf_lpe(struct ixgbe_adapter *adapter, u32 *msgbuf, u32 vf)
 #endif /* CONFIG_FCOE */
 		switch (adapter->vfinfo[vf].vf_api) {
 		case ixgbe_mbox_api_11:
+		case ixgbe_mbox_api_12:
 			/*
 			 * Version 1.1 supports jumbo frames on VFs if PF has
 			 * jumbo frames enabled which means legacy VFs are
@@ -900,6 +901,7 @@ static int ixgbe_negotiate_vf_api(struct ixgbe_adapter *adapter,
 	switch (api) {
 	case ixgbe_mbox_api_10:
 	case ixgbe_mbox_api_11:
+	case ixgbe_mbox_api_12:
 		adapter->vfinfo[vf].vf_api = api;
 		return 0;
 	default:
@@ -923,6 +925,7 @@ static int ixgbe_get_vf_queues(struct ixgbe_adapter *adapter,
 	switch (adapter->vfinfo[vf].vf_api) {
 	case ixgbe_mbox_api_20:
 	case ixgbe_mbox_api_11:
+	case ixgbe_mbox_api_12:
 		break;
 	default:
 		return -1;
@@ -950,6 +953,35 @@ static int ixgbe_get_vf_queues(struct ixgbe_adapter *adapter,
 	return 0;
 }
 
+static int ixgbe_get_vf_reta(struct ixgbe_adapter *adapter, u32 *msgbuf, u32 vf)
+{
+	u32 i, j;
+	u32 *out_buf = &msgbuf[1];
+	const u8 *reta = adapter->rss_indir_tbl;
+	u32 reta_size = ixgbe_rss_indir_tbl_entries(adapter);
+
+	/* Check if operation is permitted */
+	if (!adapter->vfinfo[vf].rss_query_enabled)
+		return -EPERM;
+
+	/* verify the PF is supporting the correct API */
+	if (adapter->vfinfo[vf].vf_api != ixgbe_mbox_api_12)
+		return -EOPNOTSUPP;
+
+	/* This mailbox command is supported (required) only for 82599 and x540
+	 * VFs which support up to 4 RSS queues. Therefore we will compress the
+	 * RETA by saving only 2 bits from each entry. This way we will be able
+	 * to transfer the whole RETA in a single mailbox operation.
+	 */
+	for (i = 0; i < reta_size / 16; i++) {
+		out_buf[i] = 0;
+		for (j = 0; j < 16; j++)
+			out_buf[i] |= (u32)(reta[16 * i + j] & 0x3) << (2 * j);
+	}
+
+	return 0;
+}
+
 static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
 {
 	u32 mbx_size = IXGBE_VFMAILBOX_SIZE;
@@ -1006,6 +1038,9 @@ static int ixgbe_rcv_msg_from_vf(struct ixgbe_adapter *adapter, u32 vf)
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
