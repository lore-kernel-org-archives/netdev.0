From: Jiang Liu <jiang.liu@linux.intel.com>
Subject: [Patch v3 30/36] net/mlx4: Cache irq_desc->affinity instead of irq_desc
Date: Mon,  1 Jun 2015 16:05:39 +0800
Message-ID: <1433145945-789-31-git-send-email-jiang.liu@linux.intel.com>
References: <1433145945-789-1-git-send-email-jiang.liu@linux.intel.com>
Cc: Jiang Liu <jiang.liu@linux.intel.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Tony Luck <tony.luck@intel.com>, x86@kernel.org,
	linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
	linux-acpi@vger.kernel.org, netdev@vger.kernel.org
To: Thomas Gleixner <tglx@linutronix.de>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Randy Dunlap <rdunlap@infradead.org>,
	Yinghai Lu <yinghai@kernel.org>,
	Borislav Petkov <bp@alien8.de>,
	Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eric Dumazet <edumazet@google.com>,
	Hadar Hen Zion <hadarh@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Matan Barak <matanb@mellanox.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <1433145945-789-1-git-send-email-jiang.liu@linux.intel.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The field 'affinity' in irq_desc won't change once the irq_desc data
structure is created. So cache irq_desc->affinity instead of irq_desc.
This also helps to hide struct irq_desc from device drivers.

Signed-off-by: Jiang Liu <jiang.liu@linux.intel.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_cq.c   |    6 +++---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c   |    5 +----
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |    2 +-
 3 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
index 22da4d0d0f05..a03a01625398 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
@@ -31,6 +31,7 @@
  *
  */
 
+#include <linux/irq.h>
 #include <linux/mlx4/cq.h>
 #include <linux/mlx4/qp.h>
 #include <linux/mlx4/cmd.h>
@@ -135,9 +136,8 @@ int mlx4_en_activate_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq *cq,
 				mdev->dev->caps.num_comp_vectors;
 		}
 
-		cq->irq_desc =
-			irq_to_desc(mlx4_eq_get_irq(mdev->dev,
-						    cq->vector));
+		cq->irq_affinity = irq_get_affinity_mask(
+					mlx4_eq_get_irq(mdev->dev, cq->vector));
 	} else {
 		/* For TX we use the same irq per
 		ring we assigned for the RX    */
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 2a77a6b19121..5675febf478e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -1044,14 +1044,11 @@ int mlx4_en_poll_rx_cq(struct napi_struct *napi, int budget)
 	/* If we used up all the quota - we're probably not done yet... */
 	if (done == budget) {
 		int cpu_curr;
-		const struct cpumask *aff;
 
 		INC_PERF_COUNTER(priv->pstats.napi_quota);
 
 		cpu_curr = smp_processor_id();
-		aff = irq_desc_get_irq_data(cq->irq_desc)->affinity;
-
-		if (likely(cpumask_test_cpu(cpu_curr, aff)))
+		if (likely(cpumask_test_cpu(cpu_curr, cq->irq_affinity)))
 			return budget;
 
 		/* Current cpu is not according to smp_irq_affinity -
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index d021f079f181..33d544a1fe84 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -357,7 +357,7 @@ struct mlx4_en_cq {
 #define CQ_USER_PEND (MLX4_EN_CQ_STATE_POLL | MLX4_EN_CQ_STATE_POLL_YIELD)
 	spinlock_t poll_lock; /* protects from LLS/napi conflicts */
 #endif  /* CONFIG_NET_RX_BUSY_POLL */
-	struct irq_desc *irq_desc;
+	struct cpumask	*irq_affinity;
 };
 
 struct mlx4_en_port_profile {
-- 
1.7.10.4

