From: Simon Horman <horms@verge.net.au>
Subject: [PATCH v2.35 3/6] ofp-actions: Add OFPUTIL_OFPAT13_PUSH_MPLS
Date: Sat, 20 Jul 2013 12:07:00 +0900
Message-ID: <1374289623-17056-4-git-send-email-horms@verge.net.au>
References: <1374289623-17056-1-git-send-email-horms@verge.net.au>
Cc: Ravi K <rkerur@gmail.com>, Isaku Yamahata <yamahata@valinux.co.jp>,
	Jesse Gross <jesse@nicira.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	jarno.rajahalme@nsn.com, Joe Stringer <joe@wand.net.nz>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:38077 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753544Ab3GTDGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 23:06:48 -0400
In-Reply-To: <1374289623-17056-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joe@wand.net.nz>

This patch adds a new compatibility enum for use with MPLS, so that the
differing behaviour between OpenFlow 1.2 and 1.3 can be implemented in
ofproto-dpif-xlate.

Signed-off-by: Joe Stringer <joe@wand.net.nz>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 lib/ofp-actions.c |    5 ++++-
 lib/ofp-parse.c   |    1 +
 lib/ofp-util.c    |    3 +++
 lib/ofp-util.h    |    1 +
 4 files changed, 9 insertions(+), 1 deletion(-)

diff --git a/lib/ofp-actions.c b/lib/ofp-actions.c
index 899928a..3e8b646 100644
--- a/lib/ofp-actions.c
+++ b/lib/ofp-actions.c
@@ -322,6 +322,7 @@ ofpact_from_nxast(const union ofp_action *a, enum ofputil_action_code code,
 #define OFPAT10_ACTION(ENUM, STRUCT, NAME) case OFPUTIL_##ENUM:
 #define OFPAT11_ACTION(ENUM, STRUCT, EXTENSIBLE, NAME) case OFPUTIL_##ENUM:
 #include "ofp-util.def"
+    case OFPUTIL_OFPAT13_PUSH_MPLS:
         NOT_REACHED();
 
     case OFPUTIL_NXAST_RESUBMIT:
@@ -479,6 +480,7 @@ ofpact_from_openflow10(const union ofp_action *a, struct ofpbuf *out)
     case OFPUTIL_ACTION_INVALID:
 #define OFPAT11_ACTION(ENUM, STRUCT, EXTENSIBLE, NAME) case OFPUTIL_##ENUM:
 #include "ofp-util.def"
+    case OFPUTIL_OFPAT13_PUSH_MPLS:
         NOT_REACHED();
 
     case OFPUTIL_OFPAT10_OUTPUT:
@@ -841,7 +843,8 @@ ofpact_from_openflow11(const union ofp_action *a, struct ofpbuf *out)
         ofpact_put_DEC_MPLS_TTL(out);
         break;
 
-    case OFPUTIL_OFPAT11_PUSH_MPLS: {
+    case OFPUTIL_OFPAT11_PUSH_MPLS:
+    case OFPUTIL_OFPAT13_PUSH_MPLS: {
         struct ofp11_action_push *oap = (struct ofp11_action_push *)a;
         if (!eth_type_mpls(oap->ethertype)) {
             return OFPERR_OFPBAC_BAD_ARGUMENT;
diff --git a/lib/ofp-parse.c b/lib/ofp-parse.c
index 618290b..c844b30 100644
--- a/lib/ofp-parse.c
+++ b/lib/ofp-parse.c
@@ -798,6 +798,7 @@ parse_named_action(enum ofputil_action_code code,
         break;
 
     case OFPUTIL_OFPAT11_PUSH_MPLS:
+    case OFPUTIL_OFPAT13_PUSH_MPLS:
     case OFPUTIL_NXAST_PUSH_MPLS:
         error = str_to_u16(arg, "push_mpls", &ethertype);
         if (!error) {
diff --git a/lib/ofp-util.c b/lib/ofp-util.c
index bc85797..a21658c 100644
--- a/lib/ofp-util.c
+++ b/lib/ofp-util.c
@@ -4752,6 +4752,9 @@ ofputil_put_action(enum ofputil_action_code code, struct ofpbuf *buf)
     case OFPUTIL_ACTION_INVALID:
         NOT_REACHED();
 
+    case OFPUTIL_OFPAT13_PUSH_MPLS:
+        return ofputil_put_OFPAT11_PUSH_MPLS(buf);
+
 #define OFPAT10_ACTION(ENUM, STRUCT, NAME)                  \
     case OFPUTIL_##ENUM: return ofputil_put_##ENUM(buf);
 #define OFPAT11_ACTION(ENUM, STRUCT, EXTENSIBLE, NAME)      \
diff --git a/lib/ofp-util.h b/lib/ofp-util.h
index 0385a57..cf55a5d 100644
--- a/lib/ofp-util.h
+++ b/lib/ofp-util.h
@@ -747,6 +747,7 @@ enum OVS_PACKED_ENUM ofputil_action_code {
 #define OFPAT11_ACTION(ENUM, STRUCT, EXTENSIBLE, NAME) OFPUTIL_##ENUM,
 #define NXAST_ACTION(ENUM, STRUCT, EXTENSIBLE, NAME)   OFPUTIL_##ENUM,
 #include "ofp-util.def"
+    OFPUTIL_OFPAT13_PUSH_MPLS
 };
 
 /* The number of values of "enum ofputil_action_code". */
-- 
1.7.10.4
