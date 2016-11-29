From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH v3 net-next 3/3] openvswitch: Fix skb->protocol for vlan frames.
Date: Tue, 29 Nov 2016 15:30:53 -0800
Message-ID: <1480462253-114713-3-git-send-email-jarno@ovn.org>
References: <1480462253-114713-1-git-send-email-jarno@ovn.org>
Cc: jarno@ovn.org, jbenc@redhat.com, pshelar@ovn.org, e@erig.me
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:58167 "EHLO
        relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754872AbcK2XbO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 18:31:14 -0500
In-Reply-To: <1480462253-114713-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not always set skb->protocol to be the ethertype of the L3 header.
For a packet with non-accelerated VLAN tags skb->protocol needs to be
the ethertype of the outermost non-accelerated VLAN ethertype.

Any VLAN offloading is undone on the OVS netlink interface, and any
VLAN tags added by userspace are non-accelerated, as are double tagged
VLAN packets.

Fixes: 018c1dda5f ("openvswitch: 802.1AD Flow handling, actions, vlan parsing, netlink attributes")
Fixes: 5108bbaddc ("openvswitch: add processing of L3 packets")
Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
v3: Set skb->protocol properly also for double tagged packets, as suggested
    by Pravin.  This patch is no longer needed for the MTU test failure, as
    the new patch 2/3 addresses that.

 net/openvswitch/datapath.c |  1 -
 net/openvswitch/flow.c     | 62 +++++++++++++++++++++++-----------------------
 2 files changed, 31 insertions(+), 32 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 2d4c4d3..9c62b63 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -606,7 +606,6 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	rcu_assign_pointer(flow->sf_acts, acts);
 	packet->priority = flow->key.phy.priority;
 	packet->mark = flow->key.phy.skb_mark;
-	packet->protocol = flow->key.eth.type;
 
 	rcu_read_lock();
 	dp = get_dp_rcu(net, ovs_header->dp_ifindex);
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 08aa926..e2fe2e5 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -354,6 +354,7 @@ static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
 		res = parse_vlan_tag(skb, &key->eth.vlan);
 		if (res <= 0)
 			return res;
+		skb->protocol = key->eth.vlan.tpid;
 	}
 
 	/* Parse inner vlan tag. */
@@ -361,6 +362,11 @@ static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
 	if (res <= 0)
 		return res;
 
+	/* If the outer vlan tag was accelerated, skb->protocol should
+	 * refelect the inner vlan type. */
+	if (!eth_type_vlan(skb->protocol))
+		skb->protocol = key->eth.cvlan.tpid;
+
 	return 0;
 }
 
@@ -477,12 +483,18 @@ static int parse_icmpv6(struct sk_buff *skb, struct sw_flow_key *key,
 }
 
 /**
- * key_extract - extracts a flow key from an Ethernet frame.
+ * key_extract - extracts a flow key from a packet with or without an
+ * Ethernet header.
  * @skb: sk_buff that contains the frame, with skb->data pointing to the
- * Ethernet header
+ * beginning of the packet.
  * @key: output flow key
  *
- * The caller must ensure that skb->len >= ETH_HLEN.
+ * 'key->mac_proto' must be initialized to indicate the frame type.  For an L3
+ * frame 'key->mac_proto' must equal 'MAC_PROTO_NONE', and the caller must
+ * ensure that 'skb->protocol' is set to the ethertype of the L3 header.
+ * Otherwise the presence of an Ethernet header is assumed and the caller must
+ * ensure that skb->len >= ETH_HLEN and that 'skb->protocol' is initialized to
+ * zero.
  *
  * Returns 0 if successful, otherwise a negative errno value.
  *
@@ -498,8 +510,9 @@ static int parse_icmpv6(struct sk_buff *skb, struct sw_flow_key *key,
  *      of a correct length, otherwise the same as skb->network_header.
  *      For other key->eth.type values it is left untouched.
  *
- *    - skb->protocol: the type of the data starting at skb->network_header.
- *      Equals to key->eth.type.
+ *    - skb->protocol: For non-accelerated VLAN, one of the VLAN ether types,
+ *      otherwise the same as key->eth.type, the ether type of the payload
+ *      starting at skb->network_header.
  */
 static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 {
@@ -531,15 +544,16 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 		if (unlikely(parse_vlan(skb, key)))
 			return -ENOMEM;
 
-		skb->protocol = parse_ethertype(skb);
-		if (unlikely(skb->protocol == htons(0)))
+		key->eth.type = parse_ethertype(skb);
+		if (unlikely(key->eth.type == htons(0)))
 			return -ENOMEM;
 
 		skb_reset_network_header(skb);
 		__skb_push(skb, skb->data - skb_mac_header(skb));
 	}
 	skb_reset_mac_len(skb);
-	key->eth.type = skb->protocol;
+	if (!eth_type_vlan(skb->protocol))
+		skb->protocol = key->eth.type;
 
 	/* Network layer. */
 	if (key->eth.type == htons(ETH_P_IP)) {
@@ -800,29 +814,15 @@ int ovs_flow_key_extract_userspace(struct net *net, const struct nlattr *attr,
 	if (err)
 		return err;
 
-	if (ovs_key_mac_proto(key) == MAC_PROTO_NONE) {
-		/* key_extract assumes that skb->protocol is set-up for
-		 * layer 3 packets which is the case for other callers,
-		 * in particular packets recieved from the network stack.
-		 * Here the correct value can be set from the metadata
-		 * extracted above.
-		 */
-		skb->protocol = key->eth.type;
-	} else {
-		struct ethhdr *eth;
-
-		skb_reset_mac_header(skb);
-		eth = eth_hdr(skb);
-
-		/* Normally, setting the skb 'protocol' field would be
-		 * handled by a call to eth_type_trans(), but it assumes
-		 * there's a sending device, which we may not have.
-		 */
-		if (eth_proto_is_802_3(eth->h_proto))
-			skb->protocol = eth->h_proto;
-		else
-			skb->protocol = htons(ETH_P_802_2);
-	}
+	/* key_extract assumes that skb->protocol is set-up for
+	 * layer 3 packets which is the case for other callers,
+	 * in particular packets recieved from the network stack.
+	 * Here the correct value can be set from the metadata
+	 * extracted above.  For layer 2 packets we initialize
+         * skb->protocol to zero and set it in key_extract() while
+         * parsing the L2 headers.
+	 */
+	skb->protocol = key->eth.type;
 
 	return key_extract(skb, key);
 }
-- 
2.1.4
