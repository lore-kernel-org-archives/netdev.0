From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V3 14/18] liquidio: CN23XX octeon3 instruction
Date: Sun, 21 Aug 2016 17:12:41 -0700
Message-ID: <1471824765-26473-15-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1471824765-26473-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
        Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0041.outbound.protection.outlook.com ([104.47.42.41]:52561
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753650AbcHVAOJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 21 Aug 2016 20:14:09 -0400
In-Reply-To: <1471824765-26473-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for data path related changes based
on octeon3 instruction header(ih3) for cn23xx.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |  35 +++--
 .../net/ethernet/cavium/liquidio/octeon_device.c   |  31 ++--
 drivers/net/ethernet/cavium/liquidio/octeon_droq.c |   6 +
 drivers/net/ethernet/cavium/liquidio/octeon_nic.c  |  27 +++-
 .../net/ethernet/cavium/liquidio/request_manager.c | 167 +++++++++++++++------
 .../ethernet/cavium/liquidio/response_manager.c    |   9 +-
 6 files changed, 202 insertions(+), 73 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 6d109d6..4cd6480 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -1344,16 +1344,15 @@ static void octeon_destroy_resources(struct octeon_device *oct)
 		octeon_delete_response_list(oct);
 
 		/* fallthrough */
-	case OCT_DEV_SC_BUFF_POOL_INIT_DONE:
-		octeon_free_sc_buffer_pool(oct);
-
-		/* fallthrough */
 	case OCT_DEV_INSTR_QUEUE_INIT_DONE:
 		for (i = 0; i < MAX_OCTEON_INSTR_QUEUES(oct); i++) {
 			if (!(oct->io_qmask.iq & (1ULL << i)))
 				continue;
 			octeon_delete_instr_queue(oct, i);
 		}
+		/* fallthrough */
+	case OCT_DEV_SC_BUFF_POOL_INIT_DONE:
+		octeon_free_sc_buffer_pool(oct);
 
 		/* fallthrough */
 	case OCT_DEV_DISPATCH_INIT_DONE:
@@ -2920,9 +2919,15 @@ static inline int send_nic_timestamp_pkt(struct octeon_device *oct,
 	sc->callback_arg = finfo->skb;
 	sc->iq_no = ndata->q_no;
 
-	len = (u32)((struct octeon_instr_ih2 *)(&sc->cmd.cmd2.ih2))->dlengsz;
+	if (OCTEON_CN23XX_PF(oct))
+		len = (u32)((struct octeon_instr_ih3 *)
+			    (&sc->cmd.cmd3.ih3))->dlengsz;
+	else
+		len = (u32)((struct octeon_instr_ih2 *)
+			    (&sc->cmd.cmd2.ih2))->dlengsz;
 
 	ring_doorbell = 1;
+
 	retval = octeon_send_command(oct, sc->iq_no, ring_doorbell, &sc->cmd,
 				     sc, len, ndata->reqtype);
 
@@ -3054,7 +3059,10 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 			return NETDEV_TX_BUSY;
 		}
 
-		ndata.cmd.cmd2.dptr = dptr;
+		if (OCTEON_CN23XX_PF(oct))
+			ndata.cmd.cmd3.dptr = dptr;
+		else
+			ndata.cmd.cmd2.dptr = dptr;
 		finfo->dptr = dptr;
 		ndata.reqtype = REQTYPE_NORESP_NET;
 
@@ -3129,15 +3137,23 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 					   g->sg_size, DMA_TO_DEVICE);
 		dptr = g->sg_dma_ptr;
 
-		ndata.cmd.cmd2.dptr = dptr;
+		if (OCTEON_CN23XX_PF(oct))
+			ndata.cmd.cmd3.dptr = dptr;
+		else
+			ndata.cmd.cmd2.dptr = dptr;
 		finfo->dptr = dptr;
 		finfo->g = g;
 
 		ndata.reqtype = REQTYPE_NORESP_NET_SG;
 	}
 
