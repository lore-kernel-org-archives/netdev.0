From: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 18/22] mmc: spi: Make use of the new sg_map helper function
Date: Thu, 13 Apr 2017 16:05:31 -0600
Message-ID: <1492121135-4437-19-git-send-email-logang@deltatee.com>
References: <1492121135-4437-1-git-send-email-logang@deltatee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
To: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>,
 "Martin K. Petersen" <martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
 Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>, Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>,
 Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
 Dan Williams <dan.j.williams-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 Ross Zwisler <ross.zwisler-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
 Matthew Wilcox <mawilcox-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>,
 Sumit Semwal <sumit.semwal-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>, Ming Lin <ming.l-Vzezgt5dB6uUEJcrhfAQsw@public.gmane.org>,
 linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
 linaro-mm-sig-cunTk1MwBs8s++Sfvej+rw@public.gmane.org, intel-gfx-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
 linux-raid-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-nvme-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, linux-nvdimm-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org,
 linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, fcoe-devel-s9riP+hp16TNLxjTenLetw@public.gmane.org,
 open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org, megaraidlinux.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org,
 sparmaintainer-GLv8BlqOqDDQT0dZR+AlfA@public.gmane.org, devel@driverd
Return-path: <linux-nvdimm-bounces-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org>
In-Reply-To: <1492121135-4437-1-git-send-email-logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.01.org/mailman/options/linux-nvdimm>,
 <mailto:linux-nvdimm-request-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.01.org/pipermail/linux-nvdimm/>
List-Post: <mailto:linux-nvdimm-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org>
List-Help: <mailto:linux-nvdimm-request-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org?subject=help>
List-Subscribe: <https://lists.01.org/mailman/listinfo/linux-nvdimm>,
 <mailto:linux-nvdimm-request-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org?subject=subscribe>
Errors-To: linux-nvdimm-bounces-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org
Sender: "Linux-nvdimm" <linux-nvdimm-bounces-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org>
List-Id: netdev.vger.kernel.org

We use the sg_map helper but it's slightly more complicated
as we only check for the error when the mapping actually gets used.
Such that if the mapping failed but wasn't needed then no
error occurs.

Signed-off-by: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
---
 drivers/mmc/host/mmc_spi.c | 26 +++++++++++++++++++-------
 1 file changed, 19 insertions(+), 7 deletions(-)

diff --git a/drivers/mmc/host/mmc_spi.c b/drivers/mmc/host/mmc_spi.c
index e77d79c..82f786d 100644
--- a/drivers/mmc/host/mmc_spi.c
+++ b/drivers/mmc/host/mmc_spi.c
@@ -676,9 +676,15 @@ mmc_spi_writeblock(struct mmc_spi_host *host, struct spi_transfer *t,
 	struct scratch		*scratch = host->data;
 	u32			pattern;
 
-	if (host->mmc->use_spi_crc)
+	if (host->mmc->use_spi_crc) {
+		if (IS_ERR(t->tx_buf))
+			return PTR_ERR(t->tx_buf);
+
 		scratch->crc_val = cpu_to_be16(
 				crc_itu_t(0, t->tx_buf, t->len));
+		t->tx_buf += t->len;
+	}
+
 	if (host->dma_dev)
 		dma_sync_single_for_device(host->dma_dev,
 				host->data_dma, sizeof(*scratch),
@@ -743,7 +749,6 @@ mmc_spi_writeblock(struct mmc_spi_host *host, struct spi_transfer *t,
 		return status;
 	}
 
-	t->tx_buf += t->len;
 	if (host->dma_dev)
 		t->tx_dma += t->len;
 
@@ -809,6 +814,11 @@ mmc_spi_readblock(struct mmc_spi_host *host, struct spi_transfer *t,
 	}
 	leftover = status << 1;
 
+	if (bitshift || host->mmc->use_spi_crc) {
+		if (IS_ERR(t->rx_buf))
+			return PTR_ERR(t->rx_buf);
+	}
+
 	if (host->dma_dev) {
 		dma_sync_single_for_device(host->dma_dev,
 				host->data_dma, sizeof(*scratch),
@@ -860,9 +870,10 @@ mmc_spi_readblock(struct mmc_spi_host *host, struct spi_transfer *t,
 					scratch->crc_val, crc, t->len);
 			return -EILSEQ;
 		}
+
+		t->rx_buf += t->len;
 	}
 
-	t->rx_buf += t->len;
 	if (host->dma_dev)
 		t->rx_dma += t->len;
 
@@ -936,11 +947,11 @@ mmc_spi_data_do(struct mmc_spi_host *host, struct mmc_command *cmd,
 		}
 
 		/* allow pio too; we don't allow highmem */
-		kmap_addr = kmap(sg_page(sg));
+		kmap_addr = sg_map(sg, SG_KMAP);
 		if (direction == DMA_TO_DEVICE)
-			t->tx_buf = kmap_addr + sg->offset;
+			t->tx_buf = kmap_addr;
 		else
-			t->rx_buf = kmap_addr + sg->offset;
+			t->rx_buf = kmap_addr;
 
 		/* transfer each block, and update request status */
 		while (length) {
@@ -970,7 +981,8 @@ mmc_spi_data_do(struct mmc_spi_host *host, struct mmc_command *cmd,
 		/* discard mappings */
 		if (direction == DMA_FROM_DEVICE)
 			flush_kernel_dcache_page(sg_page(sg));
-		kunmap(sg_page(sg));
+		if (!IS_ERR(kmap_addr))
+			sg_unmap(sg, kmap_addr, SG_KMAP);
 		if (dma_dev)
 			dma_unmap_page(dma_dev, dma_addr, PAGE_SIZE, dir);
 
-- 
2.1.4
