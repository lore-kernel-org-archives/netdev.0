From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [net-next PATCH 4/5] qlge: Fix memory leak in the process of refill
Date: Fri, 3 Feb 2012 16:06:51 -0800
Message-ID: <1328314013-20458-4-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1328314013-20458-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Ron Mercer <ron.mercer@qlogic.com>,
	Dept_NX_Linux_NIC_Driver <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe006.messaging.microsoft.com ([216.32.181.186]:19619
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754200Ab2BDAWr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2012 19:22:47 -0500
In-Reply-To: <1328314013-20458-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver was leaking memory when page allocation failures occurs.

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index af12e80..49343ec 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -1143,14 +1143,16 @@ static void ql_update_lbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 	int i;
 
 	while (rx_ring->lbq_free_cnt > 32) {
-		for (i = 0; i < 16; i++) {
+		for (i = (rx_ring->lbq_clean_idx % 16); i < 16; i++) {
 			netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
 				     "lbq: try cleaning clean_idx = %d.\n",
 				     clean_idx);
 			lbq_desc = &rx_ring->lbq[clean_idx];
 			if (ql_get_next_chunk(qdev, rx_ring, lbq_desc)) {
+				rx_ring->lbq_clean_idx = clean_idx;
 				netif_err(qdev, ifup, qdev->ndev,
-					  "Could not get a page chunk.\n");
+						"Could not get a page chunk, i=%d, clean_idx =%d .\n",
+						i, clean_idx);
 				return;
 			}
 
@@ -1195,7 +1197,7 @@ static void ql_update_sbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 	int i;
 
 	while (rx_ring->sbq_free_cnt > 16) {
-		for (i = 0; i < 16; i++) {
+		for (i = (rx_ring->sbq_clean_idx % 16); i < 16; i++) {
 			sbq_desc = &rx_ring->sbq[clean_idx];
 			netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
 				     "sbq: try cleaning clean_idx = %d.\n",
-- 
1.7.6.rc1.1.g2c162b
