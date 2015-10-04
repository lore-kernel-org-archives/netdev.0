From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 19/20] bridge: netlink: add support for netfilter tables config
Date: Sun,  4 Oct 2015 14:23:46 +0200
Message-ID: <1443961427-15085-20-git-send-email-razor@blackwall.org>
References: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	shm@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:34353 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454AbbJDMY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2015 08:24:27 -0400
Received: by wicfx3 with SMTP id fx3so85297354wic.1
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 05:24:25 -0700 (PDT)
In-Reply-To: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Add support to allow getting/setting netfilter tables settings.
Currently these are IFLA_BR_NF_CALL_IPTABLES, IFLA_BR_NF_CALL_IP6TABLES
and IFLA_BR_NF_CALL_ARPTABLES.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h |  3 +++
 net/bridge/br_netlink.c      | 37 ++++++++++++++++++++++++++++++++++++-
 2 files changed, 39 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index b8c88aa19fef..0200bed6e5d6 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -259,6 +259,9 @@ enum {
 	IFLA_BR_MCAST_QUERY_INTVL,
 	IFLA_BR_MCAST_QUERY_RESPONSE_INTVL,
 	IFLA_BR_MCAST_STARTUP_QUERY_INTVL,
+	IFLA_BR_NF_CALL_IPTABLES,
+	IFLA_BR_NF_CALL_IP6TABLES,
+	IFLA_BR_NF_CALL_ARPTABLES,
 	__IFLA_BR_MAX,
 };
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index 30def4fb5901..fd37caf02b51 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -781,6 +781,9 @@ static const struct nla_policy br_policy[IFLA_BR_MAX + 1] = {
 	[IFLA_BR_MCAST_QUERY_INTVL] = { .type = NLA_U64 },
 	[IFLA_BR_MCAST_QUERY_RESPONSE_INTVL] = { .type = NLA_U64 },
 	[IFLA_BR_MCAST_STARTUP_QUERY_INTVL] = { .type = NLA_U64 },
+	[IFLA_BR_NF_CALL_IPTABLES] = { .type = NLA_U8 },
+	[IFLA_BR_NF_CALL_IP6TABLES] = { .type = NLA_U8 },
+	[IFLA_BR_NF_CALL_ARPTABLES] = { .type = NLA_U8 },
 };
 
 static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
@@ -970,6 +973,25 @@ static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
 		br->multicast_startup_query_interval = clock_t_to_jiffies(val);
 	}
 #endif
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
+	if (data[IFLA_BR_NF_CALL_IPTABLES]) {
+		u8 val = nla_get_u8(data[IFLA_BR_NF_CALL_IPTABLES]);
+
+		br->nf_call_iptables = val ? true : false;
+	}
+
+	if (data[IFLA_BR_NF_CALL_IP6TABLES]) {
+		u8 val = nla_get_u8(data[IFLA_BR_NF_CALL_IP6TABLES]);
+
+		br->nf_call_ip6tables = val ? true : false;
+	}
+
+	if (data[IFLA_BR_NF_CALL_ARPTABLES]) {
+		u8 val = nla_get_u8(data[IFLA_BR_NF_CALL_ARPTABLES]);
+
+		br->nf_call_arptables = val ? true : false;
+	}
+#endif
 
 	return 0;
 }
@@ -1014,6 +1036,11 @@ static size_t br_get_size(const struct net_device *brdev)
 	       nla_total_size(sizeof(u64)) +    /* IFLA_BR_MCAST_QUERY_RESPONSE_INTVL */
 	       nla_total_size(sizeof(u64)) +    /* IFLA_BR_MCAST_STARTUP_QUERY_INTVL */
 #endif
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
+	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_NF_CALL_IPTABLES */
+	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_NF_CALL_IP6TABLES */
+	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_NF_CALL_ARPTABLES */
+#endif
 	       0;
 }
 
@@ -1070,7 +1097,6 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	if (nla_put_be16(skb, IFLA_BR_VLAN_PROTOCOL, br->vlan_proto))
 		return -EMSGSIZE;
 #endif
-
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	if (nla_put_u8(skb, IFLA_BR_MCAST_ROUTER, br->multicast_router) ||
 	    nla_put_u8(skb, IFLA_BR_MCAST_SNOOPING, !br->multicast_disabled) ||
@@ -1105,6 +1131,15 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	if (nla_put_u64(skb, IFLA_BR_MCAST_STARTUP_QUERY_INTVL, clockval))
 		return -EMSGSIZE;
 #endif
+#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
+	if (nla_put_u8(skb, IFLA_BR_NF_CALL_IPTABLES,
+		       br->nf_call_iptables ? 1 : 0) ||
+	    nla_put_u8(skb, IFLA_BR_NF_CALL_IP6TABLES,
+		       br->nf_call_ip6tables ? 1 : 0) ||
+	    nla_put_u8(skb, IFLA_BR_NF_CALL_ARPTABLES,
+		       br->nf_call_arptables ? 1 : 0))
+		return -EMSGSIZE;
+#endif
 
 	return 0;
 }
-- 
2.4.3
