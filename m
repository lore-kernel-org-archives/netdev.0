From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 13/20] bridge: netlink: add support for multicast_querier
Date: Sun,  4 Oct 2015 14:23:40 +0200
Message-ID: <1443961427-15085-14-git-send-email-razor@blackwall.org>
References: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	shm@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:36144 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751523AbbJDMYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2015 08:24:22 -0400
Received: by wicgb1 with SMTP id gb1so85080418wic.1
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 05:24:21 -0700 (PDT)
In-Reply-To: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Add IFLA_BR_MCAST_QUERIER to allow setting/getting br->multicast_querier
via netlink.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h |  1 +
 net/bridge/br_netlink.c      | 13 ++++++++++++-
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 7090b3977eac..fe5fac5c2a7f 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -248,6 +248,7 @@ enum {
 	IFLA_BR_MCAST_ROUTER,
 	IFLA_BR_MCAST_SNOOPING,
 	IFLA_BR_MCAST_QUERY_USE_IFADDR,
+	IFLA_BR_MCAST_QUERIER,
 	__IFLA_BR_MAX,
 };
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 12ef844273a7..e21296dacf42 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -770,6 +770,7 @@ static const struct nla_policy br_policy[IFLA_BR_MAX + 1] = {
 	[IFLA_BR_MCAST_ROUTER] = { .type = NLA_U8 },
 	[IFLA_BR_MCAST_SNOOPING] = { .type = NLA_U8 },
 	[IFLA_BR_MCAST_QUERY_USE_IFADDR] = { .type = NLA_U8 },
+	[IFLA_BR_MCAST_QUERIER] = { .type = NLA_U8 },
 };
 
 static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
@@ -888,6 +889,14 @@ static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
 		val = nla_get_u8(data[IFLA_BR_MCAST_QUERY_USE_IFADDR]);
 		br->multicast_query_use_ifaddr = !!val;
 	}
+
+	if (data[IFLA_BR_MCAST_QUERIER]) {
+		u8 mcast_querier = nla_get_u8(data[IFLA_BR_MCAST_QUERIER]);
+
+		err = br_multicast_set_querier(br, mcast_querier);
+		if (err)
+			return err;
+	}
 #endif
 
 	return 0;
@@ -921,6 +930,7 @@ static size_t br_get_size(const struct net_device *brdev)
 	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_MCAST_ROUTER */
 	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_MCAST_SNOOPING */
 	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_MCAST_QUERY_USE_IFADDR */
+	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_MCAST_QUERIER */
 #endif
 	       0;
 }
@@ -982,7 +992,8 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	if (nla_put_u8(skb, IFLA_BR_MCAST_ROUTER, br->multicast_router) ||
 	    nla_put_u8(skb, IFLA_BR_MCAST_SNOOPING, !br->multicast_disabled) ||
 	    nla_put_u8(skb, IFLA_BR_MCAST_QUERY_USE_IFADDR,
-		       br->multicast_query_use_ifaddr))
+		       br->multicast_query_use_ifaddr) ||
+	    nla_put_u8(skb, IFLA_BR_MCAST_QUERIER, br->multicast_querier))
 		return -EMSGSIZE;
 #endif
 
-- 
2.4.3
