From: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 12/22] scsi: ipr, pmcraid,
 isci: Make use of the new sg_map helper in 4 call sites
Date: Thu, 13 Apr 2017 16:05:25 -0600
Message-ID: <1492121135-4437-13-git-send-email-logang@deltatee.com>
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

Very straightforward conversion of three scsi drivers.

Signed-off-by: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
---
 drivers/scsi/ipr.c          | 27 ++++++++++++++-------------
 drivers/scsi/isci/request.c | 42 +++++++++++++++++++++++++-----------------
 drivers/scsi/pmcraid.c      | 19 ++++++++++++-------
 3 files changed, 51 insertions(+), 37 deletions(-)

diff --git a/drivers/scsi/ipr.c b/drivers/scsi/ipr.c
index b29afaf..f98f251 100644
--- a/drivers/scsi/ipr.c
+++ b/drivers/scsi/ipr.c
@@ -3853,7 +3853,7 @@ static void ipr_free_ucode_buffer(struct ipr_sglist *sglist)
 static int ipr_copy_ucode_buffer(struct ipr_sglist *sglist,
 				 u8 *buffer, u32 len)
 {
-	int bsize_elem, i, result = 0;
+	int bsize_elem, i;
 	struct scatterlist *scatterlist;
 	void *kaddr;
 
@@ -3863,32 +3863,33 @@ static int ipr_copy_ucode_buffer(struct ipr_sglist *sglist,
 	scatterlist = sglist->scatterlist;
 
 	for (i = 0; i < (len / bsize_elem); i++, buffer += bsize_elem) {
-		struct page *page = sg_page(&scatterlist[i]);
+		kaddr = sg_map(&scatterlist[i], SG_KMAP);
+		if (IS_ERR(kaddr)) {
+			ipr_trace;
+			return PTR_ERR(kaddr);
+		}
 
-		kaddr = kmap(page);
 		memcpy(kaddr, buffer, bsize_elem);
-		kunmap(page);
+		sg_unmap(&scatterlist[i], kaddr, SG_KMAP);
 
 		scatterlist[i].length = bsize_elem;
-
-		if (result != 0) {
-			ipr_trace;
-			return result;
-		}
 	}
 
 	if (len % bsize_elem) {
-		struct page *page = sg_page(&scatterlist[i]);
+		kaddr = sg_map(&scatterlist[i], SG_KMAP);
+		if (IS_ERR(kaddr)) {
+			ipr_trace;
+			return PTR_ERR(kaddr);
+		}
 
-		kaddr = kmap(page);
 		memcpy(kaddr, buffer, len % bsize_elem);
-		kunmap(page);
+		sg_unmap(&scatterlist[i], kaddr, SG_KMAP);
 
 		scatterlist[i].length = len % bsize_elem;
 	}
 
 	sglist->buffer_len = len;
-	return result;
+	return 0;
 }
 
 /**
diff --git a/drivers/scsi/isci/request.c b/drivers/scsi/isci/request.c
index 47f66e9..66d6596 100644
--- a/drivers/scsi/isci/request.c
+++ b/drivers/scsi/isci/request.c
@@ -1424,12 +1424,14 @@ sci_stp_request_pio_data_in_copy_data_buffer(struct isci_stp_request *stp_req,
 		sg = task->scatter;
 
 		while (total_len > 0) {
-			struct page *page = sg_page(sg);
-
 			copy_len = min_t(int, total_len, sg_dma_len(sg));
-			kaddr = kmap_atomic(page);
-			memcpy(kaddr + sg->offset, src_addr, copy_len);
-			kunmap_atomic(kaddr);
+			kaddr = sg_map(sg, SG_KMAP_ATOMIC);
+			if (IS_ERR(kaddr))
+				return SCI_FAILURE;
+
+			memcpy(kaddr, src_addr, copy_len);
+			sg_unmap(sg, kaddr, SG_KMAP_ATOMIC);
+
 			total_len -= copy_len;
 			src_addr += copy_len;
 			sg = sg_next(sg);
@@ -1771,14 +1773,16 @@ sci_io_request_frame_handler(struct isci_request *ireq,
 	case SCI_REQ_SMP_WAIT_RESP: {
 		struct sas_task *task = isci_request_access_task(ireq);
 		struct scatterlist *sg = &task->smp_task.smp_resp;
-		void *frame_header, *kaddr;
+		void *frame_header;
 		u8 *rsp;
 
 		sci_unsolicited_frame_control_get_header(&ihost->uf_control,
 							 frame_index,
 							 &frame_header);
-		kaddr = kmap_atomic(sg_page(sg));
-		rsp = kaddr + sg->offset;
+		rsp = sg_map(sg, SG_KMAP_ATOMIC);
+		if (IS_ERR(rsp))
+			return SCI_FAILURE;
+
 		sci_swab32_cpy(rsp, frame_header, 1);
 
 		if (rsp[0] == SMP_RESPONSE) {
@@ -1814,7 +1818,7 @@ sci_io_request_frame_handler(struct isci_request *ireq,
 			ireq->sci_status = SCI_FAILURE_CONTROLLER_SPECIFIC_IO_ERR;
 			sci_change_state(&ireq->sm, SCI_REQ_COMPLETED);
 		}
-		kunmap_atomic(kaddr);
+		sg_unmap(sg, rsp, SG_KMAP_ATOMIC);
 
 		sci_controller_release_frame(ihost, frame_index);
 
@@ -2919,15 +2923,18 @@ static void isci_request_io_request_complete(struct isci_host *ihost,
 	case SAS_PROTOCOL_SMP: {
 		struct scatterlist *sg = &task->smp_task.smp_req;
 		struct smp_req *smp_req;
-		void *kaddr;
 
 		dma_unmap_sg(&ihost->pdev->dev, sg, 1, DMA_TO_DEVICE);
 
 		/* need to swab it back in case the command buffer is re-used */
-		kaddr = kmap_atomic(sg_page(sg));
-		smp_req = kaddr + sg->offset;
+		smp_req = sg_map(sg, SG_KMAP_ATOMIC);
+		if (IS_ERR(smp_req)) {
+			status = SAS_ABORTED_TASK;
+			break;
+		}
+
 		sci_swab32_cpy(smp_req, smp_req, sg->length / sizeof(u32));
-		kunmap_atomic(kaddr);
+		sg_unmap(sg, smp_req, SG_KMAP_ATOMIC);
 		break;
 	}
 	default:
