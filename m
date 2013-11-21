From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH v2.51 1/5] ofp-actions: Allow Consistency checking
	of OF1.3+ VLAN actions after mpls_push
Date: Thu, 21 Nov 2013 12:46:42 +0900
Message-ID: <1385005606-30130-2-git-send-email-horms@verge.net.au>
References: <1385005606-30130-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1385005606-30130-1-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

The aim of this patch is to support provide infrastructure for verification
of VLAN actions after an mpls_push action for OpenFlow1.3. This supplements
existing support for verifying these actions for pre-OpenFlow1.3.

In OpenFlow1.1 and 1.2 MPLS tags are pushed after any VLAN tags that
immediately follow the ethernet header. This is pre-OpenFlow1.3 tag
ordering. Open vSwitch also uses this ordering when supporting MPLS
actions via Nicira extensions to OpenFlow1.0.

When using pre-OpenFlow1.3 tag ordering an MPLS push action does not
affect the VLANs of a packet. If VLAN tags are present immediately after
the ethernet header then they remain present there.

In of OpenFlow1.3+ MPLS LSEs are pushed before any VLAN tags that
immediately follow the ethernet header. This is OpenFlow1.3+ tag
ordering.

When using OpenFlow1.3+ tag ordering an MPLS push action affects the
VLANs of a packet as any VLAN tags previously present after the ethernet
header are moved to be immediately after the newly pushed MPLS LSE. Thus
for the purpose of action consistency checking a packet may be changed
from a VLAN packet to a non-VLAN packet.

In this way the effective value of the VLAN TCI of a packet may differ
after an MPLS push depending on the OpenFlow version in use.

This patch does not enable the logic described above.
Rather it is disabled in ofpacts_check__(). It should
be enabled when support for OpenFlow1.3+ tag order is added
and enabled.

Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>

---

v2.51
* First non-RFC post
---
 lib/ofp-actions.c | 202 +++++++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 169 insertions(+), 33 deletions(-)

diff --git a/lib/ofp-actions.c b/lib/ofp-actions.c
index e07ea1d..6754939 100644
--- a/lib/ofp-actions.c
+++ b/lib/ofp-actions.c
@@ -1879,15 +1879,108 @@ inconsistent_match(enum ofputil_protocol *usable_protocols)
     *usable_protocols &= OFPUTIL_P_OF10_ANY;
 }
 
