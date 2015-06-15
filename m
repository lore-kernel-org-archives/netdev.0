From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 02/15] netfilter: Pass struct net into the netfilter hooks
Date: Sun, 14 Jun 2015 22:13:00 -0500
Message-ID: <1434337993-6248-2-git-send-email-ebiederm@xmission.com>
References: <87616ppt3h.fsf@x220.int.ebiederm.org>
Cc: <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Juanjo Ciarlante <jjciarla@raiz.uncu.edu.ar>,
	Wensong Zhang <wensong@linux-vs.org>,
	Simon Horman <horms@verge.net.au>,
	Julian Anastasov <ja@ssi.bg>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <87616ppt3h.fsf@x220.int.ebiederm.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pass a network namespace parameter into the netfilter hooks.  At the
call site of the netfilter hooks the path a packet is taking through
the network stack is well known which allows the network namespace to
be easily and reliabily.

This allows the replacement of magic code like
"dev_net(state->in?:state->out)" that appears at the start of most
netfilter hooks with "state->net".

This simplifies the code, and allows for the possibility of per
network namespace netfilter hook lists (that nftables appears to
want).

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/netfilter.h                 | 37 ++++++++++++++++++-------------
 include/linux/netfilter_ingress.h         |  2 +-
 net/bridge/br_forward.c                   | 12 +++++-----
 net/bridge/br_input.c                     | 13 ++++++-----
 net/bridge/br_multicast.c                 |  4 ++--
 net/bridge/br_netfilter.c                 | 37 +++++++++++++++++--------------
 net/bridge/br_stp_bpdu.c                  |  4 ++--
 net/decnet/dn_neigh.c                     | 15 ++++++++-----
 net/decnet/dn_nsp_in.c                    |  4 ++--
 net/decnet/dn_route.c                     | 24 ++++++++++----------
 net/ipv4/arp.c                            | 10 +++++----
 net/ipv4/ip_forward.c                     | 11 +++++----
 net/ipv4/ip_input.c                       | 24 +++++++++++---------
 net/ipv4/ip_output.c                      | 28 ++++++++++++++---------
 net/ipv4/ipmr.c                           |  6 ++---
 net/ipv4/raw.c                            |  5 +++--
 net/ipv4/xfrm4_input.c                    |  4 ++--
 net/ipv4/xfrm4_output.c                   |  6 +++--
 net/ipv6/ip6_input.c                      | 10 ++++-----
 net/ipv6/ip6_output.c                     | 30 ++++++++++++-------------
 net/ipv6/ip6mr.c                          |  4 ++--
 net/ipv6/mcast.c                          |  7 +++---
 net/ipv6/ndisc.c                          |  4 ++--
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c |  2 +-
 net/ipv6/output_core.c                    |  6 +++--
 net/ipv6/raw.c                            | 10 +++++----
 net/ipv6/xfrm6_input.c                    |  4 ++--
 net/ipv6/xfrm6_output.c                   |  6 +++--
 net/netfilter/ipvs/ip_vs_xmit.c           |  4 ++--
 net/xfrm/xfrm_output.c                    |  4 +++-
 30 files changed, 187 insertions(+), 150 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index f5ff5d156da8..b3d157274cda 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -54,6 +54,7 @@ struct nf_hook_state {
 	struct net_device *in;
 	struct net_device *out;
 	struct sock *sk;
+	struct net *net;
 	struct list_head *hook_list;
 	int (*okfn)(struct sock *, struct sk_buff *);
 };
@@ -65,6 +66,7 @@ static inline void nf_hook_state_init(struct nf_hook_state *p,
 				      struct net_device *indev,
 				      struct net_device *outdev,
 				      struct sock *sk,
+				      struct net *net,
 				      int (*okfn)(struct sock *, struct sk_buff *))
 {
 	p->hook = hook;
@@ -73,6 +75,7 @@ static inline void nf_hook_state_init(struct nf_hook_state *p,
 	p->in = indev;
 	p->out = outdev;
 	p->sk = sk;
+	p->net = net;
 	p->hook_list = hook_list;
 	p->okfn = okfn;
 }
@@ -167,6 +170,7 @@ int nf_hook_slow(struct sk_buff *skb, struct nf_hook_state *state);
  *	value indicates the packet has been consumed by the hook.
  */
 static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
+				 struct net *net,
 				 struct sock *sk,
 				 struct sk_buff *skb,
 				 struct net_device *indev,
@@ -178,18 +182,18 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
 		struct nf_hook_state state;
 
 		nf_hook_state_init(&state, &nf_hooks[pf][hook], hook, thresh,
-				   pf, indev, outdev, sk, okfn);
+				   pf, indev, outdev, sk, net, okfn);
 		return nf_hook_slow(skb, &state);
 	}
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
-	return nf_hook_thresh(pf, hook, sk, skb, indev, outdev, okfn, INT_MIN);
+	return nf_hook_thresh(pf, hook, net, sk, skb, indev, outdev, okfn, INT_MIN);
 }
                    
 /* Activate hook; either okfn or kfree_skb called, unless a hook
@@ -210,36 +214,36 @@ static inline int nf_hook(u_int8_t pf, unsigned int hook, struct sock *sk,
 */
 
 static inline int
