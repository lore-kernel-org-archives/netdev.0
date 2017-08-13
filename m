From: Liping Zhang <zlpnobody@163.com>
Subject: [PATCH net] openvswitch: fix skb_panic due to the incorrect actions attrlen
Date: Sun, 13 Aug 2017 15:04:20 +0800
Message-ID: <20170813070420.73074-1-zlpnobody@163.com>
Cc: netdev@vger.kernel.org, Liping Zhang <zlpnobody@gmail.com>,
        Neil McKee <neil.mckee@inmon.com>
To: pshelar@nicira.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-132.163.com ([123.125.50.132]:56650 "EHLO m50-132.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750892AbdHMHWm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 13 Aug 2017 03:22:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <zlpnobody@gmail.com>

For sw_flow_actions, the actions_len only represents the kernel part's
size, and when we dump the actions to the userspace, we will do the
convertions, so it's true size may become bigger than the actions_len.

But unfortunately, for OVS_PACKET_ATTR_ACTIONS, we use the actions_len
to alloc the skbuff, so the user_skb's size may become insufficient and
oops will happen like this:
  skbuff: skb_over_panic: text:ffffffff8148fabf len:1749 put:157 head:
  ffff881300f39000 data:ffff881300f39000 tail:0x6d5 end:0x6c0 dev:<NULL>
  ------------[ cut here ]------------
  kernel BUG at net/core/skbuff.c:129!
  [...]
  Call Trace:
   <IRQ>
   [<ffffffff8148be82>] skb_put+0x43/0x44
   [<ffffffff8148fabf>] skb_zerocopy+0x6c/0x1f4
   [<ffffffffa0290d36>] queue_userspace_packet+0x3a3/0x448 [openvswitch]
   [<ffffffffa0292023>] ovs_dp_upcall+0x30/0x5c [openvswitch]
   [<ffffffffa028d435>] output_userspace+0x132/0x158 [openvswitch]
   [<ffffffffa01e6890>] ? ip6_rcv_finish+0x74/0x77 [ipv6]
   [<ffffffffa028e277>] do_execute_actions+0xcc1/0xdc8 [openvswitch]
   [<ffffffffa028e3f2>] ovs_execute_actions+0x74/0x106 [openvswitch]
   [<ffffffffa0292130>] ovs_dp_process_packet+0xe1/0xfd [openvswitch]
   [<ffffffffa0292b77>] ? key_extract+0x63c/0x8d5 [openvswitch]
   [<ffffffffa029848b>] ovs_vport_receive+0xa1/0xc3 [openvswitch]
  [...]

Also we can find that the actions_len is much little than the orig_len:
  crash> struct sw_flow_actions 0xffff8812f539d000
  struct sw_flow_actions {
    rcu = {
      next = 0xffff8812f5398800,
      func = 0xffffe3b00035db32
    },
    orig_len = 1384,
    actions_len = 592,
    actions = 0xffff8812f539d01c
  }

So as a quick fix, use the orig_len instead of the actions_len to alloc
the user_skb.

Last, this oops happened on our system running a relative old kernel, but
the same risk still exists on the mainline, since we use the wrong
actions_len from the beginning.

Fixes: ccea74457bbd ("openvswitch: include datapath actions with sampled-packet upcall to userspace")
Cc: Neil McKee <neil.mckee@inmon.com>
Signed-off-by: Liping Zhang <zlpnobody@gmail.com>
---
 net/openvswitch/actions.c  | 39 +++++++++++++++++++++++++--------------
 net/openvswitch/datapath.c |  2 +-
 net/openvswitch/datapath.h |  1 +
 3 files changed, 27 insertions(+), 15 deletions(-)

diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
index e4610676299b..799a22dfb89e 100644
--- a/net/openvswitch/actions.c
+++ b/net/openvswitch/actions.c
@@ -48,6 +48,7 @@ struct deferred_action {
 	struct sk_buff *skb;
 	const struct nlattr *actions;
 	int actions_len;
+	int actions_attrlen;
 
 	/* Store pkt_key clone when creating deferred action. */
 	struct sw_flow_key pkt_key;
@@ -135,7 +136,8 @@ static struct deferred_action *action_fifo_put(struct action_fifo *fifo)
 static struct deferred_action *add_deferred_actions(struct sk_buff *skb,
 				    const struct sw_flow_key *key,
 				    const struct nlattr *actions,
-				    const int actions_len)
+				    const int actions_len,
+				    const int actions_attrlen)
 {
 	struct action_fifo *fifo;
 	struct deferred_action *da;
@@ -146,6 +148,7 @@ static struct deferred_action *add_deferred_actions(struct sk_buff *skb,
 		da->skb = skb;
 		da->actions = actions;
 		da->actions_len = actions_len;
+		da->actions_attrlen = actions_attrlen;
 		da->pkt_key = *key;
 	}
 
@@ -166,6 +169,7 @@ static int clone_execute(struct datapath *dp, struct sk_buff *skb,
 			 struct sw_flow_key *key,
 			 u32 recirc_id,
 			 const struct nlattr *actions, int len,
+			 int actions_attrlen,
 			 bool last, bool clone_flow_key);
 
 static void update_ethertype(struct sk_buff *skb, struct ethhdr *hdr,
@@ -880,7 +884,7 @@ static void do_output(struct datapath *dp, struct sk_buff *skb, int out_port,
 static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 			    struct sw_flow_key *key, const struct nlattr *attr,
 			    const struct nlattr *actions, int actions_len,
-			    uint32_t cutlen)
+			    int actions_attrlen, uint32_t cutlen)
 {
 	struct dp_upcall_info upcall;
 	const struct nlattr *a;
@@ -921,6 +925,7 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
 			/* Include actions. */
 			upcall.actions = actions;
 			upcall.actions_len = actions_len;
+			upcall.actions_attrlen = actions_attrlen;
 			break;
 		}
 
@@ -936,7 +941,7 @@ static int output_userspace(struct datapath *dp, struct sk_buff *skb,
  */
 static int sample(struct datapath *dp, struct sk_buff *skb,
 		  struct sw_flow_key *key, const struct nlattr *attr,
-		  bool last)
+		  int actions_attrlen, bool last)
 {
 	struct nlattr *actions;
 	struct nlattr *sample_arg;
@@ -957,8 +962,8 @@ static int sample(struct datapath *dp, struct sk_buff *skb,
 	}
 
 	clone_flow_key = !arg->exec;
-	return clone_execute(dp, skb, key, 0, actions, rem, last,
-			     clone_flow_key);
+	return clone_execute(dp, skb, key, 0, actions, rem, actions_attrlen,
+			     last, clone_flow_key);
 }
 
 static void execute_hash(struct sk_buff *skb, struct sw_flow_key *key,
@@ -1083,13 +1088,14 @@ static int execute_recirc(struct datapath *dp, struct sk_buff *skb,
 	BUG_ON(!is_flow_key_valid(key));
 
 	recirc_id = nla_get_u32(a);
-	return clone_execute(dp, skb, key, recirc_id, NULL, 0, last, true);
+	return clone_execute(dp, skb, key, recirc_id, NULL, 0, 0, last, true);
 }
 
 /* Execute a list of actions against 'skb'. */
 static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 			      struct sw_flow_key *key,
-			      const struct nlattr *attr, int len)
+			      const struct nlattr *attr, int len,
+			      int actions_attrlen)
 {
 	const struct nlattr *a;
 	int rem;
@@ -1130,8 +1136,8 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 		}
 
 		case OVS_ACTION_ATTR_USERSPACE:
-			output_userspace(dp, skb, key, a, attr,
-						     len, OVS_CB(skb)->cutlen);
+			output_userspace(dp, skb, key, a, attr, len,
+					 actions_attrlen, OVS_CB(skb)->cutlen);
 			OVS_CB(skb)->cutlen = 0;
 			break;
 
@@ -1181,7 +1187,7 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 		case OVS_ACTION_ATTR_SAMPLE: {
 			bool last = nla_is_last(a, rem);
 
-			err = sample(dp, skb, key, a, last);
+			err = sample(dp, skb, key, a, actions_attrlen, last);
 			if (last)
 				return err;
 
@@ -1231,6 +1237,7 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 static int clone_execute(struct datapath *dp, struct sk_buff *skb,
 			 struct sw_flow_key *key, u32 recirc_id,
 			 const struct nlattr *actions, int len,
+			 int actions_attrlen,
 			 bool last, bool clone_flow_key)
 {
 	struct deferred_action *da;
@@ -1258,7 +1265,8 @@ static int clone_execute(struct datapath *dp, struct sk_buff *skb,
 				__this_cpu_inc(exec_actions_level);
 
 			err = do_execute_actions(dp, skb, clone,
-						 actions, len);
+						 actions, len,
+						 actions_attrlen);
 
 			if (clone_flow_key)
 				__this_cpu_dec(exec_actions_level);
@@ -1270,7 +1278,7 @@ static int clone_execute(struct datapath *dp, struct sk_buff *skb,
 	}
 
 	/* Out of 'flow_keys' space. Defer actions */
-	da = add_deferred_actions(skb, key, actions, len);
+	da = add_deferred_actions(skb, key, actions, len, actions_attrlen);
 	if (da) {
 		if (!actions) { /* Recirc action */
 			key = &da->pkt_key;
@@ -1309,10 +1317,12 @@ static void process_deferred_actions(struct datapath *dp)
 		struct sk_buff *skb = da->skb;
 		struct sw_flow_key *key = &da->pkt_key;
 		const struct nlattr *actions = da->actions;
+		int actions_attrlen = da->actions_attrlen;
 		int actions_len = da->actions_len;
 
 		if (actions)
-			do_execute_actions(dp, skb, key, actions, actions_len);
+			do_execute_actions(dp, skb, key, actions, actions_len,
+					   actions_attrlen);
 		else
 			ovs_dp_process_packet(skb, key);
 	} while (!action_fifo_is_empty(fifo));
@@ -1338,7 +1348,8 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb,
 	}
 
 	err = do_execute_actions(dp, skb, key,
-				 acts->actions, acts->actions_len);
+				 acts->actions, acts->actions_len,
+				 acts->orig_len);
 
 	if (level == 1)
 		process_deferred_actions(dp);
diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 45fe8c8a884d..66162e64e8b5 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -398,7 +398,7 @@ static size_t upcall_msg_size(const struct dp_upcall_info *upcall_info,
 
 	/* OVS_PACKET_ATTR_ACTIONS */
 	if (upcall_info->actions_len)
-		size += nla_total_size(upcall_info->actions_len);
+		size += nla_total_size(upcall_info->actions_attrlen);
 
 	/* OVS_PACKET_ATTR_MRU */
 	if (upcall_info->mru)
diff --git a/net/openvswitch/datapath.h b/net/openvswitch/datapath.h
index 5d8dcd88815f..d7dfba5893b4 100644
--- a/net/openvswitch/datapath.h
+++ b/net/openvswitch/datapath.h
@@ -124,6 +124,7 @@ struct dp_upcall_info {
 	const struct nlattr *userdata;
 	const struct nlattr *actions;
 	int actions_len;
+	int actions_attrlen;
 	u32 portid;
 	u8 cmd;
 	u16 mru;
-- 
2.13.0
