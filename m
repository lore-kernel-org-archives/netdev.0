From: Horms <horms@verge.net.au>
Subject: [PATCH] LVS: Send ICMP unreachable responses to end-users when real-servers are removed
Date: Sun, 11 Feb 2007 12:04:43 +0900
Message-ID: <20070211030441.GB3383@verge.net.au>
Cc: Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>,
	Julian Anastasov <ja@ssi.bg>,
	Wensong Zhang <wensong@linux-vs.org>,
	Joseph Mack NA3T <jmack@wm7d.net>,
	Roberto Nibali <ratz@drugphish.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:41739 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752647AbXBKD70 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Feb 2007 22:59:26 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

this is a small patch by  Janusz Krzysztofik to ip_route_output_slow()
that allows VIP-less LVS linux director to generate packets originating
>From VIP if sysctl_ip_nonlocal_bind is set.

In a nutshell, the intention is for an LVS linux director to be able
to send ICMP unreachable responses to end-users when real-servers are
removed.

http://archive.linuxvirtualserver.org/html/lvs-users/2007-01/msg00106.html

I'm not really sure about the correctness of this approach,
so I am sending it here to netdev for review

Cc: Janusz Krzysztofik <jkrzyszt@tis.icnet.pl>
Signed-off-by: Simon Horman <horms@verge.net.au>

Index: net-2.6/net/ipv4/route.c
===================================================================
--- net-2.6.orig/net/ipv4/route.c	2007-02-11 11:46:08.000000000 +0900
+++ net-2.6/net/ipv4/route.c	2007-02-11 11:46:23.000000000 +0900
@@ -2397,7 +2397,7 @@
 
 		/* It is equivalent to inet_addr_type(saddr) == RTN_LOCAL */
 		dev_out = ip_dev_find(oldflp->fl4_src);
-		if (dev_out == NULL)
+		if ((dev_out == NULL) && !(sysctl_ip_nonlocal_bind))
 			goto out;
 
 		/* I removed check for oif == dev_out->oif here.
@@ -2408,7 +2408,7 @@
 		      of another iface. --ANK
 		 */
 
-		if (oldflp->oif == 0
+		if (dev_out && oldflp->oif == 0
 		    && (MULTICAST(oldflp->fl4_dst) || oldflp->fl4_dst == htonl(0xFFFFFFFF))) {
 			/* Special hack: user can direct multicasts
 			   and limited broadcast via necessary interface
