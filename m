From: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
Subject: [PATCH v2 10/21] RDS: Make use of the new sg_map helper function
Date: Tue, 25 Apr 2017 12:20:57 -0600
Message-ID: <1493144468-22493-11-git-send-email-logang@deltatee.com>
References: <1493144468-22493-1-git-send-email-logang@deltatee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>,
 "James E.J. Bottomley" <jejb-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
 "Martin K. Petersen" <martin.petersen-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
 Matthew Wilcox <mawilcox-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>,
 Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
 Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
 Sumit Semwal <sumit.semwal-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
 "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-crypto-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
 intel-gfx-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org, linux-raid-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-mmc-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nvdimm-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org,
 linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, open-iscsi-/JYPxA39Uh5TLH3MbocFFw@public.gmane.org,
 megaraidlinux.pdl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org, sparmaintainer-GLv8BlqOqDDQT0dZR+AlfA@public.gmane.org,
 devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org, target-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org
Return-path: <linux-nvdimm-bounces-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org>
In-Reply-To: <1493144468-22493-1-git-send-email-logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
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

Straightforward conversion except there's no error path, so we
make use of SG_MAP_MUST_NOT_FAIL which may BUG_ON in certain cases
in the future.

Signed-off-by: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
Cc: Santosh Shilimkar <santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 net/rds/ib_recv.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/rds/ib_recv.c b/net/rds/ib_recv.c
index e10624a..c665689 100644
--- a/net/rds/ib_recv.c
+++ b/net/rds/ib_recv.c
@@ -800,10 +800,10 @@ static void rds_ib_cong_recv(struct rds_connection *conn,
 
 		to_copy = min(RDS_FRAG_SIZE - frag_off, PAGE_SIZE - map_off);
 		BUG_ON(to_copy & 7); /* Must be 64bit aligned. */
+		addr = sg_map(&frag->f_sg, 0,
+			      SG_KMAP_ATOMIC | SG_MAP_MUST_NOT_FAIL);
 
-		addr = kmap_atomic(sg_page(&frag->f_sg));
-
-		src = addr + frag->f_sg.offset + frag_off;
+		src = addr + frag_off;
 		dst = (void *)map->m_page_addrs[map_page] + map_off;
 		for (k = 0; k < to_copy; k += 8) {
 			/* Record ports that became uncongested, ie
@@ -811,7 +811,7 @@ static void rds_ib_cong_recv(struct rds_connection *conn,
 			uncongested |= ~(*src) & *dst;
 			*dst++ = *src++;
 		}
-		kunmap_atomic(addr);
+		sg_unmap(&frag->f_sg, addr, 0, SG_KMAP_ATOMIC);
 
 		copied += to_copy;
 
-- 
2.1.4
