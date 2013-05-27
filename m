From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 4/6] bnx2x: Count number of possible FCoE
 interfaces
Date: Mon, 27 May 2013 17:08:29 +0300
Message-ID: <1369663711-32146-5-git-send-email-yuvalmin@broadcom.com>
References: <1369663711-32146-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Bhanu Prakash Gollapudi" <bprakash@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4941 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932663Ab3E0OI4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 May 2013 10:08:56 -0400
In-Reply-To: <1369663711-32146-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

Commit 0eb43b4bb081a1a22574daab9c05286a600dd7fe
"bnx2x, bnx2fc: Use per port max exchange resources" has changed the number
of available FCoE exchanges, even in scenarios when some of the functions has
no FCoE support; This needlessly degraded the available resources.

Remedy this by calculating the maximal number of functions that may actually
utilize said connection.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
CC: Bhanu Prakash Gollapudi <bprakash@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 51 ++++++++++++++++++++++--
 1 file changed, 48 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 04fa510..0a3bb53 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -10795,12 +10795,56 @@ static void bnx2x_get_ext_wwn_info(struct bnx2x *bp, int func)
 	bp->cnic_eth_dev.fcoe_wwn_node_name_lo =
 		MF_CFG_RD(bp, func_ext_config[func].fcoe_wwn_node_name_lower);
 }
+
+static int bnx2x_shared_fcoe_funcs(struct bnx2x *bp)
+{
+	u8 count = 0;
+
+	if (IS_MF(bp)) {
+		u8 fid;
+
+		/* iterate over absolute function ids for this path: */
+		for (fid = BP_PATH(bp); fid < E2_FUNC_MAX * 2; fid += 2) {
+			if (IS_MF_SD(bp)) {
+				u32 cfg = MF_CFG_RD(bp,
+						    func_mf_config[fid].config);
+
+				if (!(cfg & FUNC_MF_CFG_FUNC_HIDE) &&
+				    ((cfg & FUNC_MF_CFG_PROTOCOL_MASK) ==
+					    FUNC_MF_CFG_PROTOCOL_FCOE))
+					count++;
+			} else {
+				u32 cfg = MF_CFG_RD(bp,
+						    func_ext_config[fid].
+								      func_cfg);
+
+				if ((cfg & MACP_FUNC_CFG_FLAGS_ENABLED) &&
+				    (cfg & MACP_FUNC_CFG_FLAGS_FCOE_OFFLOAD))
+					count++;
+			}
+		}
+	} else { /* SF */
+		int port, port_cnt = CHIP_MODE_IS_4_PORT(bp) ? 2 : 1;
+
+		for (port = 0; port < port_cnt; port++) {
+			u32 lic = SHMEM_RD(bp,
+					   drv_lic_key[port].max_fcoe_conn) ^
+				  FW_ENCODE_32BIT_PATTERN;
+			if (lic)
+				count++;
+		}
+	}
+
+	return count;
+}
+
 static void bnx2x_get_fcoe_info(struct bnx2x *bp)
 {
 	int port = BP_PORT(bp);
 	int func = BP_ABS_FUNC(bp);
 	u32 max_fcoe_conn = FW_ENCODE_32BIT_PATTERN ^ SHMEM_RD(bp,
 				drv_lic_key[port].max_fcoe_conn);
+	u8 num_fcoe_func = bnx2x_shared_fcoe_funcs(bp);
 
 	if (!CNIC_SUPPORT(bp)) {
 		bp->flags |= NO_FCOE_FLAG;
@@ -10814,9 +10858,10 @@ static void bnx2x_get_fcoe_info(struct bnx2x *bp)
 
 	/* Calculate the number of maximum allowed FCoE tasks */
 	bp->cnic_eth_dev.max_fcoe_exchanges = MAX_NUM_FCOE_TASKS_PER_ENGINE;
-	if (IS_MF(bp) || CHIP_MODE_IS_4_PORT(bp))
-		bp->cnic_eth_dev.max_fcoe_exchanges /=
-						MAX_FCOE_FUNCS_PER_ENGINE;
+
+	/* check if FCoE resources must be shared between different functions */
+	if (num_fcoe_func)
+		bp->cnic_eth_dev.max_fcoe_exchanges /= num_fcoe_func;
 
 	/* Read the WWN: */
 	if (!IS_MF(bp)) {
-- 
1.8.1.227.g44fe835
