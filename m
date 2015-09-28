From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 06/11] net: Replace calls to vrf_dev_get_rth
Date: Mon, 28 Sep 2015 10:16:56 -0700
Message-ID: <1443460621-24855-7-git-send-email-dsa@cumulusnetworks.com>
References: <1443460621-24855-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33396 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934419AbbI1RRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 13:17:20 -0400
Received: by pacex6 with SMTP id ex6so179729033pac.0
        for <netdev@vger.kernel.org>; Mon, 28 Sep 2015 10:17:19 -0700 (PDT)
In-Reply-To: <1443460621-24855-1-git-send-email-dsa@cumulusnetworks.com>
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
index cf790aeb7f74..240f5ea02618 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -112,7 +112,6 @@
 #endif
 #include <net/secure_seq.h>
 #include <net/ip_tunnels.h>
-#include <net/vrf.h>
 #include <net/l3mdev.h>
 
 #define RT_FL_TOS(oldflp4) \
@@ -2128,11 +2127,10 @@ struct rtable *__ip_route_output_key(struct net *net, struct flowi4 *fl4)
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
