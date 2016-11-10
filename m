From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v13 5/8] openvswitch: add processing of L3 packets
Date: Thu, 10 Nov 2016 16:28:21 +0100
Message-ID: <05254a13fdb29c1c3eaa1840ba2d127d98f8c418.1478791347.git.jbenc@redhat.com>
References: <cover.1478791347.git.jbenc@redhat.com>
Cc: dev@openvswitch.org, Pravin Shelar <pshelar@ovn.org>,
        Lorand Jakab <lojakab@cisco.com>,
        Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33098 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934215AbcKJP2y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 10:28:54 -0500
In-Reply-To: <cover.1478791347.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support receiving, extracting flow key and sending of L3 packets (packets
without an Ethernet header).

Note that even after this patch, non-Ethernet interfaces are still not
allowed to be added to bridges. Similarly, netlink interface for sending and
receiving L3 packets to/from user space is not in place yet.

Based on previous versions by Lorand Jakab and Simon Horman.

Signed-off-by: Lorand Jakab <lojakab@cisco.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
v13:
- fix incorrect setting of packet to NULL in ovs_packet_cmd_execute
- dropping packet for interfaces with wrong type
---
 net/openvswitch/datapath.c |  13 +-----
 net/openvswitch/flow.c     | 106 ++++++++++++++++++++++++++++++++++-----------
 net/openvswitch/vport.c    |  19 ++++++++
 3 files changed, 101 insertions(+), 37 deletions(-)

diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index fa8760176b7d..1402f1be642d 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -560,7 +560,6 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	struct sw_flow *flow;
 	struct sw_flow_actions *sf_acts;
 	struct datapath *dp;
-	struct ethhdr *eth;
 	struct vport *input_vport;
 	u16 mru = 0;
 	int len;
@@ -581,17 +580,6 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 
 	nla_memcpy(__skb_put(packet, len), a[OVS_PACKET_ATTR_PACKET], len);
 
-	skb_reset_mac_header(packet);
-	eth = eth_hdr(packet);
-
-	/* Normally, setting the skb 'protocol' field would be handled by a
-	 * call to eth_type_trans(), but it assumes there's a sending
-	 * device, which we may not have. */
-	if (eth_proto_is_802_3(eth->h_proto))
-		packet->protocol = eth->h_proto;
-	else
-		packet->protocol = htons(ETH_P_802_2);
-
 	/* Set packet's mru */
 	if (a[OVS_PACKET_ATTR_MRU]) {
 		mru = nla_get_u16(a[OVS_PACKET_ATTR_MRU]);
@@ -618,6 +606,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	rcu_assign_pointer(flow->sf_acts, acts);
 	packet->priority = flow->key.phy.priority;
 	packet->mark = flow->key.phy.skb_mark;
+	packet->protocol = flow->key.eth.type;
 
 	rcu_read_lock();
 	dp = get_dp_rcu(net, ovs_header->dp_ifindex);
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 96c8c4716603..08aa926cd5cf 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -334,14 +334,17 @@ static int parse_vlan_tag(struct sk_buff *skb, struct vlan_head *key_vh)
 	return 1;
 }
 
