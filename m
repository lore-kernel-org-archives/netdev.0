From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v3 1/5] openvswitch: Remove pkt_key from OVS_CB
Date: Tue, 16 Sep 2014 00:23:36 -0700
Message-ID: <1410852216-1485-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog120.obsmtp.com ([74.125.149.140]:39907 "HELO
	na3sys009aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752485AbaIPHXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 03:23:09 -0400
Received: by mail-pa0-f45.google.com with SMTP id rd3so8223394pab.32
        for <netdev@vger.kernel.org>; Tue, 16 Sep 2014 00:23:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OVS keeps pointer to packet key in skb->cb, but the packet key is
store on stack. This could make code bit tricky. So it is better to
get rid of the pointer.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/actions.c  | 22 ++++++++++++----------
 net/openvswitch/datapath.c |  6 ++----
 net/openvswitch/datapath.h |  5 ++---
 3 files changed, 16 insertions(+), 17 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 5231652..8a1eb56 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -38,6 +38,7 @@
 #include "vport.h"
 
 static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
+			      struct sw_flow_key *key,
 			      const struct nlattr *attr, int len);
 
 static int make_writable(struct sk_buff *skb, int write_len)
@@ -410,16 +411,14 @@ static int do_output(struct datapath *dp, struct sk_buff *skb, int out_port)
 }
 
 static int output_userspace(struct datapath *dp, struct sk_buff *skb,
-			    const struct nlattr *attr)
+			    struct sw_flow_key *key, const struct nlattr *attr)
 {
 	struct dp_upcall_info upcall;
 	const struct nlattr *a;
 	int rem;
 
-	BUG_ON(!OVS_CB(skb)->pkt_key);
-
 	upcall.cmd = OVS_PACKET_CMD_ACTION;
-	upcall.key = OVS_CB(skb)->pkt_key;
+	upcall.key = key;
 	upcall.userdata = NULL;
 	upcall.portid = 0;
 
@@ -445,7 +444,7 @@ static bool last_action(const struct nlattr *a, int rem)
 }
 
 static int sample(struct datapath *dp, struct sk_buff *skb,
-		  const struct nlattr *attr)
+		  struct sw_flow_key *key, const struct nlattr *attr)
 {
 	const struct nlattr *acts_list = NULL;
 	const struct nlattr *a;
@@ -493,7 +492,7 @@ static int sample(struct datapath *dp, struct sk_buff *skb,
 	 * return the error code and let the caller (also
 	 * do_execute_actions()) free skb on error.
 	 */
-	return do_execute_actions(dp, sample_skb, a, rem);
+	return do_execute_actions(dp, sample_skb, key, a, rem);
 }
 
 static int execute_set_action(struct sk_buff *skb,
@@ -544,6 +543,7 @@ static int execute_set_action(struct sk_buff *skb,
 
 /* Execute a list of actions against 'skb'. */
 static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
+			      struct sw_flow_key *key,
 			      const struct nlattr *attr, int len)
 {
 	/* Every output action needs a separate clone of 'skb', but the common
@@ -569,7 +569,7 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			break;
 
 		case OVS_ACTION_ATTR_USERSPACE:
-			output_userspace(dp, skb, a);
+			output_userspace(dp, skb, key, a);
 			break;
 
 		case OVS_ACTION_ATTR_PUSH_VLAN:
@@ -587,7 +587,7 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			break;
 
 		case OVS_ACTION_ATTR_SAMPLE:
-			err = sample(dp, skb, a);
+			err = sample(dp, skb, key, a);
 			if (unlikely(err)) /* skb already freed. */
 				return err;
 			break;
@@ -608,10 +608,12 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 }
 
 /* Execute a list of actions against 'skb'. */
-int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb)
+int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb,
+			struct sw_flow_key *key)
 {
 	struct sw_flow_actions *acts = rcu_dereference(OVS_CB(skb)->flow->sf_acts);
 
 	OVS_CB(skb)->tun_key = NULL;
-	return do_execute_actions(dp, skb, acts->actions, acts->actions_len);
+	return do_execute_actions(dp, skb, key,
+				  acts->actions, acts->actions_len);
 }
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 91d66b7..458096d 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -275,10 +275,9 @@ void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
 	}
 
 	OVS_CB(skb)->flow = flow;
-	OVS_CB(skb)->pkt_key = &key;
 
 	ovs_flow_stats_update(OVS_CB(skb)->flow, key.tp.flags, skb);
-	ovs_execute_actions(dp, skb);
+	ovs_execute_actions(dp, skb, &key);
 	stats_counter = &stats->n_hit;
 
 out:
@@ -568,7 +567,6 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 		goto err_flow_free;
 
 	OVS_CB(packet)->flow = flow;
-	OVS_CB(packet)->pkt_key = &flow->key;
 	packet->priority = flow->key.phy.priority;
 	packet->mark = flow->key.phy.skb_mark;
 
@@ -579,7 +577,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 		goto err_unlock;
 
 	local_bh_disable();
-	err = ovs_execute_actions(dp, packet);
+	err = ovs_execute_actions(dp, packet, &flow->key);
 	local_bh_enable();
 	rcu_read_unlock();
 
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 701b573..b576483 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -95,13 +95,11 @@ struct datapath {
 /**
  * struct ovs_skb_cb - OVS data in skb CB
  * @flow: The flow associated with this packet.  May be %NULL if no flow.
- * @pkt_key: The flow information extracted from the packet.  Must be nonnull.
  * @tun_key: Key for the tunnel that encapsulated this packet. NULL if the
  * packet is not being tunneled.
  */
 struct ovs_skb_cb {
 	struct sw_flow		*flow;
-	struct sw_flow_key	*pkt_key;
 	struct ovs_key_ipv4_tunnel  *tun_key;
 };
 #define OVS_CB(skb) ((struct ovs_skb_cb *)(skb)->cb)
@@ -191,7 +189,8 @@ int ovs_dp_upcall(struct datapath *, struct sk_buff *,
 struct sk_buff *ovs_vport_cmd_build_info(struct vport *, u32 pid, u32 seq,
 					 u8 cmd);
 
-int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb);
+int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb,
+			struct sw_flow_key *);
 void ovs_dp_notify_wq(struct work_struct *work);
 
 #define OVS_NLERR(fmt, ...)					\
-- 
1.9.3
