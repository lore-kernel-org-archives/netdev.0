From: Max Filippov <jcmvbkbc@gmail.com>
Subject: [PATCH v2] net/ethoc: support big-endian register layout
Date: Wed, 23 Sep 2015 09:35:44 +0300
Message-ID: <1442990144-13499-1-git-send-email-jcmvbkbc@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, Max Filippov <jcmvbkbc@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This allows using OpenCores ethernet controller attached to its host in
native-endian mode with bi-endian CPUs. Example of such system is Xtensa
XTFPGA platform.

Signed-off-by: Max Filippov <jcmvbkbc@gmail.com>
---
Changes v1->v2:
- expand changelog with motivation for the change.

 drivers/net/ethernet/ethoc.c | 14 ++++++++++++--
 include/net/ethoc.h          |  1 +
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 442410c..17ff9a4 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -201,6 +201,7 @@ struct ethoc {
 	void __iomem *membase;
 	int dma_alloc;
 	resource_size_t io_region_size;
+	bool big_endian;
 
 	unsigned int num_bd;
 	unsigned int num_tx;
@@ -236,12 +237,18 @@ struct ethoc_bd {
 
 static inline u32 ethoc_read(struct ethoc *dev, loff_t offset)
 {
-	return ioread32(dev->iobase + offset);
+	if (dev->big_endian)
+		return ioread32be(dev->iobase + offset);
+	else
+		return ioread32(dev->iobase + offset);
 }
 
 static inline void ethoc_write(struct ethoc *dev, loff_t offset, u32 data)
 {
-	iowrite32(data, dev->iobase + offset);
+	if (dev->big_endian)
+		iowrite32be(data, dev->iobase + offset);
+	else
+		iowrite32(data, dev->iobase + offset);
 }
 
 static inline void ethoc_read_bd(struct ethoc *dev, int index,
@@ -1106,6 +1113,9 @@ static int ethoc_probe(struct platform_device *pdev)
 		priv->dma_alloc = buffer_size;
 	}
 
+	priv->big_endian = pdata ? pdata->big_endian :
+		of_device_is_big_endian(pdev->dev.of_node);
+
 	/* calculate the number of TX/RX buffers, maximum 128 supported */
 	num_bd = min_t(unsigned int,
 		128, (netdev->mem_end - netdev->mem_start + 1) / ETHOC_BUFSIZ);
diff --git a/include/net/ethoc.h b/include/net/ethoc.h
index 2a2d6bb..bb7f467 100644
--- a/include/net/ethoc.h
+++ b/include/net/ethoc.h
@@ -17,6 +17,7 @@ struct ethoc_platform_data {
 	u8 hwaddr[IFHWADDRLEN];
 	s8 phy_id;
 	u32 eth_clkfreq;
+	bool big_endian;
 };
 
 #endif /* !LINUX_NET_ETHOC_H */
-- 
1.8.1.4