-static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
+static void clear_vlan(struct sw_flow_key *key)
 {
-	int res;
-
 	key->eth.vlan.tci = 0;
 	key->eth.vlan.tpid = 0;
 	key->eth.cvlan.tci = 0;
 	key->eth.cvlan.tpid = 0;
+}
+
+static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
+{
+	int res;
 
 	if (skb_vlan_tag_present(skb)) {
 		key->eth.vlan.tci = htons(skb->vlan_tci);
@@ -483,17 +486,20 @@ static int parse_icmpv6(struct sk_buff *skb, struct sw_flow_key *key,
  *
  * Returns 0 if successful, otherwise a negative errno value.
  *
- * Initializes @skb header pointers as follows:
+ * Initializes @skb header fields as follows:
  *
- *    - skb->mac_header: the Ethernet header.
+ *    - skb->mac_header: the L2 header.
  *
- *    - skb->network_header: just past the Ethernet header, or just past the
- *      VLAN header, to the first byte of the Ethernet payload.
+ *    - skb->network_header: just past the L2 header, or just past the
+ *      VLAN header, to the first byte of the L2 payload.
  *
  *    - skb->transport_header: If key->eth.type is ETH_P_IP or ETH_P_IPV6
  *      on output, then just past the IP header, if one is present and
  *      of a correct length, otherwise the same as skb->network_header.
  *      For other key->eth.type values it is left untouched.
+ *
+ *    - skb->protocol: the type of the data starting at skb->network_header.
+ *      Equals to key->eth.type.
  */
 static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 {
@@ -505,28 +511,35 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 
 	skb_reset_mac_header(skb);
 
-	/* Link layer.  We are guaranteed to have at least the 14 byte Ethernet
-	 * header in the linear data area.
-	 */
-	eth = eth_hdr(skb);
-	ether_addr_copy(key->eth.src, eth->h_source);
-	ether_addr_copy(key->eth.dst, eth->h_dest);
+	/* Link layer. */
+	clear_vlan(key);
+	if (key->mac_proto == MAC_PROTO_NONE) {
+		if (unlikely(eth_type_vlan(skb->protocol)))
+			return -EINVAL;
 
-	__skb_pull(skb, 2 * ETH_ALEN);
-	/* We are going to push all headers that we pull, so no need to
-	 * update skb->csum here.
-	 */
+		skb_reset_network_header(skb);
+	} else {
+		eth = eth_hdr(skb);
+		ether_addr_copy(key->eth.src, eth->h_source);
+		ether_addr_copy(key->eth.dst, eth->h_dest);
 
-	if (unlikely(parse_vlan(skb, key)))
-		return -ENOMEM;
+		__skb_pull(skb, 2 * ETH_ALEN);
+		/* We are going to push all headers that we pull, so no need to
+		* update skb->csum here.
+		*/
 
-	key->eth.type = parse_ethertype(skb);
-	if (unlikely(key->eth.type == htons(0)))
-		return -ENOMEM;
+		if (unlikely(parse_vlan(skb, key)))
+			return -ENOMEM;
+
+		skb->protocol = parse_ethertype(skb);
+		if (unlikely(skb->protocol == htons(0)))
+			return -ENOMEM;
 
-	skb_reset_network_header(skb);
+		skb_reset_network_header(skb);
+		__skb_push(skb, skb->data - skb_mac_header(skb));
+	}
 	skb_reset_mac_len(skb);
-	__skb_push(skb, skb->data - skb_mac_header(skb));
+	key->eth.type = skb->protocol;
 
 	/* Network layer. */
 	if (key->eth.type == htons(ETH_P_IP)) {
@@ -721,9 +734,25 @@ int ovs_flow_key_update(struct sk_buff *skb, struct sw_flow_key *key)
 	return key_extract(skb, key);
 }
 
+static int key_extract_mac_proto(struct sk_buff *skb)
+{
+	switch (skb->dev->type) {
+	case ARPHRD_ETHER:
+		return MAC_PROTO_ETHERNET;
+	case ARPHRD_NONE:
+		if (skb->protocol == htons(ETH_P_TEB))
+			return MAC_PROTO_ETHERNET;
+		return MAC_PROTO_NONE;
+	}
+	WARN_ON_ONCE(1);
+	return -EINVAL;
+}
+
 int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
 			 struct sk_buff *skb, struct sw_flow_key *key)
 {
+	int res;
+
 	/* Extract metadata from packet. */
 	if (tun_info) {
 		key->tun_proto = ip_tunnel_info_af(tun_info);
@@ -751,7 +780,10 @@ int ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
 	key->phy.skb_mark = skb->mark;
 	ovs_ct_fill_key(skb, key);
 	key->ovs_flow_hash = 0;
-	key->mac_proto = MAC_PROTO_ETHERNET;
+	res = key_extract_mac_proto(skb);
+	if (res < 0)
+		return res;
+	key->mac_proto = res;
 	key->recirc_id = 0;
 
 	return key_extract(skb, key);
@@ -768,5 +800,29 @@ int ovs_flow_key_extract_userspace(struct net *net, const struct nlattr *attr,
 	if (err)
 		return err;
 
+	if (ovs_key_mac_proto(key) == MAC_PROTO_NONE) {
+		/* key_extract assumes that skb->protocol is set-up for
+		 * layer 3 packets which is the case for other callers,
+		 * in particular packets recieved from the network stack.
+		 * Here the correct value can be set from the metadata
+		 * extracted above.
+		 */
+		skb->protocol = key->eth.type;
+	} else {
+		struct ethhdr *eth;
+
+		skb_reset_mac_header(skb);
+		eth = eth_hdr(skb);
+
+		/* Normally, setting the skb 'protocol' field would be
+		 * handled by a call to eth_type_trans(), but it assumes
+		 * there's a sending device, which we may not have.
+		 */
+		if (eth_proto_is_802_3(eth->h_proto))
+			skb->protocol = eth->h_proto;
+		else
+			skb->protocol = htons(ETH_P_802_2);
+	}
+
 	return key_extract(skb, key);
 }
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 898ed377b5cc..b6c8524032a0 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -485,6 +485,25 @@ void ovs_vport_send(struct vport *vport, struct sk_buff *skb, u8 mac_proto)
 {
 	int mtu = vport->dev->mtu;
 
+	switch (vport->dev->type) {
+	case ARPHRD_NONE:
+		if (mac_proto == MAC_PROTO_ETHERNET) {
+			skb_reset_network_header(skb);
+			skb_reset_mac_len(skb);
+			skb->protocol = htons(ETH_P_TEB);
+		} else if (mac_proto != MAC_PROTO_NONE) {
+			WARN_ON_ONCE(1);
+			goto drop;
+		}
+		break;
+	case ARPHRD_ETHER:
+		if (mac_proto != MAC_PROTO_ETHERNET)
+			goto drop;
+		break;
+	default:
+		goto drop;
+	}
+
 	if (unlikely(packet_length(skb, vport->dev) > mtu &&
 		     !skb_is_gso(skb))) {
 		net_warn_ratelimited("%s: dropped over-mtu packet: %d > %d\n",
-- 
1.8.3.1
