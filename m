From: Simon Horman <horms@verge.net.au>
Subject: [PATCH v16 1/4] Add packet recirculation
Date: Tue, 30 Jul 2013 10:14:30 +0900
Message-ID: <1375146873-3192-2-git-send-email-horms@verge.net.au>
References: <1375146873-3192-1-git-send-email-horms@verge.net.au>
Cc: Ravi K <rkerur@gmail.com>, Isaku Yamahata <yamahata@valinux.co.jp>,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	jarno.rajahalme@nsn.com, Joe Stringer <joe@wand.net.nz>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:39567 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754220Ab3G3BPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jul 2013 21:15:36 -0400
In-Reply-To: <1375146873-3192-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recirculation is a technique to allow a frame to re-enter
frame processing. This is intended to be used after actions
have been applied to the frame with modify the frame in
some way that makes it possible for richer processing to occur.

An example is and indeed targeted use case is MPLS. If an MPLS frame has an
mpls_pop action applied with the IPv4 ethernet type then it becomes
possible to decode the IPv4 portion of the frame. This may be used to
construct a facet that modifies the IPv4 portion of the frame. This is not
possible prior to the mpls_pop action as the contents of the frame after
the MPLS stack is not known to be IPv4.

Design:
* New recirculation action.

  ovs-vswitchd adds a recirculation action to the end of a list of
  datapath actions for a flow when the actions are truncated because
  insufficient flow match information is available to add the next
  OpenFlow action.  The recirculation action is preceded by an action
  to set the skb_mark to an id which can be used to scope a facet lookup
  of a recirculated packet.

  e.g.  pop_mpls(0x0800),dec_ttl becomes pop_mpls(0x800),set(skb_mark(id)),recirculate

* Datapath behaviour

  Then the datapath encounters a recirculate action it:
  + Recalculates the flow key based on the packet
    which will typically have been modified by previous actions
  + As the recirculate action is preceded by a set(skb_mark(id)) action,
    the new match key will now include skb_mark=id.
  + Performs a lookup using the new match key
  + Processes the packet if a facet matches the key or;
  + Makes an upcall if necessary

* No facet behaviour

  + Loop:
    1) translate actions
    2) If there is a recirculate action, execute packet
       and go back to 1) for remaining actions.

Co-Authored-by: Joe Stringer <joe@wand.net.nz>
Signed-off-by: Simon Horman <horms@verge.net.au>

---

Change Log:

v16
* Ensure that locks are released and memory freed in the case
  of recirculation in dpif_netdev_execute()
* Separate controller and MPLS tests
  - MPLS adds a number of tests and there are already a number
    of controller tests. It seems to make sense to separate them.
* Do not add reference count to facet
  - This does not appear to be necessary any more as situations
    where the parent-facet of a recirculated child-facet does not exist
    may be handled using the drop rule.
* Do not add 'strict' parameter from get_facet_chain.
  This is no longer useful as recirculated facets chains
  may me incomplete if parent-facets may be removed before child-facets.
  This is quite possible now that there is no reference count.
* Clarify comments relating to recirculated facet chain revalidation

v15
* Rebase for ofproto-dpif-xlate modularization
* Replace rule pointers in facet with offsets
 - Use rule offset to determine if facet was created by recirculation
 - Refactor xin->ofpacts initialisation to handle cases where the rule
   has disappeared but the facets still exist

v14
* Rename execute_recirculate() as commit_recirculate(),
  this seems more consistent with the naming of related functions
* Allow matching of zero skb_mark
 - Include skb_mark in flow key passed from datapath
 - Include skb_mark in flow key constructed from flow if the mask is non-zero
* Set skb_mark mask for recirculated facets during revalidation
* Run through facets in reverse order in facet_revalidate(), so that children
  are always destroyed before their parents.

v13
* Rebase for megaflow changes: very extensive rebase

v12
* Rebase
* Copy flow tunnel when recirculating in xlate_and_recirculate().
  This avoids a bug that occurred when recirculating more than once
  and thus using flow_storage as the flow passed to flow_extract()
  and flow_storage.tunnel as the tunnel passed to flow_extract().
  The tunnel parameter passed to flow_extract() must not be
  the tunnel element of its flow parameter.
* In xlate_and_recirculate() ensure that there is sufficient headroom in
  packet for both the key, which is present if xlate_and_recirculate()
  is called by handle_flow_miss_without_facet(), and an MPLS LSE in case
  mpls_push() occurs.

v11
* As suggested by Jarno Rajahalem
  - Rename xlate_with_recirculate() as xlate_and_recirculate and add
    a comment above it to make it clearer that it may modify its
    'packet' argument.
  - Only hash in facet_find_by_id() if it is needed.
  - Replace may_recirculate with may_xlate_l3_actions in do_xlate_actions()
    as this seems to be a more intuitive name
  - Fix spelling of execute_recirculate_action()
  - Remove spurious comment regarding setting of the recirculation_id element
    of struct flow in action_xlate_ctx_init() - there is no such element
    at this time
* Enhance comment for recirculation_id element of struct action_xlate_ctx
  to describe valid initial values.
* Enhance comments regarding the use of recirculation ids in facet_revalidate()
* Correct comment for recirculated element of struct action_xlate_ctx,
  previously its described states were the opposite of the implementation.
* Add comments above peek_recirculation_id() and get_recirculation_id()
* Correct error in parameter passed to odp_execute_actions()
  in xlate_and_recirculate()

v10
* Rebase
* Remove execute_actions_for_recircualtion() helper and
  use odp_execute_actions directly()

v9
* Rebase

v8
* For a learn action recirculate regardless of the value of
  ctx->may_learn in do_xlate_actions(). Previously recirculation
  only occurred if ctx->may_learn was true. That is a bug as
  it causes revalidation to fail. Flagged by the tests developed
  as part of a patch to allow multiple MPLS push and poop actions.
* Update tests removing unnecessary dl_type pre-requisite

v7
* Rebase
* Add skb_priority, skb_mark and tun_key parameters to dp_netdev_port_input()
  This allows the skb_priority, skb_mark and tun_key  to be passed from
  dpif_netdev_execute() to honour corresponding set actions.
* Recirculate on reg load and move, stack push and pop,
  multipath, bundle, and learn actions.
* Add tests

v6
* As suggested by Jesse Gross
  - Enforce MAX_RECIRCULATION_DEPTH rather than MAX_RECIRCULATION_DEPTH + 1
    by pre-decrementing rather than post-decrementing loop counter.
  - Stop processing actions when a recirculation action is met
    in validate_and_copy_actions__(). This reflects how
    actions are actually executed and will invalidate actions
    if anything follows recirculation.
  - Add a rate-limited warning for packets dropped because they
    are recirculated too much in ovs_dp_process_received_packet().
  - Pass skb_mark to dp_netdev_sample() rather than using a
    private one.
  - Handle skb_priority when executing recirculation without
    facets in ovs-vswitchd
  - Handle tunnel key when executing recirculation without
    facets in ovs-vswitchd
  - Do not duplicate counting of flow statistics for recirculated packets.
  - Handle revalidation of facets of revalidated packets
    - Also, add facet_lookup_valid_by_id() and use it when
      looking up the parent facet of a recirculated packet instead
      of using the facet without regard for weather it is valid or not.
* Merge with patch "Allow recirculation without facets"
* Merge with patch "Avoid recirculation id collision"

v5
* Correct declaration of facet_find_by_id to match definition:
  ovs_be32 -> uint32_t.

* Enhancements to recirculation id code:
  - Allow efficient lookup of facets by their recirculation id
  - Add RECIRCULATION_ID_DUMMY which may be used in cases
    where no facet it used. It is an arbitrary valid id.
  - Also add recirculated element to action_xlate_ctx()
    to use to detect if a recirculation action was added during
    translation. The previous scheme of checking if recirculation_id
    was not RECIRCULATION_ID_NONE is broken for cases where
    the context is initialised with a recirculation_id other than
    RECIRCULATION_ID_NONE. E.g. when RECIRCULATION_ID_DUMMY is used.

* Avoid recirculation id collision

  Avoid recirculation id collision by checking that an id is
  not already associated with a facet.

  Consecutive recirculation ids are used and thus it is possible for
  there to be situations where a very large number of ids have to
  be checked before finding one that is not already associated with a facet.

  To mitigate the performance impact of such situations a limit on
  the number of checks is in place and if no unused recirculation id
  can be found then the miss is handled without facets as this can
  be done using a dummy recirculation id.

rfc4
* Minor enhancement to recirculation id management: Add RECIRCULATE_ID_NONE
  to use instead of using 0 directly.

* Correct calculation of facet->recirculation_ofpacts and
  facet->recirculation_ofpacts_len in subfacet_make_actions()
  in the case of more than one level of recirculation.

* Allow recirculation without facets

  This covers the following cases:
  - Handle flow miss without facet
    + Previously the use of facets was forced if there was
      any chance of a recirculation action. That is, for
      all flows misses of MPLS packets.
  - Packet Out

rfc3

* Use IS_ERR_OR_NULL()

* Handle facet consistency checking by constructing a chain of facets
  from the given facet, to its recirculation parent and then its parent
  until the topmost facet.  If there is no recirculation  the chain will
  be of length one. If there is one recirculation action then the chain
  will be of length two. And so on.

  The topmost facet in the chain can is used to lookup the rule to be
  verified. The chain is then walked from top to bottom, translating
  actions up to the end or the first recirculation action that is
  encountered, whichever comes first. As the code walks down the chain
  it updates the actions that are executed to start of the actions to
  be executed to be just after the end of the actions executed in the
  previous facet in the chain. This is similar to the way that facets
  are created when a recirculation action is encountered.

rfc2
* As suggested by Jesse Gross
  - Update for changes to ovs_dp_process_received_packet()
    to no longer check if OVS_CB(skb)->flow is pre-initialised.
  - Do not add spurious printk debugging to ovs_execute_actions()
  - Do not add spurious debugging messages to commit_set_nw_action()
  - Correct typo in comment above commit_odp_actions().
  - Do not execute recirculation in ovs-vswitchd, rather allow
    the datapath to make an upcall when a recirculation action
    is encountered on execute.
    + This implicitly breaks support for recirculation without facets,
      so for now force all misses of MPLS frames to be handled with
      a facet; and treat handling of recirculation for packet_out as
      a todo item.
  - Use skb_mark for recirculation_id in match. This avoids
    both expanding the match and including a recirculation_id parameter
    with the recirculation action: set_skb_mark should be used before
    the recirculation action.
  - Tidy up ownership of skb in ovs_execute_actions

rfc1
* Initial post
---
 datapath/actions.c           |   9 +-
 datapath/datapath.c          | 105 +++++----
 datapath/datapath.h          |   2 +-
 datapath/flow.c              |   5 +-
 include/linux/openvswitch.h  |   4 +
 lib/dpif-netdev.c            |  80 ++++---
 lib/flow.h                   |   4 +
 lib/odp-execute.c            |   7 +-
 lib/odp-execute.h            |   3 +-
 lib/odp-util.c               |  17 +-
 lib/odp-util.h               |   1 +
 lib/ofp-actions.h            |   6 +
 ofproto/ofproto-dpif-xlate.c | 183 +++++++++++++++-
 ofproto/ofproto-dpif-xlate.h |  27 ++-
 ofproto/ofproto-dpif.c       | 504 ++++++++++++++++++++++++++++++++++++++++---
 ofproto/ofproto-dpif.h       |   5 +
 tests/ofproto-dpif.at        | 411 ++++++++++++++++++++++++++---------
 17 files changed, 1155 insertions(+), 218 deletions(-)

diff --git a/datapath/actions.c b/datapath/actions.c
index 99e02cf..ac4dd51 100644
--- a/datapath/actions.c
+++ b/datapath/actions.c
@@ -641,6 +641,9 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 		case OVS_ACTION_ATTR_SAMPLE:
 			err = sample(dp, skb, a);
 			break;
+
+		case OVS_ACTION_ATTR_RECIRCULATE:
+			return 1;
 		}
 
 		if (unlikely(err)) {
@@ -681,7 +684,7 @@ static int loop_suppress(struct datapath *dp, struct sw_flow_actions *actions)
 }
 
 /* Execute a list of actions against 'skb'. */
-int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb)
+struct sk_buff *ovs_execute_actions(struct datapath *dp, struct sk_buff *skb)
 {
 	struct sw_flow_actions *acts = rcu_dereference(OVS_CB(skb)->flow->sf_acts);
 	struct loop_counter *loop;
@@ -703,6 +706,8 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb)
 	OVS_CB(skb)->tun_key = NULL;
 	error = do_execute_actions(dp, skb, acts->actions,
 					 acts->actions_len, false);
+	if (likely(error <= 0))
+		skb = NULL;
 
 	/* Check whether sub-actions looped too much. */
 	if (unlikely(loop->looping))
@@ -713,5 +718,5 @@ out_loop:
 	if (!--loop->count)
 		loop->looping = false;
 
-	return error;
+	return (error < 0) ? ERR_PTR(error) : skb;
 }
diff --git a/datapath/datapath.c b/datapath/datapath.c
index e33733f..c8143b9 100644
--- a/datapath/datapath.c
+++ b/datapath/datapath.c
@@ -227,52 +227,65 @@ void ovs_dp_detach_port(struct vport *p)
 	ovs_vport_del(p);
 }
 
