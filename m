From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 5/9] cxgbi: convert to SKB paged frag API.
Date: Mon, 10 Oct 2011 12:11:37 +0100
Message-ID: <1318245101-16890-5-git-send-email-ian.campbell@citrix.com>
References: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	"James E.J. Bottomley" <JBottomley@parallels.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mike Christie <michaelc@cs.wisc.edu>,
	James Bottomley <James.Bottomley@suse.de>,
	Karen Xie <kxie@chelsio.com>, linux-scsi@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:44685 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753714Ab1JJLLv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 07:11:51 -0400
In-Reply-To: <1318245076.21903.408.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: "James E.J. Bottomley" <JBottomley@parallels.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Mike Christie <michaelc@cs.wisc.edu>
Cc: James Bottomley <James.Bottomley@suse.de>
Cc: Karen Xie <kxie@chelsio.com>
Cc: linux-scsi@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 drivers/scsi/cxgbi/libcxgbi.c |   16 +++++++++-------
 drivers/scsi/cxgbi/libcxgbi.h |    2 +-
 2 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/scsi/cxgbi/libcxgbi.c b/drivers/scsi/cxgbi/libcxgbi.c
index 77ac217..628b23d 100644
--- a/drivers/scsi/cxgbi/libcxgbi.c
+++ b/drivers/scsi/cxgbi/libcxgbi.c
@@ -1787,7 +1787,7 @@ static int sgl_seek_offset(struct scatterlist *sgl, unsigned int sgcnt,
 }
 
 static int sgl_read_to_frags(struct scatterlist *sg, unsigned int sgoffset,
-				unsigned int dlen, skb_frag_t *frags,
+				unsigned int dlen, struct subpage *frags,
 				int frag_max)
 {
 	unsigned int datalen = dlen;
@@ -1944,7 +1944,7 @@ int cxgbi_conn_init_pdu(struct iscsi_task *task, unsigned int offset,
 		if (tdata->nr_frags > MAX_SKB_FRAGS ||
 		    (padlen && tdata->nr_frags == MAX_SKB_FRAGS)) {
 			char *dst = skb->data + task->hdr_len;
-			skb_frag_t *frag = tdata->frags;
+			struct subpage *frag = tdata->frags;
 
 			/* data fits in the skb's headroom */
 			for (i = 0; i < tdata->nr_frags; i++, frag++) {
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
+						tdata->frags[i].page_offset,
+						tdata->frags[i].size);
+				skb_frag_ref(skb, i);
+			}
 			skb_shinfo(skb)->nr_frags = tdata->nr_frags;
 			skb->len += count;
 			skb->data_len += count;
diff --git a/drivers/scsi/cxgbi/libcxgbi.h b/drivers/scsi/cxgbi/libcxgbi.h
index 9267844..9406759 100644
--- a/drivers/scsi/cxgbi/libcxgbi.h
+++ b/drivers/scsi/cxgbi/libcxgbi.h
@@ -574,7 +574,7 @@ struct cxgbi_endpoint {
 #define MAX_PDU_FRAGS	((ULP2_MAX_PDU_PAYLOAD + 512 - 1) / 512)
 struct cxgbi_task_data {
 	unsigned short nr_frags;
-	skb_frag_t frags[MAX_PDU_FRAGS];
+	struct subpage frags[MAX_PDU_FRAGS];
 	struct sk_buff *skb;
 	unsigned int offset;
 	unsigned int count;
-- 
1.7.2.5
