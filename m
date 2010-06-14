From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH 2/3] netxen: fix rcv buffer leak
Date: Mon, 14 Jun 2010 02:39:04 -0700
Message-ID: <1276508345-17070-3-git-send-email-amit.salecha@qlogic.com>
References: <1276508345-17070-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:23346 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755837Ab0FNJjG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jun 2010 05:39:06 -0400
In-Reply-To: <1276508345-17070-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rcv producer should be read in spin-lock.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_init.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index e08527f..c865dda 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1805,9 +1805,10 @@ netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ringid,
 	netxen_ctx_msg msg = 0;
 	struct list_head *head;
 
+	spin_lock(&rds_ring->lock);
+
 	producer = rds_ring->producer;
 
-	spin_lock(&rds_ring->lock);
 	head = &rds_ring->free_list;
 	while (!list_empty(head)) {
 
@@ -1829,7 +1830,6 @@ netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ringid,
 
 		producer = get_next_index(producer, rds_ring->num_desc);
 	}
-	spin_unlock(&rds_ring->lock);
 
 	if (count) {
 		rds_ring->producer = producer;
@@ -1853,6 +1853,8 @@ netxen_post_rx_buffers(struct netxen_adapter *adapter, u32 ringid,
 					NETXEN_RCV_PRODUCER_OFFSET), msg);
 		}
 	}
+
+	spin_unlock(&rds_ring->lock);
 }
 
 static void
@@ -1864,10 +1866,11 @@ netxen_post_rx_buffers_nodb(struct netxen_adapter *adapter,
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

