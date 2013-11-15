From: Simon Horman <horms@verge.net.au>
Subject: [PATCH v2.49 2/6] ofp-actions: Account for OF version when enforcing action consistency
Date: Fri, 15 Nov 2013 16:50:54 +0900
Message-ID: <1384501858-30535-3-git-send-email-horms@verge.net.au>
References: <1384501858-30535-1-git-send-email-horms@verge.net.au>
Cc: Pravin B Shelar <pshelar@nicira.com>, Ravi K <rkerur@gmail.com>,
	Joe Stringer <joe@wand.net.nz>
To: dev@openvswitch.org, netdev@vger.kernel.org,
	Jesse Gross <jesse@nicira.com>, Ben Pfaff <blp@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:35016 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755392Ab3KOHvH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 02:51:07 -0500
In-Reply-To: <1384501858-30535-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The aim of this patch is to provide infrastructure to differentiate
between OpenFlow1.1 - 1.2 and OpenFlow1.3+ consistency checking. It
also provides enhanced OpenFlow1.0 consistency checking.

Some different versions of OpenFlow require different consistency
checking.

1. OpenFlow1.0

   This variant implicitly pushes a VLAN tag if one doesn't exist
   and an action to modify a VLAN tag is encountered.

   MPLS push is supported as a Nicira extension whose behaviour is
   the same as OpenFlow1.1 - 1.2.

   In practice Open vSwitch allows inconsistent OpenFlow 1.0 actions so
   this portion of the change is just for completeness. I do not believe it
   has any run-time affect. And I would not be opposed to folding this case
   into the handling of OpenFlow1.1 - 1.2.

2. OpenFlow1.1 - 1.2

   This does not have the implicit VLAN tag push behaviour of OpenFlow1.0.

   An MPLS push action pushes an MPLS LSE after any VLAN tags that are
   present. This is pre-OpenFlow1.3 tag ordering.

3. OpenFlow1.3+

   This does not have the implicit VLAN tag push behaviour of OpenFlow1.0.

   An MPLS push action pushes an MPLS LSE before any VLAN tags that are
   present. This is OpenFlow1.3+ tag ordering. Its implication
   is that after an MPLS push action a packet is no longer a VLAN
   packet as there are no longer any VLAN tags immediately after
   the ethernet header: there is now an MPLS LSE there.

   Currently Open vSwitch does not implement OpenFlow1.3+ tag ordering
   so this patch uses the same consistency checking for OpenFlow1.3+
   as for OpenFlow1.1 - 1.2.

   A subsequent patch, which implements OpenFlow1.3+ tag ordering,
   makes use of the infrastructure provided by this patch to check
   actions accordingly.

Unfortunately ofpact_get_SET_VLAN_VID(a)->push_vlan_if_needed and similar
devices can't be used in order to implement logic as they are not set when
when ofpact_check__() is called via parse_ofp_str().

Instead this patch takes the approach of adding an OpenFlow version
parameter to ofpact_check__().

A new function ofpact_check_usable_protocols() allows trimming the
usable_protocols based on action checking.

The net effect of this change on run-time is only to increase logging under
some circumstances as ofpacts_check() may now be called up to four times
instead of up to twice for each invocation of parse_ofp_str__()

Signed-off-by: Simon Horman <horms@verge.net.au>

---

v2.49
* Temporarily set the CFI bit of flow->vlan_tci in ofpact_check__()
  on mpls_pop as in this case a VLAN is now present. The value
  of the other bits of the VLAN are unimportant in this context
* Add ofpact_check_usable_protocols using logic that appeared in
  parse_ofp_str__() in v1 of this patch. This is to allow it to
  be re-used in ofproto_unixctl_trace_actions().
* Move OpenFlow1.3+ logic into a subsequent patch.
* Enhance changelog

v1
* First post posted separately to the MPLS patchset that
  it is now included in.
---
 lib/ofp-actions.c      | 61 ++++++++++++++++++++++++++++++++++++++++++--------
 lib/ofp-actions.h      | 11 ++++++++-
 lib/ofp-parse.c        | 24 +++++++-------------
 lib/ofp-util.c         |  6 ++---
 ofproto/ofproto-dpif.c |  8 ++++---
 tests/learn.at         |  2 ++
 utilities/ovs-ofctl.c  |  4 ++--
 7 files changed, 82 insertions(+), 34 deletions(-)

