From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 2/2] ethtool: Allow driver to select RX NFC rule
 location
Date: Sat, 17 Dec 2011 01:29:12 +0000
Message-ID: <1324085352.2798.49.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Dimitrios Michailidis <dm@chelsio.com>,
	Vladislav Zolotarov <vladz@broadcom.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:55874 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752745Ab1LQB3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 20:29:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the user does not specify a location for an RX NFC rule to be
added, pass in a location of RX_CLS_FLOW_LOC_ANY.  This will only be
supported by some drivers, so if the driver returns EINVAL then use
the rule manager functions to select a location as we have done
previously.

Remove use of RX_CLS_LOC_UNSPEC and allow for later generalisation to
other special rule locations.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 ethtool.c  |    2 +-
 internal.h |    2 --
 rxclass.c  |   29 +++++++++++++++--------------
 3 files changed, 16 insertions(+), 17 deletions(-)

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
index 1980d0e..f0794ed 100644
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
 
@@ -461,24 +458,28 @@ int rxclass_rule_ins(struct cmd_context *ctx,
 	__u32 loc = fsp->location;
 	int err;
 
+	/* notify netdev of new rule */
+	nfccmd.cmd = ETHTOOL_SRXCLSRLINS;
+	nfccmd.fs = *fsp;
+	err = send_ioctl(ctx, &nfccmd);
+
 	/*
-	 * if location is unspecified pull rules from device
-	 * and allocate a free rule for our use
+	 * If location is 'special' and not supported, pull rules from
+	 * device and allocate a free rule for our use, then try
+	 * again.
 	 */
-	if (loc == RX_CLS_LOC_UNSPEC) {
+	if (err < 0 && errno == EINVAL && (loc & RX_CLS_LOC_SPECIAL)) {
 		err = rmgr_set_location(ctx, fsp);
 		if (err < 0)
 			return err;
+		nfccmd.fs = *fsp;
+		err = send_ioctl(ctx, &nfccmd);
 	}
 
-	/* notify netdev of new rule */
-	nfccmd.cmd = ETHTOOL_SRXCLSRLINS;
-	nfccmd.fs = *fsp;
-	err = send_ioctl(ctx, &nfccmd);
 	if (err < 0)
 		perror("rmgr: Cannot insert RX class rule");
-	else if (loc == RX_CLS_LOC_UNSPEC)
-		printf("Added rule with ID %d\n", fsp->location);
+	else if (loc & RX_CLS_LOC_SPECIAL)
+		printf("Added rule with ID %d\n", nfccmd.fs.location);
 
 	return 0;
 }
@@ -998,7 +999,7 @@ int rxclass_parse_ruleopts(struct cmd_context *ctx,
 
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
