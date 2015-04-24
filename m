From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 RFC 10/15] flow_dissect: use programable dissector in skb_flow_dissect and friends
Date: Fri, 24 Apr 2015 17:51:36 +0200
Message-ID: <1429890701-30052-11-git-send-email-jiri@resnulli.us>
References: <1429890701-30052-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, therbert@google.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:36237 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031310AbbDXPwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 11:52:03 -0400
Received: by wgen6 with SMTP id n6so55144254wge.3
        for <netdev@vger.kernel.org>; Fri, 24 Apr 2015 08:52:01 -0700 (PDT)
In-Reply-To: <1429890701-30052-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/bonding/bond_main.c                |  18 +--
 drivers/net/ethernet/cisco/enic/enic_clsf.c    |  27 ++--
 drivers/net/ethernet/cisco/enic/enic_ethtool.c |  10 +-
 drivers/net/hyperv/netvsc_drv.c                |   8 +-
 include/linux/skbuff.h                         |   4 +-
 include/net/flow_dissector.h                   |  63 +++++----
 include/net/ip.h                               |   8 +-
 include/net/ipv6.h                             |   8 +-
 net/core/flow_dissector.c                      | 189 +++++++++++++++++--------
 net/ethernet/eth.c                             |   6 +-
 net/sched/cls_flow.c                           |  20 +--
 net/sched/sch_choke.c                          |   4 +-
 net/sched/sch_fq_codel.c                       |   8 +-
 net/sched/sch_hhf.c                            |   8 +-
 net/sched/sch_sfb.c                            |  20 +--
 net/sched/sch_sfq.c                            |   8 +-
 16 files changed, 246 insertions(+), 163 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3c4217b..1e3c78f 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3052,16 +3052,16 @@ static bool bond_flow_dissect(struct bonding *bond, struct sk_buff *skb,
 	int noff, proto = -1;
 
 	if (bond->params.xmit_policy > BOND_XMIT_POLICY_LAYER23)
-		return skb_flow_dissect(skb, fk);
+		return skb_flow_dissect_flow_keys(skb, fk);
 
-	fk->ports = 0;
+	fk->ports.ports = 0;
 	noff = skb_network_offset(skb);
 	if (skb->protocol == htons(ETH_P_IP)) {
 		if (unlikely(!pskb_may_pull(skb, noff + sizeof(*iph))))
 			return false;
 		iph = ip_hdr(skb);
-		fk->src = iph->saddr;
-		fk->dst = iph->daddr;
+		fk->addrs.src = iph->saddr;
+		fk->addrs.dst = iph->daddr;
 		noff += iph->ihl << 2;
 		if (!ip_is_fragment(iph))
 			proto = iph->protocol;
@@ -3069,15 +3069,15 @@ static bool bond_flow_dissect(struct bonding *bond, struct sk_buff *skb,
 		if (unlikely(!pskb_may_pull(skb, noff + sizeof(*iph6))))
 			return false;
 		iph6 = ipv6_hdr(skb);
-		fk->src = (__force __be32)ipv6_addr_hash(&iph6->saddr);
-		fk->dst = (__force __be32)ipv6_addr_hash(&iph6->daddr);
+		fk->addrs.src = (__force __be32)ipv6_addr_hash(&iph6->saddr);
+		fk->addrs.dst = (__force __be32)ipv6_addr_hash(&iph6->daddr);
 		noff += sizeof(*iph6);
 		proto = iph6->nexthdr;
 	} else {
 		return false;
 	}
 	if (bond->params.xmit_policy == BOND_XMIT_POLICY_LAYER34 && proto >= 0)
-		fk->ports = skb_flow_get_ports(skb, noff, proto);
+		fk->ports.ports = skb_flow_get_ports(skb, noff, proto);
 
 	return true;
 }
@@ -3103,8 +3103,8 @@ u32 bond_xmit_hash(struct bonding *bond, struct sk_buff *skb)
 	    bond->params.xmit_policy == BOND_XMIT_POLICY_ENCAP23)
 		hash = bond_eth_hash(skb);
 	else
-		hash = (__force u32)flow.ports;
-	hash ^= (__force u32)flow.dst ^ (__force u32)flow.src;
+		hash = (__force u32)flow.ports.ports;
+	hash ^= (__force u32)flow.addrs.dst ^ (__force u32)flow.addrs.src;
 	hash ^= (hash >> 16);
 	hash ^= (hash >> 8);
 
diff --git a/drivers/net/ethernet/cisco/enic/enic_clsf.c b/drivers/net/ethernet/cisco/enic/enic_clsf.c
index 380f049..d3d25c7 100644
--- a/drivers/net/ethernet/cisco/enic/enic_clsf.c
+++ b/drivers/net/ethernet/cisco/enic/enic_clsf.c
@@ -22,7 +22,7 @@ int enic_addfltr_5t(struct enic *enic, struct flow_keys *keys, u16 rq)
 	int res;
 	struct filter data;
 
