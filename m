From: William Tu <u9012063@gmail.com>
Subject: [net-next,v2] openvswitch: Add packet truncation support.
Date: Thu,  9 Jun 2016 16:57:29 -0700
Message-ID: <1465516649-44725-1-git-send-email-u9012063@gmail.com>
Cc: pshelar@ovn.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:35403 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203AbcFIX5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 19:57:37 -0400
Received: by mail-pf0-f194.google.com with SMTP id t190so3746143pfb.2
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 16:57:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch adds a new OVS action, OVS_ACTION_ATTR_TRUNC, in order to
truncate packets. A 'max_len' is added for setting up the maximum
packet size, and a 'cutlen' field is to record the number of bytes
to trim the packet when the packet is outputting to a port, or when
the packet is sent to userspace.

Signed-off-by: William Tu <u9012063@gmail.com>
---
v1 -> v2: 
- Use 32 bits cutlen and fix unnecessary cutlen initilization.
- Fix cutlen leaks to remaining actions under sample action.
- In queue_userspace_packet, don't extract hlen when using skb_zerocopy.
---
 include/uapi/linux/openvswitch.h |  7 +++++++
 net/openvswitch/actions.c        | 34 ++++++++++++++++++++++++++++++----
 net/openvswitch/datapath.c       | 27 ++++++++++++++++-----------
 net/openvswitch/datapath.h       |  5 ++++-
 net/openvswitch/flow_netlink.c   |  9 +++++++++
 net/openvswitch/vport.c          |  1 +
 6 files changed, 67 insertions(+), 16 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index bb0d515..80f8c7c 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -580,6 +580,11 @@ enum ovs_userspace_attr {
 
 #define OVS_USERSPACE_ATTR_MAX (__OVS_USERSPACE_ATTR_MAX - 1)
 
+struct ovs_action_trunc {
+	uint32_t max_len; /* Max packet size in bytes. */
+};
+#define ETH_MIN_FRAME_LEN ETH_ZLEN
+
 /**
  * struct ovs_action_push_mpls - %OVS_ACTION_ATTR_PUSH_MPLS action argument.
  * @mpls_lse: MPLS label stack entry to push.
@@ -703,6 +708,7 @@ enum ovs_nat_attr {
  * enum ovs_action_attr - Action types.
  *
  * @OVS_ACTION_ATTR_OUTPUT: Output packet to port.
+ * @OVS_ACTION_ATTR_TRUNC: Output packet to port with truncated packet size.
  * @OVS_ACTION_ATTR_USERSPACE: Send packet to userspace according to nested
  * %OVS_USERSPACE_ATTR_* attributes.
  * @OVS_ACTION_ATTR_SET: Replaces the contents of an existing header.  The
@@ -756,6 +762,7 @@ enum ovs_action_attr {
 				       * The data must be zero for the unmasked
 				       * bits. */
 	OVS_ACTION_ATTR_CT,           /* Nested OVS_CT_ATTR_* . */
+	OVS_ACTION_ATTR_TRUNC,        /* u32 struct ovs_action_trunc. */
 
 	__OVS_ACTION_ATTR_MAX,	      /* Nothing past this will be accepted
 				       * from userspace. */
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 9a3eb7a..64dbc80 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -750,6 +750,10 @@ static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port,
 
 	if (likely(vport)) {
 		u16 mru = OVS_CB(skb)->mru;
+		u32 cutlen = OVS_CB(skb)->cutlen;
+
+		if (cutlen > 0)
+			pskb_trim(skb, skb->len - cutlen);
 
 		if (likely(!mru || (skb->len <= mru + ETH_HLEN))) {
 			ovs_vport_send(vport, skb);
@@ -775,7 +779,8 @@ static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port,
 
 static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 			    struct sw_flow_key *key, const struct nlattr *attr,
-			    const struct nlattr *actions, int actions_len)
+			    const struct nlattr *actions, int actions_len,
+			    uint32_t cutlen)
 {
 	struct dp_upcall_info upcall;
 	const struct nlattr *a;
@@ -822,7 +827,7 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 		} /* End of switch. */
 	}
 
