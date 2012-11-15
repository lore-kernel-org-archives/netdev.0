From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 1/9] ioat: Do not enable DCA if tag map is invalid
Date: Thu, 15 Nov 2012 06:39:39 -0800
Message-ID: <1352990387-3872-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1352990387-3872-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:53540 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2993465Ab2KOOjw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2012 09:39:52 -0500
In-Reply-To: <1352990387-3872-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

I have encountered several systems that have an invalid tag map.  This
invalid tag map results in only two tags being generated 0x1F which is
usually applied to the first core in a Hyper-threaded pair and 0x00 which
is applied to the second core in a Hyper-threaded pair.  The net result of
all this is that DCA causes significant cache thrash because the 0x1F tag
will send traffic to the second socket, which the 0x00 tag will not DCA tag
the frame resulting in no benefit.

For now the best solution from the driver's perspective is to just disable
DCA if the tag map is invalid.  The correct solution for this would be to
have the BIOS on affected systems updated so that the correct tags are
generated for a given APIC ID.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Stephen Ko <stephen.s.ko@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/dma/ioat/dca.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/drivers/dma/ioat/dca.c b/drivers/dma/ioat/dca.c
index abd9038..d666807 100644
--- a/drivers/dma/ioat/dca.c
+++ b/drivers/dma/ioat/dca.c
@@ -604,6 +604,23 @@ static int ioat3_dca_count_dca_slots(void *iobase, u16 dca_offset)
 	return slots;
 }
 
+static inline int dca3_tag_map_invalid(u8 *tag_map)
+{
+	/*
+	 * If the tag map is not programmed by the BIOS the default is:
+	 * 0x80 0x80 0x80 0x80 0x80 0x00 0x00 0x00
+	 *
+	 * This an invalid map and will result in only 2 possible tags
+	 * 0x1F and 0x00.  0x00 is an invalid DCA tag so we know that
+	 * this entire definition is invalid.
+	 */
+	return ((tag_map[0] == DCA_TAG_MAP_VALID) &&
+		(tag_map[1] == DCA_TAG_MAP_VALID) &&
+		(tag_map[2] == DCA_TAG_MAP_VALID) &&
+		(tag_map[3] == DCA_TAG_MAP_VALID) &&
+		(tag_map[4] == DCA_TAG_MAP_VALID));
+}
+
 struct dca_provider * __devinit
 ioat3_dca_init(struct pci_dev *pdev, void __iomem *iobase)
 {
@@ -674,6 +691,12 @@ ioat3_dca_init(struct pci_dev *pdev, void __iomem *iobase)
 		ioatdca->tag_map[i] = bit & DCA_TAG_MAP_MASK;
 	}
 
+	if (dca3_tag_map_invalid(ioatdca->tag_map)) {
+		dev_err(&pdev->dev, "APICID_TAG_MAP set incorrectly by BIOS, disabling DCA\n");
+		free_dca_provider(dca);
+		return NULL;
+	}
+
 	err = register_dca_provider(dca, &pdev->dev);
 	if (err) {
 		free_dca_provider(dca);
-- 
1.7.11.7
