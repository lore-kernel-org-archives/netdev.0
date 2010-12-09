From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] Fix 2.6.34-rc1 regression in  disable_ipv6 support
Date: Wed, 08 Dec 2010 20:16:27 -0800
Message-ID: <m1mxofa8dg.fsf_-_@fess.ebiederm.org>
References: <m17hfnlpe1.fsf@fess.ebiederm.org> <4CFD0AF0.9090809@hp.com>
	<m14oaoeywf.fsf@fess.ebiederm.org> <4D000B6D.1060708@hp.com>
	<m1tyineu3p.fsf@fess.ebiederm.org> <20101208154932.5bc4b254@nehalam>
	<m11v5rekg3.fsf@fess.ebiederm.org> <m1ipz3d46m.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org,
	Mahesh Kelkar <maheshkelkar@gmail.com>,
	Lorenzo Colitti <lorenzo@google.com>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:47066 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752168Ab0LIEQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 23:16:34 -0500
Cc: stable@kernel.org
In-Reply-To: <m1ipz3d46m.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Wed, 08 Dec 2010 19:18:41 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


In a number of instances it is desirable to have systems that run with
ipv6 disabled, but where enabling ipv6 remains an option.  This
has been broken since 2.6.34-rc1.

The problem is failure mode is that after
# ip link set lo up
# echo 1 > /proc/sys/net/ipv6/conf/lo/disable_ipv6
# echo 0 > /proc/sys/net/ipv6/conf/lo/disable_ipv6
# ping6 ::1

The ping and anything similar operations that use the
ipv6 loopback address fail with network not reachable.

This failure mode appears to start with:
   commit dc2b99f71ef477a31020511876ab4403fb7c4420
   Author: stephen hemminger <shemminger@vyatta.com>
   Date:   Mon Feb 8 19:48:05 2010 +0000
   
       IPv6: keep permanent addresses on admin down
       
       Permanent IPV6 addresses should not be removed when the link is
       set to admin down, only when device is removed.
       
       When link is lost permanent addresses should be marked as tentative
       so that when link comes back they are subject to duplicate address
       detection (if DAD was enabled for that address).
       
       Other routing systems keep manually configured IPv6 addresses
       when link is set down.
       
       Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
       Signed-off-by: David S. Miller <davem@davemloft.net>

Keeping ipv6 addresses on network interfaces when we bring those
interfaces down is not the fundamental problem.  The real problem is
that there is something about routes and route-caches that make local
ipv6 address unreachable after the loopback interface is brought down,
and then brought up again, and it has been that way since at least
2.6.32.

Finding the real bug is beyond me right now, but fixing the regression
in disable_ipv6 is simple.  We can just delete ::1 when we bring down
the loopback interface, and it will be restored automatically when we
bring the loopback interface back up.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
Index: linux-2.6.37-rc5.x86_64/net/ipv6/addrconf.c
===================================================================
--- linux-2.6.37-rc5.x86_64.orig/net/ipv6/addrconf.c
+++ linux-2.6.37-rc5.x86_64/net/ipv6/addrconf.c
@@ -2727,6 +2727,7 @@ static int addrconf_ifdown(struct net_de
 		/* If just doing link down, and address is permanent
 		   and not link-local, then retain it. */
 		if (!how &&
+		    !ipv6_addr_loopback(&ifa->addr) &&
 		    (ifa->flags&IFA_F_PERMANENT) &&
 		    !(ipv6_addr_type(&ifa->addr) & IPV6_ADDR_LINKLOCAL)) {
 			list_move_tail(&ifa->if_list, &keep_list);
