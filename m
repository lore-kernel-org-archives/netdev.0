From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v2] openvswitch: correctly fragment packet with mpls headers
Date: Wed,  5 Oct 2016 15:01:57 +0200
Message-ID: <502ca56422930442a91db61f975f829c62b27c7f.1475672359.git.jbenc@redhat.com>
Cc: David Ahern <dsa@cumulusnetworks.com>,
        pravin shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37710 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751154AbcJENCH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Oct 2016 09:02:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If mpls headers were pushed to a defragmented packet, the refragmentation no
longer works correctly after 48d2ab609b6b ("net: mpls: Fixups for GSO"). The
network header has to be shifted after the mpls headers for the
fragmentation and restored afterwards.

Fixes: 48d2ab609b6b ("net: mpls: Fixups for GSO")
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
v2: rewrite and restore the network header only for MPLS packets
---
 net/openvswitch/actions.c | 24 ++++++++++++++++++++----
 1 file changed, 20 insertions(+), 4 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 4e03f64709bc..1105c4e29c62 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -62,7 +62,8 @@ struct ovs_frag_data {
 	struct vport *vport;
 	struct ovs_skb_cb cb;
 	__be16 inner_protocol;
-	__u16 vlan_tci;
+	u16 network_offset;	/* valid only for MPLS */
+	u16 vlan_tci;
 	__be16 vlan_proto;
 	unsigned int l2_len;
 	u8 l2_data[MAX_L2_LEN];
@@ -666,6 +667,12 @@ static int ovs_vport_output(struct net *net, struct sock *sk, struct sk_buff *sk
 	skb_postpush_rcsum(skb, skb->data, data->l2_len);
 	skb_reset_mac_header(skb);
 
+	if (eth_p_mpls(skb->protocol)) {
+		skb->inner_network_header = skb->network_header;
+		skb_set_network_header(skb, data->network_offset);
+		skb_reset_mac_len(skb);
+	}
+
 	ovs_vport_send(vport, skb);
 	return 0;
 }
@@ -684,7 +691,8 @@ static struct dst_ops ovs_dst_ops = {
 /* prepare_frag() is called once per (larger-than-MTU) frame; its inverse is
  * ovs_vport_output(), which is called once per fragmented packet.
  */
-static void prepare_frag(struct vport *vport, struct sk_buff *skb)
+static void prepare_frag(struct vport *vport, struct sk_buff *skb,
+			 u16 orig_network_offset)
 {
 	unsigned int hlen = skb_network_offset(skb);
 	struct ovs_frag_data *data;
@@ -694,6 +702,7 @@ static void prepare_frag(struct vport *vport, struct sk_buff *skb)
 	data->vport = vport;
 	data->cb = *OVS_CB(skb);
 	data->inner_protocol = skb->inner_protocol;
+	data->network_offset = orig_network_offset;
 	data->vlan_tci = skb->vlan_tci;
 	data->vlan_proto = skb->vlan_proto;
 	data->l2_len = hlen;
@@ -706,6 +715,13 @@ static void prepare_frag(struct vport *vport, struct sk_buff *skb)
 static void ovs_fragment(struct net *net, struct vport *vport,
 			 struct sk_buff *skb, u16 mru, __be16 ethertype)
 {
+	u16 orig_network_offset = 0;
+
+	if (eth_p_mpls(skb->protocol)) {
+		orig_network_offset = skb_network_offset(skb);
+		skb->network_header = skb->inner_network_header;
+	}
+
 	if (skb_network_offset(skb) > MAX_L2_LEN) {
 		OVS_NLERR(1, "L2 header too long to fragment");
 		goto err;
@@ -715,7 +731,7 @@ static void ovs_fragment(struct net *net, struct vport *vport,
 		struct dst_entry ovs_dst;
 		unsigned long orig_dst;
 
-		prepare_frag(vport, skb);
+		prepare_frag(vport, skb, orig_network_offset);
 		dst_init(&ovs_dst, &ovs_dst_ops, NULL, 1,
 			 DST_OBSOLETE_NONE, DST_NOCOUNT);
 		ovs_dst.dev = vport->dev;
@@ -735,7 +751,7 @@ static void ovs_fragment(struct net *net, struct vport *vport,
 			goto err;
 		}
 
-		prepare_frag(vport, skb);
+		prepare_frag(vport, skb, orig_network_offset);
 		memset(&ovs_rt, 0, sizeof(ovs_rt));
 		dst_init(&ovs_rt.dst, &ovs_dst_ops, NULL, 1,
 			 DST_OBSOLETE_NONE, DST_NOCOUNT);
-- 
1.8.3.1
