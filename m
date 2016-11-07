From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 01/13] net/sched: act_tunnel_key: add helper inlines to access tcf_tunnel_key
Date: Mon,  7 Nov 2016 15:14:36 +0200
Message-ID: <1478524488-1377-2-git-send-email-saeedm@mellanox.com>
References: <1478524488-1377-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:39580 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753428AbcKGNPH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 08:15:07 -0500
In-Reply-To: <1478524488-1377-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

Needed for drivers to pick the relevant action when offloading tunnel
key act.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 include/net/tc_act/tc_tunnel_key.h | 37 +++++++++++++++++++++++++++++++++++++
 net/sched/act_tunnel_key.c         |  1 -
 2 files changed, 37 insertions(+), 1 deletion(-)

diff --git a/include/net/tc_act/tc_tunnel_key.h b/include/net/tc_act/tc_tunnel_key.h
index 253f8da..efef0b4 100644
--- a/include/net/tc_act/tc_tunnel_key.h
+++ b/include/net/tc_act/tc_tunnel_key.h
@@ -12,6 +12,8 @@
 #define __NET_TC_TUNNEL_KEY_H
 
 #include <net/act_api.h>
+#include <linux/tc_act/tc_tunnel_key.h>
+#include <net/dst_metadata.h>
 
 struct tcf_tunnel_key_params {
 	struct rcu_head		rcu;
@@ -27,4 +29,39 @@ struct tcf_tunnel_key {
 
 #define to_tunnel_key(a) ((struct tcf_tunnel_key *)a)
 
+static inline bool is_tcf_tunnel_set(const struct tc_action *a)
+{
+#ifdef CONFIG_NET_CLS_ACT
+	struct tcf_tunnel_key *t = to_tunnel_key(a);
+	struct tcf_tunnel_key_params *params = rtnl_dereference(t->params);
+
+	if (a->ops && a->ops->type == TCA_ACT_TUNNEL_KEY)
+		return params->tcft_action == TCA_TUNNEL_KEY_ACT_SET;
+#endif
+	return false;
+}
+
+static inline bool is_tcf_tunnel_release(const struct tc_action *a)
+{
+#ifdef CONFIG_NET_CLS_ACT
+	struct tcf_tunnel_key *t = to_tunnel_key(a);
+	struct tcf_tunnel_key_params *params = rtnl_dereference(t->params);
+
+	if (a->ops && a->ops->type == TCA_ACT_TUNNEL_KEY)
+		return params->tcft_action == TCA_TUNNEL_KEY_ACT_RELEASE;
+#endif
+	return false;
+}
+
+static inline struct ip_tunnel_info *tcf_tunnel_info(const struct tc_action *a)
+{
+#ifdef CONFIG_NET_CLS_ACT
+	struct tcf_tunnel_key *t = to_tunnel_key(a);
+	struct tcf_tunnel_key_params *params = rtnl_dereference(t->params);
+
+	return &params->tcft_enc_metadata->u.tun_info;
+#else
+	return NULL;
+#endif
+}
 #endif /* __NET_TC_TUNNEL_KEY_H */
diff --git a/net/sched/act_tunnel_key.c b/net/sched/act_tunnel_key.c
index af47bdf..cab1fd5 100644
--- a/net/sched/act_tunnel_key.c
+++ b/net/sched/act_tunnel_key.c
@@ -16,7 +16,6 @@
 #include <net/netlink.h>
 #include <net/pkt_sched.h>
 #include <net/dst.h>
-#include <net/dst_metadata.h>
 
 #include <linux/tc_act/tc_tunnel_key.h>
 #include <net/tc_act/tc_tunnel_key.h>
-- 
2.7.4
