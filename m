From: Simon Horman <horms@verge.net.au>
Subject: [PATCH v2.37 3/6] ofp-actions: Add OFPUTIL_OFPAT13_PUSH_MPLS
Date: Tue, 20 Aug 2013 12:16:01 +1000
Message-ID: <1376964964-18151-4-git-send-email-horms@verge.net.au>
References: <1376964964-18151-1-git-send-email-horms@verge.net.au>
Cc: Ravi K <rkerur@gmail.com>, Isaku Yamahata <yamahata@valinux.co.jp>,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Joe Stringer <joe@wand.net.nz>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:54735 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751523Ab3HTCOj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Aug 2013 22:14:39 -0400
In-Reply-To: <1376964964-18151-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joe@wand.net.nz>

This patch adds a new compatibility enum for use with MPLS, so that the
differing behaviour between OpenFlow 1.2 and 1.3 can be implemented in
ofproto-dpif-xlate.

Signed-off-by: Joe Stringer <joe@wand.net.nz>
Signed-off-by: Simon Horman <horms@verge.net.au>

---

v2.36 - v2.37
* No change

v2.35
* First post
---
 lib/ofp-actions.c |    5 ++++-
 lib/ofp-parse.c   |    1 +
 lib/ofp-util.c    |    3 +++
 lib/ofp-util.h    |    1 +
 4 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/lib/ofp-actions.c b/lib/ofp-actions.c
index 61e2854..921aa27 100644
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
index 5cb39f5..5e719d3 100644
--- a/lib/ofp-parse.c
+++ b/lib/ofp-parse.c
@@ -799,6 +799,7 @@ parse_named_action(enum ofputil_action_code code,
         break;
 
     case OFPUTIL_OFPAT11_PUSH_MPLS:
+    case OFPUTIL_OFPAT13_PUSH_MPLS:
     case OFPUTIL_NXAST_PUSH_MPLS:
         error = str_to_u16(arg, "push_mpls", &ethertype);
         if (!error) {
diff --git a/lib/ofp-util.c b/lib/ofp-util.c
index 45ff0a1..47d2050 100644
--- a/lib/ofp-util.c
+++ b/lib/ofp-util.c
@@ -4764,6 +4764,9 @@ ofputil_put_action(enum ofputil_action_code code, struct ofpbuf *buf)
     case OFPUTIL_ACTION_INVALID:
         NOT_REACHED();
 
+    case OFPUTIL_OFPAT13_PUSH_MPLS:
+        return ofputil_put_OFPAT11_PUSH_MPLS(buf);
+
 #define OFPAT10_ACTION(ENUM, STRUCT, NAME)                  \
     case OFPUTIL_##ENUM: return ofputil_put_##ENUM(buf);
 #define OFPAT11_ACTION(ENUM, STRUCT, EXTENSIBLE, NAME)      \
diff --git a/lib/ofp-util.h b/lib/ofp-util.h
index f3348c0..b5f3506 100644
--- a/lib/ofp-util.h
+++ b/lib/ofp-util.h
@@ -751,6 +751,7 @@ enum OVS_PACKED_ENUM ofputil_action_code {
 #define OFPAT11_ACTION(ENUM, STRUCT, EXTENSIBLE, NAME) OFPUTIL_##ENUM,
 #define NXAST_ACTION(ENUM, STRUCT, EXTENSIBLE, NAME)   OFPUTIL_##ENUM,
 #include "ofp-util.def"
+    OFPUTIL_OFPAT13_PUSH_MPLS
 };
 
 /* The number of values of "enum ofputil_action_code". */
-- 
1.7.10.4
