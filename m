From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/3] cxgb4: Add support for loopback between VI of same port
Date: Sun, 17 May 2015 16:15:21 +0530
Message-ID: <1431859523-7423-2-git-send-email-hariprasad@chelsio.com>
References: <1431859523-7423-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:10696 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751198AbbEQFck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2015 01:32:40 -0400
In-Reply-To: <1431859523-7423-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We now have a new cxgb4 module parameter "tx_vf" that when set
to a non-zero value, causes cxgb4 to use the "Virtual Machine" version
of the firmware Ethernet TX Packet Work Request (FW_ETH_TX_PKT_VM_WR)
instead of the "normal" default non-VM Work Request (FW_ETH_TX_PKT_WR).
This allows TX Packets sent by the cxgb4 PF Driver to be subject to the
firmware's MPS TCAM Lookup and therefore elligable for loop back to other
Virtual interfaces on the same port. This is useful for communicating with
Virtual machines running the VF Driver (cxgb4vf) and also for interesting
layered service applications. Enabling it by default lowers the
performance, so maybe module parameter is the right way to this.

Based on original work by Casey Leedom <leedom@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |   1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  19 +-
 drivers/net/ethernet/chelsio/cxgb4/sge.c        | 351 ++++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_values.h  |   2 +
 4 files changed, 372 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 932ab3b..25c19ef 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1055,6 +1055,7 @@ void t4_free_sge_resources(struct adapter *adap);
 void t4_free_ofld_rxqs(struct adapter *adap, int n, struct sge_ofld_rxq *q);
 irq_handler_t t4_intr_handler(struct adapter *adap);
 netdev_tx_t t4_eth_xmit(struct sk_buff *skb, struct net_device *dev);
+int t4vm_eth_xmit(struct sk_buff *skb, struct net_device *dev);
 int t4_ethrx_handler(struct sge_rspq *q, const __be64 *rsp,
 		     const struct pkt_gl *gl);
 int t4_mgmt_tx(struct adapter *adap, struct sk_buff *skb);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 5aecf69..888406e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -205,6 +205,18 @@ MODULE_PARM_DESC(intr_cnt,
 		 "thresholds 1..3 for queue interrupt packet counters, "
 		 "deprecated parameter");
 
+/* Use Ethernet TX Packet Virtual Machine Work Request instead of normal TX
+ * Packet Work Request to send packets out on Ethernet (NIC) TX Queues.  The
+ * normal FW_ETH_TX_PKT_WR doesn't go through a loopback lookup in the
+ * hardware and so always simply goes out on the wire and is never replicated
+ * for loopback to the host on Virtual Interfaces on the same port. The
+ * FW_ETH_TX_PKT_VM_WR does do this lookup but has somewhat lower performance.
+ */
+static int tx_vm;
+module_param(tx_vm, int, 0644);
+MODULE_PARM_DESC(tx_vm, "Use Ethernet TX Workrequests which can be delivered "
+		 "to Virtual Interfaces on the same port.");
+
 /*
  * Normally we tell the chip to deliver Ingress Packets into our DMA buffers
  * offset by 2 bytes in order to have the IP headers line up on 4-byte
@@ -3025,7 +3037,7 @@ static void cxgb_netpoll(struct net_device *dev)
 }
 #endif
 
-static const struct net_device_ops cxgb4_netdev_ops = {
+static struct net_device_ops cxgb4_netdev_ops = {
 	.ndo_open             = cxgb_open,
 	.ndo_stop             = cxgb_close,
 	.ndo_start_xmit       = t4_eth_xmit,
@@ -4619,6 +4631,11 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 		netdev->priv_flags |= IFF_UNICAST_FLT;
 
+		/* If the "tx_vm" module parameter is specified, use the
+		 * t4vm_eth_xmit() transmit routine instead of the normal one.
+		 */
+		if (tx_vm)
+			cxgb4_netdev_ops.ndo_start_xmit = t4vm_eth_xmit;
 		netdev->netdev_ops = &cxgb4_netdev_ops;
 #ifdef CONFIG_CHELSIO_T4_DCB
 		netdev->dcbnl_ops = &cxgb4_dcb_ops;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index dd18fcb..0d4dd48 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -1288,6 +1288,357 @@ out_free:	dev_kfree_skb_any(skb);
 	return NETDEV_TX_OK;
 }
 
