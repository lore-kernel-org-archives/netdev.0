From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: Re: [PATCH v2.40 4/7] ofp-actions: Add separate OpenFlow
 1.3 action parser
Date: Mon, 30 Sep 2013 11:12:49 +0900
Message-ID: <20130930021246.GC4768@verge.net.au>
References: <1380241116-7661-1-git-send-email-horms@verge.net.au>
	<1380241116-7661-5-git-send-email-horms@verge.net.au>
	<20130927194119.GC17506@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Isaku Yamahata <yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>
To: Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130927194119.GC17506-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
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

On Fri, Sep 27, 2013 at 12:41:19PM -0700, Ben Pfaff wrote:
> On Fri, Sep 27, 2013 at 09:18:33AM +0900, Simon Horman wrote:
> > From: Joe Stringer <joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org>
> > 
> > This patch adds new ofpact_from_openflow13() and
> > ofpacts_from_openflow13() functions parallel to the existing ofpact
> > handling code. In the OpenFlow 1.3 version, push_mpls is handled
> > differently, but all other actions are handled by the existing code.
> > 
> > For push_mpls, ofpact_push_mpls.ofpact.compat is set to
> > OFPUTIL_OFPAT13_PUSH_MPLS, which allows correct VLAN+MPLS datapath
> > behaviour to be determined at odp translation time.
> > 
> > Signed-off-by: Joe Stringer <joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org>
> > Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
> 
> I am nervous about this idea of having ofpacts_pull_openflow11_actions()
> and ofpacts_pull_openflow11_instructions() try to figure out what
> version of OpenFlow is involved.  It is a new and somewhat surprising
> requirements that the callers provide not just actions or instructions
> but a complete OpenFlow message.  I see that the callers in ovs-ofctl.c
> don't satisfy this requirement.

Thanks, sorry for overlooking that.

I believe that Joe was worried about this at the time he implemented
this patch but for some reason I was not.

> I think that it would be better to make these functions' callers say
> what version of OpenFlow they are working with.  One could provide a
> helper function like get_version_from_ofpbuf(), which should probably go
> in ofp-util.c, but I would want it to fail (assert-fail or segfault or
> whatever) if there is no L2 header pointer, instead of returning a
> default value (that, in this case anyway, we know must be wrong because
> OF1.0 never contains OF1.1+ actions or instructions).

I have written an incremental patch to implement your suggestion
and it seems that a helper function is not necessary.

For reference the incremental change that I currently have is as follows.
It is a bit noisy but seems clean to me.

diff --git a/lib/ofp-actions.c b/lib/ofp-actions.c
index 0c4a98b..e94f189 100644
--- a/lib/ofp-actions.c
+++ b/lib/ofp-actions.c
@@ -1119,22 +1119,14 @@ get_actions_from_instruction(const struct ofp11_instruction *inst,
     *n_actions = (ntohs(inst->len) - sizeof *inst) / OFP11_INSTRUCTION_ALIGN;
 }
 
-static uint8_t
-get_version_from_ofpbuf(const struct ofpbuf *openflow)
-{
-    if (openflow && openflow->l2) {
-        struct ofp_header *oh = openflow->l2;
-        return oh->version;
-    }
-
-    return OFP10_VERSION;
-}
-
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
@@ -1146,22 +1138,27 @@ get_version_from_ofpbuf(const struct ofpbuf *openflow)
  * valid in a specific context. */
 enum ofperr
 ofpacts_pull_openflow11_actions(struct ofpbuf *openflow,
+                                enum ofp_version version,
                                 unsigned int actions_len,
                                 struct ofpbuf *ofpacts)
 {
-    uint8_t version = get_version_from_ofpbuf(openflow);
-
-    if (version < OFP13_VERSION) {
+    switch (version) {
+    case OFP10_VERSION:
+    case OFP11_VERSION:
+    case OFP12_VERSION:
         return ofpacts_pull_actions(openflow, actions_len, ofpacts,
                                     ofpacts_from_openflow11);
-    } else {
+    case OFP13_VERSION:
         return ofpacts_pull_actions(openflow, actions_len, ofpacts,
                                     ofpacts_from_openflow13);
+    default:
+        NOT_REACHED();
     }
 }
 
 enum ofperr
 ofpacts_pull_openflow11_instructions(struct ofpbuf *openflow,
+                                     enum ofp_version version,
                                      unsigned int instructions_len,
                                      struct ofpbuf *ofpacts)
 {
@@ -1209,7 +1206,6 @@ ofpacts_pull_openflow11_instructions(struct ofpbuf *openflow,
     if (insts[OVSINST_OFPIT11_APPLY_ACTIONS]) {
         const union ofp_action *actions;
         size_t n_actions;
-        uint8_t version = get_version_from_ofpbuf(openflow);
 
         get_actions_from_instruction(insts[OVSINST_OFPIT11_APPLY_ACTIONS],
                                      &actions, &n_actions);
diff --git a/lib/ofp-actions.h b/lib/ofp-actions.h
index 2184489..d67fc3f 100644
--- a/lib/ofp-actions.h
+++ b/lib/ofp-actions.h
@@ -511,9 +511,11 @@ enum ofperr ofpacts_pull_openflow10(struct ofpbuf *openflow,
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
