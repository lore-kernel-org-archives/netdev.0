From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: Add debugfs entry to enable/disable backdoor access
Date: Mon, 20 Jul 2015 20:24:11 +0530
Message-ID: <1437404051-7020-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:18404 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751949AbbGTJkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 05:40:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add debugfs entry 'use_backdoor' to enable/disable backdoor access
to read sge context. By default, we read sge context's via firmware. In
case of FW issues, one can enable backdoor access via debugfs to dump
sge context for debugging purpose.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  7 +++++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 19 ++++++++++++-------
 3 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 629f75d..58de444 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -767,6 +767,7 @@ struct adapter {
 	bool tid_release_task_busy;
 
 	struct dentry *debugfs_root;
+	u32 use_bd;     /* Use SGE Back Door intfc for reading SGE Contexts */
 
 	spinlock_t stats_lock;
 	spinlock_t win0_lock ____cacheline_aligned_in_smp;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index b135d05..5b525a7 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -2386,8 +2386,11 @@ int t4_setup_debugfs(struct adapter *adap)
 					EXT_MEM_SIZE_G(size));
 	}
 
-	de = debugfs_create_file_size("flash", S_IRUSR, adap->debugfs_root, adap,
-				      &flash_debugfs_fops, adap->params.sf_size);
+	de = debugfs_create_file_size("flash", S_IRUSR, adap->debugfs_root,
+				      adap, &flash_debugfs_fops,
+				      adap->params.sf_size);
+	debugfs_create_bool("use_backdoor", S_IWUSR | S_IRUSR,
+			    adap->debugfs_root, &adap->use_bd);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 1e6597d..f8f446e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -3689,6 +3689,11 @@ int t4_read_rss(struct adapter *adapter, u16 *map)
 	return 0;
 }
 
+static unsigned int t4_use_ldst(struct adapter *adap)
+{
+	return (adap->flags & FW_OK) || (!adap->use_bd);
+}
+
 /**
  *	t4_fw_tp_pio_rw - Access TP PIO through LDST
  *	@adap: the adapter
@@ -3732,7 +3737,7 @@ static void t4_fw_tp_pio_rw(struct adapter *adap, u32 *vals, unsigned int nregs,
  */
 void t4_read_rss_key(struct adapter *adap, u32 *key)
 {
-	if (adap->flags & FW_OK)
+	if (t4_use_ldst(adap))
 		t4_fw_tp_pio_rw(adap, key, 10, TP_RSS_SECRET_KEY0_A, 1);
 	else
 		t4_read_indirect(adap, TP_PIO_ADDR_A, TP_PIO_DATA_A, key, 10,
@@ -3762,7 +3767,7 @@ void t4_write_rss_key(struct adapter *adap, const u32 *key, int idx)
 	    (vrt & KEYEXTEND_F) && (KEYMODE_G(vrt) == 3))
 		rss_key_addr_cnt = 32;
 
-	if (adap->flags & FW_OK)
+	if (t4_use_ldst(adap))
 		t4_fw_tp_pio_rw(adap, (void *)key, 10, TP_RSS_SECRET_KEY0_A, 0);
 	else
 		t4_write_indirect(adap, TP_PIO_ADDR_A, TP_PIO_DATA_A, key, 10,
@@ -3791,7 +3796,7 @@ void t4_write_rss_key(struct adapter *adap, const u32 *key, int idx)
 void t4_read_rss_pf_config(struct adapter *adapter, unsigned int index,
 			   u32 *valp)
 {
-	if (adapter->flags & FW_OK)
+	if (t4_use_ldst(adapter))
 		t4_fw_tp_pio_rw(adapter, valp, 1,
 				TP_RSS_PF0_CONFIG_A + index, 1);
 	else
@@ -3831,7 +3836,7 @@ void t4_read_rss_vf_config(struct adapter *adapter, unsigned int index,
 
 	/* Grab the VFL/VFH values ...
 	 */
-	if (adapter->flags & FW_OK) {
+	if (t4_use_ldst(adapter)) {
 		t4_fw_tp_pio_rw(adapter, vfl, 1, TP_RSS_VFL_CONFIG_A, 1);
 		t4_fw_tp_pio_rw(adapter, vfh, 1, TP_RSS_VFH_CONFIG_A, 1);
 	} else {
@@ -3852,7 +3857,7 @@ u32 t4_read_rss_pf_map(struct adapter *adapter)
 {
 	u32 pfmap;
 
-	if (adapter->flags & FW_OK)
+	if (t4_use_ldst(adapter))
 		t4_fw_tp_pio_rw(adapter, &pfmap, 1, TP_RSS_PF_MAP_A, 1);
 	else
 		t4_read_indirect(adapter, TP_PIO_ADDR_A, TP_PIO_DATA_A,
@@ -3870,7 +3875,7 @@ u32 t4_read_rss_pf_mask(struct adapter *adapter)
 {
 	u32 pfmask;
 
-	if (adapter->flags & FW_OK)
+	if (t4_use_ldst(adapter))
 		t4_fw_tp_pio_rw(adapter, &pfmask, 1, TP_RSS_PF_MSK_A, 1);
 	else
 		t4_read_indirect(adapter, TP_PIO_ADDR_A, TP_PIO_DATA_A,
@@ -6275,7 +6280,7 @@ int t4_init_tp_params(struct adapter *adap)
 	/* Cache the adapter's Compressed Filter Mode and global Incress
 	 * Configuration.
 	 */
-	if (adap->flags & FW_OK) {
+	if (t4_use_ldst(adap)) {
 		t4_fw_tp_pio_rw(adap, &adap->params.tp.vlan_pri_map, 1,
 				TP_VLAN_PRI_MAP_A, 1);
 		t4_fw_tp_pio_rw(adap, &adap->params.tp.ingress_config, 1,
-- 
2.3.4