-NF_HOOK_THRESH(uint8_t pf, unsigned int hook, struct sock *sk,
+NF_HOOK_THRESH(uint8_t pf, unsigned int hook, struct net *net, struct sock *sk,
 	       struct sk_buff *skb, struct net_device *in,
 	       struct net_device *out,
 	       int (*okfn)(struct sock *, struct sk_buff *), int thresh)
 {
-	int ret = nf_hook_thresh(pf, hook, sk, skb, in, out, okfn, thresh);
+	int ret = nf_hook_thresh(pf, hook, net, sk, skb, in, out, okfn, thresh);
 	if (ret == 1)
 		ret = okfn(sk, skb);
 	return ret;
 }
 
 static inline int
-NF_HOOK_COND(uint8_t pf, unsigned int hook, struct sock *sk,
+NF_HOOK_COND(uint8_t pf, unsigned int hook, struct net *net, struct sock *sk,
 	     struct sk_buff *skb, struct net_device *in, struct net_device *out,
 	     int (*okfn)(struct sock *, struct sk_buff *), bool cond)
 {
 	int ret;
 
 	if (!cond ||
-	    ((ret = nf_hook_thresh(pf, hook, sk, skb, in, out, okfn, INT_MIN)) == 1))
+	    ((ret = nf_hook_thresh(pf, hook, net, sk, skb, in, out, okfn, INT_MIN)) == 1))
 		ret = okfn(sk, skb);
 	return ret;
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
@@ -339,9 +343,10 @@ nf_nat_decode_session(struct sk_buff *skb, struct flowi *fl, u_int8_t family)
 }
 
 #else /* !CONFIG_NETFILTER */
-#define NF_HOOK(pf, hook, sk, skb, indev, outdev, okfn) (okfn)(sk, skb)
-#define NF_HOOK_COND(pf, hook, sk, skb, indev, outdev, okfn, cond) (okfn)(sk, skb)
+#define NF_HOOK(pf, hook, net, sk, skb, indev, outdev, okfn) (okfn)(sk, skb)
+#define NF_HOOK_COND(pf, hook, net, sk, skb, indev, outdev, okfn, cond) (okfn)(sk, skb)
 static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
+				 struct net *net,
 				 struct sock *sk,
 				 struct sk_buff *skb,
 				 struct net_device *indev,
@@ -350,9 +355,9 @@ static inline int nf_hook_thresh(u_int8_t pf, unsigned int hook,
 {
 	return okfn(sk, skb);
 }
-static inline int nf_hook(u_int8_t pf, unsigned int hook, struct sock *sk,
-			  struct sk_buff *skb, struct net_device *indev,
-			  struct net_device *outdev,
+static inline int nf_hook(u_int8_t pf, unsigned int hook, struct net *net,
+			  struct sock *sk, struct sk_buff *skb,
+			  struct net_device *indev, struct net_device *outdev,
 			  int (*okfn)(struct sock *, struct sk_buff *))
 {
 	return 1;
diff --git a/include/linux/netfilter_ingress.h b/include/linux/netfilter_ingress.h
index cb0727fe2b3d..187feabe557c 100644
--- a/include/linux/netfilter_ingress.h
+++ b/include/linux/netfilter_ingress.h
@@ -17,7 +17,7 @@ static inline int nf_hook_ingress(struct sk_buff *skb)
 
 	nf_hook_state_init(&state, &skb->dev->nf_hooks_ingress,
 			   NF_NETDEV_INGRESS, INT_MIN, NFPROTO_NETDEV, NULL,
-			   skb->dev, NULL, NULL);
+			   skb->dev, NULL, dev_net(skb->dev), NULL);
 	return nf_hook_slow(skb, &state);
 }
 
diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index e97572b5d2cc..35564354c2e7 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -51,8 +51,8 @@ EXPORT_SYMBOL_GPL(br_dev_queue_push_xmit);
 
 int br_forward_finish(struct sock *sk, struct sk_buff *skb)
 {
-	return NF_HOOK(NFPROTO_BRIDGE, NF_BR_POST_ROUTING, sk, skb,
-		       NULL, skb->dev,
+	return NF_HOOK(NFPROTO_BRIDGE, NF_BR_POST_ROUTING,
+		       dev_net(skb->dev), sk, skb, NULL, skb->dev,
 		       br_dev_queue_push_xmit);
 
 }
@@ -76,8 +76,8 @@ static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
 		return;
 	}
 
-	NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT, NULL, skb,
-		NULL, skb->dev,
+	NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT,
+		dev_net(skb->dev), NULL, skb,NULL, skb->dev,
 		br_forward_finish);
 }
 
@@ -98,8 +98,8 @@ static void __br_forward(const struct net_bridge_port *to, struct sk_buff *skb)
 	skb->dev = to->dev;
 	skb_forward_csum(skb);
 
