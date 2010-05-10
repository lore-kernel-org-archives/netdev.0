From: kaber@trash.net
Subject: [PATCH 36/84] netfilter: bridge: use NFPROTO values for NF_HOOK invocation
Date: Mon, 10 May 2010 22:18:07 +0200
Message-ID: <1273522735-24672-37-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54511 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756774Ab0EJUTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 16:19:07 -0400
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>

The first argument to NF_HOOK* is an nfproto since quite some time.
Commit v2.6.27-2457-gfdc9314 was the first to practically start using
the new names. Do that now for the remaining NF_HOOK calls.

The semantic patch used was:
// <smpl>
@@
@@
(NF_HOOK
|NF_HOOK_THRESH
)(
-PF_BRIDGE,
+NFPROTO_BRIDGE,
 ...)

@@
@@
 NF_HOOK(
-PF_INET6,
+NFPROTO_IPV6,
 ...)

@@
@@
 NF_HOOK(
-PF_INET,
+NFPROTO_IPV4,
 ...)
// </smpl>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/bridge/br_forward.c   |   10 +++++-----
 net/bridge/br_input.c     |    6 +++---
 net/bridge/br_multicast.c |    2 +-
 net/bridge/br_netfilter.c |   15 ++++++++-------
 net/bridge/br_stp_bpdu.c  |    2 +-
 5 files changed, 18 insertions(+), 17 deletions(-)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 8dbec83..7ab52d0 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -58,7 +58,7 @@ int br_dev_queue_push_xmit(struct sk_buff *skb)
 
 int br_forward_finish(struct sk_buff *skb)
 {
-	return NF_HOOK(PF_BRIDGE, NF_BR_POST_ROUTING, skb, NULL, skb->dev,
+	return NF_HOOK(NFPROTO_BRIDGE, NF_BR_POST_ROUTING, skb, NULL, skb->dev,
 		       br_dev_queue_push_xmit);
 
 }
@@ -66,8 +66,8 @@ int br_forward_finish(struct sk_buff *skb)
 static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 {
 	skb->dev = to->dev;
-	NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_OUT, skb, NULL, skb->dev,
-			br_forward_finish);
+	NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT, skb, NULL, skb->dev,
+		br_forward_finish);
 }
 
 static void __br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
@@ -83,8 +83,8 @@ static void __br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
 	skb->dev = to->dev;
 	skb_forward_csum(skb);
 
-	NF_HOOK(PF_BRIDGE, NF_BR_FORWARD, skb, indev, skb->dev,
-			br_forward_finish);
+	NF_HOOK(NFPROTO_BRIDGE, NF_BR_FORWARD, skb, indev, skb->dev,
+		br_forward_finish);
 }
 
 /* called with rcu_read_lock */
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 333dfb7..c9018fc 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -32,7 +32,7 @@ static int br_pass_frame_up(struct sk_buff *skb)
 	indev = skb->dev;
 	skb->dev = brdev;
 
-	return NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, indev, NULL,
+	return NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, indev, NULL,
 		       netif_receive_skb);
 }
 
@@ -155,7 +155,7 @@ struct sk_buff *br_handle_frame(struct net_bridge_port *p, struct sk_buff *skb)
 		if (p->br->stp_enabled == BR_NO_STP && dest[5] == 0)
 			goto forward;
 
-		if (NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
+		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
 			    NULL, br_handle_local_finish))
 			return NULL;	/* frame consumed by filter */
 		else
@@ -176,7 +176,7 @@ forward:
 		if (!compare_ether_addr(p->br->dev->dev_addr, dest))
 			skb->pkt_type = PACKET_HOST;
 
-		NF_HOOK(PF_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
+		NF_HOOK(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
 			br_handle_frame_finish);
 		break;
 	default:
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 6980625..ed19b0a 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -608,7 +608,7 @@ static void br_multicast_send_query(struct net_bridge *br,
 	if (port) {
 		__skb_push(skb, sizeof(struct ethhdr));
 		skb->dev = port->dev;
-		NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_OUT, skb, NULL, skb->dev,
+		NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT, skb, NULL, skb->dev,
 			dev_queue_xmit);
 	} else
 		netif_rx(skb);
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 268e2e7..bc6b572 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -246,7 +246,7 @@ static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
 
 	skb->dev = nf_bridge->physindev;
 	nf_bridge_push_encap_header(skb);
-	NF_HOOK_THRESH(PF_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
+	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
 		       br_handle_frame_finish, 1);
 
 	return 0;
@@ -396,7 +396,8 @@ bridged_dnat:
 				nf_bridge->mask |= BRNF_BRIDGED_DNAT;
 				skb->dev = nf_bridge->physindev;
 				nf_bridge_push_encap_header(skb);
-				NF_HOOK_THRESH(PF_BRIDGE, NF_BR_PRE_ROUTING,
+				NF_HOOK_THRESH(NFPROTO_BRIDGE,
+					       NF_BR_PRE_ROUTING,
 					       skb, skb->dev, NULL,
 					       br_nf_pre_routing_finish_bridge,
 					       1);
@@ -417,7 +418,7 @@ bridged_dnat:
 
 	skb->dev = nf_bridge->physindev;
 	nf_bridge_push_encap_header(skb);
-	NF_HOOK_THRESH(PF_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
+	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
 		       br_handle_frame_finish, 1);
 
 	return 0;
@@ -534,7 +535,7 @@ static unsigned int br_nf_pre_routing_ipv6(unsigned int hook,
 	if (!setup_pre_routing(skb))
 		return NF_DROP;
 
-	NF_HOOK(PF_INET6, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
+	NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
 		br_nf_pre_routing_finish_ipv6);
 
 	return NF_STOLEN;
@@ -607,7 +608,7 @@ static unsigned int br_nf_pre_routing(unsigned int hook, struct sk_buff *skb,
 		return NF_DROP;
 	store_orig_dstaddr(skb);
 
-	NF_HOOK(PF_INET, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
+	NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, skb, skb->dev, NULL,
 		br_nf_pre_routing_finish);
 
 	return NF_STOLEN;
@@ -655,7 +656,7 @@ static int br_nf_forward_finish(struct sk_buff *skb)
 		in = *((struct net_device **)(skb->cb));
 	}
 	nf_bridge_push_encap_header(skb);
-	NF_HOOK_THRESH(PF_BRIDGE, NF_BR_FORWARD, skb, in,
+	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_FORWARD, skb, in,
 		       skb->dev, br_forward_finish, 1);
 	return 0;
 }
@@ -786,7 +787,7 @@ static unsigned int br_nf_local_out(unsigned int hook, struct sk_buff *skb,
 	}
 	nf_bridge_push_encap_header(skb);
 
-	NF_HOOK(PF_BRIDGE, NF_BR_FORWARD, skb, realindev, skb->dev,
+	NF_HOOK(NFPROTO_BRIDGE, NF_BR_FORWARD, skb, realindev, skb->dev,
 		br_forward_finish);
 	return NF_STOLEN;
 }
diff --git a/net/bridge/br_stp_bpdu.c b/net/bridge/br_stp_bpdu.c
index 81ae40b..11b0157 100644
--- a/net/bridge/br_stp_bpdu.c
+++ b/net/bridge/br_stp_bpdu.c
@@ -49,7 +49,7 @@ static void br_send_bpdu(struct net_bridge_port *p,
 
 	llc_mac_hdr_init(skb, p->dev->dev_addr, p->br->group_addr);
 
-	NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_OUT, skb, NULL, skb->dev,
+	NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT, skb, NULL, skb->dev,
 		dev_queue_xmit);
 }
 
-- 
1.7.0.4