+#define MAX_RECIRCULATION_DEPTH	4	/* Completely arbitrary */
+
 /* Must be called with rcu_read_lock. */
 void ovs_dp_process_received_packet(struct vport *p, struct sk_buff *skb)
 {
 	struct datapath *dp = p->dp;
-	struct sw_flow *flow;
 	struct dp_stats_percpu *stats;
-	struct sw_flow_key key;
-	u64 *stats_counter;
-	int error;
+	int limit = MAX_RECIRCULATION_DEPTH;
 
 	stats = this_cpu_ptr(dp->stats_percpu);
 
-	/* Extract flow from 'skb' into 'key'. */
-	error = ovs_flow_extract(skb, p->port_no, &key);
-	if (unlikely(error)) {
-		kfree_skb(skb);
-		return;
-	}
+	while (1) {
+		u64 *stats_counter;
+		struct sw_flow *flow;
+		struct sw_flow_key key;
+		int error;
 
-	/* Look up flow. */
-	flow = ovs_flow_lookup(rcu_dereference(dp->table), &key);
-	if (unlikely(!flow)) {
-		struct dp_upcall_info upcall;
-
-		upcall.cmd = OVS_PACKET_CMD_MISS;
-		upcall.key = &key;
-		upcall.userdata = NULL;
-		upcall.portid = p->upcall_portid;
-		ovs_dp_upcall(dp, skb, &upcall);
-		consume_skb(skb);
-		stats_counter = &stats->n_missed;
-		goto out;
-	}
+		/* Extract flow from 'skb' into 'key'. */
+		error = ovs_flow_extract(skb, p->port_no, &key);
+		if (unlikely(error)) {
+			kfree_skb(skb);
+			return;
+		}
 
-	OVS_CB(skb)->flow = flow;
-	OVS_CB(skb)->pkt_key = &key;
+		/* Look up flow. */
+		flow = ovs_flow_lookup(rcu_dereference(dp->table), &key);
+		if (unlikely(!flow)) {
+			struct dp_upcall_info upcall;
 
-	stats_counter = &stats->n_hit;
-	ovs_flow_used(OVS_CB(skb)->flow, skb);
-	ovs_execute_actions(dp, skb);
+			upcall.cmd = OVS_PACKET_CMD_MISS;
+			upcall.key = &key;
+			upcall.userdata = NULL;
+			upcall.portid = p->upcall_portid;
+			ovs_dp_upcall(dp, skb, &upcall);
+			consume_skb(skb);
+			stats_counter = &stats->n_missed;
+			skb = NULL;
+		} else {
+			OVS_CB(skb)->flow = flow;
+			OVS_CB(skb)->pkt_key = &key;
+			stats_counter = &stats->n_hit;
+			ovs_flow_used(flow, skb);
+			skb = ovs_execute_actions(dp, skb);
+		}
 
-out:
-	/* Update datapath statistics. */
-	u64_stats_update_begin(&stats->sync);
-	(*stats_counter)++;
-	u64_stats_update_end(&stats->sync);
+		/* Update datapath statistics. */
+		u64_stats_update_begin(&stats->sync);
+		(*stats_counter)++;
+		u64_stats_update_end(&stats->sync);
+
+		if (IS_ERR_OR_NULL(skb)) {
+			break;
+		} else if (unlikely(!--limit)) {
+			net_warn_ratelimited("droped packet that has "
+					     "been recirculated too much");
+			kfree_skb(skb);
+			return;
+		}
+	}
 }
 
 static struct genl_family dp_packet_genl_family = {
@@ -933,6 +946,7 @@ static int validate_and_copy_actions__(const struct nlattr *attr,
 {
 	const struct nlattr *a;
 	int rem, err;
+	bool recirculate = false;
 
 	if (depth >= SAMPLE_ACTION_DEPTH)
 		return -EOVERFLOW;
@@ -946,6 +960,7 @@ static int validate_and_copy_actions__(const struct nlattr *attr,
 			[OVS_ACTION_ATTR_POP_MPLS] = sizeof(__be16),
 			[OVS_ACTION_ATTR_PUSH_VLAN] = sizeof(struct ovs_action_push_vlan),
 			[OVS_ACTION_ATTR_POP_VLAN] = 0,
+			[OVS_ACTION_ATTR_RECIRCULATE] = 0,
 			[OVS_ACTION_ATTR_SET] = (u32)-1,
 			[OVS_ACTION_ATTR_SAMPLE] = (u32)-1
 		};
@@ -953,6 +968,9 @@ static int validate_and_copy_actions__(const struct nlattr *attr,
 		int type = nla_type(a);
 		bool skip_copy;
 
+		if (recirculate)
+			break;
+
 		if (type > OVS_ACTION_ATTR_MAX ||
 		    (action_lens[type] != nla_len(a) &&
 		     action_lens[type] != (u32)-1))
@@ -1027,6 +1045,10 @@ static int validate_and_copy_actions__(const struct nlattr *attr,
 			skip_copy = true;
 			break;
 
+		case OVS_ACTION_ATTR_RECIRCULATE:
+			recirculate = true;
+			break;
+
 		default:
 			return -EINVAL;
 		}
@@ -1137,12 +1159,23 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 		goto err_unlock;
 
 	local_bh_disable();
-	err = ovs_execute_actions(dp, packet);
+	packet = ovs_execute_actions(dp, packet);
+	if (!IS_ERR_OR_NULL(packet)) {
+		struct vport *vport;
+		vport = ovs_lookup_vport(dp, flow->key.phy.in_port);
+		if (!vport) {
+			err = -ENODEV;
+			goto err_unlock;
+		}
+		/* Recirculate */
+		ovs_dp_process_received_packet(vport, packet);
+		packet = NULL;
+	}
 	local_bh_enable();
 	rcu_read_unlock();
 
 	ovs_flow_free(flow, false);
-	return err;
+	return PTR_ERR(packet);
 
 err_unlock:
 	rcu_read_unlock();
diff --git a/datapath/datapath.h b/datapath/datapath.h
index 68bf9ac..3805e77 100644
--- a/datapath/datapath.h
+++ b/datapath/datapath.h
@@ -211,7 +211,7 @@ const char *ovs_dp_name(const struct datapath *dp);
 struct sk_buff *ovs_vport_cmd_build_info(struct vport *, u32 portid, u32 seq,
 					 u8 cmd);
 
-int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb);
+struct sk_buff *ovs_execute_actions(struct datapath *dp, struct sk_buff *skb);
 void ovs_dp_notify_wq(struct work_struct *work);
 
 #define OVS_NLERR(fmt, ...) \
diff --git a/datapath/flow.c b/datapath/flow.c
index 67276d5..2fd3e05 100644
--- a/datapath/flow.c
+++ b/datapath/flow.c
@@ -1763,8 +1763,9 @@ int ovs_flow_to_nlattrs(const struct sw_flow_key *swkey,
 			goto nla_put_failure;
 	}
 
-	if (output->phy.skb_mark &&
-		nla_put_u32(skb, OVS_KEY_ATTR_SKB_MARK, output->phy.skb_mark))
+	/* Always include the skb_mark so that it may be utilised
+	 * by recirculation */
+	if (nla_put_u32(skb, OVS_KEY_ATTR_SKB_MARK, output->phy.skb_mark))
 		goto nla_put_failure;
 
 	nla = nla_reserve(skb, OVS_KEY_ATTR_ETHERNET, sizeof(*eth_key));
diff --git a/include/linux/openvswitch.h b/include/linux/openvswitch.h
index 27d0494..d5d8922 100644
--- a/include/linux/openvswitch.h
+++ b/include/linux/openvswitch.h
@@ -522,6 +522,9 @@ struct ovs_action_push_vlan {
  * indicate the new packet contents This could potentially still be
  * %ETH_P_MPLS_* if the resulting MPLS label stack is not empty.  If there
  * is no MPLS label stack, as determined by ethertype, no action is taken.
+ * @OVS_ACTION_ATTR_RECIRCULATE: Restart processing of packet.
+ * The packet must have been modified by a previous action in such a way
+ * that it does not match its original flow again.
  *
  * Only a single header can be set with a single %OVS_ACTION_ATTR_SET.  Not all
  * fields within a header are modifiable, e.g. the IPv4 protocol and fragment
@@ -538,6 +541,7 @@ enum ovs_action_attr {
 	OVS_ACTION_ATTR_SAMPLE,       /* Nested OVS_SAMPLE_ATTR_*. */
 	OVS_ACTION_ATTR_PUSH_MPLS,    /* struct ovs_action_push_mpls. */
 	OVS_ACTION_ATTR_POP_MPLS,     /* __be16 ethertype. */
+	OVS_ACTION_ATTR_RECIRCULATE,  /* No argument */
 	__OVS_ACTION_ATTR_MAX
 };
 
diff --git a/lib/dpif-netdev.c b/lib/dpif-netdev.c
index 4890398..af36ccd 100644
--- a/lib/dpif-netdev.c
+++ b/lib/dpif-netdev.c
@@ -157,7 +157,7 @@ static int dpif_netdev_open(const struct dpif_class *, const char *name,
 static int dp_netdev_output_userspace(struct dp_netdev *, const struct ofpbuf *,
                                     int queue_no, const struct flow *,
                                     const struct nlattr *userdata);
-static void dp_netdev_execute_actions(struct dp_netdev *,
+static bool dp_netdev_execute_actions(struct dp_netdev *,
                                       struct ofpbuf *, struct flow *,
                                       const struct nlattr *actions,
                                       size_t actions_len);
@@ -1030,9 +1030,26 @@ dpif_netdev_execute(struct dpif *dpif, const struct dpif_execute *execute)
     error = dpif_netdev_flow_from_nlattrs(execute->key, execute->key_len,
                                           &key);
     if (!error) {
+        bool recirculate;
         xpthread_mutex_lock(&dp_netdev_mutex);
-        dp_netdev_execute_actions(dp, &copy, &key,
-                                  execute->actions, execute->actions_len);
+
+        recirculate = dp_netdev_execute_actions(dp, &copy, &key,
+                                                execute->actions,
+                                                execute->actions_len);
+        if (recirculate) {
+            struct dp_netdev_port *port;
+            uint32_t port_no;
+
+            port_no = odp_to_u32(key.in_port.odp_port);
+            port = (port_no < MAX_PORTS) ? dp->ports[port_no] : NULL;
+            if (port) {
+                dp_netdev_port_input(dp, port, &copy, key.skb_priority,
+                                     key.skb_mark, &key.tunnel);
+                error = 0;
+            } else {
+                error = ENOENT;
+            }
+        }
         xpthread_mutex_unlock(&dp_netdev_mutex);
     }
 
@@ -1133,25 +1150,39 @@ dp_netdev_port_input(struct dp_netdev *dp, struct dp_netdev_port *port,
                      struct ofpbuf *packet, uint32_t skb_priority,
                      uint32_t skb_mark, const struct flow_tnl *tnl)
 {
-    struct dp_netdev_flow *flow;
-    struct flow key;
-    union flow_in_port in_port_;
+    bool recirculate;
+    int limit = MAX_RECIRCULATION_DEPTH;
+    struct flow_tnl tnl_storage;
 
-    if (packet->size < ETH_HEADER_LEN) {
-        return;
-    }
-    in_port_.odp_port = port->port_no;
-    flow_extract(packet, skb_priority, skb_mark, tnl, &in_port_, &key);
-    flow = dp_netdev_lookup_flow(dp, &key);
-    if (flow) {
-        dp_netdev_flow_used(flow, packet);
-        dp_netdev_execute_actions(dp, packet, &key,
-                                  flow->actions, flow->actions_len);
-        dp->n_hit++;
-    } else {
-        dp->n_missed++;
-        dp_netdev_output_userspace(dp, packet, DPIF_UC_MISS, &key, NULL);
-    }
+    do {
+        struct dp_netdev_flow *flow;
+        struct flow key;
+        union flow_in_port in_port_;
+
+        if (packet->size < ETH_HEADER_LEN) {
+            return;
+        }
+        in_port_.odp_port = port->port_no;
+        flow_extract(packet, skb_priority, skb_mark, tnl, &in_port_, &key);
+        flow = dp_netdev_lookup_flow(dp, &key);
+        if (flow) {
+            dp_netdev_flow_used(flow, packet);
+            recirculate = dp_netdev_execute_actions(dp, packet, &key,
+                                                    flow->actions,
+                                                    flow->actions_len);
+            if (recirculate) {
+                skb_priority = key.skb_priority;
+                skb_mark = key.skb_mark;
+                tnl_storage = key.tunnel;
+                tnl = &tnl_storage;
+            }
+            dp->n_hit++;
+        } else {
+            dp->n_missed++;
+            dp_netdev_output_userspace(dp, packet, DPIF_UC_MISS, &key, NULL);
+            recirculate = false;
+        }
+    } while (recirculate && --limit);
 }
 
 static void
@@ -1281,14 +1312,15 @@ dp_netdev_action_userspace(void *dp, struct ofpbuf *packet,
     dp_netdev_output_userspace(dp, packet, DPIF_UC_ACTION, key, userdata);
 }
 
-static void
+static bool
 dp_netdev_execute_actions(struct dp_netdev *dp,
                           struct ofpbuf *packet, struct flow *key,
                           const struct nlattr *actions,
                           size_t actions_len)
 {
-    odp_execute_actions(dp, packet, key, actions, actions_len,
-                        dp_netdev_output_port, dp_netdev_action_userspace);
+    return odp_execute_actions(dp, packet, key, actions, actions_len,
+                               dp_netdev_output_port,
+                               dp_netdev_action_userspace);
 }
 
 const struct dpif_class dpif_netdev_class = {
diff --git a/lib/flow.h b/lib/flow.h
index 7c3654b..55ccccf 100644
--- a/lib/flow.h
+++ b/lib/flow.h
@@ -365,4 +365,8 @@ uint32_t minimask_hash(const struct minimask *, uint32_t basis);
 bool minimask_has_extra(const struct minimask *, const struct minimask *);
 bool minimask_is_catchall(const struct minimask *);
 
+#define MAX_RECIRCULATION_DEPTH 4   /* Completely arbitrary value to
+                                     * guard against infinite loops */
+BUILD_ASSERT_DECL(MAX_RECIRCULATION_DEPTH > 0);
+
 #endif /* flow.h */
diff --git a/lib/odp-execute.c b/lib/odp-execute.c
index e6e8c91..5a81ef9 100644
--- a/lib/odp-execute.c
+++ b/lib/odp-execute.c
@@ -153,7 +153,7 @@ odp_execute_sample(void *dp, struct ofpbuf *packet, struct flow *key,
                         nl_attr_get_size(subactions), output, userspace);
 }
 
-void
+bool
 odp_execute_actions(void *dp, struct ofpbuf *packet, struct flow *key,
                     const struct nlattr *actions, size_t actions_len,
                     void (*output)(void *dp, struct ofpbuf *packet,
@@ -211,9 +211,14 @@ odp_execute_actions(void *dp, struct ofpbuf *packet, struct flow *key,
             odp_execute_sample(dp, packet, key, a, output, userspace);
             break;
 
+        case OVS_ACTION_ATTR_RECIRCULATE:
+            return true;
+
         case OVS_ACTION_ATTR_UNSPEC:
         case __OVS_ACTION_ATTR_MAX:
             NOT_REACHED();
         }
     }
+
+    return false;
 }
diff --git a/lib/odp-execute.h b/lib/odp-execute.h
index 89dd66b..d7a6b16 100644
--- a/lib/odp-execute.h
+++ b/lib/odp-execute.h
@@ -18,6 +18,7 @@
 #ifndef EXECUTE_ACTIONS_H
 #define EXECUTE_ACTIONS_H 1
 
+#include <stdbool.h>
 #include <stddef.h>
 #include <stdint.h>
 
@@ -25,7 +26,7 @@ struct flow;
 struct nlattr;
 struct ofpbuf;
 
-void
+bool
 odp_execute_actions(void *dp, struct ofpbuf *packet, struct flow *key,
                     const struct nlattr *actions, size_t actions_len,
                     void (*output)(void *dp, struct ofpbuf *packet,
diff --git a/lib/odp-util.c b/lib/odp-util.c
index 5d7277c..1e40451 100644
--- a/lib/odp-util.c
+++ b/lib/odp-util.c
@@ -76,6 +76,7 @@ odp_action_len(uint16_t type)
     case OVS_ACTION_ATTR_POP_VLAN: return 0;
     case OVS_ACTION_ATTR_PUSH_MPLS: return sizeof(struct ovs_action_push_mpls);
     case OVS_ACTION_ATTR_POP_MPLS: return sizeof(ovs_be16);
+    case OVS_ACTION_ATTR_RECIRCULATE: return 0;
     case OVS_ACTION_ATTR_SET: return -2;
     case OVS_ACTION_ATTR_SAMPLE: return -2;
 
@@ -426,6 +427,10 @@ format_odp_action(struct ds *ds, const struct nlattr *a)
         ds_put_format(ds, "pop_mpls(eth_type=0x%"PRIx16")", ntohs(ethertype));
         break;
     }
+    case OVS_ACTION_ATTR_RECIRCULATE: {
+        ds_put_format(ds, "recirculate");
+        break;
+    }
     case OVS_ACTION_ATTR_SAMPLE:
         format_odp_sample_action(ds, a);
         break;
@@ -2331,7 +2336,7 @@ odp_flow_key_from_flow__(struct ofpbuf *buf, const struct flow *data,
         tun_key_to_attr(buf, &data->tunnel);
     }
 
-    if (flow->skb_mark) {
+    if (flow->skb_mark || data->skb_mark) {
         nl_msg_put_u32(buf, OVS_KEY_ATTR_SKB_MARK, data->skb_mark);
     }
 
@@ -3041,6 +3046,12 @@ commit_odp_tunnel_action(const struct flow *flow, struct flow *base,
     }
 }
 
+void
+commit_odp_recirculate_action(struct ofpbuf *odp_actions)
+{
+    nl_msg_put_flag(odp_actions, OVS_ACTION_ATTR_RECIRCULATE);
+}
+
 static void
 commit_set_ether_addr_action(const struct flow *flow, struct flow *base,
                              struct ofpbuf *odp_actions,
@@ -3293,8 +3304,8 @@ commit_set_skb_mark_action(const struct flow *flow, struct flow *base,
  * 'base' and 'flow', appends ODP actions to 'odp_actions' that change the flow
  * key from 'base' into 'flow', and then changes 'base' the same way.  Does not
  * commit set_tunnel actions.  Users should call commit_odp_tunnel_action()
- * in addition to this function if needed.  Sets fields in 'wc' that are
- * used as part of the action.
+ * and commit_odp_recirculate_action() in addition to those functions if
+ * needed. Sets fields in 'wc' that are used as part of the action.
  *
  * VLAN actions may be committed twice; If vlan_tci in 'flow' differs from the
  * one in 'base', then it is committed before MPLS actions. If 'final_vlan_tci'
diff --git a/lib/odp-util.h b/lib/odp-util.h
index 4770757..6b3977f 100644
--- a/lib/odp-util.h
+++ b/lib/odp-util.h
@@ -126,6 +126,7 @@ const char *odp_key_fitness_to_string(enum odp_key_fitness);
 
 void commit_odp_tunnel_action(const struct flow *, struct flow *base,
                               struct ofpbuf *odp_actions);
+void commit_odp_recirculate_action(struct ofpbuf *odp_actions);
 void commit_odp_actions(const struct flow *, struct flow *base,
                         struct ofpbuf *odp_actions, struct flow_wildcards *wc,
                         ovs_be16 final_vlan_tci);
diff --git a/lib/ofp-actions.h b/lib/ofp-actions.h
index ca33ca8..ca5472d 100644
--- a/lib/ofp-actions.h
+++ b/lib/ofp-actions.h
@@ -175,6 +175,12 @@ ofpact_end(const struct ofpact *ofpacts, size_t ofpacts_len)
     return (void *) ((uint8_t *) ofpacts + ofpacts_len);
 }
 
+static inline unsigned
+ofpact_offset(const struct ofpact *start, const struct ofpact *offset)
+{
+    return (uint8_t*) offset - (uint8_t *) start;
+}
+
 /* Assigns POS to each ofpact, in turn, in the OFPACTS_LEN bytes of ofpacts
  * starting at OFPACTS. */
 #define OFPACT_FOR_EACH(POS, OFPACTS, OFPACTS_LEN)                      \
diff --git a/ofproto/ofproto-dpif-xlate.c b/ofproto/ofproto-dpif-xlate.c
index 1e39ede..c9145b5 100644
--- a/ofproto/ofproto-dpif-xlate.c
+++ b/ofproto/ofproto-dpif-xlate.c
@@ -146,6 +146,12 @@ struct xlate_ctx {
     /* The rule that we are currently translating, or NULL. */
     struct rule_dpif *rule;
 
+    size_t ofpacts_len;         /* The number of bytes of the ofpacts
+                                 * argument to xlate_actions() processed
+                                 * by it. This is used to calculate an
+                                 * offset into ofpacts for calls to
+                                 * xlate_actions on recirculated packets */
+
     int recurse;                /* Recursion level, via xlate_table_action. */
     bool max_resubmit_trigger;  /* Recursed too deeply during translation. */
     uint32_t orig_skb_priority; /* Priority when packet arrived. */
@@ -1531,6 +1537,24 @@ execute_controller_action(struct xlate_ctx *ctx, int len,
 }
 
 static void
+compose_recirculate_action(struct xlate_ctx *ctx)
+{
+    struct flow_wildcards *wc = &ctx->xout->wc;
+
+    if (ctx->xin->recirculation_id == RECIRCULATION_ID_NONE) {
+        ctx->xin->recirculation_id = get_recirculation_id();
+    }
+    ctx->xin->recirculated = true;
+    ctx->xin->flow.skb_mark = ctx->xin->recirculation_id;
+
+    /* Other than the skb_mark, a recirculated facet may have the match as
+     * the facet that caused it to be recirculated. So unmask the skb_mark
+     * of facets that cause recirculation. The skb_mark of recirculated
+     * facets is unmasked in handle_flow_miss() */
+    memset(&wc->masks.skb_mark, 0xff, sizeof wc->masks.skb_mark);
+}
+
+static void
 compose_mpls_push_action(struct xlate_ctx *ctx, ovs_be16 eth_type)
 {
     struct flow_wildcards *wc = &ctx->xout->wc;
@@ -1940,6 +1964,7 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
     struct flow *flow = &ctx->xin->flow;
     ovs_be16 *vlan_tci = &ctx->xin->flow.vlan_tci;
     bool was_evictable = true;
+    bool may_xlate_l3_actions = true;
     const struct ofpact *a;
 
     if (ctx->rule) {
@@ -2015,18 +2040,30 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
 
         case OFPACT_SET_IPV4_SRC:
             if (flow->dl_type == htons(ETH_TYPE_IP)) {
+                if (!may_xlate_l3_actions) {
+                    compose_recirculate_action(ctx);
+                    goto out;
+                }
                 flow->nw_src = ofpact_get_SET_IPV4_SRC(a)->ipv4;
             }
             break;
 
         case OFPACT_SET_IPV4_DST:
             if (flow->dl_type == htons(ETH_TYPE_IP)) {
+                if (!may_xlate_l3_actions) {
+                    compose_recirculate_action(ctx);
+                    goto out;
+                }
                 flow->nw_dst = ofpact_get_SET_IPV4_DST(a)->ipv4;
             }
             break;
 
         case OFPACT_SET_IPV4_DSCP:
             /* OpenFlow 1.0 only supports IPv4. */
+            if (!may_xlate_l3_actions) {
+                compose_recirculate_action(ctx);
+                goto out;
+            }
             if (flow->dl_type == htons(ETH_TYPE_IP)) {
                 flow->nw_tos &= ~IP_DSCP_MASK;
                 flow->nw_tos |= ofpact_get_SET_IPV4_DSCP(a)->dscp;
@@ -2036,6 +2073,10 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
         case OFPACT_SET_L4_SRC_PORT:
             memset(&wc->masks.nw_proto, 0xff, sizeof wc->masks.nw_proto);
             if (is_ip_any(flow)) {
+                if (!may_xlate_l3_actions) {
+                    compose_recirculate_action(ctx);
+                    goto out;
+                }
                 flow->tp_src = htons(ofpact_get_SET_L4_SRC_PORT(a)->port);
             }
             break;
@@ -2043,6 +2084,10 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
         case OFPACT_SET_L4_DST_PORT:
             memset(&wc->masks.nw_proto, 0xff, sizeof wc->masks.nw_proto);
             if (is_ip_any(flow)) {
+                if (!may_xlate_l3_actions) {
+                    compose_recirculate_action(ctx);
+                    goto out;
+                }
                 flow->tp_dst = htons(ofpact_get_SET_L4_DST_PORT(a)->port);
             }
             break;
@@ -2065,6 +2110,10 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
 
         case OFPACT_REG_MOVE: {
             ovs_be16 orig_tci = flow->vlan_tci;
+            if (!may_xlate_l3_actions) {
+                compose_recirculate_action(ctx);
+                goto out;
+            }
             nxm_execute_reg_move(ofpact_get_REG_MOVE(a), flow, wc);
             vlan_tci_restore(ctx->xin, vlan_tci, orig_tci);
             break;
@@ -2072,6 +2121,10 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
 
         case OFPACT_REG_LOAD: {
             ovs_be16 orig_tci = flow->vlan_tci;
+            if (!may_xlate_l3_actions) {
+                compose_recirculate_action(ctx);
+                goto out;
+            }
             nxm_execute_reg_load(ofpact_get_REG_LOAD(a), flow);
             vlan_tci_restore(ctx->xin, vlan_tci, orig_tci);
             break;
@@ -2079,6 +2132,10 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
 
         case OFPACT_STACK_PUSH: {
             ovs_be16 orig_tci = flow->vlan_tci;
+            if (!may_xlate_l3_actions) {
+                compose_recirculate_action(ctx);
+                goto out;
+            }
             flow->vlan_tci = *vlan_tci;
             nxm_execute_stack_push(ofpact_get_STACK_PUSH(a), flow, wc,
                                    &ctx->stack);
@@ -2088,6 +2145,10 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
 
         case OFPACT_STACK_POP: {
             ovs_be16 orig_tci = flow->vlan_tci;
+            if (!may_xlate_l3_actions) {
+                compose_recirculate_action(ctx);
+                goto out;
+            }
             nxm_execute_stack_pop(ofpact_get_STACK_POP(a), flow, &ctx->stack);
             vlan_tci_restore(ctx->xin, vlan_tci, orig_tci);
             break;
@@ -2102,10 +2163,15 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
                 flow->vlan_tci = htons(0);
             }
             vlan_tci = &ctx->xin->vlan_tci;
+            may_xlate_l3_actions = true;
             break;
 
         case OFPACT_POP_MPLS:
             compose_mpls_pop_action(ctx, ofpact_get_POP_MPLS(a)->ethertype);
+            if (ctx->xin->flow.dl_type == htons(ETH_TYPE_IP) ||
+                ctx->xin->flow.dl_type == htons(ETH_TYPE_IPV6)) {
+                may_xlate_l3_actions = false;
+            }
             break;
 
         case OFPACT_SET_MPLS_TTL:
@@ -2122,7 +2188,10 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
             break;
 
         case OFPACT_DEC_TTL:
-            if (compose_dec_ttl(ctx, ofpact_get_DEC_TTL(a))) {
+            if (!may_xlate_l3_actions) {
+                compose_recirculate_action(ctx);
+                goto out;
+            } else if (compose_dec_ttl(ctx, ofpact_get_DEC_TTL(a))) {
                 goto out;
             }
             break;
@@ -2133,9 +2202,17 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
 
         case OFPACT_MULTIPATH:
             multipath_execute(ofpact_get_MULTIPATH(a), flow, wc);
+            if (!may_xlate_l3_actions) {
+                compose_recirculate_action(ctx);
+                goto out;
+            }
             break;
 
         case OFPACT_BUNDLE:
+            if (!may_xlate_l3_actions) {
+                compose_recirculate_action(ctx);
+                goto out;
+            }
             xlate_bundle_action(ctx, ofpact_get_BUNDLE(a));
             break;
 
@@ -2144,6 +2221,10 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
             break;
 
         case OFPACT_LEARN:
+            if (!may_xlate_l3_actions) {
+                compose_recirculate_action(ctx);
+                goto out;
+            }
             xlate_learn_action(ctx, ofpact_get_LEARN(a));
             break;
 
@@ -2217,15 +2298,27 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
     }
 
 out:
+    ctx->ofpacts_len = (char *)(a) - (char *)ofpacts;
     if (ctx->rule) {
         ctx->rule->up.evictable = was_evictable;
     }
 }
 
+static void
+xlate_in_reset(struct xlate_in *xin, uint32_t recirculation_id)
+{
+    xin->resubmit_hook = NULL;
+    xin->report_hook = NULL;
+    xin->resubmit_stats = NULL;
+    xin->recirculation_id = recirculation_id;
+    xin->recirculated = false;
+}
+
 void
 xlate_in_init(struct xlate_in *xin, struct ofproto_dpif *ofproto,
               const struct flow *flow, struct rule_dpif *rule,
-              uint8_t tcp_flags, const struct ofpbuf *packet)
+              uint8_t tcp_flags, const struct ofpbuf *packet,
+              uint32_t recirculation_id)
 {
     xin->ofproto = ofproto;
     xin->flow = *flow;
@@ -2236,9 +2329,18 @@ xlate_in_init(struct xlate_in *xin, struct ofproto_dpif *ofproto,
     xin->ofpacts = NULL;
     xin->ofpacts_len = 0;
     xin->tcp_flags = tcp_flags;
-    xin->resubmit_hook = NULL;
-    xin->report_hook = NULL;
-    xin->resubmit_stats = NULL;
+    xlate_in_reset(xin, recirculation_id);
+}
+
+void
+xlate_in_init_ofpacts(struct xlate_in *xin, size_t offset, size_t len)
+{
+    /* Only use the facet's rule offset and length if the rule was found
+     * correctly, not if the default miss rule was used. */
+    if (xin->rule != rule_dpif_miss_rule(xin->ofproto, &xin->flow)) {
+        xin->ofpacts = ofpact_end(xin->rule->up.ofpacts, offset);
+        xin->ofpacts_len = len;
+    }
 }
 
 void
@@ -2451,6 +2553,15 @@ xlate_actions(struct xlate_in *xin, struct xlate_out *xout)
 
         if (tunnel_ecn_ok(&ctx) && (!in_port || may_receive(in_port, &ctx))) {
             do_xlate_actions(ofpacts, ofpacts_len, &ctx);
+            if (ctx.xin->recirculated) {
+                commit_odp_actions(&ctx.xin->flow, &ctx.base_flow,
+                                   &ctx.xout->odp_actions, &ctx.xout->wc,
+                                   ctx.xin->vlan_tci);
+                commit_odp_recirculate_action(&ctx.xout->odp_actions);
+                xin->ofpacts_len -= ctx.ofpacts_len;
+                xin->ofpacts = ofpact_end(xin->ofpacts, ctx.ofpacts_len);
+                xin->recirculated = ctx.xin->recirculated;
+            }
 
             /* We've let OFPP_NORMAL and the learning action look at the
              * packet, so drop it now if forwarding is disabled. */
@@ -2495,3 +2606,65 @@ xlate_actions(struct xlate_in *xin, struct xlate_out *xout)
     memset(&wc->masks.metadata, 0, sizeof wc->masks.metadata);
     memset(&wc->masks.regs, 0, sizeof wc->masks.regs);
 }
+
+/* A loop which translates the actions for 'xin->flow'. If a recirculate
+ * action was not added by the translation then the loop ends. Otherwise
+ * the actions are executed, modifying 'xin->packet' and the loop iterates,
+ * performing translation again.
+ *
+ * The purpose of this function is to handle translation of actions
+ * in cases where facts are not use. */
+void
+xlate_and_recirculate(struct xlate_in *xin, struct xlate_out *xout,
+                      struct ofpbuf *packet, size_t occupied_packet_headroom)
+{
+    /* The packet field of struct xlate_in is const, which makes
+     * sense other than in this function where packet is modified.
+     * So packet is based as a non-const parameter. Ensure that it
+     * is the same as xin->packet */
+    ovs_assert(packet == xin->packet);
+
+    while (1) {
+        struct flow_tnl tunnel_copy;
+
+        xin->recirculated = false;
+        xin->recirculation_id = RECIRCULATION_ID_DUMMY;
+        xlate_actions(xin, xout);
+        if (!xin->recirculated) {
+            break;
+        }
+
+        /* Copy the tunnel to allow it to be passed to flow_extract() */
+        tunnel_copy = xin->flow.tunnel;
+
+        if (occupied_packet_headroom) {
+            /* In the presence of an mpls_push action odp_execute_actions()
+             * may use the trailing MPLS_HLEN bytes of headroom, which may
+             * encroach on leading portions of the headroom that are used
+             * for the key in the case of handle_flow_miss_without_facet()
+             */
+            size_t old_headroom = ofpbuf_headroom(packet);
+            void *old_base = packet->base;
+
+            ofpbuf_prealloc_headroom(packet, occupied_packet_headroom +
+                                     MPLS_HLEN);
+            if (old_base != packet->base) {
+                /* If packet->base has changed then move the key from
+                 * just before packet->data to packet->base */
+                memmove(packet->base,
+                        (char *)packet->data - old_headroom,
+                        occupied_packet_headroom);
+            }
+        }
+
+        /* Update the packet */
+        odp_execute_actions(NULL, packet, &xin->flow, xout->odp_actions.data,
+                            xout->odp_actions.size, NULL, NULL);
+
+        /* Replace the flow */
+        flow_extract(packet, xin->flow.skb_priority, xin->flow.skb_mark,
+                     &tunnel_copy, &xin->flow.in_port, &xin->flow);
+
+        xlate_in_reset(xin, RECIRCULATION_ID_DUMMY);
+    }
+}
diff --git a/ofproto/ofproto-dpif-xlate.h b/ofproto/ofproto-dpif-xlate.h
index 00f2617..ad7444a 100644
--- a/ofproto/ofproto-dpif-xlate.h
+++ b/ofproto/ofproto-dpif-xlate.h
@@ -114,6 +114,24 @@ struct xlate_in {
      * This is normally null so the client has to set it manually after
      * calling xlate_in_init(). */
     const struct dpif_flow_stats *resubmit_stats;
+
+    /* skb_mark to use to identify recirculation.
+     *
+     * If RECIRCULATION_ID_NONE at the time that a recirculate action is
+     * added then get_recirculation_id() is used to obtain a recirculation
+     * id which is saved in recirculation_id.  Otherwise the value
+     * recirculation_id is used.
+     *
+     * In this way both the value of the recirculation_id used and the need
+     * to call get_recirculation_id() may be controlled.
+     *
+     * The value RECIRCULATION_ID_DUMMY may be used as a temporary
+     * recirculation id.
+     */
+    uint32_t recirculation_id;
+
+    /* True if the context added a recirculate action. False otherwise. */
+    bool recirculated;
 };
 
 void xlate_ofproto_set(struct ofproto_dpif *, const char *name,
@@ -141,9 +159,14 @@ void xlate_ofport_remove(struct ofport_dpif *);
 void xlate_actions(struct xlate_in *, struct xlate_out *);
 void xlate_in_init(struct xlate_in *, struct ofproto_dpif *,
                    const struct flow *, struct rule_dpif *,
-                   uint8_t tcp_flags, const struct ofpbuf *packet);
+                   uint8_t tcp_flags, const struct ofpbuf *packet,
+                   uint32_t recirculation_id);
+void xlate_in_init_ofpacts(struct xlate_in *, size_t ofpacts_offset,
+                           size_t ofpacts_len);
 void xlate_out_uninit(struct xlate_out *);
 void xlate_actions_for_side_effects(struct xlate_in *);
 void xlate_out_copy(struct xlate_out *dst, const struct xlate_out *src);
-
+void xlate_and_recirculate(struct xlate_in *, struct xlate_out *,
+                           struct ofpbuf *packet,
+                           size_t occupied_packet_headroom);
 #endif /* ofproto-dpif-xlate.h */
diff --git a/ofproto/ofproto-dpif.c b/ofproto/ofproto-dpif.c
index ca0a317..5010cfa 100644
--- a/ofproto/ofproto-dpif.c
+++ b/ofproto/ofproto-dpif.c
@@ -80,6 +80,8 @@ BUILD_ASSERT_DECL(N_TABLES >= 2 && N_TABLES <= 255);
 struct flow_miss;
 struct facet;
 
+static struct rule_dpif *rule_dpif_lookup_by_facet(struct facet *,
+                                                   struct flow_wildcards *);
 static struct rule_dpif *rule_dpif_lookup(struct ofproto_dpif *,
                                           const struct flow *,
                                           struct flow_wildcards *wc);
@@ -256,17 +258,37 @@ struct facet {
     struct subfacet one_subfacet;
 
     long long int learn_rl;      /* Rate limiter for facet_learn(). */
+
+    unsigned rule_offset;        /* Where this facet's action execution
+                                  * begins in the corresponding rule. */
+    size_t rule_len;             /* The length of the actions in the
+                                  * corresponding rule. */
+
+    unsigned recirculation_offset;
+                                 /* Rule actions offset for child facets. */
+    size_t recirculation_ofpacts_len;
+                                 /* Rule actions length for child facets. */
+
+    uint32_t recirculation_id;   /* Non-zero for a facet that recirculates
+                                  * packets; Used to seed the child facet's
+                                  * flow.skb_mark in these cases. */
+    struct hmap_node recirculation_id_hmap_node;
+                                 /* In owning ofproto's 'recirculation_ids'
+                                  * hmap. */
 };
 
 static struct facet *facet_create(const struct flow_miss *, struct rule_dpif *,
-                                  struct xlate_out *,
-                                  struct dpif_flow_stats *);
+                                  struct xlate_out *, struct dpif_flow_stats *,
+                                  size_t ofpacts_offset, size_t ofpacts_len);
 static void facet_remove(struct facet *);
 static void facet_free(struct facet *);
 
 static struct facet *facet_find(struct ofproto_dpif *, const struct flow *);
+static struct facet *facet_find_by_id(struct ofproto_dpif *, uint32_t id);
 static struct facet *facet_lookup_valid(struct ofproto_dpif *,
                                         const struct flow *);
+static struct facet *facet_lookup_valid_by_id(struct ofproto_dpif *,
+                                              uint32_t id);
 static bool facet_revalidate(struct facet *);
 static bool facet_check_consistency(struct facet *);
 
@@ -279,6 +301,7 @@ static void facet_account(struct facet *);
 static void push_all_stats(void);
 
 static bool facet_is_controller_flow(struct facet *);
+static bool facet_is_recirculated(struct facet *);
 
 struct ofport_dpif {
     struct hmap_node odp_port_node; /* In dpif_backer's "odp_to_ofport_map". */
@@ -488,6 +511,7 @@ struct ofproto_dpif {
 
     /* Facets. */
     struct classifier facets;     /* Contains 'struct facet's. */
+    struct hmap recirculation_ids;
     long long int consistency_rl;
 
     /* Revalidation. */
@@ -1286,6 +1310,7 @@ construct(struct ofproto *ofproto_)
     ofproto->has_bonded_bundles = false;
 
     classifier_init(&ofproto->facets);
+    hmap_init(&ofproto->recirculation_ids);
     ofproto->consistency_rl = LLONG_MIN;
 
     for (i = 0; i < N_TABLES; i++) {
@@ -3253,6 +3278,103 @@ port_is_lacp_current(const struct ofport *ofport_)
             : -1);
 }
 
+/* Recirculation Id */
+#define RECIRCULATION_ID_MIN   (RECIRCULATION_ID_DUMMY + 2)
+
+#define RECIRCULATION_ID_MAX_LOOP 1024  /* Arbitrary value to prevent
+                                         * endless loop */
+
+static uint32_t recirculation_id_hash(uint32_t id)
+{
+    return hash_words(&id, 1, 0);
+}
+
+static uint32_t recirculation_id = RECIRCULATION_ID_MIN;
+static uint32_t validated_recirculation_id = RECIRCULATION_ID_NONE;
+
+/* Pre-allocate the next recirculation id that may be used by a facet.
+ * The recirculation id should be obtained using get_recirculation_id.
+ * Returns RECIRCULATION_ID_NONE on success,
+ * RECIRCULATION_ID_DUMMY on error */
+static uint32_t peek_recirculation_id(struct ofproto_dpif *ofproto)
+{
+    static struct vlog_rate_limit rl = VLOG_RATE_LIMIT_INIT(1, 15);
+
+    int loop = RECIRCULATION_ID_MAX_LOOP;
+
+    if (validated_recirculation_id == recirculation_id) {
+        return RECIRCULATION_ID_NONE;
+    }
+
+    while (loop--) {
+        if (recirculation_id < RECIRCULATION_ID_MIN)
+            recirculation_id = RECIRCULATION_ID_MIN;
+        /* Skip IPSEC_MARK bit it is reserved */
+        if (recirculation_id & IPSEC_MARK) {
+            recirculation_id += IPSEC_MARK;
+        }
+        if (!facet_find_by_id(ofproto, recirculation_id)) {
+            validated_recirculation_id = recirculation_id;
+            return RECIRCULATION_ID_NONE;
+        }
+        recirculation_id++;
+    }
+
+    VLOG_WARN_RL(&rl, "Failed to allocate recirulation id after %d attempts\n",
+                 RECIRCULATION_ID_MAX_LOOP);
+    return RECIRCULATION_ID_DUMMY;
+}
+
+/* Obtain a recirculation id for a facet.
+ * peek_recirculation_id() should have be called prior to each
+ * call to get_recirculation_id().
+ * This function always succeeds.
+ */
+uint32_t get_recirculation_id(void)
+{
+    ovs_assert(recirculation_id == validated_recirculation_id);
+    return recirculation_id++;
+}
+
+/* Removes 'facet' from the recirculation_ids hmap of its ofproto */
+static void
+facet_recirculation_id_remove(struct facet *facet)
+{
+    if (hmap_node_is_null(&facet->recirculation_id_hmap_node)) {
+        return;
+    }
+
+    hmap_remove(&facet->ofproto->recirculation_ids,
+                &facet->recirculation_id_hmap_node);
+}
+
+static bool
+valid_recirculation_id(uint32_t id)
+{
+    return id != RECIRCULATION_ID_NONE && !(id & IPSEC_MARK);
+}
+
+/* Set parameters for 'facet' which has a recirculate action.
+ * 'id' will be 'facet''s recirculation_id.
+ * 'ofpacts_offset will be used to calculate 'facet''s
+ * recirculation_ofpacts and recirculation_ofpacts_len.
+ *
+ * The ofpacts and opacts_len of the facet must have already been set. */
+static void
+facet_set_recirculation(struct facet *facet, uint32_t id,
+                        unsigned ofpacts_offset, size_t ofpacts_len)
+{
+    facet->recirculation_offset = ofpacts_offset;
+    facet->recirculation_ofpacts_len = ofpacts_len;
+
+    if (facet->recirculation_id != id) {
+        facet->recirculation_id = id;
+        hmap_insert(&facet->ofproto->recirculation_ids,
+                    &facet->recirculation_id_hmap_node,
+                    recirculation_id_hash(facet->recirculation_id));
+    }
+}
+
 /* Upcall handling. */
 
 /* Flow miss batching.
@@ -3424,22 +3546,34 @@ flow_miss_should_make_facet(struct flow_miss *miss, struct flow_wildcards *wc)
 static void
 handle_flow_miss_without_facet(struct rule_dpif *rule, struct xlate_out *xout,
                                struct flow_miss *miss,
+                               size_t ofpacts_offset, size_t ofpacts_len,
+                               bool recirculated,
                                struct flow_miss_op *ops, size_t *n_ops)
 {
     struct ofpbuf *packet;
 
     LIST_FOR_EACH (packet, list_node, &miss->packets) {
-
         COVERAGE_INC(facet_suppress);
 
         handle_flow_miss_common(miss->ofproto, packet, &miss->flow,
                                 rule->up.cr.priority == FAIL_OPEN_PRIORITY);
 
-        if (xout->slow) {
+        if (xout->slow || recirculated) {
             struct xlate_in xin;
-
-            xlate_in_init(&xin, miss->ofproto, &miss->flow, rule, 0, packet);
-            xlate_actions_for_side_effects(&xin);
+            struct xlate_out xout_tmp;
+            bool key_is_packet_base = miss->key == packet->base;
+
+            xlate_in_init(&xin, miss->ofproto, &miss->flow, rule, 0,
+                          packet, RECIRCULATION_ID_DUMMY);
+            xlate_in_init_ofpacts(&xin, ofpacts_offset, ofpacts_len);
+            xlate_and_recirculate(&xin, &xout_tmp, packet,
+                                  key_is_packet_base ? miss->key_len : 0);
+            if (key_is_packet_base && miss->key != packet->base) {
+                /* xlate_and_recirculate may have reallocated packet->base */
+                miss->key = packet->base;
+            }
+            xlate_out_copy(xout, &xout_tmp);
+            xlate_out_uninit(&xout_tmp);
         }
 
         if (xout->odp_actions.size) {
@@ -3471,7 +3605,8 @@ handle_flow_miss_without_facet(struct rule_dpif *rule, struct xlate_out *xout,
 static void
 handle_flow_miss_with_facet(struct flow_miss *miss, struct facet *facet,
                             long long int now, struct dpif_flow_stats *stats,
-                            struct flow_miss_op *ops, size_t *n_ops)
+                            struct flow_miss_op *ops, size_t *n_ops,
+                            struct rule_dpif *rule)
 {
     enum subfacet_path want_path;
     struct subfacet *subfacet;
@@ -3486,11 +3621,12 @@ handle_flow_miss_with_facet(struct flow_miss *miss, struct facet *facet,
                                 facet->fail_open);
 
         if (want_path != SF_FAST_PATH) {
-            struct rule_dpif *rule;
             struct xlate_in xin;
 
-            rule = rule_dpif_lookup(facet->ofproto, &facet->flow, NULL);
-            xlate_in_init(&xin, facet->ofproto, &miss->flow, rule, 0, packet);
+            rule = rule ? rule : rule_dpif_lookup_by_facet(facet, NULL);
+            xlate_in_init(&xin, facet->ofproto, &miss->flow, rule, 0, packet,
+                          facet->recirculation_id);
+            xlate_in_init_ofpacts(&xin, facet->rule_offset, facet->rule_len);
             xlate_actions_for_side_effects(&xin);
         }
 
@@ -3569,30 +3705,57 @@ handle_flow_miss(struct flow_miss *miss, struct flow_miss_op *ops,
     struct dpif_flow_stats *stats = &stats__;
     struct ofpbuf *packet;
     struct facet *facet;
+    struct rule_dpif *rule = NULL;
     long long int now;
 
     now = time_msec();
     memset(stats, 0, sizeof *stats);
     stats->used = now;
-    LIST_FOR_EACH (packet, list_node, &miss->packets) {
-        stats->tcp_flags |= packet_get_tcp_flags(packet, &miss->flow);
-        stats->n_bytes += packet->size;
-        stats->n_packets++;
+
+    /* Do not update stats for packets that have been recirculated
+     * as the packet has already been counted before it was recirculated. */
+    if (!valid_recirculation_id(miss->flow.skb_mark)) {
+        LIST_FOR_EACH (packet, list_node, &miss->packets) {
+            stats->tcp_flags |= packet_get_tcp_flags(packet, &miss->flow);
+            stats->n_bytes += packet->size;
+            stats->n_packets++;
+        }
     }
 
     facet = facet_lookup_valid(ofproto, &miss->flow);
     if (!facet) {
         struct flow_wildcards wc;
-        struct rule_dpif *rule;
         struct xlate_out xout;
         struct xlate_in xin;
+        struct facet *parent_facet = NULL;
+        size_t rule_offset, rule_len;
+
+        if (valid_recirculation_id(miss->flow.skb_mark)) {
+            parent_facet = facet_lookup_valid_by_id(ofproto,
+                                                    miss->flow.skb_mark);
+        }
 
         flow_wildcards_init_catchall(&wc);
-        rule = rule_dpif_lookup(ofproto, &miss->flow, &wc);
+        if (parent_facet) {
+            rule = rule_dpif_lookup_by_facet(parent_facet, &wc);
+            rule_offset = parent_facet->recirculation_offset;
+            rule_len = parent_facet->recirculation_ofpacts_len;
+
+            /* The skb_mark should be matched in order to differentiate
+             * recirculated packets based on their skb_mark which is
+             * their recirculation_id */
+            memset(&wc.masks.skb_mark, 0xff, sizeof wc.masks.skb_mark);
+        } else {
+            rule = rule_dpif_lookup(ofproto, &miss->flow, &wc);
+            rule_offset = 0;
+            rule_len = rule->up.ofpacts_len;
+        }
+
         rule_credit_stats(rule, stats);
 
         xlate_in_init(&xin, ofproto, &miss->flow, rule, stats->tcp_flags,
-                      NULL);
+                      NULL, peek_recirculation_id(ofproto));
+        xlate_in_init_ofpacts(&xin, rule_offset, rule_len);
         xin.resubmit_stats = stats;
         xin.may_learn = true;
         xlate_actions(&xin, &xout);
@@ -3602,17 +3765,31 @@ handle_flow_miss(struct flow_miss *miss, struct flow_miss_op *ops,
          * flow keys with fitness ODP_FIT_TO_LITTLE.  This breaks a fundamental
          * assumption used throughout the facet and subfacet handling code.
          * Since we have to handle these misses in userspace anyway, we simply
-         * skip facet creation, avoiding the problem altogether. */
+         * skip facet creation, avoiding the problem altogether.
+         *
+         * If xlate_actions() has added a recirculation action
+         * then xin.recirculated will be true and in this case
+         * a non-dummy recirculation-id is required in order to use facets. */
         if (miss->key_fitness == ODP_FIT_TOO_LITTLE
+            || (xin.recirculated &&
+                xin.recirculation_id == RECIRCULATION_ID_DUMMY)
             || !flow_miss_should_make_facet(miss, &xout.wc)) {
-            handle_flow_miss_without_facet(rule, &xout, miss, ops, n_ops);
+            handle_flow_miss_without_facet(rule, &xout, miss, rule_offset,
+                                           rule_len, xin.recirculated,
+                                           ops, n_ops);
             return;
         }
 
-        facet = facet_create(miss, rule, &xout, stats);
+        facet = facet_create(miss, rule, &xout, stats, rule_offset, rule_len);
+        if (xin.recirculated) {
+            unsigned child_offset = ofpact_offset(rule->up.ofpacts,
+                                                  xin.ofpacts);
+            facet_set_recirculation(facet, xin.recirculation_id,
+                                    child_offset, xin.ofpacts_len);
+        }
         stats = NULL;
     }
-    handle_flow_miss_with_facet(miss, facet, now, stats, ops, n_ops);
+    handle_flow_miss_with_facet(miss, facet, now, stats, ops, n_ops, rule);
 }
 
 static struct drop_key *
@@ -4154,6 +4331,15 @@ update_subfacet_stats(struct subfacet *subfacet,
     diff.tcp_flags = stats->tcp_flags;
     diff.used = stats->used;
 
+    if (facet_is_recirculated(facet)) {
+        /* Do not update stats for facets with recirculation_id set.
+         * This avoids duplicate counting packets that have more than
+         * one facet due to recirculation - only hits for
+         * the top-most facet are counted here: the only facet
+         * in the case where there is no recirculation. */
+        return;
+    }
+
     if (stats->n_packets >= subfacet->dp_packet_count) {
         diff.n_packets = stats->n_packets - subfacet->dp_packet_count;
     } else {
@@ -4427,7 +4613,8 @@ rule_expire(struct rule_dpif *rule)
  * least) one subfacet with subfacet_create(). */
 static struct facet *
 facet_create(const struct flow_miss *miss, struct rule_dpif *rule,
-             struct xlate_out *xout, struct dpif_flow_stats *stats)
+             struct xlate_out *xout, struct dpif_flow_stats *stats,
+             size_t rule_offset, size_t rule_len)
 {
     struct ofproto_dpif *ofproto = miss->ofproto;
     struct facet *facet;
@@ -4442,6 +4629,9 @@ facet_create(const struct flow_miss *miss, struct rule_dpif *rule,
     facet->flow = miss->flow;
     facet->learn_rl = time_msec() + 500;
 
+    hmap_node_nullify(&facet->recirculation_id_hmap_node);
+    facet->rule_offset = rule_offset;
+    facet->rule_len = rule_len;
     list_init(&facet->subfacets);
     netflow_flow_init(&facet->nf_flow);
     netflow_flow_update_time(ofproto->netflow, &facet->nf_flow, facet->used);
@@ -4498,6 +4688,7 @@ static void
 facet_remove(struct facet *facet)
 {
     struct subfacet *subfacet, *next_subfacet;
+    struct facet *parent_facet;
 
     ovs_assert(!list_is_empty(&facet->subfacets));
 
@@ -4520,6 +4711,7 @@ facet_remove(struct facet *facet)
     }
     classifier_remove(&facet->ofproto->facets, &facet->cr);
     cls_rule_destroy(&facet->cr);
+    facet_recirculation_id_remove(facet);
     facet_free(facet);
 }
 
@@ -4616,6 +4808,13 @@ facet_is_controller_flow(struct facet *facet)
     return false;
 }
 
+/* Returns true if the 'facet' has been created as a result of recirculation */
+static bool
+facet_is_recirculated(struct facet *facet)
+{
+    return 0 < facet->rule_offset;
+}
+
 /* Folds all of 'facet''s statistics into its rule.  Also updates the
  * accounting ofhook and emits a NetFlow expiration if appropriate.  All of
  * 'facet''s statistics in the datapath should have been zeroed and folded into
@@ -4626,6 +4825,15 @@ facet_flush_stats(struct facet *facet)
     struct ofproto_dpif *ofproto = facet->ofproto;
     struct subfacet *subfacet;
 
+    if (facet_is_recirculated(facet)) {
+        /* Do not update stats for facets with recirculation_id set.
+         * This avoids duplicate counting packets that have more than
+         * one facet due to recirculation - only hits for
+         * the top-most facet are counted here: the only facet
+         * in the case where there is no recirculation. */
+        return;
+    }
+
     LIST_FOR_EACH (subfacet, list_node, &facet->subfacets) {
         ovs_assert(!subfacet->dp_byte_count);
         ovs_assert(!subfacet->dp_packet_count);
@@ -4666,6 +4874,34 @@ facet_find(struct ofproto_dpif *ofproto, const struct flow *flow)
     return cr ? CONTAINER_OF(cr, struct facet, cr) : NULL;
 }
 
+/* Searches 'ofproto''s table of facets with recirculation ids
+ * for a facet whose recirculation_id is 'id'.
+ * Returns it if found, otherwise a null pointer.
+ *
+ * The returned facet might need revalidation; use facet_lookup_valid_by_id()
+ * instead if that is important. */
+static struct facet *
+facet_find_by_id(struct ofproto_dpif *ofproto, uint32_t id)
+{
+    uint32_t hash;
+    struct facet *facet;
+
+    /* some values are never used */
+    if (!valid_recirculation_id(id)) {
+        return NULL;
+    }
+
+    hash = recirculation_id_hash(id);
+    HMAP_FOR_EACH_WITH_HASH (facet, recirculation_id_hmap_node,
+                             hash, &ofproto->recirculation_ids) {
+        if (facet->recirculation_id == id) {
+            return facet;
+        }
+    }
+
+    return NULL;
+}
+
 /* Searches 'ofproto''s table of facets for one capable that covers
  * 'flow'.  Returns it if found, otherwise a null pointer.
  *
@@ -4687,20 +4923,45 @@ facet_lookup_valid(struct ofproto_dpif *ofproto, const struct flow *flow)
     return facet;
 }
 
+/* Searches 'ofproto''s table of facets with recirculation ids
+ * for a facet whose recirculation_id is 'id'.
+ *
+ * The returned facet is guaranteed to be valid. */
+static struct facet *
+facet_lookup_valid_by_id(struct ofproto_dpif *ofproto, uint32_t id)
+{
+    struct facet *facet;
+
+    facet = facet_find_by_id(ofproto, id);
+    if (facet
+        && (ofproto->backer->need_revalidate
+            || tag_set_intersects(&ofproto->backer->revalidate_set,
+                                  facet->xout.tags))
+        && !facet_revalidate(facet)) {
+        return NULL;
+    }
+
+    return facet;
+}
+
 static bool
-facet_check_consistency(struct facet *facet)
+facet_check_actions_consistency(struct facet *facet, struct rule_dpif *rule,
+                                const struct ofpact *ofpacts,
+                                size_t *ofpacts_len)
 {
     static struct vlog_rate_limit rl = VLOG_RATE_LIMIT_INIT(1, 15);
 
     struct xlate_out xout;
     struct xlate_in xin;
 
-    struct rule_dpif *rule;
     bool ok, fail_open;
 
     /* Check the datapath actions for consistency. */
     rule = rule_dpif_lookup(facet->ofproto, &facet->flow, NULL);
-    xlate_in_init(&xin, facet->ofproto, &facet->flow, rule, 0, NULL);
+    xlate_in_init(&xin, facet->ofproto, &facet->flow, rule, 0, NULL,
+                  facet->recirculation_id);
+    xin.ofpacts = ofpacts;
+    xin.ofpacts_len = *ofpacts_len;
     xlate_actions(&xin, &xout);
 
     fail_open = rule->up.cr.priority == FAIL_OPEN_PRIORITY;
@@ -4735,9 +4996,93 @@ facet_check_consistency(struct facet *facet)
     }
     xlate_out_uninit(&xout);
 
+    *ofpacts_len = xin.ofpacts_len;
+
     return ok;
 }
 
+
+static void
+facet_warn_rl(struct vlog_rate_limit *rl, const struct facet *facet,
+              const char *msg)
+{
+    struct ds s;
+
+    if (VLOG_DROP_WARN(rl)) {
+        return;
+    }
+
+    ds_init(&s);
+    flow_format(&s, &facet->flow);
+    ds_put_format(&s, "%s", msg);
+    VLOG_WARN("%s", ds_cstr(&s));
+    ds_destroy(&s);
+}
+
+static size_t
+get_facet_chain(struct facet *facet, struct facet **chain, size_t len)
+{
+    static struct vlog_rate_limit rl = VLOG_RATE_LIMIT_INIT(1, 15);
+    size_t top = 0;
+
+    ovs_assert(len > 0);
+
+    chain[top] = facet;
+    while (facet_is_recirculated(chain[top]) && top < len) {
+        chain[top + 1] = facet_find_by_id(facet->ofproto,
+                                          chain[top]->flow.skb_mark);
+        if (!chain[top + 1])  {
+            /* The next ancestor could not be found, so just return the
+             * incomplete chain. */
+            return top + 1;
+        }
+        top++;
+    }
+
+    if (facet_is_recirculated(chain[top])) {
+        facet_warn_rl(&rl, facet, ": parent facet of facet for "
+                       "recirculated packets could not be found "
+                       "due to under-size buffer");
+    }
+
+    return top + 1;
+}
+
+static bool
+facet_check_consistency(struct facet *facet)
+{
+    const struct ofpact *ofpacts;
+    size_t ofpacts_len;
+
+    struct rule_dpif *rule;
+    struct facet *chain[MAX_RECIRCULATION_DEPTH + 1];
+    size_t chain_len;
+
+    chain_len = get_facet_chain(facet, chain, ARRAY_SIZE(chain));
+    rule = rule_dpif_lookup(facet->ofproto, &chain[chain_len - 1]->flow, NULL);
+
+    if (facet_is_recirculated(chain[chain_len - 1])) {
+        return false;
+    }
+
+    ofpacts = rule->up.ofpacts;
+    ofpacts_len = rule->up.ofpacts_len;
+    while (chain_len--) {
+        size_t new_ofpacts_len = ofpacts_len;
+        bool ok;
+
+        ok = facet_check_actions_consistency(chain[chain_len], rule,
+                                             ofpacts, &new_ofpacts_len);
+        if (!ok) {
+            return false;
+        }
+        ofpacts = ofpact_end(ofpacts, ofpacts_len - new_ofpacts_len);
+        ofpacts_len = new_ofpacts_len;
+    }
+
+    return true;
+}
+
 /* Re-searches the classifier for 'facet':
  *
  *   - If the rule found is different from 'facet''s current rule, moves
@@ -4749,12 +5094,23 @@ facet_check_consistency(struct facet *facet)
  *   - If any of 'facet''s subfacets correspond to a new flow according to
  *     ofproto_receive(), 'facet' is removed.
  *
+ *   - If 'facet' is for a recirculated packet but the new rule does
+ *     not reciculate to the depth provide by 'facet' then 'facet' is
+ *     removed.
+ *
  *   Returns true if 'facet' is still valid.  False if 'facet' was removed. */
 static bool
 facet_revalidate(struct facet *facet)
 {
     struct ofproto_dpif *ofproto = facet->ofproto;
     struct rule_dpif *new_rule;
+
+    const struct ofpact *ofpacts;
+    size_t ofpacts_len;
+
+    struct facet *chain[MAX_RECIRCULATION_DEPTH + 1];
+    size_t chain_len;
+
     struct subfacet *subfacet;
     struct flow_wildcards wc;
     struct xlate_out xout;
@@ -4775,22 +5131,70 @@ facet_revalidate(struct facet *facet)
                                 &recv_ofproto, NULL);
         if (error
             || recv_ofproto != ofproto
+            || peek_recirculation_id(ofproto) == RECIRCULATION_ID_DUMMY
             || facet != facet_find(ofproto, &recv_flow)) {
             facet_remove(facet);
             return false;
         }
     }
 
+    chain_len = get_facet_chain(facet, chain, ARRAY_SIZE(chain));
+    /* If the top-most facet in the chain is a facet for a recirculated
+     * packet, then the original top-most can't be found because it has
+     * been revalidated with a rule that has fewer recirculation action
+     * than the previous rule. */
+    if (facet_is_recirculated(chain[chain_len - 1])) {
+        facet_remove(facet);
+        return false;
+    }
+
     flow_wildcards_init_catchall(&wc);
-    new_rule = rule_dpif_lookup(ofproto, &facet->flow, &wc);
+    new_rule = rule_dpif_lookup(ofproto, &chain[chain_len - 1]->flow, &wc);
+    ofpacts = new_rule->up.ofpacts;
+    ofpacts_len = new_rule->up.ofpacts_len;
+
+    /* In the case of a facet of a recirculated packet, there will be a chain
+     * of facets leading up to the top-most facet which is for the original
+     * unrecirculated packet. Step through the chain from the top until one
+     * before the facet being revalidated in order to recalculate the ofpacts
+     * and ofpacts_len. */
+    while (chain_len-- > 1) {
+        struct facet *f = chain[chain_len];
+
+        xlate_in_init(&xin, ofproto, &f->flow, new_rule, 0, NULL,
+                      f->recirculation_id);
+        xin.ofpacts = ofpacts;
+        xin.ofpacts_len = ofpacts_len;
+        xlate_actions(&xin, &xout);
+
+        if (!xin.recirculated && valid_recirculation_id(f->recirculation_id)) {
+            /* If the facet no longer adds a recirculation then it is no
+             * longer part of the chain of facets and should be removed. */
+            facet_remove(facet);
+            xlate_out_uninit(&xout);
+            return false;
+        }
+
+        ofpacts = xin.ofpacts;
+        ofpacts_len = xin.ofpacts_len;
+    }
 
     /* Calculate new datapath actions.
      *
      * We do not modify any 'facet' state yet, because we might need to, e.g.,
      * emit a NetFlow expiration and, if so, we need to have the old state
      * around to properly compose it. */
-    xlate_in_init(&xin, ofproto, &facet->flow, new_rule, 0, NULL);
+    xlate_in_init(&xin, ofproto, &facet->flow, new_rule, 0, NULL,
+                  facet->recirculation_id);
+    xin.ofpacts = ofpacts;
+    xin.ofpacts_len = ofpacts_len;
     xlate_actions(&xin, &xout);
+
+    if (valid_recirculation_id(facet->flow.skb_mark) ||
+        valid_recirculation_id(facet->recirculation_id)) {
+        /* The skb_mark is part of the match for recirculated facets */
+        memset(&wc.masks.skb_mark, 0xff, sizeof wc.masks.skb_mark);
+    }
     flow_wildcards_or(&xout.wc, &xout.wc, &wc);
 
     /* A facet's slow path reason should only change under dramatic
@@ -4818,6 +5222,17 @@ facet_revalidate(struct facet *facet)
             }
         }
 
+        /* Update ofpacts and recirculation fields of facet before calling
+         * facet_flush_stats() as it may indirectly call xlate_in_init()
+         * which requires those fields to be accurate. */
+        facet->rule_offset = ofpact_offset(new_rule->up.ofpacts, ofpacts);
+        facet->rule_len = ofpacts_len;
+        if (xin.recirculated) {
+            unsigned offset = ofpact_offset(new_rule->up.ofpacts, xin.ofpacts);
+            facet_set_recirculation(facet, xin.recirculation_id, offset,
+                                    xin.ofpacts_len);
+        }
+
         facet_flush_stats(facet);
 
         ofpbuf_clear(&facet->xout.odp_actions);
@@ -4880,7 +5295,7 @@ facet_push_stats(struct facet *facet, bool may_learn)
             netdev_vport_inc_rx(in_port->up.netdev, &stats);
         }
 
-        rule = rule_dpif_lookup(ofproto, &facet->flow, NULL);
+        rule = rule_dpif_lookup_by_facet(facet, NULL);
         rule_credit_stats(rule, &stats);
         netflow_flow_update_time(ofproto->netflow, &facet->nf_flow,
                                  facet->used);
@@ -4889,7 +5304,8 @@ facet_push_stats(struct facet *facet, bool may_learn)
                             stats.n_packets, stats.n_bytes);
 
         xlate_in_init(&xin, ofproto, &facet->flow, rule, stats.tcp_flags,
-                      NULL);
+                      NULL, facet->recirculation_id);
+        xlate_in_init_ofpacts(&xin, facet->rule_offset, facet->rule_len);
         xin.resubmit_stats = &stats;
         xin.may_learn = may_learn;
         xlate_actions_for_side_effects(&xin);
@@ -5186,6 +5602,20 @@ subfacet_update_stats(struct subfacet *subfacet,
 
 /* Rules. */
 
+/* Follow the chain of facets from 'facet' to its original ancestor, then use
+ * its flow to lookup the rule associated with this chain of facets. */
+static struct rule_dpif *
+rule_dpif_lookup_by_facet(struct facet *facet, struct flow_wildcards *wc)
+{
+    struct facet *root_facet, *chain[MAX_RECIRCULATION_DEPTH + 1];
+    size_t chain_len;
+
+    chain_len = get_facet_chain(facet, chain, ARRAY_SIZE(chain));
+    root_facet = chain[chain_len - 1];
+
+    return rule_dpif_lookup(facet->ofproto, &root_facet->flow, wc);
+}
+
 /* Lookup 'flow' in 'ofproto''s classifier.  If 'wc' is non-null, sets
  * the fields that were relevant as part of the lookup. */
 static struct rule_dpif *
@@ -5350,7 +5780,8 @@ rule_dpif_execute(struct rule_dpif *rule, const struct flow *flow,
     dpif_flow_stats_extract(flow, packet, time_msec(), &stats);
     rule_credit_stats(rule, &stats);
 
-    xlate_in_init(&xin, ofproto, flow, rule, stats.tcp_flags, packet);
+    xlate_in_init(&xin, ofproto, flow, rule, stats.tcp_flags, packet,
+                  RECIRCULATION_ID_DUMMY);
     xin.resubmit_stats = &stats;
     xlate_actions(&xin, &xout);
 
@@ -5409,7 +5840,8 @@ send_packet(const struct ofport_dpif *ofport, struct ofpbuf *packet)
     output.port = ofport->up.ofp_port;
     output.max_len = 0;
 
-    xlate_in_init(&xin, ofproto, &flow, NULL, 0, packet);
+    xlate_in_init(&xin, ofproto, &flow, NULL, 0, packet,
+                  RECIRCULATION_ID_DUMMY);
     xin.ofpacts_len = sizeof output;
     xin.ofpacts = &output.ofpact;
     xin.resubmit_stats = &stats;
@@ -5647,12 +6079,13 @@ packet_out(struct ofproto *ofproto_, struct ofpbuf *packet,
 
     dpif_flow_stats_extract(flow, packet, time_msec(), &stats);
 
-    xlate_in_init(&xin, ofproto, flow, NULL, stats.tcp_flags, packet);
+    xlate_in_init(&xin, ofproto, flow, NULL, stats.tcp_flags, packet,
+                  RECIRCULATION_ID_DUMMY);
     xin.resubmit_stats = &stats;
     xin.ofpacts_len = ofpacts_len;
     xin.ofpacts = ofpacts;
 
-    xlate_actions(&xin, &xout);
+    xlate_and_recirculate(&xin, &xout, packet, 0);
     dpif_execute(ofproto->backer->dpif, key.data, key.size,
                  xout.odp_actions.data, xout.odp_actions.size, packet);
     xlate_out_uninit(&xout);
@@ -6049,7 +6482,8 @@ ofproto_trace(struct ofproto_dpif *ofproto, const struct flow *flow,
         trace.flow = *flow;
         ofpbuf_use_stub(&odp_actions,
                         odp_actions_stub, sizeof odp_actions_stub);
-        xlate_in_init(&trace.xin, ofproto, flow, rule, tcp_flags, packet);
+        xlate_in_init(&trace.xin, ofproto, flow, rule, tcp_flags, packet,
+                      RECIRCULATION_ID_DUMMY);
         trace.xin.resubmit_hook = trace_resubmit;
         trace.xin.report_hook = trace_report;
 
diff --git a/ofproto/ofproto-dpif.h b/ofproto/ofproto-dpif.h
index b220423..83f6556 100644
--- a/ofproto/ofproto-dpif.h
+++ b/ofproto/ofproto-dpif.h
@@ -27,6 +27,10 @@ union user_action_cookie;
 struct ofproto_dpif;
 struct ofport_dpif;
 
+/* Recirculation Id */
+#define RECIRCULATION_ID_NONE  0
+#define RECIRCULATION_ID_DUMMY 2
+
 struct rule_dpif {
     struct rule up;
 
@@ -95,4 +99,5 @@ void ofproto_dpif_send_packet_in(struct ofproto_dpif *,
                                  struct ofputil_packet_in *pin);
 int ofproto_dpif_flow_mod(struct ofproto_dpif *, struct ofputil_flow_mod *);
 
+uint32_t get_recirculation_id(void);
 #endif /* ofproto-dpif.h */
diff --git a/tests/ofproto-dpif.at b/tests/ofproto-dpif.at
index 22215e5..5bf157d 100644
--- a/tests/ofproto-dpif.at
+++ b/tests/ofproto-dpif.at
@@ -267,13 +267,6 @@ cookie=0x7 table=5 in_port=84 actions=load:5->NXM_NX_REG4[[]],load:6->NXM_NX_TUN
 cookie=0x8 table=6 in_port=85 actions=mod_tp_src:85,controller,resubmit(86,7)
 cookie=0x9 table=7 in_port=86 actions=mod_tp_dst:86,controller,controller
 cookie=0xa dl_src=40:44:44:44:44:41 actions=push_vlan:0x8100,mod_vlan_vid:99,mod_vlan_pcp:1,controller
-cookie=0xa dl_src=40:44:44:44:44:42 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],controller
-cookie=0xa dl_src=40:44:44:44:44:43 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],controller
-cookie=0xa dl_src=40:44:44:44:44:44 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],controller
-cookie=0xa dl_src=40:44:44:44:44:45 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],dec_mpls_ttl,controller
-cookie=0xa dl_src=40:44:44:44:44:46 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],set_mpls_ttl(10),controller
-cookie=0xa dl_src=40:44:44:44:44:47 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],dec_mpls_ttl,set_mpls_ttl(10),controller
-cookie=0xa dl_src=40:44:44:44:44:48 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],set_mpls_ttl(10),dec_mpls_ttl,controller
 cookie=0xb dl_src=50:55:55:55:55:55 dl_type=0x8847 actions=load:1000->OXM_OF_MPLS_LABEL[[]],controller
 cookie=0xd dl_src=60:66:66:66:66:66 actions=pop_mpls:0x0800,controller
 cookie=0xc dl_src=70:77:77:77:77:77 actions=push_mpls:0x8848,load:1000->OXM_OF_MPLS_LABEL[[]],load:7->OXM_OF_MPLS_TC[[]],controller
@@ -360,6 +353,193 @@ NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len
 tcp,metadata=0,in_port=0,dl_vlan=99,dl_vlan_pcp=1,dl_src=40:44:44:44:44:41,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=64 tcp_csum:0
 ])
 
+dnl Modified MPLS actions.
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=50:55:55:55:55:55,dst=50:54:00:00:00:07),eth_type(0x8847),mpls(label=100,tc=7,ttl=64,bos=1)'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xb total_len=60 in_port=1 (via action) data_len=60 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=50:55:55:55:55:55,dl_dst=50:54:00:00:00:07,mpls_label=1000,mpls_tc=7,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xb total_len=60 in_port=1 (via action) data_len=60 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=50:55:55:55:55:55,dl_dst=50:54:00:00:00:07,mpls_label=1000,mpls_tc=7,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xb total_len=60 in_port=1 (via action) data_len=60 (unbuffered)
+mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=50:55:55:55:55:55,dl_dst=50:54:00:00:00:07,mpls_label=1000,mpls_tc=7,mpls_ttl=64,mpls_bos=1
+])
+
+dnl Modified MPLS pop action.
+dnl The input is a frame with a single MPLS label stack entry which tcpdump -vve shows as:
+dnl 60:66:66:66:66:66 > 50:54:00:00:00:07, ethertype MPLS unicast (0x8847), length 62: MPLS (label 20, exp 0, [S], ttl 32)
+dnl             (tos 0x0, ttl 255, id 0, offset 0, flags [none], proto TCP (6), length 44)
+dnl         192.168.0.1.80 > 192.168.0.2.0: Flags [none], cksum 0x77ec (correct), seq 42:46, win 10000, length 4
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 '50 54 00 00 00 07 60 66 66 66 66 66 88 47 00 01 41 20 45 00 00 2c 00 00 00 00 ff 06 3a 78 c0 a8 00 01 c0 a8 00 02 00 50 00 00 00 00 00 2a 00 00 00 2a 50 00 27 10 77 44 00 00 48 4f 47 45'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:66:66,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=255,tp_src=80,tp_dst=0 tcp_csum:7744
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:66:66,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=255,tp_src=80,tp_dst=0 tcp_csum:7744
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:66:66,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=255,tp_src=80,tp_dst=0 tcp_csum:7744
+])
+
+dnl Modified MPLS ipv6 controller action.
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=70:77:77:77:77:77,dst=50:54:00:00:00:07),eth_type(0x86dd),ipv6(src=::1,dst=::2,label=0,proto=10,tclass=0x70,hlimit=128,frag=no)'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xc total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=70:77:77:77:77:77,dl_dst=50:54:00:00:00:07,mpls_label=1000,mpls_tc=7,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xc total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=70:77:77:77:77:77,dl_dst=50:54:00:00:00:07,mpls_label=1000,mpls_tc=7,mpls_ttl=64,mpls_bos=1
+dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xc total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
+mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=70:77:77:77:77:77,dl_dst=50:54:00:00:00:07,mpls_label=1000,mpls_tc=7,mpls_ttl=64,mpls_bos=1
+])
+
+dnl Checksum TCP.
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --no-chdir --pidfile 2> ofctl_monitor.log])
+
+for i in 1 ; do
+    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=20:22:22:22:22:22,dst=50:54:00:00:00:07),eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no),tcp(src=8,dst=11)'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 18])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0x1 total_len=60 in_port=1 (via action) data_len=60 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=20:22:22:22:22:22,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=64,tp_src=8,tp_dst=11 tcp_csum:0
+dnl
+NXT_PACKET_IN (xid=0x0): table_id=1 cookie=0x3 total_len=64 in_port=1 reg0=0x1 (via action) data_len=64 (unbuffered)
+tcp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=20:22:22:22:22:22,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=64,tp_src=8,tp_dst=11 tcp_csum:0
+dnl
+NXT_PACKET_IN (xid=0x0): table_id=2 cookie=0x4 total_len=64 in_port=1 reg0=0x1 reg1=0x2 (via action) data_len=64 (unbuffered)
+tcp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=80:81:81:81:81:81,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=64,tp_src=8,tp_dst=11 tcp_csum:0
+dnl
+NXT_PACKET_IN (xid=0x0): table_id=3 cookie=0x5 total_len=64 in_port=1 reg0=0x1 reg1=0x2 reg2=0x3 (via action) data_len=64 (unbuffered)
+tcp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=80:81:81:81:81:81,dl_dst=82:82:82:82:82:82,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=64,tp_src=8,tp_dst=11 tcp_csum:0
+dnl
+NXT_PACKET_IN (xid=0x0): table_id=4 cookie=0x6 total_len=64 in_port=1 reg0=0x1 reg1=0x2 reg2=0x3 reg3=0x4 (via action) data_len=64 (unbuffered)
+tcp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=80:81:81:81:81:81,dl_dst=82:82:82:82:82:82,nw_src=83.83.83.83,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=64,tp_src=8,tp_dst=11 tcp_csum:1a03
+dnl
+NXT_PACKET_IN (xid=0x0): table_id=5 cookie=0x7 total_len=64 in_port=1 tun_id=0x6 reg0=0x1 reg1=0x2 reg2=0x3 reg3=0x4 reg4=0x5 (via action) data_len=64 (unbuffered)
+tcp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=80:81:81:81:81:81,dl_dst=82:82:82:82:82:82,nw_src=83.83.83.83,nw_dst=84.84.84.84,nw_tos=0,nw_ecn=0,nw_ttl=64,tp_src=8,tp_dst=11 tcp_csum:3205
+dnl
+NXT_PACKET_IN (xid=0x0): table_id=6 cookie=0x8 total_len=64 in_port=1 tun_id=0x6 reg0=0x1 reg1=0x2 reg2=0x3 reg3=0x4 reg4=0x5 (via action) data_len=64 (unbuffered)
+tcp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=80:81:81:81:81:81,dl_dst=82:82:82:82:82:82,nw_src=83.83.83.83,nw_dst=84.84.84.84,nw_tos=0,nw_ecn=0,nw_ttl=64,tp_src=85,tp_dst=11 tcp_csum:31b8
+dnl
+NXT_PACKET_IN (xid=0x0): table_id=7 cookie=0x9 total_len=64 in_port=1 tun_id=0x6 reg0=0x1 reg1=0x2 reg2=0x3 reg3=0x4 reg4=0x5 (via action) data_len=64 (unbuffered)
+tcp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=80:81:81:81:81:81,dl_dst=82:82:82:82:82:82,nw_src=83.83.83.83,nw_dst=84.84.84.84,nw_tos=0,nw_ecn=0,nw_ttl=64,tp_src=85,tp_dst=86 tcp_csum:316d
+dnl
+NXT_PACKET_IN (xid=0x0): table_id=7 cookie=0x9 total_len=64 in_port=1 tun_id=0x6 reg0=0x1 reg1=0x2 reg2=0x3 reg3=0x4 reg4=0x5 (via action) data_len=64 (unbuffered)
+tcp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=80:81:81:81:81:81,dl_dst=82:82:82:82:82:82,nw_src=83.83.83.83,nw_dst=84.84.84.84,nw_tos=0,nw_ecn=0,nw_ttl=64,tp_src=85,tp_dst=86 tcp_csum:316d
+])
+
+dnl Checksum UDP.
+AT_CHECK([ovs-ofctl monitor br0 65534 --detach --no-chdir --pidfile 2> ofctl_monitor.log])
+
+for i in 1 ; do
+    ovs-appctl netdev-dummy/receive p1 '50 54 00 00 00 07 20 22 22 22 22 22 08 00 45 00 00 1C 00 00 00 00 00 11 00 00 C0 A8 00 01 C0 A8 00 02 00 08 00 0B 00 00 12 34 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 18])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0x1 total_len=60 in_port=1 (via action) data_len=60 (unbuffered)
+udp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=20:22:22:22:22:22,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=0,tp_src=8,tp_dst=11 udp_csum:1234
+dnl
+NXT_PACKET_IN (xid=0x0): table_id=1 cookie=0x3 total_len=64 in_port=1 reg0=0x1 (via action) data_len=64 (unbuffered)
+udp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=20:22:22:22:22:22,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=0,tp_src=8,tp_dst=11 udp_csum:1234
+dnl
+NXT_PACKET_IN (xid=0x0): table_id=2 cookie=0x4 total_len=64 in_port=1 reg0=0x1 reg1=0x2 (via action) data_len=64 (unbuffered)
+udp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=80:81:81:81:81:81,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=0,tp_src=8,tp_dst=11 udp_csum:1234
+dnl
+NXT_PACKET_IN (xid=0x0): table_id=3 cookie=0x5 total_len=64 in_port=1 reg0=0x1 reg1=0x2 reg2=0x3 (via action) data_len=64 (unbuffered)
+udp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=80:81:81:81:81:81,dl_dst=82:82:82:82:82:82,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=0,tp_src=8,tp_dst=11 udp_csum:1234
+dnl
+NXT_PACKET_IN (xid=0x0): table_id=4 cookie=0x6 total_len=64 in_port=1 reg0=0x1 reg1=0x2 reg2=0x3 reg3=0x4 (via action) data_len=64 (unbuffered)
+udp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=80:81:81:81:81:81,dl_dst=82:82:82:82:82:82,nw_src=83.83.83.83,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=0,tp_src=8,tp_dst=11 udp_csum:2c37
+dnl
+NXT_PACKET_IN (xid=0x0): table_id=5 cookie=0x7 total_len=64 in_port=1 tun_id=0x6 reg0=0x1 reg1=0x2 reg2=0x3 reg3=0x4 reg4=0x5 (via action) data_len=64 (unbuffered)
+udp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=80:81:81:81:81:81,dl_dst=82:82:82:82:82:82,nw_src=83.83.83.83,nw_dst=84.84.84.84,nw_tos=0,nw_ecn=0,nw_ttl=0,tp_src=8,tp_dst=11 udp_csum:4439
+dnl
+NXT_PACKET_IN (xid=0x0): table_id=6 cookie=0x8 total_len=64 in_port=1 tun_id=0x6 reg0=0x1 reg1=0x2 reg2=0x3 reg3=0x4 reg4=0x5 (via action) data_len=64 (unbuffered)
+udp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=80:81:81:81:81:81,dl_dst=82:82:82:82:82:82,nw_src=83.83.83.83,nw_dst=84.84.84.84,nw_tos=0,nw_ecn=0,nw_ttl=0,tp_src=85,tp_dst=11 udp_csum:43ec
+dnl
+NXT_PACKET_IN (xid=0x0): table_id=7 cookie=0x9 total_len=64 in_port=1 tun_id=0x6 reg0=0x1 reg1=0x2 reg2=0x3 reg3=0x4 reg4=0x5 (via action) data_len=64 (unbuffered)
+udp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=80:81:81:81:81:81,dl_dst=82:82:82:82:82:82,nw_src=83.83.83.83,nw_dst=84.84.84.84,nw_tos=0,nw_ecn=0,nw_ttl=0,tp_src=85,tp_dst=86 udp_csum:43a1
+dnl
+NXT_PACKET_IN (xid=0x0): table_id=7 cookie=0x9 total_len=64 in_port=1 tun_id=0x6 reg0=0x1 reg1=0x2 reg2=0x3 reg3=0x4 reg4=0x5 (via action) data_len=64 (unbuffered)
+udp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=80:81:81:81:81:81,dl_dst=82:82:82:82:82:82,nw_src=83.83.83.83,nw_dst=84.84.84.84,nw_tos=0,nw_ecn=0,nw_ttl=0,tp_src=85,tp_dst=86 udp_csum:43a1
+])
+
+AT_CHECK([ovs-appctl time/warp 5000], [0], [ignore])
+AT_CHECK([ovs-ofctl dump-flows br0 | ofctl_strip | sort], [0], [dnl
+ cookie=0x1, n_packets=2, n_bytes=120, dl_src=20:22:22:22:22:22 actions=CONTROLLER:65535,resubmit(80,1)
+ cookie=0x2, n_packets=3, n_bytes=180, dl_src=30:33:33:33:33:33 actions=mod_vlan_vid:15,CONTROLLER:65535
+ cookie=0x3, table=1, n_packets=2, n_bytes=120, in_port=80 actions=load:0x1->NXM_NX_REG0[[]],mod_vlan_vid:80,CONTROLLER:65535,resubmit(81,2)
+ cookie=0x4, table=2, n_packets=2, n_bytes=120, in_port=81 actions=load:0x2->NXM_NX_REG1[[]],mod_dl_src:80:81:81:81:81:81,CONTROLLER:65535,resubmit(82,3)
+ cookie=0x5, table=3, n_packets=2, n_bytes=120, in_port=82 actions=load:0x3->NXM_NX_REG2[[]],mod_dl_dst:82:82:82:82:82:82,CONTROLLER:65535,resubmit(83,4)
+ cookie=0x6, table=4, n_packets=2, n_bytes=120, in_port=83 actions=load:0x4->NXM_NX_REG3[[]],mod_nw_src:83.83.83.83,CONTROLLER:65535,resubmit(84,5)
+ cookie=0x7, table=5, n_packets=2, n_bytes=120, in_port=84 actions=load:0x5->NXM_NX_REG4[[]],load:0x6->NXM_NX_TUN_ID[[]],mod_nw_dst:84.84.84.84,CONTROLLER:65535,resubmit(85,6)
+ cookie=0x8, table=6, n_packets=2, n_bytes=120, in_port=85 actions=mod_tp_src:85,CONTROLLER:65535,resubmit(86,7)
+ cookie=0x9, table=7, n_packets=2, n_bytes=120, in_port=86 actions=mod_tp_dst:86,CONTROLLER:65535,CONTROLLER:65535
+ cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:44:41 actions=mod_vlan_vid:99,mod_vlan_pcp:1,CONTROLLER:65535
+ cookie=0xb, n_packets=3, n_bytes=180, mpls,dl_src=50:55:55:55:55:55 actions=load:0x3e8->OXM_OF_MPLS_LABEL[[]],CONTROLLER:65535
+ cookie=0xc, n_packets=3, n_bytes=180, dl_src=70:77:77:77:77:77 actions=push_mpls:0x8848,load:0x3e8->OXM_OF_MPLS_LABEL[[]],load:0x7->OXM_OF_MPLS_TC[[]],CONTROLLER:65535
+ cookie=0xd, n_packets=3, n_bytes=186, dl_src=60:66:66:66:66:66 actions=pop_mpls:0x0800,CONTROLLER:65535
+ n_packets=3, n_bytes=180, dl_src=10:11:11:11:11:11 actions=CONTROLLER:65535
+NXST_FLOW reply:
+])
+
+OVS_VSWITCHD_STOP
+AT_CLEANUP
+
+AT_SETUP([ofproto-dpif - MPLS handling])
+OVS_VSWITCHD_START([dnl
+   add-port br0 p1 -- set Interface p1 type=dummy
+])
+ON_EXIT([kill `cat ovs-ofctl.pid`])
+
+AT_CAPTURE_FILE([ofctl_monitor.log])
+AT_DATA([flows.txt], [dnl
+cookie=0xa dl_src=40:44:44:44:44:42 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],controller
+cookie=0xa dl_src=40:44:44:44:44:43 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],controller
+cookie=0xa dl_src=40:44:44:44:44:44 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],controller
+cookie=0xa dl_src=40:44:44:44:44:45 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],dec_mpls_ttl,controller
+cookie=0xa dl_src=40:44:44:44:44:46 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],set_mpls_ttl(10),controller
+cookie=0xa dl_src=40:44:44:44:44:47 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],dec_mpls_ttl,set_mpls_ttl(10),controller
+cookie=0xa dl_src=40:44:44:44:44:48 actions=push_mpls:0x8847,load:10->OXM_OF_MPLS_LABEL[[]],load:3->OXM_OF_MPLS_TC[[]],set_mpls_ttl(10),dec_mpls_ttl,controller
+cookie=0xd dl_src=60:66:66:66:00:01 actions=pop_mpls:0x0800,dec_ttl,controller
+cookie=0xd dl_src=60:66:66:66:00:02 actions=pop_mpls:0x0800,load:0xa000001->OXM_OF_IPV4_DST[[]],controller
+cookie=0xd dl_src=60:66:66:66:00:03 actions=pop_mpls:0x0800,move:OXM_OF_IPV4_DST[[]]->OXM_OF_IPV4_SRC[[]],controller
+cookie=0xd dl_src=60:66:66:66:00:04 actions=pop_mpls:0x0800,push:OXM_OF_IPV4_DST[[]],pop:OXM_OF_IPV4_SRC[[]],controller
+cookie=0xd dl_src=60:66:66:66:00:05 actions=pop_mpls:0x0800,multipath(eth_src,50,modulo_n,256,0,OXM_OF_IPV4_SRC[[0..7]]),controller
+cookie=0xd dl_src=60:66:66:66:00:06 actions=pop_mpls:0x0800,bundle_load(eth_src,50,hrw,ofport,OXM_OF_IPV4_SRC[[0..15]],slaves:1,2),controller
+cookie=0xd dl_src=60:66:66:66:00:07 actions=pop_mpls:0x0800,learn(table=1,hard_timeout=60,eth_type=0x800,nw_proto=6,OXM_OF_IPV4_SRC[[]]=OXM_OF_IPV4_DST[[]]),controller
+])
+AT_CHECK([ovs-ofctl add-flows br0 flows.txt])
+
 dnl Modified MPLS controller action.
 AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
 