+/* Checks the consistency of a VLAN action by checking the state of the
+ * VLAN_CFI bit of the VLAN TCI against 'desired_cfi' and updating
+ * '*usable_protocols' accordingly.
+ *
+ * 'pre_of13_vlan_tci' is the VLAN TCI to check against for pre-OpenFlow1.3
+ * protocols.  'of13_vlan_tci' is the VLAN TCI to check against for
+ * OpenFlow1.3+ protocols.
+ *
+ * If the desired_cfi bit is in the desired state for any usable protocol
+ * then true is returned. Else false is returned.
+ *
+ * The check for consistent VLAN actions may depend on the OpenFlow version
+ * used and whether the VLAN action is preceded by an MPLS push action or
+ * not.
+ *
+ * In OpenFlow1.1 and 1.2 MPLS tags are pushed after any VLAN tags that
+ * immediately follow the ethernet header. This is pre-OpenFlow1.3 tag
+ * ordering. Open vSwitch also uses this ordering when supporting MPLS
+ * actions via Nicira extensions to OpenFlow1.0.
+ *
+ * When using pre-OpenFlow1.3 tag ordering an MPLS push action does not
+ * affect the VLANs of a packet. If VLAN tags are present immediately after
+ * the ethernet header then they remain present there.
+ *
+ * In of OpenFlow1.3+ MPLS LSEs are pushed before any VLAN tags that
+ * immediately follow the ethernet header. This is OpenFlow1.3+ tag
+ * ordering.
+ *
+ * When using OpenFlow1.3+ tag ordering an MPLS push action affects the
+ * VLANs of a packet as any VLAN tags previously present after the ethernet
+ * header are moved to be immediately after the newly pushed MPLS LSE. Thus
+ * for the purpose of action consistency checking a packet may be changed
+ * from a VLAN packet to a non-VLAN packet.
+ *
+ * In this way the effective value of the VLAN TCI of a packet may differ
+ * after an MPLS push depending on the OpenFlow version in use. This
+ * corresponds to the 'pre_of13_vlan_tci' and 'of13_vlan_tci' parameters of
+ * this function. */
+static bool
+ofpact_check_vlan(enum ofputil_protocol *usable_protocols,
+                  ovs_be16 pre_of13_vlan_tci, ovs_be16 of13_vlan_tci,
+                  bool desired_cfi)
+{
+    bool ok = false;
+    ovs_be16 tci, mask;
+
+    mask = htons(VLAN_CFI);
+    if (desired_cfi) {
+        tci = mask;
+    } else {
+        tci = htons(0);
+    }
+
+    if (*usable_protocols & OFPUTIL_P_OF13_UP) {
+        if ((of13_vlan_tci & mask) != tci) {
+            /* CFI miss-match for OpenFlow1.3+: clear those protocols */
+            *usable_protocols &= ~OFPUTIL_P_OF13_UP;
+        } else {
+            /* CFI bit is valid for a usable protocol:
+             * eventually return true */
+            ok = true;
+        }
+    }
+
+    if (*usable_protocols & ~OFPUTIL_P_OF13_UP) {
+        if ((pre_of13_vlan_tci & mask) != tci) {
+            enum ofputil_protocol of13_up;
+
+            /* CFI miss-match for pre-OpenFlow1.3: clear those protocols
+             * except OFPUTIL_P_OF10_ANY as it allows inconsistency. */
+            of13_up = *usable_protocols & OFPUTIL_P_OF13_UP;
+            inconsistent_match(usable_protocols);
+            *usable_protocols |= of13_up;
+        } else {
+            /* CFI bit is valid for a usable protocol:
+             * eventually return true */
+            ok = true;
+        }
+    }
+
+    return ok;
+}
+
+static enum ofperr ofpacts_check__(struct ofpact[], size_t ofpacts_len,
+                                   struct flow *, ofp_port_t max_ports,
+                                   uint8_t table_id, uint8_t n_tables,
+                                   enum ofputil_protocol *usable_protocols,
+                                   ovs_be16 *of13_vlan_tci);
+
 /* May modify flow->dl_type, flow->nw_proto and flow->vlan_tci,
  * caller must restore them.
  *
+ * May also modify of13_vlan_tci which the caller should discard. On the
+ * first call to ofpact_check__() of13_vlan_tci should be set to
+ * flow->vlan_tci
+ *
  * Modifies some actions, filling in fields that could not be properly set
  * without context. */
 static enum ofperr
 ofpact_check__(enum ofputil_protocol *usable_protocols, struct ofpact *a,
                struct flow *flow, ofp_port_t max_ports,
-               uint8_t table_id, uint8_t n_tables)
+               uint8_t table_id, uint8_t n_tables, ovs_be16 *of13_vlan_tci)
 {
     const struct ofpact_enqueue *enqueue;
     const struct mf_field *mf;
@@ -1920,12 +2013,13 @@ ofpact_check__(enum ofputil_protocol *usable_protocols, struct ofpact *a,
          * OpenFlow 1.1+ if need be. */
         ofpact_get_SET_VLAN_VID(a)->flow_has_vlan =
             (flow->vlan_tci & htons(VLAN_CFI)) == htons(VLAN_CFI);
-        if (!(flow->vlan_tci & htons(VLAN_CFI)) &&
-            !ofpact_get_SET_VLAN_VID(a)->push_vlan_if_needed) {
-            inconsistent_match(usable_protocols);
+        if (!ofpact_get_SET_VLAN_VID(a)->push_vlan_if_needed) {
+            ofpact_check_vlan(usable_protocols, flow->vlan_tci,
+                              *of13_vlan_tci, true);
         }
         /* Temporary mark that we have a vlan tag. */
         flow->vlan_tci |= htons(VLAN_CFI);
+        *of13_vlan_tci |= htons(VLAN_CFI);
         return 0;
 
     case OFPACT_SET_VLAN_PCP:
@@ -1933,29 +2027,31 @@ ofpact_check__(enum ofputil_protocol *usable_protocols, struct ofpact *a,
          * OpenFlow 1.1+ if need be. */
         ofpact_get_SET_VLAN_PCP(a)->flow_has_vlan =
             (flow->vlan_tci & htons(VLAN_CFI)) == htons(VLAN_CFI);
-        if (!(flow->vlan_tci & htons(VLAN_CFI)) &&
-            !ofpact_get_SET_VLAN_PCP(a)->push_vlan_if_needed) {
-            inconsistent_match(usable_protocols);
+        if (!ofpact_get_SET_VLAN_PCP(a)->push_vlan_if_needed) {
+            ofpact_check_vlan(usable_protocols, flow->vlan_tci,
+                              *of13_vlan_tci, true);
         }
         /* Temporary mark that we have a vlan tag. */
         flow->vlan_tci |= htons(VLAN_CFI);
+        *of13_vlan_tci |= htons(VLAN_CFI);
         return 0;
 
     case OFPACT_STRIP_VLAN:
-        if (!(flow->vlan_tci & htons(VLAN_CFI))) {
-            inconsistent_match(usable_protocols);
-        }
+        ofpact_check_vlan(usable_protocols, flow->vlan_tci, *of13_vlan_tci,
+                          true);
         /* Temporary mark that we have no vlan tag. */
-        flow->vlan_tci = htons(0);
+        *of13_vlan_tci = flow->vlan_tci = htons(0);
         return 0;
 
     case OFPACT_PUSH_VLAN:
-        if (flow->vlan_tci & htons(VLAN_CFI)) {
+        if (!ofpact_check_vlan(usable_protocols, flow->vlan_tci,
+                               *of13_vlan_tci, false)) {
             /* Multiple VLAN headers not supported. */
             return OFPERR_OFPBAC_BAD_TAG;
         }
         /* Temporary mark that we have a vlan tag. */
         flow->vlan_tci |= htons(VLAN_CFI);
+        *of13_vlan_tci |= htons(VLAN_CFI);
         return 0;
 
     case OFPACT_SET_ETH_SRC:
@@ -2012,9 +2108,9 @@ ofpact_check__(enum ofputil_protocol *usable_protocols, struct ofpact *a,
         mf = ofpact_get_SET_FIELD(a)->field;
         /* Require OXM_OF_VLAN_VID to have an existing VLAN header. */
         if (!mf_are_prereqs_ok(mf, flow) ||
-            (mf->id == MFF_VLAN_VID && !(flow->vlan_tci & htons(VLAN_CFI)))) {
-            VLOG_WARN_RL(&rl, "set_field %s lacks correct prerequisities",
-                         mf->name);
+            (mf->id == MFF_VLAN_VID &&
+             !ofpact_check_vlan(usable_protocols, flow->vlan_tci,
+                                *of13_vlan_tci, true))) {
             return OFPERR_OFPBAC_MATCH_INCONSISTENT;
         }
         /* Remember if we saw a vlan tag in the flow to aid translating to
@@ -2025,6 +2121,7 @@ ofpact_check__(enum ofputil_protocol *usable_protocols, struct ofpact *a,
             /* The set field may add or remove the vlan tag,
              * Mark the status temporarily. */
             flow->vlan_tci = ofpact_get_SET_FIELD(a)->value.be16;
+            *of13_vlan_tci = ofpact_get_SET_FIELD(a)->value.be16;
         }
         return 0;
 
@@ -2071,6 +2168,13 @@ ofpact_check__(enum ofputil_protocol *usable_protocols, struct ofpact *a,
          * Thus nothing can be assumed about the network protocol.
          * Temporarily mark that we have no nw_proto. */
         flow->nw_proto = 0;
+
+        /* In the case of OpenFlow1.3+ the MPLS LSE is pushed before
+         * any VLAN tags which were previously present immediately
+         * after the VLAN header.
+         * Temporarily mark that there is no VLAN tag in the case
+         * of OpenFlow1.3+ */
+        *of13_vlan_tci = htons(0);
         return 0;
 
     case OFPACT_POP_MPLS:
@@ -2091,8 +2195,9 @@ ofpact_check__(enum ofputil_protocol *usable_protocols, struct ofpact *a,
          * consistency of an action set. */
         struct ofpact_nest *on = ofpact_get_WRITE_ACTIONS(a);
         enum ofputil_protocol p = *usable_protocols;
-        return ofpacts_check(on->actions, ofpact_nest_get_action_len(on),
-                             flow, max_ports, table_id, n_tables, &p);
+        return ofpacts_check__(on->actions, ofpact_nest_get_action_len(on),
+                               flow, max_ports, table_id, n_tables, &p,
+                               of13_vlan_tci);
     }
 
     case OFPACT_WRITE_METADATA:
@@ -2123,23 +2228,21 @@ ofpact_check__(enum ofputil_protocol *usable_protocols, struct ofpact *a,
     }
 }
 
-/* Checks that the 'ofpacts_len' bytes of actions in 'ofpacts' are
- * appropriate for a packet with the prerequisites satisfied by 'flow' in a
- * switch with no more than 'max_ports' ports.
- *
- * If 'ofpacts' and 'flow' are inconsistent with one another, un-sets in
- * '*usable_protocols' the protocols that forbid the inconsistency.  (An
- * example of an inconsistency between match and actions is a flow that does
- * not match on an MPLS Ethertype but has an action that pops an MPLS label.)
+/* May modify flow->dl_type, flow->nw_proto and flow->vlan_tci,
+ * caller must restore them.
  *
- * May annotate ofpacts with information gathered from the 'flow'.
+ * May also modify of13_vlan_tci which the caller should discard. On the
+ * first call to ofpacts_check__() of13_vlan_tci should be set to
+ * flow->vlan_tci
  *
- * May temporarily modify 'flow', but restores the changes before returning. */
-enum ofperr
-ofpacts_check(struct ofpact ofpacts[], size_t ofpacts_len,
-              struct flow *flow, ofp_port_t max_ports,
-              uint8_t table_id, uint8_t n_tables,
-              enum ofputil_protocol *usable_protocols)
+ * Modifies some actions, filling in fields that could not be properly set
+ * without context. */
+static enum ofperr
+ofpacts_check__(struct ofpact ofpacts[], size_t ofpacts_len,
+                struct flow *flow, ofp_port_t max_ports,
+                uint8_t table_id, uint8_t n_tables,
+                enum ofputil_protocol *usable_protocols,
+                ovs_be16 *of13_vlan_tci)
 {
     struct ofpact *a;
     ovs_be16 dl_type = flow->dl_type;
@@ -2149,10 +2252,19 @@ ofpacts_check(struct ofpact ofpacts[], size_t ofpacts_len,
 
     OFPACT_FOR_EACH (a, ofpacts, ofpacts_len) {
         error = ofpact_check__(usable_protocols, a, flow,
-                               max_ports, table_id, n_tables);
+                               max_ports, table_id, n_tables,
+                               of13_vlan_tci);
         if (error) {
             break;
         }
+        /* XXX
+         * OF1.3 tag order is not currently implemented.
+         * The following line effectively disables the
+         * use of 'of13_vlan_tci' to check OF1.3+ tag order
+         * consistency. This means that pre-OF1.3+ is always used.
+         * This line should be removed by a subequent
+         * patch which enables the use of OF1.3+ tag order */
+        *of13_vlan_tci = flow->vlan_tci;
     }
     /* Restore fields that may have been modified. */
     flow->dl_type = dl_type;
@@ -2161,6 +2273,30 @@ ofpacts_check(struct ofpact ofpacts[], size_t ofpacts_len,
     return error;
 }
 
+/* Checks that the 'ofpacts_len' bytes of actions in 'ofpacts' are
+ * appropriate for a packet with the prerequisites satisfied by 'flow' in a
+ * switch with no more than 'max_ports' ports.
+ *
+ * If 'ofpacts' and 'flow' are inconsistent with one another, un-sets in
+ * '*usable_protocols' the protocols that forbid the inconsistency.  (An
+ * example of an inconsistency between match and actions is a flow that does
+ * not match on an MPLS Ethertype but has an action that pops an MPLS label.)
+ *
+ * May annotate ofpacts with information gathered from the 'flow'.
+ *
+ * May temporarily modify 'flow', but restores the changes before returning. */
+enum ofperr
+ofpacts_check(struct ofpact ofpacts[], size_t ofpacts_len,
+              struct flow *flow, ofp_port_t max_ports,
+              uint8_t table_id, uint8_t n_tables,
+              enum ofputil_protocol *usable_protocols)
+{
+    ovs_be16 of13_vlan_tci = flow->vlan_tci;
+
+    return ofpacts_check__(ofpacts, ofpacts_len, flow, max_ports, table_id,
+                           n_tables, usable_protocols, &of13_vlan_tci);
+}
+
 /* Like ofpacts_check(), but reports inconsistencies as
  * OFPERR_OFPBAC_MATCH_INCONSISTENT rather than clearing bits. */
 enum ofperr
-- 
1.8.4
