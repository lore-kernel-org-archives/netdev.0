From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 01/12] qlcnic: fix inconsistent lock state
Date: Thu, 19 Aug 2010 08:08:22 -0700
Message-ID: <1282230513-25286-2-git-send-email-amit.salecha@qlogic.com>
References: <1282230513-25286-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:50126 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752320Ab0HSPIe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Aug 2010 11:08:34 -0400
In-Reply-To: <1282230513-25286-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Spin_lock(rds_ring->lock) is not required while posting buffers
from qlcnic_open and freeing buffers from qlcnic_down.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_init.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 75ba744..08da258 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -136,8 +136,6 @@ void qlcnic_reset_rx_buffers_list(struct qlcnic_adapter *adapter)
 	for (ring = 0; ring < adapter->max_rds_rings; ring++) {
 		rds_ring = &recv_ctx->rds_rings[ring];
 
-		spin_lock(&rds_ring->lock);
-
 		INIT_LIST_HEAD(&rds_ring->free_list);
 
 		rx_buf = rds_ring->rx_buf_arr;
@@ -146,8 +144,6 @@ void qlcnic_reset_rx_buffers_list(struct qlcnic_adapter *adapter)
 					&rds_ring->free_list);
 			rx_buf++;
 		}
-
-		spin_unlock(&rds_ring->lock);
 	}
 }
 
@@ -1587,8 +1583,6 @@ qlcnic_post_rx_buffers(struct qlcnic_adapter *adapter, u32 ringid,
 	int producer, count = 0;
 	struct list_head *head;
 
-	spin_lock(&rds_ring->lock);
-
 	producer = rds_ring->producer;
 
 	head = &rds_ring->free_list;
@@ -1618,7 +1612,6 @@ qlcnic_post_rx_buffers(struct qlcnic_adapter *adapter, u32 ringid,
 		writel((producer-1) & (rds_ring->num_desc-1),
 				rds_ring->crb_rcv_producer);
 	}
-	spin_unlock(&rds_ring->lock);
 }
 
 static void
-- 
1.6.0.2

