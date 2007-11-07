From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: [PATCH 03/05] ipv6: RFC4214 Support
Date: Tue, 6 Nov 2007 17:16:07 -0800
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBE4@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stl-smtpout-01.boeing.com ([130.76.96.56]:47259 "EHLO
	stl-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755274AbXKGBjK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 20:39:10 -0500
Received: from slb-av-01.boeing.com (slb-av-01.boeing.com [129.172.13.4])
	by stl-smtpout-01.ns.cs.boeing.com (8.14.0/8.14.0/8.14.0/SMTPOUT) with ESMTP id lA71G7B6010940
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 6 Nov 2007 19:16:08 -0600 (CST)
Received: from slb-av-01.boeing.com (localhost [127.0.0.1])
	by slb-av-01.boeing.com (8.14.0/8.14.0/DOWNSTREAM_RELAY) with ESMTP id lA71G7Tg003617
	for <netdev@vger.kernel.org>; Tue, 6 Nov 2007 17:16:07 -0800 (PST)
Received: from XCH-NWBH-11.nw.nos.boeing.com (xch-nwbh-11.nw.nos.boeing.com [130.247.55.84])
	by slb-av-01.boeing.com (8.14.0/8.14.0/UPSTREAM_RELAY) with ESMTP id lA71G7sg003611
	for <netdev@vger.kernel.org>; Tue, 6 Nov 2007 17:16:07 -0800 (PST)
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fred L. Templin <fred.l.templin@boeing.com>

This is experimental support for the Intra-Site Automatic
Tunnel Addressing Protocol (ISATAP) per RFC4214. It uses
the SIT module, and is configured using the unmodified
"ip" utility with device names beginning with: "isatap".

The following diffs are specific to the Linux 2.6.23
kernel distribution.

Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>

---

--- linux-2.6.23/net/ipv6/addrconf.c.orig	2007-10-09
13:31:38.000000000 -0700
+++ linux-2.6.23/net/ipv6/addrconf.c	2007-10-31 13:08:45.000000000
-0700
@@ -73,7 +73,11 @@
 #include <net/tcp.h>
 #include <net/ip.h>
 #include <net/netlink.h>
+#if defined(CONFIG_IPV6_ISATAP)
+#include <net/ipip.h>
+#else
 #include <linux/if_tunnel.h>
+#endif
 #include <linux/rtnetlink.h>
 
 #ifdef CONFIG_IPV6_PRIVACY
@@ -1426,6 +1430,11 @@ static int ipv6_generate_eui64(u8 *eui, 
 		return addrconf_ifid_arcnet(eui, dev);
 	case ARPHRD_INFINIBAND:
 		return addrconf_ifid_infiniband(eui, dev);
+#if defined(CONFIG_IPV6_ISATAP)
+	case ARPHRD_SIT:
+		if (dev->priv_flags&IFF_ISATAP)
+		return ipv6_isatap_eui64(eui, (__be32 *)dev->dev_addr);
+#endif
 	}
 	return -1;
 }
