From: Denys Vlasenko <vda.linux@googlemail.com>
Subject: [PATCH] sge.c: stop inlining largish static functions
Date: Mon, 31 Mar 2008 00:15:35 +0200
Message-ID: <200803310015.35283.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_HEB8HmnmeMqnjpr"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755309AbYC3WRd@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_HEB8HmnmeMqnjpr
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Hi Jeff,

Can you take this patch into your net driver fixes tree?

I noticed that drivers/net/cxgb3/sge.c has lots of inlined
static functions.

Some of big inlines are single use, but at least make_sgl()
has two callsites. I didn't check every function after it...

This patch removes "inline" from biggest static function
(regardless of number of callsites - gcc nowadays auto-inlines
statics with one callsite).

Size difference for 32bit x86:

   text    data     bss     dec     hex filename
  14036       0       0   14036    36d4 linux-2.6-ALLYES/drivers/net/cxgb3/sge.o
  13185       0       0   13185    3381 linux-2.6.inline-ALLYES/drivers/net/cxgb3/sge.o

Signed-off-by: Denys Vlasenko <vda.linux@googlemail.com>
--
vda

--Boundary-00=_HEB8HmnmeMqnjpr
Content-Type: text/x-diff;
  charset="us-ascii";
  name="sge_deinline.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="sge_deinline.diff"

diff -urpN -U 10 linux-2.6/drivers/net/cxgb3/sge.c linux-2.6.inline/drivers/net/cxgb3/sge.c
--- linux-2.6/drivers/net/cxgb3/sge.c	2008-03-30 03:27:45.000000000 +0200
+++ linux-2.6.inline/drivers/net/cxgb3/sge.c	2008-03-31 00:10:01.000000000 +0200
@@ -213,21 +213,21 @@ static inline int need_skb_unmap(void)
  *	the SW descriptor state (assorted indices).  The send functions
  *	initialize the indices for the first packet descriptor so we can unmap
  *	the buffers held in the first Tx descriptor here, and we have enough
  *	information at this point to set the state for the next Tx descriptor.
  *
  *	Note that it is possible to clean up the first descriptor of a packet
  *	before the send routines have written the next descriptors, but this
  *	race does not cause any problem.  We just end up writing the unmapping
  *	info for the descriptor first.
  */
