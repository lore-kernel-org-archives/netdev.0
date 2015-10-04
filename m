From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 14/20] bridge: netlink: add support for igmp's hash_elasticity
Date: Sun,  4 Oct 2015 14:23:41 +0200
Message-ID: <1443961427-15085-15-git-send-email-razor@blackwall.org>
References: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	shm@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:37220 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751524AbbJDMYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2015 08:24:22 -0400
Received: by wicfx3 with SMTP id fx3so80981748wic.0
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 05:24:21 -0700 (PDT)
In-Reply-To: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Add IFLA_BR_MCAST_HASH_ELASTICITY to allow setting/getting
br->hash_elasticity via netlink.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h |  1 +
 net/bridge/br_netlink.c      | 12 +++++++++++-
 2 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index fe5fac5c2a7f..ca7ca766d8af 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -249,6 +249,7 @@ enum {
 	IFLA_BR_MCAST_SNOOPING,
 	IFLA_BR_MCAST_QUERY_USE_IFADDR,
 	IFLA_BR_MCAST_QUERIER,
+	IFLA_BR_MCAST_HASH_ELASTICITY,
 	__IFLA_BR_MAX,
 };
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index e21296dacf42..b210a639e8d1 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -771,6 +771,7 @@ static const struct nla_policy br_policy[IFLA_BR_MAX + 1] = {
 	[IFLA_BR_MCAST_SNOOPING] = { .type = NLA_U8 },
 	[IFLA_BR_MCAST_QUERY_USE_IFADDR] = { .type = NLA_U8 },
 	[IFLA_BR_MCAST_QUERIER] = { .type = NLA_U8 },
+	[IFLA_BR_MCAST_HASH_ELASTICITY] = { .type = NLA_U32 },
 };
 
 static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
@@ -897,6 +898,12 @@ static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
 		if (err)
 			return err;
 	}
+
+	if (data[IFLA_BR_MCAST_HASH_ELASTICITY]) {
+		u32 val = nla_get_u32(data[IFLA_BR_MCAST_HASH_ELASTICITY]);
+
+		br->hash_elasticity = val;
+	}
 #endif
 
 	return 0;
@@ -931,6 +938,7 @@ static size_t br_get_size(const struct net_device *brdev)
 	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_MCAST_SNOOPING */
 	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_MCAST_QUERY_USE_IFADDR */
 	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_MCAST_QUERIER */
+	       nla_total_size(sizeof(u32)) +     /* IFLA_BR_MCAST_HASH_ELASTICITY */
 #endif
 	       0;
 }
@@ -993,7 +1001,9 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	    nla_put_u8(skb, IFLA_BR_MCAST_SNOOPING, !br->multicast_disabled) ||
 	    nla_put_u8(skb, IFLA_BR_MCAST_QUERY_USE_IFADDR,
 		       br->multicast_query_use_ifaddr) ||
-	    nla_put_u8(skb, IFLA_BR_MCAST_QUERIER, br->multicast_querier))
+	    nla_put_u8(skb, IFLA_BR_MCAST_QUERIER, br->multicast_querier) ||
+	    nla_put_u32(skb, IFLA_BR_MCAST_HASH_ELASTICITY,
+			br->hash_elasticity))
 		return -EMSGSIZE;
 #endif
 
-- 
2.4.3
