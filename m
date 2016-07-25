From: Ido Schimmel <idosch@mellanox.com>
Subject: [PATCH net-next] mlxsw: spectrum: Fix compilation error when CLS_ACT isn't set
Date: Mon, 25 Jul 2016 13:12:33 +0300
Message-ID: <1469441553-6154-1-git-send-email-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <jiri@mellanox.com>,
	<eladr@mellanox.com>, <yotamg@mellanox.com>, <nogahf@mellanox.com>,
	<ogerlitz@mellanox.com>, "Ido Schimmel" <idosch@mellanox.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0078.outbound.protection.outlook.com ([104.47.2.78]:34996
	"EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751006AbcGYKbX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jul 2016 06:31:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When CONFIG_NET_CLS_ACT isn't set 'struct tcf_exts' has no member named
'actions' and we therefore must not access it. Otherwise compilation
fails.

Fix this by introducing a new macro similar to tc_no_actions(), which
always returns 'false' if CONFIG_NET_CLS_ACT isn't set.

Fixes: 763b4b70afcd ("mlxsw: spectrum: Add support in matchall mirror TC offloading")
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
---
I know the merge window is already open, but I thought you might want to take
this as well, as it fixes a compilation error.
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 11 +++++------
 include/net/act_api.h                          |  4 ++++
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 552636b..c3e6150 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1148,23 +1148,22 @@ static int mlxsw_sp_port_add_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
 					  struct tc_cls_matchall_offload *cls,
 					  bool ingress)
 {
-	struct tcf_exts *exts = cls->exts;
 	const struct tc_action *a;
 	int err;
 
-	if (!list_is_singular(&exts->actions)) {
+	if (!tc_single_action(cls->exts)) {
 		netdev_err(mlxsw_sp_port->dev, "only singular actions are supported\n");
 		return -ENOTSUPP;
 	}
 
-	a = list_first_entry(&exts->actions, struct tc_action, list);
-	if (is_tcf_mirred_mirror(a) && protocol == htons(ETH_P_ALL)) {
+	tc_for_each_action(a, cls->exts) {
+		if (!is_tcf_mirred_mirror(a) || protocol != htons(ETH_P_ALL))
+			return -ENOTSUPP;
+
 		err = mlxsw_sp_port_add_cls_matchall_mirror(mlxsw_sp_port, cls,
 							    a, ingress);
 		if (err)
 			return err;
-	} else {
-		return -ENOTSUPP;
 	}
 
 	return 0;
diff --git a/include/net/act_api.h b/include/net/act_api.h
index fb82b5b..0bb2106 100644
--- a/include/net/act_api.h
+++ b/include/net/act_api.h
@@ -192,6 +192,9 @@ int tcf_action_copy_stats(struct sk_buff *, struct tc_action *, int);
 #define tc_for_each_action(_a, _exts) \
 	list_for_each_entry(a, &(_exts)->actions, list)
 
+#define tc_single_action(_exts) \
+	(list_is_singular(&(_exts)->actions))
+
 static inline void tcf_action_stats_update(struct tc_action *a, u64 bytes,
 					   u64 packets, u64 lastuse)
 {
@@ -205,6 +208,7 @@ static inline void tcf_action_stats_update(struct tc_action *a, u64 bytes,
 
 #define tc_no_actions(_exts) true
 #define tc_for_each_action(_a, _exts) while ((void)(_a), 0)
+#define tc_single_action(_exts) false
 #define tcf_action_stats_update(a, bytes, packets, lastuse)
 
 #endif /* CONFIG_NET_CLS_ACT */
-- 
2.8.2
