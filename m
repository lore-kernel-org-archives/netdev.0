From: Vincent Bernat <vincent@bernat.im>
Subject: [PATCH] vxlan: use preferred address family when neither group or remote is specified
Date: Thu,  9 Mar 2017 21:05:42 +0100
Message-ID: <20170309200542.24762-1-vincent@bernat.im>
Cc: Vincent Bernat <vincent@bernat.im>
To: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:56021 "EHLO bart.luffy.cx"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751132AbdCIUP2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Mar 2017 15:15:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When neither group or remote is specified (or if they are specified with
the any address), nothing is sent to the kernel. In this case, the
kernel defaults to IPv4. This makes impossible to use IPv6 with
unspecified unicast remote ("bridge fdb add" will return
EAFNOTSUPPORT).

If the user specifies a preferred address family (eg, "ip -6 link add"),
then send either IFLA_VXLAN_GROUP or IFLA_VXLAN_GROUP6 to enforce the
use of the appropriate family.

Signed-off-by: Vincent Bernat <vincent@bernat.im>
---
 ip/iplink_vxlan.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index 6d02bb47b2f0..fef7d3af4990 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -286,10 +286,14 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 		addattr_l(n, 1024, IFLA_VXLAN_GROUP, &gaddr, 4);
 	else if (daddr)
 		addattr_l(n, 1024, IFLA_VXLAN_GROUP, &daddr, 4);
-	if (!IN6_IS_ADDR_UNSPECIFIED(&gaddr6))
+	else if (!IN6_IS_ADDR_UNSPECIFIED(&gaddr6))
 		addattr_l(n, 1024, IFLA_VXLAN_GROUP6, &gaddr6, sizeof(struct in6_addr));
 	else if (!IN6_IS_ADDR_UNSPECIFIED(&daddr6))
 		addattr_l(n, 1024, IFLA_VXLAN_GROUP6, &daddr6, sizeof(struct in6_addr));
+	else if (preferred_family == AF_INET)
+		addattr_l(n, 1024, IFLA_VXLAN_GROUP, &daddr, 4);
+	else if (preferred_family == AF_INET6)
+		addattr_l(n, 1024, IFLA_VXLAN_GROUP6, &daddr6, sizeof(struct in6_addr));
 
 	if (saddr)
 		addattr_l(n, 1024, IFLA_VXLAN_LOCAL, &saddr, 4);
-- 
2.11.0
