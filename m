From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH 01/51] DMA-API: provide a helper to set both
 DMA and coherent DMA masks
Date: Thu, 19 Sep 2013 22:25:58 +0100
Message-ID: <E1VMlja-0007fA-HU@rmk-PC.arm.linux.org.uk>
References: <20130919212235.GD12758@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Vinod Koul <vinod.koul@intel.com>, Dan Williams <dan.j.williams@intel.com>,
 Rob Landley <rob@landley.net>
To: alsa-devel@alsa-project.org, b43-dev@lists.infradead.org,
 devel@driverdev.osuosl.org, devicetree@vger.kernel.org,
 dri-devel@lists.freedesktop.org, e1000-devel@lists.sourceforge.net,
 linux-arm-kernel@lists.infradead.org, linux-crypto@vger.kernel.org,
 linux-doc@vger.kernel.org, linux-fbdev@vger.kernel.org,
 linux-ide@vger.kernel.org, linux-media@vger.kernel.org,
 linux-mmc@vger.kernel.org, linux-nvme@lists.infradead.org,
 linux-omap@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
 linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org,
 linux-tegra@vger.kernel.org, linux-usb@vger.kernel.org,
 linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
 Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
 uclinux-dist-devel@blackfin.uclinux.org
Return-path: <alsa-devel-bounces@alsa-project.org>
In-Reply-To: <20130919212235.GD12758@n2100.arm.linux.org.uk>
List-Unsubscribe: <http://mailman.alsa-project.org/mailman/options/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=unsubscribe>
List-Archive: <http://mailman.alsa-project.org/pipermail/alsa-devel/>
List-Post: <mailto:alsa-devel@alsa-project.org>
List-Help: <mailto:alsa-devel-request@alsa-project.org?subject=help>
List-Subscribe: <http://mailman.alsa-project.org/mailman/listinfo/alsa-devel>,
 <mailto:alsa-devel-request@alsa-project.org?subject=subscribe>
Errors-To: alsa-devel-bounces@alsa-project.org
Sender: alsa-devel-bounces@alsa-project.org
List-Id: netdev.vger.kernel.org

Provide a helper to set both the DMA and coherent DMA masks to the
same value - this avoids duplicated code in a number of drivers,
sometimes with buggy error handling, and also allows us identify
which drivers do things differently.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 Documentation/DMA-API-HOWTO.txt |   37 ++++++++++++++++++++++---------------
 Documentation/DMA-API.txt       |    8 ++++++++
 include/linux/dma-mapping.h     |   14 ++++++++++++++
 3 files changed, 44 insertions(+), 15 deletions(-)

diff --git a/Documentation/DMA-API-HOWTO.txt b/Documentation/DMA-API-HOWTO.txt
index 14129f1..5e98303 100644
--- a/Documentation/DMA-API-HOWTO.txt
+++ b/Documentation/DMA-API-HOWTO.txt
@@ -101,14 +101,23 @@ style to do this even if your device holds the default setting,
 because this shows that you did think about these issues wrt. your
 device.
 
-The query is performed via a call to dma_set_mask():
+The query is performed via a call to dma_set_mask_and_coherent():
 
-	int dma_set_mask(struct device *dev, u64 mask);
+	int dma_set_mask_and_coherent(struct device *dev, u64 mask);
 
-The query for consistent allocations is performed via a call to
-dma_set_coherent_mask():
+which will query the mask for both streaming and coherent APIs together.
+If you have some special requirements, then the following two separate
+queries can be used instead:
 
-	int dma_set_coherent_mask(struct device *dev, u64 mask);
+	The query for streaming mappings is performed via a call to
+	dma_set_mask():
+
+		int dma_set_mask(struct device *dev, u64 mask);
+
+	The query for consistent allocations is performed via a call
+	to dma_set_coherent_mask():
+
+		int dma_set_coherent_mask(struct device *dev, u64 mask);
 
 Here, dev is a pointer to the device struct of your device, and mask
 is a bit mask describing which bits of an address your device
