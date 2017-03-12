From: Luiz Augusto von Dentz <luiz.dentz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v7 5/6] 6lowpan: Use netdev addr_len to determine lladdr len
Date: Sun, 12 Mar 2017 10:19:37 +0200
Message-ID: <20170312081938.11700-6-luiz.dentz@gmail.com>
References: <20170312081938.11700-1-luiz.dentz@gmail.com>
Cc: patrik.flykt-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, aar-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
        jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170312081938.11700-1-luiz.dentz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Luiz Augusto von Dentz <luiz.von.dentz-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

This allow technologies such as Bluetooth to use its native lladdr which
is eui48 instead of eui64 which was expected by functions like
lowpan_header_decompress and lowpan_header_compress.

Signed-off-by: Luiz Augusto von Dentz <luiz.von.dentz-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Reviewed-by: Stefan Schmidt <stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
---
 include/net/6lowpan.h   | 19 +++++++++++++++++++
 net/6lowpan/iphc.c      | 49 ++++++++++++++++++++++++++++++++++++++-----------
 net/bluetooth/6lowpan.c | 42 ++++++------------------------------------
 3 files changed, 63 insertions(+), 47 deletions(-)

diff --git a/include/net/6lowpan.h b/include/net/6lowpan.h
index 5ab4c99..c5792cb 100644
--- a/include/net/6lowpan.h
+++ b/include/net/6lowpan.h
@@ -198,6 +198,25 @@ static inline void lowpan_iphc_uncompress_eui64_lladdr(struct in6_addr *ipaddr,
 	ipaddr->s6_addr[8] ^= 0x02;
 }
 
