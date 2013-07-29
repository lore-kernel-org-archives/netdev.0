From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH RFC] xfrm{4,6}: only report errors back to local sockets if we don't cross address family
Date: Mon, 29 Jul 2013 16:50:17 +0200
Message-ID: <20130729145017.GD2490@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: vi0oss@gmail.com, steffen.klassert@secunet.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:46356 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753217Ab3G2OuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 10:50:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

xfrm6_local_error/xfrm4_tunnel_check_size report mtu errors back to a
socket in case it is locally generated. If the packet first traversed
a 6in4/4in6 tunnel before passing the xfrm layer, we could get a panic
because of address family type mismatch in the error reporting functions.

This bug fixes only the panic part of the excellent bug report
<https://bugzilla.kernel.org/show_bug.cgi?id=58691> by vi0oss.

It is unclear to me how to let these mtu change events travel up the
stack. A match on (skb->sk && (skb->dev | tunnel_types)) could be made
first and we forcefully decrease the mtu of that interface with a warning?
This seems to be fragile to me.

Reported-by: <vi0oss@gmail.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv4/xfrm4_output.c | 4 ++--
 net/ipv6/xfrm6_output.c | 3 +++
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 327a617..61f6cae 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -32,10 +32,10 @@ static int xfrm4_tunnel_check_size(struct sk_buff *skb)
 	dst = skb_dst(skb);
 	mtu = dst_mtu(dst);
 	if (skb->len > mtu) {
-		if (skb->sk)
+		if (skb->sk && skb->sk->sk_family == AF_INET)
 			ip_local_error(skb->sk, EMSGSIZE, ip_hdr(skb)->daddr,
 				       inet_sk(skb->sk)->inet_dport, mtu);
-		else
+		else if (!skb->sk)
 			icmp_send(skb, ICMP_DEST_UNREACH,
 				  ICMP_FRAG_NEEDED, htonl(mtu));
 		ret = -EMSGSIZE;
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 8755a30..29f6db7 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -59,6 +59,9 @@ static void xfrm6_local_error(struct sk_buff *skb, u32 mtu)
 	struct flowi6 fl6;
 	struct sock *sk = skb->sk;
 
+	if (sk->sk_family != AF_INET6)
+		return;
+
 	fl6.fl6_dport = inet_sk(sk)->inet_dport;
 	fl6.daddr = ipv6_hdr(skb)->daddr;
 
-- 
1.8.3.1
