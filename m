From: Balakumaran Kannan <kumaran.4353@gmail.com>
Subject: Re: [PATCH v2] net IPv6 : Fix broken IPv6 routing table after
 loopback down-up
Date: Thu, 28 Mar 2013 20:44:36 +0530
Message-ID: <CAHPKR9J=niSHrGmeX7ZM-1fosjnRA_CFrfd+ha3zwNibNGe1bg@mail.gmail.com>
References: <CAHPKR9KE4LT_AEzUZ8cuJwBeMEEu0Ppe+jjynFQk7+N-A4YUmQ@mail.gmail.com>
	<1364478265.15753.42.camel@edumazet-glaptop>
	<1364478316.15753.43.camel@edumazet-glaptop>
	<CAHPKR9L4Y0=cbH7w_iZ20CBsH=nt4UuZwyBvDOMSrMmM_sJt1w@mail.gmail.com>
	<CAHPKR9J4vmPp6SFn-betmb6GLimZE6dRf0Tapeu5jzyUJ=vK6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: yoshfuji@linux-ipv6.org, davem@davemloft.net,
	Patrick McHardy <kaber@trash.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, jmorris@namei.org,
	Balakumaran.Kannan@ap.sony.com, maruthi.thotad@ap.sony.com,
	netdev@vger.kernel.org, jamshed.a@ap.sony.com,
	amit.agarwal@ap.sony.com, takuzo.ohara@jp.sony.com,
	aaditya.kumar@ap.sony.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:34193 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751697Ab3C1PUH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Mar 2013 11:20:07 -0400
Received: by mail-wi0-f177.google.com with SMTP id hm14so3348302wib.4
        for <netdev@vger.kernel.org>; Thu, 28 Mar 2013 08:20:06 -0700 (PDT)
In-Reply-To: <CAHPKR9J4vmPp6SFn-betmb6GLimZE6dRf0Tapeu5jzyUJ=vK6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 Routing table becomes broken once we do ifdown, ifup of the loopback(lo)
interface. After down-up, routes of other interface's IPv6 addresses through
'lo' are lost.

IPv6 addresses assigned to all interfaces are routed through 'lo' for internal
communication. Once 'lo' is down, those routing entries are removed from
routing table. But those removed entries are not being re-created properly when
'lo' is brought up. So IPv6 addresses of other interfaces becomes unreachable
from the same machine. Also this breaks communication with other machines
because of NDISC packet processing failure.

This patch fixes this issue by reading all interface's IPv6 addresses and
adding them to IPv6 routing table while bringing up 'lo'.

Patch is prepared for Linux-3.9.rc4 kernel.

Signed-off-by: Balakumaran Kannan <Balakumaran.Kannan@ap.sony.com>
Signed-off-by: Maruthi Thotad <Maruthi.Thotad@ap.sony.com>
---
==Testing==
Before applying the patch:
$ route -A inet6
Kernel IPv6 routing table
Destination                    Next Hop                   Flag Met Ref Use If
2000::20/128                   ::                         U    256 0     0 eth0
fe80::/64                      ::                         U    256 0     0 eth0
::/0                           ::                         !n   -1  1     1 lo
::1/128                        ::                         Un   0   1     0 lo
2000::20/128                   ::                         Un   0   1     0 lo
fe80::xxxx:xxxx:xxxx:xxxx/128  ::                         Un   0   1     0 lo
ff00::/8                       ::                         U    256 0     0 eth0
::/0                           ::                         !n   -1  1     1 lo
$ sudo ifdown lo
$ sudo ifup lo
$ route -A inet6
Kernel IPv6 routing table
Destination                    Next Hop                   Flag Met Ref Use If
2000::20/128                   ::                         U    256 0     0 eth0
fe80::/64                      ::                         U    256 0     0 eth0
::/0                           ::                         !n   -1  1     1 lo
::1/128                        ::                         Un   0   1     0 lo
ff00::/8                       ::                         U    256 0     0 eth0
::/0                           ::                         !n   -1  1     1 lo
$

After applying the patch:
$ route -A inet6
Kernel IPv6 routing
table
Destination                    Next Hop                   Flag Met Ref Use If
2000::20/128                   ::                         U    256 0     0 eth0
fe80::/64                      ::                         U    256 0     0 eth0
::/0                           ::                         !n   -1  1     1 lo
::1/128                        ::                         Un   0   1     0 lo
2000::20/128                   ::                         Un   0   1     0 lo
fe80::xxxx:xxxx:xxxx:xxxx/128  ::                         Un   0   1     0 lo
ff00::/8                       ::                         U    256 0     0 eth0
::/0                           ::                         !n   -1  1     1 lo
$ sudo ifdown lo
$ sudo ifup lo
$ route -A inet6
Kernel IPv6 routing table
Destination                    Next Hop                   Flag Met Ref Use If
2000::20/128                   ::                         U    256 0     0 eth0
fe80::/64                      ::                         U    256 0     0 eth0
::/0                           ::                         !n   -1  1     1 lo
::1/128                        ::                         Un   0   1     0 lo
2000::20/128                   ::                         Un   0   1     0 lo
fe80::xxxx:xxxx:xxxx:xxxx/128  ::                         Un   0   1     0 lo
ff00::/8                       ::                         U    256 0     0 eth0
::/0                           ::                         !n   -1  1     1 lo
$
---
--- linux-3.9-rc4/net/ipv6/addrconf.c.orig	2013-03-27 10:40:26.382569527 +0530
+++ linux-3.9-rc4/net/ipv6/addrconf.c	2013-03-28 20:33:59.908228232 +0530
@@ -2529,6 +2529,9 @@ static void sit_add_v4_addrs(struct inet
 static void init_loopback(struct net_device *dev)
 {
 	struct inet6_dev  *idev;
+	struct net_device *sp_dev;
+	struct inet6_ifaddr *sp_ifa;
+	struct rt6_info *sp_rt;

 	/* ::1 */

@@ -2540,6 +2543,31 @@ static void init_loopback(struct net_dev
 	}

 	add_addr(idev, &in6addr_loopback, 128, IFA_HOST);
+
+	/* Add routes to other interface's IPv6 addresses */
+	for_each_netdev(dev_net(dev), sp_dev) {
+
+		if (!strcmp(sp_dev->name, dev->name))
+			continue;
+
+		idev = __in6_dev_get(sp_dev);
+		if (NULL == idev)
+			continue;
+
+		read_lock_bh(&idev->lock);
+		list_for_each_entry(sp_ifa, &idev->addr_list, if_list) {
+
+			if (sp_ifa->flags & (IFA_F_DADFAILED | IFA_F_TENTATIVE))
+				continue;
+
+			sp_rt = addrconf_dst_alloc(idev, &sp_ifa->addr, 0);
+
+			/* Failure cases are ignored */
+			if (!IS_ERR(sp_rt))
+				ip6_ins_rt(sp_rt);
+		}
+		read_unlock_bh(&idev->lock);
+	}
 }

 static void addrconf_add_linklocal(struct inet6_dev *idev, const
struct in6_addr *addr)