+static inline void lowpan_iphc_uncompress_eui48_lladdr(struct in6_addr *ipaddr,
+						       const void *lladdr)
+{
+	/* fe:80::XXXX:XXff:feXX:XXXX
+	 *        \_________________/
+	 *              hwaddr
+	 */
+	ipaddr->s6_addr[0] = 0xFE;
+	ipaddr->s6_addr[1] = 0x80;
+	memcpy(&ipaddr->s6_addr[8], lladdr, 3);
+	ipaddr->s6_addr[11] = 0xFF;
+	ipaddr->s6_addr[12] = 0xFE;
+	memcpy(&ipaddr->s6_addr[13], lladdr + 3, 3);
+	/* second bit-flip (Universe/Local)
+	 * is done according RFC2464
+	 */
+	ipaddr->s6_addr[8] ^= 0x02;
+}
+
 #ifdef DEBUG
 /* print data in line */
 static inline void raw_dump_inline(const char *caller, char *msg,
diff --git a/net/6lowpan/iphc.c b/net/6lowpan/iphc.c
index fb5f6fa..6b1042e 100644
--- a/net/6lowpan/iphc.c
+++ b/net/6lowpan/iphc.c
@@ -278,6 +278,23 @@ lowpan_iphc_ctx_get_by_mcast_addr(const struct net_device *dev,
 	return ret;
 }
 
+static void lowpan_iphc_uncompress_lladdr(const struct net_device *dev,
+					  struct in6_addr *ipaddr,
+					  const void *lladdr)
+{
+	switch (dev->addr_len) {
+	case ETH_ALEN:
+		lowpan_iphc_uncompress_eui48_lladdr(ipaddr, lladdr);
+		break;
+	case EUI64_ADDR_LEN:
+		lowpan_iphc_uncompress_eui64_lladdr(ipaddr, lladdr);
+		break;
+	default:
+		WARN_ON_ONCE(1);
+		break;
+	}
+}
+
 /* Uncompress address function for source and
  * destination address(non-multicast).
  *
@@ -320,7 +337,7 @@ static int lowpan_iphc_uncompress_addr(struct sk_buff *skb,
 			lowpan_iphc_uncompress_802154_lladdr(ipaddr, lladdr);
 			break;
 		default:
-			lowpan_iphc_uncompress_eui64_lladdr(ipaddr, lladdr);
+			lowpan_iphc_uncompress_lladdr(dev, ipaddr, lladdr);
 			break;
 		}
 		break;
@@ -381,7 +398,7 @@ static int lowpan_iphc_uncompress_ctx_addr(struct sk_buff *skb,
 			lowpan_iphc_uncompress_802154_lladdr(ipaddr, lladdr);
 			break;
 		default:
-			lowpan_iphc_uncompress_eui64_lladdr(ipaddr, lladdr);
+			lowpan_iphc_uncompress_lladdr(dev, ipaddr, lladdr);
 			break;
 		}
 		ipv6_addr_prefix_copy(ipaddr, &ctx->pfx, ctx->plen);
@@ -810,6 +827,21 @@ lowpan_iphc_compress_ctx_802154_lladdr(const struct in6_addr *ipaddr,
 	return lladdr_compress;
 }
 
+static bool lowpan_iphc_addr_equal(const struct net_device *dev,
+				   const struct lowpan_iphc_ctx *ctx,
+				   const struct in6_addr *ipaddr,
+				   const void *lladdr)
+{
+	struct in6_addr tmp = {};
+
+	lowpan_iphc_uncompress_lladdr(dev, &tmp, lladdr);
+
+	if (ctx)
+		ipv6_addr_prefix_copy(&tmp, &ctx->pfx, ctx->plen);
+
+	return ipv6_addr_equal(&tmp, ipaddr);
+}
+
 static u8 lowpan_compress_ctx_addr(u8 **hc_ptr, const struct net_device *dev,
 				   const struct in6_addr *ipaddr,
 				   const struct lowpan_iphc_ctx *ctx,
@@ -827,13 +859,7 @@ static u8 lowpan_compress_ctx_addr(u8 **hc_ptr, const struct net_device *dev,
 		}
 		break;
 	default:
-		/* check for SAM/DAM = 11 */
-		memcpy(&tmp.s6_addr[8], lladdr, EUI64_ADDR_LEN);
-		/* second bit-flip (Universe/Local) is done according RFC2464 */
-		tmp.s6_addr[8] ^= 0x02;
-		/* context information are always used */
-		ipv6_addr_prefix_copy(&tmp, &ctx->pfx, ctx->plen);
-		if (ipv6_addr_equal(&tmp, ipaddr)) {
+		if (lowpan_iphc_addr_equal(dev, ctx, ipaddr, lladdr)) {
 			dam = LOWPAN_IPHC_DAM_11;
 			goto out;
 		}
@@ -929,11 +955,12 @@ static u8 lowpan_compress_addr_64(u8 **hc_ptr, const struct net_device *dev,
 		}
 		break;
 	default:
-		if (is_addr_mac_addr_based(ipaddr, lladdr)) {
-			dam = LOWPAN_IPHC_DAM_11; /* 0-bits */
+		if (lowpan_iphc_addr_equal(dev, NULL, ipaddr, lladdr)) {
+			dam = LOWPAN_IPHC_DAM_11;
 			pr_debug("address compression 0 bits\n");
 			goto out;
 		}
+
 		break;
 	}
 
diff --git a/net/bluetooth/6lowpan.c b/net/bluetooth/6lowpan.c
index 1456b01..0b68cfc 100644
--- a/net/bluetooth/6lowpan.c
+++ b/net/bluetooth/6lowpan.c
@@ -64,7 +64,7 @@ struct lowpan_peer {
 	struct l2cap_chan *chan;
 
 	/* peer addresses in various formats */
-	unsigned char eui64_addr[EUI64_ADDR_LEN];
+	unsigned char lladdr[ETH_ALEN];
 	struct in6_addr peer_addr;
 };
 
@@ -80,8 +80,6 @@ struct lowpan_btle_dev {
 	struct delayed_work notify_peers;
 };
 
-static void set_addr(u8 *eui, u8 *addr, u8 addr_type);
-
 static inline struct lowpan_btle_dev *
 lowpan_btle_dev(const struct net_device *netdev)
 {
@@ -277,7 +275,6 @@ static int iphc_decompress(struct sk_buff *skb, struct net_device *netdev,
 	const u8 *saddr;
 	struct lowpan_btle_dev *dev;
 	struct lowpan_peer *peer;
-	unsigned char eui64_daddr[EUI64_ADDR_LEN];
 
 	dev = lowpan_btle_dev(netdev);
 
@@ -287,10 +284,9 @@ static int iphc_decompress(struct sk_buff *skb, struct net_device *netdev,
 	if (!peer)
 		return -EINVAL;
 
-	saddr = peer->eui64_addr;
-	set_addr(&eui64_daddr[0], chan->src.b, chan->src_type);
+	saddr = peer->lladdr;
 
-	return lowpan_header_decompress(skb, netdev, &eui64_daddr, saddr);
+	return lowpan_header_decompress(skb, netdev, netdev->dev_addr, saddr);
 }
 
 static int recv_pkt(struct sk_buff *skb, struct net_device *dev,
@@ -477,7 +473,7 @@ static int setup_header(struct sk_buff *skb, struct net_device *netdev,
 			}
 		}
 
-		daddr = peer->eui64_addr;
+		daddr = peer->lladdr;
 		*peer_addr = addr;
 		*peer_addr_type = addr_type;
 		lowpan_cb(skb)->chan = peer->chan;
@@ -663,27 +659,6 @@ static struct device_type bt_type = {
 	.name	= "bluetooth",
 };
 
-static void set_addr(u8 *eui, u8 *addr, u8 addr_type)
-{
-	/* addr is the BT address in little-endian format */
-	eui[0] = addr[5];
-	eui[1] = addr[4];
-	eui[2] = addr[3];
-	eui[3] = 0xFF;
-	eui[4] = 0xFE;
-	eui[5] = addr[2];
-	eui[6] = addr[1];
-	eui[7] = addr[0];
-
-	/* Universal/local bit set, BT 6lowpan draft ch. 3.2.1 */
-	if (addr_type == BDADDR_LE_PUBLIC)
-		eui[0] &= ~0x02;
-	else
-		eui[0] |= 0x02;
-
-	BT_DBG("type %d addr %*phC", addr_type, 8, eui);
-}
-
 static void ifup(struct net_device *netdev)
 {
 	int err;
@@ -762,14 +737,9 @@ static struct l2cap_chan *add_peer_chan(struct l2cap_chan *chan,
 	peer->chan = chan;
 	memset(&peer->peer_addr, 0, sizeof(struct in6_addr));
 
-	/* RFC 2464 ch. 5 */
-	peer->peer_addr.s6_addr[0] = 0xFE;
-	peer->peer_addr.s6_addr[1] = 0x80;
-	set_addr((u8 *)&peer->peer_addr.s6_addr + 8, chan->dst.b,
-		 chan->dst_type);
+	baswap((void *)peer->lladdr, &chan->dst);
 
-	memcpy(&peer->eui64_addr, (u8 *)&peer->peer_addr.s6_addr + 8,
-	       EUI64_ADDR_LEN);
+	lowpan_iphc_uncompress_eui48_lladdr(&peer->peer_addr, peer->lladdr);
 
 	/* IPv6 address needs to have the U/L bit set properly so toggle
 	 * it back here.
-- 
2.9.3
