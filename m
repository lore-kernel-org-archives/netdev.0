From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH 19/34] mlx5: Use pci_enable_msix_range()
Date: Fri, 31 Jan 2014 16:08:38 +0100
Message-ID: <bf395f4c5a111f0f3766ce4be08e72177e227412.1391172839.git.agordeev@redhat.com>
References: <cover.1391172839.git.agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev@redhat.com>,
	Eli Cohen <eli@mellanox.com>, linux-rdma@vger.kernel.org,
	netdev@vger.kernel.org, linux-pci@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1391172839.git.agordeev@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As result of deprecation of MSI-X/MSI enablement functions
pci_enable_msix() and pci_enable_msi_block() all drivers
using these two interfaces need to be updated to use the
new pci_enable_msi_range() and pci_enable_msix_range()
interfaces.

Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c |   16 +++++-----------
 1 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index a064f06..81df046 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -116,7 +116,6 @@ static int mlx5_enable_msix(struct mlx5_core_dev *dev)
 	struct mlx5_eq_table *table = &dev->priv.eq_table;
 	int num_eqs = 1 << dev->caps.log_max_eq;
 	int nvec;
-	int err;
 	int i;
 
 	nvec = dev->caps.num_ports * num_online_cpus() + MLX5_EQ_VEC_COMP_BASE;
@@ -131,17 +130,12 @@ static int mlx5_enable_msix(struct mlx5_core_dev *dev)
 	for (i = 0; i < nvec; i++)
 		table->msix_arr[i].entry = i;
 
-retry:
-	table->num_comp_vectors = nvec - MLX5_EQ_VEC_COMP_BASE;
-	err = pci_enable_msix(dev->pdev, table->msix_arr, nvec);
-	if (err <= 0) {
-		return err;
-	} else if (err > 2) {
-		nvec = err;
-		goto retry;
-	}
+	nvec = pci_enable_msix_range(dev->pdev, table->msix_arr,
+				     MLX5_EQ_VEC_COMP_BASE, nvec);
+	if (nvec < 0)
+		return nvec;
 
-	mlx5_core_dbg(dev, "received %d MSI vectors out of %d requested\n", err, nvec);
+	table->num_comp_vectors = nvec - MLX5_EQ_VEC_COMP_BASE;
 
 	return 0;
 }
-- 
1.7.7.6
