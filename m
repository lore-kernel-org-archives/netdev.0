From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RFC] xfrm{4,6}: only report errors back to local sockets if we don't cross address family
Date: Sat, 10 Aug 2013 18:16:29 +0200
Message-ID: <20130810161629.GR14001@order.stressinduktion.org>
References: <20130729145017.GD2490@order.stressinduktion.org> <20130730082118.GA25511@secunet.com> <20130730083017.GA7068@order.stressinduktion.org> <20130730102611.GB25511@secunet.com> <20130801081150.GF3688@order.stressinduktion.org> <20130801100522.GC25511@secunet.com> <20130808224440.GJ14001@order.stressinduktion.org> <1376002677.4004.139.camel@edumazet-glaptop> <20130808230620.GK14001@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org, vi0oss@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:43591 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966333Ab3HJQQb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Aug 2013 12:16:31 -0400
Content-Disposition: inline
In-Reply-To: <20130808230620.GK14001@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 09, 2013 at 01:06:20AM +0200, Hannes Frederic Sowa wrote:
> I will check if the skb->encapsulated bit could help. Actually I don't
> know what the correct behaviour for error reporting should be in the end,
> maybe: dispatch packet back to tunnel interface, let tunnel interface
> decapsulate the inner packet and use this inner header to inform the
> original socket about the error.

Seems skb->encapsulated helps, but I still have to wire it up for the ipv6
tunnels.

I just prototyped this patch, but I fear I now introduced a dependency
from core xfrm to ipv6, which I would like to have prevented (this would
even happen if I put xfrm_local_error in a header file). Is this actually
a problem? I fear so. The other way would be to put the local_error
handler as function pointers somewhere reachable from struct sock.

[PATCH RFC] xfrm: make local error reporting more robust

In xfrm4 and xfrm6 we need to take care about sockets of the other
address family. This could happen because a 6in4 or 4in6 tunnel could
get protected by ipsec.

If the skb->encapsulation bit is set, use the addresses of the inner ip
header instead of the outer one. This is currently working for IPv4 and
will be wired up for IPv6 in a future patch.

(intentionally removed signed-off)

Reported-by: <vi0oss@gmail.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h      |  1 +
 net/ipv4/xfrm4_output.c |  3 +--
 net/ipv6/xfrm6_output.c | 18 +++++-------------
 net/xfrm/xfrm_output.c  | 26 ++++++++++++++++++++++++++
 4 files changed, 33 insertions(+), 15 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 94ce082..11b73cb 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1476,6 +1476,7 @@ extern int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi,
 extern int xfrm_input_resume(struct sk_buff *skb, int nexthdr);
 extern int xfrm_output_resume(struct sk_buff *skb, int err);
 extern int xfrm_output(struct sk_buff *skb);
+extern void xfrm_local_error(struct sk_buff *skb, unsigned int mtu);
 extern int xfrm_inner_extract_output(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm4_extract_header(struct sk_buff *skb);
 extern int xfrm4_extract_input(struct xfrm_state *x, struct sk_buff *skb);
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 327a617..cfc386f 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -33,8 +33,7 @@ static int xfrm4_tunnel_check_size(struct sk_buff *skb)
 	mtu = dst_mtu(dst);
 	if (skb->len > mtu) {
 		if (skb->sk)
-			ip_local_error(skb->sk, EMSGSIZE, ip_hdr(skb)->daddr,
-				       inet_sk(skb->sk)->inet_dport, mtu);
+			xfrm_local_error(skb, mtu);
 		else
 			icmp_send(skb, ICMP_DEST_UNREACH,
 				  ICMP_FRAG_NEEDED, htonl(mtu));
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 8755a30..7970965 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -48,23 +48,15 @@ static void xfrm6_local_rxpmtu(struct sk_buff *skb, u32 mtu)
 	struct flowi6 fl6;
 	struct sock *sk = skb->sk;
 
+	if (sk->sk_family != AF_INET6)
+		return;
+
 	fl6.flowi6_oif = sk->sk_bound_dev_if;
 	fl6.daddr = ipv6_hdr(skb)->daddr;
 
 	ipv6_local_rxpmtu(sk, &fl6, mtu);
 }
 
-static void xfrm6_local_error(struct sk_buff *skb, u32 mtu)
-{
-	struct flowi6 fl6;
-	struct sock *sk = skb->sk;
-
-	fl6.fl6_dport = inet_sk(sk)->inet_dport;
-	fl6.daddr = ipv6_hdr(skb)->daddr;
-
-	ipv6_local_error(sk, EMSGSIZE, &fl6, mtu);
-}
-
 static int xfrm6_tunnel_check_size(struct sk_buff *skb)
 {
 	int mtu, ret = 0;
@@ -80,7 +72,7 @@ static int xfrm6_tunnel_check_size(struct sk_buff *skb)
 		if (xfrm6_local_dontfrag(skb))
 			xfrm6_local_rxpmtu(skb, mtu);
 		else if (skb->sk)
-			xfrm6_local_error(skb, mtu);
+			xfrm_local_error(skb, mtu);
 		else
 			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		ret = -EMSGSIZE;
@@ -142,7 +134,7 @@ static int __xfrm6_output(struct sk_buff *skb)
 		xfrm6_local_rxpmtu(skb, mtu);
 		return -EMSGSIZE;
 	} else if (!skb->local_df && skb->len > mtu && skb->sk) {
-		xfrm6_local_error(skb, mtu);
+		xfrm_local_error(skb, mtu);
 		return -EMSGSIZE;
 	}
 
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index eb4a842..2a16cb8 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -214,5 +214,31 @@ int xfrm_inner_extract_output(struct xfrm_state *x, struct sk_buff *skb)
 	return inner_mode->afinfo->extract_output(x, skb);
 }
 
+void xfrm_local_error(struct sk_buff *skb, unsigned int mtu)
+{
+	switch (skb->sk->sk_family) {
+	case AF_INET: {
+		struct iphdr *hdr = skb->encapsulation ? inner_ip_hdr(skb) :
+			ip_hdr(skb);
+		ip_local_error(skb->sk, EMSGSIZE, hdr->daddr,
+			       inet_sk(skb->sk)->inet_dport, mtu);
+		return;
+	}
+#if IS_ENABLED(CONFIG_IPV6)
+	case AF_INET6: {
+		struct flowi6 fl6;
+		struct ipv6hdr *hdr = skb->encapsulation ? inner_ipv6_hdr(skb) :
+			inner_ipv6_hdr(skb);
+		fl6.fl6_dport = inet_sk(skb->sk)->inet_dport;
+		fl6.daddr = hdr->daddr;
+		ipv6_local_error(skb->sk, EMSGSIZE, &fl6, mtu);
+		return;
+	}
+#endif
+	}
+	BUG();
+}
+
 EXPORT_SYMBOL_GPL(xfrm_output);
 EXPORT_SYMBOL_GPL(xfrm_inner_extract_output);
+EXPORT_SYMBOL_GPL(xfrm_local_error);
-- 
1.8.3.1
