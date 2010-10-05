From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] bna: cleanup dead code and namespace issues
Date: Tue, 5 Oct 2010 19:20:19 +0900
Message-ID: <20101005192019.0066e116@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rasesh Mody <rmody@brocade.com>, Debashis Dutt <ddutt@brocade.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56076 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753980Ab0JEKU2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Oct 2010 06:20:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The new bna driver is full of issues that I found by running
some namespace checks:
  1. Lots of dead code relating to RSS and stats clearing
  2. Some functions which should be local, especially ones
     that risk namespace collision with other code.
  3. The table for interrupt control should be declared const.

The driver still is sloppy about namespace prefixes. It uses
bna_, bnad_, bfa_, rxf_, __rxf and cna_ prefixes. Please convert it
to have all variables and functions that are global use only
one prefix.

Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Patch against net-next-2.6 tree.

 drivers/net/bna/bfa_ioc.c    |    8 
 drivers/net/bna/bfa_ioc.h    |    1 
 drivers/net/bna/bfa_ioc_ct.c |    2 
 drivers/net/bna/bfa_sm.h     |    2 
 drivers/net/bna/bna.h        |  108 ----------
 drivers/net/bna/bna_ctrl.c   |  427 ++++---------------------------------------
 drivers/net/bna/bna_hw.h     |    1 
 drivers/net/bna/bna_txrx.c   |  108 +++-------
 drivers/net/bna/bnad.c       |   13 -
 drivers/net/bna/cna_fwimg.c  |    2 
 10 files changed, 90 insertions(+), 582 deletions(-)

--- a/drivers/net/bna/bfa_ioc.c	2010-10-05 18:28:08.081647186 +0900
+++ b/drivers/net/bna/bfa_ioc.c	2010-10-05 18:55:15.241670954 +0900
@@ -65,7 +65,7 @@
 			(!list_empty(&((__ioc)->mbox_mod.cmd_q)) || \
 			readl((__ioc)->ioc_regs.hfn_mbox_cmd))
 
-bool bfa_nw_auto_recover = true;
+static bool bfa_nw_auto_recover = true;
 
 /*
  * forward declarations
@@ -1276,12 +1276,6 @@ bfa_nw_ioc_auto_recover(bool auto_recove
 	bfa_nw_auto_recover = auto_recover;
 }
 
-bool
-bfa_nw_ioc_is_operational(struct bfa_ioc *ioc)
-{
-	return bfa_fsm_cmp_state(ioc, bfa_ioc_sm_op);
-}
-
 static void
 bfa_ioc_msgget(struct bfa_ioc *ioc, void *mbmsg)
 {
--- a/drivers/net/bna/bfa_ioc_ct.c	2010-10-05 18:28:08.105640040 +0900
+++ b/drivers/net/bna/bfa_ioc_ct.c	2010-10-05 18:35:37.373640864 +0900
@@ -34,7 +34,7 @@ static void bfa_ioc_ct_notify_hbfail(str
 static void bfa_ioc_ct_ownership_reset(struct bfa_ioc *ioc);
 static enum bfa_status bfa_ioc_ct_pll_init(void __iomem *rb, bool fcmode);
 
-struct bfa_ioc_hwif nw_hwif_ct;
+static struct bfa_ioc_hwif nw_hwif_ct;
 
 /**
  * Called from bfa_ioc_attach() to map asic specific calls.
--- a/drivers/net/bna/bna.h	2010-10-05 18:33:24.969649777 +0900
+++ b/drivers/net/bna/bna.h	2010-10-05 19:14:12.306169796 +0900
@@ -19,8 +19,7 @@
 #include "bfi_ll.h"
 #include "bna_types.h"
 
-extern u32 bna_dim_vector[][BNA_BIAS_T_MAX];
-extern u32 bna_napi_dim_vector[][BNA_BIAS_T_MAX];
+extern const u32 bna_napi_dim_vector[][BNA_BIAS_T_MAX];
 
 /**
  *
@@ -344,9 +343,6 @@ do {									\
  * BNA
  */
 
