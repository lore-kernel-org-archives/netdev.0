From: Joe Stringer <joestringer@nicira.com>
Subject: [RFCv2 net-next 7/7] openvswitch: Support fragmented IPv4 packets for conntrack
Date: Mon,  2 Mar 2015 13:55:05 -0800
Message-ID: <1425333305-19702-8-git-send-email-joestringer@nicira.com>
References: <1425333305-19702-1-git-send-email-joestringer@nicira.com>
Cc: Andy Zhou <azhou@nicira.com>, linux-kernel@vger.kernel.org,
	Justin Pettit <jpettit@nicira.com>,
	Thomas Graf <tgraf@suug.ch>, Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog128.obsmtp.com ([74.125.149.141]:42473 "HELO
	na3sys009aog128.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753786AbbCBVzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 16:55:49 -0500
Received: by mail-pd0-f174.google.com with SMTP id y10so42682051pdj.13
        for <netdev@vger.kernel.org>; Mon, 02 Mar 2015 13:55:47 -0800 (PST)
In-Reply-To: <1425333305-19702-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Zhou <azhou@nicira.com>

The conntrack action now re-assembles fragmented IPv4 packets and only
send a fully re-assembled IP packet to nf_conntrack layer.

When a re-assembled IP frame hits the output action. The output action
will re fragment them into IP fragments based on this packets' incoming
fragment size.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 include/uapi/linux/openvswitch.h |    5 ++-
 net/openvswitch/actions.c        |   78 ++++++++++++++++++++++++++++++++++----
 net/openvswitch/conntrack.c      |   43 ++++++++++++++++++++-
 net/openvswitch/datapath.c       |   40 ++++++++++++++++---
 net/openvswitch/datapath.h       |    6 +++
 net/openvswitch/vport.c          |    1 +
 6 files changed, 157 insertions(+), 16 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index 30d70a3..b947544 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -162,7 +162,9 @@ enum ovs_packet_cmd {
  * %OVS_USERSPACE_ATTR_EGRESS_TUN_PORT attribute, which is sent only if the
  * output port is actually a tunnel port. Contains the output tunnel key
  * extracted from the packet as nested %OVS_TUNNEL_KEY_ATTR_* attributes.
- *
+ * @OVS_PACKET_ATTR_MRU: Present for an %OVS_PACKET_CMD_ACTION and
+ * %OVS_PACKET_ATTR_USERSPACE action specify the Maximum received fragment
+ * size.
  * These attributes follow the &struct ovs_header within the Generic Netlink
  * payload for %OVS_PACKET_* commands.
  */
@@ -178,6 +180,7 @@ enum ovs_packet_attr {
 	OVS_PACKET_ATTR_UNUSED2,
 	OVS_PACKET_ATTR_PROBE,      /* Packet operation is a feature probe,
 				       error logging should be suppressed. */
+	OVS_PACKET_ATTR_MRU,          /* Maximum received IP fragment size. */
 	__OVS_PACKET_ATTR_MAX
 };
 
diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 9bd9f99..789e53a 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -53,6 +53,11 @@ struct deferred_action {
 	struct sw_flow_key pkt_key;
 };
 
+struct vport_frag_output_info {
+	struct vport *vport;
+	struct sw_flow_key *key;
+};
+
 #define DEFERRED_ACTION_FIFO_SIZE 10
 struct action_fifo {
 	int head;
@@ -595,14 +600,67 @@ static int set_sctp(struct sk_buff *skb, struct sw_flow_key *flow_key,
 	return 0;
 }
 
-static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port)
+/* Given an IP frame, reconstruct its MAC header based on flow.  */
+int ovs_setup_l2_header(struct sk_buff *skb, struct sw_flow_key *key)
+{
+	int err;
+
+	err = skb_ensure_writable(skb, ETH_HLEN);
+	if (unlikely(err))
+		return err;
+
+	__skb_push(skb, ETH_HLEN);
+	skb_reset_mac_header(skb);
+
+	ether_addr_copy(eth_hdr(skb)->h_source, key->eth.src);
+	ether_addr_copy(eth_hdr(skb)->h_dest, key->eth.dst);
+	eth_hdr(skb)->h_proto = key->eth.type;
+
+	return 0;
+}
+
+static int ovs_vport_output(struct sk_buff *skb, void *output_arg)
+{
+	struct vport_frag_output_info *arg =
+		(struct vport_frag_output_info *)output_arg;
+	struct sw_flow_key *key = arg->key;
+	struct vport *vport = arg->vport;
+	int err;
+
+	err = ovs_setup_l2_header(skb, key);
+	if (err) {
+		kfree_skb(skb);
+		return err;
+	}
+	ovs_vport_send(vport, skb);
+
+	return 0;
+}
+
+static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port,
+		      struct sw_flow_key *key)
 {
 	struct vport *vport = ovs_vport_rcu(dp, out_port);
+	unsigned int mru = OVS_CB(skb)->mru;
 
-	if (likely(vport))
-		ovs_vport_send(vport, skb);
-	else
+	if (likely(vport)) {
+		if (!mru || (skb->len <= mru + ETH_HLEN)) {
+			ovs_vport_send(vport, skb);
+		} else if (key->eth.type == htons(ETH_P_IP)) {
+			struct vport_frag_output_info arg;
+			unsigned int mtu = mru;
+
+			arg.vport = vport;
+			arg.key = key;
+
+			skb_pull(skb, ETH_HLEN);
+
+			ip_fragment_mtu(skb, mtu, LL_MAX_HEADER, NULL, &arg,
+					ovs_vport_output);
+		}
+	} else {
 		kfree_skb(skb);
+	}
 }
 
 static int output_userspace(struct datapath *dp, struct sk_buff *skb,
@@ -617,6 +675,7 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 	upcall.userdata = NULL;
 	upcall.portid = 0;
 	upcall.egress_tun_info = NULL;
+	upcall.mru = OVS_CB(skb)->mru;
 
 	for (a = nla_data(attr), rem = nla_len(attr); rem > 0;
 		 a = nla_next(a, &rem)) {
@@ -865,7 +924,7 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			struct sk_buff *out_skb = skb_clone(skb, GFP_ATOMIC);
 
 			if (out_skb)
-				do_output(dp, out_skb, prev_port);
+				do_output(dp, out_skb, prev_port, key);
 
 			prev_port = -1;
 		}
@@ -929,13 +988,18 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 		}
 
 		if (unlikely(err)) {
-			kfree_skb(skb);
+			/* Hide stolen fragments from user space. */
+			if (err == -EINPROGRESS)
+				err = 0;
+			else
+				kfree_skb(skb);
+
 			return err;
 		}
 	}
 
 	if (prev_port != -1)
