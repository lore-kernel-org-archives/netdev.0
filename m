From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: [RFC net-2.6.26] [IPV6] SIT: ISATAP Updates.
Date: Thu, 03 Apr 2008 11:38:11 +0900 (JST)
Message-ID: <20080403.113811.105715223.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	fred.l.templin@boeing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:59966 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758305AbYDCCgh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 22:36:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

This updates ISATAP implementation in Linux kernel
based on the update from Templin, Fred L <fred.l.templin@boeing.com>.

One big question is the "dump" support (4th commit).
Since we cannot use copy_to_user family inside the lock,
nasty kcalloc() is used inside the lock so far...

Patches are also available at
	git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git net-2.6.26-isatap-20080403

Regards,

--- 
HEADLINES
---------

    [IPV6] SIT: Add PRL management for ISATAP.
    [IPV6] SIT: Fix locking issues in PRL management.
    [IPV6] SIT: Disallow 0.0.0.0 in PRL and Flush PRL if given for DEL.
    [IPV6] SIT: Add SIOCGETPRL ioctl to get/dump PRL.
    [IPV6] NDISC: Ignore route information with /0 prefix from interior router.
    [IPV6]: Unify ip6_onlink() and ipip6_onlink().
    [IPV6] NDISC: Don't rely on node-type hint from L2 unless required.

DIFFSTAT
--------

 include/linux/if_tunnel.h |   22 +++-
 include/linux/skbuff.h    |    5 +
 include/net/addrconf.h    |    4 +
 include/net/ipip.h        |   10 ++
 include/net/ndisc.h       |    9 ++
 net/ipv6/Kconfig          |    4 +
 net/ipv6/addrconf.c       |   25 ++++
 net/ipv6/anycast.c        |   25 ----
 net/ipv6/ndisc.c          |   42 +++++++
 net/ipv6/route.c          |    2 
 net/ipv6/sit.c            |  257 +++++++++++++++++++++++++++++++++++++--------
 11 files changed, 330 insertions(+), 75 deletions(-)

CHANGESETS
----------

commit fadf6bf06069138f8e97c9a963be38348ba2708b
Author: Templin, Fred L <Fred.L.Templin@boeing.com>
Date:   Tue Mar 11 18:35:59 2008 -0400

    [IPV6] SIT: Add PRL management for ISATAP.
    
    This patch updates the Linux the Intra-Site Automatic Tunnel Addressing
    Protocol (ISATAP) implementation. It places the ISATAP potential router
    list (PRL) in the kernel and adds three new private ioctls for PRL
    management.
    
    [Add several changes of structure name, constant names etc. - yoshfuji]
    
    Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index 228eb4e..f20c224 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -7,6 +7,9 @@
 #define SIOCADDTUNNEL   (SIOCDEVPRIVATE + 1)
 #define SIOCDELTUNNEL   (SIOCDEVPRIVATE + 2)
 #define SIOCCHGTUNNEL   (SIOCDEVPRIVATE + 3)
+#define SIOCADDPRL      (SIOCDEVPRIVATE + 5)
+#define SIOCDELPRL      (SIOCDEVPRIVATE + 6)
+#define SIOCCHGPRL      (SIOCDEVPRIVATE + 7)
 
 #define GRE_CSUM	__constant_htons(0x8000)
 #define GRE_ROUTING	__constant_htons(0x4000)
@@ -17,9 +20,6 @@
 #define GRE_FLAGS	__constant_htons(0x00F8)
 #define GRE_VERSION	__constant_htons(0x0007)
 
-/* i_flags values for SIT mode */
-#define	SIT_ISATAP	0x0001
-
 struct ip_tunnel_parm
 {
 	char			name[IFNAMSIZ];
@@ -31,4 +31,16 @@ struct ip_tunnel_parm
 	struct iphdr		iph;
 };
 
