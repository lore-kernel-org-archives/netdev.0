From: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 21/22] mmc: tifm_sd: Make use of the new sg_map helper function
Date: Thu, 13 Apr 2017 16:05:34 -0600
Message-ID: <1492121135-4437-22-git-send-email-logang@deltatee.com>
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

This conversion is a bit complicated. We modiy the read_fifo,
write_fifo and copy_page functions to take a scatterlist instead of a
page. Thus we can use sg_map instead of kmap_atomic. There's a bit of
accounting that needed to be done for the offset for this to work.
(Seeing sg_map takes care of the offset but it's already added and
used earlier in the code.

There's also no error path, so if unmappable memory finds its way into
the sgl we can only WARN.

Signed-off-by: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
---
 drivers/mmc/host/tifm_sd.c | 88 +++++++++++++++++++++++++++++++++++-----------
 1 file changed, 67 insertions(+), 21 deletions(-)

diff --git a/drivers/mmc/host/tifm_sd.c b/drivers/mmc/host/tifm_sd.c
index 93c4b40..75b0d74 100644
--- a/drivers/mmc/host/tifm_sd.c
+++ b/drivers/mmc/host/tifm_sd.c
@@ -111,14 +111,26 @@ struct tifm_sd {
 };
 
 /* for some reason, host won't respond correctly to readw/writew */
-static void tifm_sd_read_fifo(struct tifm_sd *host, struct page *pg,
+static void tifm_sd_read_fifo(struct tifm_sd *host, struct scatterlist *sg,
 			      unsigned int off, unsigned int cnt)
 {
 	struct tifm_dev *sock = host->dev;
 	unsigned char *buf;
 	unsigned int pos = 0, val;
 
-	buf = kmap_atomic(pg) + off;
+	buf = sg_map_offset(sg, off - sg->offset, SG_KMAP_ATOMIC);
+	if (IS_ERR(buf)) {
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
 	if (host->cmd_flags & DATA_CARRY) {
 		buf[pos++] = host->bounce_buf_data[0];
 		host->cmd_flags &= ~DATA_CARRY;
@@ -134,17 +146,29 @@ static void tifm_sd_read_fifo(struct tifm_sd *host, struct page *pg,
 		}
 		buf[pos++] = (val >> 8) & 0xff;
 	}
-	kunmap_atomic(buf - off);
+	sg_unmap_offset(sg, buf, off - sg->offset, SG_KMAP_ATOMIC);
 }
 
-static void tifm_sd_write_fifo(struct tifm_sd *host, struct page *pg,
+static void tifm_sd_write_fifo(struct tifm_sd *host, struct scatterlist *sg,
 			       unsigned int off, unsigned int cnt)
 {
 	struct tifm_dev *sock = host->dev;
 	unsigned char *buf;
 	unsigned int pos = 0, val;
 
-	buf = kmap_atomic(pg) + off;
+	buf = sg_map_offset(sg, off - sg->offset, SG_KMAP_ATOMIC);
+	if (IS_ERR(buf)) {
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
 	if (host->cmd_flags & DATA_CARRY) {
 		val = host->bounce_buf_data[0] | ((buf[pos++] << 8) & 0xff00);
 		writel(val, sock->addr + SOCK_MMCSD_DATA);
@@ -161,7 +185,7 @@ static void tifm_sd_write_fifo(struct tifm_sd *host, struct page *pg,
 		val |= (buf[pos++] << 8) & 0xff00;
 		writel(val, sock->addr + SOCK_MMCSD_DATA);
 	}
-	kunmap_atomic(buf - off);
+	sg_unmap_offset(sg, buf, off - sg->offset, SG_KMAP_ATOMIC);
 }
 
 static void tifm_sd_transfer_data(struct tifm_sd *host)
@@ -170,7 +194,6 @@ static void tifm_sd_transfer_data(struct tifm_sd *host)
 	struct scatterlist *sg = r_data->sg;
 	unsigned int off, cnt, t_size = TIFM_MMCSD_FIFO_SIZE * 2;
 	unsigned int p_off, p_cnt;
-	struct page *pg;
 
 	if (host->sg_pos == host->sg_len)
 		return;
@@ -192,33 +215,57 @@ static void tifm_sd_transfer_data(struct tifm_sd *host)
 		}
 		off = sg[host->sg_pos].offset + host->block_pos;
 
-		pg = nth_page(sg_page(&sg[host->sg_pos]), off >> PAGE_SHIFT);
 		p_off = offset_in_page(off);
 		p_cnt = PAGE_SIZE - p_off;
 		p_cnt = min(p_cnt, cnt);
 		p_cnt = min(p_cnt, t_size);
 
 		if (r_data->flags & MMC_DATA_READ)
-			tifm_sd_read_fifo(host, pg, p_off, p_cnt);
+			tifm_sd_read_fifo(host, &sg[host->sg_pos], p_off,
+					  p_cnt);
 		else if (r_data->flags & MMC_DATA_WRITE)
-			tifm_sd_write_fifo(host, pg, p_off, p_cnt);
+			tifm_sd_write_fifo(host, &sg[host->sg_pos], p_off,
+					   p_cnt);
 
 		t_size -= p_cnt;
 		host->block_pos += p_cnt;
 	}
 }
 
-static void tifm_sd_copy_page(struct page *dst, unsigned int dst_off,
-			      struct page *src, unsigned int src_off,
+static void tifm_sd_copy_page(struct scatterlist *dst, unsigned int dst_off,
+			      struct scatterlist *src, unsigned int src_off,
 			      unsigned int count)
 {
-	unsigned char *src_buf = kmap_atomic(src) + src_off;
-	unsigned char *dst_buf = kmap_atomic(dst) + dst_off;
+	unsigned char *src_buf, *dst_buf;
+
+	src_off -= src->offset;
+	dst_off -= dst->offset;
+
+	src_buf = sg_map_offset(src, src_off, SG_KMAP_ATOMIC);
+	if (IS_ERR(src_buf))
+		goto sg_map_err;
+
+	dst_buf = sg_map_offset(dst, dst_off, SG_KMAP_ATOMIC);
+	if (IS_ERR(dst_buf))
+		goto sg_map_err;
 
 	memcpy(dst_buf, src_buf, count);
 
-	kunmap_atomic(dst_buf - dst_off);
-	kunmap_atomic(src_buf - src_off);
+	sg_unmap_offset(dst, dst_buf, dst_off, SG_KMAP_ATOMIC);
+	sg_unmap_offset(src, src_buf, src_off, SG_KMAP_ATOMIC);
+
+sg_map_err:
+	if (!IS_ERR(src_buf))
+		sg_unmap_offset(src, src_buf, src_off, SG_KMAP_ATOMIC);
+
+	/*
+	 * This should really never happen unless
+	 * the code is changed to use memory that is
+	 * not mappable in the sg. Seeing there doesn't
+	 * seem to be any error path out of here,
+	 * we can only WARN.
+	 */
+	WARN(1, "Non-mappable memory used in sg!");
 }
 
 static void tifm_sd_bounce_block(struct tifm_sd *host, struct mmc_data *r_data)
@@ -227,7 +274,6 @@ static void tifm_sd_bounce_block(struct tifm_sd *host, struct mmc_data *r_data)
 	unsigned int t_size = r_data->blksz;
 	unsigned int off, cnt;
 	unsigned int p_off, p_cnt;
-	struct page *pg;
 
 	dev_dbg(&host->dev->dev, "bouncing block\n");
 	while (t_size) {
@@ -241,18 +287,18 @@ static void tifm_sd_bounce_block(struct tifm_sd *host, struct mmc_data *r_data)
 		}
 		off = sg[host->sg_pos].offset + host->block_pos;
 
-		pg = nth_page(sg_page(&sg[host->sg_pos]), off >> PAGE_SHIFT);
 		p_off = offset_in_page(off);
 		p_cnt = PAGE_SIZE - p_off;
 		p_cnt = min(p_cnt, cnt);
 		p_cnt = min(p_cnt, t_size);
 
 		if (r_data->flags & MMC_DATA_WRITE)
-			tifm_sd_copy_page(sg_page(&host->bounce_buf),
+			tifm_sd_copy_page(&host->bounce_buf,
 					  r_data->blksz - t_size,
-					  pg, p_off, p_cnt);
+					  &sg[host->sg_pos], p_off, p_cnt);
 		else if (r_data->flags & MMC_DATA_READ)
-			tifm_sd_copy_page(pg, p_off, sg_page(&host->bounce_buf),
+			tifm_sd_copy_page(&sg[host->sg_pos], p_off,
+					  &host->bounce_buf,
 					  r_data->blksz - t_size, p_cnt);
 
 		t_size -= p_cnt;
-- 
2.1.4