-	NF_HOOK(NFPROTO_BRIDGE, NF_BR_FORWARD, NULL, skb,
-		indev, skb->dev,
+	NF_HOOK(NFPROTO_BRIDGE, NF_BR_FORWARD,
+		dev_net(indev), NULL, skb, indev, skb->dev,
 		br_forward_finish);
 }
 
diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
index f921a5dce22d..421903f762dc 100644
--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -55,8 +55,8 @@ static int br_pass_frame_up(struct sk_buff *skb)
 	if (!skb)
 		return NET_RX_DROP;
 
-	return NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, NULL, skb,
-		       indev, NULL,
+	return NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN,
+		       dev_net(indev), NULL, skb, indev, NULL,
 		       netif_receive_skb_sk);
 }
 
@@ -278,8 +278,9 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)
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
@@ -303,8 +304,8 @@ forward:
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
index 0b38ee98024b..d6d16bc16149 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -814,8 +814,8 @@ static void __br_multicast_send_query(struct net_bridge *br,
 
 	if (port) {
 		skb->dev = port->dev;
-		NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT, NULL, skb,
-			NULL, skb->dev,
+		NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT,
+			dev_net(port->dev), NULL, skb, NULL, skb->dev,
 			br_dev_queue_push_xmit);
 	} else {
 		br_multicast_select_own_querier(br, ip, skb);
diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 46660a28feef..20e9d78f183e 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -302,8 +302,8 @@ static int br_nf_pre_routing_finish_ipv6(struct sock *sk, struct sk_buff *skb)
 	skb->dev = nf_bridge->physindev;
 	nf_bridge_update_protocol(skb);
 	nf_bridge_push_encap_header(skb);
-	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, sk, skb,
-		       skb->dev, NULL,
+	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING,
+		       dev_net(skb->dev), sk, skb, skb->dev, NULL,
 		       br_handle_frame_finish, 1);
 
 	return 0;
