From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH 2.6.26 1/3] RDMA/cxgb3: Correctly serialize
	peer abort path.
Date: Sun, 27 Apr 2008 11:00:06 -0500
Message-ID: <20080427160006.31018.66715.stgit@dell3.ogc.int>
References: <20080427155456.31018.22282.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, divy@chelsio.com, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20080427155456.31018.22282.stgit@dell3.ogc.int>
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


OpenMPI and other stress testing exposed a few bad bugs in handling
aborts in the middle of a normal close.

- serialize abort reply and peer abort processing with
disconnect processing

- warn (and ignore) if ep timer is stopped when it wasn't running

- cleaned up disconnect path to correctly deal with aborting and dead
endpoints

- in iwch_modify_qp(), add a ref to the ep before releasing the qp lock i=
f
iwch_ep_disconnect() will be called.  The dref after calling disconnect.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/iwch_cm.c |   98 ++++++++++++++++++++++-----=
------
 drivers/infiniband/hw/cxgb3/iwch_cm.h |    1=20
 drivers/infiniband/hw/cxgb3/iwch_qp.c |    6 ++
 3 files changed, 71 insertions(+), 34 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/h=
w/cxgb3/iwch_cm.c
index 99f2f2a..1627bff 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -125,6 +125,12 @@ static void start_ep_timer(struct iwch_ep *ep)
 static void stop_ep_timer(struct iwch_ep *ep)
 {
 	PDBG("%s ep %p\n", __FUNCTION__, ep);
+	if (!timer_pending(&ep->timer)) {
+		printk(KERN_ERR "%s timer stopped when its not running!  ep %p state %=
u\n",
+			__FUNCTION__, ep, ep->com.state);
+		WARN_ON(1);
+		return;
+	}
 	del_timer_sync(&ep->timer);
 	put_ep(&ep->com);
 }
@@ -1083,8 +1089,11 @@ static int tx_ack(struct t3cdev *tdev, struct sk_b=
uff *skb, void *ctx)
 static int abort_rpl(struct t3cdev *tdev, struct sk_buff *skb, void *ctx=
)
 {
 	struct iwch_ep *ep =3D ctx;
+	unsigned long flags;
+	int release =3D 0;
=20
 	PDBG("%s ep %p\n", __FUNCTION__, ep);
+	BUG_ON(!ep);
=20
 	/*
 	 * We get 2 abort replies from the HW.  The first one must
@@ -1095,9 +1104,22 @@ static int abort_rpl(struct t3cdev *tdev, struct s=
k_buff *skb, void *ctx)
 		return CPL_RET_BUF_DONE;
 	}
=20
-	close_complete_upcall(ep);
-	state_set(&ep->com, DEAD);
-	release_ep_resources(ep);
+	spin_lock_irqsave(&ep->com.lock, flags);
+	switch (ep->com.state) {
+	case ABORTING:
+		close_complete_upcall(ep);
+		__state_set(&ep->com, DEAD);
+		release =3D 1;
+		break;
+	default:
+		printk(KERN_ERR "%s ep %p state %d\n",
+		     __FUNCTION__, ep, ep->com.state);
+		break;
+	}
+	spin_unlock_irqrestore(&ep->com.lock, flags);
+
+	if (release)
+		release_ep_resources(ep);
 	return CPL_RET_BUF_DONE;
 }
=20
@@ -1470,7 +1492,8 @@ static int peer_abort(struct t3cdev *tdev, struct s=
k_buff *skb, void *ctx)
 	struct sk_buff *rpl_skb;
 	struct iwch_qp_attributes attrs;
 	int ret;
-	int state;
+	int release =3D 0;
+	unsigned long flags;
=20
 	if (is_neg_adv_abort(req->status)) {
 		PDBG("%s neg_adv_abort ep %p tid %d\n", __FUNCTION__, ep,
@@ -1488,9 +1511,9 @@ static int peer_abort(struct t3cdev *tdev, struct s=
k_buff *skb, void *ctx)
 		return CPL_RET_BUF_DONE;
 	}
=20
-	state =3D state_read(&ep->com);
-	PDBG("%s ep %p state %u\n", __FUNCTION__, ep, state);
-	switch (state) {
+	spin_lock_irqsave(&ep->com.lock, flags);
+	PDBG("%s ep %p state %u\n", __FUNCTION__, ep, ep->com.state);
+	switch (ep->com.state) {
 	case CONNECTING:
 		break;
 	case MPA_REQ_WAIT:
@@ -1536,21 +1559,25 @@ static int peer_abort(struct t3cdev *tdev, struct=
 sk_buff *skb, void *ctx)
 		break;
 	case DEAD:
 		PDBG("%s PEER_ABORT IN DEAD STATE!!!!\n", __FUNCTION__);
+		spin_unlock_irqrestore(&ep->com.lock, flags);
 		return CPL_RET_BUF_DONE;
 	default:
 		BUG_ON(1);
 		break;
 	}
 	dst_confirm(ep->dst);
+	if (ep->com.state !=3D ABORTING) {
+		__state_set(&ep->com, DEAD);
+		release =3D 1;
+	}
+	spin_unlock_irqrestore(&ep->com.lock, flags);
=20
 	rpl_skb =3D get_skb(skb, sizeof(*rpl), GFP_KERNEL);
 	if (!rpl_skb) {
 		printk(KERN_ERR MOD "%s - cannot allocate skb!\n",
 		       __FUNCTION__);
-		dst_release(ep->dst);
-		l2t_release(L2DATA(ep->com.tdev), ep->l2t);
-		put_ep(&ep->com);
-		return CPL_RET_BUF_DONE;
+		release =3D 1;
+		goto out;
 	}
 	rpl_skb->priority =3D CPL_PRIORITY_DATA;
 	rpl =3D (struct cpl_abort_rpl *) skb_put(rpl_skb, sizeof(*rpl));
@@ -1559,10 +1586,9 @@ static int peer_abort(struct t3cdev *tdev, struct =
sk_buff *skb, void *ctx)
 	OPCODE_TID(rpl) =3D htonl(MK_OPCODE_TID(CPL_ABORT_RPL, ep->hwtid));
 	rpl->cmd =3D CPL_ABORT_NO_RST;
 	cxgb3_ofld_send(ep->com.tdev, rpl_skb);
-	if (state !=3D ABORTING) {
-		state_set(&ep->com, DEAD);
+out:
+	if (release)
 		release_ep_resources(ep);
-	}
 	return CPL_RET_BUF_DONE;
 }
=20
@@ -1661,15 +1687,18 @@ static void ep_timeout(unsigned long arg)
 	struct iwch_ep *ep =3D (struct iwch_ep *)arg;
 	struct iwch_qp_attributes attrs;
 	unsigned long flags;
+	int abort=3D1;
=20
 	spin_lock_irqsave(&ep->com.lock, flags);
 	PDBG("%s ep %p tid %u state %d\n", __FUNCTION__, ep, ep->hwtid,
 	     ep->com.state);
 	switch (ep->com.state) {
 	case MPA_REQ_SENT:
+		__state_set(&ep->com, ABORTING);
 		connect_reply_upcall(ep, -ETIMEDOUT);
 		break;
 	case MPA_REQ_WAIT:
+		__state_set(&ep->com, ABORTING);
 		break;
 	case CLOSING:
 	case MORIBUND:
@@ -1679,13 +1708,17 @@ static void ep_timeout(unsigned long arg)
 				     ep->com.qp, IWCH_QP_ATTR_NEXT_STATE,
 				     &attrs, 1);
 		}
+		__state_set(&ep->com, ABORTING);
 		break;
 	default:
-		BUG();
+		printk(KERN_ERR "%s unexpected state ep %p state %u\n",
+			__FUNCTION__, ep, ep->com.state);
+		WARN_ON(1);
+		abort=3D0;
 	}
-	__state_set(&ep->com, CLOSING);
 	spin_unlock_irqrestore(&ep->com.lock, flags);
-	abort_connection(ep, NULL, GFP_ATOMIC);
+	if (abort)
+		abort_connection(ep, NULL, GFP_ATOMIC);
 	put_ep(&ep->com);
 }
=20
@@ -1968,34 +2001,33 @@ int iwch_ep_disconnect(struct iwch_ep *ep, int ab=
rupt, gfp_t gfp)
 	PDBG("%s ep %p state %s, abrupt %d\n", __FUNCTION__, ep,
 	     states[ep->com.state], abrupt);
=20
-	if (ep->com.state =3D=3D DEAD) {
-		PDBG("%s already dead ep %p\n", __FUNCTION__, ep);
-		goto out;
-	}
-
-	if (abrupt) {
-		if (ep->com.state !=3D ABORTING) {
-			ep->com.state =3D ABORTING;
-			close =3D 1;
-		}
-		goto out;
-	}
-
 	switch (ep->com.state) {
 	case MPA_REQ_WAIT:
 	case MPA_REQ_SENT:
 	case MPA_REQ_RCVD:
 	case MPA_REP_SENT:
 	case FPDU_MODE:
-		start_ep_timer(ep);
-		ep->com.state =3D CLOSING;
 		close =3D 1;
+		if (abrupt)
+			ep->com.state =3D ABORTING;
+		else {
+			ep->com.state =3D CLOSING;
+			start_ep_timer(ep);
+		}
 		break;
 	case CLOSING:
-		ep->com.state =3D MORIBUND;
 		close =3D 1;
+		if (abrupt) {
+			stop_ep_timer(ep);
+			ep->com.state =3D ABORTING;
+		} else
+			ep->com.state =3D MORIBUND;
 		break;
 	case MORIBUND:
+	case ABORTING:
+	case DEAD:
+		PDBG("%s ignoring disconnect ep %p state %u\n",
+		     __FUNCTION__, ep, ep->com.state);
 		break;
 	default:
 		BUG();
diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.h b/drivers/infiniband/h=
w/cxgb3/iwch_cm.h
index 6107e7c..a3fb959 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.h
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.h
@@ -56,6 +56,7 @@
 #define put_ep(ep) { \
 	PDBG("put_ep (via %s:%u) ep %p refcnt %d\n", __FUNCTION__, __LINE__,  \
 	     ep, atomic_read(&((ep)->kref.refcount))); \
+	WARN_ON(atomic_read(&((ep)->kref.refcount)) < 1); \
 	kref_put(&((ep)->kref), __free_ep); \
 }
=20
diff --git a/drivers/infiniband/hw/cxgb3/iwch_qp.c b/drivers/infiniband/h=
w/cxgb3/iwch_qp.c
index ea2cdd7..c02bb94 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_qp.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_qp.c
@@ -832,6 +832,7 @@ int iwch_modify_qp(struct iwch_dev *rhp, struct iwch_=
qp *qhp,
 				abort=3D0;
 				disconnect =3D 1;
 				ep =3D qhp->ep;
+				get_ep(&ep->com);
 			}
 			flush_qp(qhp, &flag);
 			break;
@@ -848,6 +849,7 @@ int iwch_modify_qp(struct iwch_dev *rhp, struct iwch_=
qp *qhp,
 				abort=3D1;
 				disconnect =3D 1;
 				ep =3D qhp->ep;
+				get_ep(&ep->com);
 			}
 			goto err;
 			break;
@@ -929,8 +931,10 @@ out:
 	 * on the EP.  This can be a normal close (RTS->CLOSING) or
 	 * an abnormal close (RTS/CLOSING->ERROR).
 	 */
-	if (disconnect)
+	if (disconnect) {
 		iwch_ep_disconnect(ep, abort, GFP_KERNEL);
+		put_ep(&ep->com);
+	}
=20
 	/*
 	 * If free is 1, then we've disassociated the EP from the QP
