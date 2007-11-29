From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 01/01] ipv6: RFC4214 Support (v2.5)
Date: Thu, 29 Nov 2007 19:54:59 +0900 (JST)
Message-ID: <20071129.195459.55971471.yoshfuji@linux-ipv6.org>
References: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC29@XCH-NW-7V2.nw.nos.boeing.com>
	<39C363776A4E8C4A94691D2BD9D1C9A1029EDC45@XCH-NW-7V2.nw.nos.boeing.com>
	<20071129102940.GC22537@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
 boundary="--Next_Part(Thu_Nov_29_19_54_59_2007_649)--"
Content-Transfer-Encoding: 7bit
Cc: Fred.L.Templin@boeing.com, netdev@vger.kernel.org,
	vladislav.yasevich@hp.com, davem@davemloft.net
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:38793 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850AbXK2Kze (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 05:55:34 -0500
In-Reply-To: <20071129102940.GC22537@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

----Next_Part(Thu_Nov_29_19_54_59_2007_649)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

In article <20071129102940.GC22537@gondor.apana.org.au> (at Thu, 29 Nov 2007 21:29:40 +1100), Herbert Xu <herbert@gondor.apana.org.au> says:

> On Mon, Nov 26, 2007 at 05:16:16PM +0000, Templin, Fred L wrote:
> > From: Fred L. Templin <fred.l.templin@boeing.com>
> > 
> > This patch includes support for the Intra-Site Automatic Tunnel
> > Addressing Protocol (ISATAP) per RFC4214. It uses the SIT
> > module, and is configured using extensions to the "iproute2"
> > utility. The diffs are specific to the Linux 2.6.24-rc2 kernel
> > distribution.
> > 
> > This version includes the diff for ./include/linux/if.h which was
> > missing in the v2.4 submission and is needed to make the
> > patch compile. The patch has been installed, compiled and
> > tested in a clean 2.6.24-rc2 kernel build area.
> > 
> > Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>
> 
> Sorry, the patch doesn't apply to net-2.6.25.
> 
> $ git apply --check --whitespace=error-all ~/p
> Space in indent is followed by a tab.
> /home/gondolin/herbert/p:101:                          "%s: Disabled Multicast RS\n",
> Space in indent is followed by a tab.
> /home/gondolin/herbert/p:216:           }
> Space in indent is followed by a tab.
> /home/gondolin/herbert/p:252:                           printk(KERN_DEBUG "sit: nexthop == NULL\n");
> Space in indent is followed by a tab.
> /home/gondolin/herbert/p:254:           }
> fatal: corrupt patch at line 269
> $
> 
> There seems to be a line missing at the end.  Please fix the white space
> errors and resend.

I've fixed up those errors.

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA

----Next_Part(Thu_Nov_29_19_54_59_2007_649)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="isatap-fix.patch"

Subject: [PATCH] IPv6: RFC4214 Support (v2.5)
Date: Mon, 26 Nov 2007 09:16:16 -0800
From: Fred L. Templin <fred.l.templin@boeing.com>

This patch includes support for the Intra-Site Automatic Tunnel
Addressing Protocol (ISATAP) per RFC4214. It uses the SIT
module, and is configured using extensions to the "iproute2"
utility. The diffs are specific to the Linux 2.6.24-rc2 kernel
distribution.

This version includes the diff for ./include/linux/if.h which was
missing in the v2.4 submission and is needed to make the
patch compile. The patch has been installed, compiled and
tested in a clean 2.6.24-rc2 kernel build area.

Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

---

diff --git a/include/linux/if.h b/include/linux/if.h
index 186070d..5c9d1fa 100644
--- a/include/linux/if.h
+++ b/include/linux/if.h
@@ -63,6 +63,7 @@
 #define IFF_MASTER_ALB	0x10		/* bonding master, balance-alb.	*/
 #define IFF_BONDING	0x20		/* bonding master or slave	*/
 #define IFF_SLAVE_NEEDARP 0x40		/* need ARPs for validation	*/
+#define IFF_ISATAP	0x80		/* ISATAP interface (RFC4214)	*/
 
 #define IF_GET_IFACE	0x0001		/* for querying only */
 #define IF_GET_PROTO	0x0002
diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index 660b501..228eb4e 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -17,6 +17,9 @@
 #define GRE_FLAGS	__constant_htons(0x00F8)
 #define GRE_VERSION	__constant_htons(0x0007)
 
+/* i_flags values for SIT mode */
+#define	SIT_ISATAP	0x0001
+
 struct ip_tunnel_parm
 {
 	char			name[IFNAMSIZ];
diff --git a/include/linux/in.h b/include/linux/in.h
index 3975cbf..a8f00ca 100644
--- a/include/linux/in.h
+++ b/include/linux/in.h
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
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index bccc2fe..c56827d 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -17,6 +17,7 @@
 
 #define IPV6_MAX_ADDRESSES		16
 
+#include <linux/in.h>
 #include <linux/in6.h>
 
 struct prefix_info {
@@ -249,6 +250,24 @@ static inline int ipv6_addr_is_ll_all_routers(const struct in6_addr *addr)
 		addr->s6_addr32[3] == htonl(0x00000002));
 }
 
+static inline int ipv6_isatap_eui64(u8 *eui, __be32 addr)
+{
+	eui[0] = (ZERONET(addr) || PRIVATE_10(addr) || LOOPBACK(addr) ||
+		  LINKLOCAL_169(addr) || PRIVATE_172(addr) || TEST_192(addr) ||
+		  ANYCAST_6TO4(addr) || PRIVATE_192(addr) || TEST_198(addr) ||
+		  MULTICAST(addr) || BADCLASS(addr)) ? 0x00 : 0x02;
+	eui[1] = 0;
+	eui[2] = 0x5E;
+	eui[3] = 0xFE;
+	memcpy (eui+4, &addr, 4);
+	return 0;
+}
+
+static inline int ipv6_addr_is_isatap(const struct in6_addr *addr)
+{
+	return ((addr->s6_addr32[2] | htonl(0x02000000)) == htonl(0x02005EFE));
+}
+
 #ifdef CONFIG_PROC_FS
 extern int if6_proc_init(void);
 extern void if6_proc_exit(void);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8232e4b..e5eab86 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -377,6 +377,13 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 		       "%s: Disabled Privacy Extensions\n",
 		       dev->name);
 		ndev->cnf.use_tempaddr = -1;
+
+		if (dev->type == ARPHRD_SIT && (dev->priv_flags & IFF_ISATAP)) {
+			printk(KERN_INFO
+			       "%s: Disabled Multicast RS\n",
+			       dev->name);
+			ndev->cnf.rtr_solicits = 0;
+		}
 	} else {
 		in6_dev_hold(ndev);
 		ipv6_regen_rndid((unsigned long) ndev);
@@ -1409,6 +1416,9 @@ static int ipv6_generate_eui64(u8 *eui, struct net_device *dev)
 		return addrconf_ifid_arcnet(eui, dev);
 	case ARPHRD_INFINIBAND:
 		return addrconf_ifid_infiniband(eui, dev);
+	case ARPHRD_SIT:
+		if (dev->priv_flags & IFF_ISATAP)
+			return ipv6_isatap_eui64(eui, *(__be32 *)dev->dev_addr);
 	}
 	return -1;
 }
@@ -1444,7 +1454,7 @@ regen:
 	 *
 	 *  - Reserved subnet anycast (RFC 2526)
 	 *	11111101 11....11 1xxxxxxx
-	 *  - ISATAP (draft-ietf-ngtrans-isatap-13.txt) 5.1
+	 *  - ISATAP (RFC4214) 6.1
 	 *	00-00-5E-FE-xx-xx-xx-xx
 	 *  - value 0
 	 *  - XXX: already assigned to an address on the device
@@ -2175,6 +2185,16 @@ static void addrconf_sit_config(struct net_device *dev)
 		return;
 	}
 
