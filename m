From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/2] xfrm6: Don't call icmpv6_send on local error
Date: Tue, 11 Oct 2011 13:44:30 +0200
Message-ID: <20111011114430.GJ1830@secunet.com>
References: <20111011114251.GH1830@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53352 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751640Ab1JKLoc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 07:44:32 -0400
Content-Disposition: inline
In-Reply-To: <20111011114251.GH1830@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calling icmpv6_send() on a local message size error leads to
an incorrect update of the path mtu. So use xfrm6_local_rxpmtu()
to notify about the pmtu if the IPV6_DONTFRAG socket option is
set on an udp or raw socket, according RFC 3542 and use
ipv6_local_error() otherwise.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/xfrm6_output.c |   56 +++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 54 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 49a91c5..faae417 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -28,6 +28,43 @@ int xfrm6_find_1stfragopt(struct xfrm_state *x, struct sk_buff *skb,
 
 EXPORT_SYMBOL(xfrm6_find_1stfragopt);
 
+static int xfrm6_local_dontfrag(struct sk_buff *skb)
+{
+	int proto;
+	struct sock *sk = skb->sk;
+
+	if (sk) {
+		proto = sk->sk_protocol;
+
+		if (proto == IPPROTO_UDP || proto == IPPROTO_RAW)
+			return inet6_sk(sk)->dontfrag;
+	}
+
+	return 0;
+}
+
+static void xfrm6_local_rxpmtu(struct sk_buff *skb, u32 mtu)
+{
+	struct flowi6 fl6;
+	struct sock *sk = skb->sk;
+
+	fl6.flowi6_oif = sk->sk_bound_dev_if;
+	ipv6_addr_copy(&fl6.daddr, &ipv6_hdr(skb)->daddr);
+
+	ipv6_local_rxpmtu(sk, &fl6, mtu);
+}
+
+static void xfrm6_local_error(struct sk_buff *skb, u32 mtu)
+{
+	struct flowi6 fl6;
+	struct sock *sk = skb->sk;
+
+	fl6.fl6_dport = inet_sk(sk)->inet_dport;
+	ipv6_addr_copy(&fl6.daddr, &ipv6_hdr(skb)->daddr);
+
+	ipv6_local_error(sk, EMSGSIZE, &fl6, mtu);
+}
+
 static int xfrm6_tunnel_check_size(struct sk_buff *skb)
 {
 	int mtu, ret = 0;
@@ -39,7 +76,13 @@ static int xfrm6_tunnel_check_size(struct sk_buff *skb)
 
 	if (!skb->local_df && skb->len > mtu) {
 		skb->dev = dst->dev;
-		icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
+
+		if (xfrm6_local_dontfrag(skb))
+			xfrm6_local_rxpmtu(skb, mtu);
+		else if (skb->sk)
+			xfrm6_local_error(skb, mtu);
+		else
+			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		ret = -EMSGSIZE;
 	}
 
@@ -93,9 +136,18 @@ static int __xfrm6_output(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb_dst(skb);
 	struct xfrm_state *x = dst->xfrm;
+	int mtu = ip6_skb_dst_mtu(skb);
+
+	if (skb->len > mtu && xfrm6_local_dontfrag(skb)) {
+		xfrm6_local_rxpmtu(skb, mtu);
+		return -EMSGSIZE;
+	} else if (!skb->local_df && skb->len > mtu && skb->sk) {
+		xfrm6_local_error(skb, mtu);
+		return -EMSGSIZE;
+	}
 
 	if ((x && x->props.mode == XFRM_MODE_TUNNEL) &&
-	    ((skb->len > ip6_skb_dst_mtu(skb) && !skb_is_gso(skb)) ||
+	    ((skb->len > mtu && !skb_is_gso(skb)) ||
 		dst_allfrag(skb_dst(skb)))) {
 			return ip6_fragment(skb, x->outer_mode->afinfo->output_finish);
 	}
-- 
1.7.0.4
