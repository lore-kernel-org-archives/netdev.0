From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v13 3/8] openvswitch: pass mac_proto to ovs_vport_send
Date: Thu, 10 Nov 2016 16:28:19 +0100
Message-ID: <4e1bfb1eb4e58d51366405dc8acf462a7a84cfe1.1478791347.git.jbenc@redhat.com>
References: <cover.1478791347.git.jbenc@redhat.com>
Cc: dev@openvswitch.org, Pravin Shelar <pshelar@ovn.org>,
        Lorand Jakab <lojakab@cisco.com>,
        Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44326 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933482AbcKJP2p (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 10:28:45 -0500
In-Reply-To: <cover.1478791347.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We'll need it to alter packets sent to ARPHRD_NONE interfaces.

Change do_output() to use the actual L2 header size of the packet when
deciding on the minimum cutlen. The assumption here is that what matters is
not the output interface hard_header_len but rather the L2 header of the
particular packet. For example, ARPHRD_NONE tunnels that encapsulate
Ethernet should get at least the Ethernet header.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
Acked-by: Pravin B Shelar <pshelar@ovn.org>
---
 net/openvswitch/actions.c | 29 +++++++++++++++++------------
 net/openvswitch/vport.c   |  2 +-
 net/openvswitch/vport.h   |  2 +-
 3 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 44144f914920..dc8bb97e2258 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -66,6 +66,7 @@ struct ovs_frag_data {
 	u16 vlan_tci;
 	__be16 vlan_proto;
 	unsigned int l2_len;
+	u8 mac_proto;
 	u8 l2_data[MAX_L2_LEN];
 };
 
@@ -673,7 +674,7 @@ static int ovs_vport_output(struct net *net, struct sock *sk, struct sk_buff *sk
 		skb_reset_mac_len(skb);
 	}
 
-	ovs_vport_send(vport, skb);
+	ovs_vport_send(vport, skb, data->mac_proto);
 	return 0;
 }
 
@@ -692,7 +693,7 @@ static int ovs_vport_output(struct net *net, struct sock *sk, struct sk_buff *sk
  * ovs_vport_output(), which is called once per fragmented packet.
  */
 static void prepare_frag(struct vport *vport, struct sk_buff *skb,
-			 u16 orig_network_offset)
+			 u16 orig_network_offset, u8 mac_proto)
 {
 	unsigned int hlen = skb_network_offset(skb);
 	struct ovs_frag_data *data;
@@ -705,6 +706,7 @@ static void prepare_frag(struct vport *vport, struct sk_buff *skb,
 	data->network_offset = orig_network_offset;
 	data->vlan_tci = skb->vlan_tci;
 	data->vlan_proto = skb->vlan_proto;
+	data->mac_proto = mac_proto;
 	data->l2_len = hlen;
 	memcpy(&data->l2_data, skb->data, hlen);
 
@@ -713,7 +715,8 @@ static void prepare_frag(struct vport *vport, struct sk_buff *skb,
 }
 
 static void ovs_fragment(struct net *net, struct vport *vport,
-			 struct sk_buff *skb, u16 mru, __be16 ethertype)
+			 struct sk_buff *skb, u16 mru,
+			 struct sw_flow_key *key)
 {
 	u16 orig_network_offset = 0;
 
@@ -727,11 +730,12 @@ static void ovs_fragment(struct net *net, struct vport *vport,
 		goto err;
 	}
 
-	if (ethertype == htons(ETH_P_IP)) {
+	if (key->eth.type == htons(ETH_P_IP)) {
 		struct dst_entry ovs_dst;
 		unsigned long orig_dst;
 
-		prepare_frag(vport, skb, orig_network_offset);
+		prepare_frag(vport, skb, orig_network_offset,
+			     ovs_key_mac_proto(key));
 		dst_init(&ovs_dst, &ovs_dst_ops, NULL, 1,
 			 DST_OBSOLETE_NONE, DST_NOCOUNT);
 		ovs_dst.dev = vport->dev;
@@ -742,7 +746,7 @@ static void ovs_fragment(struct net *net, struct vport *vport,
 
 		ip_do_fragment(net, skb->sk, skb, ovs_vport_output);
 		refdst_drop(orig_dst);
-	} else if (ethertype == htons(ETH_P_IPV6)) {
+	} else if (key->eth.type == htons(ETH_P_IPV6)) {
 		const struct nf_ipv6_ops *v6ops = nf_get_ipv6_ops();
 		unsigned long orig_dst;
 		struct rt6_info ovs_rt;
@@ -751,7 +755,8 @@ static void ovs_fragment(struct net *net, struct vport *vport,
 			goto err;
 		}
 
-		prepare_frag(vport, skb, orig_network_offset);
+		prepare_frag(vport, skb, orig_network_offset,
+			     ovs_key_mac_proto(key));
 		memset(&ovs_rt, 0, sizeof(ovs_rt));
 		dst_init(&ovs_rt.dst, &ovs_dst_ops, NULL, 1,
 			 DST_OBSOLETE_NONE, DST_NOCOUNT);
@@ -765,7 +770,7 @@ static void ovs_fragment(struct net *net, struct vport *vport,
 		refdst_drop(orig_dst);
 	} else {
 		WARN_ONCE(1, "Failed fragment ->%s: eth=%04x, MRU=%d, MTU=%d.",
-			  ovs_vport_name(vport), ntohs(ethertype), mru,
+			  ovs_vport_name(vport), ntohs(key->eth.type), mru,
 			  vport->dev->mtu);
 		goto err;
 	}
@@ -785,19 +790,19 @@ static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port,
 		u32 cutlen = OVS_CB(skb)->cutlen;
 
 		if (unlikely(cutlen > 0)) {
-			if (skb->len - cutlen > ETH_HLEN)
+			if (skb->len - cutlen > ovs_mac_header_len(key))
 				pskb_trim(skb, skb->len - cutlen);
 			else
-				pskb_trim(skb, ETH_HLEN);
+				pskb_trim(skb, ovs_mac_header_len(key));
 		}
 
 		if (likely(!mru ||
 		           (skb->len <= mru + vport->dev->hard_header_len))) {
-			ovs_vport_send(vport, skb);
+			ovs_vport_send(vport, skb, ovs_key_mac_proto(key));
 		} else if (mru <= vport->dev->mtu) {
 			struct net *net = read_pnet(&dp->net);
 
-			ovs_fragment(net, vport, skb, mru, key->eth.type);
+			ovs_fragment(net, vport, skb, mru, key);
 		} else {
 			kfree_skb(skb);
 		}
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 3e131f6868f2..898ed377b5cc 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -481,7 +481,7 @@ static unsigned int packet_length(const struct sk_buff *skb,
 	return length;
 }
 
-void ovs_vport_send(struct vport *vport, struct sk_buff *skb)
+void ovs_vport_send(struct vport *vport, struct sk_buff *skb, u8 mac_proto)
 {
 	int mtu = vport->dev->mtu;
 
diff --git a/net/openvswitch/vport.h b/net/openvswitch/vport.h
index 46e5b69927c7..cda66c26ad08 100644
--- a/net/openvswitch/vport.h
+++ b/net/openvswitch/vport.h
@@ -197,6 +197,6 @@ static inline const char *ovs_vport_name(struct vport *vport)
 	})
 
 void ovs_vport_ops_unregister(struct vport_ops *ops);
-void ovs_vport_send(struct vport *vport, struct sk_buff *skb);
+void ovs_vport_send(struct vport *vport, struct sk_buff *skb, u8 mac_proto);
 
 #endif /* vport.h */
-- 
1.8.3.1
