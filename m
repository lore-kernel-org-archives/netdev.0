From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 10/15] dsa: push cls_matchall setup_tc processing into a separate function
Date: Sat,  5 Aug 2017 16:53:32 +0200
Message-ID: <20170805145337.17728-11-jiri@resnulli.us>
References: <20170805145337.17728-1-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        daniel@iogearbox.net, mlxsw@mellanox.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        simon.horman@netronome.com, pieter.jansenvanvuuren@netronome.com,
        dirk.vandermerwe@netronome.com, alexander.h.duyck@intel.com,
        amritha.nambiar@intel.com, oss-drivers@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:38820 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752515AbdHEOx4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 5 Aug 2017 10:53:56 -0400
Received: by mail-wr0-f196.google.com with SMTP id g32so4759815wrd.5
        for <netdev@vger.kernel.org>; Sat, 05 Aug 2017 07:53:55 -0700 (PDT)
In-Reply-To: <20170805145337.17728-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Let dsa_slave_setup_tc be a splitter for specific setup_tc types and
push out cls_matchall specific code into a separate function.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/dsa/slave.c | 33 +++++++++++++++++++++------------
 1 file changed, 21 insertions(+), 12 deletions(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index a02d22b..f041c9e 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -850,26 +850,35 @@ static void dsa_slave_del_cls_matchall(struct net_device *dev,
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
