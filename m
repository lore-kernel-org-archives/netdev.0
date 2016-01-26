From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv2 net] xen-netfront: request Tx response events more often
Date: Tue, 26 Jan 2016 17:12:44 +0000
Message-ID: <1453828364-2042-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Malcolm Crossley <malcolm.crossley@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:26128 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966812AbcAZRNJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2016 12:13:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Malcolm Crossley <malcolm.crossley@citrix.com>

Trying to batch Tx response events results in poor performance because
this delays freeing the transmitted skbs.

Instead use the standard RING_FINAL_CHECK_FOR_RESPONSES() macro to be
notified once the next Tx response is placed on the ring.

Signed-off-by: Malcolm Crossley <malcolm.crossley@citrix.com>
Signed-off-by: David Vrabel <david.vrabel@citrix.com>
---
v2:
- Use bool.
---
 drivers/net/xen-netfront.c | 15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index d6abf19..96ccd4e 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -364,6 +364,7 @@ static void xennet_tx_buf_gc(struct netfront_queue *queue)
 	RING_IDX cons, prod;
 	unsigned short id;
 	struct sk_buff *skb;
+	bool more_to_do;
 
 	BUG_ON(!netif_carrier_ok(queue->info->netdev));
 
@@ -398,18 +399,8 @@ static void xennet_tx_buf_gc(struct netfront_queue *queue)
 
 		queue->tx.rsp_cons = prod;
 
-		/*
-		 * Set a new event, then check for race with update of tx_cons.
-		 * Note that it is essential to schedule a callback, no matter
-		 * how few buffers are pending. Even if there is space in the
-		 * transmit ring, higher layers may be blocked because too much
-		 * data is outstanding: in such cases notification from Xen is
-		 * likely to be the only kick that we'll get.
-		 */
-		queue->tx.sring->rsp_event =
-			prod + ((queue->tx.sring->req_prod - prod) >> 1) + 1;
-		mb();		/* update shared area */
-	} while ((cons == prod) && (prod != queue->tx.sring->rsp_prod));
+		RING_FINAL_CHECK_FOR_RESPONSES(&queue->tx, more_to_do);
+	} while (more_to_do);
 
 	xennet_maybe_wake_tx(queue);
 }
-- 
2.1.4
