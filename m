From: osprey67 <osprey67@yahoo.com>
Subject: [PATCH 05/05] ipv6: RFC4214 Support (3)
Date: Fri, 09 Nov 2007 16:35:59 -0800
Message-ID: <4734FCEF.3080301@yahoo.com>
References: <473371B3.5030908@yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010306070204030608000303"
To: osprey67 <osprey67@yahoo.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp101.plus.mail.sp1.yahoo.com ([69.147.95.64]:38222 "HELO
	smtp101.plus.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751526AbXKJAnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2007 19:43:08 -0500
In-Reply-To: <473371B3.5030908@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010306070204030608000303
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

From: Fred L. Templin <fred.l.templin@boeing.com>

This message attaches the combined diffs from
messages 01/05 through 04/05. This file should be
suitable for use with the patch utility.

Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>


--------------010306070204030608000303
Content-Type: text/plain;
 name="isatap_linux.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="isatap_linux.txt"

--- linux-2.6.24-rc2/include/linux/if.h.orig	2007-11-08 12:05:47.000000000 -0800
+++ linux-2.6.24-rc2/include/linux/if.h	2007-11-08 08:26:44.000000000 -0800
@@ -61,6 +61,7 @@
 #define IFF_MASTER_ALB	0x10		/* bonding master, balance-alb.	*/
 #define IFF_BONDING	0x20		/* bonding master or slave	*/
 #define IFF_SLAVE_NEEDARP 0x40		/* need ARPs for validation	*/
+#define IFF_ISATAP	0x80		/* ISATAP interface (RFC4214)	*/
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002
--- linux-2.6.24-rc2/include/linux/if_tunnel.h.orig	2007-11-09 09:06:16.000000000 -0800
+++ linux-2.6.24-rc2/include/linux/if_tunnel.h	2007-11-09 15:49:54.000000000 -0800
@@ -25,6 +25,8 @@ struct ip_tunnel_parm
 	__be16			o_flags;
 	__be32			i_key;
 	__be32			o_key;
+	__be32			router;
+	__be32			lifetime;
 	struct iphdr		iph;
 };
 
--- linux-2.6.24-rc2/include/linux/in.h.orig	2007-11-09 08:00:32.000000000 -0800
+++ linux-2.6.24-rc2/include/linux/in.h	2007-11-09 08:56:09.000000000 -0800
@@ -252,7 +252,15 @@ struct sockaddr_in {
 #define BADCLASS(x)	(((x) & htonl(0xf0000000)) == htonl(0xf0000000))
 #define ZERONET(x)	(((x) & htonl(0xff000000)) == htonl(0x00000000))
 #define LOCAL_MCAST(x)	(((x) & htonl(0xFFFFFF00)) == htonl(0xE0000000))
-
+ 
+/* Special-Use IPv4 Addresses (RFC3330) */
+#define PRIVATE_10(x)	(((x) & htonl(0xff000000)) == htonl(0x0A000000))
+#define LINK_169(x) 	(((x) & htonl(0xffff0000)) == htonl(0xA9FE0000))
+#define PRIVATE_172(x)	(((x) & htonl(0xfff00000)) == htonl(0xAC100000))
+#define TEST_192(x)	(((x) & htonl(0xffffff00)) == htonl(0xC0000200))
+#define ANYCAST_6TO4(x)	(((x) & htonl(0xffffff00)) == htonl(0xC0586300))
+#define PRIVATE_192(x)	(((x) & htonl(0xffff0000)) == htonl(0xC0A80000))
+#define TEST_198(x)	(((x) & htonl(0xfffe0000)) == htonl(0xC6120000))
 #endif
 
 #endif	/* _LINUX_IN_H */
--- linux-2.6.24-rc2/include/net/addrconf.h.orig	2007-11-08 12:06:17.000000000 -0800
+++ linux-2.6.24-rc2/include/net/addrconf.h	2007-11-09 08:12:29.000000000 -0800
@@ -241,6 +241,14 @@ static inline int ipv6_addr_is_ll_all_ro
 		addr->s6_addr32[3] == htonl(0x00000002));
 }
 
+#if defined(CONFIG_IPV6_ISATAP)
+/* only for IFF_ISATAP interfaces */
+static inline int ipv6_addr_is_isatap(const struct in6_addr *addr)
+{
+	return ((addr->s6_addr32[2] | htonl(0x02000000)) == htonl(0x02005EFE));
+}
+#endif
+
 #ifdef CONFIG_PROC_FS
 extern int if6_proc_init(void);
 extern void if6_proc_exit(void);
