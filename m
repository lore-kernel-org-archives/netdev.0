From: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 22/22] memstick: Make use of the new sg_map helper function
Date: Thu, 13 Apr 2017 16:05:35 -0600
Message-ID: <1492121135-4437-23-git-send-email-logang@deltatee.com>
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

Straightforward conversion, but we have to WARN if unmappable
memory finds its way into the sgl.

Signed-off-by: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
---
 drivers/memstick/host/jmb38x_ms.c | 23 ++++++++++++++++++-----
 drivers/memstick/host/tifm_ms.c   | 22 +++++++++++++++++-----
 2 files changed, 35 insertions(+), 10 deletions(-)

diff --git a/drivers/memstick/host/jmb38x_ms.c b/drivers/memstick/host/jmb38x_ms.c
index 48db922..256cf41 100644
--- a/drivers/memstick/host/jmb38x_ms.c
+++ b/drivers/memstick/host/jmb38x_ms.c
@@ -303,7 +303,6 @@ static int jmb38x_ms_transfer_data(struct jmb38x_ms_host *host)
 	unsigned int off;
 	unsigned int t_size, p_cnt;
 	unsigned char *buf;
-	struct page *pg;
 	unsigned long flags = 0;
 
 	if (host->req->long_data) {
@@ -318,14 +317,26 @@ static int jmb38x_ms_transfer_data(struct jmb38x_ms_host *host)
 		unsigned int uninitialized_var(p_off);
 
 		if (host->req->long_data) {
-			pg = nth_page(sg_page(&host->req->sg),
-				      off >> PAGE_SHIFT);
 			p_off = offset_in_page(off);
 			p_cnt = PAGE_SIZE - p_off;
 			p_cnt = min(p_cnt, length);
 
 			local_irq_save(flags);
-			buf = kmap_atomic(pg) + p_off;
+			buf = sg_map_offset(&host->req->sg,
+					     off - host->req->sg.offset,
+					     SG_KMAP_ATOMIC);
+			if (IS_ERR(buf)) {
+				/*
+				 * This should really never happen unless
+				 * the code is changed to use memory that is
+				 * not mappable in the sg. Seeing there doesn't
+				 * seem to be any error path out of here,
+				 * we can only WARN.
+				 */
+				WARN(1, "Non-mappable memory used in sg!");
+				break;
+			}
+
 		} else {
 			buf = host->req->data + host->block_pos;
 			p_cnt = host->req->data_len - host->block_pos;
@@ -341,7 +352,9 @@ static int jmb38x_ms_transfer_data(struct jmb38x_ms_host *host)
 				 : jmb38x_ms_read_reg_data(host, buf, p_cnt);
 
 		if (host->req->long_data) {
-			kunmap_atomic(buf - p_off);
+			sg_unmap_offset(&host->req->sg, buf,
+					 off - host->req->sg.offset,
+					 SG_KMAP_ATOMIC);
 			local_irq_restore(flags);
 		}
 
diff --git a/drivers/memstick/host/tifm_ms.c b/drivers/memstick/host/tifm_ms.c
index 7bafa72..c0bc40e 100644
--- a/drivers/memstick/host/tifm_ms.c
+++ b/drivers/memstick/host/tifm_ms.c
@@ -186,7 +186,6 @@ static unsigned int tifm_ms_transfer_data(struct tifm_ms *host)
 	unsigned int off;
 	unsigned int t_size, p_cnt;
 	unsigned char *buf;
-	struct page *pg;
 	unsigned long flags = 0;
 
 	if (host->req->long_data) {
@@ -203,14 +202,25 @@ static unsigned int tifm_ms_transfer_data(struct tifm_ms *host)
 		unsigned int uninitialized_var(p_off);
 
 		if (host->req->long_data) {
-			pg = nth_page(sg_page(&host->req->sg),
-				      off >> PAGE_SHIFT);
 			p_off = offset_in_page(off);
 			p_cnt = PAGE_SIZE - p_off;
 			p_cnt = min(p_cnt, length);
 
 			local_irq_save(flags);
-			buf = kmap_atomic(pg) + p_off;
+			buf = sg_map_offset(&host->req->sg,
+					     off - host->req->sg.offset,
+					     SG_KMAP_ATOMIC);
+			if (IS_ERR(buf)) {
+				/*
+				 * This should really never happen unless
+				 * the code is changed to use memory that is
+				 * not mappable in the sg. Seeing there doesn't
+				 * seem to be any error path out of here,
+				 * we can only WARN.
+				 */
+				WARN(1, "Non-mappable memory used in sg!");
+				break;
+			}
 		} else {
 			buf = host->req->data + host->block_pos;
 			p_cnt = host->req->data_len - host->block_pos;
@@ -221,7 +231,9 @@ static unsigned int tifm_ms_transfer_data(struct tifm_ms *host)
 			 : tifm_ms_read_data(host, buf, p_cnt);
 
 		if (host->req->long_data) {
-			kunmap_atomic(buf - p_off);
+			sg_unmap_offset(&host->req->sg, buf,
+					 off - host->req->sg.offset,
+					 SG_KMAP_ATOMIC);
 			local_irq_restore(flags);
 		}
 
-- 
2.1.4