+/* SIT-mode i_flags */
+#define	SIT_ISATAP	0x0001
+
+struct ip_tunnel_prl {
+	__be32			addr;
+	__u16			flags;
+	__u16			__reserved;
+};
+
+/* PRL flags */
+#define	PRL_DEFAULT		0x0001
+
 #endif /* _IF_TUNNEL_H_ */
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ff72145..e10e55c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -313,7 +313,8 @@ struct sk_buff {
 	__u16			tc_verd;	/* traffic control verdict */
 #endif
 #endif
-	/* 2 byte hole */
+	__u8			ndisc_nodetype:2;
+	/* 14 bit hole */
 
 #ifdef CONFIG_NET_DMA
 	dma_cookie_t		dma_cookie;
diff --git a/include/net/ipip.h b/include/net/ipip.h
index 549e132..205536a 100644
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -24,6 +24,13 @@ struct ip_tunnel
 	int			mlink;
 
 	struct ip_tunnel_parm	parms;
+	struct ip_tunnel_prl_entry	*prl;		/* potential router list */
+};
+
+struct ip_tunnel_prl_entry
+{
+	struct ip_tunnel_prl_entry	*next;
+	struct ip_tunnel_prl		entry;
 };
 
 #define IPTUNNEL_XMIT() do {						\
diff --git a/include/net/ndisc.h b/include/net/ndisc.h
index 5aedf32..9f2bae6 100644
--- a/include/net/ndisc.h
+++ b/include/net/ndisc.h
@@ -12,6 +12,15 @@
 #define NDISC_REDIRECT			137
 
 /*
+ * Router type: cross-layer information from link-layer to
+ * IPv6 layer reported by certain link types (e.g., RFC4214).
+ */
+#define NDISC_NODETYPE_UNSPEC		0	/* unspecified (default) */
+#define NDISC_NODETYPE_HOST		1	/* host or unauthorized router */
+#define NDISC_NODETYPE_NODEFAULT	2	/* non-default router */
+#define NDISC_NODETYPE_DEFAULT		3	/* default router */
+
+/*
  *	ndisc options
  */
 
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 510aa74..53b5460 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1092,6 +1092,12 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 		return;
 	}
 
+	if (skb->ndisc_nodetype == NDISC_NODETYPE_HOST) {
+		ND_PRINTK2(KERN_WARNING
+			   "ICMPv6 RA: from host or unauthorized router\n");
+		return;
+	}
+
 	/*
 	 *	set the RA_RECV flag in the interface
 	 */
@@ -1115,6 +1121,10 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 		return;
 	}
 
+	/* skip link-specific parameters from interior routers */
+	if (skb->ndisc_nodetype == NDISC_NODETYPE_NODEFAULT)
+		goto skip_linkparms;
+
 	if (in6_dev->if_flags & IF_RS_SENT) {
 		/*
 		 *	flag that an RA was received after an RS was sent
@@ -1229,6 +1239,8 @@ skip_defrtr:
 		}
 	}
 
+skip_linkparms:
+
 	/*
 	 *	Process options.
 	 */
@@ -1268,6 +1280,10 @@ skip_defrtr:
 	}
 #endif
 