@@ -403,6 +403,7 @@ static int br_nf_pre_routing_finish(struct sock *sk, struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
 	struct iphdr *iph = ip_hdr(skb);
+	struct net *net = dev_net(dev);
 	struct nf_bridge_info *nf_bridge = nf_bridge_info_get(skb);
 	struct rtable *rt;
 	int err;
@@ -430,7 +431,7 @@ static int br_nf_pre_routing_finish(struct sock *sk, struct sk_buff *skb)
 			if (err != -EHOSTUNREACH || !in_dev || IN_DEV_FORWARD(in_dev))
 				goto free_skb;
 
-			rt = ip_route_output(dev_net(dev), iph->daddr, 0,
+			rt = ip_route_output(net, iph->daddr, 0,
 					     RT_TOS(iph->tos), 0);
 			if (!IS_ERR(rt)) {
 				/* - Bridged-and-DNAT'ed traffic doesn't
@@ -452,7 +453,7 @@ bridged_dnat:
 				nf_bridge_push_encap_header(skb);
 				NF_HOOK_THRESH(NFPROTO_BRIDGE,
 					       NF_BR_PRE_ROUTING,
-					       sk, skb, skb->dev, NULL,
+					       net, sk, skb, skb->dev, NULL,
 					       br_nf_pre_routing_finish_bridge,
 					       1);
 				return 0;
@@ -472,8 +473,8 @@ bridged_dnat:
 	skb->dev = nf_bridge->physindev;
 	nf_bridge_update_protocol(skb);
 	nf_bridge_push_encap_header(skb);
-	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING, sk, skb,
-		       skb->dev, NULL,
+	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_PRE_ROUTING,
+		       net, sk, skb, skb->dev, NULL,
 		       br_handle_frame_finish, 1);
 
 	return 0;
@@ -610,8 +611,8 @@ static unsigned int br_nf_pre_routing_ipv6(const struct nf_hook_ops *ops,
 		return NF_DROP;
 
 	skb->protocol = htons(ETH_P_IPV6);
-	NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING, state->sk, skb,
-		skb->dev, NULL,
+	NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING,
+		state->net, state->sk, skb, skb->dev, NULL,
 		br_nf_pre_routing_finish_ipv6);
 
 	return NF_STOLEN;
@@ -670,8 +671,8 @@ static unsigned int br_nf_pre_routing(const struct nf_hook_ops *ops,
 
 	skb->protocol = htons(ETH_P_IP);
 
-	NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, state->sk, skb,
-		skb->dev, NULL,
+	NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING,
+		state->net, state->sk, skb, skb->dev, NULL,
 		br_nf_pre_routing_finish);
 
 	return NF_STOLEN;
@@ -718,8 +719,9 @@ static int br_nf_forward_finish(struct sock *sk, struct sk_buff *skb)
 	}
 	nf_bridge_push_encap_header(skb);
 
-	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_FORWARD, sk, skb,
-		       in, skb->dev, br_forward_finish, 1);
+	NF_HOOK_THRESH(NFPROTO_BRIDGE, NF_BR_FORWARD,
+		       dev_net(in), sk, skb, in, skb->dev,
+		       br_forward_finish, 1);
 	return 0;
 }
 
@@ -782,7 +784,7 @@ static unsigned int br_nf_forward_ip(const struct nf_hook_ops *ops,
 	else
 		skb->protocol = htons(ETH_P_IPV6);
 
-	NF_HOOK(pf, NF_INET_FORWARD, NULL, skb,
+	NF_HOOK(pf, NF_INET_FORWARD, state->net, NULL, skb,
 		brnf_get_logical_dev(skb, state->in),
 		parent,	br_nf_forward_finish);
 
@@ -817,8 +819,9 @@ static unsigned int br_nf_forward_arp(const struct nf_hook_ops *ops,
 		return NF_ACCEPT;
 	}
 	*d = state->in;
-	NF_HOOK(NFPROTO_ARP, NF_ARP_FORWARD, state->sk, skb,
-		state->in, state->out, br_nf_forward_finish);
+	NF_HOOK(NFPROTO_ARP, NF_ARP_FORWARD,
+		state->net, state->sk, skb, state->in, state->out,
+		br_nf_forward_finish);
 
 	return NF_STOLEN;
 }
@@ -952,8 +955,8 @@ static unsigned int br_nf_post_routing(const struct nf_hook_ops *ops,
 	else
 		skb->protocol = htons(ETH_P_IPV6);
 
-	NF_HOOK(pf, NF_INET_POST_ROUTING, state->sk, skb,
-		NULL, realoutdev,
+	NF_HOOK(pf, NF_INET_POST_ROUTING,
+		state->net, state->sk, skb, NULL, realoutdev,
 		br_nf_dev_queue_xmit);
 
 	return NF_STOLEN;
diff --git a/net/bridge/br_stp_bpdu.c b/net/bridge/br_stp_bpdu.c
index 534fc4cd263e..cb06951fd159 100644
--- a/net/bridge/br_stp_bpdu.c
+++ b/net/bridge/br_stp_bpdu.c
@@ -54,8 +54,8 @@ static void br_send_bpdu(struct net_bridge_port *p,
 
 	skb_reset_mac_header(skb);
 
-	NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT, NULL, skb,
-		NULL, skb->dev,
+	NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_OUT,
+		dev_net(p->dev), NULL, skb, NULL, skb->dev,
 		dev_queue_xmit_sk);
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
index 933a92820d26..5bce2752d850 100644
--- a/net/ipv4/arp.c
+++ b/net/ipv4/arp.c
@@ -591,8 +591,9 @@ EXPORT_SYMBOL(arp_create);
 void arp_xmit(struct sk_buff *skb)
 {
 	/* Send it off, maybe filter it using firewalling first.  */
-	NF_HOOK(NFPROTO_ARP, NF_ARP_OUT, NULL, skb,
-		NULL, skb->dev, dev_queue_xmit_sk);
+	NF_HOOK(NFPROTO_ARP, NF_ARP_OUT,
+		dev_net(skb->dev), NULL, skb, NULL, skb->dev,
+		dev_queue_xmit_sk);
 }
 EXPORT_SYMBOL(arp_xmit);
 
@@ -880,8 +881,9 @@ static int arp_rcv(struct sk_buff *skb, struct net_device *dev,
 
 	memset(NEIGH_CB(skb), 0, sizeof(struct neighbour_cb));
 
-	return NF_HOOK(NFPROTO_ARP, NF_ARP_IN, NULL, skb,
-		       dev, NULL, arp_process);
+	return NF_HOOK(NFPROTO_ARP, NF_ARP_IN,
+		       dev_net(dev), NULL, skb, dev, NULL,
+		       arp_process);
 
 consumeskb:
 	consume_skb(skb);
diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 2d3aa408fbdc..38a0bf45a99c 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -81,6 +81,7 @@ int ip_forward(struct sk_buff *skb)
 	struct iphdr *iph;	/* Our header */
 	struct rtable *rt;	/* Route we use */
 	struct ip_options *opt	= &(IPCB(skb)->opt);
+	struct net *net;
 
 	/* that should never happen */
 	if (skb->pkt_type != PACKET_HOST)
@@ -99,6 +100,7 @@ int ip_forward(struct sk_buff *skb)
 		return NET_RX_SUCCESS;
 
 	skb_forward_csum(skb);
+	net = dev_net(skb->dev);
 
 	/*
 	 *	According to the RFC, we must first decrease the TTL field. If
@@ -119,7 +121,7 @@ int ip_forward(struct sk_buff *skb)
 	IPCB(skb)->flags |= IPSKB_FORWARDED;
 	mtu = ip_dst_mtu_maybe_forward(&rt->dst, true);
 	if (ip_exceeds_mtu(skb, mtu)) {
-		IP_INC_STATS(dev_net(rt->dst.dev), IPSTATS_MIB_FRAGFAILS);
+		IP_INC_STATS(net, IPSTATS_MIB_FRAGFAILS);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
 			  htonl(mtu));
 		goto drop;
@@ -143,8 +145,9 @@ int ip_forward(struct sk_buff *skb)
 
 	skb->priority = rt_tos2priority(iph->tos);
 
-	return NF_HOOK(NFPROTO_IPV4, NF_INET_FORWARD, NULL, skb,
-		       skb->dev, rt->dst.dev, ip_forward_finish);
+	return NF_HOOK(NFPROTO_IPV4, NF_INET_FORWARD,
+		       net, NULL, skb, skb->dev, rt->dst.dev,
+		       ip_forward_finish);
 
 sr_failed:
 	/*
@@ -155,7 +158,7 @@ sr_failed:
 
 too_many_hops:
 	/* Tell the sender its packet died... */
-	IP_INC_STATS_BH(dev_net(skb_dst(skb)->dev), IPSTATS_MIB_INHDRERRORS);
+	IP_INC_STATS_BH(net, IPSTATS_MIB_INHDRERRORS);
 	icmp_send(skb, ICMP_TIME_EXCEEDED, ICMP_EXC_TTL, 0);
 drop:
 	kfree_skb(skb);
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index 2db4c8773c1b..ac40876c476c 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -253,8 +253,8 @@ int ip_local_deliver(struct sk_buff *skb)
 			return 0;
 	}
 
-	return NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_IN, NULL, skb,
-		       skb->dev, NULL,
+	return NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_IN,
+		       dev_net(skb->dev), NULL, skb, skb->dev, NULL,
 		       ip_local_deliver_finish);
 }
 
