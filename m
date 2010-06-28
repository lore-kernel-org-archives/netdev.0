From: kaber@trash.net
Subject: [PATCH] bridge: add per bridge device controls for invoking iptables
Date: Mon, 28 Jun 2010 14:47:00 +0200
Message-ID: <1277729220-11775-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58460 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754185Ab0F1MrD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 08:47:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Support more fine grained control of bridge netfilter iptables invocation
by adding seperate brnf_call_*tables parameters for each device using the
sysfs interface. Packets are passed to layer 3 netfilter when either the
global parameter or the per bridge parameter is enabled.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/bridge/br_netfilter.c |   31 ++++++++++++++-----
 net/bridge/br_private.h   |    3 ++
 net/bridge/br_sysfs_br.c  |   72 +++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 97 insertions(+), 9 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 4442099..236a054 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -55,6 +55,9 @@ static int brnf_call_arptables __read_mostly = 1;
 static int brnf_filter_vlan_tagged __read_mostly = 0;
 static int brnf_filter_pppoe_tagged __read_mostly = 0;
 #else
+#define brnf_call_iptables 1
+#define brnf_call_ip6tables 1
+#define brnf_call_arptables 1
 #define brnf_filter_vlan_tagged 0
 #define brnf_filter_pppoe_tagged 0
 #endif
@@ -545,25 +548,30 @@ static unsigned int br_nf_pre_routing(unsigned int hook, struct sk_buff *skb,
 				      const struct net_device *out,
 				      int (*okfn)(struct sk_buff *))
 {
+	struct net_bridge_port *p;
+	struct net_bridge *br;
 	struct iphdr *iph;
 	__u32 len = nf_bridge_encap_header_len(skb);
 
 	if (unlikely(!pskb_may_pull(skb, len)))
 		goto out;
 
+	p = rcu_dereference(in->br_port);
+	if (p == NULL)
+		goto out;
+	br = p->br;
+
 	if (skb->protocol == htons(ETH_P_IPV6) || IS_VLAN_IPV6(skb) ||
 	    IS_PPPOE_IPV6(skb)) {
-#ifdef CONFIG_SYSCTL
-		if (!brnf_call_ip6tables)
+		if (!brnf_call_ip6tables && !br->nf_call_ip6tables)
 			return NF_ACCEPT;
-#endif
+
 		nf_bridge_pull_encap_header_rcsum(skb);
 		return br_nf_pre_routing_ipv6(hook, skb, in, out, okfn);
 	}
-#ifdef CONFIG_SYSCTL
-	if (!brnf_call_iptables)
+
+	if (!brnf_call_iptables && !br->nf_call_iptables)
 		return NF_ACCEPT;
-#endif
 
 	if (skb->protocol != htons(ETH_P_IP) && !IS_VLAN_IP(skb) &&
 	    !IS_PPPOE_IP(skb))
@@ -716,12 +724,17 @@ static unsigned int br_nf_forward_arp(unsigned int hook, struct sk_buff *skb,
 				      const struct net_device *out,
 				      int (*okfn)(struct sk_buff *))
 {
+	struct net_bridge_port *p;
+	struct net_bridge *br;
 	struct net_device **d = (struct net_device **)(skb->cb);
 
-#ifdef CONFIG_SYSCTL
-	if (!brnf_call_arptables)
+	p = rcu_dereference(out->br_port);
+	if (p == NULL)
+		return NF_ACCEPT;
+	br = p->br;
+
+	if (!brnf_call_arptables && !br->nf_call_arptables)
 		return NF_ACCEPT;
-#endif
 
 	if (skb->protocol != htons(ETH_P_ARP)) {
 		if (!IS_VLAN_ARP(skb))
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 0f4a74b..2ff13a3 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -164,6 +164,9 @@ struct net_bridge
 	unsigned long			feature_mask;
 #ifdef CONFIG_BRIDGE_NETFILTER
 	struct rtable 			fake_rtable;
+	bool				nf_call_iptables;
+	bool				nf_call_ip6tables;
+	bool				nf_call_arptables;
 #endif
 	unsigned long			flags;
 #define BR_SET_MAC_ADDR		0x00000001
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 486b8f3..5c1e555 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -611,6 +611,73 @@ static DEVICE_ATTR(multicast_startup_query_interval, S_IRUGO | S_IWUSR,
 		   show_multicast_startup_query_interval,
 		   store_multicast_startup_query_interval);
 #endif
+#ifdef CONFIG_BRIDGE_NETFILTER
+static ssize_t show_nf_call_iptables(
+	struct device *d, struct device_attribute *attr, char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	return sprintf(buf, "%u\n", br->nf_call_iptables);
+}
+
+static int set_nf_call_iptables(struct net_bridge *br, unsigned long val)
+{
+	br->nf_call_iptables = val ? true : false;
+	return 0;
+}
+
+static ssize_t store_nf_call_iptables(
+	struct device *d, struct device_attribute *attr, const char *buf,
+	size_t len)
+{
+	return store_bridge_parm(d, buf, len, set_nf_call_iptables);
+}
+static DEVICE_ATTR(nf_call_iptables, S_IRUGO | S_IWUSR,
+		   show_nf_call_iptables, store_nf_call_iptables);
+
+static ssize_t show_nf_call_ip6tables(
+	struct device *d, struct device_attribute *attr, char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	return sprintf(buf, "%u\n", br->nf_call_ip6tables);
+}
+
+static int set_nf_call_ip6tables(struct net_bridge *br, unsigned long val)
+{
+	br->nf_call_ip6tables = val ? true : false;
+	return 0;
+}
+
+static ssize_t store_nf_call_ip6tables(
+	struct device *d, struct device_attribute *attr, const char *buf,
+	size_t len)
+{
+	return store_bridge_parm(d, buf, len, set_nf_call_ip6tables);
+}
+static DEVICE_ATTR(nf_call_ip6tables, S_IRUGO | S_IWUSR,
+		   show_nf_call_ip6tables, store_nf_call_ip6tables);
+
+static ssize_t show_nf_call_arptables(
+	struct device *d, struct device_attribute *attr, char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+	return sprintf(buf, "%u\n", br->nf_call_arptables);
+}
+
+static int set_nf_call_arptables(struct net_bridge *br, unsigned long val)
+{
+	br->nf_call_arptables = val ? true : false;
+	return 0;
+}
+
+static ssize_t store_nf_call_arptables(
+	struct device *d, struct device_attribute *attr, const char *buf,
+	size_t len)
+{
+	return store_bridge_parm(d, buf, len, set_nf_call_arptables);
+}
+static DEVICE_ATTR(nf_call_arptables, S_IRUGO | S_IWUSR,
+		   show_nf_call_arptables, store_nf_call_arptables);
+#endif
 
 static struct attribute *bridge_attrs[] = {
 	&dev_attr_forward_delay.attr,
@@ -645,6 +712,11 @@ static struct attribute *bridge_attrs[] = {
 	&dev_attr_multicast_query_response_interval.attr,
 	&dev_attr_multicast_startup_query_interval.attr,
 #endif
+#ifdef CONFIG_BRIDGE_NETFILTER
+	&dev_attr_nf_call_iptables.attr,
+	&dev_attr_nf_call_ip6tables.attr,
+	&dev_attr_nf_call_arptables.attr,
+#endif
 	NULL
 };
 
-- 
1.7.0.4

