From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [PATCH v1 21/47] ethernet: myri10ge: use arch_phys_wc_add()
Date: Fri, 20 Mar 2015 16:18:11 -0700
Message-ID: <1426893517-2511-22-git-send-email-mcgrof@do-not-panic.com>
References: <1426893517-2511-1-git-send-email-mcgrof@do-not-panic.com>
Cc: linux-kernel@vger.kernel.org, linux-fbdev@vger.kernel.org,
	x86@kernel.org, xen-devel@lists.xenproject.org,
	"Luis R. Rodriguez" <mcgrof@suse.com>, Ingo Molnar <mingo@elte.hu>,
	Daniel Vetter <daniel.vetter@ffwll.ch>,
	Hyong-Youb Kim <hykim@myri.com>, netdev@vger.kernel.org,
	Antonino Daplas <adaplas@gmail.com>,
	Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>,
	Tomi Valkeinen <tomi.valkeinen@ti.com>
To: luto@amacapital.net, mingo@redhat.com, tglx@linutronix.de,
	hpa@zytor.com, jgross@suse.com, JBeulich@suse.com, bp@suse.de,
	suresh.b.siddha@intel.com, venkatesh.pallipadi@intel.com,
	airlied@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426893517-2511-1-git-send-email-mcgrof@do-not-panic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof@suse.com>

This driver already uses ioremap_wc() on the same range
so when write-combining is available that will be used
instead.

Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Suresh Siddha <suresh.b.siddha@intel.com>
Cc: Venkatesh Pallipadi <venkatesh.pallipadi@intel.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Juergen Gross <jgross@suse.com>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Hyong-Youb Kim <hykim@myri.com>
Cc: netdev@vger.kernel.org
Cc: Juergen Gross <jgross@suse.com>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Dave Airlie <airlied@redhat.com>
Cc: Antonino Daplas <adaplas@gmail.com>
Cc: Jean-Christophe Plagniol-Villard <plagnioj@jcrosoft.com>
Cc: Tomi Valkeinen <tomi.valkeinen@ti.com>
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Luis R. Rodriguez <mcgrof@suse.com>
---
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c | 36 ++++++------------------
 1 file changed, 8 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 1412f5a..01e4069 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -69,11 +69,7 @@
 #include <net/ip.h>
 #include <net/tcp.h>
 #include <asm/byteorder.h>
-#include <asm/io.h>
 #include <asm/processor.h>
-#ifdef CONFIG_MTRR
-#include <asm/mtrr.h>
-#endif
 #include <net/busy_poll.h>
 
 #include "myri10ge_mcp.h"
@@ -242,8 +238,7 @@ struct myri10ge_priv {
 	unsigned int rdma_tags_available;
 	int intr_coal_delay;
 	__be32 __iomem *intr_coal_delay_ptr;
-	int mtrr;
-	int wc_enabled;
+	int wc_cookie;
 	int down_cnt;
 	wait_queue_head_t down_wq;
 	struct work_struct watchdog_work;
@@ -1984,7 +1979,6 @@ myri10ge_get_ethtool_stats(struct net_device *netdev,
 		data[i] = ((u64 *)&link_stats)[i];
 
 	data[i++] = (unsigned int)mgp->tx_boundary;
-	data[i++] = (unsigned int)mgp->wc_enabled;
 	data[i++] = (unsigned int)mgp->pdev->irq;
 	data[i++] = (unsigned int)mgp->msi_enabled;
 	data[i++] = (unsigned int)mgp->msix_enabled;
@@ -4040,14 +4034,7 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	mgp->board_span = pci_resource_len(pdev, 0);
 	mgp->iomem_base = pci_resource_start(pdev, 0);
-	mgp->mtrr = -1;
-	mgp->wc_enabled = 0;
-#ifdef CONFIG_MTRR
-	mgp->mtrr = mtrr_add(mgp->iomem_base, mgp->board_span,
-			     MTRR_TYPE_WRCOMB, 1);
-	if (mgp->mtrr >= 0)
-		mgp->wc_enabled = 1;
-#endif
+	mgp->wc_cookie = arch_phys_wc_add(mgp->iomem_base, mgp->board_span);
 	mgp->sram = ioremap_wc(mgp->iomem_base, mgp->board_span);
 	if (mgp->sram == NULL) {
 		dev_err(&pdev->dev, "ioremap failed for %ld bytes at 0x%lx\n",
@@ -4146,14 +4133,14 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto abort_with_state;
 	}
 	if (mgp->msix_enabled)
-		dev_info(dev, "%d MSI-X IRQs, tx bndry %d, fw %s, WC %s\n",
+		dev_info(dev, "%d MSI-X IRQs, tx bndry %d, fw %s, MTRR %s, WC Enabled\n",
 			 mgp->num_slices, mgp->tx_boundary, mgp->fw_name,
-			 (mgp->wc_enabled ? "Enabled" : "Disabled"));
+			 (mgp->wc_cookie > 0 ? "Enabled" : "Disabled"));
 	else
-		dev_info(dev, "%s IRQ %d, tx bndry %d, fw %s, WC %s\n",
+		dev_info(dev, "%s IRQ %d, tx bndry %d, fw %s, MTRR %s, WC Enabled\n",
 			 mgp->msi_enabled ? "MSI" : "xPIC",
 			 pdev->irq, mgp->tx_boundary, mgp->fw_name,
-			 (mgp->wc_enabled ? "Enabled" : "Disabled"));
+			 (mgp->wc_cookie > 0 ? "Enabled" : "Disabled"));
 
 	board_number++;
 	return 0;
@@ -4175,10 +4162,7 @@ abort_with_ioremap:
 	iounmap(mgp->sram);
 
 abort_with_mtrr:
-#ifdef CONFIG_MTRR
-	if (mgp->mtrr >= 0)
-		mtrr_del(mgp->mtrr, mgp->iomem_base, mgp->board_span);
-#endif
+	arch_phys_wc_del(mgp->wc_cookie);
 	dma_free_coherent(&pdev->dev, sizeof(*mgp->cmd),
 			  mgp->cmd, mgp->cmd_bus);
 
@@ -4220,11 +4204,7 @@ static void myri10ge_remove(struct pci_dev *pdev)
 	pci_restore_state(pdev);
 
 	iounmap(mgp->sram);
-
-#ifdef CONFIG_MTRR
-	if (mgp->mtrr >= 0)
-		mtrr_del(mgp->mtrr, mgp->iomem_base, mgp->board_span);
-#endif
+	arch_phys_wc_del(mgp->wc_cookie);
 	myri10ge_free_slices(mgp);
 	kfree(mgp->msix_vectors);
 	dma_free_coherent(&pdev->dev, sizeof(*mgp->cmd),
-- 
2.3.2.209.gd67f9d5.dirty
