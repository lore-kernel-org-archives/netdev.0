From: Andy Zhou <azhou@ovn.org>
Subject: [net-next RFC 4/4] openvswitch: Add meter action support
Date: Thu, 12 Oct 2017 15:38:43 -0700
Message-ID: <1507847923-13612-5-git-send-email-azhou@ovn.org>
References: <1507847923-13612-1-git-send-email-azhou@ovn.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: pshelar@ovn.org, joe@ovn.org, gvrose8192@gmail.com,
        Andy Zhou <azhou@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:55686 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757116AbdJLWkN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 18:40:13 -0400
Received: by mail-pf0-f193.google.com with SMTP id 17so6955771pfn.12
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 15:40:13 -0700 (PDT)
In-Reply-To: <1507847923-13612-1-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implements OVS kernel meter action support.

Signed-off-by: Andy Zhou <azhou@ovn.org>
---
 include/uapi/linux/openvswitch.h |  1 +
 net/openvswitch/actions.c        | 12 ++++++++++++
 net/openvswitch/datapath.h       |  1 +
 net/openvswitch/flow_netlink.c   |  6 ++++++
 4 files changed, 20 insertions(+)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 325049a129e4..11fe1a06cdd6 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -835,6 +835,7 @@ enum ovs_action_attr {
 	OVS_ACTION_ATTR_TRUNC,        /* u32 struct ovs_action_trunc. */
 	OVS_ACTION_ATTR_PUSH_ETH,     /* struct ovs_action_push_eth. */
 	OVS_ACTION_ATTR_POP_ETH,      /* No argument. */
+	OVS_ACTION_ATTR_METER,        /* u32 meter ID. */
 
 	__OVS_ACTION_ATTR_MAX,	      /* Nothing past this will be accepted
 				       * from userspace. */
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index a54a556fcdb5..4eb160ac5a27 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -1210,6 +1210,12 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 		case OVS_ACTION_ATTR_POP_ETH:
 			err = pop_eth(skb, key);
 			break;
+
+		case OVS_ACTION_ATTR_METER:
+			if (ovs_meter_execute(dp, skb, key, nla_get_u32(a))) {
+				consume_skb(skb);
+				return 0;
+			}
 		}
 
 		if (unlikely(err)) {
@@ -1341,6 +1347,12 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb,
 	err = do_execute_actions(dp, skb, key,
 				 acts->actions, acts->actions_len);
 
+	/* OVS action has dropped the packet, do not expose it
+	 * to the user.
+	 */
+	if (err == -ENODATA)
+		err = 0;
+
 	if (level == 1)
 		process_deferred_actions(dp);
 
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index d1ffa1d9fe57..cda40c6af40a 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -30,6 +30,7 @@
 #include "conntrack.h"
 #include "flow.h"
 #include "flow_table.h"
+#include "meter.h"
 #include "vport-internal_dev.h"
 
 #define DP_MAX_PORTS           USHRT_MAX
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index e8eb427ce6d1..39b548431f68 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -85,6 +85,7 @@ static bool actions_may_change_flow(const struct nlattr *actions)
 		case OVS_ACTION_ATTR_SAMPLE:
 		case OVS_ACTION_ATTR_SET:
 		case OVS_ACTION_ATTR_SET_MASKED:
+		case OVS_ACTION_ATTR_METER:
 		default:
 			return true;
 		}
@@ -2482,6 +2483,7 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 			[OVS_ACTION_ATTR_TRUNC] = sizeof(struct ovs_action_trunc),
 			[OVS_ACTION_ATTR_PUSH_ETH] = sizeof(struct ovs_action_push_eth),
 			[OVS_ACTION_ATTR_POP_ETH] = 0,
+			[OVS_ACTION_ATTR_METER] = sizeof(u32),
 		};
 		const struct ovs_action_push_vlan *vlan;
 		int type = nla_type(a);
@@ -2636,6 +2638,10 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 			mac_proto = MAC_PROTO_ETHERNET;
 			break;
 
+		case OVS_ACTION_ATTR_METER:
+			/* Non-existent meters are simply ignored.  */
+			break;
+
 		default:
 			OVS_NLERR(log, "Unknown Action type %d", type);
 			return -EINVAL;
-- 
1.8.3.1
