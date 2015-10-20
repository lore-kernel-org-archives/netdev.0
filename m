From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net] ipv4: implement support for NOPREFIXROUTE ifa flag for ipv4 address
Date: Tue, 20 Oct 2015 10:28:45 +0200
Message-ID: <7decee4d1d1b71142460e604af6d15f0847ecd2d.1445329646.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55189 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752551AbbJTIaU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Oct 2015 04:30:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently adding a new ipv4 address always cause the creation of the
related network route, with default metric. When a host has multiple
interfaces on the same network, multiple routes with the same metric
are created.

If the userspace wants to set specific metric on each routes, i.e.
giving better metric to ethernet links in respect to Wi-Fi ones,
the network routes must be deleted and recreated, which is error-prone.

This patch implements the support for IFA_F_NOPREFIXROUTE for ipv4
address. When an address is added with such flag set, no associated
network route is created, no network route is deleted when
said IP is gone and it's up to the user space manage such route.

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/fib_frontend.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index d7c2bb0..e786873 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -867,9 +867,10 @@ void fib_add_ifaddr(struct in_ifaddr *ifa)
 
 	if (!ipv4_is_zeronet(prefix) && !(ifa->ifa_flags & IFA_F_SECONDARY) &&
 	    (prefix != addr || ifa->ifa_prefixlen < 32)) {
-		fib_magic(RTM_NEWROUTE,
-			  dev->flags & IFF_LOOPBACK ? RTN_LOCAL : RTN_UNICAST,
-			  prefix, ifa->ifa_prefixlen, prim);
+		if (!(ifa->ifa_flags & IFA_F_NOPREFIXROUTE))
+			fib_magic(RTM_NEWROUTE,
+				  dev->flags & IFF_LOOPBACK ? RTN_LOCAL : RTN_UNICAST,
+				  prefix, ifa->ifa_prefixlen, prim);
 
 		/* Add network specific broadcasts, when it takes a sense */
 		if (ifa->ifa_prefixlen < 31) {
@@ -914,9 +915,10 @@ void fib_del_ifaddr(struct in_ifaddr *ifa, struct in_ifaddr *iprim)
 		}
 	} else if (!ipv4_is_zeronet(any) &&
 		   (any != ifa->ifa_local || ifa->ifa_prefixlen < 32)) {
-		fib_magic(RTM_DELROUTE,
-			  dev->flags & IFF_LOOPBACK ? RTN_LOCAL : RTN_UNICAST,
-			  any, ifa->ifa_prefixlen, prim);
+		if (!(ifa->ifa_flags & IFA_F_NOPREFIXROUTE))
+			fib_magic(RTM_DELROUTE,
+				  dev->flags & IFF_LOOPBACK ? RTN_LOCAL : RTN_UNICAST,
+				  any, ifa->ifa_prefixlen, prim);
 		subnet = 1;
 	}
 
-- 
1.8.3.1
