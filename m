From: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 19/22] mmc: tmio: Make use of the new sg_map helper function
Date: Thu, 13 Apr 2017 16:05:32 -0600
Message-ID: <1492121135-4437-20-git-send-email-logang@deltatee.com>
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

Straightforward conversion to sg_map helper. A couple paths will
WARN if the memory does not end up being mappable.

Signed-off-by: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
---
 drivers/mmc/host/tmio_mmc.h     | 12 ++++++++++--
 drivers/mmc/host/tmio_mmc_dma.c |  5 +++++
 drivers/mmc/host/tmio_mmc_pio.c | 24 ++++++++++++++++++++++++
 3 files changed, 39 insertions(+), 2 deletions(-)

diff --git a/drivers/mmc/host/tmio_mmc.h b/drivers/mmc/host/tmio_mmc.h
index 2b349d4..ba68c9fed 100644
--- a/drivers/mmc/host/tmio_mmc.h
+++ b/drivers/mmc/host/tmio_mmc.h
@@ -198,17 +198,25 @@ void tmio_mmc_enable_mmc_irqs(struct tmio_mmc_host *host, u32 i);
 void tmio_mmc_disable_mmc_irqs(struct tmio_mmc_host *host, u32 i);
 irqreturn_t tmio_mmc_irq(int irq, void *devid);
 
+/* Note: this function may return PTR_ERR and must be checked! */
 static inline char *tmio_mmc_kmap_atomic(struct scatterlist *sg,
 					 unsigned long *flags)
 {
+	void *ret;
+
 	local_irq_save(*flags);
-	return kmap_atomic(sg_page(sg)) + sg->offset;
+	ret = sg_map(sg, SG_KMAP_ATOMIC);
+
+	if (IS_ERR(ret))
+		local_irq_restore(*flags);
+
+	return ret;
 }
 
 static inline void tmio_mmc_kunmap_atomic(struct scatterlist *sg,
 					  unsigned long *flags, void *virt)
 {
-	kunmap_atomic(virt - sg->offset);
+	sg_unmap(sg, virt, SG_KMAP_ATOMIC);
 	local_irq_restore(*flags);
 }
 
diff --git a/drivers/mmc/host/tmio_mmc_dma.c b/drivers/mmc/host/tmio_mmc_dma.c
index fa8a936..07531f7 100644
--- a/drivers/mmc/host/tmio_mmc_dma.c
+++ b/drivers/mmc/host/tmio_mmc_dma.c
@@ -149,6 +149,11 @@ static void tmio_mmc_start_dma_tx(struct tmio_mmc_host *host)
 	if (!aligned) {
 		unsigned long flags;
 		void *sg_vaddr = tmio_mmc_kmap_atomic(sg, &flags);
+		if (IS_ERR(sg_vaddr)) {
+			ret = PTR_ERR(sg_vaddr);
+			goto pio;
+		}
+
 		sg_init_one(&host->bounce_sg, host->bounce_buf, sg->length);
 		memcpy(host->bounce_buf, sg_vaddr, host->bounce_sg.length);
 		tmio_mmc_kunmap_atomic(sg, &flags, sg_vaddr);
diff --git a/drivers/mmc/host/tmio_mmc_pio.c b/drivers/mmc/host/tmio_mmc_pio.c
index 6b789a7..d6fdbf6 100644
--- a/drivers/mmc/host/tmio_mmc_pio.c
+++ b/drivers/mmc/host/tmio_mmc_pio.c
@@ -479,6 +479,18 @@ static void tmio_mmc_pio_irq(struct tmio_mmc_host *host)
 	}
 
 	sg_virt = tmio_mmc_kmap_atomic(host->sg_ptr, &flags);
+	if (IS_ERR(sg_virt)) {
+		/*
+		 * This should really never happen unless
+		 * the code is changed to use memory that is
+		 * not mappable in the sg. Seeing there doesn't
+		 * seem to be any error path out of here,
+		 * we can only WARN.
+		 */
+		WARN(1, "Non-mappable memory used in sg!");
+		return;
+	}
+
 	buf = (unsigned short *)(sg_virt + host->sg_off);
 
 	count = host->sg_ptr->length - host->sg_off;
@@ -506,6 +518,18 @@ static void tmio_mmc_check_bounce_buffer(struct tmio_mmc_host *host)
 	if (host->sg_ptr == &host->bounce_sg) {
 		unsigned long flags;
 		void *sg_vaddr = tmio_mmc_kmap_atomic(host->sg_orig, &flags);
+		if (IS_ERR(sg_vaddr)) {
+			/*
+			 * This should really never happen unless
+			 * the code is changed to use memory that is
+			 * not mappable in the sg. Seeing there doesn't
+			 * seem to be any error path out of here,
+			 * we can only WARN.
+			 */
+			WARN(1, "Non-mappable memory used in sg!");
+			return;
+		}
+
 		memcpy(sg_vaddr, host->bounce_buf, host->bounce_sg.length);
 		tmio_mmc_kunmap_atomic(host->sg_orig, &flags, sg_vaddr);
 	}
-- 
2.1.4
