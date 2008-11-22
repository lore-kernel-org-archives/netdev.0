From: Scott Feldman <scofeldm@cisco.com>
Subject: [PATCH 4/5] enic: move wmb closer to where needed: before writing
	posted_index to hw
Date: Fri, 21 Nov 2008 16:34:13 -0800
Message-ID: <20081122003413.15540.83477.stgit@palito_client100.nuovasystems.com>
References: <20081122003219.15540.26759.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:43497 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754722AbYKVAlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 19:41:46 -0500
In-Reply-To: <20081122003219.15540.26759.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enic: move wmb closer to where needed: before writing posted_index to hw



Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/enic_res.h |    4 ----
 drivers/net/enic/vnic_rq.h  |    9 ++++++++-
 drivers/net/enic/vnic_wq.h  |    9 ++++++++-
 3 files changed, 16 insertions(+), 6 deletions(-)

diff --git a/drivers/net/enic/enic_res.h b/drivers/net/enic/enic_res.h
index 68534a2..7bf272f 100644
--- a/drivers/net/enic/enic_res.h
+++ b/drivers/net/enic/enic_res.h
@@ -58,8 +58,6 @@ static inline void enic_queue_wq_desc_ex(struct vnic_wq *wq,
 		(u16)vlan_tag,
 		0 /* loopback */);
 
-	wmb();
-
 	vnic_wq_post(wq, os_buf, dma_addr, len, sop, eop);
 }
 
@@ -127,8 +125,6 @@ static inline void enic_queue_rq_desc(struct vnic_rq *rq,
 		(u64)dma_addr | VNIC_PADDR_TARGET,
 		type, (u16)len);
 
-	wmb();
-
 	vnic_rq_post(rq, os_buf, os_buf_index, dma_addr, len);
 }
 
diff --git a/drivers/net/enic/vnic_rq.h b/drivers/net/enic/vnic_rq.h
index 82bfca6..fd0ef66 100644
--- a/drivers/net/enic/vnic_rq.h
+++ b/drivers/net/enic/vnic_rq.h
@@ -132,8 +132,15 @@ static inline void vnic_rq_post(struct vnic_rq *rq,
 #define VNIC_RQ_RETURN_RATE		0xf	/* keep 2^n - 1 */
 #endif
 
-	if ((buf->index & VNIC_RQ_RETURN_RATE) == 0)
+	if ((buf->index & VNIC_RQ_RETURN_RATE) == 0) {
+		/* Adding write memory barrier prevents compiler and/or CPU
+		 * reordering, thus avoiding descriptor posting before
+		 * descriptor is initialized. Otherwise, hardware can read
+		 * stale descriptor fields.
+		 */
+		wmb();
 		iowrite32(buf->index, &rq->ctrl->posted_index);
+	}
 }
 
 static inline void vnic_rq_return_descs(struct vnic_rq *rq, unsigned int count)
diff --git a/drivers/net/enic/vnic_wq.h b/drivers/net/enic/vnic_wq.h
index 7081828..c826137 100644
--- a/drivers/net/enic/vnic_wq.h
+++ b/drivers/net/enic/vnic_wq.h
@@ -108,8 +108,15 @@ static inline void vnic_wq_post(struct vnic_wq *wq,
 	buf->len = len;
 
 	buf = buf->next;
-	if (eop)
+	if (eop) {
+		/* Adding write memory barrier prevents compiler and/or CPU
+		 * reordering, thus avoiding descriptor posting before
+		 * descriptor is initialized. Otherwise, hardware can read
+		 * stale descriptor fields.
+		 */
+		wmb();
 		iowrite32(buf->index, &wq->ctrl->posted_index);
+	}
 	wq->to_use = buf;
 
 	wq->ring.desc_avail--;

