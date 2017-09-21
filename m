From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/12] net: ipmr: Add MFC offload indication
Date: Thu, 21 Sep 2017 08:43:31 +0200
Message-ID: <20170921064338.1282-6-jiri@resnulli.us>
References: <20170921064338.1282-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33381 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751732AbdIUGno (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 02:43:44 -0400
Received: by mail-wm0-f68.google.com with SMTP id m127so4299854wmm.0
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 23:43:44 -0700 (PDT)
In-Reply-To: <20170921064338.1282-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Allow drivers, registered to the fib notification chain indicate whether a
multicast MFC route is offloaded or not, similarly to unicast routes. The
indication of whether a route is offloaded is done using the mfc_flags
field on an mfc_cache struct, and the information is sent to the userspace
via the RTNetlink interface only.

Currently, MFC routes are either offloaded or not, thus there is no need to
add per-VIF offload indication.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/linux/mroute.h | 1 +
 net/ipv4/ipmr.c        | 3 +++
 2 files changed, 4 insertions(+)

diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index ba5a976..9b64587 100644
--- a/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -93,6 +93,7 @@ struct mr_table {
  */
 enum {
 	MFC_STATIC = BIT(0),
+	MFC_OFFLOAD = BIT(1),
 };
 
 struct mfc_cache_cmp_arg {
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 7891d95..6804885 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -2268,6 +2268,9 @@ static int __ipmr_fill_mroute(struct mr_table *mrt, struct sk_buff *skb,
 	    nla_put_u32(skb, RTA_IIF, mrt->vif_table[c->mfc_parent].dev->ifindex) < 0)
 		return -EMSGSIZE;
 
+	if (c->mfc_flags & MFC_OFFLOAD)
+		rtm->rtm_flags |= RTNH_F_OFFLOAD;
+
 	if (!(mp_attr = nla_nest_start(skb, RTA_MULTIPATH)))
 		return -EMSGSIZE;
 
-- 
2.9.5
