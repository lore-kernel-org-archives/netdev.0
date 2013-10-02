From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH RFC 50/77] mlx5: Update MSI/MSI-X interrupts enablement code
Date: Wed,  2 Oct 2013 12:49:06 +0200
Message-ID: <9650a7dfbcfd5f1da21f7b093665abf4b1041071.1380703263.git.agordeev@redhat.com>
References: <cover.1380703262.git.agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev@redhat.com>,
        Bjorn Helgaas <bhelgaas@google.com>,
        Ralf Baechle <ralf@linux-mips.org>,
        Michael Ellerman <michael@ellerman.id.au>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Ingo Molnar <mingo@redhat.com>, Tejun Heo <tj@kernel.org>,
        Dan Williams <dan.j.williams@intel.com>,
        Andy King <acking@vmware.com>, Jon Mason <jon.mason@intel.com>,
        Matt Porter <mporter@kernel.crashing.org>,
        linux-pci@vger.kernel.org, linux-mips@linux-mips.org,
        linuxppc-dev@lists.ozlabs.org, linux390@de.ibm.com,
        linux-s390@vger.kernel.org, x86@kernel.org,
        linux-ide@vger.kernel.org, iss_storagedev@hp.com,
        linux-nvme@lists.infradead.org, linux-rdma@vger.kernel.org,
        netdev@vger.kernel.org, e1000-devel@lists.sourceforge.ne
To: linux-kernel@vger.kernel.org
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <cover.1380703262.git.agordeev@redhat.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

As result of recent re-design of the MSI/MSI-X interrupts enabling
pattern this driver has to be updated to use the new technique to
obtain a optimal number of MSI/MSI-X interrupts required.

Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/main.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index adf0e5d..5c21e50 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -119,8 +119,13 @@ static int mlx5_enable_msix(struct mlx5_core_dev *dev)
 	int err;
 	int i;
 
+	err = pci_msix_table_size(dev->pdev);
+	if (err < 0)
+		return err;
+
 	nvec = dev->caps.num_ports * num_online_cpus() + MLX5_EQ_VEC_COMP_BASE;
 	nvec = min_t(int, nvec, num_eqs);
+	nvec = min_t(int, nvec, err);
 	if (nvec <= MLX5_EQ_VEC_COMP_BASE)
 		return -ENOSPC;
 
@@ -131,20 +136,15 @@ static int mlx5_enable_msix(struct mlx5_core_dev *dev)
 	for (i = 0; i < nvec; i++)
 		table->msix_arr[i].entry = i;
 
-retry:
-	table->num_comp_vectors = nvec - MLX5_EQ_VEC_COMP_BASE;
 	err = pci_enable_msix(dev->pdev, table->msix_arr, nvec);
-	if (err <= 0) {
+	if (err) {
+		kfree(table->msix_arr);
 		return err;
-	} else if (err > MLX5_EQ_VEC_COMP_BASE) {
-		nvec = err;
-		goto retry;
 	}
 
-	mlx5_core_dbg(dev, "received %d MSI vectors out of %d requested\n", err, nvec);
-	kfree(table->msix_arr);
+	table->num_comp_vectors = nvec - MLX5_EQ_VEC_COMP_BASE;
 
-	return -ENOSPC;
+	return 0;
 }
 
 static void mlx5_disable_msix(struct mlx5_core_dev *dev)
-- 
1.7.7.6
