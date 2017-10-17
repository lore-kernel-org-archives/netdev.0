From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 11/20] bnxt: Convert ndo_setup_tc offloads to block callbacks
Date: Tue, 17 Oct 2017 22:06:06 +0200
Message-ID: <20171017200615.4530-12-jiri@resnulli.us>
References: <20171017200615.4530-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, alexander.h.duyck@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:43794 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1764053AbdJQUG0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 16:06:26 -0400
Received: by mail-wr0-f193.google.com with SMTP id p46so2908176wrb.0
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 13:06:26 -0700 (PDT)
In-Reply-To: <20171017200615.4530-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Benefit from the newly introduced block callback infrastructure and
convert ndo_setup_tc calls for flower offloads to block callbacks.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c     | 37 +++++++++++++++++++----
 drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c  |  3 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c | 43 +++++++++++++++++++++++++--
 3 files changed, 73 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 5ba4993..4dde2b8 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -7295,15 +7295,40 @@ int bnxt_setup_mq_tc(struct net_device *dev, u8 tc)
 	return 0;
 }
 
-static int bnxt_setup_flower(struct net_device *dev,
-			     struct tc_cls_flower_offload *cls_flower)
+static int bnxt_setup_tc_block_cb(enum tc_setup_type type, void *type_data,
+				  void *cb_priv)
 {
-	struct bnxt *bp = netdev_priv(dev);
+	struct bnxt *bp = cb_priv;
 
 	if (BNXT_VF(bp))
 		return -EOPNOTSUPP;
 
-	return bnxt_tc_setup_flower(bp, bp->pf.fw_fid, cls_flower);
+	switch (type) {
+	case TC_SETUP_CLSFLOWER:
+		return bnxt_tc_setup_flower(bp, bp->pf.fw_fid, type_data);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static int bnxt_setup_tc_block(struct net_device *dev,
+			       struct tc_block_offload *f)
+{
+	struct bnxt *bp = netdev_priv(dev);
+
+	if (f->binder_type != TCF_BLOCK_BINDER_TYPE_CLSACT_INGRESS)
+		return -EOPNOTSUPP;
+
+	switch (f->command) {
+	case TC_BLOCK_BIND:
+		return tcf_block_cb_register(f->block, bnxt_setup_tc_block_cb,
+					     bp, bp);
+	case TC_BLOCK_UNBIND:
+		tcf_block_cb_unregister(f->block, bnxt_setup_tc_block_cb, bp);
+		return 0;
+	default:
+		return -EOPNOTSUPP;
+	}
 }
 
 static int bnxt_setup_tc(struct net_device *dev, enum tc_setup_type type,
@@ -7311,7 +7336,9 @@ static int bnxt_setup_tc(struct net_device *dev, enum tc_setup_type type,
 {
 	switch (type) {
 	case TC_SETUP_CLSFLOWER:
-		return bnxt_setup_flower(dev, type_data);
+		return 0; /* will be removed after conversion from ndo */
+	case TC_SETUP_BLOCK:
+		return bnxt_setup_tc_block(dev, type_data);
 	case TC_SETUP_MQPRIO: {
 		struct tc_mqprio_qopt *mqprio = type_data;
 
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c
index 4730c04..a9cb653 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_tc.c
@@ -748,8 +748,7 @@ int bnxt_tc_setup_flower(struct bnxt *bp, u16 src_fid,
 {
 	int rc = 0;
 
-	if (!is_classid_clsact_ingress(cls_flower->common.classid) ||
-	    cls_flower->common.chain_index)
+	if (cls_flower->common.chain_index)
 		return -EOPNOTSUPP;
 
 	switch (cls_flower->command) {
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
index e75db04..cc278d7 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_vfr.c
@@ -115,10 +115,11 @@ bnxt_vf_rep_get_stats64(struct net_device *dev,
 	stats->tx_bytes = vf_rep->tx_stats.bytes;
 }
 
-static int bnxt_vf_rep_setup_tc(struct net_device *dev, enum tc_setup_type type,
-				void *type_data)
+static int bnxt_vf_rep_setup_tc_block_cb(enum tc_setup_type type,
+					 void *type_data,
+					 void *cb_priv)
 {
-	struct bnxt_vf_rep *vf_rep = netdev_priv(dev);
+	struct bnxt_vf_rep *vf_rep = cb_priv;
 	struct bnxt *bp = vf_rep->bp;
 	int vf_fid = bp->pf.vf[vf_rep->vf_idx].fw_fid;
 
@@ -130,6 +131,42 @@ static int bnxt_vf_rep_setup_tc(struct net_device *dev, enum tc_setup_type type,
 	}
 }
 
+static int bnxt_vf_rep_setup_tc_block(struct net_device *dev,
+				      struct tc_block_offload *f)
+{
+	struct bnxt_vf_rep *vf_rep = netdev_priv(dev);
+
+	if (f->binder_type != TCF_BLOCK_BINDER_TYPE_CLSACT_INGRESS)
+		return -EOPNOTSUPP;
+
+	switch (f->command) {
+	case TC_BLOCK_BIND:
+		return tcf_block_cb_register(f->block,
+					     bnxt_vf_rep_setup_tc_block_cb,
+					     vf_rep, vf_rep);
+		return 0;
+	case TC_BLOCK_UNBIND:
+		tcf_block_cb_unregister(f->block,
+					bnxt_vf_rep_setup_tc_block_cb, vf_rep);
+		return 0;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static int bnxt_vf_rep_setup_tc(struct net_device *dev, enum tc_setup_type type,
+				void *type_data)
+{
+	switch (type) {
+	case TC_SETUP_CLSFLOWER:
+		return 0; /* will be removed after conversion from ndo */
+	case TC_SETUP_BLOCK:
+		return bnxt_vf_rep_setup_tc_block(dev, type_data);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
 struct net_device *bnxt_get_vf_rep(struct bnxt *bp, u16 cfa_code)
 {
 	u16 vf_idx;
-- 
2.9.5
