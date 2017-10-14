From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 2/6] bnxt_en: Don't use rtnl lock to protect link change logic in workqueue.
Date: Fri, 13 Oct 2017 21:09:30 -0400
Message-ID: <1507943374-13308-3-git-send-email-michael.chan@broadcom.com>
References: <1507943374-13308-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f169.google.com ([209.85.216.169]:52501 "EHLO
        mail-qt0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751617AbdJNBJs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 21:09:48 -0400
Received: by mail-qt0-f169.google.com with SMTP id o52so22646875qtc.9
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 18:09:48 -0700 (PDT)
In-Reply-To: <1507943374-13308-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As a further improvement to the PF/VF link change logic, use a private
mutex instead of the rtnl lock to protect link change logic.  With the
new mutex, we don't have to take the rtnl lock in the workqueue when
we have to handle link related functions.  If the VF and PF drivers
are running on the same host and both take the rtnl lock and one is
waiting for the other, it will cause timeout.  This patch fixes these
timeouts.

Fixes: 90c694bb7181 ("bnxt_en: Fix RTNL lock usage on bnxt_update_link().")
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 25 ++++++++++++-----------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  4 ++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |  4 ++++
 3 files changed, 21 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 7906153..3f596de 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -6345,7 +6345,9 @@ static int __bnxt_open_nic(struct bnxt *bp, bool irq_re_init, bool link_re_init)
 	}
 
 	if (link_re_init) {
+		mutex_lock(&bp->link_lock);
 		rc = bnxt_update_phy_setting(bp);
+		mutex_unlock(&bp->link_lock);
 		if (rc)
 			netdev_warn(bp->dev, "failed to update phy settings\n");
 	}
@@ -7043,30 +7045,28 @@ static void bnxt_sp_task(struct work_struct *work)
 	if (test_and_clear_bit(BNXT_PERIODIC_STATS_SP_EVENT, &bp->sp_event))
 		bnxt_hwrm_port_qstats(bp);
 
-	/* These functions below will clear BNXT_STATE_IN_SP_TASK.  They
-	 * must be the last functions to be called before exiting.
-	 */
 	if (test_and_clear_bit(BNXT_LINK_CHNG_SP_EVENT, &bp->sp_event)) {
-		int rc = 0;
+		int rc;
 
+		mutex_lock(&bp->link_lock);
 		if (test_and_clear_bit(BNXT_LINK_SPEED_CHNG_SP_EVENT,
 				       &bp->sp_event))
 			bnxt_hwrm_phy_qcaps(bp);
 
-		bnxt_rtnl_lock_sp(bp);
-		if (test_bit(BNXT_STATE_OPEN, &bp->state))
-			rc = bnxt_update_link(bp, true);
-		bnxt_rtnl_unlock_sp(bp);
+		rc = bnxt_update_link(bp, true);
+		mutex_unlock(&bp->link_lock);
 		if (rc)
 			netdev_err(bp->dev, "SP task can't update link (rc: %x)\n",
 				   rc);
 	}
 	if (test_and_clear_bit(BNXT_HWRM_PORT_MODULE_SP_EVENT, &bp->sp_event)) {
-		bnxt_rtnl_lock_sp(bp);
-		if (test_bit(BNXT_STATE_OPEN, &bp->state))
-			bnxt_get_port_module_status(bp);
-		bnxt_rtnl_unlock_sp(bp);
+		mutex_lock(&bp->link_lock);
+		bnxt_get_port_module_status(bp);
+		mutex_unlock(&bp->link_lock);
 	}
+	/* These functions below will clear BNXT_STATE_IN_SP_TASK.  They
+	 * must be the last functions to be called before exiting.
+	 */
 	if (test_and_clear_bit(BNXT_RESET_TASK_SP_EVENT, &bp->sp_event))
 		bnxt_reset(bp, false);
 
@@ -7766,6 +7766,7 @@ static int bnxt_probe_phy(struct bnxt *bp)
 			   rc);
 		return rc;
 	}
+	mutex_init(&bp->link_lock);
 
 	rc = bnxt_update_link(bp, false);
 	if (rc) {
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 7b888d4..d2925c0 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1290,6 +1290,10 @@ struct bnxt {
 	unsigned long		*ntp_fltr_bmap;
 	int			ntp_fltr_count;
 
+	/* To protect link related settings during link changes and
+	 * ethtool settings changes.
+	 */
+	struct mutex		link_lock;
 	struct bnxt_link_info	link_info;
 	struct ethtool_eee	eee;
 	u32			lpi_tmr_lo;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 8eff05a..b2cbc97 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -1052,6 +1052,7 @@ static int bnxt_get_link_ksettings(struct net_device *dev,
 	u32 ethtool_speed;
 
 	ethtool_link_ksettings_zero_link_mode(lk_ksettings, supported);
+	mutex_lock(&bp->link_lock);
 	bnxt_fw_to_ethtool_support_spds(link_info, lk_ksettings);
 
 	ethtool_link_ksettings_zero_link_mode(lk_ksettings, advertising);
@@ -1099,6 +1100,7 @@ static int bnxt_get_link_ksettings(struct net_device *dev,
 			base->port = PORT_FIBRE;
 	}
 	base->phy_address = link_info->phy_addr;
+	mutex_unlock(&bp->link_lock);
 
 	return 0;
 }
@@ -1190,6 +1192,7 @@ static int bnxt_set_link_ksettings(struct net_device *dev,
 	if (!BNXT_SINGLE_PF(bp))
 		return -EOPNOTSUPP;
 
+	mutex_lock(&bp->link_lock);
 	if (base->autoneg == AUTONEG_ENABLE) {
 		BNXT_ETHTOOL_TO_FW_SPDS(fw_advertising, lk_ksettings,
 					advertising);
@@ -1234,6 +1237,7 @@ static int bnxt_set_link_ksettings(struct net_device *dev,
 		rc = bnxt_hwrm_set_link_setting(bp, set_pause, false);
 
 set_setting_exit:
+	mutex_unlock(&bp->link_lock);
 	return rc;
 }
 
-- 
1.8.3.1
