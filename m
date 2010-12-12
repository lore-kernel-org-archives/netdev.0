From: Andrey Vagin <avagin@openvz.org>
Subject: [PATCH] net: delete expired route in ip6_pmtu_deliver
Date: Sun, 12 Dec 2010 04:20:11 +0300
Message-ID: <1292116811-22216-1-git-send-email-avagin@openvz.org>
Cc: avagin@openvz.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:10680 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751293Ab0LLBUV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Dec 2010 20:20:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first big packets sent to a "low-MTU" client correctly
triggers the creation of a temporary route containing the reduced MTU.

But after the temporary route has expired, new ICMP6 "packet too big"
will be sent, rt6_pmtu_discovery will find the previous EXPIRED route
check that its mtu isn't bigger then in icmp packet and do nothing
before the temporary route will not deleted by gc.

I make the simple experiment:
while :; do
    time ( dd if=/dev/zero bs=10K count=1 | ssh hostname dd of=/dev/null ) || break;
done

The "time" reports real 0m0.197s if a temporary route isn't expired, but
it reports real 0m52.837s (!!!!) immediately after a temporare route has
expired.

Cc: stable@kernel.org
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 net/ipv6/route.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 96455ffb..7659d6f 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1565,11 +1565,16 @@ static void rt6_do_pmtu_disc(struct in6_addr *daddr, struct in6_addr *saddr,
 {
 	struct rt6_info *rt, *nrt;
 	int allfrag = 0;
-
+again:
 	rt = rt6_lookup(net, daddr, saddr, ifindex, 0);
 	if (rt == NULL)
 		return;
 
+	if (rt6_check_expired(rt)) {
+		ip6_del_rt(rt);
+		goto again;
+	}
+
 	if (pmtu >= dst_mtu(&rt->dst))
 		goto out;
 
-- 
1.7.2.1