@@ -388,9 +568,9 @@ dnl in_port(1),eth(src=00:01:02:03:04:05,dst=10:11:12:13:14:15),eth_type(0x8847)
 for i in 1 2 3; do
     ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:44:43,dst=50:54:00:00:00:07),eth_type(0x8847),mpls(label=11,tc=3,ttl=64,bos=1)'
 done
-
 OVS_WAIT_UNTIL([ovs-appctl -t ovs-ofctl exit])
 AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+
 NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
 mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:44:43,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=64,mpls_bos=0
 dnl
@@ -501,162 +681,176 @@ NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=64 in_port=1 (via action) data_len
 mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=40:44:44:44:44:48,dl_dst=50:54:00:00:00:07,mpls_label=10,mpls_tc=3,mpls_ttl=9,mpls_bos=1
 ])
 
-dnl Modified MPLS actions.
+dnl Modified MPLS pop action.
+dnl The input is a frame with a single MPLS label stack entry which tcpdump -vve shows as:
+dnl 60:66:66:66:00:01 > 50:54:00:00:00:07, ethertype MPLS unicast (0x8847), length 62: MPLS (label 20, exp 0, [S], ttl 32)
+dnl             (tos 0x0, ttl 255, id 0, offset 0, flags [none], proto TCP (6), length 44)
+dnl         192.168.0.1.80 > 192.168.0.2.0: Flags [none], cksum 0x77ec (correct), seq 42:46, win 10000, length 4
 AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
 
 for i in 1 2 3; do