+	/* skip link-specific ndopts from interior routers */
+	if (skb->ndisc_nodetype == NDISC_NODETYPE_NODEFAULT)
+		goto out;
+
 	if (in6_dev->cnf.accept_ra_pinfo && ndopts.nd_opts_pi) {
 		struct nd_opt_hdr *p;
 		for (p = ndopts.nd_opts_pi;
@@ -1331,6 +1347,14 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 	int optlen;
 	u8 *lladdr = NULL;
 
+	switch (skb->ndisc_nodetype) {
+	case NDISC_NODETYPE_HOST:
+	case NDISC_NODETYPE_NODEFAULT:
+		ND_PRINTK2(KERN_WARNING
+			   "ICMPv6 Redirect: from host or unauthorized router\n");
+		return;
+	}
+
 	if (!(ipv6_addr_type(&ipv6_hdr(skb)->saddr) & IPV6_ADDR_LINKLOCAL)) {
 		ND_PRINTK2(KERN_WARNING
 			   "ICMPv6 Redirect: source address is not link-local.\n");
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index cd82b6d..f17b2f6 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1699,8 +1699,6 @@ struct rt6_info *rt6_get_dflt_router(struct in6_addr *addr, struct net_device *d
 	return rt;
 }
 
-EXPORT_SYMBOL(rt6_get_dflt_router);
-
 struct rt6_info *rt6_add_dflt_router(struct in6_addr *gwaddr,
 				     struct net_device *dev,
 				     unsigned int pref)
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 1b8196c..4786419 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -16,7 +16,7 @@
  *	Changes:
  * Roger Venning <r.venning@telstra.com>:	6to4 support
  * Nate Thompson <nate@thebog.net>:		6to4 support
- * Fred L. Templin <fltemplin@acm.org>:		isatap support
+ * Fred Templin <fred.l.templin@boeing.com>:	isatap support
  */
 
 #include <linux/module.h>
@@ -197,6 +197,119 @@ failed:
 	return NULL;
 }
 
+static struct ip_tunnel_prl_entry *
+ipip6_tunnel_locate_prl(struct ip_tunnel *t, __be32 addr)
+{
+	struct ip_tunnel_prl_entry *p = (struct ip_tunnel_prl_entry *)NULL;
+
+	for (p = t->prl; p; p = p->next)
+		if (p->entry.addr == addr)
+			break;
+	return p;
+
+}
+
+static int
+ipip6_tunnel_add_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a, int chg)
+{
+	struct ip_tunnel_prl_entry *p;
+
+	for (p = t->prl; p; p = p->next) {
+		if (p->entry.addr == a->addr) {
+			if (chg) {
+				p->entry = *a;
+				return 0;
+			}
+			return -EEXIST;
+		}
+	}
+
+	if (chg)
+		return -ENXIO;
+
+	p = kzalloc(sizeof(struct ip_tunnel_prl_entry), GFP_KERNEL);
+	if (!p)
+		return -ENOBUFS;
+
+	p->entry = *a;
+	p->next = t->prl;
+	t->prl = p;
+	return 0;
+}
+
+static int
+ipip6_tunnel_del_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a)
+{
+	struct ip_tunnel_prl_entry *x, **p;
+
+	if (a) {
+		for (p = &t->prl; *p; p = &(*p)->next) {
+			if ((*p)->entry.addr == a->addr) {
+				x = *p;
+				*p = x->next;
+				kfree(x);
+				return 0;
+			}
+		}
+		return -ENXIO;
+	} else {
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
+	struct ip_tunnel_prl_entry *p = ipip6_tunnel_locate_prl(t, iph->saddr);
+	int ok = 1;
+
+	if (p) {
+		if (p->entry.flags & PRL_DEFAULT)
+			skb->ndisc_nodetype = NDISC_NODETYPE_DEFAULT;
+		else
+			skb->ndisc_nodetype = NDISC_NODETYPE_NODEFAULT;
+	} else {
+		struct in6_addr *addr6 = &ipv6_hdr(skb)->saddr;
+		if (ipv6_addr_is_isatap(addr6) &&
+		    (addr6->s6_addr32[3] == iph->saddr) &&
+		    ipip6_onlink(addr6, t->dev))
+			skb->ndisc_nodetype = NDISC_NODETYPE_HOST;
+		else
+			ok = 0;
+	}
+	return ok;
+}
+
 static void ipip6_tunnel_uninit(struct net_device *dev)
 {
 	if (dev == ipip6_fb_tunnel_dev) {
@@ -206,6 +319,7 @@ static void ipip6_tunnel_uninit(struct net_device *dev)
 		dev_put(dev);
 	} else {
 		ipip6_tunnel_unlink(netdev_priv(dev));
+		ipip6_tunnel_del_prl(netdev_priv(dev), 0);
 		dev_put(dev);
 	}
 }
@@ -365,48 +479,6 @@ static inline void ipip6_ecn_decapsulate(struct iphdr *iph, struct sk_buff *skb)
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
-	dst = ip6_route_output(&init_net, NULL, &fl);
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
@@ -427,7 +499,7 @@ static int ipip6_rcv(struct sk_buff *skb)
 		skb->pkt_type = PACKET_HOST;
 
 		if ((tunnel->dev->priv_flags & IFF_ISATAP) &&
-		    !isatap_srcok(skb, iph, tunnel->dev)) {
+		    !isatap_chksrc(skb, iph, tunnel)) {
 			tunnel->stat.rx_errors++;
 			read_unlock(&ipip6_lock);
 			kfree_skb(skb);
@@ -707,6 +779,7 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	int err = 0;
 	struct ip_tunnel_parm p;
+	struct ip_tunnel_prl prl;
 	struct ip_tunnel *t;
 
 	switch (cmd) {
@@ -806,6 +879,31 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
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

---
commit 3fcfa12904e83cc291cf2b7b05ff2530068920a4
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sat Mar 22 17:42:57 2008 +0900

    [IPV6] SIT: Fix locking issues in PRL management.
    
    To protect PRL list, use ipip6_lock.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 4786419..ee0cc28 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -198,7 +198,7 @@ failed:
 }
 
 static struct ip_tunnel_prl_entry *
-ipip6_tunnel_locate_prl(struct ip_tunnel *t, __be32 addr)
+__ipip6_tunnel_locate_prl(struct ip_tunnel *t, __be32 addr)
 {
 	struct ip_tunnel_prl_entry *p = (struct ip_tunnel_prl_entry *)NULL;
 
@@ -213,34 +213,46 @@ static int
 ipip6_tunnel_add_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a, int chg)
 {
 	struct ip_tunnel_prl_entry *p;
+	int err = 0;
+
+	write_lock(&ipip6_lock);
 
 	for (p = t->prl; p; p = p->next) {
 		if (p->entry.addr == a->addr) {
-			if (chg) {
-				p->entry = *a;
-				return 0;
-			}
-			return -EEXIST;
+			if (chg)
+				goto update;
+			err = -EEXIST;
+			goto out;
 		}
 	}
 
-	if (chg)
-		return -ENXIO;
+	if (chg) {
+		err = -ENXIO;
+		goto out;
+	}
 
 	p = kzalloc(sizeof(struct ip_tunnel_prl_entry), GFP_KERNEL);
-	if (!p)
-		return -ENOBUFS;
+	if (!p) {
+		err = -ENOBUFS;
+		goto out;
+	}
 
-	p->entry = *a;
 	p->next = t->prl;
 	t->prl = p;
-	return 0;
+update:
+	p->entry = *a;
+out:
+	write_unlock(&ipip6_lock);
+	return err;
 }
 
 static int
 ipip6_tunnel_del_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a)
 {
 	struct ip_tunnel_prl_entry *x, **p;
+	int err = 0;
+
+	write_lock(&ipip6_lock);
 
 	if (a) {
 		for (p = &t->prl; *p; p = &(*p)->next) {
@@ -248,10 +260,10 @@ ipip6_tunnel_del_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a)
 				x = *p;
 				*p = x->next;
 				kfree(x);
-				return 0;
+				goto out;
 			}
 		}
-		return -ENXIO;
+		err = -ENXIO;
 	} else {
 		while (t->prl) {
 			x = t->prl;
@@ -259,6 +271,8 @@ ipip6_tunnel_del_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a)
 			kfree(x);
 		}
 	}
