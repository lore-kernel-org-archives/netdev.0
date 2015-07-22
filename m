From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 5/6] bnx2x: Add MFW dump support
Date: Wed, 22 Jul 2015 09:16:26 +0300
Message-ID: <1437545787-22097-6-git-send-email-Yuval.Mintz@qlogic.com>
References: <1437545787-22097-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:11774 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755807AbbGVGRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jul 2015 02:17:14 -0400
In-Reply-To: <1437545787-22097-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Devices with up-to-date management FW will be able to store register dumps
on their persistent storage - in case management FW identifies a fatal
error it would gather and store such dumps, which could later be retrieved
using specific debug tools.

This patch adds the necessary part in the driver in order to make the
feature operational, as well as update users [under debug] during load
in case their device contains a dump of a previous crash.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |  2 ++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |  4 ++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h  | 17 ++++++++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 28 ++++++++++++++++++++++++
 4 files changed, 51 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index ecf1d7f..2fe3563 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -2582,6 +2582,8 @@ void bnx2x_set_local_cmng(struct bnx2x *bp);
 
 void bnx2x_update_mng_version(struct bnx2x *bp);
 
+void bnx2x_update_mfw_dump(struct bnx2x *bp);
+
 #define MCPR_SCRATCH_BASE(bp) \
 	(CHIP_IS_E1x(bp) ? MCP_REG_MCPR_SCRATCH : MCP_A_REG_MCPR_SCRATCH)
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 4ad9eeb..7d29bf2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2908,6 +2908,10 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 		return -EBUSY;
 	}
 
+	/* Update driver data for On-Chip MFW dump. */
+	if (IS_PF(bp))
+		bnx2x_update_mfw_dump(bp);
+
 	/* If PMF - send ADMIN DCBX msg to MFW to initiate DCBX FSM */
 	if (bp->port.pmf && (bp->state != BNX2X_STATE_DIAG))
 		bnx2x_dcbx_init(bp, false);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 53c8818..931b1b9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -2075,6 +2075,20 @@ enum curr_cfg_method_e {
 	CURR_CFG_MET_VENDOR_SPEC = 2,/* e.g. Option ROM, NPAR, O/S Cfg Utils */
 };
 
+struct mdump_driver_info {
+	u32 epoc;
+	u32 drv_ver;
+	u32 fw_ver;
+
+	u32 valid_dump;
+	#define FIRST_DUMP_VALID        (1 << 0)
+	#define SECOND_DUMP_VALID       (1 << 1)
+
+	u32 flags;
+	#define ENABLE_ALL_TRIGGERS     (0x7fffffff)
+	#define TRIGGER_MDUMP_ONCE      (1 << 31)
+};
+
 struct ncsi_oem_data {
 	u32 driver_version[4];
 	struct ncsi_oem_fcoe_features ncsi_oem_fcoe_features;
@@ -2347,6 +2361,9 @@ struct shmem2_region {
 	#define OS_DRIVER_STATE_LOADING		1 /* transition state */
 	#define OS_DRIVER_STATE_DISABLED	2 /* installed but disabled */
 	#define OS_DRIVER_STATE_ACTIVE		3 /* installed and active */
+
+	/* mini dump driver info */
+	struct mdump_driver_info drv_info;			/* 0x218 */
 };
 
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 0a069fa..78e55fe 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -3709,6 +3709,34 @@ out:
 	   ethver, iscsiver, fcoever);
 }
 
+void bnx2x_update_mfw_dump(struct bnx2x *bp)
+{
+	struct timeval epoc;
+	u32 drv_ver;
+	u32 valid_dump;
+
+	if (!SHMEM2_HAS(bp, drv_info))
+		return;
+
+	/* Update Driver load time */
+	do_gettimeofday(&epoc);
+	SHMEM2_WR(bp, drv_info.epoc, epoc.tv_sec);
+
+	drv_ver = bnx2x_update_mng_version_utility(DRV_MODULE_VERSION, true);
+	SHMEM2_WR(bp, drv_info.drv_ver, drv_ver);
+
+	SHMEM2_WR(bp, drv_info.fw_ver, REG_RD(bp, XSEM_REG_PRAM));
+
+	/* Check & notify On-Chip dump. */
+	valid_dump = SHMEM2_RD(bp, drv_info.valid_dump);
+
+	if (valid_dump & FIRST_DUMP_VALID)
+		DP(NETIF_MSG_IFUP, "A valid On-Chip MFW dump found on 1st partition\n");
+
+	if (valid_dump & SECOND_DUMP_VALID)
+		DP(NETIF_MSG_IFUP, "A valid On-Chip MFW dump found on 2nd partition\n");
+}
+
 static void bnx2x_oem_event(struct bnx2x *bp, u32 event)
 {
 	u32 cmd_ok, cmd_fail;
-- 
1.9.3