-		do_output(dp, skb, prev_port);
+		do_output(dp, skb, prev_port, key);
 	else
 		consume_skb(skb);
 
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 93d76a5..793d489 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -178,21 +178,60 @@ static int ovs_ct_lookup(struct net *net, u16 zone, struct sw_flow_key *key,
 	return err;
 }
 
+static int handle_fragments(struct net *net, u16 zone, struct sk_buff *skb,
+			    struct sw_flow_key *key)
+{
+	if (key->eth.type == htons(ETH_P_IP)) {
+		if (ip_is_fragment(ip_hdr(skb))) {
+			struct ovs_skb_cb ovs_cb = *OVS_CB(skb);
+			int nh_ofs = skb_network_offset(skb);
+			enum ip_defrag_users user;
+			unsigned int mru;
+			int err;
+
+			memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
+			user = IP_DEFRAG_CONNTRACK_IN + zone;
+			skb_pull(skb, nh_ofs);
+			err = ip_defrag_net(net, skb, user, &mru);
+			if (err)
+				return err;
+
+			/* Got a reassembled IP frame */
+			skb_clear_hash(skb);
+			ip_send_check(ip_hdr(skb));
+			skb->ignore_df = 1;
+			err = ovs_setup_l2_header(skb, key);
+			if (err)
+				return err;
+
+			ovs_cb.mru = mru;
+			*OVS_CB(skb) = ovs_cb;
+		}
+	} /* XXX Handle IPv6 */
+
+	return 0;
+}
+
 int ovs_ct_execute(struct sk_buff *skb, struct sw_flow_key *key,
 		   const struct ovs_conntrack_info *info)
 {
 	struct net *net;
-	int nh_ofs = skb_network_offset(skb);
 	struct nf_conn *tmpl = info->ct;
-	int err = -EINVAL;
+	int nh_ofs, err;
 
 	net = ovs_get_net(skb);
 	if (IS_ERR(net))
 		return PTR_ERR(net);
 
+	err = handle_fragments(net, info->zone, skb, key);
+	if (err)
+		return err;
+
 	/* The conntrack module expects to be working at L3. */
+	nh_ofs = skb_network_offset(skb);
 	skb_pull(skb, nh_ofs);
 
+	err = -EINVAL;
 	if (ovs_ct_lookup__(net, tmpl, key, skb))
 		goto err_push_skb;
 
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 46f67ee..1340f21 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -277,6 +277,7 @@ void ovs_dp_process_packet(struct sk_buff *skb, struct sw_flow_key *key)
 		upcall.userdata = NULL;
 		upcall.portid = ovs_vport_find_upcall_portid(p, skb);
 		upcall.egress_tun_info = NULL;
+		upcall.mru = OVS_CB(skb)->mru;
 		error = ovs_dp_upcall(dp, skb, key, &upcall);
 		if (unlikely(error))
 			kfree_skb(skb);
@@ -398,9 +399,23 @@ static size_t upcall_msg_size(const struct dp_upcall_info *upcall_info,
 	if (upcall_info->egress_tun_info)
 		size += nla_total_size(ovs_tun_key_attr_size());
 
+	/* OVS_PACKET_ATTR_MRU */
+	if (upcall_info->mru)
+		size += nla_total_size(sizeof(unsigned int));
+
 	return size;
 }
 
+static void pad_packet(struct datapath *dp, struct sk_buff *skb)
+{
+	if (!(dp->user_features & OVS_DP_F_UNALIGNED)) {
+		size_t plen = NLA_ALIGN(skb->len) - skb->len;
+
+		if (plen > 0)
+			memset(skb_put(skb, plen), 0, plen);
+	}
+}
+
 static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 				  const struct sw_flow_key *key,
 				  const struct dp_upcall_info *upcall_info)
