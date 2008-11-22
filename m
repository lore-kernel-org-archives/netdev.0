From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] net: some optimizations in af_inet
Date: Sat, 22 Nov 2008 08:06:09 +0100
Message-ID: <4927AF61.40002@cosmosbay.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010304040907030405080207"
To: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:47519 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752595AbYKVHGP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Nov 2008 02:06:15 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010304040907030405080207
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

1) Use eq_net() in inet_netns_ok() to speedup socket creation if !CONFIG_NET_NS

2) Reorder the tests about inet_ehash_secret generation (once only)
   Use the unlikely() macro when testing if inet_ehash_secret already generated.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

--------------010304040907030405080207
Content-Type: text/plain;
 name="af_inet.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="af_inet.patch"

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index b1462e8..fe03048 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -245,7 +245,7 @@ static inline int inet_netns_ok(struct net *net, int protocol)
 	int hash;
 	struct net_protocol *ipprot;
 
-	if (net == &init_net)
+	if (net_eq(net, &init_net))
 		return 1;
 
 	hash = protocol & (MAX_INET_PROTOS - 1);
@@ -272,10 +272,9 @@ static int inet_create(struct net *net, struct socket *sock, int protocol)
 	int try_loading_module = 0;
 	int err;
 
-	if (sock->type != SOCK_RAW &&
-	    sock->type != SOCK_DGRAM &&
-	    !inet_ehash_secret)
-		build_ehash_secret();
+	if (unlikely(!inet_ehash_secret))
+		if (sock->type != SOCK_RAW && sock->type != SOCK_DGRAM)
+			build_ehash_secret();
 
 	sock->state = SS_UNCONNECTED;
 

--------------010304040907030405080207--
