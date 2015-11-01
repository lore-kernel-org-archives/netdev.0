From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 4/8] net/mlx5e: Consider IRQ affinity changes in NAPI poll
Date: Sun,  1 Nov 2015 19:35:18 +0200
Message-ID: <1446399322-14046-5-git-send-email-ogerlitz@mellanox.com>
References: <1446399322-14046-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:56259 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752697AbbKARfq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Nov 2015 12:35:46 -0500
In-Reply-To: <1446399322-14046-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

Under heavy network traffic load we may be in NAPI poll mode for
a long time, thus IRQ affinity changes do not affect NAPI as desired.

Now once in a NAPI poll session we check the channel IRQ affinity,
if it points to a different CPU core than the current, stop polling
and the following device interrupt will fix the NAPI affinity.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  3 +++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c | 12 +++++++++++-
 3 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 0983a20..3c5c900 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -406,6 +406,9 @@ struct mlx5e_channel {
 	u8                         num_tc;
 	unsigned long              flags;
 
+	/* data path - accessed per napi poll */
+	struct irq_desc           *irq_desc;
+
 	/* control */
 	struct mlx5e_priv         *priv;
 	int                        ix;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 0bab33c..bdbef9f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1004,6 +1004,7 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 		goto err_close_sqs;
 
 	netif_set_xps_queue(netdev, get_cpu_mask(c->cpu), ix);
+	c->irq_desc = irq_to_desc(c->rq.cq.mcq.irqn);
 	*cp = c;
 
 	return 0;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
index 2c7cb67..99e29c9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c
@@ -30,6 +30,7 @@
  * SOFTWARE.
  */
 
+#include <linux/irq.h>
 #include "en.h"
 
 struct mlx5_cqe64 *mlx5e_get_cqe(struct mlx5e_cq *cq)
@@ -49,6 +50,15 @@ struct mlx5_cqe64 *mlx5e_get_cqe(struct mlx5e_cq *cq)
 	return cqe;
 }
 
+static inline bool mlx5e_no_channel_affinity_change(struct mlx5e_channel *c)
+{
+	int current_cpu = smp_processor_id();
+	struct irq_data *d = irq_desc_get_irq_data(c->irq_desc);
+	struct cpumask *aff = irq_data_get_affinity_mask(d);
+
+	return cpumask_test_cpu(current_cpu, aff);
+}
+
 int mlx5e_napi_poll(struct napi_struct *napi, int budget)
 {
 	struct mlx5e_channel *c = container_of(napi, struct mlx5e_channel,
@@ -65,7 +75,7 @@ int mlx5e_napi_poll(struct napi_struct *napi, int budget)
 
 	busy |= mlx5e_post_rx_wqes(&c->rq);
 
-	if (busy)
+	if (busy && likely(mlx5e_no_channel_affinity_change(c)))
 		return budget;
 
 	napi_complete(napi);
-- 
2.3.7
