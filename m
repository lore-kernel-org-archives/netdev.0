From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH net-next] xfrm: Call IP receive handler directly for inbound tunnel-mode packets
Date: Sun, 1 Jan 2012 22:32:34 -0500
Message-ID: <1325475154-15997-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ward <david.ward@ll.mit.edu>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:49565 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751446Ab2ABDoT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Jan 2012 22:44:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For IPsec tunnel mode (or BEET mode), after inbound packets are xfrm'ed,
call the IPv4/IPv6 receive handler directly instead of calling netif_rx.
In addition to avoiding unneeded re-processing of the MAC layer, packets
will not be received a second time on network taps. (Note that outbound
packets are only received on network taps post-xfrm, but inbound packets
were being received both pre- and post-xfrm. So now network taps will
receive packets in either direction only once, in the form that they go
"over the wire".)

Signed-off-by: David Ward <david.ward@ll.mit.edu>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
---
 include/net/xfrm.h     |    3 +++
 net/ipv4/xfrm4_input.c |    5 +++++
 net/ipv4/xfrm4_state.c |    1 +
 net/ipv6/xfrm6_input.c |    5 +++++
 net/ipv6/xfrm6_state.c |    1 +
 net/xfrm/xfrm_input.c  |    4 +++-
 6 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index b203e14..423a779 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -329,6 +329,7 @@ struct xfrm_state_afinfo {
 						 struct sk_buff *skb);
 	int			(*extract_output)(struct xfrm_state *x,
 						  struct sk_buff *skb);
+	int			(*tunnel_finish)(struct sk_buff *skb);
 	int			(*transport_finish)(struct sk_buff *skb,
 						    int async);
 };
@@ -1453,6 +1454,7 @@ extern int xfrm4_extract_header(struct sk_buff *skb);
 extern int xfrm4_extract_input(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
 			   int encap_type);
+extern int xfrm4_tunnel_finish(struct sk_buff *skb);
 extern int xfrm4_transport_finish(struct sk_buff *skb, int async);
 extern int xfrm4_rcv(struct sk_buff *skb);
 
@@ -1470,6 +1472,7 @@ extern int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler, unsigned short f
 extern int xfrm6_extract_header(struct sk_buff *skb);
 extern int xfrm6_extract_input(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi);
+extern int xfrm6_tunnel_finish(struct sk_buff *skb);
 extern int xfrm6_transport_finish(struct sk_buff *skb, int async);
 extern int xfrm6_rcv(struct sk_buff *skb);
 extern int xfrm6_input_addr(struct sk_buff *skb, xfrm_address_t *daddr,
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index 06814b6..4903a01 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -46,6 +46,11 @@ int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
 }
 EXPORT_SYMBOL(xfrm4_rcv_encap);
 
+int xfrm4_tunnel_finish(struct sk_buff *skb)
+{
+	return ip_rcv(skb, skb->dev, NULL, skb->dev);
+}
+
 int xfrm4_transport_finish(struct sk_buff *skb, int async)
 {
 	struct iphdr *iph = ip_hdr(skb);
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index 9258e75..1931c42 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -82,6 +82,7 @@ static struct xfrm_state_afinfo xfrm4_state_afinfo = {
 	.output_finish		= xfrm4_output_finish,
 	.extract_input		= xfrm4_extract_input,
 	.extract_output		= xfrm4_extract_output,
+	.tunnel_finish		= xfrm4_tunnel_finish,
 	.transport_finish	= xfrm4_transport_finish,
 };
 
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index f8c3cf8..dc898a8 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -29,6 +29,11 @@ int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
 }
 EXPORT_SYMBOL(xfrm6_rcv_spi);
 
+int xfrm6_tunnel_finish(struct sk_buff *skb)
+{
+	return ipv6_rcv(skb, skb->dev, NULL, skb->dev);
+}
+
 int xfrm6_transport_finish(struct sk_buff *skb, int async)
 {
 	skb_network_header(skb)[IP6CB(skb)->nhoff] =
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index f2d72b8..51d31c3 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -182,6 +182,7 @@ static struct xfrm_state_afinfo xfrm6_state_afinfo = {
 	.output_finish		= xfrm6_output_finish,
 	.extract_input		= xfrm6_extract_input,
 	.extract_output		= xfrm6_extract_output,
+	.tunnel_finish		= xfrm6_tunnel_finish,
 	.transport_finish	= xfrm6_transport_finish,
 };
 
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 54a0dc2..571af71 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -262,7 +262,9 @@ resume:
 
 	if (decaps) {
 		skb_dst_drop(skb);
-		netif_rx(skb);
+		skb_reset_network_header(skb);
+		skb_reset_transport_header(skb);
+		x->inner_mode->afinfo->tunnel_finish(skb);
 		return 0;
 	} else {
 		return x->inner_mode->afinfo->transport_finish(skb, async);
-- 
1.7.4.1
