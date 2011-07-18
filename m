From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 09/45] bna: ENET and Tx Rx Redesign Update
Date: Mon, 18 Jul 2011 01:19:37 -0700
Message-ID: <1310977178-312-10-git-send-email-rmody@brocade.com>
References: <1310977178-312-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:48174 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753670Ab1GRIVA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:21:00 -0400
In-Reply-To: <1310977178-312-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change details:
 - This patch contains the structure and function definition changes to bna.h,
   bna_types.has a result of Ethport, Enet, IOCEth, Tx, Rx redesign. It removes
   all unused HW register definition from bna_hw.h. It contains structure name
   change for stats collection, removal of get_regs support in bnad_ethtool.c

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/Makefile       |    2 +-
 drivers/net/bna/bfa_ioc.c      |    2 +-
 drivers/net/bna/bfi.h          |    8 +
 drivers/net/bna/bfi_ll.h       |   13 -
 drivers/net/bna/bna.h          |  419 +++++++-----
 drivers/net/bna/bna_hw.h       | 1463 ++++++----------------------------------
 drivers/net/bna/bna_types.h    |  653 +++++++-----------
 drivers/net/bna/bnad.c         |  428 ++++++++-----
 drivers/net/bna/bnad.h         |   32 +-
 drivers/net/bna/bnad_ethtool.c |  384 +----------
 drivers/net/bna/cna.h          |   31 +-
 include/linux/pci_ids.h        |    1 +
 12 files changed, 1070 insertions(+), 2366 deletions(-)

diff --git a/drivers/net/bna/Makefile b/drivers/net/bna/Makefile
index d501f52..8becc00 100644
--- a/drivers/net/bna/Makefile
+++ b/drivers/net/bna/Makefile
@@ -5,7 +5,7 @@
 
 obj-$(CONFIG_BNA) += bna.o
 
-bna-objs := bnad.o bnad_ethtool.o bna_ctrl.o bna_txrx.o
+bna-objs := bnad.o bnad_ethtool.o bna_enet.o bna_txrx.o
 bna-objs += bfa_msgq.o bfa_ioc.o bfa_ioc_ct.o bfa_cee.o
 bna-objs += cna_fwimg.o
 
diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index bd833a1..ad98c86 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -19,7 +19,7 @@
 #include "bfa_ioc.h"
 #include "cna.h"
 #include "bfi.h"
-#include "bfi_ctreg.h"
+#include "bfi_reg.h"
 #include "bfa_defs.h"
 
 /**
diff --git a/drivers/net/bna/bfi.h b/drivers/net/bna/bfi.h
index 6640174..c5d46a6 100644
--- a/drivers/net/bna/bfi.h
+++ b/drivers/net/bna/bfi.h
@@ -149,6 +149,14 @@ struct bfi_mbmsg {
 };
 
 /**
+ * Supported PCI function class codes (personality)
+ */
+enum bfi_pcifn_class {
+	BFI_PCIFN_CLASS_FC	= 0x0c04,
+	BFI_PCIFN_CLASS_ETH	= 0x0200,
+};
+
+/**
  * Message Classes
  */
 enum bfi_mclass {
diff --git a/drivers/net/bna/bfi_ll.h b/drivers/net/bna/bfi_ll.h
index bee4d05..e3bdb87 100644
--- a/drivers/net/bna/bfi_ll.h
+++ b/drivers/net/bna/bfi_ll.h
@@ -233,19 +233,6 @@ struct bfi_ll_rsp {
 };
 
 /**
- * @brief bfi_ll_cee_aen is used by:
- *	BFI_LL_I2H_LINK_DOWN_AEN
- *	BFI_LL_I2H_LINK_UP_AEN
- */
-struct bfi_ll_aen {
-	struct bfi_mhdr mh;		/*!< common msg header */
-	u32	reason;
-	u8		cee_linkup;
-	u8		prio_map;    /*!< LL priority bit-map */
-	u8		rsvd[2];
-};
-
-/**
  * @brief
  * 	The following error codes can be returned
  *	by the mbox commands
diff --git a/drivers/net/bna/bna.h b/drivers/net/bna/bna.h
index 6b14c1d..b342bdb 100644
--- a/drivers/net/bna/bna.h
+++ b/drivers/net/bna/bna.h
@@ -16,10 +16,9 @@
 #include "bfa_wc.h"
 #include "bfa_ioc.h"
 #include "cna.h"
-#include "bfi_ll.h"
 #include "bna_types.h"
 
-extern const u32 bna_napi_dim_vector[][BNA_BIAS_T_MAX];
+extern u32 bna_napi_dim_vector[][BNA_BIAS_T_MAX];
 
 /**
  *
@@ -32,15 +31,7 @@ extern const u32 bna_napi_dim_vector[][BNA_BIAS_T_MAX];
 /* Log string size */
 #define BNA_MESSAGE_SIZE		256
 
-/* MBOX API for PORT, TX, RX */
-#define bna_mbox_qe_fill(_qe, _cmd, _cmd_len, _cbfn, _cbarg)		\
-do {									\
-	memcpy(&((_qe)->cmd.msg[0]), (_cmd), (_cmd_len));	\
-	(_qe)->cbfn = (_cbfn);						\
-	(_qe)->cbarg = (_cbarg);					\
-} while (0)
-
-#define bna_is_small_rxq(rcb) ((rcb)->id == 1)
+#define bna_is_small_rxq(_id) ((_id) & 0x1)
 
 #define BNA_MAC_IS_EQUAL(_mac1, _mac2)					\
 	(!memcmp((_mac1), (_mac2), sizeof(mac_t)))
@@ -177,32 +168,6 @@ do {								\
 #define BNA_Q_IN_USE_COUNT(_q_ptr)					\
 	(BNA_QE_IN_USE_CNT(&(_q_ptr)->q, (_q_ptr)->q.q_depth))
 
-/* These macros build the data portion of the TxQ/RxQ doorbell */
-#define BNA_DOORBELL_Q_PRD_IDX(_pi)	(0x80000000 | (_pi))
-#define BNA_DOORBELL_Q_STOP		(0x40000000)
-
-/* These macros build the data portion of the IB doorbell */
-#define BNA_DOORBELL_IB_INT_ACK(_timeout, _events) \
-	(0x80000000 | ((_timeout) << 16) | (_events))
-#define BNA_DOORBELL_IB_INT_DISABLE	(0x40000000)
-
-/* Set the coalescing timer for the given ib */
-#define bna_ib_coalescing_timer_set(_i_dbell, _cls_timer)		\
-	((_i_dbell)->doorbell_ack = BNA_DOORBELL_IB_INT_ACK((_cls_timer), 0));
-
-/* Acks 'events' # of events for a given ib */
-#define bna_ib_ack(_i_dbell, _events)					\
-	(writel(((_i_dbell)->doorbell_ack | (_events)), \
-		(_i_dbell)->doorbell_addr));
-
-#define bna_txq_prod_indx_doorbell(_tcb)				\
-	(writel(BNA_DOORBELL_Q_PRD_IDX((_tcb)->producer_index), \
-		(_tcb)->q_dbell));
-
-#define bna_rxq_prod_indx_doorbell(_rcb)				\
-	(writel(BNA_DOORBELL_Q_PRD_IDX((_rcb)->producer_index), \
-		(_rcb)->q_dbell));
-
 #define BNA_LARGE_PKT_SIZE		1000
 
 #define BNA_UPDATE_PKT_CNT(_pkt, _len)					\
@@ -214,38 +179,59 @@ do {									\
 	}								\
 } while (0)
 
-#define	call_rxf_stop_cbfn(rxf, status)					\
+#define	call_rxf_stop_cbfn(rxf)						\
+do {									\
 	if ((rxf)->stop_cbfn) {						\
-		(*(rxf)->stop_cbfn)((rxf)->stop_cbarg, (status));	\
+		void (*cbfn)(struct bna_rx *);			\
+		struct bna_rx *cbarg;					\
+		cbfn = (rxf)->stop_cbfn;				\
+		cbarg = (rxf)->stop_cbarg;				\
 		(rxf)->stop_cbfn = NULL;				\
 		(rxf)->stop_cbarg = NULL;				\
-	}
+		cbfn(cbarg);						\
+	}								\
+} while (0)
 
-#define	call_rxf_start_cbfn(rxf, status)				\
+#define	call_rxf_start_cbfn(rxf)					\
+do {									\
 	if ((rxf)->start_cbfn) {					\
-		(*(rxf)->start_cbfn)((rxf)->start_cbarg, (status));	\
+		void (*cbfn)(struct bna_rx *);			\
+		struct bna_rx *cbarg;					\
+		cbfn = (rxf)->start_cbfn;				\
+		cbarg = (rxf)->start_cbarg;				\
 		(rxf)->start_cbfn = NULL;				\
 		(rxf)->start_cbarg = NULL;				\
-	}
+		cbfn(cbarg);						\
+	}								\
+} while (0)
 
-#define	call_rxf_cam_fltr_cbfn(rxf, status)				\
+#define	call_rxf_cam_fltr_cbfn(rxf)					\
+do {									\
 	if ((rxf)->cam_fltr_cbfn) {					\
-		(*(rxf)->cam_fltr_cbfn)((rxf)->cam_fltr_cbarg, rxf->rx,	\
-					(status));			\
+		void (*cbfn)(struct bnad *, struct bna_rx *);	\
+		struct bnad *cbarg;					\
+		cbfn = (rxf)->cam_fltr_cbfn;				\
+		cbarg = (rxf)->cam_fltr_cbarg;				\
 		(rxf)->cam_fltr_cbfn = NULL;				\
 		(rxf)->cam_fltr_cbarg = NULL;				\
-	}
+		cbfn(cbarg, rxf->rx);					\
+	}								\
+} while (0)
 
-#define	call_rxf_pause_cbfn(rxf, status)				\
+#define	call_rxf_pause_cbfn(rxf)					\
+do {									\
 	if ((rxf)->oper_state_cbfn) {					\
-		(*(rxf)->oper_state_cbfn)((rxf)->oper_state_cbarg, rxf->rx,\
-					(status));			\
-		(rxf)->rxf_flags &= ~BNA_RXF_FL_OPERSTATE_CHANGED;	\
+		void (*cbfn)(struct bnad *, struct bna_rx *);	\
+		struct bnad *cbarg;					\
+		cbfn = (rxf)->oper_state_cbfn;				\
+		cbarg = (rxf)->oper_state_cbarg;			\
 		(rxf)->oper_state_cbfn = NULL;				\
 		(rxf)->oper_state_cbarg = NULL;				\
-	}
+		cbfn(cbarg, rxf->rx);					\
+	}								\
+} while (0)
 
-#define	call_rxf_resume_cbfn(rxf, status) call_rxf_pause_cbfn(rxf, status)
+#define	call_rxf_resume_cbfn(rxf) call_rxf_pause_cbfn(rxf)
 
 #define is_xxx_enable(mode, bitmask, xxx) ((bitmask & xxx) && (mode & xxx))
 
@@ -331,6 +317,59 @@ do {									\
 	}								\
 } while (0)
 
+#define bna_tx_rid_mask(_bna) ((_bna)->tx_mod.rid_mask)
+
+#define bna_rx_rid_mask(_bna) ((_bna)->rx_mod.rid_mask)
+
+#define bna_tx_from_rid(_bna, _rid, _tx)				\
+do {								    \
+	struct bna_tx_mod *__tx_mod = &(_bna)->tx_mod;	  \
+	struct bna_tx *__tx;					    \
+	struct list_head *qe;					   \
+	_tx = NULL;						     \
+	list_for_each(qe, &__tx_mod->tx_active_q) {		     \
+		__tx = (struct bna_tx *)qe;			     \
+		if (__tx->rid == (_rid)) {			      \
+			(_tx) = __tx;				   \
+			break;					  \
+		}						       \
+	}							       \
+} while (0)
+
+#define bna_rx_from_rid(_bna, _rid, _rx)				\
+do {									\
+	struct bna_rx_mod *__rx_mod = &(_bna)->rx_mod;			\
+	struct bna_rx *__rx;						\
+	struct list_head *qe;						\
+	_rx = NULL;							\
+	list_for_each(qe, &__rx_mod->rx_active_q) {			\
+		__rx = (struct bna_rx *)qe;				\
+		if (__rx->rid == (_rid)) {				\
+			(_rx) = __rx;					\
+			break;						\
+		}							\
+	}								\
+} while (0)
+
+/**
+ *
+ *  Inline functions
+ *
+ */
+
+static inline struct bna_mac *bna_mac_find(struct list_head *q, u8 *addr)
+{
+	struct bna_mac *mac = NULL;
+	struct list_head *qe;
+	list_for_each(qe, q) {
+		if (BNA_MAC_IS_EQUAL(((struct bna_mac *)qe)->addr, addr)) {
+			mac = (struct bna_mac *)qe;
+			break;
+		}
+	}
+	return mac;
+}
+
 /**
  *
  * Function prototypes
@@ -341,17 +380,23 @@ do {									\
  * BNA
  */
 
+/* FW response handlers */
+void bna_bfi_stats_get_rsp(struct bna *bna, struct bfi_msgq_mhdr *msghdr);
+void bna_bfi_stats_clr_rsp(struct bna *bna, struct bfi_msgq_mhdr *msghdr);
+
 /* APIs for BNAD */
 void bna_res_req(struct bna_res_info *res_info);
+void bna_mod_res_req(struct bna *bna, struct bna_res_info *res_info);
 void bna_init(struct bna *bna, struct bnad *bnad,
 			struct bfa_pcidev *pcidev,
 			struct bna_res_info *res_info);
+void bna_mod_init(struct bna *bna, struct bna_res_info *res_info);
 void bna_uninit(struct bna *bna);
 void bna_stats_get(struct bna *bna);
 void bna_get_perm_mac(struct bna *bna, u8 *mac);
+void bna_hw_stats_get(struct bna *bna);
 
 /* APIs for Rx */
-int bna_rit_mod_can_satisfy(struct bna_rit_mod *rit_mod, int seg_size);
 
 /* APIs for RxF */
 struct bna_mac *bna_ucam_mod_mac_get(struct bna_ucam_mod *ucam_mod);
@@ -360,79 +405,79 @@ void bna_ucam_mod_mac_put(struct bna_ucam_mod *ucam_mod,
 struct bna_mac *bna_mcam_mod_mac_get(struct bna_mcam_mod *mcam_mod);
 void bna_mcam_mod_mac_put(struct bna_mcam_mod *mcam_mod,
 			  struct bna_mac *mac);
-struct bna_rit_segment *
-bna_rit_mod_seg_get(struct bna_rit_mod *rit_mod, int seg_size);
-void bna_rit_mod_seg_put(struct bna_rit_mod *rit_mod,
-			struct bna_rit_segment *seg);
-
-/**
- * DEVICE
- */
-
-/* APIs for BNAD */
-void bna_device_enable(struct bna_device *device);
-void bna_device_disable(struct bna_device *device,
-			enum bna_cleanup_type type);
+struct bna_mcam_handle *bna_mcam_mod_handle_get(struct bna_mcam_mod *mod);
+void bna_mcam_mod_handle_put(struct bna_mcam_mod *mcam_mod,
+			  struct bna_mcam_handle *handle);
 
 /**
  * MBOX
  */
 
-/* APIs for PORT, TX, RX */
+/* API for BNAD */
 void bna_mbox_handler(struct bna *bna, u32 intr_status);
-void bna_mbox_send(struct bna *bna, struct bna_mbox_qe *mbox_qe);
 
 /**
- * PORT
+ * ETHPORT
  */
 
-/* API for RX */
-int bna_port_mtu_get(struct bna_port *port);
-void bna_llport_rx_started(struct bna_llport *llport);
-void bna_llport_rx_stopped(struct bna_llport *llport);
+/* FW response handlers */
+void bna_bfi_ethport_admin_rsp(struct bna_ethport *ethport,
+			       struct bfi_msgq_mhdr *msghdr);
+void bna_bfi_ethport_lpbk_rsp(struct bna_ethport *ethport,
+			      struct bfi_msgq_mhdr *msghdr);
+void bna_bfi_ethport_linkup_aen(struct bna_ethport *ethport,
+				struct bfi_msgq_mhdr *msghdr);
+void bna_bfi_ethport_linkdown_aen(struct bna_ethport *ethport,
+				struct bfi_msgq_mhdr *msghdr);
+void bna_bfi_ethport_enable_aen(struct bna_ethport *ethport,
+				struct bfi_msgq_mhdr *msghdr);
+void bna_bfi_ethport_disable_aen(struct bna_ethport *ethport,
+				struct bfi_msgq_mhdr *msghdr);
+
+/* Callbacks for RX */
+void bna_ethport_cb_rx_started(struct bna_ethport *ethport);
+void bna_ethport_cb_rx_stopped(struct bna_ethport *ethport);
+
+/* APIs for ENET */
+void bna_ethport_start(struct bna_ethport *ethport);
+void bna_ethport_stop(struct bna_ethport *ethport);
+void bna_ethport_fail(struct bna_ethport *ethport);
 
-/* API for BNAD */
-void bna_port_enable(struct bna_port *port);
-void bna_port_disable(struct bna_port *port, enum bna_cleanup_type type,
-		      void (*cbfn)(void *, enum bna_cb_status));
-void bna_port_pause_config(struct bna_port *port,
-			   struct bna_pause_config *pause_config,
-			   void (*cbfn)(struct bnad *, enum bna_cb_status));
-void bna_port_mtu_set(struct bna_port *port, int mtu,
-		      void (*cbfn)(struct bnad *, enum bna_cb_status));
-void bna_port_mac_get(struct bna_port *port, mac_t *mac);
+/* APIs for BNA */
+void bna_ethport_init(struct bna_ethport *ethport, struct bna *bna);
+void bna_ethport_uninit(struct bna_ethport *ethport);
 
-/* Callbacks for TX, RX */
-void bna_port_cb_tx_stopped(struct bna_port *port,
-			    enum bna_cb_status status);
-void bna_port_cb_rx_stopped(struct bna_port *port,
-			    enum bna_cb_status status);
+/* APIs for BNAD */
+void bna_ethport_admin_up(struct bna_ethport *ethport,
+			void (*cbfn)(struct bnad *, enum bna_cb_status));
+void bna_ethport_admin_down(struct bna_ethport *ethport);
+void bna_ethport_linkcbfn_set(struct bna_ethport *ethport,
+			   void (*linkcbfn)(struct bnad *,
+					    enum bna_link_status));
+int bna_ethport_is_disabled(struct bna_ethport *ethport);
 
 /**
- * IB
+ * TX MODULE AND TX
  */
 
-/* APIs for BNA */
-void bna_ib_mod_init(struct bna_ib_mod *ib_mod, struct bna *bna,
-		     struct bna_res_info *res_info);
-void bna_ib_mod_uninit(struct bna_ib_mod *ib_mod);
+/* FW response handelrs */
+void bna_bfi_tx_enet_start_rsp(struct bna_tx *tx,
+			       struct bfi_msgq_mhdr *msghdr);
+void bna_bfi_tx_enet_stop_rsp(struct bna_tx *tx,
+			      struct bfi_msgq_mhdr *msghdr);
+void bna_bfi_bw_update_aen(struct bna_tx_mod *tx_mod);
 
-/**
- * TX MODULE AND TX
- */
+/* APIs for ENET */
+void bna_tx_mod_start(struct bna_tx_mod *tx_mod, enum bna_tx_type type);
+void bna_tx_mod_stop(struct bna_tx_mod *tx_mod, enum bna_tx_type type);
+void bna_tx_mod_fail(struct bna_tx_mod *tx_mod);
+void bna_tx_mod_prio_reconfig(struct bna_tx_mod *tx_mod, int cee_linkup,
+			      u8 prio_map, u8 iscsi_prio_map);
 
 /* APIs for BNA */
 void bna_tx_mod_init(struct bna_tx_mod *tx_mod, struct bna *bna,
 		     struct bna_res_info *res_info);
 void bna_tx_mod_uninit(struct bna_tx_mod *tx_mod);
-int bna_tx_state_get(struct bna_tx *tx);
-
-/* APIs for PORT */
-void bna_tx_mod_start(struct bna_tx_mod *tx_mod, enum bna_tx_type type);
-void bna_tx_mod_stop(struct bna_tx_mod *tx_mod, enum bna_tx_type type);
-void bna_tx_mod_fail(struct bna_tx_mod *tx_mod);
-void bna_tx_mod_prio_changed(struct bna_tx_mod *tx_mod, int prio);
-void bna_tx_mod_cee_link_status(struct bna_tx_mod *tx_mod, int cee_link);
 
 /* APIs for BNAD */
 void bna_tx_res_req(int num_txq, int txq_depth,
@@ -444,46 +489,34 @@ struct bna_tx *bna_tx_create(struct bna *bna, struct bnad *bnad,
 void bna_tx_destroy(struct bna_tx *tx);
 void bna_tx_enable(struct bna_tx *tx);
 void bna_tx_disable(struct bna_tx *tx, enum bna_cleanup_type type,
-		    void (*cbfn)(void *, struct bna_tx *,
-				 enum bna_cb_status));
+		    void (*cbfn)(void *, struct bna_tx *));
+void bna_tx_cleanup_complete(struct bna_tx *tx);
+void bna_tx_prio_set(struct bna_tx *tx, int prio,
+		     void (*cbfn)(struct bnad *, struct bna_tx *));
 void bna_tx_coalescing_timeo_set(struct bna_tx *tx, int coalescing_timeo);
 
 /**
  * RX MODULE, RX, RXF
  */
 
-/* Internal APIs */
-void rxf_cb_cam_fltr_mbox_cmd(void *arg, int status);
-void rxf_cam_mbox_cmd(struct bna_rxf *rxf, u8 cmd,
-		const struct bna_mac *mac_addr);
-void __rxf_vlan_filter_set(struct bna_rxf *rxf, enum bna_status status);
-void bna_rxf_adv_init(struct bna_rxf *rxf,
-		struct bna_rx *rx,
-		struct bna_rx_config *q_config);
-int rxf_process_packet_filter_ucast(struct bna_rxf *rxf);
-int rxf_process_packet_filter_promisc(struct bna_rxf *rxf);
-int rxf_process_packet_filter_default(struct bna_rxf *rxf);
-int rxf_process_packet_filter_allmulti(struct bna_rxf *rxf);
-int rxf_clear_packet_filter_ucast(struct bna_rxf *rxf);
-int rxf_clear_packet_filter_promisc(struct bna_rxf *rxf);
-int rxf_clear_packet_filter_default(struct bna_rxf *rxf);
-int rxf_clear_packet_filter_allmulti(struct bna_rxf *rxf);
-void rxf_reset_packet_filter_ucast(struct bna_rxf *rxf);
-void rxf_reset_packet_filter_promisc(struct bna_rxf *rxf);
-void rxf_reset_packet_filter_default(struct bna_rxf *rxf);
-void rxf_reset_packet_filter_allmulti(struct bna_rxf *rxf);
+/* FW response handlers */
+void bna_bfi_rx_enet_start_rsp(struct bna_rx *rx,
+			       struct bfi_msgq_mhdr *msghdr);
+void bna_bfi_rx_enet_stop_rsp(struct bna_rx *rx,
+			      struct bfi_msgq_mhdr *msghdr);
+void bna_bfi_rxf_cfg_rsp(struct bna_rxf *rxf, struct bfi_msgq_mhdr *msghdr);
+void bna_bfi_rxf_mcast_add_rsp(struct bna_rxf *rxf,
+			       struct bfi_msgq_mhdr *msghdr);
+
+/* APIs for ENET */
+void bna_rx_mod_start(struct bna_rx_mod *rx_mod, enum bna_rx_type type);
+void bna_rx_mod_stop(struct bna_rx_mod *rx_mod, enum bna_rx_type type);
+void bna_rx_mod_fail(struct bna_rx_mod *rx_mod);
 
 /* APIs for BNA */
 void bna_rx_mod_init(struct bna_rx_mod *rx_mod, struct bna *bna,
 		     struct bna_res_info *res_info);
 void bna_rx_mod_uninit(struct bna_rx_mod *rx_mod);
-int bna_rx_state_get(struct bna_rx *rx);
-int bna_rxf_state_get(struct bna_rxf *rxf);
-
-/* APIs for PORT */
-void bna_rx_mod_start(struct bna_rx_mod *rx_mod, enum bna_rx_type type);
-void bna_rx_mod_stop(struct bna_rx_mod *rx_mod, enum bna_rx_type type);
-void bna_rx_mod_fail(struct bna_rx_mod *rx_mod);
 
 /* APIs for BNAD */
 void bna_rx_res_req(struct bna_rx_config *rx_config,
@@ -495,54 +528,120 @@ struct bna_rx *bna_rx_create(struct bna *bna, struct bnad *bnad,
 void bna_rx_destroy(struct bna_rx *rx);
 void bna_rx_enable(struct bna_rx *rx);
 void bna_rx_disable(struct bna_rx *rx, enum bna_cleanup_type type,
-		    void (*cbfn)(void *, struct bna_rx *,
-				 enum bna_cb_status));
+		    void (*cbfn)(void *, struct bna_rx *));
+void bna_rx_cleanup_complete(struct bna_rx *rx);
 void bna_rx_coalescing_timeo_set(struct bna_rx *rx, int coalescing_timeo);
-void bna_rx_dim_reconfig(struct bna *bna, const u32 vector[][BNA_BIAS_T_MAX]);
+void bna_rx_dim_reconfig(struct bna *bna, u32 vector[][BNA_BIAS_T_MAX]);
 void bna_rx_dim_update(struct bna_ccb *ccb);
 enum bna_cb_status
 bna_rx_ucast_set(struct bna_rx *rx, u8 *ucmac,
-		 void (*cbfn)(struct bnad *, struct bna_rx *,
-			      enum bna_cb_status));
+		 void (*cbfn)(struct bnad *, struct bna_rx *));
+enum bna_cb_status
+bna_rx_ucast_add(struct bna_rx *rx, u8* ucmac,
+		 void (*cbfn)(struct bnad *, struct bna_rx *));
+enum bna_cb_status
+bna_rx_ucast_del(struct bna_rx *rx, u8 *ucmac,
+		 void (*cbfn)(struct bnad *, struct bna_rx *));
 enum bna_cb_status
 bna_rx_mcast_add(struct bna_rx *rx, u8 *mcmac,
-		 void (*cbfn)(struct bnad *, struct bna_rx *,
-			      enum bna_cb_status));
+		 void (*cbfn)(struct bnad *, struct bna_rx *));
+enum bna_cb_status
+bna_rx_mcast_del(struct bna_rx *rx, u8 *mcmac,
+		 void (*cbfn)(struct bnad *, struct bna_rx *));
 enum bna_cb_status
 bna_rx_mcast_listset(struct bna_rx *rx, int count, u8 *mcmac,
-		     void (*cbfn)(struct bnad *, struct bna_rx *,
-				  enum bna_cb_status));
+		     void (*cbfn)(struct bnad *, struct bna_rx *));
+void bna_rx_mcast_delall(struct bna_rx *rx,
+			 void (*cbfn)(struct bnad *, struct bna_rx *));
 enum bna_cb_status
 bna_rx_mode_set(struct bna_rx *rx, enum bna_rxmode rxmode,
 		enum bna_rxmode bitmask,
-		void (*cbfn)(struct bnad *, struct bna_rx *,
-			     enum bna_cb_status));
+		void (*cbfn)(struct bnad *, struct bna_rx *));
 void bna_rx_vlan_add(struct bna_rx *rx, int vlan_id);
 void bna_rx_vlan_del(struct bna_rx *rx, int vlan_id);
 void bna_rx_vlanfilter_enable(struct bna_rx *rx);
