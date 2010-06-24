From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 07/10] enic: Use receive queue buffer blocks of
	32/64 entries
Date: Thu, 24 Jun 2010 13:51:51 -0700
Message-ID: <20100624205148.22595.27702.stgit@savbu-pc100.cisco.com>
References: <20100624204723.22595.42990.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, scofeldm@cisco.com, vkolluri@cisco.com,
	roprabhu@cisco.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:55803 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753791Ab0FXUvv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 16:51:51 -0400
In-Reply-To: <20100624204723.22595.42990.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

Change the receive queue buffer allocations into blocks of 32 entries when
ring size is less than 64, otherwise use 64 entries per block.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
---
 drivers/net/enic/vnic_rq.c |   20 +++++++++++---------
 drivers/net/enic/vnic_rq.h |   14 +++++++++-----
 drivers/net/enic/vnic_wq.c |   15 ++++++++-------
 drivers/net/enic/vnic_wq.h |   14 +++++++++-----
 4 files changed, 37 insertions(+), 26 deletions(-)

diff --git a/drivers/net/enic/vnic_rq.c b/drivers/net/enic/vnic_rq.c
index 6d84ca8..45cfc79 100644
--- a/drivers/net/enic/vnic_rq.c
+++ b/drivers/net/enic/vnic_rq.c
@@ -37,7 +37,7 @@ static int vnic_rq_alloc_bufs(struct vnic_rq *rq)
 	vdev = rq->vdev;
 
 	for (i = 0; i < blks; i++) {
-		rq->bufs[i] = kzalloc(VNIC_RQ_BUF_BLK_SZ, GFP_ATOMIC);
+		rq->bufs[i] = kzalloc(VNIC_RQ_BUF_BLK_SZ(count), GFP_ATOMIC);
 		if (!rq->bufs[i]) {
 			pr_err("Failed to alloc rq_bufs\n");
 			return -ENOMEM;
@@ -46,14 +46,14 @@ static int vnic_rq_alloc_bufs(struct vnic_rq *rq)
 
 	for (i = 0; i < blks; i++) {
 		buf = rq->bufs[i];
-		for (j = 0; j < VNIC_RQ_BUF_BLK_ENTRIES; j++) {
-			buf->index = i * VNIC_RQ_BUF_BLK_ENTRIES + j;
+		for (j = 0; j < VNIC_RQ_BUF_BLK_ENTRIES(count); j++) {
+			buf->index = i * VNIC_RQ_BUF_BLK_ENTRIES(count) + j;
 			buf->desc = (u8 *)rq->ring.descs +
 				rq->ring.desc_size * buf->index;
 			if (buf->index + 1 == count) {
 				buf->next = rq->bufs[0];
 				break;
-			} else if (j + 1 == VNIC_RQ_BUF_BLK_ENTRIES) {
+			} else if (j + 1 == VNIC_RQ_BUF_BLK_ENTRIES(count)) {
 				buf->next = rq->bufs[i + 1];
 			} else {
 				buf->next = buf + 1;
@@ -119,10 +119,11 @@ void vnic_rq_init_start(struct vnic_rq *rq, unsigned int cq_index,
 	unsigned int error_interrupt_offset)
 {
 	u64 paddr;
+	unsigned int count = rq->ring.desc_count;
 
 	paddr = (u64)rq->ring.base_addr | VNIC_PADDR_TARGET;
 	writeq(paddr, &rq->ctrl->ring_base);
-	iowrite32(rq->ring.desc_count, &rq->ctrl->ring_size);
+	iowrite32(count, &rq->ctrl->ring_size);
 	iowrite32(cq_index, &rq->ctrl->cq_index);
 	iowrite32(error_interrupt_enable, &rq->ctrl->error_interrupt_enable);
 	iowrite32(error_interrupt_offset, &rq->ctrl->error_interrupt_offset);
@@ -132,8 +133,8 @@ void vnic_rq_init_start(struct vnic_rq *rq, unsigned int cq_index,
 	iowrite32(posted_index, &rq->ctrl->posted_index);
 
 	rq->to_use = rq->to_clean =
-		&rq->bufs[fetch_index / VNIC_RQ_BUF_BLK_ENTRIES]
-			[fetch_index % VNIC_RQ_BUF_BLK_ENTRIES];
+		&rq->bufs[fetch_index / VNIC_RQ_BUF_BLK_ENTRIES(count)]
+			[fetch_index % VNIC_RQ_BUF_BLK_ENTRIES(count)];
 }
 
 void vnic_rq_init(struct vnic_rq *rq, unsigned int cq_index,
@@ -184,6 +185,7 @@ void vnic_rq_clean(struct vnic_rq *rq,
 {
 	struct vnic_rq_buf *buf;
 	u32 fetch_index;
+	unsigned int count = rq->ring.desc_count;
 
 	BUG_ON(ioread32(&rq->ctrl->enable));
 
@@ -200,8 +202,8 @@ void vnic_rq_clean(struct vnic_rq *rq,
 	/* Use current fetch_index as the ring starting point */
 	fetch_index = ioread32(&rq->ctrl->fetch_index);
 	rq->to_use = rq->to_clean =
-		&rq->bufs[fetch_index / VNIC_RQ_BUF_BLK_ENTRIES]
-			[fetch_index % VNIC_RQ_BUF_BLK_ENTRIES];
+		&rq->bufs[fetch_index / VNIC_RQ_BUF_BLK_ENTRIES(count)]
+			[fetch_index % VNIC_RQ_BUF_BLK_ENTRIES(count)];
 	iowrite32(fetch_index, &rq->ctrl->posted_index);
 
 	vnic_dev_clear_desc_ring(&rq->ring);
diff --git a/drivers/net/enic/vnic_rq.h b/drivers/net/enic/vnic_rq.h
index 35e736c..8f0fb78 100644
--- a/drivers/net/enic/vnic_rq.h
+++ b/drivers/net/enic/vnic_rq.h
@@ -52,12 +52,16 @@ struct vnic_rq_ctrl {
 	u32 pad10;
 };
 
-/* Break the vnic_rq_buf allocations into blocks of 64 entries */
-#define VNIC_RQ_BUF_BLK_ENTRIES 64
-#define VNIC_RQ_BUF_BLK_SZ \
-	(VNIC_RQ_BUF_BLK_ENTRIES * sizeof(struct vnic_rq_buf))
+/* Break the vnic_rq_buf allocations into blocks of 32/64 entries */
+#define VNIC_RQ_BUF_MIN_BLK_ENTRIES 32
+#define VNIC_RQ_BUF_DFLT_BLK_ENTRIES 64
+#define VNIC_RQ_BUF_BLK_ENTRIES(entries) \
+	((unsigned int)((entries < VNIC_RQ_BUF_DFLT_BLK_ENTRIES) ? \
+	VNIC_RQ_BUF_MIN_BLK_ENTRIES : VNIC_RQ_BUF_DFLT_BLK_ENTRIES))
+#define VNIC_RQ_BUF_BLK_SZ(entries) \
+	(VNIC_RQ_BUF_BLK_ENTRIES(entries) * sizeof(struct vnic_rq_buf))
 #define VNIC_RQ_BUF_BLKS_NEEDED(entries) \
-	DIV_ROUND_UP(entries, VNIC_RQ_BUF_BLK_ENTRIES)
+	DIV_ROUND_UP(entries, VNIC_RQ_BUF_BLK_ENTRIES(entries))
 #define VNIC_RQ_BUF_BLKS_MAX VNIC_RQ_BUF_BLKS_NEEDED(4096)
 
 struct vnic_rq_buf {
diff --git a/drivers/net/enic/vnic_wq.c b/drivers/net/enic/vnic_wq.c
index ed090a3..6c4d4f7 100644
--- a/drivers/net/enic/vnic_wq.c
+++ b/drivers/net/enic/vnic_wq.c
@@ -37,7 +37,7 @@ static int vnic_wq_alloc_bufs(struct vnic_wq *wq)
 	vdev = wq->vdev;
 
 	for (i = 0; i < blks; i++) {
-		wq->bufs[i] = kzalloc(VNIC_WQ_BUF_BLK_SZ, GFP_ATOMIC);
+		wq->bufs[i] = kzalloc(VNIC_WQ_BUF_BLK_SZ(count), GFP_ATOMIC);
 		if (!wq->bufs[i]) {
 			pr_err("Failed to alloc wq_bufs\n");
 			return -ENOMEM;
@@ -46,14 +46,14 @@ static int vnic_wq_alloc_bufs(struct vnic_wq *wq)
 
 	for (i = 0; i < blks; i++) {
 		buf = wq->bufs[i];
-		for (j = 0; j < VNIC_WQ_BUF_BLK_ENTRIES; j++) {
-			buf->index = i * VNIC_WQ_BUF_BLK_ENTRIES + j;
+		for (j = 0; j < VNIC_WQ_BUF_BLK_ENTRIES(count); j++) {
+			buf->index = i * VNIC_WQ_BUF_BLK_ENTRIES(count) + j;
 			buf->desc = (u8 *)wq->ring.descs +
 				wq->ring.desc_size * buf->index;
 			if (buf->index + 1 == count) {
 				buf->next = wq->bufs[0];
 				break;
-			} else if (j + 1 == VNIC_WQ_BUF_BLK_ENTRIES) {
+			} else if (j + 1 == VNIC_WQ_BUF_BLK_ENTRIES(count)) {
 				buf->next = wq->bufs[i + 1];
 			} else {
 				buf->next = buf + 1;
@@ -119,10 +119,11 @@ void vnic_wq_init_start(struct vnic_wq *wq, unsigned int cq_index,
 	unsigned int error_interrupt_offset)
 {
 	u64 paddr;
+	unsigned int count = wq->ring.desc_count;
 
 	paddr = (u64)wq->ring.base_addr | VNIC_PADDR_TARGET;
 	writeq(paddr, &wq->ctrl->ring_base);
-	iowrite32(wq->ring.desc_count, &wq->ctrl->ring_size);
+	iowrite32(count, &wq->ctrl->ring_size);
 	iowrite32(fetch_index, &wq->ctrl->fetch_index);
 	iowrite32(posted_index, &wq->ctrl->posted_index);
 	iowrite32(cq_index, &wq->ctrl->cq_index);
@@ -131,8 +132,8 @@ void vnic_wq_init_start(struct vnic_wq *wq, unsigned int cq_index,
 	iowrite32(0, &wq->ctrl->error_status);
 
 	wq->to_use = wq->to_clean =
-		&wq->bufs[fetch_index / VNIC_WQ_BUF_BLK_ENTRIES]
-			[fetch_index % VNIC_WQ_BUF_BLK_ENTRIES];
+		&wq->bufs[fetch_index / VNIC_WQ_BUF_BLK_ENTRIES(count)]
+			[fetch_index % VNIC_WQ_BUF_BLK_ENTRIES(count)];
 }
 
 void vnic_wq_init(struct vnic_wq *wq, unsigned int cq_index,
diff --git a/drivers/net/enic/vnic_wq.h b/drivers/net/enic/vnic_wq.h
index 9c34d41..1c82139 100644
--- a/drivers/net/enic/vnic_wq.h
+++ b/drivers/net/enic/vnic_wq.h
@@ -60,12 +60,16 @@ struct vnic_wq_buf {
 	void *desc;
 };
 
-/* Break the vnic_wq_buf allocations into blocks of 64 entries */
-#define VNIC_WQ_BUF_BLK_ENTRIES 64
-#define VNIC_WQ_BUF_BLK_SZ \
-	(VNIC_WQ_BUF_BLK_ENTRIES * sizeof(struct vnic_wq_buf))
+/* Break the vnic_wq_buf allocations into blocks of 32/64 entries */
+#define VNIC_WQ_BUF_MIN_BLK_ENTRIES 32
+#define VNIC_WQ_BUF_DFLT_BLK_ENTRIES 64
+#define VNIC_WQ_BUF_BLK_ENTRIES(entries) \
+	((unsigned int)((entries < VNIC_WQ_BUF_DFLT_BLK_ENTRIES) ? \
+	VNIC_WQ_BUF_MIN_BLK_ENTRIES : VNIC_WQ_BUF_DFLT_BLK_ENTRIES))
+#define VNIC_WQ_BUF_BLK_SZ(entries) \
+	(VNIC_WQ_BUF_BLK_ENTRIES(entries) * sizeof(struct vnic_wq_buf))
 #define VNIC_WQ_BUF_BLKS_NEEDED(entries) \
-	DIV_ROUND_UP(entries, VNIC_WQ_BUF_BLK_ENTRIES)
+	DIV_ROUND_UP(entries, VNIC_WQ_BUF_BLK_ENTRIES(entries))
 #define VNIC_WQ_BUF_BLKS_MAX VNIC_WQ_BUF_BLKS_NEEDED(4096)
 
 struct vnic_wq {

