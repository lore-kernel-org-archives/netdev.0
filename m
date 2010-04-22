From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 6/8] qlcnic: fix rcv buffer leak
Date: Thu, 22 Apr 2010 05:51:40 -0700
Message-ID: <1271940702-17064-7-git-send-email-amit.salecha@qlogic.com>
References: <1271940702-17064-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:59360 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754587Ab0DVMvp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Apr 2010 08:51:45 -0400
In-Reply-To: <1271940702-17064-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rcv producer value should be read in spin-lock.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_init.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 9ef9f58..1b621ca 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -1554,9 +1554,10 @@ qlcnic_post_rx_buffers(struct qlcnic_adapter *adapter, u32 ringid,
 	int producer, count = 0;
 	struct list_head *head;
 
+	spin_lock(&rds_ring->lock);
+
 	producer = rds_ring->producer;
 
-	spin_lock(&rds_ring->lock);
 	head = &rds_ring->free_list;
 	while (!list_empty(head)) {
 
@@ -1578,13 +1579,13 @@ qlcnic_post_rx_buffers(struct qlcnic_adapter *adapter, u32 ringid,
 
 		producer = get_next_index(producer, rds_ring->num_desc);
 	}
-	spin_unlock(&rds_ring->lock);
 
 	if (count) {
 		rds_ring->producer = producer;
 		writel((producer-1) & (rds_ring->num_desc-1),
 				rds_ring->crb_rcv_producer);
 	}
+	spin_unlock(&rds_ring->lock);
 }
 
 static void
@@ -1596,10 +1597,11 @@ qlcnic_post_rx_buffers_nodb(struct qlcnic_adapter *adapter,
 	int producer, count = 0;
 	struct list_head *head;
 
-	producer = rds_ring->producer;
 	if (!spin_trylock(&rds_ring->lock))
 		return;
 
+	producer = rds_ring->producer;
+
 	head = &rds_ring->free_list;
 	while (!list_empty(head)) {
 
-- 
1.6.0.2

