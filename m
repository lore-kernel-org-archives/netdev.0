From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/13] i40e: Error handling for link event
Date: Sat, 18 Feb 2017 22:33:38 -0800
Message-ID: <20170219063341.8039-11-jeffrey.t.kirsher@intel.com>
References: <20170219063341.8039-1-jeffrey.t.kirsher@intel.com>
Cc: Harshitha Ramamurthy <harshitha.ramamurthy@intel.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:39180 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751146AbdBSGeN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 19 Feb 2017 01:34:13 -0500
In-Reply-To: <20170219063341.8039-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harshitha Ramamurthy <harshitha.ramamurthy@intel.com>

There exists an intermittent bug which causes the 'Link Detected'
field reported by the 'ethtool <iface>' command to be 'Yes' when
in fact, there is no link. This patch fixes the problem by
enabling temporary link polling when i40e_get_link_status returns
an error. This causes the driver to remember that an admin queue
command failed and polls, until the function returns with a success.

Change-Id: I64c69b008db4017b8729f3fc27b8f65c8fe2eaa0
Signed-off-by: Harshitha Ramamurthy <harshitha.ramamurthy@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e.h      |  1 +
 drivers/net/ethernet/intel/i40e/i40e_main.c | 14 ++++++++++++--
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e.h b/drivers/net/ethernet/intel/i40e/i40e.h
index f4c4ee3edde1..82d8040fa418 100644
--- a/drivers/net/ethernet/intel/i40e/i40e.h
+++ b/drivers/net/ethernet/intel/i40e/i40e.h
@@ -349,6 +349,7 @@ struct i40e_pf {
 #define I40E_FLAG_HAVE_CRT_RETIMER		BIT_ULL(52)
 #define I40E_FLAG_PTP_L4_CAPABLE		BIT_ULL(53)
 #define I40E_FLAG_WOL_MC_MAGIC_PKT_WAKE		BIT_ULL(54)
+#define I40E_FLAG_TEMP_LINK_POLLING		BIT_ULL(55)
 
 	/* tracks features that get auto disabled by errors */
 	u64 auto_disable_flags;
diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index df78271bdce5..199ef34e00f8 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -6353,7 +6353,16 @@ static void i40e_link_event(struct i40e_pf *pf)
 	old_link = (pf->hw.phy.link_info_old.link_info & I40E_AQ_LINK_UP);
 
 	status = i40e_get_link_status(&pf->hw, &new_link);
-	if (status) {
+
+	/* On success, disable temp link polling */
+	if (status == I40E_SUCCESS) {
+		if (pf->flags & I40E_FLAG_TEMP_LINK_POLLING)
+			pf->flags &= ~I40E_FLAG_TEMP_LINK_POLLING;
+	} else {
+		/* Enable link polling temporarily until i40e_get_link_status
+		 * returns I40E_SUCCESS
+		 */
+		pf->flags |= I40E_FLAG_TEMP_LINK_POLLING;
 		dev_dbg(&pf->pdev->dev, "couldn't get link state, status: %d\n",
 			status);
 		return;
@@ -6405,7 +6414,8 @@ static void i40e_watchdog_subtask(struct i40e_pf *pf)
 		return;
 	pf->service_timer_previous = jiffies;
 
-	if (pf->flags & I40E_FLAG_LINK_POLLING_ENABLED)
+	if ((pf->flags & I40E_FLAG_LINK_POLLING_ENABLED) ||
+	    (pf->flags & I40E_FLAG_TEMP_LINK_POLLING))
 		i40e_link_event(pf);
 
 	/* Update the stats for active netdevs so the network stack
-- 
2.11.0