-	return ovs_dp_upcall(dp, skb, key, &upcall);
+	return ovs_dp_upcall(dp, skb, key, &upcall, cutlen);
 }
 
 static int sample(struct datapath *dp, struct sk_buff *skb,
@@ -832,6 +837,7 @@ static int sample(struct datapath *dp, struct sk_buff *skb,
 	const struct nlattr *acts_list = NULL;
 	const struct nlattr *a;
 	int rem;
+	uint32_t cutlen = 0;
 
 	for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
 		 a = nla_next(a, &rem)) {
@@ -858,13 +864,24 @@ static int sample(struct datapath *dp, struct sk_buff *skb,
 		return 0;
 
 	/* The only known usage of sample action is having a single user-space
+	 * action, or having a truncate action followed by a single user-space
 	 * action. Treat this usage as a special case.
 	 * The output_userspace() should clone the skb to be sent to the
 	 * user space. This skb will be consumed by its caller.
 	 */
+	if (unlikely(nla_type(a) == OVS_ACTION_ATTR_TRUNC)) {
+		struct ovs_action_trunc *trunc = nla_data(a);
+
+		if (skb->len > trunc->max_len)
+			cutlen = skb->len - trunc->max_len;
+
+		a = nla_next(a, &rem);
+	}
+
 	if (likely(nla_type(a) == OVS_ACTION_ATTR_USERSPACE &&
 		   nla_is_last(a, rem)))
-		return output_userspace(dp, skb, key, a, actions, actions_len);
+		return output_userspace(dp, skb, key, a, actions,
+					actions_len, cutlen);
 
 	skb = skb_clone(skb, GFP_ATOMIC);
 	if (!skb)
@@ -1051,6 +1068,7 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			if (out_skb)
 				do_output(dp, out_skb, prev_port, key);
 
+			OVS_CB(skb)->cutlen = 0;
 			prev_port = -1;
 		}
 
@@ -1059,8 +1077,16 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			prev_port = nla_get_u32(a);
 			break;
 
+		case OVS_ACTION_ATTR_TRUNC: {
+			struct ovs_action_trunc *trunc = nla_data(a);
+
+			if (skb->len > trunc->max_len)
+				OVS_CB(skb)->cutlen = skb->len - trunc->max_len;
+			break;
+		}
+
 		case OVS_ACTION_ATTR_USERSPACE:
-			output_userspace(dp, skb, key, a, attr, len);
+			output_userspace(dp, skb, key, a, attr, len, 0);
 			break;
 
 		case OVS_ACTION_ATTR_HASH:
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 856bd8d..26f947e 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -137,10 +137,12 @@ EXPORT_SYMBOL_GPL(lockdep_ovsl_is_held);
 static struct vport *new_vport(const struct vport_parms *);
 static int queue_gso_packets(struct datapath *dp, struct sk_buff *,
 			     const struct sw_flow_key *,
-			     const struct dp_upcall_info *);
+			     const struct dp_upcall_info *,
+			     uint32_t cutlen);
 static int queue_userspace_packet(struct datapath *dp, struct sk_buff *,
 				  const struct sw_flow_key *,
-				  const struct dp_upcall_info *);
+				  const struct dp_upcall_info *,
+				  uint32_t cutlen);
 
 /* Must be called with rcu_read_lock. */
 static struct datapath *get_dp_rcu(struct net *net, int dp_ifindex)
@@ -275,7 +277,7 @@ void ovs_dp_process_packet(struct sk_buff *skb, struct sw_flow_key *key)
 		upcall.cmd = OVS_PACKET_CMD_MISS;
 		upcall.portid = ovs_vport_find_upcall_portid(p, skb);
 		upcall.mru = OVS_CB(skb)->mru;
-		error = ovs_dp_upcall(dp, skb, key, &upcall);
+		error = ovs_dp_upcall(dp, skb, key, &upcall, 0);
 		if (unlikely(error))
 			kfree_skb(skb);
 		else
