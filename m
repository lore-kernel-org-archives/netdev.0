From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: [PATCH 03/03] ISATAP V2 (sit.c changes)
Date: Tue, 15 Jan 2008 12:00:36 -0800
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A1029EDDAE@XCH-NW-7V2.nw.nos.boeing.com>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC29@XCH-NW-7V2.nw.nos.boeing.com><39C363776A4E8C4A94691D2BD9D1C9A1029EDC45@XCH-NW-7V2.nw.nos.boeing.com><20071129102940.GC22537@gondor.apana.org.au> <20071129.195459.55971471.yoshfuji@linux-ipv6.org> <39C363776A4E8C4A94691D2BD9D1C9A1029EDDAC@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stl-smtpout-01.boeing.com ([130.76.96.56]:36548 "EHLO
	stl-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751837AbYAOUAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 15:00:45 -0500
Content-class: urn:content-classes:message
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A1029EDDAC@XCH-NW-7V2.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch updates the Linux the Intra-Site Automatic Tunnel Addressing
Protocol (ISATAP) implementation. It places the ISATAP potential router
list (PRL) in the kernel and adds three new private ioctls for PRL
management. The diffs are specific to the netdev net-2.6.25 development
tree taken by "git pull" on 1/14/08.

Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>

--- net-2.6.25/net/ipv6/sit.c.orig	2008-01-14 15:33:36.000000000 -0800
+++ net-2.6.25/net/ipv6/sit.c	2008-01-15 10:21:31.000000000 -0800
@@ -16,7 +16,7 @@
  *	Changes:
  * Roger Venning <r.venning@telstra.com>:	6to4 support
  * Nate Thompson <nate@thebog.net>:		6to4 support
- * Fred L. Templin <fltemplin@acm.org>:		isatap support
+ * Fred Templin <fred.l.templin@boeing.com>:	isatap support
  */
 
 #include <linux/module.h>
@@ -200,6 +200,118 @@ failed:
 	return NULL;
 }
 
+static struct ip_tunnel_prlent *
+ipip6_tunnel_locate_prl(struct ip_tunnel *t, __be32 addr)
+{
+	struct ip_tunnel_prlent *p = (struct ip_tunnel_prlent *)NULL;
+
+	for (p = t->prl; p; p = p->next)
+		if (p->ent.addr == addr)
+			break;
+	return p;
+
+}
+
+static int
+ipip6_tunnel_add_prl(struct ip_tunnel *t, struct ip_tunnel_prladdr *a, int chg)
+{
+	struct ip_tunnel_prlent *p;
+
+	for (p = t->prl; p; p = p->next) {
+		if (p->ent.addr == a->addr) {
+			if (chg) {
+				p->ent = *a;
+				return 0;
+			}
+			return -EEXIST;
+		}
+	}
+
+	if (chg)
+		return -ENXIO;
+
+	if (!(p = kzalloc(sizeof(struct ip_tunnel_prlent), GFP_KERNEL)))
+		return -ENOBUFS;
+
+	p->ent = *a;
+	p->next = t->prl;
+	t->prl = p;
+	return 0;
+}
+
+static int
+ipip6_tunnel_del_prl(struct ip_tunnel *t, struct ip_tunnel_prladdr *a)
+{
+	struct ip_tunnel_prlent *x, **p;
+
+	if (a) {
+		for (p = &t->prl; *p; p = &(*p)->next) {
+			if ((*p)->ent.addr == a->addr) {
+				x = *p;
+				*p = x->next;
+				kfree(x);
+				return 0;
+			}
+		}
+		return -ENXIO;
+	}  else {
+		while (t->prl) {
+			x = t->prl;
+			t->prl = t->prl->next;
+			kfree(x);
+		}
+	}
+	return 0;
+}
+
+/* copied directly from anycast.c */
+static int
+ipip6_onlink(struct in6_addr *addr, struct net_device *dev)
+{
+	struct inet6_dev	*idev;
+	struct inet6_ifaddr	*ifa;
+	int	onlink;
+
+	onlink = 0;
+	rcu_read_lock();
+	idev = __in6_dev_get(dev);
+	if (idev) {
+		read_lock_bh(&idev->lock);
+		for (ifa=idev->addr_list; ifa; ifa=ifa->if_next) {
+			onlink = ipv6_prefix_equal(addr, &ifa->addr,
+						   ifa->prefix_len);
+			if (onlink)
+				break;
+		}
+		read_unlock_bh(&idev->lock);
+	}
+	rcu_read_unlock();
+	return onlink;
+}
+
+static int
+isatap_chksrc(struct sk_buff *skb, struct iphdr *iph, struct ip_tunnel *t)
+{
+	struct ip_tunnel_prlent *p = ipip6_tunnel_locate_prl(t, iph->saddr);
+	int ok = 1;
+
+	if (p) {
+		if (p->ent.flags & PRL_BORDER)
+			skb->rtr_type = RTRTYPE_BORDER;
+		else
+			skb->rtr_type = RTRTYPE_INTERIOR;
+	} else {
+		struct in6_addr *addr6 = &ipv6_hdr(skb)->saddr;
+		if (ipv6_addr_is_isatap(addr6) &&
+		    (addr6->s6_addr32[3] == iph->saddr) &&
+		    ipip6_onlink(addr6, t->dev))
+			skb->rtr_type = RTRTYPE_HOST;
+		else
+			ok = 0;
+	}
+	return ok;
+}
+
 static void ipip6_tunnel_uninit(struct net_device *dev)
 {
 	if (dev == ipip6_fb_tunnel_dev) {
@@ -209,6 +321,7 @@ static void ipip6_tunnel_uninit(struct n
 		dev_put(dev);
 	} else {
 		ipip6_tunnel_unlink(netdev_priv(dev));
+		ipip6_tunnel_del_prl(netdev_priv(dev), 0);
 		dev_put(dev);
 	}
 }
@@ -368,48 +481,6 @@ static inline void ipip6_ecn_decapsulate
 		IP6_ECN_set_ce(ipv6_hdr(skb));
 }
 
