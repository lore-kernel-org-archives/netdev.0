From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 03/10] liquidio: IQ synchronization
Date: Tue, 28 Jun 2016 17:54:25 -0700
Message-ID: <1467161672-21063-4-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1467161672-21063-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0059.outbound.protection.outlook.com ([207.46.100.59]:46448
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752494AbcF2AzL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2016 20:55:11 -0400
In-Reply-To: <1467161672-21063-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch tries to protect against bh preemption with
sc_buf_pool. It also modifies the syncronization primitives
during input queue processing.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 .../net/ethernet/cavium/liquidio/request_manager.c | 27 +++++++++++++---------
 1 file changed, 16 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index 8c82ccf..3e40cd6 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -371,6 +371,7 @@ lio_process_iq_request_list(struct octeon_device *oct,
 	unsigned int pkts_compl = 0, bytes_compl = 0;
 	struct octeon_soft_command *sc;
 	struct octeon_instr_irh *irh;
+	unsigned long flags;
 
 	while (old != iq->octeon_read_index) {
 		reqtype = iq->request_list[old].reqtype;
@@ -400,15 +401,19 @@ lio_process_iq_request_list(struct octeon_device *oct,
 				 * command response list because we expect
 				 * a response from Octeon.
 				 */
-				spin_lock_bh(&oct->response_list
-					[OCTEON_ORDERED_SC_LIST].lock);
+				spin_lock_irqsave
+					(&oct->response_list
+					 [OCTEON_ORDERED_SC_LIST].lock,
+					 flags);
 				atomic_inc(&oct->response_list
 					[OCTEON_ORDERED_SC_LIST].
 					pending_req_count);
 				list_add_tail(&sc->node, &oct->response_list
 					[OCTEON_ORDERED_SC_LIST].head);
-				spin_unlock_bh(&oct->response_list
-					[OCTEON_ORDERED_SC_LIST].lock);
+				spin_unlock_irqrestore
+					(&oct->response_list
+					 [OCTEON_ORDERED_SC_LIST].lock,
+					 flags);
 			} else {
 				if (sc->callback) {
 					sc->callback(oct, OCTEON_REQUEST_DONE,
@@ -688,7 +693,7 @@ int octeon_free_sc_buffer_pool(struct octeon_device *oct)
 	struct list_head *tmp, *tmp2;
 	struct octeon_soft_command *sc;
 
-	spin_lock(&oct->sc_buf_pool.lock);
+	spin_lock_bh(&oct->sc_buf_pool.lock);
 
 	list_for_each_safe(tmp, tmp2, &oct->sc_buf_pool.head) {
 		list_del(tmp);
@@ -700,7 +705,7 @@ int octeon_free_sc_buffer_pool(struct octeon_device *oct)
 
 	INIT_LIST_HEAD(&oct->sc_buf_pool.head);
 
-	spin_unlock(&oct->sc_buf_pool.lock);
+	spin_unlock_bh(&oct->sc_buf_pool.lock);
 
 	return 0;
 }
@@ -719,10 +724,10 @@ struct octeon_soft_command *octeon_alloc_soft_command(struct octeon_device *oct,
 	WARN_ON((offset + datasize + rdatasize + ctxsize) >
 	       SOFT_COMMAND_BUFFER_SIZE);
 
-	spin_lock(&oct->sc_buf_pool.lock);
+	spin_lock_bh(&oct->sc_buf_pool.lock);
 
 	if (list_empty(&oct->sc_buf_pool.head)) {
-		spin_unlock(&oct->sc_buf_pool.lock);
+		spin_unlock_bh(&oct->sc_buf_pool.lock);
 		return NULL;
 	}
 
@@ -733,7 +738,7 @@ struct octeon_soft_command *octeon_alloc_soft_command(struct octeon_device *oct,
 
 	atomic_inc(&oct->sc_buf_pool.alloc_buf_count);
 
-	spin_unlock(&oct->sc_buf_pool.lock);
+	spin_unlock_bh(&oct->sc_buf_pool.lock);
 
 	sc = (struct octeon_soft_command *)tmp;
 
@@ -776,11 +781,11 @@ struct octeon_soft_command *octeon_alloc_soft_command(struct octeon_device *oct,
 void octeon_free_soft_command(struct octeon_device *oct,
 			      struct octeon_soft_command *sc)
 {
-	spin_lock(&oct->sc_buf_pool.lock);
+	spin_lock_bh(&oct->sc_buf_pool.lock);
 
 	list_add_tail(&sc->node, &oct->sc_buf_pool.head);
 
 	atomic_dec(&oct->sc_buf_pool.alloc_buf_count);
 
-	spin_unlock(&oct->sc_buf_pool.lock);
+	spin_unlock_bh(&oct->sc_buf_pool.lock);
 }
-- 
1.8.3.1