-	switch (keys->ip_proto) {
+	switch (keys->basic.ip_proto) {
 	case IPPROTO_TCP:
 		data.u.ipv4.protocol = PROTO_TCP;
 		break;
@@ -33,10 +33,10 @@ int enic_addfltr_5t(struct enic *enic, struct flow_keys *keys, u16 rq)
 		return -EPROTONOSUPPORT;
 	};
 	data.type = FILTER_IPV4_5TUPLE;
-	data.u.ipv4.src_addr = ntohl(keys->src);
-	data.u.ipv4.dst_addr = ntohl(keys->dst);
-	data.u.ipv4.src_port = ntohs(keys->port16[0]);
-	data.u.ipv4.dst_port = ntohs(keys->port16[1]);
+	data.u.ipv4.src_addr = ntohl(keys->addrs.src);
+	data.u.ipv4.dst_addr = ntohl(keys->addrs.dst);
+	data.u.ipv4.src_port = ntohs(keys->ports.port16[0]);
+	data.u.ipv4.dst_port = ntohs(keys->ports.port16[1]);
 	data.u.ipv4.flags = FILTER_FIELDS_IPV4_5TUPLE;
 
 	spin_lock_bh(&enic->devcmd_lock);
@@ -158,11 +158,11 @@ static struct enic_rfs_fltr_node *htbl_key_search(struct hlist_head *h,
 	struct enic_rfs_fltr_node *tpos;
 
 	hlist_for_each_entry(tpos, h, node)
-		if (tpos->keys.src == k->src &&
-		    tpos->keys.dst == k->dst &&
-		    tpos->keys.ports == k->ports &&
-		    tpos->keys.ip_proto == k->ip_proto &&
-		    tpos->keys.n_proto == k->n_proto)
+		if (tpos->keys.addrs.src == k->addrs.src &&
+		    tpos->keys.addrs.dst == k->addrs.dst &&
+		    tpos->keys.ports.ports == k->ports.ports &&
+		    tpos->keys.basic.ip_proto == k->basic.ip_proto &&
+		    tpos->keys.basic.n_proto == k->basic.n_proto)
 			return tpos;
 	return NULL;
 }
@@ -177,9 +177,10 @@ int enic_rx_flow_steer(struct net_device *dev, const struct sk_buff *skb,
 	int res, i;
 
 	enic = netdev_priv(dev);
-	res = skb_flow_dissect(skb, &keys);
-	if (!res || keys.n_proto != htons(ETH_P_IP) ||
-	    (keys.ip_proto != IPPROTO_TCP && keys.ip_proto != IPPROTO_UDP))
+	res = skb_flow_dissect_flow_keys(skb, &keys);
+	if (!res || keys.basic.n_proto != htons(ETH_P_IP) ||
+	    (keys.basic.ip_proto != IPPROTO_TCP &&
+	     keys.basic.ip_proto != IPPROTO_UDP))
 		return -EPROTONOSUPPORT;
 
 	tbl_idx = skb_get_hash_raw(skb) & ENIC_RFS_FLW_MASK;
diff --git a/drivers/net/ethernet/cisco/enic/enic_ethtool.c b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
index 28d9ca6..7588f8d 100644
--- a/drivers/net/ethernet/cisco/enic/enic_ethtool.c
+++ b/drivers/net/ethernet/cisco/enic/enic_ethtool.c
@@ -334,7 +334,7 @@ static int enic_grxclsrule(struct enic *enic, struct ethtool_rxnfc *cmd)
 	n = htbl_fltr_search(enic, (u16)fsp->location);
 	if (!n)
 		return -EINVAL;
-	switch (n->keys.ip_proto) {
+	switch (n->keys.basic.ip_proto) {
 	case IPPROTO_TCP:
 		fsp->flow_type = TCP_V4_FLOW;
 		break;
@@ -346,16 +346,16 @@ static int enic_grxclsrule(struct enic *enic, struct ethtool_rxnfc *cmd)
 		break;
 	}
 
-	fsp->h_u.tcp_ip4_spec.ip4src = n->keys.src;
+	fsp->h_u.tcp_ip4_spec.ip4src = n->keys.addrs.src;
 	fsp->m_u.tcp_ip4_spec.ip4src = (__u32)~0;
 
-	fsp->h_u.tcp_ip4_spec.ip4dst = n->keys.dst;
+	fsp->h_u.tcp_ip4_spec.ip4dst = n->keys.addrs.dst;
 	fsp->m_u.tcp_ip4_spec.ip4dst = (__u32)~0;
 
-	fsp->h_u.tcp_ip4_spec.psrc = n->keys.port16[0];
+	fsp->h_u.tcp_ip4_spec.psrc = n->keys.ports.port16[0];
 	fsp->m_u.tcp_ip4_spec.psrc = (__u16)~0;
 
-	fsp->h_u.tcp_ip4_spec.pdst = n->keys.port16[1];
+	fsp->h_u.tcp_ip4_spec.pdst = n->keys.ports.port16[1];
 	fsp->m_u.tcp_ip4_spec.pdst = (__u16)~0;
 
 	fsp->ring_cookie = n->rq_id;
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index a3a9d38..219e21b 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -193,12 +193,12 @@ static bool netvsc_set_hash(u32 *hash, struct sk_buff *skb)
 	struct flow_keys flow;
 	int data_len;
 
-	if (!skb_flow_dissect(skb, &flow) ||
-	    !(flow.n_proto == htons(ETH_P_IP) ||
-	      flow.n_proto == htons(ETH_P_IPV6)))
+	if (!skb_flow_dissect_flow_keys(skb, &flow) ||
+	    !(flow.basic.n_proto == htons(ETH_P_IP) ||
+	      flow.basic.n_proto == htons(ETH_P_IPV6)))
 		return false;
 
-	if (flow.ip_proto == IPPROTO_TCP)
+	if (flow.basic.ip_proto == IPPROTO_TCP)
 		data_len = 12;
 	else
 		data_len = 8;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 57f5e5c..19314ae 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1932,8 +1932,8 @@ static inline void skb_probe_transport_header(struct sk_buff *skb,
 
 	if (skb_transport_header_was_set(skb))
 		return;
-	else if (skb_flow_dissect(skb, &keys))
-		skb_set_transport_header(skb, keys.thoff);
+	else if (skb_flow_dissect_flow_keys(skb, &keys))
+		skb_set_transport_header(skb, keys.basic.thoff);
 	else
 		skb_set_transport_header(skb, offset_hint);
 }
diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index 3bdf6a1..32a7997 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -59,42 +59,47 @@ struct flow_dissector {
 	unsigned short int offset[FLOW_DISSECTOR_KEY_MAX];
 };
 
-/* struct flow_keys:
- *	@src: source ip address in case of IPv4
- *	      For IPv6 it contains 32bit hash of src address
- *	@dst: destination ip address in case of IPv4
- *	      For IPv6 it contains 32bit hash of dst address
- *	@ports: port numbers of Transport header
- *		port16[0]: src port number
- *		port16[1]: dst port number
- *	@thoff: Transport header offset
- *	@n_proto: Network header protocol (eg. IPv4/IPv6)
- *	@ip_proto: Transport header protocol (eg. TCP/UDP)
- * All the members, except thoff, are in network byte order.
- */
-struct flow_keys {
-	/* (src,dst) must be grouped, in the same way than in IP header */
-	__be32 src;
-	__be32 dst;
-	union {
-		__be32 ports;
-		__be16 port16[2];
-	};
-	u16	thoff;
-	__be16	n_proto;
-	u8	ip_proto;
-};
-
 void skb_flow_dissector_init(struct flow_dissector *flow_dissector,
 			     const struct flow_dissector_key *key,
 			     unsigned int key_count);
-bool __skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow,
+
+bool __skb_flow_dissect(const struct sk_buff *skb,
+			struct flow_dissector *flow_dissector,
+			void *target_container,
 			void *data, __be16 proto, int nhoff, int hlen);
 
 static inline bool skb_flow_dissect(const struct sk_buff *skb,
-				    struct flow_keys *flow)
+				    struct flow_dissector *flow_dissector,
+				    void *target_container)
+{
+	return __skb_flow_dissect(skb, flow_dissector, target_container,
+				  NULL, 0, 0, 0);
+}
+
+struct flow_keys {
+	struct flow_dissector_key_addrs addrs;
+	struct flow_dissector_key_ports ports;
+	struct flow_dissector_key_basic basic;
+};
+
+extern struct flow_dissector flow_keys_dissector;
+extern struct flow_dissector flow_keys_buf_dissector;
+
+static inline bool skb_flow_dissect_flow_keys(const struct sk_buff *skb,
+					      struct flow_keys *flow)
+{
+	memset(flow, 0, sizeof(*flow));
+	return __skb_flow_dissect(skb, &flow_keys_dissector, flow,
+				  NULL, 0, 0, 0);
+}
+
+static inline bool skb_flow_dissect_flow_keys_buf(struct flow_keys *flow,
+						  void *data, __be16 proto,
+						  int nhoff, int hlen)
 {
-	return __skb_flow_dissect(skb, flow, NULL, 0, 0, 0);
+	memset(flow, 0, sizeof(*flow));
+	return __skb_flow_dissect(NULL, &flow_keys_buf_dissector, flow,
+				  data, proto, nhoff, hlen);
 }
 
 __be32 __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
diff --git a/include/net/ip.h b/include/net/ip.h
index 562eb65..b0443d4 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -360,10 +360,10 @@ static inline void inet_set_txhash(struct sock *sk)
 	struct inet_sock *inet = inet_sk(sk);
 	struct flow_keys keys;
 
-	keys.src = inet->inet_saddr;
-	keys.dst = inet->inet_daddr;
-	keys.port16[0] = inet->inet_sport;
-	keys.port16[1] = inet->inet_dport;
+	keys.addrs.src = inet->inet_saddr;
+	keys.addrs.dst = inet->inet_daddr;
+	keys.ports.port16[0] = inet->inet_sport;
+	keys.ports.port16[1] = inet->inet_dport;
 
 	sk->sk_txhash = flow_hash_from_keys(&keys);
 }
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 7a0ace4..14cd04f 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -696,10 +696,10 @@ static inline void ip6_set_txhash(struct sock *sk)
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct flow_keys keys;
 
-	keys.src = (__force __be32)ipv6_addr_hash(&np->saddr);
-	keys.dst = (__force __be32)ipv6_addr_hash(&sk->sk_v6_daddr);
-	keys.port16[0] = inet->inet_sport;
-	keys.port16[1] = inet->inet_dport;
+	keys.addrs.src = (__force __be32)ipv6_addr_hash(&np->saddr);
+	keys.addrs.dst = (__force __be32)ipv6_addr_hash(&sk->sk_v6_daddr);
+	keys.ports.port16[0] = inet->inet_sport;
+	keys.ports.port16[1] = inet->inet_dport;
 
 	sk->sk_txhash = flow_hash_from_keys(&keys);
 }
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 1566768..564288e 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -13,6 +13,7 @@
 #include <linux/if_tunnel.h>
 #include <linux/if_pppox.h>
 #include <linux/ppp_defs.h>