-static inline void unmap_skb(struct sk_buff *skb, struct sge_txq *q,
+static void unmap_skb(struct sk_buff *skb, struct sge_txq *q,
 			     unsigned int cidx, struct pci_dev *pdev)
 {
 	const struct sg_ent *sgp;
 	struct tx_sw_desc *d = &q->sdesc[cidx];
 	int nfrags, frag_idx, curflit, j = d->addr_idx;
 
 	sgp = (struct sg_ent *)&q->desc[cidx].flit[d->sflit];
 	frag_idx = d->fragidx;
 
 	if (frag_idx == 0 && skb_headlen(skb)) {
@@ -369,21 +369,21 @@ static void free_rx_bufs(struct pci_dev 
  *	@va:  buffer start VA
  *	@len: the buffer length
  *	@d: the HW Rx descriptor to write
  *	@sd: the SW Rx descriptor to write
  *	@gen: the generation bit value
  *	@pdev: the PCI device associated with the adapter
  *
  *	Add a buffer of the given length to the supplied HW and SW Rx
  *	descriptors.
  */
-static inline void add_one_rx_buf(void *va, unsigned int len,
+static void add_one_rx_buf(void *va, unsigned int len,
 				  struct rx_desc *d, struct rx_sw_desc *sd,
 				  unsigned int gen, struct pci_dev *pdev)
 {
 	dma_addr_t mapping;
 
 	mapping = pci_map_single(pdev, va, len, PCI_DMA_FROMDEVICE);
 	pci_unmap_addr_set(sd, dma_addr, mapping);
 
 	d->addr_lo = cpu_to_be32(mapping);
 	d->addr_hi = cpu_to_be32((u64) mapping >> 32);
@@ -767,39 +767,39 @@ recycle:
 	 */
 	return skb;
 }
 
 /**
  *	get_imm_packet - return the next ingress packet buffer from a response
  *	@resp: the response descriptor containing the packet data
  *
  *	Return a packet containing the immediate data of the given response.
  */
-static inline struct sk_buff *get_imm_packet(const struct rsp_desc *resp)
+static struct sk_buff *get_imm_packet(const struct rsp_desc *resp)
 {
 	struct sk_buff *skb = alloc_skb(IMMED_PKT_SIZE, GFP_ATOMIC);
 
 	if (skb) {
 		__skb_put(skb, IMMED_PKT_SIZE);
 		skb_copy_to_linear_data(skb, resp->imm_data, IMMED_PKT_SIZE);
 	}
 	return skb;
 }
 
 /**
  *	calc_tx_descs - calculate the number of Tx descriptors for a packet
  *	@skb: the packet
  *
  * 	Returns the number of Tx descriptors needed for the given Ethernet
  * 	packet.  Ethernet packets require addition of WR and CPL headers.
  */
-static inline unsigned int calc_tx_descs(const struct sk_buff *skb)
+static unsigned int calc_tx_descs(const struct sk_buff *skb)
 {
 	unsigned int flits;
 
 	if (skb->len <= WR_LEN - sizeof(struct cpl_tx_pkt))
 		return 1;
 
 	flits = sgl_len(skb_shinfo(skb)->nr_frags + 1) + 2;
 	if (skb_shinfo(skb)->gso_size)
 		flits++;
 	return flits_to_desc(flits);
@@ -810,21 +810,21 @@ static inline unsigned int calc_tx_descs
  *	@skb: the packet
  *	@sgp: the SGL to populate
  *	@start: start address of skb main body data to include in the SGL
  *	@len: length of skb main body data to include in the SGL
  *	@pdev: the PCI device
  *
  *	Generates a scatter/gather list for the buffers that make up a packet
  *	and returns the SGL size in 8-byte words.  The caller must size the SGL
  *	appropriately.
  */
-static inline unsigned int make_sgl(const struct sk_buff *skb,
+static unsigned int make_sgl(const struct sk_buff *skb,
 				    struct sg_ent *sgp, unsigned char *start,
 				    unsigned int len, struct pci_dev *pdev)
 {
 	dma_addr_t mapping;
 	unsigned int i, j = 0, nfrags;
 
 	if (len) {
 		mapping = pci_map_single(pdev, start, len, PCI_DMA_TODEVICE);
 		sgp->len[0] = cpu_to_be32(len);
 		sgp->addr[0] = cpu_to_be64(mapping);
@@ -853,21 +853,21 @@ static inline unsigned int make_sgl(cons
  *	@adap: the adapter
  *	@q: the Tx queue
  *
  *	Ring the doorbel if a Tx queue is asleep.  There is a natural race,
  *	where the HW is going to sleep just after we checked, however,
  *	then the interrupt handler will detect the outstanding TX packet
  *	and ring the doorbell for us.
  *
  *	When GTS is disabled we unconditionally ring the doorbell.
  */
-static inline void check_ring_tx_db(struct adapter *adap, struct sge_txq *q)
+static void check_ring_tx_db(struct adapter *adap, struct sge_txq *q)
 {
 #if USE_GTS
 	clear_bit(TXQ_LAST_PKT_DB, &q->flags);
 	if (test_and_set_bit(TXQ_RUNNING, &q->flags) == 0) {
 		set_bit(TXQ_LAST_PKT_DB, &q->flags);
 		t3_write_reg(adap, A_SG_KDOORBELL,
 			     F_SELEGRCNTX | V_EGRCNTX(q->cntxt_id));
 	}
 #else
 	wmb();			/* write descriptors before telling HW */
@@ -1176,21 +1176,21 @@ int t3_eth_xmit(struct sk_buff *skb, str
  *	@d: the Tx descriptor to write
  *	@skb: the packet
  *	@len: the length of packet data to write as immediate data
  *	@gen: the generation bit value to write
  *
  *	Writes a packet as immediate data into a Tx descriptor.  The packet
  *	contains a work request at its beginning.  We must write the packet
  *	carefully so the SGE doesn't read it accidentally before it's written
  *	in its entirety.
  */
-static inline void write_imm(struct tx_desc *d, struct sk_buff *skb,
+static void write_imm(struct tx_desc *d, struct sk_buff *skb,
 			     unsigned int len, unsigned int gen)
 {
 	struct work_request_hdr *from = (struct work_request_hdr *)skb->data;
 	struct work_request_hdr *to = (struct work_request_hdr *)d;
 
 	if (likely(!skb->data_len))
 		memcpy(&to[1], &from[1], len - sizeof(*from));
 	else
 		skb_copy_bits(skb, sizeof(*from), &to[1], len - sizeof(*from));
 
@@ -1214,26 +1214,27 @@ static inline void write_imm(struct tx_d
  *	Checks if the requested number of Tx descriptors is available on an
  *	SGE send queue.  If the queue is already suspended or not enough
  *	descriptors are available the packet is queued for later transmission.
  *	Must be called with the Tx queue locked.
  *
  *	Returns 0 if enough descriptors are available, 1 if there aren't
  *	enough descriptors and the packet has been queued, and 2 if the caller
  *	needs to retry because there weren't enough descriptors at the
  *	beginning of the call but some freed up in the mean time.
  */
-static inline int check_desc_avail(struct adapter *adap, struct sge_txq *q,
+static int check_desc_avail(struct adapter *adap, struct sge_txq *q,
 				   struct sk_buff *skb, unsigned int ndesc,
 				   unsigned int qid)
 {
 	if (unlikely(!skb_queue_empty(&q->sendq))) {
-	      addq_exit:__skb_queue_tail(&q->sendq, skb);
+ addq_exit:
+		__skb_queue_tail(&q->sendq, skb);
 		return 1;
 	}
 	if (unlikely(q->size - q->in_use < ndesc)) {
 		struct sge_qset *qs = txq_to_qset(q, qid);
 
 		set_bit(qid, &qs->txq_stopped);
 		smp_mb__after_clear_bit();
 
 		if (should_restart_tx(q) &&
 		    test_and_clear_bit(qid, &qs->txq_stopped))
@@ -1465,21 +1466,21 @@ static void write_ofld_wr(struct adapter
 			 gen, from->wr_hi, from->wr_lo);
 }
 
 /**
  *	calc_tx_descs_ofld - calculate # of Tx descriptors for an offload packet
  *	@skb: the packet
  *
  * 	Returns the number of Tx descriptors needed for the given offload
  * 	packet.  These packets are already fully constructed.
  */
-static inline unsigned int calc_tx_descs_ofld(const struct sk_buff *skb)
+static unsigned int calc_tx_descs_ofld(const struct sk_buff *skb)
 {
 	unsigned int flits, cnt;
 
 	if (skb->len <= WR_LEN)
 		return 1;	/* packet fits as immediate data */
 
 	flits = skb_transport_offset(skb) / 8;	/* headers */
 	cnt = skb_shinfo(skb)->nr_frags;
 	if (skb->tail != skb->transport_header)
 		cnt++;
@@ -1631,21 +1632,21 @@ int t3_offload_tx(struct t3cdev *tdev, s
 
 /**
  *	offload_enqueue - add an offload packet to an SGE offload receive queue
  *	@q: the SGE response queue
  *	@skb: the packet
  *
  *	Add a new offload packet to an SGE response queue's offload packet
  *	queue.  If the packet is the first on the queue it schedules the RX
  *	softirq to process the queue.
  */
-static inline void offload_enqueue(struct sge_rspq *q, struct sk_buff *skb)
+static void offload_enqueue(struct sge_rspq *q, struct sk_buff *skb)
 {
 	skb->next = skb->prev = NULL;
 	if (q->rx_tail)
 		q->rx_tail->next = skb;
 	else {
 		struct sge_qset *qs = rspq_to_qset(q);
 
 		napi_schedule(&qs->napi);
 		q->rx_head = skb;
 	}
@@ -1735,21 +1736,21 @@ static int ofld_poll(struct napi_struct 
  *	rx_offload - process a received offload packet
  *	@tdev: the offload device receiving the packet
  *	@rq: the response queue that received the packet
  *	@skb: the packet
  *	@rx_gather: a gather list of packets if we are building a bundle
  *	@gather_idx: index of the next available slot in the bundle
  *
  *	Process an ingress offload pakcet and add it to the offload ingress
  *	queue. 	Returns the index of the next available slot in the bundle.
  */
-static inline int rx_offload(struct t3cdev *tdev, struct sge_rspq *rq,
+static int rx_offload(struct t3cdev *tdev, struct sge_rspq *rq,
 			     struct sk_buff *skb, struct sk_buff *rx_gather[],
 			     unsigned int gather_idx)
 {
 	skb_reset_mac_header(skb);
 	skb_reset_network_header(skb);
 	skb_reset_transport_header(skb);
 
 	if (rq->polling) {
 		rx_gather[gather_idx++] = skb;
 		if (gather_idx == RX_BUNDLE_SIZE) {
@@ -1839,21 +1840,21 @@ static void rx_eth(struct adapter *adap,
 
 /**
  *	handle_rsp_cntrl_info - handles control information in a response
  *	@qs: the queue set corresponding to the response
  *	@flags: the response control flags
  *
  *	Handles the control information of an SGE response, such as GTS
  *	indications and completion credits for the queue set's Tx queues.
  *	HW coalesces credits, we don't do any extra SW coalescing.
  */
-static inline void handle_rsp_cntrl_info(struct sge_qset *qs, u32 flags)
+static void handle_rsp_cntrl_info(struct sge_qset *qs, u32 flags)
 {
 	unsigned int credits;
 
 #if USE_GTS
 	if (flags & F_RSPD_TXQ0_GTS)
 		clear_bit(TXQ_RUNNING, &qs->txq[TXQ_ETH].flags);
 #endif
 
 	credits = G_RSPD_TXQ0_CR(flags);
 	if (credits)
@@ -2176,21 +2177,21 @@ static int process_pure_responses(struct
  *	This is used by the NAPI interrupt handlers to decide what to do with
  *	new SGE responses.  If there are no new responses it returns -1.  If
  *	there are new responses and they are pure (i.e., non-data carrying)
  *	it handles them straight in hard interrupt context as they are very
  *	cheap and don't deliver any packets.  Finally, if there are any data
  *	signaling responses it schedules the NAPI handler.  Returns 1 if it
  *	schedules NAPI, 0 if all new responses were pure.
  *
  *	The caller must ascertain NAPI is not already running.
  */
-static inline int handle_responses(struct adapter *adap, struct sge_rspq *q)
+static int handle_responses(struct adapter *adap, struct sge_rspq *q)
 {
 	struct sge_qset *qs = rspq_to_qset(q);
 	struct rsp_desc *r = &q->desc[q->cidx];
 
 	if (!is_new_response(r, q))
 		return -1;
 	if (is_pure_response(r) && process_pure_responses(adap, qs, r) == 0) {
 		t3_write_reg(adap, A_SG_GTS, V_RSPQ(q->cntxt_id) |
 			     V_NEWTIMER(q->holdoff_tmr) | V_NEWINDEX(q->cidx));
 		return 0;
@@ -2305,21 +2306,21 @@ static irqreturn_t t3_intr_msi_napi(int 
 	if (!new_packets && t3_slow_intr_handler(adap) == 0)
 		q->unhandled_irqs++;
 
 	spin_unlock(&q->lock);
 	return IRQ_HANDLED;
 }
 
 /*
  * A helper function that processes responses and issues GTS.
  */
-static inline int process_responses_gts(struct adapter *adap,
+static int process_responses_gts(struct adapter *adap,
 					struct sge_rspq *rq)
 {
 	int work;
 
 	work = process_responses(adap, rspq_to_qset(rq), -1);
 	t3_write_reg(adap, A_SG_GTS, V_RSPQ(rq->cntxt_id) |
 		     V_NEWTIMER(rq->next_holdoff) | V_NEWINDEX(rq->cidx));
 	return work;
 }
 

--Boundary-00=_HEB8HmnmeMqnjpr--
