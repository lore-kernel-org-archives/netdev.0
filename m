From: Tom Herbert <therbert@google.com>
Subject: [PATCH] IPv6: fix rt_lookup in pmtu_discovery
Date: Wed, 6 Jan 2010 20:43:48 -0800
Message-ID: <65634d661001062043s1b4eb204v63566149bb44f144@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Lorenzo Colitti <lorenzo@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:36266 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932368Ab0AGEnw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2010 23:43:52 -0500
Received: from spaceape14.eur.corp.google.com (spaceape14.eur.corp.google.com [172.28.16.148])
	by smtp-out.google.com with ESMTP id o074houW023965
	for <netdev@vger.kernel.org>; Thu, 7 Jan 2010 04:43:51 GMT
Received: from pxi1 (pxi1.prod.google.com [10.243.27.1])
	by spaceape14.eur.corp.google.com with ESMTP id o074hmC1012130
	for <netdev@vger.kernel.org>; Wed, 6 Jan 2010 20:43:49 -0800
Received: by pxi1 with SMTP id 1so2697238pxi.25
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2010 20:43:48 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In rt6_pmtu_discovery a route lookup is done constrained to the
receiving interface of the ICMP message.  In the case of an asymmetric
routing, the receive interface may be different than the sending
interface, so no route will be found in such cases and pmtu is never
correctly set in the route to the destination.  This patch fixes that
by not using the receive interface in the lookup.

Tom

Signed-off-by: Tom Herbert <therbert@google.com>

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index df9432a..d7d8893 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1569,7 +1569,7 @@ void rt6_pmtu_discovery(struct in6_addr *daddr,
struct in6_addr *saddr,
        struct net *net = dev_net(dev);
        int allfrag = 0;

-       rt = rt6_lookup(net, daddr, saddr, dev->ifindex, 0);
+       rt = rt6_lookup(net, daddr, saddr, 0, 0);
        if (rt == NULL)
                return;
