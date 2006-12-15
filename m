From: paul.moore@hp.com
Subject: [PATCH 1/2] NetLabel: perform input validation earlier on CIPSOv4 DOI add ops
Date: Fri, 15 Dec 2006 16:49:27 -0500
Message-ID: <20061215215229.014743000@hp.com>
References: <20061215214926.018950000@hp.com>
Cc: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:45350 "EHLO atlrel8.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965240AbWLOWDy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 17:03:54 -0500
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-cipso_input_fix
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Moore <paul.moore@hp.com>

There are a couple of cases where the user input for a CIPSOv4 DOI add
operation was not being done soon enough; the result was unexpected behavior
which was resulting in oops/panics/lockups on some platforms.  This patch moves
the existing input validation code earlier in the code path to protect against
bogus user input.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 net/netlabel/netlabel_cipso_v4.c |   28 +++++++++++++++++-----------
 1 files changed, 17 insertions(+), 11 deletions(-)

Index: net-2.6.20_bugfix/net/netlabel/netlabel_cipso_v4.c
===================================================================
--- net-2.6.20_bugfix.orig/net/netlabel/netlabel_cipso_v4.c
+++ net-2.6.20_bugfix/net/netlabel/netlabel_cipso_v4.c
@@ -185,20 +185,31 @@ static int netlbl_cipsov4_add_std(struct
 	ret_val = netlbl_cipsov4_add_common(info, doi_def);
 	if (ret_val != 0)
 		goto add_std_failure;
+	ret_val = -EINVAL;
 
 	nla_for_each_nested(nla_a,
 			    info->attrs[NLBL_CIPSOV4_A_MLSLVLLST],
 			    nla_a_rem)
 		if (nla_a->nla_type == NLBL_CIPSOV4_A_MLSLVL) {
+			if (nla_validate_nested(nla_a,
+					    NLBL_CIPSOV4_A_MAX,
+					    netlbl_cipsov4_genl_policy) != 0)
+					goto add_std_failure;
 			nla_for_each_nested(nla_b, nla_a, nla_b_rem)
 				switch (nla_b->nla_type) {
 				case NLBL_CIPSOV4_A_MLSLVLLOC:
+					if (nla_get_u32(nla_b) >
+					    CIPSO_V4_MAX_LOC_LVLS)
+						goto add_std_failure;
 					if (nla_get_u32(nla_b) >=
 					    doi_def->map.std->lvl.local_size)
 					     doi_def->map.std->lvl.local_size =
 						     nla_get_u32(nla_b) + 1;
 					break;
 				case NLBL_CIPSOV4_A_MLSLVLREM:
+					if (nla_get_u32(nla_b) >
+					    CIPSO_V4_MAX_REM_LVLS)
+						goto add_std_failure;
 					if (nla_get_u32(nla_b) >=
 					    doi_def->map.std->lvl.cipso_size)
 					     doi_def->map.std->lvl.cipso_size =
@@ -206,9 +217,6 @@ static int netlbl_cipsov4_add_std(struct
 					break;
 				}
 		}
-	if (doi_def->map.std->lvl.local_size > CIPSO_V4_MAX_LOC_LVLS ||
-	    doi_def->map.std->lvl.cipso_size > CIPSO_V4_MAX_REM_LVLS)
-		goto add_std_failure;
 	doi_def->map.std->lvl.local = kcalloc(doi_def->map.std->lvl.local_size,
 					      sizeof(u32),
 					      GFP_KERNEL);
@@ -230,11 +238,6 @@ static int netlbl_cipsov4_add_std(struct
 			struct nlattr *lvl_loc;
 			struct nlattr *lvl_rem;
 
-			if (nla_validate_nested(nla_a,
-					      NLBL_CIPSOV4_A_MAX,
-					      netlbl_cipsov4_genl_policy) != 0)
-				goto add_std_failure;
-
 			lvl_loc = nla_find_nested(nla_a,
 						  NLBL_CIPSOV4_A_MLSLVLLOC);
 			lvl_rem = nla_find_nested(nla_a,
@@ -264,12 +267,18 @@ static int netlbl_cipsov4_add_std(struct
 				nla_for_each_nested(nla_b, nla_a, nla_b_rem)
 					switch (nla_b->nla_type) {
 					case NLBL_CIPSOV4_A_MLSCATLOC:
+						if (nla_get_u32(nla_b) >
+						    CIPSO_V4_MAX_LOC_CATS)
+							goto add_std_failure;
 						if (nla_get_u32(nla_b) >=
 					      doi_def->map.std->cat.local_size)
 					     doi_def->map.std->cat.local_size =
 						     nla_get_u32(nla_b) + 1;
 						break;
 					case NLBL_CIPSOV4_A_MLSCATREM:
+						if (nla_get_u32(nla_b) >
+						    CIPSO_V4_MAX_REM_CATS)
+							goto add_std_failure;
 						if (nla_get_u32(nla_b) >=
 					      doi_def->map.std->cat.cipso_size)
 					     doi_def->map.std->cat.cipso_size =
@@ -277,9 +286,6 @@ static int netlbl_cipsov4_add_std(struct
 						break;
 					}
 			}
-		if (doi_def->map.std->cat.local_size > CIPSO_V4_MAX_LOC_CATS ||
-		    doi_def->map.std->cat.cipso_size > CIPSO_V4_MAX_REM_CATS)
-			goto add_std_failure;
 		doi_def->map.std->cat.local = kcalloc(
 			                      doi_def->map.std->cat.local_size,
 					      sizeof(u32),

--
paul moore
linux security @ hp
