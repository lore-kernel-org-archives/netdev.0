From: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
Subject: [PATCH 03/22] libiscsi: Make use of new the sg_map helper function
Date: Thu, 13 Apr 2017 16:05:16 -0600
Message-ID: <1492121135-4437-4-git-send-email-logang@deltatee.com>
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

Convert the kmap and kmap_atomic uses to the sg_map function. We now
store the flags for the kmap instead of a boolean to indicate
atomicitiy. We also propogate a possible kmap error down and create
a new ISCSI_TCP_INTERNAL_ERR error type for this.

Signed-off-by: Logan Gunthorpe <logang-OTvnGxWRz7hWk0Htik3J/w@public.gmane.org>
---
 drivers/scsi/cxgbi/libcxgbi.c |  5 +++++
 drivers/scsi/libiscsi_tcp.c   | 32 ++++++++++++++++++++------------
 include/scsi/libiscsi_tcp.h   |  3 ++-
 3 files changed, 27 insertions(+), 13 deletions(-)

diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index bd7d39e..e38d0c1 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -1556,6 +1556,11 @@ static inline int read_pdu_skb(struct iscsi_conn *conn,
 		 */
 		iscsi_conn_printk(KERN_ERR, conn, "Invalid pdu or skb.");
 		return -EFAULT;
+	case ISCSI_TCP_INTERNAL_ERR:
+		pr_info("skb 0x%p, off %u, %d, TCP_INTERNAL_ERR.\n",
+			skb, offset, offloaded);
+		iscsi_conn_printk(KERN_ERR, conn, "Internal error.");
+		return -EFAULT;
 	case ISCSI_TCP_SEGMENT_DONE:
 		log_debug(1 << CXGBI_DBG_PDU_RX,
 			"skb 0x%p, off %u, %d, TCP_SEG_DONE, rc %d.\n",
diff --git a/drivers/scsi/libiscsi_tcp.c b/drivers/scsi/libiscsi_tcp.c
index 63a1d69..a2427699 100644
--- a/drivers/scsi/libiscsi_tcp.c
+++ b/drivers/scsi/libiscsi_tcp.c
@@ -133,25 +133,23 @@ static void iscsi_tcp_segment_map(struct iscsi_segment *segment, int recv)
 	if (page_count(sg_page(sg)) >= 1 && !recv)
 		return;
 
-	if (recv) {
-		segment->atomic_mapped = true;
-		segment->sg_mapped = kmap_atomic(sg_page(sg));
-	} else {
-		segment->atomic_mapped = false;
-		/* the xmit path can sleep with the page mapped so use kmap */
-		segment->sg_mapped = kmap(sg_page(sg));
+	/* the xmit path can sleep with the page mapped so don't use atomic */
+	segment->sg_map_flags = recv ? SG_KMAP_ATOMIC : SG_KMAP;
+	segment->sg_mapped = sg_map(sg, segment->sg_map_flags);
+
+	if (IS_ERR(segment->sg_mapped)) {
+		segment->sg_mapped = NULL;
+		return;
 	}
 
-	segment->data = segment->sg_mapped + sg->offset + segment->sg_offset;
+	segment->data = segment->sg_mapped + segment->sg_offset;
 }
 
 void iscsi_tcp_segment_unmap(struct iscsi_segment *segment)
 {
 	if (segment->sg_mapped) {
-		if (segment->atomic_mapped)
-			kunmap_atomic(segment->sg_mapped);
-		else
-			kunmap(sg_page(segment->sg));
+		sg_unmap(segment->sg, segment->sg_mapped,
+			  segment->sg_map_flags);
 		segment->sg_mapped = NULL;
 		segment->data = NULL;
 	}
@@ -304,6 +302,9 @@ iscsi_tcp_segment_recv(struct iscsi_tcp_conn *tcp_conn,
 			break;
 		}
 
+		if (segment->data)
+			return -EFAULT;
+
 		copy = min(len - copied, segment->size - segment->copied);
 		ISCSI_DBG_TCP(tcp_conn->iscsi_conn, "copying %d\n", copy);
 		memcpy(segment->data + segment->copied, ptr + copied, copy);
@@ -927,6 +928,13 @@ int iscsi_tcp_recv_skb(struct iscsi_conn *conn, struct sk_buff *skb,
 			      avail);
 		rc = iscsi_tcp_segment_recv(tcp_conn, segment, ptr, avail);
 		BUG_ON(rc == 0);
+		if (rc < 0) {
+			ISCSI_DBG_TCP(conn, "memory fault. Consumed %d\n",
+				      consumed);
+			*status = ISCSI_TCP_INTERNAL_ERR;
+			goto skb_done;
+		}
+
 		consumed += rc;
 
 		if (segment->total_copied >= segment->total_size) {
diff --git a/include/scsi/libiscsi_tcp.h b/include/scsi/libiscsi_tcp.h
index 30520d5..58c79af 100644
--- a/include/scsi/libiscsi_tcp.h
+++ b/include/scsi/libiscsi_tcp.h
@@ -47,7 +47,7 @@ struct iscsi_segment {
 	struct scatterlist	*sg;
 	void			*sg_mapped;
 	unsigned int		sg_offset;
-	bool			atomic_mapped;
+	int			sg_map_flags;
 
 	iscsi_segment_done_fn_t	*done;
 };
@@ -92,6 +92,7 @@ enum {
 	ISCSI_TCP_SKB_DONE,		/* skb is out of data */
 	ISCSI_TCP_CONN_ERR,		/* iscsi layer has fired a conn err */
 	ISCSI_TCP_SUSPENDED,		/* conn is suspended */
+	ISCSI_TCP_INTERNAL_ERR,         /* an internal error occurred */
 };
 
 extern void iscsi_tcp_hdr_recv_prep(struct iscsi_tcp_conn *tcp_conn);
-- 
2.1.4
