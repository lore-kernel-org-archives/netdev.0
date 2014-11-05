From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH net-next 1/2] ipv6: Allow sending packets through tunnels
 with wildcard endpoints
Date: Wed, 5 Nov 2014 08:02:48 +0100
Message-ID: <20141105070248.GC6390@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:41839 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751546AbaKEHC4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 02:02:56 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we need the IP6_TNL_F_CAP_XMIT capabiltiy to transmit
packets through an ipv6 tunnel. This capability is set when the
tunnel gets configured, based on the tunnel endpoint addresses.

On tunnels with wildcard tunnel endpoints, we need to do the
capabiltiy checking on a per packet basis like it is done in
the receive path.

This patch extends ip6_tnl_xmit_ctl() to take local and remote
addresses as parameters to allow for per packet capabiltiy
checking.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/ip6_tunnel.h |  3 ++-
 net/ipv6/ip6_gre.c       |  2 +-
 net/ipv6/ip6_tunnel.c    | 23 +++++++++++++++--------
 net/ipv6/ip6_vti.c       | 10 ++++++++--
 4 files changed, 26 insertions(+), 12 deletions(-)

diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index a5593da..9326c41 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -65,7 +65,8 @@ void ip6_tnl_dst_reset(struct ip6_tnl *t);
 void ip6_tnl_dst_store(struct ip6_tnl *t, struct dst_entry *dst);
 int ip6_tnl_rcv_ctl(struct ip6_tnl *t, const struct in6_addr *laddr,
 		const struct in6_addr *raddr);
-int ip6_tnl_xmit_ctl(struct ip6_tnl *t);
+int ip6_tnl_xmit_ctl(struct ip6_tnl *t, const struct in6_addr *laddr,
+		     const struct in6_addr *raddr);
 __u16 ip6_tnl_parse_tlv_enc_lim(struct sk_buff *skb, __u8 *raw);
 __u32 ip6_tnl_get_cap(struct ip6_tnl *t, const struct in6_addr *laddr,
 			     const struct in6_addr *raddr);
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 12c3c8e..1fcf62e 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -902,7 +902,7 @@ static netdev_tx_t ip6gre_tunnel_xmit(struct sk_buff *skb,
 	struct net_device_stats *stats = &t->dev->stats;
 	int ret;
 
-	if (!ip6_tnl_xmit_ctl(t))
+	if (!ip6_tnl_xmit_ctl(t, &t->parms.laddr, &t->parms.raddr))
 		goto tx_err;
 
 	switch (skb->protocol) {
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 8c97cd1..a8f94ff 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -909,24 +909,28 @@ ip6_tnl_addr_conflict(const struct ip6_tnl *t, const struct ipv6hdr *hdr)
 	return ipv6_addr_equal(&t->parms.raddr, &hdr->saddr);
 }
 
-int ip6_tnl_xmit_ctl(struct ip6_tnl *t)
+int ip6_tnl_xmit_ctl(struct ip6_tnl *t,
+		     const struct in6_addr *laddr,
+		     const struct in6_addr *raddr)
 {
 	struct __ip6_tnl_parm *p = &t->parms;
 	int ret = 0;
 	struct net *net = t->net;
 
-	if (p->flags & IP6_TNL_F_CAP_XMIT) {
+	if ((p->flags & IP6_TNL_F_CAP_XMIT) ||
+	    ((p->flags & IP6_TNL_F_CAP_PER_PACKET) &&
+	     (ip6_tnl_get_cap(t, laddr, raddr) & IP6_TNL_F_CAP_XMIT))) {
 		struct net_device *ldev = NULL;
 
 		rcu_read_lock();
 		if (p->link)
 			ldev = dev_get_by_index_rcu(net, p->link);
 
-		if (unlikely(!ipv6_chk_addr(net, &p->laddr, ldev, 0)))
+		if (unlikely(!ipv6_chk_addr(net, laddr, ldev, 0)))
 			pr_warn("%s xmit: Local address not yet configured!\n",
 				p->name);
-		else if (!ipv6_addr_is_multicast(&p->raddr) &&
-			 unlikely(ipv6_chk_addr(net, &p->raddr, NULL, 0)))
+		else if (!ipv6_addr_is_multicast(raddr) &&
+			 unlikely(ipv6_chk_addr(net, raddr, NULL, 0)))
 			pr_warn("%s xmit: Routing loop! Remote address found on this node!\n",
 				p->name);
 		else
@@ -977,6 +981,10 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 
 	if (!fl6->flowi6_mark)
 		dst = ip6_tnl_dst_check(t);
+
+	if (!ip6_tnl_xmit_ctl(t, &fl6->saddr, &fl6->daddr))
+		goto tx_err_link_failure;
+
 	if (!dst) {
 		ndst = ip6_route_output(net, NULL, fl6);
 
@@ -1086,8 +1094,7 @@ ip4ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 	int err;
 
 	tproto = ACCESS_ONCE(t->parms.proto);
-	if ((tproto != IPPROTO_IPIP && tproto != 0) ||
-	    !ip6_tnl_xmit_ctl(t))
+	if (tproto != IPPROTO_IPIP && tproto != 0)
 		return -1;
 
 	if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
@@ -1131,7 +1138,7 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	tproto = ACCESS_ONCE(t->parms.proto);
 	if ((tproto != IPPROTO_IPV6 && tproto != 0) ||
-	    !ip6_tnl_xmit_ctl(t) || ip6_tnl_addr_conflict(t, ipv6h))
+	    ip6_tnl_addr_conflict(t, ipv6h))
 		return -1;
 
 	offset = ip6_tnl_parse_tlv_enc_lim(skb, skb_network_header(skb));
diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index d440bb5..0e8e97e 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -416,6 +416,7 @@ vti6_xmit(struct sk_buff *skb, struct net_device *dev, struct flowi *fl)
 	struct net_device_stats *stats = &t->dev->stats;
 	struct dst_entry *dst = skb_dst(skb);
 	struct net_device *tdev;
+	struct xfrm_state *x;
 	int err = -1;
 
 	if (!dst)
@@ -429,7 +430,12 @@ vti6_xmit(struct sk_buff *skb, struct net_device *dev, struct flowi *fl)
 		goto tx_err_link_failure;
 	}
 
-	if (!vti6_state_check(dst->xfrm, &t->parms.raddr, &t->parms.laddr))
+	x = dst->xfrm;
+	if (!vti6_state_check(x, &t->parms.raddr, &t->parms.laddr))
+		goto tx_err_link_failure;
+
+	if (!ip6_tnl_xmit_ctl(t, (const struct in6_addr *)&x->props.saddr,
+			      (const struct in6_addr *)&x->id.daddr))
 		goto tx_err_link_failure;
 
 	tdev = dst->dev;
@@ -484,7 +490,7 @@ vti6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 		ipv6h = ipv6_hdr(skb);
 
 		if ((t->parms.proto != IPPROTO_IPV6 && t->parms.proto != 0) ||
-		    !ip6_tnl_xmit_ctl(t) || vti6_addr_conflict(t, ipv6h))
+		    vti6_addr_conflict(t, ipv6h))
 			goto tx_err;
 
 		xfrm_decode_session(skb, &fl, AF_INET6);
-- 
1.9.1
