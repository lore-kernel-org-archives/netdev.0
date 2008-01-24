From: Steve Wise <swise@opengridcomputing.com>
Subject: [ofa-general] [PATCH 2.6.25] RDMA/cxgb3: Fix the T3A workaround
	checks.
Date: Thu, 24 Jan 2008 16:30:16 -0600
Message-ID: <20080124223016.772.18293.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
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


RDMA/cxgb3: Fix the T3A workaround checks.

Correctly work around T3A issues by checking "hwtype !=3D T3A" instead of
"hwtype =3D=3D T3B".  Needed for new hw types.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/cxio_hal.c      |    2 +-
 drivers/infiniband/hw/cxgb3/iwch_cm.c       |    4 ++--
 drivers/infiniband/hw/cxgb3/iwch_provider.c |    2 +-
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/cxio_hal.c b/drivers/infiniband/=
hw/cxgb3/cxio_hal.c
index eec6a30..e220b44 100644
--- a/drivers/infiniband/hw/cxgb3/cxio_hal.c
+++ b/drivers/infiniband/hw/cxgb3/cxio_hal.c
@@ -179,7 +179,7 @@ int cxio_create_cq(struct cxio_rdev *rdev_p, struct t=
3_cq *cq)
 	setup.size =3D 1UL << cq->size_log2;
 	setup.credits =3D 65535;
 	setup.credit_thres =3D 1;
-	if (rdev_p->t3cdev_p->type =3D=3D T3B)
+	if (rdev_p->t3cdev_p->type !=3D T3A)
 		setup.ovfl_mode =3D 0;
 	else
 		setup.ovfl_mode =3D 1;
diff --git a/drivers/infiniband/hw/cxgb3/iwch_cm.c b/drivers/infiniband/h=
w/cxgb3/iwch_cm.c
index 20ba372..f8cb0fe 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_cm.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_cm.c
@@ -1118,7 +1118,7 @@ static int act_open_rpl(struct t3cdev *tdev, struct=
 sk_buff *skb, void *ctx)
 	     status2errno(rpl->status));
 	connect_reply_upcall(ep, status2errno(rpl->status));
 	state_set(&ep->com, DEAD);
-	if (ep->com.tdev->type =3D=3D T3B && act_open_has_tid(rpl->status))
+	if (ep->com.tdev->type !=3D T3A && act_open_has_tid(rpl->status))
 		release_tid(ep->com.tdev, GET_TID(rpl), NULL);
 	cxgb3_free_atid(ep->com.tdev, ep->atid);
 	dst_release(ep->dst);
@@ -1249,7 +1249,7 @@ static void reject_cr(struct t3cdev *tdev, u32 hwti=
d, __be32 peer_ip,
 	skb_trim(skb, sizeof(struct cpl_tid_release));
 	skb_get(skb);
=20
-	if (tdev->type =3D=3D T3B)
+	if (tdev->type !=3D T3A)
 		release_tid(tdev, hwtid, skb);
 	else {
 		struct cpl_pass_accept_rpl *rpl;
diff --git a/drivers/infiniband/hw/cxgb3/iwch_provider.c b/drivers/infini=
band/hw/cxgb3/iwch_provider.c
index 69b1204..df1838f 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_provider.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_provider.c
@@ -646,7 +646,7 @@ static struct ib_mr *iwch_reg_user_mr(struct ib_pd *p=
d, u64 start, u64 length,
 	if (err)
 		goto err;
=20
-	if (udata && t3b_device(rhp)) {
+	if (udata && !t3a_device(rhp)) {
 		uresp.pbl_addr =3D (mhp->attr.pbl_addr -
 	                         rhp->rdev.rnic_info.pbl_base) >> 3;
 		PDBG("%s user resp pbl_addr 0x%x\n", __FUNCTION__,
