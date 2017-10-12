From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 23/34] cxgb4: Convert ndo_setup_tc offloads to block callbacks
Date: Thu, 12 Oct 2017 19:18:12 +0200
Message-ID: <20171012171823.1431-24-jiri@resnulli.us>
References: <20171012171823.1431-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        michael.chan@broadcom.com, ganeshgr@chelsio.com,
        jeffrey.t.kirsher@intel.com, saeedm@mellanox.com,
        matanb@mellanox.com, leonro@mellanox.com, idosch@mellanox.com,
        jakub.kicinski@netronome.com, ast@kernel.org, daniel@iogearbox.net,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        john.hurley@netronome.com, edumazet@google.com, dsahern@gmail.com,
        alexander.h.duyck@intel.com, john.fastabend@gmail.com,
        willemb@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:51990 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755086AbdJLRSr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:18:47 -0400
Received: by mail-wm0-f67.google.com with SMTP id f4so15296871wme.0
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:18:46 -0700 (PDT)
In-Reply-To: <20171012171823.1431-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Benefit from the newly introduced block callback infrastructure and
convert ndo_setup_tc calls for flower and u32 offloads to block callbacks.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 45 +++++++++++++++++++++----
 1 file changed, 39 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index fe4cbe2..1e27aca 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2883,8 +2883,7 @@ static int cxgb_set_tx_maxrate(struct net_device *dev, int index, u32 rate)
 static int cxgb_setup_tc_flower(struct net_device *dev,
 				struct tc_cls_flower_offload *cls_flower)
 {
-	if (!is_classid_clsact_ingress(cls_flower->common.classid) ||
-	    cls_flower->common.chain_index)
+	if (cls_flower->common.chain_index)
 		return -EOPNOTSUPP;
 
 	switch (cls_flower->command) {
@@ -2902,8 +2901,7 @@ static int cxgb_setup_tc_flower(struct net_device *dev,
 static int cxgb_setup_tc_cls_u32(struct net_device *dev,
 				 struct tc_cls_u32_offload *cls_u32)
 {
-	if (!is_classid_clsact_ingress(cls_u32->common.classid) ||
-	    cls_u32->common.chain_index)
+	if (cls_u32->common.chain_index)
 		return -EOPNOTSUPP;
 
 	switch (cls_u32->command) {
@@ -2917,9 +2915,10 @@ static int cxgb_setup_tc_cls_u32(struct net_device *dev,
 	}
 }
 
-static int cxgb_setup_tc(struct net_device *dev, enum tc_setup_type type,
-			 void *type_data)
+static int cxgb_setup_tc_block_cb(enum tc_setup_type type, void *type_data,
+				  void *cb_priv)
 {
+	struct net_device *dev = cb_priv;
 	struct port_info *pi = netdev2pinfo(dev);
 	struct adapter *adap = netdev2adap(dev);
 
@@ -2940,6 +2939,40 @@ static int cxgb_setup_tc(struct net_device *dev, enum tc_setup_type type,
 	}
 }
 
+static int cxgb_setup_tc_block(struct net_device *dev,
+			       struct tc_block_offload *f)
+{
+	struct port_info *pi = netdev2pinfo(dev);
+
+	if (f->binder_type != TCF_BLOCK_BINDER_TYPE_CLSACT_INGRESS)
+		return -EOPNOTSUPP;
+
+	switch (f->command) {
+	case TC_BLOCK_BIND:
+		return tcf_block_cb_register(f->block, cxgb_setup_tc_block_cb,
+					     pi, dev);
+	case TC_BLOCK_UNBIND:
+		tcf_block_cb_unregister(f->block, cxgb_setup_tc_block_cb, pi);
+		return 0;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static int cxgb_setup_tc(struct net_device *dev, enum tc_setup_type type,
+			 void *type_data)
+{
+	switch (type) {
+	case TC_SETUP_CLSU32:
+	case TC_SETUP_CLSFLOWER:
+		return 0; /* will be removed after conversion from ndo */
+	case TC_SETUP_BLOCK:
+		return cxgb_setup_tc_block(dev, type_data);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
 static netdev_features_t cxgb_fix_features(struct net_device *dev,
 					   netdev_features_t features)
 {
-- 
2.9.5
