From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [ofa-general] [PATCH 1/9] mlx4_en: Memory leak on completion queue
	free
Date: Mon, 22 Dec 2008 12:00:04 +0200
Message-ID: <494F6524.1030301@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rdreier@cisco.com, general@lists.openfabrics.org
To: jeff@garzik.org
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

If port is being destroyed without being activated before,
CQ resources are not freed.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/en_cq.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mlx4/en_cq.c b/drivers/net/mlx4/en_cq.c
index ae2f989..4aa3b0f 100644
--- a/drivers/net/mlx4/en_cq.c
+++ b/drivers/net/mlx4/en_cq.c
@@ -71,6 +71,8 @@ int mlx4_en_create_cq(struct mlx4_en_priv *priv,
 	err = mlx4_en_map_buffer(&cq->wqres.buf);
 	if (err)
 		mlx4_free_hwq_res(mdev->dev, &cq->wqres, cq->buf_size);
+	else
+		cq->buf = (struct mlx4_cqe *) cq->wqres.buf.direct.buf;

 	return err;
 }
@@ -85,7 +87,6 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq)
 	cq->mcq.arm_db     = cq->wqres.db.db + 1;
 	*cq->mcq.set_ci_db = 0;
 	*cq->mcq.arm_db    = 0;
-	cq->buf = (struct mlx4_cqe *) cq->wqres.buf.direct.buf;
 	memset(cq->buf, 0, cq->buf_size);

 	err = mlx4_cq_alloc(mdev->dev, cq->size, &cq->wqres.mtt, &mdev->priv_uar,
-- 
1.5.4
