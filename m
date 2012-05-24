From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH 01/21] datapath: tunnelling: Replace tun_id with
	tun_key
Date: Thu, 24 May 2012 18:08:54 +0900
Message-ID: <1337850554-10339-2-git-send-email-horms@verge.net.au>
References: <1337850554-10339-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1337850554-10339-1-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

this is a first pass at providing a tun_key which can be used
as the basis for flow-based tunnelling. The tun_key includes and
replaces the tun_id in both struct ovs_skb_cb and struct sw_tun_key.

In ovs_skb_cb tun_key is a pointer as it is envisaged that it will grow
when support for IPv6 to an extent that inlining the structure will result
in ovs_skb_cb being larger than the 48 bytes available in skb->cb.

As OVS does not support IPv6 as the outer transport protocol for tunnels
the IPv6 portions of this change, which appeared in the previous revision,
have been dropped in order to limit the scope and size of this patch.

This patch does not make any effort to retain the existing tun_id behaviour
nor does it fully implement flow-based tunnels. As such it it is incomplete
and can't be used in its current form (other than to break OVS tunnelling).

** Please do not apply **

Cc: Kyle Mestery <kmestery-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>

---

v4
* Add tun_flags to ovs_key_ipv4_tunnel
* Correct format in format_odp_key_attr()

v3
* Rework, actually works in limited scenarios

v2
* Use pointer to struct ovs_key_ipv4_tunnel in OVS_CB()
  rather than having a struct ovs_key_ipv4_tunnel in OVS_CB()

v1
* Initial post
---
 datapath/actions.c          |  6 +++---
 datapath/datapath.c         | 10 +++++++++-
 datapath/datapath.h         |  5 +++--
 datapath/flow.c             | 34 +++++++++++++++++++++++-----------
 datapath/flow.h             | 27 +++++++++++++++++++++++----
 datapath/tunnel.c           | 24 +++++++++++++-----------
 datapath/tunnel.h           |  5 +++--
 datapath/vport-capwap.c     | 12 ++++++------
 datapath/vport-gre.c        | 21 +++++++++++----------
 datapath/vport.c            |  2 +-
 include/linux/openvswitch.h | 13 ++++++++++++-
 lib/dpif-netdev.c           |  1 +
 lib/odp-util.c              | 13 +++++++++++++
 lib/odp-util.h              |  5 +++--
 14 files changed, 124 insertions(+), 54 deletions(-)

diff --git a/datapath/actions.c b/datapath/actions.c
index 208f260..7b2ea25 100644
--- a/datapath/actions.c
+++ b/datapath/actions.c
@@ -342,8 +342,8 @@ static int execute_set_action(struct sk_buff *skb,
 		skb->priority = nla_get_u32(nested_attr);
 		break;
 
-	case OVS_KEY_ATTR_TUN_ID:
-		OVS_CB(skb)->tun_id = nla_get_be64(nested_attr);
+	case OVS_KEY_ATTR_IPV4_TUNNEL:
+		OVS_CB(skb)->tun_key = nla_data(nested_attr);
 		break;
 
 	case OVS_KEY_ATTR_ETHERNET:
@@ -469,7 +469,7 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb)
 		goto out_loop;
 	}
 
-	OVS_CB(skb)->tun_id = 0;
+	OVS_CB(skb)->tun_key = NULL;
 	error = do_execute_actions(dp, skb, acts->actions,
 					 acts->actions_len, false);
 
