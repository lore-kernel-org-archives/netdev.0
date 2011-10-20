From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 5/6] cxgbi: convert to SKB paged frag API.
Date: Thu, 20 Oct 2011 10:01:48 +0100
Message-ID: <1319101309-28431-5-git-send-email-ian.campbell@citrix.com>
References: <1319101275.3385.129.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mike Christie <michaelc@cs.wisc.edu>,
	James Bottomley <James.Bottomley@suse.de>,
	Karen Xie <kxie@chelsio.com>, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <1319101275.3385.129.camel@zakaz.uk.xensource.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: "James E.J. Bottomley" <JBottomley@parallels.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Mike Christie <michaelc@cs.wisc.edu>
Cc: James Bottomley <James.Bottomley@suse.de>
Cc: Karen Xie <kxie@chelsio.com>
Cc: linux-scsi@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 drivers/scsi/cxgbi/libcxgbi.c |   28 +++++++++++++++-------------
 drivers/scsi/cxgbi/libcxgbi.h |    2 +-
 2 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index be69da3..1c1329b 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -1787,7 +1787,7 @@ static int sgl_seek_offset(struct scatterlist *sgl, unsigned int sgcnt,
 }
 
 static int sgl_read_to_frags(struct scatterlist *sg, unsigned int sgoffset,
-				unsigned int dlen, skb_frag_t *frags,
+				unsigned int dlen, struct page_frag *frags,
 				int frag_max)
 {
 	unsigned int datalen = dlen;
@@ -1814,8 +1814,8 @@ static int sgl_read_to_frags(struct scatterlist *sg, unsigned int sgoffset,
 		copy = min(datalen, sglen);
 		if (i && page == frags[i - 1].page &&
 		    sgoffset + sg->offset ==
-			frags[i - 1].page_offset + skb_frag_size(&frags[i - 1])) {
-			skb_frag_size_add(&frags[i - 1], copy);
+			frags[i - 1].offset + frags[i - 1].size) {
+			frags[i - 1].size += copy;
 		} else {
 			if (i >= frag_max) {
 				pr_warn("too many pages %u, dlen %u.\n",
@@ -1824,8 +1824,8 @@ static int sgl_read_to_frags(struct scatterlist *sg, unsigned int sgoffset,
 			}
 
 			frags[i].page = page;
-			frags[i].page_offset = sg->offset + sgoffset;
-			skb_frag_size_set(&frags[i], copy);
+			frags[i].offset = sg->offset + sgoffset;
+			frags[i].size = copy;
 			i++;
 		}
 		datalen -= copy;
@@ -1944,15 +1944,15 @@ int cxgbi_conn_init_pdu(struct iscsi_task *task, unsigned int offset,
 		if (tdata->nr_frags > MAX_SKB_FRAGS ||
 		    (padlen && tdata->nr_frags == MAX_SKB_FRAGS)) {
 			char *dst = skb->data + task->hdr_len;
-			skb_frag_t *frag = tdata->frags;
+			struct page_frag *frag = tdata->frags;
 
 			/* data fits in the skb's headroom */
 			for (i = 0; i < tdata->nr_frags; i++, frag++) {
 				char *src = kmap_atomic(frag->page,
 							KM_SOFTIRQ0);
 
-				memcpy(dst, src+frag->page_offset, skb_frag_size(frag));
-				dst += skb_frag_size(frag);
+				memcpy(dst, src+frag->offset, frag->size);
+				dst += frag->size;
 				kunmap_atomic(src, KM_SOFTIRQ0);
 			}
 			if (padlen) {
@@ -1962,11 +1962,13 @@ int cxgbi_conn_init_pdu(struct iscsi_task *task, unsigned int offset,
 			skb_put(skb, count + padlen);
 		} else {
 			/* data fit into frag_list */
-			for (i = 0; i < tdata->nr_frags; i++)
-				get_page(tdata->frags[i].page);
-
-			memcpy(skb_shinfo(skb)->frags, tdata->frags,
-				sizeof(skb_frag_t) * tdata->nr_frags);
+			for (i = 0; i < tdata->nr_frags; i++) {
+				__skb_fill_page_desc(skb, i,
+						tdata->frags[i].page,
+						tdata->frags[i].offset,
+						tdata->frags[i].size);
+				skb_frag_ref(skb, i);
+			}
 			skb_shinfo(skb)->nr_frags = tdata->nr_frags;
 			skb->len += count;
 			skb->data_len += count;
diff --git a/drivers/scsi/cxgbi/libcxgbi.h b/drivers/scsi/cxgbi/libcxgbi.h
index 9267844..3a25b11 100644
--- a/drivers/scsi/cxgbi/libcxgbi.h
+++ b/drivers/scsi/cxgbi/libcxgbi.h
@@ -574,7 +574,7 @@ struct cxgbi_endpoint {
 #define MAX_PDU_FRAGS	((ULP2_MAX_PDU_PAYLOAD + 512 - 1) / 512)
 struct cxgbi_task_data {
 	unsigned short nr_frags;
-	skb_frag_t frags[MAX_PDU_FRAGS];
+	struct page_frag frags[MAX_PDU_FRAGS];
 	struct sk_buff *skb;
 	unsigned int offset;
 	unsigned int count;
-- 
1.7.2.5

