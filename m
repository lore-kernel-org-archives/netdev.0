From: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 07/22] crypto: shash,
 caam: Make use of the new sg_map helper function
Date: Thu, 13 Apr 2017 16:05:20 -0600
Message-ID: <1492121135-4437-8-git-send-email-logang@deltatee.com>
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

Very straightforward conversion to the new function in two crypto
drivers.

Signed-off-by: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
---
 crypto/shash.c                | 9 ++++++---
 drivers/crypto/caam/caamalg.c | 8 +++-----
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/crypto/shash.c b/crypto/shash.c
index 5e31c8d..2b7de94 100644
--- a/crypto/shash.c
+++ b/crypto/shash.c
@@ -283,10 +283,13 @@ int shash_ahash_digest(struct ahash_request *req, struct shash_desc *desc)
 	if (nbytes < min(sg->length, ((unsigned int)(PAGE_SIZE)) - offset)) {
 		void *data;
 
-		data = kmap_atomic(sg_page(sg));
-		err = crypto_shash_digest(desc, data + offset, nbytes,
+		data = sg_map(sg, SG_KMAP_ATOMIC);
+		if (IS_ERR(data))
+			return PTR_ERR(data);
+
+		err = crypto_shash_digest(desc, data, nbytes,
 					  req->result);
-		kunmap_atomic(data);
+		sg_unmap(sg, data, SG_KMAP_ATOMIC);
 		crypto_yield(desc->flags);
 	} else
 		err = crypto_shash_init(desc) ?:
diff --git a/drivers/crypto/caam/caamalg.c b/drivers/crypto/caam/caamalg.c
index 9bc80eb..76b97de 100644
--- a/drivers/crypto/caam/caamalg.c
+++ b/drivers/crypto/caam/caamalg.c
@@ -89,7 +89,6 @@ static void dbg_dump_sg(const char *level, const char *prefix_str,
 			struct scatterlist *sg, size_t tlen, bool ascii)
 {
 	struct scatterlist *it;
-	void *it_page;
 	size_t len;
 	void *buf;
 
@@ -98,19 +97,18 @@ static void dbg_dump_sg(const char *level, const char *prefix_str,
 		 * make sure the scatterlist's page
 		 * has a valid virtual memory mapping
 		 */
-		it_page = kmap_atomic(sg_page(it));
-		if (unlikely(!it_page)) {
+		buf = sg_map(it, SG_KMAP_ATOMIC);
+		if (IS_ERR(buf)) {
 			printk(KERN_ERR "dbg_dump_sg: kmap failed\n");
 			return;
 		}
 
-		buf = it_page + it->offset;
 		len = min_t(size_t, tlen, it->length);
 		print_hex_dump(level, prefix_str, prefix_type, rowsize,
 			       groupsize, buf, len, ascii);
 		tlen -= len;
 
-		kunmap_atomic(it_page);
+		sg_unmap(it, buf, SG_KMAP_ATOMIC);
 	}
 }
 #endif
-- 
2.1.4
