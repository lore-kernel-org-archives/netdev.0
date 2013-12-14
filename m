From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [RFC net-next] bnx2x: namespace cleanup
Date: Fri, 13 Dec 2013 17:31:16 -0800
Message-ID: <20131213173116.229505be@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ariel Elior <ariele@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:35860 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753025Ab3LNBbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 20:31:21 -0500
Received: by mail-pd0-f169.google.com with SMTP id v10so2226926pde.0
        for <netdev@vger.kernel.org>; Fri, 13 Dec 2013 17:31:21 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a bunch of whole lot of namespace issues with the Broadcom bnx2x driver
found by running 'make namespacecheck'

 * several global variables were not prefixed (num_queues, load_count)
   and could cause conflicts in future.
 * make local functions static
 * remove resulting dead code fallout
 	 bnx2x_pfc_statistic,
 	 bnx2x_init_vlan_mac_obj,
	 bnx2x_vlan_mac_h_write_unlock,
	 bnx2x_emac_get_pfc_stat
	 bnx2x_put_credit_vlan_mac,  bnx2x_get_credit_vlan_mac ...

   Looks like vlan support in this driver was a botch from day one
   either never worked, or not implemented.

Compile tested only

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h       |    2 
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.mod.c   |   82 +++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c   |   55 +++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h   |  128 ----------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c  |   66 -----
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h  |    8 
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c  |   94 ++++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c    |  265 ----------------------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h    |   13 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c |    8 
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h |   14 -
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c  |   17 -
 12 files changed, 187 insertions(+), 565 deletions(-)

--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h	2013-12-12 12:28:44.744527896 -0800
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h	2013-12-13 17:05:15.705841570 -0800
@@ -1881,7 +1881,6 @@ struct bnx2x {
 };
 
 /* Tx queues may be less or equal to Rx queues */
-extern int num_queues;
 #define BNX2X_NUM_QUEUES(bp)	(bp->num_queues)
 #define BNX2X_NUM_ETH_QUEUES(bp) ((bp)->num_ethernet_queues)
 #define BNX2X_NUM_NON_CNIC_QUEUES(bp)	(BNX2X_NUM_QUEUES(bp) - \
@@ -2053,7 +2052,6 @@ int bnx2x_del_all_macs(struct bnx2x *bp,
 void bnx2x_func_init(struct bnx2x *bp, struct bnx2x_func_init_params *p);
 void bnx2x_init_sb(struct bnx2x *bp, dma_addr_t mapping, int vfid,
 		    u8 vf_valid, int fw_sb_id, int igu_sb_id);
-u32 bnx2x_get_pretend_reg(struct bnx2x *bp);
 int bnx2x_get_gpio(struct bnx2x *bp, int gpio_num, u8 port);
 int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode, u8 port);
 int bnx2x_set_mult_gpio(struct bnx2x *bp, u8 pins, u32 mode);
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c	2013-12-12 12:28:44.744527896 -0800
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c	2013-12-13 17:04:09.950659029 -0800
@@ -30,6 +30,37 @@
 #include "bnx2x_init.h"
 #include "bnx2x_sp.h"
 
+static int bnx2x_alloc_fp_mem_cnic(struct bnx2x *bp);
+static int bnx2x_alloc_fp_mem(struct bnx2x *bp);
+static void bnx2x_free_fp_mem_cnic(struct bnx2x *bp);
+static void bnx2x_free_skbs_cnic(struct bnx2x *bp);
+static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget);
+static int bnx2x_poll(struct napi_struct *napi, int budget);
+
+static void bnx2x_add_all_napi_cnic(struct bnx2x *bp)
+{
+	int i;
+
+	/* Add NAPI objects */
+	for_each_rx_queue_cnic(bp, i) {
+		netif_napi_add(bp->dev, &bnx2x_fp(bp, i, napi),
+			       bnx2x_poll, NAPI_POLL_WEIGHT);
+		napi_hash_add(&bnx2x_fp(bp, i, napi));
+	}
+}
+
+static void bnx2x_add_all_napi(struct bnx2x *bp)
+{
+	int i;
+
+	/* Add NAPI objects */
+	for_each_eth_queue(bp, i) {
+		netif_napi_add(bp->dev, &bnx2x_fp(bp, i, napi),
+			       bnx2x_poll, NAPI_POLL_WEIGHT);
+		napi_hash_add(&bnx2x_fp(bp, i, napi));
+	}
+}
+
 /**
  * bnx2x_move_fp - move content of the fastpath structure.
  *
@@ -145,7 +176,7 @@ static void bnx2x_shrink_eth_fp(struct b
 	}
 }
 
-int load_count[2][3] = { {0} }; /* per-path: 0-common, 1-port0, 2-port1 */
+int bnx2x_load_count[2][3] = { {0} }; /* per-path: 0-common, 1-port0, 2-port1 */
 
 /* free skb in the packet ring at pos idx
  * return idx of last bd freed
@@ -812,7 +843,7 @@ void bnx2x_csum_validate(struct sk_buff
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 }
 
-int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
+static int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget)
 {
 	struct bnx2x *bp = fp->bp;
 	u16 bd_cons, bd_prod, bd_prod_fw, comp_ring_cons;
@@ -2296,16 +2327,16 @@ static int bnx2x_nic_load_no_mcp(struct
 	int path = BP_PATH(bp);
 
 	DP(NETIF_MSG_IFUP, "NO MCP - load counts[%d]      %d, %d, %d\n",
-	   path, load_count[path][0], load_count[path][1],
-	   load_count[path][2]);
-	load_count[path][0]++;
-	load_count[path][1 + port]++;
+	   path, bnx2x_load_count[path][0], bnx2x_load_count[path][1],
+	   bnx2x_load_count[path][2]);
+	bnx2x_load_count[path][0]++;
+	bnx2x_load_count[path][1 + port]++;
 	DP(NETIF_MSG_IFUP, "NO MCP - new load counts[%d]  %d, %d, %d\n",
-	   path, load_count[path][0], load_count[path][1],
-	   load_count[path][2]);
-	if (load_count[path][0] == 1)
+	   path, bnx2x_load_count[path][0], bnx2x_load_count[path][1],
+	   bnx2x_load_count[path][2]);
+	if (bnx2x_load_count[path][0] == 1)
 		return FW_MSG_CODE_DRV_LOAD_COMMON;
-	else if (load_count[path][1 + port] == 1)
+	else if (bnx2x_load_count[path][1 + port] == 1)
 		return FW_MSG_CODE_DRV_LOAD_PORT;
 	else
 		return FW_MSG_CODE_DRV_LOAD_FUNCTION;
@@ -3063,7 +3094,7 @@ int bnx2x_set_power_state(struct bnx2x *
 /*
  * net_device service functions
  */