-/* ISATAP (RFC4214) - check source address */
-static int
-isatap_srcok(struct sk_buff *skb, struct iphdr *iph, struct net_device *dev)
-{
-	struct neighbour *neigh;
-	struct dst_entry *dst;
-	struct rt6_info *rt;
-	struct flowi fl;
-	struct in6_addr *addr6;
-	struct in6_addr rtr;
-	struct ipv6hdr *iph6;
-	int ok = 0;
-
-	/* from onlink default router */
-	ipv6_addr_set(&rtr,  htonl(0xFE800000), 0, 0, 0);
-	ipv6_isatap_eui64(rtr.s6_addr + 8, iph->saddr);
-	if ((rt = rt6_get_dflt_router(&rtr, dev))) {
-		dst_release(&rt->u.dst);
-		return 1;
-	}
-
-	iph6 = ipv6_hdr(skb);
-	memset(&fl, 0, sizeof(fl));
-	fl.proto = iph6->nexthdr;
-	ipv6_addr_copy(&fl.fl6_dst, &iph6->saddr);
-	fl.oif = dev->ifindex;
-	security_skb_classify_flow(skb, &fl);
-
-	dst = ip6_route_output(NULL, &fl);
-	if (!dst->error && (dst->dev == dev) && (neigh = dst->neighbour)) {
-
-		addr6 = (struct in6_addr*)&neigh->primary_key;
-
-		/* from correct previous hop */
-		if (ipv6_addr_is_isatap(addr6) &&
-		    (addr6->s6_addr32[3] == iph->saddr))
-			ok = 1;
-	}
-	dst_release(dst);
-	return ok;
-}
-
 static int ipip6_rcv(struct sk_buff *skb)
 {
 	struct iphdr *iph;
@@ -430,7 +501,7 @@ static int ipip6_rcv(struct sk_buff *skb
 		skb->pkt_type = PACKET_HOST;
 
 		if ((tunnel->dev->priv_flags & IFF_ISATAP) &&
-		    !isatap_srcok(skb, iph, tunnel->dev)) {
+		    !isatap_chksrc(skb, iph, tunnel)) {
 			tunnel->stat.rx_errors++;
 			read_unlock(&ipip6_lock);
 			kfree_skb(skb);
@@ -710,6 +781,7 @@ ipip6_tunnel_ioctl (struct net_device *d
 {
 	int err = 0;
 	struct ip_tunnel_parm p;
+	struct ip_tunnel_prladdr prl;
 	struct ip_tunnel *t;
 
 	switch (cmd) {
@@ -809,6 +881,31 @@ ipip6_tunnel_ioctl (struct net_device *d
 		err = 0;
 		break;
 
+	case SIOCADDPRL:
+	case SIOCDELPRL:
+	case SIOCCHGPRL:
+		err = -EPERM;
+		if (!capable(CAP_NET_ADMIN))
+			goto done;
+		err = -EINVAL;
+		if (dev == ipip6_fb_tunnel_dev)
+			goto done;
+		err = -EFAULT;
+		if (copy_from_user(&prl, ifr->ifr_ifru.ifru_data, sizeof(prl)))
+			goto done;
+		err = -ENOENT;
+		if (!(t = netdev_priv(dev)))
+			goto done;
+
+		ipip6_tunnel_unlink(t);
+		if (cmd == SIOCDELPRL)
+			err = ipip6_tunnel_del_prl(t, &prl);
+		else
+			err = ipip6_tunnel_add_prl(t, &prl, cmd == SIOCCHGPRL);
+		ipip6_tunnel_link(t);
+		netdev_state_change(dev);
+		break;
+
 	default:
 		err = -EINVAL;
 	}
