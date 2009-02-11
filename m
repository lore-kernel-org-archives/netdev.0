From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 5/7] qlge: bugfix: Fix TSO breakage.
Date: Wed, 11 Feb 2009 05:58:35 -0800
Message-ID: <1234360717-32194-5-git-send-email-ron.mercer@qlogic.com>
References: <1234360717-32194-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:50248 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752903AbZBKOBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 09:01:17 -0500
In-Reply-To: <1234360717-32194-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moved the buffer mapping to a point after TSO logic has modified the
iph->check field. We were seeing stale data on the PCIe bus.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index fc7d210..54b0a9e 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1936,10 +1936,6 @@ static int qlge_send(struct sk_buff *skb, struct net_device *ndev)
 	tx_ring_desc = &tx_ring->q[tx_ring->prod_idx];
 	mac_iocb_ptr = tx_ring_desc->queue_entry;
 	memset((void *)mac_iocb_ptr, 0, sizeof(mac_iocb_ptr));
-	if (ql_map_send(qdev, mac_iocb_ptr, skb, tx_ring_desc) != NETDEV_TX_OK) {
-		QPRINTK(qdev, TX_QUEUED, ERR, "Could not map the segments.\n");
-		return NETDEV_TX_BUSY;
-	}
 
 	mac_iocb_ptr->opcode = OPCODE_OB_MAC_IOCB;
 	mac_iocb_ptr->tid = tx_ring_desc->index;
@@ -1965,6 +1961,12 @@ static int qlge_send(struct sk_buff *skb, struct net_device *ndev)
 		ql_hw_csum_setup(skb,
 				 (struct ob_mac_tso_iocb_req *)mac_iocb_ptr);
 	}
+	if (ql_map_send(qdev, mac_iocb_ptr, skb, tx_ring_desc) !=
+			NETDEV_TX_OK) {
+		QPRINTK(qdev, TX_QUEUED, ERR,
+				"Could not map the segments.\n");
+		return NETDEV_TX_BUSY;
+	}
 	QL_DUMP_OB_MAC_IOCB(mac_iocb_ptr);
 	tx_ring->prod_idx++;
 	if (tx_ring->prod_idx == tx_ring->wq_len)
-- 
1.6.0.2

