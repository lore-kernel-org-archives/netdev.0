From: Vadim Fedorenko <junk@yandex-team.ru>
Subject: [PATCH net] ip6_tunnel: fix ip6_tnl_lookup
Date: Tue, 11 Oct 2016 22:47:20 +0300
Message-ID: <20161011203454.F2B87341C3E@junk-ub14>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pmsearch-qa01d.mail.yandex.net ([5.255.216.105]:33943 "EHLO
        outback2m.cmail.yandex.net" rhost-flags-OK-FAIL-OK-OK)
        by vger.kernel.org with ESMTP id S1754934AbcJKUl0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Oct 2016 16:41:26 -0400
Received: from outback2m.cmail.yandex.net (outback2m.cmail.yandex.net [127.0.0.1])
        by outback2m.cmail.yandex.net (Yandex) with ESMTP id 5203321BA7
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2016 23:34:55 +0300 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit ea3dc9601bda ("ip6_tunnel: Add support for wildcard tunnel
endpoints.") introduces support for wildcards in tunnels endpoints,
but in some rare circumstances ip6_tnl_lookup selects wrong tunnel
interface relying only on source or destination address of the packet
and not checking presence of wildcard in tunnels endpoints. Later in
ip6_tnl_rcv this packets can be dicarded because of difference in
ipproto even if fallback device have proper ipproto configuration.

This patch adds checks of wildcard endpoint in tunnel avoiding such
behavior

Fixes: ea3dc9601bda ("ip6_tunnel: Add support for wildcard tunnel
endpoints.")

Signed-off-by: Vadim Fedorenko <junk@yandex-team.ru>
---
 net/ipv6/ip6_tunnel.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 6a66adb..5692d6b 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -157,6 +157,7 @@ ip6_tnl_lookup(struct net *net, const struct in6_addr *remote, const struct in6_
 	hash = HASH(&any, local);
 	for_each_ip6_tunnel_rcu(ip6n->tnls_r_l[hash]) {
 		if (ipv6_addr_equal(local, &t->parms.laddr) &&
+		    ipv6_addr_any(&t->parms.raddr) &&
 		    (t->dev->flags & IFF_UP))
 			return t;
 	}
@@ -164,6 +165,7 @@ ip6_tnl_lookup(struct net *net, const struct in6_addr *remote, const struct in6_
 	hash = HASH(remote, &any);
 	for_each_ip6_tunnel_rcu(ip6n->tnls_r_l[hash]) {
 		if (ipv6_addr_equal(remote, &t->parms.raddr) &&
+		    ipv6_addr_any(&t->parms.laddr) &&
 		    (t->dev->flags & IFF_UP))
 			return t;
 	}
-- 
1.9.1
