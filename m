From: Willy Tarreau <w@1wt.eu>
Subject: [PATCH net-next 4/6] net: mvneta: prefetch next rx descriptor instead of current one
Date: Sun, 12 Jan 2014 12:24:06 +0100
Message-ID: <1389525848-1814-5-git-send-email-w@1wt.eu>
References: <1389525848-1814-1-git-send-email-w@1wt.eu>
Cc: netdev@vger.kernel.org, Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:55245 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751328AbaALLY3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Jan 2014 06:24:29 -0500
In-Reply-To: <1389525848-1814-1-git-send-email-w@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the mvneta driver tries to prefetch the current Rx
descriptor during read. Tests have shown that prefetching the
next one instead increases general performance by about 1% on
HTTP traffic.

Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>
Signed-off-by: Willy Tarreau <w@1wt.eu>
---
 drivers/net/ethernet/marvell/mvneta.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index aa3a4f7..c7b37e0 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -611,6 +611,7 @@ mvneta_rxq_next_desc_get(struct mvneta_rx_queue *rxq)
 	int rx_desc = rxq->next_desc_to_proc;
 
 	rxq->next_desc_to_proc = MVNETA_QUEUE_NEXT_DESC(rxq, rx_desc);
+	prefetch(rxq->descs + rxq->next_desc_to_proc);
 	return rxq->descs + rx_desc;
 }
 
@@ -1442,7 +1443,6 @@ static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
 		u32 rx_status;
 		int rx_bytes, err;
 
-		prefetch(rx_desc);
 		rx_done++;
 		rx_filled++;
 		rx_status = rx_desc->status;
-- 
1.7.12.2.21.g234cd45.dirty
