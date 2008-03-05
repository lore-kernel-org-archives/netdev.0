From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 2/9][NETNS][IPV6] af_inet6 - allow socket creation per namespace
Date: Wed, 05 Mar 2008 18:56:51 +0100
Message-ID: <20080305180156.812542177@mai.toulouse-stg.fr.ibm.com>
References: <20080305175649.348451657@mai.toulouse-stg.fr.ibm.com>
Cc: netdev@vger.kernel.org, benjamin.thery@bull.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:18289 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752533AbYCESCC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 13:02:02 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id m25I20jq103374
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 18:02:00 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m25I20eH2015258
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 19:02:00 +0100
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m25I1xne030804
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 19:02:00 +0100
Content-Disposition: inline; filename=ipv6-allow-creation-of-ipv6-sockets-per-namespace.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow creation of IPv6 raw and datagram sockets in network namespaces 
other than init_net.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv6/af_inet6.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

Index: net-2.6.26/net/ipv6/af_inet6.c
===================================================================
--- net-2.6.26.orig/net/ipv6/af_inet6.c
+++ net-2.6.26/net/ipv6/af_inet6.c
@@ -92,9 +92,6 @@ static int inet6_create(struct net *net,
 	int try_loading_module = 0;
 	int err;
 
-	if (net != &init_net)
-		return -EAFNOSUPPORT;
-
 	if (sock->type != SOCK_RAW &&
 	    sock->type != SOCK_DGRAM &&
 	    !inet_ehash_secret)
@@ -248,6 +245,7 @@ int inet6_bind(struct socket *sock, stru
 	struct sock *sk = sock->sk;
 	struct inet_sock *inet = inet_sk(sk);
 	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct net *net = sk->sk_net;
 	__be32 v4addr = 0;
 	unsigned short snum;
 	int addr_type = 0;
@@ -278,7 +276,7 @@ int inet6_bind(struct socket *sock, stru
 	/* Check if the address belongs to the host. */
 	if (addr_type == IPV6_ADDR_MAPPED) {
 		v4addr = addr->sin6_addr.s6_addr32[3];
-		if (inet_addr_type(&init_net, v4addr) != RTN_LOCAL) {
+		if (inet_addr_type(net, v4addr) != RTN_LOCAL) {
 			err = -EADDRNOTAVAIL;
 			goto out;
 		}
@@ -300,7 +298,7 @@ int inet6_bind(struct socket *sock, stru
 					err = -EINVAL;
 					goto out;
 				}
-				dev = dev_get_by_index(&init_net, sk->sk_bound_dev_if);
+				dev = dev_get_by_index(net, sk->sk_bound_dev_if);
 				if (!dev) {
 					err = -ENODEV;
 					goto out;
@@ -312,7 +310,7 @@ int inet6_bind(struct socket *sock, stru
 			 */
 			v4addr = LOOPBACK4_IPV6;
 			if (!(addr_type & IPV6_ADDR_MULTICAST))	{
-				if (!ipv6_chk_addr(&init_net, &addr->sin6_addr,
+				if (!ipv6_chk_addr(net, &addr->sin6_addr,
 						   dev, 0)) {
 					if (dev)
 						dev_put(dev);

-- 
