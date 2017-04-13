From: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 15/22] scsi: libfc,
 csiostor: Change to sg_copy_buffer in two drivers
Date: Thu, 13 Apr 2017 16:05:28 -0600
Message-ID: <1492121135-4437-16-git-send-email-logang@deltatee.com>
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

These two drivers appear to duplicate the functionality of
sg_copy_buffer. So we clean them up to use the common code.

This helps us remove a couple of instances that would otherwise be
slightly tricky sg_map usages.

Signed-off-by: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
---
 drivers/scsi/csiostor/csio_scsi.c | 54 +++------------------------------------
 drivers/scsi/libfc/fc_libfc.c     | 49 ++++++++---------------------------
 2 files changed, 14 insertions(+), 89 deletions(-)

diff --git a/drivers/scsi/csiostor/csio_scsi.c b/drivers/scsi/csiostor/csio_scsi.c
index a1ff75f..bd9d062 100644
--- a/drivers/scsi/csiostor/csio_scsi.c
+++ b/drivers/scsi/csiostor/csio_scsi.c
@@ -1489,60 +1489,14 @@ static inline uint32_t
 csio_scsi_copy_to_sgl(struct csio_hw *hw, struct csio_ioreq *req)
 {
 	struct scsi_cmnd *scmnd  = (struct scsi_cmnd *)csio_scsi_cmnd(req);
-	struct scatterlist *sg;
-	uint32_t bytes_left;
-	uint32_t bytes_copy;
-	uint32_t buf_off = 0;
-	uint32_t start_off = 0;
-	uint32_t sg_off = 0;
-	void *sg_addr;
-	void *buf_addr;
 	struct csio_dma_buf *dma_buf;
+	size_t copied;
 
-	bytes_left = scsi_bufflen(scmnd);
-	sg = scsi_sglist(scmnd);
 	dma_buf = (struct csio_dma_buf *)csio_list_next(&req->gen_list);
+	copied = sg_copy_from_buffer(scsi_sglist(scmnd), scsi_sg_count(scmnd),
+				     dma_buf->vaddr, scsi_bufflen(scmnd));
 
-	/* Copy data from driver buffer to SGs of SCSI CMD */
-	while (bytes_left > 0 && sg && dma_buf) {
-		if (buf_off >= dma_buf->len) {
-			buf_off = 0;
-			dma_buf = (struct csio_dma_buf *)
-					csio_list_next(dma_buf);
-			continue;
-		}
-
-		if (start_off >= sg->length) {
-			start_off -= sg->length;
-			sg = sg_next(sg);
-			continue;
-		}
-
-		buf_addr = dma_buf->vaddr + buf_off;
-		sg_off = sg->offset + start_off;
-		bytes_copy = min((dma_buf->len - buf_off),
-				sg->length - start_off);
-		bytes_copy = min((uint32_t)(PAGE_SIZE - (sg_off & ~PAGE_MASK)),
-				 bytes_copy);
-
-		sg_addr = kmap_atomic(sg_page(sg) + (sg_off >> PAGE_SHIFT));
-		if (!sg_addr) {
-			csio_err(hw, "failed to kmap sg:%p of ioreq:%p\n",
-				sg, req);
-			break;
-		}
-
-		csio_dbg(hw, "copy_to_sgl:sg_addr %p sg_off %d buf %p len %d\n",
-				sg_addr, sg_off, buf_addr, bytes_copy);
-		memcpy(sg_addr + (sg_off & ~PAGE_MASK), buf_addr, bytes_copy);
-		kunmap_atomic(sg_addr);
-
-		start_off +=  bytes_copy;
-		buf_off += bytes_copy;
-		bytes_left -= bytes_copy;
-	}
-
-	if (bytes_left > 0)
+	if (copied != scsi_bufflen(scmnd))
 		return DID_ERROR;
 	else
 		return DID_OK;
diff --git a/drivers/scsi/libfc/fc_libfc.c b/drivers/scsi/libfc/fc_libfc.c
index d623d08..ce0805a 100644
--- a/drivers/scsi/libfc/fc_libfc.c
+++ b/drivers/scsi/libfc/fc_libfc.c
@@ -113,45 +113,16 @@ u32 fc_copy_buffer_to_sglist(void *buf, size_t len,
 			     u32 *nents, size_t *offset,
 			     u32 *crc)
 {
-	size_t remaining = len;
-	u32 copy_len = 0;
-
-	while (remaining > 0 && sg) {
-		size_t off, sg_bytes;
-		void *page_addr;
-
-		if (*offset >= sg->length) {
-			/*
-			 * Check for end and drop resources
-			 * from the last iteration.
-			 */
-			if (!(*nents))
-				break;
-			--(*nents);
-			*offset -= sg->length;
-			sg = sg_next(sg);
-			continue;
-		}
-		sg_bytes = min(remaining, sg->length - *offset);
-
-		/*
-		 * The scatterlist item may be bigger than PAGE_SIZE,
-		 * but we are limited to mapping PAGE_SIZE at a time.
-		 */
-		off = *offset + sg->offset;
-		sg_bytes = min(sg_bytes,
-			       (size_t)(PAGE_SIZE - (off & ~PAGE_MASK)));
-		page_addr = kmap_atomic(sg_page(sg) + (off >> PAGE_SHIFT));
-		if (crc)
-			*crc = crc32(*crc, buf, sg_bytes);
-		memcpy((char *)page_addr + (off & ~PAGE_MASK), buf, sg_bytes);
-		kunmap_atomic(page_addr);
-		buf += sg_bytes;
-		*offset += sg_bytes;
-		remaining -= sg_bytes;
-		copy_len += sg_bytes;
-	}
-	return copy_len;
+	size_t copied;
+
+	copied = sg_pcopy_from_buffer(sg, sg_nents(sg),
+				      buf, len, *offset);
+
+	*offset += copied;
+	if (crc)
+		*crc = crc32(*crc, buf, copied);
+
+	return copied;
 }
 
 /**
-- 
2.1.4
