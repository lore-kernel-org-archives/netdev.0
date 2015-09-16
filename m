From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 28/30] netfilter: Pass struct net into the netfilter hooks
Date: Tue, 15 Sep 2015 20:04:16 -0500
Message-ID: <1442365458-16349-28-git-send-email-ebiederm@xmission.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87mvwn18my.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pass a network namespace parameter into the netfilter hooks.  At the
call site of the netfilter hooks the path a packet is taking through
the network stack is well known which allows the network namespace to
be easily and reliabily.

This allows the replacement of magic code like
"dev_net(state->in?:state->out)" that appears at the start of most
netfilter hooks with "state->net".

In almost all cases the network namespace passed in is derived
from the first network device passed in, guaranteeing those
paths will not see any changes in practice.

The exceptions are:
xfrm/xfrm_output.c:xfrm_output_resume()         xs_net(skb_dst(skb)->xfrm)
ipvs/ip_vs_xmit.c:ip_vs_nat_send_or_cont()      ip_vs_conn_net(cp)
ipvs/ip_vs_xmit.c:ip_vs_send_or_cont()          ip_vs_conn_net(cp)
ipv4/raw.c:raw_send_hdrinc()                    sock_net(sk)
ipv6/ip6_output.c:ip6_xmit()			sock_net(sk)
ipv6/ndisc.c:ndisc_send_skb()                   dev_net(skb->dev) not dev_net(dst->dev)
ipv6/raw.c:raw6_send_hdrinc()                   sock_net(sk)
br_netfilter_hooks.c:br_nf_pre_routing_finish() dev_net(skb->dev) before skb->dev is set to nf_bridge->physindev

In all cases these exceptions seem to be a better expression for the
network namespace the packet is being processed in then the historic
"dev_net(in?in:out)".  I am documenting them in case something odd
pops up and someone starts trying to track down what happened.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/vrf.c                         |  7 ++++---
 include/linux/netfilter.h                 | 27 ++++++++++++---------------
 net/bridge/br_forward.c                   | 13 +++++++------
 net/bridge/br_input.c                     | 13 +++++++------
 net/bridge/br_multicast.c                 |  4 ++--
 net/bridge/br_netfilter_hooks.c           | 15 ++++++++-------
 net/bridge/br_netfilter_ipv6.c            |  7 ++++---
 net/bridge/br_stp_bpdu.c                  |  4 ++--
 net/decnet/dn_neigh.c                     | 15 +++++++++------
 net/decnet/dn_nsp_in.c                    |  4 ++--
 net/decnet/dn_route.c                     | 24 ++++++++++++------------
 net/ipv4/arp.c                            | 10 ++++++----
 net/ipv4/ip_forward.c                     |  5 +++--
 net/ipv4/ip_input.c                       |  8 ++++----
 net/ipv4/ip_output.c                      | 22 +++++++++++++---------
 net/ipv4/ipmr.c                           |  4 ++--
 net/ipv4/raw.c                            |  5 +++--
 net/ipv4/xfrm4_input.c                    |  4 ++--
 net/ipv4/xfrm4_output.c                   |  6 ++++--
 net/ipv6/ip6_input.c                      |  8 ++++----
 net/ipv6/ip6_output.c                     | 15 ++++++++-------
 net/ipv6/ip6mr.c                          |  4 ++--
 net/ipv6/mcast.c                          |  7 ++++---
 net/ipv6/ndisc.c                          |  4 ++--
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c |  2 +-
 net/ipv6/output_core.c                    |  6 ++++--
 net/ipv6/raw.c                            |  2 +-
 net/ipv6/xfrm6_input.c                    |  4 ++--
 net/ipv6/xfrm6_output.c                   |  6 ++++--
 net/netfilter/ipvs/ip_vs_xmit.c           |  4 ++--
 net/xfrm/xfrm_output.c                    |  3 ++-
 31 files changed, 142 insertions(+), 120 deletions(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index e7094fbd7568..c82260341b72 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -298,14 +298,15 @@ err:
 static int vrf_output(struct sock *sk, struct sk_buff *skb)
 {
 	struct net_device *dev = skb_dst(skb)->dev;
+	struct net *net = dev_net(dev);
 
-	IP_UPD_PO_STATS(dev_net(dev), IPSTATS_MIB_OUT, skb->len);
+	IP_UPD_PO_STATS(net, IPSTATS_MIB_OUT, skb->len);
 
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_IP);
 
-	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING, sk, skb,
-			    NULL, dev,
+	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING,
+			    net, sk, skb, NULL, dev,
 			    vrf_finish_output,
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 042148dc1e22..295f2650b5dc 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -190,12 +190,11 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
 	return 1;
 }
 
