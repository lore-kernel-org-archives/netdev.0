From: Bryan O'Sullivan <bos@pathscale.com>
Subject: [PATCH 36 of 39] IB/ipath - Ignore receive queue size if SRQ is
	specified
Date: Thu, 29 Jun 2006 14:41:27 -0700
Message-ID: <31c382d8210a80c37278.1151617287@eng-12.pathscale.com>
References: <patchbomb.1151617251@eng-12.pathscale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: openib-general@openib.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932913AbWF2Vrn@vger.kernel.org>
In-Reply-To: <patchbomb.1151617251@eng-12.pathscale.com>
To: akpm@osdl.org, rdreier@cisco.com, mst@mellanox.co.il
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The receive work queue size should be ignored if the QP is created
to use a shared receive queue according to the IB spec.

Signed-off-by: Ralph Campbell <ralph.campbell@qlogic.com>
Signed-off-by: Bryan O'Sullivan <bryan.osullivan@qlogic.com>

diff -r 9b423c45af8b -r 31c382d8210a drivers/infiniband/hw/ipath/ipath_qp.c
--- a/drivers/infiniband/hw/ipath/ipath_qp.c	Thu Jun 29 14:33:26 2006 -0700
+++ b/drivers/infiniband/hw/ipath/ipath_qp.c	Thu Jun 29 14:33:26 2006 -0700
@@ -685,16 +685,22 @@ struct ib_qp *ipath_create_qp(struct ib_
 			ret = ERR_PTR(-ENOMEM);
 			goto bail;
 		}
-		qp->r_rq.size = init_attr->cap.max_recv_wr + 1;
-		sz = sizeof(struct ipath_sge) *
-			init_attr->cap.max_recv_sge +
-			sizeof(struct ipath_rwqe);
-		qp->r_rq.wq = vmalloc(qp->r_rq.size * sz);
-		if (!qp->r_rq.wq) {
-			kfree(qp);
-			vfree(swq);
-			ret = ERR_PTR(-ENOMEM);
-			goto bail;
+		if (init_attr->srq) {
+			qp->r_rq.size = 0;
+			qp->r_rq.max_sge = 0;
+			qp->r_rq.wq = NULL;
+		} else {
+			qp->r_rq.size = init_attr->cap.max_recv_wr + 1;
+			qp->r_rq.max_sge = init_attr->cap.max_recv_sge;
+			sz = (sizeof(struct ipath_sge) * qp->r_rq.max_sge) +
+				sizeof(struct ipath_rwqe);
+			qp->r_rq.wq = vmalloc(qp->r_rq.size * sz);
+			if (!qp->r_rq.wq) {
+				kfree(qp);
+				vfree(swq);
+				ret = ERR_PTR(-ENOMEM);
+				goto bail;
+			}
 		}
 
 		/*
@@ -713,7 +719,6 @@ struct ib_qp *ipath_create_qp(struct ib_
 		qp->s_wq = swq;
 		qp->s_size = init_attr->cap.max_send_wr + 1;
 		qp->s_max_sge = init_attr->cap.max_send_sge;
-		qp->r_rq.max_sge = init_attr->cap.max_recv_sge;
 		qp->s_flags = init_attr->sq_sig_type == IB_SIGNAL_REQ_WR ?
 			1 << IPATH_S_SIGNAL_REQ_WR : 0;
 		dev = to_idev(ibpd->device);