--- linux-2.6.24-rc2/net/ipv6/Kconfig.orig	2007-11-08 12:07:17.000000000 -0800
+++ linux-2.6.24-rc2/net/ipv6/Kconfig	2007-11-08 08:27:48.000000000 -0800
@@ -57,6 +57,17 @@ config IPV6_ROUTE_INFO
 
 	  If unsure, say N.
 
+config IPV6_ISATAP
+	bool "IPv6: ISATAP (RFC 4214) support (EXPERIMENTAL)"
+	depends on IPV6 && EXPERIMENTAL
+	---help---
+	  This is experimental support for the Intra-Site Automatic
+	  Tunnel Addressing Protocol (ISATAP) per RFC4214. It uses
+	  the SIT module, and is configured using the "ip" utility
+	  with device names beginning with: "isatap".
+
+	  If unsure, say N.
+
 config IPV6_OPTIMISTIC_DAD
 	bool "IPv6: Enable RFC 4429 Optimistic DAD (EXPERIMENTAL)"
 	depends on IPV6 && EXPERIMENTAL
--- linux-2.6.24-rc2/net/ipv6/addrconf.c.orig	2007-11-08 11:59:35.000000000 -0800
+++ linux-2.6.24-rc2/net/ipv6/addrconf.c	2007-11-09 14:19:19.000000000 -0800
@@ -75,7 +75,7 @@
 #include <net/ip.h>
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
-#include <linux/if_tunnel.h>
+#include <net/ipip.h>
 #include <linux/rtnetlink.h>
 
 #ifdef CONFIG_IPV6_PRIVACY
@@ -1424,6 +1424,24 @@ static int addrconf_ifid_infiniband(u8 *
 	return 0;
 }
 
