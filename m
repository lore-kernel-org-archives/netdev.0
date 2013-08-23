From: Simon Horman <horms@verge.net.au>
Subject: [PATCH v2.38 4/6] ofp-actions: Add separate OpenFlow 1.3 action parser
Date: Fri, 23 Aug 2013 13:16:54 +1000
Message-ID: <1377227816-15303-5-git-send-email-horms@verge.net.au>
References: <1377227816-15303-1-git-send-email-horms@verge.net.au>
Cc: Ravi K <rkerur@gmail.com>, Isaku Yamahata <yamahata@valinux.co.jp>,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Joe Stringer <joe@wand.net.nz>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:36706 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753719Ab3HWDPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Aug 2013 23:15:03 -0400
In-Reply-To: <1377227816-15303-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joe@wand.net.nz>

This patch adds new ofpact_from_openflow13() and
ofpacts_from_openflow13() functions parallel to the existing ofpact
handling code. In the OpenFlow 1.3 version, push_mpls is handled
differently, but all other actions are handled by the existing code.

For push_mpls, ofpact_push_mpls.ofpact.compat is set to
OFPUTIL_OFPAT13_PUSH_MPLS, which allows correct VLAN+MPLS datapath
behaviour to be determined at odp translation time.

Signed-off-by: Joe Stringer <joe@wand.net.nz>
Signed-off-by: Simon Horman <horms@verge.net.au>

---

v2.36 - v2.38
* No change

v2.35
* First post
---
 lib/ofp-actions.c |   63 ++++++++++++++++++++++++++++++++++++++++++++++++++---
 1 file changed, 60 insertions(+), 3 deletions(-)

diff --git a/lib/ofp-actions.c b/lib/ofp-actions.c
index 921aa27..454b9a1 100644
--- a/lib/ofp-actions.c
+++ b/lib/ofp-actions.c
@@ -878,6 +878,40 @@ ofpacts_from_openflow11(const union ofp_action *in, size_t n_in,
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
@@ -1081,6 +1115,17 @@ get_actions_from_instruction(const struct ofp11_instruction *inst,
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
@@ -1100,8 +1145,15 @@ ofpacts_pull_openflow11_actions(struct ofpbuf *openflow,
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
@@ -1153,10 +1205,15 @@ ofpacts_pull_openflow11_instructions(struct ofpbuf *openflow,
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
