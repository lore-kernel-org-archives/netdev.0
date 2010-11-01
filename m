From: Tom Herbert <therbert@google.com>
Subject: [PATCH] net: check queue_index from sock is valid for device
Date: Mon, 1 Nov 2010 12:53:32 -0700 (PDT)
Message-ID: <alpine.DEB.1.00.1011011249590.5368@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:13011 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752392Ab0KATxy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Nov 2010 15:53:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In dev_pick_tx recompute the queue index if the value stored in the
socket is greater than or equal to the number of real queues for the
device.  The saved index in the sock structure is not guaranteed to
be appropriate for the egress device (this could happen on a route
change or in presence of tunnelling).  The result of the queue index
being bad would be to return a bogus queue (crash could prersumably
follow).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/core/dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 78b5a89..dc2a307 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2135,7 +2135,7 @@ static struct netdev_queue *dev_pick_tx(struct net_device *dev,
 	} else {
 		struct sock *sk = skb->sk;
 		queue_index = sk_tx_queue_get(sk);
-		if (queue_index < 0) {
+		if (queue_index < 0 || queue_index >= dev->real_num_tx_queues) {
 
 			queue_index = 0;
 			if (dev->real_num_tx_queues > 1)
-- 
1.7.3.1

