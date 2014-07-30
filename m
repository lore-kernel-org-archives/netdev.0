From: David Lamparter <equinox@diac24.net>
Subject: [PATCH net-next] ipv6: addrconf: fix mcast route for GRE devices
Date: Wed, 30 Jul 2014 02:55:43 +0200
Message-ID: <1406681743-104844-1-git-send-email-equinox@diac24.net>
Cc: David Lamparter <equinox@diac24.net>,
	Stephen Hemminger <stephen@networkplumber.org>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:47776 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750926AbaG3BTW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2014 21:19:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GRE devices, for some reason, were coming up with an autoconfigured
address, but no ff00::/8 route in the local table.  This breaks any kind
of multicast, in particular OSPFv3, mDNS, - and ND.  In fact, IPv6 only
works at all because there is little need for ND on PtP devices.

Adding any other IPv6 address on the device would rectify this issue
through inet6_addr_add()/addrconf_add_dev() - and would leave the route
around even if the address was later removed.  (This is probably why
this issue was not discovered earlier.  AFAICS it has been there from
the beginning, e.g. aee80b5 "generate link local address for GRE
tunnel")

(Note: multicast is supported on GRE devices of all kinds, including PtP
GRE, P-t-Mcast GRE and NBMA-GRE.)

Fixes: aee80b54b235 (ipv6: generate link local address for GRE tunnel)
Signed-off-by: David Lamparter <equinox@diac24.net>
Cc: Stephen Hemminger <stephen@networkplumber.org>
---
 net/ipv6/addrconf.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 0b239fc..655a0df 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2824,6 +2824,7 @@ static void addrconf_gre_config(struct net_device *dev)
 	}
 
 	addrconf_addr_gen(idev, true);
+	addrconf_add_mroute(dev);
 }
 #endif
 
-- 
1.8.5.5