-void bna_rx_hds_enable(struct bna_rx *rx, struct bna_rxf_hds *hds_config,
-		       void (*cbfn)(struct bnad *, struct bna_rx *,
-				    enum bna_cb_status));
+void bna_rx_hds_enable(struct bna_rx *rx, struct bna_hds_config *hds_config,
+		       void (*cbfn)(struct bnad *, struct bna_rx *));
 void bna_rx_hds_disable(struct bna_rx *rx,
-			void (*cbfn)(struct bnad *, struct bna_rx *,
-				     enum bna_cb_status));
+			void (*cbfn)(struct bnad *, struct bna_rx *));
+
+/**
+ * ENET
+ */
+
+/* FW response handlers */
+void bna_bfi_pause_set_rsp(struct bna_enet *enet,
+			   struct bfi_msgq_mhdr *msghdr);
+
+/* API for RX */
+int bna_enet_mtu_get(struct bna_enet *enet);
+
+/* Callbacks for ETHPORT, TX, RX */
+void bna_enet_cb_ethport_stopped(struct bna_enet *enet);
+void bna_enet_cb_tx_stopped(struct bna_enet *enet);
+void bna_enet_cb_rx_stopped(struct bna_enet *enet);
+
+/* APIs for IOCETH */
+void bna_enet_start(struct bna_enet *enet);
+void bna_enet_stop(struct bna_enet *enet);
+void bna_enet_fail(struct bna_enet *enet);
+
+/* APIs for BNA */
+void bna_enet_init(struct bna_enet *enet, struct bna *bna);
+void bna_enet_uninit(struct bna_enet *enet);
+
+/* API for BNAD */
+void bna_enet_enable(struct bna_enet *enet);
+void bna_enet_disable(struct bna_enet *enet, enum bna_cleanup_type type,
+		      void (*cbfn)(void *));
+void bna_enet_pause_config(struct bna_enet *enet,
+			   struct bna_pause_config *pause_config,
+			   void (*cbfn)(struct bnad *));
+void bna_enet_mtu_set(struct bna_enet *enet, int mtu,
+		      void (*cbfn)(struct bnad *));
+void bna_enet_perm_mac_get(struct bna_enet *enet, mac_t *mac);
+void bna_enet_type_set(struct bna_enet *enet, enum bna_enet_type type);
+enum bna_enet_type bna_enet_type_get(struct bna_enet *enet);
+
+/**
+ * IOCETH
+ */
+
+/* FW response handlers */
+void bna_bfi_attr_get_rsp(struct bna_ioceth *ioceth,
+			  struct bfi_msgq_mhdr *msghdr);
+
+/* APIs for ENET etc */
+void bna_ioceth_cb_enet_stopped(void *arg);
+
+/* APIs for BNA */
+void bna_ioceth_init(struct bna_ioceth *ioceth, struct bna *bna,
+		     struct bna_res_info *res_info);
+void bna_ioceth_uninit(struct bna_ioceth *ioceth);
+bool bna_ioceth_state_is_failed(struct bna_ioceth *ioceth);
+
+/* APIs for BNAD */
+void bna_ioceth_enable(struct bna_ioceth *ioceth);
+void bna_ioceth_disable(struct bna_ioceth *ioceth,
+			enum bna_cleanup_type type);
 
 /**
  * BNAD
  */
 
+/* Callbacks for ENET */
+void bnad_cb_ethport_link_status(struct bnad *bnad,
+			      enum bna_link_status status);
+
+/* Callbacks for IOCETH */
+void bnad_cb_ioceth_ready(struct bnad *bnad);
+void bnad_cb_ioceth_failed(struct bnad *bnad);
+void bnad_cb_ioceth_disabled(struct bnad *bnad);
+void bnad_cb_mbox_intr_enable(struct bnad *bnad);
+void bnad_cb_mbox_intr_disable(struct bnad *bnad);
+
 /* Callbacks for BNA */
 void bnad_cb_stats_get(struct bnad *bnad, enum bna_cb_status status,
 		       struct bna_stats *stats);
 
-/* Callbacks for DEVICE */
-void bnad_cb_device_enabled(struct bnad *bnad, enum bna_cb_status status);
-void bnad_cb_device_disabled(struct bnad *bnad, enum bna_cb_status status);
-void bnad_cb_device_enable_mbox_intr(struct bnad *bnad);
-void bnad_cb_device_disable_mbox_intr(struct bnad *bnad);
-
-/* Callbacks for port */
-void bnad_cb_port_link_status(struct bnad *bnad,
-			      enum bna_link_status status);
-
 #endif  /* __BNA_H__ */
diff --git a/drivers/net/bna/bna_hw.h b/drivers/net/bna/bna_hw.h
index cad233d..80b21ee 100644
--- a/drivers/net/bna/bna_hw.h
+++ b/drivers/net/bna/bna_hw.h
@@ -14,14 +14,16 @@
  * Copyright (c) 2005-2010 Brocade Communications Systems, Inc.
  * All rights reserved
  * www.brocade.com
- *
+ */
+
+/**
  * File for interrupt macros and functions
  */
 
 #ifndef __BNA_HW_H__
 #define __BNA_HW_H__
 
-#include "bfi_ctreg.h"
+#include "bfi_reg.h"
 
 /**
  *
@@ -29,98 +31,16 @@
  *
  */
 
-#ifndef BNA_BIOS_BUILD
-
-#define BFI_MAX_TXQ			64
-#define BFI_MAX_RXQ			64
-#define	BFI_MAX_RXF			64
-#define BFI_MAX_IB			128
-#define	BFI_MAX_RIT_SIZE		256
-#define	BFI_RSS_RIT_SIZE		64
-#define	BFI_NONRSS_RIT_SIZE		1
-#define BFI_MAX_UCMAC			256
-#define BFI_MAX_MCMAC			512
-#define BFI_IBIDX_SIZE			4
-#define BFI_MAX_VLAN			4095
+#define BFI_ENET_MAX_MCAM		256
 
-/**
- * There are 2 free IB index pools:
- *	pool1: 120 segments of 1 index each
- *	pool8: 1 segment of 8 indexes
- */
-#define BFI_IBIDX_POOL1_SIZE		116
-#define	BFI_IBIDX_POOL1_ENTRY_SIZE	1
-#define BFI_IBIDX_POOL2_SIZE		2
-#define	BFI_IBIDX_POOL2_ENTRY_SIZE	2
-#define	BFI_IBIDX_POOL8_SIZE		1
-#define	BFI_IBIDX_POOL8_ENTRY_SIZE	8
-#define	BFI_IBIDX_TOTAL_POOLS		3
-#define	BFI_IBIDX_TOTAL_SEGS		119 /* (POOL1 + POOL2 + POOL8)_SIZE */
-#define	BFI_IBIDX_MAX_SEGSIZE		8
-#define init_ibidx_pool(name)						\
-static struct bna_ibidx_pool name[BFI_IBIDX_TOTAL_POOLS] =		\
-{									\
-	{ BFI_IBIDX_POOL1_SIZE, BFI_IBIDX_POOL1_ENTRY_SIZE },		\
-	{ BFI_IBIDX_POOL2_SIZE, BFI_IBIDX_POOL2_ENTRY_SIZE },		\
-	{ BFI_IBIDX_POOL8_SIZE, BFI_IBIDX_POOL8_ENTRY_SIZE }		\
-}
+#define BFI_INVALID_RID			-1
 
-/**
- * There are 2 free RIT segment pools:
- *	Pool1: 192 segments of 1 RIT entry each
- *	Pool2: 1 segment of 64 RIT entry
- */
-#define BFI_RIT_SEG_POOL1_SIZE		192
-#define BFI_RIT_SEG_POOL1_ENTRY_SIZE	1
-#define BFI_RIT_SEG_POOLRSS_SIZE	1
-#define BFI_RIT_SEG_POOLRSS_ENTRY_SIZE	64
-#define BFI_RIT_SEG_TOTAL_POOLS		2
-#define BFI_RIT_TOTAL_SEGS		193 /* POOL1_SIZE + POOLRSS_SIZE */
-#define init_ritseg_pool(name)						\
-static struct bna_ritseg_pool_cfg name[BFI_RIT_SEG_TOTAL_POOLS] =	\
-{									\
-	{ BFI_RIT_SEG_POOL1_SIZE, BFI_RIT_SEG_POOL1_ENTRY_SIZE },	\
-	{ BFI_RIT_SEG_POOLRSS_SIZE, BFI_RIT_SEG_POOLRSS_ENTRY_SIZE }	\
-}
-
-#else /* BNA_BIOS_BUILD */
-
-#define BFI_MAX_TXQ			1
-#define BFI_MAX_RXQ			1
-#define	BFI_MAX_RXF			1
-#define BFI_MAX_IB			2
-#define	BFI_MAX_RIT_SIZE		2
-#define	BFI_RSS_RIT_SIZE		64
-#define	BFI_NONRSS_RIT_SIZE		1
-#define BFI_MAX_UCMAC			1
-#define BFI_MAX_MCMAC			8
 #define BFI_IBIDX_SIZE			4
-#define BFI_MAX_VLAN			4095
-/* There is one free pool: 2 segments of 1 index each */
-#define BFI_IBIDX_POOL1_SIZE		2
-#define	BFI_IBIDX_POOL1_ENTRY_SIZE	1
-#define	BFI_IBIDX_TOTAL_POOLS		1
-#define	BFI_IBIDX_TOTAL_SEGS		2 /* POOL1_SIZE */
-#define	BFI_IBIDX_MAX_SEGSIZE		1
-#define init_ibidx_pool(name)						\
-static struct bna_ibidx_pool name[BFI_IBIDX_TOTAL_POOLS] =		\
-{									\
-	{ BFI_IBIDX_POOL1_SIZE, BFI_IBIDX_POOL1_ENTRY_SIZE }		\
-}
 
-#define BFI_RIT_SEG_POOL1_SIZE		1
-#define BFI_RIT_SEG_POOL1_ENTRY_SIZE	1
-#define BFI_RIT_SEG_TOTAL_POOLS		1
-#define BFI_RIT_TOTAL_SEGS		1 /* POOL1_SIZE */
-#define init_ritseg_pool(name)						\
-static struct bna_ritseg_pool_cfg name[BFI_RIT_SEG_TOTAL_POOLS] =	\
-{									\
-	{ BFI_RIT_SEG_POOL1_SIZE, BFI_RIT_SEG_POOL1_ENTRY_SIZE }	\
-}
-
-#endif /* BNA_BIOS_BUILD */
-
-#define BFI_RSS_HASH_KEY_LEN		10
+#define BFI_VLAN_WORD_SHIFT		5	/* 32 bits */
+#define BFI_VLAN_WORD_MASK		0x1F
+#define BFI_VLAN_BLOCK_SHIFT		9	/* 512 bits */
+#define BFI_VLAN_BMASK_ALL		0xFF
 
 #define BFI_COALESCING_TIMER_UNIT	5	/* 5us */
 #define BFI_MAX_COALESCING_TIMEO	0xFF	/* in 5us units */
@@ -145,1018 +65,215 @@ static struct bna_ritseg_pool_cfg name[BFI_RIT_SEG_TOTAL_POOLS] =	\
 /* Small Q buffer size */
 #define BFI_SMALL_RXBUF_SIZE		128
 
