From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 3/6] qed: Correct endian order of MAC passed to MFW
Date: Thu, 23 Mar 2017 15:50:17 +0200
Message-ID: <1490277020-31208-4-git-send-email-Yuval.Mintz@cavium.com>
References: <1490277020-31208-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:45268 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1755816AbdCWNum (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 09:50:42 -0400
In-Reply-To: <1490277020-31208-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The management firmware is running on a Big Endian processor,
and when running on LE platform HW is configured to swap access
to memory shared between management firmware and driver on
32-bit granulariy.

As a result, for matters of simplicity most of the APIs between
driver and management firmware are based on 32-bit variables.
MAC settings are one exception, as driver needs to fill a byte
array when indicating to management firmware that primary MAC
has changed.
Due to the swap, driver must make sure that the mac that was
provided in byte-order would be translated into native order,
otherwise after the swap the management firmware would read
it swapped.

Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_mcp.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_mcp.c b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
index 8d18102..d1fcd87 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_mcp.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_mcp.c
@@ -1600,6 +1600,7 @@ int qed_mcp_ov_update_mac(struct qed_hwfn *p_hwfn,
 			  struct qed_ptt *p_ptt, u8 *mac)
 {
 	struct qed_mcp_mb_params mb_params;
+	u32 mfw_mac[2];
 	int rc;
 
 	memset(&mb_params, 0, sizeof(mb_params));
@@ -1608,8 +1609,16 @@ int qed_mcp_ov_update_mac(struct qed_hwfn *p_hwfn,
 			  DRV_MSG_CODE_VMAC_TYPE_SHIFT;
 	mb_params.param |= MCP_PF_ID(p_hwfn);
 
-	mb_params.p_data_src = mac;
-	mb_params.data_src_size = 6;
+	/* MCP is BE, and on LE platforms PCI would swap access to SHMEM
+	 * in 32-bit granularity.
+	 * So the MAC has to be set in native order [and not byte order],
+	 * otherwise it would be read incorrectly by MFW after swap.
+	 */
+	mfw_mac[0] = mac[0] << 24 | mac[1] << 16 | mac[2] << 8 | mac[3];
+	mfw_mac[1] = mac[4] << 24 | mac[5] << 16;
+
+	mb_params.p_data_src = (u8 *)mfw_mac;
+	mb_params.data_src_size = 8;
 	rc = qed_mcp_cmd_and_union(p_hwfn, p_ptt, &mb_params);
 	if (rc)
 		DP_ERR(p_hwfn, "Failed to send mac address, rc = %d\n", rc);
-- 
1.9.3
