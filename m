From: Andy Zhou <azhou@ovn.org>
Subject: [net-next v2 4/4] openvswitch: Add meter action support
Date: Tue, 17 Oct 2017 00:36:45 -0700
Message-ID: <1508225805-11613-5-git-send-email-azhou@ovn.org>
References: <1508225805-11613-1-git-send-email-azhou@ovn.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: pshelar@ovn.org, joe@ovn.org, gvrose8192@gmail.com,
        Andy Zhou <azhou@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:43107 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933956AbdJQHiK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 03:38:10 -0400
Received: by mail-pg0-f68.google.com with SMTP id s75so772137pgs.0
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 00:38:09 -0700 (PDT)
In-Reply-To: <1508225805-11613-1-git-send-email-azhou@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implements OVS kernel meter action support.

Signed-off-by: Andy Zhou <azhou@ovn.org>
---
 include/uapi/linux/openvswitch.h | 3 +++
 net/openvswitch/actions.c        | 6 ++++++
 net/openvswitch/datapath.h       | 1 +
 net/openvswitch/flow_netlink.c   | 6 ++++++
 4 files changed, 16 insertions(+)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index d413a2398214..de2807a9cc60 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -808,6 +808,8 @@ struct ovs_action_push_eth {
  * @OVS_ACTION_ATTR_POP_ETH: Pop the outermost Ethernet header off the
  * packet.
  * @OVS_ACTION_ATTR_CT_CLEAR: Clear conntrack state from the packet.
+ * @OVS_ACTION_ATTR_METER: Run packet through a meter, which may drop the
+ * packet, or modify the packet (e.g., change the DSCP field).
  *
  * Only a single header can be set with a single %OVS_ACTION_ATTR_SET.  Not all
  * fields within a header are modifiable, e.g. the IPv4 protocol and fragment
@@ -838,6 +840,7 @@ enum ovs_action_attr {
 	OVS_ACTION_ATTR_PUSH_ETH,     /* struct ovs_action_push_eth. */
 	OVS_ACTION_ATTR_POP_ETH,      /* No argument. */
 	OVS_ACTION_ATTR_CT_CLEAR,     /* No argument. */
+	OVS_ACTION_ATTR_METER,        /* u32 meter ID. */
 
 	__OVS_ACTION_ATTR_MAX,	      /* Nothing past this will be accepted
 				       * from userspace. */
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index a551232daf61..df342fe66492 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -1214,6 +1214,12 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
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
index dc0d79092e74..6789bb1ddf0e 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -87,6 +87,7 @@ static bool actions_may_change_flow(const struct nlattr *actions)
 		case OVS_ACTION_ATTR_SAMPLE:
 		case OVS_ACTION_ATTR_SET:
 		case OVS_ACTION_ATTR_SET_MASKED:
+		case OVS_ACTION_ATTR_METER:
 		default:
 			return true;
 		}
@@ -2533,6 +2534,7 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 			[OVS_ACTION_ATTR_TRUNC] = sizeof(struct ovs_action_trunc),
 			[OVS_ACTION_ATTR_PUSH_ETH] = sizeof(struct ovs_action_push_eth),
 			[OVS_ACTION_ATTR_POP_ETH] = 0,
+			[OVS_ACTION_ATTR_METER] = sizeof(u32),
 		};
 		const struct ovs_action_push_vlan *vlan;
 		int type = nla_type(a);
@@ -2690,6 +2692,10 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
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
