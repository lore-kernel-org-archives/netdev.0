From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 1/2] Remove bogus error message when changing
 offload settings on older kernels
Date: Mon, 16 Jul 2012 23:18:39 +0100
Message-ID: <1342477119.2523.41.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342477041.2523.40.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:52401 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752540Ab2GPWSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jul 2012 18:18:42 -0400
In-Reply-To: <1342477041.2523.40.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should not be checking for fixed features when we have no
information about which are fixed.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c |   60 +++++++++++++++++++++++++++++++++---------------------------
 1 files changed, 33 insertions(+), 27 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 3c34273..b424756 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1962,39 +1962,45 @@ static int do_sfeatures(struct cmd_context *ctx)
 	if (!old_state)
 		return 1;
 
-	/* For each offload that the user specified, update any
-	 * related features that the user did not specify and that
-	 * are not fixed.  Warn if all related features are fixed.
-	 */
-	for (i = 0; i < ARRAY_SIZE(off_flag_def); i++) {
-		int fixed = 1;
-
-		if (!(off_flags_mask & off_flag_def[i].value))
-			continue;
+	if (efeatures) {
+		/* For each offload that the user specified, update any
+		 * related features that the user did not specify and that
+		 * are not fixed.  Warn if all related features are fixed.
+		 */
+		for (i = 0; i < ARRAY_SIZE(off_flag_def); i++) {
+			int fixed = 1;
 
-		for (j = 0; j < defs->n_features; j++) {
-			if (defs->def[j].off_flag_index != i ||
-			    !FEATURE_BIT_IS_SET(old_state->features.features,
-						j, available) ||
-			    FEATURE_BIT_IS_SET(old_state->features.features,
-					       j, never_changed))
+			if (!(off_flags_mask & off_flag_def[i].value))
 				continue;
 
-			fixed = 0;
-			if (!FEATURE_BIT_IS_SET(efeatures->features, j, valid)) {
-				FEATURE_BIT_SET(efeatures->features, j, valid);
-				if (off_flags_wanted & off_flag_def[i].value)
-					FEATURE_BIT_SET(efeatures->features, j,
-							requested);
+			for (j = 0; j < defs->n_features; j++) {
+				if (defs->def[j].off_flag_index != i ||
+				    !FEATURE_BIT_IS_SET(
+					    old_state->features.features,
+					    j, available) ||
+				    FEATURE_BIT_IS_SET(
+					    old_state->features.features,
+					    j, never_changed))
+					continue;
+
+				fixed = 0;
+				if (!FEATURE_BIT_IS_SET(efeatures->features,
+							j, valid)) {
+					FEATURE_BIT_SET(efeatures->features,
+							j, valid);
+					if (off_flags_wanted &
+					    off_flag_def[i].value)
+						FEATURE_BIT_SET(
+							efeatures->features,
+							j, requested);
+				}
 			}
-		}
 
-		if (fixed)
-			fprintf(stderr, "Cannot change %s\n",
-				off_flag_def[i].long_name);
-	}
+			if (fixed)
+				fprintf(stderr, "Cannot change %s\n",
+					off_flag_def[i].long_name);
+		}
 
-	if (efeatures) {
 		err = send_ioctl(ctx, efeatures);
 		if (err < 0) {
 			perror("Cannot set device feature settings");
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
