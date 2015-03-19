From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH] tipc: fix build issue when building without IPv6
Date: Thu, 19 Mar 2015 12:13:43 -0300
Message-ID: <1426778023-27486-1-git-send-email-marcelo.leitner@gmail.com>
Cc: tipc-discussion@lists.sourceforge.net, erik.hugne@ericsson.com
To: richard.alpe@ericsson.com, jon.maloy@ericsson.com,
	ying.xue@windriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33020 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750994AbbCSPOK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2015 11:14:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can't directly call ipv6_sock_mc_join() but should use the stub
instead and protect it around IS_ENABLED.

Fixes: d0f91938bede ("tipc: add ip/udp media type")
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/tipc/udp_media.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
index 04836dd70c2bb79906307ec40e0cbd7b2589978e..e64634062aff3633bd91064567fe7a914bd6df32 100644
--- a/net/tipc/udp_media.c
+++ b/net/tipc/udp_media.c
@@ -44,6 +44,7 @@
 #include <net/sock.h>
 #include <net/ip.h>
 #include <net/udp_tunnel.h>
+#include <net/addrconf.h>
 #include <linux/tipc_netlink.h>
 #include "core.h"
 #include "bearer.h"
@@ -247,10 +248,13 @@ static int enable_mcast(struct udp_bearer *ub, struct udp_media_addr *remote)
 		mreqn.imr_multiaddr = remote->ipv4;
 		mreqn.imr_ifindex = ub->ifindex;
 		err = ip_mc_join_group(sk, &mreqn);
+#if IS_ENABLED(CONFIG_IPV6)
 	} else {
 		if (!ipv6_addr_is_multicast(&remote->ipv6))
 			return 0;
-		err = ipv6_sock_mc_join(sk, ub->ifindex, &remote->ipv6);
+		err = ipv6_stub->ipv6_sock_mc_join(sk, ub->ifindex,
+						   &remote->ipv6);
+#endif
 	}
 	return err;
 }
@@ -387,6 +391,11 @@ static int tipc_udp_enable(struct net *net, struct tipc_bearer *b,
 	tuncfg.encap_destroy = NULL;
 	setup_udp_tunnel_sock(net, ub->ubsock, &tuncfg);
 
+	/* At this point, IPv6 module should have been loaded in
+	 * udp_sock_create/sock_create_kern().
+	 */
+	BUG_ON(!ipv6_stub);
+
 	if (enable_mcast(ub, remote))
 		goto err;
 	return 0;
-- 
2.1.0
