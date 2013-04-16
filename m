From: Simon Horman <horms@verge.net.au>
Subject: [PATCH 5/5] Add packet recirculation
Date: Tue, 16 Apr 2013 17:14:11 +0900
Message-ID: <1366100051-14772-6-git-send-email-horms@verge.net.au>
References: <1366100051-14772-1-git-send-email-horms@verge.net.au>
Cc: Ravi K <rkerur@gmail.com>, Isaku Yamahata <yamahata@valinux.co.jp>,
	Jesse Gross <jesse@nicira.com>, Ben Pfaff <blp@nicira.com>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:49590 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751820Ab3DPIOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 04:14:20 -0400
In-Reply-To: <1366100051-14772-1-git-send-email-horms@verge.net.au>
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

Signed-off-by: Simon Horman <horms@verge.net.au>

---

This patch depends on "[PATCH v2.24] datapath: Add basic MPLS support to kernel".

TODO:

* Conclude discussion with Jesse Gross on weather or not packets
  are not output by do_execute_actions() if an output action precedes
  a recirculate action.
* Review of fproto/ofproto-dpif.c by Jesse Gross (and Ben Pfaff?)

Change Log:

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
 datapath/actions.c          |    9 +-
 datapath/datapath.c         |  105 ++++---
 datapath/datapath.h         |    2 +-
 include/linux/openvswitch.h |    4 +
 lib/dpif-netdev.c           |   75 +++--
 lib/execute-actions.c       |    7 +-
 lib/execute-actions.h       |    2 +-
 lib/flow.h                  |    4 +
 lib/odp-util.c              |   15 +-
 lib/odp-util.h              |    1 +
 ofproto/ofproto-dpif.c      |  675 ++++++++++++++++++++++++++++++++++++++-----
 11 files changed, 755 insertions(+), 144 deletions(-)

diff --git a/datapath/actions.c b/datapath/actions.c
index e9634fe..7b0f022 100644
--- a/datapath/actions.c
+++ b/datapath/actions.c
@@ -617,6 +617,9 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
 		case OVS_ACTION_ATTR_SAMPLE:
 			err = sample(dp, skb, a);
 			break;
+
+		case OVS_ACTION_ATTR_RECIRCULATE:
+			return 1;
 		}
 
 		if (unlikely(err)) {
@@ -657,7 +660,7 @@ static int loop_suppress(struct datapath *dp, struct sw_flow_actions *actions)
 }
 
 /* Execute a list of actions against 'skb'. */
-int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb)
+struct sk_buff *ovs_execute_actions(struct datapath *dp, struct sk_buff *skb)
 {
 	struct sw_flow_actions *acts = rcu_dereference(OVS_CB(skb)->flow->sf_acts);
 	struct loop_counter *loop;
@@ -676,6 +679,8 @@ int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb)
 	OVS_CB(skb)->tun_key = NULL;
 	error = do_execute_actions(dp, skb, acts->actions,
 					 acts->actions_len, false);
+	if (likely(error <= 0))
+		skb = NULL;
 
 	/* Check whether sub-actions looped too much. */
 	if (unlikely(loop->looping))
@@ -686,5 +691,5 @@ out_loop:
 	if (!--loop->count)
 		loop->looping = false;
 
-	return error;
+	return (error < 0) ? ERR_PTR(error) : skb;
 }
diff --git a/datapath/datapath.c b/datapath/datapath.c
index e8be795..22f8fc9 100644
--- a/datapath/datapath.c
+++ b/datapath/datapath.c
@@ -202,52 +202,65 @@ void ovs_dp_detach_port(struct vport *p)
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
-	int key_len;
+	int limit = MAX_RECIRCULATION_DEPTH;
 
 	stats = this_cpu_ptr(dp->stats_percpu);
 