@@ -2138,7 +2147,6 @@ static void addrconf_add_linklocal(struc
 		addr_flags |= IFA_F_OPTIMISTIC;
 #endif
 
-
 	ifp = ipv6_add_addr(idev, addr, 64, IFA_LINK, addr_flags);
 	if (!IS_ERR(ifp)) {
 		addrconf_prefix_route(&ifp->addr, ifp->prefix_len,
idev->dev, 0, 0);
@@ -2192,6 +2200,32 @@ static void addrconf_sit_config(struct n
 		return;
 	}
 
+#if defined(CONFIG_IPV6_ISATAP)
+	/* ISATAP (RFC4214) - configure as NBMA link */
+	if (dev->priv_flags&IFF_ISATAP) {
+		struct in6_addr addr;
+
+		addrconf_add_lroute(dev);
+
+		addr.s6_addr32[0] = htonl(0xFE800000);
+		addr.s6_addr32[1] = 0;
+
+		if (ipv6_generate_eui64(addr.s6_addr + 8, dev) == 0) {
+		    struct inet6_ifaddr *ifp;
+
+		    if (!IS_ERR(ifp = ipv6_add_addr(idev, &addr, 64,
+					IFA_LINK, IFA_F_PERMANENT))) {
+			addrconf_prefix_route(&ifp->addr,
ifp->prefix_len,
+					      idev->dev, 0, 0);
+			addrconf_dad_start(ifp, 0);
+			in6_ifa_put(ifp);
+		    }
+		}
+
+		return;
+	}
+#endif
+
 	sit_add_v4_addrs(idev);
 
 	if (dev->flags&IFF_POINTOPOINT) {
@@ -2521,6 +2555,16 @@ static void addrconf_rs_timer(unsigned l
 		 *	Announcement received after solicitation
 		 *	was sent
 		 */
+#if defined(CONFIG_IPV6_ISATAP)
+		/* ISATAP (RFC4214) - Re-DAD to trigger new RS/RA */
+		if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
+			spin_lock(&ifp->lock);
+			ifp->probes = 0;
+			ifp->idev->if_flags &= ~(IF_RS_SENT|IF_RA_RCVD);
+			addrconf_mod_timer(ifp, AC_DAD, HZ*120);
+			spin_unlock(&ifp->lock);
+		}
+#endif
 		goto out;
 	}
 
@@ -2535,10 +2579,32 @@ static void addrconf_rs_timer(unsigned l
 				   ifp->idev->cnf.rtr_solicit_interval);
 		spin_unlock(&ifp->lock);
 
+#if defined(CONFIG_IPV6_ISATAP)
+		/* ISATAP (RFC4214) - unicast RS */
+		if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
+		    struct ip_tunnel *t = netdev_priv(ifp->idev->dev);
+		    __be32 rtr = t->parms.i_key;
+
+		    if (!rtr) goto out;
+		
+		    all_routers.s6_addr32[0] = htonl(0xFE800000);
+		    all_routers.s6_addr32[1] = 0;
+		    ipv6_isatap_eui64(all_routers.s6_addr + 8, &rtr);
+
+		} else
+#endif
 		ipv6_addr_all_routers(&all_routers);
 
 		ndisc_send_rs(ifp->idev->dev, &ifp->addr, &all_routers);
 	} else {
+#if defined(CONFIG_IPV6_ISATAP)
+		/* ISATAP (RFC4214) - Re-DAD to trigger new RS/RA */
+		if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
+			ifp->probes = 0;
+			ifp->idev->if_flags &= ~(IF_RS_SENT|IF_RA_RCVD);
+			addrconf_mod_timer(ifp, AC_DAD, HZ*120);
+		}
+#endif
 		spin_unlock(&ifp->lock);
 		/*
 		 * Note: we do not support deprecated "all on-link"
@@ -2584,6 +2650,9 @@ static void addrconf_dad_start(struct in
 	spin_lock_bh(&ifp->lock);
 
 	if (dev->flags&(IFF_NOARP|IFF_LOOPBACK) ||
+#if defined(CONFIG_IPV6_ISATAP)
+	    dev->priv_flags&IFF_ISATAP ||
+#endif
 	    !(ifp->flags&IFA_F_TENTATIVE) ||
 	    ifp->flags & IFA_F_NODAD) {
 		ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC);
@@ -2680,6 +2749,20 @@ static void addrconf_dad_completed(struc
 	    (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)) {
 		struct in6_addr all_routers;
 
+#if defined(CONFIG_IPV6_ISATAP)
+		/* ISATAP (RFC4214) - unicast RS */
+		if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
+		    struct ip_tunnel *t = netdev_priv(ifp->idev->dev);
+		    __be32 rtr = t->parms.i_key;
+
+		    if (!rtr) return;
+
+		    all_routers.s6_addr32[0] = htonl(0xFE800000);
+		    all_routers.s6_addr32[1] = 0;
+		    ipv6_isatap_eui64(all_routers.s6_addr + 8, &rtr);
+
+		} else
+#endif
 		ipv6_addr_all_routers(&all_routers);
 
 		/*