-	irh = (struct octeon_instr_irh *)&ndata.cmd.cmd2.irh;
-	tx_info = (union tx_info *)&ndata.cmd.cmd2.ossp[0];
+	if (OCTEON_CN23XX_PF(oct)) {
+		irh = (struct octeon_instr_irh *)&ndata.cmd.cmd3.irh;
+		tx_info = (union tx_info *)&ndata.cmd.cmd3.ossp[0];
+	} else {
+		irh = (struct octeon_instr_irh *)&ndata.cmd.cmd2.irh;
+		tx_info = (union tx_info *)&ndata.cmd.cmd2.ossp[0];
+	}
 
 	if (skb_shinfo(skb)->gso_size) {
 		tx_info->s.gso_size = skb_shinfo(skb)->gso_size;
@@ -3894,6 +3910,7 @@ static int liquidio_init_nic_module(struct octeon_device *oct)
 	intrmod_cfg->tx_mincnt_trigger = LIO_INTRMOD_TXMINCNT_TRIGGER;
 	intrmod_cfg->rx_frames = CFG_GET_OQ_INTR_PKT(octeon_get_conf(oct));
 	intrmod_cfg->rx_usecs = CFG_GET_OQ_INTR_TIME(octeon_get_conf(oct));
+	intrmod_cfg->tx_frames = CFG_GET_IQ_INTR_PKT(octeon_get_conf(oct));
 	dev_dbg(&oct->pci_dev->dev, "Network interfaces ready\n");
 
 	return retval;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.c b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
index 5252763..85e3123 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.c
@@ -793,7 +793,6 @@ int octeon_setup_instr_queues(struct octeon_device *oct)
 	union oct_txpciq txpciq;
 	int numa_node = cpu_to_node(iq_no % num_online_cpus());
 
-	/* this causes queue 0 to be default queue */
 	if (OCTEON_CN6XXX(oct))
 		num_descs =
 			CFG_GET_NUM_DEF_TX_DESCS(CHIP_FIELD(oct, cn6xxx, conf));
@@ -816,6 +815,7 @@ int octeon_setup_instr_queues(struct octeon_device *oct)
 	oct->instr_queue[0]->ifidx = 0;
 	txpciq.u64 = 0;
 	txpciq.s.q_no = iq_no;
+	txpciq.s.pkind = oct->pfvf_hsword.pkind;
 	txpciq.s.use_qpg = 0;
 	txpciq.s.qpg = 0;
 	if (octeon_init_instr_queue(oct, txpciq, num_descs)) {
@@ -835,7 +835,6 @@ int octeon_setup_output_queues(struct octeon_device *oct)
 	u32 oq_no = 0;
 	int numa_node = cpu_to_node(oq_no % num_online_cpus());
 
-	/* this causes queue 0 to be default queue */
 	if (OCTEON_CN6XXX(oct)) {
 		num_descs =
 			CFG_GET_NUM_DEF_RX_DESCS(CHIP_FIELD(oct, cn6xxx, conf));
@@ -863,10 +862,10 @@ int octeon_setup_output_queues(struct octeon_device *oct)
 
 void octeon_set_io_queues_off(struct octeon_device *oct)
 {
-	/* Disable the i/p and o/p queues for this Octeon. */
-
-	octeon_write_csr(oct, CN6XXX_SLI_PKT_INSTR_ENB, 0);
-	octeon_write_csr(oct, CN6XXX_SLI_PKT_OUT_ENB, 0);
+	if (OCTEON_CN6XXX(oct)) {
+		octeon_write_csr(oct, CN6XXX_SLI_PKT_INSTR_ENB, 0);
+		octeon_write_csr(oct, CN6XXX_SLI_PKT_OUT_ENB, 0);
+	}
 }
 
 void octeon_set_droq_pkt_op(struct octeon_device *oct,
@@ -876,14 +875,16 @@ void octeon_set_droq_pkt_op(struct octeon_device *oct,
 	u32 reg_val = 0;
 
 	/* Disable the i/p and o/p queues for this Octeon. */
-	reg_val = octeon_read_csr(oct, CN6XXX_SLI_PKT_OUT_ENB);
+	if (OCTEON_CN6XXX(oct)) {
+		reg_val = octeon_read_csr(oct, CN6XXX_SLI_PKT_OUT_ENB);
 
-	if (enable)
-		reg_val = reg_val | (1 << q_no);
-	else
-		reg_val = reg_val & (~(1 << q_no));
+		if (enable)
+			reg_val = reg_val | (1 << q_no);
+		else
+			reg_val = reg_val & (~(1 << q_no));
 
-	octeon_write_csr(oct, CN6XXX_SLI_PKT_OUT_ENB, reg_val);
+		octeon_write_csr(oct, CN6XXX_SLI_PKT_OUT_ENB, reg_val);
+	}
 }
 
 int octeon_init_dispatch_list(struct octeon_device *oct)
@@ -1100,6 +1101,12 @@ int octeon_core_drv_init(struct octeon_recv_info *recv_info, void *buf)
 	}
 	oct->fw_info.app_cap_flags = recv_pkt->rh.r_core_drv_init.app_cap_flags;
 	oct->fw_info.app_mode = (u32)recv_pkt->rh.r_core_drv_init.app_mode;
+	oct->pfvf_hsword.app_mode = (u32)recv_pkt->rh.r_core_drv_init.app_mode;
+
+	oct->pfvf_hsword.pkind = recv_pkt->rh.r_core_drv_init.pkind;
+
+	for (i = 0; i < oct->num_iqs; i++)
+		oct->instr_queue[i]->txpciq.s.pkind = oct->pfvf_hsword.pkind;
 
 	atomic_set(&oct->status, OCT_DEV_CORE_OK);
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
index 5dfc23d..8848ce2 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_droq.c
@@ -31,6 +31,7 @@
 #include "octeon_network.h"
 #include "cn66xx_regs.h"
 #include "cn66xx_device.h"
+#include "cn23xx_pf_device.h"
 
 #define     CVM_MIN(d1, d2)           (((d1) < (d2)) ? (d1) : (d2))
 #define     CVM_MAX(d1, d2)           (((d1) > (d2)) ? (d1) : (d2))
@@ -262,6 +263,11 @@ int octeon_init_droq(struct octeon_device *oct,
 		c_pkts_per_intr = (u32)CFG_GET_OQ_PKTS_PER_INTR(conf6x);
 		c_refill_threshold =
 			(u32)CFG_GET_OQ_REFILL_THRESHOLD(conf6x);
+	} else if (OCTEON_CN23XX_PF(oct)) {
+		struct octeon_config *conf23 = CHIP_FIELD(oct, cn23xx_pf, conf);
+
+		c_pkts_per_intr = (u32)CFG_GET_OQ_PKTS_PER_INTR(conf23);
+		c_refill_threshold = (u32)CFG_GET_OQ_REFILL_THRESHOLD(conf23);
 	} else {
 		return 1;
 	}
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_nic.c b/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
index 0c4013d..bd0df0b 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
@@ -35,6 +35,7 @@ octeon_alloc_soft_command_resp(struct octeon_device    *oct,
 			       u32		       rdatasize)
 {
 	struct octeon_soft_command *sc;
+	struct octeon_instr_ih3  *ih3;
 	struct octeon_instr_ih2  *ih2;
 	struct octeon_instr_irh *irh;
 	struct octeon_instr_rdp *rdp;
@@ -51,10 +52,19 @@ octeon_alloc_soft_command_resp(struct octeon_device    *oct,
 	/* Add in the response related fields. Opcode and Param are already
 	 * there.
 	 */
-	ih2      = (struct octeon_instr_ih2 *)&sc->cmd.cmd2.ih2;
-	rdp     = (struct octeon_instr_rdp *)&sc->cmd.cmd2.rdp;
-	irh     = (struct octeon_instr_irh *)&sc->cmd.cmd2.irh;
-	ih2->fsz = 40; /* irh + ossp[0] + ossp[1] + rdp + rptr = 40 bytes */
+	if (OCTEON_CN23XX_PF(oct)) {
+		ih3      = (struct octeon_instr_ih3 *)&sc->cmd.cmd3.ih3;
+		rdp     = (struct octeon_instr_rdp *)&sc->cmd.cmd3.rdp;
+		irh     = (struct octeon_instr_irh *)&sc->cmd.cmd3.irh;
+		/*pkiih3 + irh + ossp[0] + ossp[1] + rdp + rptr = 40 bytes */
+		ih3->fsz = 40 + 8;
+	} else {
+		ih2      = (struct octeon_instr_ih2 *)&sc->cmd.cmd2.ih2;
+		rdp     = (struct octeon_instr_rdp *)&sc->cmd.cmd2.rdp;
+		irh     = (struct octeon_instr_irh *)&sc->cmd.cmd2.irh;
+		/* irh + ossp[0] + ossp[1] + rdp + rptr = 40 bytes */
+		ih2->fsz = 40;
+	}
 
 	irh->rflag = 1; /* a response is required */
 
@@ -63,7 +73,10 @@ octeon_alloc_soft_command_resp(struct octeon_device    *oct,
 
 	*sc->status_word = COMPLETION_WORD_INIT;
 
-	sc->cmd.cmd2.rptr =  sc->dmarptr;
+	if (OCTEON_CN23XX_PF(oct))
+		sc->cmd.cmd3.rptr =  sc->dmarptr;
+	else
+		sc->cmd.cmd2.rptr =  sc->dmarptr;
 
 	sc->wait_time = 1000;
 	sc->timeout = jiffies + sc->wait_time;
@@ -179,8 +192,8 @@ octnet_send_nic_ctrl_pkt(struct octeon_device *oct,
 	retval = octeon_send_soft_command(oct, sc);
 	if (retval == IQ_SEND_FAILED) {
 		octeon_free_soft_command(oct, sc);
-		dev_err(&oct->pci_dev->dev, "%s soft command:%d send failed status: %x\n",
-			__func__, nctrl->ncmd.s.cmd, retval);
+		dev_err(&oct->pci_dev->dev, "%s pf_num:%d soft command:%d send failed status: %x\n",
+			__func__, oct->pf_num, nctrl->ncmd.s.cmd, retval);
 		spin_unlock_bh(&oct->cmd_resp_wqlock);
 		return -1;
 	}
diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index 3ee5d02..16192fa 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -30,6 +30,7 @@
 #include "octeon_main.h"
 #include "octeon_network.h"
 #include "cn66xx_device.h"
+#include "cn23xx_pf_device.h"
 
 #define INCR_INSTRQUEUE_PKT_COUNT(octeon_dev_ptr, iq_no, field, count)  \
 	(octeon_dev_ptr->instr_queue[iq_no]->stats.field += count)
@@ -71,7 +72,8 @@ int octeon_init_instr_queue(struct octeon_device *oct,
 
 	if (OCTEON_CN6XXX(oct))
 		conf = &(CFG_GET_IQ_CFG(CHIP_FIELD(oct, cn6xxx, conf)));
-
+	else if (OCTEON_CN23XX_PF(oct))
+		conf = &(CFG_GET_IQ_CFG(CHIP_FIELD(oct, cn23xx_pf, conf)));
 	if (!conf) {
 		dev_err(&oct->pci_dev->dev, "Unsupported Chip %x\n",
 			oct->chip_id);
@@ -88,6 +90,7 @@ int octeon_init_instr_queue(struct octeon_device *oct,
 	q_size = (u32)conf->instr_type * num_descs;
 
 	iq = oct->instr_queue[iq_no];
+
 	iq->oct_dev = oct;
 
 	set_dev_node(&oct->pci_dev->dev, numa_node);
@@ -181,6 +184,9 @@ int octeon_delete_instr_queue(struct octeon_device *oct, u32 iq_no)
 	if (OCTEON_CN6XXX(oct))
 		desc_size =
 		    CFG_GET_IQ_INSTR_TYPE(CHIP_FIELD(oct, cn6xxx, conf));
+	else if (OCTEON_CN23XX_PF(oct))
+		desc_size =
+		    CFG_GET_IQ_INSTR_TYPE(CHIP_FIELD(oct, cn23xx_pf, conf));
 
 	vfree(iq->request_list);
 
@@ -383,7 +389,12 @@ lio_process_iq_request_list(struct octeon_device *oct,
 		case REQTYPE_SOFT_COMMAND:
 			sc = buf;
 
-			irh = (struct octeon_instr_irh *)&sc->cmd.cmd2.irh;
+			if (OCTEON_CN23XX_PF(oct))
+				irh = (struct octeon_instr_irh *)
+					&sc->cmd.cmd3.irh;
+			else
+				irh = (struct octeon_instr_irh *)
+					&sc->cmd.cmd2.irh;
 			if (irh->rflag) {
 				/* We're expecting a response from Octeon.
 				 * It's up to lio_process_ordered_list() to
@@ -583,6 +594,8 @@ octeon_prepare_soft_command(struct octeon_device *oct,
 {
 	struct octeon_config *oct_cfg;
 	struct octeon_instr_ih2 *ih2;
+	struct octeon_instr_ih3 *ih3;
+	struct octeon_instr_pki_ih3 *pki_ih3;
 	struct octeon_instr_irh *irh;
 	struct octeon_instr_rdp *rdp;
 
@@ -591,36 +604,88 @@ octeon_prepare_soft_command(struct octeon_device *oct,
 
 	oct_cfg = octeon_get_conf(oct);
 
-	ih2          = (struct octeon_instr_ih2 *)&sc->cmd.cmd2.ih2;
-	ih2->tagtype = ATOMIC_TAG;
-	ih2->tag     = LIO_CONTROL;
-	ih2->raw     = 1;
-	ih2->grp     = CFG_GET_CTRL_Q_GRP(oct_cfg);
-
-	if (sc->datasize) {
-		ih2->dlengsz = sc->datasize;
-		ih2->rs = 1;
-	}
-
-	irh            = (struct octeon_instr_irh *)&sc->cmd.cmd2.irh;
-	irh->opcode    = opcode;
-	irh->subcode   = subcode;
-
-	/* opcode/subcode specific parameters (ossp) */
-	irh->ossp       = irh_ossp;
-	sc->cmd.cmd2.ossp[0] = ossp0;
-	sc->cmd.cmd2.ossp[1] = ossp1;
-
-	if (sc->rdatasize) {
-		rdp = (struct octeon_instr_rdp *)&sc->cmd.cmd2.rdp;
-		rdp->pcie_port = oct->pcie_port;
-		rdp->rlen      = sc->rdatasize;
+	if (OCTEON_CN23XX_PF(oct)) {
+		ih3 = (struct octeon_instr_ih3 *)&sc->cmd.cmd3.ih3;
+
+		ih3->pkind = oct->instr_queue[sc->iq_no]->txpciq.s.pkind;
+
+		pki_ih3 = (struct octeon_instr_pki_ih3 *)&sc->cmd.cmd3.pki_ih3;
+
+		pki_ih3->w           = 1;
+		pki_ih3->raw         = 1;
+		pki_ih3->utag        = 1;
+		pki_ih3->uqpg        =
+			oct->instr_queue[sc->iq_no]->txpciq.s.use_qpg;
+		pki_ih3->utt         = 1;
+		pki_ih3->tag     = LIO_CONTROL;
+		pki_ih3->tagtype = ATOMIC_TAG;
+		pki_ih3->qpg         =
+			oct->instr_queue[sc->iq_no]->txpciq.s.qpg;
+		pki_ih3->pm          = 0x7;
+		pki_ih3->sl          = 8;
+
+		if (sc->datasize)
+			ih3->dlengsz = sc->datasize;
+
+		irh            = (struct octeon_instr_irh *)&sc->cmd.cmd3.irh;
+		irh->opcode    = opcode;
+		irh->subcode   = subcode;
+
+		/* opcode/subcode specific parameters (ossp) */
+		irh->ossp       = irh_ossp;
+		sc->cmd.cmd3.ossp[0] = ossp0;
+		sc->cmd.cmd3.ossp[1] = ossp1;
+
+		if (sc->rdatasize) {
+			rdp = (struct octeon_instr_rdp *)&sc->cmd.cmd3.rdp;
+			rdp->pcie_port = oct->pcie_port;
+			rdp->rlen      = sc->rdatasize;
+
+			irh->rflag =  1;
+			/*PKI IH3*/
+			/* pki_ih3 irh+ossp[0]+ossp[1]+rdp+rptr = 48 bytes */
+			ih3->fsz    = 40 + 8;
+		} else {
+			irh->rflag =  0;
+			/*PKI IH3*/
+			/* pki_h3 + irh + ossp[0] + ossp[1] = 32 bytes */
+			ih3->fsz    = 24 + 8;
+		}
 
-		irh->rflag =  1;
-		ih2->fsz   = 40; /* irh+ossp[0]+ossp[1]+rdp+rptr = 40 bytes */
 	} else {
-		irh->rflag =  0;
-		ih2->fsz   = 24; /* irh + ossp[0] + ossp[1] = 24 bytes */
+		ih2          = (struct octeon_instr_ih2 *)&sc->cmd.cmd2.ih2;
+		ih2->tagtype = ATOMIC_TAG;
+		ih2->tag     = LIO_CONTROL;
+		ih2->raw     = 1;
+		ih2->grp     = CFG_GET_CTRL_Q_GRP(oct_cfg);
+
+		if (sc->datasize) {
+			ih2->dlengsz = sc->datasize;
+			ih2->rs = 1;
+		}
+
+		irh            = (struct octeon_instr_irh *)&sc->cmd.cmd2.irh;
+		irh->opcode    = opcode;
+		irh->subcode   = subcode;
+
+		/* opcode/subcode specific parameters (ossp) */
+		irh->ossp       = irh_ossp;
+		sc->cmd.cmd2.ossp[0] = ossp0;
+		sc->cmd.cmd2.ossp[1] = ossp1;
+
+		if (sc->rdatasize) {
+			rdp = (struct octeon_instr_rdp *)&sc->cmd.cmd2.rdp;
+			rdp->pcie_port = oct->pcie_port;
+			rdp->rlen      = sc->rdatasize;
+
+			irh->rflag =  1;
+			/* irh+ossp[0]+ossp[1]+rdp+rptr = 40 bytes */
+			ih2->fsz   = 40;
+		} else {
+			irh->rflag =  0;
+			/* irh + ossp[0] + ossp[1] = 24 bytes */
+			ih2->fsz   = 24;
+		}
 	}
 }
 
@@ -628,23 +693,39 @@ int octeon_send_soft_command(struct octeon_device *oct,
 			     struct octeon_soft_command *sc)
 {
 	struct octeon_instr_ih2 *ih2;
+	struct octeon_instr_ih3 *ih3;
 	struct octeon_instr_irh *irh;
 	u32 len;
 
-	ih2 = (struct octeon_instr_ih2 *)&sc->cmd.cmd2.ih2;
-	if (ih2->dlengsz) {
-		WARN_ON(!sc->dmadptr);
-		sc->cmd.cmd2.dptr = sc->dmadptr;
-	}
-	irh = (struct octeon_instr_irh *)&sc->cmd.cmd2.irh;
-	if (irh->rflag) {
-		WARN_ON(!sc->dmarptr);
-		WARN_ON(!sc->status_word);
-		*sc->status_word = COMPLETION_WORD_INIT;
-
-		sc->cmd.cmd2.rptr = sc->dmarptr;
+	if (OCTEON_CN23XX_PF(oct)) {
+		ih3 =  (struct octeon_instr_ih3 *)&sc->cmd.cmd3.ih3;
+		if (ih3->dlengsz) {
+			WARN_ON(!sc->dmadptr);
+			sc->cmd.cmd3.dptr = sc->dmadptr;
+		}
+		irh = (struct octeon_instr_irh *)&sc->cmd.cmd3.irh;
+		if (irh->rflag) {
+			WARN_ON(!sc->dmarptr);
+			WARN_ON(!sc->status_word);
+			*sc->status_word = COMPLETION_WORD_INIT;
+			sc->cmd.cmd3.rptr = sc->dmarptr;
+		}
+		len = (u32)ih3->dlengsz;
+	} else {
+		ih2 = (struct octeon_instr_ih2 *)&sc->cmd.cmd2.ih2;
+		if (ih2->dlengsz) {
+			WARN_ON(!sc->dmadptr);
+			sc->cmd.cmd2.dptr = sc->dmadptr;
+		}
+		irh = (struct octeon_instr_irh *)&sc->cmd.cmd2.irh;
+		if (irh->rflag) {
+			WARN_ON(!sc->dmarptr);
+			WARN_ON(!sc->status_word);
+			*sc->status_word = COMPLETION_WORD_INIT;
+			sc->cmd.cmd2.rptr = sc->dmarptr;
+		}
+		len = (u32)ih2->dlengsz;
 	}
-	len = (u32)ih2->dlengsz;
 
 	if (sc->wait_time)
 		sc->timeout = jiffies + sc->wait_time;
diff --git a/drivers/net/ethernet/cavium/liquidio/response_manager.c b/drivers/net/ethernet/cavium/liquidio/response_manager.c
index 709049e..be52178d 100644
--- a/drivers/net/ethernet/cavium/liquidio/response_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/response_manager.c
@@ -91,8 +91,13 @@ int lio_process_ordered_list(struct octeon_device *octeon_dev,
 
 		sc = (struct octeon_soft_command *)ordered_sc_list->
 		    head.next;
-		rdp = (struct octeon_instr_rdp *)&sc->cmd.cmd2.rdp;
-		rptr = sc->cmd.cmd2.rptr;
+		if (OCTEON_CN23XX_PF(octeon_dev)) {
+			rdp = (struct octeon_instr_rdp *)&sc->cmd.cmd3.rdp;
+			rptr = sc->cmd.cmd3.rptr;
+		} else {
+			rdp = (struct octeon_instr_rdp *)&sc->cmd.cmd2.rdp;
+			rptr = sc->cmd.cmd2.rptr;
+		}
 
 		status = OCTEON_REQUEST_PENDING;
 
-- 
1.8.3.1
