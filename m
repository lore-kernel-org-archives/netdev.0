From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH v2] tipc: fix build issue when building without IPv6
Date: Thu, 19 Mar 2015 16:47:58 -0300
Message-ID: <1426794478-5469-1-git-send-email-marcelo.leitner@gmail.com>
References: <20150319.150433.850095478975909930.davem@davemloft.net>
Cc: tipc-discussion@lists.sourceforge.net, erik.hugne@ericsson.com
To: richard.alpe@ericsson.com, jon.maloy@ericsson.com,
	ying.xue@windriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44326 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750896AbbCSTsq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2015 15:48:46 -0400
In-Reply-To: <20150319.150433.850095478975909930.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can't directly call ipv6_sock_mc_join() but should use the stub
instead and protect it around IS_ENABLED.

Fixes: d0f91938bede ("tipc: add ip/udp media type")
Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---

Notes:
    The BUG_ON I had placed is completelly unnecessary:
    - with IPV6=n, the code it was trying to protect won't exist
    - if the module load fails, the socket creation a bit above
      enable_mcast() call will return an error and it will bail out
      before reaching that code.
    And thus, just removed in this v2.

 net/tipc/udp_media.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
index 04836dd70c2bb79906307ec40e0cbd7b2589978e..ac89101e5d1b62165cbdb070d9f4bebe287fc583 100644
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
-- 
2.1.0