-    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=50:55:55:55:55:55,dst=50:54:00:00:00:07),eth_type(0x8847),mpls(label=100,tc=7,ttl=64,bos=1)'
+    ovs-appctl netdev-dummy/receive p1 '50 54 00 00 00 07 60 66 66 66 00 01 88 48 00 01 41 20 45 00 00 2c 00 00 00 00 ff 06 3a 78 c0 a8 00 01 c0 a8 00 02 00 50 00 00 00 00 00 2a 00 00 00 2a 50 00 27 10 77 44 00 00 48 4f 47 45'
 done
 OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
 ovs-appctl -t ovs-ofctl exit
 
 AT_CHECK([cat ofctl_monitor.log], [0], [dnl
-NXT_PACKET_IN (xid=0x0): cookie=0xb total_len=60 in_port=1 (via action) data_len=60 (unbuffered)
-mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=50:55:55:55:55:55,dl_dst=50:54:00:00:00:07,mpls_label=1000,mpls_tc=7,mpls_ttl=64,mpls_bos=1
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:00:01,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=254,tp_src=80,tp_dst=0 tcp_csum:7744
 dnl
-NXT_PACKET_IN (xid=0x0): cookie=0xb total_len=60 in_port=1 (via action) data_len=60 (unbuffered)
-mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=50:55:55:55:55:55,dl_dst=50:54:00:00:00:07,mpls_label=1000,mpls_tc=7,mpls_ttl=64,mpls_bos=1
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:00:01,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=254,tp_src=80,tp_dst=0 tcp_csum:7744
 dnl
-NXT_PACKET_IN (xid=0x0): cookie=0xb total_len=60 in_port=1 (via action) data_len=60 (unbuffered)
-mpls,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=50:55:55:55:55:55,dl_dst=50:54:00:00:00:07,mpls_label=1000,mpls_tc=7,mpls_ttl=64,mpls_bos=1
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:00:01,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=254,tp_src=80,tp_dst=0 tcp_csum:7744
 ])
 
