From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/5] mlxsw: spectrum_acl: Provide helper to lookup ruleset
Date: Wed, 23 Aug 2017 10:08:21 +0200
Message-ID: <20170823080822.14898-4-jiri@resnulli.us>
References: <20170823080652.14847-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35753 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753386AbdHWII3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 04:08:29 -0400
Received: by mail-wr0-f196.google.com with SMTP id p8so602204wrf.2
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 01:08:29 -0700 (PDT)
In-Reply-To: <20170823080652.14847-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

We need to lookup ruleset in order to offload goto_chain termination
action. This patch adds it.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  4 ++
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c | 45 ++++++++++++++++++----
 2 files changed, 41 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 1866f69..f8c7f7e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -441,6 +441,10 @@ struct mlxsw_sp_acl_ruleset;
 /* spectrum_acl.c */
 struct mlxsw_afk *mlxsw_sp_acl_afk(struct mlxsw_sp_acl *acl);
 struct mlxsw_sp_acl_ruleset *
+mlxsw_sp_acl_ruleset_lookup(struct mlxsw_sp *mlxsw_sp, struct net_device *dev,
+			    bool ingress, u32 chain_index,
+			    enum mlxsw_sp_acl_profile profile);
+struct mlxsw_sp_acl_ruleset *
 mlxsw_sp_acl_ruleset_get(struct mlxsw_sp *mlxsw_sp, struct net_device *dev,
 			 bool ingress, u32 chain_index,
 			 enum mlxsw_sp_acl_profile profile);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
index ef86f04..4b2455e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c
@@ -221,6 +221,41 @@ static void mlxsw_sp_acl_ruleset_ref_dec(struct mlxsw_sp *mlxsw_sp,
 	mlxsw_sp_acl_ruleset_destroy(mlxsw_sp, ruleset);
 }
 
+static struct mlxsw_sp_acl_ruleset *
+__mlxsw_sp_acl_ruleset_lookup(struct mlxsw_sp_acl *acl, struct net_device *dev,
+			      bool ingress, u32 chain_index,
+			      const struct mlxsw_sp_acl_profile_ops *ops)
+{
+	struct mlxsw_sp_acl_ruleset_ht_key ht_key;
+
+	memset(&ht_key, 0, sizeof(ht_key));
+	ht_key.dev = dev;
+	ht_key.ingress = ingress;
+	ht_key.chain_index = chain_index;
+	ht_key.ops = ops;
+	return rhashtable_lookup_fast(&acl->ruleset_ht, &ht_key,
+				      mlxsw_sp_acl_ruleset_ht_params);
+}
+
+struct mlxsw_sp_acl_ruleset *
+mlxsw_sp_acl_ruleset_lookup(struct mlxsw_sp *mlxsw_sp, struct net_device *dev,
+			    bool ingress, u32 chain_index,
+			    enum mlxsw_sp_acl_profile profile)
+{
+	const struct mlxsw_sp_acl_profile_ops *ops;
+	struct mlxsw_sp_acl *acl = mlxsw_sp->acl;
+	struct mlxsw_sp_acl_ruleset *ruleset;
+
+	ops = acl->ops->profile_ops(mlxsw_sp, profile);
+	if (!ops)
+		return ERR_PTR(-EINVAL);
+	ruleset = __mlxsw_sp_acl_ruleset_lookup(acl, dev, ingress,
+						chain_index, ops);
+	if (!ruleset)
+		return ERR_PTR(-ENOENT);
+	return ruleset;
+}
+
 struct mlxsw_sp_acl_ruleset *
 mlxsw_sp_acl_ruleset_get(struct mlxsw_sp *mlxsw_sp, struct net_device *dev,
 			 bool ingress, u32 chain_index,
@@ -228,7 +263,6 @@ mlxsw_sp_acl_ruleset_get(struct mlxsw_sp *mlxsw_sp, struct net_device *dev,
 {
 	const struct mlxsw_sp_acl_profile_ops *ops;
 	struct mlxsw_sp_acl *acl = mlxsw_sp->acl;
-	struct mlxsw_sp_acl_ruleset_ht_key ht_key;
 	struct mlxsw_sp_acl_ruleset *ruleset;
 	int err;
 
@@ -236,13 +270,8 @@ mlxsw_sp_acl_ruleset_get(struct mlxsw_sp *mlxsw_sp, struct net_device *dev,
 	if (!ops)
 		return ERR_PTR(-EINVAL);
 
-	memset(&ht_key, 0, sizeof(ht_key));
-	ht_key.dev = dev;
-	ht_key.ingress = ingress;
-	ht_key.chain_index = chain_index;
-	ht_key.ops = ops;
-	ruleset = rhashtable_lookup_fast(&acl->ruleset_ht, &ht_key,
-					 mlxsw_sp_acl_ruleset_ht_params);
+	ruleset = __mlxsw_sp_acl_ruleset_lookup(acl, dev, ingress,
+						chain_index, ops);
 	if (ruleset) {
 		mlxsw_sp_acl_ruleset_ref_inc(ruleset);
 		return ruleset;
-- 
2.9.3
