From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 1/1] bnx2x: Prevent link flaps when booting
 from SAN.
Date: Thu, 6 Dec 2012 11:04:03 +0200
Message-ID: <1354784643-22236-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, "Barak Witkowski" <barak@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3667 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932139Ab2LFJCU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Dec 2012 04:02:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Barak Witkowski <barak@broadcom.com>

It is possible that the driver is configured to operate with a certain
link configuration which differs from the link's configuration during
boot from SAN - this would cause the driver to flap the link.

Said flap may be missed by specific switches, causing dcbx convergence 
to be too long and boot sequence to fail. Convergence is longer because
switch ignores new dcbx packets due to counters mismatch, as only host 
side reset the counters due to the link flap.

This patch causes the driver to ignore user's initial configuration during
boot from SAN, and continues with the existing link configuration.

Signed-off-by: Barak Witkowski <barak@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
Hi Dave,

Boot from SAN from some switches fail without this fix.

As this fix is built above Link Flap Avoidance feature submitted only to
`net-next', please consider applying it to `net-next'.
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |    6 ++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h |    1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   28 +++++++++++++++++++--
 5 files changed, 34 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 02ea644..c79a584 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1186,6 +1186,7 @@ struct bnx2x_prev_path_list {
 	u8 slot;
 	u8 path;
 	struct list_head list;
+	u8 undi;
 };
 
 struct bnx2x_sp_objs {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 8ab1492..67baddd 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2396,6 +2396,7 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 
 	if (bp->port.pmf)
 		bnx2x_initial_phy_init(bp, load_mode);
+	bp->link_params.feature_config_flags &= ~FEATURE_CONFIG_BOOT_FROM_SAN;
 
 	/* Start fast path */
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 3e7d824..09096b4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -254,6 +254,12 @@ static int bnx2x_check_lfa(struct link_params *params)
 	if (!(link_status & LINK_STATUS_LINK_UP))
 		return LFA_LINK_DOWN;
 
+	/* if loaded after BOOT from SAN, don't flap the link in any case and
+	 * rely on link set by preboot driver
+	 */
+	if (params->feature_config_flags & FEATURE_CONFIG_BOOT_FROM_SAN)
+		return 0;
+
 	/* Verify that loopback mode is not set */
 	if (params->loopback_mode)
 		return LFA_LOOPBACK_ENABLED;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
index 181c5ce..ee6e7ec 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
@@ -267,6 +267,7 @@ struct link_params {
 #define FEATURE_CONFIG_BC_SUPPORTS_SFP_TX_DISABLED		(1<<10)
 #define FEATURE_CONFIG_DISABLE_REMOTE_FAULT_DET		(1<<11)
 #define FEATURE_CONFIG_MT_SUPPORT			(1<<13)
+#define FEATURE_CONFIG_BOOT_FROM_SAN			(1<<14)
 
 	/* Will be populated during common init */
 	struct bnx2x_phy phy[MAX_PHYS];
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 75aea83..7145b37 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9515,6 +9515,20 @@ static int bnx2x_prev_mcp_done(struct bnx2x *bp)
 	return 0;
 }
 
+static struct bnx2x_prev_path_list *
+		bnx2x_prev_path_get_entry(struct bnx2x *bp)
+{
+	struct bnx2x_prev_path_list *tmp_list;
+
+	list_for_each_entry(tmp_list, &bnx2x_prev_list, list)
+		if (PCI_SLOT(bp->pdev->devfn) == tmp_list->slot &&
+		    bp->pdev->bus->number == tmp_list->bus &&
+		    BP_PATH(bp) == tmp_list->path)
+			return tmp_list;
+
+	return NULL;
+}
+
 static bool bnx2x_prev_is_path_marked(struct bnx2x *bp)
 {
 	struct bnx2x_prev_path_list *tmp_list;
@@ -9539,7 +9553,7 @@ static bool bnx2x_prev_is_path_marked(struct bnx2x *bp)
 	return rc;
 }
 
-static int bnx2x_prev_mark_path(struct bnx2x *bp)
+static int bnx2x_prev_mark_path(struct bnx2x *bp, bool after_undi)
 {
 	struct bnx2x_prev_path_list *tmp_list;
 	int rc;
@@ -9553,6 +9567,7 @@ static int bnx2x_prev_mark_path(struct bnx2x *bp)
 	tmp_list->bus = bp->pdev->bus->number;
 	tmp_list->slot = PCI_SLOT(bp->pdev->devfn);
 	tmp_list->path = BP_PATH(bp);
+	tmp_list->undi = after_undi ? (1 << BP_PORT(bp)) : 0;
 
 	rc = down_interruptible(&bnx2x_prev_sem);
 	if (rc) {
@@ -9649,6 +9664,7 @@ static int bnx2x_prev_unload_uncommon(struct bnx2x *bp)
 static int bnx2x_prev_unload_common(struct bnx2x *bp)
 {
 	u32 reset_reg, tmp_reg = 0, rc;
+	bool prev_undi = false;
 	/* It is possible a previous function received 'common' answer,
 	 * but hasn't loaded yet, therefore creating a scenario of
 	 * multiple functions receiving 'common' on the same path.
@@ -9663,7 +9679,6 @@ static int bnx2x_prev_unload_common(struct bnx2x *bp)
 	/* Reset should be performed after BRB is emptied */
 	if (reset_reg & MISC_REGISTERS_RESET_REG_1_RST_BRB1) {
 		u32 timer_count = 1000;
-		bool prev_undi = false;
 
 		/* Close the MAC Rx to prevent BRB from filling up */
 		bnx2x_prev_unload_close_mac(bp);
@@ -9713,7 +9728,7 @@ static int bnx2x_prev_unload_common(struct bnx2x *bp)
 	/* No packets are in the pipeline, path is ready for reset */
 	bnx2x_reset_common(bp);
 
-	rc = bnx2x_prev_mark_path(bp);
+	rc = bnx2x_prev_mark_path(bp, prev_undi);
 	if (rc) {
 		bnx2x_prev_mcp_done(bp);
 		return rc;
@@ -9745,6 +9760,7 @@ static int bnx2x_prev_unload(struct bnx2x *bp)
 {
 	int time_counter = 10;
 	u32 rc, fw, hw_lock_reg, hw_lock_val;
+	struct bnx2x_prev_path_list *prev_list;
 	BNX2X_DEV_INFO("Entering Previous Unload Flow\n");
 
 	/* clear hw from errors which may have resulted from an interrupted
@@ -9803,6 +9819,12 @@ static int bnx2x_prev_unload(struct bnx2x *bp)
 		rc = -EBUSY;
 	}
 
+	/* Mark function if its port was used to boot from SAN */
+	prev_list = bnx2x_prev_path_get_entry(bp);
+	if (prev_list && (prev_list->undi & (1 << BP_PORT(bp))))
+		bp->link_params.feature_config_flags |=
+			FEATURE_CONFIG_BOOT_FROM_SAN;
+
 	BNX2X_DEV_INFO("Finished Previous Unload Flow [%d]\n", rc);
 
 	return rc;
-- 
1.7.1