@@ -300,7 +302,8 @@ out:
 
 int ovs_dp_upcall(struct datapath *dp, struct sk_buff *skb,
 		  const struct sw_flow_key *key,
-		  const struct dp_upcall_info *upcall_info)
+		  const struct dp_upcall_info *upcall_info,
+		  uint32_t cutlen)
 {
 	struct dp_stats_percpu *stats;
 	int err;
@@ -311,9 +314,9 @@ int ovs_dp_upcall(struct datapath *dp, struct sk_buff *skb,
 	}
 
 	if (!skb_is_gso(skb))
-		err = queue_userspace_packet(dp, skb, key, upcall_info);
+		err = queue_userspace_packet(dp, skb, key, upcall_info, cutlen);
 	else
-		err = queue_gso_packets(dp, skb, key, upcall_info);
+		err = queue_gso_packets(dp, skb, key, upcall_info, cutlen);
 	if (err)
 		goto err;
 
@@ -331,7 +334,8 @@ err:
 
 static int queue_gso_packets(struct datapath *dp, struct sk_buff *skb,
 			     const struct sw_flow_key *key,
-			     const struct dp_upcall_info *upcall_info)
+			     const struct dp_upcall_info *upcall_info,
+				 uint32_t cutlen)
 {
 	unsigned short gso_type = skb_shinfo(skb)->gso_type;
 	struct sw_flow_key later_key;
@@ -360,7 +364,7 @@ static int queue_gso_packets(struct datapath *dp, struct sk_buff *skb,
 		if (gso_type & SKB_GSO_UDP && skb != segs)
 			key = &later_key;
 
-		err = queue_userspace_packet(dp, skb, key, upcall_info);
+		err = queue_userspace_packet(dp, skb, key, upcall_info, cutlen);
 		if (err)
 			break;
 
@@ -416,7 +420,8 @@ static void pad_packet(struct datapath *dp, struct sk_buff *skb)
 
 static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 				  const struct sw_flow_key *key,
-				  const struct dp_upcall_info *upcall_info)
+				  const struct dp_upcall_info *upcall_info,
+				  uint32_t cutlen)
 {
 	struct ovs_header *upcall;
 	struct sk_buff *nskb = NULL;
@@ -515,9 +520,9 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 		err = -ENOBUFS;
 		goto out;
 	}
-	nla->nla_len = nla_attr_size(skb->len);
+	nla->nla_len = nla_attr_size(skb->len - cutlen);
 
-	err = skb_zerocopy(user_skb, skb, skb->len, hlen);
+	err = skb_zerocopy(user_skb, skb, skb->len - cutlen, hlen);
 	if (err)
 		goto out;
 
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 427e39a..ab85c1c 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -100,11 +100,13 @@ struct datapath {
  * @input_vport: The original vport packet came in on. This value is cached
  * when a packet is received by OVS.
  * @mru: The maximum received fragement size; 0 if the packet is not
+ * @cutlen: The number of bytes from the packet end to be removed.
  * fragmented.
  */
 struct ovs_skb_cb {
 	struct vport		*input_vport;
 	u16			mru;
+	u32			cutlen;
 };
 #define OVS_CB(skb) ((struct ovs_skb_cb *)(skb)->cb)
 
@@ -194,7 +196,8 @@ extern struct genl_family dp_vport_genl_family;
 void ovs_dp_process_packet(struct sk_buff *skb, struct sw_flow_key *key);
 void ovs_dp_detach_port(struct vport *);
 int ovs_dp_upcall(struct datapath *, struct sk_buff *,
-		  const struct sw_flow_key *, const struct dp_upcall_info *);
+		  const struct sw_flow_key *, const struct dp_upcall_info *,
+		  uint32_t cutlen);
 
 const char *ovs_dp_name(const struct datapath *dp);
 struct sk_buff *ovs_vport_cmd_build_info(struct vport *, u32 pid, u32 seq,
diff --git a/net/openvswitch/flow_netlink.c b/net/openvswitch/flow_netlink.c
index 0bb650f..7bc5405 100644
--- a/net/openvswitch/flow_netlink.c
+++ b/net/openvswitch/flow_netlink.c
@@ -2229,6 +2229,7 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 			[OVS_ACTION_ATTR_SAMPLE] = (u32)-1,
 			[OVS_ACTION_ATTR_HASH] = sizeof(struct ovs_action_hash),
 			[OVS_ACTION_ATTR_CT] = (u32)-1,
+			[OVS_ACTION_ATTR_TRUNC] = sizeof(struct ovs_action_trunc),
 		};
 		const struct ovs_action_push_vlan *vlan;
 		int type = nla_type(a);
@@ -2255,6 +2256,14 @@ static int __ovs_nla_copy_actions(struct net *net, const struct nlattr *attr,
 				return -EINVAL;
 			break;
 
+		case OVS_ACTION_ATTR_TRUNC: {
+			const struct ovs_action_trunc *trunc = nla_data(a);
+
+			if (trunc->max_len < ETH_MIN_FRAME_LEN)
+				return -EINVAL;
+			break;
+		}
+
 		case OVS_ACTION_ATTR_HASH: {
 			const struct ovs_action_hash *act_hash = nla_data(a);
 
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 31cbc8c..6b21fd0 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -444,6 +444,7 @@ int ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
 
 	OVS_CB(skb)->input_vport = vport;
 	OVS_CB(skb)->mru = 0;
+	OVS_CB(skb)->cutlen = 0;
 	if (unlikely(dev_net(skb->dev) != ovs_dp_get_net(vport->dp))) {
 		u32 mark;
 
-- 
2.5.0
