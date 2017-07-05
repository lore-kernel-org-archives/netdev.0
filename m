From: David Miller <davem@davemloft.net>
Subject: [PATCH RFC 11/12] net: Remove all references to SKB_GSO_UDP.
Date: Wed, 05 Jul 2017 16:06:32 +0100 (WEST)
Message-ID: <20170705.160632.1021185732937441107.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42614 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750896AbdGEPGi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 11:06:38 -0400
Received: from localhost (unknown [193.136.225.129])
        (using TLSv1 with cipher AES256-SHA (256/256 bits))
        (Client did not present a certificate)
        (Authenticated sender: davem-davemloft)
        by shards.monkeyblade.net (Postfix) with ESMTPSA id 3D6A2126C97F5
        for <netdev@vger.kernel.org>; Wed,  5 Jul 2017 08:06:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Such packets are no longer possible.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/virtio_net.h |  5 -----
 net/core/filter.c          |  8 ++++----
 net/ipv4/af_inet.c         | 12 ++----------
 net/ipv4/gre_offload.c     | 14 +-------------
 net/ipv4/udp_offload.c     |  6 ++----
 net/openvswitch/datapath.c | 14 --------------
 net/openvswitch/flow.c     |  6 +-----
 net/sched/act_csum.c       |  6 ------
 8 files changed, 10 insertions(+), 61 deletions(-)

diff --git a/include/linux/virtio_net.h b/include/linux/virtio_net.h
index 5209b5e..32fb046 100644
--- a/include/linux/virtio_net.h
+++ b/include/linux/virtio_net.h
@@ -18,9 +18,6 @@ static inline int virtio_net_hdr_to_skb(struct sk_buff *skb,
 		case VIRTIO_NET_HDR_GSO_TCPV6:
 			gso_type = SKB_GSO_TCPV6;
 			break;
-		case VIRTIO_NET_HDR_GSO_UDP:
-			gso_type = SKB_GSO_UDP;
-			break;
 		default:
 			return -EINVAL;
 		}
