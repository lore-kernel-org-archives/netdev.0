From: Dave Jiang <dave.jiang@intel.com>
Subject: [PATCH 2/3] ioatdma: DMA copy alignment needed to address IOAT DMA
 silicon errata
Date: Wed, 04 Apr 2012 16:10:41 -0700
Message-ID: <20120404231041.20605.16201.stgit@djiang5-linux.ch.intel.com>
References: <20120404230749.20605.7000.stgit@djiang5-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Dave Jiang <dave.jiang@intel.com>
To: dan.j.williams@intel.com, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120404230749.20605.7000.stgit@djiang5-linux.ch.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Silicon errata where when RAID and legacy descriptors are mixed, the legacy
(memcpy and friends) operation must have alignment of 64 bytes to avoid
hanging. This effects Intel Xeon C55xx, C35xx, E5-2600.

Signed-off-by: Dave Jiang <dave.jiang@intel.com>
---

 drivers/dma/ioat/dma_v3.c |   41 +++++++++++++++++++++++++++++++++++++++++
 1 files changed, 41 insertions(+), 0 deletions(-)

diff --git a/drivers/dma/ioat/dma_v3.c b/drivers/dma/ioat/dma_v3.c
index 2dbf32b..c5cc3ba 100644
--- a/drivers/dma/ioat/dma_v3.c
+++ b/drivers/dma/ioat/dma_v3.c
@@ -1147,6 +1147,44 @@ static int ioat3_reset_hw(struct ioat_chan_common *chan)
 	return ioat2_reset_sync(chan, msecs_to_jiffies(200));
 }
 
+static bool is_jf_ioat(struct pci_dev *pdev)
+{
+	switch (pdev->device) {
+		case PCI_DEVICE_ID_INTEL_IOAT_JSF0:
+		case PCI_DEVICE_ID_INTEL_IOAT_JSF1:
+		case PCI_DEVICE_ID_INTEL_IOAT_JSF2:
+		case PCI_DEVICE_ID_INTEL_IOAT_JSF3:
+		case PCI_DEVICE_ID_INTEL_IOAT_JSF4:
+		case PCI_DEVICE_ID_INTEL_IOAT_JSF5:
+		case PCI_DEVICE_ID_INTEL_IOAT_JSF6:
+		case PCI_DEVICE_ID_INTEL_IOAT_JSF7:
+		case PCI_DEVICE_ID_INTEL_IOAT_JSF8:
+		case PCI_DEVICE_ID_INTEL_IOAT_JSF9:
+			return true;
+		default:
+			return false;
+	}
+}
+
+static bool is_snb_ioat(struct pci_dev *pdev)
+{
+	switch (pdev->device) {
+		case PCI_DEVICE_ID_INTEL_IOAT_SNB0:
+		case PCI_DEVICE_ID_INTEL_IOAT_SNB1:
+		case PCI_DEVICE_ID_INTEL_IOAT_SNB2:
+		case PCI_DEVICE_ID_INTEL_IOAT_SNB3:
+		case PCI_DEVICE_ID_INTEL_IOAT_SNB4:
+		case PCI_DEVICE_ID_INTEL_IOAT_SNB5:
+		case PCI_DEVICE_ID_INTEL_IOAT_SNB6:
+		case PCI_DEVICE_ID_INTEL_IOAT_SNB7:
+		case PCI_DEVICE_ID_INTEL_IOAT_SNB8:
+		case PCI_DEVICE_ID_INTEL_IOAT_SNB9:
+			return true;
+		default:
+			return false;
+	}
+}
+
 int __devinit ioat3_dma_probe(struct ioatdma_device *device, int dca)
 {
 	struct pci_dev *pdev = device->pdev;
@@ -1167,6 +1205,9 @@ int __devinit ioat3_dma_probe(struct ioatdma_device *device, int dca)
 	dma->device_alloc_chan_resources = ioat2_alloc_chan_resources;
 	dma->device_free_chan_resources = ioat2_free_chan_resources;
 
+	if (is_jf_ioat(pdev) || is_snb_ioat(pdev))
+		dma->copy_align = 6;
+
 	dma_cap_set(DMA_INTERRUPT, dma->cap_mask);
 	dma->device_prep_dma_interrupt = ioat3_prep_interrupt_lock;
 
