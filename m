From: osprey67 <osprey67@yahoo.com>
Subject: [PATCH 03/05] ipv6: RFC4214 Support (2)
Date: Thu, 08 Nov 2007 12:41:44 -0800
Message-ID: <47337488.7010406@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp117.plus.mail.mud.yahoo.com ([209.191.106.148]:31192 "HELO
	smtp117.plus.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758915AbXKHUlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 15:41:47 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fred L. Templin <osprey67@yahoo.com>

This is experimental support for the Intra-Site Automatic
Tunnel Addressing Protocol (ISATAP) per RFC4214. It uses
the SIT module, and is configured using the unmodified
"ip" utility with device names beginning with: "isatap".

The following diffs are specific to the Linux 2.6.24-rc2
kernel distribution.

Signed-off-by: Fred L. Templin <osprey67@yahoo.com>

---

--- linux-2.6.24-rc2/net/ipv6/addrconf.c.orig   2007-11-08 11:59:35.000000000 -0800
+++ linux-2.6.24-rc2/net/ipv6/addrconf.c        2007-11-08 11:28:43.000000000 -0800
@@ -75,7 +75,7 @@
  #include <net/ip.h>
  #include <net/netlink.h>
  #include <net/pkt_sched.h>
-#include <linux/if_tunnel.h>
+#include <net/ipip.h>
  #include <linux/rtnetlink.h>

  #ifdef CONFIG_IPV6_PRIVACY
@@ -1435,6 +1435,11 @@ static int ipv6_generate_eui64(u8 *eui,
                 return addrconf_ifid_arcnet(eui, dev);
         case ARPHRD_INFINIBAND:
                 return addrconf_ifid_infiniband(eui, dev);
+#if defined(CONFIG_IPV6_ISATAP)
+       case ARPHRD_SIT:
+               if (dev->priv_flags&IFF_ISATAP)
+                       return ipv6_isatap_eui64(eui, *(__be32 *)dev->dev_addr);
+#endif
         }
         return -1;
  }
@@ -2201,6 +2206,31 @@ static void addrconf_sit_config(struct n
                 return;
         }

+#if defined(CONFIG_IPV6_ISATAP)
+       /* ISATAP (RFC4214) - configure as NBMA link */
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
@@ -2531,6 +2561,16 @@ static void addrconf_rs_timer(unsigned l
                  *      Announcement received after solicitation
                  *      was sent
                  */
+#if defined(CONFIG_IPV6_ISATAP)
+               /* ISATAP (RFC4214) - Re-DAD to trigger new RS/RA */
+               if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
+                       spin_lock(&ifp->lock);
+                       ifp->probes = 0;
+                       ifp->idev->if_flags &= ~(IF_RS_SENT|IF_RA_RCVD);
+                       addrconf_mod_timer(ifp, AC_DAD, HZ*120);
+                       spin_unlock(&ifp->lock);
+               }
+#endif
                 goto out;
         }

@@ -2545,10 +2585,30 @@ static void addrconf_rs_timer(unsigned l
                                    ifp->idev->cnf.rtr_solicit_interval);
                 spin_unlock(&ifp->lock);

+#if defined(CONFIG_IPV6_ISATAP)
+               /* ISATAP (RFC4214) - unicast RS */
+               if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
+                       struct ip_tunnel *t = netdev_priv(ifp->idev->dev);
+                       __be32 rtr = t->parms.i_key;
+
+                       if (!rtr) goto out;
+
+                       ipv6_addr_set(&all_routers, htonl(0xFE800000), 0, 0, 0);
+                       ipv6_isatap_eui64(all_routers.s6_addr + 8, rtr);
+               } else
+#endif
                 ipv6_addr_all_routers(&all_routers);

                 ndisc_send_rs(ifp->idev->dev, &ifp->addr, &all_routers);
         } else {
+#if defined(CONFIG_IPV6_ISATAP)
+               /* ISATAP (RFC4214) - Re-DAD to trigger new RS/RA */
+               if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
+                       ifp->probes = 0;
+                       ifp->idev->if_flags &= ~(IF_RS_SENT|IF_RA_RCVD);
+                       addrconf_mod_timer(ifp, AC_DAD, HZ*120);
+               }
+#endif
                 spin_unlock(&ifp->lock);
                 /*
                  * Note: we do not support deprecated "all on-link"
@@ -2594,6 +2654,9 @@ static void addrconf_dad_start(struct in
         spin_lock_bh(&ifp->lock);

         if (dev->flags&(IFF_NOARP|IFF_LOOPBACK) ||
+#if defined(CONFIG_IPV6_ISATAP)
+           dev->priv_flags&IFF_ISATAP ||
+#endif
             !(ifp->flags&IFA_F_TENTATIVE) ||
             ifp->flags & IFA_F_NODAD) {
                 ifp->flags &= ~(IFA_F_TENTATIVE|IFA_F_OPTIMISTIC);
@@ -2690,6 +2753,18 @@ static void addrconf_dad_completed(struc
             (ipv6_addr_type(&ifp->addr) & IPV6_ADDR_LINKLOCAL)) {
                 struct in6_addr all_routers;

+#if defined(CONFIG_IPV6_ISATAP)
+               /* ISATAP (RFC4214) - unicast RS */
+               if (ifp->idev->dev->priv_flags & IFF_ISATAP) {
+                       struct ip_tunnel *t = netdev_priv(ifp->idev->dev);
+                       __be32 rtr = t->parms.i_key;
+
+                       if (!rtr) return;
+
+                       ipv6_addr_set(&all_routers, htonl(0xFE800000), 0, 0, 0);
+                       ipv6_isatap_eui64(all_routers.s6_addr + 8, rtr);
+               } else
+#endif
                 ipv6_addr_all_routers(&all_routers);

                 /*