-/* Defined separately since BFA_FLASH_DMA_BUF_SZ is in bfa_flash.c */
-#define BFI_FLASH_DMA_BUF_SZ		0x010000 /* 64K DMA */
-#define BFI_HW_STATS_SIZE		0x4000 /* 16K DMA */
-
-/**
- *
- * HW register offsets, macros
- *
- */
-
-/* DMA Block Register Host Window Start Address */
-#define DMA_BLK_REG_ADDR		0x00013000
-
-/* DMA Block Internal Registers */
-#define DMA_CTRL_REG0			(DMA_BLK_REG_ADDR + 0x000)
-#define DMA_CTRL_REG1			(DMA_BLK_REG_ADDR + 0x004)
-#define DMA_ERR_INT_STATUS		(DMA_BLK_REG_ADDR + 0x008)
-#define DMA_ERR_INT_ENABLE		(DMA_BLK_REG_ADDR + 0x00c)
-#define DMA_ERR_INT_STATUS_SET		(DMA_BLK_REG_ADDR + 0x010)
-
-/* APP Block Register Address Offset from BAR0 */
-#define APP_BLK_REG_ADDR		0x00014000
-
-/* Host Function Interrupt Mask Registers */
-#define HOSTFN0_INT_MASK		(APP_BLK_REG_ADDR + 0x004)
-#define HOSTFN1_INT_MASK		(APP_BLK_REG_ADDR + 0x104)
-#define HOSTFN2_INT_MASK		(APP_BLK_REG_ADDR + 0x304)
-#define HOSTFN3_INT_MASK		(APP_BLK_REG_ADDR + 0x404)
-
-/**
- * Host Function PCIe Error Registers
- * Duplicates "Correctable" & "Uncorrectable"
- * registers in PCIe Config space.
- */
-#define FN0_PCIE_ERR_REG		(APP_BLK_REG_ADDR + 0x014)
-#define FN1_PCIE_ERR_REG		(APP_BLK_REG_ADDR + 0x114)
-#define FN2_PCIE_ERR_REG		(APP_BLK_REG_ADDR + 0x314)
-#define FN3_PCIE_ERR_REG		(APP_BLK_REG_ADDR + 0x414)
-
-/* Host Function Error Type Status Registers */
-#define FN0_ERR_TYPE_STATUS_REG		(APP_BLK_REG_ADDR + 0x018)
-#define FN1_ERR_TYPE_STATUS_REG		(APP_BLK_REG_ADDR + 0x118)
-#define FN2_ERR_TYPE_STATUS_REG		(APP_BLK_REG_ADDR + 0x318)
-#define FN3_ERR_TYPE_STATUS_REG		(APP_BLK_REG_ADDR + 0x418)
-
-/* Host Function Error Type Mask Registers */
-#define FN0_ERR_TYPE_MSK_STATUS_REG	(APP_BLK_REG_ADDR + 0x01c)
-#define FN1_ERR_TYPE_MSK_STATUS_REG	(APP_BLK_REG_ADDR + 0x11c)
-#define FN2_ERR_TYPE_MSK_STATUS_REG	(APP_BLK_REG_ADDR + 0x31c)
-#define FN3_ERR_TYPE_MSK_STATUS_REG	(APP_BLK_REG_ADDR + 0x41c)
-
-/* Catapult Host Semaphore Status Registers (App block) */
-#define HOST_SEM_STS0_REG		(APP_BLK_REG_ADDR + 0x630)
-#define HOST_SEM_STS1_REG		(APP_BLK_REG_ADDR + 0x634)
-#define HOST_SEM_STS2_REG		(APP_BLK_REG_ADDR + 0x638)
-#define HOST_SEM_STS3_REG		(APP_BLK_REG_ADDR + 0x63c)
-#define HOST_SEM_STS4_REG		(APP_BLK_REG_ADDR + 0x640)
-#define HOST_SEM_STS5_REG		(APP_BLK_REG_ADDR + 0x644)
-#define HOST_SEM_STS6_REG		(APP_BLK_REG_ADDR + 0x648)
-#define HOST_SEM_STS7_REG		(APP_BLK_REG_ADDR + 0x64c)
-
-/* PCIe Misc Register */
-#define PCIE_MISC_REG			(APP_BLK_REG_ADDR + 0x200)
-
-/* Temp Sensor Control Registers */
-#define TEMPSENSE_CNTL_REG		(APP_BLK_REG_ADDR + 0x250)
-#define TEMPSENSE_STAT_REG		(APP_BLK_REG_ADDR + 0x254)
-
-/* APP Block local error registers */
-#define APP_LOCAL_ERR_STAT		(APP_BLK_REG_ADDR + 0x258)
-#define APP_LOCAL_ERR_MSK		(APP_BLK_REG_ADDR + 0x25c)
-
-/* PCIe Link Error registers */
-#define PCIE_LNK_ERR_STAT		(APP_BLK_REG_ADDR + 0x260)
-#define PCIE_LNK_ERR_MSK		(APP_BLK_REG_ADDR + 0x264)
-
-/**
- * FCoE/FIP Ethertype Register
- * 31:16 -- Chip wide value for FIP type
- * 15:0  -- Chip wide value for FCoE type
- */
-#define FCOE_FIP_ETH_TYPE		(APP_BLK_REG_ADDR + 0x280)
-
-/**
- * Reserved Ethertype Register
- * 31:16 -- Reserved
- * 15:0  -- Other ethertype
- */
-#define RESV_ETH_TYPE			(APP_BLK_REG_ADDR + 0x284)
-
-/**
- * Host Command Status Registers
- * Each set consists of 3 registers :
- * clear, set, cmd
- * 16 such register sets in all
- * See catapult_spec.pdf for detailed functionality
- * Put each type in a single macro accessed by _num ?
- */
-#define HOST_CMDSTS0_CLR_REG		(APP_BLK_REG_ADDR + 0x500)
-#define HOST_CMDSTS0_SET_REG		(APP_BLK_REG_ADDR + 0x504)
-#define HOST_CMDSTS0_REG		(APP_BLK_REG_ADDR + 0x508)
-#define HOST_CMDSTS1_CLR_REG		(APP_BLK_REG_ADDR + 0x510)
-#define HOST_CMDSTS1_SET_REG		(APP_BLK_REG_ADDR + 0x514)
-#define HOST_CMDSTS1_REG		(APP_BLK_REG_ADDR + 0x518)
-#define HOST_CMDSTS2_CLR_REG		(APP_BLK_REG_ADDR + 0x520)
-#define HOST_CMDSTS2_SET_REG		(APP_BLK_REG_ADDR + 0x524)
-#define HOST_CMDSTS2_REG		(APP_BLK_REG_ADDR + 0x528)
-#define HOST_CMDSTS3_CLR_REG		(APP_BLK_REG_ADDR + 0x530)
-#define HOST_CMDSTS3_SET_REG		(APP_BLK_REG_ADDR + 0x534)
-#define HOST_CMDSTS3_REG		(APP_BLK_REG_ADDR + 0x538)
-#define HOST_CMDSTS4_CLR_REG		(APP_BLK_REG_ADDR + 0x540)
-#define HOST_CMDSTS4_SET_REG		(APP_BLK_REG_ADDR + 0x544)
-#define HOST_CMDSTS4_REG		(APP_BLK_REG_ADDR + 0x548)
-#define HOST_CMDSTS5_CLR_REG		(APP_BLK_REG_ADDR + 0x550)
-#define HOST_CMDSTS5_SET_REG		(APP_BLK_REG_ADDR + 0x554)
-#define HOST_CMDSTS5_REG		(APP_BLK_REG_ADDR + 0x558)
-#define HOST_CMDSTS6_CLR_REG		(APP_BLK_REG_ADDR + 0x560)
-#define HOST_CMDSTS6_SET_REG		(APP_BLK_REG_ADDR + 0x564)
-#define HOST_CMDSTS6_REG		(APP_BLK_REG_ADDR + 0x568)
-#define HOST_CMDSTS7_CLR_REG		(APP_BLK_REG_ADDR + 0x570)
-#define HOST_CMDSTS7_SET_REG		(APP_BLK_REG_ADDR + 0x574)
-#define HOST_CMDSTS7_REG		(APP_BLK_REG_ADDR + 0x578)
-#define HOST_CMDSTS8_CLR_REG		(APP_BLK_REG_ADDR + 0x580)
-#define HOST_CMDSTS8_SET_REG		(APP_BLK_REG_ADDR + 0x584)
-#define HOST_CMDSTS8_REG		(APP_BLK_REG_ADDR + 0x588)
-#define HOST_CMDSTS9_CLR_REG		(APP_BLK_REG_ADDR + 0x590)
-#define HOST_CMDSTS9_SET_REG		(APP_BLK_REG_ADDR + 0x594)
-#define HOST_CMDSTS9_REG		(APP_BLK_REG_ADDR + 0x598)
-#define HOST_CMDSTS10_CLR_REG		(APP_BLK_REG_ADDR + 0x5A0)
-#define HOST_CMDSTS10_SET_REG		(APP_BLK_REG_ADDR + 0x5A4)
-#define HOST_CMDSTS10_REG		(APP_BLK_REG_ADDR + 0x5A8)
-#define HOST_CMDSTS11_CLR_REG		(APP_BLK_REG_ADDR + 0x5B0)
-#define HOST_CMDSTS11_SET_REG		(APP_BLK_REG_ADDR + 0x5B4)
-#define HOST_CMDSTS11_REG		(APP_BLK_REG_ADDR + 0x5B8)
-#define HOST_CMDSTS12_CLR_REG		(APP_BLK_REG_ADDR + 0x5C0)
-#define HOST_CMDSTS12_SET_REG		(APP_BLK_REG_ADDR + 0x5C4)
-#define HOST_CMDSTS12_REG		(APP_BLK_REG_ADDR + 0x5C8)
-#define HOST_CMDSTS13_CLR_REG		(APP_BLK_REG_ADDR + 0x5D0)
-#define HOST_CMDSTS13_SET_REG		(APP_BLK_REG_ADDR + 0x5D4)
-#define HOST_CMDSTS13_REG		(APP_BLK_REG_ADDR + 0x5D8)
-#define HOST_CMDSTS14_CLR_REG		(APP_BLK_REG_ADDR + 0x5E0)
-#define HOST_CMDSTS14_SET_REG		(APP_BLK_REG_ADDR + 0x5E4)
-#define HOST_CMDSTS14_REG		(APP_BLK_REG_ADDR + 0x5E8)
-#define HOST_CMDSTS15_CLR_REG		(APP_BLK_REG_ADDR + 0x5F0)
-#define HOST_CMDSTS15_SET_REG		(APP_BLK_REG_ADDR + 0x5F4)
-#define HOST_CMDSTS15_REG		(APP_BLK_REG_ADDR + 0x5F8)
-
-/**
- * LPU0 Block Register Address Offset from BAR0
- * Range 0x18000 - 0x18033
- */
-#define LPU0_BLK_REG_ADDR		0x00018000
-
-/**
- * LPU0 Registers
- * Should they be directly used from host,
- * except for diagnostics ?
- * CTL_REG : Control register
- * CMD_REG : Triggers exec. of cmd. in
- *           Mailbox memory
- */
-#define LPU0_MBOX_CTL_REG		(LPU0_BLK_REG_ADDR + 0x000)
-#define LPU0_MBOX_CMD_REG		(LPU0_BLK_REG_ADDR + 0x004)
-#define LPU0_MBOX_LINK_0REG		(LPU0_BLK_REG_ADDR + 0x008)
-#define LPU1_MBOX_LINK_0REG		(LPU0_BLK_REG_ADDR + 0x00c)
-#define LPU0_MBOX_STATUS_0REG		(LPU0_BLK_REG_ADDR + 0x010)
-#define LPU1_MBOX_STATUS_0REG		(LPU0_BLK_REG_ADDR + 0x014)
-#define LPU0_ERR_STATUS_REG		(LPU0_BLK_REG_ADDR + 0x018)
-#define LPU0_ERR_SET_REG		(LPU0_BLK_REG_ADDR + 0x020)
-
-/**
- * LPU1 Block Register Address Offset from BAR0
- * Range 0x18400 - 0x18433
- */
-#define LPU1_BLK_REG_ADDR		0x00018400
-
-/**
- * LPU1 Registers
- * Same as LPU0 registers above
- */
-#define LPU1_MBOX_CTL_REG		(LPU1_BLK_REG_ADDR + 0x000)
-#define LPU1_MBOX_CMD_REG		(LPU1_BLK_REG_ADDR + 0x004)
-#define LPU0_MBOX_LINK_1REG		(LPU1_BLK_REG_ADDR + 0x008)
-#define LPU1_MBOX_LINK_1REG		(LPU1_BLK_REG_ADDR + 0x00c)
-#define LPU0_MBOX_STATUS_1REG		(LPU1_BLK_REG_ADDR + 0x010)
-#define LPU1_MBOX_STATUS_1REG		(LPU1_BLK_REG_ADDR + 0x014)
-#define LPU1_ERR_STATUS_REG		(LPU1_BLK_REG_ADDR + 0x018)
-#define LPU1_ERR_SET_REG		(LPU1_BLK_REG_ADDR + 0x020)
-
-/**
- * PSS Block Register Address Offset from BAR0
- * Range 0x18800 - 0x188DB
- */
-#define PSS_BLK_REG_ADDR		0x00018800
-
-/**
- * PSS Registers
- * For details, see catapult_spec.pdf
- * ERR_STATUS_REG : Indicates error in PSS module
- * RAM_ERR_STATUS_REG : Indicates RAM module that detected error
- */
-#define ERR_STATUS_SET			(PSS_BLK_REG_ADDR + 0x018)
-#define PSS_RAM_ERR_STATUS_REG		(PSS_BLK_REG_ADDR + 0x01C)
-
-/**
- * PSS Semaphore Lock Registers, total 16
- * First read when unlocked returns 0,
- * and is set to 1, atomically.
- * Subsequent reads returns 1.
- * To clear set the value to 0.
- * Range : 0x20 to 0x5c
- */
-#define PSS_SEM_LOCK_REG(_num)		\
-	(PSS_BLK_REG_ADDR + 0x020 + ((_num) << 2))
-
-/**
- * PSS Semaphore Status Registers,
- * corresponding to the lock registers above
- */
-#define PSS_SEM_STATUS_REG(_num)		\
-	(PSS_BLK_REG_ADDR + 0x060 + ((_num) << 2))
-
-/**
- * Catapult CPQ Registers
- * Defines for Mailbox Registers
- * Used to send mailbox commands to firmware from
- * host. The data part is written to the MBox
- * memory, registers are used to indicate that
- * a commnad is resident in memory.
- *
- * Note : LPU0<->LPU1 mailboxes are not listed here
- */
-#define CPQ_BLK_REG_ADDR		0x00019000
-
-#define HOSTFN0_LPU0_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x130)
-#define HOSTFN0_LPU1_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x134)
-#define LPU0_HOSTFN0_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x138)
-#define LPU1_HOSTFN0_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x13C)
-
-#define HOSTFN1_LPU0_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x140)
-#define HOSTFN1_LPU1_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x144)
-#define LPU0_HOSTFN1_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x148)
-#define LPU1_HOSTFN1_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x14C)
-
-#define HOSTFN2_LPU0_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x170)
-#define HOSTFN2_LPU1_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x174)
-#define LPU0_HOSTFN2_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x178)
-#define LPU1_HOSTFN2_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x17C)
-
-#define HOSTFN3_LPU0_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x180)
-#define HOSTFN3_LPU1_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x184)
-#define LPU0_HOSTFN3_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x188)
-#define LPU1_HOSTFN3_MBOX1_CMD_STAT	(CPQ_BLK_REG_ADDR + 0x18C)
-
-/* Host Function Force Parity Error Registers */
-#define HOSTFN0_LPU_FORCE_PERR		(CPQ_BLK_REG_ADDR + 0x120)
-#define HOSTFN1_LPU_FORCE_PERR		(CPQ_BLK_REG_ADDR + 0x124)
-#define HOSTFN2_LPU_FORCE_PERR		(CPQ_BLK_REG_ADDR + 0x128)
-#define HOSTFN3_LPU_FORCE_PERR		(CPQ_BLK_REG_ADDR + 0x12C)
-
-/* LL Port[0|1] Halt Mask Registers */
-#define LL_HALT_MSK_P0			(CPQ_BLK_REG_ADDR + 0x1A0)
-#define LL_HALT_MSK_P1			(CPQ_BLK_REG_ADDR + 0x1B0)
-
-/* LL Port[0|1] Error Mask Registers */
-#define LL_ERR_MSK_P0			(CPQ_BLK_REG_ADDR + 0x1D0)
-#define LL_ERR_MSK_P1			(CPQ_BLK_REG_ADDR + 0x1D4)
-
-/* EMC FLI (Flash Controller) Block Register Address Offset from BAR0 */
-#define FLI_BLK_REG_ADDR		0x0001D000
-
-/* EMC FLI Registers */
-#define FLI_CMD_REG			(FLI_BLK_REG_ADDR + 0x000)
-#define FLI_ADDR_REG			(FLI_BLK_REG_ADDR + 0x004)
-#define FLI_CTL_REG			(FLI_BLK_REG_ADDR + 0x008)
-#define FLI_WRDATA_REG			(FLI_BLK_REG_ADDR + 0x00C)
-#define FLI_RDDATA_REG			(FLI_BLK_REG_ADDR + 0x010)
-#define FLI_DEV_STATUS_REG		(FLI_BLK_REG_ADDR + 0x014)
-#define FLI_SIG_WD_REG			(FLI_BLK_REG_ADDR + 0x018)
-
-/**
- * RO register
- * 31:16 -- Vendor Id
- * 15:0  -- Device Id
- */
-#define FLI_DEV_VENDOR_REG		(FLI_BLK_REG_ADDR + 0x01C)
-#define FLI_ERR_STATUS_REG		(FLI_BLK_REG_ADDR + 0x020)
-
-/**
- * RAD (RxAdm) Block Register Address Offset from BAR0
- * RAD0 Range : 0x20000 - 0x203FF
- * RAD1 Range : 0x20400 - 0x207FF
- */
-#define RAD0_BLK_REG_ADDR		0x00020000
-#define RAD1_BLK_REG_ADDR		0x00020400
-
-/* RAD0 Registers */
-#define RAD0_CTL_REG			(RAD0_BLK_REG_ADDR + 0x000)
-#define RAD0_PE_PARM_REG		(RAD0_BLK_REG_ADDR + 0x004)
-#define RAD0_BCN_REG			(RAD0_BLK_REG_ADDR + 0x008)
-
-/* Default function ID register */
-#define RAD0_DEFAULT_REG		(RAD0_BLK_REG_ADDR + 0x00C)
-
-/* Default promiscuous ID register */
-#define RAD0_PROMISC_REG		(RAD0_BLK_REG_ADDR + 0x010)
-
-#define RAD0_BCNQ_REG			(RAD0_BLK_REG_ADDR + 0x014)
-
-/*
- * This register selects 1 of 8 PM Q's using
- * VLAN pri, for non-BCN packets without a VLAN tag
- */
-#define RAD0_DEFAULTQ_REG		(RAD0_BLK_REG_ADDR + 0x018)
-
-#define RAD0_ERR_STS			(RAD0_BLK_REG_ADDR + 0x01C)
-#define RAD0_SET_ERR_STS		(RAD0_BLK_REG_ADDR + 0x020)
-#define RAD0_ERR_INT_EN			(RAD0_BLK_REG_ADDR + 0x024)
-#define RAD0_FIRST_ERR			(RAD0_BLK_REG_ADDR + 0x028)
-#define RAD0_FORCE_ERR			(RAD0_BLK_REG_ADDR + 0x02C)
-
-#define RAD0_IF_RCVD			(RAD0_BLK_REG_ADDR + 0x030)
-#define RAD0_IF_RCVD_OCTETS_HIGH	(RAD0_BLK_REG_ADDR + 0x034)
-#define RAD0_IF_RCVD_OCTETS_LOW		(RAD0_BLK_REG_ADDR + 0x038)
-#define RAD0_IF_RCVD_VLAN		(RAD0_BLK_REG_ADDR + 0x03C)
-#define RAD0_IF_RCVD_UCAST		(RAD0_BLK_REG_ADDR + 0x040)
-#define RAD0_IF_RCVD_UCAST_OCTETS_HIGH	(RAD0_BLK_REG_ADDR + 0x044)
-#define RAD0_IF_RCVD_UCAST_OCTETS_LOW   (RAD0_BLK_REG_ADDR + 0x048)
-#define RAD0_IF_RCVD_UCAST_VLAN		(RAD0_BLK_REG_ADDR + 0x04C)
-#define RAD0_IF_RCVD_MCAST		(RAD0_BLK_REG_ADDR + 0x050)
-#define RAD0_IF_RCVD_MCAST_OCTETS_HIGH  (RAD0_BLK_REG_ADDR + 0x054)
-#define RAD0_IF_RCVD_MCAST_OCTETS_LOW   (RAD0_BLK_REG_ADDR + 0x058)
-#define RAD0_IF_RCVD_MCAST_VLAN		(RAD0_BLK_REG_ADDR + 0x05C)
-#define RAD0_IF_RCVD_BCAST		(RAD0_BLK_REG_ADDR + 0x060)
-#define RAD0_IF_RCVD_BCAST_OCTETS_HIGH  (RAD0_BLK_REG_ADDR + 0x064)
-#define RAD0_IF_RCVD_BCAST_OCTETS_LOW   (RAD0_BLK_REG_ADDR + 0x068)
-#define RAD0_IF_RCVD_BCAST_VLAN		(RAD0_BLK_REG_ADDR + 0x06C)
-#define RAD0_DROPPED_FRAMES		(RAD0_BLK_REG_ADDR + 0x070)
-
-#define RAD0_MAC_MAN_1H			(RAD0_BLK_REG_ADDR + 0x080)
-#define RAD0_MAC_MAN_1L			(RAD0_BLK_REG_ADDR + 0x084)
-#define RAD0_MAC_MAN_2H			(RAD0_BLK_REG_ADDR + 0x088)
-#define RAD0_MAC_MAN_2L			(RAD0_BLK_REG_ADDR + 0x08C)
-#define RAD0_MAC_MAN_3H			(RAD0_BLK_REG_ADDR + 0x090)
-#define RAD0_MAC_MAN_3L			(RAD0_BLK_REG_ADDR + 0x094)
-#define RAD0_MAC_MAN_4H			(RAD0_BLK_REG_ADDR + 0x098)
-#define RAD0_MAC_MAN_4L			(RAD0_BLK_REG_ADDR + 0x09C)
-
-#define RAD0_LAST4_IP			(RAD0_BLK_REG_ADDR + 0x100)
-
-/* RAD1 Registers */
-#define RAD1_CTL_REG			(RAD1_BLK_REG_ADDR + 0x000)
-#define RAD1_PE_PARM_REG		(RAD1_BLK_REG_ADDR + 0x004)
-#define RAD1_BCN_REG			(RAD1_BLK_REG_ADDR + 0x008)
-
-/* Default function ID register */
-#define RAD1_DEFAULT_REG		(RAD1_BLK_REG_ADDR + 0x00C)
-
-/* Promiscuous function ID register */
-#define RAD1_PROMISC_REG		(RAD1_BLK_REG_ADDR + 0x010)
-
-#define RAD1_BCNQ_REG			(RAD1_BLK_REG_ADDR + 0x014)
+#define BFI_TX_MAX_PRIO			8
+#define BFI_TX_PRIO_MAP_ALL		0xFF
 
 /*
- * This register selects 1 of 8 PM Q's using
- * VLAN pri, for non-BCN packets without a VLAN tag
- */
-#define RAD1_DEFAULTQ_REG		(RAD1_BLK_REG_ADDR + 0x018)
-
-#define RAD1_ERR_STS			(RAD1_BLK_REG_ADDR + 0x01C)
-#define RAD1_SET_ERR_STS		(RAD1_BLK_REG_ADDR + 0x020)
-#define RAD1_ERR_INT_EN			(RAD1_BLK_REG_ADDR + 0x024)
-
-/**
- * TXA Block Register Address Offset from BAR0
- * TXA0 Range : 0x21000 - 0x213FF
- * TXA1 Range : 0x21400 - 0x217FF
- */
-#define TXA0_BLK_REG_ADDR		0x00021000
-#define TXA1_BLK_REG_ADDR		0x00021400
-
-/* TXA Registers */
-#define TXA0_CTRL_REG			(TXA0_BLK_REG_ADDR + 0x000)
-#define TXA1_CTRL_REG			(TXA1_BLK_REG_ADDR + 0x000)
-
-/**
- * TSO Sequence # Registers (RO)
- * Total 8 (for 8 queues)
- * Holds the last seq.# for TSO frames
- * See catapult_spec.pdf for more details
- */
-#define TXA0_TSO_TCP_SEQ_REG(_num)		\
-	(TXA0_BLK_REG_ADDR + 0x020 + ((_num) << 2))
-
-#define TXA1_TSO_TCP_SEQ_REG(_num)		\
-	(TXA1_BLK_REG_ADDR + 0x020 + ((_num) << 2))
-
-/**
- * TSO IP ID # Registers (RO)
- * Total 8 (for 8 queues)
- * Holds the last IP ID for TSO frames
- * See catapult_spec.pdf for more details
- */
-#define TXA0_TSO_IP_INFO_REG(_num)		\
-	(TXA0_BLK_REG_ADDR + 0x040 + ((_num) << 2))
-
-#define TXA1_TSO_IP_INFO_REG(_num)		\
-	(TXA1_BLK_REG_ADDR + 0x040 + ((_num) << 2))
-
-/**
- * RXA Block Register Address Offset from BAR0
- * RXA0 Range : 0x21800 - 0x21BFF
- * RXA1 Range : 0x21C00 - 0x21FFF
- */
-#define RXA0_BLK_REG_ADDR		0x00021800
-#define RXA1_BLK_REG_ADDR		0x00021C00
-
-/* RXA Registers */
-#define RXA0_CTL_REG			(RXA0_BLK_REG_ADDR + 0x040)
-#define RXA1_CTL_REG			(RXA1_BLK_REG_ADDR + 0x040)
-
-/**
- * PPLB Block Register Address Offset from BAR0
- * PPLB0 Range : 0x22000 - 0x223FF
- * PPLB1 Range : 0x22400 - 0x227FF
- */
-#define PLB0_BLK_REG_ADDR		0x00022000
-#define PLB1_BLK_REG_ADDR		0x00022400
-
-/**
- * PLB Registers
- * Holds RL timer used time stamps in RLT tagged frames
- */
-#define PLB0_ECM_TIMER_REG		(PLB0_BLK_REG_ADDR + 0x05C)
-#define PLB1_ECM_TIMER_REG		(PLB1_BLK_REG_ADDR + 0x05C)
-
-/* Controls the rate-limiter on each of the priority class */
-#define PLB0_RL_CTL			(PLB0_BLK_REG_ADDR + 0x060)
-#define PLB1_RL_CTL			(PLB1_BLK_REG_ADDR + 0x060)
-
-/**
- * Max byte register, total 8, 0-7
- * see catapult_spec.pdf for details
- */
-#define PLB0_RL_MAX_BC(_num)			\
-	(PLB0_BLK_REG_ADDR + 0x064 + ((_num) << 2))
-#define PLB1_RL_MAX_BC(_num)			\
-	(PLB1_BLK_REG_ADDR + 0x064 + ((_num) << 2))
-
-/**
- * RL Time Unit Register for priority 0-7
- * 4 bits per priority
- * (2^rl_unit)*1us is the actual time period
- */
-#define PLB0_RL_TU_PRIO			(PLB0_BLK_REG_ADDR + 0x084)
-#define PLB1_RL_TU_PRIO			(PLB1_BLK_REG_ADDR + 0x084)
-
-/**
- * RL byte count register,
- * bytes transmitted in (rl_unit*1)us time period
- * 1 per priority, 8 in all, 0-7.
- */
-#define PLB0_RL_BYTE_CNT(_num)			\
-	(PLB0_BLK_REG_ADDR + 0x088 + ((_num) << 2))
-#define PLB1_RL_BYTE_CNT(_num)			\
-	(PLB1_BLK_REG_ADDR + 0x088 + ((_num) << 2))
-
-/**
- * RL Min factor register
- * 2 bits per priority,
- * 4 factors possible: 1, 0.5, 0.25, 0
- * 2'b00 - 0; 2'b01 - 0.25; 2'b10 - 0.5; 2'b11 - 1
- */
-#define PLB0_RL_MIN_REG			(PLB0_BLK_REG_ADDR + 0x0A8)
-#define PLB1_RL_MIN_REG			(PLB1_BLK_REG_ADDR + 0x0A8)
-
-/**
- * RL Max factor register
- * 2 bits per priority,
- * 4 factors possible: 1, 0.5, 0.25, 0
- * 2'b00 - 0; 2'b01 - 0.25; 2'b10 - 0.5; 2'b11 - 1
- */
-#define PLB0_RL_MAX_REG			(PLB0_BLK_REG_ADDR + 0x0AC)
-#define PLB1_RL_MAX_REG			(PLB1_BLK_REG_ADDR + 0x0AC)
-
-/* MAC SERDES Address Paging register */
-#define PLB0_EMS_ADD_REG		(PLB0_BLK_REG_ADDR + 0xD0)
-#define PLB1_EMS_ADD_REG		(PLB1_BLK_REG_ADDR + 0xD0)
-
-/* LL EMS Registers */
-#define LL_EMS0_BLK_REG_ADDR		0x00026800
-#define LL_EMS1_BLK_REG_ADDR		0x00026C00
-
-/**
- * BPC Block Register Address Offset from BAR0
- * BPC0 Range : 0x23000 - 0x233FF
- * BPC1 Range : 0x23400 - 0x237FF
- */
-#define BPC0_BLK_REG_ADDR		0x00023000
-#define BPC1_BLK_REG_ADDR		0x00023400
-
-/**
- * PMM Block Register Address Offset from BAR0
- * PMM0 Range : 0x23800 - 0x23BFF
- * PMM1 Range : 0x23C00 - 0x23FFF
- */
-#define PMM0_BLK_REG_ADDR		0x00023800
-#define PMM1_BLK_REG_ADDR		0x00023C00
-
-/**
- * HQM Block Register Address Offset from BAR0
- * HQM0 Range : 0x24000 - 0x243FF
- * HQM1 Range : 0x24400 - 0x247FF
- */
-#define HQM0_BLK_REG_ADDR		0x00024000
-#define HQM1_BLK_REG_ADDR		0x00024400
-
-/**
- * HQM Control Register
- * Controls some aspects of IB
- * See catapult_spec.pdf for details
- */
-#define HQM0_CTL_REG			(HQM0_BLK_REG_ADDR + 0x000)
-#define HQM1_CTL_REG			(HQM1_BLK_REG_ADDR + 0x000)
-
-/**
- * HQM Stop Q Semaphore Registers.
- * Only one Queue resource can be stopped at
- * any given time. This register controls access
- * to the single stop Q resource.
- * See catapult_spec.pdf for details
- */
-#define HQM0_RXQ_STOP_SEM		(HQM0_BLK_REG_ADDR + 0x028)
-#define HQM0_TXQ_STOP_SEM		(HQM0_BLK_REG_ADDR + 0x02C)
-#define HQM1_RXQ_STOP_SEM		(HQM1_BLK_REG_ADDR + 0x028)
-#define HQM1_TXQ_STOP_SEM		(HQM1_BLK_REG_ADDR + 0x02C)
-
-/**
- * LUT Block Register Address Offset from BAR0
- * LUT0 Range : 0x25800 - 0x25BFF
- * LUT1 Range : 0x25C00 - 0x25FFF
- */
-#define LUT0_BLK_REG_ADDR		0x00025800
-#define LUT1_BLK_REG_ADDR		0x00025C00
-
-/**
- * LUT Registers
- * See catapult_spec.pdf for details
- */
-#define LUT0_ERR_STS			(LUT0_BLK_REG_ADDR + 0x000)
-#define LUT1_ERR_STS			(LUT1_BLK_REG_ADDR + 0x000)
-#define LUT0_SET_ERR_STS		(LUT0_BLK_REG_ADDR + 0x004)
-#define LUT1_SET_ERR_STS		(LUT1_BLK_REG_ADDR + 0x004)
-
-/**
- * TRC (Debug/Trace) Register Offset from BAR0
- * Range : 0x26000 -- 0x263FFF
- */
-#define TRC_BLK_REG_ADDR		0x00026000
-
-/**
- * TRC Registers
- * See catapult_spec.pdf for details of each
- */
-#define TRC_CTL_REG			(TRC_BLK_REG_ADDR + 0x000)
-#define TRC_MODS_REG			(TRC_BLK_REG_ADDR + 0x004)
-#define TRC_TRGC_REG			(TRC_BLK_REG_ADDR + 0x008)
-#define TRC_CNT1_REG			(TRC_BLK_REG_ADDR + 0x010)
-#define TRC_CNT2_REG			(TRC_BLK_REG_ADDR + 0x014)
-#define TRC_NXTS_REG			(TRC_BLK_REG_ADDR + 0x018)
-#define TRC_DIRR_REG			(TRC_BLK_REG_ADDR + 0x01C)
-
-/**
- * TRC Trigger match filters, total 10
- * Determines the trigger condition
- */
-#define TRC_TRGM_REG(_num)		\
-	(TRC_BLK_REG_ADDR + 0x040 + ((_num) << 2))
-
-/**
- * TRC Next State filters, total 10
- * Determines the next state conditions
- */
-#define TRC_NXTM_REG(_num)		\
-	(TRC_BLK_REG_ADDR + 0x080 + ((_num) << 2))
-
-/**
- * TRC Store Match filters, total 10
- * Determines the store conditions
- */
-#define TRC_STRM_REG(_num)		\
-	(TRC_BLK_REG_ADDR + 0x0C0 + ((_num) << 2))
-
-/* DOORBELLS ACCESS */
-
-/**
- * Catapult doorbells
- * Each doorbell-queue set has
- * 1 RxQ, 1 TxQ, 2 IBs in that order
- * Size of each entry in 32 bytes, even though only 1 word
- * is used. For Non-VM case each doorbell-q set is
- * separated by 128 bytes, for VM case it is separated
- * by 4K bytes
- * Non VM case Range : 0x38000 - 0x39FFF
- * VM case Range     : 0x100000 - 0x11FFFF
- * The range applies to both HQMs
- */
-#define HQM_DOORBELL_BLK_BASE_ADDR	0x00038000
-#define HQM_DOORBELL_VM_BLK_BASE_ADDR	0x00100000
-
-/* MEMORY ACCESS */
-
-/**
- * Catapult H/W Block Memory Access Address
- * To the host a memory space of 32K (page) is visible
- * at a time. The address range is from 0x08000 to 0x0FFFF
- */
-#define HW_BLK_HOST_MEM_ADDR		0x08000
-
-/**
- * Catapult LUT Memory Access Page Numbers
- * Range : LUT0 0xa0-0xa1
- *         LUT1 0xa2-0xa3
- */
-#define LUT0_MEM_BLK_BASE_PG_NUM	0x000000A0
-#define LUT1_MEM_BLK_BASE_PG_NUM	0x000000A2
-
-/**
- * Catapult RxFn Database Memory Block Base Offset
  *
- * The Rx function database exists in LUT block.
- * In PCIe space this is accessible as a 256x32
- * bit block. Each entry in this database is 4
- * (4 byte) words. Max. entries is 64.
- * Address of an entry corresponding to a function
- * = base_addr + (function_no. * 16)
- */
-#define RX_FNDB_RAM_BASE_OFFSET		0x0000B400
-
-/**
- * Catapult TxFn Database Memory Block Base Offset Address
- *
- * The Tx function database exists in LUT block.
- * In PCIe space this is accessible as a 64x32
- * bit block. Each entry in this database is 1
- * (4 byte) word. Max. entries is 64.
- * Address of an entry corresponding to a function
- * = base_addr + (function_no. * 4)
- */
-#define TX_FNDB_RAM_BASE_OFFSET		0x0000B800
-
-/**
- * Catapult Unicast CAM Base Offset Address
- *
- * Exists in LUT memory space.
- * Shared by both the LL & FCoE driver.
- * Size is 256x48 bits; mapped to PCIe space
- * 512x32 bit blocks. For each address, bits
- * are written in the order : [47:32] and then
- * [31:0].
- */
-#define UCAST_CAM_BASE_OFFSET		0x0000A800
-
-/**
- * Catapult Unicast RAM Base Offset Address
- *
- * Exists in LUT memory space.
- * Shared by both the LL & FCoE driver.
- * Size is 256x9 bits.
- */
-#define UCAST_RAM_BASE_OFFSET		0x0000B000
-
-/**
- * Catapult Mulicast CAM Base Offset Address
- *
- * Exists in LUT memory space.
- * Shared by both the LL & FCoE driver.
- * Size is 256x48 bits; mapped to PCIe space
- * 512x32 bit blocks. For each address, bits
- * are written in the order : [47:32] and then
- * [31:0].
- */
-#define MCAST_CAM_BASE_OFFSET		0x0000A000
-
-/**
- * Catapult VLAN RAM Base Offset Address
- *
- * Exists in LUT memory space.
- * Size is 4096x66 bits; mapped to PCIe space as
- * 8192x32 bit blocks.
- * All the 4K entries are within the address range
- * 0x0000 to 0x8000, so in the first LUT page.
- */
-#define VLAN_RAM_BASE_OFFSET		0x00000000
-
-/**
- * Catapult Tx Stats RAM Base Offset Address
+ * Register definitions and macros
  *
- * Exists in LUT memory space.
- * Size is 1024x33 bits;
- * Each Tx function has 64 bytes of space
- */
-#define TX_STATS_RAM_BASE_OFFSET	0x00009000
-
-/**
- * Catapult Rx Stats RAM Base Offset Address
- *
- * Exists in LUT memory space.
- * Size is 1024x33 bits;
- * Each Rx function has 64 bytes of space
- */
-#define RX_STATS_RAM_BASE_OFFSET	0x00008000
-
-/* Catapult RXA Memory Access Page Numbers */
-#define RXA0_MEM_BLK_BASE_PG_NUM	0x0000008C
-#define RXA1_MEM_BLK_BASE_PG_NUM	0x0000008D
-
-/**
- * Catapult Multicast Vector Table Base Offset Address
- *
- * Exists in RxA memory space.
- * Organized as 512x65 bit block.
- * However for each entry 16 bytes allocated (power of 2)
- * Total size 512*16 bytes.
- * There are two logical divisions, 256 entries each :
- * a) Entries 0x00 to 0xff (256) -- Approx. MVT
- *    Offset 0x000 to 0xFFF
- * b) Entries 0x100 to 0x1ff (256) -- Exact MVT
- *    Offsets 0x1000 to 0x1FFF
- */
-#define MCAST_APPROX_MVT_BASE_OFFSET	0x00000000
-#define MCAST_EXACT_MVT_BASE_OFFSET	0x00001000
-
-/**
- * Catapult RxQ Translate Table (RIT) Base Offset Address
- *
- * Exists in RxA memory space
- * Total no. of entries 64
- * Each entry is 1 (4 byte) word.
- * 31:12 -- Reserved
- * 11:0  -- Two 6 bit RxQ Ids
- */
-#define FUNCTION_TO_RXQ_TRANSLATE	0x00002000
-
-/* Catapult RxAdm (RAD) Memory Access Page Numbers */
-#define RAD0_MEM_BLK_BASE_PG_NUM	0x00000086
-#define RAD1_MEM_BLK_BASE_PG_NUM	0x00000087
-
-/**
- * Catapult RSS Table Base Offset Address
- *
- * Exists in RAD memory space.
- * Each entry is 352 bits, but aligned on
- * 64 byte (512 bit) boundary. Accessed
- * 4 byte words, the whole entry can be
- * broken into 11 word accesses.
- */
-#define RSS_TABLE_BASE_OFFSET		0x00000800
-
-/**
- * Catapult CPQ Block Page Number
- * This value is written to the page number registers
- * to access the memory associated with the mailboxes.
- */
-#define CPQ_BLK_PG_NUM			0x00000005
-
-/**
- * Clarification :
- * LL functions are 2 & 3; can HostFn0/HostFn1
- * <-> LPU0/LPU1 memories be used ?
- */
-/**
- * Catapult HostFn0/HostFn1 to LPU0/LPU1 Mbox memory
- * Per catapult_spec.pdf, the offset of the mbox
- * memory is in the register space at an offset of 0x200
- */
-#define CPQ_BLK_REG_MBOX_ADDR		(CPQ_BLK_REG_ADDR + 0x200)
-
-#define HOSTFN_LPU_MBOX			(CPQ_BLK_REG_MBOX_ADDR + 0x000)
-
-/* Catapult LPU0/LPU1 to HostFn0/HostFn1 Mbox memory */
-#define LPU_HOSTFN_MBOX			(CPQ_BLK_REG_MBOX_ADDR + 0x080)
-
-/**
- * Catapult HQM Block Page Number
- * This is written to the page number register for
- * the appropriate function to access the memory
- * associated with HQM
- */
-#define HQM0_BLK_PG_NUM			0x00000096
-#define HQM1_BLK_PG_NUM			0x00000097
-
-/**
- * Note that TxQ and RxQ entries are interlaced
- * the HQM memory, i.e RXQ0, TXQ0, RXQ1, TXQ1.. etc.
- */
-
-#define HQM_RXTX_Q_RAM_BASE_OFFSET	0x00004000
-
-/**
- * CQ Memory
- * Exists in HQM Memory space
- * Each entry is 16 (4 byte) words of which
- * only 12 words are used for configuration
- * Total 64 entries per HQM memory space
- */
-#define HQM_CQ_RAM_BASE_OFFSET		0x00006000
-
-/**
- * Interrupt Block (IB) Memory
- * Exists in HQM Memory space
- * Each entry is 8 (4 byte) words of which
- * only 5 words are used for configuration
- * Total 128 entries per HQM memory space
- */
-#define HQM_IB_RAM_BASE_OFFSET		0x00001000
-
-/**
- * Index Table (IT) Memory
- * Exists in HQM Memory space
- * Each entry is 1 (4 byte) word which
- * is used for configuration
- * Total 128 entries per HQM memory space
  */
-#define HQM_INDX_TBL_RAM_BASE_OFFSET	0x00002000
-
-/**
- * PSS Block Memory Page Number
- * This is written to the appropriate page number
- * register to access the CPU memory.
- * Also known as the PSS secondary memory (SMEM).
- * Range : 0x180 to 0x1CF
- * See catapult_spec.pdf for details
- */
-#define PSS_BLK_PG_NUM			0x00000180
-
-/**
- * Offsets of different instances of PSS SMEM
- * 2.5M of continuous 1T memory space : 2 blocks
- * of 1M each (32 pages each, page=32KB) and 4 smaller
- * blocks of 128K each (4 pages each, page=32KB)
- * PSS_LMEM_INST0 is used for firmware download
- */
-#define PSS_LMEM_INST0			0x00000000
-#define PSS_LMEM_INST1			0x00100000
-#define PSS_LMEM_INST2			0x00200000
-#define PSS_LMEM_INST3			0x00220000
-#define PSS_LMEM_INST4			0x00240000
-#define PSS_LMEM_INST5			0x00260000
 
 #define BNA_PCI_REG_CT_ADDRSZ		(0x40000)
 
-#define BNA_GET_PAGE_NUM(_base_page, _offset)   \
-	((_base_page) + ((_offset) >> 15))
+#define ct_reg_addr_init(_bna, _pcidev)					\
+{									\
+	struct bna_reg_offset reg_offset[] =				\
+	{{HOSTFN0_INT_STATUS, HOSTFN0_INT_MSK},				\
+	 {HOSTFN1_INT_STATUS, HOSTFN1_INT_MSK},				\
+	 {HOSTFN2_INT_STATUS, HOSTFN2_INT_MSK},				\
+	 {HOSTFN3_INT_STATUS, HOSTFN3_INT_MSK} };			\
+									\
+	(_bna)->regs.fn_int_status = (_pcidev)->pci_bar_kva +		\
+				reg_offset[(_pcidev)->pci_func].fn_int_status;\
+	(_bna)->regs.fn_int_mask = (_pcidev)->pci_bar_kva +		\
+				reg_offset[(_pcidev)->pci_func].fn_int_mask;\
+}
+
+#define ct_bit_defn_init(_bna, _pcidev)					\
+{									\
+	(_bna)->bits.mbox_status_bits = (__HFN_INT_MBOX_LPU0 |		\
+					__HFN_INT_MBOX_LPU1);		\
+	(_bna)->bits.mbox_mask_bits = (__HFN_INT_MBOX_LPU0 |		\
+					__HFN_INT_MBOX_LPU1);		\
+	(_bna)->bits.error_status_bits = (__HFN_INT_ERR_MASK);		\
+	(_bna)->bits.error_mask_bits = (__HFN_INT_ERR_MASK);		\
+	(_bna)->bits.halt_status_bits = __HFN_INT_LL_HALT;		\
+}
 
