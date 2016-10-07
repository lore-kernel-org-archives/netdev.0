From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v3 2/6] openvswitch: normalize vlan rx path
Date: Fri,  7 Oct 2016 18:07:37 +0200
Message-ID: <2b0e7198a9f8d2230985aadca150819e5477e0d6.1475855896.git.jbenc@redhat.com>
References: <cover.1475855896.git.jbenc@redhat.com>
Cc: pravin shelar <pshelar@ovn.org>, Eric Garver <e@erig.me>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59786 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934919AbcJGQHy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Oct 2016 12:07:54 -0400
In-Reply-To: <cover.1475855896.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similarly to how the core networking stack behaves, let the first vlan tag
be always stored in skb->vlan_tci. This is already ensured in
__netif_receive_skb_core for packets that were received from the kernel and
honored by skb_vlan_push and skb_vlan_pop. There is a couple of paths where
a packet with vlan header inside the packet data can be received:

(1) Packets received from the user space.
(2) Packets received via internal device, either injected through AF_PACKET
    or with vlan acceleration turned off.

In addition, there will be a third path when support for ETH_P_TEB packets
is added.

To catch all of these cases, untag the vlan frame in ovs_flow_key_extract
and ovs_flow_key_extract_userspace.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
v3: moved the untagging to ovs_flow_key_extract* to catch all cases
---
 net/openvswitch/flow.c | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index f358608dd33d..14159ac19850 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -716,6 +716,20 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 	return 0;
 }
 
+static struct sk_buff *vlan_untag(struct sk_buff *skb)
+{
+	if (eth_type_vlan(skb->protocol)) {
+		__skb_pull(skb, ETH_HLEN);
+		skb_reset_network_header(skb);
+		skb_reset_mac_len(skb);
+		skb = skb_vlan_untag(skb);
+		if (unlikely(!skb))
+			return NULL;
+		skb_push(skb, ETH_HLEN);
+	}
+	return skb;
+}
+
 int ovs_flow_key_update(struct sk_buff *skb, struct sw_flow_key *key)
 {
 	return key_extract(skb, key);
@@ -727,6 +741,10 @@ struct sk_buff *ovs_flow_key_extract(const struct ip_tunnel_info *tun_info,
 {
 	int err;
 
+	skb = vlan_untag(skb);
+	if (!skb)
+		return ERR_PTR(-ENOMEM);
+
 	/* Extract metadata from packet. */
 	if (tun_info) {
 		key->tun_proto = ip_tunnel_info_af(tun_info);
@@ -772,6 +790,10 @@ struct sk_buff *ovs_flow_key_extract_userspace(struct net *net,
 {
 	int err;
 
+	skb = vlan_untag(skb);
+	if (!skb)
+		return ERR_PTR(-ENOMEM);
+
 	/* Extract metadata from netlink attributes. */
 	err = ovs_nla_get_flow_metadata(net, attr, key, log);
 	if (err)
-- 
1.8.3.1
