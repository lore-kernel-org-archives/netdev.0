From: William Tu <u9012063@gmail.com>
Subject: [PATCH] openvswitch: Add packet truncation support.
Date: Wed,  8 Jun 2016 18:18:25 -0700
Message-ID: <1465435105-21777-1-git-send-email-u9012063@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33151 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1425927AbcFIBSg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 21:18:36 -0400
Received: by mail-pf0-f196.google.com with SMTP id c74so1630012pfb.0
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 18:18:35 -0700 (PDT)
Received: from vm-dev.localdomain ([208.91.1.34])
        by smtp.gmail.com with ESMTPSA id k69sm5162571pfc.41.2016.06.08.18.18.34
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jun 2016 18:18:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch adds a new OVS action, OVS_ACTION_ATTR_TRUNC, in order to
truncate packets. A 'max_len' is added for setting up the maximum
packet size, and a 'cutlen' field is to record the number of bytes
to trim the packet when the packet is outputting to a port, or when
the packet is sent to userspace.

Signed-off-by: William Tu <u9012063@gmail.com>
---
 include/uapi/linux/openvswitch.h |  7 +++++++
 net/openvswitch/actions.c        | 28 +++++++++++++++++++++++++++-
 net/openvswitch/datapath.c       |  9 +++++++--
 net/openvswitch/datapath.h       |  2 ++
 net/openvswitch/flow_netlink.c   |  9 +++++++++
 net/openvswitch/vport.c          |  1 +
 6 files changed, 53 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index bb0d515..6d7ac5b 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -580,6 +580,11 @@ enum ovs_userspace_attr {
 
 #define OVS_USERSPACE_ATTR_MAX (__OVS_USERSPACE_ATTR_MAX - 1)
 
+struct ovs_action_trunc {
+	uint32_t max_len; /* Max packet size in bytes. */
+};
+#define ETH_MIN_FRAME_LEN 60
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
+	OVS_ACTION_ATTR_TRUNC,        /* u16 struct ovs_action_trunc. */
 
 	__OVS_ACTION_ATTR_MAX,	      /* Nothing past this will be accepted
 				       * from userspace. */
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 9a3eb7a..889b78b 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -750,6 +750,10 @@ static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port,
 
 	if (likely(vport)) {
 		u16 mru = OVS_CB(skb)->mru;
+		u16 cutlen = OVS_CB(skb)->cutlen;
+
+		if (cutlen > 0)
+			pskb_trim(skb, skb->len - cutlen);
 
 		if (likely(!mru || (skb->len <= mru + ETH_HLEN))) {
 			ovs_vport_send(vport, skb);
@@ -858,10 +862,19 @@ static int sample(struct datapath *dp, struct sk_buff *skb,
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
+		OVS_CB(skb)->cutlen = skb->len > trunc->max_len ?
+						skb->len - trunc->max_len : 0;
+		a = nla_next(a, &rem);
+	}
+
 	if (likely(nla_type(a) == OVS_ACTION_ATTR_USERSPACE &&
 		   nla_is_last(a, rem)))
 		return output_userspace(dp, skb, key, a, actions, actions_len);
@@ -1044,13 +1057,18 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 	for (a = attr, rem = len; rem > 0;
 	     a = nla_next(a, &rem)) {
 		int err = 0;
+		int cutlen = OVS_CB(skb)->cutlen;
 
 		if (unlikely(prev_port != -1)) {
 			struct sk_buff *out_skb = skb_clone(skb, GFP_ATOMIC);
 
-			if (out_skb)
+			if (out_skb) {
+				/* skb_clone does not clone the CB. */
+				OVS_CB(out_skb)->cutlen = cutlen;
 				do_output(dp, out_skb, prev_port, key);
+			}
 
+			OVS_CB(skb)->cutlen = 0;
 			prev_port = -1;
 		}
 
@@ -1059,6 +1077,14 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			prev_port = nla_get_u32(a);
 			break;
 
+		case OVS_ACTION_ATTR_TRUNC: {
+			struct ovs_action_trunc *trunc = nla_data(a);
+
+			OVS_CB(skb)->cutlen = skb->len > trunc->max_len ?
+						skb->len - trunc->max_len : 0;
+			break;
+		}
+
 		case OVS_ACTION_ATTR_USERSPACE:
 			output_userspace(dp, skb, key, a, attr, len);
 			break;
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 856bd8d..fb3e5a3 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -425,6 +425,7 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 	size_t len;
 	unsigned int hlen;
 	int err, dp_ifindex;
+	int cutlen = OVS_CB(skb)->cutlen;
 
 	dp_ifindex = get_dpifindex(dp);
 	if (!dp_ifindex)
@@ -461,6 +462,9 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 	else
 		hlen = skb->len;
 
+	if (cutlen > 0)
+		hlen -= cutlen;
+
 	len = upcall_msg_size(upcall_info, hlen);
 	user_skb = genlmsg_new(len, GFP_ATOMIC);
 	if (!user_skb) {
@@ -515,9 +519,9 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 		err = -ENOBUFS;
 		goto out;
 	}
-	nla->nla_len = nla_attr_size(skb->len);
+	nla->nla_len = nla_attr_size(skb->len - cutlen);
 
-	err = skb_zerocopy(user_skb, skb, skb->len, hlen);
+	err = skb_zerocopy(user_skb, skb, skb->len - cutlen, hlen);
 	if (err)
 		goto out;
 
@@ -531,6 +535,7 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 out:
 	if (err)
 		skb_tx_error(skb);
+	OVS_CB(skb)->cutlen = 0;
 	kfree_skb(user_skb);
 	kfree_skb(nskb);
 	return err;
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 427e39a..fcb1d51 100644
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
+	u16			cutlen;
 };
 #define OVS_CB(skb) ((struct ovs_skb_cb *)(skb)->cb)
 
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