+enum {
+	/* Egress Queue sizes, producer and consumer indices are all in units
+	 * of Egress Context Units bytes.  Note that as far as the hardware is
+	 * concerned, the free list is an Egress Queue (the host produces free
+	 * buffers which the hardware consumes) and free list entries are
+	 * 64-bit PCI DMA addresses.
+	 */
+	EQ_UNIT = IDXSIZE_UNIT_X,
+	FL_PER_EQ_UNIT = EQ_UNIT / sizeof(__be64),
+	TXD_PER_EQ_UNIT = EQ_UNIT / sizeof(__be64),
+
+	T4VF_ETHTXQ_MAX_HDR = (sizeof(struct fw_eth_tx_pkt_vm_wr) +
+			       sizeof(struct cpl_tx_pkt_lso_core) +
+			       sizeof(struct cpl_tx_pkt_core)) / sizeof(__be64),
+};
+
+/**
+ *	t4vf_is_eth_imm - can an Ethernet packet be sent as immediate data?
+ *	@skb: the packet
+ *
+ *	Returns whether an Ethernet packet is small enough to fit completely as
+ *	immediate data.
+ */
+static inline int t4vf_is_eth_imm(const struct sk_buff *skb)
+{
+	/* The VF Driver uses the FW_ETH_TX_PKT_VM_WR firmware Work Request
+	 * which does not accommodate immediate data.  We could dike out all
+	 * of the support code for immediate data but that would tie our hands
+	 * too much if we ever want to enhace the firmware.  It would also
+	 * create more differences between the PF and VF Drivers.
+	 */
+	return false;
+}
+
+/**
+ *	t4vf_calc_tx_flits - calculate the number of flits for a packet TX WR
+ *	@skb: the packet
+ *
+ *	Returns the number of flits needed for a TX Work Request for the
+ *	given Ethernet packet, including the needed WR and CPL headers.
+ */
+static inline unsigned int t4vf_calc_tx_flits(const struct sk_buff *skb)
+{
+	unsigned int flits;
+
+	/* If the skb is small enough, we can pump it out as a work request
+	 * with only immediate data.  In that case we just have to have the
+	 * TX Packet header plus the skb data in the Work Request.
+	 */
+	if (t4vf_is_eth_imm(skb))
+		return DIV_ROUND_UP(skb->len + sizeof(struct cpl_tx_pkt),
+				    sizeof(__be64));
+
+	/* Otherwise, we're going to have to construct a Scatter gather list
+	 * of the skb body and fragments.  We also include the flits necessary
+	 * for the TX Packet Work Request and CPL.  We always have a firmware
+	 * Write Header (incorporated as part of the cpl_tx_pkt_lso and
+	 * cpl_tx_pkt structures), followed by either a TX Packet Write CPL
+	 * message or, if we're doing a Large Send Offload, an LSO CPL message
+	 * with an embedded TX Packet Write CPL message.
+	 */
+	flits = sgl_len(skb_shinfo(skb)->nr_frags + 1);
+	if (skb_shinfo(skb)->gso_size)
+		flits += (sizeof(struct fw_eth_tx_pkt_vm_wr) +
+			  sizeof(struct cpl_tx_pkt_lso_core) +
+			  sizeof(struct cpl_tx_pkt_core)) / sizeof(__be64);
+	else
+		flits += (sizeof(struct fw_eth_tx_pkt_vm_wr) +
+			  sizeof(struct cpl_tx_pkt_core)) / sizeof(__be64);
+	return flits;
+}
+
+/**
+ *	t4vm_eth_xmit - add a packet to an Ethernet TX queue
+ *	@skb: the packet
+ *	@dev: the egress net device
+ *
+ *	Add a packet to an SGE Ethernet TX queue.  Runs with softirqs disabled.
+ */
+int t4vm_eth_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	u32 wr_mid;
+	u64 cntrl, *end;
+	int qidx, credits, max_pkt_len;
+	unsigned int flits, ndesc;
+	struct adapter *adapter;
+	struct sge_eth_txq *txq;
+	const struct port_info *pi;
+	struct fw_eth_tx_pkt_vm_wr *wr;
+	struct cpl_tx_pkt_core *cpl;
+	const struct skb_shared_info *ssi;
+	dma_addr_t addr[MAX_SKB_FRAGS + 1];
+	const size_t fw_hdr_copy_len = (sizeof(wr->ethmacdst) +
+					sizeof(wr->ethmacsrc) +
+					sizeof(wr->ethtype) +
+					sizeof(wr->vlantci));
+
+	/* The chip minimum packet length is 10 octets but the firmware
+	 * command that we are using requires that we copy the Ethernet header
+	 * (including the VLAN tag) into the header so we reject anything
+	 * smaller than that ...
+	 */
+	if (unlikely(skb->len < fw_hdr_copy_len))
+		goto out_free;
+
+	/* Discard the packet if the length is greater than mtu */
+	max_pkt_len = ETH_HLEN + dev->mtu;
+	if (skb_vlan_tag_present(skb))
+		max_pkt_len += VLAN_HLEN;
+	if (!skb_shinfo(skb)->gso_size && (unlikely(skb->len > max_pkt_len)))
+		goto out_free;
+
+	/* Figure out which TX Queue we're going to use. */
+	pi = netdev_priv(dev);
+	adapter = pi->adapter;
+	qidx = skb_get_queue_mapping(skb);
+	BUG_ON(qidx >= pi->nqsets);
+	txq = &adapter->sge.ethtxq[pi->first_qset + qidx];
+
+	/* Take this opportunity to reclaim any TX Descriptors whose DMA
+	 * transfers have completed.
+	 */
+	reclaim_completed_tx(adapter, &txq->q, true);
+
+	/* Calculate the number of flits and TX Descriptors we're going to
+	 * need along with how many TX Descriptors will be left over after
+	 * we inject our Work Request.
+	 */
+	flits = t4vf_calc_tx_flits(skb);
+	ndesc = flits_to_desc(flits);
+	credits = txq_avail(&txq->q) - ndesc;
+
+	if (unlikely(credits < 0)) {
+		/* Not enough room for this packet's Work Request.  Stop the
+		 * TX Queue and return a "busy" condition.  The queue will get
+		 * started later on when the firmware informs us that space
+		 * has opened up.
+		 */
+		eth_txq_stop(txq);
+		dev_err(adapter->pdev_dev,
+			"%s: TX ring %u full while queue awake!\n",
+			dev->name, qidx);
+		return NETDEV_TX_BUSY;
+	}
+
+	if (!t4vf_is_eth_imm(skb) &&
+	    unlikely(map_skb(adapter->pdev_dev, skb, addr) < 0)) {
+		/* We need to map the skb into PCI DMA space (because it can't
+		 * be in-lined directly into the Work Request) and the mapping
+		 * operation failed.  Record the error and drop the packet.
+		 */
+		txq->mapping_err++;
+		goto out_free;
+	}
+
+	wr_mid = FW_WR_LEN16_V(DIV_ROUND_UP(flits, 2));
+	if (unlikely(credits < ETHTXQ_STOP_THRES)) {
+		/* After we're done injecting the Work Request for this
+		 * packet, we'll be below our "stop threshold" so stop the TX
+		 * Queue now and schedule a request for an SGE Egress Queue
+		 * Update message.  The queue will get started later on when
+		 * the firmware processes this Work Request and sends us an
+		 * Egress Queue Status Update message indicating that space
+		 * has opened up.
+		 */
+		eth_txq_stop(txq);
+		wr_mid |= FW_WR_EQUEQ_F | FW_WR_EQUIQ_F;
+	}
+
+	/* Start filling in our Work Request.  Note that we do _not_ handle
+	 * the WR Header wrapping around the TX Descriptor Ring.  If our
+	 * maximum header size ever exceeds one TX Descriptor, we'll need to
+	 * do something else here.
+	 */
+	BUG_ON(DIV_ROUND_UP(T4VF_ETHTXQ_MAX_HDR, TXD_PER_EQ_UNIT) > 1);
+	wr = (void *)&txq->q.desc[txq->q.pidx];
+	wr->equiq_to_len16 = cpu_to_be32(wr_mid);
+	wr->r3[0] = cpu_to_be32(0);
+	wr->r3[1] = cpu_to_be32(0);
+	skb_copy_from_linear_data(skb, (void *)wr->ethmacdst, fw_hdr_copy_len);
+	end = (u64 *)wr + flits;
+
+	/* If this is a Large Send Offload packet we'll put in an LSO CPL
+	 * message with an encapsulated TX Packet CPL message.  Otherwise we
+	 * just use a TX Packet CPL message.
+	 */
+	ssi = skb_shinfo(skb);
+	if (ssi->gso_size) {
+		struct cpl_tx_pkt_lso_core *lso = (void *)(wr + 1);
+		bool v6 = (ssi->gso_type & SKB_GSO_TCPV6) != 0;
+		int l3hdr_len = skb_network_header_len(skb);
+		int eth_xtra_len = skb_network_offset(skb) - ETH_HLEN;
+
+		wr->op_immdlen =
+			cpu_to_be32(FW_WR_OP_V(FW_ETH_TX_PKT_VM_WR) |
+				    FW_WR_IMMDLEN_V(sizeof(*lso) +
+						    sizeof(*cpl)));
+		/* Fill in the LSO CPL message. */
+		lso->lso_ctrl =
+			cpu_to_be32(LSO_OPCODE_V(CPL_TX_PKT_LSO) |
+				    LSO_FIRST_SLICE_F |
+				    LSO_LAST_SLICE_F |
+				    LSO_IPV6_V(v6) |
+				    LSO_ETHHDR_LEN_V(eth_xtra_len / 4) |
+				    LSO_IPHDR_LEN_V(l3hdr_len / 4) |
+				    LSO_TCPHDR_LEN_V(tcp_hdr(skb)->doff));
+		lso->ipid_ofst = cpu_to_be16(0);
+		lso->mss = cpu_to_be16(ssi->gso_size);
+		lso->seqno_offset = cpu_to_be32(0);
+		if (is_t4(adapter->params.chip))
+			lso->len = cpu_to_be32(skb->len);
+		else
+			lso->len = cpu_to_be32(LSO_T5_XFER_SIZE_V(skb->len));
+
+		/* Set up TX Packet CPL pointer, control word and perform
+		 * accounting.
+		 */
+		cpl = (void *)(lso + 1);
+		cntrl = (TXPKT_CSUM_TYPE_V(v6 ?
+					   TX_CSUM_TCPIP6 :
+					   TX_CSUM_TCPIP) |
+			 TXPKT_IPHDR_LEN_V(l3hdr_len) |
+			 TXPKT_ETHHDR_LEN_V(eth_xtra_len));
+		txq->tso++;
+		txq->tx_cso += ssi->gso_segs;
+	} else {
+		int len;
+
+		len = (t4vf_is_eth_imm(skb)
+		       ? skb->len + sizeof(*cpl)
+		       : sizeof(*cpl));
+		wr->op_immdlen =
+			cpu_to_be32(FW_WR_OP_V(FW_ETH_TX_PKT_VM_WR) |
+				    FW_WR_IMMDLEN_V(len));
+
+		/* Set up TX Packet CPL pointer, control word and perform
+		 * accounting.
+		 */
+		cpl = (void *)(wr + 1);
+		if (skb->ip_summed == CHECKSUM_PARTIAL) {
+			cntrl = hwcsum(skb) | TXPKT_IPCSUM_DIS_F;
+			txq->tx_cso++;
+		} else {
+			cntrl = TXPKT_L4CSUM_DIS_F | TXPKT_IPCSUM_DIS_F;
+		}
+	}
+
+	/* If there's a VLAN tag present, add that to the list of things to
+	 * do in this Work Request.
+	 */
+	if (skb_vlan_tag_present(skb)) {
+		txq->vlan_ins++;
+		cntrl |= TXPKT_VLAN_VLD_F | TXPKT_VLAN_V(skb_vlan_tag_get(skb));
+	}
+
+	/* Fill in the TX Packet CPL message header. */
+	cpl->ctrl0 = cpu_to_be32(TXPKT_OPCODE_V(CPL_TX_PKT_XT) |
+				 TXPKT_INTF_V(pi->port_id) |
+				 TXPKT_PF_V(0));
+	cpl->pack = cpu_to_be16(0);
+	cpl->len = cpu_to_be16(skb->len);
+	cpl->ctrl1 = cpu_to_be64(cntrl);
+
+	/* Fill in the body of the TX Packet CPL message with either in-lined
+	 * data or a Scatter/Gather List.
+	 */
+	if (t4vf_is_eth_imm(skb)) {
+		/* In-line the packet's data and free the skb since we don't
+		 * need it any longer.
+		 */
+		inline_tx_skb(skb, &txq->q, cpl + 1);
+		dev_kfree_skb(skb);
+	} else {
+		/* Write the skb's Scatter/Gather list into the TX Packet CPL
+		 * message and retain a pointer to the skb so we can free it
+		 * later when its DMA completes.  (We store the skb pointer
+		 * in the Software Descriptor corresponding to the last TX
+		 * Descriptor used by the Work Request.)
+		 *
+		 * The retained skb will be freed when the corresponding TX
+		 * Descriptors are reclaimed after their DMAs complete.
+		 * However, this could take quite a while since, in general,
+		 * the hardware is set up to be lazy about sending DMA
+		 * completion notifications to us and we mostly perform TX
+		 * reclaims in the transmit routine.
+		 *
+		 * This is good for performamce but means that we rely on new
+		 * TX packets arriving to run the destructors of completed
+		 * packets, which open up space in their sockets' send queues.
+		 * Sometimes we do not get such new packets causing TX to
+		 * stall.  A single UDP transmitter is a good example of this
+		 * situation.  We have a clean up timer that periodically
+		 * reclaims completed packets but it doesn't run often enough
+		 * (nor do we want it to) to prevent lengthy stalls.  A
+		 * solution to this problem is to run the destructor early,
+		 * after the packet is queued but before it's DMAd.  A con is
+		 * that we lie to socket memory accounting, but the amount of
+		 * extra memory is reasonable (limited by the number of TX
+		 * descriptors), the packets do actually get freed quickly by
+		 * new packets almost always, and for protocols like TCP that
+		 * wait for acks to really free up the data the extra memory
+		 * is even less.  On the positive side we run the destructors
+		 * on the sending CPU rather than on a potentially different
+		 * completing CPU, usually a good thing.
+		 *
+		 * Run the destructor before telling the DMA engine about the
+		 * packet to make sure it doesn't complete and get freed
+		 * prematurely.
+		 */
+		struct ulptx_sgl *sgl = (struct ulptx_sgl *)(cpl + 1);
+		struct sge_txq *tq = &txq->q;
+		int last_desc;
+
+		/* If the Work Request header was an exact multiple of our TX
+		 * Descriptor length, then it's possible that the starting SGL
+		 * pointer lines up exactly with the end of our TX Descriptor
+		 * ring.  If that's the case, wrap around to the beginning
+		 * here ...
+		 */
+		if (unlikely((void *)sgl == (void *)tq->stat)) {
+			sgl = (void *)tq->desc;
+			end = (void *)((void *)tq->desc +
+				       ((void *)end - (void *)tq->stat));
+		}
+
+		write_sgl(skb, tq, sgl, end, 0, addr);
+		skb_orphan(skb);
+
+		last_desc = tq->pidx + ndesc - 1;
+		if (last_desc >= tq->size)
+			last_desc -= tq->size;
+		tq->sdesc[last_desc].skb = skb;
+		tq->sdesc[last_desc].sgl = sgl;
+	}
+
+	/* Advance our internal TX Queue state, tell the hardware about
+	 * the new TX descriptors and return success.
+	 */
+	txq_advance(&txq->q, ndesc);
+	dev->trans_start = jiffies;
+	ring_tx_db(adapter, &txq->q, ndesc);
+	return NETDEV_TX_OK;
+
+out_free:
+	/* An error of some sort happened.  Free the TX skb and tell the
+	 * OS that we've "dealt" with the packet ...
+	 */
+	dev_kfree_skb(skb);
+	return NETDEV_TX_OK;
+}
+
 /**
  *	reclaim_completed_tx_imm - reclaim completed control-queue Tx descs
  *	@q: the SGE control Tx queue
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_values.h b/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
index 72ec1f9..7e3ac74 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_values.h
@@ -69,6 +69,8 @@
 
 #define CIDXFLUSHTHRESH_32_X		5
 
+#define IDXSIZE_UNIT_X			64
+
 #define UPDATEDELIVERY_INTERRUPT_X	1
 
 #define RSPD_TYPE_FLBUF_X		0
-- 
2.3.4
