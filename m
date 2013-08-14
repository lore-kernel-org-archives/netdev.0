From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net v3] xfrm: make local error reporting more robust
Date: Wed, 14 Aug 2013 13:05:23 +0200
Message-ID: <20130814110523.GG16264@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: steffen.klassert@secunet.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:50949 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759501Ab3HNLFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 07:05:25 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In xfrm4 and xfrm6 we need to take care about sockets of the other
address family. This could happen because a 6in4 or 4in6 tunnel could
get protected by ipsec.

Because we don't want to have a run-time dependency on ipv6 when only
using ipv4 xfrm we have to embed a pointer to the correct local_error
function in xfrm_state_afinet and look it up when returning an error
depending on the socket address family.

Thanks to vi0ss for the great bug report:
<https://bugzilla.kernel.org/show_bug.cgi?id=58691>

v2:
a) fix two more unsafe interpretations of skb->sk as ipv6 socket
   (xfrm6_local_dontfrag and __xfrm6_output)
v3:
a) add an EXPORT_SYMBOL_GPL(xfrm_local_error) to fix a link error when
   building ipv6 as a module (thanks to Steffen Klassert)

Reported-by: <vi0oss@gmail.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/xfrm.h      |  6 ++++++
 net/ipv4/xfrm4_output.c | 12 ++++++++++--
 net/ipv4/xfrm4_state.c  |  1 +
 net/ipv6/xfrm6_output.c | 10 ++++++----
 net/ipv6/xfrm6_state.c  |  1 +
 net/xfrm/xfrm_output.c  | 13 +++++++++++++
 net/xfrm/xfrm_state.c   |  7 ++-----
 7 files changed, 39 insertions(+), 11 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 94ce082..e823786 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -341,10 +341,13 @@ struct xfrm_state_afinfo {
 						  struct sk_buff *skb);
 	int			(*transport_finish)(struct sk_buff *skb,
 						    int async);
+	void			(*local_error)(struct sk_buff *skb, u32 mtu);
 };
 
 extern int xfrm_state_register_afinfo(struct xfrm_state_afinfo *afinfo);
 extern int xfrm_state_unregister_afinfo(struct xfrm_state_afinfo *afinfo);
+extern struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned int family);
+extern void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo);
 
 extern void xfrm_state_delete_tunnel(struct xfrm_state *x);
 
@@ -1477,6 +1480,7 @@ extern int xfrm_input_resume(struct sk_buff *skb, int nexthdr);
 extern int xfrm_output_resume(struct sk_buff *skb, int err);
 extern int xfrm_output(struct sk_buff *skb);
 extern int xfrm_inner_extract_output(struct xfrm_state *x, struct sk_buff *skb);
+extern void xfrm_local_error(struct sk_buff *skb, int mtu);
 extern int xfrm4_extract_header(struct sk_buff *skb);
 extern int xfrm4_extract_input(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
@@ -1497,6 +1501,7 @@ extern int xfrm4_tunnel_register(struct xfrm_tunnel *handler, unsigned short fam
 extern int xfrm4_tunnel_deregister(struct xfrm_tunnel *handler, unsigned short family);
 extern int xfrm4_mode_tunnel_input_register(struct xfrm_tunnel *handler);
 extern int xfrm4_mode_tunnel_input_deregister(struct xfrm_tunnel *handler);
+extern void xfrm4_local_error(struct sk_buff *skb, u32 mtu);
 extern int xfrm6_extract_header(struct sk_buff *skb);
 extern int xfrm6_extract_input(struct xfrm_state *x, struct sk_buff *skb);
 extern int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi);
@@ -1514,6 +1519,7 @@ extern int xfrm6_output(struct sk_buff *skb);
 extern int xfrm6_output_finish(struct sk_buff *skb);
 extern int xfrm6_find_1stfragopt(struct xfrm_state *x, struct sk_buff *skb,
 				 u8 **prevhdr);
+extern void xfrm6_local_error(struct sk_buff *skb, u32 mtu);
 
 #ifdef CONFIG_XFRM
 extern int xfrm4_udp_encap_rcv(struct sock *sk, struct sk_buff *skb);
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index 327a617..7a5491f 100644
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
@@ -99,3 +98,12 @@ int xfrm4_output(struct sk_buff *skb)
 			    x->outer_mode->afinfo->output_finish,
 			    !(IPCB(skb)->flags & IPSKB_REROUTED));
 }
