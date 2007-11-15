From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: [PATCH 01/01] ipv6: RFC4214 Support (v2.2)
Date: Wed, 14 Nov 2007 22:44:17 -0800
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC2B@XCH-NW-7V2.nw.nos.boeing.com>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC14@XCH-NW-7V2.nw.nos.boeing.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC1F@XCH-NW-7V2.nw.nos.boeing.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC22@XCH-NW-7V2.nw.nos.boeing.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC24@XCH-NW-7V2.nw.nos.boeing.com> <4739C7EA.5070609@hp.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC27@XCH-NW-7V2.nw.nos.boeing.com> <4739D7F7.90300@hp.com> <39C363776A4E8C4A94691D2BD9D1C9A1029EDC29@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: =?iso-2022-jp?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>,
	"Vlad Yasevich" <vladislav.yasevich@hp.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stl-smtpout-01.boeing.com ([130.76.96.56]:35358 "EHLO
	stl-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764810AbXKOGor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 01:44:47 -0500
Content-class: urn:content-classes:message
In-Reply-To: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC29@XCH-NW-7V2.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fred L. Templin <fred.l.templin@boeing.com>

This patch includes support for the Intra-Site Automatic Tunnel
Addressing Protocol (ISATAP) per RFC4214. It uses the SIT
module, and is configured using extensions to the "iproute2"
utility.

The following diffs are specific to the Linux 2.6.24-rc2 kernel
distribution. This message includes the full and patchable diff text;
please use this version to apply patches.

Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>

---

--- linux-2.6.24-rc2/include/linux/if.h.orig	2007-11-08 12:05:47.000000000 -0800
+++ linux-2.6.24-rc2/include/linux/if.h	2007-11-08 08:26:44.000000000 -0800
@@ -61,6 +61,7 @@
 #define IFF_MASTER_ALB	0x10		/* bonding master, balance-alb.	*/
 #define IFF_BONDING	0x20		/* bonding master or slave	*/
 #define IFF_SLAVE_NEEDARP 0x40		/* need ARPs for validation	*/
+#define IFF_ISATAP	0x80		/* ISATAP interface (RFC4214)	*/
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002
--- linux-2.6.24-rc2/include/linux/in.h.orig	2007-11-09 08:00:32.000000000 -0800
+++ linux-2.6.24-rc2/include/linux/in.h	2007-11-12 07:37:05.000000000 -0800
@@ -253,6 +253,14 @@ struct sockaddr_in {
 #define ZERONET(x)	(((x) & htonl(0xff000000)) == htonl(0x00000000))
 #define LOCAL_MCAST(x)	(((x) & htonl(0xFFFFFF00)) == htonl(0xE0000000))
 
+/* Special-Use IPv4 Addresses (RFC3330) */
+#define PRIVATE_10(x)	(((x) & htonl(0xff000000)) == htonl(0x0A000000))
+#define LINKLOCAL_169(x) (((x) & htonl(0xffff0000)) == htonl(0xA9FE0000))
+#define PRIVATE_172(x)	(((x) & htonl(0xfff00000)) == htonl(0xAC100000))
+#define TEST_192(x)	(((x) & htonl(0xffffff00)) == htonl(0xC0000200))
+#define ANYCAST_6TO4(x)	(((x) & htonl(0xffffff00)) == htonl(0xC0586300))
+#define PRIVATE_192(x)	(((x) & htonl(0xffff0000)) == htonl(0xC0A80000))
+#define TEST_198(x)	(((x) & htonl(0xfffe0000)) == htonl(0xC6120000))
 #endif
 
 #endif	/* _LINUX_IN_H */
--- linux-2.6.24-rc2/include/net/addrconf.h.orig	2007-11-08 12:06:17.000000000 -0800
+++ linux-2.6.24-rc2/include/net/addrconf.h	2007-11-12 14:29:51.000000000 -0800
@@ -241,6 +241,12 @@ static inline int ipv6_addr_is_ll_all_ro
 		addr->s6_addr32[3] == htonl(0x00000002));
 }
 
+/* only for IFF_ISATAP interfaces */
+static inline int ipv6_addr_is_isatap(const struct in6_addr *addr)
+{
+	return ((addr->s6_addr32[2] | htonl(0x02000000)) == htonl(0x02005EFE));
+}
+
 #ifdef CONFIG_PROC_FS
 extern int if6_proc_init(void);
 extern void if6_proc_exit(void);
