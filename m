From: Chris Wright <chrisw@sous-sol.org>
Subject: Re: [PATCH 0/16] DMA-API debugging facility v2
Date: Thu, 5 Feb 2009 18:27:59 -0800
Message-ID: <20090206022759.GF27684@sequoia.sous-sol.org>
References: <1231517970-20288-1-git-send-email-joerg.roedel@amd.com> <1233874352.8135.12.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joerg Roedel <joerg.roedel@amd.com>, fujita.tomonori@lab.ntt.co.jp,
	netdev@vger.kernel.org, iommu@lists.linux-foundation.org,
	mingo@redhat.com, linux-kernel@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sous-sol.org ([216.99.217.87]:53246 "EHLO sequoia.sous-sol.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750885AbZBFC22 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Feb 2009 21:28:28 -0500
Content-Disposition: inline
In-Reply-To: <1233874352.8135.12.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* David Woodhouse (dwmw2@infradead.org) wrote:
> This adds a function to dump the DMA mappings that the debugging code is
> aware of -- either for a single device, or for _all_ devices.
> 
> This can be useful for debugging -- sticking a call to it in the DMA
> page fault handler, for example, to see if the faulting address _should_
> be mapped or not, and hence work out whether it's IOMMU bugs we're
> seeing, or driver bugs.

BTW, here's how I hooked it up:

diff --git a/drivers/pci/intel-iommu.c b/drivers/pci/intel-iommu.c
index c933980..df593d1 100644
--- a/drivers/pci/intel-iommu.c
+++ b/drivers/pci/intel-iommu.c
@@ -1072,6 +1072,34 @@ void dmar_msi_read(int irq, struct msi_msg *msg)
 	spin_unlock_irqrestore(&iommu->register_lock, flag);
 }
 
+static struct pci_dev *domain_find_pdev(u8 bus, u8 devfn)
+{
+	unsigned long flags;
+	struct pci_dev *pdev = NULL;
+	struct device_domain_info *info;
+
+	spin_lock_irqsave(&device_domain_lock, flags);
+	list_for_each_entry(info, &device_domain_list, global) {
+		if (info->bus == bus && info->devfn == devfn) {
+			pdev = info->dev;
+			break;
+		}
+	}
+	spin_unlock_irqrestore(&device_domain_lock, flags);
+	return pdev;
+}
+
+static void dump_mappings(u16 source_id)
+{
+	struct pci_dev *pdev;
+	u8 bus = source_id >> 8;
+	u8 devfn = source_id & 0xff;
+
+	pdev = domain_find_pdev(bus, devfn);
+	if (pdev)
+		debug_dma_dump_mappings(&pdev->dev);
+}
+
 static int iommu_page_fault_do_one(struct intel_iommu *iommu, int type,
 		u8 fault_reason, u16 source_id, unsigned long long addr)
 {
@@ -1086,6 +1114,8 @@ static int iommu_page_fault_do_one(struct intel_iommu *iommu, int type,
 		(type ? "DMA Read" : "DMA Write"),
 		(source_id >> 8), PCI_SLOT(source_id & 0xFF),
 		PCI_FUNC(source_id & 0xFF), addr, fault_reason, reason);
+
+	dump_mappings(source_id);
 	return 0;
 }
 
