From: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 14/22] scsi: arcmsr, ips,
 megaraid: Make use of the new sg_map helper function
Date: Thu, 13 Apr 2017 16:05:27 -0600
Message-ID: <1492121135-4437-15-git-send-email-logang@deltatee.com>
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

Very straightforward conversion of three scsi drivers

Signed-off-by: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
---
 drivers/scsi/arcmsr/arcmsr_hba.c | 16 ++++++++++++----
 drivers/scsi/ips.c               |  8 ++++----
 drivers/scsi/megaraid.c          |  9 +++++++--
 3 files changed, 23 insertions(+), 10 deletions(-)

diff --git a/drivers/scsi/arcmsr/arcmsr_hba.c b/drivers/scsi/arcmsr/arcmsr_hba.c
index af032c4..3cd485c 100644
--- a/drivers/scsi/arcmsr/arcmsr_hba.c
+++ b/drivers/scsi/arcmsr/arcmsr_hba.c
@@ -2306,7 +2306,10 @@ static int arcmsr_iop_message_xfer(struct AdapterControlBlock *acb,
 
 	use_sg = scsi_sg_count(cmd);
 	sg = scsi_sglist(cmd);
-	buffer = kmap_atomic(sg_page(sg)) + sg->offset;
+	buffer = sg_map(sg, SG_KMAP_ATOMIC);
+	if (IS_ERR(buffer))
+		return ARCMSR_MESSAGE_FAIL;
+
 	if (use_sg > 1) {
 		retvalue = ARCMSR_MESSAGE_FAIL;
 		goto message_out;
@@ -2539,7 +2542,7 @@ static int arcmsr_iop_message_xfer(struct AdapterControlBlock *acb,
 message_out:
 	if (use_sg) {
 		struct scatterlist *sg = scsi_sglist(cmd);
-		kunmap_atomic(buffer - sg->offset);
+		sg_unmap(sg, buffer, SG_KMAP_ATOMIC);
 	}
 	return retvalue;
 }
@@ -2590,11 +2593,16 @@ static void arcmsr_handle_virtual_command(struct AdapterControlBlock *acb,
 		strncpy(&inqdata[32], "R001", 4); /* Product Revision */
 
 		sg = scsi_sglist(cmd);
-		buffer = kmap_atomic(sg_page(sg)) + sg->offset;
+		buffer = sg_map(sg, SG_KMAP_ATOMIC);
+		if (IS_ERR(buffer)) {
+			cmd->result = (DID_ERROR << 16);
+			cmd->scsi_done(cmd);
+			return;
+		}
 
 		memcpy(buffer, inqdata, sizeof(inqdata));
 		sg = scsi_sglist(cmd);
-		kunmap_atomic(buffer - sg->offset);
+		sg_unmap(sg, buffer, SG_KMAP_ATOMIC);
 
 		cmd->scsi_done(cmd);
 	}
diff --git a/drivers/scsi/ips.c b/drivers/scsi/ips.c
index 3419e1b..a44291d 100644
--- a/drivers/scsi/ips.c
+++ b/drivers/scsi/ips.c
@@ -1506,14 +1506,14 @@ static int ips_is_passthru(struct scsi_cmnd *SC)
                 /* kmap_atomic() ensures addressability of the user buffer.*/
                 /* local_irq_save() protects the KM_IRQ0 address slot.     */
                 local_irq_save(flags);
-                buffer = kmap_atomic(sg_page(sg)) + sg->offset;
-                if (buffer && buffer[0] == 'C' && buffer[1] == 'O' &&
+                buffer = sg_map(sg, SG_KMAP_ATOMIC);
+                if (!IS_ERR(buffer) && buffer[0] == 'C' && buffer[1] == 'O' &&
                     buffer[2] == 'P' && buffer[3] == 'P') {
-                        kunmap_atomic(buffer - sg->offset);
+                        sg_unmap(sg, buffer, SG_KMAP_ATOMIC);
                         local_irq_restore(flags);
                         return 1;
                 }
-                kunmap_atomic(buffer - sg->offset);
+                sg_unmap(sg, buffer, SG_KMAP_ATOMIC);
                 local_irq_restore(flags);
 	}
 	return 0;
diff --git a/drivers/scsi/megaraid.c b/drivers/scsi/megaraid.c
index 3c63c29..0b66e50 100644
--- a/drivers/scsi/megaraid.c
+++ b/drivers/scsi/megaraid.c
@@ -663,10 +663,15 @@ mega_build_cmd(adapter_t *adapter, Scsi_Cmnd *cmd, int *busy)
 			struct scatterlist *sg;
 
 			sg = scsi_sglist(cmd);
-			buf = kmap_atomic(sg_page(sg)) + sg->offset;
+			buf = sg_map(sg, SG_KMAP_ATOMIC);
+			if (IS_ERR(buf)) {
+                                cmd->result = (DID_ERROR << 16);
+				cmd->scsi_done(cmd);
+				return NULL;
+			}
 
 			memset(buf, 0, cmd->cmnd[4]);
-			kunmap_atomic(buf - sg->offset);
+			sg_unmap(sg, buf, SG_KMAP_ATOMIC);
 
 			cmd->result = (DID_OK << 16);
 			cmd->scsi_done(cmd);
-- 
2.1.4
