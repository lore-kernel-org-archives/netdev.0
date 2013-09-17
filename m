From: Prarit Bhargava <prarit@redhat.com>
Subject: [PATCH 2/2] Re: net, mellanox mlx4 Fix compile warnings
Date: Tue, 17 Sep 2013 15:13:43 -0400
Message-ID: <1379445223-28550-1-git-send-email-prarit@redhat.com>
References: <20130916.212559.252825159014181091.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Prarit Bhargava <prarit@redhat.com>, dledford@redhat.com,
	amirv@mellanox.com, davem@davemloft.net, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52413 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753216Ab3IQTOG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Sep 2013 15:14:06 -0400
In-Reply-To: <20130916.212559.252825159014181091.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46ix unitialized variable warnings.

drivers/net/ethernet/mellanox/mlx4/resource_tracker.c: In function =E2=80=
=98mlx4_HW2SW_CQ_wrapper=E2=80=99:
drivers/net/ethernet/mellanox/mlx4/resource_tracker.c:2551:16: error: =E2=
=80=98cq=E2=80=99 may be used uninitialized in this function [-Werror=3D=
maybe-uninitialized]
  atomic_dec(&cq->mtt->ref_count);
                ^
drivers/net/ethernet/mellanox/mlx4/resource_tracker.c: In function =E2=80=
=98mlx4_HW2SW_SRQ_wrapper=E2=80=99:
drivers/net/ethernet/mellanox/mlx4/resource_tracker.c:2734:17: error: =E2=
=80=98srq=E2=80=99 may be used uninitialized in this function [-Werror=3D=
maybe-uninitialized]
  atomic_dec(&srq->mtt->ref_count);

[v2]: davem suggested making cq_res_start_move_to() return 'cq' as an e=
rror
pointer instead of setting 'cq' by reference.  I also did the same for
srq.

Signed-off-by: Prarit Bhargava <prarit@redhat.com>
Cc: dledford@redhat.com
Cc: amirv@mellanox.com
Cc: davem@davemloft.net
Cc: ogerlitz@mellanox.com
---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   46 ++++++++++--=
--------
 1 file changed, 24 insertions(+), 22 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c b/dr=
ivers/net/ethernet/mellanox/mlx4/resource_tracker.c
index dd68763..343206b 100644
--- a/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
+++ b/drivers/net/ethernet/mellanox/mlx4/resource_tracker.c
@@ -1073,8 +1073,9 @@ static int eq_res_start_move_to(struct mlx4_dev *=
dev, int slave, int index,
 	return err;
 }
=20
-static int cq_res_start_move_to(struct mlx4_dev *dev, int slave, int c=
qn,
-				enum res_cq_states state, struct res_cq **cq)
+static struct res_cq *cq_res_start_move_to(struct mlx4_dev *dev,
+						  int slave, int cqn,
+						  enum res_cq_states state)
 {
 	struct mlx4_priv *priv =3D mlx4_priv(dev);
 	struct mlx4_resource_tracker *tracker =3D &priv->mfunc.master.res_tra=
cker;
@@ -1117,18 +1118,19 @@ static int cq_res_start_move_to(struct mlx4_dev=
 *dev, int slave, int cqn,
 			r->com.from_state =3D r->com.state;
 			r->com.to_state =3D state;
 			r->com.state =3D RES_CQ_BUSY;
-			if (cq)
-				*cq =3D r;
+		} else {
+			r =3D ERR_PTR(err);
 		}
 	}
=20
 	spin_unlock_irq(mlx4_tlock(dev));
=20
-	return err;
+	return r;
 }
=20
-static int srq_res_start_move_to(struct mlx4_dev *dev, int slave, int =
index,
-				 enum res_cq_states state, struct res_srq **srq)
+static struct res_srq *srq_res_start_move_to(struct mlx4_dev *dev, int=
 slave,
+					     int index,
+					     enum res_cq_states state)
 {
 	struct mlx4_priv *priv =3D mlx4_priv(dev);
 	struct mlx4_resource_tracker *tracker =3D &priv->mfunc.master.res_tra=
cker;
@@ -1167,14 +1169,14 @@ static int srq_res_start_move_to(struct mlx4_de=
v *dev, int slave, int index,
 			r->com.from_state =3D r->com.state;
 			r->com.to_state =3D state;
 			r->com.state =3D RES_SRQ_BUSY;
-			if (srq)
-				*srq =3D r;
+		} else {
+			r =3D ERR_PTR(err);
 		}
 	}
=20
 	spin_unlock_irq(mlx4_tlock(dev));
=20
-	return err;
+	return r;
 }
=20
 static void res_abort_move(struct mlx4_dev *dev, int slave,
@@ -2530,9 +2532,9 @@ int mlx4_SW2HW_CQ_wrapper(struct mlx4_dev *dev, i=
nt slave,
 	struct res_cq *cq;
 	struct res_mtt *mtt;
=20
-	err =3D cq_res_start_move_to(dev, slave, cqn, RES_CQ_HW, &cq);
-	if (err)
-		return err;
+	cq =3D cq_res_start_move_to(dev, slave, cqn, RES_CQ_HW);
+	if (IS_ERR(cq))
+		return PTR_ERR(cq);
 	err =3D get_res(dev, slave, mtt_base, RES_MTT, &mtt);
 	if (err)
 		goto out_move;
@@ -2565,9 +2567,9 @@ int mlx4_HW2SW_CQ_wrapper(struct mlx4_dev *dev, i=
nt slave,
 	int cqn =3D vhcr->in_modifier;
 	struct res_cq *cq;
=20
-	err =3D cq_res_start_move_to(dev, slave, cqn, RES_CQ_ALLOCATED, &cq);
-	if (err)
-		return err;
+	cq =3D cq_res_start_move_to(dev, slave, cqn, RES_CQ_ALLOCATED);
+	if (IS_ERR(cq))
+		return PTR_ERR(cq);
 	err =3D mlx4_DMA_wrapper(dev, slave, vhcr, inbox, outbox, cmd);
 	if (err)
 		goto out_move;
@@ -2709,9 +2711,9 @@ int mlx4_SW2HW_SRQ_wrapper(struct mlx4_dev *dev, =
int slave,
 	if (srqn !=3D (be32_to_cpu(srqc->state_logsize_srqn) & 0xffffff))
 		return -EINVAL;
=20
-	err =3D srq_res_start_move_to(dev, slave, srqn, RES_SRQ_HW, &srq);
-	if (err)
-		return err;
+	srq =3D srq_res_start_move_to(dev, slave, srqn, RES_SRQ_ALLOCATED);
+	if (IS_ERR(srq))
+		return PTR_ERR(srq);
 	err =3D get_res(dev, slave, mtt_base, RES_MTT, &mtt);
 	if (err)
 		goto ex_abort;
@@ -2748,9 +2750,9 @@ int mlx4_HW2SW_SRQ_wrapper(struct mlx4_dev *dev, =
int slave,
 	int srqn =3D vhcr->in_modifier;
 	struct res_srq *srq;
=20
-	err =3D srq_res_start_move_to(dev, slave, srqn, RES_SRQ_ALLOCATED, &s=
rq);
-	if (err)
-		return err;
+	srq =3D srq_res_start_move_to(dev, slave, srqn, RES_SRQ_ALLOCATED);
+	if (IS_ERR(srq))
+		return PTR_ERR(srq);
 	err =3D mlx4_DMA_wrapper(dev, slave, vhcr, inbox, outbox, cmd);
 	if (err)
 		goto ex_abort;
--=20
1.7.9.3
