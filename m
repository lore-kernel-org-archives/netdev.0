From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH RFC 69/77] tg3: Update MSI/MSI-X interrupts enablement code
Date: Wed,  2 Oct 2013 12:49:25 +0200
Message-ID: <7439a70d0bb225702097714d92df2169ffd94dd6.1380703263.git.agordeev@redhat.com>
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
 drivers/net/ethernet/broadcom/tg3.c |   24 +++++++++++++-----------
 1 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 12d961c..2e842ef3 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -11241,6 +11241,10 @@ static bool tg3_enable_msix(struct tg3 *tp)
 	int i, rc;
 	struct msix_entry msix_ent[TG3_IRQ_MAX_VECS];
 
+	rc = pci_msix_table_size(tp->pdev);
+	if (rc < 0)
+		return false;
+
 	tp->txq_cnt = tp->txq_req;
 	tp->rxq_cnt = tp->rxq_req;
 	if (!tp->rxq_cnt)
@@ -11256,6 +11260,14 @@ static bool tg3_enable_msix(struct tg3 *tp)
 		tp->txq_cnt = 1;
 
 	tp->irq_cnt = tg3_irq_count(tp);
+	if (tp->irq_cnt > rc) {
+		netdev_notice(tp->dev, "Requested %d MSI-Xs, available %d\n",
+			      tp->irq_cnt, rc);
+		tp->irq_cnt = rc;
+		tp->rxq_cnt = max(rc - 1, 1);
+		if (tp->txq_cnt)
+			tp->txq_cnt = min(tp->rxq_cnt, tp->txq_max);
+	}
 
 	for (i = 0; i < tp->irq_max; i++) {
 		msix_ent[i].entry  = i;
@@ -11263,18 +11275,8 @@ static bool tg3_enable_msix(struct tg3 *tp)
 	}
 
 	rc = pci_enable_msix(tp->pdev, msix_ent, tp->irq_cnt);
-	if (rc < 0) {
+	if (rc)
 		return false;
-	} else if (rc != 0) {
-		if (pci_enable_msix(tp->pdev, msix_ent, rc))
-			return false;
-		netdev_notice(tp->dev, "Requested %d MSI-X vectors, received %d\n",
-			      tp->irq_cnt, rc);
-		tp->irq_cnt = rc;
-		tp->rxq_cnt = max(rc - 1, 1);
-		if (tp->txq_cnt)
-			tp->txq_cnt = min(tp->rxq_cnt, tp->txq_max);
-	}
 
 	for (i = 0; i < tp->irq_max; i++)
 		tp->napi[i].irq_vec = msix_ent[i].vector;
-- 
1.7.7.6