+#if defined(CONFIG_IPV6_ISATAP)
+static int addrconf_ifid_isatap(u8 *eui, __be32 addr)
+{
+
+	eui[0] = 0x02; eui[1] = 0; eui[2] = 0x5E; eui[3] = 0xFE;
+	memcpy (eui+4, &addr, 4);
+
+	/* Special-Use IPv4 Addresses (RFC3330)
+	if (ZERONET(addr) || PRIVATE_10(addr) || LOOPBACK(addr) ||
+	    LINK_169(addr) || PRIVATE_172(addr) || TEST_192(addr) ||
+	    ANYCAST_6TO4(addr) || PRIVATE_192(addr) || TEST_198(addr) ||
+	    MULTICAST(addr) || BADCLASS(addr)) eui[0] &= ~0x02;
+*/ eui[0] = 0;
+
+	return 0;
+}
+#endif
+
 static int ipv6_generate_eui64(u8 *eui, struct net_device *dev)
 {
 	switch (dev->type) {
@@ -1435,6 +1453,11 @@ static int ipv6_generate_eui64(u8 *eui, 
 		return addrconf_ifid_arcnet(eui, dev);
 	case ARPHRD_INFINIBAND:
 		return addrconf_ifid_infiniband(eui, dev);
+#if defined(CONFIG_IPV6_ISATAP)
+	case ARPHRD_SIT:
+		if (dev->priv_flags & IFF_ISATAP)
+			return addrconf_ifid_isatap(eui, *(__be32 *)dev->dev_addr);
+#endif
 	}
 	return -1;
 }
@@ -1470,8 +1493,7 @@ regen:
 	 *
 	 *  - Reserved subnet anycast (RFC 2526)
 	 *	11111101 11....11 1xxxxxxx
-	 *  - ISATAP (draft-ietf-ngtrans-isatap-13.txt) 5.1
-	 *	00-00-5E-FE-xx-xx-xx-xx
+	 *  - ISATAP (RFC4214) 00-00-5E-FE-xx-xx-xx-xx - remove??
 	 *  - value 0
 	 *  - XXX: already assigned to an address on the device
 	 */
@@ -2201,6 +2223,31 @@ static void addrconf_sit_config(struct n
 		return;
 	}
 
+#if defined(CONFIG_IPV6_ISATAP)
+	/* ISATAP (RFC4214) - NBMA link */
+	if (dev->priv_flags & IFF_ISATAP) {
+		struct in6_addr addr;
+
+		addrconf_add_lroute(dev);
+
+		ipv6_addr_set(&addr,  htonl(0xFE800000), 0, 0, 0);
+
+		if (ipv6_generate_eui64(addr.s6_addr + 8, dev) == 0) {
+			struct inet6_ifaddr *ifp;
+
+			ifp = ipv6_add_addr(idev, &addr, 64,
+					IFA_LINK, IFA_F_PERMANENT);
+			if (!IS_ERR(ifp)) {
+				addrconf_prefix_route(&ifp->addr,
+					ifp->prefix_len, idev->dev, 0, 0);
+				addrconf_dad_start(ifp, 0);
+				in6_ifa_put(ifp);
+			}
+		}
+		return;
+	}
+#endif
+
 	sit_add_v4_addrs(idev);
 
 	if (dev->flags&IFF_POINTOPOINT) {
@@ -2531,6 +2578,19 @@ static void addrconf_rs_timer(unsigned l
 		 *	Announcement received after solicitation
 		 *	was sent
 		 */
+#if defined(CONFIG_IPV6_ISATAP)
+		/* ISATAP (RFC4214) - Re-DAD to trigger new RS/RA */
+		if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
+			struct ip_tunnel *t  = netdev_priv(ifp->idev->dev);
+			if (t->parms.router != INADDR_NONE) {
+				spin_lock(&ifp->lock);
+				ifp->probes = 0;
+				ifp->idev->if_flags &= ~(IF_RS_SENT|IF_RA_RCVD);
+				addrconf_mod_timer(ifp, AC_DAD, t->parms.lifetime*HZ);
+				spin_unlock(&ifp->lock);
+			}
+		}
+#endif
 		goto out;
 	}
 
@@ -2545,10 +2605,32 @@ static void addrconf_rs_timer(unsigned l
 				   ifp->idev->cnf.rtr_solicit_interval);
 		spin_unlock(&ifp->lock);
 
+#if defined(CONFIG_IPV6_ISATAP)
+		/* ISATAP (RFC4214) - unicast RS */
+		if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
+			struct ip_tunnel *t = netdev_priv(ifp->idev->dev);
+
+			if (t->parms.router == INADDR_NONE) goto out;
+
+			ipv6_addr_set(&all_routers, htonl(0xFE800000), 0, 0, 0);
+			addrconf_ifid_isatap(all_routers.s6_addr + 8, t->parms.router);
+		} else
+#endif
 		ipv6_addr_all_routers(&all_routers);
 
 		ndisc_send_rs(ifp->idev->dev, &ifp->addr, &all_routers);
 	} else {
+#if defined(CONFIG_IPV6_ISATAP)
+		/* ISATAP (RFC4214) - Re-DAD to trigger new RS/RA */
+		if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
+			struct ip_tunnel *t = netdev_priv(ifp->idev->dev);
+			if (t->parms.router != INADDR_NONE) {
+				ifp->probes = 0;
+				ifp->idev->if_flags &= ~(IF_RS_SENT|IF_RA_RCVD);
+				addrconf_mod_timer(ifp, AC_DAD, t->parms.lifetime*HZ);
+			}
+		}
+#endif
 		spin_unlock(&ifp->lock);
 		/*
 		 * Note: we do not support deprecated "all on-link"
@@ -2594,6 +2676,9 @@ static void addrconf_dad_start(struct in
 	spin_lock_bh(&ifp->lock);
 
 	if (dev->flags&(IFF_NOARP|IFF_LOOPBACK) ||
+#if defined(CONFIG_IPV6_ISATAP)
+	    dev->priv_flags&IFF_ISATAP ||
+#endif
 	    !(ifp->flags&IFA_F_TENTATIVE) ||
 	    ifp->flags & IFA_F_NODAD) {
 		ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC);
@@ -2690,6 +2775,17 @@ static void addrconf_dad_completed(struc
 	    (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)) {
 		struct in6_addr all_routers;
 
+#if defined(CONFIG_IPV6_ISATAP)
+		/* ISATAP (RFC4214) - unicast RS */
+		if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
+			struct ip_tunnel *t = netdev_priv(ifp->idev->dev);
+
+			if (t->parms.router == INADDR_NONE) return;
+
+			ipv6_addr_set(&all_routers, htonl(0xFE800000), 0, 0, 0);
+			addrconf_ifid_isatap(all_routers.s6_addr + 8, t->parms.router);
+		} else
+#endif
 		ipv6_addr_all_routers(&all_routers);
 
 		/*
--- linux-2.6.24-rc2/net/ipv6/sit.c.orig	2007-11-08 12:03:41.000000000 -0800
+++ linux-2.6.24-rc2/net/ipv6/sit.c	2007-11-09 15:50:41.000000000 -0800
@@ -16,6 +16,7 @@
  *	Changes:
  * Roger Venning <r.venning@telstra.com>:	6to4 support
  * Nate Thompson <nate@thebog.net>:		6to4 support
+ * Fred L. Templin <fltemplin@acm.org>:		isatap support
  */
 
 #include <linux/module.h>