-#define BNA_GET_PAGE_OFFSET(_offset)    \
-	((_offset) & 0x7fff)
+#define ct2_reg_addr_init(_bna, _pcidev)				\
+{									\
+	(_bna)->regs.fn_int_status = (_pcidev)->pci_bar_kva +		\
+				CT2_HOSTFN_INT_STATUS;			\
+	(_bna)->regs.fn_int_mask = (_pcidev)->pci_bar_kva +		\
+				CT2_HOSTFN_INTR_MASK;			\
+}
 
-#define BNA_GET_MEM_BASE_ADDR(_bar0, _base_offset)	\
-	((_bar0) + HW_BLK_HOST_MEM_ADDR		\
-	  + BNA_GET_PAGE_OFFSET((_base_offset)))
+#define ct2_bit_defn_init(_bna, _pcidev)				\
+{									\
+	(_bna)->bits.mbox_status_bits = (__HFN_INT_MBOX_LPU0_CT2 |	\
+					__HFN_INT_MBOX_LPU1_CT2);	\
+	(_bna)->bits.mbox_mask_bits = (__HFN_INT_MBOX_LPU0_CT2 |	\
+					__HFN_INT_MBOX_LPU1_CT2);	\
+	(_bna)->bits.error_status_bits = (__HFN_INT_ERR_MASK_CT2);	\
+	(_bna)->bits.error_mask_bits = (__HFN_INT_ERR_MASK_CT2);	\
+	(_bna)->bits.halt_status_bits = __HFN_INT_CPQ_HALT_CT2;		\
+	(_bna)->bits.halt_mask_bits = __HFN_INT_CPQ_HALT_CT2;		\
+}
 
-#define BNA_GET_VLAN_MEM_ENTRY_ADDR(_bar0, _fn_id, _vlan_id)\
-	(_bar0 + (HW_BLK_HOST_MEM_ADDR)  \
-	+ (BNA_GET_PAGE_OFFSET(VLAN_RAM_BASE_OFFSET))	\
-	+ (((_fn_id) & 0x3f) << 9)	  \
-	+ (((_vlan_id) & 0xfe0) >> 3))
+#define bna_reg_addr_init(_bna, _pcidev)				\
+{									\
+	switch ((_pcidev)->device_id) {					\
+	case PCI_DEVICE_ID_BROCADE_CT:					\
+		ct_reg_addr_init((_bna), (_pcidev));			\
+		ct_bit_defn_init((_bna), (_pcidev));			\
+		break;							\
+	case PCI_DEVICE_ID_BROCADE_CT2:					\
+		ct2_reg_addr_init((_bna), (_pcidev));			\
+		ct2_bit_defn_init((_bna), (_pcidev));			\
+		break;							\
+	}								\
+}
 
+#define bna_port_id_get(_bna) ((_bna)->ioceth.ioc.port_id)
 /**
  *
  *  Interrupt related bits, flags and macros
  *
  */
 
-#define __LPU02HOST_MBOX0_STATUS_BITS 0x00100000
-#define __LPU12HOST_MBOX0_STATUS_BITS 0x00200000
-#define __LPU02HOST_MBOX1_STATUS_BITS 0x00400000
-#define __LPU12HOST_MBOX1_STATUS_BITS 0x00800000
-
-#define __LPU02HOST_MBOX0_MASK_BITS	0x00100000
-#define __LPU12HOST_MBOX0_MASK_BITS	0x00200000
-#define __LPU02HOST_MBOX1_MASK_BITS	0x00400000
-#define __LPU12HOST_MBOX1_MASK_BITS	0x00800000
-
-#define __LPU2HOST_MBOX_MASK_BITS			 \
-	(__LPU02HOST_MBOX0_MASK_BITS | __LPU02HOST_MBOX1_MASK_BITS |	\
-	  __LPU12HOST_MBOX0_MASK_BITS | __LPU12HOST_MBOX1_MASK_BITS)
-
-#define __LPU2HOST_IB_STATUS_BITS	0x0000ffff
-
-#define BNA_IS_LPU0_MBOX_INTR(_intr_status) \
-	((_intr_status) & (__LPU02HOST_MBOX0_STATUS_BITS | \
-			__LPU02HOST_MBOX1_STATUS_BITS))
+#define IB_STATUS_BITS		0x0000ffff
 
-#define BNA_IS_LPU1_MBOX_INTR(_intr_status) \
-	((_intr_status) & (__LPU12HOST_MBOX0_STATUS_BITS | \
-		__LPU12HOST_MBOX1_STATUS_BITS))
+#define BNA_IS_MBOX_INTR(_bna, _intr_status)				\
+	((_intr_status) & (_bna)->bits.mbox_status_bits)
 
-#define BNA_IS_MBOX_INTR(_intr_status)		\
-	((_intr_status) &			\
-	(__LPU02HOST_MBOX0_STATUS_BITS |	\
-	 __LPU02HOST_MBOX1_STATUS_BITS |	\
-	 __LPU12HOST_MBOX0_STATUS_BITS |	\
-	 __LPU12HOST_MBOX1_STATUS_BITS))
+#define BNA_IS_HALT_INTR(_bna, _intr_status)				\
+	((_intr_status) & (_bna)->bits.halt_status_bits)
 
-#define __EMC_ERROR_STATUS_BITS		0x00010000
-#define __LPU0_ERROR_STATUS_BITS	0x00020000
-#define __LPU1_ERROR_STATUS_BITS	0x00040000
-#define __PSS_ERROR_STATUS_BITS		0x00080000
+#define BNA_IS_ERR_INTR(_bna, _intr_status)	\
+	((_intr_status) & (_bna)->bits.error_status_bits)
 
-#define __HALT_STATUS_BITS		0x01000000
+#define BNA_IS_MBOX_ERR_INTR(_bna, _intr_status)	\
+	(BNA_IS_MBOX_INTR(_bna, _intr_status) |		\
+	BNA_IS_ERR_INTR(_bna, _intr_status))
 
-#define __EMC_ERROR_MASK_BITS		0x00010000
-#define __LPU0_ERROR_MASK_BITS		0x00020000
-#define __LPU1_ERROR_MASK_BITS		0x00040000
-#define __PSS_ERROR_MASK_BITS		0x00080000
+#define BNA_IS_INTX_DATA_INTR(_intr_status)		\
+		((_intr_status) & IB_STATUS_BITS)
 
