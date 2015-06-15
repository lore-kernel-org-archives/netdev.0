From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 03/32] netfilter: bridge: re-order br_nf_pre_routing_finish_ipv6()
Date: Mon, 15 Jun 2015 23:26:00 +0200
Message-ID: <1434403589-24796-4-git-send-email-pablo@netfilter.org>
References: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58738 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755876AbbFOVVT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2015 17:21:19 -0400
In-Reply-To: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bernhard Thaler <bernhard.thaler@wvnet.at>

Put br_nf_pre_routing_finish_ipv6() after daddr_was_changed() and
br_nf_pre_routing_finish_bridge() to prepare calling these functions
from there.

Signed-off-by: Bernhard Thaler <bernhard.thaler@wvnet.at>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/br_netfilter.c |   63 +++++++++++++++++++++++----------------------
 1 file changed, 32 insertions(+), 31 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 2651876..6cb642c 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -278,37 +278,6 @@ static void nf_bridge_update_protocol(struct sk_buff *skb)
 	}
 }
 
-/* PF_BRIDGE/PRE_ROUTING *********************************************/
-/* Undo the changes made for ip6tables PREROUTING and continue the
- * bridge PRE_ROUTING hook. */
-static int br_nf_pre_routing_finish_ipv6(struct sock *sk, struct sk_buff *skb)
-{
-	struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
-	struct rtable *rt;
-
-	if (nf_bridge->pkt_otherhost) {
-		skb->pkt_type = PACKET_OTHERHOST;
-		nf_bridge->pkt_otherhost = false;
-	}
-	nf_bridge->mask &= ~BRNF_NF_BRIDGE_PREROUTING;
-
-	rt = bridge_parent_rtable(nf_bridge->physindev);
-	if (!rt) {
-		kfree_skb(skb);
-		return 0;
-	}
-	skb_dst_set_noref(skb, &rt->dst);
-
-	skb->dev = nf_bridge->physindev;
-	nf_bridge_update_protocol(skb);
-	nf_bridge_push_encap_header(skb);
-	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, sk, skb,
-		       skb->dev, NULL,
-		       br_handle_frame_finish, 1);
-
-	return 0;
-}
-
 /* Obtain the correct destination MAC address, while preserving the original
  * source MAC address. If we already know this address, we just copy it. If we
  * don't, we use the neighbour framework to find out. In both cases, we make
@@ -360,6 +329,38 @@ static bool daddr_was_changed(const struct sk_buff *skb,
 	return ip_hdr(skb)->daddr != nf_bridge->ipv4_daddr;
 }
 
+/* PF_BRIDGE/PRE_ROUTING *********************************************/
+/* Undo the changes made for ip6tables PREROUTING and continue the
+ * bridge PRE_ROUTING hook.
+ */
+static int br_nf_pre_routing_finish_ipv6(struct sock *sk, struct sk_buff *skb)
+{
+	struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
+	struct rtable *rt;
+
+	if (nf_bridge->pkt_otherhost) {
+		skb->pkt_type = PACKET_OTHERHOST;
+		nf_bridge->pkt_otherhost = false;
+	}
+	nf_bridge->mask &= ~BRNF_NF_BRIDGE_PREROUTING;
+
+	rt = bridge_parent_rtable(nf_bridge->physindev);
+	if (!rt) {
+		kfree_skb(skb);
+		return 0;
+	}
+	skb_dst_set_noref(skb, &rt->dst);
+
+	skb->dev = nf_bridge->physindev;
+	nf_bridge_update_protocol(skb);
+	nf_bridge_push_encap_header(skb);
+	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, sk, skb,
+		       skb->dev, NULL,
+		       br_handle_frame_finish, 1);
+
+	return 0;
+}
+
 /* This requires some explaining. If DNAT has taken place,
  * we will need to fix up the destination Ethernet address.
  * This is also true when SNAT takes place (for the reply direction).
-- 
1.7.10.4
