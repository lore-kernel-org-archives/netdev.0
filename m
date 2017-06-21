From: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH net-next 1/4] qed: Cleanup qed_roce before duplicating it
Date: Wed, 21 Jun 2017 16:22:43 +0300
Message-ID: <1498051366-22988-2-git-send-email-Michal.Kalderon@cavium.com>
References: <1498051366-22988-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1498051366-22988-1-git-send-email-Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The next patch in the series will duplicate qed_roce as part
of code preprations for iWARP support. Do some cleanup before
duplicating

Signed-off-by: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
---
 drivers/net/ethernet/qlogic/qed/qed_roce.c | 51 +++++++-----------------------
 1 file changed, 12 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_roce.c b/drivers/net/ethernet/qlogic/qed/qed_roce.c
index 673f80a..9dc41a8 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_roce.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_roce.c
@@ -35,11 +35,7 @@
 #include <linux/delay.h>
 #include <linux/dma-mapping.h>
 #include <linux/errno.h>
-#include <linux/if_ether.h>
-#include <linux/if_vlan.h>
 #include <linux/io.h>
-#include <linux/ip.h>
-#include <linux/ipv6.h>
 #include <linux/kernel.h>
 #include <linux/list.h>
 #include <linux/module.h>
@@ -48,10 +44,6 @@
 #include <linux/slab.h>
 #include <linux/spinlock.h>
 #include <linux/string.h>
-#include <linux/tcp.h>
-#include <linux/bitops.h>
-#include <linux/qed/qed_roce_if.h>
-#include <linux/qed/qed_roce_if.h>
 #include "qed.h"
 #include "qed_cxt.h"
 #include "qed_hsi.h"
@@ -61,10 +53,9 @@
 #include "qed_ll2.h"
 #include "qed_mcp.h"
 #include "qed_reg_addr.h"
-#include "qed_sp.h"
 #include "qed_roce.h"
-#include "qed_ll2.h"
-#include <linux/qed/qed_ll2_if.h>
+#include <linux/qed/qed_roce_if.h>
+#include "qed_sp.h"
 
 static void qed_roce_free_real_icid(struct qed_hwfn *p_hwfn, u16 icid);
 
@@ -100,13 +91,10 @@ static int qed_rdma_bmap_alloc(struct qed_hwfn *p_hwfn,
 
 	bmap->max_count = max_count;
 
-	bmap->bitmap = kzalloc(BITS_TO_LONGS(max_count) * sizeof(long),
+	bmap->bitmap = kcalloc(BITS_TO_LONGS(max_count), sizeof(long),
 			       GFP_KERNEL);
-	if (!bmap->bitmap) {
-		DP_NOTICE(p_hwfn,
-			  "qed bmap alloc failed: cannot allocate memory (bitmap)\n");
+	if (!bmap->bitmap)
 		return -ENOMEM;
-	}
 
 	snprintf(bmap->name, QED_RDMA_MAX_BMAP_NAME, "%s", name);
 
@@ -189,12 +177,8 @@ static int qed_rdma_alloc(struct qed_hwfn *p_hwfn,
 
 	/* Allocate a struct with current pf rdma info */
 	p_rdma_info = kzalloc(sizeof(*p_rdma_info), GFP_KERNEL);
-	if (!p_rdma_info) {
-		DP_NOTICE(p_hwfn,
-			  "qed rdma alloc failed: cannot allocate memory (rdma info). rc = %d\n",
-			  rc);
+	if (!p_rdma_info)
 		return rc;
-	}
 
 	p_hwfn->p_rdma_info = p_rdma_info;
 	p_rdma_info->proto = PROTOCOLID_ROCE;
@@ -217,21 +201,13 @@ static int qed_rdma_alloc(struct qed_hwfn *p_hwfn,
 
 	/* Allocate a struct with device params and fill it */
 	p_rdma_info->dev = kzalloc(sizeof(*p_rdma_info->dev), GFP_KERNEL);
-	if (!p_rdma_info->dev) {
-		DP_NOTICE(p_hwfn,
-			  "qed rdma alloc failed: cannot allocate memory (rdma info dev). rc = %d\n",
-			  rc);
+	if (!p_rdma_info->dev)
 		goto free_rdma_info;
-	}
 
 	/* Allocate a struct with port params and fill it */
 	p_rdma_info->port = kzalloc(sizeof(*p_rdma_info->port), GFP_KERNEL);
-	if (!p_rdma_info->port) {
-		DP_NOTICE(p_hwfn,
-			  "qed rdma alloc failed: cannot allocate memory (rdma info port). rc = %d\n",
-			  rc);
+	if (!p_rdma_info->port)
 		goto free_rdma_dev;
-	}
 
 	/* Allocate bit map for pd's */
 	rc = qed_rdma_bmap_alloc(p_hwfn, &p_rdma_info->pd_map, RDMA_MAX_PDS,
@@ -1108,6 +1084,7 @@ static int qed_rdma_create_cq(void *rdma_cxt,
 	struct qed_sp_init_data init_data;
 	struct qed_spq_entry *p_ent;
 	dma_addr_t ramrod_res_phys;
+	enum protocol_type proto;
 	int rc = -ENOMEM;
 
 	DP_VERBOSE(p_hwfn, QED_MSG_RDMA, "icid = %08x\n", in_params->icid);
@@ -1128,11 +1105,11 @@ static int qed_rdma_create_cq(void *rdma_cxt,
 	init_data.cid = in_params->icid;
 	init_data.opaque_fid = p_hwfn->hw_info.opaque_fid;
 	init_data.comp_mode = QED_SPQ_MODE_EBLOCK;
-
+	proto = p_hwfn->p_rdma_info->proto;
 	/* Send destroy CQ ramrod */
 	rc = qed_sp_init_request(p_hwfn, &p_ent,
 				 RDMA_RAMROD_DESTROY_CQ,
-				 p_hwfn->p_rdma_info->proto, &init_data);
+				 proto, &init_data);
 	if (rc)
 		goto err;
 
@@ -1155,9 +1132,7 @@ static int qed_rdma_create_cq(void *rdma_cxt,
 	qed_bmap_release_id(p_hwfn,
 			    &p_hwfn->p_rdma_info->cq_map,
 			    (in_params->icid -
-			     qed_cxt_get_proto_cid_start(p_hwfn,
-							 p_hwfn->
-							 p_rdma_info->proto)));
+			     qed_cxt_get_proto_cid_start(p_hwfn, proto)));
 
 	spin_unlock_bh(&p_hwfn->p_rdma_info->lock);
 
@@ -2153,10 +2128,8 @@ static int qed_rdma_destroy_qp(void *rdma_cxt, struct qed_rdma_qp *qp)
 	}
 
 	qp = kzalloc(sizeof(*qp), GFP_KERNEL);
-	if (!qp) {
-		DP_NOTICE(p_hwfn, "Failed to allocate qed_rdma_qp\n");
+	if (!qp)
 		return NULL;
-	}
 
 	rc = qed_roce_alloc_cid(p_hwfn, &qp->icid);
 	qp->qpid = ((0xFF << 16) | qp->icid);
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