@@ -479,6 +494,16 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 		nla_nest_end(user_skb, nla);
 	}
 
+	/* Add OVS_PACKET_ATTR_MRU */
+	if (upcall_info->mru) {
+		if (nla_put_u16(user_skb, OVS_PACKET_ATTR_MRU,
+				upcall_info->mru)) {
+			err = -ENOBUFS;
+			goto out;
+		}
+		pad_packet(dp, user_skb);
+	}
+
 	/* Only reserve room for attribute header, packet data is added
 	 * in skb_zerocopy() */
 	if (!(nla = nla_reserve(user_skb, OVS_PACKET_ATTR_PACKET, 0))) {
@@ -492,12 +517,7 @@ static int queue_userspace_packet(struct datapath *dp, struct sk_buff *skb,
 		goto out;
 
 	/* Pad OVS_PACKET_ATTR_PACKET if linear copy was performed */
-	if (!(dp->user_features & OVS_DP_F_UNALIGNED)) {
-		size_t plen = NLA_ALIGN(user_skb->len) - user_skb->len;
-
-		if (plen > 0)
-			memset(skb_put(user_skb, plen), 0, plen);
-	}
+	pad_packet(dp, user_skb);
 
 	((struct nlmsghdr *) user_skb->data)->nlmsg_len = user_skb->len;
 
@@ -526,6 +546,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	int len;
 	int err;
 	bool log = !a[OVS_PACKET_ATTR_PROBE];
+	unsigned int mru;
 
 	err = -EINVAL;
 	if (!a[OVS_PACKET_ATTR_PACKET] || !a[OVS_PACKET_ATTR_KEY] ||
@@ -552,6 +573,12 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	else
 		packet->protocol = htons(ETH_P_802_2);
 
+	/* Set packet's mru */
+	mru = 0;
+	if (a[OVS_PACKET_ATTR_MRU])
+		mru = nla_get_u16(a[OVS_PACKET_ATTR_MRU]);
+	OVS_CB(packet)->mru = mru;
+
 	/* Build an sw_flow for sending this packet. */
 	flow = ovs_flow_alloc();
 	err = PTR_ERR(flow);
@@ -612,6 +639,7 @@ static const struct nla_policy packet_policy[OVS_PACKET_ATTR_MAX + 1] = {
 	[OVS_PACKET_ATTR_KEY] = { .type = NLA_NESTED },
 	[OVS_PACKET_ATTR_ACTIONS] = { .type = NLA_NESTED },
 	[OVS_PACKET_ATTR_PROBE] = { .type = NLA_FLAG },
+	[OVS_PACKET_ATTR_MRU] = { .type = NLA_U16 },
 };
 
 static const struct genl_ops dp_packet_genl_ops[] = {
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 9661a01..cfbdda1 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -98,10 +98,13 @@ struct datapath {
  * NULL if the packet is not being tunneled.
  * @input_vport: The original vport packet came in on. This value is cached
  * when a packet is received by OVS.
+ * @mru: The maximum received fragement size; 0 if the packet is not
+ * fragmented.
  */
 struct ovs_skb_cb {
 	struct ovs_tunnel_info  *egress_tun_info;
 	struct vport		*input_vport;
+	unsigned int		mru;
 };
 #define OVS_CB(skb) ((struct ovs_skb_cb *)(skb)->cb)
 
@@ -114,12 +117,14 @@ struct ovs_skb_cb {
  * then no packet is sent and the packet is accounted in the datapath's @n_lost
  * counter.
  * @egress_tun_info: If nonnull, becomes %OVS_PACKET_ATTR_EGRESS_TUN_KEY.
+ * @mru: If not zero, Maximum received IP fragment size.
  */
 struct dp_upcall_info {
 	const struct ovs_tunnel_info *egress_tun_info;
 	const struct nlattr *userdata;
 	u32 portid;
 	u8 cmd;
+	unsigned int mru;
 };
 
 /**
@@ -198,6 +203,7 @@ void ovs_dp_notify_wq(struct work_struct *work);
 
 int action_fifos_init(void);
 void action_fifos_exit(void);
+int ovs_setup_l2_header(struct sk_buff *skb, struct sw_flow_key *key);
 
 /* 'KEY' must not have any bits set outside of the 'MASK' */
 #define OVS_MASKED(OLD, KEY, MASK) ((KEY) | ((OLD) & ~(MASK)))
diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index ec2954f..184dd51 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -486,6 +486,7 @@ void ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
 
 	OVS_CB(skb)->input_vport = vport;
 	OVS_CB(skb)->egress_tun_info = NULL;
+	OVS_CB(skb)->mru = 0;
 	/* Extract flow from 'skb' into 'key'. */
 	error = ovs_flow_key_extract(tun_info, skb, &key);
 	if (unlikely(error)) {
-- 
1.7.10.4
