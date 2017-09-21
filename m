From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next v2 3/4] cxgb4: add support to offload action vlan
Date: Thu, 21 Sep 2017 23:41:15 +0530
Message-ID: <0ebc997552ff5db738087771cdab1f89209e53a3.1506015856.git.rahul.lakkireddy@chelsio.com>
References: <cover.1506015856.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, kumaras@chelsio.com, ganeshgr@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:47813 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751726AbdIUSML (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 14:12:11 -0400
In-Reply-To: <cover.1506015856.git.rahul.lakkireddy@chelsio.com>
In-Reply-To: <cover.1506015856.git.rahul.lakkireddy@chelsio.com>
References: <cover.1506015856.git.rahul.lakkireddy@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumaras@chelsio.com>

Add support for offloading tc-flower flows having
vlan actions: pop, push and modify.

Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
Signed-off-by: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>
---
v2:
- Avoid wrapping line for netdev_err message. Also, use
  consistent error message string.

 .../net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c   | 42 ++++++++++++++++++++++
 1 file changed, 42 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
index dda34d5a52fb..e42d2efc9ea2 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
@@ -34,6 +34,7 @@
 
 #include <net/tc_act/tc_gact.h>
 #include <net/tc_act/tc_mirred.h>
+#include <net/tc_act/tc_vlan.h>
 
 #include "cxgb4.h"
 #include "cxgb4_tc_flower.h"
@@ -185,6 +186,27 @@ static void cxgb4_process_flow_actions(struct net_device *in,
 
 			fs->action = FILTER_SWITCH;
 			fs->eport = pi->port_id;
+		} else if (is_tcf_vlan(a)) {
+			u32 vlan_action = tcf_vlan_action(a);
+			u8 prio = tcf_vlan_push_prio(a);
+			u16 vid = tcf_vlan_push_vid(a);
+			u16 vlan_tci = (prio << VLAN_PRIO_SHIFT) | vid;
+
+			switch (vlan_action) {
+			case TCA_VLAN_ACT_POP:
+				fs->newvlan |= VLAN_REMOVE;
+				break;
+			case TCA_VLAN_ACT_PUSH:
+				fs->newvlan |= VLAN_INSERT;
+				fs->vlan = vlan_tci;
+				break;
+			case TCA_VLAN_ACT_MODIFY:
+				fs->newvlan |= VLAN_REWRITE;
+				fs->vlan = vlan_tci;
+				break;
+			default:
+				break;
+			}
 		}
 	}
 }
@@ -222,6 +244,26 @@ static int cxgb4_validate_flow_actions(struct net_device *dev,
 					   __func__);
 				return -EINVAL;
 			}
+		} else if (is_tcf_vlan(a)) {
+			u16 proto = be16_to_cpu(tcf_vlan_push_proto(a));
+			u32 vlan_action = tcf_vlan_action(a);
+
+			switch (vlan_action) {
+			case TCA_VLAN_ACT_POP:
+				break;
+			case TCA_VLAN_ACT_PUSH:
+			case TCA_VLAN_ACT_MODIFY:
+				if (proto != ETH_P_8021Q) {
+					netdev_err(dev, "%s: Unsupported vlan proto\n",
+						   __func__);
+					return -EOPNOTSUPP;
+				}
+				break;
+			default:
+				netdev_err(dev, "%s: Unsupported vlan action\n",
+					   __func__);
+				return -EOPNOTSUPP;
+			}
 		} else {
 			netdev_err(dev, "%s: Unsupported action\n", __func__);
 			return -EOPNOTSUPP;
-- 
2.14.1
