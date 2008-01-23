From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 10/12 net-2.6.25] [NETNS]: Correct namespace for connect-time routing.
Date: Wed, 23 Jan 2008 10:46:25 +0300
Message-ID: <1201074387-7366-1-git-send-email-den@openvz.org>
References: <479612BE.8030409@openvz.org>
Cc: netdev@vger.kernel.org, devel@openvz.org,
	containers@lists.osdl.org, "Denis V. Lunev" <den@openvz.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from swsoft-msk-nat.sw.ru ([195.214.232.10]:59128 "EHLO iris.sw.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753571AbYAWHq2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2008 02:46:28 -0500
In-Reply-To: <479612BE.8030409@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ip_route_connect and ip_route_newports are a part of routing API presented to
the socket layer. The namespace is available inside them through a socket.

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 include/net/route.h |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/include/net/route.h b/include/net/route.h
index d9b876a..1985d82 100644
--- a/include/net/route.h
+++ b/include/net/route.h
@@ -33,6 +33,7 @@
 #include <linux/ip.h>
 #include <linux/cache.h>
 #include <linux/security.h>
+#include <net/sock.h>
 
 #ifndef __KERNEL__
 #warning This file is not supposed to be used outside of kernel.
@@ -157,8 +158,9 @@ static inline int ip_route_connect(struct rtable **rp, __be32 dst,
 					 .dport = dport } } };
 
 	int err;
+	struct net *net = sk->sk_net;
 	if (!dst || !src) {
-		err = __ip_route_output_key(&init_net, rp, &fl);
+		err = __ip_route_output_key(net, rp, &fl);
 		if (err)
 			return err;
 		fl.fl4_dst = (*rp)->rt_dst;
@@ -167,7 +169,7 @@ static inline int ip_route_connect(struct rtable **rp, __be32 dst,
 		*rp = NULL;
 	}
 	security_sk_classify_flow(sk, &fl);
-	return ip_route_output_flow(&init_net, rp, &fl, sk, flags);
+	return ip_route_output_flow(net, rp, &fl, sk, flags);
 }
 
 static inline int ip_route_newports(struct rtable **rp, u8 protocol,
@@ -184,7 +186,7 @@ static inline int ip_route_newports(struct rtable **rp, u8 protocol,
 		ip_rt_put(*rp);
 		*rp = NULL;
 		security_sk_classify_flow(sk, &fl);
-		return ip_route_output_flow(&init_net, rp, &fl, sk, 0);
+		return ip_route_output_flow(sk->sk_net, rp, &fl, sk, 0);
 	}
 	return 0;
 }
-- 
1.5.3.rc5