+
+void xfrm4_local_error(struct sk_buff *skb, u32 mtu)
+{
+	struct iphdr *hdr;
+
+	hdr = skb->encapsulation ? inner_ip_hdr(skb) : ip_hdr(skb);
+	ip_local_error(skb->sk, EMSGSIZE, hdr->daddr,
+		       inet_sk(skb->sk)->inet_dport, mtu);
+}
diff --git a/net/ipv4/xfrm4_state.c b/net/ipv4/xfrm4_state.c
index 9258e75..0b2a064 100644
--- a/net/ipv4/xfrm4_state.c
+++ b/net/ipv4/xfrm4_state.c
@@ -83,6 +83,7 @@ static struct xfrm_state_afinfo xfrm4_state_afinfo = {
 	.extract_input		= xfrm4_extract_input,
 	.extract_output		= xfrm4_extract_output,
 	.transport_finish	= xfrm4_transport_finish,
+	.local_error		= xfrm4_local_error,
 };
 
 void __init xfrm4_state_init(void)
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index 8755a30..b64fff3 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -34,8 +34,10 @@ static int xfrm6_local_dontfrag(struct sk_buff *skb)
 	struct sock *sk = skb->sk;
 
 	if (sk) {
-		proto = sk->sk_protocol;
+		if (sk->sk_family != AF_INET6)
+			return 0;
 
+		proto = sk->sk_protocol;
 		if (proto == IPPROTO_UDP || proto == IPPROTO_RAW)
 			return inet6_sk(sk)->dontfrag;
 	}
@@ -54,7 +56,7 @@ static void xfrm6_local_rxpmtu(struct sk_buff *skb, u32 mtu)
 	ipv6_local_rxpmtu(sk, &fl6, mtu);
 }
 
-static void xfrm6_local_error(struct sk_buff *skb, u32 mtu)
+void xfrm6_local_error(struct sk_buff *skb, u32 mtu)
 {
 	struct flowi6 fl6;
 	struct sock *sk = skb->sk;
@@ -80,7 +82,7 @@ static int xfrm6_tunnel_check_size(struct sk_buff *skb)
 		if (xfrm6_local_dontfrag(skb))
 			xfrm6_local_rxpmtu(skb, mtu);
 		else if (skb->sk)
-			xfrm6_local_error(skb, mtu);
+			xfrm_local_error(skb, mtu);
 		else
 			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		ret = -EMSGSIZE;
@@ -142,7 +144,7 @@ static int __xfrm6_output(struct sk_buff *skb)
 		xfrm6_local_rxpmtu(skb, mtu);
 		return -EMSGSIZE;
 	} else if (!skb->local_df && skb->len > mtu && skb->sk) {
-		xfrm6_local_error(skb, mtu);
+		xfrm_local_error(skb, mtu);
 		return -EMSGSIZE;
 	}
 
diff --git a/net/ipv6/xfrm6_state.c b/net/ipv6/xfrm6_state.c
index d8c70b8..3fc9701 100644
--- a/net/ipv6/xfrm6_state.c
+++ b/net/ipv6/xfrm6_state.c
@@ -183,6 +183,7 @@ static struct xfrm_state_afinfo xfrm6_state_afinfo = {
 	.extract_input		= xfrm6_extract_input,
 	.extract_output		= xfrm6_extract_output,
 	.transport_finish	= xfrm6_transport_finish,
+	.local_error		= xfrm6_local_error,
 };
 
 int __init xfrm6_state_init(void)
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index eb4a842..6f5fc61 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -214,5 +214,18 @@ int xfrm_inner_extract_output(struct xfrm_state *x, struct sk_buff *skb)
 	return inner_mode->afinfo->extract_output(x, skb);
 }
 
+void xfrm_local_error(struct sk_buff *skb, int mtu)
+{
+	struct xfrm_state_afinfo *afinfo;
+
+	afinfo = xfrm_state_get_afinfo(skb->sk->sk_family);
+	if (!afinfo)
+		return;
+
+	afinfo->local_error(skb, mtu);
+	xfrm_state_put_afinfo(afinfo);
+}
+
 EXPORT_SYMBOL_GPL(xfrm_output);
 EXPORT_SYMBOL_GPL(xfrm_inner_extract_output);
+EXPORT_SYMBOL_GPL(xfrm_local_error);
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 78f66fa..54c0acd 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -39,9 +39,6 @@ static DEFINE_SPINLOCK(xfrm_state_lock);
 
 static unsigned int xfrm_state_hashmax __read_mostly = 1 * 1024 * 1024;
 
-static struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned int family);
-static void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo);
-
 static inline unsigned int xfrm_dst_hash(struct net *net,
 					 const xfrm_address_t *daddr,
 					 const xfrm_address_t *saddr,
@@ -1860,7 +1857,7 @@ int xfrm_state_unregister_afinfo(struct xfrm_state_afinfo *afinfo)
 }
 EXPORT_SYMBOL(xfrm_state_unregister_afinfo);
 
-static struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned int family)
+struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned int family)
 {
 	struct xfrm_state_afinfo *afinfo;
 	if (unlikely(family >= NPROTO))
@@ -1872,7 +1869,7 @@ static struct xfrm_state_afinfo *xfrm_state_get_afinfo(unsigned int family)
 	return afinfo;
 }
 
-static void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo)
+void xfrm_state_put_afinfo(struct xfrm_state_afinfo *afinfo)
 {
 	rcu_read_unlock();
 }
-- 
1.8.3.1