-static inline int nf_hook(u_int8_t pf, unsigned int hook, struct sock *sk,
-			  struct sk_buff *skb, struct net_device *indev,
-			  struct net_device *outdev,
+static inline int nf_hook(u_int8_t pf, unsigned int hook, struct net *net,
+			  struct sock *sk, struct sk_buff *skb,
+			  struct net_device *indev, struct net_device *outdev,
 			  int (*okfn)(struct sock *, struct sk_buff *))
 {
-	struct net *net = dev_net(indev ? indev : outdev);
 	return nf_hook_thresh(pf, hook, net, sk, skb, indev, outdev, okfn, INT_MIN);
 }
                    
@@ -217,12 +216,11 @@ static inline int nf_hook(u_int8_t pf, unsigned int hook, struct sock *sk,
 */
 
 static inline int
-NF_HOOK_THRESH(uint8_t pf, unsigned int hook, struct sock *sk,
+NF_HOOK_THRESH(uint8_t pf, unsigned int hook, struct net *net, struct sock *sk,
 	       struct sk_buff *skb, struct net_device *in,
 	       struct net_device *out,
 	       int (*okfn)(struct sock *, struct sk_buff *), int thresh)
 {
-	struct net *net = dev_net(in ? in : out);
 	int ret = nf_hook_thresh(pf, hook, net, sk, skb, in, out, okfn, thresh);
 	if (ret == 1)
 		ret = okfn(sk, skb);
@@ -230,11 +228,10 @@ NF_HOOK_THRESH(uint8_t pf, unsigned int hook, struct sock *sk,
 }
 
 static inline int
-NF_HOOK_COND(uint8_t pf, unsigned int hook, struct sock *sk,
+NF_HOOK_COND(uint8_t pf, unsigned int hook, struct net *net, struct sock *sk,
 	     struct sk_buff *skb, struct net_device *in, struct net_device *out,
 	     int (*okfn)(struct sock *, struct sk_buff *), bool cond)
 {
-	struct net *net = dev_net(in ? in : out);
 	int ret;
 
 	if (!cond ||
@@ -244,11 +241,11 @@ NF_HOOK_COND(uint8_t pf, unsigned int hook, struct sock *sk,
 }
 
 static inline int
-NF_HOOK(uint8_t pf, unsigned int hook, struct sock *sk, struct sk_buff *skb,
+NF_HOOK(uint8_t pf, unsigned int hook, struct net *net, struct sock *sk, struct sk_buff *skb,
 	struct net_device *in, struct net_device *out,
 	int (*okfn)(struct sock *, struct sk_buff *))
 {
-	return NF_HOOK_THRESH(pf, hook, sk, skb, in, out, okfn, INT_MIN);
+	return NF_HOOK_THRESH(pf, hook, net, sk, skb, in, out, okfn, INT_MIN);
 }
 
 /* Call setsockopt() */
@@ -348,11 +345,11 @@ nf_nat_decode_session(struct sk_buff *skb, struct flowi *fl, u_int8_t family)
 }
 
 #else /* !CONFIG_NETFILTER */
-#define NF_HOOK(pf, hook, sk, skb, indev, outdev, okfn) (okfn)(sk, skb)
-#define NF_HOOK_COND(pf, hook, sk, skb, indev, outdev, okfn, cond) (okfn)(sk, skb)
-static inline int nf_hook(u_int8_t pf, unsigned int hook, struct sock *sk,
-			  struct sk_buff *skb, struct net_device *indev,
-			  struct net_device *outdev,
+#define NF_HOOK(pf, hook, net, sk, skb, indev, outdev, okfn) (okfn)(sk, skb)
+#define NF_HOOK_COND(pf, hook, net, sk, skb, indev, outdev, okfn, cond) (okfn)(sk, skb)
+static inline int nf_hook(u_int8_t pf, unsigned int hook, struct net *net,
+			  struct sock *sk, struct sk_buff *skb,
+			  struct net_device *indev, struct net_device *outdev,
 			  int (*okfn)(struct sock *, struct sk_buff *))
 {
 	return 1;
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index fa7bfced888e..2dd2a23ce707 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -67,8 +67,9 @@ EXPORT_SYMBOL_GPL(br_dev_queue_push_xmit);
 
 int br_forward_finish(struct sock *sk, struct sk_buff *skb)
 {
-	return NF_HOOK(NFPROTO_BRIDGE, NF_BR_POST_ROUTING, sk, skb,
-		       NULL, skb->dev,
+	struct net *net = dev_net(skb->dev);
+	return NF_HOOK(NFPROTO_BRIDGE, NF_BR_POST_ROUTING,
+		       net, sk, skb, NULL, skb->dev,
 		       br_dev_queue_push_xmit);
 
 }
@@ -92,8 +93,8 @@ static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 		return;
 	}
 
-	NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT, NULL, skb,
-		NULL, skb->dev,
+	NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT,
+		dev_net(skb->dev), NULL, skb,NULL, skb->dev,
 		br_forward_finish);
 }
 
@@ -114,8 +115,8 @@ static void __br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
 	skb->dev = to->dev;
 	skb_forward_csum(skb);
 
-	NF_HOOK(NFPROTO_BRIDGE, NF_BR_FORWARD, NULL, skb,
-		indev, skb->dev,
+	NF_HOOK(NFPROTO_BRIDGE, NF_BR_FORWARD,
+		dev_net(indev), NULL, skb, indev, skb->dev,
 		br_forward_finish);
 }
 
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index 2359c041e27c..78fa7acd836e 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -60,8 +60,8 @@ static int br_pass_frame_up(struct sk_buff *skb)
 	if (!skb)
 		return NET_RX_DROP;
 
-	return NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, NULL, skb,
-		       indev, NULL,
+	return NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN,
+		       dev_net(indev), NULL, skb, indev, NULL,
 		       br_netif_receive_skb);
 }
 
@@ -283,8 +283,9 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
 		}
 
 		/* Deliver packet to local host only */
-		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, NULL, skb,
-			    skb->dev, NULL, br_handle_local_finish)) {
+		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN,
+			    dev_net(skb->dev), NULL, skb, skb->dev, NULL,
+			    br_handle_local_finish)) {
 			return RX_HANDLER_CONSUMED; /* consumed by filter */
 		} else {
 			*pskb = skb;
@@ -308,8 +309,8 @@ forward:
 		if (ether_addr_equal(p->br->dev->dev_addr, dest))
 			skb->pkt_type = PACKET_HOST;
 
-		NF_HOOK(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, NULL, skb,
-			skb->dev, NULL,
+		NF_HOOK(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING,
+			dev_net(skb->dev), NULL, skb, skb->dev, NULL,
 			br_handle_frame_finish);
 		break;
 	default:
diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 66efdc21f548..b4d858a18eb6 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -829,8 +829,8 @@ static void __br_multicast_send_query(struct net_bridge *br,
 
 	if (port) {
 		skb->dev = port->dev;
-		NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT, NULL, skb,
-			NULL, skb->dev,
+		NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT,
+			dev_net(port->dev), NULL, skb, NULL, skb->dev,
 			br_dev_queue_push_xmit);
 	} else {
 		br_multicast_select_own_querier(br, ip, skb);
diff --git a/net/bridge/br_netfilter_hooks.c b/net/bridge/br_netfilter_hooks.c
index c1127908e23a..7886c9d7e23d 100644
--- a/net/bridge/br_netfilter_hooks.c
+++ b/net/bridge/br_netfilter_hooks.c
@@ -394,7 +394,7 @@ bridged_dnat:
 				nf_bridge_push_encap_header(skb);
 				NF_HOOK_THRESH(NFPROTO_BRIDGE,
 					       NF_BR_PRE_ROUTING,
-					       sk, skb, skb->dev, NULL,
+					       net, sk, skb, skb->dev, NULL,
 					       br_nf_pre_routing_finish_bridge,
 					       1);
 				return 0;
@@ -414,7 +414,7 @@ bridged_dnat:
 	skb->dev = nf_bridge->physindev;
 	nf_bridge_update_protocol(skb);
 	nf_bridge_push_encap_header(skb);
-	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, sk, skb,
+	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, net, sk, skb,
 		       skb->dev, NULL,
 		       br_handle_frame_finish, 1);
 
@@ -512,7 +512,7 @@ static unsigned int br_nf_pre_routing(const struct nf_hook_ops *ops,
 
 	skb->protocol = htons(ETH_P_IP);
 
-	NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, state->sk, skb,
+	NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, state->net, state->sk, skb,
 		skb->dev, NULL,
 		br_nf_pre_routing_finish);
 
@@ -539,6 +539,7 @@ static unsigned int br_nf_local_in(const struct nf_hook_ops *ops,
 static int br_nf_forward_finish(struct sock *sk, struct sk_buff *skb)
 {
 	struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
+	struct net *net = dev_net(skb->dev);
 	struct net_device *in;
 
 	if (!IS_ARP(skb) && !IS_VLAN_ARP(skb)) {
@@ -560,7 +561,7 @@ static int br_nf_forward_finish(struct sock *sk, struct sk_buff *skb)
 	}
 	nf_bridge_push_encap_header(skb);
 
-	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_FORWARD, sk, skb,
+	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_FORWARD, net, sk, skb,
 		       in, skb->dev, br_forward_finish, 1);
 	return 0;
 }
@@ -627,7 +628,7 @@ static unsigned int br_nf_forward_ip(const struct nf_hook_ops *ops,
 	else
 		skb->protocol = htons(ETH_P_IPV6);
 
-	NF_HOOK(pf, NF_INET_FORWARD, NULL, skb,
+	NF_HOOK(pf, NF_INET_FORWARD, state->net, NULL, skb,
 		brnf_get_logical_dev(skb, state->in),
 		parent,	br_nf_forward_finish);
 
@@ -662,7 +663,7 @@ static unsigned int br_nf_forward_arp(const struct nf_hook_ops *ops,
 		return NF_ACCEPT;
 	}
 	*d = state->in;
-	NF_HOOK(NFPROTO_ARP, NF_ARP_FORWARD, state->sk, skb,
+	NF_HOOK(NFPROTO_ARP, NF_ARP_FORWARD, state->net, state->sk, skb,
 		state->in, state->out, br_nf_forward_finish);
 
 	return NF_STOLEN;
@@ -842,7 +843,7 @@ static unsigned int br_nf_post_routing(const struct nf_hook_ops *ops,
 	else
 		skb->protocol = htons(ETH_P_IPV6);
 
-	NF_HOOK(pf, NF_INET_POST_ROUTING, state->sk, skb,
+	NF_HOOK(pf, NF_INET_POST_ROUTING, state->net, state->sk, skb,
 		NULL, realoutdev,
 		br_nf_dev_queue_xmit);
 
diff --git a/net/bridge/br_netfilter_ipv6.c b/net/bridge/br_netfilter_ipv6.c
index 77383bfe7ea3..5d19361ad5d3 100644
--- a/net/bridge/br_netfilter_ipv6.c
+++ b/net/bridge/br_netfilter_ipv6.c
@@ -166,6 +166,7 @@ static int br_nf_pre_routing_finish_ipv6(struct sock *sk, struct sk_buff *skb)
 	struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
 	struct rtable *rt;
 	struct net_device *dev = skb->dev;
+	struct net *net = dev_net(dev);
 	const struct nf_ipv6_ops *v6ops = nf_get_ipv6_ops();
 
 	nf_bridge->frag_max_size = IP6CB(skb)->frag_max_size;
@@ -189,7 +190,7 @@ static int br_nf_pre_routing_finish_ipv6(struct sock *sk, struct sk_buff *skb)
 			nf_bridge_update_protocol(skb);
 			nf_bridge_push_encap_header(skb);
 			NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING,
-				       sk, skb, skb->dev, NULL,
+				       net, sk, skb, skb->dev, NULL,
 				       br_nf_pre_routing_finish_bridge,
 				       1);
 			return 0;
@@ -208,7 +209,7 @@ static int br_nf_pre_routing_finish_ipv6(struct sock *sk, struct sk_buff *skb)
 	skb->dev = nf_bridge->physindev;
 	nf_bridge_update_protocol(skb);
 	nf_bridge_push_encap_header(skb);
-	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, sk, skb,
+	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, net, sk, skb,
 		       skb->dev, NULL,
 		       br_handle_frame_finish, 1);
 
@@ -237,7 +238,7 @@ unsigned int br_nf_pre_routing_ipv6(const struct nf_hook_ops *ops,
 	nf_bridge->ipv6_daddr = ipv6_hdr(skb)->daddr;
 
 	skb->protocol = htons(ETH_P_IPV6);
-	NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING, state->sk, skb,
+	NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING, state->net, state->sk, skb,
 		skb->dev, NULL,
 		br_nf_pre_routing_finish_ipv6);
 
diff --git a/net/bridge/br_stp_bpdu.c b/net/bridge/br_stp_bpdu.c
index 3017a396cdef..8e2e8c352198 100644
--- a/net/bridge/br_stp_bpdu.c
+++ b/net/bridge/br_stp_bpdu.c
@@ -59,8 +59,8 @@ static void br_send_bpdu(struct net_bridge_port *p,
 
 	skb_reset_mac_header(skb);
 
-	NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT, NULL, skb,
-		NULL, skb->dev,
+	NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT,
+		dev_net(p->dev), NULL, skb, NULL, skb->dev,
 		br_send_bpdu_finish);
 }
 
diff --git a/net/decnet/dn_neigh.c b/net/decnet/dn_neigh.c
index 4507b188fc51..305ab2fe25cd 100644
--- a/net/decnet/dn_neigh.c
+++ b/net/decnet/dn_neigh.c
@@ -246,8 +246,9 @@ static int dn_long_output(struct neighbour *neigh, struct sock *sk,
 
 	skb_reset_network_header(skb);
 
-	return NF_HOOK(NFPROTO_DECNET, NF_DN_POST_ROUTING, sk, skb,
-		       NULL, neigh->dev, dn_neigh_output_packet);
+	return NF_HOOK(NFPROTO_DECNET, NF_DN_POST_ROUTING,
+		       &init_net, sk, skb, NULL, neigh->dev,
+		       dn_neigh_output_packet);
 }
 
 /*
@@ -286,8 +287,9 @@ static int dn_short_output(struct neighbour *neigh, struct sock *sk,
 
 	skb_reset_network_header(skb);
 
-	return NF_HOOK(NFPROTO_DECNET, NF_DN_POST_ROUTING, sk, skb,
-		       NULL, neigh->dev, dn_neigh_output_packet);
+	return NF_HOOK(NFPROTO_DECNET, NF_DN_POST_ROUTING,
+		       &init_net, sk, skb, NULL, neigh->dev,
+		       dn_neigh_output_packet);
 }
 
 /*
@@ -327,8 +329,9 @@ static int dn_phase3_output(struct neighbour *neigh, struct sock *sk,
 
 	skb_reset_network_header(skb);
 
-	return NF_HOOK(NFPROTO_DECNET, NF_DN_POST_ROUTING, sk, skb,
-		       NULL, neigh->dev, dn_neigh_output_packet);
+	return NF_HOOK(NFPROTO_DECNET, NF_DN_POST_ROUTING,
+		       &init_net, sk, skb, NULL, neigh->dev,
+		       dn_neigh_output_packet);
 }
 
 int dn_to_neigh_output(struct sock *sk, struct sk_buff *skb)
diff --git a/net/decnet/dn_nsp_in.c b/net/decnet/dn_nsp_in.c
index a321eac9fd0c..e7b0605ca34a 100644
--- a/net/decnet/dn_nsp_in.c
+++ b/net/decnet/dn_nsp_in.c
@@ -814,8 +814,8 @@ free_out:
 
 int dn_nsp_rx(struct sk_buff *skb)
 {
-	return NF_HOOK(NFPROTO_DECNET, NF_DN_LOCAL_IN, NULL, skb,
-		       skb->dev, NULL,
+	return NF_HOOK(NFPROTO_DECNET, NF_DN_LOCAL_IN,
+		       &init_net, NULL, skb, skb->dev, NULL,
 		       dn_nsp_rx_packet);
 }
 
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 03227ffd19ce..fefcd2e85ef9 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -573,8 +573,8 @@ static int dn_route_rx_long(struct sk_buff *skb)
 	ptr++;
 	cb->hops = *ptr++; /* Visit Count */
 
-	return NF_HOOK(NFPROTO_DECNET, NF_DN_PRE_ROUTING, NULL, skb,
-		       skb->dev, NULL,
+	return NF_HOOK(NFPROTO_DECNET, NF_DN_PRE_ROUTING,
+		       &init_net, NULL, skb, skb->dev, NULL,
 		       dn_route_rx_packet);
 
 drop_it:
@@ -601,8 +601,8 @@ static int dn_route_rx_short(struct sk_buff *skb)
 	ptr += 2;
 	cb->hops = *ptr & 0x3f;
 
-	return NF_HOOK(NFPROTO_DECNET, NF_DN_PRE_ROUTING, NULL, skb,
-		       skb->dev, NULL,
+	return NF_HOOK(NFPROTO_DECNET, NF_DN_PRE_ROUTING,
+		       &init_net, NULL, skb, skb->dev, NULL,
 		       dn_route_rx_packet);
 
 drop_it:
@@ -706,22 +706,22 @@ int dn_route_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type
 		switch (flags & DN_RT_CNTL_MSK) {
 		case DN_RT_PKT_HELO:
 			return NF_HOOK(NFPROTO_DECNET, NF_DN_HELLO,
-				       NULL, skb, skb->dev, NULL,
+				       &init_net, NULL, skb, skb->dev, NULL,
 				       dn_route_ptp_hello);
 
 		case DN_RT_PKT_L1RT:
 		case DN_RT_PKT_L2RT:
 			return NF_HOOK(NFPROTO_DECNET, NF_DN_ROUTE,
-				       NULL, skb, skb->dev, NULL,
+				       &init_net, NULL, skb, skb->dev, NULL,
 				       dn_route_discard);
 		case DN_RT_PKT_ERTH:
 			return NF_HOOK(NFPROTO_DECNET, NF_DN_HELLO,
-				       NULL, skb, skb->dev, NULL,
+				       &init_net, NULL, skb, skb->dev, NULL,
 				       dn_neigh_router_hello);
 
 		case DN_RT_PKT_EEDH:
 			return NF_HOOK(NFPROTO_DECNET, NF_DN_HELLO,
-				       NULL, skb, skb->dev, NULL,
+				       &init_net, NULL, skb, skb->dev, NULL,
 				       dn_neigh_endnode_hello);
 		}
 	} else {
@@ -770,8 +770,8 @@ static int dn_output(struct sock *sk, struct sk_buff *skb)
 	cb->rt_flags |= DN_RT_F_IE;
 	cb->hops = 0;
 
-	return NF_HOOK(NFPROTO_DECNET, NF_DN_LOCAL_OUT, sk, skb,
-		       NULL, dev,
+	return NF_HOOK(NFPROTO_DECNET, NF_DN_LOCAL_OUT,
+		       &init_net, sk, skb, NULL, dev,
 		       dn_to_neigh_output);
 
 error:
@@ -819,8 +819,8 @@ static int dn_forward(struct sk_buff *skb)
 	if (rt->rt_flags & RTCF_DOREDIRECT)
 		cb->rt_flags |= DN_RT_F_IE;
 
-	return NF_HOOK(NFPROTO_DECNET, NF_DN_FORWARD, NULL, skb,
-		       dev, skb->dev,
+	return NF_HOOK(NFPROTO_DECNET, NF_DN_FORWARD,
+		       &init_net, NULL, skb, dev, skb->dev,
 		       dn_to_neigh_output);
 
 drop:
diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
index 3632e98eb0f9..ae71e9ade5f9 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -632,8 +632,9 @@ static int arp_xmit_finish(struct sock *sk, struct sk_buff *skb)
 void arp_xmit(struct sk_buff *skb)
 {
 	/* Send it off, maybe filter it using firewalling first.  */
-	NF_HOOK(NFPROTO_ARP, NF_ARP_OUT, NULL, skb,
-		NULL, skb->dev, arp_xmit_finish);
+	NF_HOOK(NFPROTO_ARP, NF_ARP_OUT,
+		dev_net(skb->dev), NULL, skb, NULL, skb->dev,
+		arp_xmit_finish);
 }
 EXPORT_SYMBOL(arp_xmit);
 
@@ -897,8 +898,9 @@ static int arp_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	memset(NEIGH_CB(skb), 0, sizeof(struct neighbour_cb));
 
-	return NF_HOOK(NFPROTO_ARP, NF_ARP_IN, NULL, skb,
-		       dev, NULL, arp_process);
+	return NF_HOOK(NFPROTO_ARP, NF_ARP_IN,
+		       dev_net(dev), NULL, skb, dev, NULL,
+		       arp_process);
 
 consumeskb:
 	consume_skb(skb);
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 95235c813f18..0a3c45a2e757 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -146,8 +146,9 @@ int ip_forward(struct sk_buff *skb)
 
 	skb->priority = rt_tos2priority(iph->tos);
 
-	return NF_HOOK(NFPROTO_IPV4, NF_INET_FORWARD, NULL, skb,
-		       skb->dev, rt->dst.dev, ip_forward_finish);
+	return NF_HOOK(NFPROTO_IPV4, NF_INET_FORWARD,
+		       net, NULL, skb, skb->dev, rt->dst.dev,
+		       ip_forward_finish);
 
 sr_failed:
 	/*
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index cc242b9501d9..991d082c7312 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -254,8 +254,8 @@ int ip_local_deliver(struct sk_buff *skb)
 			return 0;
 	}
 
-	return NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_IN, NULL, skb,
-		       skb->dev, NULL,
+	return NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_IN,
+		       dev_net(skb->dev), NULL, skb, skb->dev, NULL,
 		       ip_local_deliver_finish);
 }
 
@@ -453,8 +453,8 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 	/* Must drop socket now because of tproxy. */
 	skb_orphan(skb);
 
-	return NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, NULL, skb,
-		       dev, NULL,
+	return NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING,
+		       net, NULL, skb, dev, NULL,
 		       ip_rcv_finish);
 
 csum_error:
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index fc550e97daac..4c9532259a7f 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -97,12 +97,14 @@ EXPORT_SYMBOL(ip_send_check);
 
 static int __ip_local_out_sk(struct sock *sk, struct sk_buff *skb)
 {
+	struct net *net = dev_net(skb_dst(skb)->dev);
 	struct iphdr *iph = ip_hdr(skb);
 
 	iph->tot_len = htons(skb->len);
 	ip_send_check(iph);
-	return nf_hook(NFPROTO_IPV4, NF_INET_LOCAL_OUT, sk, skb, NULL,
-		       skb_dst(skb)->dev, dst_output);
+	return nf_hook(NFPROTO_IPV4, NF_INET_LOCAL_OUT,
+		       net, sk, skb, NULL, skb_dst(skb)->dev,
+		       dst_output);
 }
 
 int __ip_local_out(struct sk_buff *skb)
@@ -322,7 +324,7 @@ int ip_mc_output(struct sock *sk, struct sk_buff *skb)
 			struct sk_buff *newskb = skb_clone(skb, GFP_ATOMIC);
 			if (newskb)
 				NF_HOOK(NFPROTO_IPV4, NF_INET_POST_ROUTING,
-					sk, newskb, NULL, newskb->dev,
+					net, sk, newskb, NULL, newskb->dev,
 					dev_loopback_xmit);
 		}
 
@@ -337,12 +339,14 @@ int ip_mc_output(struct sock *sk, struct sk_buff *skb)
 	if (rt->rt_flags&RTCF_BROADCAST) {
 		struct sk_buff *newskb = skb_clone(skb, GFP_ATOMIC);
 		if (newskb)
-			NF_HOOK(NFPROTO_IPV4, NF_INET_POST_ROUTING, sk, newskb,
-				NULL, newskb->dev, dev_loopback_xmit);
+			NF_HOOK(NFPROTO_IPV4, NF_INET_POST_ROUTING,
+				net, sk, newskb, NULL, newskb->dev,
+				dev_loopback_xmit);
 	}
 
-	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING, sk, skb, NULL,
-			    skb->dev, ip_finish_output,
+	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING,
+			    net, sk, skb, NULL, skb->dev,
+			    ip_finish_output,
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
 
@@ -356,8 +360,8 @@ int ip_output(struct sock *sk, struct sk_buff *skb)
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_IP);
 
-	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING, sk, skb,
-			    NULL, dev,
+	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING,
+			    net, sk, skb, NULL, dev,
 			    ip_finish_output,
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index dfe4e8ec6c3a..a88c0c5374ff 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1788,8 +1788,8 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 	 * not mrouter) cannot join to more than one interface - it will
 	 * result in receiving multiple packets.
 	 */
-	NF_HOOK(NFPROTO_IPV4, NF_INET_FORWARD, NULL, skb,
-		skb->dev, dev,
+	NF_HOOK(NFPROTO_IPV4, NF_INET_FORWARD,
+		net, NULL, skb, skb->dev, dev,
 		ipmr_forward_finish);
 	return;
 
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 09ab5bb6913a..2045b1aaa6ef 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -411,8 +411,9 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 		icmp_out_count(net, ((struct icmphdr *)
 			skb_transport_header(skb))->type);
 
-	err = NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_OUT, sk, skb,
-		      NULL, rt->dst.dev, dst_output);
+	err = NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_OUT,
+		      net, sk, skb, NULL, rt->dst.dev,
+		      dst_output);
 	if (err > 0)
 		err = net_xmit_errno(err);
 	if (err)
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index 60b032f58ccc..5093000d3d5e 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -52,8 +52,8 @@ int xfrm4_transport_finish(struct sk_buff *skb, int async)
 	iph->tot_len = htons(skb->len);
 	ip_send_check(iph);
 
-	NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, NULL, skb,
-		skb->dev, NULL,
+	NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING,
+		dev_net(skb->dev), NULL, skb, skb->dev, NULL,
 		xfrm4_rcv_encap_finish);
 	return 0;
 }
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 737f5e395a6a..e4a85199e015 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -96,8 +96,10 @@ static int __xfrm4_output(struct sock *sk, struct sk_buff *skb)
 
 int xfrm4_output(struct sock *sk, struct sk_buff *skb)
 {
-	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING, sk, skb,
-			    NULL, skb_dst(skb)->dev, __xfrm4_output,
+	struct net *net = dev_net(skb_dst(skb)->dev);
+	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING,
+			    net, sk, skb, NULL, skb_dst(skb)->dev,
+			    __xfrm4_output,
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
 
diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index c628dba477d4..583cf959c23d 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -183,8 +183,8 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	/* Must drop socket now because of tproxy. */
 	skb_orphan(skb);
 
-	return NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING, NULL, skb,
-		       dev, NULL,
+	return NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING,
+		       net, NULL, skb, dev, NULL,
 		       ip6_rcv_finish);
 err:
 	IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INHDRERRORS);
@@ -278,8 +278,8 @@ discard:
 
 int ip6_input(struct sk_buff *skb)
 {
-	return NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_IN, NULL, skb,
-		       skb->dev, NULL,
+	return NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_IN,
+		       dev_net(skb->dev), NULL, skb, skb->dev, NULL,
 		       ip6_input_finish);
 }
 
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 8cab909b181e..96e76ddd4a44 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -83,7 +83,7 @@ static int ip6_finish_output2(struct sock *sk, struct sk_buff *skb)
 			 */
 			if (newskb)
 				NF_HOOK(NFPROTO_IPV6, NF_INET_POST_ROUTING,
-					sk, newskb, NULL, newskb->dev,
+					net, sk, newskb, NULL, newskb->dev,
 					dev_loopback_xmit);
 
 			if (ipv6_hdr(skb)->hop_limit == 0) {
@@ -142,8 +142,8 @@ int ip6_output(struct sock *sk, struct sk_buff *skb)
 		return 0;
 	}
 
