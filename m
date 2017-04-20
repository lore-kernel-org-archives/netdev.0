From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net] ipv4: Avoid caching dsts when lookup skipped nh oif check
Date: Thu, 20 Apr 2017 13:58:52 +0100
Message-ID: <1492693132-4708-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, David Ahern <dsa@cumulusnetworks.com>,
        "Robert Shearman" <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:60782 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1764767AbdDTM70 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 08:59:26 -0400
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

results in a hang with this message:

    unregister_netdevice: waiting for red to become free. Usage count = 1

The problem is caused by caching the dst used for sending the packet
out of the specified interface on the route that the lookup returned
from the local table when the rule for the lookup in the local table
is ordered before the rule for lookups using l3mdevs. Thus the dst
could stay around until the route in the local table is deleted which
may be never.

Address the problem by not allocating a cacheable output dst if
FLOWI_FLAG_SKIP_NH_OIF is set and the nh device differs from the
device used for the dst.

Fixes: ebfc102c566d ("net: vrf: Flip IPv4 output path from FIB lookup hook to out hook")
Reported-by: David Ahern <dsa@cumulusnetworks.com>
Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 net/ipv4/route.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index acd69cfe2951..f667783ffd19 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2125,6 +2125,14 @@ static struct rtable *__mkroute_output(const struct fib_result *res,
 		fi = NULL;
 	}
 
+	/* If the flag to skip the nh oif check is set then the output
+	 * device may not match the nh device, so cannot use or add to
+	 * cache in that case.
+	 */
+	if (unlikely(fl4->flowi4_flags & FLOWI_FLAG_SKIP_NH_OIF &&
+		     FIB_RES_NH(*res).nh_dev != dev_out))
+		do_cache = false;
+
 	fnhe = NULL;
 	do_cache &= fi != NULL;
 	if (do_cache) {
-- 
2.1.4
