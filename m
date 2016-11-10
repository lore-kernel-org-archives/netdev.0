From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v13 2/8] openvswitch: add mac_proto field to the flow key
Date: Thu, 10 Nov 2016 16:28:18 +0100
Message-ID: <0324efb801d89db335ea60ba499af7e214070750.1478791347.git.jbenc@redhat.com>
References: <cover.1478791347.git.jbenc@redhat.com>
Cc: dev@openvswitch.org, Pravin Shelar <pshelar@ovn.org>,
        Lorand Jakab <lojakab@cisco.com>,
        Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43988 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933482AbcKJP2t (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 10:28:49 -0500
In-Reply-To: <cover.1478791347.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use a hole in the structure. We support only Ethernet so far and will add
a support for L2-less packets shortly. We could use a bool to indicate
whether the Ethernet header is present or not but the approach with the
mac_proto field is more generic and occupies the same number of bytes in the
struct, while allowing later extensibility. It also makes the code in the
next patches more self explaining.

It would be nice to use ARPHRD_ constants but those are u16 which would be
waste. Thus define our own constants.

Another upside of this is that we can overload this new field to also denote
whether the flow key is valid. This has the advantage that on
refragmentation, we don't have to reparse the packet but can rely on the
stored eth.type. This is especially important for the next patches in this
series - instead of adding another branch for L2-less packets before calling
ovs_fragment, we can just remove all those branches completely.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
Acked-by: Pravin B Shelar <pshelar@ovn.org>
---
 net/openvswitch/actions.c      | 14 +++-----------
 net/openvswitch/flow.c         |  1 +
 net/openvswitch/flow.h         | 22 ++++++++++++++++++++++
 net/openvswitch/flow_netlink.c |  5 +++++
 4 files changed, 31 insertions(+), 11 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 49af167105d3..44144f914920 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -137,12 +137,12 @@ static struct deferred_action *add_deferred_actions(struct sk_buff *skb,
 
 static void invalidate_flow_key(struct sw_flow_key *key)
 {
-	key->eth.type = htons(0);
+	key->mac_proto |= SW_FLOW_KEY_INVALID;
 }
 
 static bool is_flow_key_valid(const struct sw_flow_key *key)
 {
-	return !!key->eth.type;
+	return !(key->mac_proto & SW_FLOW_KEY_INVALID);
 }
 
 static void update_ethertype(struct sk_buff *skb, struct ethhdr *hdr,
@@ -796,16 +796,8 @@ static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port,
 			ovs_vport_send(vport, skb);
 		} else if (mru <= vport->dev->mtu) {
 			struct net *net = read_pnet(&dp->net);
-			__be16 ethertype = key->eth.type;
 
-			if (!is_flow_key_valid(key)) {
-				if (eth_p_mpls(skb->protocol))
-					ethertype = skb->inner_protocol;
-				else
-					ethertype = vlan_get_protocol(skb);
-			}
-
-			ovs_fragment(net, vport, skb, mru, ethertype);
+			ovs_fragment(net, vport, skb, mru, key->eth.type);
 		} else {
 			kfree_skb(skb);
 		}
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 22087062bd10..96c8c4716603 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -751,6 +751,7 @@ int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
 	key->phy.skb_mark = skb->mark;
 	ovs_ct_fill_key(skb, key);
 	key->ovs_flow_hash = 0;
+	key->mac_proto = MAC_PROTO_ETHERNET;
 	key->recirc_id = 0;
 
 	return key_extract(skb, key);
diff --git a/net/openvswitch/flow.h b/net/openvswitch/flow.h
index ae783f5c6695..f61cae7f9030 100644
--- a/net/openvswitch/flow.h
+++ b/net/openvswitch/flow.h
@@ -37,6 +37,12 @@
 
 struct sk_buff;
 
+enum sw_flow_mac_proto {
+	MAC_PROTO_NONE = 0,
+	MAC_PROTO_ETHERNET,
+};
+#define SW_FLOW_KEY_INVALID	0x80
+
 /* Store options at the end of the array if they are less than the
  * maximum size. This allows us to get the benefits of variable length
  * matching for small options.
@@ -68,6 +74,7 @@ struct sw_flow_key {
 		u32	skb_mark;	/* SKB mark. */
 		u16	in_port;	/* Input switch port (or DP_MAX_PORTS). */
 	} __packed phy; /* Safe when right after 'tun_key'. */
+	u8 mac_proto;			/* MAC layer protocol (e.g. Ethernet). */
 	u8 tun_proto;			/* Protocol of encapsulating tunnel. */
 	u32 ovs_flow_hash;		/* Datapath computed hash value.  */
 	u32 recirc_id;			/* Recirculation ID.  */
@@ -206,6 +213,21 @@ struct arp_eth_header {
 	unsigned char       ar_tip[4];		/* target IP address        */
 } __packed;
 
+static inline u8 ovs_key_mac_proto(const struct sw_flow_key *key)
+{
+	return key->mac_proto & ~SW_FLOW_KEY_INVALID;
+}
+
+static inline u16 __ovs_mac_header_len(u8 mac_proto)
+{
+	return mac_proto == MAC_PROTO_ETHERNET ? ETH_HLEN : 0;
+}
+
+static inline u16 ovs_mac_header_len(const struct sw_flow_key *key)
+{
+	return __ovs_mac_header_len(ovs_key_mac_proto(key));
+}
+
 static inline bool ovs_identifier_is_ufid(const struct sw_flow_id *sfid)
 {
 	return sfid->ufid_len;
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index ae25ded82b3b..ccb9900c5230 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -1059,6 +1059,11 @@ static int metadata_from_nlattrs(struct net *net, struct sw_flow_match *match,
 				   sizeof(*cl), is_mask);
 		*attrs &= ~(1ULL << OVS_KEY_ATTR_CT_LABELS);
 	}
+
+	/* Always exact match mac_proto */
+	SW_FLOW_KEY_PUT(match, mac_proto, is_mask ? 0xff : MAC_PROTO_ETHERNET,
+			is_mask);
+
 	return 0;
 }
 
-- 
1.8.3.1
