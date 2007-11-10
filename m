From: osprey67 <osprey67@yahoo.com>
Subject: [PATCH 03/05] ipv6: RFC4214 Support (3)
Date: Fri, 09 Nov 2007 16:35:28 -0800
Message-ID: <4734FCD0.1070103@yahoo.com>
References: <473371B3.5030908@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: osprey67 <osprey67@yahoo.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp128.plus.mail.sp1.yahoo.com ([69.147.95.91]:37090 "HELO
	smtp128.plus.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751442AbXKJAmi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2007 19:42:38 -0500
In-Reply-To: <473371B3.5030908@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
+++ linux-2.6.24-rc2/net/ipv6/addrconf.c        2007-11-09 14:19:19.000000000 -0800
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
+       eui[0] = 0x02; eui[1] = 0; eui[2] = 0x5E; eui[3] = 0xFE;
+       memcpy (eui+4, &addr, 4);
+
+       /* Special-Use IPv4 Addresses (RFC3330)
+       if (ZERONET(addr) || PRIVATE_10(addr) || LOOPBACK(addr) ||
+           LINK_169(addr) || PRIVATE_172(addr) || TEST_192(addr) ||
+           ANYCAST_6TO4(addr) || PRIVATE_192(addr) || TEST_198(addr) ||
+           MULTICAST(addr) || BADCLASS(addr)) eui[0] &= ~0x02;
+*/ eui[0] = 0;
+
+       return 0;
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
+       case ARPHRD_SIT:
+               if (dev->priv_flags & IFF_ISATAP)
+                       return addrconf_ifid_isatap(eui, *(__be32 *)dev->dev_addr);
+#endif
         }
         return -1;
  }
@@ -1470,8 +1493,7 @@ regen:
          *
          *  - Reserved subnet anycast (RFC 2526)
          *      11111101 11....11 1xxxxxxx
-        *  - ISATAP (draft-ietf-ngtrans-isatap-13.txt) 5.1
-        *      00-00-5E-FE-xx-xx-xx-xx
+        *  - ISATAP (RFC4214) 00-00-5E-FE-xx-xx-xx-xx - remove??
          *  - value 0
          *  - XXX: already assigned to an address on the device
          */
@@ -2201,6 +2223,31 @@ static void addrconf_sit_config(struct n
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
@@ -2531,6 +2578,19 @@ static void addrconf_rs_timer(unsigned l
                  *      Announcement received after solicitation
                  *      was sent
                  */
+#if defined(CONFIG_IPV6_ISATAP)
+               /* ISATAP (RFC4214) - Re-DAD to trigger new RS/RA */
+               if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
+                       struct ip_tunnel *t  = netdev_priv(ifp->idev->dev);
+                       if (t->parms.router != INADDR_NONE) {
+                               spin_lock(&ifp->lock);
+                               ifp->probes = 0;
+                               ifp->idev->if_flags &= ~(IF_RS_SENT|IF_RA_RCVD);
+                               addrconf_mod_timer(ifp, AC_DAD, t->parms.lifetime*HZ);
+                               spin_unlock(&ifp->lock);
+                       }
+               }
+#endif
                 goto out;
         }

@@ -2545,10 +2605,32 @@ static void addrconf_rs_timer(unsigned l
                                    ifp->idev->cnf.rtr_solicit_interval);
                 spin_unlock(&ifp->lock);

+#if defined(CONFIG_IPV6_ISATAP)
+               /* ISATAP (RFC4214) - unicast RS */
+               if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
+                       struct ip_tunnel *t = netdev_priv(ifp->idev->dev);
+
+                       if (t->parms.router == INADDR_NONE) goto out;
+
+                       ipv6_addr_set(&all_routers, htonl(0xFE800000), 0, 0, 0);
+                       addrconf_ifid_isatap(all_routers.s6_addr + 8, t->parms.router);
+               } else
+#endif
                 ipv6_addr_all_routers(&all_routers);

                 ndisc_send_rs(ifp->idev->dev, &ifp->addr, &all_routers);
         } else {
+#if defined(CONFIG_IPV6_ISATAP)
+               /* ISATAP (RFC4214) - Re-DAD to trigger new RS/RA */
+               if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
+                       struct ip_tunnel *t = netdev_priv(ifp->idev->dev);
+                       if (t->parms.router != INADDR_NONE) {
+                               ifp->probes = 0;
+                               ifp->idev->if_flags &= ~(IF_RS_SENT|IF_RA_RCVD);
+                               addrconf_mod_timer(ifp, AC_DAD, t->parms.lifetime*HZ);
+                       }
+               }
+#endif
                 spin_unlock(&ifp->lock);
                 /*
                  * Note: we do not support deprecated "all on-link"
@@ -2594,6 +2676,9 @@ static void addrconf_dad_start(struct in
         spin_lock_bh(&ifp->lock);

         if (dev->flags&(IFF_NOARP|IFF_LOOPBACK) ||
+#if defined(CONFIG_IPV6_ISATAP)
+           dev->priv_flags&IFF_ISATAP ||
+#endif
             !(ifp->flags&IFA_F_TENTATIVE) ||
             ifp->flags & IFA_F_NODAD) {
                 ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC);
@@ -2690,6 +2775,17 @@ static void addrconf_dad_completed(struc
             (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)) {
                 struct in6_addr all_routers;

+#if defined(CONFIG_IPV6_ISATAP)
+               /* ISATAP (RFC4214) - unicast RS */
+               if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
+                       struct ip_tunnel *t = netdev_priv(ifp->idev->dev);
+
+                       if (t->parms.router == INADDR_NONE) return;
+
+                       ipv6_addr_set(&all_routers, htonl(0xFE800000), 0, 0, 0);
+                       addrconf_ifid_isatap(all_routers.s6_addr + 8, t->parms.router);
+               } else
+#endif
                 ipv6_addr_all_routers(&all_routers);

                 /*
