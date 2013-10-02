From: Alexander Gordeev <agordeev@redhat.com>
Subject: [PATCH RFC 09/77] ahci: Update MSI/MSI-X interrupts enablement code
Date: Wed,  2 Oct 2013 12:48:25 +0200
Message-ID: <4cced33c3809e6a53ada2dd8c781fcc5242e19ab.1380703262.git.agordeev@redhat.com>
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
 drivers/ata/ahci.c |   56 ++++++++++++++++++++++++++++++++-------------------
 1 files changed, 35 insertions(+), 21 deletions(-)

diff --git a/drivers/ata/ahci.c b/drivers/ata/ahci.c
index 9d715ae..f1c8838 100644
--- a/drivers/ata/ahci.c
+++ b/drivers/ata/ahci.c
@@ -1091,26 +1091,40 @@ static inline void ahci_gtf_filter_workaround(struct ata_host *host)
 {}
 #endif
 
-int ahci_init_interrupts(struct pci_dev *pdev, struct ahci_host_priv *hpriv)
+int ahci_init_interrupts(struct pci_dev *pdev, unsigned int n_ports,
+			 struct ahci_host_priv *hpriv)
 {
-	int rc;
-	unsigned int maxvec;
+	int rc, nvec;
 
-	if (!(hpriv->flags & AHCI_HFLAG_NO_MSI)) {
-		rc = pci_enable_msi_block_auto(pdev, &maxvec);
-		if (rc > 0) {
-			if ((rc == maxvec) || (rc == 1))
-				return rc;
-			/*
-			 * Assume that advantage of multipe MSIs is negated,
-			 * so fallback to single MSI mode to save resources
-			 */
-			pci_disable_msi(pdev);
-			if (!pci_enable_msi(pdev))
-				return 1;
-		}
-	}
+	if (hpriv->flags & AHCI_HFLAG_NO_MSI)
+		goto intx;
+
+	rc = pci_get_msi_cap(pdev);
+	if (rc < 0)
+		goto intx;
+
+	/*
+	 * If number of MSIs is less than number of ports then Sharing Last
+	 * Message mode could be enforced. In this case assume that advantage
+	 * of multipe MSIs is negated and use single MSI mode instead.
+	 */
+	if (rc < n_ports)
+		goto single_msi;
+
+	nvec = rc;
+	rc = pci_enable_msi_block(pdev, nvec);
+	if (rc)
+		goto intx;
 
+	return nvec;
+
+single_msi:
+	rc = pci_enable_msi(pdev);
+	if (rc)
+		goto intx;
+	return 1;
+
+intx:
 	pci_intx(pdev, 1);
 	return 0;
 }
@@ -1277,10 +1291,6 @@ static int ahci_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	hpriv->mmio = pcim_iomap_table(pdev)[ahci_pci_bar];
 
-	n_msis = ahci_init_interrupts(pdev, hpriv);
-	if (n_msis > 1)
-		hpriv->flags |= AHCI_HFLAG_MULTI_MSI;
-
 	/* save initial config */
 	ahci_pci_save_initial_config(pdev, hpriv);
 
@@ -1335,6 +1345,10 @@ static int ahci_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 */
 	n_ports = max(ahci_nr_ports(hpriv->cap), fls(hpriv->port_map));
 
+	n_msis = ahci_init_interrupts(pdev, n_ports, hpriv);
+	if (n_msis > 1)
+		hpriv->flags |= AHCI_HFLAG_MULTI_MSI;
+
 	host = ata_host_alloc_pinfo(&pdev->dev, ppi, n_ports);
 	if (!host)
 		return -ENOMEM;
-- 
1.7.7.6