diff --git a/datapath/datapath.c b/datapath/datapath.c
index a4376a0..65dfe79 100644
--- a/datapath/datapath.c
+++ b/datapath/datapath.c
@@ -587,12 +587,20 @@ static int validate_set(const struct nlattr *a,
 
 	switch (key_type) {
 	const struct ovs_key_ipv4 *ipv4_key;
+	const struct ovs_key_ipv4_tunnel *tun_key;
 
 	case OVS_KEY_ATTR_PRIORITY:
 	case OVS_KEY_ATTR_TUN_ID:
 	case OVS_KEY_ATTR_ETHERNET:
 		break;
 
+	case OVS_KEY_ATTR_IPV4_TUNNEL:
+		tun_key = nla_data(ovs_key);
+		if (!tun_key->ipv4_dst) {
+			return -EINVAL;
+		}
+		break;
+
 	case OVS_KEY_ATTR_IPV4:
 		if (flow_key->eth.type != htons(ETH_P_IP))
 			return -EINVAL;
@@ -785,7 +793,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 
 	err = ovs_flow_metadata_from_nlattrs(&flow->key.phy.priority,
 					     &flow->key.phy.in_port,
-					     &flow->key.phy.tun_id,
+					     &flow->key.phy.tun_key,
 					     a[OVS_PACKET_ATTR_KEY]);
 	if (err)
 		goto err_flow_put;
diff --git a/datapath/datapath.h b/datapath/datapath.h
index affbf0e..de0b28d 100644
--- a/datapath/datapath.h
+++ b/datapath/datapath.h
@@ -96,7 +96,7 @@ struct datapath {
 /**
  * struct ovs_skb_cb - OVS data in skb CB
  * @flow: The flow associated with this packet.  May be %NULL if no flow.
- * @tun_id: ID of the tunnel that encapsulated this packet.  It is 0 if the
+ * @tun_key: Key for the tunnel that encapsulated this packet.
  * @ip_summed: Consistently stores L4 checksumming status across different
  * kernel versions.
  * @csum_start: Stores the offset from which to start checksumming independent
@@ -107,7 +107,7 @@ struct datapath {
  */
 struct ovs_skb_cb {
 	struct sw_flow		*flow;
-	__be64			tun_id;
+	struct ovs_key_ipv4_tunnel  *tun_key;
 #ifdef NEED_CSUM_NORMALIZE
 	enum csum_type		ip_summed;
 	u16			csum_start;
@@ -192,4 +192,5 @@ struct sk_buff *ovs_vport_cmd_build_info(struct vport *, u32 pid, u32 seq,
 					 u8 cmd);
 
 int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb);
+
 #endif /* datapath.h */
diff --git a/datapath/flow.c b/datapath/flow.c
index d07337c..49c0dd8 100644
--- a/datapath/flow.c
+++ b/datapath/flow.c
@@ -629,7 +629,8 @@ int ovs_flow_extract(struct sk_buff *skb, u16 in_port, struct sw_flow_key *key,
 	memset(key, 0, sizeof(*key));
 
 	key->phy.priority = skb->priority;
-	key->phy.tun_id = OVS_CB(skb)->tun_id;
+	if (OVS_CB(skb)->tun_key)
+		key->phy.tun_key = *OVS_CB(skb)->tun_key;
 	key->phy.in_port = in_port;
 
 	skb_reset_mac_header(skb);
@@ -847,6 +848,7 @@ const int ovs_key_lens[OVS_KEY_ATTR_MAX + 1] = {
 
 	/* Not upstream. */
 	[OVS_KEY_ATTR_TUN_ID] = sizeof(__be64),
+	[OVS_KEY_ATTR_IPV4_TUNNEL] = sizeof(struct ovs_key_ipv4_tunnel),
 };
 
 static int ipv4_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_len,
@@ -1022,9 +1024,11 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
 		swkey->phy.in_port = DP_MAX_PORTS;
 	}
 
-	if (attrs & (1ULL << OVS_KEY_ATTR_TUN_ID)) {
-		swkey->phy.tun_id = nla_get_be64(a[OVS_KEY_ATTR_TUN_ID]);
-		attrs &= ~(1ULL << OVS_KEY_ATTR_TUN_ID);
+	if (attrs & (1ULL << OVS_KEY_ATTR_IPV4_TUNNEL)) {
+		struct ovs_key_ipv4_tunnel *tun_key;
+		tun_key = nla_data(a[OVS_KEY_ATTR_IPV4_TUNNEL]);
+		swkey->phy.tun_key = *tun_key;
+		attrs &= ~(1ULL << OVS_KEY_ATTR_IPV4_TUNNEL);
 	}
 
 	/* Data attributes. */
@@ -1162,14 +1166,15 @@ int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
  * get the metadata, that is, the parts of the flow key that cannot be
  * extracted from the packet itself.
  */
-int ovs_flow_metadata_from_nlattrs(u32 *priority, u16 *in_port, __be64 *tun_id,
+int ovs_flow_metadata_from_nlattrs(u32 *priority, u16 *in_port,
+				   struct ovs_key_ipv4_tunnel *tun_key,
 				   const struct nlattr *attr)
 {
 	const struct nlattr *nla;
 	int rem;
 
 	*in_port = DP_MAX_PORTS;
-	*tun_id = 0;
+	tun_key->tun_id = 0;
 	*priority = 0;
 
 	nla_for_each_nested(nla, attr, rem) {
@@ -1184,8 +1189,9 @@ int ovs_flow_metadata_from_nlattrs(u32 *priority, u16 *in_port, __be64 *tun_id,
 				*priority = nla_get_u32(nla);
 				break;
 
-			case OVS_KEY_ATTR_TUN_ID:
-				*tun_id = nla_get_be64(nla);
+			case OVS_KEY_ATTR_IPV4_TUNNEL:
+				memcpy(tun_key, nla_data(nla),
+				       sizeof(*tun_key));
 				break;
 
 			case OVS_KEY_ATTR_IN_PORT:
@@ -1204,15 +1210,21 @@ int ovs_flow_metadata_from_nlattrs(u32 *priority, u16 *in_port, __be64 *tun_id,
 int ovs_flow_to_nlattrs(const struct sw_flow_key *swkey, struct sk_buff *skb)
 {
 	struct ovs_key_ethernet *eth_key;
+	struct ovs_key_ipv4_tunnel *tun_key;
 	struct nlattr *nla, *encap;
 
 	if (swkey->phy.priority &&
 	    nla_put_u32(skb, OVS_KEY_ATTR_PRIORITY, swkey->phy.priority))
 		goto nla_put_failure;
 
-	if (swkey->phy.tun_id != cpu_to_be64(0) &&
-	    nla_put_be64(skb, OVS_KEY_ATTR_TUN_ID, swkey->phy.tun_id))
-		goto nla_put_failure;
+	if (swkey->phy.tun_key.ipv4_dst) {
+		nla = nla_reserve(skb, OVS_KEY_ATTR_IPV4_TUNNEL,
+				  sizeof(*tun_key));
+		if (!nla)
+			goto nla_put_failure;
+		tun_key = nla_data(nla);
+		*tun_key = swkey->phy.tun_key;
+	}
 
 	if (swkey->phy.in_port != DP_MAX_PORTS &&
 	    nla_put_u32(skb, OVS_KEY_ATTR_IN_PORT, swkey->phy.in_port))
diff --git a/datapath/flow.h b/datapath/flow.h
index 5be481e..bab5363 100644
--- a/datapath/flow.h
+++ b/datapath/flow.h
@@ -42,7 +42,7 @@ struct sw_flow_actions {
 
 struct sw_flow_key {
 	struct {
-		__be64	tun_id;		/* Encapsulating tunnel ID. */
+		struct ovs_key_ipv4_tunnel tun_key;  /* Encapsulating tunnel key. */
 		u32	priority;	/* Packet QoS priority. */
 		u16	in_port;	/* Input switch port (or DP_MAX_PORTS). */
 	} phy;
@@ -150,6 +150,7 @@ u64 ovs_flow_used_time(unsigned long flow_jiffies);
  *                         ------  ---  ------  -----
  *  OVS_KEY_ATTR_PRIORITY      4    --     4      8
  *  OVS_KEY_ATTR_TUN_ID        8    --     4     12
+ *  OVS_KEY_ATTR_IPV4_TUNNEL  18     2     4     24
  *  OVS_KEY_ATTR_IN_PORT       4    --     4      8
  *  OVS_KEY_ATTR_ETHERNET     12    --     4     16
  *  OVS_KEY_ATTR_8021Q         4    --     4      8
@@ -158,14 +159,15 @@ u64 ovs_flow_used_time(unsigned long flow_jiffies);
  *  OVS_KEY_ATTR_ICMPV6        2     2     4      8
  *  OVS_KEY_ATTR_ND           28    --     4     32
  *  -------------------------------------------------
- *  total                                       144
+ *  total                                       168
  */
-#define FLOW_BUFSIZE 144
+#define FLOW_BUFSIZE 168
 
 int ovs_flow_to_nlattrs(const struct sw_flow_key *, struct sk_buff *);
 int ovs_flow_from_nlattrs(struct sw_flow_key *swkey, int *key_lenp,
 		      const struct nlattr *);
-int ovs_flow_metadata_from_nlattrs(u32 *priority, u16 *in_port, __be64 *tun_id,
+int ovs_flow_metadata_from_nlattrs(u32 *priority, u16 *in_port,
+				   struct ovs_key_ipv4_tunnel *tun_key,
 				   const struct nlattr *);
 
 #define MAX_ACTIONS_BUFSIZE	(16 * 1024)
@@ -204,4 +206,21 @@ u32 ovs_flow_hash(const struct sw_flow_key *key, int key_len);
 struct sw_flow *ovs_flow_tbl_next(struct flow_table *table, u32 *bucket, u32 *idx);
 extern const int ovs_key_lens[OVS_KEY_ATTR_MAX + 1];
 
+static inline void tun_key_swap_addr(struct ovs_key_ipv4_tunnel *tun_key)
+{
+	__be32 ndst = tun_key->ipv4_src;
+	tun_key->ipv4_src = tun_key->ipv4_dst;
+	tun_key->ipv4_dst = ndst;
+}
+
+static inline void tun_key_init(struct ovs_key_ipv4_tunnel *tun_key,
+				const struct iphdr *iph, __be64 tun_id)
+{
+	tun_key->tun_id = tun_id;
+	tun_key->ipv4_src = iph->saddr;
+	tun_key->ipv4_dst = iph->daddr;
+	tun_key->ipv4_tos = iph->tos;
+	tun_key->ipv4_ttl = iph->ttl;
+}
+
 #endif /* flow.h */
diff --git a/datapath/tunnel.c b/datapath/tunnel.c
index d651c11..010e513 100644
--- a/datapath/tunnel.c
+++ b/datapath/tunnel.c
@@ -367,9 +367,9 @@ struct vport *ovs_tnl_find_port(struct net *net, __be32 saddr, __be32 daddr,
 	return NULL;
 }
 
-static void ecn_decapsulate(struct sk_buff *skb, u8 tos)
+static void ecn_decapsulate(struct sk_buff *skb)
 {
-	if (unlikely(INET_ECN_is_ce(tos))) {
+	if (unlikely(INET_ECN_is_ce(OVS_CB(skb)->tun_key->ipv4_tos))) {
 		__be16 protocol = skb->protocol;
 
 		skb_set_network_header(skb, ETH_HLEN);
@@ -416,7 +416,7 @@ static void ecn_decapsulate(struct sk_buff *skb, u8 tos)
  * - skb->csum does not include the inner Ethernet header.
  * - The layer pointers are undefined.
  */
-void ovs_tnl_rcv(struct vport *vport, struct sk_buff *skb, u8 tos)
+void ovs_tnl_rcv(struct vport *vport, struct sk_buff *skb)
 {
 	struct ethhdr *eh;
 
@@ -433,7 +433,7 @@ void ovs_tnl_rcv(struct vport *vport, struct sk_buff *skb, u8 tos)
 	skb_clear_rxhash(skb);
 	secpath_reset(skb);
 
-	ecn_decapsulate(skb, tos);
+	ecn_decapsulate(skb);
 	vlan_set_tci(skb, 0);
 
 	if (unlikely(compute_ip_summed(skb, false))) {
@@ -613,12 +613,14 @@ static void ipv6_build_icmp(struct sk_buff *skb, struct sk_buff *nskb,
 
 bool ovs_tnl_frag_needed(struct vport *vport,
 			 const struct tnl_mutable_config *mutable,
-			 struct sk_buff *skb, unsigned int mtu, __be64 flow_key)
+			 struct sk_buff *skb, unsigned int mtu,
+			 struct ovs_key_ipv4_tunnel *tun_key)
 {
 	unsigned int eth_hdr_len = ETH_HLEN;
 	unsigned int total_length = 0, header_length = 0, payload_length;
 	struct ethhdr *eh, *old_eh = eth_hdr(skb);
 	struct sk_buff *nskb;
+	struct ovs_key_ipv4_tunnel ntun_key;
 
 	/* Sanity check */
 	if (skb->protocol == htons(ETH_P_IP)) {
@@ -705,8 +707,10 @@ bool ovs_tnl_frag_needed(struct vport *vport,
 	 * any way of synthesizing packets.
 	 */
 	if ((mutable->flags & (TNL_F_IN_KEY_MATCH | TNL_F_OUT_KEY_ACTION)) ==
-	    (TNL_F_IN_KEY_MATCH | TNL_F_OUT_KEY_ACTION))
-		OVS_CB(nskb)->tun_id = flow_key;
+	    (TNL_F_IN_KEY_MATCH | TNL_F_OUT_KEY_ACTION)) {
+		ntun_key = *tun_key;
+		OVS_CB(nskb)->tun_key = &ntun_key;
+	}
 
 	if (unlikely(compute_ip_summed(nskb, false))) {
 		kfree_skb(nskb);
@@ -761,7 +765,7 @@ static bool check_mtu(struct sk_buff *skb,
 
 			if (packet_length > mtu &&
 			    ovs_tnl_frag_needed(vport, mutable, skb, mtu,
-						OVS_CB(skb)->tun_id))
+						OVS_CB(skb)->tun_key))
 				return false;
 		}
 	}
@@ -778,7 +782,7 @@ static bool check_mtu(struct sk_buff *skb,
 
 			if (packet_length > mtu &&
 			    ovs_tnl_frag_needed(vport, mutable, skb, mtu,
-						OVS_CB(skb)->tun_id))
+						OVS_CB(skb)->tun_key))
 				return false;
 		}
 	}
@@ -799,10 +803,8 @@ static void create_tunnel_header(const struct vport *vport,
 	iph->ihl	= sizeof(struct iphdr) >> 2;
 	iph->frag_off	= htons(IP_DF);
 	iph->protocol	= tnl_vport->tnl_ops->ipproto;
-	iph->tos	= mutable->tos;
 	iph->daddr	= rt->rt_dst;
 	iph->saddr	= rt->rt_src;
-	iph->ttl	= mutable->ttl;
 	if (!iph->ttl)
 		iph->ttl = ip4_dst_hoplimit(&rt_dst(rt));
 
diff --git a/datapath/tunnel.h b/datapath/tunnel.h
index 1924017..7d78297 100644
--- a/datapath/tunnel.h
+++ b/datapath/tunnel.h
@@ -269,14 +269,15 @@ int ovs_tnl_set_addr(struct vport *vport, const unsigned char *addr);
 const char *ovs_tnl_get_name(const struct vport *vport);
 const unsigned char *ovs_tnl_get_addr(const struct vport *vport);
 int ovs_tnl_send(struct vport *vport, struct sk_buff *skb);
-void ovs_tnl_rcv(struct vport *vport, struct sk_buff *skb, u8 tos);
+void ovs_tnl_rcv(struct vport *vport, struct sk_buff *skb);
 
 struct vport *ovs_tnl_find_port(struct net *net, __be32 saddr, __be32 daddr,
 				__be64 key, int tunnel_type,
 				const struct tnl_mutable_config **mutable);
 bool ovs_tnl_frag_needed(struct vport *vport,
 			 const struct tnl_mutable_config *mutable,
-			 struct sk_buff *skb, unsigned int mtu, __be64 flow_key);
+			 struct sk_buff *skb, unsigned int mtu,
+			 struct ovs_key_ipv4_tunnel *tun_key);
 void ovs_tnl_free_linked_skbs(struct sk_buff *skb);
 
 int ovs_tnl_init(void);
diff --git a/datapath/vport-capwap.c b/datapath/vport-capwap.c
index 05a099d..1e08d5a 100644
--- a/datapath/vport-capwap.c
+++ b/datapath/vport-capwap.c
@@ -220,7 +220,7 @@ static struct sk_buff *capwap_update_header(const struct vport *vport,
 		struct capwaphdr_wsi *wsi = (struct capwaphdr_wsi *)(cwh + 1);
 		struct capwaphdr_wsi_key *opt = (struct capwaphdr_wsi_key *)(wsi + 1);
 
-		opt->key = OVS_CB(skb)->tun_id;
+		opt->key = OVS_CB(skb)->tun_key->tun_id;
 	}
 
 	udph->len = htons(skb->len - skb_transport_offset(skb));
@@ -316,6 +316,7 @@ static int capwap_rcv(struct sock *sk, struct sk_buff *skb)
 	struct vport *vport;
 	const struct tnl_mutable_config *mutable;
 	struct iphdr *iph;
+	struct ovs_key_ipv4_tunnel tun_key;
 	__be64 key = 0;
 
 	if (unlikely(!pskb_may_pull(skb, CAPWAP_MIN_HLEN + ETH_HLEN)))
@@ -333,12 +334,11 @@ static int capwap_rcv(struct sock *sk, struct sk_buff *skb)
 		goto error;
 	}
 
-	if (mutable->flags & TNL_F_IN_KEY_MATCH)
-		OVS_CB(skb)->tun_id = key;
-	else
-		OVS_CB(skb)->tun_id = 0;
+	tun_key_init(&tun_key, iph,
+		     mutable->flags & TNL_F_IN_KEY_MATCH ? key : 0);
+	OVS_CB(skb)->tun_key = &tun_key;
 
-	ovs_tnl_rcv(vport, skb, iph->tos);
+	ovs_tnl_rcv(vport, skb);
 	goto out;
 
 error:
diff --git a/datapath/vport-gre.c b/datapath/vport-gre.c
index ab89c5b..fd2b038 100644
--- a/datapath/vport-gre.c
+++ b/datapath/vport-gre.c
@@ -101,10 +101,6 @@ static struct sk_buff *gre_update_header(const struct vport *vport,
 	__be32 *options = (__be32 *)(skb_network_header(skb) + mutable->tunnel_hlen
 					       - GRE_HEADER_SECTION);
 
-	/* Work backwards over the options so the checksum is last. */
-	if (mutable->flags & TNL_F_OUT_KEY_ACTION)
-		*options = be64_get_low32(OVS_CB(skb)->tun_id);
-
 	if (mutable->out_key || mutable->flags & TNL_F_OUT_KEY_ACTION)
 		options--;
 
@@ -285,7 +281,11 @@ static void gre_err(struct sk_buff *skb, u32 info)
 #endif
 
 	__skb_pull(skb, tunnel_hdr_len);
-	ovs_tnl_frag_needed(vport, mutable, skb, mtu, key);
+	{
+		struct ovs_key_ipv4_tunnel tun_key;
+		tun_key_init(&tun_key, iph, key);
+		ovs_tnl_frag_needed(vport, mutable, skb, mtu, &tun_key);
+	}
 	__skb_push(skb, tunnel_hdr_len);
 
 out:
@@ -327,6 +327,7 @@ static int gre_rcv(struct sk_buff *skb)
 	const struct tnl_mutable_config *mutable;
 	int hdr_len;
 	struct iphdr *iph;
+	struct ovs_key_ipv4_tunnel tun_key;
 	__be16 flags;
 	__be64 key;
 
@@ -351,15 +352,15 @@ static int gre_rcv(struct sk_buff *skb)
 		goto error;
 	}
 
-	if (mutable->flags & TNL_F_IN_KEY_MATCH)
-		OVS_CB(skb)->tun_id = key;
-	else
-		OVS_CB(skb)->tun_id = 0;
+
+	tun_key_init(&tun_key, iph,
+		     mutable->flags & TNL_F_IN_KEY_MATCH ? key : 0);
+	OVS_CB(skb)->tun_key = &tun_key;
 
 	__skb_pull(skb, hdr_len);
 	skb_postpull_rcsum(skb, skb_transport_header(skb), hdr_len + ETH_HLEN);
 
-	ovs_tnl_rcv(vport, skb, iph->tos);
+	ovs_tnl_rcv(vport, skb);
 	return 0;
 
 error:
diff --git a/datapath/vport.c b/datapath/vport.c
index 172261a..0c77a1b 100644
--- a/datapath/vport.c
+++ b/datapath/vport.c
@@ -462,7 +462,7 @@ void ovs_vport_receive(struct vport *vport, struct sk_buff *skb)
 		OVS_CB(skb)->flow = NULL;
 
 	if (!(vport->ops->flags & VPORT_F_TUN_ID))
-		OVS_CB(skb)->tun_id = 0;
+		OVS_CB(skb)->tun_key = NULL;
 
 	ovs_dp_process_received_packet(vport, skb);
 }
diff --git a/include/linux/openvswitch.h b/include/linux/openvswitch.h
index f5c9cca..c32bb58 100644
--- a/include/linux/openvswitch.h
+++ b/include/linux/openvswitch.h
@@ -278,7 +278,8 @@ enum ovs_key_attr {
 	OVS_KEY_ATTR_ICMPV6,    /* struct ovs_key_icmpv6 */
 	OVS_KEY_ATTR_ARP,       /* struct ovs_key_arp */
 	OVS_KEY_ATTR_ND,        /* struct ovs_key_nd */
-	OVS_KEY_ATTR_TUN_ID = 63, /* be64 tunnel ID */
+	OVS_KEY_ATTR_TUN_ID,    /* be64 tunnel ID */
+	OVS_KEY_ATTR_IPV4_TUNNEL,  /* struct ovs_key_ipv4_tunnel */
 	__OVS_KEY_ATTR_MAX
 };
 
@@ -360,6 +361,16 @@ struct ovs_key_nd {
 	__u8  nd_tll[6];
 };
 
+struct ovs_key_ipv4_tunnel {
+	__be64 tun_id;
+	__u32  tun_flags;
+	__be32 ipv4_src;
+	__be32 ipv4_dst;
+	__u8   ipv4_tos;
+	__u8   ipv4_ttl;
+	__u8   pad[2];
+};
+
 /**
  * enum ovs_flow_attr - attributes for %OVS_FLOW_* commands.
  * @OVS_FLOW_ATTR_KEY: Nested %OVS_KEY_ATTR_* attributes specifying the flow
diff --git a/lib/dpif-netdev.c b/lib/dpif-netdev.c
index fb0a863..d065a3a 100644
--- a/lib/dpif-netdev.c
+++ b/lib/dpif-netdev.c
@@ -1165,6 +1165,7 @@ execute_set_action(struct ofpbuf *packet, const struct nlattr *a)
     case OVS_KEY_ATTR_TUN_ID:
     case OVS_KEY_ATTR_PRIORITY:
     case OVS_KEY_ATTR_IPV6:
+    case OVS_KEY_ATTR_IPV4_TUNNEL:
         /* not implemented */
         break;
 
diff --git a/lib/odp-util.c b/lib/odp-util.c
index 8693d3c..23d1efe 100644
--- a/lib/odp-util.c
+++ b/lib/odp-util.c
@@ -106,6 +106,7 @@ ovs_key_attr_to_string(enum ovs_key_attr attr)
     case OVS_KEY_ATTR_ARP: return "arp";
     case OVS_KEY_ATTR_ND: return "nd";
     case OVS_KEY_ATTR_TUN_ID: return "tun_id";
+    case OVS_KEY_ATTR_IPV4_TUNNEL: return "ipv4_tunnel";
 
     case __OVS_KEY_ATTR_MAX:
     default:
@@ -614,6 +615,7 @@ odp_flow_key_attr_len(uint16_t type)
     case OVS_KEY_ATTR_ICMPV6: return sizeof(struct ovs_key_icmpv6);
     case OVS_KEY_ATTR_ARP: return sizeof(struct ovs_key_arp);
     case OVS_KEY_ATTR_ND: return sizeof(struct ovs_key_nd);
+    case OVS_KEY_ATTR_IPV4_TUNNEL: return sizeof(struct ovs_key_ipv4_tunnel);
 
     case OVS_KEY_ATTR_UNSPEC:
     case __OVS_KEY_ATTR_MAX:
@@ -668,6 +670,7 @@ format_odp_key_attr(const struct nlattr *a, struct ds *ds)
     const struct ovs_key_icmpv6 *icmpv6_key;
     const struct ovs_key_arp *arp_key;
     const struct ovs_key_nd *nd_key;
+    const struct ovs_key_ipv4_tunnel *ipv4_tun_key;
     enum ovs_key_attr attr = nl_attr_type(a);
     int expected_len;
 
@@ -698,6 +701,16 @@ format_odp_key_attr(const struct nlattr *a, struct ds *ds)
         ds_put_format(ds, "(%#"PRIx64")", ntohll(nl_attr_get_be64(a)));
         break;
 
+    case OVS_KEY_ATTR_IPV4_TUNNEL:
+        ipv4_tun_key = nl_attr_get(a);
+        ds_put_format(ds, "(tun_id=%"PRIx64",flags=%"PRIx32
+                      ",src="IP_FMT",dst="IP_FMT",tos=%"PRIx8",ttl=%"PRIu8")",
+                      ntohll(ipv4_tun_key->tun_id), ipv4_tun_key->tun_flags,
+                      IP_ARGS(&ipv4_tun_key->ipv4_src),
+                      IP_ARGS(&ipv4_tun_key->ipv4_dst),
+                      ipv4_tun_key->ipv4_tos, ipv4_tun_key->ipv4_ttl);
+        break;
+
     case OVS_KEY_ATTR_IN_PORT:
         ds_put_format(ds, "(%"PRIu32")", nl_attr_get_u32(a));
         break;
diff --git a/lib/odp-util.h b/lib/odp-util.h
index d53f083..4e5a8a1 100644
--- a/lib/odp-util.h
+++ b/lib/odp-util.h
@@ -72,6 +72,7 @@ int odp_actions_from_string(const char *, const struct simap *port_names,
  *                         ------  ---  ------  -----
  *  OVS_KEY_ATTR_PRIORITY      4    --     4      8
  *  OVS_KEY_ATTR_TUN_ID        8    --     4     12
+ *  OVS_KEY_ATTR_IPV4_TUNNEL  18     2     4     24
  *  OVS_KEY_ATTR_IN_PORT       4    --     4      8
  *  OVS_KEY_ATTR_ETHERNET     12    --     4     16
  *  OVS_KEY_ATTR_8021Q         4    --     4      8
@@ -80,9 +81,9 @@ int odp_actions_from_string(const char *, const struct simap *port_names,
  *  OVS_KEY_ATTR_ICMPV6        2     2     4      8
  *  OVS_KEY_ATTR_ND           28    --     4     32
  *  -------------------------------------------------
- *  total                                       144
+ *  total                                       168
  */
-#define ODPUTIL_FLOW_KEY_BYTES 144
+#define ODPUTIL_FLOW_KEY_BYTES 168
 
 /* A buffer with sufficient size and alignment to hold an nlattr-formatted flow
  * key.  An array of "struct nlattr" might not, in theory, be sufficiently
-- 
1.7.10.2.484.gcd07cc5
