From: Jacob Keller <jacob.e.keller@intel.com>
Subject: [PATCH 4/4] fm10k: don't reinitialize RSS flow table when RXFH configured
Date: Mon,  8 Feb 2016 12:06:05 -0800
Message-ID: <1454961965-15116-5-git-send-email-jacob.e.keller@intel.com>
References: <1454961965-15116-1-git-send-email-jacob.e.keller@intel.com>
Cc: mooray3@wp.pl, davem@davemloft.net,
	Jacob Keller <jacob.e.keller@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:8053 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754739AbcBHUIk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2016 15:08:40 -0500
In-Reply-To: <1454961965-15116-1-git-send-email-jacob.e.keller@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also print an error message incase we do have to reconfigure as this
should no longer happen anymore due to ethtool changes. If it somehow
does occur, user should be made aware of it.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 134ce4daa994..4e58f9155883 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -1937,8 +1937,10 @@ static void fm10k_init_reta(struct fm10k_intfc *interface)
 	u16 i, rss_i = interface->ring_feature[RING_F_RSS].indices;
 	u32 reta, base;
 
-	/* If the netdev is initialized we have to maintain table if possible */
-	if (interface->netdev->reg_state != NETREG_UNINITIALIZED) {
+	/* If the Rx flow indirection table has been configured manually, we
+	 * need to maintain it when possible.
+	 */
+	if (netif_is_rxfh_configured(interface->netdev)) {
 		for (i = FM10K_RETA_SIZE; i--;) {
 			reta = interface->reta[i];
 			if ((((reta << 24) >> 24) < rss_i) &&
@@ -1946,6 +1948,10 @@ static void fm10k_init_reta(struct fm10k_intfc *interface)
 			    (((reta <<  8) >> 24) < rss_i) &&
 			    (((reta)       >> 24) < rss_i))
 				continue;
+
+			/* this should never happen */
+			dev_err(&interface->pdev->dev,
+				"RSS indirection table assigned flows out of queue bounds. Reconfiguring.\n");
 			goto repopulate_reta;
 		}
 
-- 
2.7.0.236.gda096a0.dirty
