From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: 3.14 stable request for net: gso: use feature flag argument in all protocol gso handlers
Date: Thu, 13 Aug 2015 18:44:50 -0700
Message-ID: <12006.1439516690@famine>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
	Florian Westphal <fw@strlen.de>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:55326 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754621AbbHNBo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 21:44:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	For 3.14 -stable, please consider commit:

commit 1e16aa3ddf863c6b9f37eddf52503230a62dedb3
Author: Florian Westphal <fw@strlen.de>
Date:   Mon Oct 20 13:49:16 2014 +0200

    net: gso: use feature flag argument in all protocol gso handlers


	We have observed kernel panics when an openvswitch bridge is
populated with virtual devices (veth, for example) that have expansive
feature sets that include NETIF_F_GSO_GRE.

	The failure occurs when foreign GRE encapsulated traffic
(explicitly not including the initial packets of a connection) arrives at
the system (likely via a switch flood event).  The packets are GRO
accumulated, and passed to the OVS receive processing.  As the connection
is not in the OVS kernel datapath table, the call path is:

ovs_dp_upcall ->
	queue_gso_packets ->
		__skb_gso_segment(skb, NETIF_F_SG, false)

	Without the patch cited above, __skb_gso_segment returns NULL,
as the features from the device (including _GSO_GRE) are used in place
of the _SG feature supplied to the call.  The kernel panics on a
subsequent dereference of the NULL pointer in queue_userspace_packet().

	A backport to 3.14.50 is below.

	-J

Subject: [PATCH 3.14-stable] net: gso: use feature flag argument in all protocol gso handlers

From: Florian Westphal <fw@strlen.de>

skb_gso_segment() has a 'features' argument representing offload features
available to the output path.

A few handlers, e.g. GRE, instead re-fetch the features of skb->dev and use
those instead of the provided ones when handing encapsulation/tunnels.

Depending on dev->hw_enc_features of the output device skb_gso_segment() can
then return NULL even when the caller has disabled all GSO feature bits,
as segmentation of inner header thinks device will take care of segmentation.

This e.g. affects the tbf scheduler, which will silently drop GRE-encap GSO skbs
that did not fit the remaining token quota as the segmentation does not work
when device supports corresponding hw offload capabilities.

Cc: Pravin B Shelar <pshelar@nicira.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: David S. Miller <davem@davemloft.net>
[jay.vosburgh: backported to 3.14. ]
Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>

---
 net/ipv4/af_inet.c     | 2 +-
 net/ipv4/gre_offload.c | 2 +-
 net/ipv4/udp.c         | 2 +-
 net/ipv6/ip6_offload.c | 2 +-
 net/mpls/mpls_gso.c    | 2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 951fe55..f4c804d 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1291,7 +1291,7 @@ static struct sk_buff *inet_gso_segment(struct sk_buff *skb,
 
 	encap = SKB_GSO_CB(skb)->encap_level > 0;
 	if (encap)
-		features = skb->dev->hw_enc_features & netif_skb_features(skb);
+		features &= skb->dev->hw_enc_features;
 	SKB_GSO_CB(skb)->encap_level += ihl;
 
 	skb_reset_transport_header(skb);
diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index 278836f..0da513e 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -69,7 +69,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 	skb->mac_len = skb_inner_network_offset(skb);
 
 	/* segment inner packet. */
-	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
+	enc_features = skb->dev->hw_enc_features & features;
 	segs = skb_mac_gso_segment(skb, enc_features);
 	if (!segs || IS_ERR(segs)) {
 		skb_gso_error_unwind(skb, protocol, ghl, mac_offset, mac_len);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 21a3a9e..22b2a83 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2510,7 +2510,7 @@ struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 	skb->protocol = htons(ETH_P_TEB);
 
 	/* segment inner packet. */
-	enc_features = skb->dev->hw_enc_features & netif_skb_features(skb);
+	enc_features = skb->dev->hw_enc_features & features;
 	segs = skb_mac_gso_segment(skb, enc_features);
 	if (!segs || IS_ERR(segs)) {
 		skb_gso_error_unwind(skb, protocol, tnl_hlen, mac_offset,
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index b2f0915..dc46eba 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -112,7 +112,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 
 	encap = SKB_GSO_CB(skb)->encap_level > 0;
 	if (encap)
-		features = skb->dev->hw_enc_features & netif_skb_features(skb);
+		features &= skb->dev->hw_enc_features;
 	SKB_GSO_CB(skb)->encap_level += sizeof(*ipv6h);
 
 	ipv6h = ipv6_hdr(skb);
diff --git a/net/mpls/mpls_gso.c b/net/mpls/mpls_gso.c
index 851cd88..0c970cb 100644
--- a/net/mpls/mpls_gso.c
+++ b/net/mpls/mpls_gso.c
@@ -47,7 +47,7 @@ static struct sk_buff *mpls_gso_segment(struct sk_buff *skb,
 	__skb_push(skb, skb->mac_len);
 
 	/* Segment inner packet. */
-	mpls_features = skb->dev->mpls_features & netif_skb_features(skb);
+	mpls_features = skb->dev->mpls_features & features;
 	segs = skb_mac_gso_segment(skb, mpls_features);
 
 
-- 
1.9.1


---
	-Jay Vosburgh, jay.vosburgh@canonical.com
