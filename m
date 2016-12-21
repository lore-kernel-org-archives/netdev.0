From: Satha Koteswara Rao <satha.rao@caviumnetworks.com>
Subject: [RFC PATCH 1/7] PF driver modified to enable HW filter support,
 changes works in backward compatibility mode Enable required things
 in Makefile Enable LZ4 dependecy inside config file
Date: Wed, 21 Dec 2016 14:16:45 +0530
Message-ID: <1482310011-1862-2-git-send-email-satha.rao@caviumnetworks.com>
References: <1482310011-1862-1-git-send-email-satha.rao@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: rvatsavayi@caviumnetworks.com, rric@kernel.org, david.daney@cavium.com,
 netdev@vger.kernel.org, satha.rao@caviumnetworks.com,
 derek.chickles@caviumnetworks.com, sgoutham@cavium.com, davem@davemloft.net,
 linux-arm-kernel@lists.infradead.org, philip.romanov@cavium.com
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1482310011-1862-1-git-send-email-satha.rao@caviumnetworks.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

---
 drivers/net/ethernet/cavium/Kconfig            |   1 +
 drivers/net/ethernet/cavium/thunder/Makefile   |   2 +-
 drivers/net/ethernet/cavium/thunder/nic.h      | 203 ++++---
 drivers/net/ethernet/cavium/thunder/nic_main.c | 735 ++++++++++++++++++++++---
 4 files changed, 804 insertions(+), 137 deletions(-)

diff --git a/drivers/net/ethernet/cavium/Kconfig b/drivers/net/ethernet/cavium/Kconfig
index 92f411c..e4855a0 100644
--- a/drivers/net/ethernet/cavium/Kconfig
+++ b/drivers/net/ethernet/cavium/Kconfig
@@ -17,6 +17,7 @@ config THUNDER_NIC_PF
 	tristate "Thunder Physical function driver"
 	depends on 64BIT
 	select THUNDER_NIC_BGX
+        select CRYPTO_LZ4
 	---help---
 	  This driver supports Thunder's NIC physical function.
 	  The NIC provides the controller and DMA engines to
diff --git a/drivers/net/ethernet/cavium/thunder/Makefile b/drivers/net/ethernet/cavium/thunder/Makefile
index 6b4d4ad..30e4417 100644
--- a/drivers/net/ethernet/cavium/thunder/Makefile
+++ b/drivers/net/ethernet/cavium/thunder/Makefile
@@ -7,6 +7,6 @@ obj-$(CONFIG_THUNDER_NIC_BGX) += thunder_bgx.o
 obj-$(CONFIG_THUNDER_NIC_PF) += nicpf.o
 obj-$(CONFIG_THUNDER_NIC_VF) += nicvf.o
 
-nicpf-y := nic_main.o
+nicpf-y := pf_vf.o pf_reg.o pf_filter.o tbl_access.o nic_main.o
 nicvf-y := nicvf_main.o nicvf_queues.o
 nicvf-y += nicvf_ethtool.o
diff --git a/drivers/net/ethernet/cavium/thunder/nic.h b/drivers/net/ethernet/cavium/thunder/nic.h
index 86bd93c..17a29e7 100644
--- a/drivers/net/ethernet/cavium/thunder/nic.h
+++ b/drivers/net/ethernet/cavium/thunder/nic.h
@@ -54,6 +54,7 @@
 
 /* Max when CPI_ALG is IP diffserv */
 #define	NIC_MAX_CPI_PER_LMAC		64
+#define NIC_TNS_CPI_PER_LMAC		16
 
 /* NIC VF Interrupts */
 #define	NICVF_INTR_CQ			0
@@ -111,6 +112,7 @@
  * 1 tick per 0.025usec
  */
 #define NICPF_CLK_PER_INT_TICK		1