-dnl Modified MPLS ipv6 controller action.
+dnl Modified MPLS pop action.
+dnl The input is a frame with a single MPLS label stack entry which tcpdump -vve shows as:
+dnl 60:66:66:66:00:02 > 50:54:00:00:00:07, ethertype MPLS unicast (0x8847), length 62: MPLS (label 20, exp 0, [S], ttl 32)
+dnl             (tos 0x0, ttl 255, id 0, offset 0, flags [none], proto TCP (6), length 44)
+dnl         192.168.0.1.80 > 192.168.0.2.0: Flags [none], cksum 0x77ec (correct), seq 42:46, win 10000, length 4
 AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
 
 for i in 1 2 3; do
-    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=70:77:77:77:77:77,dst=50:54:00:00:00:07),eth_type(0x86dd),ipv6(src=::1,dst=::2,label=0,proto=10,tclass=0x70,hlimit=128,frag=no)'
+    ovs-appctl netdev-dummy/receive p1 '50 54 00 00 00 07 60 66 66 66 00 02 88 47 00 01 41 20 45 00 00 2c 00 00 00 00 ff 06 3a 78 c0 a8 00 01 c0 a8 00 02 00 50 00 00 00 00 00 2a 00 00 00 2a 50 00 27 10 77 44 00 00 48 4f 47 45'
 done
 OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
 ovs-appctl -t ovs-ofctl exit
 
 AT_CHECK([cat ofctl_monitor.log], [0], [dnl
-NXT_PACKET_IN (xid=0x0): cookie=0xc total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
-mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=70:77:77:77:77:77,dl_dst=50:54:00:00:00:07,mpls_label=1000,mpls_tc=7,mpls_ttl=64,mpls_bos=1
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:00:02,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=10.0.0.1,nw_tos=0,nw_ecn=0,nw_ttl=255,tp_src=80,tp_dst=0 tcp_csum:2dee
 dnl
-NXT_PACKET_IN (xid=0x0): cookie=0xc total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
-mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=70:77:77:77:77:77,dl_dst=50:54:00:00:00:07,mpls_label=1000,mpls_tc=7,mpls_ttl=64,mpls_bos=1
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:00:02,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=10.0.0.1,nw_tos=0,nw_ecn=0,nw_ttl=255,tp_src=80,tp_dst=0 tcp_csum:2dee
 dnl
-NXT_PACKET_IN (xid=0x0): cookie=0xc total_len=64 in_port=1 (via action) data_len=64 (unbuffered)
-mplsm,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=70:77:77:77:77:77,dl_dst=50:54:00:00:00:07,mpls_label=1000,mpls_tc=7,mpls_ttl=64,mpls_bos=1
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:00:02,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=10.0.0.1,nw_tos=0,nw_ecn=0,nw_ttl=255,tp_src=80,tp_dst=0 tcp_csum:2dee
 ])
 