+#include <linux/stddef.h>
 #include <net/flow_dissector.h>
 #include <scsi/fc/fc_fcoe.h>
 
@@ -63,17 +64,6 @@ void skb_flow_dissector_init(struct flow_dissector *flow_dissector,
 }
 EXPORT_SYMBOL(skb_flow_dissector_init);
 
-/* copy saddr & daddr, possibly using 64bit load/store
- * Equivalent to :	flow->src = iph->saddr;
- *			flow->dst = iph->daddr;
- */
-static void iph_to_flow_copy_addrs(struct flow_keys *flow, const struct iphdr *iph)
-{
-	BUILD_BUG_ON(offsetof(typeof(*flow), dst) !=
-		     offsetof(typeof(*flow), src) + sizeof(flow->src));
-	memcpy(&flow->src, &iph->saddr, sizeof(flow->src) + sizeof(flow->dst));
-}
-
 /**
  * __skb_flow_get_ports - extract the upper layer ports and return them
  * @skb: sk_buff to extract the ports from
@@ -111,17 +101,27 @@ EXPORT_SYMBOL(__skb_flow_get_ports);
 /**
  * __skb_flow_dissect - extract the flow_keys struct and return it
  * @skb: sk_buff to extract the flow from, can be NULL if the rest are specified
+ * @flow_dissector: list of keys to dissect
+ * @target_container: target structure to put dissected values into
  * @data: raw buffer pointer to the packet, if NULL use skb->data
  * @proto: protocol for which to get the flow, if @data is NULL use skb->protocol
  * @nhoff: network header offset, if @data is NULL use skb_network_offset(skb)
  * @hlen: packet header length, if @data is NULL use skb_headlen(skb)
  *
- * The function will try to retrieve the struct flow_keys from either the skbuff
- * or a raw buffer specified by the rest parameters
+ * The function will try to retrieve individual keys into target specified
+ * by flow_dissector from either the skbuff or a raw buffer specified by the
+ * rest parameters.
+ *
+ * Caller must take care of zeroing target container memory.
  */
