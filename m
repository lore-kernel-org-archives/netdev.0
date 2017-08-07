From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 10/16] dsa: push cls_matchall setup_tc processing into a separate function
Date: Mon,  7 Aug 2017 10:15:26 +0200
Message-ID: <20170807081532.32760-11-jiri@resnulli.us>
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
Received: from mail-wr0-f193.google.com ([209.85.128.193]:36827 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751989AbdHGIPu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 04:15:50 -0400
Received: by mail-wr0-f193.google.com with SMTP id y67so7125493wrb.3
        for <netdev@vger.kernel.org>; Mon, 07 Aug 2017 01:15:50 -0700 (PDT)
In-Reply-To: <20170807081532.32760-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Let dsa_slave_setup_tc be a splitter for specific setup_tc types and
push out cls_matchall specific code into a separate function.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/slave.c | 33 +++++++++++++++++++++------------
 1 file changed, 21 insertions(+), 12 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 453f6dd..e76d576 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -863,26 +863,35 @@ static void dsa_slave_del_cls_matchall(struct net_device *dev,
 	kfree(mall_tc_entry);
 }
 
-static int dsa_slave_setup_tc(struct net_device *dev, enum tc_setup_type type,
-			      u32 handle, u32 chain_index, __be16 protocol,
-			      struct tc_to_netdev *tc)
+static int dsa_slave_setup_tc_cls_matchall(struct net_device *dev,
+					   u32 handle, u32 chain_index,
+					   __be16 protocol,
+					   struct tc_cls_matchall_offload *cls)
 {
 	bool ingress = TC_H_MAJ(handle) == TC_H_MAJ(TC_H_INGRESS);
 
 	if (chain_index)
 		return -EOPNOTSUPP;
 
+	switch (cls->command) {
+	case TC_CLSMATCHALL_REPLACE:
+		return dsa_slave_add_cls_matchall(dev, protocol, cls, ingress);
+	case TC_CLSMATCHALL_DESTROY:
+		dsa_slave_del_cls_matchall(dev, cls);
+		return 0;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static int dsa_slave_setup_tc(struct net_device *dev, enum tc_setup_type type,
+			      u32 handle, u32 chain_index, __be16 protocol,
+			      struct tc_to_netdev *tc)
+{
 	switch (type) {
 	case TC_SETUP_CLSMATCHALL:
-		switch (tc->cls_mall->command) {
-		case TC_CLSMATCHALL_REPLACE:
-			return dsa_slave_add_cls_matchall(dev, protocol,
-							  tc->cls_mall,
-							  ingress);
-		case TC_CLSMATCHALL_DESTROY:
-			dsa_slave_del_cls_matchall(dev, tc->cls_mall);
-			return 0;
-		}
+		return dsa_slave_setup_tc_cls_matchall(dev, handle, chain_index,
+						       protocol, tc->cls_mall);
 	default:
 		return -EOPNOTSUPP;
 	}
-- 
2.9.3