-
 dnl Modified MPLS pop action.
-dnl The input is a frame with two MPLS headers which tcpdump -vve shows as:
-dnl 60:66:66:66:66:66 > 50:54:00:00:00:07, ethertype MPLS multicast (0x8847), length 66: MPLS (label 20, exp 0, ttl 32)
-dnl             (tos 0x0, ttl 64, id 0, offset 0, flags [none], proto TCP (6), length 44)
-
+dnl The input is a frame with a single MPLS label stack entry which tcpdump -vve shows as:
+dnl 60:66:66:66:00:03 > 50:54:00:00:00:07, ethertype MPLS unicast (0x8848), length 62: MPLS (label 20, exp 0, [S], ttl 32)
+dnl             (tos 0x0, ttl 255, id 0, offset 0, flags [none], proto TCP (6), length 44)
+dnl         192.168.0.1.80 > 192.168.0.2.0: Flags [none], cksum 0x77ec (correct), seq 42:46, win 10000, length 4
 AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
 
 for i in 1 2 3; do
-    ovs-appctl netdev-dummy/receive p1 '50 54 00 00 00 07 60 66 66 66 66 66 88 47 00 01 41 20 45 00 00 2c 00 00 00 00 40 06 3b 78 c0 a8 00 01 c0 a8 00 02 00 50 00 00 00 00 00 2a 00 00 00 2a 50 00 27 10 77 44 00 00 48 4f 47 45'
+    ovs-appctl netdev-dummy/receive p1 '50 54 00 00 00 07 60 66 66 66 00 03 88 48 00 01 41 20 45 00 00 2c 00 00 00 00 ff 06 3a 78 c0 a8 00 01 c0 a8 00 02 00 50 00 00 00 00 00 2a 00 00 00 2a 50 00 27 10 77 44 00 00 48 4f 47 45'
 done
