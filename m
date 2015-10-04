From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 12/20] bridge: netlink: add support for multicast_query_use_ifaddr
Date: Sun,  4 Oct 2015 14:23:39 +0200
Message-ID: <1443961427-15085-13-git-send-email-razor@blackwall.org>
References: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	shm@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:37207 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575AbbJDMYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2015 08:24:21 -0400
Received: by wicfx3 with SMTP id fx3so80981306wic.0
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 05:24:20 -0700 (PDT)
In-Reply-To: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Add IFLA_BR_MCAST_QUERY_USE_IFADDR to allow setting/getting
br->multicast_query_use_ifaddr via netlink.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h |  1 +
 net/bridge/br_netlink.c      | 13 ++++++++++++-
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 22cb395a713d..7090b3977eac 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -247,6 +247,7 @@ enum {
 	IFLA_BR_FDB_FLUSH,
 	IFLA_BR_MCAST_ROUTER,
 	IFLA_BR_MCAST_SNOOPING,
+	IFLA_BR_MCAST_QUERY_USE_IFADDR,
 	__IFLA_BR_MAX,
 };
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 25e1c66d70f1..12ef844273a7 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -769,6 +769,7 @@ static const struct nla_policy br_policy[IFLA_BR_MAX + 1] = {
 				 .len  = ETH_ALEN },
 	[IFLA_BR_MCAST_ROUTER] = { .type = NLA_U8 },
 	[IFLA_BR_MCAST_SNOOPING] = { .type = NLA_U8 },
+	[IFLA_BR_MCAST_QUERY_USE_IFADDR] = { .type = NLA_U8 },
 };
 
 static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
@@ -880,6 +881,13 @@ static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
 		if (err)
 			return err;
 	}
+
+	if (data[IFLA_BR_MCAST_QUERY_USE_IFADDR]) {
+		u8 val;
+
+		val = nla_get_u8(data[IFLA_BR_MCAST_QUERY_USE_IFADDR]);
+		br->multicast_query_use_ifaddr = !!val;
+	}
 #endif
 
 	return 0;
@@ -912,6 +920,7 @@ static size_t br_get_size(const struct net_device *brdev)
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_MCAST_ROUTER */
 	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_MCAST_SNOOPING */
+	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_MCAST_QUERY_USE_IFADDR */
 #endif
 	       0;
 }
@@ -971,7 +980,9 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	if (nla_put_u8(skb, IFLA_BR_MCAST_ROUTER, br->multicast_router) ||
-	    nla_put_u8(skb, IFLA_BR_MCAST_SNOOPING, !br->multicast_disabled))
+	    nla_put_u8(skb, IFLA_BR_MCAST_SNOOPING, !br->multicast_disabled) ||
+	    nla_put_u8(skb, IFLA_BR_MCAST_QUERY_USE_IFADDR,
+		       br->multicast_query_use_ifaddr))
 		return -EMSGSIZE;
 #endif
 
-- 
2.4.3
