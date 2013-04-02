From: Balakumaran Kannan <kumaran.4353@gmail.com>
Subject: Re: [PATCH v2] net IPv6 : Fix broken IPv6 routing table after loopback
 down-up
Date: Tue, 02 Apr 2013 16:15:05 +0530
Message-ID: <515AB6B1.4080501@gmail.com>
References: <CAHPKR9L4Y0=cbH7w_iZ20CBsH=nt4UuZwyBvDOMSrMmM_sJt1w@mail.gmail.com> <CAHPKR9J4vmPp6SFn-betmb6GLimZE6dRf0Tapeu5jzyUJ=vK6Q@mail.gmail.com> <CAHPKR9J=niSHrGmeX7ZM-1fosjnRA_CFrfd+ha3zwNibNGe1bg@mail.gmail.com> <20130329.151759.1699178800809051958.davem@davemloft.net> <CAHPKR9+=fFPTpjdE+diyXDvjEdPcqcRXJvWP_rHWrqB7wMTEPA@mail.gmail.com> <515976BE.6060607@gmail.com> <515996CF.3030809@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com,
	kaber@trash.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	Balakumaran.Kannan@ap.sony.com, maruthi.thotad@ap.sony.com,
	netdev@vger.kernel.org, jamshed.a@ap.sony.com,
	amit.agarwal@ap.sony.com, takuzo.ohara@jp.sony.com,
	aaditya.kumar@ap.sony.com
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:39861 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932477Ab3DBKpX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 06:45:23 -0400
Received: by mail-pb0-f48.google.com with SMTP id xb4so173052pbc.35
        for <netdev@vger.kernel.org>; Tue, 02 Apr 2013 03:45:22 -0700 (PDT)
In-Reply-To: <515996CF.3030809@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 Routing table becomes broken once we do ifdown, ifup of the loopback(lo)
interface. After down-up, routes of other interface's IPv6 addresses through
'lo' are lost.

IPv6 addresses assigned to all interfaces are routed through 'lo' for internal
communication. Once 'lo' is down, those routing entries are removed from routing
table. But those removed entries are not being re-created properly when 'lo' is
brought up. So IPv6 addresses of other interfaces becomes unreachable from the
same machine. Also this breaks communication with other machines because of
NDISC packet processing failure.

This patch fixes this issue by reading all interface's IPv6 addresses and adding
them to IPv6 routing table while bringing up 'lo'.

Patch is prepared for Linux-3.9.rc5 kernel.

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
--- linux-3.9-rc5/net/ipv6/addrconf.c.orig	2013-04-02 15:53:44.401743369 +0530
+++ linux-3.9-rc5/net/ipv6/addrconf.c	2013-04-02 15:53:54.921794799 +0530
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
+		if (!idev)
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
 
 static void addrconf_add_linklocal(struct inet6_dev *idev, const struct in6_addr *addr)
