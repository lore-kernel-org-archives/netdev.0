From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH,RFC] macvlan: Handle broadcasts inline if we have only a few
 macvlans.
Date: Fri, 27 May 2016 02:44:33 +0300
Message-ID: <20160526234433.GU8402@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hmm.wantstofly.org ([138.201.34.84]:46836 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755162AbcEZXvj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 19:51:39 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 412ca1550cbecb2c ("macvlan: Move broadcasts into a work queue")
moved processing of all macvlan multicasts into a work queue.  This
causes a noticable performance regression when there is heavy multicast
traffic on the underlying interface for multicast groups that the
macvlan subinterfaces are not members of, in which case we end up
cloning all those packets and then freeing them again from a work queue
without really doing any useful work with them in between.

The commit message for commit 412ca1550cbecb2c says:

|   Fundamentally, we need to ensure that the amount of work handled
|   in each netif_rx backlog run is constrained.  As broadcasts are
|   anything but constrained, it either needs to be limited per run
|   or moved to process context.

This patch moves multicast handling back into macvlan_handle_frame()
context if there are 100 or fewer macvlan subinterfaces, while keeping
the work queue for if there are more macvlan subinterfaces than that.

I played around with keeping track of the number of macvlan
subinterfaces that have each multicast filter bit set, but that ended
up being more complicated than I liked.  Conditionalising the work
queue deferring on the total number of macvlan subinterfaces seems
like a fair compromise.

On a quickly whipped together test program that creates an ethertap
interface with a single macvlan subinterface and then blasts 16 Mi
multicast packets through the ethertap interface for a multicast
group that the macvlan subinterface is not a member of, run time goes
from (vanilla kernel):

        # time ./stress
        real    0m41.864s
        user    0m0.622s
        sys     0m20.754s

to (with this patch):

        # time ./stress
        real    0m16.539s
        user    0m0.519s
        sys     0m15.949s

Reported-by: Grant Zhang <gzhang@fastly.com>
Signed-off-by: Lennert Buytenhek <lbuytenhek@fastly.com>
---
 drivers/net/macvlan.c | 71 ++++++++++++++++++++++++++++++++-------------------
 1 file changed, 45 insertions(+), 26 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index cb01023..02934a5 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -231,7 +231,8 @@ static unsigned int mc_hash(const struct macvlan_dev *vlan,
 static void macvlan_broadcast(struct sk_buff *skb,
 			      const struct macvlan_port *port,
 			      struct net_device *src,
-			      enum macvlan_mode mode)
+			      enum macvlan_mode mode,
+			      bool do_rx_softirq)
 {
 	const struct ethhdr *eth = eth_hdr(skb);
 	const struct macvlan_dev *vlan;
@@ -254,17 +255,49 @@ static void macvlan_broadcast(struct sk_buff *skb,
 
 			err = NET_RX_DROP;
 			nskb = skb_clone(skb, GFP_ATOMIC);
-			if (likely(nskb))
+			if (likely(nskb)) {
 				err = macvlan_broadcast_one(
 					nskb, vlan, eth,
-					mode == MACVLAN_MODE_BRIDGE) ?:
-				      netif_rx_ni(nskb);
+					mode == MACVLAN_MODE_BRIDGE);
+				if (err == 0) {
+					if (do_rx_softirq)
+						err = netif_rx_ni(nskb);
+					else
+						err = netif_rx(nskb);
+				}
+			}
 			macvlan_count_rx(vlan, skb->len + ETH_HLEN,
 					 err == NET_RX_SUCCESS, true);
 		}
 	}
 }
 
+static void macvlan_process_one(struct sk_buff *skb,
+				struct macvlan_port *port,
+				const struct macvlan_dev *src,
+				bool do_rx_softirq)
+{
+	if (!src)
+		/* frame comes from an external address */
+		macvlan_broadcast(skb, port, NULL,
+				  MACVLAN_MODE_PRIVATE |
+				  MACVLAN_MODE_VEPA    |
+				  MACVLAN_MODE_PASSTHRU|
+				  MACVLAN_MODE_BRIDGE, do_rx_softirq);
+	else if (src->mode == MACVLAN_MODE_VEPA)
+		/* flood to everyone except source */
+		macvlan_broadcast(skb, port, src->dev,
+				  MACVLAN_MODE_VEPA |
+				  MACVLAN_MODE_BRIDGE, do_rx_softirq);
+	else
+		/*
+		 * flood only to VEPA ports, bridge ports
+		 * already saw the frame on the way out.
+		 */
+		macvlan_broadcast(skb, port, src->dev,
+				  MACVLAN_MODE_VEPA, do_rx_softirq);
+}
+
 static void macvlan_process_broadcast(struct work_struct *w)
 {
 	struct macvlan_port *port = container_of(w, struct macvlan_port,
@@ -282,27 +315,7 @@ static void macvlan_process_broadcast(struct work_struct *w)
 		const struct macvlan_dev *src = MACVLAN_SKB_CB(skb)->src;
 
 		rcu_read_lock();
-
-		if (!src)
-			/* frame comes from an external address */
-			macvlan_broadcast(skb, port, NULL,
-					  MACVLAN_MODE_PRIVATE |
-					  MACVLAN_MODE_VEPA    |
-					  MACVLAN_MODE_PASSTHRU|
-					  MACVLAN_MODE_BRIDGE);
-		else if (src->mode == MACVLAN_MODE_VEPA)
-			/* flood to everyone except source */
-			macvlan_broadcast(skb, port, src->dev,
-					  MACVLAN_MODE_VEPA |
-					  MACVLAN_MODE_BRIDGE);
-		else
-			/*
-			 * flood only to VEPA ports, bridge ports
-			 * already saw the frame on the way out.
-			 */
-			macvlan_broadcast(skb, port, src->dev,
-					  MACVLAN_MODE_VEPA);
-
+		macvlan_process_one(skb, port, src, true);
 		rcu_read_unlock();
 
 		kfree_skb(skb);
@@ -429,6 +442,11 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 			goto out;
 		}
 
+		if (port->count <= 100) {
+			macvlan_process_one(skb, port, src, false);
+			return RX_HANDLER_PASS;
+		}
+
 		MACVLAN_SKB_CB(skb)->src = src;
 		macvlan_broadcast_enqueue(port, skb);
 
@@ -479,7 +497,8 @@ static int macvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		/* send to other bridge ports directly */
 		if (is_multicast_ether_addr(eth->h_dest)) {
-			macvlan_broadcast(skb, port, dev, MACVLAN_MODE_BRIDGE);
+			macvlan_broadcast(skb, port, dev,
+					  MACVLAN_MODE_BRIDGE, true);
 			goto xmit_world;
 		}
 
-- 
2.5.5
