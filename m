From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net-next 1/3] enic: make vnic_wq_buf doubly linked
Date: Wed, 24 Dec 2014 15:59:36 +0530
Message-ID: <1419416978-1008-2-git-send-email-_govind@gmx.com>
References: <1419416978-1008-1-git-send-email-_govind@gmx.com>
Cc: ssujith@cisco.com, benve@cisco.com,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org, sassmann@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.com ([74.208.4.201]:65174 "EHLO mout.gmx.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751071AbaLXKaY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Dec 2014 05:30:24 -0500
In-Reply-To: <1419416978-1008-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes vnic_wq_buf doubly liked list. This is needed for dma_mapping
error check, in case some frag's dma map fails, we need to move back and remove
previously queued buffers.

Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/vnic_wq.c | 3 +++
 drivers/net/ethernet/cisco/enic/vnic_wq.h | 1 +
 2 files changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/cisco/enic/vnic_wq.c b/drivers/net/ethernet/cisco/enic/vnic_wq.c
index 3e6b8d5..b5a1c93 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_wq.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_wq.c
@@ -47,11 +47,14 @@ static int vnic_wq_alloc_bufs(struct vnic_wq *wq)
 				wq->ring.desc_size * buf->index;
 			if (buf->index + 1 == count) {
 				buf->next = wq->bufs[0];
+				buf->next->prev = buf;
 				break;
 			} else if (j + 1 == VNIC_WQ_BUF_BLK_ENTRIES(count)) {
 				buf->next = wq->bufs[i + 1];
+				buf->next->prev = buf;
 			} else {
 				buf->next = buf + 1;
+				buf->next->prev = buf;
 				buf++;
 			}
 		}
diff --git a/drivers/net/ethernet/cisco/enic/vnic_wq.h b/drivers/net/ethernet/cisco/enic/vnic_wq.h
index 816f1ad..2961543 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_wq.h
+++ b/drivers/net/ethernet/cisco/enic/vnic_wq.h
@@ -62,6 +62,7 @@ struct vnic_wq_buf {
 	uint8_t cq_entry; /* Gets completion event from hw */
 	uint8_t desc_skip_cnt; /* Num descs to occupy */
 	uint8_t compressed_send; /* Both hdr and payload in one desc */
+	struct vnic_wq_buf *prev;
 };
 
 /* Break the vnic_wq_buf allocations into blocks of 32/64 entries */
-- 
2.2.1
