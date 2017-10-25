From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/4] net: sched: move the can_offload check from binding phase to rule insertion phase
Date: Wed, 25 Oct 2017 16:34:58 +0200
Message-ID: <20171025143500.28973-3-jiri@resnulli.us>
References: <20171025143500.28973-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, simon.horman@netronome.com,
        pieter.jansenvanvuuren@netronome.com, john.hurley@netronome.com,
        alexander.h.duyck@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:54134 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932201AbdJYOfE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 10:35:04 -0400
Received: by mail-wr0-f195.google.com with SMTP id u40so188761wrf.10
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 07:35:03 -0700 (PDT)
In-Reply-To: <20171025143500.28973-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This restores the original behaviour before the block callbacks were
introduced. Allow the drivers to do binding of block always, no matter
if the NETIF_F_HW_TC feature is on or off. Move the check to the block
callback which is called for rule insertion.

Reported-by: Alexander Duyck <alexander.duyck@gmail.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c           | 2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c       | 3 +++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c     | 3 +++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c       | 3 +++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c   | 3 +++
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c    | 3 +++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c      | 3 +++
 drivers/net/ethernet/netronome/nfp/bpf/main.c       | 3 +++
 drivers/net/ethernet/netronome/nfp/flower/offload.c | 3 +++
 net/dsa/slave.c                                     | 3 +++
 net/sched/cls_api.c                                 | 2 +-
 11 files changed, 29 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 24d55724..e193232 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -7325,7 +7325,7 @@ static int bnxt_setup_tc_block_cb(enum tc_setup_type type, void *type_data,
 {
 	struct bnxt *bp = cb_priv;
 
-	if (BNXT_VF(bp))
+	if (!tc_can_offload(bp->dev) || BNXT_VF(bp))
 		return -EOPNOTSUPP;
 
 	switch (type) {
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
index 4ae9359..2fa614f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
@@ -124,6 +124,9 @@ static int bnxt_vf_rep_setup_tc_block_cb(enum tc_setup_type type,
 	struct bnxt *bp = vf_rep->bp;
 	int vf_fid = bp->pf.vf[vf_rep->vf_idx].fw_fid;
 
+	if (!tc_can_offload(bp->dev))
+		return -EOPNOTSUPP;
+
 	switch (type) {
 	case TC_SETUP_CLSFLOWER:
 		return bnxt_tc_setup_flower(bp, vf_fid, type_data);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index e16078d..b07eecf 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2935,6 +2935,9 @@ static int cxgb_setup_tc_block_cb(enum tc_setup_type type, void *type_data,
 		return -EINVAL;
 	}
 
+	if (!tc_can_offload(dev))
+		return -EOPNOTSUPP;
+
 	switch (type) {
 	case TC_SETUP_CLSU32:
 		return cxgb_setup_tc_cls_u32(dev, type_data);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 7f503d3..3520f28 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9392,6 +9392,9 @@ static int ixgbe_setup_tc_block_cb(enum tc_setup_type type, void *type_data,
 {
 	struct ixgbe_adapter *adapter = cb_priv;
 
+	if (!tc_can_offload(adapter->netdev))
+		return -EOPNOTSUPP;
+
 	switch (type) {
 	case TC_SETUP_CLSU32:
 		return ixgbe_setup_tc_cls_u32(adapter, type_data);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 560b208..28ae00b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3106,6 +3106,9 @@ int mlx5e_setup_tc_block_cb(enum tc_setup_type type, void *type_data,
 {
 	struct mlx5e_priv *priv = cb_priv;
 
+	if (!tc_can_offload(priv->netdev))
+		return -EOPNOTSUPP;
+
 	switch (type) {
 	case TC_SETUP_CLSFLOWER:
 		return mlx5e_setup_tc_cls_flower(priv, type_data);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 0edb706..2c43606 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -682,6 +682,9 @@ static int mlx5e_rep_setup_tc_cb(enum tc_setup_type type, void *type_data,
 {
 	struct mlx5e_priv *priv = cb_priv;
 
+	if (!tc_can_offload(priv->netdev))
+		return -EOPNOTSUPP;
+
 	switch (type) {
 	case TC_SETUP_CLSFLOWER:
 		return mlx5e_rep_setup_tc_cls_flower(priv, type_data);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 8f8db6c..71aa603 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1738,6 +1738,9 @@ static int mlxsw_sp_setup_tc_block_cb(enum tc_setup_type type, void *type_data,
 {
 	struct mlxsw_sp_port *mlxsw_sp_port = cb_priv;
 
+	if (!tc_can_offload(mlxsw_sp_port->dev))
+		return -EOPNOTSUPP;
+
 	switch (type) {
 	case TC_SETUP_CLSMATCHALL:
 		return mlxsw_sp_setup_tc_cls_matchall(mlxsw_sp_port, type_data,
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.c b/drivers/net/ethernet/netronome/nfp/bpf/main.c
index fa0ac90..55fca38 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.c
@@ -120,6 +120,9 @@ static int nfp_bpf_setup_tc_block_cb(enum tc_setup_type type,
 	struct tc_cls_bpf_offload *cls_bpf = type_data;
 	struct nfp_net *nn = cb_priv;
 
+	if (!tc_can_offload(nn->dp.netdev))
+		return -EOPNOTSUPP;
+
 	switch (type) {
 	case TC_SETUP_CLSBPF:
 		if (!nfp_net_ebpf_capable(nn) ||
diff --git a/drivers/net/ethernet/netronome/nfp/flower/offload.c b/drivers/net/ethernet/netronome/nfp/flower/offload.c
index c47753f..7c6cab1 100644
--- a/drivers/net/ethernet/netronome/nfp/flower/offload.c
+++ b/drivers/net/ethernet/netronome/nfp/flower/offload.c
@@ -470,6 +470,9 @@ static int nfp_flower_setup_tc_block_cb(enum tc_setup_type type,
 {
 	struct nfp_net *nn = cb_priv;
 
+	if (!tc_can_offload(nn->dp.netdev))
+		return -EOPNOTSUPP;
+
 	switch (type) {
 	case TC_SETUP_CLSFLOWER:
 		return nfp_flower_repr_offload(nn->app, nn->port->netdev,
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index d0ae701..3481fd6 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -799,6 +799,9 @@ static int dsa_slave_setup_tc_block_cb(enum tc_setup_type type, void *type_data,
 {
 	struct net_device *dev = cb_priv;
 
+	if (!tc_can_offload(dev))
+		return -EOPNOTSUPP;
+
 	switch (type) {
 	case TC_SETUP_CLSMATCHALL:
 		return dsa_slave_setup_tc_cls_matchall(dev, type_data, ingress);
diff --git a/net/sched/cls_api.c b/net/sched/cls_api.c
index 0e96cda..0636c19 100644
--- a/net/sched/cls_api.c
+++ b/net/sched/cls_api.c
@@ -247,7 +247,7 @@ static void tcf_block_offload_cmd(struct tcf_block *block, struct Qdisc *q,
 	struct net_device *dev = q->dev_queue->dev;
 	struct tc_block_offload bo = {};
 
-	if (!tc_can_offload(dev))
+	if (!dev->netdev_ops->ndo_setup_tc)
 		return;
 	bo.command = command;
 	bo.binder_type = ei->binder_type;
-- 
2.9.5