-/* Internal APIs */
-void bna_adv_res_req(struct bna_res_info *res_info);
-
 /* APIs for BNAD */
 void bna_res_req(struct bna_res_info *res_info);
 void bna_init(struct bna *bna, struct bnad *bnad,
@@ -354,7 +350,6 @@ void bna_init(struct bna *bna, struct bn
 			struct bna_res_info *res_info);
 void bna_uninit(struct bna *bna);
 void bna_stats_get(struct bna *bna);
-void bna_stats_clr(struct bna *bna);
 void bna_get_perm_mac(struct bna *bna, u8 *mac);
 
 /* APIs for Rx */
@@ -376,18 +371,6 @@ void bna_rit_mod_seg_put(struct bna_rit_
  * DEVICE
  */
 
-/* Interanl APIs */
-void bna_adv_device_init(struct bna_device *device, struct bna *bna,
-			struct bna_res_info *res_info);
-
-/* APIs for BNA */
-void bna_device_init(struct bna_device *device, struct bna *bna,
-		     struct bna_res_info *res_info);
-void bna_device_uninit(struct bna_device *device);
-void bna_device_cb_port_stopped(void *arg, enum bna_cb_status status);
-int bna_device_status_get(struct bna_device *device);
-int bna_device_state_get(struct bna_device *device);
-
 /* APIs for BNAD */
 void bna_device_enable(struct bna_device *device);
 void bna_device_disable(struct bna_device *device,
@@ -397,12 +380,6 @@ void bna_device_disable(struct bna_devic
  * MBOX
  */
 
-/* APIs for DEVICE */
-void bna_mbox_mod_init(struct bna_mbox_mod *mbox_mod, struct bna *bna);
-void bna_mbox_mod_uninit(struct bna_mbox_mod *mbox_mod);
-void bna_mbox_mod_start(struct bna_mbox_mod *mbox_mod);
-void bna_mbox_mod_stop(struct bna_mbox_mod *mbox_mod);
-
 /* APIs for PORT, TX, RX */
 void bna_mbox_handler(struct bna *bna, u32 intr_status);
 void bna_mbox_send(struct bna *bna, struct bna_mbox_qe *mbox_qe);
@@ -411,17 +388,6 @@ void bna_mbox_send(struct bna *bna, stru
  * PORT
  */
 
-/* APIs for BNA */
-void bna_port_init(struct bna_port *port, struct bna *bna);
-void bna_port_uninit(struct bna_port *port);
-int bna_port_state_get(struct bna_port *port);
-int bna_llport_state_get(struct bna_llport *llport);
-
-/* APIs for DEVICE */
-void bna_port_start(struct bna_port *port);
-void bna_port_stop(struct bna_port *port);
-void bna_port_fail(struct bna_port *port);
-
 /* API for RX */
 int bna_port_mtu_get(struct bna_port *port);
 void bna_llport_admin_up(struct bna_llport *llport);
@@ -437,12 +403,6 @@ void bna_port_pause_config(struct bna_po
 void bna_port_mtu_set(struct bna_port *port, int mtu,
 		      void (*cbfn)(struct bnad *, enum bna_cb_status));
 void bna_port_mac_get(struct bna_port *port, mac_t *mac);
-void bna_port_type_set(struct bna_port *port, enum bna_port_type type);
-void bna_port_linkcbfn_set(struct bna_port *port,
-			   void (*linkcbfn)(struct bnad *,
-					    enum bna_link_status));
-void bna_port_admin_up(struct bna_port *port);
-void bna_port_admin_down(struct bna_port *port);
 
 /* Callbacks for TX, RX */
 void bna_port_cb_tx_stopped(struct bna_port *port,
@@ -450,11 +410,6 @@ void bna_port_cb_tx_stopped(struct bna_p
 void bna_port_cb_rx_stopped(struct bna_port *port,
 			    enum bna_cb_status status);
 
-/* Callbacks for MBOX */
-void bna_port_cb_link_up(struct bna_port *port, struct bfi_ll_aen *aen,
-			 int status);
-void bna_port_cb_link_down(struct bna_port *port, int status);
-
 /**
  * IB
  */
@@ -464,25 +419,10 @@ void bna_ib_mod_init(struct bna_ib_mod *
 		     struct bna_res_info *res_info);
 void bna_ib_mod_uninit(struct bna_ib_mod *ib_mod);
 
-/* APIs for TX, RX */
-struct bna_ib *bna_ib_get(struct bna_ib_mod *ib_mod,
-			    enum bna_intr_type intr_type, int vector);
-void bna_ib_put(struct bna_ib_mod *ib_mod, struct bna_ib *ib);
-int bna_ib_reserve_idx(struct bna_ib *ib);
-void bna_ib_release_idx(struct bna_ib *ib, int idx);
-int bna_ib_config(struct bna_ib *ib, struct bna_ib_config *ib_config);
-void bna_ib_start(struct bna_ib *ib);
-void bna_ib_stop(struct bna_ib *ib);
-void bna_ib_fail(struct bna_ib *ib);
-void bna_ib_coalescing_timeo_set(struct bna_ib *ib, u8 coalescing_timeo);
-
 /**
  * TX MODULE AND TX
  */
 
-/* Internal APIs */
-void bna_tx_prio_changed(struct bna_tx *tx, int prio);
-
 /* APIs for BNA */
 void bna_tx_mod_init(struct bna_tx_mod *tx_mod, struct bna *bna,
 		     struct bna_res_info *res_info);
@@ -508,10 +448,6 @@ void bna_tx_enable(struct bna_tx *tx);
 void bna_tx_disable(struct bna_tx *tx, enum bna_cleanup_type type,
 		    void (*cbfn)(void *, struct bna_tx *,
 				 enum bna_cb_status));
-enum bna_cb_status
-bna_tx_prio_set(struct bna_tx *tx, int prio,
-		void (*cbfn)(struct bnad *, struct bna_tx *,
-			     enum bna_cb_status));
 void bna_tx_coalescing_timeo_set(struct bna_tx *tx, int coalescing_timeo);
 
 /**
@@ -564,35 +500,20 @@ void bna_rx_disable(struct bna_rx *rx, e
 		    void (*cbfn)(void *, struct bna_rx *,
 				 enum bna_cb_status));
 void bna_rx_coalescing_timeo_set(struct bna_rx *rx, int coalescing_timeo);
-void bna_rx_dim_reconfig(struct bna *bna, u32 vector[][BNA_BIAS_T_MAX]);
+void bna_rx_dim_reconfig(struct bna *bna, const u32 vector[][BNA_BIAS_T_MAX]);
 void bna_rx_dim_update(struct bna_ccb *ccb);
 enum bna_cb_status
 bna_rx_ucast_set(struct bna_rx *rx, u8 *ucmac,
 		 void (*cbfn)(struct bnad *, struct bna_rx *,
 			      enum bna_cb_status));
 enum bna_cb_status
-bna_rx_ucast_add(struct bna_rx *rx, u8* ucmac,
-		 void (*cbfn)(struct bnad *, struct bna_rx *,
-			      enum bna_cb_status));
-enum bna_cb_status
-bna_rx_ucast_del(struct bna_rx *rx, u8 *ucmac,
-		 void (*cbfn)(struct bnad *, struct bna_rx *,
-			      enum bna_cb_status));
-enum bna_cb_status
 bna_rx_mcast_add(struct bna_rx *rx, u8 *mcmac,
 		 void (*cbfn)(struct bnad *, struct bna_rx *,
 			      enum bna_cb_status));
 enum bna_cb_status
-bna_rx_mcast_del(struct bna_rx *rx, u8 *mcmac,
-		 void (*cbfn)(struct bnad *, struct bna_rx *,
-			      enum bna_cb_status));
-enum bna_cb_status
 bna_rx_mcast_listset(struct bna_rx *rx, int count, u8 *mcmac,
 		     void (*cbfn)(struct bnad *, struct bna_rx *,
 				  enum bna_cb_status));
-void bna_rx_mcast_delall(struct bna_rx *rx,
-			 void (*cbfn)(struct bnad *, struct bna_rx *,
-				      enum bna_cb_status));
 enum bna_cb_status
 bna_rx_mode_set(struct bna_rx *rx, enum bna_rxmode rxmode,
 		enum bna_rxmode bitmask,
@@ -601,37 +522,12 @@ bna_rx_mode_set(struct bna_rx *rx, enum 
 void bna_rx_vlan_add(struct bna_rx *rx, int vlan_id);
 void bna_rx_vlan_del(struct bna_rx *rx, int vlan_id);
 void bna_rx_vlanfilter_enable(struct bna_rx *rx);
-void bna_rx_vlanfilter_disable(struct bna_rx *rx);
-void bna_rx_rss_enable(struct bna_rx *rx);
-void bna_rx_rss_disable(struct bna_rx *rx);
-void bna_rx_rss_reconfig(struct bna_rx *rx, struct bna_rxf_rss *rss_config);
-void bna_rx_rss_rit_set(struct bna_rx *rx, unsigned int *vectors,
-			int nvectors);
 void bna_rx_hds_enable(struct bna_rx *rx, struct bna_rxf_hds *hds_config,
 		       void (*cbfn)(struct bnad *, struct bna_rx *,
 				    enum bna_cb_status));
 void bna_rx_hds_disable(struct bna_rx *rx,
 			void (*cbfn)(struct bnad *, struct bna_rx *,
 				     enum bna_cb_status));
-void bna_rx_receive_pause(struct bna_rx *rx,
-			  void (*cbfn)(struct bnad *, struct bna_rx *,
-				       enum bna_cb_status));
-void bna_rx_receive_resume(struct bna_rx *rx,
-			   void (*cbfn)(struct bnad *, struct bna_rx *,
-					enum bna_cb_status));
-
-/* RxF APIs for RX */
-void bna_rxf_start(struct bna_rxf *rxf);
-void bna_rxf_stop(struct bna_rxf *rxf);
-void bna_rxf_fail(struct bna_rxf *rxf);
-void bna_rxf_init(struct bna_rxf *rxf, struct bna_rx *rx,
-		  struct bna_rx_config *q_config);
-void bna_rxf_uninit(struct bna_rxf *rxf);
-
-/* Callback from RXF to RX */
-void bna_rx_cb_rxf_stopped(struct bna_rx *rx, enum bna_cb_status);
-void bna_rx_cb_rxf_started(struct bna_rx *rx, enum bna_cb_status);
-
 /**
  * BNAD
  */
--- a/drivers/net/bna/bna_ctrl.c	2010-10-05 18:28:08.125665071 +0900
+++ b/drivers/net/bna/bna_ctrl.c	2010-10-05 19:17:51.037641382 +0900
@@ -19,6 +19,13 @@
 #include "bfa_sm.h"
 #include "bfa_wc.h"
 
+static void bna_device_cb_port_stopped(void *arg, enum bna_cb_status status);
+static void bna_adv_device_init(struct bna_device *device, struct bna *bna,
+				struct bna_res_info *res_info);
+static void bna_port_cb_link_up(struct bna_port *port, struct bfi_ll_aen *aen,
+				int status);
+static void bna_port_cb_link_down(struct bna_port *port, int status);
+
 /**
  * MBOX
  */
@@ -96,7 +103,7 @@ bna_ll_isr(void *llarg, struct bfi_mbmsg
 		bna_mbox_aen_callback(bna, msg);
 }
 
-void
+static void
 bna_err_handler(struct bna *bna, u32 intr_status)
 {
 	u32 init_halt;
@@ -140,7 +147,7 @@ bna_mbox_send(struct bna *bna, struct bn
 	}
 }
 
-void
+static void
 bna_mbox_flush_q(struct bna *bna, struct list_head *q)
 {
 	struct bna_mbox_qe *mb_qe = NULL;
@@ -166,18 +173,18 @@ bna_mbox_flush_q(struct bna *bna, struct
 	bna->mbox_mod.state = BNA_MBOX_FREE;
 }
 
-void
+static void
 bna_mbox_mod_start(struct bna_mbox_mod *mbox_mod)
 {
 }
 
-void
+static void
 bna_mbox_mod_stop(struct bna_mbox_mod *mbox_mod)
 {
 	bna_mbox_flush_q(mbox_mod->bna, &mbox_mod->posted_q);
 }
 
-void
+static void
 bna_mbox_mod_init(struct bna_mbox_mod *mbox_mod, struct bna *bna)
 {
 	bfa_nw_ioc_mbox_regisr(&bna->device.ioc, BFI_MC_LL, bna_ll_isr, bna);
@@ -187,7 +194,7 @@ bna_mbox_mod_init(struct bna_mbox_mod *m
 	mbox_mod->bna = bna;
 }
 
-void
+static void
 bna_mbox_mod_uninit(struct bna_mbox_mod *mbox_mod)
 {
 	mbox_mod->bna = NULL;
@@ -538,7 +545,7 @@ bna_fw_cb_llport_down(void *arg, int sta
 	bfa_fsm_send_event(llport, LLPORT_E_FWRESP_DOWN);
 }
 
-void
+static void
 bna_port_cb_llport_stopped(struct bna_port *port,
 				enum bna_cb_status status)
 {
@@ -591,7 +598,7 @@ bna_llport_fail(struct bna_llport *llpor
 	bfa_fsm_send_event(llport, LLPORT_E_FAIL);
 }
 
-int
+static int
 bna_llport_state_get(struct bna_llport *llport)
 {
 	return bfa_sm_to_state(llport_sm_table, llport->fsm);
@@ -1109,7 +1116,7 @@ bna_port_cb_chld_stopped(void *arg)
 	bfa_fsm_send_event(port, PORT_E_CHLD_STOPPED);
 }
 
-void
+static void
 bna_port_init(struct bna_port *port, struct bna *bna)
 {
 	port->bna = bna;
@@ -1137,7 +1144,7 @@ bna_port_init(struct bna_port *port, str
 	bna_llport_init(&port->llport, bna);
 }
 
-void
+static void
 bna_port_uninit(struct bna_port *port)
 {
 	bna_llport_uninit(&port->llport);
@@ -1147,13 +1154,13 @@ bna_port_uninit(struct bna_port *port)
 	port->bna = NULL;
 }
 
-int
+static int
 bna_port_state_get(struct bna_port *port)
 {
 	return bfa_sm_to_state(port_sm_table, port->fsm);
 }
 
-void
+static void
 bna_port_start(struct bna_port *port)
 {
 	port->flags |= BNA_PORT_F_DEVICE_READY;
@@ -1161,7 +1168,7 @@ bna_port_start(struct bna_port *port)
 		bfa_fsm_send_event(port, PORT_E_START);
 }
 
-void
+static void
 bna_port_stop(struct bna_port *port)
 {
 	port->stop_cbfn = bna_device_cb_port_stopped;
@@ -1171,7 +1178,7 @@ bna_port_stop(struct bna_port *port)
 	bfa_fsm_send_event(port, PORT_E_STOP);
 }
 
-void
+static void
 bna_port_fail(struct bna_port *port)
 {
 	port->flags &= ~BNA_PORT_F_DEVICE_READY;
@@ -1190,7 +1197,7 @@ bna_port_cb_rx_stopped(struct bna_port *
 	bfa_wc_down(&port->chld_stop_wc);
 }
 
-void
+static void
 bna_port_cb_link_up(struct bna_port *port, struct bfi_ll_aen *aen,
 			int status)
 {
@@ -1218,7 +1225,7 @@ bna_port_cb_link_up(struct bna_port *por
 	port->link_cbfn(port->bna->bnad, port->llport.link_status);
 }
 
-void
+static void
 bna_port_cb_link_down(struct bna_port *port, int status)
 {
 	port->llport.link_status = BNA_LINK_DOWN;
@@ -1293,54 +1300,6 @@ bna_port_mac_get(struct bna_port *port, 
 }
 
 /**
- * Should be called only when port is disabled
- */
-void
-bna_port_type_set(struct bna_port *port, enum bna_port_type type)
-{
-	port->type = type;
-	port->llport.type = type;
-}
-
-/**
- * Should be called only when port is disabled
- */
-void
-bna_port_linkcbfn_set(struct bna_port *port,
-		      void (*linkcbfn)(struct bnad *, enum bna_link_status))
-{
-	port->link_cbfn = linkcbfn;
-}
-
-void
-bna_port_admin_up(struct bna_port *port)
-{
-	struct bna_llport *llport = &port->llport;
-
-	if (llport->flags & BNA_LLPORT_F_ENABLED)
-		return;
-
-	llport->flags |= BNA_LLPORT_F_ENABLED;
-
-	if (llport->flags & BNA_LLPORT_F_RX_ENABLED)
-		bfa_fsm_send_event(llport, LLPORT_E_UP);
-}
-
-void
-bna_port_admin_down(struct bna_port *port)
-{
-	struct bna_llport *llport = &port->llport;
-
-	if (!(llport->flags & BNA_LLPORT_F_ENABLED))
-		return;
-
-	llport->flags &= ~BNA_LLPORT_F_ENABLED;
-
-	if (llport->flags & BNA_LLPORT_F_RX_ENABLED)
-		bfa_fsm_send_event(llport, LLPORT_E_DOWN);
-}
-
-/**
  * DEVICE
  */
 #define enable_mbox_intr(_device)\
@@ -1357,7 +1316,7 @@ do {\
 	bnad_cb_device_disable_mbox_intr((_device)->bna->bnad);\
 } while (0)
 
-const struct bna_chip_regs_offset reg_offset[] =
+static const struct bna_chip_regs_offset reg_offset[] =
 {{HOST_PAGE_NUM_FN0, HOSTFN0_INT_STATUS,
 	HOSTFN0_INT_MASK, HOST_MSIX_ERR_INDEX_FN0},
 {HOST_PAGE_NUM_FN1, HOSTFN1_INT_STATUS,
@@ -1642,7 +1601,7 @@ static struct bfa_ioc_cbfn bfa_iocll_cbf
 	bna_device_cb_iocll_reset
 };
 
-void
+static void
 bna_device_init(struct bna_device *device, struct bna *bna,
 		struct bna_res_info *res_info)
 {
@@ -1681,7 +1640,7 @@ bna_device_init(struct bna_device *devic
 	bfa_fsm_set_state(device, bna_device_sm_stopped);
 }
 
-void
+static void
 bna_device_uninit(struct bna_device *device)
 {
 	bna_mbox_mod_uninit(&device->bna->mbox_mod);
@@ -1691,7 +1650,7 @@ bna_device_uninit(struct bna_device *dev
 	device->bna = NULL;
 }
 
-void
+static void
 bna_device_cb_port_stopped(void *arg, enum bna_cb_status status)
 {
 	struct bna_device *device = (struct bna_device *)arg;
@@ -1699,7 +1658,7 @@ bna_device_cb_port_stopped(void *arg, en
 	bfa_fsm_send_event(device, DEVICE_E_PORT_STOPPED);
 }
 
-int
+static int
 bna_device_status_get(struct bna_device *device)
 {
 	return device->fsm == (bfa_fsm_t)bna_device_sm_ready;
@@ -1733,13 +1692,13 @@ bna_device_disable(struct bna_device *de
 	bfa_fsm_send_event(device, DEVICE_E_DISABLE);
 }
 
-int
+static int
 bna_device_state_get(struct bna_device *device)
 {
 	return bfa_sm_to_state(device_sm_table, device->fsm);
 }
 
-u32 bna_dim_vector[BNA_LOAD_T_MAX][BNA_BIAS_T_MAX] = {
+static const u32 bna_dim_vector[BNA_LOAD_T_MAX][BNA_BIAS_T_MAX] = {
 	{12, 20},
 	{10, 18},
 	{8, 16},
@@ -1750,7 +1709,7 @@ u32 bna_dim_vector[BNA_LOAD_T_MAX][BNA_B
 	{1, 2},
 };
 
-u32 bna_napi_dim_vector[BNA_LOAD_T_MAX][BNA_BIAS_T_MAX] = {
+const u32 bna_napi_dim_vector[BNA_LOAD_T_MAX][BNA_BIAS_T_MAX] = {
 	{12, 12},
 	{6, 10},
 	{5, 10},
@@ -1762,7 +1721,7 @@ u32 bna_napi_dim_vector[BNA_LOAD_T_MAX][
 };
 
 /* device */
-void
+static void
 bna_adv_device_init(struct bna_device *device, struct bna *bna,
 		struct bna_res_info *res_info)
 {
@@ -1790,7 +1749,7 @@ bna_adv_device_init(struct bna_device *d
 
 /* utils */
 
-void
+static void
 bna_adv_res_req(struct bna_res_info *res_info)
 {
 	/* DMA memory for COMMON_MODULE */
@@ -2044,36 +2003,6 @@ bna_fw_stats_get(struct bna *bna)
 	bna->stats.txf_bmap[1] = bna->tx_mod.txf_bmap[1];
 }
 
-static void
-bna_fw_cb_stats_clr(void *arg, int status)
-{
-	struct bna *bna = (struct bna *)arg;
-
-	bfa_q_qe_init(&bna->mbox_qe.qe);
-
-	memset(bna->stats.sw_stats, 0, sizeof(struct bna_sw_stats));
-	memset(bna->stats.hw_stats, 0, sizeof(struct bfi_ll_stats));
-
-	bnad_cb_stats_clr(bna->bnad);
-}
-
-static void
-bna_fw_stats_clr(struct bna *bna)
-{
-	struct bfi_ll_stats_req ll_req;
-
-	bfi_h2i_set(ll_req.mh, BFI_MC_LL, BFI_LL_H2I_STATS_CLEAR_REQ, 0);
-	ll_req.stats_mask = htons(BFI_LL_STATS_ALL);
-	ll_req.rxf_id_mask[0] = htonl(0xffffffff);
-	ll_req.rxf_id_mask[1] =	htonl(0xffffffff);
-	ll_req.txf_id_mask[0] =	htonl(0xffffffff);
-	ll_req.txf_id_mask[1] =	htonl(0xffffffff);
-
-	bna_mbox_qe_fill(&bna->mbox_qe, &ll_req, sizeof(ll_req),
-				bna_fw_cb_stats_clr, bna);
-	bna_mbox_send(bna, &bna->mbox_qe);
-}
-
 void
 bna_stats_get(struct bna *bna)
 {
@@ -2083,22 +2012,8 @@ bna_stats_get(struct bna *bna)
 		bnad_cb_stats_get(bna->bnad, BNA_CB_FAIL, &bna->stats);
 }
 
-void
-bna_stats_clr(struct bna *bna)
-{
-	if (bna_device_status_get(&bna->device))
-		bna_fw_stats_clr(bna);
-	else {
-		memset(&bna->stats.sw_stats, 0,
-				sizeof(struct bna_sw_stats));
-		memset(bna->stats.hw_stats, 0,
-				sizeof(struct bfi_ll_stats));
-		bnad_cb_stats_clr(bna->bnad);
-	}
-}
-
 /* IB */
-void
+static void
 bna_ib_coalescing_timeo_set(struct bna_ib *ib, u8 coalescing_timeo)
 {
 	ib->ib_config.coalescing_timeo = coalescing_timeo;
@@ -2157,7 +2072,7 @@ rxf_fltr_mbox_cmd(struct bna_rxf *rxf, u
 	bna_mbox_send(rxf->rx->bna, &rxf->mbox_qe);
 }
 
-void
+static void
 __rxf_default_function_config(struct bna_rxf *rxf, enum bna_status status)
 {
 	struct bna_rx_fndb_ram *rx_fndb_ram;
@@ -2553,7 +2468,7 @@ rxf_reset_packet_filter_allmulti(struct 
  *	0 = no h/w change
  *	1 = need h/w change
  */
-int
+static int
 rxf_promisc_enable(struct bna_rxf *rxf)
 {
 	struct bna *bna = rxf->rx->bna;
@@ -2584,7 +2499,7 @@ rxf_promisc_enable(struct bna_rxf *rxf)
  *	0 = no h/w change
  *	1 = need h/w change
  */
-int
+static int
 rxf_promisc_disable(struct bna_rxf *rxf)
 {
 	struct bna *bna = rxf->rx->bna;
@@ -2623,7 +2538,7 @@ rxf_promisc_disable(struct bna_rxf *rxf)
  *	0 = no h/w change
  *	1 = need h/w change
  */
-int
+static int
 rxf_default_enable(struct bna_rxf *rxf)
 {
 	struct bna *bna = rxf->rx->bna;
@@ -2654,7 +2569,7 @@ rxf_default_enable(struct bna_rxf *rxf)
  *	0 = no h/w change
  *	1 = need h/w change
  */
-int
+static int
 rxf_default_disable(struct bna_rxf *rxf)
 {
 	struct bna *bna = rxf->rx->bna;
@@ -2693,7 +2608,7 @@ rxf_default_disable(struct bna_rxf *rxf)
  *	0 = no h/w change
  *	1 = need h/w change
  */
-int
+static int
 rxf_allmulti_enable(struct bna_rxf *rxf)
 {
 	int ret = 0;
@@ -2721,7 +2636,7 @@ rxf_allmulti_enable(struct bna_rxf *rxf)
  *	0 = no h/w change
  *	1 = need h/w change
  */
-int
+static int
 rxf_allmulti_disable(struct bna_rxf *rxf)
 {
 	int ret = 0;
@@ -2745,158 +2660,7 @@ rxf_allmulti_disable(struct bna_rxf *rxf
 	return ret;
 }
 
-/* RxF <- bnad */
-void
-bna_rx_mcast_delall(struct bna_rx *rx,
-		    void (*cbfn)(struct bnad *, struct bna_rx *,
-				 enum bna_cb_status))
-{
-	struct bna_rxf *rxf = &rx->rxf;
-	struct list_head *qe;
-	struct bna_mac *mac;
-	int need_hw_config = 0;
 
-	/* Purge all entries from pending_add_q */
-	while (!list_empty(&rxf->mcast_pending_add_q)) {
-		bfa_q_deq(&rxf->mcast_pending_add_q, &qe);
-		mac = (struct bna_mac *)qe;
-		bfa_q_qe_init(&mac->qe);
-		bna_mcam_mod_mac_put(&rxf->rx->bna->mcam_mod, mac);
-	}
-
-	/* Schedule all entries in active_q for deletion */
-	while (!list_empty(&rxf->mcast_active_q)) {
-		bfa_q_deq(&rxf->mcast_active_q, &qe);
-		mac = (struct bna_mac *)qe;
-		bfa_q_qe_init(&mac->qe);
-		list_add_tail(&mac->qe, &rxf->mcast_pending_del_q);
-		need_hw_config = 1;
-	}
-
-	if (need_hw_config) {
-		rxf->cam_fltr_cbfn = cbfn;
-		rxf->cam_fltr_cbarg = rx->bna->bnad;
-		bfa_fsm_send_event(rxf, RXF_E_CAM_FLTR_MOD);
-		return;
-	}
-
-	if (cbfn)
-		(*cbfn)(rx->bna->bnad, rx, BNA_CB_SUCCESS);
-}
-
-/* RxF <- Rx */
-void
-bna_rx_receive_resume(struct bna_rx *rx,
-		      void (*cbfn)(struct bnad *, struct bna_rx *,
-				   enum bna_cb_status))
-{
-	struct bna_rxf *rxf = &rx->rxf;
-
-	if (rxf->rxf_oper_state == BNA_RXF_OPER_STATE_PAUSED) {
-		rxf->oper_state_cbfn = cbfn;
-		rxf->oper_state_cbarg = rx->bna->bnad;
-		bfa_fsm_send_event(rxf, RXF_E_RESUME);
-	} else if (cbfn)
-		(*cbfn)(rx->bna->bnad, rx, BNA_CB_SUCCESS);
-}
-
-void
-bna_rx_receive_pause(struct bna_rx *rx,
-		     void (*cbfn)(struct bnad *, struct bna_rx *,
-				  enum bna_cb_status))
-{
-	struct bna_rxf *rxf = &rx->rxf;
-
-	if (rxf->rxf_oper_state == BNA_RXF_OPER_STATE_RUNNING) {
-		rxf->oper_state_cbfn = cbfn;
-		rxf->oper_state_cbarg = rx->bna->bnad;
-		bfa_fsm_send_event(rxf, RXF_E_PAUSE);
-	} else if (cbfn)
-		(*cbfn)(rx->bna->bnad, rx, BNA_CB_SUCCESS);
-}
-
-/* RxF <- bnad */
-enum bna_cb_status
-bna_rx_ucast_add(struct bna_rx *rx, u8 *addr,
-		 void (*cbfn)(struct bnad *, struct bna_rx *,
-			      enum bna_cb_status))
-{
-	struct bna_rxf *rxf = &rx->rxf;
-	struct list_head *qe;
-	struct bna_mac *mac;
-
-	/* Check if already added */
-	list_for_each(qe, &rxf->ucast_active_q) {
-		mac = (struct bna_mac *)qe;
-		if (BNA_MAC_IS_EQUAL(mac->addr, addr)) {
-			if (cbfn)
-				(*cbfn)(rx->bna->bnad, rx, BNA_CB_SUCCESS);
-			return BNA_CB_SUCCESS;
-		}
-	}
-
-	/* Check if pending addition */
-	list_for_each(qe, &rxf->ucast_pending_add_q) {
-		mac = (struct bna_mac *)qe;
-		if (BNA_MAC_IS_EQUAL(mac->addr, addr)) {
-			if (cbfn)
-				(*cbfn)(rx->bna->bnad, rx, BNA_CB_SUCCESS);
-			return BNA_CB_SUCCESS;
-		}
-	}
-
-	mac = bna_ucam_mod_mac_get(&rxf->rx->bna->ucam_mod);
-	if (mac == NULL)
-		return BNA_CB_UCAST_CAM_FULL;
-	bfa_q_qe_init(&mac->qe);
-	memcpy(mac->addr, addr, ETH_ALEN);
-	list_add_tail(&mac->qe, &rxf->ucast_pending_add_q);
-
-	rxf->cam_fltr_cbfn = cbfn;
-	rxf->cam_fltr_cbarg = rx->bna->bnad;
-
-	bfa_fsm_send_event(rxf, RXF_E_CAM_FLTR_MOD);
-
-	return BNA_CB_SUCCESS;
-}
-
-/* RxF <- bnad */
-enum bna_cb_status
-bna_rx_ucast_del(struct bna_rx *rx, u8 *addr,
-		 void (*cbfn)(struct bnad *, struct bna_rx *,
-			      enum bna_cb_status))
-{
-	struct bna_rxf *rxf = &rx->rxf;
-	struct list_head *qe;
-	struct bna_mac *mac;
-
-	list_for_each(qe, &rxf->ucast_pending_add_q) {
-		mac = (struct bna_mac *)qe;
-		if (BNA_MAC_IS_EQUAL(mac->addr, addr)) {
-			list_del(qe);
-			bfa_q_qe_init(qe);
-			bna_ucam_mod_mac_put(&rxf->rx->bna->ucam_mod, mac);
-			if (cbfn)
-				(*cbfn)(rx->bna->bnad, rx, BNA_CB_SUCCESS);
-			return BNA_CB_SUCCESS;
-		}
-	}
-
-	list_for_each(qe, &rxf->ucast_active_q) {
-		mac = (struct bna_mac *)qe;
-		if (BNA_MAC_IS_EQUAL(mac->addr, addr)) {
-			list_del(qe);
-			bfa_q_qe_init(qe);
-			list_add_tail(qe, &rxf->ucast_pending_del_q);
-			rxf->cam_fltr_cbfn = cbfn;
-			rxf->cam_fltr_cbarg = rx->bna->bnad;
-			bfa_fsm_send_event(rxf, RXF_E_CAM_FLTR_MOD);
-			return BNA_CB_SUCCESS;
-		}
-	}
-
-	return BNA_CB_INVALID_MAC;
-}
 
 /* RxF <- bnad */
 enum bna_cb_status
@@ -2978,38 +2742,6 @@ err_return:
 	return BNA_CB_FAIL;
 }
 
-/* RxF <- bnad */
-void
-bna_rx_rss_enable(struct bna_rx *rx)
-{
-	struct bna_rxf *rxf = &rx->rxf;
-
-	rxf->rxf_flags |= BNA_RXF_FL_RSS_CONFIG_PENDING;
-	rxf->rss_status = BNA_STATUS_T_ENABLED;
-	bfa_fsm_send_event(rxf, RXF_E_CAM_FLTR_MOD);
-}
-
-/* RxF <- bnad */
-void
-bna_rx_rss_disable(struct bna_rx *rx)
-{
-	struct bna_rxf *rxf = &rx->rxf;
-
-	rxf->rxf_flags |= BNA_RXF_FL_RSS_CONFIG_PENDING;
-	rxf->rss_status = BNA_STATUS_T_DISABLED;
-	bfa_fsm_send_event(rxf, RXF_E_CAM_FLTR_MOD);
-}
-
-/* RxF <- bnad */
-void
-bna_rx_rss_reconfig(struct bna_rx *rx, struct bna_rxf_rss *rss_config)
-{
-	struct bna_rxf *rxf = &rx->rxf;
-	rxf->rxf_flags |= BNA_RXF_FL_RSS_CONFIG_PENDING;
-	rxf->rss_status = BNA_STATUS_T_ENABLED;
-	rxf->rss_cfg = *rss_config;
-	bfa_fsm_send_event(rxf, RXF_E_CAM_FLTR_MOD);
-}
 
 void
 /* RxF <- bnad */
@@ -3024,68 +2756,8 @@ bna_rx_vlanfilter_enable(struct bna_rx *
 	}
 }
 
-/* RxF <- bnad */
-void
-bna_rx_vlanfilter_disable(struct bna_rx *rx)
-{
-	struct bna_rxf *rxf = &rx->rxf;
-
-	if (rxf->vlan_filter_status == BNA_STATUS_T_ENABLED) {
-		rxf->rxf_flags |= BNA_RXF_FL_VLAN_CONFIG_PENDING;
-		rxf->vlan_filter_status = BNA_STATUS_T_DISABLED;
-		bfa_fsm_send_event(rxf, RXF_E_CAM_FLTR_MOD);
-	}
-}
-
 /* Rx */
 
-struct bna_rxp *
-bna_rx_get_rxp(struct bna_rx *rx, int vector)
-{
-	struct bna_rxp *rxp;
-	struct list_head *qe;
-
-	list_for_each(qe, &rx->rxp_q) {
-		rxp = (struct bna_rxp *)qe;
-		if (rxp->vector == vector)
-			return rxp;
-	}
-	return NULL;
-}
-
-/*
- * bna_rx_rss_rit_set()
- * Sets the Q ids for the specified msi-x vectors in the RIT.
- * Maximum rit size supported is 64, which should be the max size of the
- * vectors array.
- */
-
-void
-bna_rx_rss_rit_set(struct bna_rx *rx, unsigned int *vectors, int nvectors)
-{
-	int i;
-	struct bna_rxp *rxp;
-	struct bna_rxq *q0 = NULL, *q1 = NULL;
-	struct bna *bna;
-	struct bna_rxf *rxf;
-
-	/* Build the RIT contents for this RX */
-	bna = rx->bna;
-
-	rxf = &rx->rxf;
-	for (i = 0; i < nvectors; i++) {
-		rxp = bna_rx_get_rxp(rx, vectors[i]);
-
-		GET_RXQS(rxp, q0, q1);
-		rxf->rit_segment->rit[i].large_rxq_id = q0->rxq_id;
-		rxf->rit_segment->rit[i].small_rxq_id = (q1 ? q1->rxq_id : 0);
-	}
-
-	rxf->rit_segment->rit_size = nvectors;
-
-	/* Subsequent call to enable/reconfig RSS will update the RIT in h/w */
-}
-
 /* Rx <- bnad */
 void
 bna_rx_coalescing_timeo_set(struct bna_rx *rx, int coalescing_timeo)
@@ -3102,7 +2774,7 @@ bna_rx_coalescing_timeo_set(struct bna_r
 
 /* Rx <- bnad */
 void
-bna_rx_dim_reconfig(struct bna *bna, u32 vector[][BNA_BIAS_T_MAX])
+bna_rx_dim_reconfig(struct bna *bna, const u32 vector[][BNA_BIAS_T_MAX])
 {
 	int i, j;
 
@@ -3164,21 +2836,6 @@ bna_rx_dim_update(struct bna_ccb *ccb)
 }
 
 /* Tx */
-/* TX <- bnad */
-enum bna_cb_status
-bna_tx_prio_set(struct bna_tx *tx, int prio,
-		void (*cbfn)(struct bnad *, struct bna_tx *,
-			     enum bna_cb_status))
-{
-	if (tx->flags & BNA_TX_F_PRIO_LOCK)
-		return BNA_CB_FAIL;
-	else {
-		tx->prio_change_cbfn = cbfn;
-		bna_tx_prio_changed(tx, prio);
-	}
-
-	return BNA_CB_SUCCESS;
-}
 
 /* TX <- bnad */
 void
--- a/drivers/net/bna/bna_hw.h	2010-10-05 18:45:27.577646257 +0900
+++ b/drivers/net/bna/bna_hw.h	2010-10-05 18:45:32.957640709 +0900
@@ -1282,7 +1282,6 @@ struct bna_chip_regs_offset {
 	u32 fn_int_mask;
 	u32 msix_idx;
 };
-extern const struct bna_chip_regs_offset reg_offset[];
 
 struct bna_chip_regs {
 	void __iomem *page_addr;
--- a/drivers/net/bna/bna_txrx.c	2010-10-05 18:28:08.141648599 +0900
+++ b/drivers/net/bna/bna_txrx.c	2010-10-05 19:17:57.785641486 +0900
@@ -59,6 +59,10 @@ struct bna_ibidx_pool {
 };
 init_ibidx_pool(ibidx_pool);
 
+/* Callback from RXF to RX */
+static void bna_rx_cb_rxf_stopped(struct bna_rx *rx, enum bna_cb_status);
+static void bna_rx_cb_rxf_started(struct bna_rx *rx, enum bna_cb_status);
+
 static struct bna_intr *
 bna_intr_get(struct bna_ib_mod *ib_mod, enum bna_intr_type intr_type,
 		int vector)
@@ -195,7 +199,7 @@ bna_ib_mod_uninit(struct bna_ib_mod *ib_
 	ib_mod->bna = NULL;
 }
 
-struct bna_ib *
+static struct bna_ib *
 bna_ib_get(struct bna_ib_mod *ib_mod,
 		enum bna_intr_type intr_type,
 		int vector)
@@ -240,7 +244,7 @@ bna_ib_get(struct bna_ib_mod *ib_mod,
 	return ib;
 }
 
-void
+static void
 bna_ib_put(struct bna_ib_mod *ib_mod, struct bna_ib *ib)
 {
 	bna_intr_put(ib_mod, ib->intr);
@@ -255,7 +259,7 @@ bna_ib_put(struct bna_ib_mod *ib_mod, st
 }
 
 /* Returns index offset - starting from 0 */
-int
+static int
 bna_ib_reserve_idx(struct bna_ib *ib)
 {
 	struct bna_ib_mod *ib_mod = &ib->bna->ib_mod;
@@ -309,7 +313,7 @@ bna_ib_reserve_idx(struct bna_ib *ib)
 	return idx;
 }
 
-void
+static void
 bna_ib_release_idx(struct bna_ib *ib, int idx)
 {
 	struct bna_ib_mod *ib_mod = &ib->bna->ib_mod;
@@ -356,7 +360,7 @@ bna_ib_release_idx(struct bna_ib *ib, in
 	}
 }
 
-int
+static int
 bna_ib_config(struct bna_ib *ib, struct bna_ib_config *ib_config)
 {
 	if (ib->start_count)
@@ -374,7 +378,7 @@ bna_ib_config(struct bna_ib *ib, struct 
 	return 0;
 }
 
-void
+static void
 bna_ib_start(struct bna_ib *ib)
 {
 	struct bna_ib_blk_mem ib_cfg;
@@ -450,7 +454,7 @@ bna_ib_start(struct bna_ib *ib)
 	}
 }
 
-void
+static void
 bna_ib_stop(struct bna_ib *ib)
 {
 	u32 intx_mask;
@@ -468,7 +472,7 @@ bna_ib_stop(struct bna_ib *ib)
 	}
 }
 
-void
+static void
 bna_ib_fail(struct bna_ib *ib)
 {
 	ib->start_count = 0;
@@ -1394,7 +1398,7 @@ rxf_reset_packet_filter(struct bna_rxf *
 	rxf_reset_packet_filter_allmulti(rxf);
 }
 
-void
+static void
 bna_rxf_init(struct bna_rxf *rxf,
 		struct bna_rx *rx,
 		struct bna_rx_config *q_config)
@@ -1444,7 +1448,7 @@ bna_rxf_init(struct bna_rxf *rxf,
 	bfa_fsm_set_state(rxf, bna_rxf_sm_stopped);
 }
 
-void
+static void
 bna_rxf_uninit(struct bna_rxf *rxf)
 {
 	struct bna_mac *mac;
@@ -1476,7 +1480,7 @@ bna_rxf_uninit(struct bna_rxf *rxf)
 	rxf->rx = NULL;
 }
 
-void
+static void
 bna_rxf_start(struct bna_rxf *rxf)
 {
 	rxf->start_cbfn = bna_rx_cb_rxf_started;
@@ -1485,7 +1489,7 @@ bna_rxf_start(struct bna_rxf *rxf)
 	bfa_fsm_send_event(rxf, RXF_E_START);
 }
 
-void
+static void
 bna_rxf_stop(struct bna_rxf *rxf)
 {
 	rxf->stop_cbfn = bna_rx_cb_rxf_stopped;
@@ -1493,7 +1497,7 @@ bna_rxf_stop(struct bna_rxf *rxf)
 	bfa_fsm_send_event(rxf, RXF_E_STOP);
 }
 
-void
+static void
 bna_rxf_fail(struct bna_rxf *rxf)
 {
 	rxf->rxf_flags |= BNA_RXF_FL_FAILED;
@@ -1575,42 +1579,6 @@ bna_rx_mcast_add(struct bna_rx *rx, u8 *
 	return BNA_CB_SUCCESS;
 }
 
-enum bna_cb_status
-bna_rx_mcast_del(struct bna_rx *rx, u8 *addr,
-		 void (*cbfn)(struct bnad *, struct bna_rx *,
-			      enum bna_cb_status))
-{
-	struct bna_rxf *rxf = &rx->rxf;
-	struct list_head *qe;
-	struct bna_mac *mac;
-
-	list_for_each(qe, &rxf->mcast_pending_add_q) {
-		mac = (struct bna_mac *)qe;
-		if (BNA_MAC_IS_EQUAL(mac->addr, addr)) {
-			list_del(qe);
-			bfa_q_qe_init(qe);
-			bna_mcam_mod_mac_put(&rxf->rx->bna->mcam_mod, mac);
-			if (cbfn)
-				(*cbfn)(rx->bna->bnad, rx, BNA_CB_SUCCESS);
-			return BNA_CB_SUCCESS;
-		}
-	}
-
-	list_for_each(qe, &rxf->mcast_active_q) {
-		mac = (struct bna_mac *)qe;
-		if (BNA_MAC_IS_EQUAL(mac->addr, addr)) {
-			list_del(qe);
-			bfa_q_qe_init(qe);
-			list_add_tail(qe, &rxf->mcast_pending_del_q);
-			rxf->cam_fltr_cbfn = cbfn;
-			rxf->cam_fltr_cbarg = rx->bna->bnad;
-			bfa_fsm_send_event(rxf, RXF_E_CAM_FLTR_MOD);
-			return BNA_CB_SUCCESS;
-		}
-	}
-
-	return BNA_CB_INVALID_MAC;
-}
 
 enum bna_cb_status
 bna_rx_mcast_listset(struct bna_rx *rx, int count, u8 *mclist,
@@ -1862,7 +1830,7 @@ bfa_fsm_state_decl(bna_rx, rxf_stop_wait
 bfa_fsm_state_decl(bna_rx, rxq_stop_wait,
 	struct bna_rx, enum bna_rx_event);
 
-static struct bfa_sm_table rx_sm_table[] = {
+static const struct bfa_sm_table rx_sm_table[] = {
 	{BFA_SM(bna_rx_sm_stopped), BNA_RX_STOPPED},
 	{BFA_SM(bna_rx_sm_rxf_start_wait), BNA_RX_RXF_START_WAIT},
 	{BFA_SM(bna_rx_sm_started), BNA_RX_STARTED},
@@ -2247,7 +2215,7 @@ bna_rit_create(struct bna_rx *rx)
 	}
 }
 
-int
+static int
 _rx_can_satisfy(struct bna_rx_mod *rx_mod,
 		struct bna_rx_config *rx_cfg)
 {
@@ -2272,7 +2240,7 @@ _rx_can_satisfy(struct bna_rx_mod *rx_mo
 	return 1;
 }
 
-struct bna_rxq *
+static struct bna_rxq *
 _get_free_rxq(struct bna_rx_mod *rx_mod)
 {
 	struct bna_rxq *rxq = NULL;
@@ -2286,7 +2254,7 @@ _get_free_rxq(struct bna_rx_mod *rx_mod)
 	return rxq;
 }
 
-void
+static void
 _put_free_rxq(struct bna_rx_mod *rx_mod, struct bna_rxq *rxq)
 {
 	bfa_q_qe_init(&rxq->qe);
@@ -2294,7 +2262,7 @@ _put_free_rxq(struct bna_rx_mod *rx_mod,
 	rx_mod->rxq_free_count++;
 }
 
-struct bna_rxp *
+static struct bna_rxp *
 _get_free_rxp(struct bna_rx_mod *rx_mod)
 {
 	struct list_head	*qe = NULL;
@@ -2310,7 +2278,7 @@ _get_free_rxp(struct bna_rx_mod *rx_mod)
 	return rxp;
 }
 
-void
+static void
 _put_free_rxp(struct bna_rx_mod *rx_mod, struct bna_rxp *rxp)
 {
 	bfa_q_qe_init(&rxp->qe);
@@ -2318,7 +2286,7 @@ _put_free_rxp(struct bna_rx_mod *rx_mod,
 	rx_mod->rxp_free_count++;
 }
 
-struct bna_rx *
+static struct bna_rx *
 _get_free_rx(struct bna_rx_mod *rx_mod)
 {
 	struct list_head	*qe = NULL;
@@ -2336,7 +2304,7 @@ _get_free_rx(struct bna_rx_mod *rx_mod)
 	return rx;
 }
 
-void
+static void
 _put_free_rx(struct bna_rx_mod *rx_mod, struct bna_rx *rx)
 {
 	bfa_q_qe_init(&rx->qe);
@@ -2344,7 +2312,7 @@ _put_free_rx(struct bna_rx_mod *rx_mod, 
 	rx_mod->rx_free_count++;
 }
 
-void
+static void
 _rx_init(struct bna_rx *rx, struct bna *bna)
 {
 	rx->bna = bna;
@@ -2360,7 +2328,7 @@ _rx_init(struct bna_rx *rx, struct bna *
 	rx->stop_cbarg = NULL;
 }
 
-void
+static void
 _rxp_add_rxqs(struct bna_rxp *rxp,
 		struct bna_rxq *q0,
 		struct bna_rxq *q1)
@@ -2383,7 +2351,7 @@ _rxp_add_rxqs(struct bna_rxp *rxp,
 	}
 }
 
-void
+static void
 _rxq_qpt_init(struct bna_rxq *rxq,
 		struct bna_rxp *rxp,
 		u32 page_count,
@@ -2412,7 +2380,7 @@ _rxq_qpt_init(struct bna_rxq *rxq,
 	}
 }
 
-void
+static void
 _rxp_cqpt_setup(struct bna_rxp *rxp,
 		u32 page_count,
 		u32 page_size,
@@ -2441,13 +2409,13 @@ _rxp_cqpt_setup(struct bna_rxp *rxp,
 	}
 }
 
-void
+static void
 _rx_add_rxp(struct bna_rx *rx, struct bna_rxp *rxp)
 {
 	list_add_tail(&rxp->qe, &rx->rxp_q);
 }
 
-void
+static void
 _init_rxmod_queues(struct bna_rx_mod *rx_mod)
 {
 	INIT_LIST_HEAD(&rx_mod->rx_free_q);
@@ -2460,7 +2428,7 @@ _init_rxmod_queues(struct bna_rx_mod *rx
 	rx_mod->rxp_free_count = 0;
 }
 
-void
+static void
 _rx_ctor(struct bna_rx *rx, int id)
 {
 	bfa_q_qe_init(&rx->qe);
@@ -2492,7 +2460,7 @@ bna_rx_cb_rxq_stopped_all(void *arg)
 	bfa_fsm_send_event(rx, RX_E_RXQ_STOPPED);
 }
 
-void
+static void
 bna_rx_mod_cb_rx_stopped(void *arg, struct bna_rx *rx,
 			 enum bna_cb_status status)
 {
@@ -2501,7 +2469,7 @@ bna_rx_mod_cb_rx_stopped(void *arg, stru
 	bfa_wc_down(&rx_mod->rx_stop_wc);
 }
 
-void
+static void
 bna_rx_mod_cb_rx_stopped_all(void *arg)
 {
 	struct bna_rx_mod *rx_mod = (struct bna_rx_mod *)arg;
@@ -2511,7 +2479,7 @@ bna_rx_mod_cb_rx_stopped_all(void *arg)
 	rx_mod->stop_cbfn = NULL;
 }
 
-void
+static void
 bna_rx_start(struct bna_rx *rx)
 {
 	rx->rx_flags |= BNA_RX_F_PORT_ENABLED;
@@ -2519,7 +2487,7 @@ bna_rx_start(struct bna_rx *rx)
 		bfa_fsm_send_event(rx, RX_E_START);
 }
 
-void
+static void
 bna_rx_stop(struct bna_rx *rx)
 {
 	rx->rx_flags &= ~BNA_RX_F_PORT_ENABLED;
@@ -2532,7 +2500,7 @@ bna_rx_stop(struct bna_rx *rx)
 	}
 }
 
-void
+static void
 bna_rx_fail(struct bna_rx *rx)
 {
 	/* Indicate port is not enabled, and failed */
@@ -3731,7 +3699,7 @@ bna_tx_fail(struct bna_tx *tx)
 	bfa_fsm_send_event(tx, TX_E_FAIL);
 }
 
-void
+static void
 bna_tx_prio_changed(struct bna_tx *tx, int prio)
 {
 	struct bna_txq *txq;
--- a/drivers/net/bna/bnad.c	2010-10-05 18:28:08.157640648 +0900
+++ b/drivers/net/bna/bnad.c	2010-10-05 19:11:35.125672896 +0900
@@ -28,7 +28,7 @@
 #include "bna.h"
 #include "cna.h"
 
-DEFINE_MUTEX(bnad_fwimg_mutex);
+static DEFINE_MUTEX(bnad_fwimg_mutex);
 
 /*
  * Module params
@@ -46,7 +46,7 @@ MODULE_PARM_DESC(bnad_ioc_auto_recover, 
  */
 u32 bnad_rxqs_per_cq = 2;
 
-const u8 bnad_bcast_addr[] =  {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
+static const u8 bnad_bcast_addr[] =  {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
 
 /*
  * Local MACROS
@@ -684,7 +684,7 @@ bnad_enable_mbox_irq(struct bnad *bnad)
  * Called with bnad->bna_lock held b'cos of
  * bnad->cfg_flags access.
  */
-void
+static void
 bnad_disable_mbox_irq(struct bnad *bnad)
 {
 	int irq = BNAD_GET_MBOX_IRQ(bnad);
@@ -953,11 +953,6 @@ bnad_cb_stats_get(struct bnad *bnad, enu
 		  jiffies + msecs_to_jiffies(BNAD_STATS_TIMER_FREQ));
 }
 
-void
-bnad_cb_stats_clr(struct bnad *bnad)
-{
-}
-
 /* Resource allocation, free functions */
 
 static void
@@ -3211,7 +3206,7 @@ bnad_pci_remove(struct pci_dev *pdev)
 	free_netdev(netdev);
 }
 
-const struct pci_device_id bnad_pci_id_table[] = {
+static const struct pci_device_id bnad_pci_id_table[] = {
 	{
 		PCI_DEVICE(PCI_VENDOR_ID_BROCADE,
 			PCI_DEVICE_ID_BROCADE_CT),
--- a/drivers/net/bna/cna_fwimg.c	2010-10-05 18:28:08.173646664 +0900
+++ b/drivers/net/bna/cna_fwimg.c	2010-10-05 18:29:06.225688125 +0900
@@ -22,7 +22,7 @@ const struct firmware *bfi_fw;
 static u32 *bfi_image_ct_cna;
 static u32 bfi_image_ct_cna_size;
 
-u32 *
+static u32 *
 cna_read_firmware(struct pci_dev *pdev, u32 **bfi_image,
 			u32 *bfi_image_size, char *fw_name)
 {
--- a/drivers/net/bna/bfa_ioc.h	2010-10-05 18:54:23.662672433 +0900
+++ b/drivers/net/bna/bfa_ioc.h	2010-10-05 18:54:30.857688208 +0900
@@ -271,7 +271,6 @@ void bfa_nw_ioc_enable(struct bfa_ioc *i
 void bfa_nw_ioc_disable(struct bfa_ioc *ioc);
 
 void bfa_nw_ioc_error_isr(struct bfa_ioc *ioc);
-bool bfa_nw_ioc_is_operational(struct bfa_ioc *ioc);
 
 void bfa_nw_ioc_get_attr(struct bfa_ioc *ioc, struct bfa_ioc_attr *ioc_attr);
 void bfa_nw_ioc_hbfail_register(struct bfa_ioc *ioc,
--- a/drivers/net/bna/bfa_sm.h	2010-10-05 19:12:40.405663296 +0900
+++ b/drivers/net/bna/bfa_sm.h	2010-10-05 19:12:48.897641119 +0900
@@ -77,7 +77,7 @@ typedef void (*bfa_fsm_t)(void *fsm, int
 	((_fsm)->fsm == (bfa_fsm_t)(_state))
 
 static inline int
-bfa_sm_to_state(struct bfa_sm_table *smt, bfa_sm_t sm)
+bfa_sm_to_state(const struct bfa_sm_table *smt, bfa_sm_t sm)
 {
 	int	i = 0;
 
