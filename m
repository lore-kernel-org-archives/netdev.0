From: pablo@netfilter.org
Subject: [PATCH 5/6] bridge: netfilter: don't call iptables on vlan packets if sysctl is off
Date: Tue,  6 Mar 2012 12:22:54 +0100
Message-ID: <1331032975-5303-6-git-send-email-pablo@netfilter.org>
References: <1331032975-5303-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48363 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759078Ab2CFLXO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2012 06:23:14 -0500
In-Reply-To: <1331032975-5303-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

When net.bridge.bridge-nf-filter-vlan-tagged is 0 (default), vlan packets
arriving should not be sent to ip(6)tables by bridge netfilter.

However, it turns out that we currently always send VLAN packets to
netfilter, if ..
a), CONFIG_VLAN_8021Q is enabled ; or
b), CONFIG_VLAN_8021Q is not set but rx vlan offload is enabled
   on the bridge port.

This is because bridge netfilter treats skb with
skb->protocol == ETH_P_IP{V6} as "non-vlan packet".

With rx vlan offload on or CONFIG_VLAN_8021Q=y, the vlan header has
already been removed here, and we cannot rely on skb->protocol alone.

Fix this by only using skb->protocol if the skb has no vlan tag,
or if a vlan tag is present and filter-vlan-tagged bridge netfilter
sysctl is enabled.

We cannot remove the skb->protocol == htons(ETH_P_8021Q) test
because the vlan tag is still around in the CONFIG_VLAN_8021Q=n &&
"ethtool -K $itf rxvlan off" case.

reproducer:
iptables -t raw -I PREROUTING -i br0
iptables -t raw -I PREROUTING -i br0.1

Then send packets to an ip address configured on br0.1 interface.
Even with net.bridge.bridge-nf-filter-vlan-tagged=0, the 1st rule
will match instead of the 2nd one.

With this patch applied, the 2nd rule will match instead.
In the non-local address case, netfilter won't be consulted after
this patch unless the sysctl is switched on.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/br_netfilter.c |   32 ++++++++++++++++++--------------
 1 files changed, 18 insertions(+), 14 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 8412247..dec4f38 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -62,6 +62,15 @@ static int brnf_filter_pppoe_tagged __read_mostly = 0;
 #define brnf_filter_pppoe_tagged 0
 #endif
 
+#define IS_IP(skb) \
+	(!vlan_tx_tag_present(skb) && skb->protocol == htons(ETH_P_IP))
+
+#define IS_IPV6(skb) \
+	(!vlan_tx_tag_present(skb) && skb->protocol == htons(ETH_P_IPV6))
+
+#define IS_ARP(skb) \
+	(!vlan_tx_tag_present(skb) && skb->protocol == htons(ETH_P_ARP))
+
 static inline __be16 vlan_proto(const struct sk_buff *skb)
 {
 	if (vlan_tx_tag_present(skb))
@@ -639,8 +648,7 @@ static unsigned int br_nf_pre_routing(unsigned int hook, struct sk_buff *skb,
 		return NF_DROP;
 	br = p->br;
 
-	if (skb->protocol == htons(ETH_P_IPV6) || IS_VLAN_IPV6(skb) ||
-	    IS_PPPOE_IPV6(skb)) {
+	if (IS_IPV6(skb) || IS_VLAN_IPV6(skb) || IS_PPPOE_IPV6(skb)) {
 		if (!brnf_call_ip6tables && !br->nf_call_ip6tables)
 			return NF_ACCEPT;
 
@@ -651,8 +659,7 @@ static unsigned int br_nf_pre_routing(unsigned int hook, struct sk_buff *skb,
 	if (!brnf_call_iptables && !br->nf_call_iptables)
 		return NF_ACCEPT;
 
-	if (skb->protocol != htons(ETH_P_IP) && !IS_VLAN_IP(skb) &&
-	    !IS_PPPOE_IP(skb))
+	if (!IS_IP(skb) && !IS_VLAN_IP(skb) && !IS_PPPOE_IP(skb))
 		return NF_ACCEPT;
 
 	nf_bridge_pull_encap_header_rcsum(skb);
@@ -701,7 +708,7 @@ static int br_nf_forward_finish(struct sk_buff *skb)
 	struct nf_bridge_info *nf_bridge = skb->nf_bridge;
 	struct net_device *in;
 
-	if (skb->protocol != htons(ETH_P_ARP) && !IS_VLAN_ARP(skb)) {
+	if (!IS_ARP(skb) && !IS_VLAN_ARP(skb)) {
 		in = nf_bridge->physindev;
 		if (nf_bridge->mask & BRNF_PKT_TYPE) {
 			skb->pkt_type = PACKET_OTHERHOST;
@@ -718,6 +725,7 @@ static int br_nf_forward_finish(struct sk_buff *skb)
 	return 0;
 }
 
+
 /* This is the 'purely bridged' case.  For IP, we pass the packet to
  * netfilter with indev and outdev set to the bridge device,
  * but we are still able to filter on the 'real' indev/outdev
@@ -744,11 +752,9 @@ static unsigned int br_nf_forward_ip(unsigned int hook, struct sk_buff *skb,
 	if (!parent)
 		return NF_DROP;
 
-	if (skb->protocol == htons(ETH_P_IP) || IS_VLAN_IP(skb) ||
-	    IS_PPPOE_IP(skb))
+	if (IS_IP(skb) || IS_VLAN_IP(skb) || IS_PPPOE_IP(skb))
 		pf = PF_INET;
-	else if (skb->protocol == htons(ETH_P_IPV6) || IS_VLAN_IPV6(skb) ||
-		 IS_PPPOE_IPV6(skb))
+	else if (IS_IPV6(skb) || IS_VLAN_IPV6(skb) || IS_PPPOE_IPV6(skb))
 		pf = PF_INET6;
 	else
 		return NF_ACCEPT;
@@ -795,7 +801,7 @@ static unsigned int br_nf_forward_arp(unsigned int hook, struct sk_buff *skb,
 	if (!brnf_call_arptables && !br->nf_call_arptables)
 		return NF_ACCEPT;
 
-	if (skb->protocol != htons(ETH_P_ARP)) {
+	if (!IS_ARP(skb)) {
 		if (!IS_VLAN_ARP(skb))
 			return NF_ACCEPT;
 		nf_bridge_pull_encap_header(skb);
@@ -853,11 +859,9 @@ static unsigned int br_nf_post_routing(unsigned int hook, struct sk_buff *skb,
 	if (!realoutdev)
 		return NF_DROP;
 
-	if (skb->protocol == htons(ETH_P_IP) || IS_VLAN_IP(skb) ||
-	    IS_PPPOE_IP(skb))
+	if (IS_IP(skb) || IS_VLAN_IP(skb) || IS_PPPOE_IP(skb))
 		pf = PF_INET;
-	else if (skb->protocol == htons(ETH_P_IPV6) || IS_VLAN_IPV6(skb) ||
-		 IS_PPPOE_IPV6(skb))
+	else if (IS_IPV6(skb) || IS_VLAN_IPV6(skb) || IS_PPPOE_IPV6(skb))
 		pf = PF_INET6;
 	else
 		return NF_ACCEPT;
-- 
1.7.7.3
