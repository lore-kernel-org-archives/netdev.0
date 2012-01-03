From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCHv2 ethtool 3/3] rxclass: Allow driver to select RX NFC rule
 location
Date: Tue, 3 Jan 2012 22:25:03 +0000
Message-ID: <1325629503.2832.48.camel@bwh-desktop>
References: <1325627819.2832.31.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:21488 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751717Ab2ACWZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 17:25:06 -0500
In-Reply-To: <1325627819.2832.31.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the user does not specify a location for an RX NFC rule to be added
and the result of the ETHTOOL_GRXCLSRLCNT command indicates that the
driver supports special rule locations, let the driver select the
location.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 rxclass.c |   29 ++++++++++++++++++++---------
 1 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/rxclass.c b/rxclass.c
index 9c7456f..4d49aa6 100644
--- a/rxclass.c
+++ b/rxclass.c
@@ -200,16 +200,17 @@ static void rxclass_print_rule(struct ethtool_rx_flow_spec *fsp)
 	}
 }
 
-static int rxclass_get_count(struct cmd_context *ctx, __u32 *count)
+static int rxclass_get_dev_info(struct cmd_context *ctx, __u32 *count,
+				int *driver_select)
 {
 	struct ethtool_rxnfc nfccmd;
 	int err;
 
-	/* request count and store */
 	nfccmd.cmd = ETHTOOL_GRXCLSRLCNT;
-	nfccmd.rule_cnt = 0;
 	err = send_ioctl(ctx, &nfccmd);
 	*count = nfccmd.rule_cnt;
+	if (driver_select)
+		*driver_select = !!(nfccmd.data & RX_CLS_LOC_SPECIAL);
 	if (err < 0)
 		perror("rxclass: Cannot get RX class rule count");
 
@@ -244,7 +245,7 @@ int rxclass_rule_getall(struct cmd_context *ctx)
 	__u32 count;
 
 	/* determine rule count */
-	err = rxclass_get_count(ctx, &count);
+	err = rxclass_get_dev_info(ctx, &count, NULL);
 	if (err < 0)
 		return err;
 
@@ -290,6 +291,8 @@ int rxclass_rule_getall(struct cmd_context *ctx)
  */
 
 struct rmgr_ctrl {
+	/* flag for device/driver that can select locations itself */
+	int			driver_select;
 	/* slot contains a bitmap indicating which filters are valid */
 	unsigned long		*slot;
 	__u32			n_rules;
@@ -316,6 +319,10 @@ static int rmgr_find_empty_slot(struct rmgr_ctrl *rmgr,
 	__u32 loc;
 	__u32 slot_num;
 
+	/* leave this to the driver if possible */
+	if (rmgr->driver_select)
+		return 0;
+
 	/* start at the end of the list since it is lowest priority */
 	loc = rmgr->size - 1;
 
@@ -373,11 +380,15 @@ static int rmgr_init(struct cmd_context *ctx, struct rmgr_ctrl *rmgr)
 	/* clear rule manager settings */
 	memset(rmgr, 0, sizeof(*rmgr));
 
-	/* request count and store in rmgr->n_rules */
-	err = rxclass_get_count(ctx, &rmgr->n_rules);
+	/* request device/driver information */
+	err = rxclass_get_dev_info(ctx, &rmgr->n_rules, &rmgr->driver_select);
 	if (err < 0)
 		return err;
 
+	/* do not get the table if the device/driver can select locations */
+	if (rmgr->driver_select)
+		return 0;
+
 	/* alloc memory for request of location list */
 	nfccmd = calloc(1, sizeof(*nfccmd) + (rmgr->n_rules * sizeof(__u32)));
 	if (!nfccmd) {
@@ -459,8 +470,8 @@ int rxclass_rule_ins(struct cmd_context *ctx,
 	int err;
 
 	/*
-	 * if location is unspecified pull rules from device
-	 * and allocate a free rule for our use
+	 * if location is unspecified and driver cannot select locations, pull
+	 * rules from device and allocate a free rule for our use
 	 */
 	if (loc & RX_CLS_LOC_SPECIAL) {
 		err = rmgr_set_location(ctx, fsp);
@@ -475,7 +486,7 @@ int rxclass_rule_ins(struct cmd_context *ctx,
 	if (err < 0)
 		perror("rmgr: Cannot insert RX class rule");
 	else if (loc & RX_CLS_LOC_SPECIAL)
-		printf("Added rule with ID %d\n", fsp->location);
+		printf("Added rule with ID %d\n", nfccmd.fs.location);
 
 	return 0;
 }
-- 
1.7.4.4


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
