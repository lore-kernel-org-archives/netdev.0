From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH RESEND 1/3] RDMA/cxgb3: Flush the RQ when
	closing.
Date: Mon, 21 Jan 2008 14:42:09 -0600
Message-ID: <20080121204208.3820.92974.stgit@dell3.ogc.int>
References: <20080121204130.3820.11053.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080121204130.3820.11053.stgit@dell3.ogc.int>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org


RDMA/cxgb3: Flush the RQ when closing.

- for kernel mode cqs, call event notification handler when flushing
- flush qp when moving from RTS -> CLOSING
- fixed logic to identify a kernel mode qp

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/iwch_qp.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_qp.c b/drivers/infiniband/h=
w/cxgb3/iwch_qp.c
index 9bb8112..7681fdc 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_qp.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_qp.c
@@ -642,6 +642,7 @@ static void __flush_qp(struct iwch_qp *qhp, unsigned =
long *flag)
 	cxio_flush_rq(&qhp->wq, &rchp->cq, count);
 	spin_unlock(&qhp->lock);
 	spin_unlock_irqrestore(&rchp->lock, *flag);
+	(*rchp->ibcq.comp_handler)(&rchp->ibcq, rchp->ibcq.cq_context);
=20
 	/* locking heirarchy: cq lock first, then qp lock. */
 	spin_lock_irqsave(&schp->lock, *flag);
@@ -651,6 +652,7 @@ static void __flush_qp(struct iwch_qp *qhp, unsigned =
long *flag)
 	cxio_flush_sq(&qhp->wq, &schp->cq, count);
 	spin_unlock(&qhp->lock);
 	spin_unlock_irqrestore(&schp->lock, *flag);
+	(*schp->ibcq.comp_handler)(&schp->ibcq, schp->ibcq.cq_context);
=20
 	/* deref */
 	if (atomic_dec_and_test(&qhp->refcnt))
@@ -661,7 +663,7 @@ static void __flush_qp(struct iwch_qp *qhp, unsigned =
long *flag)
=20
 static void flush_qp(struct iwch_qp *qhp, unsigned long *flag)
 {
-	if (t3b_device(qhp->rhp))
+	if (qhp->ibqp.uobject)
 		cxio_set_wq_in_error(&qhp->wq);
 	else
 		__flush_qp(qhp, flag);
@@ -830,10 +832,11 @@ int iwch_modify_qp(struct iwch_dev *rhp, struct iwc=
h_qp *qhp,
 				disconnect =3D 1;
 				ep =3D qhp->ep;
 			}
+			flush_qp(qhp, &flag);
 			break;
 		case IWCH_QP_STATE_TERMINATE:
 			qhp->attr.state =3D IWCH_QP_STATE_TERMINATE;
-			if (t3b_device(qhp->rhp))
+			if (qhp->ibqp.uobject)
 				cxio_set_wq_in_error(&qhp->wq);
 			if (!internal)
 				terminate =3D 1;
