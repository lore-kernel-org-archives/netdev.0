From: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Subject: [PATCH] bridge: fix parsing of MLDv2 reports
Date: Fri, 22 May 2015 12:18:59 -0300
Message-ID: <1432307939-19640-1-git-send-email-cascardo@redhat.com>
Cc: davem@davemloft.net, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	yoshfuji@linux-ipv6.org, Rik.Theys@esat.kuleuven.be,
	Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52389 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753148AbbEVPUz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 May 2015 11:20:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When more than a multicast address is present in a MLDv2 report, all but
the first address is ignored, because the code breaks out of the loop if
there has not been an error adding that address.

This has caused failures when two guests connected through the bridge
tried to communicate using IPv6. Neighbor discoveries would not be
transmitted to the other guest when both used a link-local address and a
static address.

This only happens when there is a MLDv2 querier in the network.

The fix will only break out of the loop when there is a failure adding a
multicast address.

The mdb before the patch:

dev ovirtmgmt port vnet0 grp ff02::1:ff7d:6603 temp
dev ovirtmgmt port vnet1 grp ff02::1:ff7d:6604 temp
dev ovirtmgmt port bond0.86 grp ff02::2 temp

After the patch:

dev ovirtmgmt port vnet0 grp ff02::1:ff7d:6603 temp
dev ovirtmgmt port vnet1 grp ff02::1:ff7d:6604 temp
dev ovirtmgmt port bond0.86 grp ff02::fb temp
dev ovirtmgmt port bond0.86 grp ff02::2 temp
dev ovirtmgmt port bond0.86 grp ff02::d temp
dev ovirtmgmt port vnet0 grp ff02::1:ff00:76 temp
dev ovirtmgmt port bond0.86 grp ff02::16 temp
dev ovirtmgmt port vnet1 grp ff02::1:ff00:77 temp
dev ovirtmgmt port bond0.86 grp ff02::1:ff00:def temp
dev ovirtmgmt port bond0.86 grp ff02::1:ffa1:40bf temp

Reported-by: Rik Theys <Rik.Theys@esat.kuleuven.be>
Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@redhat.com>
Tested-by: Rik Theys <Rik.Theys@esat.kuleuven.be>
---
 net/bridge/br_multicast.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index 4b6722f..a3abe6e 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1072,7 +1072,7 @@ static int br_ip6_multicast_mld2_report(struct net_bridge *br,
 
 		err = br_ip6_multicast_add_group(br, port, &grec->grec_mca,
 						 vid);
-		if (!err)
+		if (err)
 			break;
 	}
 
-- 
2.4.1
