From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net v2] ovs: add recursion limit to ovs_vport_receive
Date: Fri, 15 Jan 2016 00:05:55 +0100
Message-ID: <1452812755-14018-1-git-send-email-hannes@stressinduktion.org>
Cc: dev@openvswitch.org, Pravin Shelar <pshelar@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:37157 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756966AbcANXGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 18:06:04 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id 162E0203A3
	for <netdev@vger.kernel.org>; Thu, 14 Jan 2016 18:06:03 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It was seen that defective configurations of openvswitch could overwrite
the STACK_END_MAGIC and cause a hard crash of the kernel because of too
many recursions within ovs.

This problem arises due to the high stack usage of openvswitch. The rest
of the kernel is fine with the current limit of 10 (RECURSION_LIMIT).
Thus add an extra recursion limit counter for ovs_vport_receive until
parts of the stack usage is moved to percpu scratch space.

Cc: Pravin Shelar <pshelar@ovn.org>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
v2) add preemption protection

 net/openvswitch/vport.c | 20 ++++++++++++++++++--
 1 file changed, 18 insertions(+), 2 deletions(-)

diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index 31cbc8c5c7db82..238fe435ca5877 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -426,6 +426,9 @@ u32 ovs_vport_find_upcall_portid(const struct vport *vport, struct sk_buff *skb)
 	return ids->ids[ids_index];
 }
 
+static DEFINE_PER_CPU(int, ovs_recursion);
+static const int ovs_recursion_limit = 8;
+
 /**
  *	ovs_vport_receive - pass up received packet to the datapath for processing
  *
@@ -442,6 +445,15 @@ int ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
 	struct sw_flow_key key;
 	int error;
 
+	preempt_disable();
+	if (__this_cpu_inc_return(ovs_recursion) > ovs_recursion_limit) {
+		net_crit_ratelimited("ovs: recursion limit reached on datapath %s, probable configuration error\n",
+				     ovs_dp_name(vport->dp));
+		error = -ENETDOWN;
+		kfree_skb(skb);
+		goto out;
+	}
+
 	OVS_CB(skb)->input_vport = vport;
 	OVS_CB(skb)->mru = 0;
 	if (unlikely(dev_net(skb->dev) != ovs_dp_get_net(vport->dp))) {
@@ -457,10 +469,14 @@ int ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
 	error = ovs_flow_key_extract(tun_info, skb, &key);
 	if (unlikely(error)) {
 		kfree_skb(skb);
-		return error;
+		goto out;
 	}
+
 	ovs_dp_process_packet(skb, &key);
-	return 0;
+out:
+	__this_cpu_dec(ovs_recursion);
+	preempt_enable();
+	return error;
 }
 EXPORT_SYMBOL_GPL(ovs_vport_receive);
 
-- 
2.5.0
