From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next] ipv4: fix validate_source for VRF setup
Date: Mon, 30 Oct 2017 12:02:10 +0100
Message-ID: <4318cc9fd74f049659fc61ab62f3210051f81e37.1509361214.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        David Ahern <dsahern@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41956 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751959AbdJ3LCi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Oct 2017 07:02:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David reported breakages of VRF scenarios due to the
commit 6e617de84e87 ("net: avoid a full fib lookup when rp_filter is
disabled."): the local addresses based test is too strict when VRFs
are in place.

With this change we fall-back to a full lookup when custom fib rules
are in place; so that we address the VRF use case and possibly other
similar issues in non trivial setups.

Reported-by: David Ahern <dsahern@gmail.com>
Fixes: 6e617de84e87 ("net: avoid a full fib lookup when rp_filter is disabled.")
Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/fib_frontend.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index f02819134ba2..95a904098dd1 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -405,10 +405,12 @@ int fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 	    (dev->ifindex != oif || !IN_DEV_TX_REDIRECTS(idev))) {
 		if (IN_DEV_ACCEPT_LOCAL(idev))
 			goto ok;
-		/* if no local routes are added from user space we can check
-		 * for local addresses looking-up the ifaddr table
+		/* with custom local routes in place, checking local addresses
+		 * only will be too optimistic, with custom rules, checking
+		 * local addresses only can be too strict, e.g. due to vrf
 		 */
-		if (net->ipv4.fib_has_custom_local_routes)
+		if (net->ipv4.fib_has_custom_local_routes ||
+		    net->ipv4.fib_has_custom_rules)
 			goto full_check;
 		if (inet_lookup_ifaddr_rcu(net, src))
 			return -EINVAL;
-- 
2.13.6
