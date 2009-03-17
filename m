From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [RFC PATCH 3/4] ipv6: Make v4-mapped bindings consitant with IPv4
Date: Tue, 17 Mar 2009 17:06:01 -0400
Message-ID: <1237323962-18635-4-git-send-email-vladislav.yasevich@hp.com>
References: <20090317.123146.210941276.davem@davemloft.net>
Cc: netdev@vger.kernel.org, Vlad Yasevich <vladislav.yasevich@hp.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:46137 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754182AbZCQVGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2009 17:06:08 -0400
In-Reply-To: <20090317.123146.210941276.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Binding to a v4-mapped address on an AF_INET6 socket should
produce the same result as binding to an IPv4 address on
AF_INET socket.  The two are interchangable as v4-mapped
address is really a portability aid.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/ipv6/af_inet6.c |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 0adce8e..274cc89 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -276,6 +276,8 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 
 	/* Check if the address belongs to the host. */
 	if (addr_type == IPV6_ADDR_MAPPED) {
+		int chk_addr_ret;
+
 		/* Binding to v4-mapped address on a v6-only socket
 		 * makes no sense
 		 */
@@ -283,11 +285,17 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 			err = -EINVAL;
 			goto out;
 		}
+
+		/* Reproduce AF_INET checks to make the bindings consitant */
 		v4addr = addr->sin6_addr.s6_addr32[3];
-		if (inet_addr_type(net, v4addr) != RTN_LOCAL) {
-			err = -EADDRNOTAVAIL;
+		chk_addr_ret = inet_addr_type(net, v4addr);
+		if (!sysctl_ip_nonlocal_bind &&
+		    !(inet->freebind || inet->transparent) &&
+		    v4addr != htonl(INADDR_ANY) &&
+		    chk_addr_ret != RTN_LOCAL &&
+		    chk_addr_ret != RTN_MULTICAST &&
+		    chk_addr_ret != RTN_BROADCAST)
 			goto out;
-		}
 	} else {
 		if (addr_type != IPV6_ADDR_ANY) {
 			struct net_device *dev = NULL;
-- 
1.5.4.3

