From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 07/20] bridge: netlink: export all timers
Date: Sun,  4 Oct 2015 14:23:34 +0200
Message-ID: <1443961427-15085-8-git-send-email-razor@blackwall.org>
References: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	shm@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:38024 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751523AbbJDMYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2015 08:24:17 -0400
Received: by wiclk2 with SMTP id lk2so81178795wic.1
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 05:24:16 -0700 (PDT)
In-Reply-To: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Export the following bridge timers (also exported via sysfs):
IFLA_BR_HELLO_TIMER, IFLA_BR_TCN_TIMER, IFLA_BR_TOPOLOGY_CHANGE_TIMER,
IFLA_BR_GC_TIMER via netlink.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h |  4 ++++
 net/bridge/br_netlink.c      | 16 +++++++++++++++-
 2 files changed, 19 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index b00286ca1bfe..a1e33282ab9d 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -239,6 +239,10 @@ enum {
 	IFLA_BR_ROOT_PATH_COST,
 	IFLA_BR_TOPOLOGY_CHANGE,
 	IFLA_BR_TOPOLOGY_CHANGE_DETECTED,
+	IFLA_BR_HELLO_TIMER,
+	IFLA_BR_TCN_TIMER,
+	IFLA_BR_TOPOLOGY_CHANGE_TIMER,
+	IFLA_BR_GC_TIMER,
 	__IFLA_BR_MAX,
 };
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 8bcaa5171f35..755bfe0ab404 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -860,12 +860,17 @@ static size_t br_get_size(const struct net_device *brdev)
 	       nla_total_size(sizeof(u32)) +    /* IFLA_BR_ROOT_PATH_COST */
 	       nla_total_size(sizeof(u8)) +    /* IFLA_BR_TOPOLOGY_CHANGE */
 	       nla_total_size(sizeof(u8)) +    /* IFLA_BR_TOPOLOGY_CHANGE_DETECTED */
+	       nla_total_size(sizeof(u64)) +    /* IFLA_BR_HELLO_TIMER */
+	       nla_total_size(sizeof(u64)) +    /* IFLA_BR_TCN_TIMER */
+	       nla_total_size(sizeof(u64)) +    /* IFLA_BR_TOPOLOGY_CHANGE_TIMER */
+	       nla_total_size(sizeof(u64)) +    /* IFLA_BR_GC_TIMER */
 	       0;
 }
 
 static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 {
 	struct net_bridge *br = netdev_priv(brdev);
+	u64 hello_timer, tcn_timer, topology_change_timer, gc_timer;
 	u32 forward_delay = jiffies_to_clock_t(br->forward_delay);
 	u32 hello_time = jiffies_to_clock_t(br->hello_time);
 	u32 age_time = jiffies_to_clock_t(br->max_age);
@@ -882,6 +887,10 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	memcpy(root_id.addr, br->designated_root.addr, sizeof(root_id.addr));
 	memcpy(bridge_id.prio, br->bridge_id.prio, sizeof(bridge_id.prio));
 	memcpy(bridge_id.addr, br->bridge_id.addr, sizeof(bridge_id.addr));
+	hello_timer = br_timer_value(&br->hello_timer);
+	tcn_timer = br_timer_value(&br->tcn_timer);
+	topology_change_timer = br_timer_value(&br->topology_change_timer);
+	gc_timer = br_timer_value(&br->gc_timer);
 
 	if (nla_put_u32(skb, IFLA_BR_FORWARD_DELAY, forward_delay) ||
 	    nla_put_u32(skb, IFLA_BR_HELLO_TIME, hello_time) ||
@@ -897,7 +906,12 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	    nla_put_u32(skb, IFLA_BR_ROOT_PATH_COST, br->root_path_cost) ||
 	    nla_put_u8(skb, IFLA_BR_TOPOLOGY_CHANGE, br->topology_change) ||
 	    nla_put_u8(skb, IFLA_BR_TOPOLOGY_CHANGE_DETECTED,
-		       br->topology_change_detected))
+		       br->topology_change_detected) ||
+	    nla_put_u64(skb, IFLA_BR_HELLO_TIMER, hello_timer) ||
+	    nla_put_u64(skb, IFLA_BR_TCN_TIMER, tcn_timer) ||
+	    nla_put_u64(skb, IFLA_BR_TOPOLOGY_CHANGE_TIMER,
+			topology_change_timer) ||
+	    nla_put_u64(skb, IFLA_BR_GC_TIMER, gc_timer))
 		return -EMSGSIZE;
 
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
-- 
2.4.3