+#define NICPF_TNS_CLK_PER_INT_TICK	2
 
 /* Time to wait before we decide that a SQ is stuck.
  *
@@ -129,6 +131,7 @@ struct nicvf_cq_poll {
 
 #define NIC_MAX_RSS_HASH_BITS		8
 #define NIC_MAX_RSS_IDR_TBL_SIZE	(1 << NIC_MAX_RSS_HASH_BITS)
+#define NIC_TNS_RSS_IDR_TBL_SIZE	5
 #define RSS_HASH_KEY_SIZE		5 /* 320 bit key */
 
 struct nicvf_rss_info {
@@ -255,74 +258,6 @@ struct nicvf_drv_stats {
 	struct u64_stats_sync   syncp;
 };
 
-struct nicvf {
-	struct nicvf		*pnicvf;
-	struct net_device	*netdev;
-	struct pci_dev		*pdev;
-	void __iomem		*reg_base;
-#define	MAX_QUEUES_PER_QSET			8
-	struct queue_set	*qs;
-	struct nicvf_cq_poll	*napi[8];
-	u8			vf_id;
-	u8			sqs_id;
-	bool                    sqs_mode;
-	bool			hw_tso;
-	bool			t88;
-
-	/* Receive buffer alloc */
-	u32			rb_page_offset;
-	u16			rb_pageref;
-	bool			rb_alloc_fail;
-	bool			rb_work_scheduled;
-	struct page		*rb_page;
-	struct delayed_work	rbdr_work;
-	struct tasklet_struct	rbdr_task;
-
-	/* Secondary Qset */
-	u8			sqs_count;
-#define	MAX_SQS_PER_VF_SINGLE_NODE		5
-#define	MAX_SQS_PER_VF				11
-	struct nicvf		*snicvf[MAX_SQS_PER_VF];
-
-	/* Queue count */
-	u8			rx_queues;
-	u8			tx_queues;
-	u8			max_queues;
-
-	u8			node;
-	u8			cpi_alg;
-	bool			link_up;
-	u8			duplex;
-	u32			speed;
-	bool			tns_mode;
-	bool			loopback_supported;
-	struct nicvf_rss_info	rss_info;
-	struct tasklet_struct	qs_err_task;
-	struct work_struct	reset_task;
-
-	/* Interrupt coalescing settings */
-	u32			cq_coalesce_usecs;
-	u32			msg_enable;
-
-	/* Stats */
-	struct nicvf_hw_stats   hw_stats;
-	struct nicvf_drv_stats  __percpu *drv_stats;
-	struct bgx_stats	bgx_stats;
-
-	/* MSI-X  */
-	bool			msix_enabled;
-	u8			num_vec;
-	struct msix_entry	msix_entries[NIC_VF_MSIX_VECTORS];
-	char			irq_name[NIC_VF_MSIX_VECTORS][IFNAMSIZ + 15];
-	bool			irq_allocated[NIC_VF_MSIX_VECTORS];
-	cpumask_var_t		affinity_mask[NIC_VF_MSIX_VECTORS];
-
-	/* VF <-> PF mailbox communication */
-	bool			pf_acked;
-	bool			pf_nacked;
-	bool			set_mac_pending;
-} ____cacheline_aligned_in_smp;
-
 /* PF <--> VF Mailbox communication
  * Eight 64bit registers are shared between PF and VF.
  * Separate set for each VF.
@@ -357,6 +292,18 @@ struct nicvf {
 #define	NIC_MBOX_MSG_SNICVF_PTR		0x15	/* Send sqet nicvf ptr to PVF */
 #define	NIC_MBOX_MSG_LOOPBACK		0x16	/* Set interface in loopback */
 #define	NIC_MBOX_MSG_RESET_STAT_COUNTER 0x17	/* Reset statistics counters */
+/* Communicate regarding the added/deleted unicast/multicase address */
+#define NIC_MBOX_MSG_UC_MC              0x18
+/* Communicate regarding the setting of Promisc mode */
+#define NIC_MBOX_MSG_PROMISC		0x19
+/* Communicate with vf regarding admin vlan */
+#define NIC_MBOX_MSG_ADMIN_VLAN         0x20
+/* Communicate regarding the added/deleted VLAN */
+#define NIC_MBOX_MSG_VLAN               0x21
+/* Communicate to Pf that the VF carrier and tx queue are turned on */
+#define NIC_MBOX_MSG_OP_UP		0x22
+/* Communicate to Pf that the VF carrier and tx queue are turned off */
+#define NIC_MBOX_MSG_OP_DOWN		0x23
 #define	NIC_MBOX_MSG_CFG_DONE		0xF0	/* VF configuration done */
 #define	NIC_MBOX_MSG_SHUTDOWN		0xF1	/* VF is being shutdown */
 
@@ -367,6 +314,29 @@ struct nic_cfg_msg {
 	u8    tns_mode:1;
 	u8    sqs_mode:1;
 	u8    loopback_supported:1;
+	u8    pf_up:1;
+	bool  is_pf;
+	bool  veb_enabled;
+	bool  bgx_id;
+	u8    lmac;
+	u8    chan;
+	u8    mac_addr[ETH_ALEN];
+};
+
+/* VLAN INFO */
+struct vlan_msg {
+	u8 msg;
+	u8 vf_id;
+	bool vlan_add:1;
+	u16 vlan_id;
+};
+
+struct uc_mc_msg {
+	u8 msg;
+	u8 vf_id;
+	uint64_t addr_type:1;
+	uint64_t is_flush:1;
+	uint64_t is_add:1;
 	u8    mac_addr[ETH_ALEN];
 };
 
@@ -446,6 +416,7 @@ struct bgx_stats_msg {
 /* Physical interface link status */
 struct bgx_link_status {
 	u8    msg;
+	u8    lmac;
 	u8    link_up;
 	u8    duplex;
 	u32   speed;
@@ -498,9 +469,18 @@ struct reset_stat_cfg {
 	u16   sq_stat_mask;
 };
 
+struct promisc_info {
+	u8    msg;
+	u8    vf_id;
+	bool  on;
+};
+
 /* 128 bit shared memory between PF and each VF */
 union nic_mbx {
 	struct { u8 msg; }	msg;
+	struct promisc_info     promisc_cfg;
+	struct vlan_msg		vlan_cfg;
+	struct uc_mc_msg	uc_mc_cfg;
 	struct nic_cfg_msg	nic_cfg;
 	struct qs_cfg_msg	qs;
 	struct rq_cfg_msg	rq;
@@ -518,6 +498,93 @@ struct reset_stat_cfg {
 	struct reset_stat_cfg	reset_stat;
 };
 
+struct nicvf {
+	struct nicvf		*pnicvf;
+	struct net_device	*netdev;
+	struct pci_dev		*pdev;
+	void __iomem		*reg_base;
+#define	MAX_QUEUES_PER_QSET			8
+	struct queue_set	*qs;
+	struct nicvf_cq_poll	*napi[8];
+	u8			vf_id;
+	u8			sqs_id;
+	bool                    sqs_mode;
+	bool			hw_tso;
+	bool			t88;
+
+	/* Receive buffer alloc */
+	u32			rb_page_offset;
+	u16			rb_pageref;
+	bool			rb_alloc_fail;
+	bool			rb_work_scheduled;
+	struct page		*rb_page;
+	struct delayed_work	rbdr_work;
+	struct tasklet_struct	rbdr_task;
+
+	/* Secondary Qset */
+	u8			sqs_count;
+#define	MAX_SQS_PER_VF_SINGLE_NODE		5
+#define	MAX_SQS_PER_VF				11
+	struct nicvf		*snicvf[MAX_SQS_PER_VF];
+
+	/* Queue count */
+	u8			rx_queues;
+	u8			tx_queues;
+	u8			max_queues;
+
+	u8			node;
+	u8			cpi_alg;
+	u16			mtu;
+	bool			link_up;
+	u8			duplex;
+	u32			speed;
+	bool			tns_mode;
+	bool			loopback_supported;
+	/* In VEB mode, true_vf directely attached to physical port,
+	 * it acts as PF in this VF group (set of VF's attached to same
+	 * physical port).
+	 */
+	bool			true_vf;
+	struct nicvf_rss_info	rss_info;
+	struct tasklet_struct	qs_err_task;
+	struct work_struct	reset_task;
+
+	/* Interrupt coalescing settings */
+	u32			cq_coalesce_usecs;
+	u32			msg_enable;
+
+	/* Stats */
+	struct nicvf_hw_stats   hw_stats;
+	struct nicvf_drv_stats  __percpu *drv_stats;
+	struct bgx_stats	bgx_stats;
+
+	/* MSI-X  */
+	bool			msix_enabled;
+	u8			num_vec;
+	struct msix_entry	msix_entries[NIC_VF_MSIX_VECTORS];
+	char			irq_name[NIC_VF_MSIX_VECTORS][IFNAMSIZ + 15];
+	bool			irq_allocated[NIC_VF_MSIX_VECTORS];
+	cpumask_var_t		affinity_mask[NIC_VF_MSIX_VECTORS];
+
+	char			phys_port_name[IFNAMSIZ + 15];
+	/* VF <-> PF mailbox communication */
+	bool			pf_acked;
+	bool			pf_nacked;
+	bool			set_mac_pending;
+	struct netdev_hw_addr_list uc_shadow;
+	struct netdev_hw_addr_list mc_shadow;
+
+	/* work queue for handling UC MC mailbox messages */
+	bool			send_op_link_status;
+	struct delayed_work	dwork;
+	struct workqueue_struct *uc_mc_msg;
+
+	/* Admin vlan id */
+	int			admin_vlan_id;
+	bool			pf_ack_waiting;
+	bool			wait_for_ack;
+} ____cacheline_aligned_in_smp;
+
 #define NIC_NODE_ID_MASK	0x03
 #define NIC_NODE_ID_SHIFT	44
 
diff --git a/drivers/net/ethernet/cavium/thunder/nic_main.c b/drivers/net/ethernet/cavium/thunder/nic_main.c
index 6677b96..42299320 100644
--- a/drivers/net/ethernet/cavium/thunder/nic_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nic_main.c
@@ -17,6 +17,7 @@
 #include "nic.h"
 #include "q_struct.h"
 #include "thunder_bgx.h"
+#include "pf_globals.h"
 
 #define DRV_NAME	"thunder-nic"
 #define DRV_VERSION	"1.0"
@@ -70,7 +71,52 @@ struct nicpf {
 	struct msix_entry	*msix_entries;
 	bool			irq_allocated[NIC_PF_MSIX_VECTORS];
 	char			irq_name[NIC_PF_MSIX_VECTORS][20];
-};
+	bool			vf_op_enabled[MAX_NUM_VFS_SUPPORTED];
+	bool			admin_vlan[MAX_NUM_VFS_SUPPORTED];
+	u8			vnic_intf_map[MAX_NUM_VFS_SUPPORTED];
+	u64			mac[MAX_NUM_VFS_SUPPORTED];
+	struct delayed_work	notification_dwork;
+	struct workqueue_struct *notification_msg;
+
+#define MAX_VF_MBOX_MESSAGE	(2 * MAX_NUM_VFS_SUPPORTED)
+	union nic_mbx		vf_mbx_msg[MAX_VF_MBOX_MESSAGE];
+	bool			valid_vf_mbx_msg[MAX_VF_MBOX_MESSAGE];
+	/* Protect different notification messages */
+	spinlock_t		vf_mbx_msg_lock;
+} ____cacheline_aligned_in_smp;
+
+static unsigned int num_vfs;
+module_param(num_vfs, uint, 0644);
+MODULE_PARM_DESC(num_vfs, "Non zero positive value, specifies number of VF's per physical port");
+
+static u8 link_lmac[MAX_NUMNODES][TNS_MAX_LMAC];
+static int pf_speed[MAX_NUMNODES][TNS_MAX_LMAC];
+static int pf_duplex[MAX_NUMNODES][TNS_MAX_LMAC];
+
+static void nic_send_msg_to_vf(struct nicpf *nic, int vf, union nic_mbx *mbx);
+static int veb_enabled;
+
+void send_link_change_to_vf(struct nicpf *nic, void *arg)
+{
+	int start_vf, end_vf;
+	int i;
+	union nic_mbx *mbx = (union nic_mbx *)arg;
+
+	get_vf_group(nic->node, mbx->link_status.lmac, &start_vf, &end_vf);
+
+	for (i = start_vf; i <= end_vf; i++) {
+		union nic_mbx lmbx = {};
+
+		if (!nic->vf_enabled[i])
+			continue;
+		if (!nic->mbx_lock[i])
+			nic_send_msg_to_vf(nic, i, mbx);
+		lmbx.mac.vf_id = i;
+		lmbx.msg.msg = mbx->link_status.link_up ? NIC_MBOX_MSG_OP_UP :
+							 NIC_MBOX_MSG_OP_DOWN;
+		pf_notify_msg_handler(nic->node, (void *)(&lmbx));
+	}
+}
 
 /* Supported devices */
 static const struct pci_device_id nic_id_table[] = {
@@ -135,6 +181,53 @@ static u64 nic_get_mbx_addr(int vf)
 	return NIC_PF_VF_0_127_MAILBOX_0_1 + (vf << NIC_VF_NUM_SHIFT);
 }
 
+/* Set RBDR Backpressure (RBDR_BP) and CQ backpressure (CQ_BP) of vnic queues
+ * to 129 each
+ * @vf: vf to which bp needs to be set
+ * @rcv_id: receive queue of the vf
+ */
+void set_rbdr_cq_bp(struct nicpf *nic, u8 vf, u8 rcv_id)
+{
+	union nic_pf_qsx_rqx_bp_cfg bp_info;
+	u64 offset = 0;
+
+	offset = (vf & 127) * 0x200000ull + (rcv_id & 7) * 0x40000ull;
+	bp_info.u = nic_reg_read(nic,  NIC_PF_QSX_RQX_BP_CFG + offset);
+	bp_info.s.rbdr_bp = RBDR_CQ_BP;
+	bp_info.s.cq_bp = RBDR_CQ_BP;
+	nic_reg_write(nic, NIC_PF_QSX_RQX_BP_CFG + offset, bp_info.u);
+}
+
+/* Set backpressure configuratin  on the NIC TNS receive interface
+ * @intf: NIC interface
+ * @tns_mode: if the NIC is in  TNS/BY-PASS mode
+ */
+void set_bp_id(struct nicpf *nic, u8 intf, u8 tns_mode)
+{
+	union nic_pf_intfx_bp_cfg bp_conf;
+	u8 offset = (intf & 1) * 0x100ull;
+
+	bp_conf.u = nic_reg_read(nic, NIC_PF_INTFX_BP_CFG + offset);
+	bp_conf.s.bp_id = (intf) ? ((tns_mode) ? 0x7 : 0x9) :
+					((tns_mode) ? 0x6 : 0x8);
+	nic_reg_write(nic,  NIC_PF_INTFX_BP_CFG + offset, bp_conf.u);
+}
+
+/* enable the BP bus for this interface
+ * @intf: NIC interface
+ */
+void bp_enable(struct nicpf *nic, u8 intf)
+{
+	union nic_pf_intfx_bp_cfg bp_conf;
+	u8 offset = (intf & 1) * 0x100ull;
+
+	bp_conf.u = nic_reg_read(nic, NIC_PF_INTFX_BP_CFG + offset);
+	if (!bp_conf.s.bp_ena)
+		bp_conf.s.bp_ena = 1;
+
+	nic_reg_write(nic, NIC_PF_INTFX_BP_CFG + offset, bp_conf.u);
+}
+
 /* Send a mailbox message to VF
  * @vf: vf to which this message to be sent
  * @mbx: Message to be sent
@@ -169,24 +262,53 @@ static void nic_mbx_send_ready(struct nicpf *nic, int vf)
 	union nic_mbx mbx = {};
 	int bgx_idx, lmac;
 	const char *mac;
+	int nid = nic->node;
 
 	mbx.nic_cfg.msg = NIC_MBOX_MSG_READY;
 	mbx.nic_cfg.vf_id = vf;
 
-	mbx.nic_cfg.tns_mode = NIC_TNS_BYPASS_MODE;
+	if (veb_enabled)
+		mbx.nic_cfg.tns_mode = NIC_TNS_MODE;
+	else
+		mbx.nic_cfg.tns_mode = NIC_TNS_BYPASS_MODE;
 
-	if (vf < nic->num_vf_en) {
+	if (!veb_enabled && vf < nic->num_vf_en) {
 		bgx_idx = NIC_GET_BGX_FROM_VF_LMAC_MAP(nic->vf_lmac_map[vf]);
 		lmac = NIC_GET_LMAC_FROM_VF_LMAC_MAP(nic->vf_lmac_map[vf]);
 
-		mac = bgx_get_lmac_mac(nic->node, bgx_idx, lmac);
+		mac = bgx_get_lmac_mac(nid, bgx_idx, lmac);
 		if (mac)
 			ether_addr_copy((u8 *)&mbx.nic_cfg.mac_addr, mac);
+	} else if (veb_enabled) {
+		int lmac = 0, bgx_idx = 0;
+
+		if (get_bgx_id(nid, vf, &bgx_idx, &lmac))
+			dev_err(&nic->pdev->dev, "!!ERROR!!Wrong BGX values\n");
+
+		if (is_pf(nid, vf)) {
+			mac = bgx_get_lmac_mac(nid, bgx_idx, lmac);
+			if (mac)
+				ether_addr_copy((u8 *)&nic->mac[vf], mac);
+		} else if (is_zero_ether_addr((u8 *)&nic->mac[vf])) {
+			eth_random_addr((u8 *)&nic->mac[vf]);
+		}
+
+		ether_addr_copy((u8 *)&mbx.nic_cfg.mac_addr,
+				(u8 *)&nic->mac[vf]);
+		mbx.nic_cfg.is_pf = is_pf(nid, vf);
+		mbx.nic_cfg.lmac = lmac;
+		mbx.nic_cfg.bgx_id = bgx_idx;
+		mbx.nic_cfg.chan = (vf < 64) ? vf : (64 + vf);
 	}
-	mbx.nic_cfg.sqs_mode = (vf >= nic->num_vf_en) ? true : false;
-	mbx.nic_cfg.node_id = nic->node;
+	mbx.nic_cfg.veb_enabled = (veb_enabled == 0) ? 0 : 1;
+	mbx.nic_cfg.node_id = nid;
 
-	mbx.nic_cfg.loopback_supported = vf < nic->num_vf_en;
+	if (veb_enabled) {
+		mbx.nic_cfg.pf_up = link_lmac[nid][vf_to_pport(nid, vf)];
+	} else {
+		mbx.nic_cfg.loopback_supported = vf < nic->num_vf_en;
+		mbx.nic_cfg.sqs_mode = (vf >= nic->num_vf_en) ? true : false;
+	}
 
 	nic_send_msg_to_vf(nic, vf, &mbx);
 }
@@ -242,8 +364,15 @@ static void nic_get_bgx_stats(struct nicpf *nic, struct bgx_stats_msg *bgx)
 	int bgx_idx, lmac;
 	union nic_mbx mbx = {};
 
-	bgx_idx = NIC_GET_BGX_FROM_VF_LMAC_MAP(nic->vf_lmac_map[bgx->vf_id]);
-	lmac = NIC_GET_LMAC_FROM_VF_LMAC_MAP(nic->vf_lmac_map[bgx->vf_id]);
+	if (veb_enabled) {
+		if (get_bgx_id(nic->node, bgx->vf_id, &bgx_idx, &lmac))
+			dev_err(&nic->pdev->dev, "Unable to get BGX index\n");
+	} else {
+		bgx_idx = NIC_GET_BGX_FROM_VF_LMAC_MAP(
+				nic->vf_lmac_map[bgx->vf_id]);
+		lmac = NIC_GET_LMAC_FROM_VF_LMAC_MAP(
+				nic->vf_lmac_map[bgx->vf_id]);
+	}
 
 	mbx.bgx_stats.msg = NIC_MBOX_MSG_BGX_STATS;
 	mbx.bgx_stats.vf_id = bgx->vf_id;
@@ -267,6 +396,16 @@ static int nic_update_hw_frs(struct nicpf *nic, int new_frs, int vf)
 	if ((new_frs > NIC_HW_MAX_FRS) || (new_frs < NIC_HW_MIN_FRS))
 		return 1;
 
+	if (veb_enabled) {
+		new_frs += ETH_HLEN;
+		if (new_frs <= nic->pkind.maxlen)
+			return 0;
+
+		nic->pkind.maxlen = new_frs;
+		nic_reg_write(nic, NIC_PF_PKIND_0_15_CFG, *(u64 *)&nic->pkind);
+		return 0;
+	}
+
 	bgx = NIC_GET_BGX_FROM_VF_LMAC_MAP(nic->vf_lmac_map[vf]);
 	lmac = NIC_GET_LMAC_FROM_VF_LMAC_MAP(nic->vf_lmac_map[vf]);
 	lmac += bgx * MAX_LMAC_PER_BGX;
@@ -302,8 +441,14 @@ static void nic_set_tx_pkt_pad(struct nicpf *nic, int size)
 	 * Hence set this value to lessthan min pkt size of MAC+IP+TCP
 	 * headers, BGX will do the padding to transmit 64 byte pkt.
 	 */
-	if (size > 52)
-		size = 52;
+	if (size > 52) {
+		if (veb_enabled) {
+			if (size > 60)
+				size = 60;
+		} else {
+			size = 52;
+		}
+	}
 
 	pci_read_config_word(nic->pdev, PCI_SUBSYSTEM_ID, &sdevid);
 	/* 81xx's RGX has only one LMAC */
@@ -331,6 +476,10 @@ static void nic_set_lmac_vf_mapping(struct nicpf *nic)
 	u64 lmac_credit;
 
 	nic->num_vf_en = 0;
+	if (veb_enabled) {
+		nic->num_vf_en = PF_END;
+		return;
+	}
 
 	for (bgx = 0; bgx < nic->hw->bgx_cnt; bgx++) {
 		if (!(bgx_map & (1 << bgx)))
@@ -386,7 +535,8 @@ static int nic_get_hw_info(struct nicpf *nic)
 		hw->chans_per_bgx = 128;
 		hw->cpi_cnt = 2048;
 		hw->rssi_cnt = 4096;
-		hw->rss_ind_tbl_size = NIC_MAX_RSS_IDR_TBL_SIZE;
+		hw->rss_ind_tbl_size = veb_enabled ? NIC_TNS_RSS_IDR_TBL_SIZE :
+						     NIC_MAX_RSS_IDR_TBL_SIZE;
 		hw->tl3_cnt = 256;
 		hw->tl2_cnt = 64;
 		hw->tl1_cnt = 2;
@@ -451,6 +601,9 @@ static int nic_init_hw(struct nicpf *nic)
 	int i, err;
 	u64 cqm_cfg;
 
+	/* Reset NIC, in case the driver is repeatedly inserted and removed */
+	nic_reg_write(nic, NIC_PF_SOFT_RESET, 1);
+
 	/* Get HW capability info */
 	err = nic_get_hw_info(nic);
 	if (err)
@@ -462,23 +615,36 @@ static int nic_init_hw(struct nicpf *nic)
 	/* Enable backpressure */
 	nic_reg_write(nic, NIC_PF_BP_CFG, (1ULL << 6) | 0x03);
 
-	/* TNS and TNS bypass modes are present only on 88xx */
-	if (nic->pdev->subsystem_device == PCI_SUBSYS_DEVID_88XX_NIC_PF) {
-		/* Disable TNS mode on both interfaces */
+	if (veb_enabled) {
 		nic_reg_write(nic, NIC_PF_INTF_0_1_SEND_CFG,
-			      (NIC_TNS_BYPASS_MODE << 7) | BGX0_BLOCK);
+			      (NIC_TNS_MODE << 7) | (0x03ULL << 4) | 0x06);
 		nic_reg_write(nic, NIC_PF_INTF_0_1_SEND_CFG | (1 << 8),
-			      (NIC_TNS_BYPASS_MODE << 7) | BGX1_BLOCK);
+			      (NIC_TNS_MODE << 7) | (0x03ULL << 4) | 0x07);
+		nic_reg_write(nic, NIC_PF_INTF_0_1_BP_CFG,
+			      (1ULL << 63) | (1ULL << 4) | 0x09);
+		nic_reg_write(nic, NIC_PF_INTF_0_1_BP_CFG + (1 << 8),
+			      (1ULL << 63) | (1ULL << 4) | 0x09);
+	} else {
+		/* TNS and TNS bypass modes are present only on 88xx */
+		if (nic->pdev->subsystem_device ==
+		    PCI_SUBSYS_DEVID_88XX_NIC_PF) {
+			/* Disable TNS mode on both interfaces */
+			nic_reg_write(nic, NIC_PF_INTF_0_1_SEND_CFG,
+				      (NIC_TNS_BYPASS_MODE << 7) | BGX0_BLOCK);
+			nic_reg_write(nic, NIC_PF_INTF_0_1_SEND_CFG | (1 << 8),
+				      (NIC_TNS_BYPASS_MODE << 7) | BGX1_BLOCK);
+		}
+		nic_reg_write(nic, NIC_PF_INTF_0_1_BP_CFG,
+			      (1ULL << 63) | BGX0_BLOCK);
+		nic_reg_write(nic, NIC_PF_INTF_0_1_BP_CFG + (1 << 8),
+			      (1ULL << 63) | BGX1_BLOCK);
 	}
 
-	nic_reg_write(nic, NIC_PF_INTF_0_1_BP_CFG,
-		      (1ULL << 63) | BGX0_BLOCK);
-	nic_reg_write(nic, NIC_PF_INTF_0_1_BP_CFG + (1 << 8),
-		      (1ULL << 63) | BGX1_BLOCK);
-
 	/* PKIND configuration */
 	nic->pkind.minlen = 0;
-	nic->pkind.maxlen = NIC_HW_MAX_FRS + VLAN_ETH_HLEN + ETH_FCS_LEN + 4;
+	nic->pkind.maxlen = NIC_HW_MAX_FRS + ETH_HLEN;
+	if (!veb_enabled)
+		nic->pkind.maxlen += VLAN_HLEN + ETH_FCS_LEN + 4;
 	nic->pkind.lenerr_en = 1;
 	nic->pkind.rx_hdr = 0;
 	nic->pkind.hdr_sl = 0;
@@ -508,7 +674,7 @@ static int nic_init_hw(struct nicpf *nic)
 static void nic_config_cpi(struct nicpf *nic, struct cpi_cfg_msg *cfg)
 {
 	struct hw_info *hw = nic->hw;
-	u32 vnic, bgx, lmac, chan;
+	u32 vnic, bgx, lmac, chan = 0;
 	u32 padd, cpi_count = 0;
 	u64 cpi_base, cpi, rssi_base, rssi;
 	u8  qset, rq_idx = 0;
@@ -517,8 +683,17 @@ static void nic_config_cpi(struct nicpf *nic, struct cpi_cfg_msg *cfg)
 	bgx = NIC_GET_BGX_FROM_VF_LMAC_MAP(nic->vf_lmac_map[vnic]);
 	lmac = NIC_GET_LMAC_FROM_VF_LMAC_MAP(nic->vf_lmac_map[vnic]);
 
-	chan = (lmac * hw->chans_per_lmac) + (bgx * hw->chans_per_bgx);
-	cpi_base = vnic * NIC_MAX_CPI_PER_LMAC;
+	if (veb_enabled) {
+		if (nic->vnic_intf_map[vnic] == 0)
+			chan = vnic;
+		else if (nic->vnic_intf_map[vnic] == 1)
+			chan = 128 + (vnic - 64);
+		cpi_base = vnic * NIC_TNS_CPI_PER_LMAC;
+	} else {
+		chan = (lmac * hw->chans_per_lmac) +
+			(bgx * hw->chans_per_bgx);
+		cpi_base = vnic * NIC_MAX_CPI_PER_LMAC;
+	}
 	rssi_base = vnic * hw->rss_ind_tbl_size;
 
 	/* Rx channel configuration */
@@ -534,7 +709,8 @@ static void nic_config_cpi(struct nicpf *nic, struct cpi_cfg_msg *cfg)
 	else if (cfg->cpi_alg == CPI_ALG_VLAN16) /* 3 bits PCP + DEI */
 		cpi_count = 16;
 	else if (cfg->cpi_alg == CPI_ALG_DIFF) /* 6bits DSCP */
-		cpi_count = NIC_MAX_CPI_PER_LMAC;
+		cpi_count = veb_enabled ? NIC_TNS_CPI_PER_LMAC :
+					  NIC_MAX_CPI_PER_LMAC;
 
 	/* RSS Qset, Qidx mapping */
 	qset = cfg->vf_id;
@@ -542,6 +718,8 @@ static void nic_config_cpi(struct nicpf *nic, struct cpi_cfg_msg *cfg)
 	for (; rssi < (rssi_base + cfg->rq_cnt); rssi++) {
 		nic_reg_write(nic, NIC_PF_RSSI_0_4097_RQ | (rssi << 3),
 			      (qset << 3) | rq_idx);
+		if (veb_enabled)
+			set_rbdr_cq_bp(nic, vnic, rq_idx);
 		rq_idx++;
 	}
 
@@ -652,8 +830,8 @@ static void nic_tx_channel_cfg(struct nicpf *nic, u8 vnic,
 			       struct sq_cfg_msg *sq)
 {
 	struct hw_info *hw = nic->hw;
-	u32 bgx, lmac, chan;
-	u32 tl2, tl3, tl4;
+	u32 bgx, lmac, chan = 0;
+	u32 tl2, tl3, tl4 = 0;
 	u32 rr_quantum;
 	u8 sq_idx = sq->sq_num;
 	u8 pqs_vnic;
@@ -670,10 +848,19 @@ static void nic_tx_channel_cfg(struct nicpf *nic, u8 vnic,
 	/* 24 bytes for FCS, IPG and preamble */
 	rr_quantum = ((NIC_HW_MAX_FRS + 24) / 4);
 
-	/* For 88xx 0-511 TL4 transmits via BGX0 and
-	 * 512-1023 TL4s transmit via BGX1.
-	 */
-	if (hw->tl1_per_bgx) {
+	if (veb_enabled) {
+		if (nic->vnic_intf_map[vnic] == 0) {
+			tl4 = (hw->tl4_cnt / hw->chans_per_bgx) * vnic;
+			chan = vnic;
+		} else if (nic->vnic_intf_map[vnic] == 1) {
+			tl4 = (hw->tl4_cnt / hw->bgx_cnt) +
+			      (hw->tl4_cnt / hw->chans_per_bgx) * (vnic - 64);
+			chan = 128 + (vnic - 64);
+		}
+	} else if (hw->tl1_per_bgx) {
+		/* For 88xx 0-511 TL4 transmits via BGX0 and
+		 * 512-1023 TL4s transmit via BGX1.
+		 */
 		tl4 = bgx * (hw->tl4_cnt / hw->bgx_cnt);
 		if (!sq->sqs_mode) {
 			tl4 += (lmac * MAX_QUEUES_PER_QSET);
@@ -686,8 +873,10 @@ static void nic_tx_channel_cfg(struct nicpf *nic, u8 vnic,
 			tl4 += (lmac * MAX_QUEUES_PER_QSET * MAX_SQS_PER_VF);
 			tl4 += (svf * MAX_QUEUES_PER_QSET);
 		}
+		chan = (lmac * hw->chans_per_lmac) + (bgx * hw->chans_per_bgx);
 	} else {
 		tl4 = (vnic * MAX_QUEUES_PER_QSET);
+		chan = (lmac * hw->chans_per_lmac) + (bgx * hw->chans_per_bgx);
 	}
 	tl4 += sq_idx;
 
@@ -706,7 +895,6 @@ static void nic_tx_channel_cfg(struct nicpf *nic, u8 vnic,
 	 * On 81xx/83xx TL3_CHAN reg should be configured with channel
 	 * within LMAC i.e 0-7 and not the actual channel number like on 88xx
 	 */
-	chan = (lmac * hw->chans_per_lmac) + (bgx * hw->chans_per_bgx);
 	if (hw->tl1_per_bgx)
 		nic_reg_write(nic, NIC_PF_TL3_0_255_CHAN | (tl3 << 3), chan);
 	else
@@ -874,6 +1062,30 @@ static void nic_enable_tunnel_parsing(struct nicpf *nic, int vf)
 		      ((0xfULL << 60) | vxlan_prot_def));
 }
 
+void send_notifications(struct work_struct *work)
+{
+	struct nicpf *nic;
+	int i;
+
+	nic = container_of(work, struct nicpf, notification_dwork.work);
+	spin_lock(&nic->vf_mbx_msg_lock);
+	for (i = 0; i < MAX_VF_MBOX_MESSAGE; i++) {
+		union nic_mbx *mbx = &nic->vf_mbx_msg[i];
+
+		if (!nic->valid_vf_mbx_msg[i])
+			continue;
+
+		spin_unlock(&nic->vf_mbx_msg_lock);
+		if (mbx->link_status.msg == NIC_MBOX_MSG_BGX_LINK_CHANGE)
+			send_link_change_to_vf(nic, (void *)mbx);
+		else
+			pf_notify_msg_handler(nic->node, (void *)mbx);
+		spin_lock(&nic->vf_mbx_msg_lock);
+		nic->valid_vf_mbx_msg[i] = false;
+	}
+	spin_unlock(&nic->vf_mbx_msg_lock);
+}
+
 static void nic_enable_vf(struct nicpf *nic, int vf, bool enable)
 {
 	int bgx, lmac;
@@ -889,6 +1101,187 @@ static void nic_enable_vf(struct nicpf *nic, int vf, bool enable)
 	bgx_lmac_rx_tx_enable(nic->node, bgx, lmac, enable);
 }
 
+static int nic_submit_msg_notification(struct nicpf *nic, int vf,
+				       union nic_mbx *mbx)
+{
+	int i, ret = 0;
+
+	if (!veb_enabled)
+		return ret;
+
+	/* PF<->VF Communication Work, and request Validation */
+	switch (mbx->msg.msg) {
+	case NIC_MBOX_MSG_VLAN:
+		if (mbx->vlan_cfg.vlan_add &&
+		    (tns_filter_valid_entry(nic->node, NIC_MBOX_MSG_VLAN, vf,
+						mbx->vlan_cfg.vlan_id) ||
+		     nic->admin_vlan[vf])) {
+			nic_mbx_send_nack(nic, vf);
+			return 1;
+		}
+		break;
+	case NIC_MBOX_MSG_ADMIN_VLAN:
+		if ((mbx->vlan_cfg.vlan_add &&
+		     (tns_filter_valid_entry(nic->node, NIC_MBOX_MSG_ADMIN_VLAN,
+						vf, mbx->vlan_cfg.vlan_id) ||
+		      nic->admin_vlan[mbx->vlan_cfg.vf_id])) ||
+		    (!is_pf(nic->node, vf) ||
+			(get_pf(nic->node, mbx->vlan_cfg.vf_id) != vf))) {
+			nic_mbx_send_nack(nic, vf);
+			return 1;
+		}
+		break;
+	case NIC_MBOX_MSG_UC_MC:
+		if (mbx->uc_mc_cfg.is_add &&
+		    tns_filter_valid_entry(nic->node, NIC_MBOX_MSG_UC_MC,
+					   vf, 0)) {
+			dev_err(&nic->pdev->dev, "MAC filter max reached\n");
+			nic_mbx_send_nack(nic, vf);
+			return 1;
+		}
+		break;
+	case NIC_MBOX_MSG_OP_UP:
+		if (!nic->vf_enabled[vf])
+			return 0;
+		break;
+	case NIC_MBOX_MSG_OP_DOWN:
+		if (!(nic->vf_enabled[vf] && nic->vf_op_enabled[vf]))
+			return 0;
+		break;
+	case NIC_MBOX_MSG_CFG_DONE:
+	{
+		int port = vf_to_pport(nic->node, vf);
+
+		/* Last message of VF config msg sequence */
+		nic->vf_enabled[vf] = true;
+		if (is_pf(nic->node, vf)) {
+			int bgx_id, lmac;
+
+			if (get_bgx_id(nic->node, vf, &bgx_id, &lmac))
+				dev_err(&nic->pdev->dev, "Unable to get BGX index\n");
+
+			/* ENABLE PAUSE FRAME GENERATION */
+			enable_pause_frames(nic->node, bgx_id, lmac);
+
+			bgx_lmac_rx_tx_enable(nic->node, bgx_id, lmac, true);
+		}
+		if (link_lmac[nic->node][port]) {
+			union nic_mbx mbx = {};
+
+			mbx.link_status.msg = NIC_MBOX_MSG_CFG_DONE;
+			mbx.link_status.link_up = 1;
+			mbx.link_status.duplex = pf_duplex[nic->node][port];
+			mbx.link_status.speed = pf_speed[nic->node][port];
+			nic_send_msg_to_vf(nic, vf, &mbx);
+		} else {
+			nic_mbx_send_ack(nic, vf);
+		}
+
+		if (is_pf(nic->node, vf) && link_lmac[nic->node][port]) {
+			mbx->link_status.msg = NIC_MBOX_MSG_BGX_LINK_CHANGE;
+			mbx->link_status.link_up = 1;
+			mbx->link_status.speed = pf_speed[nic->node][port];
+			mbx->link_status.duplex = pf_duplex[nic->node][port];
+			mbx->link_status.lmac = port;
+			break;
+		}
+		return 1;
+	}
+	}
+
+	spin_lock(&nic->vf_mbx_msg_lock);
+	for (i = 0; i < MAX_VF_MBOX_MESSAGE; i++)
+		if (!nic->valid_vf_mbx_msg[i])
+			break;
+	if (i == MAX_VF_MBOX_MESSAGE) {
+		spin_unlock(&nic->vf_mbx_msg_lock);
+		dev_err(&nic->pdev->dev, "Notification array full msg: %d\n",
+			mbx->msg.msg);
+		return -1;
+	}
+
+	memcpy(&nic->vf_mbx_msg[i], mbx, sizeof(union nic_mbx));
+
+	switch (mbx->msg.msg) {
+	case NIC_MBOX_MSG_READY:
+		nic->vf_mbx_msg[i].msg.msg = NIC_MBOX_MSG_SET_MAC;
+		ether_addr_copy((u8 *)&nic->vf_mbx_msg[i].mac.mac_addr,
+				(u8 *)&nic->mac[vf]);
+		/* fall-through */
+	case NIC_MBOX_MSG_SET_MAC:
+		nic->vf_mbx_msg[i].mac.vf_id = vf;
+		break;
+	case NIC_MBOX_MSG_ADMIN_VLAN:
+		nic_send_msg_to_vf(nic, mbx->vlan_cfg.vf_id, mbx);
+		nic->admin_vlan[mbx->vlan_cfg.vf_id] = mbx->vlan_cfg.vlan_add;
+		break;
+	case NIC_MBOX_MSG_PROMISC:
+		ret = 1;
+	case NIC_MBOX_MSG_VLAN:
+	case NIC_MBOX_MSG_UC_MC:
+		break;
+	case NIC_MBOX_MSG_OP_UP:
+		nic->vf_op_enabled[vf] = true;
+		nic->vf_mbx_msg[i].mac.vf_id = vf;
+		break;
+	case NIC_MBOX_MSG_OP_DOWN:
+		nic->vf_mbx_msg[i].mac.vf_id = vf;
+		nic->vf_op_enabled[vf] = false;
+		break;
+	case NIC_MBOX_MSG_SHUTDOWN:
+	{
+		int submit_work = 0;
+
+#ifdef VNIC_MULTI_QSET_SUPPORT
+		if (vf >= nic->num_vf_en)
+			nic->sqs_used[vf - nic->num_vf_en] = false;
+		nic->pqs_vf[vf] = 0;
+#endif
+		if (is_pf(nic->node, vf)) {
+			int bgx_idx, lmac_idx;
+
+			if (get_bgx_id(nic->node, vf, &bgx_idx, &lmac_idx))
+				dev_err(&nic->pdev->dev, "Unable to get BGX\n");
+
+			bgx_lmac_rx_tx_enable(nic->node, bgx_idx, lmac_idx,
+					      false);
+		}
+
+		if (is_pf(nic->node, vf) &&
+		    link_lmac[nic->node][vf_to_pport(nic->node, vf)]) {
+			union nic_mbx *lmbx = &nic->vf_mbx_msg[i + 1];
+
+			lmbx->link_status.msg = NIC_MBOX_MSG_BGX_LINK_CHANGE;
+			lmbx->link_status.lmac = vf_to_pport(nic->node, vf);
+			lmbx->link_status.link_up = 0;
+			nic->valid_vf_mbx_msg[i + 1] = true;
+			submit_work = 1;
+		}
+
+		if (nic->vf_enabled[vf] && nic->vf_op_enabled[vf]) {
+			nic->vf_mbx_msg[i].mac.vf_id = vf;
+			nic->vf_enabled[vf] = false;
+			submit_work = 1;
+		}
+		if (submit_work)
+			break;
+
+		/* First msg in VF teardown sequence */
+		nic->vf_enabled[vf] = false;
+		spin_unlock(&nic->vf_mbx_msg_lock);
+		return 0;
+	}
+	default:
+		break;
+	}
+
+	nic->valid_vf_mbx_msg[i] = true;
+	spin_unlock(&nic->vf_mbx_msg_lock);
+	queue_delayed_work(nic->notification_msg, &nic->notification_dwork, 0);
+
+	return ret;
+}
+
 /* Interrupt handler to handle mailbox messages from VFs */
 static void nic_handle_mbx_intr(struct nicpf *nic, int vf)
 {
@@ -916,12 +1309,32 @@ static void nic_handle_mbx_intr(struct nicpf *nic, int vf)
 		__func__, mbx.msg.msg, vf);
 	switch (mbx.msg.msg) {
 	case NIC_MBOX_MSG_READY:
+		if (veb_enabled) {
+			if (!is_pf(nic->node, vf) &&
+			    (vf > (get_pf(nic->node, vf) + veb_enabled))) {
+				nic_mbx_send_nack(nic, vf);
+				goto unlock;
+			}
+		}
 		nic_mbx_send_ready(nic, vf);
 		if (vf < nic->num_vf_en) {
 			nic->link[vf] = 0;
 			nic->duplex[vf] = 0;
 			nic->speed[vf] = 0;
 		}
+		//PF assigning MAC address for VF, as part of VF probe init
+		//We need to notify this to filter as VF set MAC
+		if (veb_enabled)
+			nic_submit_msg_notification(nic, vf, &mbx);
+		goto unlock;
+	case NIC_MBOX_MSG_VLAN:
+	case NIC_MBOX_MSG_ADMIN_VLAN:
+	case NIC_MBOX_MSG_UC_MC:
+		if (nic_submit_msg_notification(nic, vf, &mbx))
+			goto unlock;
+		break;
+	case NIC_MBOX_MSG_PROMISC:
+		nic_submit_msg_notification(nic, vf, &mbx);
 		goto unlock;
 	case NIC_MBOX_MSG_QS_CFG:
 		reg_addr = NIC_PF_QSET_0_127_CFG |
@@ -977,10 +1390,18 @@ static void nic_handle_mbx_intr(struct nicpf *nic, int vf)
 			ret = -1; /* NACK */
 			break;
 		}
-		lmac = mbx.mac.vf_id;
-		bgx = NIC_GET_BGX_FROM_VF_LMAC_MAP(nic->vf_lmac_map[lmac]);
-		lmac = NIC_GET_LMAC_FROM_VF_LMAC_MAP(nic->vf_lmac_map[lmac]);
-		bgx_set_lmac_mac(nic->node, bgx, lmac, mbx.mac.mac_addr);
+		if (veb_enabled) {
+			nic_submit_msg_notification(nic, vf, &mbx);
+		} else {
+			int vf_lmac;
+
+			lmac = mbx.mac.vf_id;
+			vf_lmac = nic->vf_lmac_map[lmac];
+			bgx = NIC_GET_BGX_FROM_VF_LMAC_MAP(vf_lmac);
+			lmac = NIC_GET_LMAC_FROM_VF_LMAC_MAP(vf_lmac);
+			bgx_set_lmac_mac(nic->node, bgx, lmac,
+					 mbx.mac.mac_addr);
+		}
 		break;
 	case NIC_MBOX_MSG_SET_MAX_FRS:
 		ret = nic_update_hw_frs(nic, mbx.frs.max_frs,
@@ -996,16 +1417,28 @@ static void nic_handle_mbx_intr(struct nicpf *nic, int vf)
 	case NIC_MBOX_MSG_RSS_CFG_CONT:
 		nic_config_rss(nic, &mbx.rss_cfg);
 		break;
+	case NIC_MBOX_MSG_OP_UP:
+	case NIC_MBOX_MSG_OP_DOWN:
+		if (nic_submit_msg_notification(nic, vf, &mbx))
+			goto unlock;
+		break;
 	case NIC_MBOX_MSG_CFG_DONE:
 		/* Last message of VF config msg sequence */
-		nic_enable_vf(nic, vf, true);
+		if (veb_enabled)
+			nic_submit_msg_notification(nic, vf, &mbx);
+		else
+			nic_enable_vf(nic, vf, true);
 		goto unlock;
 	case NIC_MBOX_MSG_SHUTDOWN:
-		/* First msg in VF teardown sequence */
-		if (vf >= nic->num_vf_en)
-			nic->sqs_used[vf - nic->num_vf_en] = false;
-		nic->pqs_vf[vf] = 0;
-		nic_enable_vf(nic, vf, false);
+		if (veb_enabled) {
+			nic_submit_msg_notification(nic, vf, &mbx);
+		} else {
+			/* First msg in VF teardown sequence */
+			if (vf >= nic->num_vf_en)
+				nic->sqs_used[vf - nic->num_vf_en] = false;
+			nic->pqs_vf[vf] = 0;
+			nic_enable_vf(nic, vf, false);
+		}
 		break;
 	case NIC_MBOX_MSG_ALLOC_SQS:
 		nic_alloc_sqs(nic, &mbx.sqs_alloc);
@@ -1228,47 +1661,148 @@ static void nic_poll_for_link(struct work_struct *work)
 	union nic_mbx mbx = {};
 	struct nicpf *nic;
 	struct bgx_link_status link;
-	u8 vf, bgx, lmac;
+	int vf, bgx, lmac;
 
 	nic = container_of(work, struct nicpf, dwork.work);
 
 	mbx.link_status.msg = NIC_MBOX_MSG_BGX_LINK_CHANGE;
 
-	for (vf = 0; vf < nic->num_vf_en; vf++) {
-		/* Poll only if VF is UP */
-		if (!nic->vf_enabled[vf])
-			continue;
+	if (veb_enabled) {
+		int port = 0, i;
+		union nic_mbx *mbxp;
 
-		/* Get BGX, LMAC indices for the VF */
-		bgx = NIC_GET_BGX_FROM_VF_LMAC_MAP(nic->vf_lmac_map[vf]);
-		lmac = NIC_GET_LMAC_FROM_VF_LMAC_MAP(nic->vf_lmac_map[vf]);
-		/* Get interface link status */
-		bgx_get_lmac_link_state(nic->node, bgx, lmac, &link);
+		for (port = 0; port < TNS_MAX_LMAC; port++) {
+			int start_vf, end_vf;
 
-		/* Inform VF only if link status changed */
-		if (nic->link[vf] == link.link_up)
-			continue;
+			if (phy_port_to_bgx_lmac(nic->node, port, &bgx, &lmac))
+				continue;
 
-		if (!nic->mbx_lock[vf]) {
-			nic->link[vf] = link.link_up;
-			nic->duplex[vf] = link.duplex;
-			nic->speed[vf] = link.speed;
+			get_vf_group(nic->node, port, &start_vf, &end_vf);
+			if (!nic->vf_enabled[start_vf])
+				continue;
 
-			/* Send a mbox message to VF with current link status */
-			mbx.link_status.link_up = link.link_up;
-			mbx.link_status.duplex = link.duplex;
-			mbx.link_status.speed = link.speed;
-			nic_send_msg_to_vf(nic, vf, &mbx);
+			bgx_get_lmac_link_state(nic->node, bgx, lmac, &link);
+
+			if (link_lmac[nic->node][port] == link.link_up)
+				continue;
+
+			link_lmac[nic->node][port] = link.link_up;
+			pf_speed[nic->node][port] = link.speed;
+			pf_duplex[nic->node][port] = link.duplex;
+
+			spin_lock(&nic->vf_mbx_msg_lock);
+			for (i = 0; i < MAX_VF_MBOX_MESSAGE; i++)
+				if (!nic->valid_vf_mbx_msg[i])
+					break;
+
+			if (i == MAX_VF_MBOX_MESSAGE) {
+				spin_unlock(&nic->vf_mbx_msg_lock);
+				return;
+			}
+
+			mbxp = &nic->vf_mbx_msg[i];
+			nic->valid_vf_mbx_msg[i] = true;
+			mbxp->link_status.msg = NIC_MBOX_MSG_BGX_LINK_CHANGE;
+			mbxp->link_status.link_up = link.link_up;
+			mbxp->link_status.speed = link.speed;
+			mbxp->link_status.duplex = link.duplex;
+			mbxp->link_status.lmac = port;
+			spin_unlock(&nic->vf_mbx_msg_lock);
+			queue_delayed_work(nic->notification_msg,
+					   &nic->notification_dwork, 0);
+
+			break;
+		}
+	} else {
+		for (vf = 0; vf < nic->num_vf_en; vf++) {
+			int vf_lmac = nic->vf_lmac_map[vf];
+
+			/* Poll only if VF is UP */
+			if (!nic->vf_enabled[vf])
+				continue;
+
+			/* Get BGX, LMAC indices for the VF */
+			bgx = NIC_GET_BGX_FROM_VF_LMAC_MAP(vf_lmac);
+			lmac = NIC_GET_LMAC_FROM_VF_LMAC_MAP(vf_lmac);
+			/* Get interface link status */
+			bgx_get_lmac_link_state(nic->node, bgx, lmac, &link);
+
+			/* Inform VF only if link status changed */
+			if (nic->link[vf] == link.link_up)
+				continue;
+
+			if (!nic->mbx_lock[vf]) {
+				nic->link[vf] = link.link_up;
+				nic->duplex[vf] = link.duplex;
+				nic->speed[vf] = link.speed;
+
+				/* Send a mbox message to VF with current
+				 * link status
+				 */
+				mbx.link_status.link_up = link.link_up;
+				mbx.link_status.duplex = link.duplex;
+				mbx.link_status.speed = link.speed;
+				nic_send_msg_to_vf(nic, vf, &mbx);
+			}
 		}
 	}
 	queue_delayed_work(nic->check_link, &nic->dwork, HZ * 2);
 }
 
+static void set_tns_config(struct nicpf *nic)
+{
+	int i;
+	u32 vf_count;
+
+	bp_enable(nic, 0);
+	bp_enable(nic, 1);
+	vf_count = PF_END;
+	for (i = 0; i < vf_count; i++) {
+		if (i < 64)
+			nic->vnic_intf_map[i]		= 0;
+		else
+			nic->vnic_intf_map[i]		= 1;
+	}
+
+	set_bp_id(nic, 0, 1);
+	set_bp_id(nic, 1, 1);
+
+	nic->num_vf_en = vf_count;
+}
+
+static inline bool firmware_image_available(const struct firmware **fw,
+					    struct device *dev)
+{
+	int ret = 0;
+
+	ret = request_firmware(fw, FW_NAME, dev);
+	if (ret) {
+		dev_err(dev, "firmware file %s not found\n", FW_NAME);
+		dev_err(dev, "Fall back to backward compatible mode\n");
+		return false;
+	}
+
+	return true;
+}
+
+static int tns_init_done;
+
+void nic_enable_valid_vf(int max_vf_cnt)
+{
+	if (veb_enabled > (max_vf_cnt - 1)) {
+		veb_enabled = max_vf_cnt - 1;
+		pr_info("Number of VF's per physical port set to %d\n",
+			veb_enabled);
+		num_vfs = veb_enabled;
+	}
+}
+
 static int nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 {
 	struct device *dev = &pdev->dev;
 	struct nicpf *nic;
 	int    err;
+	const struct firmware *fw;
 
 	BUILD_BUG_ON(sizeof(union nic_mbx) > 16);
 
@@ -1319,6 +1853,19 @@ static int nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_release_regions;
 	}
 
+	if (veb_enabled && !tns_init_done) {
+		u16 sdevid;
+
+		pci_read_config_word(nic->pdev, PCI_SUBSYSTEM_ID, &sdevid);
+		if (sdevid == PCI_SUBSYS_DEVID_88XX_NIC_PF &&
+		    firmware_image_available(&fw, dev)) {
+			pr_info("Number Of VF's %d enabled per physical port\n",
+				num_vfs);
+		} else {
+			veb_enabled = 0;
+			num_vfs = 0;
+		}
+	}
 	nic->node = nic_get_node_id(pdev);
 
 	/* Initialize hardware */
@@ -1326,13 +1873,48 @@ static int nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		goto err_release_regions;
 
-	nic_set_lmac_vf_mapping(nic);
+	if (veb_enabled) {
+		nic_set_pf_vf_mapping(nic->node);
+		/* init TNS function pointers */
+		set_tns_config(nic);
+	} else {
+		nic_set_lmac_vf_mapping(nic);
+	}
 
 	/* Register interrupts */
 	err = nic_register_interrupts(nic);
 	if (err)
 		goto err_release_regions;
 
+	if (veb_enabled) {
+		int i;
+
+		for (i = 0; i < TNS_MAX_LMAC; i++)
+			link_lmac[nic->node][i] = 0;
+
+		spin_lock_init(&nic->vf_mbx_msg_lock);
+
+		nic->notification_msg = alloc_workqueue("notification_work",
+						WQ_UNBOUND | WQ_MEM_RECLAIM, 1);
+		if (!nic->notification_msg) {
+			err = -ENOMEM;
+			goto err_unregister_interrupts;
+		}
+		INIT_DELAYED_WORK(&nic->notification_dwork, send_notifications);
+		if (!tns_init_done) {
+			if (tns_init(fw, dev)) {
+				dev_err(dev, "Failed to init filter block\n");
+				err = -ENODEV;
+				goto err_unregister_interrupts;
+			}
+			tns_init_done = 1;
+			if (pf_filter_init()) {
+				pr_info("Failed to configure HW filter\n");
+				goto err_unregister_interrupts;
+			}
+		}
+	}
+
 	/* Configure SRIOV */
 	err = nic_sriov_init(pdev, nic);
 	if (err)
@@ -1356,6 +1938,10 @@ static int nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		pci_disable_sriov(pdev);
 err_unregister_interrupts:
 	nic_unregister_interrupts(nic);
+	if (veb_enabled && nic->notification_msg) {
+		cancel_delayed_work_sync(&nic->notification_dwork);
+		destroy_workqueue(nic->notification_msg);
+	}
 err_release_regions:
 	pci_release_regions(pdev);
 err_disable_device:
@@ -1379,10 +1965,14 @@ static void nic_remove(struct pci_dev *pdev)
 		cancel_delayed_work_sync(&nic->dwork);
 		destroy_workqueue(nic->check_link);
 	}
-
 	nic_unregister_interrupts(nic);
 	pci_release_regions(pdev);
 
+	if (veb_enabled && nic->notification_msg) {
+		cancel_delayed_work_sync(&nic->notification_dwork);
+		destroy_workqueue(nic->notification_msg);
+	}
+
 	nic_free_lmacmem(nic);
 	devm_kfree(&pdev->dev, nic->hw);
 	devm_kfree(&pdev->dev, nic);
@@ -1402,11 +1992,20 @@ static int __init nic_init_module(void)
 {
 	pr_info("%s, ver %s\n", DRV_NAME, DRV_VERSION);
 
+	veb_enabled = num_vfs;
+	if (veb_enabled)
+		nic_init_pf_vf_mapping();
+
 	return pci_register_driver(&nic_driver);
 }
 
 static void __exit nic_cleanup_module(void)
 {
+	if (veb_enabled) {
+		tns_init_done = 0;
+		tns_exit();
+	}
+
 	pci_unregister_driver(&nic_driver);
 }
 
-- 
1.8.3.1
