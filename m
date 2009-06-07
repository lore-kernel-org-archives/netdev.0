From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [ofa-general][PATCH] mlx4: FIX error flow when initializing EQ table
Date: Sun, 07 Jun 2009 18:16:09 +0300
Message-ID: <4A2BD9B9.6000802@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>,
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

If mlx4_create_eq() would fail for one of EQ's assigned for
completion handling, the code would try to free the same EQ
we failed to create.
The crash was found by Christoph Lameter

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/eq.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mlx4/eq.c b/drivers/net/mlx4/eq.c
index 8830dcb..dee1887 100644
--- a/drivers/net/mlx4/eq.c
+++ b/drivers/net/mlx4/eq.c
@@ -623,8 +623,10 @@ int mlx4_init_eq_table(struct mlx4_dev *dev)
 		err = mlx4_create_eq(dev, dev->caps.num_cqs + MLX4_NUM_SPARE_EQE,
 				     (dev->flags & MLX4_FLAG_MSI_X) ? i : 0,
 				     &priv->eq_table.eq[i]);
-		if (err)
+		if (err) {
+			--i;
 			goto err_out_unmap;
+		}
 	}
 
 	err = mlx4_create_eq(dev, MLX4_NUM_ASYNC_EQE + MLX4_NUM_SPARE_EQE,
-- 
1.6.1.3
