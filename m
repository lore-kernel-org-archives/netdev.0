From: David Vrabel <david.vrabel@citrix.com>
Subject: [PATCHv1 net] xen-netfront: request Tx response events more often
Date: Fri, 15 Jan 2016 11:56:42 +0000
Message-ID: <1452859002-18543-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Vrabel <david.vrabel@citrix.com>,
	<xen-devel@lists.xenproject.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Malcolm Crossley <malcolm.crossley@citrix.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:9930 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751709AbcAOL5T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jan 2016 06:57:19 -0500
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
 drivers/net/xen-netfront.c | 15 +++------------
 1 file changed, 3 insertions(+), 12 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index d6abf19..9cb45be 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -364,6 +364,7 @@ static void xennet_tx_buf_gc(struct netfront_queue *queue)
 	RING_IDX cons, prod;
 	unsigned short id;
 	struct sk_buff *skb;
+	int more_to_do;
 
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
