From: Neil McKee <neil.mckee@inmon.com>
Subject: [PATCH net-next] openvswitch: include datapath actions with sampled-packet upcall to userspace
Date: Wed, 20 May 2015 12:32:38 -0700
Message-ID: <1432150358-13108-1-git-send-email-neil.mckee@inmon.com>
Cc: Neil McKee <neil.mckee@inmon.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:35154 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753684AbbETTcu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 May 2015 15:32:50 -0400
Received: by pdea3 with SMTP id a3so79736957pde.2
        for <netdev@vger.kernel.org>; Wed, 20 May 2015 12:32:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Directly associate a sampled packet with the path it takes through the virtual switch.
Path information currently includes mangling, encapsulation and decapsulation actions
for tunneling protocols GRE, VXLAN, Geneve, MPLS and QinQ, but this extension requires
no further changes to accommodate datapath actions that may be added in the future.

Adding path information enhances visibility into complex virtual networks.

Signed-off-by: Neil McKee <neil.mckee@inmon.com>
---
 net/openvswitch/actions.c  | 14 +++++++++-----
 net/openvswitch/datapath.c | 18 ++++++++++++++++++
 net/openvswitch/datapath.h |  2 ++
 3 files changed, 29 insertions(+), 5 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index b491c1c..ee5760d 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -608,7 +608,8 @@ static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port)
 }
 
 static int output_userspace(struct datapath *dp, struct sk_buff *skb,
-			    struct sw_flow_key *key, const struct nlattr *attr)
+			    struct sw_flow_key *key, const struct nlattr *attr,
+			    const struct nlattr *actions, int actions_len)
 {
 	struct ovs_tunnel_info info;
 	struct dp_upcall_info upcall;
@@ -619,6 +620,8 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 	upcall.userdata = NULL;
 	upcall.portid = 0;
 	upcall.egress_tun_info = NULL;
+	upcall.actions = actions;
+	upcall.actions_len = actions_len;
 
 	for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
 		 a = nla_next(a, &rem)) {
@@ -654,7 +657,8 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 }
 
 static int sample(struct datapath *dp, struct sk_buff *skb,
-		  struct sw_flow_key *key, const struct nlattr *attr)
+		  struct sw_flow_key *key, const struct nlattr *attr,
+		  const struct nlattr *actions, int actions_len)
 {
 	const struct nlattr *acts_list = NULL;
 	const struct nlattr *a;
@@ -688,7 +692,7 @@ static int sample(struct datapath *dp, struct sk_buff *skb,
 	 */
 	if (likely(nla_type(a) == OVS_ACTION_ATTR_USERSPACE &&
 		   nla_is_last(a, rem)))
-		return output_userspace(dp, skb, key, a);
+		return output_userspace(dp, skb, key, a, actions, actions_len);
 
 	skb = skb_clone(skb, GFP_ATOMIC);
 	if (!skb)
@@ -872,7 +876,7 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			break;
 
 		case OVS_ACTION_ATTR_USERSPACE:
-			output_userspace(dp, skb, key, a);
+			output_userspace(dp, skb, key, a, attr, len);
 			break;
 
 		case OVS_ACTION_ATTR_HASH:
@@ -916,7 +920,7 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			break;
 
 		case OVS_ACTION_ATTR_SAMPLE:
-			err = sample(dp, skb, key, a);
+			err = sample(dp, skb, key, a, attr, len);
 			break;
 		}
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 5bae724..e735c8f 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -277,6 +277,8 @@ void ovs_dp_process_packet(struct sk_buff *skb, struct sw_flow_key *key)
 		upcall.userdata = NULL;
 		upcall.portid = ovs_vport_find_upcall_portid(p, skb);
 		upcall.egress_tun_info = NULL;
+		upcall.actions = NULL;
+		upcall.actions_len = 0;
 		error = ovs_dp_upcall(dp, skb, key, &upcall);
 		if (unlikely(error))
 			kfree_skb(skb);
@@ -398,6 +400,10 @@ static size_t upcall_msg_size(const struct dp_upcall_info *upcall_info,
 	if (upcall_info->egress_tun_info)
 		size += nla_total_size(ovs_tun_key_attr_size());
 
+	/* OVS_PACKET_ATTR_ACTIONS */
+	if (upcall_info->actions_len)
+		size += nla_total_size(upcall_info->actions_len);
+
 	return size;
 }
 
@@ -479,6 +485,18 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 		nla_nest_end(user_skb, nla);
 	}
 
+	if (upcall_info->actions_len) {
+		nla = nla_nest_start(user_skb, OVS_PACKET_ATTR_ACTIONS);
+		err = ovs_nla_put_actions(upcall_info->actions,
+					  upcall_info->actions_len,
+					  user_skb);
+		if (!err) {
+			nla_nest_end(user_skb, nla);
+		} else {
+			nla_nest_cancel(user_skb, nla);
+		}
+	}
+
 	/* Only reserve room for attribute header, packet data is added
 	 * in skb_zerocopy() */
 	if (!(nla = nla_reserve(user_skb, OVS_PACKET_ATTR_PACKET, 0))) {
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 3ece945..b98b1b4 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -118,6 +118,8 @@ struct ovs_skb_cb {
 struct dp_upcall_info {
 	const struct ovs_tunnel_info *egress_tun_info;
 	const struct nlattr *userdata;
+	const struct nlattr *actions;
+	int actions_len;
 	u32 portid;
 	u8 cmd;
 };
-- 
1.9.3
