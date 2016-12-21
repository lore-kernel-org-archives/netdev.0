From: Selvin Xavier <selvin.xavier@broadcom.com>
Subject: [PATCH for bnxt_re V4 19/21] RDMA/bnxt_re: Set uverbs command mask
Date: Wed, 21 Dec 2016 03:42:08 -0800
Message-ID: <1482320530-5344-20-git-send-email-selvin.xavier@broadcom.com>
References: <1482320530-5344-1-git-send-email-selvin.xavier@broadcom.com>
Cc: netdev@vger.kernel.org, michael.chan@broadcom.com,
        Selvin Xavier <selvin.xavier@broadcom.com>,
        Eddie Wai <eddie.wai@broadcom.com>,
        Devesh Sharma <devesh.sharma@broadcom.com>,
        Somnath Kotur <somnath.kotur@broadcom.com>,
        Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
To: dledford@redhat.com, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:37482 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933584AbcLULoM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 06:44:12 -0500
Received: by mail-wm0-f52.google.com with SMTP id t79so156288567wmt.0
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2016 03:44:11 -0800 (PST)
In-Reply-To: <1482320530-5344-1-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch exports available uverbs command mask to the IB stack.
Also, populates some of the missing parameters in the ibdev structure
used for registration.

v4: Changes the include file names

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Devesh Sharma <devesh.sharma@broadcom.com>
Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Sriharsha Basavapatna <sriharsha.basavapatna@broadcom.com>
Signed-off-by: Selvin Xavier <selvin.xavier@broadcom.com>
---
 drivers/infiniband/hw/bnxt_re/main.c | 35 +++++++++++++++++++++++++++++++++++
 1 file changed, 35 insertions(+)

diff --git a/drivers/infiniband/hw/bnxt_re/main.c b/drivers/infiniband/hw/bnxt_re/main.c
index 7e78da6..7bc41da 100644
--- a/drivers/infiniband/hw/bnxt_re/main.c
+++ b/drivers/infiniband/hw/bnxt_re/main.c
@@ -61,6 +61,7 @@
 #include "qplib_rcfw.h"
 #include "bnxt_re.h"
 #include "ib_verbs.h"
+#include <rdma/bnxt_re-abi.h>
 #include "bnxt.h"
 static char version[] =
 		BNXT_RE_DESC " v" ROCE_DRV_MODULE_VERSION "\n";
@@ -435,8 +436,42 @@ static int bnxt_re_register_ib(struct bnxt_re_dev *rdev)
 		strlen(BNXT_RE_DESC) + 5);
 	ibdev->phys_port_cnt = 1;
 
+	bnxt_qplib_get_guid(rdev->netdev->dev_addr, (u8 *)&ibdev->node_guid);
+
 	ibdev->num_comp_vectors	= 1;
 	ibdev->dma_device = &rdev->en_dev->pdev->dev;
+	ibdev->local_dma_lkey = BNXT_QPLIB_RSVD_LKEY;
+
+	/* User space */
+	ibdev->uverbs_abi_ver = BNXT_RE_ABI_VERSION;
+	ibdev->uverbs_cmd_mask =
+			(1ull << IB_USER_VERBS_CMD_GET_CONTEXT)		|
+			(1ull << IB_USER_VERBS_CMD_QUERY_DEVICE)	|
+			(1ull << IB_USER_VERBS_CMD_QUERY_PORT)		|
+			(1ull << IB_USER_VERBS_CMD_ALLOC_PD)		|
+			(1ull << IB_USER_VERBS_CMD_DEALLOC_PD)		|
+			(1ull << IB_USER_VERBS_CMD_REG_MR)		|
+			(1ull << IB_USER_VERBS_CMD_REREG_MR)		|
+			(1ull << IB_USER_VERBS_CMD_DEREG_MR)		|
+			(1ull << IB_USER_VERBS_CMD_CREATE_COMP_CHANNEL) |
+			(1ull << IB_USER_VERBS_CMD_CREATE_CQ)		|
+			(1ull << IB_USER_VERBS_CMD_RESIZE_CQ)		|
+			(1ull << IB_USER_VERBS_CMD_DESTROY_CQ)		|
+			(1ull << IB_USER_VERBS_CMD_CREATE_QP)		|
+			(1ull << IB_USER_VERBS_CMD_MODIFY_QP)		|
+			(1ull << IB_USER_VERBS_CMD_QUERY_QP)		|
+			(1ull << IB_USER_VERBS_CMD_DESTROY_QP)		|
+			(1ull << IB_USER_VERBS_CMD_CREATE_SRQ)		|
+			(1ull << IB_USER_VERBS_CMD_MODIFY_SRQ)		|
+			(1ull << IB_USER_VERBS_CMD_QUERY_SRQ)		|
+			(1ull << IB_USER_VERBS_CMD_DESTROY_SRQ)		|
+			(1ull << IB_USER_VERBS_CMD_CREATE_AH)		|
+			(1ull << IB_USER_VERBS_CMD_MODIFY_AH)		|
+			(1ull << IB_USER_VERBS_CMD_QUERY_AH)		|
+			(1ull << IB_USER_VERBS_CMD_DESTROY_AH);
+	/* POLL_CQ and REQ_NOTIFY_CQ is directly handled in libbnxt_re */
+
+	/* Kernel verbs */
 	ibdev->query_device		= bnxt_re_query_device;
 	ibdev->modify_device		= bnxt_re_modify_device;
 
-- 
2.5.5
