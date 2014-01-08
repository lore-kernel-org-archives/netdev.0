From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool] ethtool: Accept long feature names reported by -k
 option as input to -K option
Date: Wed, 8 Jan 2014 21:52:11 +0000
Message-ID: <1389217931.1644.44.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Or Gerlitz <or.gerlitz@gmail.com>,
	Bill Fink <billfink@mindspring.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:64643 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751668AbaAHVwQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 16:52:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before the generic features API was introduced, the ethtool -K option
took short names for various features, e.g. 'gso' but the -k option
reported their state using longer names,
e.g. 'generic-segmentation-offload'.

All newer features have a single kernel-provided name so input
and output are consistent.  But the old features still aren't, and
although their short names are documented it's not good to have
these exceptions.

Change the argument parsing code for -K so that the long names
reported by -k are also accepted.

Reported-by: Or Gerlitz <or.gerlitz@gmail.com>
Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
This turned out to be pretty easy to do as the argument processing is
all table-driven already.  I'll push this if it works for you.

Ben.

 ethtool.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index b06dfa3..4226d2e 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -2053,25 +2053,31 @@ static int do_sfeatures(struct cmd_context *ctx)
 	/* Generate cmdline_info for legacy flags and kernel-named
 	 * features, and parse our arguments.
 	 */
-	cmdline_features = calloc(ARRAY_SIZE(off_flag_def) + defs->n_features,
+	cmdline_features = calloc(2 * ARRAY_SIZE(off_flag_def) +
+				  defs->n_features,
 				  sizeof(cmdline_features[0]));
 	if (!cmdline_features) {
 		perror("Cannot parse arguments");
 		return 1;
 	}
-	for (i = 0; i < ARRAY_SIZE(off_flag_def); i++)
+	for (i = 0; i < ARRAY_SIZE(off_flag_def); i++) {
 		flag_to_cmdline_info(off_flag_def[i].short_name,
 				     off_flag_def[i].value,
 				     &off_flags_wanted, &off_flags_mask,
-				     &cmdline_features[i]);
+				     &cmdline_features[2 * i]);
+		flag_to_cmdline_info(off_flag_def[i].long_name,
+				     off_flag_def[i].value,
+				     &off_flags_wanted, &off_flags_mask,
+				     &cmdline_features[2 * i] + 1);
+	}
 	for (i = 0; i < defs->n_features; i++)
 		flag_to_cmdline_info(
 			defs->def[i].name, FEATURE_FIELD_FLAG(i),
 			&FEATURE_WORD(efeatures->features, i, requested),
 			&FEATURE_WORD(efeatures->features, i, valid),
-			&cmdline_features[ARRAY_SIZE(off_flag_def) + i]);
+			&cmdline_features[2 * ARRAY_SIZE(off_flag_def) + i]);
 	parse_generic_cmdline(ctx, &any_changed, cmdline_features,
-			      ARRAY_SIZE(off_flag_def) + defs->n_features);
+			      2 * ARRAY_SIZE(off_flag_def) + defs->n_features);
 	free(cmdline_features);
 
 	if (!any_changed) {

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
