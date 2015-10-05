From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next] bridge: netlink: make br_fill_info's frame size smaller
Date: Mon,  5 Oct 2015 12:11:21 +0200
Message-ID: <1444039881-8818-1-git-send-email-razor@blackwall.org>
References: <201510051053.L0S9UKIW%fengguang.wu@intel.com>
Cc: davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:33034 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752507AbbJEKL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 06:11:26 -0400
Received: by wiclk2 with SMTP id lk2so112573009wic.0
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 03:11:25 -0700 (PDT)
In-Reply-To: <201510051053.L0S9UKIW%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

When KASAN is enabled the frame size grows > 2048 bytes and we get a
warning, so make it smaller.
net/bridge/br_netlink.c: In function 'br_fill_info':
>> net/bridge/br_netlink.c:1110:1: warning: the frame size of 2160 bytes
>> is larger than 2048 bytes [-Wframe-larger-than=]

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_netlink.c | 42 +++++++++++++++++++-----------------------
 1 file changed, 19 insertions(+), 23 deletions(-)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 70efe2edde2b..330abf4b033a 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -1057,28 +1057,27 @@ static size_t br_get_size(const struct net_device *brdev)
 static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 {
 	struct net_bridge *br = netdev_priv(brdev);
-	u64 hello_timer, tcn_timer, topology_change_timer, gc_timer, clockval;
 	u32 forward_delay = jiffies_to_clock_t(br->forward_delay);
 	u32 hello_time = jiffies_to_clock_t(br->hello_time);
 	u32 age_time = jiffies_to_clock_t(br->max_age);
 	u32 ageing_time = jiffies_to_clock_t(br->ageing_time);
 	u32 stp_enabled = br->stp_enabled;
 	u16 priority = (br->bridge_id.prio[0] << 8) | br->bridge_id.prio[1];
-	u16 group_fwd_mask = br->group_fwd_mask;
 	u8 vlan_enabled = br_vlan_enabled(br);
-	struct ifla_bridge_id root_id, bridge_id;
-
-	memset(&bridge_id, 0, sizeof(bridge_id));
-	memset(&root_id, 0, sizeof(root_id));
-	memcpy(root_id.prio, br->designated_root.prio, sizeof(root_id.prio));
-	memcpy(root_id.addr, br->designated_root.addr, sizeof(root_id.addr));
-	memcpy(bridge_id.prio, br->bridge_id.prio, sizeof(bridge_id.prio));
-	memcpy(bridge_id.addr, br->bridge_id.addr, sizeof(bridge_id.addr));
-	hello_timer = br_timer_value(&br->hello_timer);
-	tcn_timer = br_timer_value(&br->tcn_timer);
-	topology_change_timer = br_timer_value(&br->topology_change_timer);
-	gc_timer = br_timer_value(&br->gc_timer);
-	clockval = 0;
+	u64 clockval;
+
+	clockval = br_timer_value(&br->hello_timer);
+	if (nla_put_u64(skb, IFLA_BR_HELLO_TIMER, clockval))
+		return -EMSGSIZE;
+	clockval = br_timer_value(&br->tcn_timer);
+	if (nla_put_u64(skb, IFLA_BR_TCN_TIMER, clockval))
+		return -EMSGSIZE;
+	clockval = br_timer_value(&br->topology_change_timer);
+	if (nla_put_u64(skb, IFLA_BR_TOPOLOGY_CHANGE_TIMER, clockval))
+		return -EMSGSIZE;
+	clockval = br_timer_value(&br->gc_timer);
+	if (nla_put_u64(skb, IFLA_BR_GC_TIMER, clockval))
+		return -EMSGSIZE;
 
 	if (nla_put_u32(skb, IFLA_BR_FORWARD_DELAY, forward_delay) ||
 	    nla_put_u32(skb, IFLA_BR_HELLO_TIME, hello_time) ||
@@ -1087,19 +1086,16 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	    nla_put_u32(skb, IFLA_BR_STP_STATE, stp_enabled) ||
 	    nla_put_u16(skb, IFLA_BR_PRIORITY, priority) ||
 	    nla_put_u8(skb, IFLA_BR_VLAN_FILTERING, vlan_enabled) ||
-	    nla_put_u16(skb, IFLA_BR_GROUP_FWD_MASK, group_fwd_mask) ||
-	    nla_put(skb, IFLA_BR_ROOT_ID, sizeof(root_id), &root_id) ||
-	    nla_put(skb, IFLA_BR_BRIDGE_ID, sizeof(bridge_id), &bridge_id) ||
+	    nla_put_u16(skb, IFLA_BR_GROUP_FWD_MASK, br->group_fwd_mask) ||
+	    nla_put(skb, IFLA_BR_BRIDGE_ID, sizeof(struct ifla_bridge_id),
+		    &br->bridge_id) ||
+	    nla_put(skb, IFLA_BR_ROOT_ID, sizeof(struct ifla_bridge_id),
+		    &br->designated_root) ||
 	    nla_put_u16(skb, IFLA_BR_ROOT_PORT, br->root_port) ||
 	    nla_put_u32(skb, IFLA_BR_ROOT_PATH_COST, br->root_path_cost) ||
 	    nla_put_u8(skb, IFLA_BR_TOPOLOGY_CHANGE, br->topology_change) ||
 	    nla_put_u8(skb, IFLA_BR_TOPOLOGY_CHANGE_DETECTED,
 		       br->topology_change_detected) ||
-	    nla_put_u64(skb, IFLA_BR_HELLO_TIMER, hello_timer) ||
-	    nla_put_u64(skb, IFLA_BR_TCN_TIMER, tcn_timer) ||
-	    nla_put_u64(skb, IFLA_BR_TOPOLOGY_CHANGE_TIMER,
-			topology_change_timer) ||
-	    nla_put_u64(skb, IFLA_BR_GC_TIMER, gc_timer) ||
 	    nla_put(skb, IFLA_BR_GROUP_ADDR, ETH_ALEN, br->group_addr))
 		return -EMSGSIZE;
 
-- 
2.4.3
