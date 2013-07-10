From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [PATCH net] gso: Update tunnel segmentation to support Tx checksum
	offload
Date: Wed, 10 Jul 2013 13:43:03 -0700
Message-ID: <20130710203439.14927.20911.stgit@ahduyck-hc1.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, pshelar@nicira.com,
	joseph.gasparakis@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:20843 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754908Ab3GJUic (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jul 2013 16:38:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change makes it so that the GRE and VXLAN tunnels can make use of Tx
checksum offload support provided by some drivers via the hw_enc_features.
This resolves a performance regression seen when using TSO versus just
using the Tx checksum offload.

To achieve this it was necessary to address two items.  First
netif_skb_features needed to be updated so that it would correctly handle
the Trans Ether Bridging protocol.  To that end the reference to
skb->protocol was replaced with a call to skb_network_protocol.

Second it was necessary to update the GRE and UDP tunnel segmentation
offloads so that they would reset the encapsulation bit and inner header
offsets after the offload was complete.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

I am submitting this as a fix for 3.11 and stable, however the fix for
stable would likely need some modification since it seems that gre.c was
renamed to gre_offload.c at some point between 3.10 and 3.11.  If needed
I can submit a separate patch for stable.

 net/core/dev.c         |    2 +-
 net/ipv4/gre_offload.c |    3 +++
 net/ipv4/udp.c         |    4 +++-
 3 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 560dafd..0419961 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2495,7 +2495,7 @@ static netdev_features_t harmonize_features(struct sk_buff *skb,
 
 netdev_features_t netif_skb_features(struct sk_buff *skb)
 {
-	__be16 protocol = skb->protocol;
+	__be16 protocol = skb_network_protocol(skb);
 	netdev_features_t features = skb->dev->features;
 
 	if (skb_shinfo(skb)->gso_segs > skb->dev->gso_max_segs)
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