-bool __skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow,
+bool __skb_flow_dissect(const struct sk_buff *skb,
+			struct flow_dissector *flow_dissector,
+			void *target_container,
 			void *data, __be16 proto, int nhoff, int hlen)
 {
+	struct flow_dissector_key_basic *key_basic;
+	struct flow_dissector_key_addrs *key_addrs;
+	struct flow_dissector_key_ports *key_ports;
 	u8 ip_proto;
 
 	if (!data) {
@@ -131,7 +131,12 @@ bool __skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow,
 		hlen = skb_headlen(skb);
 	}
 
-	memset(flow, 0, sizeof(*flow));
+	/* It is ensured by skb_flow_dissector_init() that basic key will
+	 * be always present.
+	 */
+	key_basic = skb_flow_dissector_target(flow_dissector,
+					      FLOW_DISSECTOR_KEY_BASIC,
+					      target_container);
 
 again:
 	switch (proto) {
@@ -148,14 +153,13 @@ ip:
 		if (ip_is_fragment(iph))
 			ip_proto = 0;
 
-		/* skip the address processing if skb is NULL.  The assumption
-		 * here is that if there is no skb we are not looking for flow
-		 * info but lengths and protocols.
-		 */
-		if (!skb)
+		if (!skb_flow_dissector_uses_key(flow_dissector,
+						 FLOW_DISSECTOR_KEY_IPV4_ADDRS))
 			break;
-
-		iph_to_flow_copy_addrs(flow, iph);
+		key_addrs = skb_flow_dissector_target(flow_dissector,
+						      FLOW_DISSECTOR_KEY_IPV4_ADDRS,
+						      target_container);
+		memcpy(key_addrs, &iph->saddr, sizeof(*key_addrs));
 		break;
 	}
 	case htons(ETH_P_IPV6): {
@@ -171,12 +175,15 @@ ipv6:
 		ip_proto = iph->nexthdr;
 		nhoff += sizeof(struct ipv6hdr);
 
-		/* see comment above in IPv4 section */
-		if (!skb)
+		if (!skb_flow_dissector_uses_key(flow_dissector,
+						 FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS))
 			break;
+		key_addrs = skb_flow_dissector_target(flow_dissector,
+						      FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS,
+						      target_container);
 
-		flow->src = (__force __be32)ipv6_addr_hash(&iph->saddr);
-		flow->dst = (__force __be32)ipv6_addr_hash(&iph->daddr);
+		key_addrs->src = (__force __be32)ipv6_addr_hash(&iph->saddr);
+		key_addrs->dst = (__force __be32)ipv6_addr_hash(&iph->daddr);
 
 		flow_label = ip6_flowlabel(iph);
 		if (flow_label) {
@@ -184,10 +191,18 @@ ipv6:
 			 * use that to represent the ports without any
 			 * further dissection.
 			 */
-			flow->n_proto = proto;
-			flow->ip_proto = ip_proto;
-			flow->ports = flow_label;
-			flow->thoff = (u16)nhoff;
+
+			key_basic->n_proto = proto;
+			key_basic->ip_proto = ip_proto;
+			key_basic->thoff = (u16)nhoff;
+
+			if (!skb_flow_dissector_uses_key(flow_dissector,
+							 FLOW_DISSECTOR_KEY_PORTS))
+				break;
+			key_ports = skb_flow_dissector_target(flow_dissector,
+							      FLOW_DISSECTOR_KEY_PORTS,
+							      target_container);
+			key_ports->ports = flow_label;
 
 			return true;
 		}
@@ -234,14 +249,22 @@ ipv6:
 		hdr = __skb_header_pointer(skb, nhoff, sizeof(_hdr), data, hlen, &_hdr);
 		if (!hdr)
 			return false;
-		flow->src = hdr->srcnode;
-		flow->dst = 0;
-		flow->n_proto = proto;
-		flow->thoff = (u16)nhoff;
+		key_basic->n_proto = proto;
+		key_basic->thoff = (u16)nhoff;
+
+		if (skb_flow_dissector_uses_key(flow_dissector,
+						FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS)) {
+			return true;
+			key_addrs = skb_flow_dissector_target(flow_dissector,
+							      FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS,
+							      target_container);
+			key_addrs->src = hdr->srcnode;
+			key_addrs->dst = 0;
+		}
 		return true;
 	}
 	case htons(ETH_P_FCOE):
-		flow->thoff = (u16)(nhoff + FCOE_HEADER_LEN);
+		key_basic->thoff = (u16)(nhoff + FCOE_HEADER_LEN);
 		/* fall through */
 	default:
 		return false;
@@ -296,14 +319,24 @@ ipv6:
 		break;
 	}
 
-	flow->n_proto = proto;
-	flow->ip_proto = ip_proto;
-	flow->thoff = (u16) nhoff;
-
-	/* unless skb is set we don't need to record port info */
-	if (skb)
-		flow->ports = __skb_flow_get_ports(skb, nhoff, ip_proto,
-						   data, hlen);
+	/* It is ensured by skb_flow_dissector_init() that basic key will
+	 * be always present.
+	 */
+	key_basic = skb_flow_dissector_target(flow_dissector,
+					      FLOW_DISSECTOR_KEY_BASIC,
+					      target_container);
+	key_basic->n_proto = proto;
+	key_basic->ip_proto = ip_proto;
+	key_basic->thoff = (u16) nhoff;
+
+	if (skb_flow_dissector_uses_key(flow_dissector,
+					FLOW_DISSECTOR_KEY_PORTS)) {
+		key_ports = skb_flow_dissector_target(flow_dissector,
+						      FLOW_DISSECTOR_KEY_PORTS,
+						      target_container);
+		key_ports->ports = __skb_flow_get_ports(skb, nhoff, ip_proto,
+							data, hlen);
+	}
 
 	return true;
 }
@@ -326,16 +359,16 @@ static inline u32 __flow_hash_from_keys(struct flow_keys *keys)
 	u32 hash;
 
 	/* get a consistent hash (same value on both flow directions) */