-int bnx2x_poll(struct napi_struct *napi, int budget)
+static int bnx2x_poll(struct napi_struct *napi, int budget)
 {
 	int work_done = 0;
 	u8 cos;
@@ -4190,7 +4221,7 @@ static void bnx2x_free_fp_mem_at(struct
 	/* end of fastpath */
 }
 
-void bnx2x_free_fp_mem_cnic(struct bnx2x *bp)
+static void bnx2x_free_fp_mem_cnic(struct bnx2x *bp)
 {
 	int i;
 	for_each_cnic_queue(bp, i)
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h	2013-12-12 12:28:44.744527896 -0800
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h	2013-12-13 17:22:16.088442962 -0800
@@ -26,10 +26,9 @@
 #include "bnx2x_sriov.h"
 
 /* This is used as a replacement for an MCP if it's not present */
-extern int load_count[2][3]; /* per-path: 0-common, 1-port0, 2-port1 */
+extern int bnx2x_load_count[2][3]; /* per-path: 0-common, 1-port0, 2-port1 */
 
-extern int num_queues;
-extern int int_mode;
+extern int bnx2x_num_queues;
 
 /************************ Macros ********************************/
 #define BNX2X_PCI_FREE(x, y, size) \
@@ -408,44 +407,8 @@ int bnx2x_release_leader_lock(struct bnx
  */
 int bnx2x_set_eth_mac(struct bnx2x *bp, bool set);
 
-/**
- * bnx2x_set_rx_mode - set MAC filtering configurations.
- *
- * @dev:	netdevice
- *
- * called with netif_tx_lock from dev_mcast.c
- * If bp->state is OPEN, should be called with
- * netif_addr_lock_bh()
- */
-void bnx2x_set_rx_mode(struct net_device *dev);
 void bnx2x_set_rx_mode_inner(struct bnx2x *bp);
 
-/**
- * bnx2x_set_storm_rx_mode - configure MAC filtering rules in a FW.
- *
- * @bp:		driver handle
- *
- * If bp->state is OPEN, should be called with
- * netif_addr_lock_bh().
- */
-int bnx2x_set_storm_rx_mode(struct bnx2x *bp);
-
-/**
- * bnx2x_set_q_rx_mode - configures rx_mode for a single queue.
- *
- * @bp:			driver handle
- * @cl_id:		client id
- * @rx_mode_flags:	rx mode configuration
- * @rx_accept_flags:	rx accept configuration
- * @tx_accept_flags:	tx accept configuration (tx switch)
- * @ramrod_flags:	ramrod configuration
- */
-int bnx2x_set_q_rx_mode(struct bnx2x *bp, u8 cl_id,
-			unsigned long rx_mode_flags,
-			unsigned long rx_accept_flags,
-			unsigned long tx_accept_flags,
-			unsigned long ramrod_flags);
-
 /* Parity errors related */
 void bnx2x_set_pf_load(struct bnx2x *bp);
 bool bnx2x_clear_pf_load(struct bnx2x *bp);
@@ -564,9 +527,6 @@ int bnx2x_reload_if_running(struct net_d
 
 int bnx2x_change_mac_addr(struct net_device *dev, void *p);
 
-/* NAPI poll Rx part */
-int bnx2x_rx_int(struct bnx2x_fastpath *fp, int budget);
-
 /* NAPI poll Tx part */
 int bnx2x_tx_int(struct bnx2x *bp, struct bnx2x_fp_txdata *txdata);
 
@@ -577,13 +537,9 @@ int bnx2x_resume(struct pci_dev *pdev);
 /* Release IRQ vectors */
 void bnx2x_free_irq(struct bnx2x *bp);
 
-void bnx2x_free_fp_mem_cnic(struct bnx2x *bp);
 void bnx2x_free_fp_mem(struct bnx2x *bp);
-int bnx2x_alloc_fp_mem_cnic(struct bnx2x *bp);
-int bnx2x_alloc_fp_mem(struct bnx2x *bp);
 void bnx2x_init_rx_rings(struct bnx2x *bp);
 void bnx2x_init_rx_rings_cnic(struct bnx2x *bp);
-void bnx2x_free_skbs_cnic(struct bnx2x *bp);
 void bnx2x_free_skbs(struct bnx2x *bp);
 void bnx2x_netif_stop(struct bnx2x *bp, int disable_hw);
 void bnx2x_netif_start(struct bnx2x *bp);
@@ -607,15 +563,6 @@ int bnx2x_enable_msix(struct bnx2x *bp);
 int bnx2x_enable_msi(struct bnx2x *bp);
 
 /**
- * bnx2x_poll - NAPI callback
- *
- * @napi:	napi structure
- * @budget:
- *
- */
-int bnx2x_poll(struct napi_struct *napi, int budget);
-
-/**
  * bnx2x_low_latency_recv - LL callback
  *
  * @napi:	napi structure
@@ -861,30 +808,6 @@ static inline void bnx2x_free_rx_sge(str
 	sge->addr_lo = 0;
 }
 
-static inline void bnx2x_add_all_napi_cnic(struct bnx2x *bp)
-{
-	int i;
-
-	/* Add NAPI objects */
-	for_each_rx_queue_cnic(bp, i) {
-		netif_napi_add(bp->dev, &bnx2x_fp(bp, i, napi),
-			       bnx2x_poll, NAPI_POLL_WEIGHT);
-		napi_hash_add(&bnx2x_fp(bp, i, napi));
-	}
-}
-
-static inline void bnx2x_add_all_napi(struct bnx2x *bp)
-{
-	int i;
-
-	/* Add NAPI objects */
-	for_each_eth_queue(bp, i) {
-		netif_napi_add(bp->dev, &bnx2x_fp(bp, i, napi),
-			       bnx2x_poll, NAPI_POLL_WEIGHT);
-		napi_hash_add(&bnx2x_fp(bp, i, napi));
-	}
-}
-
 static inline void bnx2x_del_all_napi_cnic(struct bnx2x *bp)
 {
 	int i;
@@ -920,8 +843,8 @@ static inline void bnx2x_disable_msi(str
 
 static inline int bnx2x_calc_num_queues(struct bnx2x *bp)
 {
-	return  num_queues ?
-		 min_t(int, num_queues, BNX2X_MAX_QUEUES(bp)) :
+	return  bnx2x_num_queues ?
+		 min_t(int, bnx2x_num_queues, BNX2X_MAX_QUEUES(bp)) :
 		 min_t(int, netif_get_num_default_rss_queues(),
 		       BNX2X_MAX_QUEUES(bp));
 }
@@ -1172,8 +1095,6 @@ static inline u8 bnx2x_fp_qzone_id(struc
 		return fp->cl_id;
 }
 
-u32 bnx2x_rx_ustorm_prods_offset(struct bnx2x_fastpath *fp);
-
 static inline void bnx2x_init_txdata(struct bnx2x *bp,
 				     struct bnx2x_fp_txdata *txdata, u32 cid,
 				     int txq_index, __le16 *tx_cons_sb,
@@ -1206,47 +1127,6 @@ static inline u8 bnx2x_cnic_igu_sb_id(st
 	return bp->igu_base_sb;
 }
 
-static inline void bnx2x_init_fcoe_fp(struct bnx2x *bp)
-{
-	struct bnx2x_fastpath *fp = bnx2x_fcoe_fp(bp);
-	unsigned long q_type = 0;
-
-	bnx2x_fcoe(bp, rx_queue) = BNX2X_NUM_ETH_QUEUES(bp);
-	bnx2x_fcoe(bp, cl_id) = bnx2x_cnic_eth_cl_id(bp,
-						     BNX2X_FCOE_ETH_CL_ID_IDX);
-	bnx2x_fcoe(bp, cid) = BNX2X_FCOE_ETH_CID(bp);
-	bnx2x_fcoe(bp, fw_sb_id) = DEF_SB_ID;
-	bnx2x_fcoe(bp, igu_sb_id) = bp->igu_dsb_id;
-	bnx2x_fcoe(bp, rx_cons_sb) = BNX2X_FCOE_L2_RX_INDEX;
-	bnx2x_init_txdata(bp, bnx2x_fcoe(bp, txdata_ptr[0]),
-			  fp->cid, FCOE_TXQ_IDX(bp), BNX2X_FCOE_L2_TX_INDEX,
-			  fp);
-
-	DP(NETIF_MSG_IFUP, "created fcoe tx data (fp index %d)\n", fp->index);
-
-	/* qZone id equals to FW (per path) client id */
-	bnx2x_fcoe(bp, cl_qzone_id) = bnx2x_fp_qzone_id(fp);
-	/* init shortcut */
-	bnx2x_fcoe(bp, ustorm_rx_prods_offset) =
-		bnx2x_rx_ustorm_prods_offset(fp);
-
-	/* Configure Queue State object */
-	__set_bit(BNX2X_Q_TYPE_HAS_RX, &q_type);
-	__set_bit(BNX2X_Q_TYPE_HAS_TX, &q_type);
-
-	/* No multi-CoS for FCoE L2 client */
-	BUG_ON(fp->max_cos != 1);
-
-	bnx2x_init_queue_obj(bp, &bnx2x_sp_obj(bp, fp).q_obj, fp->cl_id,
-			     &fp->cid, 1, BP_FUNC(bp), bnx2x_sp(bp, q_rdata),
-			     bnx2x_sp_mapping(bp, q_rdata), q_type);
-
-	DP(NETIF_MSG_IFUP,
-	   "queue[%d]: bnx2x_init_sb(%p,%p) cl_id %d fw_sb %d igu_sb %d\n",
-	   fp->index, bp, fp->status_blk.e2_sb, fp->cl_id, fp->fw_sb_id,
-	   fp->igu_sb_id);
-}
-
 static inline int bnx2x_clean_tx_queue(struct bnx2x *bp,
 				       struct bnx2x_fp_txdata *txdata)
 {
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c	2013-12-12 12:28:44.744527896 -0800
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c	2013-12-13 17:22:37.056165608 -0800
@@ -93,8 +93,8 @@ MODULE_FIRMWARE(FW_FILE_NAME_E1);
 MODULE_FIRMWARE(FW_FILE_NAME_E1H);
 MODULE_FIRMWARE(FW_FILE_NAME_E2);
 
-int num_queues;
-module_param(num_queues, int, 0);
+int bnx2x_num_queues;
+module_param_named(num_queues, bnx2x_num_queues, int, 0);
 MODULE_PARM_DESC(num_queues,
 		 " Set number of queues (default is as a number of CPUs)");
 
@@ -102,7 +102,7 @@ static int disable_tpa;
 module_param(disable_tpa, int, 0);
 MODULE_PARM_DESC(disable_tpa, " Disable the TPA (LRO) feature");
 
-int int_mode;
+static int int_mode;
 module_param(int_mode, int, 0);
 MODULE_PARM_DESC(int_mode, " Force interrupt mode other than MSI-X "
 				"(1 INT#x; 2 MSI)");
@@ -278,6 +278,17 @@ MODULE_DEVICE_TABLE(pci, bnx2x_pci_tbl);
 #define BNX2X_PREV_WAIT_NEEDED 1
 static DEFINE_SEMAPHORE(bnx2x_prev_sem);
 static LIST_HEAD(bnx2x_prev_list);
+
+static void bnx2x_set_rx_mode(struct net_device *dev);
+static int bnx2x_set_storm_rx_mode(struct bnx2x *bp);
+static u32 bnx2x_rx_ustorm_prods_offset(struct bnx2x_fastpath *fp);
+static int bnx2x_set_q_rx_mode(struct bnx2x *bp, u8 cl_id,
+			       unsigned long rx_mode_flags,
+			       unsigned long rx_accept_flags,
+			       unsigned long tx_accept_flags,
+			       unsigned long ramrod_flags);
+
+
 /****************************************************************************
 * General service functions
 ****************************************************************************/
@@ -5852,11 +5863,11 @@ static void bnx2x_init_eq_ring(struct bn
 }
 
 /* called with netif_addr_lock_bh() */
-int bnx2x_set_q_rx_mode(struct bnx2x *bp, u8 cl_id,
-			unsigned long rx_mode_flags,
-			unsigned long rx_accept_flags,
-			unsigned long tx_accept_flags,
-			unsigned long ramrod_flags)
+static int bnx2x_set_q_rx_mode(struct bnx2x *bp, u8 cl_id,
+			       unsigned long rx_mode_flags,
+			       unsigned long rx_accept_flags,
+			       unsigned long tx_accept_flags,
+			       unsigned long ramrod_flags)
 {
 	struct bnx2x_rx_mode_ramrod_params ramrod_param;
 	int rc;
@@ -5964,7 +5975,7 @@ static int bnx2x_fill_accept_flags(struc
 }
 
 /* called with netif_addr_lock_bh() */
-int bnx2x_set_storm_rx_mode(struct bnx2x *bp)
+static int bnx2x_set_storm_rx_mode(struct bnx2x *bp)
 {
 	unsigned long rx_mode_flags = 0, ramrod_flags = 0;
 	unsigned long rx_accept_flags = 0, tx_accept_flags = 0;
@@ -6160,6 +6171,47 @@ static void bnx2x_init_tx_rings(struct b
 			bnx2x_init_tx_ring_one(bp->fp[i].txdata_ptr[cos]);
 }
 
+static void bnx2x_init_fcoe_fp(struct bnx2x *bp)
+{
+	struct bnx2x_fastpath *fp = bnx2x_fcoe_fp(bp);
+	unsigned long q_type = 0;
+
+	bnx2x_fcoe(bp, rx_queue) = BNX2X_NUM_ETH_QUEUES(bp);
+	bnx2x_fcoe(bp, cl_id) = bnx2x_cnic_eth_cl_id(bp,
+						     BNX2X_FCOE_ETH_CL_ID_IDX);
+	bnx2x_fcoe(bp, cid) = BNX2X_FCOE_ETH_CID(bp);
+	bnx2x_fcoe(bp, fw_sb_id) = DEF_SB_ID;
+	bnx2x_fcoe(bp, igu_sb_id) = bp->igu_dsb_id;
+	bnx2x_fcoe(bp, rx_cons_sb) = BNX2X_FCOE_L2_RX_INDEX;
+	bnx2x_init_txdata(bp, bnx2x_fcoe(bp, txdata_ptr[0]),
+			  fp->cid, FCOE_TXQ_IDX(bp), BNX2X_FCOE_L2_TX_INDEX,
+			  fp);
+
+	DP(NETIF_MSG_IFUP, "created fcoe tx data (fp index %d)\n", fp->index);
+
+	/* qZone id equals to FW (per path) client id */
+	bnx2x_fcoe(bp, cl_qzone_id) = bnx2x_fp_qzone_id(fp);
+	/* init shortcut */
+	bnx2x_fcoe(bp, ustorm_rx_prods_offset) =
+		bnx2x_rx_ustorm_prods_offset(fp);
+
+	/* Configure Queue State object */
+	__set_bit(BNX2X_Q_TYPE_HAS_RX, &q_type);
+	__set_bit(BNX2X_Q_TYPE_HAS_TX, &q_type);
+
+	/* No multi-CoS for FCoE L2 client */
+	BUG_ON(fp->max_cos != 1);
+
+	bnx2x_init_queue_obj(bp, &bnx2x_sp_obj(bp, fp).q_obj, fp->cl_id,
+			     &fp->cid, 1, BP_FUNC(bp), bnx2x_sp(bp, q_rdata),
+			     bnx2x_sp_mapping(bp, q_rdata), q_type);
+
+	DP(NETIF_MSG_IFUP,
+	   "queue[%d]: bnx2x_init_sb(%p,%p) cl_id %d fw_sb %d igu_sb %d\n",
+	   fp->index, bp, fp->status_blk.e2_sb, fp->cl_id, fp->fw_sb_id,
+	   fp->igu_sb_id);
+}
+
 void bnx2x_nic_init_cnic(struct bnx2x *bp)
 {
 	if (!NO_FCOE(bp))
@@ -8732,16 +8784,16 @@ u32 bnx2x_send_unload_req(struct bnx2x *
 		int path = BP_PATH(bp);
 
 		DP(NETIF_MSG_IFDOWN, "NO MCP - load counts[%d]      %d, %d, %d\n",
-		   path, load_count[path][0], load_count[path][1],
-		   load_count[path][2]);
-		load_count[path][0]--;
-		load_count[path][1 + port]--;
+		   path, bnx2x_load_count[path][0], bnx2x_load_count[path][1],
+		   bnx2x_load_count[path][2]);
+		bnx2x_load_count[path][0]--;
+		bnx2x_load_count[path][1 + port]--;
 		DP(NETIF_MSG_IFDOWN, "NO MCP - new load counts[%d]  %d, %d, %d\n",
-		   path, load_count[path][0], load_count[path][1],
-		   load_count[path][2]);
-		if (load_count[path][0] == 0)
+		   path, bnx2x_load_count[path][0], bnx2x_load_count[path][1],
+		   bnx2x_load_count[path][2]);
+		if (bnx2x_load_count[path][0] == 0)
 			reset_code = FW_MSG_CODE_DRV_UNLOAD_COMMON;
-		else if (load_count[path][1 + port] == 0)
+		else if (bnx2x_load_count[path][1 + port] == 0)
 			reset_code = FW_MSG_CODE_DRV_UNLOAD_PORT;
 		else
 			reset_code = FW_MSG_CODE_DRV_UNLOAD_FUNCTION;
@@ -9767,7 +9819,7 @@ period_task_exit:
  * Init service functions
  */
 
-u32 bnx2x_get_pretend_reg(struct bnx2x *bp)
+static u32 bnx2x_get_pretend_reg(struct bnx2x *bp)
 {
 	u32 base = PXP2_REG_PGL_PRETEND_FUNC_F0;
 	u32 stride = PXP2_REG_PGL_PRETEND_FUNC_F1 - base;
@@ -11931,7 +11983,7 @@ static int bnx2x_set_mc_list(struct bnx2
 }
 
 /* If bp->state is OPEN, should be called with netif_addr_lock_bh() */
-void bnx2x_set_rx_mode(struct net_device *dev)
+static void bnx2x_set_rx_mode(struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 
@@ -12693,7 +12745,7 @@ static int set_is_vf(int chip_id)
 	}
 }
 
-struct cnic_eth_dev *bnx2x_cnic_probe(struct net_device *dev);
+static struct cnic_eth_dev *bnx2x_cnic_probe(struct net_device *dev);
 
 static int bnx2x_init_one(struct pci_dev *pdev,
 				    const struct pci_device_id *ent)
@@ -13757,7 +13809,7 @@ static int bnx2x_unregister_cnic(struct
 	return 0;
 }
 
-struct cnic_eth_dev *bnx2x_cnic_probe(struct net_device *dev)
+static struct cnic_eth_dev *bnx2x_cnic_probe(struct net_device *dev)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 	struct cnic_eth_dev *cp = &bp->cnic_eth_dev;
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c	2013-12-12 12:28:44.744527896 -0800
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c	2013-12-13 17:12:53.563907357 -0800
@@ -356,22 +356,6 @@ static bool bnx2x_get_credit_vlan(struct
 	return vp->get(vp, 1);
 }
 
-static bool bnx2x_get_credit_vlan_mac(struct bnx2x_vlan_mac_obj *o)
-{
-	struct bnx2x_credit_pool_obj *mp = o->macs_pool;
-	struct bnx2x_credit_pool_obj *vp = o->vlans_pool;
-
-	if (!mp->get(mp, 1))
-		return false;
-
-	if (!vp->get(vp, 1)) {
-		mp->put(mp, 1);
-		return false;
-	}
-
-	return true;
-}
-
 static bool bnx2x_put_cam_offset_mac(struct bnx2x_vlan_mac_obj *o, int offset)
 {
 	struct bnx2x_credit_pool_obj *mp = o->macs_pool;
@@ -400,22 +384,6 @@ static bool bnx2x_put_credit_vlan(struct
 	return vp->put(vp, 1);
 }
 
-static bool bnx2x_put_credit_vlan_mac(struct bnx2x_vlan_mac_obj *o)
-{
-	struct bnx2x_credit_pool_obj *mp = o->macs_pool;
-	struct bnx2x_credit_pool_obj *vp = o->vlans_pool;
-
-	if (!mp->put(mp, 1))
-		return false;
-
-	if (!vp->put(vp, 1)) {
-		mp->get(mp, 1);
-		return false;
-	}
-
-	return true;
-}
-
 /**
  * __bnx2x_vlan_mac_h_write_trylock - try getting the vlan mac writer lock
  *
@@ -508,23 +476,6 @@ static void __bnx2x_vlan_mac_h_write_unl
 }
 
 /**
- * bnx2x_vlan_mac_h_write_unlock - unlock the vlan mac head list writer lock
- *
- * @bp:			device handle
- * @o:			vlan_mac object
- *
- * @details Notice if a pending execution exists, it would perform it -
- *          possibly releasing and reclaiming the execution queue lock.
- */
-void bnx2x_vlan_mac_h_write_unlock(struct bnx2x *bp,
-				   struct bnx2x_vlan_mac_obj *o)
-{
-	spin_lock_bh(&o->exe_queue.lock);
-	__bnx2x_vlan_mac_h_write_unlock(bp, o);
-	spin_unlock_bh(&o->exe_queue.lock);
-}
-
-/**
  * __bnx2x_vlan_mac_h_read_lock - lock the vlan mac head list reader lock
  *
  * @bp:			device handle
@@ -685,26 +636,6 @@ static int bnx2x_check_vlan_add(struct b
 	return 0;
 }
 
-static int bnx2x_check_vlan_mac_add(struct bnx2x *bp,
-				    struct bnx2x_vlan_mac_obj *o,
-				   union bnx2x_classification_ramrod_data *data)
-{
-	struct bnx2x_vlan_mac_registry_elem *pos;
-
-	DP(BNX2X_MSG_SP, "Checking VLAN_MAC (%pM, %d) for ADD command\n",
-	   data->vlan_mac.mac, data->vlan_mac.vlan);
-
-	list_for_each_entry(pos, &o->head, link)
-		if ((data->vlan_mac.vlan == pos->u.vlan_mac.vlan) &&
-		    (!memcmp(data->vlan_mac.mac, pos->u.vlan_mac.mac,
-				  ETH_ALEN)) &&
-		    (data->vlan_mac.is_inner_mac ==
-		     pos->u.vlan_mac.is_inner_mac))
-			return -EEXIST;
-
-	return 0;
-}
-
 /* check_del() callbacks */
 static struct bnx2x_vlan_mac_registry_elem *
 	bnx2x_check_mac_del(struct bnx2x *bp,
@@ -739,27 +670,6 @@ static struct bnx2x_vlan_mac_registry_el
 	return NULL;
 }
 
-static struct bnx2x_vlan_mac_registry_elem *
-	bnx2x_check_vlan_mac_del(struct bnx2x *bp,
-				 struct bnx2x_vlan_mac_obj *o,
-				 union bnx2x_classification_ramrod_data *data)
-{
-	struct bnx2x_vlan_mac_registry_elem *pos;
-
-	DP(BNX2X_MSG_SP, "Checking VLAN_MAC (%pM, %d) for DEL command\n",
-	   data->vlan_mac.mac, data->vlan_mac.vlan);
-
-	list_for_each_entry(pos, &o->head, link)
-		if ((data->vlan_mac.vlan == pos->u.vlan_mac.vlan) &&
-		    (!memcmp(data->vlan_mac.mac, pos->u.vlan_mac.mac,
-			     ETH_ALEN)) &&
-		    (data->vlan_mac.is_inner_mac ==
-		     pos->u.vlan_mac.is_inner_mac))
-			return pos;
-
-	return NULL;
-}
-
 /* check_move() callback */
 static bool bnx2x_check_move(struct bnx2x *bp,
 			     struct bnx2x_vlan_mac_obj *src_o,
@@ -811,8 +721,8 @@ static inline u8 bnx2x_vlan_mac_get_rx_t
 	return rx_tx_flag;
 }
 
-void bnx2x_set_mac_in_nig(struct bnx2x *bp,
-			  bool add, unsigned char *dev_addr, int index)
+static void bnx2x_set_mac_in_nig(struct bnx2x *bp,
+				 bool add, unsigned char *dev_addr, int index)
 {
 	u32 wb_data[2];
 	u32 reg_offset = BP_PORT(bp) ? NIG_REG_LLH1_FUNC_MEM :
@@ -1126,97 +1036,6 @@ static void bnx2x_set_one_vlan_e2(struct
 					rule_cnt);
 }
 
-static void bnx2x_set_one_vlan_mac_e2(struct bnx2x *bp,
-				      struct bnx2x_vlan_mac_obj *o,
-				      struct bnx2x_exeq_elem *elem,
-				      int rule_idx, int cam_offset)
-{
-	struct bnx2x_raw_obj *raw = &o->raw;
-	struct eth_classify_rules_ramrod_data *data =
-		(struct eth_classify_rules_ramrod_data *)(raw->rdata);
-	int rule_cnt = rule_idx + 1;
-	union eth_classify_rule_cmd *rule_entry = &data->rules[rule_idx];
-	enum bnx2x_vlan_mac_cmd cmd = elem->cmd_data.vlan_mac.cmd;
-	bool add = (cmd == BNX2X_VLAN_MAC_ADD) ? true : false;
-	u16 vlan = elem->cmd_data.vlan_mac.u.vlan_mac.vlan;
-	u8 *mac = elem->cmd_data.vlan_mac.u.vlan_mac.mac;
-
-	/* Reset the ramrod data buffer for the first rule */
-	if (rule_idx == 0)
-		memset(data, 0, sizeof(*data));
-
-	/* Set a rule header */
-	bnx2x_vlan_mac_set_cmd_hdr_e2(bp, o, add, CLASSIFY_RULE_OPCODE_PAIR,
-				      &rule_entry->pair.header);
-
-	/* Set VLAN and MAC themselves */
-	rule_entry->pair.vlan = cpu_to_le16(vlan);
-	bnx2x_set_fw_mac_addr(&rule_entry->pair.mac_msb,
-			      &rule_entry->pair.mac_mid,
-			      &rule_entry->pair.mac_lsb, mac);
-	rule_entry->pair.inner_mac =
-		cpu_to_le16(elem->cmd_data.vlan_mac.u.vlan_mac.is_inner_mac);
-	/* MOVE: Add a rule that will add this MAC to the target Queue */
-	if (cmd == BNX2X_VLAN_MAC_MOVE) {
-		rule_entry++;
-		rule_cnt++;
-
-		/* Setup ramrod data */
-		bnx2x_vlan_mac_set_cmd_hdr_e2(bp,
-					elem->cmd_data.vlan_mac.target_obj,
-					      true, CLASSIFY_RULE_OPCODE_PAIR,
-					      &rule_entry->pair.header);
-
-		/* Set a VLAN itself */
-		rule_entry->pair.vlan = cpu_to_le16(vlan);
-		bnx2x_set_fw_mac_addr(&rule_entry->pair.mac_msb,
-				      &rule_entry->pair.mac_mid,
-				      &rule_entry->pair.mac_lsb, mac);
-		rule_entry->pair.inner_mac =
-			cpu_to_le16(elem->cmd_data.vlan_mac.u.
-						vlan_mac.is_inner_mac);
-	}
-
-	/* Set the ramrod data header */
-	/* TODO: take this to the higher level in order to prevent multiple
-		 writing */
-	bnx2x_vlan_mac_set_rdata_hdr_e2(raw->cid, raw->state, &data->header,
-					rule_cnt);
-}
-
-/**
- * bnx2x_set_one_vlan_mac_e1h -
- *
- * @bp:		device handle
- * @o:		bnx2x_vlan_mac_obj
- * @elem:	bnx2x_exeq_elem
- * @rule_idx:	rule_idx
- * @cam_offset:	cam_offset
- */
-static void bnx2x_set_one_vlan_mac_e1h(struct bnx2x *bp,
-				       struct bnx2x_vlan_mac_obj *o,
-				       struct bnx2x_exeq_elem *elem,
-				       int rule_idx, int cam_offset)
-{
-	struct bnx2x_raw_obj *raw = &o->raw;
-	struct mac_configuration_cmd *config =
-		(struct mac_configuration_cmd *)(raw->rdata);
-	/* 57710 and 57711 do not support MOVE command,
-	 * so it's either ADD or DEL
-	 */
-	bool add = (elem->cmd_data.vlan_mac.cmd == BNX2X_VLAN_MAC_ADD) ?
-		true : false;
-
-	/* Reset the ramrod data buffer */
-	memset(config, 0, sizeof(*config));
-
-	bnx2x_vlan_mac_set_rdata_e1x(bp, o, BNX2X_FILTER_VLAN_MAC_PENDING,
-				     cam_offset, add,
-				     elem->cmd_data.vlan_mac.u.vlan_mac.mac,
-				     elem->cmd_data.vlan_mac.u.vlan_mac.vlan,
-				     ETH_VLAN_FILTER_CLASSIFY, config);
-}
-
 /**
  * bnx2x_vlan_mac_restore - reconfigure next MAC/VLAN/VLAN-MAC element
  *
@@ -1316,23 +1135,6 @@ static struct bnx2x_exeq_elem *bnx2x_exe
 	return NULL;
 }
 
-static struct bnx2x_exeq_elem *bnx2x_exeq_get_vlan_mac(
-	struct bnx2x_exe_queue_obj *o,
-	struct bnx2x_exeq_elem *elem)
-{
-	struct bnx2x_exeq_elem *pos;
-	struct bnx2x_vlan_mac_ramrod_data *data =
-		&elem->cmd_data.vlan_mac.u.vlan_mac;
-
-	/* Check pending for execution commands */
-	list_for_each_entry(pos, &o->exe_queue, link)
-		if (!memcmp(&pos->cmd_data.vlan_mac.u.vlan_mac, data,
-			      sizeof(*data)) &&
-		    (pos->cmd_data.vlan_mac.cmd == elem->cmd_data.vlan_mac.cmd))
-			return pos;
-
-	return NULL;
-}
 
 /**
  * bnx2x_validate_vlan_mac_add - check if an ADD command can be executed
@@ -2237,69 +2039,6 @@ void bnx2x_init_vlan_obj(struct bnx2x *b
 	}
 }
 
-void bnx2x_init_vlan_mac_obj(struct bnx2x *bp,
-			     struct bnx2x_vlan_mac_obj *vlan_mac_obj,
-			     u8 cl_id, u32 cid, u8 func_id, void *rdata,
-			     dma_addr_t rdata_mapping, int state,
-			     unsigned long *pstate, bnx2x_obj_type type,
-			     struct bnx2x_credit_pool_obj *macs_pool,
-			     struct bnx2x_credit_pool_obj *vlans_pool)
-{
-	union bnx2x_qable_obj *qable_obj =
-		(union bnx2x_qable_obj *)vlan_mac_obj;
-
-	bnx2x_init_vlan_mac_common(vlan_mac_obj, cl_id, cid, func_id, rdata,
-				   rdata_mapping, state, pstate, type,
-				   macs_pool, vlans_pool);
-
-	/* CAM pool handling */
-	vlan_mac_obj->get_credit = bnx2x_get_credit_vlan_mac;
-	vlan_mac_obj->put_credit = bnx2x_put_credit_vlan_mac;
-	/* CAM offset is relevant for 57710 and 57711 chips only which have a
-	 * single CAM for both MACs and VLAN-MAC pairs. So the offset
-	 * will be taken from MACs' pool object only.
-	 */
-	vlan_mac_obj->get_cam_offset = bnx2x_get_cam_offset_mac;
-	vlan_mac_obj->put_cam_offset = bnx2x_put_cam_offset_mac;
-
-	if (CHIP_IS_E1(bp)) {
-		BNX2X_ERR("Do not support chips others than E2\n");
-		BUG();
-	} else if (CHIP_IS_E1H(bp)) {
-		vlan_mac_obj->set_one_rule      = bnx2x_set_one_vlan_mac_e1h;
-		vlan_mac_obj->check_del         = bnx2x_check_vlan_mac_del;
-		vlan_mac_obj->check_add         = bnx2x_check_vlan_mac_add;
-		vlan_mac_obj->check_move        = bnx2x_check_move_always_err;
-		vlan_mac_obj->ramrod_cmd        = RAMROD_CMD_ID_ETH_SET_MAC;
-
-		/* Exe Queue */
-		bnx2x_exe_queue_init(bp,
-				     &vlan_mac_obj->exe_queue, 1, qable_obj,
-				     bnx2x_validate_vlan_mac,
-				     bnx2x_remove_vlan_mac,
-				     bnx2x_optimize_vlan_mac,
-				     bnx2x_execute_vlan_mac,
-				     bnx2x_exeq_get_vlan_mac);
-	} else {
-		vlan_mac_obj->set_one_rule      = bnx2x_set_one_vlan_mac_e2;
-		vlan_mac_obj->check_del         = bnx2x_check_vlan_mac_del;
-		vlan_mac_obj->check_add         = bnx2x_check_vlan_mac_add;
-		vlan_mac_obj->check_move        = bnx2x_check_move;
-		vlan_mac_obj->ramrod_cmd        =
-			RAMROD_CMD_ID_ETH_CLASSIFICATION_RULES;
-
-		/* Exe Queue */
-		bnx2x_exe_queue_init(bp,
-				     &vlan_mac_obj->exe_queue,
-				     CLASSIFY_RULES_COUNT,
-				     qable_obj, bnx2x_validate_vlan_mac,
-				     bnx2x_remove_vlan_mac,
-				     bnx2x_optimize_vlan_mac,
-				     bnx2x_execute_vlan_mac,
-				     bnx2x_exeq_get_vlan_mac);
-	}
-}
-
 /* RX_MODE verbs: DROP_ALL/ACCEPT_ALL/ACCEPT_ALL_MULTI/ACCEPT_ALL_VLAN/NORMAL */
 static inline void __storm_memset_mac_filters(struct bnx2x *bp,
 			struct tstorm_eth_mac_filter_config *mac_filters,
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h	2013-12-12 12:28:44.744527896 -0800
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h	2013-12-13 16:49:50.489376105 -0800
@@ -441,9 +441,6 @@ enum {
 	BNX2X_LLH_CAM_MAX_PF_LINE = NIG_REG_LLH1_FUNC_MEM_SIZE / 2
 };
 
-void bnx2x_set_mac_in_nig(struct bnx2x *bp,
-			  bool add, unsigned char *dev_addr, int index);
-
 /** RX_MODE verbs:DROP_ALL/ACCEPT_ALL/ACCEPT_ALL_MULTI/ACCEPT_ALL_VLAN/NORMAL */
 
 /* RX_MODE ramrod special flags: set in rx_mode_flags field in
@@ -1300,22 +1297,12 @@ void bnx2x_init_vlan_obj(struct bnx2x *b
 			 unsigned long *pstate, bnx2x_obj_type type,
 			 struct bnx2x_credit_pool_obj *vlans_pool);
 
-void bnx2x_init_vlan_mac_obj(struct bnx2x *bp,
-			     struct bnx2x_vlan_mac_obj *vlan_mac_obj,
-			     u8 cl_id, u32 cid, u8 func_id, void *rdata,
-			     dma_addr_t rdata_mapping, int state,
-			     unsigned long *pstate, bnx2x_obj_type type,
-			     struct bnx2x_credit_pool_obj *macs_pool,
-			     struct bnx2x_credit_pool_obj *vlans_pool);
-
 int bnx2x_vlan_mac_h_read_lock(struct bnx2x *bp,
 					struct bnx2x_vlan_mac_obj *o);
 void bnx2x_vlan_mac_h_read_unlock(struct bnx2x *bp,
 				  struct bnx2x_vlan_mac_obj *o);
 int bnx2x_vlan_mac_h_write_lock(struct bnx2x *bp,
 				struct bnx2x_vlan_mac_obj *o);
-void bnx2x_vlan_mac_h_write_unlock(struct bnx2x *bp,
-					  struct bnx2x_vlan_mac_obj *o);
 int bnx2x_config_vlan_mac(struct bnx2x *bp,
 			   struct bnx2x_vlan_mac_ramrod_params *p);
 
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c	2013-12-12 12:28:44.744527896 -0800
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c	2013-12-13 16:50:28.524774974 -0800
@@ -798,10 +798,10 @@ int bnx2x_vfop_mac_list_cmd(struct bnx2x
 	return -ENOMEM;
 }
 
-int bnx2x_vfop_vlan_set_cmd(struct bnx2x *bp,
-			    struct bnx2x_virtf *vf,
-			    struct bnx2x_vfop_cmd *cmd,
-			    int qid, u16 vid, bool add)
+static int bnx2x_vfop_vlan_set_cmd(struct bnx2x *bp,
+				   struct bnx2x_virtf *vf,
+				   struct bnx2x_vfop_cmd *cmd,
+				   int qid, u16 vid, bool add)
 {
 	struct bnx2x_vfop *vfop = bnx2x_vfop_add(bp, vf);
 	int rc;
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h	2013-12-12 12:28:44.744527896 -0800
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.h	2013-12-13 17:19:52.402331971 -0800
@@ -663,11 +663,6 @@ int bnx2x_vfop_mac_list_cmd(struct bnx2x
 			    struct bnx2x_vfop_filters *macs,
 			    int qid, bool drv_only);
 
-int bnx2x_vfop_vlan_set_cmd(struct bnx2x *bp,
-			    struct bnx2x_virtf *vf,
-			    struct bnx2x_vfop_cmd *cmd,
-			    int qid, u16 vid, bool add);
-
 int bnx2x_vfop_vlan_list_cmd(struct bnx2x *bp,
 			     struct bnx2x_virtf *vf,
 			     struct bnx2x_vfop_cmd *cmd,
@@ -725,13 +720,6 @@ void bnx2x_vf_enable_access(struct bnx2x
 /* Handles an FLR (or VF_DISABLE) notification form the MCP */
 void bnx2x_vf_handle_flr_event(struct bnx2x *bp);
 
-void bnx2x_add_tlv(struct bnx2x *bp, void *tlvs_list, u16 offset, u16 type,
-		   u16 length);
-void bnx2x_vfpf_prep(struct bnx2x *bp, struct vfpf_first_tlv *first_tlv,
-		     u16 type, u16 length);
-void bnx2x_vfpf_finalize(struct bnx2x *bp, struct vfpf_first_tlv *first_tlv);
-void bnx2x_dp_tlv_list(struct bnx2x *bp, void *tlvs_list);
-
 bool bnx2x_tlv_supported(u16 tlvtype);
 
 u32 bnx2x_crc_vf_bulletin(struct bnx2x *bp,
@@ -748,7 +736,6 @@ int bnx2x_vfpf_init(struct bnx2x *bp);
 void bnx2x_vfpf_close_vf(struct bnx2x *bp);
 int bnx2x_vfpf_setup_q(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 		       bool is_leading);
-int bnx2x_vfpf_teardown_queue(struct bnx2x *bp, int qidx);
 int bnx2x_vfpf_config_mac(struct bnx2x *bp, u8 *addr, u8 vf_qid, bool set);
 int bnx2x_vfpf_config_rss(struct bnx2x *bp,
 			  struct bnx2x_config_rss_params *params);
@@ -812,7 +799,6 @@ static inline int bnx2x_vfpf_release(str
 static inline int bnx2x_vfpf_init(struct bnx2x *bp) {return 0; }
 static inline void bnx2x_vfpf_close_vf(struct bnx2x *bp) {}
 static inline int bnx2x_vfpf_setup_q(struct bnx2x *bp, struct bnx2x_fastpath *fp, bool is_leading) {return 0; }
-static inline int bnx2x_vfpf_teardown_queue(struct bnx2x *bp, int qidx) {return 0; }
 static inline int bnx2x_vfpf_config_mac(struct bnx2x *bp, u8 *addr,
 					u8 vf_qid, bool set) {return 0; }
 static inline int bnx2x_vfpf_config_rss(struct bnx2x *bp,
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.mod.c	2013-12-13 11:41:04.637983755 -0800
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.mod.c	2013-12-13 17:23:34.407405346 -0800
@@ -23,14 +23,14 @@ __attribute__((section("__versions"))) =
 	{ 0x53c4fe30, __VMLINUX_SYMBOL_STR(rcu_lock_map) },
 	{        0, __VMLINUX_SYMBOL_STR(alloc_pages_current) },
 	{ 0x2d3385d3, __VMLINUX_SYMBOL_STR(system_wq) },
-	{ 0xf17383f8, __VMLINUX_SYMBOL_STR(netdev_info) },
+	{ 0x402e9763, __VMLINUX_SYMBOL_STR(netdev_info) },
 	{ 0x429e4adf, __VMLINUX_SYMBOL_STR(kmalloc_caches) },
 	{ 0x20806298, __VMLINUX_SYMBOL_STR(pci_bus_read_config_byte) },
 	{ 0xd2b09ce5, __VMLINUX_SYMBOL_STR(__kmalloc) },
-	{ 0x18a296c5, __VMLINUX_SYMBOL_STR(ethtool_op_get_ts_info) },
+	{ 0xeb8b795c, __VMLINUX_SYMBOL_STR(ethtool_op_get_ts_info) },
 	{ 0xf9a482f9, __VMLINUX_SYMBOL_STR(msleep) },
 	{ 0x77ecac9f, __VMLINUX_SYMBOL_STR(zlib_inflateEnd) },
-	{ 0xabe8720, __VMLINUX_SYMBOL_STR(skb_clone_tx_timestamp) },
+	{ 0x43ba4501, __VMLINUX_SYMBOL_STR(skb_clone_tx_timestamp) },
 	{ 0x3c9390db, __VMLINUX_SYMBOL_STR(pci_vpd_find_tag) },
 	{ 0xd369a6ea, __VMLINUX_SYMBOL_STR(pci_enable_sriov) },
 	{ 0x26ac900d, __VMLINUX_SYMBOL_STR(_raw_spin_unlock) },
@@ -42,24 +42,24 @@ __attribute__((section("__versions"))) =
 	{ 0x71b629b8, __VMLINUX_SYMBOL_STR(__alloc_workqueue_key) },
 	{ 0x79aa04a2, __VMLINUX_SYMBOL_STR(get_random_bytes) },
 	{ 0x4cc84397, __VMLINUX_SYMBOL_STR(dma_set_mask) },
-	{ 0xa53aa63e, __VMLINUX_SYMBOL_STR(napi_complete) },
-	{ 0xee901eed, __VMLINUX_SYMBOL_STR(napi_hash_del) },
+	{ 0xc998f67e, __VMLINUX_SYMBOL_STR(napi_complete) },
+	{ 0x66ec135, __VMLINUX_SYMBOL_STR(napi_hash_del) },
 	{ 0xe97d7707, __VMLINUX_SYMBOL_STR(pci_disable_device) },
 	{ 0xc7a4fbed, __VMLINUX_SYMBOL_STR(rtnl_lock) },
 	{ 0xd1d0669c, __VMLINUX_SYMBOL_STR(pci_disable_msix) },
 	{ 0x4ea25709, __VMLINUX_SYMBOL_STR(dql_reset) },
-	{ 0xbd1ca50d, __VMLINUX_SYMBOL_STR(netif_carrier_on) },
+	{ 0xf3f0ddac, __VMLINUX_SYMBOL_STR(netif_carrier_on) },
 	{ 0x7a188791, __VMLINUX_SYMBOL_STR(prandom_bytes) },
 	{ 0x809ac169, __VMLINUX_SYMBOL_STR(_raw_spin_lock_bh) },
-	{ 0x5955780e, __VMLINUX_SYMBOL_STR(tcp_gro_complete) },
+	{ 0x2eaf1a93, __VMLINUX_SYMBOL_STR(tcp_gro_complete) },
 	{ 0xc9be421f, __VMLINUX_SYMBOL_STR(pci_disable_sriov) },
 	{ 0x6b06fdce, __VMLINUX_SYMBOL_STR(delayed_work_timer_fn) },
 	{ 0x46856953, __VMLINUX_SYMBOL_STR(down_interruptible) },
-	{ 0x6163fc06, __VMLINUX_SYMBOL_STR(netif_carrier_off) },
-	{ 0x4737a8ab, __VMLINUX_SYMBOL_STR(__netdev_pick_tx) },
+	{ 0xf4116d7b, __VMLINUX_SYMBOL_STR(netif_carrier_off) },
+	{ 0x1cf9ce77, __VMLINUX_SYMBOL_STR(__netdev_pick_tx) },
 	{ 0x22bce513, __VMLINUX_SYMBOL_STR(mdio_mii_ioctl) },
 	{ 0xcd80aeb3, __VMLINUX_SYMBOL_STR(x86_dma_fallback_dev) },
-	{ 0x712e2bea, __VMLINUX_SYMBOL_STR(__dev_kfree_skb_any) },
+	{ 0x801ae1a5, __VMLINUX_SYMBOL_STR(__dev_kfree_skb_any) },
 	{ 0xeae3dfd6, __VMLINUX_SYMBOL_STR(__const_udelay) },
 	{ 0xba58dbd9, __VMLINUX_SYMBOL_STR(pci_release_regions) },
 	{ 0x159de811, __VMLINUX_SYMBOL_STR(init_timer_key) },
@@ -72,13 +72,13 @@ __attribute__((section("__versions"))) =
 	{ 0x274dc2b, __VMLINUX_SYMBOL_STR(netif_get_num_default_rss_queues) },
 	{ 0x27000b29, __VMLINUX_SYMBOL_STR(crc32c) },
 	{ 0x91715312, __VMLINUX_SYMBOL_STR(sprintf) },
-	{ 0x8bb85c61, __VMLINUX_SYMBOL_STR(netif_napi_del) },
+	{ 0xc087ffc3, __VMLINUX_SYMBOL_STR(netif_napi_del) },
 	{ 0x7d11c268, __VMLINUX_SYMBOL_STR(jiffies) },
 	{ 0x6bcb6e07, __VMLINUX_SYMBOL_STR(__might_sleep) },
-	{ 0xd1e42585, __VMLINUX_SYMBOL_STR(__netdev_alloc_skb) },
+	{ 0xa1c85670, __VMLINUX_SYMBOL_STR(__netdev_alloc_skb) },
 	{ 0x27c33efe, __VMLINUX_SYMBOL_STR(csum_ipv6_magic) },
 	{ 0x4a0e4bde, __VMLINUX_SYMBOL_STR(lock_release) },
-	{ 0x21816eff, __VMLINUX_SYMBOL_STR(__pskb_pull_tail) },
+	{ 0x33c575fa, __VMLINUX_SYMBOL_STR(__pskb_pull_tail) },
 	{ 0x4730457d, __VMLINUX_SYMBOL_STR(pci_set_master) },
 	{ 0xab70ad05, __VMLINUX_SYMBOL_STR(del_timer_sync) },
 	{ 0xfe096515, __VMLINUX_SYMBOL_STR(lock_acquire) },
@@ -86,18 +86,18 @@ __attribute__((section("__versions"))) =
 	{ 0x3a2385b7, __VMLINUX_SYMBOL_STR(cancel_delayed_work) },
 	{ 0x838c2004, __VMLINUX_SYMBOL_STR(pci_enable_msix) },
 	{ 0x2bd98c5d, __VMLINUX_SYMBOL_STR(pci_restore_state) },
-	{ 0xc523d03f, __VMLINUX_SYMBOL_STR(dev_err) },
-	{ 0x9154da5b, __VMLINUX_SYMBOL_STR(dev_addr_del) },
+	{ 0x166f16f7, __VMLINUX_SYMBOL_STR(dev_err) },
+	{ 0xd62c7b59, __VMLINUX_SYMBOL_STR(dev_addr_del) },
 	{ 0x8aa3e373, __VMLINUX_SYMBOL_STR(down_trylock) },
 	{ 0x9bbd9894, __VMLINUX_SYMBOL_STR(__mutex_init) },
 	{ 0x27e1a049, __VMLINUX_SYMBOL_STR(printk) },
 	{ 0x449ad0a7, __VMLINUX_SYMBOL_STR(memcmp) },
 	{ 0xa00aca2a, __VMLINUX_SYMBOL_STR(dql_completed) },
 	{ 0x4c9d28b0, __VMLINUX_SYMBOL_STR(phys_base) },
-	{ 0xbbc11b87, __VMLINUX_SYMBOL_STR(free_netdev) },
+	{ 0x2f5ee645, __VMLINUX_SYMBOL_STR(free_netdev) },
 	{ 0xa1c76e0a, __VMLINUX_SYMBOL_STR(_cond_resched) },
-	{ 0x2d69bd0f, __VMLINUX_SYMBOL_STR(register_netdev) },
-	{ 0x3ada3701, __VMLINUX_SYMBOL_STR(netif_receive_skb) },
+	{ 0xd6cac1c8, __VMLINUX_SYMBOL_STR(register_netdev) },
+	{ 0xd00ebb74, __VMLINUX_SYMBOL_STR(netif_receive_skb) },
 	{ 0xce5ac24f, __VMLINUX_SYMBOL_STR(zlib_inflate_workspacesize) },
 	{ 0x5a921311, __VMLINUX_SYMBOL_STR(strncmp) },
 	{ 0xb53620d1, __VMLINUX_SYMBOL_STR(pci_vpd_find_info_keyword) },
@@ -107,46 +107,46 @@ __attribute__((section("__versions"))) =
 	{ 0x3b7e69ab, __VMLINUX_SYMBOL_STR(pci_get_domain_bus_and_slot) },
 	{ 0x802d0e93, __VMLINUX_SYMBOL_STR(crc32_le) },
 	{ 0x8c03d20c, __VMLINUX_SYMBOL_STR(destroy_workqueue) },
-	{ 0xa3a29992, __VMLINUX_SYMBOL_STR(dev_close) },
-	{ 0xbf6beff6, __VMLINUX_SYMBOL_STR(netdev_printk) },
+	{ 0x30af308f, __VMLINUX_SYMBOL_STR(dev_close) },
+	{ 0x84d02dbd, __VMLINUX_SYMBOL_STR(netdev_printk) },
 	{ 0x44d5b5d9, __VMLINUX_SYMBOL_STR(pci_wait_for_pending_transaction) },
 	{ 0x51240bdc, __VMLINUX_SYMBOL_STR(down) },
-	{ 0xc611b9cb, __VMLINUX_SYMBOL_STR(netif_set_real_num_rx_queues) },
+	{ 0x916322f5, __VMLINUX_SYMBOL_STR(netif_set_real_num_rx_queues) },
 	{ 0xc2cdbf1, __VMLINUX_SYMBOL_STR(synchronize_sched) },
 	{ 0xa5882aae, __VMLINUX_SYMBOL_STR(mod_timer) },
-	{ 0x2877d37f, __VMLINUX_SYMBOL_STR(netif_set_real_num_tx_queues) },
-	{ 0x99832419, __VMLINUX_SYMBOL_STR(netif_napi_add) },
+	{ 0x1205ef44, __VMLINUX_SYMBOL_STR(netif_set_real_num_tx_queues) },
+	{ 0x424f7d79, __VMLINUX_SYMBOL_STR(netif_napi_add) },
 	{ 0xd6b8e852, __VMLINUX_SYMBOL_STR(request_threaded_irq) },
 	{ 0x3be905e5, __VMLINUX_SYMBOL_STR(__get_page_tail) },
 	{ 0x42160169, __VMLINUX_SYMBOL_STR(flush_workqueue) },
 	{ 0xe523ad75, __VMLINUX_SYMBOL_STR(synchronize_irq) },
-	{ 0x333aadcc, __VMLINUX_SYMBOL_STR(build_skb) },
+	{ 0xf1048363, __VMLINUX_SYMBOL_STR(build_skb) },
 	{ 0x881039d0, __VMLINUX_SYMBOL_STR(zlib_inflate) },
 	{ 0xc6cbbc89, __VMLINUX_SYMBOL_STR(capable) },
 	{ 0x3ff62317, __VMLINUX_SYMBOL_STR(local_bh_disable) },
-	{ 0x6f647f44, __VMLINUX_SYMBOL_STR(netif_device_attach) },
-	{ 0x47c522f0, __VMLINUX_SYMBOL_STR(napi_gro_receive) },
-	{ 0x2376f214, __VMLINUX_SYMBOL_STR(_dev_info) },
+	{ 0x71a07217, __VMLINUX_SYMBOL_STR(netif_device_attach) },
+	{ 0xbf116787, __VMLINUX_SYMBOL_STR(napi_gro_receive) },
+	{ 0xba72546d, __VMLINUX_SYMBOL_STR(_dev_info) },
 	{ 0x35ec9aad, __VMLINUX_SYMBOL_STR(kmem_cache_alloc) },
 	{ 0x78764f4e, __VMLINUX_SYMBOL_STR(pv_irq_ops) },
-	{ 0x7864de34, __VMLINUX_SYMBOL_STR(dev_addr_add) },
+	{ 0x18434044, __VMLINUX_SYMBOL_STR(dev_addr_add) },
 	{ 0x35c34cfa, __VMLINUX_SYMBOL_STR(__free_pages) },
-	{ 0x7c809aca, __VMLINUX_SYMBOL_STR(netif_device_detach) },
+	{ 0xcf802453, __VMLINUX_SYMBOL_STR(netif_device_detach) },
 	{ 0x42c8de35, __VMLINUX_SYMBOL_STR(ioremap_nocache) },
 	{ 0x12a38747, __VMLINUX_SYMBOL_STR(usleep_range) },
 	{ 0xd37cf8b0, __VMLINUX_SYMBOL_STR(pci_bus_read_config_word) },
-	{ 0x483b928a, __VMLINUX_SYMBOL_STR(__napi_schedule) },
+	{ 0x101ac060, __VMLINUX_SYMBOL_STR(__napi_schedule) },
 	{ 0x559e7837, __VMLINUX_SYMBOL_STR(pci_bus_read_config_dword) },
 	{ 0x93fca811, __VMLINUX_SYMBOL_STR(__get_free_pages) },
 	{ 0x3e1f69df, __VMLINUX_SYMBOL_STR(_raw_spin_unlock_bh) },
 	{ 0x5c40ebae, __VMLINUX_SYMBOL_STR(queue_delayed_work_on) },
 	{ 0x7e0cf32b, __VMLINUX_SYMBOL_STR(pci_intx) },
-	{ 0x77f359b, __VMLINUX_SYMBOL_STR(napi_hash_add) },
+	{ 0x6fd4de37, __VMLINUX_SYMBOL_STR(napi_hash_add) },
 	{ 0x6b2dc060, __VMLINUX_SYMBOL_STR(dump_stack) },
 	{ 0x799aca4, __VMLINUX_SYMBOL_STR(local_bh_enable) },
 	{ 0x31b2b7b0, __VMLINUX_SYMBOL_STR(__raw_spin_lock_init) },
-	{ 0xf8bc14da, __VMLINUX_SYMBOL_STR(eth_type_trans) },
-	{ 0x4990a89a, __VMLINUX_SYMBOL_STR(netdev_err) },
+	{ 0x10472b34, __VMLINUX_SYMBOL_STR(eth_type_trans) },
+	{ 0x474f0fdb, __VMLINUX_SYMBOL_STR(netdev_err) },
 	{ 0xaca9c329, __VMLINUX_SYMBOL_STR(pci_unregister_driver) },
 	{ 0xd9921248, __VMLINUX_SYMBOL_STR(_raw_spin_lock) },
 	{ 0xb8dfd0f8, __VMLINUX_SYMBOL_STR(pci_ioremap_bar) },
@@ -166,20 +166,20 @@ __attribute__((section("__versions"))) =
 	{ 0x8263899a, __VMLINUX_SYMBOL_STR(put_page) },
 	{ 0x89c0ed7c, __VMLINUX_SYMBOL_STR(lockdep_init_map) },
 	{ 0xd2303d52, __VMLINUX_SYMBOL_STR(request_firmware) },
-	{ 0x60368da4, __VMLINUX_SYMBOL_STR(unregister_netdev) },
+	{ 0x552b1e3b, __VMLINUX_SYMBOL_STR(unregister_netdev) },
 	{ 0x28318305, __VMLINUX_SYMBOL_STR(snprintf) },
 	{ 0x859f568b, __VMLINUX_SYMBOL_STR(pci_enable_msi_block) },
 	{ 0xd9fcf04c, __VMLINUX_SYMBOL_STR(pci_choose_state) },
-	{ 0xe167394, __VMLINUX_SYMBOL_STR(__netif_schedule) },
+	{ 0xaa7c7243, __VMLINUX_SYMBOL_STR(__netif_schedule) },
 	{ 0xe113bbbc, __VMLINUX_SYMBOL_STR(csum_partial) },
-	{ 0xd94545a5, __VMLINUX_SYMBOL_STR(consume_skb) },
+	{ 0xd8903b5f, __VMLINUX_SYMBOL_STR(consume_skb) },
 	{ 0x85670f1d, __VMLINUX_SYMBOL_STR(rtnl_is_locked) },
-	{ 0x4180adf8, __VMLINUX_SYMBOL_STR(skb_tstamp_tx) },
-	{ 0x14e86a1b, __VMLINUX_SYMBOL_STR(skb_put) },
+	{ 0x4252b96b, __VMLINUX_SYMBOL_STR(skb_tstamp_tx) },
+	{ 0x9fdecbfb, __VMLINUX_SYMBOL_STR(skb_put) },
 	{ 0x1fe8f5b4, __VMLINUX_SYMBOL_STR(pci_enable_device) },
 	{ 0xd8263d17, __VMLINUX_SYMBOL_STR(pci_wake_from_d3) },
 	{ 0xb5f6edbd, __VMLINUX_SYMBOL_STR(pci_read_vpd) },
-	{ 0xed24e118, __VMLINUX_SYMBOL_STR(skb_copy_bits) },
+	{ 0xcd4d5f24, __VMLINUX_SYMBOL_STR(skb_copy_bits) },
 	{ 0x5e111069, __VMLINUX_SYMBOL_STR(dev_get_drvdata) },
 	{ 0x6df657cd, __VMLINUX_SYMBOL_STR(down_timeout) },
 	{ 0x45538d9e, __VMLINUX_SYMBOL_STR(pci_find_ext_capability) },
@@ -191,7 +191,7 @@ __attribute__((section("__versions"))) =
 	{ 0xf20dabd8, __VMLINUX_SYMBOL_STR(free_irq) },
 	{ 0xa9e682de, __VMLINUX_SYMBOL_STR(pci_save_state) },
 	{ 0xe914e41e, __VMLINUX_SYMBOL_STR(strcpy) },
-	{ 0x796b6aa7, __VMLINUX_SYMBOL_STR(alloc_etherdev_mqs) },
+	{ 0x817c1e3b, __VMLINUX_SYMBOL_STR(alloc_etherdev_mqs) },
 };
 
 static const char __module_depends[]
@@ -221,4 +221,4 @@ MODULE_ALIAS("pci:v000014E4d0000163Dsv*s
 MODULE_ALIAS("pci:v000014E4d0000163Esv*sd*bc*sc*i*");
 MODULE_ALIAS("pci:v000014E4d0000163Fsv*sd*bc*sc*i*");
 
-MODULE_INFO(srcversion, "1F2CFB773C08BE9D4F83F7A");
+MODULE_INFO(srcversion, "F26FD4F30CA2440A52BE35C");
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c	2013-12-12 12:28:44.744527896 -0800
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c	2013-12-13 17:15:31.677812282 -0800
@@ -189,6 +189,11 @@ typedef int (*read_sfp_module_eeprom_fun
 #define MAX_PACKET_SIZE					(9700)
 #define MAX_KR_LINK_RETRY				4
 
+static int bnx2x_sfp_module_detection(struct bnx2x_phy *phy,
+				      struct link_params *params);
+static int bnx2x_check_half_open_conn(struct link_params *params,
+				      struct link_vars *vars, u8 notify);
+
 /**********************************************************/
 /*                     INTERFACE                          */
 /**********************************************************/
@@ -1399,57 +1404,6 @@ static void bnx2x_update_pfc_xmac(struct
 	udelay(30);
 }
 
-
-static void bnx2x_emac_get_pfc_stat(struct link_params *params,
-				    u32 pfc_frames_sent[2],
-				    u32 pfc_frames_received[2])
-{
-	/* Read pfc statistic */
-	struct bnx2x *bp = params->bp;
-	u32 emac_base = params->port ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
-	u32 val_xon = 0;
-	u32 val_xoff = 0;
-
-	DP(NETIF_MSG_LINK, "pfc statistic read from EMAC\n");
-
-	/* PFC received frames */
-	val_xoff = REG_RD(bp, emac_base +
-				EMAC_REG_RX_PFC_STATS_XOFF_RCVD);
-	val_xoff &= EMAC_REG_RX_PFC_STATS_XOFF_RCVD_COUNT;
-	val_xon = REG_RD(bp, emac_base + EMAC_REG_RX_PFC_STATS_XON_RCVD);
-	val_xon &= EMAC_REG_RX_PFC_STATS_XON_RCVD_COUNT;
-
-	pfc_frames_received[0] = val_xon + val_xoff;
-
-	/* PFC received sent */
-	val_xoff = REG_RD(bp, emac_base +
-				EMAC_REG_RX_PFC_STATS_XOFF_SENT);
-	val_xoff &= EMAC_REG_RX_PFC_STATS_XOFF_SENT_COUNT;
-	val_xon = REG_RD(bp, emac_base + EMAC_REG_RX_PFC_STATS_XON_SENT);
-	val_xon &= EMAC_REG_RX_PFC_STATS_XON_SENT_COUNT;
-
-	pfc_frames_sent[0] = val_xon + val_xoff;
-}
-
-/* Read pfc statistic*/
-void bnx2x_pfc_statistic(struct link_params *params, struct link_vars *vars,
-			 u32 pfc_frames_sent[2],
-			 u32 pfc_frames_received[2])
-{
-	/* Read pfc statistic */
-	struct bnx2x *bp = params->bp;
-
-	DP(NETIF_MSG_LINK, "pfc statistic\n");
-
-	if (!vars->link_up)
-		return;
-
-	if (vars->mac_type == MAC_TYPE_EMAC) {
-		DP(NETIF_MSG_LINK, "About to read PFC stats from EMAC\n");
-		bnx2x_emac_get_pfc_stat(params, pfc_frames_sent,
-					pfc_frames_received);
-	}
-}
 /******************************************************************/
 /*			MAC/PBF section				  */
 /******************************************************************/
@@ -8632,8 +8586,8 @@ static void bnx2x_set_limiting_mode(stru
 	}
 }
 
-int bnx2x_sfp_module_detection(struct bnx2x_phy *phy,
-			       struct link_params *params)
+static int bnx2x_sfp_module_detection(struct bnx2x_phy *phy,
+				      struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
 	u16 edc_mode;
@@ -13391,9 +13345,9 @@ static u8 bnx2x_analyze_link_error(struc
 *	a fault, for example, due to break in the TX side of fiber.
 *
 ******************************************************************************/
-int bnx2x_check_half_open_conn(struct link_params *params,
-				struct link_vars *vars,
-				u8 notify)
+static int bnx2x_check_half_open_conn(struct link_params *params,
+				      struct link_vars *vars,
+				      u8 notify)
 {
 	struct bnx2x *bp = params->bp;
 	u32 lss_status = 0;
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h	2013-12-12 12:28:44.744527896 -0800
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h	2013-12-13 17:15:16.462014792 -0800
@@ -534,18 +534,10 @@ int bnx2x_ets_e3b0_config(const struct l
 			 const struct link_vars *vars,
 			 struct bnx2x_ets_params *ets_params);
 /* Read pfc statistic*/
-void bnx2x_pfc_statistic(struct link_params *params, struct link_vars *vars,
-						 u32 pfc_frames_sent[2],
-						 u32 pfc_frames_received[2]);
 void bnx2x_init_mod_abs_int(struct bnx2x *bp, struct link_vars *vars,
 			    u32 chip_id, u32 shmem_base, u32 shmem2_base,
 			    u8 port);
 
-int bnx2x_sfp_module_detection(struct bnx2x_phy *phy,
-			       struct link_params *params);
-
 void bnx2x_period_func(struct link_params *params, struct link_vars *vars);
 
-int bnx2x_check_half_open_conn(struct link_params *params,
-			       struct link_vars *vars, u8 notify);
 #endif /* BNX2X_LINK_H */
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c	2013-12-12 12:28:44.744527896 -0800
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_vfpf.c	2013-12-13 17:23:20.887584769 -0800
@@ -21,9 +21,11 @@
 #include "bnx2x_cmn.h"
 #include <linux/crc32.h>
 
+static int bnx2x_vfpf_teardown_queue(struct bnx2x *bp, int qidx);
+
 /* place a given tlv on the tlv buffer at a given offset */
-void bnx2x_add_tlv(struct bnx2x *bp, void *tlvs_list, u16 offset, u16 type,
-		   u16 length)
+static void bnx2x_add_tlv(struct bnx2x *bp, void *tlvs_list, u16 offset,
+			  u16 type, u16 length)
 {
 	struct channel_tlv *tl =
 		(struct channel_tlv *)(tlvs_list + offset);
@@ -33,8 +35,8 @@ void bnx2x_add_tlv(struct bnx2x *bp, voi
 }
 
 /* Clear the mailbox and init the header of the first tlv */
-void bnx2x_vfpf_prep(struct bnx2x *bp, struct vfpf_first_tlv *first_tlv,
-		     u16 type, u16 length)
+static void bnx2x_vfpf_prep(struct bnx2x *bp, struct vfpf_first_tlv *first_tlv,
+			    u16 type, u16 length)
 {
 	mutex_lock(&bp->vf2pf_mutex);
 
@@ -52,7 +54,8 @@ void bnx2x_vfpf_prep(struct bnx2x *bp, s
 }
 
 /* releases the mailbox */
-void bnx2x_vfpf_finalize(struct bnx2x *bp, struct vfpf_first_tlv *first_tlv)
+static void bnx2x_vfpf_finalize(struct bnx2x *bp,
+				struct vfpf_first_tlv *first_tlv)
 {
 	DP(BNX2X_MSG_IOV, "done sending [%d] tlv over vf pf channel\n",
 	   first_tlv->tl.type);
@@ -85,7 +88,7 @@ static void *bnx2x_search_tlv_list(struc
 }
 
 /* list the types and lengths of the tlvs on the buffer */
-void bnx2x_dp_tlv_list(struct bnx2x *bp, void *tlvs_list)
+static void bnx2x_dp_tlv_list(struct bnx2x *bp, void *tlvs_list)
 {
 	int i = 1;
 	struct channel_tlv *tlv = (struct channel_tlv *)tlvs_list;
@@ -633,7 +636,7 @@ int bnx2x_vfpf_setup_q(struct bnx2x *bp,
 	return rc;
 }
 
-int bnx2x_vfpf_teardown_queue(struct bnx2x *bp, int qidx)
+static int bnx2x_vfpf_teardown_queue(struct bnx2x *bp, int qidx)
 {
 	struct vfpf_q_op_tlv *req = &bp->vf2pf_mbox->req.q_op;
 	struct pfvf_general_resp_tlv *resp = &bp->vf2pf_mbox->resp.general_resp;