@@ -377,6 +377,7 @@ drop:
 int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt, struct net_device *orig_dev)
 {
 	const struct iphdr *iph;
+	struct net *net;
 	u32 len;
 
 	/* When the interface is in promisc. mode, drop all the crap
@@ -386,11 +387,12 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 		goto drop;
 
 
-	IP_UPD_PO_STATS_BH(dev_net(dev), IPSTATS_MIB_IN, skb->len);
+	net = dev_net(dev);
+	IP_UPD_PO_STATS_BH(net, IPSTATS_MIB_IN, skb->len);
 
 	skb = skb_share_check(skb, GFP_ATOMIC);
 	if (!skb) {
-		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INDISCARDS);
+		IP_INC_STATS_BH(net, IPSTATS_MIB_INDISCARDS);
 		goto out;
 	}
 
@@ -416,7 +418,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 	BUILD_BUG_ON(IPSTATS_MIB_ECT1PKTS != IPSTATS_MIB_NOECTPKTS + INET_ECN_ECT_1);
 	BUILD_BUG_ON(IPSTATS_MIB_ECT0PKTS != IPSTATS_MIB_NOECTPKTS + INET_ECN_ECT_0);
 	BUILD_BUG_ON(IPSTATS_MIB_CEPKTS != IPSTATS_MIB_NOECTPKTS + INET_ECN_CE);
-	IP_ADD_STATS_BH(dev_net(dev),
+	IP_ADD_STATS_BH(net,
 			IPSTATS_MIB_NOECTPKTS + (iph->tos & INET_ECN_MASK),
 			max_t(unsigned short, 1, skb_shinfo(skb)->gso_segs));
 
@@ -430,7 +432,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 
 	len = ntohs(iph->tot_len);
 	if (skb->len < len) {
-		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INTRUNCATEDPKTS);
+		IP_INC_STATS_BH(net, IPSTATS_MIB_INTRUNCATEDPKTS);
 		goto drop;
 	} else if (len < (iph->ihl*4))
 		goto inhdr_error;
@@ -440,7 +442,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 	 * Note this now means skb->len holds ntohs(iph->tot_len).
 	 */
 	if (pskb_trim_rcsum(skb, len)) {
-		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INDISCARDS);
+		IP_INC_STATS_BH(net, IPSTATS_MIB_INDISCARDS);
 		goto drop;
 	}
 
@@ -452,14 +454,14 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
 	/* Must drop socket now because of tproxy. */
 	skb_orphan(skb);
 
-	return NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING, NULL, skb,
-		       dev, NULL,
+	return NF_HOOK(NFPROTO_IPV4, NF_INET_PRE_ROUTING,
+		       net, NULL, skb, dev, NULL,
 		       ip_rcv_finish);
 
 csum_error:
-	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_CSUMERRORS);
+	IP_INC_STATS_BH(net, IPSTATS_MIB_CSUMERRORS);
 inhdr_error:
-	IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_INHDRERRORS);
+	IP_INC_STATS_BH(net, IPSTATS_MIB_INHDRERRORS);
 drop:
 	kfree_skb(skb);
 out:
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 55f3c2e94357..599914efe304 100644
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
-		       skb_dst(skb)->dev, dst_output_sk);
+	return nf_hook(NFPROTO_IPV4, NF_INET_LOCAL_OUT,
+		       net, sk, skb, NULL, skb_dst(skb)->dev,
+		       dst_output_sk);
 }
 
 int __ip_local_out(struct sk_buff *skb)