-	if (((__force u32)keys->dst < (__force u32)keys->src) ||
-	    (((__force u32)keys->dst == (__force u32)keys->src) &&
-	     ((__force u16)keys->port16[1] < (__force u16)keys->port16[0]))) {
-		swap(keys->dst, keys->src);
-		swap(keys->port16[0], keys->port16[1]);
+	if (((__force u32)keys->addrs.dst < (__force u32)keys->addrs.src) ||
+	    (((__force u32)keys->addrs.dst == (__force u32)keys->addrs.src) &&
+	     ((__force u16)keys->ports.port16[1] < (__force u16)keys->ports.port16[0]))) {
+		swap(keys->addrs.dst, keys->addrs.src);
+		swap(keys->ports.port16[0], keys->ports.port16[1]);
 	}
 
-	hash = __flow_hash_3words((__force u32)keys->dst,
-				  (__force u32)keys->src,
-				  (__force u32)keys->ports);
+	hash = __flow_hash_3words((__force u32)keys->addrs.dst,
+				  (__force u32)keys->addrs.src,
+				  (__force u32)keys->ports.ports);
 	if (!hash)
 		hash = 1;
 
@@ -361,9 +394,9 @@ void __skb_get_hash(struct sk_buff *skb)
 {
 	struct flow_keys keys;
 
-	if (!skb_flow_dissect(skb, &keys))
+	if (!skb_flow_dissect_flow_keys(skb, &keys))
 		return;
-	if (keys.ports)
+	if (keys.ports.ports)
 		skb->l4_hash = 1;
 	skb->sw_hash = 1;
 	skb->hash = __flow_hash_from_keys(&keys);
@@ -373,9 +406,9 @@ EXPORT_SYMBOL(__skb_get_hash);
 u32 __skb_get_poff(const struct sk_buff *skb, void *data,
 		   const struct flow_keys *keys, int hlen)
 {
-	u32 poff = keys->thoff;
+	u32 poff = keys->basic.thoff;
 
-	switch (keys->ip_proto) {
+	switch (keys->basic.ip_proto) {
 	case IPPROTO_TCP: {
 		/* access doff as u8 to avoid unaligned access */
 		const u8 *doff;
@@ -429,8 +462,52 @@ u32 skb_get_poff(const struct sk_buff *skb)
 {
 	struct flow_keys keys;
 
-	if (!skb_flow_dissect(skb, &keys))
+	if (!skb_flow_dissect_flow_keys(skb, &keys))
 		return 0;
 
 	return __skb_get_poff(skb, skb->data, &keys, skb_headlen(skb));
 }
+
+static const struct flow_dissector_key flow_keys_dissector_keys[] = {
+	{
+		.key_id = FLOW_DISSECTOR_KEY_BASIC,
+		.offset = offsetof(struct flow_keys, basic),
+	},
+	{
+		.key_id = FLOW_DISSECTOR_KEY_IPV4_ADDRS,
+		.offset = offsetof(struct flow_keys, addrs),
+	},
+	{
+		.key_id = FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS,
+		.offset = offsetof(struct flow_keys, addrs),
+	},
+	{
+		.key_id = FLOW_DISSECTOR_KEY_PORTS,
+		.offset = offsetof(struct flow_keys, ports),
+	},
+};
+
+static const struct flow_dissector_key flow_keys_buf_dissector_keys[] = {
+	{
+		.key_id = FLOW_DISSECTOR_KEY_BASIC,
+		.offset = offsetof(struct flow_keys, basic),
+	},
+};
+
+struct flow_dissector flow_keys_dissector __read_mostly;
+EXPORT_SYMBOL(flow_keys_dissector);
+
+struct flow_dissector flow_keys_buf_dissector __read_mostly;
+
+static int __init init_default_flow_dissectors(void)
+{
+	skb_flow_dissector_init(&flow_keys_dissector,
+				flow_keys_dissector_keys,
+				ARRAY_SIZE(flow_keys_dissector_keys));
+	skb_flow_dissector_init(&flow_keys_buf_dissector,
+				flow_keys_buf_dissector_keys,
+				ARRAY_SIZE(flow_keys_buf_dissector_keys));
+	return 0;
+}
+
+late_initcall_sync(init_default_flow_dissectors);
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 04d3bea..9a4d983 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -131,9 +131,9 @@ u32 eth_get_headlen(void *data, unsigned int len)
 		return len;
 
 	/* parse any remaining L2/L3 headers, check for L4 */
-	if (!__skb_flow_dissect(NULL, &keys, data,
-				eth->h_proto, sizeof(*eth), len))
-		return max_t(u32, keys.thoff, sizeof(*eth));
+	if (!skb_flow_dissect_flow_keys_buf(&keys, data, eth->h_proto,
+					    sizeof(*eth), len))
+		return max_t(u32, keys.basic.thoff, sizeof(*eth));
 
 	/* parse for any L4 headers */
 	return min_t(u32, __skb_get_poff(NULL, data, &keys, len), len);
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index 4c5a922..4b3e3e3 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -68,35 +68,35 @@ static inline u32 addr_fold(void *addr)
 
 static u32 flow_get_src(const struct sk_buff *skb, const struct flow_keys *flow)
 {
-	if (flow->src)
-		return ntohl(flow->src);
+	if (flow->addrs.src)
+		return ntohl(flow->addrs.src);
 	return addr_fold(skb->sk);
 }
 
 static u32 flow_get_dst(const struct sk_buff *skb, const struct flow_keys *flow)
 {
-	if (flow->dst)
-		return ntohl(flow->dst);
+	if (flow->addrs.dst)
+		return ntohl(flow->addrs.dst);
 	return addr_fold(skb_dst(skb)) ^ (__force u16) tc_skb_protocol(skb);
 }
 
 static u32 flow_get_proto(const struct sk_buff *skb, const struct flow_keys *flow)
 {
-	return flow->ip_proto;
+	return flow->basic.ip_proto;
 }
 
 static u32 flow_get_proto_src(const struct sk_buff *skb, const struct flow_keys *flow)
 {
-	if (flow->ports)
-		return ntohs(flow->port16[0]);
+	if (flow->ports.ports)
+		return ntohs(flow->ports.port16[0]);
 
 	return addr_fold(skb->sk);
 }
 
 static u32 flow_get_proto_dst(const struct sk_buff *skb, const struct flow_keys *flow)
 {
-	if (flow->ports)
-		return ntohs(flow->port16[1]);
+	if (flow->ports.ports)
+		return ntohs(flow->ports.port16[1]);
 
 	return addr_fold(skb_dst(skb)) ^ (__force u16) tc_skb_protocol(skb);
 }
@@ -295,7 +295,7 @@ static int flow_classify(struct sk_buff *skb, const struct tcf_proto *tp,
 
 		keymask = f->keymask;
 		if (keymask & FLOW_KEYS_NEEDED)
-			skb_flow_dissect(skb, &flow_keys);
+			skb_flow_dissect_flow_keys(skb, &flow_keys);
 
 		for (n = 0; n < f->nkeys; n++) {
 			key = ffs(keymask) - 1;
diff --git a/net/sched/sch_choke.c b/net/sched/sch_choke.c
index 0796af7..19831d0 100644
--- a/net/sched/sch_choke.c
+++ b/net/sched/sch_choke.c
@@ -176,13 +176,13 @@ static bool choke_match_flow(struct sk_buff *skb1,
 
 	if (!choke_skb_cb(skb1)->keys_valid) {
 		choke_skb_cb(skb1)->keys_valid = 1;
-		skb_flow_dissect(skb1, &temp);
+		skb_flow_dissect_flow_keys(skb1, &temp);
 		memcpy(&choke_skb_cb(skb1)->keys, &temp, CHOKE_K_LEN);
 	}
 
 	if (!choke_skb_cb(skb2)->keys_valid) {
 		choke_skb_cb(skb2)->keys_valid = 1;
-		skb_flow_dissect(skb2, &temp);
+		skb_flow_dissect_flow_keys(skb2, &temp);
 		memcpy(&choke_skb_cb(skb2)->keys, &temp, CHOKE_K_LEN);
 	}
 
diff --git a/net/sched/sch_fq_codel.c b/net/sched/sch_fq_codel.c
index f4a3f84..2b7bf47 100644
--- a/net/sched/sch_fq_codel.c
+++ b/net/sched/sch_fq_codel.c
@@ -73,10 +73,10 @@ static unsigned int fq_codel_hash(const struct fq_codel_sched_data *q,
 	struct flow_keys keys;
 	unsigned int hash;
 
-	skb_flow_dissect(skb, &keys);
-	hash = jhash_3words((__force u32)keys.dst,
-			    (__force u32)keys.src ^ keys.ip_proto,
-			    (__force u32)keys.ports, q->perturbation);
+	skb_flow_dissect_flow_keys(skb, &keys);
+	hash = jhash_3words((__force u32)keys.addrs.dst,
+			    (__force u32)keys.addrs.src ^ keys.basic.ip_proto,
+			    (__force u32)keys.ports.ports, q->perturbation);
 
 	return reciprocal_scale(hash, q->flows_cnt);
 }
diff --git a/net/sched/sch_hhf.c b/net/sched/sch_hhf.c
index 6df497d..76cea8a 100644
--- a/net/sched/sch_hhf.c
+++ b/net/sched/sch_hhf.c
@@ -185,10 +185,10 @@ static unsigned int skb_hash(const struct hhf_sched_data *q,
 	if (skb->sk && skb->sk->sk_hash)
 		return skb->sk->sk_hash;
 
-	skb_flow_dissect(skb, &keys);
-	hash = jhash_3words((__force u32)keys.dst,
-			    (__force u32)keys.src ^ keys.ip_proto,
-			    (__force u32)keys.ports, q->perturbation);
+	skb_flow_dissect_flow_keys(skb, &keys);
+	hash = jhash_3words((__force u32)keys.addrs.dst,
+			    (__force u32)keys.addrs.src ^ keys.basic.ip_proto,
+			    (__force u32)keys.ports.ports, q->perturbation);
 	return hash;
 }
 
diff --git a/net/sched/sch_sfb.c b/net/sched/sch_sfb.c
index b1f258b..48bdf14 100644
--- a/net/sched/sch_sfb.c
+++ b/net/sched/sch_sfb.c
@@ -312,18 +312,18 @@ static int sfb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 		/* If using external classifiers, get result and record it. */
 		if (!sfb_classify(skb, fl, &ret, &salt))
 			goto other_drop;
-		keys.src = salt;
-		keys.dst = 0;
-		keys.ports = 0;
+		keys.addrs.src = salt;
+		keys.addrs.dst = 0;
+		keys.ports.ports = 0;
 	} else {
-		skb_flow_dissect(skb, &keys);
+		skb_flow_dissect_flow_keys(skb, &keys);
 	}
 
 	slot = q->slot;
 
-	sfbhash = jhash_3words((__force u32)keys.dst,
-			       (__force u32)keys.src,
-			       (__force u32)keys.ports,
+	sfbhash = jhash_3words((__force u32)keys.addrs.dst,
+			       (__force u32)keys.addrs.src,
+			       (__force u32)keys.ports.ports,
 			       q->bins[slot].perturbation);
 	if (!sfbhash)
 		sfbhash = 1;
@@ -356,9 +356,9 @@ static int sfb_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 	if (unlikely(p_min >= SFB_MAX_PROB)) {
 		/* Inelastic flow */
 		if (q->double_buffering) {
-			sfbhash = jhash_3words((__force u32)keys.dst,
-					       (__force u32)keys.src,
-					       (__force u32)keys.ports,
+			sfbhash = jhash_3words((__force u32)keys.addrs.dst,
+					       (__force u32)keys.addrs.src,
+					       (__force u32)keys.ports.ports,
 					       q->bins[slot].perturbation);
 			if (!sfbhash)
 				sfbhash = 1;
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index 91738e0..fa30425 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -176,9 +176,9 @@ static unsigned int sfq_hash(const struct sfq_sched_data *q,
 	const struct flow_keys *keys = &sfq_skb_cb(skb)->keys;
 	unsigned int hash;
 
-	hash = jhash_3words((__force u32)keys->dst,
-			    (__force u32)keys->src ^ keys->ip_proto,
-			    (__force u32)keys->ports, q->perturbation);
+	hash = jhash_3words((__force u32)keys->addrs.dst,
+			    (__force u32)keys->addrs.src ^ keys->basic.ip_proto,
+			    (__force u32)keys->ports.ports, q->perturbation);
 	return hash & (q->divisor - 1);
 }
 
@@ -197,7 +197,7 @@ static unsigned int sfq_classify(struct sk_buff *skb, struct Qdisc *sch,
 
 	fl = rcu_dereference_bh(q->filter_list);
 	if (!fl) {
-		skb_flow_dissect(skb, &sfq_skb_cb(skb)->keys);
+		skb_flow_dissect_flow_keys(skb, &sfq_skb_cb(skb)->keys);
 		return sfq_hash(q, skb) + 1;
 	}
 
-- 
1.9.3
