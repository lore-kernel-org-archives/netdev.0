From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/17] fm10k: fix possible null pointer deref after kcalloc
Date: Wed, 20 Apr 2016 23:09:27 -0700
Message-ID: <1461218969-68578-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:24794 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751676AbcDUGJg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Apr 2016 02:09:36 -0400
In-Reply-To: <1461218969-68578-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

When writing a new default redirection table, we needed to populate
a new RSS table using ethtool_rxfh_indir_default. We populated this
table into a region of memory allocated using kcalloc, but never checked
this for NULL. Fix this by moving the default table generation into
fm10k_write_reta. If this function is passed a table, use it. Otherwise,
generate the default table using ethtool_rxfh_indir_default, 4 at at
time.

Fixes: 0ea7fae44094 ("fm10k: use ethtool_rxfh_indir_default for default redirection table")
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 26 ++++++++++++++++++------
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    | 14 ++-----------
 2 files changed, 22 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index ca276c0..e79e915 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -971,15 +971,29 @@ u32 fm10k_get_reta_size(struct net_device __always_unused *netdev)
 
 void fm10k_write_reta(struct fm10k_intfc *interface, const u32 *indir)
 {
+	u16 rss_i = interface->ring_feature[RING_F_RSS].indices;
 	struct fm10k_hw *hw = &interface->hw;
-	int i;
+	u32 table[4];
+	int i, j;
 
 	/* record entries to reta table */
-	for (i = 0; i < FM10K_RETA_SIZE; i++, indir += 4) {
-		u32 reta = indir[0] |
-			   (indir[1] << 8) |
-			   (indir[2] << 16) |
-			   (indir[3] << 24);
+	for (i = 0; i < FM10K_RETA_SIZE; i++) {
+		u32 reta, n;
+
+		/* generate a new table if we weren't given one */
+		for (j = 0; j < 4; j++) {
+			if (indir)
+				n = indir[i + j];
+			else
+				n = ethtool_rxfh_indir_default(i + j, rss_i);
+
+			table[j] = n;
+		}
+
+		reta = table[0] |
+			(table[1] << 8) |
+			(table[2] << 16) |
+			(table[3] << 24);
 
 		if (interface->reta[i] == reta)
 			continue;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 58092e5..aca3e47 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -1927,8 +1927,7 @@ static void fm10k_assign_rings(struct fm10k_intfc *interface)
 static void fm10k_init_reta(struct fm10k_intfc *interface)
 {
 	u16 i, rss_i = interface->ring_feature[RING_F_RSS].indices;
-	struct net_device *netdev = interface->netdev;
-	u32 reta, *indir;
+	u32 reta;
 
 	/* If the Rx flow indirection table has been configured manually, we
 	 * need to maintain it when possible.
@@ -1953,16 +1952,7 @@ static void fm10k_init_reta(struct fm10k_intfc *interface)
 	}
 
 repopulate_reta:
-	indir = kcalloc(fm10k_get_reta_size(netdev),
-			sizeof(indir[0]), GFP_KERNEL);
-
-	/* generate redirection table using the default kernel policy */
-	for (i = 0; i < fm10k_get_reta_size(netdev); i++)
-		indir[i] = ethtool_rxfh_indir_default(i, rss_i);
-
-	fm10k_write_reta(interface, indir);
-
-	kfree(indir);
+	fm10k_write_reta(interface, NULL);
 }
 
 /**
-- 
2.5.5