-#for i in 2 3; do
-#    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=60:66:66:66:66:66,dst=50:54:00:00:00:07),eth_type(0x8847),mpls(label=10,tc=3,ttl=100,bos=1)'
-#done
 OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
 ovs-appctl -t ovs-ofctl exit
 
 AT_CHECK([cat ofctl_monitor.log], [0], [dnl
 NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
-tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:66:66,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=64,tp_src=80,tp_dst=0 tcp_csum:7744
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:00:03,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.2,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=255,tp_src=80,tp_dst=0 tcp_csum:7743
 dnl
 NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
-tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:66:66,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=64,tp_src=80,tp_dst=0 tcp_csum:7744
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:00:03,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.2,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=255,tp_src=80,tp_dst=0 tcp_csum:7743
 dnl
 NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
-tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:66:66,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=64,tp_src=80,tp_dst=0 tcp_csum:7744
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:00:03,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.2,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=255,tp_src=80,tp_dst=0 tcp_csum:7743
 ])
 
-dnl Checksum TCP.
-AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --no-chdir --pidfile 2> ofctl_monitor.log])
+dnl Modified MPLS pop action.
+dnl The input is a frame with a single MPLS label stack entry which tcpdump -vve shows as:
+dnl 60:66:66:66:00:04 > 50:54:00:00:00:07, ethertype MPLS unicast (0x8847), length 62: MPLS (label 20, exp 0, [S], ttl 32)
+dnl             (tos 0x0, ttl 255, id 0, offset 0, flags [none], proto TCP (6), length 44)
+dnl         192.168.0.1.80 > 192.168.0.2.0: Flags [none], cksum 0x77ec (correct), seq 42:46, win 10000, length 4
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
 
-for i in 1 ; do
-    ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=20:22:22:22:22:22,dst=50:54:00:00:00:07),eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no),tcp(src=8,dst=11)'
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 '50 54 00 00 00 07 60 66 66 66 00 04 88 47 00 01 41 20 45 00 00 2c 00 00 00 00 ff 06 3a 78 c0 a8 00 01 c0 a8 00 02 00 50 00 00 00 00 00 2a 00 00 00 2a 50 00 27 10 77 44 00 00 48 4f 47 45'
 done
-OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 18])
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
 ovs-appctl -t ovs-ofctl exit
 
 AT_CHECK([cat ofctl_monitor.log], [0], [dnl
-NXT_PACKET_IN (xid=0x0): cookie=0x1 total_len=60 in_port=1 (via action) data_len=60 (unbuffered)
-tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=20:22:22:22:22:22,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=64,tp_src=8,tp_dst=11 tcp_csum:0
-dnl
-NXT_PACKET_IN (xid=0x0): table_id=1 cookie=0x3 total_len=64 in_port=1 reg0=0x1 (via action) data_len=64 (unbuffered)
-tcp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=20:22:22:22:22:22,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=64,tp_src=8,tp_dst=11 tcp_csum:0
-dnl
-NXT_PACKET_IN (xid=0x0): table_id=2 cookie=0x4 total_len=64 in_port=1 reg0=0x1 reg1=0x2 (via action) data_len=64 (unbuffered)
-tcp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=80:81:81:81:81:81,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=64,tp_src=8,tp_dst=11 tcp_csum:0
-dnl
-NXT_PACKET_IN (xid=0x0): table_id=3 cookie=0x5 total_len=64 in_port=1 reg0=0x1 reg1=0x2 reg2=0x3 (via action) data_len=64 (unbuffered)
-tcp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=80:81:81:81:81:81,dl_dst=82:82:82:82:82:82,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=64,tp_src=8,tp_dst=11 tcp_csum:0
-dnl
-NXT_PACKET_IN (xid=0x0): table_id=4 cookie=0x6 total_len=64 in_port=1 reg0=0x1 reg1=0x2 reg2=0x3 reg3=0x4 (via action) data_len=64 (unbuffered)
-tcp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=80:81:81:81:81:81,dl_dst=82:82:82:82:82:82,nw_src=83.83.83.83,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=64,tp_src=8,tp_dst=11 tcp_csum:1a03
-dnl
-NXT_PACKET_IN (xid=0x0): table_id=5 cookie=0x7 total_len=64 in_port=1 tun_id=0x6 reg0=0x1 reg1=0x2 reg2=0x3 reg3=0x4 reg4=0x5 (via action) data_len=64 (unbuffered)
-tcp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=80:81:81:81:81:81,dl_dst=82:82:82:82:82:82,nw_src=83.83.83.83,nw_dst=84.84.84.84,nw_tos=0,nw_ecn=0,nw_ttl=64,tp_src=8,tp_dst=11 tcp_csum:3205
-dnl
-NXT_PACKET_IN (xid=0x0): table_id=6 cookie=0x8 total_len=64 in_port=1 tun_id=0x6 reg0=0x1 reg1=0x2 reg2=0x3 reg3=0x4 reg4=0x5 (via action) data_len=64 (unbuffered)
-tcp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=80:81:81:81:81:81,dl_dst=82:82:82:82:82:82,nw_src=83.83.83.83,nw_dst=84.84.84.84,nw_tos=0,nw_ecn=0,nw_ttl=64,tp_src=85,tp_dst=11 tcp_csum:31b8
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:00:04,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.2,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=255,tp_src=80,tp_dst=0 tcp_csum:7743
 dnl
-NXT_PACKET_IN (xid=0x0): table_id=7 cookie=0x9 total_len=64 in_port=1 tun_id=0x6 reg0=0x1 reg1=0x2 reg2=0x3 reg3=0x4 reg4=0x5 (via action) data_len=64 (unbuffered)
-tcp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=80:81:81:81:81:81,dl_dst=82:82:82:82:82:82,nw_src=83.83.83.83,nw_dst=84.84.84.84,nw_tos=0,nw_ecn=0,nw_ttl=64,tp_src=85,tp_dst=86 tcp_csum:316d
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:00:04,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.2,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=255,tp_src=80,tp_dst=0 tcp_csum:7743
 dnl
-NXT_PACKET_IN (xid=0x0): table_id=7 cookie=0x9 total_len=64 in_port=1 tun_id=0x6 reg0=0x1 reg1=0x2 reg2=0x3 reg3=0x4 reg4=0x5 (via action) data_len=64 (unbuffered)
-tcp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=80:81:81:81:81:81,dl_dst=82:82:82:82:82:82,nw_src=83.83.83.83,nw_dst=84.84.84.84,nw_tos=0,nw_ecn=0,nw_ttl=64,tp_src=85,tp_dst=86 tcp_csum:316d
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:00:04,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.2,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=255,tp_src=80,tp_dst=0 tcp_csum:7743
 ])
 