--- linux-2.6.24-rc2/net/ipv6/addrconf.c.orig	2007-11-08 11:59:35.000000000 -0800
+++ linux-2.6.24-rc2/net/ipv6/addrconf.c	2007-11-14 22:17:28.000000000 -0800
@@ -75,7 +75,7 @@
 #include <net/ip.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
-#include <linux/if_tunnel.h>
+#include <net/ipip.h>
 #include <linux/rtnetlink.h>
 
 #ifdef CONFIG_IPV6_PRIVACY
@@ -1424,6 +1424,21 @@ static int addrconf_ifid_infiniband(u8 *
 	return 0;
 }
 
+static int addrconf_ifid_isatap(u8 *eui, __be32 addr)
+{
+
+	eui[0] = 0x02; eui[1] = 0; eui[2] = 0x5E; eui[3] = 0xFE;
+	memcpy (eui+4, &addr, 4);
+
+	if (ZERONET(addr) || PRIVATE_10(addr) || LOOPBACK(addr) ||
+	    LINKLOCAL_169(addr) || PRIVATE_172(addr) || TEST_192(addr) ||
+	    ANYCAST_6TO4(addr) || PRIVATE_192(addr) || TEST_198(addr) ||
+	    MULTICAST(addr) || BADCLASS(addr))
+		eui[0] &= ~0x02;
+
+	return 0;
+}
+
 static int ipv6_generate_eui64(u8 *eui, struct net_device *dev)
 {
 	switch (dev->type) {
@@ -1435,6 +1450,9 @@ static int ipv6_generate_eui64(u8 *eui, 
 		return addrconf_ifid_arcnet(eui, dev);
 	case ARPHRD_INFINIBAND:
 		return addrconf_ifid_infiniband(eui, dev);
+	case ARPHRD_SIT:
+		if (dev->priv_flags & IFF_ISATAP)
+			return addrconf_ifid_isatap(eui, *(__be32 *)dev->dev_addr);
 	}
 	return -1;
 }
@@ -1470,7 +1488,7 @@ regen:
 	 *
 	 *  - Reserved subnet anycast (RFC 2526)
 	 *	11111101 11....11 1xxxxxxx
-	 *  - ISATAP (draft-ietf-ngtrans-isatap-13.txt) 5.1
+	 *  - ISATAP (RFC4214)
 	 *	00-00-5E-FE-xx-xx-xx-xx
 	 *  - value 0
 	 *  - XXX: already assigned to an address on the device
@@ -2167,7 +2185,8 @@ static void addrconf_dev_config(struct n
 	    (dev->type != ARPHRD_FDDI) &&
 	    (dev->type != ARPHRD_IEEE802_TR) &&
 	    (dev->type != ARPHRD_ARCNET) &&
-	    (dev->type != ARPHRD_INFINIBAND)) {
+	    (dev->type != ARPHRD_INFINIBAND) &&
+	    !(dev->priv_flags & IFF_ISATAP)) {
 		/* Alas, we support only Ethernet autoconfiguration. */
 		return;
 	}
@@ -2320,7 +2339,10 @@ static int addrconf_notify(struct notifi
 		switch(dev->type) {
 #if defined(CONFIG_IPV6_SIT) || defined(CONFIG_IPV6_SIT_MODULE)
 		case ARPHRD_SIT:
-			addrconf_sit_config(dev);
+			if (dev->priv_flags & IFF_ISATAP)
+				addrconf_dev_config(dev);
+			else
+				addrconf_sit_config(dev);
 			break;
 #endif
 		case ARPHRD_TUNNEL6:
@@ -2519,6 +2541,32 @@ static int addrconf_ifdown(struct net_de
 	return 0;
 }
 
+static void
+addrconf_isatap_sched_rs(struct inet6_ifaddr *ifp)
+{
+	struct ip_tunnel *t  = netdev_priv(ifp->idev->dev);
+	if (t->parms.i_key != INADDR_NONE) {
+		spin_lock(&ifp->lock);
+		ifp->probes = 0;
+		ifp->idev->if_flags &= ~(IF_RS_SENT|IF_RA_RCVD);
+		addrconf_mod_timer(ifp, AC_RS, t->parms.o_key*HZ);
+		spin_unlock(&ifp->lock);
+	}
+}
+
+static int
+addrconf_isatap_router(struct in6_addr *router, struct inet6_ifaddr *ifp)
+{
+	struct ip_tunnel *t = netdev_priv(ifp->idev->dev);
+
+	if (t->parms.i_key == INADDR_NONE)
+		return 0;
+
+	ipv6_addr_set(router, htonl(0xFE800000), 0, 0, 0);
+	addrconf_ifid_isatap(router->s6_addr + 8, t->parms.i_key);
+	return 1;
+}
+
 static void addrconf_rs_timer(unsigned long data)
 {
 	struct inet6_ifaddr *ifp = (struct inet6_ifaddr *) data;
@@ -2531,6 +2579,10 @@ static void addrconf_rs_timer(unsigned l
 		 *	Announcement received after solicitation
 		 *	was sent
 		 */
+
+		/* ISATAP (RFC4214) - schedule next RS/RA */
+		if (ifp->idev->dev->priv_flags & IFF_ISATAP)
+			addrconf_isatap_sched_rs(ifp);
 		goto out;
 	}
 
@@ -2545,9 +2597,20 @@ static void addrconf_rs_timer(unsigned l
 				   ifp->idev->cnf.rtr_solicit_interval);
 		spin_unlock(&ifp->lock);
 
-		ipv6_addr_all_routers(&all_routers);
+		/* ISATAP (RFC4214) - unicast RS */
+		if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
+			if (!addrconf_isatap_router(&all_routers, ifp))
+				goto out;
+		} else
+			ipv6_addr_all_routers(&all_routers);
 
 		ndisc_send_rs(ifp->idev->dev, &ifp->addr, &all_routers);
+
+		if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
+			spin_lock(&ifp->lock);
+			ifp->idev->if_flags |= IF_RS_SENT;
+			spin_unlock(&ifp->lock);
+		}
 	} else {
 		spin_unlock(&ifp->lock);
 		/*
@@ -2556,6 +2619,10 @@ static void addrconf_rs_timer(unsigned l
 		 */
 		printk(KERN_DEBUG "%s: no IPv6 routers present\n",
 		       ifp->idev->dev->name);
+
+		/* ISATAP (RFC4214) - try again later */
+		if (ifp->idev->dev->priv_flags & IFF_ISATAP)
+			addrconf_isatap_sched_rs(ifp);
 	}
 
 out:
@@ -2595,6 +2662,7 @@ static void addrconf_dad_start(struct in
 
 	if (dev->flags&(IFF_NOARP|IFF_LOOPBACK) ||
 	    !(ifp->flags&IFA_F_TENTATIVE) ||
+	    dev->priv_flags & IFF_ISATAP ||
 	    ifp->flags & IFA_F_NODAD) {
 		ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC);
 		spin_unlock_bh(&ifp->lock);
@@ -2690,7 +2758,12 @@ static void addrconf_dad_completed(struc
 	    (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)) {
 		struct in6_addr all_routers;
 
-		ipv6_addr_all_routers(&all_routers);
+		/* ISATAP (RFC4214) - unicast RS */
+		if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
+			if (!addrconf_isatap_router(&all_routers, ifp))
+				return;
+		} else
+			ipv6_addr_all_routers(&all_routers);
 
 		/*
 		 *	If a host as already performed a random delay
--- linux-2.6.24-rc2/net/ipv6/sit.c.orig	2007-11-08 12:03:41.000000000 -0800
+++ linux-2.6.24-rc2/net/ipv6/sit.c	2007-11-13 16:34:23.000000000 -0800
@@ -16,6 +16,7 @@
  *	Changes:
  * Roger Venning <r.venning@telstra.com>:	6to4 support
  * Nate Thompson <nate@thebog.net>:		6to4 support
+ * Fred L. Templin <fltemplin@acm.org>:		isatap support
  */
 
 #include <linux/module.h>
@@ -182,6 +183,9 @@ static struct ip_tunnel * ipip6_tunnel_l
 	dev->init = ipip6_tunnel_init;
 	nt->parms = *parms;
 
+	if (parms->i_key)
+		dev->priv_flags |= IFF_ISATAP;
+
 	if (register_netdevice(dev) < 0) {
 		free_netdev(dev);
 		goto failed;
@@ -364,6 +368,46 @@ static inline void ipip6_ecn_decapsulate
 		IP6_ECN_set_ce(ipv6_hdr(skb));
 }
 
+/* ISATAP (RFC4214) - check source address */
+static int
+isatap_srcok(struct sk_buff *skb, struct iphdr *iph, struct ip_tunnel *tunnel)
+{
+	struct neighbour *neigh;
+	struct dst_entry *dst;
+	struct flowi fl;
+	struct in6_addr *addr6;
+	struct ipv6hdr *iph6;
+	int ok = 0;
+
+	/* from ISATAP router */
+	if ((iph->saddr == tunnel->parms.i_key) &&
+	    (tunnel->parms.i_key != INADDR_NONE))
+		return 1;
+
+	iph6 = ipv6_hdr(skb);
+	addr6 = &iph6->saddr;
+
+	memset(&fl, 0, sizeof(fl));
+	fl.proto = iph6->nexthdr;
+	ipv6_addr_copy(&fl.fl6_dst, addr6);
+	fl.oif = tunnel->dev->ifindex;
+	security_skb_classify_flow(skb, &fl);
+
+	dst = ip6_route_output(NULL, &fl);
+	if (!dst->error && (dst->dev == tunnel->dev) &&
+	     ((neigh = dst->neighbour) != NULL)) {
+
+		addr6 = (struct in6_addr*)&neigh->primary_key;
+
+		/* from correct previous hop */
+		if (ipv6_addr_is_isatap(addr6) &&
+		    (addr6->s6_addr32[3] == iph->saddr))
+			ok = 1;
+    	}
+	dst_release(dst);
+	return ok;
+}
+
 static int ipip6_rcv(struct sk_buff *skb)
 {
 	struct iphdr *iph;
@@ -382,6 +426,14 @@ static int ipip6_rcv(struct sk_buff *skb
 		IPCB(skb)->flags = 0;
 		skb->protocol = htons(ETH_P_IPV6);
 		skb->pkt_type = PACKET_HOST;
+
+		if ((tunnel->dev->priv_flags & IFF_ISATAP) &&
+		    !isatap_srcok(skb, iph, tunnel)) {
+			tunnel->stat.rx_errors++;
+			read_unlock(&ipip6_lock);
+			kfree_skb(skb);
+			return 0;
+		}
 		tunnel->stat.rx_packets++;
 		tunnel->stat.rx_bytes += skb->len;
 		skb->dev = tunnel->dev;
@@ -444,6 +496,29 @@ static int ipip6_tunnel_xmit(struct sk_b
 	if (skb->protocol != htons(ETH_P_IPV6))
 		goto tx_error;
 
+	/* ISATAP (RFC4214) - must come before 6to4 */
+	if (dev->priv_flags & IFF_ISATAP) {
+		struct neighbour *neigh = NULL;
+
+		if (skb->dst)
+			neigh = skb->dst->neighbour;
+
+		if (neigh == NULL) {
+			if (net_ratelimit())
+		    		printk(KERN_DEBUG "sit: nexthop == NULL\n");
+			goto tx_error;
+	    	}
+
+		addr6 = (struct in6_addr*)&neigh->primary_key;
+		addr_type = ipv6_addr_type(addr6);
+
+		if ((addr_type & IPV6_ADDR_UNICAST) &&
+		     ipv6_addr_is_isatap(addr6))
+			dst = addr6->s6_addr32[3];
+		else
+			goto tx_error;
+	}
+
 	if (!dst)
 		dst = try_6to4(&iph6->daddr);
 
@@ -651,6 +726,8 @@ ipip6_tunnel_ioctl (struct net_device *d
 				ipip6_tunnel_unlink(t);
 				t->parms.iph.saddr = p.iph.saddr;
 				t->parms.iph.daddr = p.iph.daddr;
+				t->parms.i_key = p.i_key;
+				t->parms.o_key = p.o_key;
 				memcpy(dev->dev_addr, &p.iph.saddr, 4);
 				memcpy(dev->broadcast, &p.iph.daddr, 4);
 				ipip6_tunnel_link(t);
@@ -663,6 +740,8 @@ ipip6_tunnel_ioctl (struct net_device *d
 			if (cmd == SIOCCHGTUNNEL) {
 				t->parms.iph.ttl = p.iph.ttl;
 				t->parms.iph.tos = p.iph.tos;
+				t->parms.i_key = p.i_key;
+				t->parms.o_key = p.o_key;
 			}
 			if (copy_to_user(ifr->ifr_ifru.ifru_data, &t->parms, sizeof(p)))
 				err = -EFAULT;
