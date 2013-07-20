From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH v2.35 4/6] ofp-actions: Add separate OpenFlow 1.3
	action parser
Date: Sat, 20 Jul 2013 12:07:01 +0900
Message-ID: <1374289623-17056-5-git-send-email-horms@verge.net.au>
References: <1374289623-17056-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Isaku Yamahata <yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1374289623-17056-1-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
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

From: Joe Stringer <joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org>

This patch adds new ofpact_from_openflow13() and
ofpacts_from_openflow13() functions parallel to the existing ofpact
handling code. In the OpenFlow 1.3 version, push_mpls is handled
differently, but all other actions are handled by the existing code.

For push_mpls, ofpact_push_mpls.ofpact.compat is set to
OFPUTIL_OFPAT13_PUSH_MPLS, which allows correct VLAN+MPLS datapath
behaviour to be determined at odp translation time.

Signed-off-by: Joe Stringer <joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org>
Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
---
 lib/ofp-actions.c |   63 ++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 60 insertions(+), 3 deletions(-)

diff --git a/lib/ofp-actions.c b/lib/ofp-actions.c
index 3e8b646..80994bd 100644
--- a/lib/ofp-actions.c
+++ b/lib/ofp-actions.c
@@ -877,6 +877,40 @@ ofpacts_from_openflow11(const union ofp_action *in, size_t n_in,
     return ofpacts_from_openflow(in, n_in, out, ofpact_from_openflow11);
 }
 
+static enum ofperr
+ofpact_from_openflow13(const union ofp_action *a, struct ofpbuf *out)
+{
+    enum ofputil_action_code code;
+    enum ofperr error;
+
+    error = decode_openflow11_action(a, &code);
+    if (error) {
+        return error;
+    }
+
+    if (code == OFPUTIL_OFPAT11_PUSH_MPLS) {
+        struct ofpact_push_mpls *oam;
+        struct ofp11_action_push *oap = (struct ofp11_action_push *)a;
+        if (!eth_type_mpls(oap->ethertype)) {
+            return OFPERR_OFPBAC_BAD_ARGUMENT;
+        }
+        oam = ofpact_put_PUSH_MPLS(out);
+        oam->ethertype = oap->ethertype;
+        oam->ofpact.compat = OFPUTIL_OFPAT13_PUSH_MPLS;
+    } else {
+        return ofpact_from_openflow11(a, out);
+    }
+
+    return error;
+}
+
+static enum ofperr
+ofpacts_from_openflow13(const union ofp_action *in, size_t n_in,
+                        struct ofpbuf *out)
+{
+    return ofpacts_from_openflow(in, n_in, out, ofpact_from_openflow13);
+}
+
 /* OpenFlow 1.1 instructions. */
 
 #define DEFINE_INST(ENUM, STRUCT, EXTENSIBLE, NAME)             \
@@ -1080,6 +1114,17 @@ get_actions_from_instruction(const struct ofp11_instruction *inst,
     *n_actions = (ntohs(inst->len) - sizeof *inst) / OFP11_INSTRUCTION_ALIGN;
 }
 
+static uint8_t
+get_version_from_ofpbuf(const struct ofpbuf *openflow)
+{
+    if (openflow && openflow->l2) {
+        struct ofp_header *oh = openflow->l2;
+        return oh->version;
+    }
+
+    return OFP10_VERSION;
+}
+
 /* Attempts to convert 'actions_len' bytes of OpenFlow 1.1 actions from the
  * front of 'openflow' into ofpacts.  On success, replaces any existing content
  * in 'ofpacts' by the converted ofpacts; on failure, clears 'ofpacts'.
@@ -1099,8 +1144,15 @@ ofpacts_pull_openflow11_actions(struct ofpbuf *openflow,
                                 unsigned int actions_len,
                                 struct ofpbuf *ofpacts)
 {
-    return ofpacts_pull_actions(openflow, actions_len, ofpacts,
-                                ofpacts_from_openflow11);
+    uint8_t version = get_version_from_ofpbuf(openflow);
+
+    if (version < OFP13_VERSION) {
+        return ofpacts_pull_actions(openflow, actions_len, ofpacts,
+                                    ofpacts_from_openflow11);
+    } else {
+        return ofpacts_pull_actions(openflow, actions_len, ofpacts,
+                                    ofpacts_from_openflow13);
+    }
 }
 
 enum ofperr
@@ -1152,10 +1204,15 @@ ofpacts_pull_openflow11_instructions(struct ofpbuf *openflow,
     if (insts[OVSINST_OFPIT11_APPLY_ACTIONS]) {
         const union ofp_action *actions;
         size_t n_actions;
+        uint8_t version = get_version_from_ofpbuf(openflow);
 
         get_actions_from_instruction(insts[OVSINST_OFPIT11_APPLY_ACTIONS],
                                      &actions, &n_actions);
-        error = ofpacts_from_openflow11(actions, n_actions, ofpacts);
+        if (version < OFP13_VERSION) {
+            error = ofpacts_from_openflow11(actions, n_actions, ofpacts);
+        } else {
+            error = ofpacts_from_openflow13(actions, n_actions, ofpacts);
+        }
         if (error) {
             goto exit;
         }
-- 
1.7.10.4
