From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net PATCH 2/2] vxlan: Add checksum check to the features check
 function
Date: Mon, 02 May 2016 09:25:16 -0700
Message-ID: <20160502162516.11701.1037.stgit@ahduyck-xeon-server>
References: <20160502161621.11701.9271.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, ogerlitz@mellanox.com, davem@davemloft.net,
	alexander.duyck@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:34030 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753673AbcEBQZX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 May 2016 12:25:23 -0400
Received: by mail-pa0-f43.google.com with SMTP id r5so77621722pag.1
        for <netdev@vger.kernel.org>; Mon, 02 May 2016 09:25:23 -0700 (PDT)
In-Reply-To: <20160502161621.11701.9271.stgit@ahduyck-xeon-server>
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
index 73ed2e951c02..35437c779da8 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -252,7 +252,9 @@ static inline netdev_features_t vxlan_features_check(struct sk_buff *skb,
 	    (skb->inner_protocol_type != ENCAP_TYPE_ETHER ||
 	     skb->inner_protocol != htons(ETH_P_TEB) ||
 	     (skb_inner_mac_header(skb) - skb_transport_header(skb) !=
-	      sizeof(struct udphdr) + sizeof(struct vxlanhdr))))
+	      sizeof(struct udphdr) + sizeof(struct vxlanhdr)) ||
+	     (skb->ip_summed != CHECKSUM_NONE &&
+	      !can_checksum_protocol(features, inner_eth_hdr(skb)->h_proto))))
 		return features & ~(NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK);
 
 	return features;
