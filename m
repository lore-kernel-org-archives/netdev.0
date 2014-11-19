From: Tom Herbert <therbert@google.com>
Subject: [PATCH RFC] net: Pass full skb hash to ndo_rx_flow_steer
Date: Tue, 18 Nov 2014 20:08:57 -0800
Message-ID: <1416370137-2512-1-git-send-email-therbert@google.com>
To: luto@amacapital.net, ben@decadent.org.uk, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f172.google.com ([209.85.213.172]:41943 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753791AbaKSEJJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 23:09:09 -0500
Received: by mail-ig0-f172.google.com with SMTP id hl2so2250148igb.11
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 20:09:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, for aRFS the index into the flow table is passed to
ndo_rx_flow_steer as the flow ID of a connection. This is the skb->hash
& the table mask. It looks like the backend can accept the full
skb->hash as the flow ID which should reduce the number of collisions
in the hardware tables.

This patch provides the skb->hash to the driver for flow steering.
Expiration of HW steered flows was also updated.

With a hash collision in RFS, ndo_rx_flow_steer will continue to be
called with different CPUs, but now with different flow_ids. If this
is still too much device interaction, then it might make sense for the
driver to do its own lookup in its structure to see if a matching
filter is already installed for a given flow_id, an if it is just
refresh a timestamp to avoid expiration (based on looking at sfc
driver).

I don't currently have any HW to test this, if someone could try this
on hardware with aRFS and provide feedback that would be appreciated.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/core/dev.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 1ab168e..cb1e06d 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3057,7 +3057,8 @@ set_rps_cpu(struct net_device *dev, struct sk_buff *skb,
 			goto out;
 		flow_id = skb_get_hash(skb) & flow_table->mask;
 		rc = dev->netdev_ops->ndo_rx_flow_steer(dev, skb,
-							rxq_index, flow_id);
+							rxq_index,
+							skb_get_hash(skb));
 		if (rc < 0)
 			goto out;
 		old_rflow = rflow;
@@ -3195,8 +3196,8 @@ bool rps_may_expire_flow(struct net_device *dev, u16 rxq_index,
 
 	rcu_read_lock();
 	flow_table = rcu_dereference(rxqueue->rps_flow_table);
-	if (flow_table && flow_id <= flow_table->mask) {
-		rflow = &flow_table->flows[flow_id];
+	if (flow_table) {
+		rflow = &flow_table->flows[flow_id & flow_table->mask];
 		cpu = ACCESS_ONCE(rflow->cpu);
 		if (rflow->filter == filter_id && cpu != RPS_NO_CPU &&
 		    ((int)(per_cpu(softnet_data, cpu).input_queue_head -
-- 
2.1.0.rc2.206.gedb03e5
