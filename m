From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 20/20] bridge: netlink: add support for default_pvid
Date: Sun,  4 Oct 2015 14:23:47 +0200
Message-ID: <1443961427-15085-21-git-send-email-razor@blackwall.org>
References: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
	stephen@networkplumber.org, bridge@lists.linux-foundation.org,
	shm@cumulusnetworks.com,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:36189 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751660AbbJDMY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2015 08:24:27 -0400
Received: by wicgb1 with SMTP id gb1so85081971wic.1
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 05:24:26 -0700 (PDT)
In-Reply-To: <1443961427-15085-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Add IFLA_BR_VLAN_DEFAULT_PVID to allow setting/getting bridge's
default_pvid via netlink.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h |  1 +
 net/bridge/br_netlink.c      | 13 ++++++++++++-
 net/bridge/br_private.h      |  1 +
 net/bridge/br_vlan.c         | 14 +++++++-------
 4 files changed, 21 insertions(+), 8 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 0200bed6e5d6..c5b15bfeabe2 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -262,6 +262,7 @@ enum {
 	IFLA_BR_NF_CALL_IPTABLES,
 	IFLA_BR_NF_CALL_IP6TABLES,
 	IFLA_BR_NF_CALL_ARPTABLES,
+	IFLA_BR_VLAN_DEFAULT_PVID,
 	__IFLA_BR_MAX,
 };
 
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index fd37caf02b51..70efe2edde2b 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -784,6 +784,7 @@ static const struct nla_policy br_policy[IFLA_BR_MAX + 1] = {
 	[IFLA_BR_NF_CALL_IPTABLES] = { .type = NLA_U8 },
 	[IFLA_BR_NF_CALL_IP6TABLES] = { .type = NLA_U8 },
 	[IFLA_BR_NF_CALL_ARPTABLES] = { .type = NLA_U8 },
+	[IFLA_BR_VLAN_DEFAULT_PVID] = { .type = NLA_U16 },
 };
 
 static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
@@ -847,6 +848,14 @@ static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
 		if (err)
 			return err;
 	}
+
+	if (data[IFLA_BR_VLAN_DEFAULT_PVID]) {
+		__u16 defpvid = nla_get_u16(data[IFLA_BR_VLAN_DEFAULT_PVID]);
+
+		err = __br_vlan_set_default_pvid(br, defpvid);
+		if (err)
+			return err;
+	}
 #endif
 
 	if (data[IFLA_BR_GROUP_FWD_MASK]) {
@@ -1007,6 +1016,7 @@ static size_t br_get_size(const struct net_device *brdev)
 	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_VLAN_FILTERING */
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
 	       nla_total_size(sizeof(__be16)) +	/* IFLA_BR_VLAN_PROTOCOL */
+	       nla_total_size(sizeof(u16)) +    /* IFLA_BR_VLAN_DEFAULT_PVID */
 #endif
 	       nla_total_size(sizeof(u16)) +    /* IFLA_BR_GROUP_FWD_MASK */
 	       nla_total_size(sizeof(struct ifla_bridge_id)) +   /* IFLA_BR_ROOT_ID */
@@ -1094,7 +1104,8 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 		return -EMSGSIZE;
 
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
-	if (nla_put_be16(skb, IFLA_BR_VLAN_PROTOCOL, br->vlan_proto))
+	if (nla_put_be16(skb, IFLA_BR_VLAN_PROTOCOL, br->vlan_proto) ||
+	    nla_put_u16(skb, IFLA_BR_VLAN_DEFAULT_PVID, br->default_pvid))
 		return -EMSGSIZE;
 #endif
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 1ff6a0faef3f..09d3ecbcb4f0 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -690,6 +690,7 @@ int __br_vlan_set_proto(struct net_bridge *br, __be16 proto);
 int br_vlan_set_proto(struct net_bridge *br, unsigned long val);
 int br_vlan_init(struct net_bridge *br);
 int br_vlan_set_default_pvid(struct net_bridge *br, unsigned long val);
+int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid);
 int nbp_vlan_add(struct net_bridge_port *port, u16 vid, u16 flags);
 int nbp_vlan_delete(struct net_bridge_port *port, u16 vid);
 void nbp_vlan_flush(struct net_bridge_port *port);
diff --git a/net/bridge/br_vlan.c b/net/bridge/br_vlan.c
index b879111582f0..eae07ee9bfe0 100644
--- a/net/bridge/br_vlan.c
+++ b/net/bridge/br_vlan.c
@@ -727,7 +727,7 @@ static void br_vlan_disable_default_pvid(struct net_bridge *br)
 	br->default_pvid = 0;
 }
 
-static int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid)
+int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid)
 {
 	const struct net_bridge_vlan *pvent;
 	struct net_bridge_port *p;
@@ -735,6 +735,11 @@ static int __br_vlan_set_default_pvid(struct net_bridge *br, u16 pvid)
 	int err = 0;
 	unsigned long *changed;
 
+	if (!pvid) {
+		br_vlan_disable_default_pvid(br);
+		return 0;
+	}
+
 	changed = kcalloc(BITS_TO_LONGS(BR_MAX_PORTS), sizeof(unsigned long),
 			  GFP_KERNEL);
 	if (!changed)
@@ -825,12 +830,7 @@ int br_vlan_set_default_pvid(struct net_bridge *br, unsigned long val)
 		err = -EPERM;
 		goto unlock;
 	}
-
-	if (!pvid)
-		br_vlan_disable_default_pvid(br);
-	else
-		err = __br_vlan_set_default_pvid(br, pvid);
-
+	err = __br_vlan_set_default_pvid(br, pvid);
 unlock:
 	rtnl_unlock();
 	return err;
-- 
2.4.3
