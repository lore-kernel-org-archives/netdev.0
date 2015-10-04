From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 11/20] bridge: netlink: add support for multicast_snooping
Date: Sun,  4 Oct 2015 14:23:38 +0200
Message-ID: <1443961427-15085-12-git-send-email-razor@blackwall.org>
References: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	shm@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:38050 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751569AbbJDMYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2015 08:24:20 -0400
Received: by wiclk2 with SMTP id lk2so81179620wic.1
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 05:24:19 -0700 (PDT)
In-Reply-To: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Add IFLA_BR_MCAST_SNOOPING to allow enabling/disabling multicast
snooping via netlink.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h |  1 +
 net/bridge/br_netlink.c      | 13 ++++++++++++-
 2 files changed, 13 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 5d2c92973afe..22cb395a713d 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -246,6 +246,7 @@ enum {
 	IFLA_BR_GROUP_ADDR,
 	IFLA_BR_FDB_FLUSH,
 	IFLA_BR_MCAST_ROUTER,
+	IFLA_BR_MCAST_SNOOPING,
 	__IFLA_BR_MAX,
 };
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index f4df609c1ad9..25e1c66d70f1 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -768,6 +768,7 @@ static const struct nla_policy br_policy[IFLA_BR_MAX + 1] = {
 	[IFLA_BR_GROUP_ADDR] = { .type = NLA_BINARY,
 				 .len  = ETH_ALEN },
 	[IFLA_BR_MCAST_ROUTER] = { .type = NLA_U8 },
+	[IFLA_BR_MCAST_SNOOPING] = { .type = NLA_U8 },
 };
 
 static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
@@ -871,6 +872,14 @@ static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
 		if (err)
 			return err;
 	}
+
+	if (data[IFLA_BR_MCAST_SNOOPING]) {
+		u8 mcast_snooping = nla_get_u8(data[IFLA_BR_MCAST_SNOOPING]);
+
+		err = br_multicast_toggle(br, mcast_snooping);
+		if (err)
+			return err;
+	}
 #endif
 
 	return 0;
@@ -902,6 +911,7 @@ static size_t br_get_size(const struct net_device *brdev)
 	       nla_total_size(ETH_ALEN) +       /* IFLA_BR_GROUP_ADDR */
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_MCAST_ROUTER */
+	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_MCAST_SNOOPING */
 #endif
 	       0;
 }
@@ -960,7 +970,8 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 #endif
 
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
-	if (nla_put_u8(skb, IFLA_BR_MCAST_ROUTER, br->multicast_router))
+	if (nla_put_u8(skb, IFLA_BR_MCAST_ROUTER, br->multicast_router) ||
+	    nla_put_u8(skb, IFLA_BR_MCAST_SNOOPING, !br->multicast_disabled))
 		return -EMSGSIZE;
 #endif
 
-- 
2.4.3
