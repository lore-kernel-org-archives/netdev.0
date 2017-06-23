From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 6/6] esp6_offload: Fix IP6CB(skb)->nhoff for ESP GRO
Date: Fri, 23 Jun 2017 09:06:34 +0200
Message-ID: <1498201594-10835-7-git-send-email-steffen.klassert@secunet.com>
References: <1498201594-10835-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:47088 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751238AbdFWHGo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 23 Jun 2017 03:06:44 -0400
In-Reply-To: <1498201594-10835-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yossi Kuperman <yossiku@mellanox.com>

IP6CB(skb)->nhoff is the offset of the nexthdr field in an IPv6
header, unless there are extension headers present, in which case
nhoff points to the nexthdr field of the last extension header.

In non-GRO code path, nhoff is set by ipv6_rcv before any XFRM code
is executed. Conversely, in GRO code path (when esp6_offload is loaded),
nhoff is not set. The following functions fail to read the correct value
and eventually the packet is dropped:

    xfrm6_transport_finish
    xfrm6_tunnel_input
    xfrm6_rcv_tnl

Set nhoff to the proper offset of nexthdr in esp6_gro_receive.

Fixes: 7785bba299a8 ("esp: Add a software GRO codepath")
Signed-off-by: Yossi Kuperman <yossiku@mellanox.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/esp6_offload.c | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/net/ipv6/esp6_offload.c b/net/ipv6/esp6_offload.c
index d950d43..f02f131 100644
--- a/net/ipv6/esp6_offload.c
+++ b/net/ipv6/esp6_offload.c
@@ -30,6 +30,25 @@
 #include <net/ipv6.h>
 #include <linux/icmpv6.h>
 
+static __u16 esp6_nexthdr_esp_offset(struct ipv6hdr *ipv6_hdr, int nhlen)
+{
+	int off = sizeof(struct ipv6hdr);
+	struct ipv6_opt_hdr *exthdr;
+
+	if (likely(ipv6_hdr->nexthdr == NEXTHDR_ESP))
+		return offsetof(struct ipv6hdr, nexthdr);
+
+	while (off < nhlen) {
+		exthdr = (void *)ipv6_hdr + off;
+		if (exthdr->nexthdr == NEXTHDR_ESP)
+			return off;
+
+		off += ipv6_optlen(exthdr);
+	}
+
+	return 0;
+}
+
 static struct sk_buff **esp6_gro_receive(struct sk_buff **head,
 					 struct sk_buff *skb)
 {
@@ -38,6 +57,7 @@ static struct sk_buff **esp6_gro_receive(struct sk_buff **head,
 	struct xfrm_state *x;
 	__be32 seq;
 	__be32 spi;
+	int nhoff;
 	int err;
 
 	skb_pull(skb, offset);
@@ -72,6 +92,11 @@ static struct sk_buff **esp6_gro_receive(struct sk_buff **head,
 
 	xo->flags |= XFRM_GRO;
 
+	nhoff = esp6_nexthdr_esp_offset(ipv6_hdr(skb), offset);
+	if (!nhoff)
+		goto out;
+
+	IP6CB(skb)->nhoff = nhoff;
 	XFRM_TUNNEL_SKB_CB(skb)->tunnel.ip6 = NULL;
 	XFRM_SPI_SKB_CB(skb)->family = AF_INET6;
 	XFRM_SPI_SKB_CB(skb)->daddroff = offsetof(struct ipv6hdr, daddr);
-- 
2.7.4
