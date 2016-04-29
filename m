From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH v2 4/9] vxlan: Add checksum check to the features
 check function
Date: Fri, 29 Apr 2016 15:43:27 -0700
Message-ID: <20160429224327.12418.95639.stgit@ahduyck-xeon-server>
References: <20160429222735.12418.61229.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: talal@mellanox.com, netdev@vger.kernel.org,
	michael.chan@broadcom.com, davem@davemloft.net, galp@mellanox.com,
	ogerlitz@mellanox.com, eranbe@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34772 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752231AbcD2Wn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Apr 2016 18:43:29 -0400
Received: by mail-pa0-f53.google.com with SMTP id r5so51664524pag.1
        for <netdev@vger.kernel.org>; Fri, 29 Apr 2016 15:43:29 -0700 (PDT)
In-Reply-To: <20160429222735.12418.61229.stgit@ahduyck-xeon-server>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to perform an additional check on the inner headers to determine if
we can offload the checksum for them.  Previously this check didn't occur
so we would generate an invalid frame in the case of an IPv6 header
encapsulated inside of an IPv4 tunnel.  To fix this I added a secondary
check to vxlan_features_check so that we can verify that we can offload the
inner checksum.

Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---
 include/linux/if_ether.h |    5 +++++
 include/net/vxlan.h      |    4 +++-
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index d5569734f672..548fd535fd02 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -28,6 +28,11 @@ static inline struct ethhdr *eth_hdr(const struct sk_buff *skb)
 	return (struct ethhdr *)skb_mac_header(skb);
 }
 
+static inline struct ethhdr *inner_eth_hdr(const struct sk_buff *skb)
+{
+	return (struct ethhdr *)skb_inner_mac_header(skb);
+}
+
 int eth_header_parse(const struct sk_buff *skb, unsigned char *haddr);
 
 extern ssize_t sysfs_format_mac(char *buf, const unsigned char *addr, int len);
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 673e9f9e6da7..b8803165df91 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -317,7 +317,9 @@ static inline netdev_features_t vxlan_features_check(struct sk_buff *skb,
 	    (skb->inner_protocol_type != ENCAP_TYPE_ETHER ||
 	     skb->inner_protocol != htons(ETH_P_TEB) ||
 	     (skb_inner_mac_header(skb) - skb_transport_header(skb) !=
-	      sizeof(struct udphdr) + sizeof(struct vxlanhdr))))
+	      sizeof(struct udphdr) + sizeof(struct vxlanhdr)) ||
+	     (skb->ip_summed != CHECKSUM_NONE &&
+	      !can_checksum_protocol(features, inner_eth_hdr(skb)->h_proto))))
 		return features & ~(NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK);
 
 	return features;
