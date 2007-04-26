From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH 2.6.22 4/5] iw_cxgb3: Support for new abort
	logic.
Date: Thu, 26 Apr 2007 15:21:20 -0500
Message-ID: <20070426202120.24234.62250.stgit@dell3.ogc.int>
References: <20070426202057.24234.56383.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org, divy@chelsio.com,
	linux-kernel@vger.kernel.org
To: rdreier@cisco.com,jeff@garzik.org
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070426202057.24234.56383.stgit@dell3.ogc.int>
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


Support for new abort logic.

The HW now posts 2 ABORT_RPL and/or PEER_ABORT_REQ messages.  We need
to handle them by silenty dropping the 1st but mark that we're ready
for the final message.  This plugs some close races between the uP and HW=
.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/iwch_cm.c |   18 ++++++++++++++++++
 drivers/infiniband/hw/cxgb3/iwch_cm.h |    6 ++++++
 2 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/h=
w/cxgb3/iwch_cm.c
index a990423..3a46a97 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -1107,6 +1107,15 @@ static int abort_rpl(struct t3cdev *tdev
=20
 	PDBG("%s ep %p\n", __FUNCTION__, ep);
=20
+	/*
+ 	 * We get 2 abort replies from the HW.  The first one must
+	 * be ignored except for scribbling that we need one more.
+	 */
+	if (!(ep->flags & ABORT_REQ_IN_PROGRESS)) {
+		ep->flags |=3D ABORT_REQ_IN_PROGRESS;
+		return CPL_RET_BUF_DONE;
+	}
+
 	close_complete_upcall(ep);
 	state_set(&ep->com, DEAD);
 	release_ep_resources(ep);
@@ -1474,6 +1483,15 @@ static int peer_abort(struct t3cdev *tde
 	int ret;
 	int state;
=20
+	/*
+ 	 * We get 2 peer aborts from the HW.  The first one must
+	 * be ignored except for scribbling that we need one more.
+	 */
+	if (!(ep->flags & PEER_ABORT_IN_PROGRESS)) {
+		ep->flags |=3D PEER_ABORT_IN_PROGRESS;
+		return CPL_RET_BUF_DONE;
+	}
+
 	if (is_neg_adv_abort(req->status)) {
 		PDBG("%s neg_adv_abort ep %p tid %d\n", __FUNCTION__, ep,
 		     ep->hwtid);
diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.h b/drivers/infiniband/h=
w/cxgb3/iwch_cm.h
index 0c6f281..21a388c 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.h
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.h
@@ -143,6 +143,11 @@ enum iwch_ep_state {
 	DEAD,
 };
=20
+enum iwch_ep_flags {
+	PEER_ABORT_IN_PROGRESS	=3D (1 << 0),
+	ABORT_REQ_IN_PROGRESS	=3D (1 << 1),
+};
+
 struct iwch_ep_common {
 	struct iw_cm_id *cm_id;
 	struct iwch_qp *qp;
@@ -181,6 +186,7 @@ struct iwch_ep {
 	u16 plen;
 	u32 ird;
 	u32 ord;
+	u32 flags;
 };
=20
 static inline struct iwch_ep *to_ep(struct iw_cm_id *cm_id)
