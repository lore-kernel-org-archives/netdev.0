From: yossiku@mellanox.com
Subject: [PATCH net 2/2] esp6_offload: Fix IP6CB(skb)->nhoff for ESP GRO
Date: Mon, 19 Jun 2017 11:33:21 +0300
Message-ID: <1497861201-30262-2-git-send-email-yossiku@mellanox.com>
References: <1497861201-30262-1-git-send-email-yossiku@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yevgeny Kliteynik <kliteyn@mellanox.com>,
        Boris Pismenny <borisp@mellanox.com>,
        Ilan Tayari <ilant@mellanox.com>,
        Yossi Kuperman <yossiku@mellanox.com>
To: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-he1eur01on0077.outbound.protection.outlook.com ([104.47.0.77]:11136
        "EHLO EUR01-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753428AbdFSId7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Jun 2017 04:33:59 -0400
In-Reply-To: <1497861201-30262-1-git-send-email-yossiku@mellanox.com>
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
2.8.1
