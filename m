From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/32] netfilter: bridge: re-order check_hbh_len()
Date: Mon, 15 Jun 2015 23:26:04 +0200
Message-ID: <1434403589-24796-8-git-send-email-pablo@netfilter.org>
References: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:58801 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756173AbbFOVVc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Jun 2015 17:21:32 -0400
In-Reply-To: <1434403589-24796-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bernhard Thaler <bernhard.thaler@wvnet.at>

Prepare check_hbh_len() to be called from newly introduced
br_validate_ipv6() in next commit.

Signed-off-by: Bernhard Thaler <bernhard.thaler@wvnet.at>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/bridge/br_netfilter.c |  111 +++++++++++++++++++++++----------------------
 1 file changed, 56 insertions(+), 55 deletions(-)

diff --git a/net/bridge/br_netfilter.c b/net/bridge/br_netfilter.c
index 962d5f8..d201ea4 100644
--- a/net/bridge/br_netfilter.c
+++ b/net/bridge/br_netfilter.c
@@ -264,6 +264,62 @@ drop:
 	return -1;
 }
 
+/* We only check the length. A bridge shouldn't do any hop-by-hop stuff
+ * anyway
+ */
+static int check_hbh_len(struct sk_buff *skb)
+{
+	unsigned char *raw = (u8 *)(ipv6_hdr(skb) + 1);
+	u32 pkt_len;
+	const unsigned char *nh = skb_network_header(skb);
+	int off = raw - nh;
+	int len = (raw[1] + 1) << 3;
+
+	if ((raw + len) - skb->data > skb_headlen(skb))
+		goto bad;
+
+	off += 2;
+	len -= 2;
+
+	while (len > 0) {
+		int optlen = nh[off + 1] + 2;
+
+		switch (nh[off]) {
+		case IPV6_TLV_PAD1:
+			optlen = 1;
+			break;
+
+		case IPV6_TLV_PADN:
+			break;
+
+		case IPV6_TLV_JUMBO:
+			if (nh[off + 1] != 4 || (off & 3) != 2)
+				goto bad;
+			pkt_len = ntohl(*(__be32 *)(nh + off + 2));
+			if (pkt_len <= IPV6_MAXPLEN ||
+			    ipv6_hdr(skb)->payload_len)
+				goto bad;
+			if (pkt_len > skb->len - sizeof(struct ipv6hdr))
+				goto bad;
+			if (pskb_trim_rcsum(skb,
+					    pkt_len + sizeof(struct ipv6hdr)))
+				goto bad;
+			nh = skb_network_header(skb);
+			break;
+		default:
+			if (optlen > len)
+				goto bad;
+			break;
+		}
+		off += optlen;
+		len -= optlen;
+	}
+	if (len == 0)
+		return 0;
+bad:
+	return -1;
+}
+
 static void nf_bridge_update_protocol(struct sk_buff *skb)
 {
 	switch (skb->nf_bridge->orig_proto) {
@@ -549,61 +605,6 @@ static struct net_device *setup_pre_routing(struct sk_buff *skb)
 	return skb->dev;
 }
 
-/* We only check the length. A bridge shouldn't do any hop-by-hop stuff anyway */
-static int check_hbh_len(struct sk_buff *skb)
-{
-	unsigned char *raw = (u8 *)(ipv6_hdr(skb) + 1);
-	u32 pkt_len;
-	const unsigned char *nh = skb_network_header(skb);
-	int off = raw - nh;
-	int len = (raw[1] + 1) << 3;
-
-	if ((raw + len) - skb->data > skb_headlen(skb))
-		goto bad;
-
-	off += 2;
-	len -= 2;
-
-	while (len > 0) {
-		int optlen = nh[off + 1] + 2;
-
-		switch (nh[off]) {
-		case IPV6_TLV_PAD1:
-			optlen = 1;
-			break;
-
-		case IPV6_TLV_PADN:
-			break;
-
-		case IPV6_TLV_JUMBO:
-			if (nh[off + 1] != 4 || (off & 3) != 2)
-				goto bad;
-			pkt_len = ntohl(*(__be32 *) (nh + off + 2));
-			if (pkt_len <= IPV6_MAXPLEN ||
-			    ipv6_hdr(skb)->payload_len)
-				goto bad;
-			if (pkt_len > skb->len - sizeof(struct ipv6hdr))
-				goto bad;
-			if (pskb_trim_rcsum(skb,
-					    pkt_len + sizeof(struct ipv6hdr)))
-				goto bad;
-			nh = skb_network_header(skb);
-			break;
-		default:
-			if (optlen > len)
-				goto bad;
-			break;
-		}
-		off += optlen;
-		len -= optlen;
-	}
-	if (len == 0)
-		return 0;
-bad:
-	return -1;
-
-}
-
 /* Replicate the checks that IPv6 does on packet reception and pass the packet
  * to ip6tables, which doesn't support NAT, so things are fairly simple. */
 static unsigned int br_nf_pre_routing_ipv6(const struct nf_hook_ops *ops,
-- 
1.7.10.4
