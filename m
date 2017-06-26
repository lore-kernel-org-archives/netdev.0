From: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: [RFC 16/19] RDMA/qedr: Add support for read with invalidate, supported in iWARP
Date: Mon, 26 Jun 2017 21:07:06 +0300
Message-ID: <1498500429-22557-17-git-send-email-Michal.Kalderon@cavium.com>
References: <1498500429-22557-1-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: <michal.kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, <ram.amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        <yuval.mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>, <ariel.elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1498500429-22557-1-git-send-email-Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

iWARP supports read with invalidate. There is an assumption
that read with invalidate will only be called on an iWARP device

Signed-off-by: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Ram Amrani <Ram.Amrani-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Signed-off-by: Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>

---
 drivers/infiniband/hw/qedr/qedr_hsi_rdma.h | 6 ++++--
 drivers/infiniband/hw/qedr/verbs.c         | 8 +++-----
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/infiniband/hw/qedr/qedr_hsi_rdma.h b/drivers/infiniband/hw/qedr/qedr_hsi_rdma.h
index 5c98d20..b7587f1 100644
--- a/drivers/infiniband/hw/qedr/qedr_hsi_rdma.h
+++ b/drivers/infiniband/hw/qedr/qedr_hsi_rdma.h
@@ -655,8 +655,10 @@ struct rdma_sq_rdma_wqe_1st {
 #define RDMA_SQ_RDMA_WQE_1ST_INLINE_FLG_SHIFT      4
 #define RDMA_SQ_RDMA_WQE_1ST_DIF_ON_HOST_FLG_MASK  0x1
 #define RDMA_SQ_RDMA_WQE_1ST_DIF_ON_HOST_FLG_SHIFT 5
-#define RDMA_SQ_RDMA_WQE_1ST_RESERVED0_MASK        0x3
-#define RDMA_SQ_RDMA_WQE_1ST_RESERVED0_SHIFT       6
+#define RDMA_SQ_RDMA_WQE_1ST_READ_INV_FLG_MASK     0x1
+#define RDMA_SQ_RDMA_WQE_1ST_READ_INV_FLG_SHIFT    6
+#define RDMA_SQ_RDMA_WQE_1ST_RESERVED0_MASK        0x1
+#define RDMA_SQ_RDMA_WQE_1ST_RESERVED0_SHIFT       7
 	u8 wqe_size;
 	u8 prev_wqe_size;
 };
diff --git a/drivers/infiniband/hw/qedr/verbs.c b/drivers/infiniband/hw/qedr/verbs.c
index 7fef9b3..fc9ff13 100644
--- a/drivers/infiniband/hw/qedr/verbs.c
+++ b/drivers/infiniband/hw/qedr/verbs.c
@@ -2837,6 +2837,7 @@ static enum ib_wc_opcode qedr_ib_to_wc_opcode(enum ib_wr_opcode opcode)
 	case IB_WR_SEND_WITH_INV:
 		return IB_WC_SEND;
 	case IB_WR_RDMA_READ:
+	case IB_WR_RDMA_READ_WITH_INV:
 		return IB_WC_RDMA_READ;
 	case IB_WR_ATOMIC_CMP_AND_SWP:
 		return IB_WC_COMP_SWAP;
@@ -2997,11 +2998,8 @@ static int __qedr_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 		qp->wqe_wr_id[qp->sq.prod].bytes_len = rwqe->length;
 		break;
 	case IB_WR_RDMA_READ_WITH_INV:
-		DP_ERR(dev,
-		       "RDMA READ WITH INVALIDATE not supported\n");
-		*bad_wr = wr;
-		rc = -EINVAL;
-		break;
+		SET_FIELD2(wqe->flags, RDMA_SQ_RDMA_WQE_1ST_READ_INV_FLG, 1);
+		/* fallthrough... same is identical to RDMA READ */
 
 	case IB_WR_RDMA_READ:
 		wqe->req_type = RDMA_SQ_REQ_TYPE_RDMA_RD;
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
