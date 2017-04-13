From: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 16/22] xen-blkfront: Make use of the new sg_map helper function
Date: Thu, 13 Apr 2017 16:05:29 -0600
Message-ID: <1492121135-4437-17-git-send-email-logang@deltatee.com>
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

Straightforward conversion to the new helper, except due to
the lack of error path, we have to warn if unmapable memory
is ever present in the sgl.

Signed-off-by: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
---
 drivers/block/xen-blkfront.c | 33 +++++++++++++++++++++++++++------
 1 file changed, 27 insertions(+), 6 deletions(-)

diff --git a/drivers/block/xen-blkfront.c b/drivers/block/xen-blkfront.c
index 5067a0a..7dcf41d 100644
--- a/drivers/block/xen-blkfront.c
+++ b/drivers/block/xen-blkfront.c
@@ -807,8 +807,19 @@ static int blkif_queue_rw_req(struct request *req, struct blkfront_ring_info *ri
 		BUG_ON(sg->offset + sg->length > PAGE_SIZE);
 
 		if (setup.need_copy) {
-			setup.bvec_off = sg->offset;
-			setup.bvec_data = kmap_atomic(sg_page(sg));
+			setup.bvec_off = 0;
+			setup.bvec_data = sg_map(sg, SG_KMAP_ATOMIC);
+			if (IS_ERR(setup.bvec_data)) {
+				/*
+				 * This should really never happen unless
+				 * the code is changed to use memory that is
+				 * not mappable in the sg. Seeing there is a
+				 * questionable error path out of here,
+				 * we WARN.
+				 */
+				WARN(1, "Non-mappable memory used in sg!");
+				return 1;
+			}
 		}
 
 		gnttab_foreach_grant_in_range(sg_page(sg),
@@ -818,7 +829,7 @@ static int blkif_queue_rw_req(struct request *req, struct blkfront_ring_info *ri
 					      &setup);
 
 		if (setup.need_copy)
-			kunmap_atomic(setup.bvec_data);
+			sg_unmap(sg, setup.bvec_data, SG_KMAP_ATOMIC);
 	}
 	if (setup.segments)
 		kunmap_atomic(setup.segments);
@@ -1468,8 +1479,18 @@ static bool blkif_completion(unsigned long *id,
 		for_each_sg(s->sg, sg, num_sg, i) {
 			BUG_ON(sg->offset + sg->length > PAGE_SIZE);
 
-			data.bvec_offset = sg->offset;
-			data.bvec_data = kmap_atomic(sg_page(sg));
+			data.bvec_offset = 0;
+			data.bvec_data = sg_map(sg, SG_KMAP_ATOMIC);
+			if (IS_ERR(data.bvec_data)) {
+				/*
+				 * This should really never happen unless
+				 * the code is changed to use memory that is
+				 * not mappable in the sg. Seeing there is no
+				 * clear error path, we WARN.
+				 */
+				WARN(1, "Non-mappable memory used in sg!");
+				return 1;
+			}
 
 			gnttab_foreach_grant_in_range(sg_page(sg),
 						      sg->offset,
@@ -1477,7 +1498,7 @@ static bool blkif_completion(unsigned long *id,
 						      blkif_copy_from_grant,
 						      &data);
 
-			kunmap_atomic(data.bvec_data);
+			sg_unmap(sg, data.bvec_data, SG_KMAP_ATOMIC);
 		}
 	}
 	/* Add the persistent grant into the list of free grants */
-- 
2.1.4
