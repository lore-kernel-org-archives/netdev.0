From: Jacob Keller <jacob.e.keller@intel.com>
Subject: [PATCH 2/2] fm10k: support dynamic mode for RSS table control
Date: Tue,  2 Feb 2016 15:22:07 -0800
Message-ID: <1454455328-706-3-git-send-email-jacob.e.keller@intel.com>
References: <1454455328-706-1-git-send-email-jacob.e.keller@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:30800 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754811AbcBBXWV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 18:22:21 -0500
In-Reply-To: <1454455328-706-1-git-send-email-jacob.e.keller@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for the new dynamic flag from set_rxfh and get_rxfh. For now
the only known dynamic reason to change RSS is when number of queues is
changed. The default mode for the driver will be dynamic, indicating
that the driver is free to change its own default setting as it sees
fit. Since the current default userspace ethtool operation will only
send false as the value to dynamic this results in the behavior that the
driver configured RSS settings are capable of being modified but user
supplied changes will be preserved as long as possible.

In practice, this resolves an issue where decreasing the number of
queues and then increasing them shall no longer break RSS unless the
user has manually configured a non-dynamic RSS table setting.

If the user has configured the RSS table without setting dynamic, the
driver will do its best to maintain the configuration. If this is not
possible, we will indicate that the mode is now dynamic and reset to
driver defaults.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k.h         |  1 +
 drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c | 10 +++++++++-
 drivers/net/ethernet/intel/fm10k/fm10k_main.c    |  8 +++++---
 3 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k.h b/drivers/net/ethernet/intel/fm10k/fm10k.h
index 83f386714e87..5402b5c55247 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k.h
+++ b/drivers/net/ethernet/intel/fm10k/fm10k.h
@@ -268,6 +268,7 @@ struct fm10k_intfc {
 #define FM10K_FLAG_RX_TS_ENABLED		(u32)(BIT(3))
 #define FM10K_FLAG_SWPRI_CONFIG			(u32)(BIT(4))
 #define FM10K_FLAG_DEBUG_STATS			(u32)(BIT(5))
+#define FM10K_FLAG_STATIC_RETA_TBL		(u32)(BIT(6))
 	int xcast_mode;
 
 	/* Tx fast path data */
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
index af11c4c1b256..8799296ff86e 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_ethtool.c
@@ -1100,7 +1100,7 @@ static int fm10k_get_rssh(struct net_device *netdev, u32 *indir, u8 *key,
 		*hfunc = ETH_RSS_HASH_TOP;
 
 	if (dynamic)
-		*dynamic = false;
+		*dynamic = !(interface->flags & FM10K_FLAG_STATIC_RETA_TBL);
 
 	err = fm10k_get_reta(netdev, indir);
 	if (err || !key)
@@ -1123,6 +1123,14 @@ static int fm10k_set_rssh(struct net_device *netdev, const u32 *indir,
 	if (hfunc != ETH_RSS_HASH_NO_CHANGE && hfunc != ETH_RSS_HASH_TOP)
 		return -EOPNOTSUPP;
 
+	/* If dynamic mode is not requested, enable the static flag. We'll
+	 * still attempt to populate the RETA table using the provided
+	 * settings if possible. */
+	if (dynamic)
+		interface->flags &= ~FM10K_FLAG_STATIC_RETA_TBL;
+	else
+		interface->flags |= FM10K_FLAG_STATIC_RETA_TBL;
+
 	err = fm10k_set_reta(netdev, indir);
 	if (err || !key)
 		return err;
diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 134ce4daa994..8c75f60028a6 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -1932,13 +1932,13 @@ static void fm10k_assign_rings(struct fm10k_intfc *interface)
 	fm10k_cache_ring_rss(interface);
 }
 
-static void fm10k_init_reta(struct fm10k_intfc *interface)
+void fm10k_init_reta(struct fm10k_intfc *interface)
 {
 	u16 i, rss_i = interface->ring_feature[RING_F_RSS].indices;
 	u32 reta, base;
 
-	/* If the netdev is initialized we have to maintain table if possible */
-	if (interface->netdev->reg_state != NETREG_UNINITIALIZED) {
+	/* Maintain static user provided table if possible. */
+	if (interface->flags & FM10K_FLAG_STATIC_RETA_TBL) {
 		for (i = FM10K_RETA_SIZE; i--;) {
 			reta = interface->reta[i];
 			if ((((reta << 24) >> 24) < rss_i) &&
@@ -1954,6 +1954,8 @@ static void fm10k_init_reta(struct fm10k_intfc *interface)
 	}
 
 repopulate_reta:
+	interface->flags &= ~FM10K_FLAG_STATIC_RETA_TBL;
+
 	/* Populate the redirection table 4 entries at a time.  To do this
 	 * we are generating the results for n and n+2 and then interleaving
 	 * those with the results with n+1 and n+3.
-- 
2.6.3.505.g5cc1fd1
