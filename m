From: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
Subject: [PATCH v2.40 3/7] ofp-actions: Add
	OFPUTIL_OFPAT13_PUSH_MPLS
Date: Fri, 27 Sep 2013 09:18:32 +0900
Message-ID: <1380241116-7661-4-git-send-email-horms@verge.net.au>
References: <1380241116-7661-1-git-send-email-horms@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Isaku Yamahata <yamahata-jCdQPDEk3idL9jVzuh4AOg@public.gmane.org>, Ravi K <rkerur-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jesse Gross <jesse-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>, Ben Pfaff <blp-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1380241116-7661-1-git-send-email-horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>
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

This patch adds a new compatibility enum for use with MPLS, so that the
differing behaviour between OpenFlow 1.2 and 1.3 can be implemented in
ofproto-dpif-xlate.

Signed-off-by: Joe Stringer <joe-Q1GJJQv1iO6lP80pJB477g@public.gmane.org>
Signed-off-by: Simon Horman <horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org>

---

v2.36 - v2.39
* No change

v2.35
* First post
---
 lib/ofp-actions.c | 5 ++++-
 lib/ofp-parse.c   | 1 +
 lib/ofp-util.c    | 3 +++
 lib/ofp-util.h    | 1 +
 4 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/lib/ofp-actions.c b/lib/ofp-actions.c
index dcc82db..6d33711 100644
--- a/lib/ofp-actions.c
+++ b/lib/ofp-actions.c
@@ -322,6 +322,7 @@ ofpact_from_nxast(const union ofp_action *a, enum ofputil_action_code code,
 #define OFPAT10_ACTION(ENUM, STRUCT, NAME) case OFPUTIL_##ENUM:
 #define OFPAT11_ACTION(ENUM, STRUCT, EXTENSIBLE, NAME) case OFPUTIL_##ENUM:
 #include "ofp-util.def"
+    case OFPUTIL_OFPAT13_PUSH_MPLS:
         NOT_REACHED();
 
     case OFPUTIL_NXAST_RESUBMIT:
@@ -480,6 +481,7 @@ ofpact_from_openflow10(const union ofp_action *a, struct ofpbuf *out)
     case OFPUTIL_ACTION_INVALID:
 #define OFPAT11_ACTION(ENUM, STRUCT, EXTENSIBLE, NAME) case OFPUTIL_##ENUM:
 #include "ofp-util.def"
+    case OFPUTIL_OFPAT13_PUSH_MPLS:
         NOT_REACHED();
 
     case OFPUTIL_OFPAT10_OUTPUT:
@@ -842,7 +844,8 @@ ofpact_from_openflow11(const union ofp_action *a, struct ofpbuf *out)
         ofpact_put_DEC_MPLS_TTL(out);
         break;
 
-    case OFPUTIL_OFPAT11_PUSH_MPLS: {
+    case OFPUTIL_OFPAT11_PUSH_MPLS:
+    case OFPUTIL_OFPAT13_PUSH_MPLS: {
         struct ofp11_action_push *oap = (struct ofp11_action_push *)a;
         if (!eth_type_mpls(oap->ethertype)) {
             return OFPERR_OFPBAC_BAD_ARGUMENT;
diff --git a/lib/ofp-parse.c b/lib/ofp-parse.c
index 522bd95..85eff4d 100644
--- a/lib/ofp-parse.c
+++ b/lib/ofp-parse.c
@@ -804,6 +804,7 @@ parse_named_action(enum ofputil_action_code code,
         break;
 
     case OFPUTIL_OFPAT11_PUSH_MPLS:
+    case OFPUTIL_OFPAT13_PUSH_MPLS:
     case OFPUTIL_NXAST_PUSH_MPLS:
         error = str_to_u16(arg, "push_mpls", &ethertype);
         if (!error) {
diff --git a/lib/ofp-util.c b/lib/ofp-util.c
index 173b534..c9a2731 100644
--- a/lib/ofp-util.c
+++ b/lib/ofp-util.c
@@ -4777,6 +4777,9 @@ ofputil_put_action(enum ofputil_action_code code, struct ofpbuf *buf)
     case OFPUTIL_ACTION_INVALID:
         NOT_REACHED();
 
+    case OFPUTIL_OFPAT13_PUSH_MPLS:
+        return ofputil_put_OFPAT11_PUSH_MPLS(buf);
+
 #define OFPAT10_ACTION(ENUM, STRUCT, NAME)                  \
     case OFPUTIL_##ENUM: return ofputil_put_##ENUM(buf);
 #define OFPAT11_ACTION(ENUM, STRUCT, EXTENSIBLE, NAME)      \
diff --git a/lib/ofp-util.h b/lib/ofp-util.h
index d5f34d7..51e8f7e 100644
--- a/lib/ofp-util.h
+++ b/lib/ofp-util.h
@@ -795,6 +795,7 @@ enum OVS_PACKED_ENUM ofputil_action_code {
 #define OFPAT11_ACTION(ENUM, STRUCT, EXTENSIBLE, NAME) OFPUTIL_##ENUM,
 #define NXAST_ACTION(ENUM, STRUCT, EXTENSIBLE, NAME)   OFPUTIL_##ENUM,
 #include "ofp-util.def"
+    OFPUTIL_OFPAT13_PUSH_MPLS
 };
 
 /* The number of values of "enum ofputil_action_code". */
-- 
1.8.4