diff --git a/lib/ofp-actions.c b/lib/ofp-actions.c
index e4e05dd..64333b3 100644
--- a/lib/ofp-actions.c
+++ b/lib/ofp-actions.c
@@ -1875,9 +1875,9 @@ ofpact_check_output_port(ofp_port_t port, ofp_port_t max_ports)
  * Modifies some actions, filling in fields that could not be properly set
  * without context. */
 static enum ofperr
-ofpact_check__(struct ofpact *a, struct flow *flow,
-               bool enforce_consistency, ofp_port_t max_ports,
-               uint8_t table_id, uint8_t n_tables)
+ofpact_check__(enum ofp_version ofp_version, struct ofpact *a,
+               struct flow *flow, bool enforce_consistency,
+               ofp_port_t max_ports, uint8_t table_id, uint8_t n_tables)
 {
     const struct ofpact_enqueue *enqueue;
     const struct mf_field *mf;
@@ -1911,7 +1911,7 @@ ofpact_check__(struct ofpact *a, struct flow *flow,
         ofpact_get_SET_VLAN_VID(a)->flow_has_vlan =
             (flow->vlan_tci & htons(VLAN_CFI)) == htons(VLAN_CFI);
         if (!(flow->vlan_tci & htons(VLAN_CFI)) &&
-            !ofpact_get_SET_VLAN_VID(a)->push_vlan_if_needed) {
+            ofp_version >= OFP11_VERSION) {
             goto inconsistent;
         }
         /* Temporary mark that we have a vlan tag. */
@@ -1924,7 +1924,7 @@ ofpact_check__(struct ofpact *a, struct flow *flow,
         ofpact_get_SET_VLAN_PCP(a)->flow_has_vlan =
             (flow->vlan_tci & htons(VLAN_CFI)) == htons(VLAN_CFI);
         if (!(flow->vlan_tci & htons(VLAN_CFI)) &&
-            !ofpact_get_SET_VLAN_PCP(a)->push_vlan_if_needed) {
+            ofp_version >= OFP11_VERSION) {
             goto inconsistent;
         }
         /* Temporary mark that we have a vlan tag. */
@@ -2078,8 +2078,9 @@ ofpact_check__(struct ofpact *a, struct flow *flow,
 
     case OFPACT_WRITE_ACTIONS: {
         struct ofpact_nest *on = ofpact_get_WRITE_ACTIONS(a);
-        return ofpacts_check(on->actions, ofpact_nest_get_action_len(on),
-                             flow, false, max_ports, table_id, n_tables);
+        return ofpacts_check(ofp_version, on->actions,
+                             ofpact_nest_get_action_len(on), flow, false,
+                             max_ports, table_id, n_tables);
     }
 
     case OFPACT_WRITE_METADATA:
@@ -2124,7 +2125,8 @@ ofpact_check__(struct ofpact *a, struct flow *flow,
  *
  * May temporarily modify 'flow', but restores the changes before returning. */
 enum ofperr
-ofpacts_check(struct ofpact ofpacts[], size_t ofpacts_len,
+ofpacts_check(enum ofp_version ofp_version,
+              struct ofpact ofpacts[], size_t ofpacts_len,
               struct flow *flow, bool enforce_consistency,
               ofp_port_t max_ports,
               uint8_t table_id, uint8_t n_tables)
@@ -2136,7 +2138,7 @@ ofpacts_check(struct ofpact ofpacts[], size_t ofpacts_len,
     enum ofperr error = 0;
 
     OFPACT_FOR_EACH (a, ofpacts, ofpacts_len) {
-        error = ofpact_check__(a, flow, enforce_consistency,
+        error = ofpact_check__(ofp_version, a, flow, enforce_consistency,
                                max_ports, table_id, n_tables);
         if (error) {
             break;
@@ -2149,6 +2151,47 @@ ofpacts_check(struct ofpact ofpacts[], size_t ofpacts_len,
     return error;
 }
 
+enum ofperr
+ofpacts_check_usable_protocols(enum ofputil_protocol *usable_protocols,
+                               struct ofpact ofpacts[], size_t ofpacts_len,
+                               struct flow *flow, bool enforce_consistency,
+                               ofp_port_t max_ports, uint8_t table_id,
+                               uint8_t n_tables)
+{
+    enum ofperr err;
+    enum ofperr last_err = 0;
+
+    /* XXX: As a side effect of multiple calls to ofpacts_check
+     * logging may be duplicated. */
+    if (*usable_protocols & OFPUTIL_P_OF10_ANY) {
+        err = ofpacts_check(OFP10_VERSION, ofpacts, ofpacts_len, flow,
+                            true, max_ports, table_id, n_tables);
+        if (!enforce_consistency &&
+            err == OFPERR_OFPBAC_MATCH_INCONSISTENT) {
+            /* Try again, allowing for inconsistency. */
+            err = ofpacts_check(OFP10_VERSION, ofpacts, ofpacts_len, flow,
+                                false, max_ports, table_id, n_tables);
+        }
+        if (err) {
+            *usable_protocols &= ~OFPUTIL_P_OF10_ANY;
+            last_err = err;
+        }
+    }
+    if (*usable_protocols & (OFPUTIL_P_OF11_UP)) {
+        err = ofpacts_check(OFP11_VERSION, ofpacts, ofpacts_len, flow,
+                            true, max_ports, table_id, n_tables);
+        if (err) {
+            *usable_protocols &= ~(OFPUTIL_P_OF11_UP);
+            last_err = err;
+        }
+    }
+    if (!*usable_protocols && last_err) {
+        return last_err;
+    }
+
+    return 0;
+}
+
 /* Verifies that the 'ofpacts_len' bytes of actions in 'ofpacts' are
  * in the appropriate order as defined by the OpenFlow spec. */
 enum ofperr
diff --git a/lib/ofp-actions.h b/lib/ofp-actions.h
index 70ad4b6..56c84d0 100644
--- a/lib/ofp-actions.h
+++ b/lib/ofp-actions.h
@@ -606,10 +606,19 @@ enum ofperr ofpacts_pull_openflow_instructions(struct ofpbuf *openflow,
                                                unsigned int instructions_len,
                                                enum ofp_version version,
                                                struct ofpbuf *ofpacts);
-enum ofperr ofpacts_check(struct ofpact[], size_t ofpacts_len,
+enum ofperr ofpacts_check(enum ofp_version ofp_version,
+                          struct ofpact[], size_t ofpacts_len,
                           struct flow *, bool enforce_consistency,
                           ofp_port_t max_ports,
                           uint8_t table_id, uint8_t n_tables);
+enum ofperr ofpacts_check_usable_protocols(enum ofputil_protocol *usable_protocols,
+                                           struct ofpact ofpacts[],
+                                           size_t ofpacts_len,
+                                           struct flow *flow,
+                                           bool enforce_consistency,
+                                           ofp_port_t max_ports,
+                                           uint8_t table_id,
+                                           uint8_t n_tables);
 enum ofperr ofpacts_verify(const struct ofpact ofpacts[], size_t ofpacts_len);
 enum ofperr ofpact_check_output_port(ofp_port_t port, ofp_port_t max_ports);
 
diff --git a/lib/ofp-parse.c b/lib/ofp-parse.c
index f2debb3..85e7228 100644
--- a/lib/ofp-parse.c
+++ b/lib/ofp-parse.c
@@ -1414,24 +1414,16 @@ parse_ofp_str__(struct ofputil_flow_mod *fm, int command, char *string,
         if (!error) {
             enum ofperr err;
 
-            err = ofpacts_check(ofpacts.data, ofpacts.size, &fm->match.flow,
-                                true, OFPP_MAX, fm->table_id, 255);
+            err = ofpacts_check_usable_protocols(usable_protocols,
+                                                 ofpacts.data, ofpacts.size,
+                                                 &fm->match.flow,
+                                                 enforce_consistency, OFPP_MAX,
+                                                 fm->table_id, 255);
             if (err) {
-                if (!enforce_consistency &&
-                    err == OFPERR_OFPBAC_MATCH_INCONSISTENT) {
-                    /* Allow inconsistent actions to be used with OF 1.0. */
-                    *usable_protocols &= OFPUTIL_P_OF10_ANY;
-                    /* Try again, allowing for inconsistency.
-                     * XXX: As a side effect, logging may be duplicated. */
-                    err = ofpacts_check(ofpacts.data, ofpacts.size,
-                                        &fm->match.flow, false,
-                                        OFPP_MAX, fm->table_id, 255);
-                }
-                if (err) {
-                    error = xasprintf("actions are invalid with specified match "
-                                      "(%s)", ofperr_to_string(err));
-                }
+                error = xasprintf("actions are invalid with specified match "
+                                  "(%s)", ofperr_to_string(err));
             }
+
         }
         if (error) {
             ofpbuf_uninit(&ofpacts);
diff --git a/lib/ofp-util.c b/lib/ofp-util.c
index ede37b0..6678318 100644
--- a/lib/ofp-util.c
+++ b/lib/ofp-util.c
@@ -1672,9 +1672,9 @@ ofputil_decode_flow_mod(struct ofputil_flow_mod *fm,
                 : OFPERR_OFPFMFC_TABLE_FULL);
     }
 
-    return ofpacts_check(fm->ofpacts, fm->ofpacts_len, &fm->match.flow,
-                         oh->version > OFP10_VERSION, max_port,
-                         fm->table_id, max_table);
+    return ofpacts_check(oh->version, fm->ofpacts, fm->ofpacts_len,
+                         &fm->match.flow, oh->version > OFP10_VERSION,
+                         max_port, fm->table_id, max_table);
 }
 
 static enum ofperr
diff --git a/ofproto/ofproto-dpif.c b/ofproto/ofproto-dpif.c
index 3391594..cef6e38 100644
--- a/ofproto/ofproto-dpif.c
+++ b/ofproto/ofproto-dpif.c
@@ -5490,9 +5490,11 @@ ofproto_unixctl_trace_actions(struct unixctl_conn *conn, int argc,
         unixctl_command_reply_error(conn, "invalid in_port");
         goto exit;
     }
-    retval = ofpacts_check(ofpacts.data, ofpacts.size, &flow,
-                           enforce_consistency,
-                           u16_to_ofp(ofproto->up.max_ports), 0, 0);
+    retval = ofpacts_check_usable_protocols(&usable_protocols, ofpacts.data,
+                                            ofpacts.size, &flow,
+                                            enforce_consistency,
+                                            u16_to_ofp(ofproto->up.max_ports),
+                                            0, 0);
     if (retval) {
         ds_clear(&result);
         ds_put_format(&result, "Bad actions: %s", ofperr_to_string(retval));
diff --git a/tests/learn.at b/tests/learn.at
index 491cd5e..19e4449 100644
--- a/tests/learn.at
+++ b/tests/learn.at
@@ -76,6 +76,7 @@ AT_CHECK([[ovs-ofctl parse-flow 'actions=learn(load:5->NXM_OF_IP_DST[])']],
 AT_CHECK([sed -e 's/.*|meta_flow|WARN|//' < stderr], [0],
   [[destination field ip_dst lacks correct prerequisites
 destination field ip_dst lacks correct prerequisites
+destination field ip_dst lacks correct prerequisites
 ovs-ofctl: actions are invalid with specified match (OFPBAC_MATCH_INCONSISTENT)
 ]], [[]])
 AT_CHECK([[ovs-ofctl parse-flow 'actions=learn(load:NXM_OF_IP_DST[]->NXM_NX_REG1[])']],
@@ -83,6 +84,7 @@ AT_CHECK([[ovs-ofctl parse-flow 'actions=learn(load:NXM_OF_IP_DST[]->NXM_NX_REG1
 AT_CHECK([sed -e 's/.*|meta_flow|WARN|//' < stderr], [0],
   [[source field ip_dst lacks correct prerequisites
 source field ip_dst lacks correct prerequisites
+source field ip_dst lacks correct prerequisites
 ovs-ofctl: actions are invalid with specified match (OFPBAC_MATCH_INCONSISTENT)
 ]])
 AT_CLEANUP
diff --git a/utilities/ovs-ofctl.c b/utilities/ovs-ofctl.c
index a0dc5c8..f49093d 100644
--- a/utilities/ovs-ofctl.c
+++ b/utilities/ovs-ofctl.c
@@ -3077,8 +3077,8 @@ ofctl_parse_ofp11_instructions(int argc OVS_UNUSED, char *argv[] OVS_UNUSED)
             /* Verify actions, enforce consistency. */
             struct flow flow;
             memset(&flow, 0, sizeof flow);
-            error = ofpacts_check(ofpacts.data, ofpacts.size, &flow,
-                                  true, OFPP_MAX,
+            error = ofpacts_check(OFP11_VERSION, ofpacts.data, ofpacts.size,
+                                  &flow, true, OFPP_MAX,
                                   table_id ? atoi(table_id) : 0, 255);
         }
         if (error) {
-- 
1.8.4
