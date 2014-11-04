From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 11/14] openvswitch: Remove flow member from struct ovs_skb_cb
Date: Mon,  3 Nov 2014 22:01:56 -0800
Message-ID: <1415080916-1953-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Lorand Jakab <lojakab@cisco.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog002.obsmtp.com ([74.125.150.44]:54765 "HELO
	na6sys009bog002.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752167AbaKEUCJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 15:02:09 -0500
Received: by mail-pd0-f177.google.com with SMTP id v10so1364892pde.36
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 12:02:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorand Jakab <lojakab@cisco.com>

The 'flow' memeber was chosen for removal because it's only used
in ovs_execute_actions() we can pass it as argument to this
function.

Signed-off-by: Lorand Jakab <lojakab@cisco.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 net/openvswitch/actions.c  |  5 +----
 net/openvswitch/datapath.c | 12 +++++++-----
 net/openvswitch/datapath.h |  4 +---
 3 files changed, 9 insertions(+), 12 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index 9fd33c0..f7e5891 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -865,14 +865,11 @@ static void process_deferred_actions(struct datapath *dp)
 
 /* Execute a list of actions against 'skb'. */
 int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb,
-			struct sw_flow_key *key)
+			struct sw_flow_actions *acts, struct sw_flow_key *key)
 {
 	int level = this_cpu_read(exec_actions_level);
-	struct sw_flow_actions *acts;
 	int err;
 
-	acts = rcu_dereference(OVS_CB(skb)->flow->sf_acts);
-
 	this_cpu_inc(exec_actions_level);
 	OVS_CB(skb)->egress_tun_info = NULL;
 	err = do_execute_actions(dp, skb, key,
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index cdbc44c..4fd8a45 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -257,6 +257,7 @@ void ovs_dp_process_packet(struct sk_buff *skb, struct sw_flow_key *key)
 	const struct vport *p = OVS_CB(skb)->input_vport;
 	struct datapath *dp = p->dp;
 	struct sw_flow *flow;
+	struct sw_flow_actions *sf_acts;
 	struct dp_stats_percpu *stats;
 	u64 *stats_counter;
 	u32 n_mask_hit;
@@ -282,10 +283,10 @@ void ovs_dp_process_packet(struct sk_buff *skb, struct sw_flow_key *key)
 		goto out;
 	}
 
-	OVS_CB(skb)->flow = flow;
+	ovs_flow_stats_update(flow, key->tp.flags, skb);
+	sf_acts = rcu_dereference(flow->sf_acts);
+	ovs_execute_actions(dp, skb, sf_acts, key);
 
-	ovs_flow_stats_update(OVS_CB(skb)->flow, key->tp.flags, skb);
-	ovs_execute_actions(dp, skb, key);
 	stats_counter = &stats->n_hit;
 
 out:
@@ -524,6 +525,7 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	struct sw_flow_actions *acts;
 	struct sk_buff *packet;
 	struct sw_flow *flow;
+	struct sw_flow_actions *sf_acts;
 	struct datapath *dp;
 	struct ethhdr *eth;
 	struct vport *input_vport;
@@ -579,7 +581,6 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	rcu_assign_pointer(flow->sf_acts, acts);
 
 	OVS_CB(packet)->egress_tun_info = NULL;
-	OVS_CB(packet)->flow = flow;
 	packet->priority = flow->key.phy.priority;
 	packet->mark = flow->key.phy.skb_mark;
 
@@ -597,9 +598,10 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 		goto err_unlock;
 
 	OVS_CB(packet)->input_vport = input_vport;
+	sf_acts = rcu_dereference(flow->sf_acts);
 
 	local_bh_disable();
-	err = ovs_execute_actions(dp, packet, &flow->key);
+	err = ovs_execute_actions(dp, packet, sf_acts, &flow->key);
 	local_bh_enable();
 	rcu_read_unlock();
 
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 9741354..1c56a80 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -94,14 +94,12 @@ struct datapath {
 
 /**
  * struct ovs_skb_cb - OVS data in skb CB
- * @flow: The flow associated with this packet.  May be %NULL if no flow.
  * @egress_tun_key: Tunnel information about this packet on egress path.
  * NULL if the packet is not being tunneled.
  * @input_vport: The original vport packet came in on. This value is cached
  * when a packet is received by OVS.
  */
 struct ovs_skb_cb {
-	struct sw_flow		*flow;
 	struct ovs_tunnel_info  *egress_tun_info;
 	struct vport		*input_vport;
 };
@@ -194,7 +192,7 @@ struct sk_buff *ovs_vport_cmd_build_info(struct vport *, u32 pid, u32 seq,
 					 u8 cmd);
 
 int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb,
-			struct sw_flow_key *);
+			struct sw_flow_actions *acts, struct sw_flow_key *);
 
 void ovs_dp_notify_wq(struct work_struct *work);
 
-- 
1.9.3
