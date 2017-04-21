From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net v2] ipv4: Avoid caching l3mdev dst on mismatched local route
Date: Fri, 21 Apr 2017 21:34:59 +0100
Message-ID: <1492806899-6215-1-git-send-email-rshearma@brocade.com>
References: <f3a3ab2d-4a32-a3ec-6a72-071e56577017@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, David Ahern <dsa@cumulusnetworks.com>,
        "Robert Shearman" <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:53740 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1161735AbdDUUfa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 16:35:30 -0400
In-Reply-To: <f3a3ab2d-4a32-a3ec-6a72-071e56577017@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David reported that doing the following:

    ip li add red type vrf table 10
    ip link set dev eth1 vrf red
    ip addr add 127.0.0.1/8 dev red
    ip link set dev eth1 up
    ip li set red up
    ping -c1 -w1 -I red 127.0.0.1
    ip li del red

when either policy routing IP rules are present or the local table
lookup ip rule is before the l3mdev lookup results in a hang with
these messages:

    unregister_netdevice: waiting for red to become free. Usage count = 1

The problem is caused by caching the dst used for sending the packet
out of the specified interface on a local route with a different
nexthop interface. Thus the dst could stay around until the route in
the table the lookup was done is deleted which may be never.

Address the problem by not forcing output device to be the l3mdev in
the flow's output interface if the lookup didn't use the l3mdev. This
then results in the dst using the right device according to the route.

Changes in v2:
 - make the dev_out passed in by __ip_route_output_key_hash correct
   instead of checking the nh dev if FLOWI_FLAG_SKIP_NH_OIF is set as
   suggested by David.

Fixes: 5f02ce24c2696 ("net: l3mdev: Allow the l3mdev to be a loopback")
Reported-by: David Ahern <dsa@cumulusnetworks.com>
Suggested-by: David Ahern <dsa@cumulusnetworks.com>
Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 net/ipv4/route.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index acd69cfe2951..d9724889ff09 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2359,7 +2359,8 @@ struct rtable *__ip_route_output_key_hash(struct net *net, struct flowi4 *fl4,
 		}
 
 		/* L3 master device is the loopback for that domain */
-		dev_out = l3mdev_master_dev_rcu(dev_out) ? : net->loopback_dev;
+		dev_out = l3mdev_master_dev_rcu(FIB_RES_DEV(res)) ? :
+			net->loopback_dev;
 		fl4->flowi4_oif = dev_out->ifindex;
 		flags |= RTCF_LOCAL;
 		goto make_route;
-- 
2.1.4
