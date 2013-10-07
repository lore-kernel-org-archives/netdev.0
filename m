From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH v2.43 2/5] ofp-actions: Add separate OpenFlow 1.3
	action parser
Date: Mon,  7 Oct 2013 17:00:44 +0900
Message-ID: <1381132847-12589-3-git-send-email-horms@verge.net.au>
References: <1381132847-12589-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Isaku Yamahata <yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1381132847-12589-1-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
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

In the case of push_mpls for OpenFlow 1.3 the new mpls_before_vlan field of
struct ofpact_push_mpls is set to true.  This will be used by a subsequent
patch to allow allow the correct VLAN+MPLS datapath behaviour to be
determined at odp translation time.

enum ofpact_mpls_position contributed by Ben Pfaff.

Signed-off-by: Joe Stringer <joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org>
Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>

---

Ben, please feel free to add yourself as a co-author
as you wrote the enum ofpact_mpls_position portion.

v2.43 [Ben Pfaff and Simon Horman]
* Code contributed by Ben Pfaff
  + Use enum for to control order of MPLS LSE insertion
    This makes the logic somewhat clearer
* Add a helper push_mpls_from_openflow() to consolidate
  the same logic that appears in three locations.

v2.42
* No change

v2.41 [Simon Horman]
* As suggested by Ben Pfaff
  + Expand struct ofpact_reg_load to include a mpls_before_vlan field
    rather than using the compat field of the ofpact field of
    struct ofpact_reg_load.
  + Pass version to  ofpacts_pull_openflow11_actions and
    ofpacts_pull_openflow11_instructions.  This removes the invalid
    assumption that that these functions are passed a full message and are
    thus able to deduce the OpenFlow version.

v2.36 - v2.40
* No change

v2.35 [Joe Stringer]
* First post
---
 lib/ofp-actions.c     | 91 ++++++++++++++++++++++++++++++++++++++++++++-------
 lib/ofp-actions.h     | 16 +++++++++
 lib/ofp-print.c       |  2 +-
 lib/ofp-util.c        | 24 ++++++++------
 lib/ofp-util.h        |  2 +-
 utilities/ovs-ofctl.c |  8 ++---
 6 files changed, 115 insertions(+), 28 deletions(-)

diff --git a/lib/ofp-actions.c b/lib/ofp-actions.c
index 65430f3..dc0c9c8 100644
--- a/lib/ofp-actions.c
+++ b/lib/ofp-actions.c
@@ -238,6 +238,22 @@ sample_from_openflow(const struct nx_action_sample *nas,
 }
 
 static enum ofperr
