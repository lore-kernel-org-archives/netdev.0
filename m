From: Phil Dibowitz <phil@ipom.com>
Subject: [PATCH] ipv6_tunnel: Allow receiving packets on the fallback tunnel
 if they pass sanity checks
Date: Thu, 28 Jun 2012 21:15:52 -0700
Message-ID: <20120629041552.GA27362@ipom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, phild@fb.com, ville.nuorvala@gmail.com,
	phil@ipom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ipom.com ([96.126.97.66]:58556 "EHLO mail.ipom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750764Ab2F2EP6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2012 00:15:58 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ville Nuorvala <ville.nuorvala@gmail.com>

At Facebook, we do Layer-3 DSR via IP-in-IP tunneling. Our load balancers wrap
an extra IP header on incoming packets so they can be routed to the backend.
In the v4 tunnel driver, when these packets fall on the default tunl0 device,
the behavior is to decapsulate them and drop them back on the stack. So our
setup is that tunl0 has the VIP and eth0 has (obviously) the backend's real
address.

In IPv6 we do the same thing, but the v6 tunnel driver didn't have this same
behavior - if you didn't have an explicit tunnel setup, it would drop the
packet.

This patch brings that v4 feature to the v6 driver.

The same IPv6 address checks are performed as with any normal tunnel,
but as the fallback tunnel endpoint addresses are unspecified, the checks
must be performed on a per-packet basis, rather than at tunnel
configuration time.

[Patch description modified by phil@ipom.com]

Signed-off-by: Ville Nuorvala <ville.nuorvala@gmail.com>
Tested-by: Phil Dibowitz <phil@ipom.com>

---
 include/net/ip6_tunnel.h |    2 +
 net/ipv6/ip6_tunnel.c    |   65 +++++++++++++++++++++++++++-------------------
 2 files changed, 40 insertions(+), 27 deletions(-)

diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index fc73e66..358fb86 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -9,6 +9,8 @@
 #define IP6_TNL_F_CAP_XMIT 0x10000
 /* capable of receiving packets */
 #define IP6_TNL_F_CAP_RCV 0x20000
+/* determine capability on a per-packet basis */
+#define IP6_TNL_F_CAP_PER_PACKET 0x40000
 
 /* IPv6 tunnel */
 
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index c9015fa..04a3cba 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -684,24 +684,50 @@ static void ip6ip6_dscp_ecn_decapsulate(const struct ip6_tnl *t,
 		IP6_ECN_set_ce(ipv6_hdr(skb));
 }
 
+static __u32 ip6_tnl_get_cap(struct ip6_tnl *t,
+			     const struct in6_addr *laddr,
+			     const struct in6_addr *raddr)
+{
+	struct ip6_tnl_parm *p = &t->parms;
+	int ltype = ipv6_addr_type(laddr);
+	int rtype = ipv6_addr_type(raddr);
+	__u32 flags = 0;
+
+	if (ltype == IPV6_ADDR_ANY || rtype == IPV6_ADDR_ANY) {
+		flags = IP6_TNL_F_CAP_PER_PACKET;
+	} else if (ltype & (IPV6_ADDR_UNICAST|IPV6_ADDR_MULTICAST) &&
+		   rtype & (IPV6_ADDR_UNICAST|IPV6_ADDR_MULTICAST) &&
+		   !((ltype|rtype) & IPV6_ADDR_LOOPBACK) &&
+		   (!((ltype|rtype) & IPV6_ADDR_LINKLOCAL) || p->link)) {
+		if (ltype&IPV6_ADDR_UNICAST)
+			flags |= IP6_TNL_F_CAP_XMIT;
+		if (rtype&IPV6_ADDR_UNICAST)
+			flags |= IP6_TNL_F_CAP_RCV;
+	}
+	return flags;
+}
+
 /* called with rcu_read_lock() */
-static inline int ip6_tnl_rcv_ctl(struct ip6_tnl *t)
+static inline int ip6_tnl_rcv_ctl(struct ip6_tnl *t,
+				  const struct in6_addr *laddr,
+				  const struct in6_addr *raddr)
 {
 	struct ip6_tnl_parm *p = &t->parms;
 	int ret = 0;
 	struct net *net = dev_net(t->dev);
 
-	if (p->flags & IP6_TNL_F_CAP_RCV) {
+	if ((p->flags & IP6_TNL_F_CAP_RCV) ||
+	    ((p->flags & IP6_TNL_F_CAP_PER_PACKET) &&
+	     (ip6_tnl_get_cap(t, laddr, raddr) & IP6_TNL_F_CAP_RCV))) {
 		struct net_device *ldev = NULL;
 
 		if (p->link)
 			ldev = dev_get_by_index_rcu(net, p->link);
 
-		if ((ipv6_addr_is_multicast(&p->laddr) ||
-		     likely(ipv6_chk_addr(net, &p->laddr, ldev, 0))) &&
-		    likely(!ipv6_chk_addr(net, &p->raddr, NULL, 0)))
+		if ((ipv6_addr_is_multicast(laddr) ||
+		     likely(ipv6_chk_addr(net, laddr, ldev, 0))) &&
+		    likely(!ipv6_chk_addr(net, raddr, NULL, 0)))
 			ret = 1;
-
 	}
 	return ret;
 }
@@ -740,7 +766,7 @@ static int ip6_tnl_rcv(struct sk_buff *skb, __u16 protocol,
 			goto discard;
 		}
 
-		if (!ip6_tnl_rcv_ctl(t)) {
+		if (!ip6_tnl_rcv_ctl(t, &ipv6h->daddr, &ipv6h->saddr)) {
 			t->dev->stats.rx_dropped++;
 			rcu_read_unlock();
 			goto discard;
@@ -1114,25 +1140,6 @@ tx_err:
 	return NETDEV_TX_OK;
 }
 
-static void ip6_tnl_set_cap(struct ip6_tnl *t)
-{
-	struct ip6_tnl_parm *p = &t->parms;
-	int ltype = ipv6_addr_type(&p->laddr);
-	int rtype = ipv6_addr_type(&p->raddr);
-
-	p->flags &= ~(IP6_TNL_F_CAP_XMIT|IP6_TNL_F_CAP_RCV);
-
-	if (ltype & (IPV6_ADDR_UNICAST|IPV6_ADDR_MULTICAST) &&
-	    rtype & (IPV6_ADDR_UNICAST|IPV6_ADDR_MULTICAST) &&
-	    !((ltype|rtype) & IPV6_ADDR_LOOPBACK) &&
-	    (!((ltype|rtype) & IPV6_ADDR_LINKLOCAL) || p->link)) {
-		if (ltype&IPV6_ADDR_UNICAST)
-			p->flags |= IP6_TNL_F_CAP_XMIT;
-		if (rtype&IPV6_ADDR_UNICAST)
-			p->flags |= IP6_TNL_F_CAP_RCV;
-	}
-}
-
 static void ip6_tnl_link_config(struct ip6_tnl *t)
 {
 	struct net_device *dev = t->dev;
@@ -1153,7 +1160,8 @@ static void ip6_tnl_link_config(struct ip6_tnl *t)
 	if (!(p->flags&IP6_TNL_F_USE_ORIG_FLOWLABEL))
 		fl6->flowlabel |= IPV6_FLOWLABEL_MASK & p->flowinfo;
 
-	ip6_tnl_set_cap(t);
+	p->flags &= ~(IP6_TNL_F_CAP_XMIT|IP6_TNL_F_CAP_RCV|IP6_TNL_F_CAP_PER_PACKET);
+	p->flags |= ip6_tnl_get_cap(t, &p->laddr, &p->raddr);
 
 	if (p->flags&IP6_TNL_F_CAP_XMIT && p->flags&IP6_TNL_F_CAP_RCV)
 		dev->flags |= IFF_POINTOPOINT;
@@ -1438,6 +1446,9 @@ static int __net_init ip6_fb_tnl_dev_init(struct net_device *dev)
 
 	t->parms.proto = IPPROTO_IPV6;
 	dev_hold(dev);
+
+	ip6_tnl_link_config(t);
+
 	rcu_assign_pointer(ip6n->tnls_wc[0], t);
 	return 0;
 }