@@ -3190,12 +3197,13 @@ sci_io_request_construct_smp(struct device *dev,
 	struct scu_task_context *task_context;
 	struct isci_port *iport;
 	struct smp_req *smp_req;
-	void *kaddr;
 	u8 req_len;
 	u32 cmd;
 
-	kaddr = kmap_atomic(sg_page(sg));
-	smp_req = kaddr + sg->offset;
+	smp_req = sg_map(sg, SG_KMAP_ATOMIC);
+	if (IS_ERR(smp_req))
+		return SCI_FAILURE;
+
 	/*
 	 * Look at the SMP requests' header fields; for certain SAS 1.x SMP
 	 * functions under SAS 2.0, a zero request length really indicates
@@ -3220,7 +3228,7 @@ sci_io_request_construct_smp(struct device *dev,
 	req_len = smp_req->req_len;
 	sci_swab32_cpy(smp_req, smp_req, sg->length / sizeof(u32));
 	cmd = *(u32 *) smp_req;
-	kunmap_atomic(kaddr);
+	sg_unmap(sg, smp_req, SG_KMAP_ATOMIC);
 
 	if (!dma_map_sg(dev, sg, 1, DMA_TO_DEVICE))
 		return SCI_FAILURE;
diff --git a/drivers/scsi/pmcraid.c b/drivers/scsi/pmcraid.c
index 49e70a3..af1903e 100644
--- a/drivers/scsi/pmcraid.c
+++ b/drivers/scsi/pmcraid.c
@@ -3342,9 +3342,12 @@ static int pmcraid_copy_sglist(
 	scatterlist = sglist->scatterlist;
 
 	for (i = 0; i < (len / bsize_elem); i++, buffer += bsize_elem) {
-		struct page *page = sg_page(&scatterlist[i]);
+		kaddr = sg_map(&scatterlist[i], SG_KMAP);
+		if (IS_ERR(kaddr)) {
+			pmcraid_err("failed to copy user data into sg list\n");
+			return PTR_ERR(kaddr);
+		}
 
-		kaddr = kmap(page);
 		if (direction == DMA_TO_DEVICE)
 			rc = __copy_from_user(kaddr,
 					      (void *)buffer,
@@ -3352,7 +3355,7 @@ static int pmcraid_copy_sglist(
 		else
 			rc = __copy_to_user((void *)buffer, kaddr, bsize_elem);
 
-		kunmap(page);
+		sg_unmap(&scatterlist[i], kaddr, SG_KMAP);
 
 		if (rc) {
 			pmcraid_err("failed to copy user data into sg list\n");
@@ -3363,9 +3366,11 @@ static int pmcraid_copy_sglist(
 	}
 
 	if (len % bsize_elem) {
-		struct page *page = sg_page(&scatterlist[i]);
-
-		kaddr = kmap(page);
+		kaddr = sg_map(&scatterlist[i], SG_KMAP);
+		if (IS_ERR(kaddr)) {
+			pmcraid_err("failed to copy user data into sg list\n");
+			return PTR_ERR(kaddr);
+		}
 
 		if (direction == DMA_TO_DEVICE)
 			rc = __copy_from_user(kaddr,
@@ -3376,7 +3381,7 @@ static int pmcraid_copy_sglist(
 					    kaddr,
 					    len % bsize_elem);
 
-		kunmap(page);
+		sg_unmap(&scatterlist[i], kaddr, SG_KMAP);
 
 		scatterlist[i].length = len % bsize_elem;
 	}
-- 
2.1.4
