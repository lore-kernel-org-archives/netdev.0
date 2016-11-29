From: Jarno Rajahalme <jarno@ovn.org>
Subject: [PATCH v2 net-next 2/2] openvswitch: Fix skb->protocol for vlan frames.
Date: Mon, 28 Nov 2016 18:41:16 -0800
Message-ID: <1480387276-123557-2-git-send-email-jarno@ovn.org>
References: <1480387276-123557-1-git-send-email-jarno@ovn.org>
Cc: jbenc@redhat.com, jarno@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:58930 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751347AbcK2Clh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 21:41:37 -0500
In-Reply-To: <1480387276-123557-1-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not set skb->protocol to be the ethertype of the L3 header, unless
the packet only has the L3 header.  For a non-hardware offloaded VLAN
frame skb->protocol needs to be one of the VLAN ethertypes.

Any VLAN offloading is undone on the OVS netlink interface.  Also any
VLAN tags added by userspace are non-offloaded.

Incorrect skb->protocol value on a full-size non-offloaded VLAN skb
causes packet drop due to failing MTU check, as the VLAN header should
not be counted in when considering MTU in ovs_vport_send().

Fixes: 5108bbaddc ("openvswitch: add processing of L3 packets")
Signed-off-by: Jarno Rajahalme <jarno@ovn.org>
---
v2: Set skb->protocol when an ETH_P_TEB frame is received via ARPHRD_NONE
    interface.

 net/openvswitch/datapath.c |  1 -
 net/openvswitch/flow.c     | 30 ++++++++++++++++++++++--------
 2 files changed, 22 insertions(+), 9 deletions(-)

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
index 08aa926..b9aae99 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -477,12 +477,17 @@ static int parse_icmpv6(struct sk_buff *skb, struct sw_flow_key *key,
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
+ * 'key->mac_proto' must be initialized to indicate the frame type.
+ * For an L3 frame 'key->mac_proto' must equal 'MAC_PROTO_NONE', and the
+ * caller must ensure that 'skb->protocol' is set to the ethertype of the L3
+ * header.  Otherwise the presence of an Ethernet header is assumed and
+ * the caller must ensure that skb->len >= ETH_HLEN.
  *
  * Returns 0 if successful, otherwise a negative errno value.
  *
@@ -498,8 +503,9 @@ static int parse_icmpv6(struct sk_buff *skb, struct sw_flow_key *key,
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
@@ -518,6 +524,7 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 			return -EINVAL;
 
 		skb_reset_network_header(skb);
+		key->eth.type = skb->protocol;
 	} else {
 		eth = eth_hdr(skb);
 		ether_addr_copy(key->eth.src, eth->h_source);
@@ -531,15 +538,22 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 		if (unlikely(parse_vlan(skb, key)))
 			return -ENOMEM;
 
-		skb->protocol = parse_ethertype(skb);
-		if (unlikely(skb->protocol == htons(0)))
+		key->eth.type = parse_ethertype(skb);
+		if (unlikely(key->eth.type == htons(0)))
 			return -ENOMEM;
 
+		if (skb->protocol == htons(ETH_P_TEB)) {
+			if (key->eth.vlan.tci & htons(VLAN_TAG_PRESENT)
+			    && !skb_vlan_tag_present(skb))
+				skb->protocol = key->eth.vlan.tpid;
+			else
+				skb->protocol = key->eth.type;
+		}
+
 		skb_reset_network_header(skb);
 		__skb_push(skb, skb->data - skb_mac_header(skb));
 	}
 	skb_reset_mac_len(skb);
-	key->eth.type = skb->protocol;
 
 	/* Network layer. */
 	if (key->eth.type == htons(ETH_P_IP)) {
-- 
2.1.4
