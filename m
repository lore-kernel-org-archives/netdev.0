From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: [Resend] [PATCH 03/05] ipv6: RFC4214 Support (4)
Date: Mon, 12 Nov 2007 13:01:23 -0800
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A1029EDC16@XCH-NW-7V2.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
Cc: =?iso-2022-jp?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from blv-smtpout-01.boeing.com ([130.76.32.69]:39025 "EHLO
	blv-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759512AbXKLVBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Nov 2007 16:01:36 -0500
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 

-----Original Message-----
From: osprey67 [mailto:osprey67@yahoo.com] 
Sent: Monday, November 12, 2007 7:55 AM
To: netdev@vger.kernel.org
Subject: [PATCH 03/05] ipv6: RFC4214 Support (4)

From: Fred L. Templin <fred.l.templin@boeing.com>

This is experimental support for the Intra-Site Automatic
Tunnel Addressing Protocol (ISATAP) per RFC4214. It uses
the SIT module, and is configured using the unmodified
"ip" utility with device names beginning with: "isatap".

The following diffs are specific to the Linux 2.6.24-rc2
kernel distribution.

Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>

---

--- linux-2.6.24-rc2/net/ipv6/addrconf.c.orig   2007-11-08 11:59:35.000000000 -0800
+++ linux-2.6.24-rc2/net/ipv6/addrconf.c        2007-11-12 07:04:27.000000000 -0800
@@ -75,7 +75,7 @@
  #include <net/ip.h>
  #include <net/netlink.h>
  #include <net/pkt_sched.h>
-#include <linux/if_tunnel.h>
+#include <net/ipip.h>
  #include <linux/rtnetlink.h>

  #ifdef CONFIG_IPV6_PRIVACY
@@ -1424,6 +1424,22 @@ static int addrconf_ifid_infiniband(u8 *
         return 0;
  }

+#if defined(CONFIG_IPV6_ISATAP)
+static int addrconf_ifid_isatap(u8 *eui, __be32 addr)
+{
+
+       eui[0] = 0x02; eui[1] = 0; eui[2] = 0x5E; eui[3] = 0xFE;
+       memcpy (eui+4, &addr, 4);
+
+       if (ZERONET(addr) || PRIVATE_10(addr) || LOOPBACK(addr) ||
+           LINKLOCAL_169(addr) || PRIVATE_172(addr) || TEST_192(addr) ||
+           ANYCAST_6TO4(addr) || PRIVATE_192(addr) || TEST_198(addr) ||
+           MULTICAST(addr) || BADCLASS(addr)) eui[0] &= ~0x02;
+
+       return 0;
+}
+#endif
+
  static int ipv6_generate_eui64(u8 *eui, struct net_device *dev)
  {
         switch (dev->type) {
@@ -1435,6 +1451,11 @@ static int ipv6_generate_eui64(u8 *eui,
                 return addrconf_ifid_arcnet(eui, dev);
         case ARPHRD_INFINIBAND:
                 return addrconf_ifid_infiniband(eui, dev);
+#if defined(CONFIG_IPV6_ISATAP)
+       case ARPHRD_SIT:
+               if (dev->priv_flags & IFF_ISATAP)
+                       return addrconf_ifid_isatap(eui, *(__be32 *)dev->dev_addr);
+#endif
         }
         return -1;
  }
@@ -1470,8 +1491,7 @@ regen:
          *
          *  - Reserved subnet anycast (RFC 2526)
          *      11111101 11....11 1xxxxxxx
-        *  - ISATAP (draft-ietf-ngtrans-isatap-13.txt) 5.1
-        *      00-00-5E-FE-xx-xx-xx-xx
+        *  - ISATAP (RFC4214) 00-00-5E-FE-xx-xx-xx-xx - remove??
          *  - value 0
          *  - XXX: already assigned to an address on the device
          */
@@ -2201,6 +2221,31 @@ static void addrconf_sit_config(struct n
                 return;
         }

+#if defined(CONFIG_IPV6_ISATAP)
+       /* ISATAP (RFC4214) - NBMA link */
+       if (dev->priv_flags & IFF_ISATAP) {
+               struct in6_addr addr;
+
+               addrconf_add_lroute(dev);
+
+               ipv6_addr_set(&addr,  htonl(0xFE800000), 0, 0, 0);
+
+               if (ipv6_generate_eui64(addr.s6_addr + 8, dev) == 0) {
+                       struct inet6_ifaddr *ifp;
+
+                       ifp = ipv6_add_addr(idev, &addr, 64,
+                                       IFA_LINK, IFA_F_PERMANENT);
+                       if (!IS_ERR(ifp)) {
+                               addrconf_prefix_route(&ifp->addr,
+                                       ifp->prefix_len, idev->dev, 0, 0);
+                               addrconf_dad_start(ifp, 0);
+                               in6_ifa_put(ifp);
+                       }
+               }
+               return;
+       }
+#endif
+
         sit_add_v4_addrs(idev);

         if (dev->flags&IFF_POINTOPOINT) {
@@ -2531,6 +2576,19 @@ static void addrconf_rs_timer(unsigned l
                  *      Announcement received after solicitation
                  *      was sent
                  */
+#if defined(CONFIG_IPV6_ISATAP)
+               /* ISATAP (RFC4214) - schedule next RS/RA */
+               if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
+                       struct ip_tunnel *t  = netdev_priv(ifp->idev->dev);
+                       if (t->parms.i_key != INADDR_NONE) {
+                               spin_lock(&ifp->lock);
+                               ifp->probes = 0;
+                               ifp->idev->if_flags &= ~(IF_RS_SENT|IF_RA_RCVD);
+                               addrconf_mod_timer(ifp, AC_DAD, t->parms.o_key*HZ);
+                               spin_unlock(&ifp->lock);
+                       }
+               }
+#endif
                 goto out;
         }

@@ -2545,10 +2603,32 @@ static void addrconf_rs_timer(unsigned l
                                    ifp->idev->cnf.rtr_solicit_interval);
                 spin_unlock(&ifp->lock);

+#if defined(CONFIG_IPV6_ISATAP)
+               /* ISATAP (RFC4214) - unicast RS */
+               if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
+                       struct ip_tunnel *t = netdev_priv(ifp->idev->dev);
+
+                       if (t->parms.i_key == INADDR_NONE) goto out;
+
+                       ipv6_addr_set(&all_routers, htonl(0xFE800000), 0, 0, 0);
+                       addrconf_ifid_isatap(all_routers.s6_addr + 8, t->parms.i_key);
+               } else
+#endif
                 ipv6_addr_all_routers(&all_routers);

                 ndisc_send_rs(ifp->idev->dev, &ifp->addr, &all_routers);
         } else {
+#if defined(CONFIG_IPV6_ISATAP)
+               /* ISATAP (RFC4214) - try again later */
+               if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
+                       struct ip_tunnel *t = netdev_priv(ifp->idev->dev);
+                       if (t->parms.i_key != INADDR_NONE) {
+                               ifp->probes = 0;
+                               ifp->idev->if_flags &= ~(IF_RS_SENT|IF_RA_RCVD);
+                               addrconf_mod_timer(ifp, AC_DAD, t->parms.o_key*HZ);
+                       }
+               }
+#endif
                 spin_unlock(&ifp->lock);
                 /*
                  * Note: we do not support deprecated "all on-link"
@@ -2594,6 +2674,9 @@ static void addrconf_dad_start(struct in
         spin_lock_bh(&ifp->lock);

         if (dev->flags&(IFF_NOARP|IFF_LOOPBACK) ||
+#if defined(CONFIG_IPV6_ISATAP)
+           dev->priv_flags&IFF_ISATAP ||
+#endif
             !(ifp->flags&IFA_F_TENTATIVE) ||
             ifp->flags & IFA_F_NODAD) {
                 ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC);
@@ -2690,6 +2773,17 @@ static void addrconf_dad_completed(struc
             (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)) {
                 struct in6_addr all_routers;

+#if defined(CONFIG_IPV6_ISATAP)
+               /* ISATAP (RFC4214) - unicast RS */
+               if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
+                       struct ip_tunnel *t = netdev_priv(ifp->idev->dev);
+
+                       if (t->parms.i_key == INADDR_NONE) return;
+
+                       ipv6_addr_set(&all_routers, htonl(0xFE800000), 0, 0, 0);
+                       addrconf_ifid_isatap(all_routers.s6_addr + 8, t->parms.i_key);
+               } else
+#endif
                 ipv6_addr_all_routers(&all_routers);

                 /*
-
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
