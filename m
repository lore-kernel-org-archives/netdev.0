From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 15/20] bridge: netlink: add support for igmp's hash_max
Date: Sun,  4 Oct 2015 14:23:42 +0200
Message-ID: <1443961427-15085-16-git-send-email-razor@blackwall.org>
References: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	shm@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:36154 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454AbbJDMYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2015 08:24:23 -0400
Received: by wicgb1 with SMTP id gb1so85080844wic.1
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 05:24:22 -0700 (PDT)
In-Reply-To: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Add IFLA_BR_MCAST_HASH_MAX to allow setting/getting br->hash_max via
netlink.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h |  1 +
 net/bridge/br_netlink.c      | 13 ++++++++++++-
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index ca7ca766d8af..10a44a735512 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -250,6 +250,7 @@ enum {
 	IFLA_BR_MCAST_QUERY_USE_IFADDR,
 	IFLA_BR_MCAST_QUERIER,
 	IFLA_BR_MCAST_HASH_ELASTICITY,
+	IFLA_BR_MCAST_HASH_MAX,
 	__IFLA_BR_MAX,
 };
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index b210a639e8d1..d6b61b0eeada 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -772,6 +772,7 @@ static const struct nla_policy br_policy[IFLA_BR_MAX + 1] = {
 	[IFLA_BR_MCAST_QUERY_USE_IFADDR] = { .type = NLA_U8 },
 	[IFLA_BR_MCAST_QUERIER] = { .type = NLA_U8 },
 	[IFLA_BR_MCAST_HASH_ELASTICITY] = { .type = NLA_U32 },
+	[IFLA_BR_MCAST_HASH_MAX] = { .type = NLA_U32 },
 };
 
 static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
@@ -904,6 +905,14 @@ static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
 
 		br->hash_elasticity = val;
 	}
+
+	if (data[IFLA_BR_MCAST_HASH_MAX]) {
+		u32 hash_max = nla_get_u32(data[IFLA_BR_MCAST_HASH_MAX]);
+
+		err = br_multicast_set_hash_max(br, hash_max);
+		if (err)
+			return err;
+	}
 #endif
 
 	return 0;
@@ -939,6 +948,7 @@ static size_t br_get_size(const struct net_device *brdev)
 	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_MCAST_QUERY_USE_IFADDR */
 	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_MCAST_QUERIER */
 	       nla_total_size(sizeof(u32)) +     /* IFLA_BR_MCAST_HASH_ELASTICITY */
+	       nla_total_size(sizeof(u32)) +     /* IFLA_BR_MCAST_HASH_MAX */
 #endif
 	       0;
 }
@@ -1003,7 +1013,8 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 		       br->multicast_query_use_ifaddr) ||
 	    nla_put_u8(skb, IFLA_BR_MCAST_QUERIER, br->multicast_querier) ||
 	    nla_put_u32(skb, IFLA_BR_MCAST_HASH_ELASTICITY,
-			br->hash_elasticity))
+			br->hash_elasticity) ||
+	    nla_put_u32(skb, IFLA_BR_MCAST_HASH_MAX, br->hash_max))
 		return -EMSGSIZE;
 #endif
 
-- 
2.4.3
