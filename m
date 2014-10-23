From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] macvlan: fix a race on port dismantle and possible skb
 leaks
Date: Wed, 22 Oct 2014 19:43:46 -0700
Message-ID: <1414032226.2094.14.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:54260 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932353AbaJWCnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 22:43:47 -0400
Received: by mail-pa0-f49.google.com with SMTP id hz1so177835pad.22
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 19:43:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We need to cancel the work queue after rcu grace period,
otherwise it can be rescheduled by incoming packets.

We need to purge queue if some skbs are still in it.

We can use __skb_queue_head_init() variant in
macvlan_process_broadcast()

Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: 412ca1550cbec ("macvlan: Move broadcasts into a work queue")
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
 drivers/net/macvlan.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 29b3bb410781..98c2732755ea 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -272,7 +272,7 @@ static void macvlan_process_broadcast(struct work_struct *w)
 	struct sk_buff *skb;
 	struct sk_buff_head list;
 
-	skb_queue_head_init(&list);
+	__skb_queue_head_init(&list);
 
 	spin_lock_bh(&port->bc_queue.lock);
 	skb_queue_splice_tail_init(&port->bc_queue, &list);
@@ -1082,9 +1082,15 @@ static void macvlan_port_destroy(struct net_device *dev)
 {
 	struct macvlan_port *port = macvlan_port_get_rtnl(dev);
 
-	cancel_work_sync(&port->bc_work);
 	dev->priv_flags &= ~IFF_MACVLAN_PORT;
 	netdev_rx_handler_unregister(dev);
+
+	/* After this point, no packet can schedule bc_work anymore,
+	 * but we need to cancel it and purge left skbs if any.
+	 */
+	cancel_work_sync(&port->bc_work);
+	__skb_queue_purge(&port->bc_queue);
+
 	kfree_rcu(port, rcu);
 }
 
