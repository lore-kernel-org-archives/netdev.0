From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 6/6] vti: Use the tunnel mark for lookup in the error handlers.
Date: Thu, 15 May 2014 09:07:56 +0200
Message-ID: <1400137676-27565-7-git-send-email-steffen.klassert@secunet.com>
References: <1400137676-27565-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44810 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753792AbaEOHIX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 03:08:23 -0400
In-Reply-To: <1400137676-27565-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to use the mark we get from the tunnels o_key to
lookup the right vti state in the error handlers. This patch
ensures that.

Fixes: df3893c1 ("vti: Update the ipv4 side to use it's own receive hook.")
Fixes: fa9ad96d ("vti6: Update the ipv6 side to use its own receive hook.")
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/ip_vti.c  |    5 ++++-
 net/ipv6/ip6_vti.c |    5 ++++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index cd62596..d3f64d7 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -239,6 +239,7 @@ static netdev_tx_t vti_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 static int vti4_err(struct sk_buff *skb, u32 info)
 {
 	__be32 spi;
+	__u32 mark;
 	struct xfrm_state *x;
 	struct ip_tunnel *tunnel;
 	struct ip_esp_hdr *esph;
@@ -254,6 +255,8 @@ static int vti4_err(struct sk_buff *skb, u32 info)
 	if (!tunnel)
 		return -1;
 
+	mark = be32_to_cpu(tunnel->parms.o_key);
+
 	switch (protocol) {
 	case IPPROTO_ESP:
 		esph = (struct ip_esp_hdr *)(skb->data+(iph->ihl<<2));
@@ -281,7 +284,7 @@ static int vti4_err(struct sk_buff *skb, u32 info)
 		return 0;
 	}
 
-	x = xfrm_state_lookup(net, skb->mark, (const xfrm_address_t *)&iph->daddr,
+	x = xfrm_state_lookup(net, mark, (const xfrm_address_t *)&iph->daddr,
 			      spi, protocol, AF_INET);
 	if (!x)
 		return 0;
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index a511003..6cc9f93 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -511,6 +511,7 @@ static int vti6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		    u8 type, u8 code, int offset, __be32 info)
 {
 	__be32 spi;
+	__u32 mark;
 	struct xfrm_state *x;
 	struct ip6_tnl *t;
 	struct ip_esp_hdr *esph;
@@ -524,6 +525,8 @@ static int vti6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	if (!t)
 		return -1;
 
+	mark = be32_to_cpu(t->parms.o_key);
+
 	switch (protocol) {
 	case IPPROTO_ESP:
 		esph = (struct ip_esp_hdr *)(skb->data + offset);
@@ -545,7 +548,7 @@ static int vti6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 	    type != NDISC_REDIRECT)
 		return 0;
 
-	x = xfrm_state_lookup(net, skb->mark, (const xfrm_address_t *)&iph->daddr,
+	x = xfrm_state_lookup(net, mark, (const xfrm_address_t *)&iph->daddr,
 			      spi, protocol, AF_INET6);
 	if (!x)
 		return 0;
-- 
1.7.9.5
