From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 5/5] vti6: Add a lookup method for tunnels with wildcard endpoints.
Date: Wed, 3 Dec 2014 11:05:01 +0100
Message-ID: <1417601101-18625-6-git-send-email-steffen.klassert@secunet.com>
References: <1417601101-18625-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:33460 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751629AbaLCKFa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Dec 2014 05:05:30 -0500
In-Reply-To: <1417601101-18625-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we can't lookup tunnels with wildcard endpoints.
This patch adds a method to lookup these tunnels in the
receive path.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/ip6_vti.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/net/ipv6/ip6_vti.c b/net/ipv6/ip6_vti.c
index d440bb5..6101919 100644
--- a/net/ipv6/ip6_vti.c
+++ b/net/ipv6/ip6_vti.c
@@ -95,6 +95,7 @@ vti6_tnl_lookup(struct net *net, const struct in6_addr *remote,
 	unsigned int hash = HASH(remote, local);
 	struct ip6_tnl *t;
 	struct vti6_net *ip6n = net_generic(net, vti6_net_id);
+	struct in6_addr any;
 
 	for_each_vti6_tunnel_rcu(ip6n->tnls_r_l[hash]) {
 		if (ipv6_addr_equal(local, &t->parms.laddr) &&
@@ -102,6 +103,22 @@ vti6_tnl_lookup(struct net *net, const struct in6_addr *remote,
 		    (t->dev->flags & IFF_UP))
 			return t;
 	}
+
+	memset(&any, 0, sizeof(any));
+	hash = HASH(&any, local);
+	for_each_vti6_tunnel_rcu(ip6n->tnls_r_l[hash]) {
+		if (ipv6_addr_equal(local, &t->parms.laddr) &&
+		    (t->dev->flags & IFF_UP))
+			return t;
+	}
+
+	hash = HASH(remote, &any);
+	for_each_vti6_tunnel_rcu(ip6n->tnls_r_l[hash]) {
+		if (ipv6_addr_equal(remote, &t->parms.raddr) &&
+		    (t->dev->flags & IFF_UP))
+			return t;
+	}
+
 	t = rcu_dereference(ip6n->tnls_wc[0]);
 	if (t && (t->dev->flags & IFF_UP))
 		return t;
-- 
1.9.1
