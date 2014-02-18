From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH net-next 18/35] mlx4: Use pci_enable_msix_range() instead of pci_enable_msix()
Date: Tue, 18 Feb 2014 11:11:47 +0100
Message-ID: <97d31ce7a0f6dd647f34975ef0c836ac1b470448.1392717503.git.agordeev@redhat.com>
References: <cover.1392717502.git.agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1392717502.git.agordeev@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As result of deprecation of MSI-X/MSI enablement functions
pci_enable_msix() and pci_enable_msi_block() all drivers
using these two interfaces need to be updated to use the
new pci_enable_msi_range() and pci_enable_msix_range()
interfaces.

Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Amir Vadai <amirv@mellanox.com>
Cc: netdev@vger.kernel.org
Cc: linux-pci@vger.kernel.org
Acked-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |   21 +++++----------------
 1 files changed, 5 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index d711158..218b759 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -1976,7 +1976,6 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 	int nreq = min_t(int, dev->caps.num_ports *
 			 min_t(int, netif_get_num_default_rss_queues() + 1,
 			       MAX_MSIX_P_PORT) + MSIX_LEGACY_SZ, MAX_MSIX);
-	int err;
 	int i;
 
 	if (msi_x) {
@@ -1990,23 +1989,13 @@ static void mlx4_enable_msi_x(struct mlx4_dev *dev)
 		for (i = 0; i < nreq; ++i)
 			entries[i].entry = i;
 
-	retry:
-		err = pci_enable_msix(dev->pdev, entries, nreq);
-		if (err) {
-			/* Try again if at least 2 vectors are available */
-			if (err > 1) {
-				mlx4_info(dev, "Requested %d vectors, "
-					  "but only %d MSI-X vectors available, "
-					  "trying again\n", nreq, err);
-				nreq = err;
-				goto retry;
-			}
+		nreq = pci_enable_msix_range(dev->pdev, entries, 2, nreq);
+
+		if (nreq < 0) {
 			kfree(entries);
 			goto no_msi;
-		}
-
-		if (nreq <
-		    MSIX_LEGACY_SZ + dev->caps.num_ports * MIN_MSIX_P_PORT) {
+		} else if (nreq < MSIX_LEGACY_SZ +
+				  dev->caps.num_ports * MIN_MSIX_P_PORT) {
 			/*Working in legacy mode , all EQ's shared*/
 			dev->caps.comp_pool           = 0;
 			dev->caps.num_comp_vectors = nreq - 1;
-- 
1.7.7.6
