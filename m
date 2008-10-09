From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 5/4] inet: Make tunnel RX/TX byte counters more consistent
Date: Thu, 9 Oct 2008 19:23:08 +0800
Message-ID: <20081009112308.GB19075@gondor.apana.org.au>
References: <20081009070424.GA16684@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Philip Craig <philipc@snapgear.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53230 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758369AbYJILXL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 07:23:11 -0400
Content-Disposition: inline
In-Reply-To: <20081009070424.GA16684@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

inet: Make tunnel RX/TX byte counters more consistent

This patch makes the RX/TX byte counters for IPIP, GRE and SIT more
consistent.  Previously we included the external IP headers on the
way out but not when the packet is inbound.

The new scheme is to count payload only in both directions.  For
IPIP and SIT this simply means the exclusion of the external IP
header.  For GRE this means that we exclude the GRE header as
well.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/ipip.h |    2 +-
 net/ipv4/ip_gre.c  |    7 +++++--
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/include/net/ipip.h b/include/net/ipip.h
index a85bda6..fdf9bd7 100644
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -37,7 +37,7 @@ struct ip_tunnel_prl_entry
 
 #define IPTUNNEL_XMIT() do {						\
 	int err;							\
-	int pkt_len = skb->len;						\
+	int pkt_len = skb->len - skb_transport_offset(skb);		\
 									\
 	skb->ip_summed = CHECKSUM_NONE;					\
 	ip_select_ident(iph, &rt->u.dst, NULL);				\
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 44ed948..0d5e35b 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -477,6 +477,7 @@ static int ipgre_rcv(struct sk_buff *skb)
 	struct ip_tunnel *tunnel;
 	int    offset = 4;
 	__be16 gre_proto;
+	unsigned int len;
 
 	if (!pskb_may_pull(skb, 16))
 		goto drop_nolock;
@@ -567,6 +568,8 @@ static int ipgre_rcv(struct sk_buff *skb)
 			tunnel->i_seqno = seqno + 1;
 		}
 
+		len = skb->len;
+
 		/* Warning: All skb pointers will be invalidated! */
 		if (tunnel->dev->type == ARPHRD_ETHER) {
 			if (!pskb_may_pull(skb, ETH_HLEN)) {
@@ -581,7 +584,7 @@ static int ipgre_rcv(struct sk_buff *skb)
 		}
 
 		stats->rx_packets++;
-		stats->rx_bytes += skb->len;
+		stats->rx_bytes += len;
 		skb->dev = tunnel->dev;
 		dst_release(skb->dst);
 		skb->dst = NULL;
@@ -770,7 +773,7 @@ static int ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 		old_iph = ip_hdr(skb);
 	}
 
-	skb->transport_header = skb->network_header;
+	skb_reset_transport_header(skb);
 	skb_push(skb, gre_hlen);
 	skb_reset_network_header(skb);
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));

-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
