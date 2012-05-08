From: pablo@netfilter.org
Subject: [PATCH 04/25] netfilter: bridge: optionally set indev to vlan
Date: Tue,  8 May 2012 20:38:02 +0200
Message-ID: <1336502303-1722-5-git-send-email-pablo@netfilter.org>
References: <1336502303-1722-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, openbsc@lists.osmocom.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:39679 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756685Ab2EHSk3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 May 2012 14:40:29 -0400
In-Reply-To: <1336502303-1722-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>

if net.bridge.bridge-nf-filter-vlan-tagged sysctl is enabled, bridge
netfilter removes the vlan header temporarily and then feeds the packet
to ip(6)tables.

When the new "bridge-nf-pass-vlan-input-device" sysctl is on
(default off), then bridge netfilter will also set the
in-interface to the vlan interface; if such an interface exists.

This is needed to make iptables REDIRECT target work with
"vlan-on-top-of-bridge" setups and to allow use of "iptables -i" to
match the vlan device name.

Also update Documentation with current brnf default settings.

Signed-off-by: Florian Westphal <fw@strlen.de>
Acked-by: Bart De Schuymer <bdschuym@pandora.be>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 Documentation/networking/ip-sysctl.txt |   13 +++++++++++--
 net/bridge/br_netfilter.c              |   26 ++++++++++++++++++++++++--
 2 files changed, 35 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 90b0c4f..6f896b9 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1301,13 +1301,22 @@ bridge-nf-call-ip6tables - BOOLEAN
 bridge-nf-filter-vlan-tagged - BOOLEAN
 	1 : pass bridged vlan-tagged ARP/IP/IPv6 traffic to {arp,ip,ip6}tables.
 	0 : disable this.
-	Default: 1
+	Default: 0
 
 bridge-nf-filter-pppoe-tagged - BOOLEAN
 	1 : pass bridged pppoe-tagged IP/IPv6 traffic to {ip,ip6}tables.
 	0 : disable this.
-	Default: 1
+	Default: 0
 
+bridge-nf-pass-vlan-input-dev - BOOLEAN
+	1: if bridge-nf-filter-vlan-tagged is enabled, try to find a vlan
+	interface on the bridge and set the netfilter input device to the vlan.
+	This allows use of e.g. "iptables -i br0.1" and makes the REDIRECT
+	target work with vlan-on-top-of-bridge interfaces.  When no matching
+	vlan interface is found, or this switch is off, the input device is
+	set to the bridge interface.
+	0: disable bridge netfilter vlan interface lookup.
+	Default: 0
 
 proc/sys/net/sctp/* Variables:
 
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 53f0836..dce55d4 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -54,12 +54,14 @@ static int brnf_call_ip6tables __read_mostly = 1;
 static int brnf_call_arptables __read_mostly = 1;
 static int brnf_filter_vlan_tagged __read_mostly = 0;
 static int brnf_filter_pppoe_tagged __read_mostly = 0;
+static int brnf_pass_vlan_indev __read_mostly = 0;
 #else
 #define brnf_call_iptables 1
 #define brnf_call_ip6tables 1
 #define brnf_call_arptables 1
 #define brnf_filter_vlan_tagged 0
 #define brnf_filter_pppoe_tagged 0
+#define brnf_pass_vlan_indev 0
 #endif
 
 #define IS_IP(skb) \
@@ -503,6 +505,19 @@ bridged_dnat:
 	return 0;
 }
 
+static struct net_device *brnf_get_logical_dev(struct sk_buff *skb, const struct net_device *dev)
+{
+	struct net_device *vlan, *br;
+
+	br = bridge_parent(dev);
+	if (brnf_pass_vlan_indev == 0 || !vlan_tx_tag_present(skb))
+		return br;
+
+	vlan = __vlan_find_dev_deep(br, vlan_tx_tag_get(skb) & VLAN_VID_MASK);
+
+	return vlan ? vlan : br;
+}
+
 /* Some common code for IPv4/IPv6 */
 static struct net_device *setup_pre_routing(struct sk_buff *skb)
 {
@@ -515,7 +530,7 @@ static struct net_device *setup_pre_routing(struct sk_buff *skb)
 
 	nf_bridge->mask |= BRNF_NF_BRIDGE_PREROUTING;
 	nf_bridge->physindev = skb->dev;
-	skb->dev = bridge_parent(skb->dev);
+	skb->dev = brnf_get_logical_dev(skb, skb->dev);
 	if (skb->protocol == htons(ETH_P_8021Q))
 		nf_bridge->mask |= BRNF_8021Q;
 	else if (skb->protocol == htons(ETH_P_PPP_SES))
@@ -774,7 +789,7 @@ static unsigned int br_nf_forward_ip(unsigned int hook, struct sk_buff *skb,
 	else
 		skb->protocol = htons(ETH_P_IPV6);
 
-	NF_HOOK(pf, NF_INET_FORWARD, skb, bridge_parent(in), parent,
+	NF_HOOK(pf, NF_INET_FORWARD, skb, brnf_get_logical_dev(skb, in), parent,
 		br_nf_forward_finish);
 
 	return NF_STOLEN;
@@ -1002,6 +1017,13 @@ static ctl_table brnf_table[] = {
 		.mode		= 0644,
 		.proc_handler	= brnf_sysctl_call_tables,
 	},
+	{
+		.procname	= "bridge-nf-pass-vlan-input-dev",
+		.data		= &brnf_pass_vlan_indev,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= brnf_sysctl_call_tables,
+	},
 	{ }
 };
 #endif
-- 
1.7.9.5
