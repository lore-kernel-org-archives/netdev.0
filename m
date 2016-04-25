From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net-next PATCH 4/8] vxlan: Add checksum check to the features
 check function
Date: Mon, 25 Apr 2016 11:31:20 -0700
Message-ID: <20160425183120.11331.19865.stgit@ahduyck-xeon-server>
References: <20160425182442.11331.88349.stgit@ahduyck-xeon-server>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: talal@mellanox.com, netdev@vger.kernel.org, davem@davemloft.net,
	galp@mellanox.com, ogerlitz@mellanox.com, eranbe@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33333 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933040AbcDYSbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 14:31:22 -0400
Received: by mail-pf0-f181.google.com with SMTP id 206so20645433pfu.0
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 11:31:22 -0700 (PDT)
In-Reply-To: <20160425182442.11331.88349.stgit@ahduyck-xeon-server>
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
