From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 06/11] net: Replace calls to vrf_dev_get_rth
Date: Thu, 24 Sep 2015 18:21:02 -0600
Message-ID: <1443140467-69297-7-git-send-email-dsa@cumulusnetworks.com>
References: <1443140467-69297-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36527 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753295AbbIYAVX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 20:21:23 -0400
Received: by pacgz1 with SMTP id gz1so5000448pac.3
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 17:21:23 -0700 (PDT)
In-Reply-To: <1443140467-69297-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace calls to vrf_dev_get_rth with l3mdev_get_rtable.
The check on the flow flags is handled in the l3mdev operation.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/vrf.h | 22 ----------------------
 net/ipv4/route.c  |  8 +++-----
 2 files changed, 3 insertions(+), 27 deletions(-)

diff --git a/include/net/vrf.h b/include/net/vrf.h
index b05b96646e2a..5bba1535ba73 100644
--- a/include/net/vrf.h
+++ b/include/net/vrf.h
@@ -32,26 +32,4 @@ struct net_vrf {
 	u32			tb_id;
 };
 
-
-#if IS_ENABLED(CONFIG_NET_VRF)
-/* caller has already checked netif_is_l3_master(dev) */
-static inline struct rtable *vrf_dev_get_rth(const struct net_device *dev)
-{
-	struct rtable *rth = ERR_PTR(-ENETUNREACH);
-	struct net_vrf *vrf = netdev_priv(dev);
-
-	if (vrf) {
-		rth = vrf->rth;
-		atomic_inc(&rth->dst.__refcnt);
-	}
-	return rth;
-}
-
-#else
-static inline struct rtable *vrf_dev_get_rth(const struct net_device *dev)
-{
-	return ERR_PTR(-ENETUNREACH);
-}
-#endif
-
 #endif /* __LINUX_NET_VRF_H */
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 90cf915c36d9..c858fdb8c2d5 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -112,7 +112,6 @@
 #endif
 #include <net/secure_seq.h>
 #include <net/ip_tunnels.h>
-#include <net/vrf.h>
 #include <net/l3mdev.h>
 
 #define RT_FL_TOS(oldflp4) \
@@ -2127,11 +2126,10 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
 				fl4->saddr = inet_select_addr(dev_out, 0,
 							      RT_SCOPE_HOST);
 		}
-		if (netif_is_l3_master(dev_out) &&
-		    !(fl4->flowi4_flags & FLOWI_FLAG_VRFSRC)) {
-			rth = vrf_dev_get_rth(dev_out);
+
+		rth = l3mdev_get_rtable(dev_out, fl4);
+		if (rth)
 			goto out;
-		}
 	}
 
 	if (!fl4->daddr) {
-- 
2.3.8 (Apple Git-58)
