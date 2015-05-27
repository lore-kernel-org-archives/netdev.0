From: Neil McKee <neil.mckee@inmon.com>
Subject: [PATCH v3 net-next] openvswitch: include datapath actions with sampled-packet upcall to userspace
Date: Tue, 26 May 2015 20:59:43 -0700
Message-ID: <1432699183-15713-1-git-send-email-neil.mckee@inmon.com>
References: <CALnjE+p3DutBRfUXOWOR3Dw_SmwbxuZcTftps15=hCxs+MWLJA@mail.gmail.com>
Cc: Neil McKee <neil.mckee@inmon.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:35216 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751889AbbE0D7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 23:59:54 -0400
Received: by pdea3 with SMTP id a3so107258894pde.2
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 20:59:53 -0700 (PDT)
In-Reply-To: <CALnjE+p3DutBRfUXOWOR3Dw_SmwbxuZcTftps15=hCxs+MWLJA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If new optional attribute OVS_USERSPACE_ATTR_ACTIONS is added to an
OVS_ACTION_ATTR_USERSPACE action, then include the datapath actions
in the upcall.

This Directly associates the sampled packet with the path it takes
through the virtual switch. Path information currently includes mangling,
encapsulation and decapsulation actions for tunneling protocols GRE,
VXLAN, Geneve, MPLS and QinQ, but this extension requires no further
changes to accommodate datapath actions that may be added in the
future.

Adding path information enhances visibility into complex virtual
networks.

Signed-off-by: Neil McKee <neil.mckee@inmon.com>
---
 include/uapi/linux/openvswitch.h |  4 ++++
 net/openvswitch/actions.c        | 23 +++++++++++++++--------
 net/openvswitch/datapath.c       | 18 ++++++++++++++++--
 net/openvswitch/datapath.h       |  2 ++
 4 files changed, 37 insertions(+), 10 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index bbd49a0..1dab776 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -153,6 +153,8 @@ enum ovs_packet_cmd {
  * flow key against the kernel's.
  * @OVS_PACKET_ATTR_ACTIONS: Contains actions for the packet.  Used
  * for %OVS_PACKET_CMD_EXECUTE.  It has nested %OVS_ACTION_ATTR_* attributes.
+ * Also used in upcall when %OVS_ACTION_ATTR_USERSPACE has optional
+ * %OVS_USERSPACE_ATTR_ACTIONS attribute.
  * @OVS_PACKET_ATTR_USERDATA: Present for an %OVS_PACKET_CMD_ACTION
  * notification if the %OVS_ACTION_ATTR_USERSPACE action specified an
  * %OVS_USERSPACE_ATTR_USERDATA attribute, with the same length and content
@@ -528,6 +530,7 @@ enum ovs_sample_attr {
  * copied to the %OVS_PACKET_CMD_ACTION message as %OVS_PACKET_ATTR_USERDATA.
  * @OVS_USERSPACE_ATTR_EGRESS_TUN_PORT: If present, u32 output port to get
  * tunnel info.
+ * @OVS_USERSPACE_ATTR_ACTIONS: If present, send actions with upcall.
  */
 enum ovs_userspace_attr {
 	OVS_USERSPACE_ATTR_UNSPEC,
@@ -535,6 +538,7 @@ enum ovs_userspace_attr {
 	OVS_USERSPACE_ATTR_USERDATA,  /* Optional user-specified cookie. */
 	OVS_USERSPACE_ATTR_EGRESS_TUN_PORT,  /* Optional, u32 output port
 					      * to get tunnel info. */
+	OVS_USERSPACE_ATTR_ACTIONS,   /* Optional flag to get actions. */
 	__OVS_USERSPACE_ATTR_MAX
 };
 
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index b491c1c..8a8c0b8 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -608,17 +608,16 @@ static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port)
 }
 
 static int output_userspace(struct datapath *dp, struct sk_buff *skb,
-			    struct sw_flow_key *key, const struct nlattr *attr)
+			    struct sw_flow_key *key, const struct nlattr *attr,
+			    const struct nlattr *actions, int actions_len)
 {
 	struct ovs_tunnel_info info;
 	struct dp_upcall_info upcall;
 	const struct nlattr *a;
 	int rem;
 
+	memset(&upcall, 0, sizeof(upcall));
 	upcall.cmd = OVS_PACKET_CMD_ACTION;
-	upcall.userdata = NULL;
-	upcall.portid = 0;
-	upcall.egress_tun_info = NULL;
 
 	for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
 		 a = nla_next(a, &rem)) {
@@ -647,6 +646,13 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 			break;
 		}
 
