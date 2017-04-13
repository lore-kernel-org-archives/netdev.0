From: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 13/22] scsi: hisi_sas, mvsas,
 gdth: Make use of the new sg_map helper function
Date: Thu, 13 Apr 2017 16:05:26 -0600
Message-ID: <1492121135-4437-14-git-send-email-logang@deltatee.com>
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
 drivers/scsi/gdth.c                    |  9 +++++++--
 drivers/scsi/hisi_sas/hisi_sas_v1_hw.c | 14 +++++++++-----
 drivers/scsi/hisi_sas/hisi_sas_v2_hw.c | 13 +++++++++----
 drivers/scsi/mvsas/mv_sas.c            | 10 +++++-----
 4 files changed, 30 insertions(+), 16 deletions(-)

diff --git a/drivers/scsi/gdth.c b/drivers/scsi/gdth.c
index d020a13..82c9fba 100644
--- a/drivers/scsi/gdth.c
+++ b/drivers/scsi/gdth.c
@@ -2301,10 +2301,15 @@ static void gdth_copy_internal_data(gdth_ha_str *ha, Scsi_Cmnd *scp,
                 return;
             }
             local_irq_save(flags);
-            address = kmap_atomic(sg_page(sl)) + sl->offset;
+            address = sg_map(sl, SG_KMAP_ATOMIC);
+            if (IS_ERR(address)) {
+                scp->result = DID_ERROR << 16;
+                return;
+	    }
+
             memcpy(address, buffer, cpnow);
             flush_dcache_page(sg_page(sl));
-            kunmap_atomic(address);
+            sg_unmap(sl, address, SG_KMAP_ATOMIC);
             local_irq_restore(flags);
             if (cpsum == cpcount)
                 break;
diff --git a/drivers/scsi/hisi_sas/hisi_sas_v1_hw.c b/drivers/scsi/hisi_sas/hisi_sas_v1_hw.c
index 854fbea..30408f8 100644
--- a/drivers/scsi/hisi_sas/hisi_sas_v1_hw.c
+++ b/drivers/scsi/hisi_sas/hisi_sas_v1_hw.c
@@ -1377,18 +1377,22 @@ static int slot_complete_v1_hw(struct hisi_hba *hisi_hba,
 		void *to;
 		struct scatterlist *sg_resp = &task->smp_task.smp_resp;
 
-		ts->stat = SAM_STAT_GOOD;
-		to = kmap_atomic(sg_page(sg_resp));
+		to = sg_map(sg_resp, SG_KMAP_ATOMIC);
+		if (IS_ERR(to)) {
+			dev_err(dev, "slot complete: error mapping memory");
+			ts->stat = SAS_SG_ERR;
+			break;
+		}
 
+		ts->stat = SAM_STAT_GOOD;
 		dma_unmap_sg(dev, &task->smp_task.smp_resp, 1,
 			     DMA_FROM_DEVICE);
 		dma_unmap_sg(dev, &task->smp_task.smp_req, 1,
 			     DMA_TO_DEVICE);
-		memcpy(to + sg_resp->offset,
-		       slot->status_buffer +
+		memcpy(to, slot->status_buffer +
 		       sizeof(struct hisi_sas_err_record),
 		       sg_dma_len(sg_resp));
-		kunmap_atomic(to);
+		sg_unmap(sg_resp, to, SG_KMAP_ATOMIC);
 		break;
 	}
 	case SAS_PROTOCOL_SATA:
diff --git a/drivers/scsi/hisi_sas/hisi_sas_v2_hw.c b/drivers/scsi/hisi_sas/hisi_sas_v2_hw.c
index 1b21445..0907947 100644
--- a/drivers/scsi/hisi_sas/hisi_sas_v2_hw.c
+++ b/drivers/scsi/hisi_sas/hisi_sas_v2_hw.c
@@ -1796,18 +1796,23 @@ slot_complete_v2_hw(struct hisi_hba *hisi_hba, struct hisi_sas_slot *slot,
 		struct scatterlist *sg_resp = &task->smp_task.smp_resp;
 		void *to;
 
+		to = sg_map(sg_resp, SG_KMAP_ATOMIC);
+		if (IS_ERR(to)) {
+			dev_err(dev, "slot complete: error mapping memory");
+			ts->stat = SAS_SG_ERR;
+			break;
+		}
+
 		ts->stat = SAM_STAT_GOOD;
-		to = kmap_atomic(sg_page(sg_resp));
 
 		dma_unmap_sg(dev, &task->smp_task.smp_resp, 1,
 			     DMA_FROM_DEVICE);
 		dma_unmap_sg(dev, &task->smp_task.smp_req, 1,
 			     DMA_TO_DEVICE);
-		memcpy(to + sg_resp->offset,
-		       slot->status_buffer +
+		memcpy(to, slot->status_buffer +
 		       sizeof(struct hisi_sas_err_record),
 		       sg_dma_len(sg_resp));
-		kunmap_atomic(to);
+		sg_unmap(sg_resp, to, SG_KMAP_ATOMIC);
 		break;
 	}
 	case SAS_PROTOCOL_SATA:
diff --git a/drivers/scsi/mvsas/mv_sas.c b/drivers/scsi/mvsas/mv_sas.c
index c7cc803..374d0e0 100644
--- a/drivers/scsi/mvsas/mv_sas.c
+++ b/drivers/scsi/mvsas/mv_sas.c
@@ -1798,11 +1798,11 @@ int mvs_slot_complete(struct mvs_info *mvi, u32 rx_desc, u32 flags)
 	case SAS_PROTOCOL_SMP: {
 			struct scatterlist *sg_resp = &task->smp_task.smp_resp;
 			tstat->stat = SAM_STAT_GOOD;
-			to = kmap_atomic(sg_page(sg_resp));
-			memcpy(to + sg_resp->offset,
-				slot->response + sizeof(struct mvs_err_info),
-				sg_dma_len(sg_resp));
-			kunmap_atomic(to);
+			to = sg_map(sg_resp, SG_KMAP_ATOMIC);
+			memcpy(to,
+			       slot->response + sizeof(struct mvs_err_info),
+			       sg_dma_len(sg_resp));
+			sg_unmap(sg_resp, to, SG_KMAP_ATOMIC);
 			break;
 		}
 
-- 
2.1.4
