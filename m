From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH 32/34] niu: Use pci_enable_msix_range()
Date: Fri, 31 Jan 2014 16:08:51 +0100
Message-ID: <b00085e1236e43e7a7531ce136064062ed88ea74.1391172839.git.agordeev@redhat.com>
References: <cover.1391172839.git.agordeev@redhat.com>
Cc: Alexander Gordeev <agordeev@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jingoo Han <jg1.han@samsung.com>, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <cover.1391172839.git.agordeev@redhat.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As result of deprecation of MSI-X/MSI enablement functions
pci_enable_msix() and pci_enable_msi_block() all drivers
using these two interfaces need to be updated to use the
new pci_enable_msi_range() and pci_enable_msix_range()
interfaces.

Signed-off-by: Alexander Gordeev <agordeev@redhat.com>
---
 drivers/net/ethernet/sun/niu.c |   11 +++--------
 1 files changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 8e2266e..79606f4 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -9041,7 +9041,7 @@ static void niu_try_msix(struct niu *np, u8 *ldg_num_map)
 	struct msix_entry msi_vec[NIU_NUM_LDG];
 	struct niu_parent *parent = np->parent;
 	struct pci_dev *pdev = np->pdev;
-	int i, num_irqs, err;
+	int i, num_irqs;
 	u8 first_ldg;
 
 	first_ldg = (NIU_NUM_LDG / parent->num_ports) * np->port;
@@ -9053,21 +9053,16 @@ static void niu_try_msix(struct niu *np, u8 *ldg_num_map)
 		    (np->port == 0 ? 3 : 1));
 	BUG_ON(num_irqs > (NIU_NUM_LDG / parent->num_ports));
 
-retry:
 	for (i = 0; i < num_irqs; i++) {
 		msi_vec[i].vector = 0;
 		msi_vec[i].entry = i;
 	}
 
-	err = pci_enable_msix(pdev, msi_vec, num_irqs);
-	if (err < 0) {
+	num_irqs = pci_enable_msix_range(pdev, msi_vec, 1, num_irqs);
+	if (num_irqs < 0) {
 		np->flags &= ~NIU_FLAGS_MSIX;
 		return;
 	}
-	if (err > 0) {
-		num_irqs = err;
-		goto retry;
-	}
 
 	np->flags |= NIU_FLAGS_MSIX;
 	for (i = 0; i < num_irqs; i++)
-- 
1.7.7.6
