From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] qed: fix uninitialized data in aRFS intrastructure
Date: Thu, 11 May 2017 14:15:14 +0200
Message-ID: <20170511121633.3591880-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Chad Dupuis <Chad.Dupuis@cavium.com>,
        Ram Amrani <Ram.Amrani@cavium.com>,
        Manish Rangankar <Manish.Rangankar@cavium.com>,
        "Chopra, Manish" <Manish.Chopra@cavium.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Yuval Mintz <Yuval.Mintz@cavium.com>,
        Ariel Elior <Ariel.Elior@cavium.com>,
        everest-linux-l2@cavium.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The new code contains an incredibly elaborate way of setting a 64-bit
register, which went subtly wrong due to the wrong size in a memset():

ethernet/qlogic/qed/qed_init_fw_funcs.c: In function 'qed_set_rfs_mode_disable':
ethernet/qlogic/qed/qed_init_fw_funcs.c:993:3: error: '*((void *)&ramline+4)' is used uninitialized in this function [-Werror=uninitialized]

This removes the silly loop and memset, and instead directly writes
the correct value to the register.

Fixes: d51e4af5c209 ("qed: aRFS infrastructure support")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 .../net/ethernet/qlogic/qed/qed_init_fw_funcs.c    | 48 +++++-----------------
 1 file changed, 11 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c b/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c
index 67200c5498ab..a7c2c147a738 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_init_fw_funcs.c
@@ -966,45 +966,29 @@ void qed_set_geneve_enable(struct qed_hwfn *p_hwfn,
 #define PARSER_ETH_CONN_CM_HDR (0x0)
 #define CAM_LINE_SIZE sizeof(u32)
 #define RAM_LINE_SIZE sizeof(u64)
-#define REG_SIZE sizeof(u32)
+#define CAM_REG(pf_id) (PRS_REG_GFT_CAM + CAM_LINE_SIZE * (pf_id))
+#define RAM_REG(pf_id) (PRS_REG_GFT_PROFILE_MASK_RAM + RAM_LINE_SIZE * (pf_id))
 
 void qed_set_rfs_mode_disable(struct qed_hwfn *p_hwfn,
 			      struct qed_ptt *p_ptt, u16 pf_id)
 {
-	union gft_cam_line_union camline;
-	struct gft_ram_line ramline;
-	u32 *p_ramline, i;
-
-	p_ramline = (u32 *)&ramline;
-
 	/*stop using gft logic */
 	qed_wr(p_hwfn, p_ptt, PRS_REG_SEARCH_GFT, 0);
 	qed_wr(p_hwfn, p_ptt, PRS_REG_CM_HDR_GFT, 0x0);
-	memset(&camline, 0, sizeof(union gft_cam_line_union));
-	qed_wr(p_hwfn, p_ptt, PRS_REG_GFT_CAM + CAM_LINE_SIZE * pf_id,
-	       camline.cam_line_mapped.camline);
-	memset(&ramline, 0, sizeof(union gft_cam_line_union));
-
-	for (i = 0; i < RAM_LINE_SIZE / REG_SIZE; i++) {
-		u32 hw_addr = PRS_REG_GFT_PROFILE_MASK_RAM;
-
-		hw_addr += (RAM_LINE_SIZE * pf_id + i * REG_SIZE);
-
-		qed_wr(p_hwfn, p_ptt, hw_addr, *(p_ramline + i));
-	}
+	qed_wr(p_hwfn, p_ptt, CAM_REG(pf_id), 0);
+	qed_wr(p_hwfn, p_ptt, RAM_REG(pf_id), 0);
+	qed_wr(p_hwfn, p_ptt, RAM_REG(pf_id) + 4, 0);
 }
 
 void qed_set_rfs_mode_enable(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
 			     u16 pf_id, bool tcp, bool udp,
 			     bool ipv4, bool ipv6)
 {
-	u32 rfs_cm_hdr_event_id, *p_ramline;
+	u32 rfs_cm_hdr_event_id;
 	union gft_cam_line_union camline;
 	struct gft_ram_line ramline;
-	int i;
 
 	rfs_cm_hdr_event_id = qed_rd(p_hwfn, p_ptt, PRS_REG_CM_HDR_GFT);
-	p_ramline = (u32 *)&ramline;
 
 	if (!ipv6 && !ipv4)
 		DP_NOTICE(p_hwfn,
@@ -1060,8 +1044,7 @@ void qed_set_rfs_mode_enable(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
 	}
 
 	/* write characteristics to cam */
-	qed_wr(p_hwfn, p_ptt, PRS_REG_GFT_CAM + CAM_LINE_SIZE * pf_id,
-	       camline.cam_line_mapped.camline);
+	qed_wr(p_hwfn, p_ptt, CAM_REG(pf_id), camline.cam_line_mapped.camline);
 	camline.cam_line_mapped.camline = qed_rd(p_hwfn, p_ptt,
 						 PRS_REG_GFT_CAM +
 						 CAM_LINE_SIZE * pf_id);
@@ -1074,19 +1057,10 @@ void qed_set_rfs_mode_enable(struct qed_hwfn *p_hwfn, struct qed_ptt *p_ptt,
 	SET_FIELD(ramline.low32bits, GFT_RAM_LINE_SRC_PORT, 1);
 	SET_FIELD(ramline.low32bits, GFT_RAM_LINE_DST_PORT, 1);
 
-	/* each iteration write to reg */
-	for (i = 0; i < RAM_LINE_SIZE / REG_SIZE; i++)
-		qed_wr(p_hwfn, p_ptt,
-		       PRS_REG_GFT_PROFILE_MASK_RAM + RAM_LINE_SIZE * pf_id +
-		       i * REG_SIZE, *(p_ramline + i));
+	qed_wr(p_hwfn, p_ptt, RAM_REG(pf_id),     ramline.low32bits);
+	qed_wr(p_hwfn, p_ptt, RAM_REG(pf_id) + 4, ramline.high32bits);
 
 	/* set default profile so that no filter match will happen */
-	ramline.low32bits = 0xffff;
-	ramline.high32bits = 0xffff;
-
-	for (i = 0; i < RAM_LINE_SIZE / REG_SIZE; i++)
-		qed_wr(p_hwfn, p_ptt,
-		       PRS_REG_GFT_PROFILE_MASK_RAM + RAM_LINE_SIZE *
-		       PRS_GFT_CAM_LINES_NO_MATCH + i * REG_SIZE,
-		       *(p_ramline + i));
+	qed_wr(p_hwfn, p_ptt, RAM_REG(PRS_GFT_CAM_LINES_NO_MATCH),     0xffff);
+	qed_wr(p_hwfn, p_ptt, RAM_REG(PRS_GFT_CAM_LINES_NO_MATCH) + 4, 0xffff);
 }
-- 
2.9.0