+	if (dev->priv_flags & IFF_ISATAP) {
+		struct in6_addr addr;
+
+		ipv6_addr_set(&addr,  htonl(0xFE800000), 0, 0, 0);
+		addrconf_prefix_route(&addr, 64, dev, 0, 0);
+		if (!ipv6_generate_eui64(addr.s6_addr + 8, dev))
+			addrconf_add_linklocal(idev, &addr);
+		return;
+	}
+
 	sit_add_v4_addrs(idev);
 
 	if (dev->flags&IFF_POINTOPOINT) {
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 2597f3d..0f3bfe7 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1654,6 +1654,8 @@ struct rt6_info *rt6_get_dflt_router(struct in6_addr *addr, struct net_device *d
 	return rt;
 }
 
+EXPORT_SYMBOL(rt6_get_dflt_router);
+
 struct rt6_info *rt6_add_dflt_router(struct in6_addr *gwaddr,
 				     struct net_device *dev,
 				     unsigned int pref)
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 71433d2..94aad27 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -16,6 +16,7 @@
  *	Changes:
  * Roger Venning <r.venning@telstra.com>:	6to4 support
  * Nate Thompson <nate@thebog.net>:		6to4 support
+ * Fred L. Templin <fltemplin@acm.org>:		isatap support
  */
 
 #include <linux/module.h>
@@ -182,6 +183,9 @@ static struct ip_tunnel * ipip6_tunnel_locate(struct ip_tunnel_parm *parms, int
 	dev->init = ipip6_tunnel_init;
 	nt->parms = *parms;
 
+	if (parms->i_flags & SIT_ISATAP)
+		dev->priv_flags |= IFF_ISATAP;
+
 	if (register_netdevice(dev) < 0) {
 		free_netdev(dev);
 		goto failed;
@@ -364,6 +368,48 @@ static inline void ipip6_ecn_decapsulate(struct iphdr *iph, struct sk_buff *skb)
 		IP6_ECN_set_ce(ipv6_hdr(skb));
 }
 
+/* ISATAP (RFC4214) - check source address */
+static int
+isatap_srcok(struct sk_buff *skb, struct iphdr *iph, struct net_device *dev)
+{
+	struct neighbour *neigh;
+	struct dst_entry *dst;
+	struct rt6_info *rt;
+	struct flowi fl;
+	struct in6_addr *addr6;
+	struct in6_addr rtr;
+	struct ipv6hdr *iph6;
+	int ok = 0;
+
+	/* from onlink default router */
+	ipv6_addr_set(&rtr,  htonl(0xFE800000), 0, 0, 0);
+	ipv6_isatap_eui64(rtr.s6_addr + 8, iph->saddr);
+	if ((rt = rt6_get_dflt_router(&rtr, dev))) {
+		dst_release(&rt->u.dst);
+		return 1;
+	}
+
+	iph6 = ipv6_hdr(skb);
+	memset(&fl, 0, sizeof(fl));
+	fl.proto = iph6->nexthdr;
+	ipv6_addr_copy(&fl.fl6_dst, &iph6->saddr);
+	fl.oif = dev->ifindex;
+	security_skb_classify_flow(skb, &fl);
+
+	dst = ip6_route_output(NULL, &fl);
+	if (!dst->error && (dst->dev == dev) && (neigh = dst->neighbour)) {
+
+		addr6 = (struct in6_addr*)&neigh->primary_key;
+
+		/* from correct previous hop */
+		if (ipv6_addr_is_isatap(addr6) &&
+		    (addr6->s6_addr32[3] == iph->saddr))
+			ok = 1;
+	}
+	dst_release(dst);
+	return ok;
+}
+
 static int ipip6_rcv(struct sk_buff *skb)
 {
 	struct iphdr *iph;
@@ -382,6 +428,14 @@ static int ipip6_rcv(struct sk_buff *skb)
 		IPCB(skb)->flags = 0;
 		skb->protocol = htons(ETH_P_IPV6);
 		skb->pkt_type = PACKET_HOST;
+
+		if ((tunnel->dev->priv_flags & IFF_ISATAP) &&
+		    !isatap_srcok(skb, iph, tunnel->dev)) {
+			tunnel->stat.rx_errors++;
+			read_unlock(&ipip6_lock);
+			kfree_skb(skb);
+			return 0;
+		}
 		tunnel->stat.rx_packets++;
 		tunnel->stat.rx_bytes += skb->len;
 		skb->dev = tunnel->dev;
@@ -444,6 +498,29 @@ static int ipip6_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
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
+				printk(KERN_DEBUG "sit: nexthop == NULL\n");
+			goto tx_error;
+		}
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
 

----Next_Part(Thu_Nov_29_19_54_59_2007_649)----
