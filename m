From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 17/20] dsa: Convert ndo_setup_tc offloads to block callbacks
Date: Tue, 17 Oct 2017 22:06:12 +0200
Message-ID: <20171017200615.4530-18-jiri@resnulli.us>
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
Received: from mail-wm0-f67.google.com ([74.125.82.67]:48911 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1764067AbdJQUGc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 16:06:32 -0400
Received: by mail-wm0-f67.google.com with SMTP id i124so6017908wmf.3
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 13:06:31 -0700 (PDT)
In-Reply-To: <20171017200615.4530-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Benefit from the newly introduced block callback infrastructure and
convert ndo_setup_tc calls for matchall offloads to block callbacks.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/dsa/slave.c | 64 +++++++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 53 insertions(+), 11 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 45f4ea8..0a20b19 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -788,17 +788,9 @@ static void dsa_slave_del_cls_matchall(struct net_device *dev,
 }
 
 static int dsa_slave_setup_tc_cls_matchall(struct net_device *dev,
-					   struct tc_cls_matchall_offload *cls)
+					   struct tc_cls_matchall_offload *cls,
+					   bool ingress)
 {
-	bool ingress;
-
-	if (is_classid_clsact_ingress(cls->common.classid))
-		ingress = true;
-	else if (is_classid_clsact_egress(cls->common.classid))
-		ingress = false;
-	else
-		return -EOPNOTSUPP;
-
 	if (cls->common.chain_index)
 		return -EOPNOTSUPP;
 
@@ -813,12 +805,62 @@ static int dsa_slave_setup_tc_cls_matchall(struct net_device *dev,
 	}
 }
 
+static int dsa_slave_setup_tc_block_cb(enum tc_setup_type type, void *type_data,
+				       void *cb_priv, bool ingress)
+{
+	struct net_device *dev = cb_priv;
+
+	switch (type) {
+	case TC_SETUP_CLSMATCHALL:
+		return dsa_slave_setup_tc_cls_matchall(dev, type_data, ingress);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static int dsa_slave_setup_tc_block_cb_ig(enum tc_setup_type type,
+					  void *type_data, void *cb_priv)
+{
+	return dsa_slave_setup_tc_block_cb(type, type_data, cb_priv, true);
+}
+
+static int dsa_slave_setup_tc_block_cb_eg(enum tc_setup_type type,
+					  void *type_data, void *cb_priv)
+{
+	return dsa_slave_setup_tc_block_cb(type, type_data, cb_priv, false);
+}
+
+static int dsa_slave_setup_tc_block(struct net_device *dev,
+				    struct tc_block_offload *f)
+{
+	tc_setup_cb_t *cb;
+
+	if (f->binder_type == TCF_BLOCK_BINDER_TYPE_CLSACT_INGRESS)
+		cb = dsa_slave_setup_tc_block_cb_ig;
+	else if (f->binder_type == TCF_BLOCK_BINDER_TYPE_CLSACT_EGRESS)
+		cb = dsa_slave_setup_tc_block_cb_eg;
+	else
+		return -EOPNOTSUPP;
+
+	switch (f->command) {
+	case TC_BLOCK_BIND:
+		return tcf_block_cb_register(f->block, cb, dev, dev);
+	case TC_BLOCK_UNBIND:
+		tcf_block_cb_unregister(f->block, cb, dev);
+		return 0;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
 static int dsa_slave_setup_tc(struct net_device *dev, enum tc_setup_type type,
 			      void *type_data)
 {
 	switch (type) {
 	case TC_SETUP_CLSMATCHALL:
-		return dsa_slave_setup_tc_cls_matchall(dev, type_data);
+		return 0; /* will be removed after conversion from ndo */
+	case TC_SETUP_BLOCK:
+		return dsa_slave_setup_tc_block(dev, type_data);
 	default:
 		return -EOPNOTSUPP;
 	}
-- 
2.9.5
