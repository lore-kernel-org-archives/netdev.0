From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 01/20] bridge: netlink: add group_fwd_mask support
Date: Sun,  4 Oct 2015 14:23:28 +0200
Message-ID: <1443961427-15085-2-git-send-email-razor@blackwall.org>
References: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	shm@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:34231 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454AbbJDMYM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2015 08:24:12 -0400
Received: by wicfx3 with SMTP id fx3so85293340wic.1
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 05:24:11 -0700 (PDT)
In-Reply-To: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Add IFLA_BR_GROUP_FWD_MASK attribute to allow setting and retrieving the
group_fwd_mask via netlink.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h |  1 +
 net/bridge/br_netlink.c      | 14 +++++++++++++-
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 3a5f263cfc2f..f7f480613555 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -232,6 +232,7 @@ enum {
 	IFLA_BR_PRIORITY,
 	IFLA_BR_VLAN_FILTERING,
 	IFLA_BR_VLAN_PROTOCOL,
+	IFLA_BR_GROUP_FWD_MASK,
 	__IFLA_BR_MAX,
 };
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index c3186198d46d..39b201a2bc12 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -764,6 +764,7 @@ static const struct nla_policy br_policy[IFLA_BR_MAX + 1] = {
 	[IFLA_BR_PRIORITY] = { .type = NLA_U16 },
 	[IFLA_BR_VLAN_FILTERING] = { .type = NLA_U8 },
 	[IFLA_BR_VLAN_PROTOCOL] = { .type = NLA_U16 },
+	[IFLA_BR_GROUP_FWD_MASK] = { .type = NLA_U16 },
 };
 
 static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
@@ -829,6 +830,14 @@ static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
 	}
 #endif
 
+	if (data[IFLA_BR_GROUP_FWD_MASK]) {
+		u16 fwd_mask = nla_get_u16(data[IFLA_BR_GROUP_FWD_MASK]);
+
+		if (fwd_mask & BR_GROUPFWD_RESTRICTED)
+			return -EINVAL;
+		br->group_fwd_mask = fwd_mask;
+	}
+
 	return 0;
 }
 
@@ -844,6 +853,7 @@ static size_t br_get_size(const struct net_device *brdev)
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
 	       nla_total_size(sizeof(__be16)) +	/* IFLA_BR_VLAN_PROTOCOL */
 #endif
+	       nla_total_size(sizeof(u16)) +    /* IFLA_BR_GROUP_FWD_MASK */
 	       0;
 }
 
@@ -856,6 +866,7 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	u32 ageing_time = jiffies_to_clock_t(br->ageing_time);
 	u32 stp_enabled = br->stp_enabled;
 	u16 priority = (br->bridge_id.prio[0] << 8) | br->bridge_id.prio[1];
+	u16 group_fwd_mask = br->group_fwd_mask;
 	u8 vlan_enabled = br_vlan_enabled(br);
 
 	if (nla_put_u32(skb, IFLA_BR_FORWARD_DELAY, forward_delay) ||
@@ -864,7 +875,8 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	    nla_put_u32(skb, IFLA_BR_AGEING_TIME, ageing_time) ||
 	    nla_put_u32(skb, IFLA_BR_STP_STATE, stp_enabled) ||
 	    nla_put_u16(skb, IFLA_BR_PRIORITY, priority) ||
-	    nla_put_u8(skb, IFLA_BR_VLAN_FILTERING, vlan_enabled))
+	    nla_put_u8(skb, IFLA_BR_VLAN_FILTERING, vlan_enabled) ||
+	    nla_put_u16(skb, IFLA_BR_GROUP_FWD_MASK, group_fwd_mask))
 		return -EMSGSIZE;
 
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
-- 
2.4.3
