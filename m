From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH RFC net-next 4/4] bridge: add ability to turn off fdb used updates
Date: Tue, 31 Jan 2017 16:31:58 +0100
Message-ID: <1485876718-18091-5-git-send-email-nikolay@cumulusnetworks.com>
References: <1485876718-18091-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, stephen@networkplumber.org,
        davem@davemloft.net,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36408 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750970AbdAaPcb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 10:32:31 -0500
Received: by mail-wm0-f45.google.com with SMTP id c85so265923074wmi.1
        for <netdev@vger.kernel.org>; Tue, 31 Jan 2017 07:32:30 -0800 (PST)
In-Reply-To: <1485876718-18091-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Being able to turn off fdb "used" updates makes it possible to avoid
false-sharing on each packet transmit/receive for that fdb. The best way
to completely avoid false-sharing is by binding ports to CPUs so receive
will write to the "updated" field only on a single CPU and transmit to
that fdb will not touch the "used" field. The default is used_enabled =
1 to avoid breaking user-space, strongly suggest if not needed to set it
to 0.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/uapi/linux/if_link.h |  1 +
 net/bridge/br_device.c       |  1 +
 net/bridge/br_input.c        |  3 ++-
 net/bridge/br_netlink.c      | 10 +++++++++-
 net/bridge/br_private.h      |  1 +
 net/bridge/br_sysfs_br.c     | 23 +++++++++++++++++++++++
 6 files changed, 37 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index b9aa5641ebe5..8bcd234fed03 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -277,6 +277,7 @@ enum {
 	IFLA_BR_MCAST_STATS_ENABLED,
 	IFLA_BR_MCAST_IGMP_VERSION,
 	IFLA_BR_MCAST_MLD_VERSION,
+	IFLA_BR_USED_ENABLED,
 	__IFLA_BR_MAX,
 };
 
diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 89b414fd1901..b1fa1b031fea 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -408,6 +408,7 @@ void br_dev_setup(struct net_device *dev)
 	br->bridge_hello_time = br->hello_time = 2 * HZ;
 	br->bridge_forward_delay = br->forward_delay = 15 * HZ;
 	br->bridge_ageing_time = br->ageing_time = BR_DEFAULT_AGEING_TIME;
+	br->used_enabled = 1;
 	dev->max_mtu = ETH_MAX_MTU;
 
 	br_netfilter_rtable_init(br);
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 855b72fbe1da..8a320901aaa7 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -197,7 +197,8 @@ int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buff *skb
 		if (dst->is_local)
 			return br_pass_frame_up(skb);
 
-		dst->used = jiffies;
+		if (br->used_enabled)
+			dst->used = jiffies;
 		br_forward(dst->dst, skb, local_rcv, false);
 	} else {
 		if (!mcast_hit)
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index d63ad8337dcd..49272efaad00 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -851,6 +851,7 @@ static const struct nla_policy br_policy[IFLA_BR_MAX + 1] = {
 	[IFLA_BR_MCAST_STATS_ENABLED] = { .type = NLA_U8 },
 	[IFLA_BR_MCAST_IGMP_VERSION] = { .type = NLA_U8 },
 	[IFLA_BR_MCAST_MLD_VERSION] = { .type = NLA_U8 },
+	[IFLA_BR_USED_ENABLED] = { .type = NLA_U8 },
 };
 
 static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
@@ -1102,6 +1103,11 @@ static int br_changelink(struct net_device *brdev, struct nlattr *tb[],
 		br->nf_call_arptables = val ? true : false;
 	}
 #endif
+	if (data[IFLA_BR_USED_ENABLED]) {
+		u8 val = nla_get_u8(data[IFLA_BR_USED_ENABLED]);
+
+		br->used_enabled = !!val;
+	}
 
 	return 0;
 }
@@ -1175,6 +1181,7 @@ static size_t br_get_size(const struct net_device *brdev)
 	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_NF_CALL_IP6TABLES */
 	       nla_total_size(sizeof(u8)) +     /* IFLA_BR_NF_CALL_ARPTABLES */
 #endif
+	       nla_total_size(sizeof(u8)) +	/* IFLA_BR_USED_ENABLED */
 	       0;
 }
 
@@ -1246,7 +1253,8 @@ static int br_fill_info(struct sk_buff *skb, const struct net_device *brdev)
 	    nla_put_u32(skb, IFLA_BR_MCAST_STARTUP_QUERY_CNT,
 			br->multicast_startup_query_count) ||
 	    nla_put_u8(skb, IFLA_BR_MCAST_IGMP_VERSION,
-		       br->multicast_igmp_version))
+		       br->multicast_igmp_version) ||
+	    nla_put_u8(skb, IFLA_BR_USED_ENABLED, br->used_enabled))
 		return -EMSGSIZE;
 #if IS_ENABLED(CONFIG_IPV6)
 	if (nla_put_u8(skb, IFLA_BR_MCAST_MLD_VERSION,
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 1e1b9a07e2da..4b6eb2393d7e 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -281,6 +281,7 @@ struct net_bridge {
 	struct net_device		*dev;
 	struct pcpu_sw_netstats		__percpu *stats;
 	/* These fields are accessed on each packet */
+	u8				used_enabled;
 #ifdef CONFIG_BRIDGE_VLAN_FILTERING
 	u8				vlan_enabled;
 	u8				vlan_stats_enabled;
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 0f4034934d56..22adc29e8721 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -334,6 +334,28 @@ static ssize_t flush_store(struct device *d,
 }
 static DEVICE_ATTR_WO(flush);
 
+static ssize_t used_enabled_show(struct device *d,
+				 struct device_attribute *attr, char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+
+	return sprintf(buf, "%u\n", br->used_enabled);
+}
+
+static int set_used_enabled(struct net_bridge *br, unsigned long val)
+{
+	br->used_enabled = !!val;
+	return 0;
+}
+
+static ssize_t used_enabled_store(struct device *d,
+				  struct device_attribute *attr,
+				  const char *buf, size_t len)
+{
+	return store_bridge_parm(d, buf, len, set_used_enabled);
+}
+static DEVICE_ATTR_RW(used_enabled);
+
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 static ssize_t multicast_router_show(struct device *d,
 				     struct device_attribute *attr, char *buf)
@@ -829,6 +851,7 @@ static struct attribute *bridge_attrs[] = {
 	&dev_attr_gc_timer.attr,
 	&dev_attr_group_addr.attr,
 	&dev_attr_flush.attr,
+	&dev_attr_used_enabled.attr,
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	&dev_attr_multicast_router.attr,
 	&dev_attr_multicast_snooping.attr,
-- 
2.1.4