+out:
+	write_unlock(&ipip6_lock);
 	return 0;
 }
 
@@ -290,9 +304,11 @@ ipip6_onlink(struct in6_addr *addr, struct net_device *dev)
 static int
 isatap_chksrc(struct sk_buff *skb, struct iphdr *iph, struct ip_tunnel *t)
 {
-	struct ip_tunnel_prl_entry *p = ipip6_tunnel_locate_prl(t, iph->saddr);
+	struct ip_tunnel_prl_entry *p;
 	int ok = 1;
 
+	read_lock(&ipip6_lock);
+	p = __ipip6_tunnel_locate_prl(t, iph->saddr);
 	if (p) {
 		if (p->entry.flags & PRL_DEFAULT)
 			skb->ndisc_nodetype = NDISC_NODETYPE_DEFAULT;
@@ -307,6 +323,7 @@ isatap_chksrc(struct sk_buff *skb, struct iphdr *iph, struct ip_tunnel *t)
 		else
 			ok = 0;
 	}
+	read_unlock(&ipip6_lock);
 	return ok;
 }
 
@@ -895,12 +912,10 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (!(t = netdev_priv(dev)))
 			goto done;
 
-		ipip6_tunnel_unlink(t);
 		if (cmd == SIOCDELPRL)
 			err = ipip6_tunnel_del_prl(t, &prl);
 		else
 			err = ipip6_tunnel_add_prl(t, &prl, cmd == SIOCCHGPRL);
-		ipip6_tunnel_link(t);
 		netdev_state_change(dev);
 		break;
 

---
commit 0009ae1f50fb10178b5f54216ce567f3cb1d7267
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sat Mar 22 17:50:59 2008 +0900

    [IPV6] SIT: Disallow 0.0.0.0 in PRL and Flush PRL if given for DEL.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index ee0cc28..84c1ed2 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -215,6 +215,9 @@ ipip6_tunnel_add_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a, int chg)
 	struct ip_tunnel_prl_entry *p;
 	int err = 0;
 
+	if (a->addr == htonl(INADDR_ANY))
+		return -EINVAL;
+
 	write_lock(&ipip6_lock);
 
 	for (p = t->prl; p; p = p->next) {
@@ -254,7 +257,7 @@ ipip6_tunnel_del_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a)
 
 	write_lock(&ipip6_lock);
 