-#define __HALT_MASK_BITS		0x01000000
-
-#define __ERROR_MASK_BITS		\
-	(__EMC_ERROR_MASK_BITS | __LPU0_ERROR_MASK_BITS | \
-	  __LPU1_ERROR_MASK_BITS | __PSS_ERROR_MASK_BITS | \
-	  __HALT_MASK_BITS)
-
-#define BNA_IS_ERR_INTR(_intr_status)	\
-	((_intr_status) &		\
-	(__EMC_ERROR_STATUS_BITS |	\
-	 __LPU0_ERROR_STATUS_BITS |	\
-	 __LPU1_ERROR_STATUS_BITS |	\
-	 __PSS_ERROR_STATUS_BITS  |	\
-	 __HALT_STATUS_BITS))
-
-#define BNA_IS_MBOX_ERR_INTR(_intr_status)	\
-	(BNA_IS_MBOX_INTR((_intr_status)) |	\
-	 BNA_IS_ERR_INTR((_intr_status)))
-
-#define BNA_IS_INTX_DATA_INTR(_intr_status)	\
-	((_intr_status) & __LPU2HOST_IB_STATUS_BITS)
-
-#define BNA_INTR_STATUS_MBOX_CLR(_intr_status)			\
-do {								\
-	(_intr_status) &= ~(__LPU02HOST_MBOX0_STATUS_BITS |	\
-			__LPU02HOST_MBOX1_STATUS_BITS |		\
-			__LPU12HOST_MBOX0_STATUS_BITS |		\
-			__LPU12HOST_MBOX1_STATUS_BITS);		\
+#define bna_halt_clear(_bna)						\
+do {									\
+	u32 init_halt;						\
+	init_halt = readl((_bna)->ioceth.ioc.ioc_regs.ll_halt);	\
+	init_halt &= ~__FW_INIT_HALT_P;					\
+	writel(init_halt, (_bna)->ioceth.ioc.ioc_regs.ll_halt);	\
+	init_halt = readl((_bna)->ioceth.ioc.ioc_regs.ll_halt);	\
 } while (0)
 
-#define BNA_INTR_STATUS_ERR_CLR(_intr_status)		\
-do {							\
-	(_intr_status) &= ~(__EMC_ERROR_STATUS_BITS |	\
-		__LPU0_ERROR_STATUS_BITS |		\
-		__LPU1_ERROR_STATUS_BITS |		\
-		__PSS_ERROR_STATUS_BITS  |		\
-		__HALT_STATUS_BITS);			\
-} while (0)
-
-#define bna_intx_disable(_bna, _cur_mask)		\
-{							\
-	(_cur_mask) = readl((_bna)->regs.fn_int_mask);\
-	writel(0xffffffff, (_bna)->regs.fn_int_mask);\
+#define bna_intx_disable(_bna, _cur_mask)				\
+{									\
+	(_cur_mask) = readl((_bna)->regs.fn_int_mask);		\
+	writel(0xffffffff, (_bna)->regs.fn_int_mask);		\
 }
 
-#define bna_intx_enable(bna, new_mask)			\
+#define bna_intx_enable(bna, new_mask)					\
 	writel((new_mask), (bna)->regs.fn_int_mask)
+#define bna_mbox_intr_disable(bna)					\
+do {									\
+	u32 mask;							\
+	mask = readl((bna)->regs.fn_int_mask);				\
+	writel((mask | (bna)->bits.mbox_mask_bits |			\
+		(bna)->bits.error_mask_bits), (bna)->regs.fn_int_mask); \
+	mask = readl((bna)->regs.fn_int_mask);				\
+} while (0)
 
-#define bna_mbox_intr_disable(bna)		\
-	writel((readl((bna)->regs.fn_int_mask) | \
-	     (__LPU2HOST_MBOX_MASK_BITS | __ERROR_MASK_BITS)), \
-	     (bna)->regs.fn_int_mask)
-
-#define bna_mbox_intr_enable(bna)		\
-	writel((readl((bna)->regs.fn_int_mask) & \
-	     ~(__LPU2HOST_MBOX_MASK_BITS | __ERROR_MASK_BITS)), \
-	     (bna)->regs.fn_int_mask)
+#define bna_mbox_intr_enable(bna)					\
+do {									\
+	u32 mask;							\
+	mask = readl((bna)->regs.fn_int_mask);				\
+	writel((mask & ~((bna)->bits.mbox_mask_bits |			\
+		(bna)->bits.error_mask_bits)), (bna)->regs.fn_int_mask);\
+	mask = readl((bna)->regs.fn_int_mask);				\
+} while (0)
 
 #define bna_intr_status_get(_bna, _status)				\
 {									\
-	(_status) = readl((_bna)->regs.fn_int_status);		\
-	if ((_status)) {						\
-		writel((_status) & ~(__LPU02HOST_MBOX0_STATUS_BITS |\
-					  __LPU02HOST_MBOX1_STATUS_BITS |\
-					  __LPU12HOST_MBOX0_STATUS_BITS |\
-					  __LPU12HOST_MBOX1_STATUS_BITS), \
-			      (_bna)->regs.fn_int_status);\
+	(_status) = readl((_bna)->regs.fn_int_status);			\
+	if (_status) {							\
+		writel(((_status) & ~(_bna)->bits.mbox_status_bits),	\
+			(_bna)->regs.fn_int_status);			\
 	}								\
 }
 
-#define bna_intr_status_get_no_clr(_bna, _status)		\
-	(_status) = readl((_bna)->regs.fn_int_status)
-
-#define bna_intr_mask_get(bna, mask)		\
-	(*mask) = readl((bna)->regs.fn_int_mask)
-
-#define bna_intr_ack(bna, intr_bmap)		\
-	writel((intr_bmap), (bna)->regs.fn_int_status)
+/*
+ * MAX ACK EVENTS : No. of acks that can be accumulated in driver,
+ * before acking to h/w. The no. of bits is 16 in the doorbell register,
+ * however we keep this limited to 15 bits.
+ * This is because around the edge of 64K boundary (16 bits), one
+ * single poll can make the accumulated ACK counter cross the 64K boundary,
+ * causing problems, when we try to ack with a value greater than 64K.
+ * 15 bits (32K) should  be large enough to accumulate, anyways, and the max.
+ * acked events to h/w can be (32K + max poll weight) (currently 64).
+ */
+#define	BNA_IB_MAX_ACK_EVENTS		(1 << 15)
+
+/* These macros build the data portion of the TxQ/RxQ doorbell */
+#define BNA_DOORBELL_Q_PRD_IDX(_pi)	(0x80000000 | (_pi))
+#define BNA_DOORBELL_Q_STOP		(0x40000000)
+
+/* These macros build the data portion of the IB doorbell */
+#define BNA_DOORBELL_IB_INT_ACK(_timeout, _events)			\
+	(0x80000000 | ((_timeout) << 16) | (_events))
+#define BNA_DOORBELL_IB_INT_DISABLE	(0x40000000)
+
+/* Set the coalescing timer for the given ib */
+#define bna_ib_coalescing_timer_set(_i_dbell, _cls_timer)		\
+	((_i_dbell)->doorbell_ack = BNA_DOORBELL_IB_INT_ACK((_cls_timer), 0));
+
+/* Acks 'events' # of events for a given ib while disabling interrupts */
+#define bna_ib_ack_disable_irq(_i_dbell, _events)			\
+	(writel(BNA_DOORBELL_IB_INT_ACK(0, (_events)), \
+		(_i_dbell)->doorbell_addr));
+
+/* Acks 'events' # of events for a given ib */
+#define bna_ib_ack(_i_dbell, _events)					\
+	(writel(((_i_dbell)->doorbell_ack | (_events)), \
+		(_i_dbell)->doorbell_addr));
+
+#define bna_ib_start(_bna, _ib, _is_regular)				\
+{									\
+	u32 intx_mask;						\
+	struct bna_ib *ib = _ib;					\
+	if ((ib->intr_type == BNA_INTR_T_INTX)) {			\
+		bna_intx_disable((_bna), intx_mask);			\
+		intx_mask &= ~(ib->intr_vector);			\
+		bna_intx_enable((_bna), intx_mask);			\
+	}								\
+	bna_ib_coalescing_timer_set(&ib->door_bell,			\
+			ib->coalescing_timeo);				\
+	if (_is_regular)						\
+		bna_ib_ack(&ib->door_bell, 0);				\
+}
 
-#define bna_ib_intx_disable(bna, ib_id)		\
-	writel(readl((bna)->regs.fn_int_mask) | \
-	    (1 << (ib_id)), \
-	    (bna)->regs.fn_int_mask)
+#define bna_ib_stop(_bna, _ib)						\
+{									\
+	u32 intx_mask;						\
+	struct bna_ib *ib = _ib;					\
+	writel(BNA_DOORBELL_IB_INT_DISABLE,				\
+		ib->door_bell.doorbell_addr);				\
+	if (ib->intr_type == BNA_INTR_T_INTX) {				\
+		bna_intx_disable((_bna), intx_mask);			\
+		intx_mask |= ib->intr_vector;				\
+		bna_intx_enable((_bna), intx_mask);			\
+	}								\
+}
 
-#define bna_ib_intx_enable(bna, ib_id)		\
-	writel(readl((bna)->regs.fn_int_mask) & \
-	    ~(1 << (ib_id)), \
-	    (bna)->regs.fn_int_mask)
+#define bna_txq_prod_indx_doorbell(_tcb)				\
+	(writel(BNA_DOORBELL_Q_PRD_IDX((_tcb)->producer_index), \
+		(_tcb)->q_dbell));
 
-#define bna_mbox_msix_idx_set(_device) \
-do {\
-	writel(((_device)->vector & 0x000001FF), \
-		(_device)->bna->pcidev.pci_bar_kva + \
-		reg_offset[(_device)->bna->pcidev.pci_func].msix_idx);\
-} while (0)
+#define bna_rxq_prod_indx_doorbell(_rcb)				\
+	(writel(BNA_DOORBELL_Q_PRD_IDX((_rcb)->producer_index), \
+		(_rcb)->q_dbell));
 
 /**
  *
@@ -1164,20 +281,6 @@ do {\
  *
  */
 
-#define	BNA_Q_IDLE_STATE	0x00008001
-
-#define BNA_GET_DOORBELL_BASE_ADDR(_bar0)	\
-	((_bar0) + HQM_DOORBELL_BLK_BASE_ADDR)
-
-#define BNA_GET_DOORBELL_ENTRY_OFFSET(_entry)		\
-	((HQM_DOORBELL_BLK_BASE_ADDR)		\
-	+ (_entry << 7))
-
-#define BNA_DOORBELL_IB_INT_ACK(_timeout, _events) \
-		(0x80000000 | ((_timeout) << 16) | (_events))
-
-#define BNA_DOORBELL_IB_INT_DISABLE		(0x40000000)
-
 /* TxQ Entry Opcodes */
 #define BNA_TXQ_WI_SEND			(0x402)	/* Single Frame Transmission */
 #define BNA_TXQ_WI_SEND_LSO		(0x403)	/* Multi-Frame Transmission */
@@ -1232,191 +335,23 @@ do {\
  *
  */
 
-enum txf_flags {
-	BFI_TXF_CF_ENABLE		= 1 << 0,
-	BFI_TXF_CF_VLAN_FILTER		= 1 << 8,
-	BFI_TXF_CF_VLAN_ADMIT		= 1 << 9,
-	BFI_TXF_CF_VLAN_INSERT		= 1 << 10,
-	BFI_TXF_CF_RSVD1		= 1 << 11,
-	BFI_TXF_CF_MAC_SA_CHECK		= 1 << 12,
-	BFI_TXF_CF_VLAN_WI_BASED	= 1 << 13,
-	BFI_TXF_CF_VSWITCH_MCAST	= 1 << 14,
-	BFI_TXF_CF_VSWITCH_UCAST	= 1 << 15,
-	BFI_TXF_CF_RSVD2		= 0x7F << 1
-};
-
-enum ib_flags {
-	BFI_IB_CF_MASTER_ENABLE		= (1 << 0),
-	BFI_IB_CF_MSIX_MODE		= (1 << 1),
-	BFI_IB_CF_COALESCING_MODE	= (1 << 2),
-	BFI_IB_CF_INTER_PKT_ENABLE	= (1 << 3),
-	BFI_IB_CF_INT_ENABLE		= (1 << 4),
-	BFI_IB_CF_INTER_PKT_DMA		= (1 << 5),
-	BFI_IB_CF_ACK_PENDING		= (1 << 6),
-	BFI_IB_CF_RESERVED1		= (1 << 7)
-};
-
-enum rss_hash_type {
-	BFI_RSS_T_V4_TCP		= (1 << 11),
-	BFI_RSS_T_V4_IP			= (1 << 10),
-	BFI_RSS_T_V6_TCP		= (1 <<  9),
-	BFI_RSS_T_V6_IP			= (1 <<  8)
-};
-enum hds_header_type {
-	BNA_HDS_T_V4_TCP	= (1 << 11),
-	BNA_HDS_T_V4_UDP	= (1 << 10),
-	BNA_HDS_T_V6_TCP	= (1 << 9),
-	BNA_HDS_T_V6_UDP	= (1 << 8),
-	BNA_HDS_FORCED		= (1 << 7),
-};
-enum rxf_flags {
-	BNA_RXF_CF_SM_LG_RXQ			= (1 << 15),
-	BNA_RXF_CF_DEFAULT_VLAN			= (1 << 14),
-	BNA_RXF_CF_DEFAULT_FUNCTION_ENABLE	= (1 << 13),
-	BNA_RXF_CF_VLAN_STRIP			= (1 << 12),
-	BNA_RXF_CF_RSS_ENABLE			= (1 <<  8)
-};
-struct bna_chip_regs_offset {
-	u32 page_addr;
+struct bna_reg_offset {
 	u32 fn_int_status;
 	u32 fn_int_mask;
-	u32 msix_idx;
-};
-
-struct bna_chip_regs {
-	void __iomem *page_addr;
-	void __iomem *fn_int_status;
-	void __iomem *fn_int_mask;
-};
-
-struct bna_txq_mem {
-	u32 pg_tbl_addr_lo;
-	u32 pg_tbl_addr_hi;
-	u32 cur_q_entry_lo;
-	u32 cur_q_entry_hi;
-	u32 reserved1;
-	u32 reserved2;
-	u32 pg_cnt_n_prd_ptr;	/* 31:16->total page count */
-					/* 15:0 ->producer pointer (index?) */
-	u32 entry_n_pg_size;	/* 31:16->entry size */
-					/* 15:0 ->page size */
-	u32 int_blk_n_cns_ptr;	/* 31:24->Int Blk Id;  */
-					/* 23:16->Int Blk Offset */
-					/* 15:0 ->consumer pointer(index?) */
-	u32 cns_ptr2_n_q_state;	/* 31:16->cons. ptr 2; 15:0-> Q state */
-	u32 nxt_qid_n_fid_n_pri;	/* 17:10->next */
-					/* QId;9:3->FID;2:0->Priority */
-	u32 wvc_n_cquota_n_rquota; /* 31:24->WI Vector Count; */
-					/* 23:12->Cfg Quota; */
-					/* 11:0 ->Run Quota */
-	u32 reserved3[4];
-};
-
-struct bna_rxq_mem {
-	u32 pg_tbl_addr_lo;
-	u32 pg_tbl_addr_hi;
-	u32 cur_q_entry_lo;
-	u32 cur_q_entry_hi;
-	u32 reserved1;
-	u32 reserved2;
-	u32 pg_cnt_n_prd_ptr;	/* 31:16->total page count */
-					/* 15:0 ->producer pointer (index?) */
-	u32 entry_n_pg_size;	/* 31:16->entry size */
-					/* 15:0 ->page size */
-	u32 sg_n_cq_n_cns_ptr;	/* 31:28->reserved; 27:24->sg count */
-					/* 23:16->CQ; */
-					/* 15:0->consumer pointer(index?) */
-	u32 buf_sz_n_q_state;	/* 31:16->buffer size; 15:0-> Q state */
-	u32 next_qid;		/* 17:10->next QId */
-	u32 reserved3;
-	u32 reserved4[4];
-};
-
-struct bna_rxtx_q_mem {
-	struct bna_rxq_mem rxq;
-	struct bna_txq_mem txq;
-};
-
-struct bna_cq_mem {
-	u32 pg_tbl_addr_lo;
-	u32 pg_tbl_addr_hi;
-	u32 cur_q_entry_lo;
-	u32 cur_q_entry_hi;
-
-	u32 reserved1;
-	u32 reserved2;
-	u32 pg_cnt_n_prd_ptr;	/* 31:16->total page count */
-					/* 15:0 ->producer pointer (index?) */
-	u32 entry_n_pg_size;	/* 31:16->entry size */
-					/* 15:0 ->page size */
-	u32 int_blk_n_cns_ptr;	/* 31:24->Int Blk Id; */
-					/* 23:16->Int Blk Offset */
-					/* 15:0 ->consumer pointer(index?) */
-	u32 q_state;		/* 31:16->reserved; 15:0-> Q state */
-	u32 reserved3[2];
-	u32 reserved4[4];
-};
-
-struct bna_ib_blk_mem {
-	u32 host_addr_lo;
-	u32 host_addr_hi;
-	u32 clsc_n_ctrl_n_msix;	/* 31:24->coalescing; */
-					/* 23:16->coalescing cfg; */
-					/* 15:8 ->control; */
-					/* 7:0 ->msix; */
-	u32 ipkt_n_ent_n_idxof;
-	u32 ipkt_cnt_cfg_n_unacked;
-
-	u32 reserved[3];
-};
-
-struct bna_idx_tbl_mem {
-	u32 idx;	  /* !< 31:16->res;15:0->idx; */
-};
-
-struct bna_doorbell_qset {
-	u32 rxq[0x20 >> 2];
-	u32 txq[0x20 >> 2];
-	u32 ib0[0x20 >> 2];
-	u32 ib1[0x20 >> 2];
-};
-
-struct bna_rx_fndb_ram {
-	u32 rss_prop;
-	u32 size_routing_props;
-	u32 rit_hds_mcastq;
-	u32 control_flags;
 };
 
-struct bna_tx_fndb_ram {
-	u32 vlan_n_ctrl_flags;
+struct bna_bit_defn {
+	u32 mbox_status_bits;
+	u32 mbox_mask_bits;
+	u32 error_status_bits;
+	u32 error_mask_bits;
+	u32 halt_status_bits;
+	u32 halt_mask_bits;
 };
 
-/**
- * @brief
- *  Structure which maps to RxFn Indirection Table (RIT)
- *  Size : 1 word
- *  See catapult_spec.pdf, RxA for details
- */
-struct bna_rit_mem {
-	u32 rxq_ids;	/* !< 31:12->res;11:0->two 6 bit RxQ Ids */
-};
-
-/**
- * @brief
- *  Structure which maps to RSS Table entry
- *  Size : 16 words
- *  See catapult_spec.pdf, RAD for details
- */
-struct bna_rss_mem {
-	/*
-	 * 31:12-> res
-	 * 11:8 -> protocol type
-	 *  7:0 -> hash index
-	 */
-	u32 type_n_hash;
-	u32 hash_key[10];  /* !< 40 byte Toeplitz hash key */
-	u32 reserved[5];
+struct bna_reg {
+	void __iomem *fn_int_status;
+	void __iomem *fn_int_mask;
 };
 
 /* TxQ Vector (a.k.a. Tx-Buffer Descriptor) */
@@ -1431,10 +366,6 @@ struct bna_txq_wi_vector {
 	struct bna_dma_addr host_addr; /* Tx-Buf DMA addr */
 };
 
-typedef u16 bna_txq_wi_opcode_t;
-
-typedef u16 bna_txq_wi_ctrl_flag_t;
-
 /**
  *  TxQ Entry Structure
  *
@@ -1445,10 +376,10 @@ struct bna_txq_entry {
 		struct {
 			u8 reserved;
 			u8 num_vectors;	/* number of vectors present */
-			bna_txq_wi_opcode_t opcode; /* Either */
+			u16 opcode; /* Either */
 						    /* BNA_TXQ_WI_SEND or */
 						    /* BNA_TXQ_WI_SEND_LSO */
-			bna_txq_wi_ctrl_flag_t flags; /* OR of all the flags */
+			u16 flags; /* OR of all the flags */
 			u16 l4_hdr_size_n_offset;
 			u16 vlan_tag;
 			u16 lso_mss;	/* Only 14 LSB are valid */
@@ -1457,7 +388,7 @@ struct bna_txq_entry {
 
 		struct {
 			u16 reserved;
-			bna_txq_wi_opcode_t opcode; /* Must be */
+			u16 opcode; /* Must be */
 						    /* BNA_TXQ_WI_EXTENSION */
 			u32 reserved2[3];	/* Place holder for */
 						/* removed vector (12 bytes) */
@@ -1465,19 +396,15 @@ struct bna_txq_entry {
 	} hdr;
 	struct bna_txq_wi_vector vector[4];
 };
-#define wi_hdr		hdr.wi
-#define wi_ext_hdr  hdr.wi_ext
 
 /* RxQ Entry Structure */
 struct bna_rxq_entry {		/* Rx-Buffer */
 	struct bna_dma_addr host_addr; /* Rx-Buffer DMA address */
 };
 
-typedef u32 bna_cq_e_flag_t;
-
 /* CQ Entry Structure */
 struct bna_cq_entry {
-	bna_cq_e_flag_t flags;
+	u32 flags;
 	u16 vlan_tag;
 	u16 length;
 	u32 rss_hash;
diff --git a/drivers/net/bna/bna_types.h b/drivers/net/bna/bna_types.h
index 2f89cb2..a4f71c0 100644
--- a/drivers/net/bna/bna_types.h
+++ b/drivers/net/bna/bna_types.h
@@ -21,6 +21,8 @@
 #include "cna.h"
 #include "bna_hw.h"
 #include "bfa_cee.h"
+#include "bfi_enet.h"
+#include "bfa_msgq.h"
 
 /**
  *
@@ -28,13 +30,14 @@
  *
  */
 
+struct bna_mcam_handle;
 struct bna_txq;
 struct bna_tx;
 struct bna_rxq;
 struct bna_cq;
 struct bna_rx;
 struct bna_rxf;
-struct bna_port;
+struct bna_enet;
 struct bna;
 struct bnad;
 
@@ -86,31 +89,29 @@ enum bna_res_req_type {
 	BNA_RES_MEM_T_ATTR		= 1,
 	BNA_RES_MEM_T_FWTRC		= 2,
 	BNA_RES_MEM_T_STATS		= 3,
-	BNA_RES_MEM_T_SWSTATS		= 4,
-	BNA_RES_MEM_T_IBIDX		= 5,
-	BNA_RES_MEM_T_IB_ARRAY		= 6,
-	BNA_RES_MEM_T_INTR_ARRAY	= 7,
-	BNA_RES_MEM_T_IDXSEG_ARRAY	= 8,
-	BNA_RES_MEM_T_TX_ARRAY		= 9,
-	BNA_RES_MEM_T_TXQ_ARRAY		= 10,
-	BNA_RES_MEM_T_RX_ARRAY		= 11,
-	BNA_RES_MEM_T_RXP_ARRAY		= 12,
-	BNA_RES_MEM_T_RXQ_ARRAY		= 13,
-	BNA_RES_MEM_T_UCMAC_ARRAY	= 14,
-	BNA_RES_MEM_T_MCMAC_ARRAY	= 15,
-	BNA_RES_MEM_T_RIT_ENTRY		= 16,
-	BNA_RES_MEM_T_RIT_SEGMENT	= 17,
-	BNA_RES_INTR_T_MBOX		= 18,
 	BNA_RES_T_MAX
 };
 
+enum bna_mod_res_req_type {
+	BNA_MOD_RES_MEM_T_TX_ARRAY	= 0,
+	BNA_MOD_RES_MEM_T_TXQ_ARRAY	= 1,
+	BNA_MOD_RES_MEM_T_RX_ARRAY	= 2,
+	BNA_MOD_RES_MEM_T_RXP_ARRAY	= 3,
+	BNA_MOD_RES_MEM_T_RXQ_ARRAY	= 4,
+	BNA_MOD_RES_MEM_T_UCMAC_ARRAY	= 5,
+	BNA_MOD_RES_MEM_T_MCMAC_ARRAY	= 6,
+	BNA_MOD_RES_MEM_T_MCHANDLE_ARRAY = 7,
+	BNA_MOD_RES_T_MAX
+};
+
 enum bna_tx_res_req_type {
 	BNA_TX_RES_MEM_T_TCB	= 0,
 	BNA_TX_RES_MEM_T_UNMAPQ	= 1,
 	BNA_TX_RES_MEM_T_QPT	= 2,
 	BNA_TX_RES_MEM_T_SWQPT	= 3,
 	BNA_TX_RES_MEM_T_PAGE	= 4,
-	BNA_TX_RES_INTR_T_TXCMPL = 5,
+	BNA_TX_RES_MEM_T_IBIDX	= 5,
+	BNA_TX_RES_INTR_T_TXCMPL = 6,
 	BNA_TX_RES_T_MAX,
 };
 
@@ -127,13 +128,10 @@ enum bna_rx_mem_type {
 	BNA_RX_RES_MEM_T_DSWQPT		= 9,	/* RX s/w QPT */
 	BNA_RX_RES_MEM_T_DPAGE		= 10,	/* RX s/w QPT */
 	BNA_RX_RES_MEM_T_HPAGE		= 11,	/* RX s/w QPT */
-	BNA_RX_RES_T_INTR		= 12,	/* Rx interrupts */
-	BNA_RX_RES_T_MAX		= 13
-};
-
-enum bna_mbox_state {
-	BNA_MBOX_FREE		= 0,
-	BNA_MBOX_POSTED		= 1
+	BNA_RX_RES_MEM_T_IBIDX		= 12,
+	BNA_RX_RES_MEM_T_RIT		= 13,
+	BNA_RX_RES_T_INTR		= 14,	/* Rx interrupts */
+	BNA_RX_RES_T_MAX		= 15
 };
 
 enum bna_tx_type {
@@ -142,14 +140,15 @@ enum bna_tx_type {
 };
 
 enum bna_tx_flags {
-	BNA_TX_F_PORT_STARTED	= 1,
+	BNA_TX_F_ENET_STARTED	= 1,
 	BNA_TX_F_ENABLED	= 2,
-	BNA_TX_F_PRIO_LOCK	= 4,
+	BNA_TX_F_PRIO_CHANGED	= 4,
+	BNA_TX_F_BW_UPDATED	= 8,
 };
 
 enum bna_tx_mod_flags {
-	BNA_TX_MOD_F_PORT_STARTED	= 1,
-	BNA_TX_MOD_F_PORT_LOOPBACK	= 2,
+	BNA_TX_MOD_F_ENET_STARTED	= 1,
+	BNA_TX_MOD_F_ENET_LOOPBACK	= 2,
 };
 
 enum bna_rx_type {
@@ -165,80 +164,49 @@ enum bna_rxp_type {
 
 enum bna_rxmode {
 	BNA_RXMODE_PROMISC	= 1,
-	BNA_RXMODE_ALLMULTI	= 2
+	BNA_RXMODE_DEFAULT	= 2,
+	BNA_RXMODE_ALLMULTI	= 4
 };
 
 enum bna_rx_event {
 	RX_E_START			= 1,
 	RX_E_STOP			= 2,
 	RX_E_FAIL			= 3,
-	RX_E_RXF_STARTED		= 4,
-	RX_E_RXF_STOPPED		= 5,
-	RX_E_RXQ_STOPPED		= 6,
-};
-
-enum bna_rx_state {
-	BNA_RX_STOPPED			= 1,
-	BNA_RX_RXF_START_WAIT		= 2,
-	BNA_RX_STARTED			= 3,
-	BNA_RX_RXF_STOP_WAIT		= 4,
-	BNA_RX_RXQ_STOP_WAIT		= 5,
+	RX_E_STARTED			= 4,
+	RX_E_STOPPED			= 5,
+	RX_E_RXF_STARTED		= 6,
+	RX_E_RXF_STOPPED		= 7,
+	RX_E_CLEANUP_DONE		= 8,
 };
 
 enum bna_rx_flags {
-	BNA_RX_F_ENABLE		= 0x01,		/* bnad enabled rxf */
-	BNA_RX_F_PORT_ENABLED	= 0x02,		/* Port object is enabled */
-	BNA_RX_F_PORT_FAILED	= 0x04,		/* Port in failed state */
+	BNA_RX_F_ENET_STARTED	= 1,
+	BNA_RX_F_ENABLED	= 2,
 };
 
 enum bna_rx_mod_flags {
-	BNA_RX_MOD_F_PORT_STARTED	= 1,
-	BNA_RX_MOD_F_PORT_LOOPBACK	= 2,
-};
-
-enum bna_rxf_oper_state {
-	BNA_RXF_OPER_STATE_RUNNING	= 0x01, /* rxf operational */
-	BNA_RXF_OPER_STATE_PAUSED	= 0x02,	/* rxf in PAUSED state */
+	BNA_RX_MOD_F_ENET_STARTED	= 1,
+	BNA_RX_MOD_F_ENET_LOOPBACK	= 2,
 };
 
 enum bna_rxf_flags {
-	BNA_RXF_FL_STOP_PENDING		= 0x01,
-	BNA_RXF_FL_FAILED		= 0x02,
-	BNA_RXF_FL_RSS_CONFIG_PENDING	= 0x04,
-	BNA_RXF_FL_OPERSTATE_CHANGED	= 0x08,
-	BNA_RXF_FL_RXF_ENABLED		= 0x10,
-	BNA_RXF_FL_VLAN_CONFIG_PENDING	= 0x20,
+	BNA_RXF_F_PAUSED		= 1,
 };
 
 enum bna_rxf_event {
 	RXF_E_START			= 1,
 	RXF_E_STOP			= 2,
 	RXF_E_FAIL			= 3,
-	RXF_E_CAM_FLTR_MOD		= 4,
-	RXF_E_STARTED			= 5,
-	RXF_E_STOPPED			= 6,
-	RXF_E_CAM_FLTR_RESP		= 7,
-	RXF_E_PAUSE			= 8,
-	RXF_E_RESUME			= 9,
-	RXF_E_STAT_CLEARED		= 10,
-};
-
-enum bna_rxf_state {
-	BNA_RXF_STOPPED			= 1,
-	BNA_RXF_START_WAIT		= 2,
-	BNA_RXF_CAM_FLTR_MOD_WAIT	= 3,
-	BNA_RXF_STARTED			= 4,
-	BNA_RXF_CAM_FLTR_CLR_WAIT	= 5,
-	BNA_RXF_STOP_WAIT		= 6,
-	BNA_RXF_PAUSE_WAIT		= 7,
-	BNA_RXF_RESUME_WAIT		= 8,
-	BNA_RXF_STAT_CLR_WAIT		= 9,
+	RXF_E_CONFIG			= 4,
+	RXF_E_PAUSE			= 5,
+	RXF_E_RESUME			= 6,
+	RXF_E_FW_RESP			= 7,
 };
 
-enum bna_port_type {
-	BNA_PORT_T_REGULAR		= 0,
-	BNA_PORT_T_LOOPBACK_INTERNAL	= 1,
-	BNA_PORT_T_LOOPBACK_EXTERNAL	= 2,
+enum bna_enet_type {
+	BNA_ENET_T_REGULAR		= 0,
+	BNA_ENET_T_LOOPBACK_INTERNAL	= 1,
+	BNA_ENET_T_LOOPBACK_EXTERNAL	= 2,
 };
 
 enum bna_link_status {
@@ -247,17 +215,27 @@ enum bna_link_status {
 	BNA_CEE_UP		= 2
 };
 
-enum bna_llport_flags {
-	BNA_LLPORT_F_ADMIN_UP		= 1,
-	BNA_LLPORT_F_PORT_ENABLED	= 2,
-	BNA_LLPORT_F_RX_STARTED		= 4
+enum bna_ethport_flags {
+	BNA_ETHPORT_F_ADMIN_UP		= 1,
+	BNA_ETHPORT_F_PORT_ENABLED	= 2,
+	BNA_ETHPORT_F_RX_STARTED	= 4,
 };
 
-enum bna_port_flags {
-	BNA_PORT_F_DEVICE_READY	= 1,
-	BNA_PORT_F_ENABLED	= 2,
-	BNA_PORT_F_PAUSE_CHANGED = 4,
-	BNA_PORT_F_MTU_CHANGED	= 8
+enum bna_enet_flags {
+	BNA_ENET_F_IOCETH_READY		= 1,
+	BNA_ENET_F_ENABLED		= 2,
+	BNA_ENET_F_PAUSE_CHANGED	= 4,
+	BNA_ENET_F_MTU_CHANGED		= 8
+};
+
+enum bna_rss_flags {
+	BNA_RSS_F_RIT_PENDING		= 1,
+	BNA_RSS_F_CFG_PENDING		= 2,
+	BNA_RSS_F_STATUS_PENDING	= 4,
+};
+
+enum bna_mod_flags {
+	BNA_MOD_F_INIT_DONE		= 1,
 };
 
 enum bna_pkt_rates {
@@ -289,10 +267,17 @@ enum bna_dim_bias_types {
 	BNA_BIAS_T_MAX			= 2
 };
 
+#define BNA_MAX_NAME_SIZE	64
+struct bna_ident {
+	int			id;
+	char			name[BNA_MAX_NAME_SIZE];
+};
+
 struct bna_mac {
 	/* This should be the first one */
 	struct list_head			qe;
 	u8			addr[ETH_ALEN];
+	struct bna_mcam_handle *handle;
 };
 
 struct bna_mem_descr {
@@ -338,23 +323,29 @@ struct bna_qpt {
 	u32		page_size;
 };
 
+struct bna_attr {
+	int			num_txq;
+	int			num_rxp;
+	int			num_ucmac;
+	int			num_mcmac;
+	int			max_rit_size;
+};
+
 /**
  *
- * Device
+ * IOCEth
  *
  */
 
-struct bna_device {
+struct bna_ioceth {
 	bfa_fsm_t		fsm;
 	struct bfa_ioc ioc;
 
-	enum bna_intr_type intr_type;
-	int			vector;
+	struct bna_attr attr;
+	struct bfa_msgq_cmd_entry msgq_cmd;
+	struct bfi_enet_attr_req attr_req;
 
-	void (*ready_cbfn)(struct bnad *bnad, enum bna_cb_status status);
-	struct bnad *ready_cbarg;
-
-	void (*stop_cbfn)(struct bnad *bnad, enum bna_cb_status status);
+	void (*stop_cbfn)(struct bnad *bnad);
 	struct bnad *stop_cbarg;
 
 	struct bna *bna;
@@ -362,32 +353,7 @@ struct bna_device {
 
 /**
  *
- * Mail box
- *
- */
-
-struct bna_mbox_qe {
-	/* This should be the first one */
-	struct list_head			qe;
-
-	struct bfa_mbox_cmd cmd;
-	u32		cmd_len;
-	/* Callback for port, tx, rx, rxf */
-	void (*cbfn)(void *arg, int status);
-	void			*cbarg;
-};
-
-struct bna_mbox_mod {
-	enum bna_mbox_state state;
-	struct list_head			posted_q;
-	u32		msg_pending;
-	u32		msg_ctr;
-	struct bna *bna;
-};
-
-/**
- *
- * Port
+ * Enet
  *
  */
 
@@ -397,50 +363,58 @@ struct bna_pause_config {
 	enum bna_status rx_pause;
 };
 
-struct bna_llport {
+struct bna_enet {
 	bfa_fsm_t		fsm;
-	enum bna_llport_flags flags;
+	enum bna_enet_flags flags;
 
-	enum bna_port_type type;
+	enum bna_enet_type type;
 
-	enum bna_link_status link_status;
+	struct bna_pause_config pause_config;
+	int			mtu;
 
-	int			rx_started_count;
+	/* Callback for bna_enet_disable(), enet_stop() */
+	void (*stop_cbfn)(void *);
+	void			*stop_cbarg;
+
+	/* Callback for bna_enet_pause_config() */
+	void (*pause_cbfn)(struct bnad *);
+
+	/* Callback for bna_enet_mtu_set() */
+	void (*mtu_cbfn)(struct bnad *);
 
-	void (*stop_cbfn)(struct bna_port *, enum bna_cb_status);
+	struct bfa_wc		chld_stop_wc;
 
-	struct bna_mbox_qe mbox_qe;
+	struct bfa_msgq_cmd_entry msgq_cmd;
+	struct bfi_enet_set_pause_req pause_req;
 
 	struct bna *bna;
 };
 
-struct bna_port {
-	bfa_fsm_t		fsm;
-	enum bna_port_flags flags;
-
-	enum bna_port_type type;
+/**
+ *
+ * Ethport
+ *
+ */
 
-	struct bna_llport llport;
+struct bna_ethport {
+	bfa_fsm_t		fsm;
+	enum bna_ethport_flags flags;
 
-	struct bna_pause_config pause_config;
-	u8			priority;
-	int			mtu;
+	enum bna_link_status link_status;
 
-	/* Callback for bna_port_disable(), port_stop() */
-	void (*stop_cbfn)(void *, enum bna_cb_status);
-	void			*stop_cbarg;
+	int			rx_started_count;
 
-	/* Callback for bna_port_pause_config() */
-	void (*pause_cbfn)(struct bnad *, enum bna_cb_status);
+	void (*stop_cbfn)(struct bna_enet *);
 
-	/* Callback for bna_port_mtu_set() */
-	void (*mtu_cbfn)(struct bnad *, enum bna_cb_status);
+	void (*adminup_cbfn)(struct bnad *, enum bna_cb_status);
 
 	void (*link_cbfn)(struct bnad *, enum bna_link_status);
 
-	struct bfa_wc		chld_stop_wc;
-
-	struct bna_mbox_qe mbox_qe;
+	struct bfa_msgq_cmd_entry msgq_cmd;
+	union {
+		struct bfi_enet_enable_req admin_req;
+		struct bfi_enet_diag_lb_req lpbk_req;
+	} bfi_enet_cmd;
 
 	struct bna *bna;
 };
@@ -451,82 +425,25 @@ struct bna_port {
  *
  */
 
-/* IB index segment structure */
-struct bna_ibidx_seg {
-	/* This should be the first one */
-	struct list_head			qe;
-
-	u8			ib_seg_size;
-	u8			ib_idx_tbl_offset;
-};
-
-/* Interrupt structure */
-struct bna_intr {
-	/* This should be the first one */
-	struct list_head			qe;
-	int			ref_count;
-
-	enum bna_intr_type intr_type;
-	int			vector;
-
-	struct bna_ib *ib;
-};
-
 /* Doorbell structure */
 struct bna_ib_dbell {
 	void *__iomem doorbell_addr;
 	u32		doorbell_ack;
 };
 
-/* Interrupt timer configuration */
-struct bna_ib_config {
-	u8		coalescing_timeo;    /* Unit is 5usec. */
-
-	int			interpkt_count;
-	int			interpkt_timeo;
-
-	enum ib_flags ctrl_flags;
-};
-
 /* IB structure */
 struct bna_ib {
-	/* This should be the first one */
-	struct list_head			qe;
-
-	int			ib_id;
-
-	int			ref_count;
-	int			start_count;
-
 	struct bna_dma_addr ib_seg_host_addr;
 	void		*ib_seg_host_addr_kva;
-	u32		idx_mask; /* Size >= BNA_IBIDX_MAX_SEGSIZE */
-
-	struct bna_ibidx_seg *idx_seg;
 
 	struct bna_ib_dbell door_bell;
 
-	struct bna_intr *intr;
-
-	struct bna_ib_config ib_config;
-
-	struct bna *bna;
-};
-
-/* IB module - keeps track of IBs and interrupts */
-struct bna_ib_mod {
-	struct bna_ib *ib;		/* BFI_MAX_IB entries */
-	struct bna_intr *intr;		/* BFI_MAX_IB entries */
-	struct bna_ibidx_seg *idx_seg;	/* BNA_IBIDX_TOTAL_SEGS */
-
-	struct list_head			ib_free_q;
-
-	struct list_head		ibidx_seg_pool[BFI_IBIDX_TOTAL_POOLS];
-
-	struct list_head			intr_free_q;
-	struct list_head			intr_active_q;
+	enum bna_intr_type	intr_type;
+	int			intr_vector;
 
-	struct bna *bna;
+	u8			coalescing_timeo;    /* Unit is 5usec. */
+	int			interpkt_count;
+	int			interpkt_timeo;
 };
 
 /**
@@ -552,6 +469,7 @@ struct bna_tcb {
 	/* Control path */
 	struct bna_txq *txq;
 	struct bnad *bnad;
+	void			*priv; /* BNAD's cookie */
 	enum bna_intr_type intr_type;
 	int			intr_vector;
 	u8			priority; /* Current priority */
@@ -565,68 +483,66 @@ struct bna_txq {
 	/* This should be the first one */
 	struct list_head			qe;
 
-	int			txq_id;
-
 	u8			priority;
 
 	struct bna_qpt qpt;
 	struct bna_tcb *tcb;
-	struct bna_ib *ib;
-	int			ib_seg_offset;
+	struct bna_ib ib;
 
 	struct bna_tx *tx;
 
+	int			hw_id;
+
 	u64		tx_packets;
 	u64		tx_bytes;
 };
 
-/* TxF structure (hardware Tx Function) */
-struct bna_txf {
-	int			txf_id;
-	enum txf_flags ctrl_flags;
-	u16		vlan;
-};
-
 /* Tx object */
 struct bna_tx {
 	/* This should be the first one */
 	struct list_head			qe;
+	int			rid;
+	int			hw_id;
 
 	bfa_fsm_t		fsm;
 	enum bna_tx_flags flags;
 
 	enum bna_tx_type type;
+	int			num_txq;
 
 	struct list_head			txq_q;
-	struct bna_txf txf;
+	u16			txf_vlan_id;
 
 	/* Tx event handlers */
 	void (*tcb_setup_cbfn)(struct bnad *, struct bna_tcb *);
 	void (*tcb_destroy_cbfn)(struct bnad *, struct bna_tcb *);
-	void (*tx_stall_cbfn)(struct bnad *, struct bna_tcb *);
-	void (*tx_resume_cbfn)(struct bnad *, struct bna_tcb *);
-	void (*tx_cleanup_cbfn)(struct bnad *, struct bna_tcb *);
+	void (*tx_stall_cbfn)(struct bnad *, struct bna_tx *);
+	void (*tx_resume_cbfn)(struct bnad *, struct bna_tx *);
+	void (*tx_cleanup_cbfn)(struct bnad *, struct bna_tx *);
 
 	/* callback for bna_tx_disable(), bna_tx_stop() */
-	void (*stop_cbfn)(void *arg, struct bna_tx *tx,
-				enum bna_cb_status status);
+	void (*stop_cbfn)(void *arg, struct bna_tx *tx);
 	void			*stop_cbarg;
 
 	/* callback for bna_tx_prio_set() */
-	void (*prio_change_cbfn)(struct bnad *bnad, struct bna_tx *tx,
-				enum bna_cb_status status);
-
-	struct bfa_wc		txq_stop_wc;
+	void (*prio_change_cbfn)(struct bnad *bnad, struct bna_tx *tx);
 
-	struct bna_mbox_qe mbox_qe;
+	struct bfa_msgq_cmd_entry msgq_cmd;
+	union {
+		struct bfi_enet_tx_cfg_req	cfg_req;
+		struct bfi_enet_req		req;
+		struct bfi_enet_tx_cfg_rsp	cfg_rsp;
+	} bfi_enet_cmd;
 
 	struct bna *bna;
 	void			*priv;	/* bnad's cookie */
 };
 
+/* Tx object configuration used during creation */
 struct bna_tx_config {
 	int			num_txq;
 	int			txq_depth;
+	int			coalescing_timeo;
 	enum bna_tx_type tx_type;
 };
 
@@ -635,9 +551,9 @@ struct bna_tx_event_cbfn {
 	void (*tcb_setup_cbfn)(struct bnad *, struct bna_tcb *);
 	void (*tcb_destroy_cbfn)(struct bnad *, struct bna_tcb *);
 	/* Mandatory */
-	void (*tx_stall_cbfn)(struct bnad *, struct bna_tcb *);
-	void (*tx_resume_cbfn)(struct bnad *, struct bna_tcb *);
-	void (*tx_cleanup_cbfn)(struct bnad *, struct bna_tcb *);
+	void (*tx_stall_cbfn)(struct bnad *, struct bna_tx *);
+	void (*tx_resume_cbfn)(struct bnad *, struct bna_tx *);
+	void (*tx_cleanup_cbfn)(struct bnad *, struct bna_tx *);
 };
 
 /* Tx module - keeps track of free, active tx objects */
@@ -651,57 +567,25 @@ struct bna_tx_mod {
 	struct list_head			txq_free_q;
 
 	/* callback for bna_tx_mod_stop() */
-	void (*stop_cbfn)(struct bna_port *port,
-				enum bna_cb_status status);
+	void (*stop_cbfn)(struct bna_enet *enet);
 
 	struct bfa_wc		tx_stop_wc;
 
 	enum bna_tx_mod_flags flags;
 
-	int			priority;
-	int			cee_link;
+	u8			prio_map;
+	int			default_prio;
+	int			iscsi_over_cee;
+	int			iscsi_prio;
+	int			prio_reconfigured;
 
-	u32		txf_bmap[2];
+	u32			rid_mask;
 
 	struct bna *bna;
 };
 
 /**
  *
- * Receive Indirection Table
- *
- */
-
-/* One row of RIT table */
-struct bna_rit_entry {
-	u8 large_rxq_id;	/* used for either large or data buffers */
-	u8 small_rxq_id;	/* used for either small or header buffers */
-};
-
-/* RIT segment */
-struct bna_rit_segment {
-	struct list_head			qe;
-
-	u32		rit_offset;
-	u32		rit_size;
-	/**
-	 * max_rit_size: Varies per RIT segment depending on how RIT is
-	 * partitioned
-	 */
-	u32		max_rit_size;
-
-	struct bna_rit_entry *rit;
-};
-
-struct bna_rit_mod {
-	struct bna_rit_entry *rit;
-	struct bna_rit_segment *rit_segment;
-
-	struct list_head		rit_seg_pool[BFI_RIT_SEG_TOTAL_POOLS];
-};
-
-/**
- *
  * Rx object
  *
  */
@@ -719,8 +603,9 @@ struct bna_rcb {
 	int			page_count;
 	/* Control path */
 	struct bna_rxq *rxq;
-	struct bna_cq *cq;
+	struct bna_ccb *ccb;
 	struct bnad *bnad;
+	void			*priv; /* BNAD's cookie */
 	unsigned long		flags;
 	int			id;
 };
@@ -728,7 +613,6 @@ struct bna_rcb {
 /* RxQ structure - QPT, configuration */
 struct bna_rxq {
 	struct list_head			qe;
-	int			rxq_id;
 
 	int			buffer_size;
 	int			q_depth;
@@ -739,6 +623,8 @@ struct bna_rxq {
 	struct bna_rxp *rxp;
 	struct bna_rx *rx;
 
+	int			hw_id;
+
 	u64		rx_packets;
 	u64		rx_bytes;
 	u64		rx_packets_with_error;
@@ -784,6 +670,7 @@ struct bna_ccb {
 	/* Control path */
 	struct bna_cq *cq;
 	struct bnad *bnad;
+	void			*priv; /* BNAD's cookie */
 	enum bna_intr_type intr_type;
 	int			intr_vector;
 	u8			rx_coalescing_timeo; /* For NAPI */
@@ -793,46 +680,43 @@ struct bna_ccb {
 
 /* CQ QPT, configuration  */
 struct bna_cq {
-	int			cq_id;
-
 	struct bna_qpt qpt;
 	struct bna_ccb *ccb;
 
-	struct bna_ib *ib;
-	u8			ib_seg_offset;
+	struct bna_ib ib;
 
 	struct bna_rx *rx;
 };
 
 struct bna_rss_config {
-	enum rss_hash_type hash_type;
+	enum bfi_enet_rss_type	hash_type;
 	u8			hash_mask;
-	u32		toeplitz_hash_key[BFI_RSS_HASH_KEY_LEN];
+	u32		toeplitz_hash_key[BFI_ENET_RSS_KEY_LEN];
 };
 
 struct bna_hds_config {
-	enum hds_header_type hdr_type;
-	int			header_size;
+	enum bfi_enet_hds_type	hdr_type;
+	int			forced_offset;
 };
 
-/* This structure is used during RX creation */
+/* Rx object configuration used during creation */
 struct bna_rx_config {
 	enum bna_rx_type rx_type;
 	int			num_paths;
 	enum bna_rxp_type rxp_type;
 	int			paused;
 	int			q_depth;
+	int			coalescing_timeo;
 	/*
 	 * Small/Large (or Header/Data) buffer size to be configured
 	 * for SLR and HDS queue type. Large buffer size comes from
-	 * port->mtu.
+	 * enet->mtu.
 	 */
 	int			small_buff_size;
 
 	enum bna_status rss_status;
 	struct bna_rss_config rss_config;
 
-	enum bna_status hds_status;
 	struct bna_hds_config hds_config;
 
 	enum bna_status vlan_strip_status;
@@ -851,51 +735,35 @@ struct bna_rxp {
 
 	/* MSI-x vector number for configuring RSS */
 	int			vector;
-
-	struct bna_mbox_qe mbox_qe;
-};
-
-/* HDS configuration structure */
-struct bna_rxf_hds {
-	enum hds_header_type hdr_type;
-	int			header_size;
-};
-
-/* RSS configuration structure */
-struct bna_rxf_rss {
-	enum rss_hash_type hash_type;
-	u8			hash_mask;
-	u32		toeplitz_hash_key[BFI_RSS_HASH_KEY_LEN];
+	int			hw_id;
 };
 
 /* RxF structure (hardware Rx Function) */
 struct bna_rxf {
 	bfa_fsm_t		fsm;
-	int			rxf_id;
-	enum rxf_flags ctrl_flags;
-	u16		default_vlan_tag;
-	enum bna_rxf_oper_state rxf_oper_state;
-	enum bna_status hds_status;
-	struct bna_rxf_hds hds_cfg;
-	enum bna_status rss_status;
-	struct bna_rxf_rss rss_cfg;
-	struct bna_rit_segment *rit_segment;
-	struct bna_rx *rx;
-	u32		forced_offset;
-	struct bna_mbox_qe mbox_qe;
-	int			mcast_rxq_id;
+	enum bna_rxf_flags flags;
+
+	struct bfa_msgq_cmd_entry msgq_cmd;
+	union {
+		struct bfi_enet_enable_req req;
+		struct bfi_enet_rss_cfg_req rss_req;
+		struct bfi_enet_rit_req rit_req;
+		struct bfi_enet_rx_vlan_req vlan_req;
+		struct bfi_enet_mcast_add_req mcast_add_req;
+		struct bfi_enet_mcast_del_req mcast_del_req;
+		struct bfi_enet_ucast_req ucast_req;
+	} bfi_enet_cmd;
 
 	/* callback for bna_rxf_start() */
-	void (*start_cbfn) (struct bna_rx *rx, enum bna_cb_status status);
+	void (*start_cbfn) (struct bna_rx *rx);
 	struct bna_rx *start_cbarg;
 
 	/* callback for bna_rxf_stop() */
-	void (*stop_cbfn) (struct bna_rx *rx, enum bna_cb_status status);
+	void (*stop_cbfn) (struct bna_rx *rx);
 	struct bna_rx *stop_cbarg;
 
-	/* callback for bna_rxf_receive_enable() / bna_rxf_receive_disable() */
-	void (*oper_state_cbfn) (struct bnad *bnad, struct bna_rx *rx,
-			enum bna_cb_status status);
+	/* callback for bna_rx_receive_pause() / bna_rx_receive_resume() */
+	void (*oper_state_cbfn) (struct bnad *bnad, struct bna_rx *rx);
 	struct bnad *oper_state_cbarg;
 
 	/**
@@ -905,25 +773,25 @@ struct bna_rxf {
 	 *	bna_rxf_{ucast/mcast}_del(),
 	 *	bna_rxf_mode_set()
 	 */
-	void (*cam_fltr_cbfn)(struct bnad *bnad, struct bna_rx *rx,
-				enum bna_cb_status status);
+	void (*cam_fltr_cbfn)(struct bnad *bnad, struct bna_rx *rx);
 	struct bnad *cam_fltr_cbarg;
 
-	enum bna_rxf_flags rxf_flags;
-
 	/* List of unicast addresses yet to be applied to h/w */
 	struct list_head			ucast_pending_add_q;
 	struct list_head			ucast_pending_del_q;
+	struct bna_mac *ucast_pending_mac;
 	int			ucast_pending_set;
 	/* ucast addresses applied to the h/w */
 	struct list_head			ucast_active_q;
-	struct bna_mac *ucast_active_mac;
+	struct bna_mac ucast_active_mac;
+	int			ucast_active_set;
 
 	/* List of multicast addresses yet to be applied to h/w */
 	struct list_head			mcast_pending_add_q;
 	struct list_head			mcast_pending_del_q;
 	/* multicast addresses applied to the h/w */
 	struct list_head			mcast_active_q;
+	struct list_head			mcast_handle_q;
 
 	/* Rx modes yet to be applied to h/w */
 	enum bna_rxmode rxmode_pending;
@@ -931,41 +799,58 @@ struct bna_rxf {
 	/* Rx modes applied to h/w */
 	enum bna_rxmode rxmode_active;
 
+	u8			vlan_pending_bitmask;
 	enum bna_status vlan_filter_status;
-	u32		vlan_filter_table[(BFI_MAX_VLAN + 1) / 32];
+	u32	vlan_filter_table[(BFI_ENET_VLAN_ID_MAX + 1) / 32];
+	bool			vlan_strip_pending;
+	enum bna_status		vlan_strip_status;
+
+	enum bna_rss_flags	rss_pending;
+	enum bna_status		rss_status;
+	struct bna_rss_config	rss_cfg;
+	u8			*rit;
+	int			rit_size;
+
+	struct bna_rx		*rx;
 };
 
 /* Rx object */
 struct bna_rx {
 	/* This should be the first one */
 	struct list_head			qe;
+	int			rid;
+	int			hw_id;
 
 	bfa_fsm_t		fsm;
 
 	enum bna_rx_type type;
 
-	/* list-head for RX path objects */
+	int			num_paths;
 	struct list_head			rxp_q;
 
+	struct bna_hds_config	hds_cfg;
+
 	struct bna_rxf rxf;
 
 	enum bna_rx_flags rx_flags;
 
-	struct bna_mbox_qe mbox_qe;
-
-	struct bfa_wc		rxq_stop_wc;
+	struct bfa_msgq_cmd_entry msgq_cmd;
+	union {
+		struct bfi_enet_rx_cfg_req	cfg_req;
+		struct bfi_enet_req		req;
+		struct bfi_enet_rx_cfg_rsp	cfg_rsp;
+	} bfi_enet_cmd;
 
 	/* Rx event handlers */
 	void (*rcb_setup_cbfn)(struct bnad *, struct bna_rcb *);
 	void (*rcb_destroy_cbfn)(struct bnad *, struct bna_rcb *);
 	void (*ccb_setup_cbfn)(struct bnad *, struct bna_ccb *);
 	void (*ccb_destroy_cbfn)(struct bnad *, struct bna_ccb *);
-	void (*rx_cleanup_cbfn)(struct bnad *, struct bna_ccb *);
-	void (*rx_post_cbfn)(struct bnad *, struct bna_rcb *);
+	void (*rx_cleanup_cbfn)(struct bnad *, struct bna_rx *);
+	void (*rx_post_cbfn)(struct bnad *, struct bna_rx *);
 
 	/* callback for bna_rx_disable(), bna_rx_stop() */
-	void (*stop_cbfn)(void *arg, struct bna_rx *rx,
-				enum bna_cb_status status);
+	void (*stop_cbfn)(void *arg, struct bna_rx *rx);
 	void			*stop_cbarg;
 
 	struct bna *bna;
@@ -979,8 +864,8 @@ struct bna_rx_event_cbfn {
 	void (*ccb_setup_cbfn)(struct bnad *, struct bna_ccb *);
 	void (*ccb_destroy_cbfn)(struct bnad *, struct bna_ccb *);
 	/* Mandatory */
-	void (*rx_cleanup_cbfn)(struct bnad *, struct bna_ccb *);
-	void (*rx_post_cbfn)(struct bnad *, struct bna_rcb *);
+	void (*rx_cleanup_cbfn)(struct bnad *, struct bna_rx *);
+	void (*rx_post_cbfn)(struct bnad *, struct bna_rx *);
 };
 
 /* Rx module - keeps track of free, active rx objects */
@@ -1003,12 +888,11 @@ struct bna_rx_mod {
 	enum bna_rx_mod_flags flags;
 
 	/* callback for bna_rx_mod_stop() */
-	void (*stop_cbfn)(struct bna_port *port,
-				enum bna_cb_status status);
+	void (*stop_cbfn)(struct bna_enet *enet);
 
 	struct bfa_wc		rx_stop_wc;
 	u32		dim_vector[BNA_LOAD_T_MAX][BNA_BIAS_T_MAX];
-	u32		rxf_bmap[2];
+	u32		rid_mask;
 };
 
 /**
@@ -1024,9 +908,18 @@ struct bna_ucam_mod {
 	struct bna *bna;
 };
 
+struct bna_mcam_handle {
+	/* This should be the first one */
+	struct list_head			qe;
+	int			handle;
+	int			refcnt;
+};
+
 struct bna_mcam_mod {
 	struct bna_mac *mcmac;		/* BFI_MAX_MCMAC entries */
+	struct bna_mcam_handle *mchandle;	/* BFI_MAX_MCMAC entries */
 	struct list_head			free_q;
+	struct list_head			free_handle_q;
 
 	struct bna *bna;
 };
@@ -1037,50 +930,20 @@ struct bna_mcam_mod {
  *
  */
 
-struct bna_tx_stats {
-	int			tx_state;
-	int			tx_flags;
-	int			num_txqs;
-	u32		txq_bmap[2];
-	int			txf_id;
-};
-
-struct bna_rx_stats {
-	int			rx_state;
-	int			rx_flags;
-	int			num_rxps;
-	int			num_rxqs;
-	u32		rxq_bmap[2];
-	u32		cq_bmap[2];
-	int			rxf_id;
-	int			rxf_state;
-	int			rxf_oper_state;
-	int			num_active_ucast;
-	int			num_active_mcast;
-	int			rxmode_active;
-	int			vlan_filter_status;
-	u32		vlan_filter_table[(BFI_MAX_VLAN + 1) / 32];
-	int			rss_status;
-	int			hds_status;
-};
-
-struct bna_sw_stats {
-	int			device_state;
-	int			port_state;
-	int			port_flags;
-	int			llport_state;
-	int			priority;
-	int			num_active_tx;
-	int			num_active_rx;
-	struct bna_tx_stats tx_stats[BFI_MAX_TXQ];
-	struct bna_rx_stats rx_stats[BFI_MAX_RXQ];
+struct bna_stats {
+	struct bna_dma_addr	hw_stats_dma;
+	struct bfi_enet_stats	*hw_stats_kva;
+	struct bfi_enet_stats	hw_stats;
 };
 
-struct bna_stats {
-	u32		txf_bmap[2];
-	u32		rxf_bmap[2];
-	struct bfi_ll_stats	*hw_stats;
-	struct bna_sw_stats *sw_stats;
+struct bna_stats_mod {
+	bool		ioc_ready;
+	bool		stats_get_busy;
+	bool		stats_clr_busy;
+	struct bfa_msgq_cmd_entry stats_get_cmd;
+	struct bfa_msgq_cmd_entry stats_clr_cmd;
+	struct bfi_enet_stats_req stats_get;
+	struct bfi_enet_stats_req stats_clr;
 };
 
 /**
@@ -1090,38 +953,32 @@ struct bna_stats {
  */
 
 struct bna {
+	struct bna_ident ident;
 	struct bfa_pcidev pcidev;
 
-	int			port_num;
-
-	struct bna_chip_regs regs;
+	struct bna_reg regs;
+	struct bna_bit_defn bits;
 
-	struct bna_dma_addr hw_stats_dma;
 	struct bna_stats stats;
 
-	struct bna_device device;
+	struct bna_ioceth ioceth;
 	struct bfa_cee cee;
+	struct bfa_msgq msgq;
 
-	struct bna_mbox_mod mbox_mod;
-
-	struct bna_port port;
+	struct bna_ethport ethport;
+	struct bna_enet enet;
+	struct bna_stats_mod stats_mod;
 
 	struct bna_tx_mod tx_mod;
-
 	struct bna_rx_mod rx_mod;
-
-	struct bna_ib_mod ib_mod;
-
 	struct bna_ucam_mod ucam_mod;
 	struct bna_mcam_mod mcam_mod;
 
-	struct bna_rit_mod rit_mod;
+	enum bna_mod_flags mod_flags;
 
-	int			rxf_promisc_id;
-
-	struct bna_mbox_qe mbox_qe;
+	int			default_mode_rid;
+	int			promisc_rid;
 
 	struct bnad *bnad;
 };
-
 #endif	/* __BNA_TYPES_H__ */
diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index abad4e3..50a6868 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -440,7 +440,6 @@ bnad_poll_cq(struct bnad *bnad, struct bna_ccb *ccb, int budget)
 	struct bnad_skb_unmap *unmap_array;
 	struct sk_buff *skb;
 	u32 flags, unmap_cons;
-	u32 qid0 = ccb->rcb[0]->rxq->rxq_id;
 	struct bna_pkt_rate *pkt_rt = &ccb->pkt_rate;
 
 	if (!test_bit(BNAD_RXQ_STARTED, &ccb->rcb[0]->flags))
@@ -454,10 +453,10 @@ bnad_poll_cq(struct bnad *bnad, struct bna_ccb *ccb, int budget)
 		packets++;
 		BNA_UPDATE_PKT_CNT(pkt_rt, ntohs(cmpl->length));
 
-		if (qid0 == cmpl->rxq_id)
-			rcb = ccb->rcb[0];
-		else
+		if (bna_is_small_rxq(cmpl->rxq_id))
 			rcb = ccb->rcb[1];
+		else
+			rcb = ccb->rcb[0];
 
 		unmap_q = rcb->unmap_q;
 		unmap_array = unmap_q->unmap_array;
@@ -618,7 +617,7 @@ bnad_msix_mbox_handler(int irq, void *data)
 
 	bna_intr_status_get(&bnad->bna, intr_status);
 
-	if (BNA_IS_MBOX_ERR_INTR(intr_status))
+	if (BNA_IS_MBOX_ERR_INTR(&bnad->bna, intr_status))
 		bna_mbox_handler(&bnad->bna, intr_status);
 
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
@@ -646,7 +645,7 @@ bnad_isr(int irq, void *data)
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 
-	if (BNA_IS_MBOX_ERR_INTR(intr_status))
+	if (BNA_IS_MBOX_ERR_INTR(&bnad->bna, intr_status))
 		bna_mbox_handler(&bnad->bna, intr_status);
 
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
@@ -713,43 +712,49 @@ bnad_set_netdev_perm_addr(struct bnad *bnad)
 
 /* Callbacks */
 void
-bnad_cb_device_enable_mbox_intr(struct bnad *bnad)
+bnad_cb_mbox_intr_enable(struct bnad *bnad)
 {
 	bnad_enable_mbox_irq(bnad);
 }
 
 void
-bnad_cb_device_disable_mbox_intr(struct bnad *bnad)
+bnad_cb_mbox_intr_disable(struct bnad *bnad)
 {
 	bnad_disable_mbox_irq(bnad);
 }
 
 void
-bnad_cb_device_enabled(struct bnad *bnad, enum bna_cb_status status)
+bnad_cb_ioceth_ready(struct bnad *bnad)
 {
+	bnad->bnad_completions.ioc_comp_status = BNA_CB_SUCCESS;
 	complete(&bnad->bnad_completions.ioc_comp);
-	bnad->bnad_completions.ioc_comp_status = status;
 }
 
 void
-bnad_cb_device_disabled(struct bnad *bnad, enum bna_cb_status status)
+bnad_cb_ioceth_failed(struct bnad *bnad)
 {
+	bnad->bnad_completions.ioc_comp_status = BNA_CB_FAIL;
+	complete(&bnad->bnad_completions.ioc_comp);
+}
+
+void
+bnad_cb_ioceth_disabled(struct bnad *bnad)
+{
+	bnad->bnad_completions.ioc_comp_status = BNA_CB_SUCCESS;
 	complete(&bnad->bnad_completions.ioc_comp);
-	bnad->bnad_completions.ioc_comp_status = status;
 }
 
 static void
-bnad_cb_port_disabled(void *arg, enum bna_cb_status status)
+bnad_cb_enet_disabled(void *arg)
 {
 	struct bnad *bnad = (struct bnad *)arg;
 
-	complete(&bnad->bnad_completions.port_comp);
-
 	netif_carrier_off(bnad->netdev);
+	complete(&bnad->bnad_completions.enet_comp);
 }
 
 void
-bnad_cb_port_link_status(struct bnad *bnad,
+bnad_cb_ethport_link_status(struct bnad *bnad,
 			enum bna_link_status link_status)
 {
 	bool link_up = 0;
@@ -757,34 +762,60 @@ bnad_cb_port_link_status(struct bnad *bnad,
 	link_up = (link_status == BNA_LINK_UP) || (link_status == BNA_CEE_UP);
 
 	if (link_status == BNA_CEE_UP) {
+		if (!test_bit(BNAD_RF_CEE_RUNNING, &bnad->run_flags))
+			BNAD_UPDATE_CTR(bnad, cee_toggle);
 		set_bit(BNAD_RF_CEE_RUNNING, &bnad->run_flags);
-		BNAD_UPDATE_CTR(bnad, cee_up);
-	} else
+	} else {
+		if (test_bit(BNAD_RF_CEE_RUNNING, &bnad->run_flags))
+			BNAD_UPDATE_CTR(bnad, cee_toggle);
 		clear_bit(BNAD_RF_CEE_RUNNING, &bnad->run_flags);
+	}
 
 	if (link_up) {
 		if (!netif_carrier_ok(bnad->netdev)) {
-			struct bna_tcb *tcb = bnad->tx_info[0].tcb[0];
-			if (!tcb)
-				return;
-			pr_warn("bna: %s link up\n",
+			uint tx_id, tcb_id;
+			printk(KERN_WARNING "bna: %s link up\n",
 				bnad->netdev->name);
 			netif_carrier_on(bnad->netdev);
 			BNAD_UPDATE_CTR(bnad, link_toggle);
-			if (test_bit(BNAD_TXQ_TX_STARTED, &tcb->flags)) {
-				/* Force an immediate Transmit Schedule */
-				pr_info("bna: %s TX_STARTED\n",
-					bnad->netdev->name);
-				netif_wake_queue(bnad->netdev);
-				BNAD_UPDATE_CTR(bnad, netif_queue_wakeup);
-			} else {
-				netif_stop_queue(bnad->netdev);
-				BNAD_UPDATE_CTR(bnad, netif_queue_stop);
+			for (tx_id = 0; tx_id < bnad->num_tx; tx_id++) {
+				for (tcb_id = 0; tcb_id < bnad->num_txq_per_tx;
+				      tcb_id++) {
+					struct bna_tcb *tcb =
+					bnad->tx_info[tx_id].tcb[tcb_id];
+					u32 txq_id;
+					if (!tcb)
+						continue;
+
+					txq_id = tcb->id;
+
+					if (test_bit(BNAD_TXQ_TX_STARTED,
+						     &tcb->flags)) {
+						/*
+						 * Force an immediate
+						 * Transmit Schedule */
+						printk(KERN_INFO "bna: %s %d "
+						      "TXQ_STARTED\n",
+						       bnad->netdev->name,
+						       txq_id);
+						netif_wake_subqueue(
+								bnad->netdev,
+								txq_id);
+						BNAD_UPDATE_CTR(bnad,
+							netif_queue_wakeup);
+					} else {
+						netif_stop_subqueue(
+								bnad->netdev,
+								txq_id);
+						BNAD_UPDATE_CTR(bnad,
+							netif_queue_stop);
+					}
+				}
 			}
 		}
 	} else {
 		if (netif_carrier_ok(bnad->netdev)) {
-			pr_warn("bna: %s link down\n",
+			printk(KERN_WARNING "bna: %s link down\n",
 				bnad->netdev->name);
 			netif_carrier_off(bnad->netdev);
 			BNAD_UPDATE_CTR(bnad, link_toggle);
@@ -793,8 +824,7 @@ bnad_cb_port_link_status(struct bnad *bnad,
 }
 
 static void
-bnad_cb_tx_disabled(void *arg, struct bna_tx *tx,
-			enum bna_cb_status status)
+bnad_cb_tx_disabled(void *arg, struct bna_tx *tx)
 {
 	struct bnad *bnad = (struct bnad *)arg;
 
@@ -871,108 +901,166 @@ bnad_cb_ccb_destroy(struct bnad *bnad, struct bna_ccb *ccb)
 }
 
 static void
-bnad_cb_tx_stall(struct bnad *bnad, struct bna_tcb *tcb)
+bnad_cb_tx_stall(struct bnad *bnad, struct bna_tx *tx)
 {
 	struct bnad_tx_info *tx_info =
-			(struct bnad_tx_info *)tcb->txq->tx->priv;
-
-	if (tx_info != &bnad->tx_info[0])
-		return;
+			(struct bnad_tx_info *)tx->priv;
+	struct bna_tcb *tcb;
+	u32 txq_id;
+	int i;
 
-	clear_bit(BNAD_TXQ_TX_STARTED, &tcb->flags);
-	netif_stop_queue(bnad->netdev);
-	pr_info("bna: %s TX_STOPPED\n", bnad->netdev->name);
+	for (i = 0; i < BNAD_MAX_TXQ_PER_TX; i++) {
+		tcb = tx_info->tcb[i];
+		if (!tcb)
+			continue;
+		txq_id = tcb->id;
+		clear_bit(BNAD_TXQ_TX_STARTED, &tcb->flags);
+		netif_stop_subqueue(bnad->netdev, txq_id);
+		printk(KERN_INFO "bna: %s %d TXQ_STOPPED\n",
+			bnad->netdev->name, txq_id);
+	}
 }
 
 static void
-bnad_cb_tx_resume(struct bnad *bnad, struct bna_tcb *tcb)
+bnad_cb_tx_resume(struct bnad *bnad, struct bna_tx *tx)
 {
-	struct bnad_unmap_q *unmap_q = tcb->unmap_q;
+	struct bnad_tx_info *tx_info = (struct bnad_tx_info *)tx->priv;
+	struct bna_tcb *tcb;
+	struct bnad_unmap_q *unmap_q;
+	u32 txq_id;
+	int i;
 
-	if (test_bit(BNAD_TXQ_TX_STARTED, &tcb->flags))
-		return;
+	for (i = 0; i < BNAD_MAX_TXQ_PER_TX; i++) {
+		tcb = tx_info->tcb[i];
+		if (!tcb)
+			continue;
+		txq_id = tcb->id;
 
-	clear_bit(BNAD_RF_TX_SHUTDOWN_DELAYED, &bnad->run_flags);
+		unmap_q = tcb->unmap_q;
 
-	while (test_and_set_bit(BNAD_TXQ_FREE_SENT, &tcb->flags))
-		cpu_relax();
+		if (test_bit(BNAD_TXQ_TX_STARTED, &tcb->flags))
+			continue;
 
-	bnad_free_all_txbufs(bnad, tcb);
+		while (test_and_set_bit(BNAD_TXQ_FREE_SENT, &tcb->flags))
+			cpu_relax();
 
-	unmap_q->producer_index = 0;
-	unmap_q->consumer_index = 0;
+		bnad_free_all_txbufs(bnad, tcb);
 
-	smp_mb__before_clear_bit();
-	clear_bit(BNAD_TXQ_FREE_SENT, &tcb->flags);
+		unmap_q->producer_index = 0;
+		unmap_q->consumer_index = 0;
+
+		smp_mb__before_clear_bit();
+		clear_bit(BNAD_TXQ_FREE_SENT, &tcb->flags);
+
+		set_bit(BNAD_TXQ_TX_STARTED, &tcb->flags);
+
+		if (netif_carrier_ok(bnad->netdev)) {
+			printk(KERN_INFO "bna: %s %d TXQ_STARTED\n",
+				bnad->netdev->name, txq_id);
+			netif_wake_subqueue(bnad->netdev, txq_id);
+			BNAD_UPDATE_CTR(bnad, netif_queue_wakeup);
+		}
+	}
 
 	/*
-	 * Workaround for first device enable failure & we
+	 * Workaround for first ioceth enable failure & we
 	 * get a 0 MAC address. We try to get the MAC address
 	 * again here.
 	 */
 	if (is_zero_ether_addr(&bnad->perm_addr.mac[0])) {
-		bna_port_mac_get(&bnad->bna.port, &bnad->perm_addr);
+		bna_enet_perm_mac_get(&bnad->bna.enet, &bnad->perm_addr);
 		bnad_set_netdev_perm_addr(bnad);
 	}
-
-	set_bit(BNAD_TXQ_TX_STARTED, &tcb->flags);
-
-	if (netif_carrier_ok(bnad->netdev)) {
-		pr_info("bna: %s TX_STARTED\n", bnad->netdev->name);
-		netif_wake_queue(bnad->netdev);
-		BNAD_UPDATE_CTR(bnad, netif_queue_wakeup);
-	}
 }
 
 static void
-bnad_cb_tx_cleanup(struct bnad *bnad, struct bna_tcb *tcb)
+bnad_cb_tx_cleanup(struct bnad *bnad, struct bna_tx *tx)
 {
-	/* Delay only once for the whole Tx Path Shutdown */
-	if (!test_and_set_bit(BNAD_RF_TX_SHUTDOWN_DELAYED, &bnad->run_flags))
-		mdelay(BNAD_TXRX_SYNC_MDELAY);
+	struct bnad_tx_info *tx_info = (struct bnad_tx_info *)tx->priv;
+	struct bna_tcb *tcb;
+	int i;
+
+	for (i = 0; i < BNAD_MAX_TXQ_PER_TX; i++) {
+		tcb = tx_info->tcb[i];
+		if (!tcb)
+			continue;
+	}
+
+	mdelay(BNAD_TXRX_SYNC_MDELAY);
+	bna_tx_cleanup_complete(tx);
 }
 
 static void
-bnad_cb_rx_cleanup(struct bnad *bnad,
-			struct bna_ccb *ccb)
+bnad_cb_rx_cleanup(struct bnad *bnad, struct bna_rx *rx)
 {
-	clear_bit(BNAD_RXQ_STARTED, &ccb->rcb[0]->flags);
+	struct bnad_rx_info *rx_info = (struct bnad_rx_info *)rx->priv;
+	struct bna_ccb *ccb;
+	struct bnad_rx_ctrl *rx_ctrl;
+	int i;
+
+	mdelay(BNAD_TXRX_SYNC_MDELAY);
+
+	for (i = 0; i < BNAD_MAX_RXP_PER_RX; i++) {
+		rx_ctrl = &rx_info->rx_ctrl[i];
+		ccb = rx_ctrl->ccb;
+		if (!ccb)
+			continue;
+
+		clear_bit(BNAD_RXQ_STARTED, &ccb->rcb[0]->flags);
+
+		if (ccb->rcb[1])
+			clear_bit(BNAD_RXQ_STARTED, &ccb->rcb[1]->flags);
 
-	if (ccb->rcb[1])
-		clear_bit(BNAD_RXQ_STARTED, &ccb->rcb[1]->flags);
+		while (test_bit(BNAD_FP_IN_RX_PATH, &rx_ctrl->flags))
+			cpu_relax();
+	}
 
-	if (!test_and_set_bit(BNAD_RF_RX_SHUTDOWN_DELAYED, &bnad->run_flags))
-		mdelay(BNAD_TXRX_SYNC_MDELAY);
+	bna_rx_cleanup_complete(rx);
 }
 
 static void
-bnad_cb_rx_post(struct bnad *bnad, struct bna_rcb *rcb)
+bnad_cb_rx_post(struct bnad *bnad, struct bna_rx *rx)
 {
-	struct bnad_unmap_q *unmap_q = rcb->unmap_q;
-
-	clear_bit(BNAD_RF_RX_SHUTDOWN_DELAYED, &bnad->run_flags);
-
-	if (rcb == rcb->cq->ccb->rcb[0])
-		bnad_cq_cmpl_init(bnad, rcb->cq->ccb);
+	struct bnad_rx_info *rx_info = (struct bnad_rx_info *)rx->priv;
+	struct bna_ccb *ccb;
+	struct bna_rcb *rcb;
+	struct bnad_rx_ctrl *rx_ctrl;
+	struct bnad_unmap_q *unmap_q;
+	int i;
+	int j;
 
-	bnad_free_all_rxbufs(bnad, rcb);
+	for (i = 0; i < BNAD_MAX_RXP_PER_RX; i++) {
+		rx_ctrl = &rx_info->rx_ctrl[i];
+		ccb = rx_ctrl->ccb;
+		if (!ccb)
+			continue;
 
-	set_bit(BNAD_RXQ_STARTED, &rcb->flags);
+		bnad_cq_cmpl_init(bnad, ccb);
 
-	/* Now allocate & post buffers for this RCB */
-	/* !!Allocation in callback context */
-	if (!test_and_set_bit(BNAD_RXQ_REFILL, &rcb->flags)) {
-		if (BNA_QE_FREE_CNT(unmap_q, unmap_q->q_depth)
-			 >> BNAD_RXQ_REFILL_THRESHOLD_SHIFT)
-			bnad_alloc_n_post_rxbufs(bnad, rcb);
-		smp_mb__before_clear_bit();
-		clear_bit(BNAD_RXQ_REFILL, &rcb->flags);
+		for (j = 0; j < BNAD_MAX_RXQ_PER_RXP; j++) {
+			rcb = ccb->rcb[j];
+			if (!rcb)
+				continue;
+			bnad_free_all_rxbufs(bnad, rcb);
+
+			set_bit(BNAD_RXQ_STARTED, &rcb->flags);
+			unmap_q = rcb->unmap_q;
+
+			/* Now allocate & post buffers for this RCB */
+			/* !!Allocation in callback context */
+			if (!test_and_set_bit(BNAD_RXQ_REFILL, &rcb->flags)) {
+				if (BNA_QE_FREE_CNT(unmap_q, unmap_q->q_depth)
+					>> BNAD_RXQ_REFILL_THRESHOLD_SHIFT)
+					bnad_alloc_n_post_rxbufs(bnad, rcb);
+					smp_mb__before_clear_bit();
+				clear_bit(BNAD_RXQ_REFILL, &rcb->flags);
+			}
+		}
 	}
 }
 
 static void
-bnad_cb_rx_disabled(void *arg, struct bna_rx *rx,
-			enum bna_cb_status status)
+bnad_cb_rx_disabled(void *arg, struct bna_rx *rx)
 {
 	struct bnad *bnad = (struct bnad *)arg;
 
@@ -980,10 +1068,9 @@ bnad_cb_rx_disabled(void *arg, struct bna_rx *rx,
 }
 
 static void
-bnad_cb_rx_mcast_add(struct bnad *bnad, struct bna_rx *rx,
-				enum bna_cb_status status)
+bnad_cb_rx_mcast_add(struct bnad *bnad, struct bna_rx *rx)
 {
-	bnad->bnad_completions.mcast_comp_status = status;
+	bnad->bnad_completions.mcast_comp_status = BNA_CB_SUCCESS;
 	complete(&bnad->bnad_completions.mcast_comp);
 }
 
@@ -1002,6 +1089,13 @@ bnad_cb_stats_get(struct bnad *bnad, enum bna_cb_status status,
 		  jiffies + msecs_to_jiffies(BNAD_STATS_TIMER_FREQ));
 }
 
+static void
+bnad_cb_enet_mtu_set(struct bnad *bnad)
+{
+	bnad->bnad_completions.mtu_comp_status = BNA_CB_SUCCESS;
+	complete(&bnad->bnad_completions.mtu_comp);
+}
+
 /* Resource allocation, free functions */
 
 static void
@@ -1413,7 +1507,7 @@ bnad_ioc_timeout(unsigned long data)
 	unsigned long flags;
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
-	bfa_nw_ioc_timeout((void *) &bnad->bna.device.ioc);
+	bfa_nw_ioc_timeout((void *) &bnad->bna.ioceth.ioc);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 }
 
@@ -1424,7 +1518,7 @@ bnad_ioc_hb_check(unsigned long data)
 	unsigned long flags;
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
-	bfa_nw_ioc_hb_check((void *) &bnad->bna.device.ioc);
+	bfa_nw_ioc_hb_check((void *) &bnad->bna.ioceth.ioc);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 }
 
@@ -1435,7 +1529,7 @@ bnad_iocpf_timeout(unsigned long data)
 	unsigned long flags;
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
-	bfa_nw_iocpf_timeout((void *) &bnad->bna.device.ioc);
+	bfa_nw_iocpf_timeout((void *) &bnad->bna.ioceth.ioc);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 }
 
@@ -1446,7 +1540,7 @@ bnad_iocpf_sem_timeout(unsigned long data)
 	unsigned long flags;
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
-	bfa_nw_iocpf_sem_timeout((void *) &bnad->bna.device.ioc);
+	bfa_nw_iocpf_sem_timeout((void *) &bnad->bna.ioceth.ioc);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 }
 
@@ -1505,7 +1599,7 @@ bnad_stats_timeout(unsigned long data)
 		return;
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
-	bna_stats_get(&bnad->bna);
+	bna_hw_stats_get(&bnad->bna);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 }
 
@@ -1751,10 +1845,10 @@ bnad_init_rx_config(struct bnad *bnad, struct bna_rx_config *rx_config)
 	if (bnad->num_rxp_per_rx > 1) {
 		rx_config->rss_status = BNA_STATUS_T_ENABLED;
 		rx_config->rss_config.hash_type =
-				(BFI_RSS_T_V4_TCP |
-				 BFI_RSS_T_V6_TCP |
-				 BFI_RSS_T_V4_IP  |
-				 BFI_RSS_T_V6_IP);
+				(BFI_ENET_RSS_IPV6 |
+				 BFI_ENET_RSS_IPV6_TCP |
+				 BFI_ENET_RSS_IPV4 |
+				 BFI_ENET_RSS_IPV4_TCP);
 		rx_config->rss_config.hash_mask =
 				bnad->num_rxp_per_rx - 1;
 		get_random_bytes(rx_config->rss_config.toeplitz_hash_key,
@@ -1987,7 +2081,7 @@ bnad_restore_vlans(struct bnad *bnad, u32 rx_id)
 	if (!bnad->vlan_grp)
 		return;
 
-	BUG_ON(!(VLAN_N_VID == (BFI_MAX_VLAN + 1)));
+	BUG_ON(!(VLAN_N_VID == (BFI_ENET_VLAN_ID_MAX + 1)));
 
 	for (vlan_id = 0; vlan_id < VLAN_N_VID; vlan_id++) {
 		if (!vlan_group_get_device(bnad->vlan_grp, vlan_id))
@@ -2042,11 +2136,11 @@ bnad_netdev_qstats_fill(struct bnad *bnad, struct rtnl_link_stats64 *stats)
 void
 bnad_netdev_hwstats_fill(struct bnad *bnad, struct rtnl_link_stats64 *stats)
 {
-	struct bfi_ll_stats_mac *mac_stats;
+	struct bfi_enet_stats_mac *mac_stats;
 	u64 bmap;
 	int i;
 
-	mac_stats = &bnad->stats.bna_stats->hw_stats->mac_stats;
+	mac_stats = &bnad->stats.bna_stats->hw_stats.mac_stats;
 	stats->rx_errors =
 		mac_stats->rx_fcs_error + mac_stats->rx_alignment_error +
 		mac_stats->rx_frame_length_error + mac_stats->rx_code_error +
@@ -2065,13 +2159,12 @@ bnad_netdev_hwstats_fill(struct bnad *bnad, struct rtnl_link_stats64 *stats)
 	stats->rx_crc_errors = mac_stats->rx_fcs_error;
 	stats->rx_frame_errors = mac_stats->rx_alignment_error;
 	/* recv'r fifo overrun */
-	bmap = (u64)bnad->stats.bna_stats->rxf_bmap[0] |
-		((u64)bnad->stats.bna_stats->rxf_bmap[1] << 32);
-	for (i = 0; bmap && (i < BFI_LL_RXF_ID_MAX); i++) {
+	bmap = bna_rx_rid_mask(&bnad->bna);
+	for (i = 0; bmap; i++) {
 		if (bmap & 1) {
 			stats->rx_fifo_errors +=
 				bnad->stats.bna_stats->
-					hw_stats->rxf_stats[i].frame_drops;
+					hw_stats.rxf_stats[i].frame_drops;
 			break;
 		}
 		bmap >>= 1;
@@ -2151,7 +2244,7 @@ bnad_q_num_init(struct bnad *bnad)
 	int rxps;
 
 	rxps = min((uint)num_online_cpus(),
-			(uint)(BNAD_MAX_RXS * BNAD_MAX_RXPS_PER_RX));
+			(uint)(BNAD_MAX_RX * BNAD_MAX_RXP_PER_RX));
 
 	if (!(bnad->cfg_flags & BNAD_CF_MSIX))
 		rxps = 1;	/* INTx */
@@ -2182,37 +2275,41 @@ bnad_q_num_adjust(struct bnad *bnad, int msix_vectors)
 		bnad->num_rxp_per_rx = 1;
 }
 
-/* Enable / disable device */
-static void
-bnad_device_disable(struct bnad *bnad)
+/* Enable / disable ioceth */
+static int
+bnad_ioceth_disable(struct bnad *bnad)
 {
 	unsigned long flags;
-
-	init_completion(&bnad->bnad_completions.ioc_comp);
+	int err = 0;
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
-	bna_device_disable(&bnad->bna.device, BNA_HARD_CLEANUP);
+	init_completion(&bnad->bnad_completions.ioc_comp);
+	bna_ioceth_disable(&bnad->bna.ioceth, BNA_HARD_CLEANUP);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
-	wait_for_completion(&bnad->bnad_completions.ioc_comp);
+	wait_for_completion_timeout(&bnad->bnad_completions.ioc_comp,
+		msecs_to_jiffies(BNAD_IOCETH_TIMEOUT));
+
+	err = bnad->bnad_completions.ioc_comp_status;
+	return err;
 }
 
 static int
-bnad_device_enable(struct bnad *bnad)
+bnad_ioceth_enable(struct bnad *bnad)
 {
 	int err = 0;
 	unsigned long flags;
 
-	init_completion(&bnad->bnad_completions.ioc_comp);
-
 	spin_lock_irqsave(&bnad->bna_lock, flags);
-	bna_device_enable(&bnad->bna.device);
+	init_completion(&bnad->bnad_completions.ioc_comp);
+	bnad->bnad_completions.ioc_comp_status = BNA_CB_WAITING;
+	bna_ioceth_enable(&bnad->bna.ioceth);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
-	wait_for_completion(&bnad->bnad_completions.ioc_comp);
+	wait_for_completion_timeout(&bnad->bnad_completions.ioc_comp,
+		msecs_to_jiffies(BNAD_IOCETH_TIMEOUT));
 
-	if (bnad->bnad_completions.ioc_comp_status)
-		err = bnad->bnad_completions.ioc_comp_status;
+	err = bnad->bnad_completions.ioc_comp_status;
 
 	return err;
 }
@@ -2365,9 +2462,9 @@ bnad_open(struct net_device *netdev)
 	mtu = ETH_HLEN + bnad->netdev->mtu + ETH_FCS_LEN;
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
-	bna_port_mtu_set(&bnad->bna.port, mtu, NULL);
-	bna_port_pause_config(&bnad->bna.port, &pause_config, NULL);
-	bna_port_enable(&bnad->bna.port);
+	bna_enet_mtu_set(&bnad->bna.enet, mtu, NULL);
+	bna_enet_pause_config(&bnad->bna.enet, &pause_config, NULL);
+	bna_enet_enable(&bnad->bna.enet);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
 	/* Enable broadcast */
@@ -2407,14 +2504,14 @@ bnad_stop(struct net_device *netdev)
 	/* Stop the stats timer */
 	bnad_stats_timer_stop(bnad);
 
-	init_completion(&bnad->bnad_completions.port_comp);
+	init_completion(&bnad->bnad_completions.enet_comp);
 
 	spin_lock_irqsave(&bnad->bna_lock, flags);
-	bna_port_disable(&bnad->bna.port, BNA_HARD_CLEANUP,
-			bnad_cb_port_disabled);
+	bna_enet_disable(&bnad->bna.enet, BNA_HARD_CLEANUP,
+			bnad_cb_enet_disabled);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
-	wait_for_completion(&bnad->bnad_completions.port_comp);
+	wait_for_completion(&bnad->bnad_completions.enet_comp);
 
 	bnad_cleanup_tx(bnad, 0);
 	bnad_cleanup_rx(bnad, 0);
@@ -2448,7 +2545,7 @@ bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 	struct bnad_unmap_q *unmap_q;
 	dma_addr_t		dma_addr;
 	struct bna_txq_entry *txqent;
-	bna_txq_wi_ctrl_flag_t	flags;
+	u16	flags;
 
 	if (unlikely
 	    (skb->len <= ETH_HLEN || skb->len > BFI_TX_MAX_DATA_PER_PKT)) {
@@ -2771,11 +2868,25 @@ bnad_set_mac_address(struct net_device *netdev, void *mac_addr)
 }
 
 static int
-bnad_change_mtu(struct net_device *netdev, int new_mtu)
+bnad_mtu_set(struct bnad *bnad, int mtu)
 {
-	int mtu, err = 0;
 	unsigned long flags;
 
+	init_completion(&bnad->bnad_completions.mtu_comp);
+
+	spin_lock_irqsave(&bnad->bna_lock, flags);
+	bna_enet_mtu_set(&bnad->bna.enet, mtu, bnad_cb_enet_mtu_set);
+	spin_unlock_irqrestore(&bnad->bna_lock, flags);
+
+	wait_for_completion(&bnad->bnad_completions.mtu_comp);
+
+	return bnad->bnad_completions.mtu_comp_status;
+}
+
+static int
+bnad_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	int err, mtu = netdev->mtu;
 	struct bnad *bnad = netdev_priv(netdev);
 
 	if (new_mtu + ETH_HLEN < ETH_ZLEN || new_mtu > BNAD_JUMBO_MTU)
@@ -2785,11 +2896,10 @@ bnad_change_mtu(struct net_device *netdev, int new_mtu)
 
 	netdev->mtu = new_mtu;
 
-	mtu = ETH_HLEN + new_mtu + ETH_FCS_LEN;
-
-	spin_lock_irqsave(&bnad->bna_lock, flags);
-	bna_port_mtu_set(&bnad->bna.port, mtu, NULL);
-	spin_unlock_irqrestore(&bnad->bna_lock, flags);
+	mtu = ETH_HLEN + VLAN_HLEN + new_mtu + ETH_FCS_LEN;
+	err = bnad_mtu_set(bnad, mtu);
+	if (err)
+		err = -EBUSY;
 
 	mutex_unlock(&bnad->conf_mutex);
 	return err;
@@ -2989,7 +3099,7 @@ bnad_uninit(struct bnad *bnad)
 
 /*
  * Initialize locks
-	a) Per device mutes used for serializing configuration
+	a) Per ioceth mutes used for serializing configuration
 	   changes from OS interface
 	b) spin lock used to protect bna state machine
  */
@@ -3136,17 +3246,17 @@ bnad_pci_probe(struct pci_dev *pdev,
 	bnad->stats.bna_stats = &bna->stats;
 
 	/* Set up timers */
-	setup_timer(&bnad->bna.device.ioc.ioc_timer, bnad_ioc_timeout,
+	setup_timer(&bnad->bna.ioceth.ioc.ioc_timer, bnad_ioc_timeout,
 				((unsigned long)bnad));
-	setup_timer(&bnad->bna.device.ioc.hb_timer, bnad_ioc_hb_check,
+	setup_timer(&bnad->bna.ioceth.ioc.hb_timer, bnad_ioc_hb_check,
 				((unsigned long)bnad));
-	setup_timer(&bnad->bna.device.ioc.iocpf_timer, bnad_iocpf_timeout,
+	setup_timer(&bnad->bna.ioceth.ioc.iocpf_timer, bnad_iocpf_timeout,
 				((unsigned long)bnad));
-	setup_timer(&bnad->bna.device.ioc.sem_timer, bnad_iocpf_sem_timeout,
+	setup_timer(&bnad->bna.ioceth.ioc.sem_timer, bnad_iocpf_sem_timeout,
 				((unsigned long)bnad));
 
 	/* Now start the timer before calling IOC */
-	mod_timer(&bnad->bna.device.ioc.iocpf_timer,
+	mod_timer(&bnad->bna.ioceth.ioc.iocpf_timer,
 		  jiffies + msecs_to_jiffies(BNA_IOC_TIMER_FREQ));
 
 	/*
@@ -3154,11 +3264,11 @@ bnad_pci_probe(struct pci_dev *pdev,
 	 * Don't care even if err != 0, bna state machine will
 	 * deal with it
 	 */
-	err = bnad_device_enable(bnad);
+	err = bnad_ioceth_enable(bnad);
 
 	/* Get the burnt-in mac */
 	spin_lock_irqsave(&bnad->bna_lock, flags);
-	bna_port_mac_get(&bna->port, &bnad->perm_addr);
+	bna_enet_perm_mac_get(&bna->enet, &bnad->perm_addr);
 	bnad_set_netdev_perm_addr(bnad);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
@@ -3175,10 +3285,10 @@ bnad_pci_probe(struct pci_dev *pdev,
 
 disable_device:
 	mutex_lock(&bnad->conf_mutex);
-	bnad_device_disable(bnad);
-	del_timer_sync(&bnad->bna.device.ioc.ioc_timer);
-	del_timer_sync(&bnad->bna.device.ioc.sem_timer);
-	del_timer_sync(&bnad->bna.device.ioc.hb_timer);
+	bnad_ioceth_disable(bnad);
+	del_timer_sync(&bnad->bna.ioceth.ioc.ioc_timer);
+	del_timer_sync(&bnad->bna.ioceth.ioc.sem_timer);
+	del_timer_sync(&bnad->bna.ioceth.ioc.hb_timer);
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_uninit(bna);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
@@ -3213,10 +3323,10 @@ bnad_pci_remove(struct pci_dev *pdev)
 	unregister_netdev(netdev);
 
 	mutex_lock(&bnad->conf_mutex);
-	bnad_device_disable(bnad);
-	del_timer_sync(&bnad->bna.device.ioc.ioc_timer);
-	del_timer_sync(&bnad->bna.device.ioc.sem_timer);
-	del_timer_sync(&bnad->bna.device.ioc.hb_timer);
+	bnad_ioceth_disable(bnad);
+	del_timer_sync(&bnad->bna.ioceth.ioc.ioc_timer);
+	del_timer_sync(&bnad->bna.ioceth.ioc.sem_timer);
+	del_timer_sync(&bnad->bna.ioceth.ioc.hb_timer);
 	spin_lock_irqsave(&bnad->bna_lock, flags);
 	bna_uninit(bna);
 	spin_unlock_irqrestore(&bnad->bna_lock, flags);
diff --git a/drivers/net/bna/bnad.h b/drivers/net/bna/bnad.h
index acf04b6..0928e68 100644
--- a/drivers/net/bna/bnad.h
+++ b/drivers/net/bna/bnad.h
@@ -37,12 +37,13 @@
 #define BNAD_TXQ_DEPTH		2048
 #define BNAD_RXQ_DEPTH		2048
 
-#define BNAD_MAX_TXS		1
+#define BNAD_MAX_TX		1
 #define BNAD_MAX_TXQ_PER_TX	8	/* 8 priority queues */
 #define BNAD_TXQ_NUM		1
 
-#define BNAD_MAX_RXS		1
-#define BNAD_MAX_RXPS_PER_RX	16
+#define BNAD_MAX_RX		1
+#define BNAD_MAX_RXP_PER_RX	16
+#define BNAD_MAX_RXQ_PER_RXP    2
 
 /*
  * Control structure pointed to ccb->ctrl, which
@@ -72,6 +73,8 @@ struct bnad_rx_ctrl {
 #define BNAD_STATS_TIMER_FREQ		1000	/* in msecs */
 #define BNAD_DIM_TIMER_FREQ		1000	/* in msecs */
 
+#define BNAD_IOCETH_TIMEOUT	     10000
+
 #define BNAD_MAX_Q_DEPTH		0x10000
 #define BNAD_MIN_Q_DEPTH		0x200
 
@@ -111,7 +114,8 @@ struct bnad_completion {
 	struct completion	tx_comp;
 	struct completion	rx_comp;
 	struct completion	stats_comp;
-	struct completion	port_comp;
+	struct completion	enet_comp;
+	struct completion	mtu_comp;
 
 	u8			ioc_comp_status;
 	u8			ucast_comp_status;
@@ -120,6 +124,7 @@ struct bnad_completion {
 	u8			rx_comp_status;
 	u8			stats_comp_status;
 	u8			port_comp_status;
+	u8			mtu_comp_status;
 };
 
 /* Tx Rx Control Stats */
@@ -141,6 +146,7 @@ struct bnad_drv_stats {
 	u64		netif_rx_dropped;
 
 	u64		link_toggle;
+	u64		cee_toggle;
 	u64		cee_up;
 
 	u64		rxp_info_alloc_failed;
@@ -175,7 +181,7 @@ struct bnad_tx_info {
 struct bnad_rx_info {
 	struct bna_rx *rx; /* 1:1 between rx_info & rx */
 
-	struct bnad_rx_ctrl rx_ctrl[BNAD_MAX_RXPS_PER_RX];
+	struct bnad_rx_ctrl rx_ctrl[BNAD_MAX_RXP_PER_RX];
 } ____cacheline_aligned;
 
 /* Unmap queues for Tx / Rx cleanup */
@@ -209,12 +215,16 @@ struct bnad_unmap_q {
 #define BNAD_RF_TX_SHUTDOWN_DELAYED	6
 #define BNAD_RF_RX_SHUTDOWN_DELAYED	7
 
+/* Define for Fast Path flags */
+/* Defined as bit positions */
+#define BNAD_FP_IN_RX_PATH	      0
+
 struct bnad {
 	struct net_device	*netdev;
 
 	/* Data path */
-	struct bnad_tx_info tx_info[BNAD_MAX_TXS];
-	struct bnad_rx_info rx_info[BNAD_MAX_RXS];
+	struct bnad_tx_info tx_info[BNAD_MAX_TX];
+	struct bnad_rx_info rx_info[BNAD_MAX_RX];
 
 	struct vlan_group	*vlan_grp;
 	/*
@@ -234,8 +244,8 @@ struct bnad {
 	u8			tx_coalescing_timeo;
 	u8			rx_coalescing_timeo;
 
-	struct bna_rx_config rx_config[BNAD_MAX_RXS];
-	struct bna_tx_config tx_config[BNAD_MAX_TXS];
+	struct bna_rx_config rx_config[BNAD_MAX_RX];
+	struct bna_tx_config tx_config[BNAD_MAX_TX];
 
 	void __iomem		*bar0;	/* BAR0 address */
 
@@ -261,8 +271,8 @@ struct bnad {
 
 	/* Control path resources, memory & irq */
 	struct bna_res_info res_info[BNA_RES_T_MAX];
-	struct bnad_tx_res_info tx_res_info[BNAD_MAX_TXS];
-	struct bnad_rx_res_info rx_res_info[BNAD_MAX_RXS];
+	struct bnad_tx_res_info tx_res_info[BNAD_MAX_TX];
+	struct bnad_rx_res_info rx_res_info[BNAD_MAX_RX];
 
 	struct bnad_completion bnad_completions;
 
diff --git a/drivers/net/bna/bnad_ethtool.c b/drivers/net/bna/bnad_ethtool.c
index fea07f1..1c19dce 100644
--- a/drivers/net/bna/bnad_ethtool.c
+++ b/drivers/net/bna/bnad_ethtool.c
@@ -29,14 +29,14 @@
 
 #define BNAD_NUM_TXF_COUNTERS 12
 #define BNAD_NUM_RXF_COUNTERS 10
-#define BNAD_NUM_CQ_COUNTERS 3
+#define BNAD_NUM_CQ_COUNTERS (3 + 5)
 #define BNAD_NUM_RXQ_COUNTERS 6
 #define BNAD_NUM_TXQ_COUNTERS 5
 
 #define BNAD_ETHTOOL_STATS_NUM						\
 	(sizeof(struct rtnl_link_stats64) / sizeof(u64) +	\
 	sizeof(struct bnad_drv_stats) / sizeof(u64) +		\
-	offsetof(struct bfi_ll_stats, rxf_stats[0]) / sizeof(u64))
+	offsetof(struct bfi_enet_stats, rxf_stats[0]) / sizeof(u64))
 
 static char *bnad_net_stats_strings[BNAD_ETHTOOL_STATS_NUM] = {
 	"rx_packets",
@@ -277,7 +277,7 @@ bnad_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *drvinfo)
 	ioc_attr = kzalloc(sizeof(*ioc_attr), GFP_KERNEL);
 	if (ioc_attr) {
 		spin_lock_irqsave(&bnad->bna_lock, flags);
-		bfa_nw_ioc_get_attr(&bnad->bna.device.ioc, ioc_attr);
+		bfa_nw_ioc_get_attr(&bnad->bna.ioceth.ioc, ioc_attr);
 		spin_unlock_irqrestore(&bnad->bna_lock, flags);
 
 		strncpy(drvinfo->fw_version, ioc_attr->adapter_attr.fw_ver,
@@ -288,323 +288,6 @@ bnad_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *drvinfo)
 	strncpy(drvinfo->bus_info, pci_name(bnad->pcidev), ETHTOOL_BUSINFO_LEN);
 }
 
-static int
-get_regs(struct bnad *bnad, u32 * regs)
-{
-	int num = 0, i;
-	u32 reg_addr;
-	unsigned long flags;
-
-#define BNAD_GET_REG(addr)					\
-do {								\
-	if (regs)						\
-		regs[num++] = readl(bnad->bar0 + (addr));	\
-	else							\
-		num++;						\
-} while (0)
-
-	spin_lock_irqsave(&bnad->bna_lock, flags);
-
-	/* DMA Block Internal Registers */
-	BNAD_GET_REG(DMA_CTRL_REG0);
-	BNAD_GET_REG(DMA_CTRL_REG1);
-	BNAD_GET_REG(DMA_ERR_INT_STATUS);
-	BNAD_GET_REG(DMA_ERR_INT_ENABLE);
-	BNAD_GET_REG(DMA_ERR_INT_STATUS_SET);
-
-	/* APP Block Register Address Offset from BAR0 */
-	BNAD_GET_REG(HOSTFN0_INT_STATUS);
-	BNAD_GET_REG(HOSTFN0_INT_MASK);
-	BNAD_GET_REG(HOST_PAGE_NUM_FN0);
-	BNAD_GET_REG(HOST_MSIX_ERR_INDEX_FN0);
-	BNAD_GET_REG(FN0_PCIE_ERR_REG);
-	BNAD_GET_REG(FN0_ERR_TYPE_STATUS_REG);
-	BNAD_GET_REG(FN0_ERR_TYPE_MSK_STATUS_REG);
-
-	BNAD_GET_REG(HOSTFN1_INT_STATUS);
-	BNAD_GET_REG(HOSTFN1_INT_MASK);
-	BNAD_GET_REG(HOST_PAGE_NUM_FN1);
-	BNAD_GET_REG(HOST_MSIX_ERR_INDEX_FN1);
-	BNAD_GET_REG(FN1_PCIE_ERR_REG);
-	BNAD_GET_REG(FN1_ERR_TYPE_STATUS_REG);
-	BNAD_GET_REG(FN1_ERR_TYPE_MSK_STATUS_REG);
-
-	BNAD_GET_REG(PCIE_MISC_REG);
-
-	BNAD_GET_REG(HOST_SEM0_INFO_REG);
-	BNAD_GET_REG(HOST_SEM1_INFO_REG);
-	BNAD_GET_REG(HOST_SEM2_INFO_REG);
-	BNAD_GET_REG(HOST_SEM3_INFO_REG);
-
-	BNAD_GET_REG(TEMPSENSE_CNTL_REG);
-	BNAD_GET_REG(TEMPSENSE_STAT_REG);
-
-	BNAD_GET_REG(APP_LOCAL_ERR_STAT);
-	BNAD_GET_REG(APP_LOCAL_ERR_MSK);
-
-	BNAD_GET_REG(PCIE_LNK_ERR_STAT);
-	BNAD_GET_REG(PCIE_LNK_ERR_MSK);
-
-	BNAD_GET_REG(FCOE_FIP_ETH_TYPE);
-	BNAD_GET_REG(RESV_ETH_TYPE);
-
-	BNAD_GET_REG(HOSTFN2_INT_STATUS);
-	BNAD_GET_REG(HOSTFN2_INT_MASK);
-	BNAD_GET_REG(HOST_PAGE_NUM_FN2);
-	BNAD_GET_REG(HOST_MSIX_ERR_INDEX_FN2);
-	BNAD_GET_REG(FN2_PCIE_ERR_REG);
-	BNAD_GET_REG(FN2_ERR_TYPE_STATUS_REG);
-	BNAD_GET_REG(FN2_ERR_TYPE_MSK_STATUS_REG);
-
-	BNAD_GET_REG(HOSTFN3_INT_STATUS);
-	BNAD_GET_REG(HOSTFN3_INT_MASK);
-	BNAD_GET_REG(HOST_PAGE_NUM_FN3);
-	BNAD_GET_REG(HOST_MSIX_ERR_INDEX_FN3);
-	BNAD_GET_REG(FN3_PCIE_ERR_REG);
-	BNAD_GET_REG(FN3_ERR_TYPE_STATUS_REG);
-	BNAD_GET_REG(FN3_ERR_TYPE_MSK_STATUS_REG);
-
-	/* Host Command Status Registers */
-	reg_addr = HOST_CMDSTS0_CLR_REG;
-	for (i = 0; i < 16; i++) {
-		BNAD_GET_REG(reg_addr);
-		BNAD_GET_REG(reg_addr + 4);
-		BNAD_GET_REG(reg_addr + 8);
-		reg_addr += 0x10;
-	}
-
-	/* Function ID register */
-	BNAD_GET_REG(FNC_ID_REG);
-
-	/* Function personality register */
-	BNAD_GET_REG(FNC_PERS_REG);
-
-	/* Operation mode register */
-	BNAD_GET_REG(OP_MODE);
-
-	/* LPU0 Registers */
-	BNAD_GET_REG(LPU0_MBOX_CTL_REG);
-	BNAD_GET_REG(LPU0_MBOX_CMD_REG);
-	BNAD_GET_REG(LPU0_MBOX_LINK_0REG);
-	BNAD_GET_REG(LPU1_MBOX_LINK_0REG);
-	BNAD_GET_REG(LPU0_MBOX_STATUS_0REG);
-	BNAD_GET_REG(LPU1_MBOX_STATUS_0REG);
-	BNAD_GET_REG(LPU0_ERR_STATUS_REG);
-	BNAD_GET_REG(LPU0_ERR_SET_REG);
-
-	/* LPU1 Registers */
-	BNAD_GET_REG(LPU1_MBOX_CTL_REG);
-	BNAD_GET_REG(LPU1_MBOX_CMD_REG);
-	BNAD_GET_REG(LPU0_MBOX_LINK_1REG);
-	BNAD_GET_REG(LPU1_MBOX_LINK_1REG);
-	BNAD_GET_REG(LPU0_MBOX_STATUS_1REG);
-	BNAD_GET_REG(LPU1_MBOX_STATUS_1REG);
-	BNAD_GET_REG(LPU1_ERR_STATUS_REG);
-	BNAD_GET_REG(LPU1_ERR_SET_REG);
-
-	/* PSS Registers */
-	BNAD_GET_REG(PSS_CTL_REG);
-	BNAD_GET_REG(PSS_ERR_STATUS_REG);
-	BNAD_GET_REG(ERR_STATUS_SET);
-	BNAD_GET_REG(PSS_RAM_ERR_STATUS_REG);
-
-	/* Catapult CPQ Registers */
-	BNAD_GET_REG(HOSTFN0_LPU0_MBOX0_CMD_STAT);
-	BNAD_GET_REG(HOSTFN0_LPU1_MBOX0_CMD_STAT);
-	BNAD_GET_REG(LPU0_HOSTFN0_MBOX0_CMD_STAT);
-	BNAD_GET_REG(LPU1_HOSTFN0_MBOX0_CMD_STAT);
-
-	BNAD_GET_REG(HOSTFN0_LPU0_MBOX1_CMD_STAT);
-	BNAD_GET_REG(HOSTFN0_LPU1_MBOX1_CMD_STAT);
-	BNAD_GET_REG(LPU0_HOSTFN0_MBOX1_CMD_STAT);
-	BNAD_GET_REG(LPU1_HOSTFN0_MBOX1_CMD_STAT);
-
-	BNAD_GET_REG(HOSTFN1_LPU0_MBOX0_CMD_STAT);
-	BNAD_GET_REG(HOSTFN1_LPU1_MBOX0_CMD_STAT);
-	BNAD_GET_REG(LPU0_HOSTFN1_MBOX0_CMD_STAT);
-	BNAD_GET_REG(LPU1_HOSTFN1_MBOX0_CMD_STAT);
-
-	BNAD_GET_REG(HOSTFN1_LPU0_MBOX1_CMD_STAT);
-	BNAD_GET_REG(HOSTFN1_LPU1_MBOX1_CMD_STAT);
-	BNAD_GET_REG(LPU0_HOSTFN1_MBOX1_CMD_STAT);
-	BNAD_GET_REG(LPU1_HOSTFN1_MBOX1_CMD_STAT);
-
-	BNAD_GET_REG(HOSTFN2_LPU0_MBOX0_CMD_STAT);
-	BNAD_GET_REG(HOSTFN2_LPU1_MBOX0_CMD_STAT);
-	BNAD_GET_REG(LPU0_HOSTFN2_MBOX0_CMD_STAT);
-	BNAD_GET_REG(LPU1_HOSTFN2_MBOX0_CMD_STAT);
-
-	BNAD_GET_REG(HOSTFN2_LPU0_MBOX1_CMD_STAT);
-	BNAD_GET_REG(HOSTFN2_LPU1_MBOX1_CMD_STAT);
-	BNAD_GET_REG(LPU0_HOSTFN2_MBOX1_CMD_STAT);
-	BNAD_GET_REG(LPU1_HOSTFN2_MBOX1_CMD_STAT);
-
-	BNAD_GET_REG(HOSTFN3_LPU0_MBOX0_CMD_STAT);
-	BNAD_GET_REG(HOSTFN3_LPU1_MBOX0_CMD_STAT);
-	BNAD_GET_REG(LPU0_HOSTFN3_MBOX0_CMD_STAT);
-	BNAD_GET_REG(LPU1_HOSTFN3_MBOX0_CMD_STAT);
-
-	BNAD_GET_REG(HOSTFN3_LPU0_MBOX1_CMD_STAT);
-	BNAD_GET_REG(HOSTFN3_LPU1_MBOX1_CMD_STAT);
-	BNAD_GET_REG(LPU0_HOSTFN3_MBOX1_CMD_STAT);
-	BNAD_GET_REG(LPU1_HOSTFN3_MBOX1_CMD_STAT);
-
-	/* Host Function Force Parity Error Registers */
-	BNAD_GET_REG(HOSTFN0_LPU_FORCE_PERR);
-	BNAD_GET_REG(HOSTFN1_LPU_FORCE_PERR);
-	BNAD_GET_REG(HOSTFN2_LPU_FORCE_PERR);
-	BNAD_GET_REG(HOSTFN3_LPU_FORCE_PERR);
-
-	/* LL Port[0|1] Halt Mask Registers */
-	BNAD_GET_REG(LL_HALT_MSK_P0);
-	BNAD_GET_REG(LL_HALT_MSK_P1);
-
-	/* LL Port[0|1] Error Mask Registers */
-	BNAD_GET_REG(LL_ERR_MSK_P0);
-	BNAD_GET_REG(LL_ERR_MSK_P1);
-
-	/* EMC FLI Registers */
-	BNAD_GET_REG(FLI_CMD_REG);
-	BNAD_GET_REG(FLI_ADDR_REG);
-	BNAD_GET_REG(FLI_CTL_REG);
-	BNAD_GET_REG(FLI_WRDATA_REG);
-	BNAD_GET_REG(FLI_RDDATA_REG);
-	BNAD_GET_REG(FLI_DEV_STATUS_REG);
-	BNAD_GET_REG(FLI_SIG_WD_REG);
-
-	BNAD_GET_REG(FLI_DEV_VENDOR_REG);
-	BNAD_GET_REG(FLI_ERR_STATUS_REG);
-
-	/* RxAdm 0 Registers */
-	BNAD_GET_REG(RAD0_CTL_REG);
-	BNAD_GET_REG(RAD0_PE_PARM_REG);
-	BNAD_GET_REG(RAD0_BCN_REG);
-	BNAD_GET_REG(RAD0_DEFAULT_REG);
-	BNAD_GET_REG(RAD0_PROMISC_REG);
-	BNAD_GET_REG(RAD0_BCNQ_REG);
-	BNAD_GET_REG(RAD0_DEFAULTQ_REG);
-
-	BNAD_GET_REG(RAD0_ERR_STS);
-	BNAD_GET_REG(RAD0_SET_ERR_STS);
-	BNAD_GET_REG(RAD0_ERR_INT_EN);
-	BNAD_GET_REG(RAD0_FIRST_ERR);
-	BNAD_GET_REG(RAD0_FORCE_ERR);
-
-	BNAD_GET_REG(RAD0_MAC_MAN_1H);
-	BNAD_GET_REG(RAD0_MAC_MAN_1L);
-	BNAD_GET_REG(RAD0_MAC_MAN_2H);
-	BNAD_GET_REG(RAD0_MAC_MAN_2L);
-	BNAD_GET_REG(RAD0_MAC_MAN_3H);
-	BNAD_GET_REG(RAD0_MAC_MAN_3L);
-	BNAD_GET_REG(RAD0_MAC_MAN_4H);
-	BNAD_GET_REG(RAD0_MAC_MAN_4L);
-
-	BNAD_GET_REG(RAD0_LAST4_IP);
-
-	/* RxAdm 1 Registers */
-	BNAD_GET_REG(RAD1_CTL_REG);
-	BNAD_GET_REG(RAD1_PE_PARM_REG);
-	BNAD_GET_REG(RAD1_BCN_REG);
-	BNAD_GET_REG(RAD1_DEFAULT_REG);
-	BNAD_GET_REG(RAD1_PROMISC_REG);
-	BNAD_GET_REG(RAD1_BCNQ_REG);
-	BNAD_GET_REG(RAD1_DEFAULTQ_REG);
-
-	BNAD_GET_REG(RAD1_ERR_STS);
-	BNAD_GET_REG(RAD1_SET_ERR_STS);
-	BNAD_GET_REG(RAD1_ERR_INT_EN);
-
-	/* TxA0 Registers */
-	BNAD_GET_REG(TXA0_CTRL_REG);
-	/* TxA0 TSO Sequence # Registers (RO) */
-	for (i = 0; i < 8; i++) {
-		BNAD_GET_REG(TXA0_TSO_TCP_SEQ_REG(i));
-		BNAD_GET_REG(TXA0_TSO_IP_INFO_REG(i));
-	}
-
-	/* TxA1 Registers */
-	BNAD_GET_REG(TXA1_CTRL_REG);
-	/* TxA1 TSO Sequence # Registers (RO) */
-	for (i = 0; i < 8; i++) {
-		BNAD_GET_REG(TXA1_TSO_TCP_SEQ_REG(i));
-		BNAD_GET_REG(TXA1_TSO_IP_INFO_REG(i));
-	}
-
-	/* RxA Registers */
-	BNAD_GET_REG(RXA0_CTL_REG);
-	BNAD_GET_REG(RXA1_CTL_REG);
-
-	/* PLB0 Registers */
-	BNAD_GET_REG(PLB0_ECM_TIMER_REG);
-	BNAD_GET_REG(PLB0_RL_CTL);
-	for (i = 0; i < 8; i++)
-		BNAD_GET_REG(PLB0_RL_MAX_BC(i));
-	BNAD_GET_REG(PLB0_RL_TU_PRIO);
-	for (i = 0; i < 8; i++)
-		BNAD_GET_REG(PLB0_RL_BYTE_CNT(i));
-	BNAD_GET_REG(PLB0_RL_MIN_REG);
-	BNAD_GET_REG(PLB0_RL_MAX_REG);
-	BNAD_GET_REG(PLB0_EMS_ADD_REG);
-
-	/* PLB1 Registers */
-	BNAD_GET_REG(PLB1_ECM_TIMER_REG);
-	BNAD_GET_REG(PLB1_RL_CTL);
-	for (i = 0; i < 8; i++)
-		BNAD_GET_REG(PLB1_RL_MAX_BC(i));
-	BNAD_GET_REG(PLB1_RL_TU_PRIO);
-	for (i = 0; i < 8; i++)
-		BNAD_GET_REG(PLB1_RL_BYTE_CNT(i));
-	BNAD_GET_REG(PLB1_RL_MIN_REG);
-	BNAD_GET_REG(PLB1_RL_MAX_REG);
-	BNAD_GET_REG(PLB1_EMS_ADD_REG);
-
-	/* HQM Control Register */
-	BNAD_GET_REG(HQM0_CTL_REG);
-	BNAD_GET_REG(HQM0_RXQ_STOP_SEM);
-	BNAD_GET_REG(HQM0_TXQ_STOP_SEM);
-	BNAD_GET_REG(HQM1_CTL_REG);
-	BNAD_GET_REG(HQM1_RXQ_STOP_SEM);
-	BNAD_GET_REG(HQM1_TXQ_STOP_SEM);
-
-	/* LUT Registers */
-	BNAD_GET_REG(LUT0_ERR_STS);
-	BNAD_GET_REG(LUT0_SET_ERR_STS);
-	BNAD_GET_REG(LUT1_ERR_STS);
-	BNAD_GET_REG(LUT1_SET_ERR_STS);
-
-	/* TRC Registers */
-	BNAD_GET_REG(TRC_CTL_REG);
-	BNAD_GET_REG(TRC_MODS_REG);
-	BNAD_GET_REG(TRC_TRGC_REG);
-	BNAD_GET_REG(TRC_CNT1_REG);
-	BNAD_GET_REG(TRC_CNT2_REG);
-	BNAD_GET_REG(TRC_NXTS_REG);
-	BNAD_GET_REG(TRC_DIRR_REG);
-	for (i = 0; i < 10; i++)
-		BNAD_GET_REG(TRC_TRGM_REG(i));
-	for (i = 0; i < 10; i++)
-		BNAD_GET_REG(TRC_NXTM_REG(i));
-	for (i = 0; i < 10; i++)
-		BNAD_GET_REG(TRC_STRM_REG(i));
-
-	spin_unlock_irqrestore(&bnad->bna_lock, flags);
-#undef BNAD_GET_REG
-	return num;
-}
-static int
-bnad_get_regs_len(struct net_device *netdev)
-{
-	int ret = get_regs(netdev_priv(netdev), NULL) * sizeof(u32);
-	return ret;
-}
-
-static void
-bnad_get_regs(struct net_device *netdev, struct ethtool_regs *regs, void *buf)
-{
-	memset(buf, 0, bnad_get_regs_len(netdev));
-	get_regs(netdev_priv(netdev), buf);
-}
-
 static void
 bnad_get_wol(struct net_device *netdev, struct ethtool_wolinfo *wolinfo)
 {
@@ -779,8 +462,8 @@ bnad_get_pauseparam(struct net_device *netdev,
 	struct bnad *bnad = netdev_priv(netdev);
 
 	pauseparam->autoneg = 0;
-	pauseparam->rx_pause = bnad->bna.port.pause_config.rx_pause;
-	pauseparam->tx_pause = bnad->bna.port.pause_config.tx_pause;
+	pauseparam->rx_pause = bnad->bna.enet.pause_config.rx_pause;
+	pauseparam->tx_pause = bnad->bna.enet.pause_config.tx_pause;
 }
 
 static int
@@ -795,12 +478,12 @@ bnad_set_pauseparam(struct net_device *netdev,
 		return -EINVAL;
 
 	mutex_lock(&bnad->conf_mutex);
-	if (pauseparam->rx_pause != bnad->bna.port.pause_config.rx_pause ||
-	    pauseparam->tx_pause != bnad->bna.port.pause_config.tx_pause) {
+	if (pauseparam->rx_pause != bnad->bna.enet.pause_config.rx_pause ||
+	    pauseparam->tx_pause != bnad->bna.enet.pause_config.tx_pause) {
 		pause_config.rx_pause = pauseparam->rx_pause;
 		pause_config.tx_pause = pauseparam->tx_pause;
 		spin_lock_irqsave(&bnad->bna_lock, flags);
-		bna_port_pause_config(&bnad->bna.port, &pause_config, NULL);
+		bna_enet_pause_config(&bnad->bna.enet, &pause_config, NULL);
 		spin_unlock_irqrestore(&bnad->bna_lock, flags);
 	}
 	mutex_unlock(&bnad->conf_mutex);
@@ -812,7 +495,7 @@ bnad_get_strings(struct net_device *netdev, u32 stringset, u8 * string)
 {
 	struct bnad *bnad = netdev_priv(netdev);
 	int i, j, q_num;
-	u64 bmap;
+	u32 bmap;
 
 	mutex_lock(&bnad->conf_mutex);
 
@@ -825,9 +508,8 @@ bnad_get_strings(struct net_device *netdev, u32 stringset, u8 * string)
 			       ETH_GSTRING_LEN);
 			string += ETH_GSTRING_LEN;
 		}
-		bmap = (u64)bnad->bna.tx_mod.txf_bmap[0] |
-			((u64)bnad->bna.tx_mod.txf_bmap[1] << 32);
-		for (i = 0; bmap && (i < BFI_LL_TXF_ID_MAX); i++) {
+		bmap = bna_tx_rid_mask(&bnad->bna);
+		for (i = 0; bmap; i++) {
 			if (bmap & 1) {
 				sprintf(string, "txf%d_ucast_octets", i);
 				string += ETH_GSTRING_LEN;
@@ -857,9 +539,8 @@ bnad_get_strings(struct net_device *netdev, u32 stringset, u8 * string)
 			bmap >>= 1;
 		}
 
-		bmap = (u64)bnad->bna.rx_mod.rxf_bmap[0] |
-			((u64)bnad->bna.rx_mod.rxf_bmap[1] << 32);
-		for (i = 0; bmap && (i < BFI_LL_RXF_ID_MAX); i++) {
+		bmap = bna_rx_rid_mask(&bnad->bna);
+		for (i = 0; bmap; i++) {
 			if (bmap & 1) {
 				sprintf(string, "rxf%d_ucast_octets", i);
 				string += ETH_GSTRING_LEN;
@@ -980,18 +661,16 @@ bnad_get_stats_count_locked(struct net_device *netdev)
 {
 	struct bnad *bnad = netdev_priv(netdev);
 	int i, j, count, rxf_active_num = 0, txf_active_num = 0;
-	u64 bmap;
+	u32 bmap;
 
-	bmap = (u64)bnad->bna.tx_mod.txf_bmap[0] |
-			((u64)bnad->bna.tx_mod.txf_bmap[1] << 32);
-	for (i = 0; bmap && (i < BFI_LL_TXF_ID_MAX); i++) {
+	bmap = bna_tx_rid_mask(&bnad->bna);
+	for (i = 0; bmap; i++) {
 		if (bmap & 1)
 			txf_active_num++;
 		bmap >>= 1;
 	}
-	bmap = (u64)bnad->bna.rx_mod.rxf_bmap[0] |
-			((u64)bnad->bna.rx_mod.rxf_bmap[1] << 32);
-	for (i = 0; bmap && (i < BFI_LL_RXF_ID_MAX); i++) {
+	bmap = bna_rx_rid_mask(&bnad->bna);
+	for (i = 0; bmap; i++) {
 		if (bmap & 1)
 			rxf_active_num++;
 		bmap >>= 1;
@@ -1104,7 +783,7 @@ bnad_get_ethtool_stats(struct net_device *netdev, struct ethtool_stats *stats,
 	unsigned long flags;
 	struct rtnl_link_stats64 *net_stats64;
 	u64 *stats64;
-	u64 bmap;
+	u32 bmap;
 
 	mutex_lock(&bnad->conf_mutex);
 	if (bnad_get_stats_count_locked(netdev) != stats->n_stats) {
@@ -1135,20 +814,20 @@ bnad_get_ethtool_stats(struct net_device *netdev, struct ethtool_stats *stats,
 		buf[bi++] = stats64[i];
 
 	/* Fill hardware stats excluding the rxf/txf into ethtool bufs */
-	stats64 = (u64 *) bnad->stats.bna_stats->hw_stats;
+	stats64 = (u64 *) &bnad->stats.bna_stats->hw_stats;
 	for (i = 0;
-	     i < offsetof(struct bfi_ll_stats, rxf_stats[0]) / sizeof(u64);
+	     i < offsetof(struct bfi_enet_stats, rxf_stats[0]) /
+		sizeof(u64);
 	     i++)
 		buf[bi++] = stats64[i];
 
 	/* Fill txf stats into ethtool buffers */
-	bmap = (u64)bnad->bna.tx_mod.txf_bmap[0] |
-			((u64)bnad->bna.tx_mod.txf_bmap[1] << 32);
-	for (i = 0; bmap && (i < BFI_LL_TXF_ID_MAX); i++) {
+	bmap = bna_tx_rid_mask(&bnad->bna);
+	for (i = 0; bmap; i++) {
 		if (bmap & 1) {
 			stats64 = (u64 *)&bnad->stats.bna_stats->
-						hw_stats->txf_stats[i];
-			for (j = 0; j < sizeof(struct bfi_ll_stats_txf) /
+						hw_stats.txf_stats[i];
+			for (j = 0; j < sizeof(struct bfi_enet_stats_txf) /
 					sizeof(u64); j++)
 				buf[bi++] = stats64[j];
 		}
@@ -1156,13 +835,12 @@ bnad_get_ethtool_stats(struct net_device *netdev, struct ethtool_stats *stats,
 	}
 
 	/*  Fill rxf stats into ethtool buffers */
-	bmap = (u64)bnad->bna.rx_mod.rxf_bmap[0] |
-			((u64)bnad->bna.rx_mod.rxf_bmap[1] << 32);
-	for (i = 0; bmap && (i < BFI_LL_RXF_ID_MAX); i++) {
+	bmap = bna_rx_rid_mask(&bnad->bna);
+	for (i = 0; bmap; i++) {
 		if (bmap & 1) {
 			stats64 = (u64 *)&bnad->stats.bna_stats->
-						hw_stats->rxf_stats[i];
-			for (j = 0; j < sizeof(struct bfi_ll_stats_rxf) /
+						hw_stats.rxf_stats[i];
+			for (j = 0; j < sizeof(struct bfi_enet_stats_rxf) /
 					sizeof(u64); j++)
 				buf[bi++] = stats64[j];
 		}
@@ -1192,8 +870,6 @@ static struct ethtool_ops bnad_ethtool_ops = {
 	.get_settings = bnad_get_settings,
 	.set_settings = bnad_set_settings,
 	.get_drvinfo = bnad_get_drvinfo,
-	.get_regs_len = bnad_get_regs_len,
-	.get_regs = bnad_get_regs,
 	.get_wol = bnad_get_wol,
 	.get_link = ethtool_op_get_link,
 	.get_coalesce = bnad_get_coalesce,
diff --git a/drivers/net/bna/cna.h b/drivers/net/bna/cna.h
index a679e03..50fce15 100644
--- a/drivers/net/bna/cna.h
+++ b/drivers/net/bna/cna.h
@@ -40,7 +40,7 @@
 
 extern char bfa_version[];
 
-#define	CNA_FW_FILE_CT	"ctfw_cna.bin"
+#define	CNA_FW_FILE_CT	"ctfw.bin"
 #define FC_SYMNAME_MAX	256	/*!< max name server symbolic name size */
 
 #pragma pack(1)
@@ -77,4 +77,33 @@ typedef struct mac { u8 mac[MAC_ADDRLEN]; } mac_t;
 	}								\
 }
 
+/*
+ * bfa_q_deq_tail - dequeue an element from tail of the queue
+ */
+#define bfa_q_deq_tail(_q, _qe) {					\
+	if (!list_empty(_q)) {						\
+		*((struct list_head **) (_qe)) = bfa_q_prev(_q);	\
+		bfa_q_next(bfa_q_prev(*((struct list_head **) _qe))) =  \
+						(struct list_head *) (_q); \
+		bfa_q_prev(_q) = bfa_q_prev(*(struct list_head **) _qe);\
+		bfa_q_qe_init(*((struct list_head **) _qe));		\
+	} else {							\
+		*((struct list_head **) (_qe)) = (struct list_head *) NULL; \
+	}								\
+}
+
+/*
+ * bfa_add_tail_head - enqueue an element at the head of queue
+ */
+#define bfa_q_enq_head(_q, _qe) {					\
+	if (!(bfa_q_next(_qe) == NULL) && (bfa_q_prev(_qe) == NULL))	\
+		pr_err("Assertion failure: %s:%d: %d",			\
+			__FILE__, __LINE__,				\
+		(bfa_q_next(_qe) == NULL) && (bfa_q_prev(_qe) == NULL));\
+	bfa_q_next(_qe) = bfa_q_next(_q);				\
+	bfa_q_prev(_qe) = (struct list_head *) (_q);			\
+	bfa_q_prev(bfa_q_next(_q)) = (struct list_head *) (_qe);	\
+	bfa_q_next(_q) = (struct list_head *) (_qe);			\
+}
+
 #endif /* __CNA_H__ */
diff --git a/include/linux/pci_ids.h b/include/linux/pci_ids.h
index 0570930..09afeab 100644
--- a/include/linux/pci_ids.h
+++ b/include/linux/pci_ids.h
@@ -2223,6 +2223,7 @@
 #define PCI_DEVICE_ID_BROCADE_CT	0x0014
 #define PCI_DEVICE_ID_BROCADE_FC_8G1P	0x0017
 #define PCI_DEVICE_ID_BROCADE_CT_FC	0x0021
+#define PCI_DEVICE_ID_BROCADE_CT	0x0022
 
 #define PCI_VENDOR_ID_SIBYTE		0x166d
 #define PCI_DEVICE_ID_BCM1250_PCI	0x0001
-- 
1.7.1

