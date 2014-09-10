From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 02/25] netfilter: nft_meta: add pkttype support
Date: Wed, 10 Sep 2014 17:10:19 +0200
Message-ID: <1410361842-4656-3-git-send-email-pablo@netfilter.org>
References: <1410361842-4656-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1410361842-4656-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ana Rey <anarey@gmail.com>

Add pkttype support for ip, ipv6 and inet families of tables.

This allows you to fetch the meta packet type based on the link layer
information. The loopback traffic is a special case, the packet type
is guessed from the network layer header.

No special handling for bridge and arp since we're not going to see
such traffic in the loopback interface.

Joint work with Alvaro Neira Ayuso <alvaroneay@gmail.com>

Signed-off-by: Alvaro Neira Ayuso <alvaroneay@gmail.com>
Signed-off-by: Ana Rey <anarey@gmail.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/uapi/linux/netfilter/nf_tables.h |    2 ++
 net/netfilter/nft_meta.c                 |   28 ++++++++++++++++++++++++++++
 2 files changed, 30 insertions(+)

diff --git a/include/uapi/linux/netfilter/nf_tables.h b/include/uapi/linux/netfilter/nf_tables.h
index 801bdd1..98144cd 100644
--- a/include/uapi/linux/netfilter/nf_tables.h
+++ b/include/uapi/linux/netfilter/nf_tables.h
@@ -571,6 +571,7 @@ enum nft_exthdr_attributes {
  * @NFT_META_L4PROTO: layer 4 protocol number
  * @NFT_META_BRI_IIFNAME: packet input bridge interface name
  * @NFT_META_BRI_OIFNAME: packet output bridge interface name
+ * @NFT_META_PKTTYPE: packet type (skb->pkt_type), special handling for loopback
  */
 enum nft_meta_keys {
 	NFT_META_LEN,
@@ -592,6 +593,7 @@ enum nft_meta_keys {
 	NFT_META_L4PROTO,
 	NFT_META_BRI_IIFNAME,
 	NFT_META_BRI_OIFNAME,
+	NFT_META_PKTTYPE,
 };
 
 /**
diff --git a/net/netfilter/nft_meta.c b/net/netfilter/nft_meta.c
index 852b178..4f2862f 100644
--- a/net/netfilter/nft_meta.c
+++ b/net/netfilter/nft_meta.c
@@ -14,6 +14,9 @@
 #include <linux/netlink.h>
 #include <linux/netfilter.h>
 #include <linux/netfilter/nf_tables.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
 #include <net/dst.h>
 #include <net/sock.h>
 #include <net/tcp_states.h> /* for TCP_TIME_WAIT */
@@ -124,6 +127,30 @@ void nft_meta_get_eval(const struct nft_expr *expr,
 		dest->data[0] = skb->secmark;
 		break;
 #endif
+	case NFT_META_PKTTYPE:
+		if (skb->pkt_type != PACKET_LOOPBACK) {
+			dest->data[0] = skb->pkt_type;
+			break;
+		}
+
+		switch (pkt->ops->pf) {
+		case NFPROTO_IPV4:
+			if (ipv4_is_multicast(ip_hdr(skb)->daddr))
+				dest->data[0] = PACKET_MULTICAST;
+			else
+				dest->data[0] = PACKET_BROADCAST;
+			break;
+		case NFPROTO_IPV6:
+			if (ipv6_hdr(skb)->daddr.s6_addr[0] == 0xFF)
+				dest->data[0] = PACKET_MULTICAST;
+			else
+				dest->data[0] = PACKET_BROADCAST;
+			break;
+		default:
+			WARN_ON(1);
+			goto err;
+		}
+		break;
 	default:
 		WARN_ON(1);
 		goto err;
@@ -195,6 +222,7 @@ int nft_meta_get_init(const struct nft_ctx *ctx,
 #ifdef CONFIG_NETWORK_SECMARK
 	case NFT_META_SECMARK:
 #endif
+	case NFT_META_PKTTYPE:
 		break;
 	default:
 		return -EOPNOTSUPP;
-- 
1.7.10.4

