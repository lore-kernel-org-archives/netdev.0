From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next] xfrm: make local error reporting more robust
Date: Tue, 13 Aug 2013 02:48:39 +0200
Message-ID: <20130813004839.GB27385@order.stressinduktion.org>
References: <20130730082118.GA25511@secunet.com> <20130730083017.GA7068@order.stressinduktion.org> <20130730102611.GB25511@secunet.com> <20130801081150.GF3688@order.stressinduktion.org> <20130801100522.GC25511@secunet.com> <20130808224440.GJ14001@order.stressinduktion.org> <1376002677.4004.139.camel@edumazet-glaptop> <20130808230620.GK14001@order.stressinduktion.org> <20130810161629.GR14001@order.stressinduktion.org> <20130812055414.GK25511@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	vi0oss@gmail.com
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47591 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231Ab3HMAsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 20:48:41 -0400
Content-Disposition: inline
In-Reply-To: <20130812055414.GK25511@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 12, 2013 at 07:54:14AM +0200, Steffen Klassert wrote:
> On Sat, Aug 10, 2013 at 06:16:29PM +0200, Hannes Frederic Sowa wrote:
> > 
> > Seems skb->encapsulated helps, but I still have to wire it up for the ipv6
> > tunnels.
> > 
> > I just prototyped this patch, but I fear I now introduced a dependency
> > from core xfrm to ipv6, which I would like to have prevented (this would
> > even happen if I put xfrm_local_error in a header file). Is this actually
> > a problem? I fear so. The other way would be to put the local_error
> > handler as function pointers somewhere reachable from struct sock.
> > 
> 
> Maybe we should put a local_error() function pointer to struct
> xfrm_state_afinfo and call it via inner_mode->afinfo->local_error().
> 
> This should always call the right local_error function and we
> would not need to touch generic networking code to fix it.

afinfo was a great hint. But I could not use inner_mode, because it
would still point to the wrong afinfo instance.

I tested this patch with vi0ss's great test script:
<https://gist.github.com/vi/5640512>

I will look at the skb->encapsulation for IPv6 logic again, as soon
as I understand the side effects when I introduce this. This will then
correct the destination address when sending back ipv6 errors.

Steffen, if you are fine with this patch, do you think it is a candidate
for stable?

[PATCH net-next] xfrm: make local error reporting more robust

In xfrm4 and xfrm6 we need to take care about sockets of the other
address family. This could happen because a 6in4 or 4in6 tunnel could
get protected by ipsec.

Because we don't want to have a run-time dependency on ipv6 when only
using ipv4 xfrm we have to embed a pointer to the correct local_error
function in xfrm_state_afinet and look it up when returning an error
depending on the socket address family.

Thanks to vi0ss for the great bug report:
<https://bugzilla.kernel.org/show_bug.cgi?id=58691>

Reported-by: <vi0oss@gmail.com>
Cc: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/net/xfrm.h      |  6 ++++++
 net/ipv4/xfrm4_output.c | 12 ++++++++++--
 net/ipv4/xfrm4_state.c  |  1 +
 net/ipv6/xfrm6_output.c |  4 ++--
 net/ipv6/xfrm6_state.c  |  1 +
 net/xfrm/xfrm_output.c  | 12 ++++++++++++
 net/xfrm/xfrm_state.c   |  7 ++-----
 7 files changed, 34 insertions(+), 9 deletions(-)

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
index 8755a30..f6f9110 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -54,7 +54,7 @@ static void xfrm6_local_rxpmtu(struct sk_buff *skb, u32 mtu)
 	ipv6_local_rxpmtu(sk, &fl6, mtu);
 }
 
-static void xfrm6_local_error(struct sk_buff *skb, u32 mtu)
+void xfrm6_local_error(struct sk_buff *skb, u32 mtu)
 {
 	struct flowi6 fl6;
 	struct sock *sk = skb->sk;
@@ -80,7 +80,7 @@ static int xfrm6_tunnel_check_size(struct sk_buff *skb)
 		if (xfrm6_local_dontfrag(skb))
 			xfrm6_local_rxpmtu(skb, mtu);
 		else if (skb->sk)
-			xfrm6_local_error(skb, mtu);
+			xfrm_local_error(skb, mtu);
 		else
 			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 		ret = -EMSGSIZE;
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
index eb4a842..c445a2f 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -214,5 +214,17 @@ int xfrm_inner_extract_output(struct xfrm_state *x, struct sk_buff *skb)
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
