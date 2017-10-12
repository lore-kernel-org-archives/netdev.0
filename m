From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 24/34] ixgbe: Convert ndo_setup_tc offloads to block callbacks
Date: Thu, 12 Oct 2017 19:18:13 +0200
Message-ID: <20171012171823.1431-25-jiri@resnulli.us>
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
Received: from mail-wm0-f65.google.com ([74.125.82.65]:46124 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754373AbdJLRSr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:18:47 -0400
Received: by mail-wm0-f65.google.com with SMTP id m72so15071364wmc.1
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:18:47 -0700 (PDT)
In-Reply-To: <20171012171823.1431-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Benefit from the newly introduced block callback infrastructure and
convert ndo_setup_tc calls for u32 offloads to block callbacks.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 45 +++++++++++++++++++++++----
 1 file changed, 39 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 7683c14..6b52cfd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -9365,13 +9365,10 @@ static int ixgbe_configure_clsu32(struct ixgbe_adapter *adapter,
 	return err;
 }
 
-static int ixgbe_setup_tc_cls_u32(struct net_device *dev,
+static int ixgbe_setup_tc_cls_u32(struct ixgbe_adapter *adapter,
 				  struct tc_cls_u32_offload *cls_u32)
 {
-	struct ixgbe_adapter *adapter = netdev_priv(dev);
-
-	if (!is_classid_clsact_ingress(cls_u32->common.classid) ||
-	    cls_u32->common.chain_index)
+	if (cls_u32->common.chain_index)
 		return -EOPNOTSUPP;
 
 	switch (cls_u32->command) {
@@ -9390,6 +9387,40 @@ static int ixgbe_setup_tc_cls_u32(struct net_device *dev,
 	}
 }
 
+static int ixgbe_setup_tc_block_cb(enum tc_setup_type type, void *type_data,
+				   void *cb_priv)
+{
+	struct ixgbe_adapter *adapter = cb_priv;
+
+	switch (type) {
+	case TC_SETUP_CLSU32:
+		return ixgbe_setup_tc_cls_u32(adapter, type_data);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static int ixgbe_setup_tc_block(struct net_device *dev,
+				struct tc_block_offload *f)
+{
+	struct ixgbe_adapter *adapter = netdev_priv(dev);
+
+	if (f->binder_type != TCF_BLOCK_BINDER_TYPE_CLSACT_INGRESS)
+		return -EOPNOTSUPP;
+
+	switch (f->command) {
+	case TC_BLOCK_BIND:
+		return tcf_block_cb_register(f->block, ixgbe_setup_tc_block_cb,
+					     adapter, adapter);
+	case TC_BLOCK_UNBIND:
+		tcf_block_cb_unregister(f->block, ixgbe_setup_tc_block_cb,
+					adapter);
+		return 0;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
 static int ixgbe_setup_tc_mqprio(struct net_device *dev,
 				 struct tc_mqprio_qopt *mqprio)
 {
@@ -9402,7 +9433,9 @@ static int __ixgbe_setup_tc(struct net_device *dev, enum tc_setup_type type,
 {
 	switch (type) {
 	case TC_SETUP_CLSU32:
-		return ixgbe_setup_tc_cls_u32(dev, type_data);
+		return 0; /* will be removed after conversion from ndo */
+	case TC_SETUP_BLOCK:
+		return ixgbe_setup_tc_block(dev, type_data);
 	case TC_SETUP_MQPRIO:
 		return ixgbe_setup_tc_mqprio(dev, type_data);
 	default:
-- 
2.9.5
