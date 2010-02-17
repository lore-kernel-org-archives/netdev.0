From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 1/3] qlge: Fix dropping of large non-TCP/UDP frames.
Date: Wed, 17 Feb 2010 08:41:21 -0800
Message-ID: <1266424883-25927-2-git-send-email-ron.mercer@qlogic.com>
References: <1266424883-25927-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:36599 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752682Ab0BQQsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 11:48:32 -0500
In-Reply-To: <1266424883-25927-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was found with pings that were large enough to span multiple rx
buffers.  The split frame logic handles this case nicely.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   20 +++++---------------
 1 files changed, 5 insertions(+), 15 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 2c052ca..0541e77 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2066,21 +2066,11 @@ static unsigned long ql_process_mac_rx_intr(struct ql_adapter *qdev,
 		ql_process_mac_rx_page(qdev, rx_ring, ib_mac_rsp,
 						length, vlan_id);
 	} else {
-		struct bq_desc *lbq_desc;
-
-		/* Free small buffer that holds the IAL */
-		lbq_desc = ql_get_curr_sbuf(rx_ring);
-		netif_err(qdev, rx_err, qdev->ndev,
-			  "Dropping frame, len %d > mtu %d\n",
-			  length, qdev->ndev->mtu);
-
-		/* Unwind the large buffers for this frame. */
-		while (length > 0) {
-			lbq_desc = ql_get_curr_lchunk(qdev, rx_ring);
-			length -= (length < rx_ring->lbq_buf_size) ?
-				length : rx_ring->lbq_buf_size;
-			put_page(lbq_desc->p.pg_chunk.page);
-		}
+		/* Non-TCP/UDP large frames that span multiple buffers
+		 * can be processed corrrectly by the split frame logic.
+		 */
+		ql_process_mac_split_rx_intr(qdev, rx_ring, ib_mac_rsp,
+						vlan_id);
 	}
 
 	return (unsigned long)length;
-- 
1.6.0.2

