From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 4/5] drivers/net/ethernet/mellanox/mlx4/mcg.c: fix error return code
Date: Tue, 14 Aug 2012 14:58:34 +0200
Message-ID: <1344949115-13266-5-git-send-email-Julia.Lawall@lip6.fr>
References: <1344949115-13266-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344949115-13266-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Convert a 0 error return code to a negative one, as returned elsewhere in the
function.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
identifier ret;
expression e,e1,e2,e3,e4,x;
@@

(
if (\(ret != 0\|ret < 0\) || ...) { ... return ...; }
|
ret = 0
)
... when != ret = e1
*x = \(kmalloc\|kzalloc\|kcalloc\|devm_kzalloc\|ioremap\|ioremap_nocache\|devm_ioremap\|devm_ioremap_nocache\)(...);
... when != x = e2
    when != ret = e3
*if (x == NULL || ...)
{
  ... when != ret = e4
*  return ret;
}
// </smpl>

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
 drivers/net/ethernet/mellanox/mlx4/mcg.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mcg.c b/drivers/net/ethernet/mellanox/mlx4/mcg.c
index 4ec3835..a018ea2 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mcg.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mcg.c
@@ -432,8 +432,10 @@ static int add_promisc_qp(struct mlx4_dev *dev, u8 port,
 			if ((be32_to_cpu(mgm->qp[i]) & MGM_QPN_MASK) == qpn) {
 				/* Entry already exists, add to duplicates */
 				dqp = kmalloc(sizeof *dqp, GFP_KERNEL);
-				if (!dqp)
+				if (!dqp) {
+					err = -ENOMEM;
 					goto out_mailbox;
+				}
 				dqp->qpn = qpn;
 				list_add_tail(&dqp->list, &entry->duplicates);
 				found = true;