-	if (a) {
+	if (a && a->addr != htonl(INADDR_ANY)) {
 		for (p = &t->prl; *p; p = &(*p)->next) {
 			if ((*p)->entry.addr == a->addr) {
 				x = *p;

---
commit 300aaeeaab5f447fcf40e911afe96df3de28f0db
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Mon Mar 24 18:28:39 2008 +0900

    [IPV6] SIT: Add SIOCGETPRL ioctl to get/dump PRL.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index f20c224..f1fbe9c 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -7,6 +7,7 @@
 #define SIOCADDTUNNEL   (SIOCDEVPRIVATE + 1)
 #define SIOCDELTUNNEL   (SIOCDEVPRIVATE + 2)
 #define SIOCCHGTUNNEL   (SIOCDEVPRIVATE + 3)
+#define SIOCGETPRL      (SIOCDEVPRIVATE + 4)
 #define SIOCADDPRL      (SIOCDEVPRIVATE + 5)
 #define SIOCDELPRL      (SIOCDEVPRIVATE + 6)
 #define SIOCCHGPRL      (SIOCDEVPRIVATE + 7)
@@ -38,6 +39,9 @@ struct ip_tunnel_prl {
 	__be32			addr;
 	__u16			flags;
 	__u16			__reserved;
+	__u32			datalen;
+	__u32			__reserved2;
+	void __user		*data;
 };
 
 /* PRL flags */
diff --git a/include/net/ipip.h b/include/net/ipip.h
index 205536a..633ed4d 100644
--- a/include/net/ipip.h
+++ b/include/net/ipip.h
@@ -24,13 +24,16 @@ struct ip_tunnel
 	int			mlink;
 
 	struct ip_tunnel_parm	parms;
+
 	struct ip_tunnel_prl_entry	*prl;		/* potential router list */
+	unsigned int			prl_count;	/* # of entries in PRL */
 };
 
 struct ip_tunnel_prl_entry
 {
 	struct ip_tunnel_prl_entry	*next;
-	struct ip_tunnel_prl		entry;
+	__be32				addr;
+	u16				flags;
 };
 
 #define IPTUNNEL_XMIT() do {						\
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 84c1ed2..08a483a 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -203,12 +203,73 @@ __ipip6_tunnel_locate_prl(struct ip_tunnel *t, __be32 addr)
 	struct ip_tunnel_prl_entry *p = (struct ip_tunnel_prl_entry *)NULL;
 
 	for (p = t->prl; p; p = p->next)
-		if (p->entry.addr == addr)
+		if (p->addr == addr)
 			break;
 	return p;
 
 }
 
+static int ipip6_tunnel_get_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a)
+{
+	struct ip_tunnel_prl *kp;
+	struct ip_tunnel_prl_entry *prl;
+	unsigned int cmax, c = 0, ca, len;
+	int ret = 0;
+
+	cmax = a->datalen / sizeof(*a);
+	if (cmax > 1 && a->addr != htonl(INADDR_ANY))
+		cmax = 1;
+
+	/* For simple GET or for root users,
+	 * we try harder to allocate.
+	 */
+	kp = (cmax <= 1 || capable(CAP_NET_ADMIN)) ?
+		kcalloc(cmax, sizeof(*kp), GFP_KERNEL) :
+		NULL;
+
+	read_lock(&ipip6_lock);
+
+	ca = t->prl_count < cmax ? t->prl_count : cmax;
+
+	if (!kp) {
+		/* We don't try hard to allocate much memory for
+		 * non-root users.
+		 * For root users, retry allocating enough memory for
+		 * the answer.
+		 */
+		kp = kcalloc(ca, sizeof(*kp), GFP_ATOMIC);
+		if (!kp) {
+			ret = -ENOMEM;
+			goto out;
+		}
+	}
+
+	c = 0;
+	for (prl = t->prl; prl; prl = prl->next) {
+		if (c > cmax)
+			break;
+		if (a->addr != htonl(INADDR_ANY) && prl->addr != a->addr)
+			continue;
+		kp[c].addr = prl->addr;
+		kp[c].flags = prl->flags;
+		c++;
+		if (a->addr != htonl(INADDR_ANY))
+			break;
+	}
+out:
+	read_unlock(&ipip6_lock);
+
+	len = sizeof(*kp) * c;
+	ret = len ? copy_to_user(a->data, kp, len) : 0;
+
+	kfree(kp);
+	if (ret)
+		return -EFAULT;
+
+	a->datalen = len;
+	return 0;
+}
+
 static int
 ipip6_tunnel_add_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a, int chg)
 {
@@ -221,7 +282,7 @@ ipip6_tunnel_add_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a, int chg)
 	write_lock(&ipip6_lock);
 
 	for (p = t->prl; p; p = p->next) {
-		if (p->entry.addr == a->addr) {
+		if (p->addr == a->addr) {
 			if (chg)
 				goto update;
 			err = -EEXIST;
@@ -242,8 +303,10 @@ ipip6_tunnel_add_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a, int chg)
 
 	p->next = t->prl;
 	t->prl = p;
+	t->prl_count++;
 update:
-	p->entry = *a;
+	p->addr = a->addr;
+	p->flags = a->flags;
 out:
 	write_unlock(&ipip6_lock);
 	return err;
@@ -259,10 +322,11 @@ ipip6_tunnel_del_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a)
 
 	if (a && a->addr != htonl(INADDR_ANY)) {
 		for (p = &t->prl; *p; p = &(*p)->next) {
-			if ((*p)->entry.addr == a->addr) {
+			if ((*p)->addr == a->addr) {
 				x = *p;
 				*p = x->next;
 				kfree(x);
+				t->prl_count--;
 				goto out;
 			}
 		}
@@ -272,6 +336,7 @@ ipip6_tunnel_del_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a)
 			x = t->prl;
 			t->prl = t->prl->next;
 			kfree(x);
+			t->prl_count--;
 		}
 	}
 out:
@@ -313,7 +378,7 @@ isatap_chksrc(struct sk_buff *skb, struct iphdr *iph, struct ip_tunnel *t)
 	read_lock(&ipip6_lock);
 	p = __ipip6_tunnel_locate_prl(t, iph->saddr);
 	if (p) {
-		if (p->entry.flags & PRL_DEFAULT)
+		if (p->flags & PRL_DEFAULT)
 			skb->ndisc_nodetype = NDISC_NODETYPE_DEFAULT;
 		else
 			skb->ndisc_nodetype = NDISC_NODETYPE_NODEFAULT;
@@ -899,11 +964,12 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 		err = 0;
 		break;
 
+	case SIOCGETPRL:
 	case SIOCADDPRL:
 	case SIOCDELPRL:
 	case SIOCCHGPRL:
 		err = -EPERM;
-		if (!capable(CAP_NET_ADMIN))
+		if (cmd != SIOCGETPRL && !capable(CAP_NET_ADMIN))
 			goto done;
 		err = -EINVAL;
 		if (dev == ipip6_fb_tunnel_dev)
@@ -915,11 +981,23 @@ ipip6_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
 		if (!(t = netdev_priv(dev)))
 			goto done;
 
-		if (cmd == SIOCDELPRL)
+		switch (cmd) {
+		case SIOCGETPRL:
+			err = ipip6_tunnel_get_prl(t, &prl);
+			if (!err && copy_to_user(ifr->ifr_ifru.ifru_data,
+						 &prl, sizeof(prl)))
+				err = -EFAULT;
+			break;
+		case SIOCDELPRL:
 			err = ipip6_tunnel_del_prl(t, &prl);
-		else
+			break;
+		case SIOCADDPRL:
+		case SIOCCHGPRL:
 			err = ipip6_tunnel_add_prl(t, &prl, cmd == SIOCCHGPRL);
-		netdev_state_change(dev);
+			break;
+		}
+		if (cmd != SIOCGETPRL)
+			netdev_state_change(dev);
 		break;
 
 	default:

---
commit 6294e000736401d4415ad41f408e56e14aaaf7b4
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sat Mar 15 23:56:52 2008 -0400

    [IPV6] NDISC: Ignore route information with /0 prefix from interior router.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 53b5460..16273e1 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1272,7 +1272,13 @@ skip_linkparms:
 		for (p = ndopts.nd_opts_ri;
 		     p;
 		     p = ndisc_next_option(p, ndopts.nd_opts_ri_end)) {
-			if (((struct route_info *)p)->prefix_len > in6_dev->cnf.accept_ra_rt_info_max_plen)
+			struct route_info *ri = (struct route_info *)p;
+#ifdef CONFIG_IPV6_NDISC_NODETYPE
+			if (skb->ndisc_nodetype == NDISC_NODETYPE_NODEFAULT &&
+			    ri->prefix_len == 0)
+				continue;
+#endif
+			if (ri->prefix_len > in6_dev->cnf.accept_ra_rt_info_max_plen)
 				continue;
 			rt6_route_rcv(skb->dev, (u8*)p, (p->nd_opt_len) << 3,
 				      &ipv6_hdr(skb)->saddr);

---
commit 52eeeb8481d705e61e2e9aae974e7799a93783e9
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sat Mar 15 22:54:23 2008 -0400

    [IPV6]: Unify ip6_onlink() and ipip6_onlink().
    
    Both are identical, let's create ipv6_chk_prefix() and use it
    in both places.

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index d89b0bc..bdcc863 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -71,6 +71,10 @@ extern int			ipv6_chk_addr(struct net *net,
 extern int			ipv6_chk_home_addr(struct net *net,
 						   struct in6_addr *addr);
 #endif
+
+extern int			ipv6_chk_prefix(struct in6_addr *addr,
+						struct net_device *dev);
+
 extern struct inet6_ifaddr      *ipv6_get_ifaddr(struct net *net,
 						 struct in6_addr *addr,
 						 struct net_device *dev,
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 5ab9973..c17f8c0 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1249,6 +1249,31 @@ int ipv6_chk_same_addr(struct net *net, const struct in6_addr *addr,
 	return ifp != NULL;
 }
 
+int ipv6_chk_prefix(struct in6_addr *addr, struct net_device *dev)
+{
+	struct inet6_dev *idev;
+	struct inet6_ifaddr *ifa;
+	int	onlink;
+
+	onlink = 0;
+	rcu_read_lock();
+	idev = __in6_dev_get(dev);
+	if (idev) {
+		read_lock_bh(&idev->lock);
+		for (ifa = idev->addr_list; ifa; ifa = ifa->if_next) {
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
+EXPORT_SYMBOL(ipv6_chk_prefix);
+
 struct inet6_ifaddr *ipv6_get_ifaddr(struct net *net, struct in6_addr *addr,
 				     struct net_device *dev, int strict)
 {
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index 463bd95..36e8174 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -48,29 +48,6 @@ static int ipv6_dev_ac_dec(struct net_device *dev, struct in6_addr *addr);
 /* Big ac list lock for all the sockets */
 static DEFINE_RWLOCK(ipv6_sk_ac_lock);
 
-static int
-ip6_onlink(struct in6_addr *addr, struct net_device *dev)
-{
-	struct inet6_dev	*idev;
-	struct inet6_ifaddr	*ifa;
-	int	onlink;
-
-	onlink = 0;
-	rcu_read_lock();
-	idev = __in6_dev_get(dev);
-	if (idev) {
-		read_lock_bh(&idev->lock);
-		for (ifa=idev->addr_list; ifa; ifa=ifa->if_next) {
-			onlink = ipv6_prefix_equal(addr, &ifa->addr,
-						   ifa->prefix_len);
-			if (onlink)
-				break;
-		}
-		read_unlock_bh(&idev->lock);
-	}
-	rcu_read_unlock();
-	return onlink;
-}
 
 /*
  *	socket join an anycast group
@@ -142,7 +119,7 @@ int ipv6_sock_ac_join(struct sock *sk, int ifindex, struct in6_addr *addr)
 	 * This obviates the need for propagating anycast routes while
 	 * still allowing some non-router anycast participation.
 	 */
-	if (!ip6_onlink(addr, dev)) {
+	if (!ipv6_chk_prefix(addr, dev)) {
 		if (ishost)
 			err = -EADDRNOTAVAIL;
 		if (err)
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 08a483a..cc16fe0 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -344,31 +344,6 @@ out:
 	return 0;
 }
 
-/* copied directly from anycast.c */
-static int
-ipip6_onlink(struct in6_addr *addr, struct net_device *dev)
-{
-	struct inet6_dev	*idev;
-	struct inet6_ifaddr	*ifa;
-	int	onlink;
-
-	onlink = 0;
-	rcu_read_lock();
-	idev = __in6_dev_get(dev);
-	if (idev) {
-		read_lock_bh(&idev->lock);
-		for (ifa=idev->addr_list; ifa; ifa=ifa->if_next) {
-			onlink = ipv6_prefix_equal(addr, &ifa->addr,
-						   ifa->prefix_len);
-			if (onlink)
-				break;
-		}
-		read_unlock_bh(&idev->lock);
-	}
-	rcu_read_unlock();
-	return onlink;
-}
-
 static int
 isatap_chksrc(struct sk_buff *skb, struct iphdr *iph, struct ip_tunnel *t)
 {
@@ -386,7 +361,7 @@ isatap_chksrc(struct sk_buff *skb, struct iphdr *iph, struct ip_tunnel *t)
 		struct in6_addr *addr6 = &ipv6_hdr(skb)->saddr;
 		if (ipv6_addr_is_isatap(addr6) &&
 		    (addr6->s6_addr32[3] == iph->saddr) &&
-		    ipip6_onlink(addr6, t->dev))
+		    ipv6_chk_prefix(addr6, t->dev))
 			skb->ndisc_nodetype = NDISC_NODETYPE_HOST;
 		else
 			ok = 0;

---
commit de357cc01334a468e4d5b7ba66a17b0d3ca9d63e
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Sat Mar 15 23:59:18 2008 -0400

    [IPV6] NDISC: Don't rely on node-type hint from L2 unless required.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index e10e55c..e517701 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -313,7 +313,9 @@ struct sk_buff {
 	__u16			tc_verd;	/* traffic control verdict */
 #endif
 #endif
+#ifdef CONFIG_IPV6_NDISC_NODETYPE
 	__u8			ndisc_nodetype:2;
+#endif
 	/* 14 bit hole */
 
 #ifdef CONFIG_NET_DMA
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 47263e4..7d2e7f0 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -168,6 +168,7 @@ config IPV6_SIT
 	tristate "IPv6: IPv6-in-IPv4 tunnel (SIT driver)"
 	depends on IPV6
 	select INET_TUNNEL
+	select IPV6_NDISC_NODETYPE
 	default y
 	---help---
 	  Tunneling means encapsulating data of one protocol type within
@@ -178,6 +179,9 @@ config IPV6_SIT
 
 	  Saying M here will produce a module called sit.ko. If unsure, say Y.
 
+config IPV6_NDISC_NODETYPE
+	bool
+
 config IPV6_TUNNEL
 	tristate "IPv6: IP-in-IPv6 tunnel (RFC2473)"
 	select INET6_TUNNEL
diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 16273e1..c400b87 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -1092,11 +1092,13 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 		return;
 	}
 
+#ifdef CONFIG_IPV6_NDISC_NODETYPE
 	if (skb->ndisc_nodetype == NDISC_NODETYPE_HOST) {
 		ND_PRINTK2(KERN_WARNING
 			   "ICMPv6 RA: from host or unauthorized router\n");
 		return;
 	}
+#endif
 
 	/*
 	 *	set the RA_RECV flag in the interface
@@ -1121,9 +1123,11 @@ static void ndisc_router_discovery(struct sk_buff *skb)
 		return;
 	}
 
+#ifdef CONFIG_IPV6_NDISC_NODETYPE
 	/* skip link-specific parameters from interior routers */
 	if (skb->ndisc_nodetype == NDISC_NODETYPE_NODEFAULT)
 		goto skip_linkparms;
+#endif
 
 	if (in6_dev->if_flags & IF_RS_SENT) {
 		/*
@@ -1239,7 +1243,9 @@ skip_defrtr:
 		}
 	}
 
+#ifdef CONFIG_IPV6_NDISC_NODETYPE
 skip_linkparms:
+#endif
 
 	/*
 	 *	Process options.
@@ -1286,9 +1292,11 @@ skip_linkparms:
 	}
 #endif
 
+#ifdef CONFIG_IPV6_NDISC_NODETYPE
 	/* skip link-specific ndopts from interior routers */
 	if (skb->ndisc_nodetype == NDISC_NODETYPE_NODEFAULT)
 		goto out;
+#endif
 
 	if (in6_dev->cnf.accept_ra_pinfo && ndopts.nd_opts_pi) {
 		struct nd_opt_hdr *p;
@@ -1353,6 +1361,7 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 	int optlen;
 	u8 *lladdr = NULL;
 
+#ifdef CONFIG_IPV6_NDISC_NODETYPE
 	switch (skb->ndisc_nodetype) {
 	case NDISC_NODETYPE_HOST:
 	case NDISC_NODETYPE_NODEFAULT:
@@ -1360,6 +1369,7 @@ static void ndisc_redirect_rcv(struct sk_buff *skb)
 			   "ICMPv6 Redirect: from host or unauthorized router\n");
 		return;
 	}
+#endif
 
 	if (!(ipv6_addr_type(&ipv6_hdr(skb)->saddr) & IPV6_ADDR_LINKLOCAL)) {
 		ND_PRINTK2(KERN_WARNING

---
