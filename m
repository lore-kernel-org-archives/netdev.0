From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH] net: Require socket to allow XPS to set queue mapping
Date: Thu, 25 Aug 2016 12:23:28 -0700
Message-ID: <147215300812.3936.8031402062962283044.stgit@ahduyck-desk.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, rick.jones2@hpe.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:29565 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752567AbcHYTXa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 25 Aug 2016 15:23:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have been seeing a number of issues where XPS leads to issues with
packets being reordered in the transmit queues of the device drivers.  The
main situation where this seems to occur is when a VM us using a tap
interface to send packets to the network via a NIC that has XPS enabled.

A bit of looking into this revealed the main issue is that the scheduler
seems to be migrating the VM between CPUs and as this occurs the traffic
for a given flow from a VM is following this migration and hopping between
Tx queues leading to packet reordering.

A workaround for this is to make certain all the VMs have RPS enabled on
the tap interfaces, however this requires extra configuration on the host
for each VM created.

A simpler approach is provided with this patch.  With it we disable XPS any
time a socket is not present for a given flow.  By doing this we can avoid
using XPS for any routing or bridging situations in which XPS is likely
more of a hinderance than a help.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 net/core/dev.c |   28 +++++++++++++++-------------
 1 file changed, 15 insertions(+), 13 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index a75df86..9cea73b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3242,24 +3242,26 @@ static inline int get_xps_queue(struct net_device *dev, struct sk_buff *skb)
 
 static u16 __netdev_pick_tx(struct net_device *dev, struct sk_buff *skb)
 {
+	int queue_index, new_index;
 	struct sock *sk = skb->sk;
-	int queue_index = sk_tx_queue_get(sk);
 
-	if (queue_index < 0 || skb->ooo_okay ||
-	    queue_index >= dev->real_num_tx_queues) {
-		int new_index = get_xps_queue(dev, skb);
-		if (new_index < 0)
-			new_index = skb_tx_hash(dev, skb);
+	if (!sk)
+		return skb_tx_hash(dev, skb);
 
-		if (queue_index != new_index && sk &&
-		    sk_fullsock(sk) &&
-		    rcu_access_pointer(sk->sk_dst_cache))
-			sk_tx_queue_set(sk, new_index);
+	queue_index = sk_tx_queue_get(sk);
+	if (queue_index >= 0 && !skb->ooo_okay &&
+	    queue_index < dev->real_num_tx_queues)
+		return queue_index;
 
-		queue_index = new_index;
-	}
+	new_index = get_xps_queue(dev, skb);
+	if (new_index < 0)
+		new_index = skb_tx_hash(dev, skb);
 
-	return queue_index;
+	if (queue_index != new_index && sk_fullsock(sk) &&
+	    rcu_access_pointer(sk->sk_dst_cache))
+		sk_tx_queue_set(sk, new_index);
+
+	return new_index;
 }
 
 struct netdev_queue *netdev_pick_tx(struct net_device *dev,