+		case OVS_USERSPACE_ATTR_ACTIONS: {
+			/* Include actions. */
+			upcall.actions = actions;
+			upcall.actions_len = actions_len;
+			break;
+		}
+
 		} /* End of switch. */
 	}
 
@@ -654,7 +660,8 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 }
 
 static int sample(struct datapath *dp, struct sk_buff *skb,
-		  struct sw_flow_key *key, const struct nlattr *attr)
+		  struct sw_flow_key *key, const struct nlattr *attr,
+		  const struct nlattr *actions, int actions_len)
 {
 	const struct nlattr *acts_list = NULL;
 	const struct nlattr *a;
@@ -688,7 +695,7 @@ static int sample(struct datapath *dp, struct sk_buff *skb,
 	 */
 	if (likely(nla_type(a) == OVS_ACTION_ATTR_USERSPACE &&
 		   nla_is_last(a, rem)))
-		return output_userspace(dp, skb, key, a);
+		return output_userspace(dp, skb, key, a, actions, actions_len);
 
 	skb = skb_clone(skb, GFP_ATOMIC);
 	if (!skb)
@@ -872,7 +879,7 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			break;
 
 		case OVS_ACTION_ATTR_USERSPACE:
-			output_userspace(dp, skb, key, a);
+			output_userspace(dp, skb, key, a, attr, len);
 			break;
 
 		case OVS_ACTION_ATTR_HASH:
@@ -916,7 +923,7 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			break;
 
 		case OVS_ACTION_ATTR_SAMPLE:
-			err = sample(dp, skb, key, a);
+			err = sample(dp, skb, key, a, attr, len);
 			break;
 		}
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 5bae724..3891923 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -273,10 +273,9 @@ void ovs_dp_process_packet(struct sk_buff *skb, struct sw_flow_key *key)
 		struct dp_upcall_info upcall;
 		int error;
 
+		memset(&upcall, 0, sizeof(upcall));
 		upcall.cmd = OVS_PACKET_CMD_MISS;
-		upcall.userdata = NULL;
 		upcall.portid = ovs_vport_find_upcall_portid(p, skb);
-		upcall.egress_tun_info = NULL;
 		error = ovs_dp_upcall(dp, skb, key, &upcall);
 		if (unlikely(error))
 			kfree_skb(skb);
@@ -398,6 +397,10 @@ static size_t upcall_msg_size(const struct dp_upcall_info *upcall_info,
 	if (upcall_info->egress_tun_info)
 		size += nla_total_size(ovs_tun_key_attr_size());
 
+	/* OVS_PACKET_ATTR_ACTIONS */
+	if (upcall_info->actions_len)
+		size += nla_total_size(upcall_info->actions_len);
+
 	return size;
 }
 
@@ -479,6 +482,17 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 		nla_nest_end(user_skb, nla);
 	}
 
+	if (upcall_info->actions_len) {
+		nla = nla_nest_start(user_skb, OVS_PACKET_ATTR_ACTIONS);
+		err = ovs_nla_put_actions(upcall_info->actions,
+					  upcall_info->actions_len,
+					  user_skb);
+		if (!err)
+			nla_nest_end(user_skb, nla);
+		else
+			nla_nest_cancel(user_skb, nla);
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
