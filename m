From: Tonghao Zhang <xiangxia.m.yue@gmail.com>
Subject: [PATCH 1/2] openvswitch: Optimize updating for OvS flow_stats.
Date: Mon, 10 Jul 2017 06:19:48 -0700
Message-ID: <1499692789-3140-1-git-send-email-xiangxia.m.yue@gmail.com>
Cc: pshelar@ovn.org, Tonghao Zhang <xiangxia.m.yue@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34653 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753563AbdGJNTO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 09:19:14 -0400
Received: by mail-pg0-f67.google.com with SMTP id j186so12720602pge.1
        for <netdev@vger.kernel.org>; Mon, 10 Jul 2017 06:19:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the ovs_flow_stats_update(), we only use the node
var to alloc flow_stats struct. But this is not a
common case, it is unnecessary to call the numa_node_id()
everytime. This patch is not a bugfix, but there maybe
a small increase.

Signed-off-by: Tonghao Zhang <xiangxia.m.yue@gmail.com>
---
 net/openvswitch/flow.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 3f76cb7..89aeb32 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -72,7 +72,6 @@ void ovs_flow_stats_update(struct sw_flow *flow, __be16 tcp_flags,
 			   const struct sk_buff *skb)
 {
 	struct flow_stats *stats;
-	int node = numa_node_id();
 	int cpu = smp_processor_id();
 	int len = skb->len + (skb_vlan_tag_present(skb) ? VLAN_HLEN : 0);
 
@@ -108,7 +107,7 @@ void ovs_flow_stats_update(struct sw_flow *flow, __be16 tcp_flags,
 							      __GFP_THISNODE |
 							      __GFP_NOWARN |
 							      __GFP_NOMEMALLOC,
-							      node);
+							      numa_node_id());
 				if (likely(new_stats)) {
 					new_stats->used = jiffies;
 					new_stats->packet_count = 1;
-- 
1.8.3.1