-	return NF_HOOK_COND(NFPROTO_IPV6, NF_INET_POST_ROUTING, sk, skb,
-			    NULL, dev,
+	return NF_HOOK_COND(NFPROTO_IPV6, NF_INET_POST_ROUTING,
+			    net, sk, skb, NULL, dev,
 			    ip6_finish_output,
 			    !(IP6CB(skb)->flags & IP6SKB_REROUTED));
 }
@@ -223,8 +223,9 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 	if ((skb->len <= mtu) || skb->ignore_df || skb_is_gso(skb)) {
 		IP6_UPD_PO_STATS(net, ip6_dst_idev(skb_dst(skb)),
 			      IPSTATS_MIB_OUT, skb->len);
-		return NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, sk, skb,
-			       NULL, dst->dev, dst_output);
+		return NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT,
+			       net, sk, skb, NULL, dst->dev,
+			       dst_output);
 	}
 
 	skb->dev = dst->dev;
@@ -511,8 +512,8 @@ int ip6_forward(struct sk_buff *skb)
 
 	IP6_INC_STATS_BH(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTFORWDATAGRAMS);
 	IP6_ADD_STATS_BH(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTOCTETS, skb->len);
-	return NF_HOOK(NFPROTO_IPV6, NF_INET_FORWARD, NULL, skb,
-		       skb->dev, dst->dev,
+	return NF_HOOK(NFPROTO_IPV6, NF_INET_FORWARD,
+		       net, NULL, skb, skb->dev, dst->dev,
 		       ip6_forward_finish);
 
 error:
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 3e3085b37a91..e830942b2090 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -2064,8 +2064,8 @@ static int ip6mr_forward2(struct net *net, struct mr6_table *mrt,
 
 	IP6CB(skb)->flags |= IP6SKB_FORWARDED;
 
-	return NF_HOOK(NFPROTO_IPV6, NF_INET_FORWARD, NULL, skb,
-		       skb->dev, dev,
+	return NF_HOOK(NFPROTO_IPV6, NF_INET_FORWARD,
+		       net, NULL, skb, skb->dev, dev,
 		       ip6mr_forward2_finish);
 
 out_free:
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 5b3f2841acf6..124338a39e29 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1645,7 +1645,7 @@ static void mld_sendpack(struct sk_buff *skb)
 	payload_len = skb->len;
 
 	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT,
-		      net->ipv6.igmp_sk, skb, NULL, skb->dev,
+		      net, net->ipv6.igmp_sk, skb, NULL, skb->dev,
 		      dst_output);
 out:
 	if (!err) {
@@ -2008,8 +2008,9 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 	}
 
 	skb_dst_set(skb, dst);
-	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, sk, skb,
-		      NULL, skb->dev, dst_output);
+	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT,
+		      net, sk, skb, NULL, skb->dev,
+		      dst_output);
 out:
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(net, idev, type);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 349ac1b022b6..dd2b08d7c8d1 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -463,8 +463,8 @@ static void ndisc_send_skb(struct sk_buff *skb,
 	idev = __in6_dev_get(dst->dev);
 	IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUT, skb->len);
 