@@ -288,11 +290,12 @@ int ip_mc_output(struct sock *sk, struct sk_buff *skb)
 {
 	struct rtable *rt = skb_rtable(skb);
 	struct net_device *dev = rt->dst.dev;
+	struct net *net = dev_net(dev);
 
 	/*
 	 *	If the indicated interface is up and running, send the packet.
 	 */
-	IP_UPD_PO_STATS(dev_net(dev), IPSTATS_MIB_OUT, skb->len);
+	IP_UPD_PO_STATS(net, IPSTATS_MIB_OUT, skb->len);
 
 	skb->dev = dev;
 	skb->protocol = htons(ETH_P_IP);
@@ -320,7 +323,7 @@ int ip_mc_output(struct sock *sk, struct sk_buff *skb)
 			struct sk_buff *newskb = skb_clone(skb, GFP_ATOMIC);
 			if (newskb)
 				NF_HOOK(NFPROTO_IPV4, NF_INET_POST_ROUTING,
-					sk, newskb, NULL, newskb->dev,
+					net, sk, newskb, NULL, newskb->dev,
 					dev_loopback_xmit);
 		}
 
@@ -335,26 +338,29 @@ int ip_mc_output(struct sock *sk, struct sk_buff *skb)
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
 
 int ip_output(struct sock *sk, struct sk_buff *skb)
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
 			    ip_finish_output,
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 3a2c0162c3ba..e462180cd048 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1746,7 +1746,7 @@ static void ipmr_queue_xmit(struct net *net, struct mr_table *mrt,
 		 * to blackhole.
 		 */
 
-		IP_INC_STATS_BH(dev_net(dev), IPSTATS_MIB_FRAGFAILS);
+		IP_INC_STATS_BH(net, IPSTATS_MIB_FRAGFAILS);
 		ip_rt_put(rt);
 		goto out_free;
 	}
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
index 561cd4b8fc6e..98c2671c1e61 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -411,8 +411,9 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 		icmp_out_count(net, ((struct icmphdr *)
 			skb_transport_header(skb))->type);
 
-	err = NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_OUT, sk, skb,
-		      NULL, rt->dst.dev, dst_output_sk);
+	err = NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_OUT,
+		      net, sk, skb, NULL, rt->dst.dev,
+		      dst_output_sk);
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
index 2878dbfffeb7..04bc57423050 100644
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
index 41a73da371a9..b049e9d2d13a 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -108,7 +108,7 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	if (hdr->version != 6)
 		goto err;
 
