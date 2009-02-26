From: Maciej Sosnowski <maciej.sosnowski@intel.com>
Subject: [PATCH 1/7] I/OAT: add verification for proper APICID_TAG_MAP setting
	by BIOS
Date: Thu, 26 Feb 2009 11:04:23 +0100
Message-ID: <20090226100408.3615.48145.stgit@linux.site>
References: <20090226100327.3615.21419.stgit@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: snakebyte@gmx.de, shannon.nelson@intel.com,
	jeffrey.t.krisher@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: dan.j.williams@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:60479 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753870AbZBZKNF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 05:13:05 -0500
In-Reply-To: <20090226100327.3615.21419.stgit@linux.site>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BIOS versions for systems with I/OAT ver.2 have been found
which fail to program APICID_TAG_MAP for DCA.
The ioatdma driver should recognize incorrectly set APICID_TAG_MAP
and disable DCA in that case.

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Acked-by: Jeff Kirsher <jeffrey.t.krisher@intel.com>
---

 drivers/dma/ioat_dca.c |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/drivers/dma/ioat_dca.c b/drivers/dma/ioat_dca.c
index 6cf622d..78705ca 100644
--- a/drivers/dma/ioat_dca.c
+++ b/drivers/dma/ioat_dca.c
@@ -49,6 +49,23 @@ #define DCA3_TAG_MAP_LITERAL_VAL 0x1
 
 #define DCA_TAG_MAP_MASK 0xDF
 
+/* expected tag map bytes for I/OAT ver.2 */
+#define DCA2_TAG_MAP_BYTE0 0x80
+#define DCA2_TAG_MAP_BYTE1 0x0
+#define DCA2_TAG_MAP_BYTE2 0x81
+#define DCA2_TAG_MAP_BYTE3 0x82
+#define DCA2_TAG_MAP_BYTE4 0x82
+
+/* verify if tag map matches expected values */
+static inline int dca2_tag_map_valid(u8 *tag_map)
+{
+	return ((tag_map[0] == DCA2_TAG_MAP_BYTE0) &&
+		(tag_map[1] == DCA2_TAG_MAP_BYTE1) &&
+		(tag_map[2] == DCA2_TAG_MAP_BYTE2) &&
+		(tag_map[3] == DCA2_TAG_MAP_BYTE3) &&
+		(tag_map[4] == DCA2_TAG_MAP_BYTE4));
+}
+
 /*
  * "Legacy" DCA systems do not implement the DCA register set in the
  * I/OAT device.  Software needs direct support for their tag mappings.
@@ -452,6 +469,13 @@ struct dca_provider *ioat2_dca_init(stru
 			ioatdca->tag_map[i] = 0;
 	}
 
+	if (!dca2_tag_map_valid(ioatdca->tag_map)) {
+		dev_err(&pdev->dev, "APICID_TAG_MAP set incorrectly by BIOS, "
+			"disabling DCA\n");
+		free_dca_provider(dca);
+		return NULL;
+	}
+
 	err = register_dca_provider(dca, &pdev->dev);
 	if (err) {
 		free_dca_provider(dca);

