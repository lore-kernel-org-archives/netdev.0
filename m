From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH net] ipv4: reject RTNH_F_LINKDOWN for incompatible routes
Date: Sat,  9 Jul 2016 12:00:15 +0300
Message-ID: <1468054815-24766-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org, Vegard Nossum <vegard.nossum@oracle.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:39904 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932860AbcGIJBF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Jul 2016 05:01:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vegard Nossum is reporting for a crash in fib_dump_info (fib_nhs==1)
when nh_dev = NULL. Problem happens when RTNH_F_LINKDOWN is
provided from user space for routes that do not use the flag,
catched with netlink fuzzer.

RTNH_F_LINKDOWN should be used only for link routes, not for
local routes or for routes with error code. Do not complicate
fast path with more checks, reject the flag early when configured
for incompatible routes.

Reported-by: Vegard Nossum <vegard.nossum@oracle.com>
Fixes: 0eeb075fad73 ("net: ipv4 sysctl option to ignore routes when nexthop link is down")
Tested-by: Vegard Nossum <vegard.nossum@oracle.com>
Signed-off-by: Julian Anastasov <ja@ssi.bg>
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>
Cc: Dinesh Dutt <ddutt@cumulusnetworks.com>
Cc: Scott Feldman <sfeldma@gmail.com>
---
 net/ipv4/fib_semantics.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Note: works for all kernels: net, net-next, 4.4.14, 4.5.7, 4.6.3

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index d09173b..b642479 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1113,7 +1113,8 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 	}
 
 	if (fib_props[cfg->fc_type].error) {
-		if (cfg->fc_gw || cfg->fc_oif || cfg->fc_mp)
+		if (cfg->fc_gw || cfg->fc_oif || cfg->fc_mp ||
+		    (fi->fib_nh->nh_flags & RTNH_F_LINKDOWN))
 			goto err_inval;
 		goto link_it;
 	} else {
@@ -1136,7 +1137,7 @@ struct fib_info *fib_create_info(struct fib_config *cfg)
 		struct fib_nh *nh = fi->fib_nh;
 
 		/* Local address is added. */
-		if (nhs != 1 || nh->nh_gw)
+		if (nhs != 1 || nh->nh_gw || (nh->nh_flags & RTNH_F_LINKDOWN))
 			goto err_inval;
 		nh->nh_scope = RT_SCOPE_NOWHERE;
 		nh->nh_dev = dev_get_by_index(net, fi->fib_nh->nh_oif);
-- 
1.9.3
