From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCHv2 ethtool 2/3] rxclass: Use RX_CLS_LOC_{ANY,SPECIAL} in
 place of RX_CLS_LOC_UNSPEC
Date: Tue, 3 Jan 2012 22:24:42 +0000
Message-ID: <1325629482.2832.47.camel@bwh-desktop>
References: <1325627819.2832.31.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:21483 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751717Ab2ACWYp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 17:24:45 -0500
In-Reply-To: <1325627819.2832.31.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macro RX_CLS_LOC_ANY is now defined in ethtool(-copy).h with the
same intended semantics and same value as RX_CLS_LOC_UNSPEC.

Change some equality tests to check for the flag RX_CLS_LOC_SPECIAL,
to allow for future support of other special location value.

Remove the special case for RX_CLS_LOC_UNSPEC in
rxclass_print_nfc_rule(), since it is dead code.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c  |    2 +-
 internal.h |    2 --
 rxclass.c  |   11 ++++-------
 3 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index d21eaea..d0cc7d4 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -2719,7 +2719,7 @@ static int flow_spec_to_ntuple(struct ethtool_rx_flow_spec *fsp,
 	size_t i;
 
 	/* verify location is not specified */
-	if (fsp->location != RX_CLS_LOC_UNSPEC)
+	if (fsp->location != RX_CLS_LOC_ANY)
 		return -1;
 
 	/* verify ring cookie can transfer to action */
diff --git a/internal.h b/internal.h
index cb126b3..867c0ea 100644
--- a/internal.h
+++ b/internal.h
@@ -86,8 +86,6 @@ static inline int test_bit(unsigned int nr, const unsigned long *addr)
 #define SIOCETHTOOL     0x8946
 #endif
 
-#define	RX_CLS_LOC_UNSPEC	0xffffffffUL
-
 /* Context for sub-commands */
 struct cmd_context {
 	const char *devname;	/* net device name */
diff --git a/rxclass.c b/rxclass.c
index 1980d0e..9c7456f 100644
--- a/rxclass.c
+++ b/rxclass.c
@@ -68,10 +68,7 @@ static void rxclass_print_nfc_rule(struct ethtool_rx_flow_spec *fsp)
 	unsigned char	*smac, *smacm, *dmac, *dmacm;
 	__u32		flow_type;
 
-	if (fsp->location != RX_CLS_LOC_UNSPEC)
-		fprintf(stdout,	"Filter: %d\n", fsp->location);
-	else
-		fprintf(stdout,	"Filter: Unspecified\n");
+	fprintf(stdout,	"Filter: %d\n", fsp->location);
 
 	flow_type = fsp->flow_type & ~FLOW_EXT;
 
@@ -465,7 +462,7 @@ int rxclass_rule_ins(struct cmd_context *ctx,
 	 * if location is unspecified pull rules from device
 	 * and allocate a free rule for our use
 	 */
-	if (loc == RX_CLS_LOC_UNSPEC) {
+	if (loc & RX_CLS_LOC_SPECIAL) {
 		err = rmgr_set_location(ctx, fsp);
 		if (err < 0)
 			return err;
@@ -477,7 +474,7 @@ int rxclass_rule_ins(struct cmd_context *ctx,
 	err = send_ioctl(ctx, &nfccmd);
 	if (err < 0)
 		perror("rmgr: Cannot insert RX class rule");
-	else if (loc == RX_CLS_LOC_UNSPEC)
+	else if (loc & RX_CLS_LOC_SPECIAL)
 		printf("Added rule with ID %d\n", fsp->location);
 
 	return 0;
@@ -998,7 +995,7 @@ int rxclass_parse_ruleopts(struct cmd_context *ctx,
 
 	memset(p, 0, sizeof(*fsp));
 	fsp->flow_type = flow_type;
-	fsp->location = RX_CLS_LOC_UNSPEC;
+	fsp->location = RX_CLS_LOC_ANY;
 
 	for (i = 1; i < argc;) {
 		const struct rule_opts *opt;
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