-	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, sk, skb,
-		      NULL, dst->dev,
+	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT,
+		      net, sk, skb, NULL, dst->dev,
 		      dst_output);
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(net, idev, type);
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index 6d9c0b3d5b8c..6b576be3c83e 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -74,7 +74,7 @@ static unsigned int ipv6_defrag(const struct nf_hook_ops *ops,
 
 	nf_ct_frag6_consume_orig(reasm);
 
-	NF_HOOK_THRESH(NFPROTO_IPV6, ops->hooknum, state->sk, reasm,
+	NF_HOOK_THRESH(NFPROTO_IPV6, ops->hooknum, state->net, state->sk, reasm,
 		       state->in, state->out,
 		       state->okfn, NF_IP6_PRI_CONNTRACK_DEFRAG + 1);
 
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index 8178f72fe90d..9cc9127fb5e7 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -140,6 +140,7 @@ EXPORT_SYMBOL(ip6_dst_hoplimit);
 
 static int __ip6_local_out_sk(struct sock *sk, struct sk_buff *skb)
 {
+	struct net *net = dev_net(skb_dst(skb)->dev);
 	int len;
 
 	len = skb->len - sizeof(struct ipv6hdr);
@@ -148,8 +149,9 @@ static int __ip6_local_out_sk(struct sock *sk, struct sk_buff *skb)
 	ipv6_hdr(skb)->payload_len = htons(len);
 	IP6CB(skb)->nhoff = offsetof(struct ipv6hdr, nexthdr);
 
-	return nf_hook(NFPROTO_IPV6, NF_INET_LOCAL_OUT, sk, skb,
-		       NULL, skb_dst(skb)->dev, dst_output);
+	return nf_hook(NFPROTO_IPV6, NF_INET_LOCAL_OUT,
+		       net, sk, skb, NULL, skb_dst(skb)->dev,
+		       dst_output);
 }
 
 int __ip6_local_out(struct sk_buff *skb)
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 5aa461302716..dc65ec198f7c 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -654,7 +654,7 @@ static int rawv6_send_hdrinc(struct sock *sk, struct msghdr *msg, int length,
 		goto error_fault;
 
 	IP6_UPD_PO_STATS(net, rt->rt6i_idev, IPSTATS_MIB_OUT, skb->len);
-	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, sk, skb,
+	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, net, sk, skb,
 		      NULL, rt->dst.dev, dst_output);
 	if (err > 0)
 		err = net_xmit_errno(err);
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 74bd17882a2f..0eaab1fa6be5 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -42,8 +42,8 @@ int xfrm6_transport_finish(struct sk_buff *skb, int async)
 	ipv6_hdr(skb)->payload_len = htons(skb->len);
 	__skb_push(skb, skb->data - skb_network_header(skb));
 
-	NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING, NULL, skb,
-		skb->dev, NULL,
+	NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING,
+		dev_net(skb->dev), NULL, skb, skb->dev, NULL,
 		ip6_rcv_finish);
 	return -1;
 }
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index b0fcd6c09837..431ae2c22234 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -168,7 +168,9 @@ static int __xfrm6_output(struct sock *sk, struct sk_buff *skb)
 
 int xfrm6_output(struct sock *sk, struct sk_buff *skb)
 {
-	return NF_HOOK_COND(NFPROTO_IPV6, NF_INET_POST_ROUTING, sk, skb,
-			    NULL, skb_dst(skb)->dev, __xfrm6_output,
+	struct net *net = dev_net(skb_dst(skb)->dev);
+	return NF_HOOK_COND(NFPROTO_IPV6, NF_INET_POST_ROUTING,
+			    net, sk, skb,  NULL, skb_dst(skb)->dev,
+			    __xfrm6_output,
 			    !(IP6CB(skb)->flags & IP6SKB_REROUTED));
 }
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index b8e5544af87f..65c996c14bca 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -573,7 +573,7 @@ static inline int ip_vs_nat_send_or_cont(int pf, struct sk_buff *skb,
 		skb_forward_csum(skb);
 		if (!skb->sk)
 			skb_sender_cpu_clear(skb);
-		NF_HOOK(pf, NF_INET_LOCAL_OUT, NULL, skb,
+		NF_HOOK(pf, NF_INET_LOCAL_OUT, ip_vs_conn_net(cp), NULL, skb,
 			NULL, skb_dst(skb)->dev, dst_output);
 	} else
 		ret = NF_ACCEPT;
@@ -595,7 +595,7 @@ static inline int ip_vs_send_or_cont(int pf, struct sk_buff *skb,
 		skb_forward_csum(skb);
 		if (!skb->sk)
 			skb_sender_cpu_clear(skb);
-		NF_HOOK(pf, NF_INET_LOCAL_OUT, NULL, skb,
+		NF_HOOK(pf, NF_INET_LOCAL_OUT, ip_vs_conn_net(cp), NULL, skb,
 			NULL, skb_dst(skb)->dev, dst_output);
 	} else
 		ret = NF_ACCEPT;
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 57a50f6ce28c..c21f1a02ce13 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -131,6 +131,7 @@ out:
 
 int xfrm_output_resume(struct sk_buff *skb, int err)
 {
+	struct net *net = xs_net(skb_dst(skb)->xfrm);
 	while (likely((err = xfrm_output_one(skb, err)) == 0)) {
 		nf_reset(skb);
 
@@ -142,7 +143,7 @@ int xfrm_output_resume(struct sk_buff *skb, int err)
 			return dst_output(skb->sk, skb);
 
 		err = nf_hook(skb_dst(skb)->ops->family,
-			      NF_INET_POST_ROUTING, skb->sk, skb,
+			      NF_INET_POST_ROUTING, net, skb->sk, skb,
 			      NULL, skb_dst(skb)->dev, xfrm_output2);
 		if (unlikely(err != 1))
 			goto out;
-- 
2.2.1

