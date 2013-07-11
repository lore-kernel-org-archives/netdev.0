From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH net v2] gso: Update tunnel segmentation to support Tx checksum
	offload
Date: Wed, 10 Jul 2013 17:05:06 -0700
Message-ID: <20130711000015.13134.17801.stgit@ahduyck-hc1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, pshelar@nicira.com,
	joseph.gasparakis@intel.com, eric.dumazet@gmail.com,
	jesse@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:53343 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754471Ab3GKAAj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jul 2013 20:00:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change makes it so that the GRE and VXLAN tunnels can make use of Tx
checksum offload support provided by some drivers via the hw_enc_features.
Without this fix enabling GSO means sacrificing Tx checksum offload and
this actually leads to a performance regression as shown below:

            Utilization
            Send
Throughput  local         GSO
10^6bits/s  % S           state
  6276.51   8.39          enabled
  7123.52   8.42          disabled

To resolve this it was necessary to address two items.  First
netif_skb_features needed to be updated so that it would correctly handle
the Trans Ether Bridging protocol without impacting the need to check for
Q-in-Q tagging.  To do this it was necessary to update harmonize_features
so that it used skb_network_protocol instead of just using the outer
protocol.

Second it was necessary to update the GRE and UDP tunnel segmentation
offloads so that they would reset the encapsulation bit and inner header
offsets after the offload was complete.

As a result of this change I have seen the following results on a interface
with Tx checksum enabled for encapsulated frames:

            Utilization
            Send
Throughput  local         GSO
10^6bits/s  % S           state
  7123.52   8.42          disabled
  8321.75   5.43          enabled

v2: Instead of replacing refrence to skb->protocol with
    skb_network_protocol just replace the protocol reference in
    harmonize_features to allow for double VLAN tag checks.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 net/core/dev.c         |   14 ++++++--------
 net/ipv4/gre_offload.c |    3 +++
 net/ipv4/udp.c         |    4 +++-
 3 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 560dafd..d398b60 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2481,10 +2481,10 @@ static int dev_gso_segment(struct sk_buff *skb, netdev_features_t features)
 }
 
 static netdev_features_t harmonize_features(struct sk_buff *skb,
-	__be16 protocol, netdev_features_t features)
+	netdev_features_t features)
 {
 	if (skb->ip_summed != CHECKSUM_NONE &&
-	    !can_checksum_protocol(features, protocol)) {
+	    !can_checksum_protocol(features, skb_network_protocol(skb))) {
 		features &= ~NETIF_F_ALL_CSUM;
 	} else if (illegal_highdma(skb->dev, skb)) {
 		features &= ~NETIF_F_SG;
@@ -2505,20 +2505,18 @@ netdev_features_t netif_skb_features(struct sk_buff *skb)
 		struct vlan_ethhdr *veh = (struct vlan_ethhdr *)skb->data;
 		protocol = veh->h_vlan_encapsulated_proto;
 	} else if (!vlan_tx_tag_present(skb)) {
-		return harmonize_features(skb, protocol, features);
+		return harmonize_features(skb, features);
 	}
 
 	features &= (skb->dev->vlan_features | NETIF_F_HW_VLAN_CTAG_TX |
 					       NETIF_F_HW_VLAN_STAG_TX);
 
-	if (protocol != htons(ETH_P_8021Q) && protocol != htons(ETH_P_8021AD)) {
-		return harmonize_features(skb, protocol, features);
-	} else {
+	if (protocol == htons(ETH_P_8021Q) || protocol == htons(ETH_P_8021AD))
 		features &= NETIF_F_SG | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST |
 				NETIF_F_GEN_CSUM | NETIF_F_HW_VLAN_CTAG_TX |
 				NETIF_F_HW_VLAN_STAG_TX;
-		return harmonize_features(skb, protocol, features);
-	}
+
+	return harmonize_features(skb, features);
 }
 EXPORT_SYMBOL(netif_skb_features);
 
diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index 775d5b5..55e6bfb 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -100,6 +100,9 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 		}
 		__skb_push(skb, tnl_hlen - ghl);
 
+		skb_reset_inner_headers(skb);
+		skb->encapsulation = 1;
+
 		skb_reset_mac_header(skb);
 		skb_set_network_header(skb, mac_len);
 		skb->mac_len = mac_len;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 6b270e5..d399dd5 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -2323,6 +2323,9 @@ struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 		struct udphdr *uh;
 		int udp_offset = outer_hlen - tnl_hlen;
 
+		skb_reset_inner_headers(skb);
+		skb->encapsulation = 1;
+
 		skb->mac_len = mac_len;
 
 		skb_push(skb, outer_hlen);
@@ -2345,7 +2348,6 @@ struct sk_buff *skb_udp_tunnel_segment(struct sk_buff *skb,
 				uh->check = CSUM_MANGLED_0;
 
 		}
-		skb->ip_summed = CHECKSUM_NONE;
 		skb->protocol = protocol;
 	} while ((skb = skb->next));
 out:
