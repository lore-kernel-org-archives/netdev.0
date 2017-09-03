From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 16/17] net/mlx5e: Stop NAPI when irq balancer changes affinity
Date: Sun,  3 Sep 2017 07:21:16 +0300
Message-ID: <20170903042117.28923-17-saeedm@mellanox.com>
References: <20170903042117.28923-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:60120 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751482AbdICEWP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 00:22:15 -0400
In-Reply-To: <20170903042117.28923-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

NAPI context keeps rescheduling on same CPU as long as it's busy.
This doesn't give the oppurtunity for changes in irq affinities
to take effect.
Fix that by calling napi_complete_done() upon a change in affinity.
This would stop the NAPI and reschedule it on the new CPU.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  3 +++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  5 +++++
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c | 20 ++++++++++++++++++--
 3 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 7c046ae8b18e..1388a1e2f835 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -582,6 +582,9 @@ struct mlx5e_channel {
 	__be32                     mkey_be;
 	u8                         num_tc;
 
+	/* data path - accessed per napi poll */
+	struct irq_desc *irq_desc;
+
 	/* control */
 	struct mlx5e_priv         *priv;
 	struct mlx5_core_dev      *mdev;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index b2f689ec0d72..20f34131d4e5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1761,7 +1761,9 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 	struct net_device *netdev = priv->netdev;
 	int cpu = mlx5e_get_cpu(priv, ix);
 	struct mlx5e_channel *c;
+	unsigned int irq;
 	int err;
+	int eqn;
 
 	c = kzalloc_node(sizeof(*c), GFP_KERNEL, cpu_to_node(cpu));
 	if (!c)
@@ -1778,6 +1780,9 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 	c->num_tc   = params->num_tc;
 	c->xdp      = !!params->xdp_prog;
 
+	mlx5_vector2eqn(priv->mdev, ix, &eqn, &irq);
+	c->irq_desc = irq_to_desc(irq);
+
 	netif_napi_add(netdev, &c->napi, mlx5e_napi_poll, 64);
 
 	err = mlx5e_open_cq(c, icocq_moder, &cparam->icosq_cq, &c->icosq.cq);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
index 92d9aa1cddd6..e906b754415c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -30,8 +30,20 @@
  * SOFTWARE.
  */
 
+#include <linux/irq.h>
 #include "en.h"
 
+static inline bool mlx5e_channel_no_affinity_change(struct mlx5e_channel *c)
+{
+	int current_cpu = smp_processor_id();
+	const struct cpumask *aff;
+	struct irq_data *idata;
+
+	idata = irq_desc_get_irq_data(c->irq_desc);
+	aff = irq_data_get_affinity_mask(idata);
+	return cpumask_test_cpu(current_cpu, aff);
+}
+
 int mlx5e_napi_poll(struct napi_struct *napi, int budget)
 {
 	struct mlx5e_channel *c = container_of(napi, struct mlx5e_channel,
@@ -51,8 +63,12 @@ int mlx5e_napi_poll(struct napi_struct *napi, int budget)
 
 	busy |= c->rq.post_wqes(&c->rq);
 
-	if (busy)
-		return budget;
+	if (busy) {
+		if (likely(mlx5e_channel_no_affinity_change(c)))
+			return budget;
+		if (work_done == budget)
+			work_done--;
+	}
 
 	if (unlikely(!napi_complete_done(napi, work_done)))
 		return work_done;
-- 
2.13.0