@@ -137,7 +146,7 @@ exactly why.
 
 The standard 32-bit addressing device would do something like this:
 
-	if (dma_set_mask(dev, DMA_BIT_MASK(32))) {
+	if (dma_set_mask_and_coherent(dev, DMA_BIT_MASK(32))) {
 		printk(KERN_WARNING
 		       "mydev: No suitable DMA available.\n");
 		goto ignore_this_device;
@@ -171,22 +180,20 @@ If a card is capable of using 64-bit consistent allocations as well,
 
 	int using_dac, consistent_using_dac;
 
-	if (!dma_set_mask(dev, DMA_BIT_MASK(64))) {
+	if (!dma_set_mask_and_coherent(dev, DMA_BIT_MASK(64))) {
 		using_dac = 1;
 	   	consistent_using_dac = 1;
-		dma_set_coherent_mask(dev, DMA_BIT_MASK(64));
-	} else if (!dma_set_mask(dev, DMA_BIT_MASK(32))) {
+	} else if (!dma_set_mask_and_coherent(dev, DMA_BIT_MASK(32))) {
 		using_dac = 0;
 		consistent_using_dac = 0;
-		dma_set_coherent_mask(dev, DMA_BIT_MASK(32));
 	} else {
 		printk(KERN_WARNING
 		       "mydev: No suitable DMA available.\n");
 		goto ignore_this_device;
 	}
 
-dma_set_coherent_mask() will always be able to set the same or a
-smaller mask as dma_set_mask(). However for the rare case that a
+The coherent coherent mask will always be able to set the same or a
+smaller mask as the streaming mask. However for the rare case that a
 device driver only uses consistent allocations, one would have to
 check the return value from dma_set_coherent_mask().
 
@@ -199,9 +206,9 @@ Finally, if your device can only drive the low 24-bits of
 		goto ignore_this_device;
 	}
 
-When dma_set_mask() is successful, and returns zero, the kernel saves
-away this mask you have provided.  The kernel will use this
-information later when you make DMA mappings.
+When dma_set_mask() or dma_set_mask_and_coherent() is successful, and
+returns zero, the kernel saves away this mask you have provided.  The
+kernel will use this information later when you make DMA mappings.
 
 There is a case which we are aware of at this time, which is worth
 mentioning in this documentation.  If your device supports multiple
diff --git a/Documentation/DMA-API.txt b/Documentation/DMA-API.txt
index 78a6c56..e865279 100644
--- a/Documentation/DMA-API.txt
+++ b/Documentation/DMA-API.txt
@@ -142,6 +142,14 @@ internal API for use by the platform than an external API for use by
 driver writers.
 
 int
+dma_set_mask_and_coherent(struct device *dev, u64 mask)
+
+Checks to see if the mask is possible and updates the device
+streaming and coherent DMA mask parameters if it is.
+
+Returns: 0 if successful and a negative error if not.
+
+int
 dma_set_mask(struct device *dev, u64 mask)
 
 Checks to see if the mask is possible and updates the device
diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 3a8d0a2..ec951f9 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -97,6 +97,20 @@ static inline int dma_set_coherent_mask(struct device *dev, u64 mask)
 }
 #endif
 
+/*
+ * Set both the DMA mask and the coherent DMA mask to the same thing.
+ * Note that we don't check the return value from dma_set_coherent_mask()
+ * as the DMA API guarantees that the coherent DMA mask can be set to
+ * the same or smaller than the streaming DMA mask.
+ */
+static inline int dma_set_mask_and_coherent(struct device *dev, u64 mask)
+{
+	int rc = dma_set_mask(dev, mask);
+	if (rc == 0)
+		dma_set_coherent_mask(dev, mask);
+	return rc;
+}
+
 extern u64 dma_get_required_mask(struct device *dev);
 
 static inline unsigned int dma_get_max_seg_size(struct device *dev)
-- 
1.7.4.4
