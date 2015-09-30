From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 06/11] net: Replace calls to vrf_dev_get_rth
Date: Tue, 29 Sep 2015 20:07:15 -0700
Message-ID: <1443582438-23823-7-git-send-email-dsa@cumulusnetworks.com>
References: <1443582438-23823-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dsahern@gmail.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34352 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752618AbbI3DHe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 23:07:34 -0400
Received: by padhy16 with SMTP id hy16so24930972pad.1
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 20:07:34 -0700 (PDT)
In-Reply-To: <1443582438-23823-1-git-send-email-dsa@cumulusnetworks.com>
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
index ba466667c45c..1441de1550e6 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -112,7 +112,6 @@
 #endif
 #include <net/secure_seq.h>
 #include <net/ip_tunnels.h>
-#include <net/vrf.h>
 #include <net/l3mdev.h>
 
 #define RT_FL_TOS(oldflp4) \
@@ -2125,11 +2124,10 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
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
1.9.1