@@ -182,6 +183,14 @@ static struct ip_tunnel * ipip6_tunnel_l
 	dev->init = ipip6_tunnel_init;
 	nt->parms = *parms;
 
+#if defined(CONFIG_IPV6_ISATAP)
+	if (parms->router) {
+		dev->priv_flags |= IFF_ISATAP;
+		if (!nt->parms.lifetime)
+			nt->parms.lifetime = 120; /* RFC4214 Default */
+	}
+#endif
+
 	if (register_netdevice(dev) < 0) {
 		free_netdev(dev);
 		goto failed;
@@ -382,6 +391,48 @@ static int ipip6_rcv(struct sk_buff *skb
 		IPCB(skb)->flags = 0;
 		skb->protocol = htons(ETH_P_IPV6);
 		skb->pkt_type = PACKET_HOST;
+#if defined(CONFIG_IPV6_ISATAP)
+		/* ISATAP (RFC4214) - check source address */
+		if (tunnel->dev->priv_flags & IFF_ISATAP) {
+			struct neighbour *neigh;
+			struct dst_entry *dst;
+			struct flowi fl;
+			struct in6_addr *addr6;
+			struct ipv6hdr *iph6;
+
+			/* from ISATAP router */
+			if ((tunnel->parms.router != INADDR_NONE) &&
+			    (iph->saddr == tunnel->parms.router)) goto accept;
+
+			iph6 = ipv6_hdr(skb);
+			addr6 = &iph6->saddr;
+
+			/* from legitimate previous hop */
+			memset(&fl, 0, sizeof(fl));
+			fl.proto = iph6->nexthdr;
+			ipv6_addr_copy(&fl.fl6_dst, addr6);
+			fl.oif = tunnel->dev->ifindex;
+			security_skb_classify_flow(skb, &fl);
+
+			if (!(dst = ip6_route_output(NULL, &fl)) ||
+			     (dst->dev != tunnel->dev) ||
+			     ((neigh = dst->neighbour) == NULL)) goto drop;
+
+			addr6 = (struct in6_addr*)&neigh->primary_key;
+
+			if (!(ipv6_addr_is_isatap(addr6)) ||
+			     (addr6->s6_addr32[3] != iph->saddr)) {
+drop:
+				tunnel->stat.rx_errors++;
+				read_unlock(&ipip6_lock);
+				dst_release(dst);
+				kfree_skb(skb);
+				return 0;
+		    	}
+			dst_release(dst);
+		}
+accept:
+#endif
 		tunnel->stat.rx_packets++;
 		tunnel->stat.rx_bytes += skb->len;
 		skb->dev = tunnel->dev;
@@ -444,6 +495,31 @@ static int ipip6_tunnel_xmit(struct sk_b
 	if (skb->protocol != htons(ETH_P_IPV6))
 		goto tx_error;
 
+#if defined(CONFIG_IPV6_ISATAP)
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
+#endif	/* CONFIG_IPV6_ISATAP */
+
 	if (!dst)
 		dst = try_6to4(&iph6->daddr);
 
@@ -651,6 +727,10 @@ ipip6_tunnel_ioctl (struct net_device *d
 				ipip6_tunnel_unlink(t);
 				t->parms.iph.saddr = p.iph.saddr;
 				t->parms.iph.daddr = p.iph.daddr;
+#if defined(CONFIG_IPV6_ISATAP)
+				if (p.router) t->parms.router = p.router;
+				if (p.lifetime) t->parms.lifetime = p.lifetime;
+#endif
 				memcpy(dev->dev_addr, &p.iph.saddr, 4);
 				memcpy(dev->broadcast, &p.iph.daddr, 4);
 				ipip6_tunnel_link(t);
@@ -663,6 +743,10 @@ ipip6_tunnel_ioctl (struct net_device *d
 			if (cmd == SIOCCHGTUNNEL) {
 				t->parms.iph.ttl = p.iph.ttl;
 				t->parms.iph.tos = p.iph.tos;
+#if defined(CONFIG_IPV6_ISATAP)
+				if (p.router) t->parms.router = p.router;
+				if (p.lifetime) t->parms.lifetime = p.lifetime;
+#endif
 			}
 			if (copy_to_user(ifr->ifr_ifru.ifru_data, &t->parms, sizeof(p)))
 				err = -EFAULT;

--------------010306070204030608000303--
