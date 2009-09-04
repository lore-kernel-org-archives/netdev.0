From: Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH 16/29] ioat: ignore reserved bits for chancnt and xfercap
Date: Thu, 03 Sep 2009 19:31:51 -0700
Message-ID: <20090904023151.32667.13156.stgit@dwillia2-linux.ch.intel.com>
References: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-raid@vger.kernel.org, netdev@vger.kernel.org,
	Maciej Sosnowski <maciej.sosnowski@intel.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-raid-owner@vger.kernel.org>
In-Reply-To: <20090904022733.32667.77626.stgit@dwillia2-linux.ch.intel.com>
Sender: linux-raid-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't trust that the reserved bits are always zero, also sanity check
the returned value.

Signed-off-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 drivers/dma/ioat/dma.c    |    7 +++++++
 drivers/dma/ioat/dma_v2.c |    7 +++++++
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/dma/ioat/dma.c b/drivers/dma/ioat/dma.c
index 08417ad..5173ba9 100644
--- a/drivers/dma/ioat/dma.c
+++ b/drivers/dma/ioat/dma.c
@@ -132,7 +132,14 @@ static int ioat1_enumerate_channels(struct ioatdma_device *device)
 
 	INIT_LIST_HEAD(&dma->channels);
 	dma->chancnt = readb(device->reg_base + IOAT_CHANCNT_OFFSET);
+	dma->chancnt &= 0x1f; /* bits [4:0] valid */
+	if (dma->chancnt > ARRAY_SIZE(device->idx)) {
+		dev_warn(dev, "(%d) exceeds max supported channels (%zu)\n",
+			 dma->chancnt, ARRAY_SIZE(device->idx));
+		dma->chancnt = ARRAY_SIZE(device->idx);
+	}
 	xfercap_scale = readb(device->reg_base + IOAT_XFERCAP_OFFSET);
+	xfercap_scale &= 0x1f; /* bits [4:0] valid */
 	xfercap = (xfercap_scale == 0 ? -1 : (1UL << xfercap_scale));
 	dev_dbg(dev, "%s: xfercap = %d\n", __func__, xfercap);
 
diff --git a/drivers/dma/ioat/dma_v2.c b/drivers/dma/ioat/dma_v2.c
index 9bd3d14..589bbc3 100644
--- a/drivers/dma/ioat/dma_v2.c
+++ b/drivers/dma/ioat/dma_v2.c
@@ -360,7 +360,14 @@ static int ioat2_enumerate_channels(struct ioatdma_device *device)
 
 	INIT_LIST_HEAD(&dma->channels);
 	dma->chancnt = readb(device->reg_base + IOAT_CHANCNT_OFFSET);
+	dma->chancnt &= 0x1f; /* bits [4:0] valid */
+	if (dma->chancnt > ARRAY_SIZE(device->idx)) {
+		dev_warn(dev, "(%d) exceeds max supported channels (%zu)\n",
+			 dma->chancnt, ARRAY_SIZE(device->idx));
+		dma->chancnt = ARRAY_SIZE(device->idx);
+	}
 	xfercap_log = readb(device->reg_base + IOAT_XFERCAP_OFFSET);
+	xfercap_log &= 0x1f; /* bits [4:0] valid */
 	if (xfercap_log == 0)
 		return 0;
 	dev_dbg(dev, "%s: xfercap = %d\n", __func__, 1 << xfercap_log);

