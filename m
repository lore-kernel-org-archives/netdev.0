From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH v2 2/6] netpoll: Only call ndo_start_xmit from a single place
Date: Thu, 27 Mar 2014 15:37:28 -0700
Message-ID: <87k3bfqndj.fsf_-_@x220.int.ebiederm.org>
References: <20140314.225923.61318448733570839.davem@davemloft.net>
	<87k3bwqgf7.fsf@xmission.com> <877g7wqg8e.fsf_-_@xmission.com>
	<20140317.154916.2276987764507311378.davem@davemloft.net>
	<87iorcgh5d.fsf_-_@xmission.com>
	<87vbuzqnh3.fsf_-_@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:43268 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757370AbaC0Whk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 18:37:40 -0400
In-Reply-To: <87vbuzqnh3.fsf_-_@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Thu, 27 Mar 2014 15:35:20 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Factor out the code that needs to surround ndo_start_xmit
from netpoll_send_skb_on_dev into netpoll_start_xmit.

It is an unfortunate fact that as the netpoll code has been maintained
the primary call site ndo_start_xmit learned how to handle vlans
and timestamps but the second call of ndo_start_xmit in queue_process
did not.

With the introduction of netpoll_start_xmit this associated logic now
happens at both call sites of ndo_start_xmit and should make it easy
for that to continue into the future.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/core/netpoll.c |   61 +++++++++++++++++++++++++++++++---------------------
 1 file changed, 36 insertions(+), 25 deletions(-)

diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index 4bccc78c5b58..825200fcb0ff 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -69,6 +69,37 @@ module_param(carrier_timeout, uint, 0644);
 #define np_notice(np, fmt, ...)				\
 	pr_notice("%s: " fmt, np->name, ##__VA_ARGS__)
 
+static int netpoll_start_xmit(struct sk_buff *skb, struct net_device *dev,
+			      struct netdev_queue *txq)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+	int status = NETDEV_TX_OK;
+	netdev_features_t features;
+
+	features = netif_skb_features(skb);
+
+	if (vlan_tx_tag_present(skb) &&
+	    !vlan_hw_offload_capable(features, skb->vlan_proto)) {
+		skb = __vlan_put_tag(skb, skb->vlan_proto,
+				     vlan_tx_tag_get(skb));
+		if (unlikely(!skb)) {
+			/* This is actually a packet drop, but we
+			 * don't want the code that calls this
+			 * function to try and operate on a NULL skb.
+			 */
+			goto out;
+		}
+		skb->vlan_tci = 0;
+	}
+
+	status = ops->ndo_start_xmit(skb, dev);
+	if (status == NETDEV_TX_OK)
+		txq_trans_update(txq);
+
+out:
+	return status;
+}
+
 static void queue_process(struct work_struct *work)
 {
 	struct netpoll_info *npinfo =
@@ -78,7 +109,6 @@ static void queue_process(struct work_struct *work)
 
 	while ((skb = skb_dequeue(&npinfo->txq))) {
 		struct net_device *dev = skb->dev;
-		const struct net_device_ops *ops = dev->netdev_ops;
 		struct netdev_queue *txq;
 
 		if (!netif_device_present(dev) || !netif_running(dev)) {
@@ -91,7 +121,7 @@ static void queue_process(struct work_struct *work)
 		local_irq_save(flags);
 		__netif_tx_lock(txq, smp_processor_id());
 		if (netif_xmit_frozen_or_stopped(txq) ||
-		    ops->ndo_start_xmit(skb, dev) != NETDEV_TX_OK) {
+		    netpoll_start_xmit(skb, dev, txq) != NETDEV_TX_OK) {
 			skb_queue_head(&npinfo->txq, skb);
 			__netif_tx_unlock(txq);
 			local_irq_restore(flags);
@@ -295,7 +325,6 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 {
 	int status = NETDEV_TX_BUSY;
 	unsigned long tries;
-	const struct net_device_ops *ops = dev->netdev_ops;
 	/* It is up to the caller to keep npinfo alive. */
 	struct netpoll_info *npinfo;
 
@@ -317,27 +346,9 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 		for (tries = jiffies_to_usecs(1)/USEC_PER_POLL;
 		     tries > 0; --tries) {
 			if (__netif_tx_trylock(txq)) {
-				if (!netif_xmit_stopped(txq)) {
-					if (vlan_tx_tag_present(skb) &&
-					    !vlan_hw_offload_capable(netif_skb_features(skb),
-								     skb->vlan_proto)) {
-						skb = __vlan_put_tag(skb, skb->vlan_proto, vlan_tx_tag_get(skb));
-						if (unlikely(!skb)) {
-							/* This is actually a packet drop, but we
-							 * don't want the code at the end of this
-							 * function to try and re-queue a NULL skb.
-							 */
-							status = NETDEV_TX_OK;
-							goto unlock_txq;
-						}
-						skb->vlan_tci = 0;
-					}
-
-					status = ops->ndo_start_xmit(skb, dev);
-					if (status == NETDEV_TX_OK)
-						txq_trans_update(txq);
-				}
-			unlock_txq:
+				if (!netif_xmit_stopped(txq))
+					status = netpoll_start_xmit(skb, dev, txq);
+
 				__netif_tx_unlock(txq);
 
 				if (status == NETDEV_TX_OK)
@@ -353,7 +364,7 @@ void netpoll_send_skb_on_dev(struct netpoll *np, struct sk_buff *skb,
 
 		WARN_ONCE(!irqs_disabled(),
 			"netpoll_send_skb_on_dev(): %s enabled interrupts in poll (%pF)\n",
-			dev->name, ops->ndo_start_xmit);
+			dev->name, dev->netdev_ops->ndo_start_xmit);
 
 	}
 
-- 
1.7.10.4
