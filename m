From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next RFC v1 13/27] afnetns: use inet_allow_bind in inet6_bind
Date: Mon, 13 Mar 2017 00:01:37 +0100
Message-ID: <20170312230151.5185-14-hannes@stressinduktion.org>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:48852 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935607AbdCLXCJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:02:09 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id 80CB5207AC
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:04 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id AE60D240CF
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:03 -0400 (EDT)
In-Reply-To: <20170312230151.5185-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/af_inet6.c | 17 ++++-------------
 1 file changed, 4 insertions(+), 13 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 04db40620ea65c..f9367c507573bc 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -316,8 +316,6 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 
 	/* Check if the address belongs to the host. */
 	if (addr_type == IPV6_ADDR_MAPPED) {
-		int chk_addr_ret;
-
 		/* Binding to v4-mapped address on a v6-only socket
 		 * makes no sense
 		 */
@@ -326,18 +324,11 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 			goto out;
 		}
 
-		/* Reproduce AF_INET checks to make the bindings consistent */
-		v4addr = addr->sin6_addr.s6_addr32[3];
-		chk_addr_ret = inet_addr_type(net, v4addr);
-		if (!net->ipv4.sysctl_ip_nonlocal_bind &&
-		    !(inet->freebind || inet->transparent) &&
-		    v4addr != htonl(INADDR_ANY) &&
-		    chk_addr_ret != RTN_LOCAL &&
-		    chk_addr_ret != RTN_MULTICAST &&
-		    chk_addr_ret != RTN_BROADCAST) {
-			err = -EADDRNOTAVAIL;
+		err = inet_allow_bind(sk, addr->sin6_addr.s6_addr32[3]);
+		if (err < 0)
 			goto out;
-		}
+		else
+			err = 0;
 	} else {
 		if (addr_type != IPV6_ADDR_ANY) {
 			struct net_device *dev = NULL;
-- 
2.9.3