@@ -73,8 +70,6 @@ static inline int virtio_net_hdr_from_skb(const struct sk_buff *skb,
 			hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV4;
 		else if (sinfo->gso_type & SKB_GSO_TCPV6)
 			hdr->gso_type = VIRTIO_NET_HDR_GSO_TCPV6;
-		else if (sinfo->gso_type & SKB_GSO_UDP)
-			hdr->gso_type = VIRTIO_NET_HDR_GSO_UDP;
 		else
 			return -EINVAL;
 		if (sinfo->gso_type & SKB_GSO_TCP_ECN)
diff --git a/net/core/filter.c b/net/core/filter.c
index 9416957..4987432 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2024,8 +2024,8 @@ static int bpf_skb_proto_4_to_6(struct sk_buff *skb)
 		return ret;
 
 	if (skb_is_gso(skb)) {
-		/* SKB_GSO_UDP stays as is. SKB_GSO_TCPV4 needs to
-		 * be changed into SKB_GSO_TCPV6.
+		/* SKB_GSO_TCPV4 needs to be changed into
+		 * SKB_GSO_TCPV6.
 		 */
 		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV4) {
 			skb_shinfo(skb)->gso_type &= ~SKB_GSO_TCPV4;
@@ -2060,8 +2060,8 @@ static int bpf_skb_proto_6_to_4(struct sk_buff *skb)
 		return ret;
 
 	if (skb_is_gso(skb)) {
-		/* SKB_GSO_UDP stays as is. SKB_GSO_TCPV6 needs to
-		 * be changed into SKB_GSO_TCPV4.
+		/* SKB_GSO_TCPV6 needs to be changed into
+		 * SKB_GSO_TCPV4.
 		 */
 		if (skb_shinfo(skb)->gso_type & SKB_GSO_TCPV6) {
 			skb_shinfo(skb)->gso_type &= ~SKB_GSO_TCPV6;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 76c2077c..5ce44fb 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1219,10 +1219,9 @@ EXPORT_SYMBOL(inet_sk_rebuild_header);
 struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 				 netdev_features_t features)
 {
-	bool udpfrag = false, fixedid = false, gso_partial, encap;
+	bool fixedid = false, gso_partial, encap;
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	const struct net_offload *ops;
-	unsigned int offset = 0;
 	struct iphdr *iph;
 	int proto, tot_len;
 	int nhoff;
@@ -1257,7 +1256,6 @@ struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 	segs = ERR_PTR(-EPROTONOSUPPORT);
 
 	if (!skb->encapsulation || encap) {
-		udpfrag = !!(skb_shinfo(skb)->gso_type & SKB_GSO_UDP);
 		fixedid = !!(skb_shinfo(skb)->gso_type & SKB_GSO_TCP_FIXEDID);
 
 		/* fixed ID is invalid if DF bit is not set */
@@ -1277,13 +1275,7 @@ struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 	skb = segs;
 	do {
 		iph = (struct iphdr *)(skb_mac_header(skb) + nhoff);
-		if (udpfrag) {
-			iph->frag_off = htons(offset >> 3);
-			if (skb->next)
-				iph->frag_off |= htons(IP_MF);
-			offset += skb->len - nhoff - ihl;
-			tot_len = skb->len - nhoff;
-		} else if (skb_is_gso(skb)) {
+		if (skb_is_gso(skb)) {
 			if (!fixedid) {
 				iph->id = htons(id);
 				id += skb_shinfo(skb)->gso_segs;
diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index d5cac99..416bb30 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -24,7 +24,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	__be16 protocol = skb->protocol;
 	u16 mac_len = skb->mac_len;
 	int gre_offset, outer_hlen;
-	bool need_csum, ufo, gso_partial;
+	bool need_csum, gso_partial;
 
 	if (!skb->encapsulation)
 		goto out;
@@ -47,20 +47,8 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	need_csum = !!(skb_shinfo(skb)->gso_type & SKB_GSO_GRE_CSUM);
 	skb->encap_hdr_csum = need_csum;
 
-	ufo = !!(skb_shinfo(skb)->gso_type & SKB_GSO_UDP);
-
 	features &= skb->dev->hw_enc_features;
 
-	/* The only checksum offload we care about from here on out is the
-	 * outer one so strip the existing checksum feature flags based
-	 * on the fact that we will be computing our checksum in software.
-	 */
-	if (ufo) {
-		features &= ~NETIF_F_CSUM_MASK;
-		if (!need_csum)
-			features |= NETIF_F_HW_CSUM;
-	}
-
 	/* segment inner packet. */
 	segs = skb_mac_gso_segment(skb, features);
 	if (IS_ERR_OR_NULL(segs)) {
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index 7812501..4fedce3 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -21,7 +21,7 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 	__be16 new_protocol, bool is_ipv6)
 {
 	int tnl_hlen = skb_inner_mac_header(skb) - skb_transport_header(skb);
-	bool remcsum, need_csum, offload_csum, ufo, gso_partial;
+	bool remcsum, need_csum, offload_csum, gso_partial;
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	struct udphdr *uh = udp_hdr(skb);
 	u16 mac_offset = skb->mac_header;
@@ -61,8 +61,6 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 	remcsum = !!(skb_shinfo(skb)->gso_type & SKB_GSO_TUNNEL_REMCSUM);
 	skb->remcsum_offload = remcsum;
 
-	ufo = !!(skb_shinfo(skb)->gso_type & SKB_GSO_UDP);
-
 	need_ipsec = skb_dst(skb) && dst_xfrm(skb_dst(skb));
 	/* Try to offload checksum if possible */
 	offload_csum = !!(need_csum &&
@@ -77,7 +75,7 @@ static struct sk_buff *__skb_udp_tunnel_segment(struct sk_buff *skb,
 	 * outer one so strip the existing checksum feature flags and
 	 * instead set the flag based on our outer checksum offload value.
 	 */
-	if (remcsum || ufo) {
+	if (remcsum) {
 		features &= ~NETIF_F_CSUM_MASK;
 		if (!need_csum || offload_csum)
 			features |= NETIF_F_HW_CSUM;
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 45fe8c8..f6e229b 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -335,8 +335,6 @@ static int queue_gso_packets(struct datapath *dp, struct sk_buff *skb,
 			     const struct dp_upcall_info *upcall_info,
 				 uint32_t cutlen)
 {
-	unsigned short gso_type = skb_shinfo(skb)->gso_type;
-	struct sw_flow_key later_key;
 	struct sk_buff *segs, *nskb;
 	int err;
 
@@ -347,21 +345,9 @@ static int queue_gso_packets(struct datapath *dp, struct sk_buff *skb,
 	if (segs == NULL)
 		return -EINVAL;
 
-	if (gso_type & SKB_GSO_UDP) {
-		/* The initial flow key extracted by ovs_flow_key_extract()
-		 * in this case is for a first fragment, so we need to
-		 * properly mark later fragments.
-		 */
-		later_key = *key;
-		later_key.ip.frag = OVS_FRAG_TYPE_LATER;
-	}
-
 	/* Queue all of the segments. */
 	skb = segs;
 	do {
-		if (gso_type & SKB_GSO_UDP && skb != segs)
-			key = &later_key;
-
 		err = queue_userspace_packet(dp, skb, key, upcall_info, cutlen);
 		if (err)
 			break;
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 3f76cb7..597d96f 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -584,8 +584,7 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 			key->ip.frag = OVS_FRAG_TYPE_LATER;
 			return 0;
 		}
-		if (nh->frag_off & htons(IP_MF) ||
-			skb_shinfo(skb)->gso_type & SKB_GSO_UDP)
+		if (nh->frag_off & htons(IP_MF))
 			key->ip.frag = OVS_FRAG_TYPE_FIRST;
 		else
 			key->ip.frag = OVS_FRAG_TYPE_NONE;
@@ -701,9 +700,6 @@ static int key_extract(struct sk_buff *skb, struct sw_flow_key *key)
 
 		if (key->ip.frag == OVS_FRAG_TYPE_LATER)
 			return 0;
-		if (skb_shinfo(skb)->gso_type & SKB_GSO_UDP)
-			key->ip.frag = OVS_FRAG_TYPE_FIRST;
-
 		/* Transport layer. */
 		if (key->ip.proto == NEXTHDR_TCP) {
 			if (tcphdr_ok(skb)) {
diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index 3317a2f..67afc12 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -231,9 +231,6 @@ static int tcf_csum_ipv4_udp(struct sk_buff *skb, unsigned int ihl,
 	const struct iphdr *iph;
 	u16 ul;
 
-	if (skb_is_gso(skb) && skb_shinfo(skb)->gso_type & SKB_GSO_UDP)
-		return 1;
-
 	/*
 	 * Support both UDP and UDPLITE checksum algorithms, Don't use
 	 * udph->len to get the real length without any protocol check,
@@ -287,9 +284,6 @@ static int tcf_csum_ipv6_udp(struct sk_buff *skb, unsigned int ihl,
 	const struct ipv6hdr *ip6h;
 	u16 ul;
 
-	if (skb_is_gso(skb) && skb_shinfo(skb)->gso_type & SKB_GSO_UDP)
-		return 1;
-
 	/*
 	 * Support both UDP and UDPLITE checksum algorithms, Don't use
 	 * udph->len to get the real length without any protocol check,
-- 
2.9.4