-dnl Checksum UDP.
-AT_CHECK([ovs-ofctl monitor br0 65534 --detach --no-chdir --pidfile 2> ofctl_monitor.log])
+dnl Modified MPLS pop action.
+dnl The input is a frame with a single MPLS label stack entry which tcpdump -vve shows as:
+dnl 60:66:66:66:00:05 > 50:54:00:00:00:07, ethertype MPLS unicast (0x8848), length 62: MPLS (label 20, exp 0, [S], ttl 32)
+dnl             (tos 0x0, ttl 255, id 0, offset 0, flags [none], proto TCP (6), length 44)
+dnl         192.168.0.1.80 > 192.168.0.2.0: Flags [none], cksum 0x77ec (correct), seq 42:46, win 10000, length 4
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
 
-for i in 1 ; do
-    ovs-appctl netdev-dummy/receive p1 '50 54 00 00 00 07 20 22 22 22 22 22 08 00 45 00 00 1C 00 00 00 00 00 11 00 00 C0 A8 00 01 C0 A8 00 02 00 08 00 0B 00 00 12 34 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00'
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 '50 54 00 00 00 07 60 66 66 66 00 05 88 48 00 01 41 20 45 00 00 2c 00 00 00 00 ff 06 3a 78 c0 a8 00 01 c0 a8 00 02 00 50 00 00 00 00 00 2a 00 00 00 2a 50 00 27 10 77 44 00 00 48 4f 47 45'
 done
-OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 18])
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
 ovs-appctl -t ovs-ofctl exit
 
 AT_CHECK([cat ofctl_monitor.log], [0], [dnl
-NXT_PACKET_IN (xid=0x0): cookie=0x1 total_len=60 in_port=1 (via action) data_len=60 (unbuffered)
-udp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=20:22:22:22:22:22,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=0,tp_src=8,tp_dst=11 udp_csum:1234
-dnl
-NXT_PACKET_IN (xid=0x0): table_id=1 cookie=0x3 total_len=64 in_port=1 reg0=0x1 (via action) data_len=64 (unbuffered)
-udp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=20:22:22:22:22:22,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=0,tp_src=8,tp_dst=11 udp_csum:1234
-dnl
-NXT_PACKET_IN (xid=0x0): table_id=2 cookie=0x4 total_len=64 in_port=1 reg0=0x1 reg1=0x2 (via action) data_len=64 (unbuffered)
-udp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=80:81:81:81:81:81,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=0,tp_src=8,tp_dst=11 udp_csum:1234
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:00:05,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.106,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=255,tp_src=80,tp_dst=0 tcp_csum:76db
 dnl
-NXT_PACKET_IN (xid=0x0): table_id=3 cookie=0x5 total_len=64 in_port=1 reg0=0x1 reg1=0x2 reg2=0x3 (via action) data_len=64 (unbuffered)
-udp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=80:81:81:81:81:81,dl_dst=82:82:82:82:82:82,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=0,tp_src=8,tp_dst=11 udp_csum:1234
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:00:05,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.106,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=255,tp_src=80,tp_dst=0 tcp_csum:76db
 dnl
-NXT_PACKET_IN (xid=0x0): table_id=4 cookie=0x6 total_len=64 in_port=1 reg0=0x1 reg1=0x2 reg2=0x3 reg3=0x4 (via action) data_len=64 (unbuffered)
-udp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=80:81:81:81:81:81,dl_dst=82:82:82:82:82:82,nw_src=83.83.83.83,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=0,tp_src=8,tp_dst=11 udp_csum:2c37
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:00:05,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.106,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=255,tp_src=80,tp_dst=0 tcp_csum:76db
+])
+
+dnl Modified MPLS pop action.
+dnl The input is a frame with a single MPLS label stack entry which tcpdump -vve shows as:
+dnl 60:66:66:66:00:06 > 50:54:00:00:00:07, ethertype MPLS unicast (0x8847), length 62: MPLS (label 20, exp 0, [S], ttl 32)
+dnl             (tos 0x0, ttl 255, id 0, offset 0, flags [none], proto TCP (6), length 44)
+dnl         192.168.0.1.80 > 192.168.0.2.0: Flags [none], cksum 0x77ec (correct), seq 42:46, win 10000, length 4
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 '50 54 00 00 00 07 60 66 66 66 00 06 88 47 00 01 41 20 45 00 00 2c 00 00 00 00 ff 06 3a 78 c0 a8 00 01 c0 a8 00 02 00 50 00 00 00 00 00 2a 00 00 00 2a 50 00 27 10 77 44 00 00 48 4f 47 45'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:00:06,dl_dst=50:54:00:00:00:07,nw_src=192.168.255.255,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=255,tp_src=80,tp_dst=0 tcp_csum:7745
 dnl
-NXT_PACKET_IN (xid=0x0): table_id=5 cookie=0x7 total_len=64 in_port=1 tun_id=0x6 reg0=0x1 reg1=0x2 reg2=0x3 reg3=0x4 reg4=0x5 (via action) data_len=64 (unbuffered)
-udp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=80:81:81:81:81:81,dl_dst=82:82:82:82:82:82,nw_src=83.83.83.83,nw_dst=84.84.84.84,nw_tos=0,nw_ecn=0,nw_ttl=0,tp_src=8,tp_dst=11 udp_csum:4439
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:00:06,dl_dst=50:54:00:00:00:07,nw_src=192.168.255.255,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=255,tp_src=80,tp_dst=0 tcp_csum:7745
 dnl
-NXT_PACKET_IN (xid=0x0): table_id=6 cookie=0x8 total_len=64 in_port=1 tun_id=0x6 reg0=0x1 reg1=0x2 reg2=0x3 reg3=0x4 reg4=0x5 (via action) data_len=64 (unbuffered)
-udp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=80:81:81:81:81:81,dl_dst=82:82:82:82:82:82,nw_src=83.83.83.83,nw_dst=84.84.84.84,nw_tos=0,nw_ecn=0,nw_ttl=0,tp_src=85,tp_dst=11 udp_csum:43ec
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:00:06,dl_dst=50:54:00:00:00:07,nw_src=192.168.255.255,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=255,tp_src=80,tp_dst=0 tcp_csum:7745
+])
+
+dnl Modified MPLS pop action.
+dnl The input is a frame with a single MPLS label stack entry which tcpdump -vve shows as:
+dnl 60:66:66:66:00:07 > 50:54:00:00:00:07, ethertype MPLS unicast (0x8848), length 62: MPLS (label 20, exp 0, [S], ttl 32)
+dnl             (tos 0x0, ttl 255, id 0, offset 0, flags [none], proto TCP (6), length 44)
+dnl         192.168.0.1.80 > 192.168.0.2.0: Flags [none], cksum 0x77ec (correct), seq 42:46, win 10000, length 4
+AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor.log])
+
+for i in 1 2 3; do
+    ovs-appctl netdev-dummy/receive p1 '50 54 00 00 00 07 60 66 66 66 00 07 88 48 00 01 41 20 45 00 00 2c 00 00 00 00 ff 06 3a 78 c0 a8 00 01 c0 a8 00 02 00 50 00 00 00 00 00 2a 00 00 00 2a 50 00 27 10 77 44 00 00 48 4f 47 45'
+done
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
+
+AT_CHECK([cat ofctl_monitor.log], [0], [dnl
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:00:07,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=255,tp_src=80,tp_dst=0 tcp_csum:7744
 dnl
-NXT_PACKET_IN (xid=0x0): table_id=7 cookie=0x9 total_len=64 in_port=1 tun_id=0x6 reg0=0x1 reg1=0x2 reg2=0x3 reg3=0x4 reg4=0x5 (via action) data_len=64 (unbuffered)
-udp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=80:81:81:81:81:81,dl_dst=82:82:82:82:82:82,nw_src=83.83.83.83,nw_dst=84.84.84.84,nw_tos=0,nw_ecn=0,nw_ttl=0,tp_src=85,tp_dst=86 udp_csum:43a1
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:00:07,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=255,tp_src=80,tp_dst=0 tcp_csum:7744
 dnl
-NXT_PACKET_IN (xid=0x0): table_id=7 cookie=0x9 total_len=64 in_port=1 tun_id=0x6 reg0=0x1 reg1=0x2 reg2=0x3 reg3=0x4 reg4=0x5 (via action) data_len=64 (unbuffered)
-udp,metadata=0,in_port=0,dl_vlan=80,dl_vlan_pcp=0,dl_src=80:81:81:81:81:81,dl_dst=82:82:82:82:82:82,nw_src=83.83.83.83,nw_dst=84.84.84.84,nw_tos=0,nw_ecn=0,nw_ttl=0,tp_src=85,tp_dst=86 udp_csum:43a1
+NXT_PACKET_IN (xid=0x0): cookie=0xd total_len=58 in_port=1 (via action) data_len=58 (unbuffered)
+tcp,metadata=0,in_port=0,vlan_tci=0x0000,dl_src=60:66:66:66:00:07,dl_dst=50:54:00:00:00:07,nw_src=192.168.0.1,nw_dst=192.168.0.2,nw_tos=0,nw_ecn=0,nw_ttl=255,tp_src=80,tp_dst=0 tcp_csum:7744
 ])
 
-AT_CHECK([ovs-appctl time/warp 5000], [0], [ignore])
+AT_CHECK([ovs-appctl time/warp 10000], [0], [ignore])
 AT_CHECK([ovs-ofctl dump-flows br0 | ofctl_strip | sort], [0], [dnl
- cookie=0x1, n_packets=2, n_bytes=120, dl_src=20:22:22:22:22:22 actions=CONTROLLER:65535,resubmit(80,1)
- cookie=0x2, n_packets=3, n_bytes=180, dl_src=30:33:33:33:33:33 actions=mod_vlan_vid:15,CONTROLLER:65535
- cookie=0x3, table=1, n_packets=2, n_bytes=120, in_port=80 actions=load:0x1->NXM_NX_REG0[[]],mod_vlan_vid:80,CONTROLLER:65535,resubmit(81,2)
- cookie=0x4, table=2, n_packets=2, n_bytes=120, in_port=81 actions=load:0x2->NXM_NX_REG1[[]],mod_dl_src:80:81:81:81:81:81,CONTROLLER:65535,resubmit(82,3)
- cookie=0x5, table=3, n_packets=2, n_bytes=120, in_port=82 actions=load:0x3->NXM_NX_REG2[[]],mod_dl_dst:82:82:82:82:82:82,CONTROLLER:65535,resubmit(83,4)
- cookie=0x6, table=4, n_packets=2, n_bytes=120, in_port=83 actions=load:0x4->NXM_NX_REG3[[]],mod_nw_src:83.83.83.83,CONTROLLER:65535,resubmit(84,5)
- cookie=0x7, table=5, n_packets=2, n_bytes=120, in_port=84 actions=load:0x5->NXM_NX_REG4[[]],load:0x6->NXM_NX_TUN_ID[[]],mod_nw_dst:84.84.84.84,CONTROLLER:65535,resubmit(85,6)
- cookie=0x8, table=6, n_packets=2, n_bytes=120, in_port=85 actions=mod_tp_src:85,CONTROLLER:65535,resubmit(86,7)
- cookie=0x9, table=7, n_packets=2, n_bytes=120, in_port=86 actions=mod_tp_dst:86,CONTROLLER:65535,CONTROLLER:65535
- cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:44:41 actions=mod_vlan_vid:99,mod_vlan_pcp:1,CONTROLLER:65535
  cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:44:42 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],CONTROLLER:65535
  cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:44:43 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],CONTROLLER:65535
  cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:44:44 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],CONTROLLER:65535
@@ -664,10 +858,14 @@ AT_CHECK([ovs-ofctl dump-flows br0 | ofctl_strip | sort], [0], [dnl
  cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:44:46 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],set_mpls_ttl(10),CONTROLLER:65535
  cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:44:47 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],dec_mpls_ttl,set_mpls_ttl(10),CONTROLLER:65535
  cookie=0xa, n_packets=3, n_bytes=180, dl_src=40:44:44:44:44:48 actions=push_mpls:0x8847,load:0xa->OXM_OF_MPLS_LABEL[[]],load:0x3->OXM_OF_MPLS_TC[[]],set_mpls_ttl(10),dec_mpls_ttl,CONTROLLER:65535
- cookie=0xb, n_packets=3, n_bytes=180, mpls,dl_src=50:55:55:55:55:55 actions=load:0x3e8->OXM_OF_MPLS_LABEL[[]],CONTROLLER:65535
- cookie=0xc, n_packets=3, n_bytes=180, dl_src=70:77:77:77:77:77 actions=push_mpls:0x8848,load:0x3e8->OXM_OF_MPLS_LABEL[[]],load:0x7->OXM_OF_MPLS_TC[[]],CONTROLLER:65535
- cookie=0xd, n_packets=3, n_bytes=186, dl_src=60:66:66:66:66:66 actions=pop_mpls:0x0800,CONTROLLER:65535
- n_packets=3, n_bytes=180, dl_src=10:11:11:11:11:11 actions=CONTROLLER:65535
+ cookie=0xd, n_packets=3, n_bytes=186, dl_src=60:66:66:66:00:01 actions=pop_mpls:0x0800,dec_ttl(0),CONTROLLER:65535
+ cookie=0xd, n_packets=3, n_bytes=186, dl_src=60:66:66:66:00:02 actions=pop_mpls:0x0800,load:0xa000001->NXM_OF_IP_DST[[]],CONTROLLER:65535
+ cookie=0xd, n_packets=3, n_bytes=186, dl_src=60:66:66:66:00:03 actions=pop_mpls:0x0800,move:NXM_OF_IP_DST[[]]->NXM_OF_IP_SRC[[]],CONTROLLER:65535
+ cookie=0xd, n_packets=3, n_bytes=186, dl_src=60:66:66:66:00:04 actions=pop_mpls:0x0800,push:NXM_OF_IP_DST[[]],pop:NXM_OF_IP_SRC[[]],CONTROLLER:65535
+ cookie=0xd, n_packets=3, n_bytes=186, dl_src=60:66:66:66:00:05 actions=pop_mpls:0x0800,multipath(eth_src,50,modulo_n,256,0,NXM_OF_IP_SRC[[0..7]]),CONTROLLER:65535
+ cookie=0xd, n_packets=3, n_bytes=186, dl_src=60:66:66:66:00:06 actions=pop_mpls:0x0800,bundle_load(eth_src,50,hrw,ofport,NXM_OF_IP_SRC[[0..15]],slaves:1,2),CONTROLLER:65535
+ cookie=0xd, n_packets=3, n_bytes=186, dl_src=60:66:66:66:00:07 actions=pop_mpls:0x0800,learn(table=1,hard_timeout=60,eth_type=0x800,nw_proto=6,NXM_OF_IP_SRC[[]]=NXM_OF_IP_DST[[]]),CONTROLLER:65535
+ table=1, hard_timeout=60, tcp,nw_src=192.168.0.2 actions=drop
 NXST_FLOW reply:
 ])
 
@@ -835,7 +1033,8 @@ AT_CHECK([ovs-ofctl monitor br0 65534 -P nxm --detach --pidfile 2> ofctl_monitor
 for i in 1 2 3; do
     ovs-appctl netdev-dummy/receive p1 'in_port(1),eth(src=40:44:44:44:54:50,dst=50:54:00:00:00:07),eth_type(0x0800),ipv4(src=192.168.0.1,dst=192.168.0.2,proto=6,tos=0,ttl=64,frag=no)'
 done
-OVS_WAIT_UNTIL([ovs-appctl -t ovs-ofctl exit])
+OVS_WAIT_UNTIL([test `wc -l < ofctl_monitor.log` -ge 6])
+ovs-appctl -t ovs-ofctl exit
 
 AT_CHECK([cat ofctl_monitor.log], [0], [dnl
 NXT_PACKET_IN (xid=0x0): cookie=0xa total_len=68 in_port=1 (via action) data_len=68 (unbuffered)
-- 
1.8.3.2
