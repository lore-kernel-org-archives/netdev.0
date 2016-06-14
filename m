From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next V2 9/9] liquidio: Introduce new octeon2/3 header
Date: Tue, 14 Jun 2016 16:54:51 -0700
Message-ID: <1465948491-10541-10-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1465948491-10541-1-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-bl2on0069.outbound.protection.outlook.com ([65.55.169.69]:3775
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751521AbcFNXz4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 19:55:56 -0400
In-Reply-To: <1465948491-10541-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added support for new instruction header for octeon2/octeon3(ih) and
corresponding changes.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    |  40 +++---
 .../net/ethernet/cavium/liquidio/liquidio_common.h | 134 ++++++++++++++++++++-
 drivers/net/ethernet/cavium/liquidio/octeon_iq.h   |  41 ++++++-
 drivers/net/ethernet/cavium/liquidio/octeon_nic.c  |  21 ++--
 drivers/net/ethernet/cavium/liquidio/octeon_nic.h  | 130 +++++++++++++++-----
 .../net/ethernet/cavium/liquidio/request_manager.c |  59 +++++----
 .../ethernet/cavium/liquidio/response_manager.c    |   6 +-
 7 files changed, 334 insertions(+), 97 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 4119e70..d0ab97c 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2658,10 +2658,9 @@ static inline int send_nic_timestamp_pkt(struct octeon_device *oct,
 {
 	int retval;
 	struct octeon_soft_command *sc;
-	struct octeon_instr_ih *ih;
-	struct octeon_instr_rdp *rdp;
 	struct lio *lio;
 	int ring_doorbell;
+	u32 len;
 
 	lio = finfo->lio;
 
@@ -2683,12 +2682,11 @@ static inline int send_nic_timestamp_pkt(struct octeon_device *oct,
 	sc->callback_arg = finfo->skb;
 	sc->iq_no = ndata->q_no;
 
-	ih = (struct octeon_instr_ih *)&sc->cmd.ih;
-	rdp = (struct octeon_instr_rdp *)&sc->cmd.rdp;
+	len = (u32)((struct octeon_instr_ih2 *)(&sc->cmd.cmd2.ih2))->dlengsz;
 
 	ring_doorbell = !xmit_more;
 	retval = octeon_send_command(oct, sc->iq_no, ring_doorbell, &sc->cmd,
-				     sc, ih->dlengsz, ndata->reqtype);
+				     sc, len, ndata->reqtype);
 
 	if (retval == IQ_SEND_FAILED) {
 		dev_err(&oct->pci_dev->dev, "timestamp data packet failed status: %x\n",
@@ -2715,6 +2713,8 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 	struct octnic_data_pkt ndata;
 	struct octeon_device *oct;
 	struct oct_iq_stats *stats;
+	struct octeon_instr_irh *irh;
+	union tx_info *tx_info;
 	int status = 0;
 	int q_idx = 0, iq_no = 0;
 	int xmit_more, j;
@@ -2800,18 +2800,18 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 		cmdsetup.s.u.datasize = skb->len;
 		octnet_prepare_pci_cmd(oct, &ndata.cmd, &cmdsetup, tag);
 		/* Offload checksum calculation for TCP/UDP packets */
-		ndata.cmd.dptr = dma_map_single(&oct->pci_dev->dev,
-						skb->data,
-						skb->len,
-						DMA_TO_DEVICE);
-		if (dma_mapping_error(&oct->pci_dev->dev, ndata.cmd.dptr)) {
+		dptr = dma_map_single(&oct->pci_dev->dev,
+				      skb->data,
+				      skb->len,
+				      DMA_TO_DEVICE);
+		if (dma_mapping_error(&oct->pci_dev->dev, dptr)) {
 			dev_err(&oct->pci_dev->dev, "%s DMA mapping error 1\n",
 				__func__);
 			return NETDEV_TX_BUSY;
 		}
 
-		finfo->dptr = ndata.cmd.dptr;
-
+		ndata.cmd.cmd2.dptr = dptr;
+		finfo->dptr = dptr;
 		ndata.reqtype = REQTYPE_NORESP_NET;
 
 	} else {
@@ -2885,18 +2885,17 @@ static int liquidio_xmit(struct sk_buff *skb, struct net_device *netdev)
 					   g->sg_size, DMA_TO_DEVICE);
 		dptr = g->sg_dma_ptr;
 
-		finfo->dptr = ndata.cmd.dptr;
+		ndata.cmd.cmd2.dptr = dptr;
+		finfo->dptr = dptr;
 		finfo->g = g;
 
 		ndata.reqtype = REQTYPE_NORESP_NET_SG;
 	}
 
-	if (skb_shinfo(skb)->gso_size) {
-		struct octeon_instr_irh *irh =
-			(struct octeon_instr_irh *)&ndata.cmd.irh;
-		union tx_info *tx_info = (union tx_info *)&ndata.cmd.ossp[0];
+	irh = (struct octeon_instr_irh *)&ndata.cmd.cmd2.irh;
+	tx_info = (union tx_info *)&ndata.cmd.cmd2.ossp[0];
 
-		irh->len = 1;   /* to indicate that ossp[0] contains tx_info */
+	if (skb_shinfo(skb)->gso_size) {
 		tx_info->s.gso_size = skb_shinfo(skb)->gso_size;
 		tx_info->s.gso_segs = skb_shinfo(skb)->gso_segs;
 	}
@@ -2926,8 +2925,9 @@ lio_xmit_failed:
 	stats->tx_dropped++;
 	netif_info(lio, tx_err, lio->netdev, "IQ%d Transmit dropped:%llu\n",
 		   iq_no, stats->tx_dropped);
-	dma_unmap_single(&oct->pci_dev->dev, ndata.cmd.dptr,
-			 ndata.datasize, DMA_TO_DEVICE);
+	if (dptr)
+		dma_unmap_single(&oct->pci_dev->dev, dptr,
+				 ndata.datasize, DMA_TO_DEVICE);
 	tx_buffer_free(skb);
 	return NETDEV_TX_OK;
 }
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 9917576..2179691 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -285,8 +285,140 @@ union octnet_cmd {
 
 #define   OCTNET_CMD_SIZE     (sizeof(union octnet_cmd))
 
+/* Instruction Header (DPI - CN23xx) - for OCTEON-III models */
+struct  octeon_instr_ih3 {
+#ifdef __BIG_ENDIAN_BITFIELD
+
+	/** Reserved3 */
+	u64     reserved3:1;
+
+	/** Gather indicator 1=gather*/
+	u64     gather:1;
+
+	/** Data length OR no. of entries in gather list */
+	u64     dlengsz:14;
+
+	/** Front Data size */
+	u64     fsz:6;
+
+	/** Reserved2 */
+	u64     reserved2:4;
+
+	/** PKI port kind - PKIND */
+	u64     pkind:6;
+
+	/** Reserved1 */
+	u64     reserved1:32;
+
+#else
+	/** Reserved1 */
+	u64     reserved1:32;
+
+	/** PKI port kind - PKIND */
+	u64     pkind:6;
+
+	/** Reserved2 */
+	u64     reserved2:4;
+
+	/** Front Data size */
+	u64     fsz:6;
+
+	/** Data length OR no. of entries in gather list */
+	u64     dlengsz:14;
+
+	/** Gather indicator 1=gather*/
+	u64     gather:1;
+
+	/** Reserved3 */
+	u64     reserved3:1;
+
+#endif
+};
+
+/* Optional PKI Instruction Header(PKI IH) - for OCTEON CN23XX models */
+/** BIG ENDIAN format.   */
+struct  octeon_instr_pki_ih3 {
+#ifdef __BIG_ENDIAN_BITFIELD
+
+	/** Wider bit */
+	u64     w:1;
+
+	/** Raw mode indicator 1 = RAW */
+	u64     raw:1;
+
+	/** Use Tag */
+	u64     utag:1;
+
+	/** Use QPG */
+	u64     uqpg:1;
+
+	/** Reserved2 */
+	u64     reserved2:1;
+
+	/** Parse Mode */
+	u64     pm:3;
+
+	/** Skip Length */
+	u64     sl:8;
+
+	/** Use Tag Type */
+	u64     utt:1;
+
+	/** Tag type */
+	u64     tagtype:2;
+
+	/** Reserved1 */
+	u64     reserved1:2;
+
+	/** QPG Value */
+	u64     qpg:11;
+
+	/** Tag Value */
+	u64     tag:32;
+
+#else
+
+	/** Tag Value */
+	u64     tag:32;
+
+	/** QPG Value */
+	u64     qpg:11;
+
+	/** Reserved1 */
+	u64     reserved1:2;
+
+	/** Tag type */
+	u64     tagtype:2;
+
+	/** Use Tag Type */
+	u64     utt:1;
+
+	/** Skip Length */
+	u64     sl:8;
+
+	/** Parse Mode */
+	u64     pm:3;
+
+	/** Reserved2 */
+	u64     reserved2:1;
+
+	/** Use QPG */
+	u64     uqpg:1;
+
+	/** Use Tag */
+	u64     utag:1;
+
+	/** Raw mode indicator 1 = RAW */
+	u64     raw:1;
+
+	/** Wider bit */
+	u64     w:1;
+#endif
+
+};
+
 /** Instruction Header */
-struct octeon_instr_ih {
+struct octeon_instr_ih2 {
 #ifdef __BIG_ENDIAN_BITFIELD
 	/** Raw mode indicator 1 = RAW */
 	u64 raw:1;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
index 14c5d70..513f8a0 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_iq.h
@@ -75,6 +75,8 @@ struct oct_iq_stats {
  *  a Octeon device has one such structure to represent it.
 */
 struct octeon_instr_queue {
+	struct octeon_device *oct_dev;
+
 	/** A spinlock to protect access to the input ring.  */
 	spinlock_t lock;
 
@@ -183,12 +185,12 @@ struct octeon_instr_32B {
 /** 64-byte instruction format.
  *  Format of instruction for a 64-byte mode input queue.
  */
-struct octeon_instr_64B {
+struct octeon_instr2_64B {
 	/** Pointer where the input data is available. */
 	u64 dptr;
 
 	/** Instruction Header. */
-	u64 ih;
+	u64 ih2;
 
 	/** Input Request Header. */
 	u64 irh;
@@ -205,10 +207,40 @@ struct octeon_instr_64B {
 	u64 rptr;
 
 	u64 reserved;
+};
+
+struct octeon_instr3_64B {
+	/** Pointer where the input data is available. */
+	u64 dptr;
+
+	/** Instruction Header. */
+	u64 ih3;
+
+	/** Instruction Header. */
+	u64 pki_ih3;
+
+	/** Input Request Header. */
+	u64 irh;
+
+	/** opcode/subcode specific parameters */
+	u64 ossp[2];
+
+	/** Return Data Parameters */
+	u64 rdp;
+
+	/** Pointer where the response for a RAW mode packet will be written
+	 * by Octeon.
+	 */
+	u64 rptr;
 
 };
 
-#define OCT_64B_INSTR_SIZE     (sizeof(struct octeon_instr_64B))
+union octeon_instr_64B {
+	struct octeon_instr2_64B cmd2;
+	struct octeon_instr3_64B cmd3;
+};
+
+#define OCT_64B_INSTR_SIZE     (sizeof(union octeon_instr_64B))
 
 /** The size of each buffer in soft command buffer pool
  */
@@ -221,7 +253,8 @@ struct octeon_soft_command {
 	u32 size;
 
 	/** Command and return status */
-	struct octeon_instr_64B cmd;
+	union octeon_instr_64B cmd;
+
 #define COMPLETION_WORD_INIT    0xffffffffffffffffULL
 	u64 *status_word;
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_nic.c b/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
index 20e0122..7843b8a 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_nic.c
@@ -44,11 +44,11 @@
 
 void *
 octeon_alloc_soft_command_resp(struct octeon_device    *oct,
-			       struct octeon_instr_64B *cmd,
-			       size_t		       rdatasize)
+			       union octeon_instr_64B *cmd,
+			       u32		       rdatasize)
 {
 	struct octeon_soft_command *sc;
-	struct octeon_instr_ih  *ih;
+	struct octeon_instr_ih2  *ih2;
 	struct octeon_instr_irh *irh;
 	struct octeon_instr_rdp *rdp;
 
@@ -59,24 +59,25 @@ octeon_alloc_soft_command_resp(struct octeon_device    *oct,
 		return NULL;
 
 	/* Copy existing command structure into the soft command */
-	memcpy(&sc->cmd, cmd, sizeof(struct octeon_instr_64B));
+	memcpy(&sc->cmd, cmd, sizeof(union octeon_instr_64B));
 
 	/* Add in the response related fields. Opcode and Param are already
 	 * there.
 	 */
-	ih      = (struct octeon_instr_ih *)&sc->cmd.ih;
-	ih->fsz = 40; /* irh + ossp[0] + ossp[1] + rdp + rptr = 40 bytes */
+	ih2      = (struct octeon_instr_ih2 *)&sc->cmd.cmd2.ih2;
+	rdp     = (struct octeon_instr_rdp *)&sc->cmd.cmd2.rdp;
+	irh     = (struct octeon_instr_irh *)&sc->cmd.cmd2.irh;
+	ih2->fsz = 40; /* irh + ossp[0] + ossp[1] + rdp + rptr = 40 bytes */
 
-	irh        = (struct octeon_instr_irh *)&sc->cmd.irh;
 	irh->rflag = 1; /* a response is required */
-	irh->len   = 4; /* means four 64-bit words immediately follow irh */
 
-	rdp            = (struct octeon_instr_rdp *)&sc->cmd.rdp;
 	rdp->pcie_port = oct->pcie_port;
 	rdp->rlen      = rdatasize;
 
 	*sc->status_word = COMPLETION_WORD_INIT;
 
+	sc->cmd.cmd2.rptr =  sc->dmarptr;
+
 	sc->wait_time = 1000;
 	sc->timeout = jiffies + sc->wait_time;
 
@@ -123,7 +124,7 @@ static inline struct octeon_soft_command
 {
 	struct octeon_soft_command *sc = NULL;
 	u8 *data;
-	size_t rdatasize;
+	u32 rdatasize;
 	u32 uddsize = 0, datasize = 0;
 
 	uddsize = (u32)(nctrl->ncmd.s.more * 8);
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_nic.h b/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
index 5e53cc9..b71a2bb 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_nic.h
@@ -85,7 +85,7 @@ struct octnic_data_pkt {
 	u32 datasize;
 
 	/** Command to be passed to the Octeon device software. */
-	struct octeon_instr_64B cmd;
+	union octeon_instr_64B cmd;
 
 	/** Input queue to use to send this command. */
 	u32 q_no;
@@ -121,52 +121,109 @@ static inline int octnet_iq_is_full(struct octeon_device *oct, u32 q_no)
 		>= (oct->instr_queue[q_no]->max_count - 2));
 }
 
-/** Utility function to prepare a 64B NIC instruction based on a setup command
- * @param cmd - pointer to instruction to be filled in.
- * @param setup - pointer to the setup structure
- * @param q_no - which queue for back pressure
- *
- * Assumes the cmd instruction is pre-allocated, but no fields are filled in.
- */
 static inline void
-octnet_prepare_pci_cmd(struct octeon_device *oct, struct octeon_instr_64B *cmd,
-		       union octnic_cmd_setup *setup, u32 tag)
+octnet_prepare_pci_cmd_o2(struct octeon_device *oct,
+			  union octeon_instr_64B *cmd,
+			  union octnic_cmd_setup *setup, u32 tag)
 {
-	struct octeon_instr_ih *ih;
+	struct octeon_instr_ih2 *ih2;
 	struct octeon_instr_irh *irh;
 	union octnic_packet_params packet_params;
 	int port;
 
-	memset(cmd, 0, sizeof(struct octeon_instr_64B));
+	memset(cmd, 0, sizeof(union octeon_instr_64B));
 
-	ih = (struct octeon_instr_ih *)&cmd->ih;
+	ih2 = (struct octeon_instr_ih2 *)&cmd->cmd2.ih2;
 
 	/* assume that rflag is cleared so therefore front data will only have
-	 * irh and ossp[1] and ossp[2] for a total of 24 bytes
+	 * irh and ossp[0], ossp[1] for a total of 32 bytes
 	 */
-	ih->fsz = 24;
+	ih2->fsz = 24;
 
-	ih->tagtype = ORDERED_TAG;
-	ih->grp = DEFAULT_POW_GRP;
+	ih2->tagtype = ORDERED_TAG;
+	ih2->grp = DEFAULT_POW_GRP;
 
 	port = (int)oct->instr_queue[setup->s.iq_no]->txpciq.s.port;
 
 	if (tag)
-		ih->tag = tag;
+		ih2->tag = tag;
 	else
-		ih->tag = LIO_DATA(port);
+		ih2->tag = LIO_DATA(port);
+
+	ih2->raw = 1;
+	ih2->qos = (port & 3) + 4;	/* map qos based on interface */
+
+	if (!setup->s.gather) {
+		ih2->dlengsz = setup->s.u.datasize;
+	} else {
+		ih2->gather = 1;
+		ih2->dlengsz = setup->s.u.gatherptrs;
+	}
+
+	irh = (struct octeon_instr_irh *)&cmd->cmd2.irh;
+
+	irh->opcode = OPCODE_NIC;
+	irh->subcode = OPCODE_NIC_NW_DATA;
+
+	packet_params.u32 = 0;
+
+	packet_params.s.ip_csum = setup->s.ip_csum;
+	packet_params.s.transport_csum = setup->s.transport_csum;
+	packet_params.s.tnl_csum = setup->s.tnl_csum;
+	packet_params.s.tsflag = setup->s.timestamp;
+
+	irh->ossp = packet_params.u32;
+}
+
+static inline void
+octnet_prepare_pci_cmd_o3(struct octeon_device *oct,
+			  union octeon_instr_64B *cmd,
+			  union octnic_cmd_setup *setup, u32 tag)
+{
+	struct octeon_instr_irh *irh;
+	struct octeon_instr_ih3     *ih3;
+	struct octeon_instr_pki_ih3 *pki_ih3;
+	union octnic_packet_params packet_params;
+	int port;
 
-	ih->raw = 1;
-	ih->qos = (port & 3) + 4;	/* map qos based on interface */
+	memset(cmd, 0, sizeof(union octeon_instr_64B));
+
+	ih3 = (struct octeon_instr_ih3 *)&cmd->cmd3.ih3;
+	pki_ih3 = (struct octeon_instr_pki_ih3 *)&cmd->cmd3.pki_ih3;
+
+	/* assume that rflag is cleared so therefore front data will only have
+	 * irh and ossp[1] and ossp[2] for a total of 24 bytes
+	 */
+	ih3->pkind       = oct->instr_queue[setup->s.iq_no]->txpciq.s.pkind;
+	/*PKI IH*/
+	ih3->fsz = 24 + 8;
 
 	if (!setup->s.gather) {
-		ih->dlengsz = setup->s.u.datasize;
+		ih3->dlengsz = setup->s.u.datasize;
 	} else {
-		ih->gather = 1;
-		ih->dlengsz = setup->s.u.gatherptrs;
+		ih3->gather = 1;
+		ih3->dlengsz = setup->s.u.gatherptrs;
 	}
 
-	irh = (struct octeon_instr_irh *)&cmd->irh;
+	pki_ih3->w       = 1;
+	pki_ih3->raw     = 1;
+	pki_ih3->utag    = 1;
+	pki_ih3->utt     = 1;
+	pki_ih3->uqpg    = oct->instr_queue[setup->s.iq_no]->txpciq.s.use_qpg;
+
+	port = (int)oct->instr_queue[setup->s.iq_no]->txpciq.s.port;
+
+	if (tag)
+		pki_ih3->tag = tag;
+	else
+		pki_ih3->tag     = LIO_DATA(port);
+
+	pki_ih3->tagtype = ORDERED_TAG;
+	pki_ih3->qpg     = oct->instr_queue[setup->s.iq_no]->txpciq.s.qpg;
+	pki_ih3->pm      = 0x7; /*0x7 - meant for Parse nothing, uninterpreted*/
+	pki_ih3->sl      = 8;   /* sl will be sizeof(pki_ih3)*/
+
+	irh = (struct octeon_instr_irh *)&cmd->cmd3.irh;
 
 	irh->opcode = OPCODE_NIC;
 	irh->subcode = OPCODE_NIC_NW_DATA;
@@ -181,6 +238,23 @@ octnet_prepare_pci_cmd(struct octeon_device *oct, struct octeon_instr_64B *cmd,
 	irh->ossp = packet_params.u32;
 }
 
+/** Utility function to prepare a 64B NIC instruction based on a setup command
+ * @param cmd - pointer to instruction to be filled in.
+ * @param setup - pointer to the setup structure
+ * @param q_no - which queue for back pressure
+ *
+ * Assumes the cmd instruction is pre-allocated, but no fields are filled in.
+ */
+static inline void
+octnet_prepare_pci_cmd(struct octeon_device *oct, union octeon_instr_64B *cmd,
+		       union octnic_cmd_setup *setup, u32 tag)
+{
+	if (OCTEON_CN6XXX(oct))
+		octnet_prepare_pci_cmd_o2(oct, cmd, setup, tag);
+	else
+		octnet_prepare_pci_cmd_o3(oct, cmd, setup, tag);
+}
+
 /** Allocate and a soft command with space for a response immediately following
  * the commnad.
  * @param oct - octeon device pointer
@@ -193,8 +267,8 @@ octnet_prepare_pci_cmd(struct octeon_device *oct, struct octeon_instr_64B *cmd,
  */
 void *
 octeon_alloc_soft_command_resp(struct octeon_device    *oct,
-			       struct octeon_instr_64B *cmd,
-			       size_t		       rdatasize);
+			       union octeon_instr_64B *cmd,
+			       u32		       rdatasize);
 
 /** Send a NIC data packet to the device
  * @param oct - octeon device pointer
@@ -209,8 +283,6 @@ int octnet_send_nic_data_pkt(struct octeon_device *oct,
 /** Send a NIC control packet to the device
  * @param oct - octeon device pointer
  * @param nctrl - control structure with command, timout, and callback info
- * @param nparams - response control structure
- *
  * @returns IQ_FAILED if it failed to add to the input queue. IQ_STOP if it the
  * queue should be stopped, and IQ_SEND_OK if it sent okay.
  */
diff --git a/drivers/net/ethernet/cavium/liquidio/request_manager.c b/drivers/net/ethernet/cavium/liquidio/request_manager.c
index b0a8d4d..8649677 100644
--- a/drivers/net/ethernet/cavium/liquidio/request_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/request_manager.c
@@ -99,6 +99,7 @@ int octeon_init_instr_queue(struct octeon_device *oct,
 	q_size = (u32)conf->instr_type * num_descs;
 
 	iq = oct->instr_queue[iq_no];
+	iq->oct_dev = oct;
 
 	set_dev_node(&oct->pci_dev->dev, numa_node);
 	iq->base_addr = lio_dma_alloc(oct, q_size,
@@ -420,7 +421,7 @@ lio_process_iq_request_list(struct octeon_device *oct,
 		case REQTYPE_SOFT_COMMAND:
 			sc = buf;
 
-			irh = (struct octeon_instr_irh *)&sc->cmd.irh;
+			irh = (struct octeon_instr_irh *)&sc->cmd.cmd2.irh;
 			if (irh->rflag) {
 				/* We're expecting a response from Octeon.
 				 * It's up to lio_process_ordered_list() to
@@ -583,7 +584,7 @@ octeon_prepare_soft_command(struct octeon_device *oct,
 			    u64 ossp1)
 {
 	struct octeon_config *oct_cfg;
-	struct octeon_instr_ih *ih;
+	struct octeon_instr_ih2 *ih2;
 	struct octeon_instr_irh *irh;
 	struct octeon_instr_rdp *rdp;
 
@@ -592,73 +593,69 @@ octeon_prepare_soft_command(struct octeon_device *oct,
 
 	oct_cfg = octeon_get_conf(oct);
 
-	ih          = (struct octeon_instr_ih *)&sc->cmd.ih;
-	ih->tagtype = ATOMIC_TAG;
-	ih->tag     = LIO_CONTROL;
-	ih->raw     = 1;
-	ih->grp     = CFG_GET_CTRL_Q_GRP(oct_cfg);
+	ih2          = (struct octeon_instr_ih2 *)&sc->cmd.cmd2.ih2;
+	ih2->tagtype = ATOMIC_TAG;
+	ih2->tag     = LIO_CONTROL;
+	ih2->raw     = 1;
+	ih2->grp     = CFG_GET_CTRL_Q_GRP(oct_cfg);
 
 	if (sc->datasize) {
-		ih->dlengsz = sc->datasize;
-		ih->rs = 1;
+		ih2->dlengsz = sc->datasize;
+		ih2->rs = 1;
 	}
 
-	irh            = (struct octeon_instr_irh *)&sc->cmd.irh;
+	irh            = (struct octeon_instr_irh *)&sc->cmd.cmd2.irh;
 	irh->opcode    = opcode;
 	irh->subcode   = subcode;
 
 	/* opcode/subcode specific parameters (ossp) */
 	irh->ossp       = irh_ossp;
-	sc->cmd.ossp[0] = ossp0;
-	sc->cmd.ossp[1] = ossp1;
+	sc->cmd.cmd2.ossp[0] = ossp0;
+	sc->cmd.cmd2.ossp[1] = ossp1;
 
 	if (sc->rdatasize) {
-		rdp            = (struct octeon_instr_rdp *)&sc->cmd.rdp;
+		rdp = (struct octeon_instr_rdp *)&sc->cmd.cmd2.rdp;
 		rdp->pcie_port = oct->pcie_port;
 		rdp->rlen      = sc->rdatasize;
 
 		irh->rflag =  1;
-		irh->len   =  4;
-		ih->fsz    = 40; /* irh+ossp[0]+ossp[1]+rdp+rptr = 40 bytes */
+		ih2->fsz   = 40; /* irh+ossp[0]+ossp[1]+rdp+rptr = 40 bytes */
 	} else {
 		irh->rflag =  0;
-		irh->len   =  2;
-		ih->fsz    = 24; /* irh + ossp[0] + ossp[1] = 24 bytes */
+		ih2->fsz   = 24; /* irh + ossp[0] + ossp[1] = 24 bytes */
 	}
-
-	while (!(oct->io_qmask.iq & (1 << sc->iq_no)))
-		sc->iq_no++;
 }
 
 int octeon_send_soft_command(struct octeon_device *oct,
 			     struct octeon_soft_command *sc)
 {
-	struct octeon_instr_ih *ih;
+	struct octeon_instr_ih2 *ih2;
 	struct octeon_instr_irh *irh;
 	struct octeon_instr_rdp *rdp;
+	u32 len;
 
-	ih = (struct octeon_instr_ih *)&sc->cmd.ih;
-	if (ih->dlengsz) {
-		BUG_ON(!sc->dmadptr);
-		sc->cmd.dptr = sc->dmadptr;
+	ih2 = (struct octeon_instr_ih2 *)&sc->cmd.cmd2.ih2;
+	if (ih2->dlengsz) {
+		WARN_ON(!sc->dmadptr);
+		sc->cmd.cmd2.dptr = sc->dmadptr;
 	}
-
-	irh = (struct octeon_instr_irh *)&sc->cmd.irh;
+	irh = (struct octeon_instr_irh *)&sc->cmd.cmd2.irh;
 	if (irh->rflag) {
 		BUG_ON(!sc->dmarptr);
 		BUG_ON(!sc->status_word);
 		*sc->status_word = COMPLETION_WORD_INIT;
 
-		rdp = (struct octeon_instr_rdp *)&sc->cmd.rdp;
+		rdp = (struct octeon_instr_rdp *)&sc->cmd.cmd2.rdp;
 
-		sc->cmd.rptr = sc->dmarptr;
+		sc->cmd.cmd2.rptr = sc->dmarptr;
 	}
+	len = (u32)ih2->dlengsz;
 
 	if (sc->wait_time)
 		sc->timeout = jiffies + sc->wait_time;
 
-	return octeon_send_command(oct, sc->iq_no, 1, &sc->cmd, sc,
-				   (u32)ih->dlengsz, REQTYPE_SOFT_COMMAND);
+	return (octeon_send_command(oct, sc->iq_no, 1, &sc->cmd, sc,
+				    len, REQTYPE_SOFT_COMMAND));
 }
 
 int octeon_setup_sc_buffer_pool(struct octeon_device *oct)
diff --git a/drivers/net/ethernet/cavium/liquidio/response_manager.c b/drivers/net/ethernet/cavium/liquidio/response_manager.c
index 6287a7c..e2e9103 100644
--- a/drivers/net/ethernet/cavium/liquidio/response_manager.c
+++ b/drivers/net/ethernet/cavium/liquidio/response_manager.c
@@ -85,6 +85,7 @@ int lio_process_ordered_list(struct octeon_device *octeon_dev,
 	u32 status;
 	u64 status64;
 	struct octeon_instr_rdp *rdp;
+	u64 rptr;
 
 	ordered_sc_list = &octeon_dev->response_list[OCTEON_ORDERED_SC_LIST];
 
@@ -102,7 +103,8 @@ int lio_process_ordered_list(struct octeon_device *octeon_dev,
 
 		sc = (struct octeon_soft_command *)ordered_sc_list->
 		    head.next;
-		rdp = (struct octeon_instr_rdp *)&sc->cmd.rdp;
+		rdp = (struct octeon_instr_rdp *)&sc->cmd.cmd2.rdp;
+		rptr = sc->cmd.cmd2.rptr;
 
 		status = OCTEON_REQUEST_PENDING;
 
@@ -110,7 +112,7 @@ int lio_process_ordered_list(struct octeon_device *octeon_dev,
 		 * to where rptr is pointing to
 		 */
 		dma_sync_single_for_cpu(&octeon_dev->pci_dev->dev,
-					sc->cmd.rptr, rdp->rlen,
+					rptr, rdp->rlen,
 					DMA_FROM_DEVICE);
 		status64 = *sc->status_word;
 
-- 
1.8.3.1
