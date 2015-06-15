From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH net-next 14/15] ipv4: Pass struct net into ip_defrag and ip_check_defrag
Date: Sun, 14 Jun 2015 22:13:12 -0500
Message-ID: <1434337993-6248-14-git-send-email-ebiederm@xmission.com>
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

Don't make ip_defrag guess which network namespace it needs
to defragment packets in.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 drivers/net/macvlan.c               | 2 +-
 include/net/ip.h                    | 6 +++---
 net/ipv4/ip_fragment.c              | 8 +++-----
 net/ipv4/ip_input.c                 | 8 +++++---
 net/ipv4/netfilter/nf_defrag_ipv4.c | 7 ++++---
 net/netfilter/ipvs/ip_vs_core.c     | 2 +-
 net/packet/af_packet.c              | 6 +++---
 7 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 9f59f17dc317..2e2f116d2daf 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -412,7 +412,7 @@ static rx_handler_result_t macvlan_handle_frame(struct sk_buff **pskb)
 
 	port = macvlan_port_get_rcu(skb->dev);
 	if (is_multicast_ether_addr(eth->h_dest)) {
-		skb = ip_check_defrag(skb, IP_DEFRAG_MACVLAN);
+		skb = ip_check_defrag(dev_net(skb->dev), skb, IP_DEFRAG_MACVLAN);
 		if (!skb)
 			return RX_HANDLER_CONSUMED;
 		eth = eth_hdr(skb);
diff --git a/include/net/ip.h b/include/net/ip.h
index 0750a186ea63..d9fa29bd4a16 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -505,11 +505,11 @@ static inline bool ip_defrag_user_in_between(u32 user,
 	return user >= lower_bond && user <= upper_bond;
 }
 
-int ip_defrag(struct sk_buff *skb, u32 user);
+int ip_defrag(struct net *net, struct sk_buff *skb, u32 user);
 #ifdef CONFIG_INET
-struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32 user);
+struct sk_buff *ip_check_defrag(struct net *net, struct sk_buff *skb, u32 user);
 #else
-static inline struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32 user)
+static inline struct sk_buff *ip_check_defrag(struct net *net, struct sk_buff *skb, u32 user)
 {
 	return skb;
 }
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index a50dc6d408d1..92c802c448e5 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -658,12 +658,10 @@ out_fail:
 }
 
 /* Process an incoming IP datagram fragment. */
-int ip_defrag(struct sk_buff *skb, u32 user)
+int ip_defrag(struct net *net, struct sk_buff *skb, u32 user)
 {
 	struct ipq *qp;
-	struct net *net;
 
-	net = skb->dev ? dev_net(skb->dev) : dev_net(skb_dst(skb)->dev);
 	IP_INC_STATS_BH(net, IPSTATS_MIB_REASMREQDS);
 
 	/* Lookup (or create) queue header */
@@ -686,7 +684,7 @@ int ip_defrag(struct sk_buff *skb, u32 user)
 }
 EXPORT_SYMBOL(ip_defrag);
 
-struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32 user)
+struct sk_buff *ip_check_defrag(struct net *net, struct sk_buff *skb, u32 user)
 {
 	struct iphdr iph;
 	int netoff;
@@ -715,7 +713,7 @@ struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32 user)
 			if (pskb_trim_rcsum(skb, netoff + len))
 				return skb;
 			memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
-			if (ip_defrag(skb, user))
+			if (ip_defrag(net, skb, user))
 				return NULL;
 			skb_clear_hash(skb);
 		}
diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index ac40876c476c..4ef75d649b71 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -168,7 +168,8 @@ bool ip_call_ra_chain(struct sk_buff *skb)
 		     sk->sk_bound_dev_if == dev->ifindex) &&
 		    net_eq(sock_net(sk), dev_net(dev))) {
 			if (ip_is_fragment(ip_hdr(skb))) {
-				if (ip_defrag(skb, IP_DEFRAG_CALL_RA_CHAIN))
+				if (ip_defrag(dev_net(skb->dev), skb,
+					      IP_DEFRAG_CALL_RA_CHAIN))
 					return true;
 			}
 			if (last) {
@@ -247,14 +248,15 @@ int ip_local_deliver(struct sk_buff *skb)
 	/*
 	 *	Reassemble IP fragments.
 	 */
+	struct net *net = dev_net(skb->dev);
 
 	if (ip_is_fragment(ip_hdr(skb))) {
-		if (ip_defrag(skb, IP_DEFRAG_LOCAL_DELIVER))
+		if (ip_defrag(net, skb, IP_DEFRAG_LOCAL_DELIVER))
 			return 0;
 	}
 
 	return NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_IN,
-		       dev_net(skb->dev), NULL, skb, skb->dev, NULL,
+		       net, NULL, skb, skb->dev, NULL,
 		       ip_local_deliver_finish);
 }
 
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index dad108c913eb..015787e47a7d 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -22,14 +22,15 @@
 #endif
 #include <net/netfilter/nf_conntrack_zones.h>
 
-static int nf_ct_ipv4_gather_frags(struct sk_buff *skb, u_int32_t user)
+static int nf_ct_ipv4_gather_frags(struct net *net, struct sk_buff *skb,
+				   u_int32_t user)
 {
 	int err;
 
 	skb_orphan(skb);
 
 	local_bh_disable();
-	err = ip_defrag(skb, user);
+	err = ip_defrag(net, skb, user);
 	local_bh_enable();
 
 	if (!err) {
@@ -85,7 +86,7 @@ static unsigned int ipv4_conntrack_defrag(const struct nf_hook_ops *ops,
 		enum ip_defrag_users user =
 			nf_ct_defrag_user(state->hook, skb);
 
-		if (nf_ct_ipv4_gather_frags(skb, user))
+		if (nf_ct_ipv4_gather_frags(state->net, skb, user))
 			return NF_STOLEN;
 	}
 	return NF_ACCEPT;
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 5d2b806a862e..f8a11129b371 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -657,7 +657,7 @@ static inline int ip_vs_gather_frags(struct sk_buff *skb, u_int32_t user)
 	int err;
 
 	local_bh_disable();
-	err = ip_defrag(skb, user);
+	err = ip_defrag(skb_net(skb), skb, user);
 	local_bh_enable();
 	if (!err)
 		ip_send_check(ip_hdr(skb));
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index fd5164139bf0..4f1b75addcc8 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1440,17 +1440,17 @@ static int packet_rcv_fanout(struct sk_buff *skb, struct net_device *dev,
 {
 	struct packet_fanout *f = pt->af_packet_priv;
 	unsigned int num = f->num_members;
+	struct net *net = read_pnet(&f->net);
 	struct packet_sock *po;
 	unsigned int idx;
 
-	if (!net_eq(dev_net(dev), read_pnet(&f->net)) ||
-	    !num) {
+	if (!net_eq(dev_net(dev), net) || !num) {
 		kfree_skb(skb);
 		return 0;
 	}
 
 	if (fanout_has_flag(f, PACKET_FANOUT_FLAG_DEFRAG)) {
-		skb = ip_check_defrag(skb, IP_DEFRAG_AF_PACKET);
+		skb = ip_check_defrag(net, skb, IP_DEFRAG_AF_PACKET);
 		if (!skb)
 			return 0;
 	}
-- 
2.2.1

