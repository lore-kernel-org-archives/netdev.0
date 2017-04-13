From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Subject: [PATCH 2/7] PCI: call pcie_flr from reset_intel_82599_sfp_virtfn
Date: Thu, 13 Apr 2017 16:53:34 +0200
Message-ID: <20170413145339.20186-3-hch@lst.de>
References: <20170413145339.20186-1-hch@lst.de>
Cc: linux-pci-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, qat-linux-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bjorn Helgaas <bhelgaas-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Giovanni Cabiddu <giovanni.cabiddu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Salvatore Benedetto <salvatore.benedetto-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Mike Marciniszyn <mike.marciniszyn-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Derek Chickles <derek.chickles-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
        Satanand Burla <satananda.burla-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
        Felix Manlunas <felix.manlunas-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
        Raghu Vatsavayi <raghu.vatsavayi-M3mlKVOIwJVv6pq1l3V1OdBPR1lH4CV8@public.gmane.org>,
        Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170413145339.20186-1-hch-jcswGhMUV9g@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The 82599 quirk contained an outdated copy of the FLR code.

Signed-off-by: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
---
 drivers/pci/quirks.c | 16 ++++------------
 1 file changed, 4 insertions(+), 12 deletions(-)

diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index 673683660b5c..b1775354cc69 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -3642,19 +3642,11 @@ static int reset_intel_82599_sfp_virtfn(struct pci_dev *dev, int probe)
 	 *
 	 * The 82599 supports FLR on VFs, but FLR support is reported only
 	 * in the PF DEVCAP (sec 9.3.10.4), not in the VF DEVCAP (sec 9.5).
-	 * Therefore, we can't use pcie_flr(), which checks the VF DEVCAP.
+	 * Thus we must call pcie_flr directly without first checking if it is
+	 * supported.
 	 */
-
-	if (probe)
-		return 0;
-
-	if (!pci_wait_for_pending_transaction(dev))
-		dev_err(&dev->dev, "transaction is not cleared; proceeding with reset anyway\n");
-
-	pcie_capability_set_word(dev, PCI_EXP_DEVCTL, PCI_EXP_DEVCTL_BCR_FLR);
-
-	msleep(100);
-
+	if (!probe)
+		pcie_flr(dev);
 	return 0;
 }
 
-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
