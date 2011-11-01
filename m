From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH ethtool 18/21] rxclass: Replace global rmgr with automatic
 variable/parameter
Date: Tue, 1 Nov 2011 23:22:00 +0000
Message-ID: <1320189720.2758.49.camel@bwh-desktop>
References: <1320186901.2758.30.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:38675 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754400Ab1KAXWD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2011 19:22:03 -0400
In-Reply-To: <1320186901.2758.30.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 rxclass.c |   78 ++++++++++++++++++++++++++----------------------------------
 1 files changed, 34 insertions(+), 44 deletions(-)

diff --git a/rxclass.c b/rxclass.c
index 0c7b916..3b23a33 100644
--- a/rxclass.c
+++ b/rxclass.c
@@ -299,30 +299,28 @@ struct rmgr_ctrl {
 	__u32			size;
 };
 
-static struct rmgr_ctrl rmgr;
-static int rmgr_init_done = 0;
-
-static int rmgr_ins(__u32 loc)
+static int rmgr_ins(struct rmgr_ctrl *rmgr, __u32 loc)
 {
 	/* verify location is in rule manager range */
-	if (loc >= rmgr.size) {
+	if (loc >= rmgr->size) {
 		fprintf(stderr, "rmgr: Location out of range\n");
 		return -1;
 	}
 
 	/* set bit for the rule */
-	set_bit(loc, rmgr.slot);
+	set_bit(loc, rmgr->slot);
 
 	return 0;
 }
 
-static int rmgr_find_empty_slot(struct ethtool_rx_flow_spec *fsp)
+static int rmgr_find_empty_slot(struct rmgr_ctrl *rmgr,
+				struct ethtool_rx_flow_spec *fsp)
 {
 	__u32 loc;
 	__u32 slot_num;
 
 	/* start at the end of the list since it is lowest priority */
-	loc = rmgr.size - 1;
+	loc = rmgr->size - 1;
 
 	/* locate the first slot a rule can be placed in */
 	slot_num = loc / BITS_PER_LONG;
@@ -333,10 +331,10 @@ static int rmgr_find_empty_slot(struct ethtool_rx_flow_spec *fsp)
 	 * moving 1 + loc % BITS_PER_LONG we align ourselves to the last bit
 	 * in the previous word.
 	 *
-	 * If loc rolls over it should be greater than or equal to rmgr.size
+	 * If loc rolls over it should be greater than or equal to rmgr->size
 	 * and as such we know we have reached the end of the list.
 	 */
-	if (!~(rmgr.slot[slot_num] | (~1UL << rmgr.size % BITS_PER_LONG))) {
+	if (!~(rmgr->slot[slot_num] | (~1UL << rmgr->size % BITS_PER_LONG))) {
 		loc -= 1 + (loc % BITS_PER_LONG);
 		slot_num--;
 	}
@@ -345,7 +343,7 @@ static int rmgr_find_empty_slot(struct ethtool_rx_flow_spec *fsp)
 	 * Now that we are aligned with the last bit in each long we can just
 	 * go though and eliminate all the longs with no free bits
 	 */
-	while (loc < rmgr.size && !~(rmgr.slot[slot_num])) {
+	while (loc < rmgr->size && !~(rmgr->slot[slot_num])) {
 		loc -= BITS_PER_LONG;
 		slot_num--;
 	}
@@ -354,13 +352,13 @@ static int rmgr_find_empty_slot(struct ethtool_rx_flow_spec *fsp)
 	 * If we still are inside the range, test individual bits as one is
 	 * likely available for our use.
 	 */
-	while (loc < rmgr.size && test_bit(loc, rmgr.slot))
+	while (loc < rmgr->size && test_bit(loc, rmgr->slot))
 		loc--;
 
 	/* location found, insert rule */
-	if (loc < rmgr.size) {
+	if (loc < rmgr->size) {
 		fsp->location = loc;
-		return rmgr_ins(loc);
+		return rmgr_ins(rmgr, loc);
 	}
 
 	/* No space to add this rule */
@@ -369,25 +367,22 @@ static int rmgr_find_empty_slot(struct ethtool_rx_flow_spec *fsp)
 	return -1;
 }
 
-static int rmgr_init(struct cmd_context *ctx)
+static int rmgr_init(struct cmd_context *ctx, struct rmgr_ctrl *rmgr)
 {
 	struct ethtool_rxnfc *nfccmd;
 	int err, i;
 	__u32 *rule_locs;
 
-	if (rmgr_init_done)
-		return 0;
-
 	/* clear rule manager settings */
-	memset(&rmgr, 0, sizeof(struct rmgr_ctrl));
+	memset(rmgr, 0, sizeof(*rmgr));
 
-	/* request count and store in rmgr.n_rules */
-	err = rxclass_get_count(ctx, &rmgr.n_rules);
+	/* request count and store in rmgr->n_rules */
+	err = rxclass_get_count(ctx, &rmgr->n_rules);
 	if (err < 0)
 		return err;
 
 	/* alloc memory for request of location list */
-	nfccmd = calloc(1, sizeof(*nfccmd) + (rmgr.n_rules * sizeof(__u32)));
+	nfccmd = calloc(1, sizeof(*nfccmd) + (rmgr->n_rules * sizeof(__u32)));
 	if (!nfccmd) {
 		perror("rmgr: Cannot allocate memory for"
 		       " RX class rule locations");
@@ -396,7 +391,7 @@ static int rmgr_init(struct cmd_context *ctx)
 
 	/* request location list */
 	nfccmd->cmd = ETHTOOL_GRXCLSRLALL;
-	nfccmd->rule_cnt = rmgr.n_rules;
+	nfccmd->rule_cnt = rmgr->n_rules;
 	err = send_ioctl(ctx, nfccmd);
 	if (err < 0) {
 		perror("rmgr: Cannot get RX class rules");
@@ -405,61 +400,56 @@ static int rmgr_init(struct cmd_context *ctx)
 	}
 
 	/* make certain the table size is valid */
-	rmgr.size = nfccmd->data;
-	if (rmgr.size == 0 || rmgr.size < rmgr.n_rules) {
+	rmgr->size = nfccmd->data;
+	if (rmgr->size == 0 || rmgr->size < rmgr->n_rules) {
 		perror("rmgr: Invalid RX class rules table size");
 		return -1;
 	}
 
 	/* initialize bitmap for storage of valid locations */
-	rmgr.slot = calloc(1, BITS_TO_LONGS(rmgr.size) * sizeof(long));
-	if (!rmgr.slot) {
+	rmgr->slot = calloc(1, BITS_TO_LONGS(rmgr->size) * sizeof(long));
+	if (!rmgr->slot) {
 		perror("rmgr: Cannot allocate memory for RX class rules");
 		return -1;
 	}
 
 	/* write locations to bitmap */
 	rule_locs = nfccmd->rule_locs;
-	for (i = 0; i < rmgr.n_rules; i++) {
-		err = rmgr_ins(rule_locs[i]);
+	for (i = 0; i < rmgr->n_rules; i++) {
+		err = rmgr_ins(rmgr, rule_locs[i]);
 		if (err < 0)
 			break;
 	}
 
-	/* free memory and set flag to avoid reinit */
 	free(nfccmd);
-	rmgr_init_done = 1;
 
 	return err;
 }
 
-static void rmgr_cleanup(void)
+static void rmgr_cleanup(struct rmgr_ctrl *rmgr)
 {
-	if (!rmgr_init_done)
-		return;
-
-	rmgr_init_done = 0;
-
-	free(rmgr.slot);
-	rmgr.slot = NULL;
-	rmgr.size = 0;
+	free(rmgr->slot);
+	rmgr->slot = NULL;
+	rmgr->size = 0;
 }
 
 static int rmgr_set_location(struct cmd_context *ctx,
 			     struct ethtool_rx_flow_spec *fsp)
 {
+	struct rmgr_ctrl rmgr;
 	int err;
 
 	/* init table of available rules */
-	err = rmgr_init(ctx);
+	err = rmgr_init(ctx, &rmgr);
 	if (err < 0)
-		return err;
+		goto out;
 
 	/* verify rule location */
-	err = rmgr_find_empty_slot(fsp);
+	err = rmgr_find_empty_slot(&rmgr, fsp);
 
+out:
 	/* cleanup table and free resources */
-	rmgr_cleanup();
+	rmgr_cleanup(&rmgr);
 
 	return err;
 }
-- 
1.7.4.4



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
