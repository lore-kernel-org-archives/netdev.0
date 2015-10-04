From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 10/20] bridge: netlink: add support for multicast_router
Date: Sun,  4 Oct 2015 14:23:37 +0200
Message-ID: <1443961427-15085-11-git-send-email-razor@blackwall.org>
References: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	shm@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:38044 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751544AbbJDMYT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2015 08:24:19 -0400
Received: by wiclk2 with SMTP id lk2so81179430wic.1
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 05:24:18 -0700 (PDT)
In-Reply-To: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Add IFLA_BR_MCAST_ROUTER to allow setting and retrieving
br->multicast_router when igmp snooping is enabled.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h |  1 +
 net/bridge/br_netlink.c      | 19 +++++++++++++++++++
 2 files changed, 20 insertions(+)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 9ca9bf8bfe04..5d2c92973afe 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -245,6 +245,7 @@ enum {
 	IFLA_BR_GC_TIMER,
 	IFLA_BR_GROUP_ADDR,
 	IFLA_BR_FDB_FLUSH,
+	IFLA_BR_MCAST_ROUTER,
 	__IFLA_BR_MAX,
 };
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 5853c5737006..f4df609c1ad9 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -767,6 +767,7 @@ static const struct nla_policy br_policy[IFLA_BR_MAX + 1] = {
 	[IFLA_BR_GROUP_FWD_MASK] = { .type = NLA_U16 },
 	[IFLA_BR_GROUP_ADDR] = { .type = NLA_BINARY,
 				 .len  = ETH_ALEN },
+	[IFLA_BR_MCAST_ROUTER] = { .type = NLA_U8 },
 };
 
 static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
@@ -862,6 +863,16 @@ static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
 	if (data[IFLA_BR_FDB_FLUSH])
 		br_fdb_flush(br);
 
+#ifdef CONFIG_BRIDGE_IGMP_SNOOPING
+	if (data[IFLA_BR_MCAST_ROUTER]) {
+		u8 multicast_router = nla_get_u8(data[IFLA_BR_MCAST_ROUTER]);
+
+		err = br_multicast_set_router(br, multicast_router);
+		if (err)
+			return err;
+	}
+#endif
+
 	return 0;
 }
 
@@ -889,6 +900,9 @@ static size_t br_get_size(const struct net_device *brdev)
 	       nla_total_size(sizeof(u64)) +    /* IFLA_BR_TOPOLOGY_CHANGE_TIMER */
 	       nla_total_size(sizeof(u64)) +    /* IFLA_BR_GC_TIMER */
 	       nla_total_size(ETH_ALEN) +       /* IFLA_BR_GROUP_ADDR */
+#ifdef CONFIG_BRIDGE_IGMP_SNOOPING
+	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_MCAST_ROUTER */
+#endif
 	       0;
 }
 
@@ -945,6 +959,11 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 		return -EMSGSIZE;
 #endif
 
+#ifdef CONFIG_BRIDGE_IGMP_SNOOPING
+	if (nla_put_u8(skb, IFLA_BR_MCAST_ROUTER, br->multicast_router))
+		return -EMSGSIZE;
+#endif
+
 	return 0;
 }
 
-- 
2.4.3