-	/* Extract flow from 'skb' into 'key'. */
-	error = ovs_flow_extract(skb, p->port_no, &key, &key_len);
-	if (unlikely(error)) {
-		kfree_skb(skb);
-		return;
-	}
+	while (1) {
+		u64 *stats_counter;
+		struct sw_flow *flow;
+		struct sw_flow_key key;
+		int error, key_len;
 
-	/* Look up flow. */
-	flow = ovs_flow_tbl_lookup(rcu_dereference(dp->table), &key, key_len);
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
+		error = ovs_flow_extract(skb, p->port_no, &key, &key_len);
+		if (unlikely(error)) {
+			kfree_skb(skb);
+			return;
+		}
 
-	OVS_CB(skb)->flow = flow;
+		/* Look up flow. */
+		flow = ovs_flow_tbl_lookup(rcu_dereference(dp->table),
+					   &key, key_len);
+		if (unlikely(!flow)) {
+			struct dp_upcall_info upcall;
+
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
+			stats_counter = &stats->n_hit;
+			ovs_flow_used(flow, skb);
+			skb = ovs_execute_actions(dp, skb);
+		}
 
-	stats_counter = &stats->n_hit;
-	ovs_flow_used(OVS_CB(skb)->flow, skb);
-	ovs_execute_actions(dp, skb);
+		/* Update datapath statistics. */
+		u64_stats_update_begin(&stats->sync);
+		(*stats_counter)++;
+		u64_stats_update_end(&stats->sync);
 
-out:
-	/* Update datapath statistics. */
-	u64_stats_update_begin(&stats->sync);
-	(*stats_counter)++;
-	u64_stats_update_end(&stats->sync);
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
@@ -789,6 +802,7 @@ static int validate_and_copy_actions__(const struct nlattr *attr,
 {
 	const struct nlattr *a;
 	int rem, err;
+	bool recirculate = false;
 
 	if (depth >= SAMPLE_ACTION_DEPTH)
 		return -EOVERFLOW;
@@ -818,6 +832,7 @@ static int validate_and_copy_actions__(const struct nlattr *attr,
 			[OVS_ACTION_ATTR_POP_MPLS] = sizeof(__be16),
 			[OVS_ACTION_ATTR_PUSH_VLAN] = sizeof(struct ovs_action_push_vlan),
 			[OVS_ACTION_ATTR_POP_VLAN] = 0,
+			[OVS_ACTION_ATTR_RECIRCULATE] = 0,
 			[OVS_ACTION_ATTR_SET] = (u32)-1,
 			[OVS_ACTION_ATTR_SAMPLE] = (u32)-1
 		};
@@ -825,6 +840,9 @@ static int validate_and_copy_actions__(const struct nlattr *attr,
 		int type = nla_type(a);
 		bool skip_copy;
 
+		if (recirculate)
+			break;
+
 		if (type > OVS_ACTION_ATTR_MAX ||
 		    (action_lens[type] != nla_len(a) &&
 		     action_lens[type] != (u32)-1))
@@ -901,6 +919,10 @@ static int validate_and_copy_actions__(const struct nlattr *attr,
 			skip_copy = true;
 			break;
 
+		case OVS_ACTION_ATTR_RECIRCULATE:
+			recirculate = true;
+			break;
+
 		default:
 			return -EINVAL;
 		}
@@ -1005,12 +1027,23 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
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
 
 	ovs_flow_free(flow);
-	return err;
+	return PTR_ERR(packet);
 
 err_unlock:
 	rcu_read_unlock();
diff --git a/datapath/datapath.h b/datapath/datapath.h
index 7665742..8da5e8a 100644
--- a/datapath/datapath.h
+++ b/datapath/datapath.h
@@ -188,7 +188,7 @@ const char *ovs_dp_name(const struct datapath *dp);
 struct sk_buff *ovs_vport_cmd_build_info(struct vport *, u32 portid, u32 seq,
 					 u8 cmd);
 
-int ovs_execute_actions(struct datapath *dp, struct sk_buff *skb);
+struct sk_buff *ovs_execute_actions(struct datapath *dp, struct sk_buff *skb);
 
 unsigned char *skb_cb_mpls_stack(const struct sk_buff *skb);
 #endif /* datapath.h */
diff --git a/include/linux/openvswitch.h b/include/linux/openvswitch.h
index e890fd8..0fff7cc 100644
--- a/include/linux/openvswitch.h
+++ b/include/linux/openvswitch.h
@@ -516,6 +516,9 @@ struct ovs_action_push_vlan {
  * indicate the new packet contents This could potentially still be
  * %ETH_P_MPLS_* if the resulting MPLS label stack is not empty.  If there
  * is no MPLS label stack, as determined by ethertype, no action is taken.
+ * @OVS_ACTION_ATTR_RECIRCULATE: Restart processing of packet.
+ * The packet must have been modified by a previous action in such a way
+ * that it does not match its original flow again.
  *
  * Only a single header can be set with a single %OVS_ACTION_ATTR_SET.  Not all
  * fields within a header are modifiable, e.g. the IPv4 protocol and fragment
@@ -532,6 +535,7 @@ enum ovs_action_attr {
 	OVS_ACTION_ATTR_SAMPLE,       /* Nested OVS_SAMPLE_ATTR_*. */
 	OVS_ACTION_ATTR_PUSH_MPLS,    /* struct ovs_action_push_mpls. */
 	OVS_ACTION_ATTR_POP_MPLS,     /* __be16 ethertype. */
+	OVS_ACTION_ATTR_RECIRCULATE,  /* No argument */
 	__OVS_ACTION_ATTR_MAX
 };
 
diff --git a/lib/dpif-netdev.c b/lib/dpif-netdev.c
index 0acecdb..9f6b93c 100644
--- a/lib/dpif-netdev.c
+++ b/lib/dpif-netdev.c
@@ -153,13 +153,16 @@ static int dpif_netdev_open(const struct dpif_class *, const char *name,
 static int dp_netdev_output_userspace(struct dp_netdev *, const struct ofpbuf *,
                                     int queue_no, const struct flow *,
                                     const struct nlattr *userdata);
-static void dp_netdev_execute_actions(struct dp_netdev *,
+static bool dp_netdev_execute_actions(struct dp_netdev *,
                                       struct ofpbuf *, struct flow *,
                                       const struct nlattr *actions,
                                       size_t actions_len,
                                       uint32_t *skb_priority,
                                       uint32_t *skb_mark,
                                       struct flow_tnl *tun_key);
+static void dp_netdev_port_input(struct dp_netdev *dp,
+                                 struct dp_netdev_port *port,
+                                 struct ofpbuf *packet);
 
 static struct dpif_netdev *
 dpif_netdev_cast(const struct dpif *dpif)
@@ -944,14 +947,26 @@ dpif_netdev_execute(struct dpif *dpif, const struct dpif_execute *execute)
     error = dpif_netdev_flow_from_nlattrs(execute->key, execute->key_len,
                                           &key);
     if (!error) {
+        bool recirculate;
         uint32_t skb_priority = 0;
         uint32_t skb_mark = 0;
         struct flow_tnl tun_key;
 
         memset(&tun_key, 0, sizeof tun_key);
-        dp_netdev_execute_actions(dp, &copy, &key,
-                                  execute->actions, execute->actions_len,
-                                  &skb_priority, &skb_mark, &tun_key);
+        recirculate = dp_netdev_execute_actions(dp, &copy, &key,
+                                                execute->actions,
+                                                execute->actions_len,
+                                                &skb_priority, &skb_mark,
+                                                &tun_key);
+        if (recirculate) {
+            struct dp_netdev_port *port;
+            port = (key.in_port < MAX_PORTS) ? dp->ports[key.in_port] : NULL;
+            if (port) {
+                dp_netdev_port_input(dp, port, &copy);
+                return 0;
+            }
+            error = ENOENT;
+        }
     }
 
     ofpbuf_uninit(&copy);
@@ -1038,28 +1053,36 @@ static void
 dp_netdev_port_input(struct dp_netdev *dp, struct dp_netdev_port *port,
                      struct ofpbuf *packet)
 {
-    struct dp_netdev_flow *flow;
-    struct flow key;
+    bool recirculate;
     uint32_t skb_priority = 0;
     uint32_t skb_mark = 0;
     struct flow_tnl tun_key;
+    int limit = MAX_RECIRCULATION_DEPTH;
 
-    if (packet->size < ETH_HEADER_LEN) {
-        return;
-    }
-    flow_extract(packet, 0, 0, NULL, port->port_no, &key);
-    flow = dp_netdev_lookup_flow(dp, &key);
-    if (flow) {
-        memset(&tun_key, 0, sizeof tun_key);
-        dp_netdev_flow_used(flow, packet);
-        dp_netdev_execute_actions(dp, packet, &key,
-                                  flow->actions, flow->actions_len,
-                                  &skb_priority, &skb_mark, &tun_key);
-        dp->n_hit++;
-    } else {
-        dp->n_missed++;
-        dp_netdev_output_userspace(dp, packet, DPIF_UC_MISS, &key, NULL);
-    }
+    do {
+        struct dp_netdev_flow *flow;
+        struct flow key;
+
+        if (packet->size < ETH_HEADER_LEN) {
+            return;
+        }
+        flow_extract(packet, 0, skb_mark, NULL, port->port_no, &key);
+        flow = dp_netdev_lookup_flow(dp, &key);
+        if (flow) {
+            dp_netdev_flow_used(flow, packet);
+            memset(&tun_key, 0, sizeof tun_key);
+            recirculate = dp_netdev_execute_actions(dp, packet, &key,
+                                                    flow->actions,
+                                                    flow->actions_len,
+                                                    &skb_priority, &skb_mark,
+                                                    &tun_key);
+            dp->n_hit++;
+        } else {
+            dp->n_missed++;
+            dp_netdev_output_userspace(dp, packet, DPIF_UC_MISS, &key, NULL);
+            recirculate = false;
+        }
+    } while (recirculate && --limit);
 }
 
 static void
@@ -1171,16 +1194,16 @@ dp_netdev_action_userspace(void *dp, struct ofpbuf *packet, struct flow *key,
     dp_netdev_output_userspace(dp, packet, DPIF_UC_ACTION, key, userdata);
 }
 
-static void
+static bool
 dp_netdev_execute_actions(struct dp_netdev *dp,
                           struct ofpbuf *packet, struct flow *key,
                           const struct nlattr *actions,
                           size_t actions_len, uint32_t *skb_priority,
                           uint32_t *skb_mark, struct flow_tnl *tun_key)
 {
-    execute_actions(dp, packet, key, actions, actions_len, skb_priority,
-                    skb_mark, tun_key, dp_netdev_output_port,
-                    dp_netdev_action_userspace);
+    return execute_actions(dp, packet, key, actions, actions_len, skb_priority,
+                           skb_mark, tun_key, dp_netdev_output_port,
+                           dp_netdev_action_userspace);
 }
 
 const struct dpif_class dpif_netdev_class = {
diff --git a/lib/execute-actions.c b/lib/execute-actions.c
index ca9c3ca..01df415 100644
--- a/lib/execute-actions.c
+++ b/lib/execute-actions.c
@@ -155,7 +155,7 @@ execute_sample(void *dp, struct ofpbuf *packet, struct flow *key,
                     tun_key, output, userspace);
 }
 
-void
+bool
 execute_actions(void *dp, struct ofpbuf *packet, struct flow *key,
                 const struct nlattr *actions, size_t actions_len,
                 uint32_t *skb_priority, uint32_t *skb_mark,
@@ -212,9 +212,14 @@ execute_actions(void *dp, struct ofpbuf *packet, struct flow *key,
                            output, userspace);
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
diff --git a/lib/execute-actions.h b/lib/execute-actions.h
index 2c36f27..0480ee0 100644
--- a/lib/execute-actions.h
+++ b/lib/execute-actions.h
@@ -22,7 +22,7 @@
 #include "netlink-protocol.h"
 #include "ofpbuf.h"
 
-void
+bool
 execute_actions(void *dp, struct ofpbuf *packet, struct flow *key,
                 const struct nlattr *actions, size_t actions_len,
                 uint32_t *skb_priority, uint32_t *skb_mark,
diff --git a/lib/flow.h b/lib/flow.h
index 6e169d6..1e3e00d 100644
--- a/lib/flow.h
+++ b/lib/flow.h
@@ -296,4 +296,8 @@ uint32_t minimask_hash(const struct minimask *, uint32_t basis);
 bool minimask_has_extra(const struct minimask *, const struct minimask *);
 bool minimask_is_catchall(const struct minimask *);
 
+#define MAX_RECIRCULATION_DEPTH 4   /* Completely arbitrary value to
+                                     * guard against infinite loops */
+BUILD_ASSERT_DECL(MAX_RECIRCULATION_DEPTH > 0);
+
 #endif /* flow.h */
diff --git a/lib/odp-util.c b/lib/odp-util.c
index acecb78..789f76c 100644
--- a/lib/odp-util.c
+++ b/lib/odp-util.c
@@ -75,6 +75,7 @@ odp_action_len(uint16_t type)
     case OVS_ACTION_ATTR_POP_VLAN: return 0;
     case OVS_ACTION_ATTR_PUSH_MPLS: return sizeof(struct ovs_action_push_mpls);
     case OVS_ACTION_ATTR_POP_MPLS: return sizeof(ovs_be16);
+    case OVS_ACTION_ATTR_RECIRCULATE: return 0;
     case OVS_ACTION_ATTR_SET: return -2;
     case OVS_ACTION_ATTR_SAMPLE: return -2;
 
@@ -376,6 +377,10 @@ format_odp_action(struct ds *ds, const struct nlattr *a)
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
@@ -2172,6 +2177,12 @@ commit_odp_tunnel_action(const struct flow *flow, struct flow *base,
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
                              struct ofpbuf *odp_actions)
@@ -2385,14 +2396,14 @@ commit_set_skb_mark_action(const struct flow *flow, struct flow *base,
         return;
     }
     base->skb_mark = flow->skb_mark;
-
     odp_put_skb_mark_action(base->skb_mark, odp_actions);
 }
 /* If any of the flow key data that ODP actions can modify are different in
  * 'base' and 'flow', appends ODP actions to 'odp_actions' that change the flow
  * key from 'base' into 'flow', and then changes 'base' the same way.  Does not
  * commit set_tunnel actions.  Users should call commit_odp_tunnel_action()
- * in addition to this function if needed. */
+ * and commit_odp_recirculate_action() in addition to those functions are
+ * needed. */
 void
 commit_odp_actions(const struct flow *flow, struct flow *base,
                    struct ofpbuf *odp_actions)
diff --git a/lib/odp-util.h b/lib/odp-util.h
index df38ec0..c718000 100644
--- a/lib/odp-util.h
+++ b/lib/odp-util.h
@@ -118,6 +118,7 @@ const char *odp_key_fitness_to_string(enum odp_key_fitness);
 
 void commit_odp_tunnel_action(const struct flow *, struct flow *base,
                               struct ofpbuf *odp_actions);
+void commit_odp_recirculate_action(struct ofpbuf *odp_actions);
 void commit_odp_actions(const struct flow *, struct flow *base,
                         struct ofpbuf *odp_actions);
 
diff --git a/ofproto/ofproto-dpif.c b/ofproto/ofproto-dpif.c
index 47830c1..0ead27d 100644
--- a/ofproto/ofproto-dpif.c
+++ b/ofproto/ofproto-dpif.c
@@ -28,6 +28,7 @@
 #include "cfm.h"
 #include "dpif.h"
 #include "dynamic-string.h"
+#include "execute-actions.h"
 #include "fail-open.h"
 #include "hmapx.h"
 #include "lacp.h"
@@ -119,7 +120,8 @@ static struct rule_dpif *rule_dpif_miss_rule(struct ofproto_dpif *ofproto,
 
 static void rule_credit_stats(struct rule_dpif *,
                               const struct dpif_flow_stats *);
-static void flow_push_stats(struct facet *, const struct dpif_flow_stats *);
+static void flow_push_stats(struct facet *, const struct dpif_flow_stats *,
+                            const struct ofpact *, size_t ofpacts_len);
 static tag_type rule_calculate_tag(const struct flow *,
                                    const struct minimask *, uint32_t basis);
 static void rule_invalidate(const struct rule_dpif *);
@@ -276,6 +278,17 @@ struct action_xlate_ctx {
     uint16_t nf_output_iface;   /* Output interface index for NetFlow. */
     mirror_mask_t mirrors;      /* Bitmap of associated mirrors. */
 
+    size_t ofpacts_len;         /* The number of bytes of the ofpacts
+                                 * argument to xlate_actions() processed
+                                 * by it. This is used to calculate an
+                                 * offset into ofpacts for calls to
+                                 * xlate_actions on recirculated packets */
+
+    uint32_t recirculation_id;  /* skb_mark to use to identify
+                                 * recirculation. */
+    bool recirculated;          /* True if the context does not add a
+                                 * recirculate action. False otherwise. */
+
 /* xlate_actions() initializes and uses these members, but the client has no
  * reason to look at them. */
 
@@ -312,7 +325,8 @@ static void action_xlate_ctx_init(struct action_xlate_ctx *,
                                   struct ofproto_dpif *, const struct flow *,
                                   const struct initial_vals *initial_vals,
                                   struct rule_dpif *,
-                                  uint8_t tcp_flags, const struct ofpbuf *);
+                                  uint8_t tcp_flags, const struct ofpbuf *,
+                                  uint32_t recirculation_id);
 static void xlate_actions(struct action_xlate_ctx *,
                           const struct ofpact *ofpacts, size_t ofpacts_len,
                           struct ofpbuf *odp_actions);
@@ -494,17 +508,46 @@ struct facet {
     struct subfacet one_subfacet;
 
     long long int learn_rl;      /* Rate limiter for facet_learn(). */
+
+    const struct ofpact *ofpacts;   /* ofpacts for this facet.
+                                     * Will differ from rule->up.ofpacts
+                                     * if facet is for a recirculated packet. */
+    size_t ofpacts_len;             /* ofpacts_len for this facet
+                                     * Will differ from * rule->up.ofpacts_len
+                                     * if facet is for a recirculated packet. */
+
+    uint32_t recirculation_id;       /* Recirculation id.
+                                      * Non-sero for a facet
+                                      * that recirculates packets;
+                                      * used as the value of flow.skb_mark
+                                      * in the facet of recirculated packets.
+                                      * Zero otherwise. */
+    struct hmap_node recirculation_id_hmap_node;
+                                    /* In owning ofproto's 'recirculation_id'
+                                     * hmap. */
+    const struct ofpact *recirculation_ofpacts;
+                                    /* ofpacts for facets of packets
+                                     * recirculated by this facet */
+    size_t recirculation_ofpacts_len;
+                                    /* ofpacts_len for facets of packets
+                                     * recirculated by this facet */
+
+    bool recirculated;              /* Facet of a recirculated packet? */
 };
 
-static struct facet *facet_create(struct rule_dpif *,
-                                  const struct flow *, uint32_t hash);
+static struct facet *facet_create(struct rule_dpif *, const struct flow *,
+                                  const struct ofpact *, size_t ofpacts_len,
+                                  bool recirculated, uint32_t hash);
 static void facet_remove(struct facet *);
 static void facet_free(struct facet *);
 
+static struct facet *facet_find_by_id(struct ofproto_dpif *, uint32_t id);
 static struct facet *facet_find(struct ofproto_dpif *,
                                 const struct flow *, uint32_t hash);
 static struct facet *facet_lookup_valid(struct ofproto_dpif *,
                                         const struct flow *, uint32_t hash);
+static struct facet *facet_lookup_valid_by_id(struct ofproto_dpif *,
+                                              uint32_t id);
 static void facet_revalidate(struct facet *);
 static bool facet_check_consistency(struct facet *);
 
@@ -703,6 +746,7 @@ struct ofproto_dpif {
 
     /* Facets. */
     struct hmap facets;
+    struct hmap recirculation_ids;
     struct hmap subfacets;
     struct governor *governor;
     long long int consistency_rl;
@@ -1358,6 +1402,7 @@ construct(struct ofproto *ofproto_)
     ofproto->has_bonded_bundles = false;
 
     hmap_init(&ofproto->facets);
+    hmap_init(&ofproto->recirculation_ids);
     hmap_init(&ofproto->subfacets);
     ofproto->governor = NULL;
     ofproto->consistency_rl = LLONG_MIN;
@@ -3408,6 +3453,58 @@ port_is_lacp_current(const struct ofport *ofport_)
             : -1);
 }
 
+/* Recirculation Id */
+#define RECIRCULATION_ID_NONE  0
+#define RECIRCULATION_ID_DUMMY 2
+#define RECIRCULATION_ID_MIN   RECIRCULATION_ID_DUMMY
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
+static uint32_t peek_recirculation_id(struct ofproto_dpif *ofproto)
+{
+    static struct vlog_rate_limit rl = VLOG_RATE_LIMIT_INIT(1, 15);
+
+    int loop = RECIRCULATION_ID_MAX_LOOP;
+
+    if (validated_recirculation_id == recirculation_id) {
+        return recirculation_id;
+    }
+
+    while (loop--) {
+        if (recirculation_id < RECIRCULATION_ID_MIN)
+            recirculation_id = RECIRCULATION_ID_MIN;
+        /* Skip IPSEC_MARK bit it is reserved */
+        if (recirculation_id & IPSEC_MARK) {
+            recirculation_id++;
+            ovs_assert(!(recirculation_id & IPSEC_MARK));
+        }
+        if (!facet_find_by_id(ofproto, recirculation_id)) {
+            validated_recirculation_id = recirculation_id;
+            return recirculation_id;
+        }
+        recirculation_id++;
+    }
+
+    VLOG_WARN_RL(&rl, "Failed to allocate recirulation id after %d attempts\n",
+                 RECIRCULATION_ID_MAX_LOOP);
+    return RECIRCULATION_ID_NONE;
+}
+
+static uint32_t get_recirculation_id(void)
+{
+    ovs_assert(recirculation_id == validated_recirculation_id);
+    return recirculation_id++;
+}
+
 /* Upcall handling. */
 
 /* Flow miss batching.
@@ -3504,6 +3601,17 @@ flow_miss_find(struct hmap *todo, const struct ofproto_dpif *ofproto,
     return NULL;
 }
 
+static void
+execute_actions_for_recircualtion(struct ofpbuf *packet,
+                                  const struct nlattr *actions,
+                                  size_t actions_len, uint32_t *skb_priority,
+                                  uint32_t *skb_mark, struct flow_tnl *tun_key)
+{
+    /* Assert that there was a recirculation action */
+    ovs_assert(execute_actions(NULL, packet, NULL, actions, actions_len,
+                               skb_priority, skb_mark, tun_key, NULL, NULL));
+}
+
 /* Partially Initializes 'op' as an "execute" operation for 'miss' and
  * 'packet'.  The caller must initialize op->actions and op->actions_len.  If
  * 'miss' is associated with a subfacet the caller must also initialize the
@@ -3565,6 +3673,14 @@ static bool
 flow_miss_should_make_facet(struct ofproto_dpif *ofproto,
                             struct flow_miss *miss, uint32_t hash)
 {
+    /* If the packet is MPLS then recirculation may be used and
+     * this will not be possible with facets if there are no recirculation
+     * ids available */
+    if (eth_type_mpls(miss->flow.dl_type) &&
+        peek_recirculation_id(ofproto) == RECIRCULATION_ID_NONE) {
+        return false;
+    }
+
     if (!ofproto->governor) {
         size_t n_subfacets;
 
@@ -3580,18 +3696,68 @@ flow_miss_should_make_facet(struct ofproto_dpif *ofproto,
                                         list_size(&miss->packets));
 }
 
+static const struct flow *
+xlate_with_recirculate(struct ofproto_dpif *ofproto, struct rule_dpif *rule,
+                       const struct flow *flow, struct flow *flow_storage,
+                       const struct initial_vals *initial_vals,
+                       const struct ofpact *ofpacts, size_t ofpacts_len,
+                       struct ofpbuf *odp_actions,
+                       struct dpif_flow_stats *stats, struct ofpbuf *packet)
+{
+    struct initial_vals initial_vals_ = *initial_vals;
+
+    while (1) {
+        struct action_xlate_ctx ctx;
+        uint32_t skb_priority;
+        uint32_t skb_mark;
+        struct flow_tnl tun_key;
+
+        ofpbuf_clear(odp_actions);
+        action_xlate_ctx_init(&ctx, ofproto, flow, &initial_vals_,
+                              rule, stats->tcp_flags, packet,
+                              RECIRCULATION_ID_DUMMY);
+        ctx.resubmit_stats = stats;
+        xlate_actions(&ctx, ofpacts, ofpacts_len, odp_actions);
+
+        if (!ctx.recirculated) {
+            break;
+        }
+
+        /* Update the packet */
+        skb_priority = flow->skb_priority;
+        skb_mark = flow->skb_mark;
+        tun_key = flow->tunnel;
+        execute_actions_for_recircualtion(packet, odp_actions->data,
+                                          odp_actions->size,
+                                          &skb_priority, &skb_mark, &tun_key);
+        ofpbuf_clear(odp_actions);
+
+        /* Replace the flow */
+        flow_extract(packet, skb_priority, skb_mark,
+                     NULL, flow->in_port, flow_storage);
+        flow = flow_storage;
+        initial_vals_.vlan_tci = flow->vlan_tci;
+        initial_vals_.tunnel_ip_tos = flow->tunnel.ip_tos;
+
+        ofpacts = ofpact_end(ofpacts, ctx.ofpacts_len);
+        ofpacts_len -= ctx.ofpacts_len;
+    }
+
+    return flow;
+}
+
 /* Handles 'miss', which matches 'rule', without creating a facet or subfacet
  * or creating any datapath flow.  May add an "execute" operation to 'ops' and
  * increment '*n_ops'. */
 static void
-handle_flow_miss_without_facet(struct flow_miss *miss,
-                               struct rule_dpif *rule,
+handle_flow_miss_without_facet(struct flow_miss *miss, struct rule_dpif *rule,
+                               const struct ofpact *ofpacts, size_t ofpacts_len,
                                struct flow_miss_op *ops, size_t *n_ops)
 {
     struct ofproto_dpif *ofproto = ofproto_dpif_cast(rule->up.ofproto);
     long long int now = time_msec();
-    struct action_xlate_ctx ctx;
     struct ofpbuf *packet;
+    struct flow flow_storage;
 
     LIST_FOR_EACH (packet, list_node, &miss->packets) {
         struct flow_miss_op *op = &ops[*n_ops];
@@ -3605,11 +3771,9 @@ handle_flow_miss_without_facet(struct flow_miss *miss,
         dpif_flow_stats_extract(&miss->flow, packet, now, &stats);
         rule_credit_stats(rule, &stats);
 
-        action_xlate_ctx_init(&ctx, ofproto, &miss->flow,
-                              &miss->initial_vals, rule, 0, packet);
-        ctx.resubmit_stats = &stats;
-        xlate_actions(&ctx, rule->up.ofpacts, rule->up.ofpacts_len,
-                      &odp_actions);
+        xlate_with_recirculate(ofproto, rule, &miss->flow, &flow_storage,
+                               &miss->initial_vals, ofpacts, ofpacts_len,
+                               &odp_actions, &stats, packet);
 
         if (odp_actions.size) {
             struct dpif_execute *execute = &op->dpif_op.u.execute;
@@ -3659,8 +3823,16 @@ handle_flow_miss_with_facet(struct flow_miss *miss, struct facet *facet,
             subfacet_make_actions(subfacet, packet, &odp_actions);
         }
 
-        dpif_flow_stats_extract(&facet->flow, packet, now, &stats);
-        subfacet_update_stats(subfacet, &stats);
+        if (!facet->recirculated) {
+           /* Do not update stats for facets with recirculation_id set.
+            * This avoids duplicate counting packets that have more than one
+            * facet due to recirculation - only hits for the bottom-most
+            * facet are counted here: the only facet in the case where
+            * there is no recirculation.
+            */
+            dpif_flow_stats_extract(&facet->flow, packet, now, &stats);
+            subfacet_update_stats(subfacet, &stats);
+        }
 
         if (subfacet->actions_len) {
             struct dpif_execute *execute = &op->dpif_op.u.execute;
@@ -3723,14 +3895,30 @@ handle_flow_miss(struct flow_miss *miss, struct flow_miss_op *ops,
 
     facet = facet_lookup_valid(ofproto, &miss->flow, hash);
     if (!facet) {
-        struct rule_dpif *rule = rule_dpif_lookup(ofproto, &miss->flow);
+        struct rule_dpif *rule;
+        const struct ofpact *ofpacts;
+        size_t ofpacts_len;
+        struct facet *parent_facet;
+
+        parent_facet = facet_lookup_valid_by_id(ofproto, miss->flow.skb_mark);
+        if (parent_facet) {
+            rule = parent_facet->rule;
+            ofpacts = parent_facet->recirculation_ofpacts;
+            ofpacts_len = parent_facet->recirculation_ofpacts_len;
+        } else {
+            rule = rule_dpif_lookup(ofproto, &miss->flow);
+            ofpacts = rule->up.ofpacts;
+            ofpacts_len = rule->up.ofpacts_len;
+        }
 
         if (!flow_miss_should_make_facet(ofproto, miss, hash)) {
-            handle_flow_miss_without_facet(miss, rule, ops, n_ops);
+            handle_flow_miss_without_facet(miss, rule, ofpacts,
+                                           ofpacts_len, ops, n_ops);
             return;
         }
 
-        facet = facet_create(rule, &miss->flow, hash);
+        facet = facet_create(rule, &miss->flow, ofpacts, ofpacts_len,
+                             parent_facet != NULL, hash);
         now = facet->used;
     } else {
         now = time_msec();
@@ -4197,6 +4385,15 @@ update_subfacet_stats(struct subfacet *subfacet,
 {
     struct facet *facet = subfacet->facet;
 
+    if (facet->recirculated) {
+        /* Do not update stats for facets with recirculation_id set.
+         * This avoids duplicate counting packets that have more than
+         * one facet due to recirculation - only hits for
+         * the top-most facet are counted here: the only facet
+         * in the case where there is no recirculation. */
+        return;
+    }
+
     if (stats->n_packets >= subfacet->dp_packet_count) {
         uint64_t extra = stats->n_packets - subfacet->dp_packet_count;
         facet->packet_count += extra;
@@ -4481,6 +4678,45 @@ rule_expire(struct rule_dpif *rule)
     ofproto_rule_expire(&rule->up, reason);
 }
 
+/* Facet Recirculation Helper. */
+
+/* Removes 'facet' from the recirculation_ids hmap of its ofproto */
+static void
+facet_recirculation_id_remove(struct facet *facet)
+{
+    struct ofproto_dpif *ofproto = ofproto_dpif_cast(facet->rule->up.ofproto);
+
+    if (hmap_node_is_null(&facet->recirculation_id_hmap_node)) {
+        return;
+    }
+
+    hmap_remove(&ofproto->recirculation_ids,
+                &facet->recirculation_id_hmap_node);
+}
+
+/* Set paramaters for 'facet' which has a recirculate action.
+ * 'id' will be 'facet''s recirculation_id.
+ * 'ofpacts_offset will be used to calculate 'facet''s
+ * recirculation_ofpacts and recirculation_ofpacts_len.
+ *
+ * The ofpacts and opacts_len of the facet must have already been set. */
+static void
+facet_set_recirculation(struct facet *facet, uint32_t id,
+                        size_t ofpacts_offset)
+{
+    struct ofproto_dpif *ofproto = ofproto_dpif_cast(facet->rule->up.ofproto);
+
+    facet->recirculation_ofpacts = ofpact_end(facet->ofpacts, ofpacts_offset);
+    facet->recirculation_ofpacts_len = facet->ofpacts_len - ofpacts_offset;
+
+    if (facet->recirculation_id != id) {
+        facet->recirculation_id = id;
+        hmap_insert(&ofproto->recirculation_ids,
+                    &facet->recirculation_id_hmap_node,
+                    recirculation_id_hash(facet->recirculation_id));
+    }
+}
+
 /* Facets. */
 
 /* Creates and returns a new facet owned by 'rule', given a 'flow'.
@@ -4494,7 +4730,9 @@ rule_expire(struct rule_dpif *rule)
  * The facet will initially have no subfacets.  The caller should create (at
  * least) one subfacet with subfacet_create(). */
 static struct facet *
-facet_create(struct rule_dpif *rule, const struct flow *flow, uint32_t hash)
+facet_create(struct rule_dpif *rule, const struct flow *flow,
+             const struct ofpact *ofpacts, size_t ofpacts_len,
+             bool recirculated, uint32_t hash)
 {
     struct ofproto_dpif *ofproto = ofproto_dpif_cast(rule->up.ofproto);
     struct facet *facet;
@@ -4502,9 +4740,13 @@ facet_create(struct rule_dpif *rule, const struct flow *flow, uint32_t hash)
     facet = xzalloc(sizeof *facet);
     facet->used = time_msec();
     hmap_insert(&ofproto->facets, &facet->hmap_node, hash);
+    hmap_node_nullify(&facet->recirculation_id_hmap_node);
     list_push_back(&rule->facets, &facet->list_node);
     facet->rule = rule;
     facet->flow = *flow;
+    facet->ofpacts = ofpacts;
+    facet->ofpacts_len = ofpacts_len;
+    facet->recirculated = recirculated;
     list_init(&facet->subfacets);
     netflow_flow_init(&facet->nf_flow);
     netflow_flow_update_time(ofproto->netflow, &facet->nf_flow, facet->used);
@@ -4574,6 +4816,7 @@ facet_remove(struct facet *facet)
     }
     hmap_remove(&ofproto->facets, &facet->hmap_node);
     list_remove(&facet->list_node);
+    facet_recirculation_id_remove(facet);
     facet_free(facet);
 }
 
@@ -4603,10 +4846,10 @@ facet_learn(struct facet *facet)
 
     action_xlate_ctx_init(&ctx, ofproto, &facet->flow,
                           &subfacet->initial_vals,
-                          facet->rule, facet->tcp_flags, NULL);
+                          facet->rule, facet->tcp_flags, NULL,
+                          facet->recirculation_id);
     ctx.may_learn = true;
-    xlate_actions_for_side_effects(&ctx, facet->rule->up.ofpacts,
-                                   facet->rule->up.ofpacts_len);
+    xlate_actions_for_side_effects(&ctx, facet->ofpacts, facet->ofpacts_len);
 }
 
 static void
@@ -4689,6 +4932,15 @@ facet_flush_stats(struct facet *facet)
     struct ofproto_dpif *ofproto = ofproto_dpif_cast(facet->rule->up.ofproto);
     struct subfacet *subfacet;
 
+    if (facet->recirculated) {
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
@@ -4742,6 +4994,33 @@ facet_find(struct ofproto_dpif *ofproto,
     return NULL;
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
+    uint32_t hash = recirculation_id_hash(id);
+    struct facet *facet;
+
+    /* some values are never used */
+    if (id == RECIRCULATION_ID_NONE || (id & IPSEC_MARK)) {
+        return NULL;
+    }
+
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
 /* Searches 'ofproto''s table of facets for one exactly equal to 'flow'.
  * Returns it if found, otherwise a null pointer.
  *
@@ -4768,6 +5047,29 @@ facet_lookup_valid(struct ofproto_dpif *ofproto, const struct flow *flow,
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
+                                  facet->tags))) {
+        facet_revalidate(facet);
+
+        /* facet_revalidate() may have destroyed 'facet'. */
+        facet = facet_find_by_id(ofproto, id);
+    }
+
+    return facet;
+}
+
 /* Return a subfacet from 'facet'.  A facet consists of one or more
  * subfacets, and this function returns one of them. */
 static struct subfacet *facet_get_subfacet(struct facet *facet)
@@ -4815,7 +5117,9 @@ subfacet_should_install(struct subfacet *subfacet, enum slow_path_reason slow,
 }
 
 static bool
-facet_check_consistency(struct facet *facet)
+facet_check_actions_consistency(struct facet *facet, struct rule_dpif *rule,
+                                const struct ofpact *ofpacts,
+                                size_t *ofpacts_len)
 {
     static struct vlog_rate_limit rl = VLOG_RATE_LIMIT_INIT(1, 15);
 
@@ -4824,33 +5128,10 @@ facet_check_consistency(struct facet *facet)
     uint64_t odp_actions_stub[1024 / 8];
     struct ofpbuf odp_actions;
 
-    struct rule_dpif *rule;
     struct subfacet *subfacet;
     bool may_log = false;
-    bool ok;
-
-    /* Check the rule for consistency. */
-    rule = rule_dpif_lookup(ofproto, &facet->flow);
-    ok = rule == facet->rule;
-    if (!ok) {
-        may_log = !VLOG_DROP_WARN(&rl);
-        if (may_log) {
-            struct ds s;
-
-            ds_init(&s);
-            flow_format(&s, &facet->flow);
-            ds_put_format(&s, ": facet associated with wrong rule (was "
-                          "table=%"PRIu8",", facet->rule->up.table_id);
-            cls_rule_format(&facet->rule->up.cr, &s);
-            ds_put_format(&s, ") (should have been table=%"PRIu8",",
-                          rule->up.table_id);
-            cls_rule_format(&rule->up.cr, &s);
-            ds_put_char(&s, ')');
-
-            VLOG_WARN("%s", ds_cstr(&s));
-            ds_destroy(&s);
-        }
-    }
+    bool ok = true;
+    size_t consumed = 0;
 
     /* Check the datapath actions for consistency. */
     ofpbuf_use_stub(&odp_actions, odp_actions_stub, sizeof odp_actions_stub);
@@ -4860,9 +5141,10 @@ facet_check_consistency(struct facet *facet)
         struct ds s;
 
         action_xlate_ctx_init(&ctx, ofproto, &facet->flow,
-                              &subfacet->initial_vals, rule, 0, NULL);
-        xlate_actions(&ctx, rule->up.ofpacts, rule->up.ofpacts_len,
-                      &odp_actions);
+                              &subfacet->initial_vals, rule, 0, NULL,
+                              facet->recirculation_id);
+        xlate_actions(&ctx, ofpacts, *ofpacts_len, &odp_actions);
+        consumed = ctx.ofpacts_len;
 
         if (subfacet->path == SF_NOT_INSTALLED) {
             /* This only happens if the datapath reported an error when we
@@ -4921,6 +5203,116 @@ facet_check_consistency(struct facet *facet)
     }
     ofpbuf_uninit(&odp_actions);
 
+    *ofpacts_len -= consumed;
+
+    return ok;
+}
+
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
+get_facet_chain(struct facet *facet, struct facet **chain, size_t len,
+                bool strict)
+{
+    static struct vlog_rate_limit rl = VLOG_RATE_LIMIT_INIT(1, 15);
+    struct ofproto_dpif *ofproto = ofproto_dpif_cast(facet->rule->up.ofproto);
+    size_t top = 0;
+
+    ovs_assert(len > 0);
+
+    chain[top] = facet;
+    while (chain[top]->recirculated && top < len) {
+        chain[top + 1] = facet_find_by_id(ofproto, chain[top]->flow.skb_mark);
+        if (!chain[top + 1])  {
+            if (strict) {
+                facet_warn_rl(&rl, facet, ": parent facet of facet for "
+                              "recirculated packets could not be found");
+            }
+            return top + 1;
+        }
+        top++;
+    }
+
+    if (chain[top]->recirculated ) {
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
+    static struct vlog_rate_limit rl = VLOG_RATE_LIMIT_INIT(1, 15);
+
+    struct ofproto_dpif *ofproto = ofproto_dpif_cast(facet->rule->up.ofproto);
+
+    const struct ofpact *ofpacts;
+    size_t ofpacts_len;
+
+    struct rule_dpif *rule;
+    struct facet *chain[MAX_RECIRCULATION_DEPTH + 1];
+    size_t chain_len;
+    bool may_log = false;
+    bool ok;
+
+    chain_len = get_facet_chain(facet, chain, ARRAY_SIZE(chain), true);
+    rule = rule_dpif_lookup(ofproto, &chain[chain_len - 1]->flow);
+    ok = rule == chain[chain_len - 1]->rule;
+    if (!ok) {
+        may_log = !VLOG_DROP_WARN(&rl);
+        if (may_log) {
+            struct ds s;
+
+            ds_init(&s);
+            flow_format(&s, &chain[chain_len - 1]->flow);
+            ds_put_format(&s, ": facet associated with wrong rule (was "
+                          "table=%"PRIu8",",
+                          chain[chain_len - 1]->rule->up.table_id);
+            cls_rule_format(&chain[chain_len - 1]->rule->up.cr, &s);
+            ds_put_format(&s, ") (should have been table=%"PRIu8",",
+                          rule->up.table_id);
+            cls_rule_format(&rule->up.cr, &s);
+            ds_put_char(&s, ')');
+
+            VLOG_WARN("%s", ds_cstr(&s));
+            ds_destroy(&s);
+        }
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
+            break;
+        }
+        ofpacts = ofpact_end(ofpacts, ofpacts_len - new_ofpacts_len);
+        ofpacts_len = new_ofpacts_len;
+    }
+
     return ok;
 }
 
@@ -4933,7 +5325,12 @@ facet_check_consistency(struct facet *facet)
  *     where it is and recompiles its actions anyway.
  *
  *   - If any of 'facet''s subfacets correspond to a new flow according to
- *     ofproto_receive(), 'facet' is removed. */
+ *     ofproto_receive(), 'facet' is removed.
+ *
+ *   - If 'facet' is for a recirculated packet but the new rule does
+ *     not reciculate to the depth provide by 'facet' then 'facet' is
+ *     removed.
+ */
 static void
 facet_revalidate(struct facet *facet)
 {
@@ -4948,8 +5345,16 @@ facet_revalidate(struct facet *facet)
     uint64_t odp_actions_stub[1024 / 8];
     struct ofpbuf odp_actions;
 
+    const struct ofpact *ofpacts;
+    size_t ofpacts_len;
+
     struct rule_dpif *new_rule;
+
+    struct facet *chain[MAX_RECIRCULATION_DEPTH + 1];
+    size_t chain_len;
+
     struct subfacet *subfacet;
+    uint32_t recirculation_id;
     int i;
 
     COVERAGE_INC(facet_revalidate);
@@ -4967,13 +5372,57 @@ facet_revalidate(struct facet *facet)
                                 &recv_ofproto, NULL, NULL);
         if (error
             || recv_ofproto != ofproto
-            || memcmp(&recv_flow, &facet->flow, sizeof recv_flow)) {
+            || memcmp(&recv_flow, &facet->flow, sizeof recv_flow)
+            || peek_recirculation_id(ofproto) == RECIRCULATION_ID_NONE) {
             facet_remove(facet);
             return;
         }
     }
 
-    new_rule = rule_dpif_lookup(ofproto, &facet->flow);
+    chain_len = get_facet_chain(facet, chain, ARRAY_SIZE(chain), false);
+    /* If the top-most facet in the chain is a facet for a recirculated
+     * packet then the original top-most can't be found because it has been
+     * revalidated with a rule that has fewer of recirculation actions than
+     * the previous rule.  In this case, remove the facets in the chain as
+     * they are longer useful. */
+    if (chain[chain_len - 1]->recirculated) {
+        facet_remove(facet);
+        return;
+    }
+
+    new_rule = rule_dpif_lookup(ofproto, &chain[chain_len - 1]->flow);
+    memset(&ctx, 0, sizeof ctx);
+    ofpbuf_use_stub(&odp_actions, odp_actions_stub, sizeof odp_actions_stub);
+    ofpacts = new_rule->up.ofpacts;
+    ofpacts_len = new_rule->up.ofpacts_len;
+
+    /* In the case of a facet of a recirculated packet there
+     * will be a chain of facets leading up to the top-most facet which
+     * is for the original unrecirculated packet. Step through the chain
+     * from the top until one before the facet being revalidated in
+     * order to calculate the ofpacts and ofpacts_len. */
+    while (chain_len-- > 1) {
+        struct facet *f = chain[chain_len];
+        struct subfacet *subfacet = CONTAINER_OF(list_front(&f->subfacets),
+                                                 struct subfacet, list_node);
+
+        action_xlate_ctx_init(&ctx, ofproto, &f->flow,
+                              &subfacet->initial_vals, new_rule, 0, NULL,
+                              f->recirculation_id);
+        xlate_actions(&ctx, ofpacts, ofpacts_len, &odp_actions);
+
+        if (f->recirculation_id != RECIRCULATION_ID_NONE && !ctx.recirculated) {
+           /* If the facet no longer adds a recirculation action or is
+            * queued up for removal then In this case, remove the remaining
+            * facets in the chain as they are longer useful. */
+            facet_remove(facet);
+            ofpbuf_uninit(&odp_actions);
+            return;
+        }
+
+        ofpacts = ofpact_end(ofpacts, ctx.ofpacts_len);
+        ofpacts_len -= ctx.ofpacts_len;
+    }
 
     /* Calculate new datapath actions.
      *
@@ -4985,15 +5434,15 @@ facet_revalidate(struct facet *facet)
      * then we need to talk to the datapath. */
     i = 0;
     new_actions = NULL;
-    memset(&ctx, 0, sizeof ctx);
-    ofpbuf_use_stub(&odp_actions, odp_actions_stub, sizeof odp_actions_stub);
+    recirculation_id = facet->recirculation_id;
     LIST_FOR_EACH (subfacet, list_node, &facet->subfacets) {
         enum slow_path_reason slow;
 
         action_xlate_ctx_init(&ctx, ofproto, &facet->flow,
-                              &subfacet->initial_vals, new_rule, 0, NULL);
-        xlate_actions(&ctx, new_rule->up.ofpacts, new_rule->up.ofpacts_len,
-                      &odp_actions);
+                              &subfacet->initial_vals, new_rule, 0, NULL,
+                              recirculation_id);
+        xlate_actions(&ctx, ofpacts, ofpacts_len, &odp_actions);
+        recirculation_id = ctx.recirculation_id;
 
         slow = (subfacet->slow & SLOW_MATCH) | ctx.slow;
         if (subfacet_should_install(subfacet, slow, &odp_actions)) {
@@ -5016,6 +5465,19 @@ facet_revalidate(struct facet *facet)
     }
     ofpbuf_uninit(&odp_actions);
 
+    /* Update ofpacts and recirculation fields of facet before
+     * calling facet_flush_stats() as it may indirectly call
+     * action_xlate_ctx_init() which requires those fields to be accurate. */
+    facet->ofpacts = ofpacts;
+    facet->ofpacts_len = ofpacts_len;
+    if (ctx.recirculated) {
+        facet_set_recirculation(facet, ctx.recirculation_id, ctx.ofpacts_len);
+    } else if (facet->recirculation_id != RECIRCULATION_ID_NONE) {
+        facet_recirculation_id_remove(facet);
+        hmap_node_nullify(&facet->recirculation_id_hmap_node);
+        facet->recirculation_id = RECIRCULATION_ID_NONE;
+    }
+
     if (new_actions) {
         facet_flush_stats(facet);
     }
@@ -5093,7 +5555,8 @@ facet_push_stats(struct facet *facet)
         facet->prev_byte_count = facet->byte_count;
         facet->prev_used = facet->used;
 
-        flow_push_stats(facet, &stats);
+        flow_push_stats(facet, &stats,
+                        facet->ofpacts, facet->ofpacts_len);
 
         update_mirror_stats(ofproto_dpif_cast(facet->rule->up.ofproto),
                             facet->mirrors, stats.n_packets, stats.n_bytes);
@@ -5133,7 +5596,8 @@ rule_credit_stats(struct rule_dpif *rule, const struct dpif_flow_stats *stats)
 /* Pushes flow statistics to the rules which 'facet->flow' resubmits
  * into given 'facet->rule''s actions and mirrors. */
 static void
-flow_push_stats(struct facet *facet, const struct dpif_flow_stats *stats)
+flow_push_stats(struct facet *facet, const struct dpif_flow_stats *stats,
+                const struct ofpact *ofpacts, size_t ofpacts_len)
 {
     struct rule_dpif *rule = facet->rule;
     struct ofproto_dpif *ofproto = ofproto_dpif_cast(rule->up.ofproto);
@@ -5143,10 +5607,11 @@ flow_push_stats(struct facet *facet, const struct dpif_flow_stats *stats)
     ofproto_rule_update_used(&rule->up, stats->used);
 
     action_xlate_ctx_init(&ctx, ofproto, &facet->flow,
-                          &subfacet->initial_vals, rule, 0, NULL);
+                          &subfacet->initial_vals, rule, 0, NULL,
+                          facet->recirculation_id);
     ctx.resubmit_stats = stats;
-    xlate_actions_for_side_effects(&ctx, rule->up.ofpacts,
-                                   rule->up.ofpacts_len);
+
+    xlate_actions_for_side_effects(&ctx, ofpacts, ofpacts_len);
 }
 
 /* Subfacets. */
@@ -5306,8 +5771,13 @@ subfacet_make_actions(struct subfacet *subfacet, const struct ofpbuf *packet,
     struct action_xlate_ctx ctx;
 
     action_xlate_ctx_init(&ctx, ofproto, &facet->flow,
-                          &subfacet->initial_vals, rule, 0, packet);
-    xlate_actions(&ctx, rule->up.ofpacts, rule->up.ofpacts_len, odp_actions);
+                          &subfacet->initial_vals, rule, 0, packet,
+                          facet->recirculation_id);
+    xlate_actions(&ctx, facet->ofpacts, facet->ofpacts_len, odp_actions);
+    if (ctx.recirculated) {
+        facet_set_recirculation(facet, ctx.recirculation_id,
+                                ctx.ofpacts_len);
+    }
     facet->tags = ctx.tags;
     facet->has_learn = ctx.has_learn;
     facet->has_normal = ctx.has_normal;
@@ -5638,7 +6108,8 @@ rule_dpif_execute(struct rule_dpif *rule, const struct flow *flow,
     initial_vals.tunnel_ip_tos = flow->tunnel.ip_tos;
     ofpbuf_use_stub(&odp_actions, odp_actions_stub, sizeof odp_actions_stub);
     action_xlate_ctx_init(&ctx, ofproto, flow, &initial_vals,
-                          rule, stats.tcp_flags, packet);
+                          rule, stats.tcp_flags, packet,
+                          RECIRCULATION_ID_DUMMY);
     ctx.resubmit_stats = &stats;
     xlate_actions(&ctx, rule->up.ofpacts, rule->up.ofpacts_len, &odp_actions);
 
@@ -6320,6 +6791,16 @@ execute_dec_mpls_ttl_action(struct action_xlate_ctx *ctx)
 }
 
 static void
+execute_recircualte_action(struct action_xlate_ctx *ctx)
+{
+    if (ctx->recirculation_id == RECIRCULATION_ID_NONE) {
+        ctx->recirculation_id = get_recirculation_id();
+    }
+    ctx->recirculated = true;
+    ctx->flow.skb_mark = ctx->recirculation_id;
+}
+
+static void
 xlate_output_action(struct action_xlate_ctx *ctx,
                     uint16_t port, uint16_t max_len, bool may_packet_in)
 {
@@ -6560,6 +7041,7 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
                  struct action_xlate_ctx *ctx)
 {
     bool was_evictable = true;
+    bool may_recirculate = false;
     const struct ofpact *a;
 
     if (ctx->rule) {
@@ -6628,18 +7110,30 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
 
         case OFPACT_SET_IPV4_SRC:
             if (ctx->flow.dl_type == htons(ETH_TYPE_IP)) {
+                if (may_recirculate) {
+                    execute_recircualte_action(ctx);
+                    goto out;
+                }
                 ctx->flow.nw_src = ofpact_get_SET_IPV4_SRC(a)->ipv4;
             }
             break;
 
         case OFPACT_SET_IPV4_DST:
             if (ctx->flow.dl_type == htons(ETH_TYPE_IP)) {
+                if (may_recirculate) {
+                    execute_recircualte_action(ctx);
+                    goto out;
+                }
                 ctx->flow.nw_dst = ofpact_get_SET_IPV4_DST(a)->ipv4;
             }
             break;
 
         case OFPACT_SET_IPV4_DSCP:
             /* OpenFlow 1.0 only supports IPv4. */
+            if (may_recirculate) {
+                execute_recircualte_action(ctx);
+                goto out;
+            }
             if (ctx->flow.dl_type == htons(ETH_TYPE_IP)) {
                 ctx->flow.nw_tos &= ~IP_DSCP_MASK;
                 ctx->flow.nw_tos |= ofpact_get_SET_IPV4_DSCP(a)->dscp;
@@ -6648,12 +7142,20 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
 
         case OFPACT_SET_L4_SRC_PORT:
             if (is_ip_any(&ctx->flow)) {
+                if (may_recirculate) {
+                    execute_recircualte_action(ctx);
+                    goto out;
+                }
                 ctx->flow.tp_src = htons(ofpact_get_SET_L4_SRC_PORT(a)->port);
             }
             break;
 
         case OFPACT_SET_L4_DST_PORT:
             if (is_ip_any(&ctx->flow)) {
+                if (may_recirculate) {
+                    execute_recircualte_action(ctx);
+                    goto out;
+                }
                 ctx->flow.tp_dst = htons(ofpact_get_SET_L4_DST_PORT(a)->port);
             }
             break;
@@ -6694,10 +7196,15 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
 
         case OFPACT_PUSH_MPLS:
             execute_mpls_push_action(ctx, ofpact_get_PUSH_MPLS(a)->ethertype);
+            may_recirculate = false;
             break;
 
         case OFPACT_POP_MPLS:
             execute_mpls_pop_action(ctx, ofpact_get_POP_MPLS(a)->ethertype);
+            if (ctx->flow.dl_type == htons(ETH_TYPE_IP) ||
+                ctx->flow.dl_type == htons(ETH_TYPE_IPV6)) {
+                may_recirculate = true;
+            }
             break;
 
         case OFPACT_SET_MPLS_TTL:
@@ -6713,7 +7220,10 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
             break;
 
         case OFPACT_DEC_TTL:
-            if (compose_dec_ttl(ctx, ofpact_get_DEC_TTL(a))) {
+            if (may_recirculate) {
+                execute_recircualte_action(ctx);
+                goto out;
+            } else if (compose_dec_ttl(ctx, ofpact_get_DEC_TTL(a))) {
                 goto out;
             }
             break;
@@ -6800,6 +7310,7 @@ do_xlate_actions(const struct ofpact *ofpacts, size_t ofpacts_len,
     }
 
 out:
+    ctx->ofpacts_len = (char *)(a) - (char *)ofpacts;
     if (ctx->rule) {
         ctx->rule->up.evictable = was_evictable;
     }
@@ -6810,7 +7321,8 @@ action_xlate_ctx_init(struct action_xlate_ctx *ctx,
                       struct ofproto_dpif *ofproto, const struct flow *flow,
                       const struct initial_vals *initial_vals,
                       struct rule_dpif *rule,
-                      uint8_t tcp_flags, const struct ofpbuf *packet)
+                      uint8_t tcp_flags, const struct ofpbuf *packet,
+                      uint32_t recirculation_id)
 {
     ovs_be64 initial_tun_id = flow->tunnel.tun_id;
 
@@ -6833,7 +7345,13 @@ action_xlate_ctx_init(struct action_xlate_ctx *ctx,
      *   registers.
      * - Tunnel 'base_flow' is completely cleared since that is what the
      *   kernel does.  If we wish to maintain the original values an action
-     *   needs to be generated. */
+     *   needs to be generated.
+     * - The recirculation_id element of flow and base flow are set to
+     *   recirculate_id, which is the id that will be used by a recirculation
+     *   action of one is added. It is stored in flow and base_flow for
+     *   convenience as the recirculation_id element of flow and base flow
+     *   are otherwise unused  by action_xlate_ctx_init().
+     */
 
     ctx->ofproto = ofproto;
     ctx->flow = *flow;
@@ -6849,6 +7367,7 @@ action_xlate_ctx_init(struct action_xlate_ctx *ctx,
     ctx->resubmit_hook = NULL;
     ctx->report_hook = NULL;
     ctx->resubmit_stats = NULL;
+    ctx->recirculation_id = recirculation_id;
 }
 
 /* Translates the 'ofpacts_len' bytes of "struct ofpacts" starting at 'ofpacts'
@@ -6885,6 +7404,7 @@ xlate_actions(struct action_xlate_ctx *ctx,
     ctx->orig_skb_priority = ctx->flow.skb_priority;
     ctx->table_id = 0;
     ctx->exit = false;
+    ctx->recirculated = false;
 
     ofpbuf_use_stub(&ctx->stack, ctx->init_stack, sizeof ctx->init_stack);
 
@@ -6933,6 +7453,11 @@ xlate_actions(struct action_xlate_ctx *ctx,
 
         if (tunnel_ecn_ok(ctx) && (!in_port || may_receive(in_port, ctx))) {
             do_xlate_actions(ofpacts, ofpacts_len, ctx);
+            if (ctx->recirculated) {
+                commit_odp_actions(&ctx->flow, &ctx->base_flow,
+                                   ctx->odp_actions);
+                commit_odp_recirculate_action(odp_actions);
+            }
 
             /* We've let OFPP_NORMAL and the learning action look at the
              * packet, so drop it now if forwarding is disabled. */
@@ -7676,10 +8201,10 @@ packet_out(struct ofproto *ofproto_, struct ofpbuf *packet,
     struct initial_vals initial_vals;
     struct odputil_keybuf keybuf;
     struct dpif_flow_stats stats;
+    struct flow flow_storage;
 
     struct ofpbuf key;
 
-    struct action_xlate_ctx ctx;
     uint64_t odp_actions_stub[1024 / 8];
     struct ofpbuf odp_actions;
 
@@ -7691,13 +8216,13 @@ packet_out(struct ofproto *ofproto_, struct ofpbuf *packet,
 
     initial_vals.vlan_tci = flow->vlan_tci;
     initial_vals.tunnel_ip_tos = 0;
-    action_xlate_ctx_init(&ctx, ofproto, flow, &initial_vals, NULL,
-                          packet_get_tcp_flags(packet, flow), packet);
-    ctx.resubmit_stats = &stats;
 
     ofpbuf_use_stub(&odp_actions,
                     odp_actions_stub, sizeof odp_actions_stub);
-    xlate_actions(&ctx, ofpacts, ofpacts_len, &odp_actions);
+    flow = xlate_with_recirculate(ofproto, NULL, flow, &flow_storage,
+                                  &initial_vals, ofpacts, ofpacts_len,
+                                  &odp_actions, &stats, packet);
+
     dpif_execute(ofproto->backer->dpif, key.data, key.size,
                  odp_actions.data, odp_actions.size, packet);
     ofpbuf_uninit(&odp_actions);
@@ -8077,7 +8602,7 @@ ofproto_trace(struct ofproto_dpif *ofproto, const struct flow *flow,
         ofpbuf_use_stub(&odp_actions,
                         odp_actions_stub, sizeof odp_actions_stub);
         action_xlate_ctx_init(&trace.ctx, ofproto, flow, initial_vals,
-                              rule, tcp_flags, packet);
+                              rule, tcp_flags, packet, RECIRCULATION_ID_DUMMY);
         trace.ctx.resubmit_hook = trace_resubmit;
         trace.ctx.report_hook = trace_report;
         xlate_actions(&trace.ctx, rule->up.ofpacts, rule->up.ofpacts_len,
-- 
1.7.10.4