-	IP6_ADD_STATS_BH(dev_net(dev), idev,
+	IP6_ADD_STATS_BH(net, idev,
 			 IPSTATS_MIB_NOECTPKTS +
 				(ipv6_get_dsfield(hdr) & INET_ECN_MASK),
 			 max_t(unsigned short, 1, skb_shinfo(skb)->gso_segs));
@@ -182,8 +182,8 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	/* Must drop socket now because of tproxy. */
 	skb_orphan(skb);
 
-	return NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING, NULL, skb,
-		       dev, NULL,
+	return NF_HOOK(NFPROTO_IPV6, NF_INET_PRE_ROUTING,
+		       net, NULL, skb, dev, NULL,
 		       ip6_rcv_finish);
 err:
 	IP6_INC_STATS_BH(net, idev, IPSTATS_MIB_INHDRERRORS);
@@ -279,8 +279,8 @@ discard:
 
 int ip6_input(struct sk_buff *skb)
 {
-	return NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_IN, NULL, skb,
-		       skb->dev, NULL,
+	return NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_IN,
+		       dev_net(skb->dev), NULL, skb, skb->dev, NULL,
 		       ip6_input_finish);
 }
 
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index d5f7716662db..bd4e47b7fc4d 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -60,6 +60,7 @@ static int ip6_finish_output2(struct sock *sk, struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct net_device *dev = dst->dev;
+	struct net *net = dev_net(dev);
 	struct neighbour *neigh;
 	struct in6_addr *nexthop;
 	int ret;
@@ -71,7 +72,7 @@ static int ip6_finish_output2(struct sock *sk, struct sk_buff *skb)
 		struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
 
 		if (!(dev->flags & IFF_LOOPBACK) && sk_mc_loop(sk) &&
-		    ((mroute6_socket(dev_net(dev), skb) &&
+		    ((mroute6_socket(net, skb) &&
 		     !(IP6CB(skb)->flags & IP6SKB_FORWARDED)) ||
 		     ipv6_chk_mcast_addr(dev, &ipv6_hdr(skb)->daddr,
 					 &ipv6_hdr(skb)->saddr))) {
@@ -82,19 +83,18 @@ static int ip6_finish_output2(struct sock *sk, struct sk_buff *skb)
 			 */
 			if (newskb)
 				NF_HOOK(NFPROTO_IPV6, NF_INET_POST_ROUTING,
-					sk, newskb, NULL, newskb->dev,
+					net, sk, newskb, NULL, newskb->dev,
 					dev_loopback_xmit);
 
 			if (ipv6_hdr(skb)->hop_limit == 0) {
-				IP6_INC_STATS(dev_net(dev), idev,
+				IP6_INC_STATS(net, idev,
 					      IPSTATS_MIB_OUTDISCARDS);
 				kfree_skb(skb);
 				return 0;
 			}
 		}
 
-		IP6_UPD_PO_STATS(dev_net(dev), idev, IPSTATS_MIB_OUTMCAST,
-				skb->len);
+		IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUTMCAST, skb->len);
 
 		if (IPV6_ADDR_MC_SCOPE(&ipv6_hdr(skb)->daddr) <=
 		    IPV6_ADDR_SCOPE_NODELOCAL &&
@@ -116,8 +116,7 @@ static int ip6_finish_output2(struct sock *sk, struct sk_buff *skb)
 	}
 	rcu_read_unlock_bh();
 
-	IP6_INC_STATS(dev_net(dst->dev),
-		      ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
+	IP6_INC_STATS(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTNOROUTES);
 	kfree_skb(skb);
 	return -EINVAL;
 }
@@ -136,15 +135,15 @@ int ip6_output(struct sock *sk, struct sk_buff *skb)
 {
 	struct net_device *dev = skb_dst(skb)->dev;
 	struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
+	struct net *net = dev_net(dev);
 	if (unlikely(idev->cnf.disable_ipv6)) {
-		IP6_INC_STATS(dev_net(dev), idev,
-			      IPSTATS_MIB_OUTDISCARDS);
+		IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTDISCARDS);
 		kfree_skb(skb);
 		return 0;
 	}
 
-	return NF_HOOK_COND(NFPROTO_IPV6, NF_INET_POST_ROUTING, sk, skb,
-			    NULL, dev,
+	return NF_HOOK_COND(NFPROTO_IPV6, NF_INET_POST_ROUTING,
+			    net, sk, skb, NULL, dev,
 			    ip6_finish_output,
 			    !(IP6CB(skb)->flags & IP6SKB_REROUTED));
 }
@@ -224,8 +223,9 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 	if ((skb->len <= mtu) || skb->ignore_df || skb_is_gso(skb)) {
 		IP6_UPD_PO_STATS(net, ip6_dst_idev(skb_dst(skb)),
 			      IPSTATS_MIB_OUT, skb->len);
-		return NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, sk, skb,
-			       NULL, dst->dev, dst_output_sk);
+		return NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT,
+			       net, sk, skb, NULL, dst->dev,
+			       dst_output_sk);
 	}
 
 	skb->dev = dst->dev;
@@ -512,8 +512,8 @@ int ip6_forward(struct sk_buff *skb)
 
 	IP6_INC_STATS_BH(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTFORWDATAGRAMS);
 	IP6_ADD_STATS_BH(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTOCTETS, skb->len);
-	return NF_HOOK(NFPROTO_IPV6, NF_INET_FORWARD, NULL, skb,
-		       skb->dev, dst->dev,
+	return NF_HOOK(NFPROTO_IPV6, NF_INET_FORWARD,
+		       net, NULL, skb, skb->dev, dst->dev,
 		       ip6_forward_finish);
 
 error:
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 74ceb73c1c9a..5417f80334f6 100644
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
index 083b2927fc67..8be6bdb0e3f7 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -1645,7 +1645,7 @@ static void mld_sendpack(struct sk_buff *skb)
 	payload_len = skb->len;
 
 	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT,
-		      net->ipv6.igmp_sk, skb, NULL, skb->dev,
+		      net, net->ipv6.igmp_sk, skb, NULL, skb->dev,
 		      dst_output_sk);
 out:
 	if (!err) {
@@ -2008,8 +2008,9 @@ static void igmp6_send(struct in6_addr *addr, struct net_device *dev, int type)
 	}
 
 	skb_dst_set(skb, dst);
-	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, sk, skb,
-		      NULL, skb->dev, dst_output_sk);
+	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT,
+		      net, sk, skb, NULL, skb->dev,
+		      dst_output_sk);
 out:
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(net, idev, type);
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 0a05b35a90fc..171cb9af25c5 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -463,8 +463,8 @@ static void ndisc_send_skb(struct sk_buff *skb,
 	idev = __in6_dev_get(dst->dev);
 	IP6_UPD_PO_STATS(net, idev, IPSTATS_MIB_OUT, skb->len);
 
-	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, sk, skb,
-		      NULL, dst->dev,
+	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT,
+		      net, sk, skb, NULL, dst->dev,
 		      dst_output_sk);
 	if (!err) {
 		ICMP6MSGOUT_INC_STATS(net, idev, type);
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index a45db0b4785c..2346b369248a 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -75,7 +75,7 @@ static unsigned int ipv6_defrag(const struct nf_hook_ops *ops,
 
 	nf_ct_frag6_consume_orig(reasm);
 
-	NF_HOOK_THRESH(NFPROTO_IPV6, ops->hooknum, state->sk, reasm,
+	NF_HOOK_THRESH(NFPROTO_IPV6, ops->hooknum, state->net, state->sk, reasm,
 		       state->in, state->out,
 		       state->okfn, NF_IP6_PRI_CONNTRACK_DEFRAG + 1);
 
diff --git a/net/ipv6/output_core.c b/net/ipv6/output_core.c
index 21678acd4521..b053e36560a9 100644
--- a/net/ipv6/output_core.c
+++ b/net/ipv6/output_core.c
@@ -139,6 +139,7 @@ EXPORT_SYMBOL(ip6_dst_hoplimit);
 
 static int __ip6_local_out_sk(struct sock *sk, struct sk_buff *skb)
 {
+	struct net *net = dev_net(skb_dst(skb)->dev);
 	int len;
 
 	len = skb->len - sizeof(struct ipv6hdr);
@@ -147,8 +148,9 @@ static int __ip6_local_out_sk(struct sock *sk, struct sk_buff *skb)
 	ipv6_hdr(skb)->payload_len = htons(len);
 	IP6CB(skb)->nhoff = offsetof(struct ipv6hdr, nexthdr);
 
-	return nf_hook(NFPROTO_IPV6, NF_INET_LOCAL_OUT, sk, skb,
-		       NULL, skb_dst(skb)->dev, dst_output_sk);
+	return nf_hook(NFPROTO_IPV6, NF_INET_LOCAL_OUT,
+		       net, sk, skb, NULL, skb_dst(skb)->dev,
+		       dst_output_sk);
 }
 
 int __ip6_local_out(struct sk_buff *skb)
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index ca4700cb26c4..19c3ae193554 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -613,6 +613,7 @@ static int rawv6_send_hdrinc(struct sock *sk, struct msghdr *msg, int length,
 			unsigned int flags)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct net *net = sock_net(sk);
 	struct ipv6hdr *iph;
 	struct sk_buff *skb;
 	int err;
@@ -651,9 +652,10 @@ static int rawv6_send_hdrinc(struct sock *sk, struct msghdr *msg, int length,
 	if (err)
 		goto error_fault;
 
-	IP6_UPD_PO_STATS(sock_net(sk), rt->rt6i_idev, IPSTATS_MIB_OUT, skb->len);
-	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT, sk, skb,
-		      NULL, rt->dst.dev, dst_output_sk);
+	IP6_UPD_PO_STATS(net, rt->rt6i_idev, IPSTATS_MIB_OUT, skb->len);
+	err = NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT,
+		      net, sk, skb, NULL, rt->dst.dev,
+		      dst_output_sk);
 	if (err > 0)
 		err = net_xmit_errno(err);
 	if (err)
@@ -665,7 +667,7 @@ error_fault:
 	err = -EFAULT;
 	kfree_skb(skb);
 error:
-	IP6_INC_STATS(sock_net(sk), rt->rt6i_idev, IPSTATS_MIB_OUTDISCARDS);
+	IP6_INC_STATS(net, rt->rt6i_idev, IPSTATS_MIB_OUTDISCARDS);
 	if (err == -ENOBUFS && !np->recverr)
 		err = 0;
 	return err;
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
index 09c76a7b474d..0e3c546f8490 100644
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
index bf66a8657a5f..9f8130b33c32 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -540,7 +540,7 @@ static inline int ip_vs_nat_send_or_cont(int pf, struct sk_buff *skb,
 		ip_vs_update_conntrack(skb, cp, 1);
 	if (!local) {
 		skb_forward_csum(skb);
-		NF_HOOK(pf, NF_INET_LOCAL_OUT, NULL, skb,
+		NF_HOOK(pf, NF_INET_LOCAL_OUT, ip_vs_conn_net(cp), NULL, skb,
 			NULL, skb_dst(skb)->dev, dst_output_sk);
 	} else
 		ret = NF_ACCEPT;
@@ -558,7 +558,7 @@ static inline int ip_vs_send_or_cont(int pf, struct sk_buff *skb,
 		ip_vs_notrack(skb);
 	if (!local) {
 		skb_forward_csum(skb);
-		NF_HOOK(pf, NF_INET_LOCAL_OUT, NULL, skb,
+		NF_HOOK(pf, NF_INET_LOCAL_OUT, ip_vs_conn_net(cp), NULL, skb,
 			NULL, skb_dst(skb)->dev, dst_output_sk);
 	} else
 		ret = NF_ACCEPT;
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 68ada2ca4b60..3ff4c9d06206 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -132,6 +132,7 @@ out:
 int xfrm_output_resume(struct sk_buff *skb, int err)
 {
 	while (likely((err = xfrm_output_one(skb, err)) == 0)) {
+		struct net *net;
 		nf_reset(skb);
 
 		err = skb_dst(skb)->ops->local_out(skb);
@@ -141,8 +142,9 @@ int xfrm_output_resume(struct sk_buff *skb, int err)
 		if (!skb_dst(skb)->xfrm)
 			return dst_output(skb);
 
+		net = xs_net(skb_dst(skb)->xfrm);
 		err = nf_hook(skb_dst(skb)->ops->family,
-			      NF_INET_POST_ROUTING, skb->sk, skb,
+			      NF_INET_POST_ROUTING, net, skb->sk, skb,
 			      NULL, skb_dst(skb)->dev, xfrm_output2);
 		if (unlikely(err != 1))
 			goto out;
-- 
2.2.1

