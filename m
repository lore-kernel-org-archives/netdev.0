From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 04/16] cxgb4: push cls_u32 setup_tc processing into a separate function
Date: Mon,  7 Aug 2017 10:15:20 +0200
Message-ID: <20170807081532.32760-5-jiri@resnulli.us>
References: <20170807081532.32760-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        dirk.vandermerwe@netronome.com, alexander.h.duyck@intel.com,
        amritha.nambiar@intel.com, oss-drivers@netronome.com,
        yisen.zhuang@huawei.com, salil.mehta@huawei.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:38392 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752513AbdHGIPl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 04:15:41 -0400
Received: by mail-wm0-f68.google.com with SMTP id y206so121153wmd.5
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 01:15:41 -0700 (PDT)
In-Reply-To: <20170807081532.32760-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Let cxgb_setup_tc be a splitter for specific setup_tc types and push out
cls_u32 specific code into a separate function.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 42 +++++++++++++++----------
 1 file changed, 26 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 89d2b0c..6512290 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2889,6 +2889,26 @@ static int cxgb_set_tx_maxrate(struct net_device *dev, int index, u32 rate)
 	return err;
 }
 
+static int cxgb_setup_tc_cls_u32(struct net_device *dev,
+				 enum tc_setup_type type,
+				 u32 handle, u32 chain_index, __be16 proto,
+				 struct tc_cls_u32_offload *cls_u32)
+{
+	if (TC_H_MAJ(handle) != TC_H_MAJ(TC_H_INGRESS) ||
+	    chain_index)
+		return -EOPNOTSUPP;
+
+	switch (cls_u32->command) {
+	case TC_CLSU32_NEW_KNODE:
+	case TC_CLSU32_REPLACE_KNODE:
+		return cxgb4_config_knode(dev, proto, cls_u32);
+	case TC_CLSU32_DELETE_KNODE:
+		return cxgb4_delete_knode(dev, proto, cls_u32);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
 static int cxgb_setup_tc(struct net_device *dev, enum tc_setup_type type,
 			 u32 handle, u32 chain_index, __be16 proto,
 			 struct tc_to_netdev *tc)
@@ -2896,9 +2916,6 @@ static int cxgb_setup_tc(struct net_device *dev, enum tc_setup_type type,
 	struct port_info *pi = netdev2pinfo(dev);
 	struct adapter *adap = netdev2adap(dev);
 
-	if (chain_index)
-		return -EOPNOTSUPP;
-
 	if (!(adap->flags & FULL_INIT_DONE)) {
 		dev_err(adap->pdev_dev,
 			"Failed to setup tc on port %d. Link Down?\n",
@@ -2906,20 +2923,13 @@ static int cxgb_setup_tc(struct net_device *dev, enum tc_setup_type type,
 		return -EINVAL;
 	}
 
-	if (TC_H_MAJ(handle) == TC_H_MAJ(TC_H_INGRESS) &&
-	    type == TC_SETUP_CLSU32) {
-		switch (tc->cls_u32->command) {
-		case TC_CLSU32_NEW_KNODE:
-		case TC_CLSU32_REPLACE_KNODE:
-			return cxgb4_config_knode(dev, proto, tc->cls_u32);
-		case TC_CLSU32_DELETE_KNODE:
-			return cxgb4_delete_knode(dev, proto, tc->cls_u32);
-		default:
-			return -EOPNOTSUPP;
-		}
+	switch (type) {
+	case TC_SETUP_CLSU32:
+		return cxgb_setup_tc_cls_u32(dev, type, handle, chain_index,
+					     proto, tc->cls_u32);
+	default:
+		return -EOPNOTSUPP;
 	}
-
-	return -EOPNOTSUPP;
 }
 
 static netdev_features_t cxgb_fix_features(struct net_device *dev,
-- 
2.9.3