+push_mpls_from_openflow(ovs_be16 ethertype, enum ofpact_mpls_position position,
+                        struct ofpbuf *out)
+{
+    struct ofpact_push_mpls *oam;
+
+    if (!eth_type_mpls(ethertype)) {
+        return OFPERR_OFPBAC_BAD_ARGUMENT;
+    }
+    oam = ofpact_put_PUSH_MPLS(out);
+    oam->ethertype = ethertype;
+    oam->position = position;
+
+    return 0;
+}
+
+static enum ofperr
 decode_nxast_action(const union ofp_action *a, enum ofputil_action_code *code)
 {
     const struct nx_action_header *nah = (const struct nx_action_header *) a;
@@ -430,10 +446,8 @@ ofpact_from_nxast(const union ofp_action *a, enum ofputil_action_code code,
 
     case OFPUTIL_NXAST_PUSH_MPLS: {
         struct nx_action_push_mpls *nxapm = (struct nx_action_push_mpls *)a;
-        if (!eth_type_mpls(nxapm->ethertype)) {
-            return OFPERR_OFPBAC_BAD_ARGUMENT;
-        }
-        ofpact_put_PUSH_MPLS(out)->ethertype = nxapm->ethertype;
+        error = push_mpls_from_openflow(nxapm->ethertype,
+                                        OFPACT_MPLS_AFTER_VLAN, out);
         break;
     }
 
@@ -844,10 +858,8 @@ ofpact_from_openflow11(const union ofp_action *a, struct ofpbuf *out)
 
     case OFPUTIL_OFPAT11_PUSH_MPLS: {
         struct ofp11_action_push *oap = (struct ofp11_action_push *)a;
-        if (!eth_type_mpls(oap->ethertype)) {
-            return OFPERR_OFPBAC_BAD_ARGUMENT;
-        }
-        ofpact_put_PUSH_MPLS(out)->ethertype = oap->ethertype;
+        error = push_mpls_from_openflow(oap->ethertype,
+                                        OFPACT_MPLS_AFTER_VLAN, out);
         break;
     }
 
@@ -881,6 +893,35 @@ ofpacts_from_openflow11(const union ofp_action *in, size_t n_in,
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
+        struct ofp11_action_push *oap = (struct ofp11_action_push *)a;
+        error = push_mpls_from_openflow(oap->ethertype,
+                                        OFPACT_MPLS_BEFORE_VLAN, out);
+    } else {
+        error = ofpact_from_openflow11(a, out);
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
@@ -1085,11 +1126,14 @@ get_actions_from_instruction(const struct ofp11_instruction *inst,
     *n_actions = (ntohs(inst->len) - sizeof *inst) / OFP11_INSTRUCTION_ALIGN;
 }
 
-/* Attempts to convert 'actions_len' bytes of OpenFlow 1.1 actions from the
+/* Attempts to convert 'actions_len' bytes of OpenFlow actions from the
  * front of 'openflow' into ofpacts.  On success, replaces any existing content
  * in 'ofpacts' by the converted ofpacts; on failure, clears 'ofpacts'.
  * Returns 0 if successful, otherwise an OpenFlow error.
  *
+ * Actions are processed according to their OpenFlow version which
+ * is provided in the 'version' parameter.
+ *
  * In most places in OpenFlow 1.1 and 1.2, actions appear encapsulated in
  * instructions, so you should call ofpacts_pull_openflow11_instructions()
  * instead of this function.
@@ -1101,15 +1145,27 @@ get_actions_from_instruction(const struct ofp11_instruction *inst,
  * valid in a specific context. */
 enum ofperr
 ofpacts_pull_openflow11_actions(struct ofpbuf *openflow,
+                                enum ofp_version version,
                                 unsigned int actions_len,
                                 struct ofpbuf *ofpacts)
 {
-    return ofpacts_pull_actions(openflow, actions_len, ofpacts,
-                                ofpacts_from_openflow11);
+    switch (version) {
+    case OFP10_VERSION:
+    case OFP11_VERSION:
+    case OFP12_VERSION:
+        return ofpacts_pull_actions(openflow, actions_len, ofpacts,
+                                    ofpacts_from_openflow11);
+    case OFP13_VERSION:
+        return ofpacts_pull_actions(openflow, actions_len, ofpacts,
+                                    ofpacts_from_openflow13);
+    default:
+        NOT_REACHED();
+    }
 }
 
 enum ofperr
 ofpacts_pull_openflow11_instructions(struct ofpbuf *openflow,
+                                     enum ofp_version version,
                                      unsigned int instructions_len,
                                      struct ofpbuf *ofpacts)
 {
@@ -1160,7 +1216,18 @@ ofpacts_pull_openflow11_instructions(struct ofpbuf *openflow,
 
         get_actions_from_instruction(insts[OVSINST_OFPIT11_APPLY_ACTIONS],
                                      &actions, &n_actions);
-        error = ofpacts_from_openflow11(actions, n_actions, ofpacts);
+        switch (version) {
+        case OFP10_VERSION:
+        case OFP11_VERSION:
+        case OFP12_VERSION:
+            error = ofpacts_from_openflow11(actions, n_actions, ofpacts);
+            break;
+        case OFP13_VERSION:
+            error = ofpacts_from_openflow13(actions, n_actions, ofpacts);
+            break;
+        default:
+            NOT_REACHED();
+        }
         if (error) {
             goto exit;
         }
diff --git a/lib/ofp-actions.h b/lib/ofp-actions.h
index 0876ed7..87764df 100644
--- a/lib/ofp-actions.h
+++ b/lib/ofp-actions.h
@@ -326,12 +326,26 @@ struct ofpact_reg_load {
     union mf_subvalue subvalue; /* Least-significant bits are used. */
 };
 
+/* The position in the packet at which to insert an MPLS header.
+ *
+ * Used NXAST_PUSH_MPLS, OFPAT11_PUSH_MPLS. */
+enum ofpact_mpls_position {
+    /* Add the MPLS LSE after the Ethernet header but before any VLAN tags.
+     * OpenFlow 1.3+ requires this behavior. */
+   OFPACT_MPLS_BEFORE_VLAN,
+
+   /* Add the MPLS LSE after the Ethernet header and any VLAN tags.
+    * OpenFlow 1.1 and 1.2 require this behavior. */
+   OFPACT_MPLS_AFTER_VLAN
+};
+
 /* OFPACT_PUSH_VLAN/MPLS/PBB
  *
  * Used for NXAST_PUSH_MPLS, OFPAT11_PUSH_MPLS. */
 struct ofpact_push_mpls {
     struct ofpact ofpact;
     ovs_be16 ethertype;
+    enum ofpact_mpls_position position;
 };
 
 /* OFPACT_POP_MPLS
@@ -504,9 +518,11 @@ enum ofperr ofpacts_pull_openflow10(struct ofpbuf *openflow,
                                     unsigned int actions_len,
                                     struct ofpbuf *ofpacts);
 enum ofperr ofpacts_pull_openflow11_actions(struct ofpbuf *openflow,
+                                            enum ofp_version version,
                                             unsigned int actions_len,
                                             struct ofpbuf *ofpacts);
 enum ofperr ofpacts_pull_openflow11_instructions(struct ofpbuf *openflow,
+                                                 enum ofp_version version,
                                                  unsigned int instructions_len,
                                                  struct ofpbuf *ofpacts);
 enum ofperr ofpacts_check(const struct ofpact[], size_t ofpacts_len,
diff --git a/lib/ofp-print.c b/lib/ofp-print.c
index 6fe1cee..a0615b5 100644
--- a/lib/ofp-print.c
+++ b/lib/ofp-print.c
@@ -2224,7 +2224,7 @@ ofp_print_group_desc(struct ds *s, const struct ofp_header *oh)
         struct ofputil_group_desc gd;
         int retval;
 
-        retval = ofputil_decode_group_desc_reply(&gd, &b);
+        retval = ofputil_decode_group_desc_reply(&gd, &b, oh->version);
         if (retval) {
             if (retval != EOF) {
                 ds_put_cstr(s, " ***parse error***");
diff --git a/lib/ofp-util.c b/lib/ofp-util.c
index 173b534..570447a 100644
--- a/lib/ofp-util.c
+++ b/lib/ofp-util.c
@@ -1504,7 +1504,8 @@ ofputil_decode_flow_mod(struct ofputil_flow_mod *fm,
             return error;
         }
 
-        error = ofpacts_pull_openflow11_instructions(&b, b.size, ofpacts);
+        error = ofpacts_pull_openflow11_instructions(&b, oh->version,
+                                                     b.size, ofpacts);
         if (error) {
             return error;
         }
@@ -2360,7 +2361,8 @@ ofputil_decode_flow_stats_reply(struct ofputil_flow_stats *fs,
             return EINVAL;
         }
 
-        if (ofpacts_pull_openflow11_instructions(msg, length - sizeof *ofs -
+        if (ofpacts_pull_openflow11_instructions(msg, oh->version,
+                                                 length - sizeof *ofs -
                                                  padded_match_len, ofpacts)) {
             VLOG_WARN_RL(&bad_ofmsg_rl, "OFPST_FLOW reply bad instructions");
             return EINVAL;
@@ -3092,7 +3094,8 @@ ofputil_decode_packet_out(struct ofputil_packet_out *po,
             return error;
         }
 
-        error = ofpacts_pull_openflow11_actions(&b, ntohs(opo->actions_len),
+        error = ofpacts_pull_openflow11_actions(&b, oh->version,
+                                                ntohs(opo->actions_len),
                                                 ofpacts);
         if (error) {
             return error;
@@ -5674,8 +5677,8 @@ ofputil_append_group_desc_reply(const struct ofputil_group_desc *gds,
 }
 
 static enum ofperr
-ofputil_pull_buckets(struct ofpbuf *msg, size_t buckets_length,
-                     struct list *buckets)
+ofputil_pull_buckets(struct ofpbuf *msg, enum ofp_version version,
+                     size_t buckets_length, struct list *buckets)
 {
     struct ofp11_bucket *ob;
 
@@ -5708,8 +5711,8 @@ ofputil_pull_buckets(struct ofpbuf *msg, size_t buckets_length,
         buckets_length -= ob_len;
 
         ofpbuf_init(&ofpacts, 0);
-        error = ofpacts_pull_openflow11_actions(msg, ob_len - sizeof *ob,
-                                                &ofpacts);
+        error = ofpacts_pull_openflow11_actions(msg, version,
+                                                ob_len - sizeof *ob, &ofpacts);
         if (error) {
             ofpbuf_uninit(&ofpacts);
             ofputil_bucket_list_destroy(buckets);
@@ -5745,7 +5748,7 @@ ofputil_pull_buckets(struct ofpbuf *msg, size_t buckets_length,
  * otherwise a positive errno value. */
 int
 ofputil_decode_group_desc_reply(struct ofputil_group_desc *gd,
-                                struct ofpbuf *msg)
+                                struct ofpbuf *msg, enum ofp_version version)
 {
     struct ofp11_group_desc_stats *ogds;
     size_t length;
@@ -5774,7 +5777,8 @@ ofputil_decode_group_desc_reply(struct ofputil_group_desc *gd,
         return OFPERR_OFPBRC_BAD_LEN;
     }
 
-    return ofputil_pull_buckets(msg, length - sizeof *ogds, &gd->buckets);
+    return ofputil_pull_buckets(msg, version, length - sizeof *ogds,
+                                &gd->buckets);
 }
 
 /* Converts abstract group mod 'gm' into a message for OpenFlow version
@@ -5857,7 +5861,7 @@ ofputil_decode_group_mod(const struct ofp_header *oh,
     gm->type = ogm->type;
     gm->group_id = ntohl(ogm->group_id);
 
-    return ofputil_pull_buckets(&msg, msg.size, &gm->buckets);
+    return ofputil_pull_buckets(&msg, oh->version, msg.size, &gm->buckets);
 }
 
 /* Parse a queue status request message into 'oqsr'.
diff --git a/lib/ofp-util.h b/lib/ofp-util.h
index d5f34d7..5fa8fee 100644
--- a/lib/ofp-util.h
+++ b/lib/ofp-util.h
@@ -973,7 +973,7 @@ int ofputil_decode_group_stats_reply(struct ofpbuf *,
                                      struct ofputil_group_stats *);
 
 int ofputil_decode_group_desc_reply(struct ofputil_group_desc *,
-                                    struct ofpbuf *);
+                                    struct ofpbuf *, enum ofp_version);
 
 void ofputil_append_group_desc_reply(const struct ofputil_group_desc *,
                                      struct list *buckets,
diff --git a/utilities/ovs-ofctl.c b/utilities/ovs-ofctl.c
index c2cc1f6..00d35aa 100644
--- a/utilities/ovs-ofctl.c
+++ b/utilities/ovs-ofctl.c
@@ -2968,8 +2968,8 @@ ofctl_parse_ofp11_actions(int argc OVS_UNUSED, char *argv[] OVS_UNUSED)
         /* Convert to ofpacts. */
         ofpbuf_init(&ofpacts, 0);
         size = of11_in.size;
-        error = ofpacts_pull_openflow11_actions(&of11_in, of11_in.size,
-                                                &ofpacts);
+        error = ofpacts_pull_openflow11_actions(&of11_in, OFP11_VERSION,
+                                                of11_in.size, &ofpacts);
         if (error) {
             printf("bad OF1.1 actions: %s\n\n", ofperr_get_name(error));
             ofpbuf_uninit(&ofpacts);
@@ -3036,8 +3036,8 @@ ofctl_parse_ofp11_instructions(int argc OVS_UNUSED, char *argv[] OVS_UNUSED)
         /* Convert to ofpacts. */
         ofpbuf_init(&ofpacts, 0);
         size = of11_in.size;
-        error = ofpacts_pull_openflow11_instructions(&of11_in, of11_in.size,
-                                                     &ofpacts);
+        error = ofpacts_pull_openflow11_instructions(&of11_in, OFP11_VERSION,
+                                                     of11_in.size, &ofpacts);
         if (!error) {
             /* Verify actions. */
             struct flow flow;
-- 
1.8.4
