From: David Lamparter <equinox@diac24.net>
Subject: [PATCH v2] ipv6: addrconf: fix mcast route for GRE devices
Date: Wed, 30 Jul 2014 17:39:57 +0200
Message-ID: <1406734797-122248-1-git-send-email-equinox@diac24.net>
References: <20140730153503.GJ801478@jupiter.n2.diac24.net>
Cc: David Lamparter <equinox@diac24.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:59101 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753182AbaG3PkN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2014 11:40:13 -0400
In-Reply-To: <20140730153503.GJ801478@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GRE devices, for some reason, were coming up with an autoconfigured
address, but no ff00::/8 route in the local table.  This breaks any kind
of multicast, in particular OSPFv3, mDNS, - and ND.  In fact, IPv6 only
works at all because there is little need for ND on PtP devices.

Adding any other IPv6 address on the device from userspace would rectify
this issue through inet6_addr_add()/addrconf_add_dev() - and would leave
the route around even if the address was later removed.  (This is
probably why this issue was not discovered earlier.  AFAICS it has been
there from the beginning, e.g. aee80b5 "generate link local address for
GRE tunnel")

(Note: multicast is supported on GRE devices of all kinds, including PtP
GRE, P-t-Mcast GRE and NBMA-GRE.)

Fixes: aee80b54b235 (ipv6: generate link local address for GRE tunnel)
Signed-off-by: David Lamparter <equinox@diac24.net>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
Cc: Stephen Hemminger <stephen@networkplumber.org>
---
 net/ipv6/addrconf.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 0b239fc..7540a25 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2818,10 +2818,9 @@ static void addrconf_gre_config(struct net_device *dev)
 
 	ASSERT_RTNL();
 
-	if ((idev = ipv6_find_idev(dev)) == NULL) {
-		pr_debug("%s: add_dev failed\n", __func__);
+	idev = addrconf_add_dev(dev);
+	if (IS_ERR(idev))
 		return;
-	}
 
 	addrconf_addr_gen(idev, true);
 }
-- 
1.8.5.5
