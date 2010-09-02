From: Cyril Chemparathy <cyril@ti.com>
Subject: [PATCH v2 10/10] net: davinci_emac: cleanup unused cpdma code
Date: Thu,  2 Sep 2010 18:03:28 -0400
Message-ID: <1283465008-18606-11-git-send-email-cyril@ti.com>
References: <1283465008-18606-1-git-send-email-cyril@ti.com>
Cc: davinci-linux-open-source@linux.davincidsp.com,
	linux-omap@vger.kernel.org, nsekhar@ti.com, srk@ti.com,
	omar.ramirez@ti.com, bparrot@ti.com,
	Cyril Chemparathy <cyril@ti.com>
To: netdev@vger.kernel.org
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <1283465008-18606-1-git-send-email-cyril@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Having switched over to the newly introduced cpdma layer, this patch now
removes a whole bunch of code that is now unused.  This patch has been
maintained separate strictly for reasons of readability.

Signed-off-by: Cyril Chemparathy <cyril@ti.com>
---
 drivers/net/davinci_emac.c |  930 --------------------------------------------
 1 files changed, 0 insertions(+), 930 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 4147d32..525b84c 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -127,7 +127,6 @@ static const char emac_version_string[] = "TI DaVinci EMAC Linux v6.1";
 /* EMAC register related defines */
 #define EMAC_ALL_MULTI_REG_VALUE	(0xFFFFFFFF)
 #define EMAC_NUM_MULTICAST_BITS		(64)
-#define EMAC_TEARDOWN_VALUE		(0xFFFFFFFC)
 #define EMAC_TX_CONTROL_TX_ENABLE_VAL	(0x1)
 #define EMAC_RX_CONTROL_RX_ENABLE_VAL	(0x1)
 #define EMAC_MAC_HOST_ERR_INTMASK_VAL	(0x2)
@@ -214,24 +213,10 @@ static const char emac_version_string[] = "TI DaVinci EMAC Linux v6.1";
 #define EMAC_DEF_MAX_MULTICAST_ADDRESSES (64) /* Max mcast addr's */
 
 /* EMAC Peripheral Device Register Memory Layout structure */
-#define EMAC_TXIDVER		0x0
-#define EMAC_TXCONTROL		0x4
-#define EMAC_TXTEARDOWN		0x8
-#define EMAC_RXIDVER		0x10
-#define EMAC_RXCONTROL		0x14
-#define EMAC_RXTEARDOWN		0x18
-#define EMAC_TXINTSTATRAW	0x80
-#define EMAC_TXINTSTATMASKED	0x84
-#define EMAC_TXINTMASKSET	0x88
-#define EMAC_TXINTMASKCLEAR	0x8C
 #define EMAC_MACINVECTOR	0x90
 
 #define EMAC_DM646X_MACEOIVECTOR	0x94
 
-#define EMAC_RXINTSTATRAW	0xA0
-#define EMAC_RXINTSTATMASKED	0xA4
-#define EMAC_RXINTMASKSET	0xA8
-#define EMAC_RXINTMASKCLEAR	0xAC
 #define EMAC_MACINTSTATRAW	0xB0
 #define EMAC_MACINTSTATMASKED	0xB4
 #define EMAC_MACINTMASKSET	0xB8
@@ -258,12 +243,6 @@ static const char emac_version_string[] = "TI DaVinci EMAC Linux v6.1";
 #define EMAC_MACADDRHI		0x504
 #define EMAC_MACINDEX		0x508
 
-/* EMAC HDP and Completion registors */
-#define EMAC_TXHDP(ch)		(0x600 + (ch * 4))
-#define EMAC_RXHDP(ch)		(0x620 + (ch * 4))
-#define EMAC_TXCP(ch)		(0x640 + (ch * 4))
-#define EMAC_RXCP(ch)		(0x660 + (ch * 4))
-
 /* EMAC statistics registers */
 #define EMAC_RXGOODFRAMES	0x200
 #define EMAC_RXBCASTFRAMES	0x204
@@ -328,120 +307,6 @@ static const char emac_version_string[] = "TI DaVinci EMAC Linux v6.1";
 /* EMAC Stats Clear Mask */
 #define EMAC_STATS_CLR_MASK    (0xFFFFFFFF)
 
-/** net_buf_obj: EMAC network bufferdata structure
- *
- * EMAC network buffer data structure
- */
-struct emac_netbufobj {
-	void *buf_token;
-	char *data_ptr;
-	int length;
-};
-
-/** net_pkt_obj: EMAC network packet data structure
- *
- * EMAC network packet data structure - supports buffer list (for future)
- */
-struct emac_netpktobj {
-	void *pkt_token; /* data token may hold tx/rx chan id */
-	struct emac_netbufobj *buf_list; /* array of network buffer objects */
-	int num_bufs;
-	int pkt_length;
-};
-
-/** emac_tx_bd: EMAC TX Buffer descriptor data structure
- *
- * EMAC TX Buffer descriptor data structure
- */
-struct emac_tx_bd {
-	int h_next;
-	int buff_ptr;
-	int off_b_len;
-	int mode; /* SOP, EOP, ownership, EOQ, teardown,Qstarv, length */
-	struct emac_tx_bd __iomem *next;
-	void *buf_token;
-};
-
-/** emac_txch: EMAC TX Channel data structure
- *
- * EMAC TX Channel data structure
- */
-struct emac_txch {
-	/* Config related */
-	u32 num_bd;
-	u32 service_max;
-
-	/* CPPI specific */
-	u32 alloc_size;
-	void __iomem *bd_mem;
-	struct emac_tx_bd __iomem *bd_pool_head;
-	struct emac_tx_bd __iomem *active_queue_head;
-	struct emac_tx_bd __iomem *active_queue_tail;
-	struct emac_tx_bd __iomem *last_hw_bdprocessed;
-	u32 queue_active;
-	u32 teardown_pending;
-	u32 *tx_complete;
-
-	/** statistics */
-	u32 proc_count;     /* TX: # of times emac_tx_bdproc is called */
-	u32 mis_queued_packets;
-	u32 queue_reinit;
-	u32 end_of_queue_add;
-	u32 out_of_tx_bd;
-	u32 no_active_pkts; /* IRQ when there were no packets to process */
-	u32 active_queue_count;
-};
-
-/** emac_rx_bd: EMAC RX Buffer descriptor data structure
- *
- * EMAC RX Buffer descriptor data structure
- */
-struct emac_rx_bd {
-	int h_next;
-	int buff_ptr;
-	int off_b_len;
-	int mode;
-	struct emac_rx_bd __iomem *next;
-	void *data_ptr;
-	void *buf_token;
-};
-
-/** emac_rxch: EMAC RX Channel data structure
- *
- * EMAC RX Channel data structure
- */
-struct emac_rxch {
-	/* configuration info */
-	u32 num_bd;
-	u32 service_max;
-	u32 buf_size;
-	char mac_addr[6];
-
-	/** CPPI specific */
-	u32 alloc_size;
-	void __iomem *bd_mem;
-	struct emac_rx_bd __iomem *bd_pool_head;
-	struct emac_rx_bd __iomem *active_queue_head;
-	struct emac_rx_bd __iomem *active_queue_tail;
-	u32 queue_active;
-	u32 teardown_pending;
-
-	/* packet and buffer objects */
-	struct emac_netpktobj pkt_queue;
-	struct emac_netbufobj buf_queue;
-
-	/** statistics */
-	u32 proc_count; /* number of times emac_rx_bdproc is called */
-	u32 processed_bd;
-	u32 recycled_bd;
-	u32 out_of_rx_bd;
-	u32 out_of_rx_buffers;
-	u32 queue_reinit;
-	u32 end_of_queue_add;
-	u32 end_of_queue;
-	u32 mis_queued_packets;
-};
-
 /* emac_priv: EMAC private data structure
  *
  * EMAC adapter private data structure
@@ -452,17 +317,10 @@ struct emac_priv {
 	struct platform_device *pdev;
 	struct napi_struct napi;
 	char mac_addr[6];
-	spinlock_t tx_lock;
-	spinlock_t rx_lock;
 	void __iomem *remap_addr;
 	u32 emac_base_phys;
 	void __iomem *emac_base;
 	void __iomem *ctrl_base;
-	void __iomem *emac_ctrl_ram;
-	u32 ctrl_ram_size;
-	u32 hw_ram_addr;
-	struct emac_txch *txch[EMAC_DEF_MAX_TX_CH];
-	struct emac_rxch *rxch[EMAC_DEF_MAX_RX_CH];
 	struct cpdma_ctlr *dma;
 	struct cpdma_chan *txchan;
 	struct cpdma_chan *rxchan;
@@ -491,18 +349,6 @@ struct emac_priv {
 static struct clk *emac_clk;
 static unsigned long emac_bus_frequency;
 
-#define emac_virt_to_phys(addr, priv) \
-	(((u32 __force)(addr) - (u32 __force)(priv->emac_ctrl_ram)) \
-	+ priv->hw_ram_addr)
-
-/* Cache macros - Packet buffers would be from skb pool which is cached */
-#define EMAC_VIRT_NOCACHE(addr) (addr)
-
-/* DM644x does not have BD's in cached memory - so no cache functions */
-#define BD_CACHE_INVALIDATE(addr, size)
-#define BD_CACHE_WRITEBACK(addr, size)
-#define BD_CACHE_WRITEBACK_INVALIDATE(addr, size)
-
 /* EMAC TX Host Error description strings */
 static char *emac_txhost_errcodes[16] = {
 	"No error", "SOP error", "Ownership bit not set in SOP buffer",
@@ -545,20 +391,6 @@ static void emac_dump_regs(struct emac_priv *priv)
 			emac_ctrl_read(EMAC_CTRL_EWCTL),
 			emac_ctrl_read(EMAC_CTRL_EWINTTCNT));
 	}
-	dev_info(emac_dev, "EMAC: TXID: %08X %s, RXID: %08X %s\n",
-		emac_read(EMAC_TXIDVER),
-		((emac_read(EMAC_TXCONTROL)) ? "enabled" : "disabled"),
-		emac_read(EMAC_RXIDVER),
-		((emac_read(EMAC_RXCONTROL)) ? "enabled" : "disabled"));
-	dev_info(emac_dev, "EMAC: TXIntRaw:%08X, TxIntMasked: %08X, "\
-		"TxIntMasSet: %08X\n", emac_read(EMAC_TXINTSTATRAW),
-		emac_read(EMAC_TXINTSTATMASKED), emac_read(EMAC_TXINTMASKSET));
-	dev_info(emac_dev, "EMAC: RXIntRaw:%08X, RxIntMasked: %08X, "\
-		"RxIntMasSet: %08X\n", emac_read(EMAC_RXINTSTATRAW),
-		emac_read(EMAC_RXINTSTATMASKED), emac_read(EMAC_RXINTMASKSET));
-	dev_info(emac_dev, "EMAC: MacIntRaw:%08X, MacIntMasked: %08X, "\
-		"MacInVector=%08X\n", emac_read(EMAC_MACINTSTATRAW),
-		emac_read(EMAC_MACINTSTATMASKED), emac_read(EMAC_MACINVECTOR));
 	dev_info(emac_dev, "EMAC: EmuControl:%08X, FifoControl: %08X\n",
 		emac_read(EMAC_EMCONTROL), emac_read(EMAC_FIFOCONTROL));
 	dev_info(emac_dev, "EMAC: MBPEnable:%08X, RXUnicastSet: %08X, "\
@@ -567,8 +399,6 @@ static void emac_dump_regs(struct emac_priv *priv)
 	dev_info(emac_dev, "EMAC: MacControl:%08X, MacStatus: %08X, "\
 		"MacConfig=%08X\n", emac_read(EMAC_MACCONTROL),
 		emac_read(EMAC_MACSTATUS), emac_read(EMAC_MACCONFIG));
-	dev_info(emac_dev, "EMAC: TXHDP[0]:%08X, RXHDP[0]: %08X\n",
-		emac_read(EMAC_TXHDP(0)), emac_read(EMAC_RXHDP(0)));
 	dev_info(emac_dev, "EMAC Statistics\n");
 	dev_info(emac_dev, "EMAC: rx_good_frames:%d\n",
 		emac_read(EMAC_RXGOODFRAMES));
@@ -1208,373 +1038,6 @@ static void emac_tx_handler(void *token, int len, int status)
 	dev_kfree_skb_any(skb);
 }
 
-/** EMAC on-chip buffer descriptor memory
- *
- * WARNING: Please note that the on chip memory is used for both TX and RX
- * buffer descriptor queues and is equally divided between TX and RX desc's
- * If the number of TX or RX descriptors change this memory pointers need
- * to be adjusted. If external memory is allocated then these pointers can
- * pointer to the memory
- *
- */
-#define EMAC_TX_BD_MEM(priv)	((priv)->emac_ctrl_ram)
-#define EMAC_RX_BD_MEM(priv)	((priv)->emac_ctrl_ram + \
-				(((priv)->ctrl_ram_size) >> 1))
-
-/**
- * emac_init_txch: TX channel initialization
- * @priv: The DaVinci EMAC private adapter structure
- * @ch: RX channel number
- *
- * Called during device init to setup a TX channel (allocate buffer desc
- * create free pool and keep ready for transmission
- *
- * Returns success(0) or mem alloc failures error code
- */
-static int emac_init_txch(struct emac_priv *priv, u32 ch)
-{
-	struct device *emac_dev = &priv->ndev->dev;
-	u32 cnt, bd_size;
-	void __iomem *mem;
-	struct emac_tx_bd __iomem *curr_bd;
-	struct emac_txch *txch = NULL;
-
-	txch = kzalloc(sizeof(struct emac_txch), GFP_KERNEL);
-	if (NULL == txch) {
-		dev_err(emac_dev, "DaVinci EMAC: TX Ch mem alloc failed");
-		return -ENOMEM;
-	}
-	priv->txch[ch] = txch;
-	txch->service_max = EMAC_DEF_TX_MAX_SERVICE;
-	txch->active_queue_head = NULL;
-	txch->active_queue_tail = NULL;
-	txch->queue_active = 0;
-	txch->teardown_pending = 0;
-
-	/* allocate memory for TX CPPI channel on a 4 byte boundry */
-	txch->tx_complete = kzalloc(txch->service_max * sizeof(u32),
-				    GFP_KERNEL);
-	if (NULL == txch->tx_complete) {
-		dev_err(emac_dev, "DaVinci EMAC: Tx service mem alloc failed");
-		kfree(txch);
-		return -ENOMEM;
-	}
-
-	/* allocate buffer descriptor pool align every BD on four word
-	 * boundry for future requirements */
-	bd_size = (sizeof(struct emac_tx_bd) + 0xF) & ~0xF;
-	txch->num_bd = (priv->ctrl_ram_size >> 1) / bd_size;
-	txch->alloc_size = (((bd_size * txch->num_bd) + 0xF) & ~0xF);
-
-	/* alloc TX BD memory */
-	txch->bd_mem = EMAC_TX_BD_MEM(priv);
-	__memzero((void __force *)txch->bd_mem, txch->alloc_size);
-
-	/* initialize the BD linked list */
-	mem = (void __force __iomem *)
-			(((u32 __force) txch->bd_mem + 0xF) & ~0xF);
-	txch->bd_pool_head = NULL;
-	for (cnt = 0; cnt < txch->num_bd; cnt++) {
-		curr_bd = mem + (cnt * bd_size);
-		curr_bd->next = txch->bd_pool_head;
-		txch->bd_pool_head = curr_bd;
-	}
-
-	/* reset statistics counters */
-	txch->out_of_tx_bd = 0;
-	txch->no_active_pkts = 0;
-	txch->active_queue_count = 0;
-
-	return 0;
-}
-
-/**
- * emac_cleanup_txch: Book-keep function to clean TX channel resources
- * @priv: The DaVinci EMAC private adapter structure
- * @ch: TX channel number
- *
- * Called to clean up TX channel resources
- *
- */
-static void emac_cleanup_txch(struct emac_priv *priv, u32 ch)
-{
-	struct emac_txch *txch = priv->txch[ch];
-
-	if (txch) {
-		if (txch->bd_mem)
-			txch->bd_mem = NULL;
-		kfree(txch->tx_complete);
-		kfree(txch);
-		priv->txch[ch] = NULL;
-	}
-}
-
-/**
- * emac_net_tx_complete: TX packet completion function
- * @priv: The DaVinci EMAC private adapter structure
- * @net_data_tokens: packet token - skb pointer
- * @num_tokens: number of skb's to free
- * @ch: TX channel number
- *
- * Frees the skb once packet is transmitted
- *
- */
-static int emac_net_tx_complete(struct emac_priv *priv,
-				void **net_data_tokens,
-				int num_tokens, u32 ch)
-{
-	struct net_device *ndev = priv->ndev;
-	u32 cnt;
-
-	if (unlikely(num_tokens && netif_queue_stopped(ndev)))
-		netif_start_queue(ndev);
-	for (cnt = 0; cnt < num_tokens; cnt++) {
-		struct sk_buff *skb = (struct sk_buff *)net_data_tokens[cnt];
-		if (skb == NULL)
-			continue;
-		ndev->stats.tx_packets++;
-		ndev->stats.tx_bytes += skb->len;
-		dev_kfree_skb_any(skb);
-	}
-	return 0;
-}
-
-/**
- * emac_txch_teardown: TX channel teardown
- * @priv: The DaVinci EMAC private adapter structure
- * @ch: TX channel number
- *
- * Called to teardown TX channel
- *
- */
-static void emac_txch_teardown(struct emac_priv *priv, u32 ch)
-{
-	struct device *emac_dev = &priv->ndev->dev;
-	u32 teardown_cnt = 0xFFFFFFF0; /* Some high value */
-	struct emac_txch *txch = priv->txch[ch];
-	struct emac_tx_bd __iomem *curr_bd;
-
-	while ((emac_read(EMAC_TXCP(ch)) & EMAC_TEARDOWN_VALUE) !=
-	       EMAC_TEARDOWN_VALUE) {
-		/* wait till tx teardown complete */
-		cpu_relax(); /* TODO: check if this helps ... */
-		--teardown_cnt;
-		if (0 == teardown_cnt) {
-			dev_err(emac_dev, "EMAC: TX teardown aborted\n");
-			break;
-		}
-	}
-	emac_write(EMAC_TXCP(ch), EMAC_TEARDOWN_VALUE);
-
-	/* process sent packets and return skb's to upper layer */
-	if (1 == txch->queue_active) {
-		curr_bd = txch->active_queue_head;
-		while (curr_bd != NULL) {
-			dma_unmap_single(emac_dev, curr_bd->buff_ptr,
-				curr_bd->off_b_len & EMAC_RX_BD_BUF_SIZE,
-				DMA_TO_DEVICE);
-
-			emac_net_tx_complete(priv, (void __force *)
-					&curr_bd->buf_token, 1, ch);
-			if (curr_bd != txch->active_queue_tail)
-				curr_bd = curr_bd->next;
-			else
-				break;
-		}
-		txch->bd_pool_head = txch->active_queue_head;
-		txch->active_queue_head =
-		txch->active_queue_tail = NULL;
-	}
-}
-
-/**
- * emac_stop_txch: Stop TX channel operation
- * @priv: The DaVinci EMAC private adapter structure
- * @ch: TX channel number
- *
- * Called to stop TX channel operation
- *
- */
-static void emac_stop_txch(struct emac_priv *priv, u32 ch)
-{
-	struct emac_txch *txch = priv->txch[ch];
-
-	if (txch) {
-		txch->teardown_pending = 1;
-		emac_write(EMAC_TXTEARDOWN, 0);
-		emac_txch_teardown(priv, ch);
-		txch->teardown_pending = 0;
-		emac_write(EMAC_TXINTMASKCLEAR, BIT(ch));
-	}
-}
-
-/**
- * emac_tx_bdproc: TX buffer descriptor (packet) processing
- * @priv: The DaVinci EMAC private adapter structure
- * @ch: TX channel number to process buffer descriptors for
- * @budget: number of packets allowed to process
- * @pending: indication to caller that packets are pending to process
- *
- * Processes TX buffer descriptors after packets are transmitted - checks
- * ownership bit on the TX * descriptor and requeues it to free pool & frees
- * the SKB buffer. Only "budget" number of packets are processed and
- * indication of pending packets provided to the caller
- *
- * Returns number of packets processed
- */
-static int emac_tx_bdproc(struct emac_priv *priv, u32 ch, u32 budget)
-{
-	struct device *emac_dev = &priv->ndev->dev;
-	unsigned long flags;
-	u32 frame_status;
-	u32 pkts_processed = 0;
-	u32 tx_complete_cnt = 0;
-	struct emac_tx_bd __iomem *curr_bd;
-	struct emac_txch *txch = priv->txch[ch];
-	u32 *tx_complete_ptr = txch->tx_complete;
-
-	if (unlikely(1 == txch->teardown_pending)) {
-		if (netif_msg_tx_err(priv) && net_ratelimit()) {
-			dev_err(emac_dev, "DaVinci EMAC:emac_tx_bdproc: "\
-				"teardown pending\n");
-		}
-		return 0;  /* dont handle any pkt completions */
-	}
-
-	++txch->proc_count;
-	spin_lock_irqsave(&priv->tx_lock, flags);
-	curr_bd = txch->active_queue_head;
-	if (NULL == curr_bd) {
-		emac_write(EMAC_TXCP(ch),
-			   emac_virt_to_phys(txch->last_hw_bdprocessed, priv));
-		txch->no_active_pkts++;
-		spin_unlock_irqrestore(&priv->tx_lock, flags);
-		return 0;
-	}
-	BD_CACHE_INVALIDATE(curr_bd, EMAC_BD_LENGTH_FOR_CACHE);
-	frame_status = curr_bd->mode;
-	while ((curr_bd) &&
-	      ((frame_status & EMAC_CPPI_OWNERSHIP_BIT) == 0) &&
-	      (pkts_processed < budget)) {
-		emac_write(EMAC_TXCP(ch), emac_virt_to_phys(curr_bd, priv));
-		txch->active_queue_head = curr_bd->next;
-		if (frame_status & EMAC_CPPI_EOQ_BIT) {
-			if (curr_bd->next) {	/* misqueued packet */
-				emac_write(EMAC_TXHDP(ch), curr_bd->h_next);
-				++txch->mis_queued_packets;
-			} else {
-				txch->queue_active = 0; /* end of queue */
-			}
-		}
-
-		dma_unmap_single(emac_dev, curr_bd->buff_ptr,
-				curr_bd->off_b_len & EMAC_RX_BD_BUF_SIZE,
-				DMA_TO_DEVICE);
-
-		*tx_complete_ptr = (u32) curr_bd->buf_token;
-		++tx_complete_ptr;
-		++tx_complete_cnt;
-		curr_bd->next = txch->bd_pool_head;
-		txch->bd_pool_head = curr_bd;
-		--txch->active_queue_count;
-		pkts_processed++;
-		txch->last_hw_bdprocessed = curr_bd;
-		curr_bd = txch->active_queue_head;
-		if (curr_bd) {
-			BD_CACHE_INVALIDATE(curr_bd, EMAC_BD_LENGTH_FOR_CACHE);
-			frame_status = curr_bd->mode;
-		}
-	} /* end of pkt processing loop */
-
-	emac_net_tx_complete(priv,
-			     (void *)&txch->tx_complete[0],
-			     tx_complete_cnt, ch);
-	spin_unlock_irqrestore(&priv->tx_lock, flags);
-	return pkts_processed;
-}
-
-#define EMAC_ERR_TX_OUT_OF_BD -1
-
-/**
- * emac_send: EMAC Transmit function (internal)
- * @priv: The DaVinci EMAC private adapter structure
- * @pkt: packet pointer (contains skb ptr)
- * @ch: TX channel number
- *
- * Called by the transmit function to queue the packet in EMAC hardware queue
- *
- * Returns success(0) or error code (typically out of desc's)
- */
-static int emac_send(struct emac_priv *priv, struct emac_netpktobj *pkt, u32 ch)
-{
-	unsigned long flags;
-	struct emac_tx_bd __iomem *curr_bd;
-	struct emac_txch *txch;
-	struct emac_netbufobj *buf_list;
-
-	txch = priv->txch[ch];
-	buf_list = pkt->buf_list;   /* get handle to the buffer array */
-
-	/* check packet size and pad if short */
-	if (pkt->pkt_length < EMAC_DEF_MIN_ETHPKTSIZE) {
-		buf_list->length += (EMAC_DEF_MIN_ETHPKTSIZE - pkt->pkt_length);
-		pkt->pkt_length = EMAC_DEF_MIN_ETHPKTSIZE;
-	}
-
-	spin_lock_irqsave(&priv->tx_lock, flags);
-	curr_bd = txch->bd_pool_head;
-	if (curr_bd == NULL) {
-		txch->out_of_tx_bd++;
-		spin_unlock_irqrestore(&priv->tx_lock, flags);
-		return EMAC_ERR_TX_OUT_OF_BD;
-	}
-
-	txch->bd_pool_head = curr_bd->next;
-	curr_bd->buf_token = buf_list->buf_token;
-	curr_bd->buff_ptr = dma_map_single(&priv->ndev->dev, buf_list->data_ptr,
-			buf_list->length, DMA_TO_DEVICE);
-	curr_bd->off_b_len = buf_list->length;
-	curr_bd->h_next = 0;
-	curr_bd->next = NULL;
-	curr_bd->mode = (EMAC_CPPI_SOP_BIT | EMAC_CPPI_OWNERSHIP_BIT |
-			 EMAC_CPPI_EOP_BIT | pkt->pkt_length);
-
-	/* flush the packet from cache if write back cache is present */
-	BD_CACHE_WRITEBACK_INVALIDATE(curr_bd, EMAC_BD_LENGTH_FOR_CACHE);
-
-	/* send the packet */
-	if (txch->active_queue_head == NULL) {
-		txch->active_queue_head = curr_bd;
-		txch->active_queue_tail = curr_bd;
-		if (1 != txch->queue_active) {
-			emac_write(EMAC_TXHDP(ch),
-					emac_virt_to_phys(curr_bd, priv));
-			txch->queue_active = 1;
-		}
-		++txch->queue_reinit;
-	} else {
-		register struct emac_tx_bd __iomem *tail_bd;
-		register u32 frame_status;
-
-		tail_bd = txch->active_queue_tail;
-		tail_bd->next = curr_bd;
-		txch->active_queue_tail = curr_bd;
-		tail_bd = EMAC_VIRT_NOCACHE(tail_bd);
-		tail_bd->h_next = (int)emac_virt_to_phys(curr_bd, priv);
-		frame_status = tail_bd->mode;
-		if (frame_status & EMAC_CPPI_EOQ_BIT) {
-			emac_write(EMAC_TXHDP(ch),
-				emac_virt_to_phys(curr_bd, priv));
-			frame_status &= ~(EMAC_CPPI_EOQ_BIT);
-			tail_bd->mode = frame_status;
-			++txch->end_of_queue_add;
-		}
-	}
-	txch->active_queue_count++;
-	spin_unlock_irqrestore(&priv->tx_lock, flags);
-	return 0;
-}
-
 /**
  * emac_dev_xmit: EMAC Transmit function
  * @skb: SKB pointer
@@ -1647,207 +1110,6 @@ static void emac_dev_tx_timeout(struct net_device *ndev)
 }
 
 /**
- * emac_net_alloc_rx_buf: Allocate a skb for RX
- * @priv: The DaVinci EMAC private adapter structure
- * @buf_size: size of SKB data buffer to allocate
- * @data_token: data token returned (skb handle for storing in buffer desc)
- * @ch: RX channel number
- *
- * Called during RX channel setup - allocates skb buffer of required size
- * and provides the skb handle and allocated buffer data pointer to caller
- *
- * Returns skb data pointer or 0 on failure to alloc skb
- */
-static void *emac_net_alloc_rx_buf(struct emac_priv *priv, int buf_size,
-		void **data_token, u32 ch)
-{
-	struct net_device *ndev = priv->ndev;
-	struct device *emac_dev = &ndev->dev;
-	struct sk_buff *p_skb;
-
-	p_skb = dev_alloc_skb(buf_size);
-	if (unlikely(NULL == p_skb)) {
-		if (netif_msg_rx_err(priv) && net_ratelimit())
-			dev_err(emac_dev, "DaVinci EMAC: failed to alloc skb");
-		return NULL;
-	}
-
-	/* set device pointer in skb and reserve space for extra bytes */
-	p_skb->dev = ndev;
-	skb_reserve(p_skb, NET_IP_ALIGN);
-	*data_token = (void *) p_skb;
-	return p_skb->data;
-}
-
-/**
- * emac_init_rxch: RX channel initialization
- * @priv: The DaVinci EMAC private adapter structure
- * @ch: RX channel number
- * @param: mac address for RX channel
- *
- * Called during device init to setup a RX channel (allocate buffers and
- * buffer descriptors, create queue and keep ready for reception
- *
- * Returns success(0) or mem alloc failures error code
- */
-static int emac_init_rxch(struct emac_priv *priv, u32 ch, char *param)
-{
-	struct device *emac_dev = &priv->ndev->dev;
-	u32 cnt, bd_size;
-	void __iomem *mem;
-	struct emac_rx_bd __iomem *curr_bd;
-	struct emac_rxch *rxch = NULL;
-
-	rxch = kzalloc(sizeof(struct emac_rxch), GFP_KERNEL);
-	if (NULL == rxch) {
-		dev_err(emac_dev, "DaVinci EMAC: RX Ch mem alloc failed");
-		return -ENOMEM;
-	}
-	priv->rxch[ch] = rxch;
-	rxch->buf_size = priv->rx_buf_size;
-	rxch->service_max = EMAC_DEF_RX_MAX_SERVICE;
-	rxch->queue_active = 0;
-	rxch->teardown_pending = 0;
-
-	/* save mac address */
-	for (cnt = 0; cnt < 6; cnt++)
-		rxch->mac_addr[cnt] = param[cnt];
-
-	/* allocate buffer descriptor pool align every BD on four word
-	 * boundry for future requirements */
-	bd_size = (sizeof(struct emac_rx_bd) + 0xF) & ~0xF;
-	rxch->num_bd = (priv->ctrl_ram_size >> 1) / bd_size;
-	rxch->alloc_size = (((bd_size * rxch->num_bd) + 0xF) & ~0xF);
-	rxch->bd_mem = EMAC_RX_BD_MEM(priv);
-	__memzero((void __force *)rxch->bd_mem, rxch->alloc_size);
-	rxch->pkt_queue.buf_list = &rxch->buf_queue;
-
-	/* allocate RX buffer and initialize the BD linked list */
-	mem = (void __force __iomem *)
-			(((u32 __force) rxch->bd_mem + 0xF) & ~0xF);
-	rxch->active_queue_head = NULL;
-	rxch->active_queue_tail = mem;
-	for (cnt = 0; cnt < rxch->num_bd; cnt++) {
-		curr_bd = mem + (cnt * bd_size);
-		/* for future use the last parameter contains the BD ptr */
-		curr_bd->data_ptr = emac_net_alloc_rx_buf(priv,
-				    rxch->buf_size,
-				    (void __force **)&curr_bd->buf_token,
-				    EMAC_DEF_RX_CH);
-		if (curr_bd->data_ptr == NULL) {
-			dev_err(emac_dev, "DaVinci EMAC: RX buf mem alloc " \
-				"failed for ch %d\n", ch);
-			kfree(rxch);
-			return -ENOMEM;
-		}
-
-		/* populate the hardware descriptor */
-		curr_bd->h_next = emac_virt_to_phys(rxch->active_queue_head,
-				priv);
-		curr_bd->buff_ptr = dma_map_single(emac_dev, curr_bd->data_ptr,
-				rxch->buf_size, DMA_FROM_DEVICE);
-		curr_bd->off_b_len = rxch->buf_size;
-		curr_bd->mode = EMAC_CPPI_OWNERSHIP_BIT;
-
-		/* write back to hardware memory */
-		BD_CACHE_WRITEBACK_INVALIDATE((u32) curr_bd,
-					      EMAC_BD_LENGTH_FOR_CACHE);
-		curr_bd->next = rxch->active_queue_head;
-		rxch->active_queue_head = curr_bd;
-	}
-
-	/* At this point rxCppi->activeQueueHead points to the first
-	   RX BD ready to be given to RX HDP and rxch->active_queue_tail
-	   points to the last RX BD
-	 */
-	return 0;
-}
-
-/**
- * emac_rxch_teardown: RX channel teardown
- * @priv: The DaVinci EMAC private adapter structure
- * @ch: RX channel number
- *
- * Called during device stop to teardown RX channel
- *
- */
-static void emac_rxch_teardown(struct emac_priv *priv, u32 ch)
-{
-	struct device *emac_dev = &priv->ndev->dev;
-	u32 teardown_cnt = 0xFFFFFFF0; /* Some high value */
-
-	while ((emac_read(EMAC_RXCP(ch)) & EMAC_TEARDOWN_VALUE) !=
-	       EMAC_TEARDOWN_VALUE) {
-		/* wait till tx teardown complete */
-		cpu_relax(); /* TODO: check if this helps ... */
-		--teardown_cnt;
-		if (0 == teardown_cnt) {
-			dev_err(emac_dev, "EMAC: RX teardown aborted\n");
-			break;
-		}
-	}
-	emac_write(EMAC_RXCP(ch), EMAC_TEARDOWN_VALUE);
-}
-
-/**
- * emac_stop_rxch: Stop RX channel operation
- * @priv: The DaVinci EMAC private adapter structure
- * @ch: RX channel number
- *
- * Called during device stop to stop RX channel operation
- *
- */
-static void emac_stop_rxch(struct emac_priv *priv, u32 ch)
-{
-	struct emac_rxch *rxch = priv->rxch[ch];
-
-	if (rxch) {
-		rxch->teardown_pending = 1;
-		emac_write(EMAC_RXTEARDOWN, ch);
-		/* wait for teardown complete */
-		emac_rxch_teardown(priv, ch);
-		rxch->teardown_pending = 0;
-		emac_write(EMAC_RXINTMASKCLEAR, BIT(ch));
-	}
-}
-
-/**
- * emac_cleanup_rxch: Book-keep function to clean RX channel resources
- * @priv: The DaVinci EMAC private adapter structure
- * @ch: RX channel number
- *
- * Called during device stop to clean up RX channel resources
- *
- */
-static void emac_cleanup_rxch(struct emac_priv *priv, u32 ch)
-{
-	struct emac_rxch *rxch = priv->rxch[ch];
-	struct emac_rx_bd __iomem *curr_bd;
-
-	if (rxch) {
-		/* free the receive buffers previously allocated */
-		curr_bd = rxch->active_queue_head;
-		while (curr_bd) {
-			if (curr_bd->buf_token) {
-				dma_unmap_single(&priv->ndev->dev,
-					curr_bd->buff_ptr,
-					curr_bd->off_b_len
-						& EMAC_RX_BD_BUF_SIZE,
-					DMA_FROM_DEVICE);
-
-				dev_kfree_skb_any((struct sk_buff *)\
-						  curr_bd->buf_token);
-			}
-			curr_bd = curr_bd->next;
-		}
-		if (rxch->bd_mem)
-			rxch->bd_mem = NULL;
-		kfree(rxch);
-		priv->rxch[ch] = NULL;
-	}
-}
-
-/**
  * emac_set_type0addr: Set EMAC Type0 mac address
  * @priv: The DaVinci EMAC private adapter structure
  * @ch: RX channel number
@@ -1987,194 +1249,6 @@ static int emac_dev_setmac_addr(struct net_device *ndev, void *addr)
 }
 
 /**
- * emac_addbd_to_rx_queue: Recycle RX buffer descriptor
- * @priv: The DaVinci EMAC private adapter structure
- * @ch: RX channel number to process buffer descriptors for
- * @curr_bd: current buffer descriptor
- * @buffer: buffer pointer for descriptor
- * @buf_token: buffer token (stores skb information)
- *
- * Prepares the recycled buffer descriptor and addes it to hardware
- * receive queue - if queue empty this descriptor becomes the head
- * else addes the descriptor to end of queue
- *
- */
-static void emac_addbd_to_rx_queue(struct emac_priv *priv, u32 ch,
-		struct emac_rx_bd __iomem *curr_bd,
-		char *buffer, void *buf_token)
-{
-	struct emac_rxch *rxch = priv->rxch[ch];
-
-	/* populate the hardware descriptor */
-	curr_bd->h_next = 0;
-	curr_bd->buff_ptr = dma_map_single(&priv->ndev->dev, buffer,
-				rxch->buf_size, DMA_FROM_DEVICE);
-	curr_bd->off_b_len = rxch->buf_size;
-	curr_bd->mode = EMAC_CPPI_OWNERSHIP_BIT;
-	curr_bd->next = NULL;
-	curr_bd->data_ptr = buffer;
-	curr_bd->buf_token = buf_token;
-
-	/* write back  */
-	BD_CACHE_WRITEBACK_INVALIDATE(curr_bd, EMAC_BD_LENGTH_FOR_CACHE);
-	if (rxch->active_queue_head == NULL) {
-		rxch->active_queue_head = curr_bd;
-		rxch->active_queue_tail = curr_bd;
-		if (0 != rxch->queue_active) {
-			emac_write(EMAC_RXHDP(ch),
-			   emac_virt_to_phys(rxch->active_queue_head, priv));
-			rxch->queue_active = 1;
-		}
-	} else {
-		struct emac_rx_bd __iomem *tail_bd;
-		u32 frame_status;
-
-		tail_bd = rxch->active_queue_tail;
-		rxch->active_queue_tail = curr_bd;
-		tail_bd->next = curr_bd;
-		tail_bd = EMAC_VIRT_NOCACHE(tail_bd);
-		tail_bd->h_next = emac_virt_to_phys(curr_bd, priv);
-		frame_status = tail_bd->mode;
-		if (frame_status & EMAC_CPPI_EOQ_BIT) {
-			emac_write(EMAC_RXHDP(ch),
-					emac_virt_to_phys(curr_bd, priv));
-			frame_status &= ~(EMAC_CPPI_EOQ_BIT);
-			tail_bd->mode = frame_status;
-			++rxch->end_of_queue_add;
-		}
-	}
-	++rxch->recycled_bd;
-}
-
-/**
- * emac_net_rx_cb: Prepares packet and sends to upper layer
- * @priv: The DaVinci EMAC private adapter structure
- * @net_pkt_list: Network packet list (received packets)
- *
- * Invalidates packet buffer memory and sends the received packet to upper
- * layer
- *
- * Returns success or appropriate error code (none as of now)
- */
-static int emac_net_rx_cb(struct emac_priv *priv,
-			  struct emac_netpktobj *net_pkt_list)
-{
-	struct net_device *ndev = priv->ndev;
-	struct sk_buff *p_skb = net_pkt_list->pkt_token;
-	/* set length of packet */
-	skb_put(p_skb, net_pkt_list->pkt_length);
-	p_skb->protocol = eth_type_trans(p_skb, priv->ndev);
-	netif_receive_skb(p_skb);
-	ndev->stats.rx_bytes += net_pkt_list->pkt_length;
-	ndev->stats.rx_packets++;
-	return 0;
-}
-
-/**
- * emac_rx_bdproc: RX buffer descriptor (packet) processing
- * @priv: The DaVinci EMAC private adapter structure
- * @ch: RX channel number to process buffer descriptors for
- * @budget: number of packets allowed to process
- * @pending: indication to caller that packets are pending to process
- *
- * Processes RX buffer descriptors - checks ownership bit on the RX buffer
- * descriptor, sends the receive packet to upper layer, allocates a new SKB
- * and recycles the buffer descriptor (requeues it in hardware RX queue).
- * Only "budget" number of packets are processed and indication of pending
- * packets provided to the caller.
- *
- * Returns number of packets processed (and indication of pending packets)
- */
-static int emac_rx_bdproc(struct emac_priv *priv, u32 ch, u32 budget)
-{
-	unsigned long flags;
-	u32 frame_status;
-	u32 pkts_processed = 0;
-	char *new_buffer;
-	struct emac_rx_bd __iomem *curr_bd;
-	struct emac_rx_bd __iomem *last_bd;
-	struct emac_netpktobj *curr_pkt, pkt_obj;
-	struct emac_netbufobj buf_obj;
-	struct emac_netbufobj *rx_buf_obj;
-	void *new_buf_token;
-	struct emac_rxch *rxch = priv->rxch[ch];
-
-	if (unlikely(1 == rxch->teardown_pending))
-		return 0;
-	++rxch->proc_count;
-	spin_lock_irqsave(&priv->rx_lock, flags);
-	pkt_obj.buf_list = &buf_obj;
-	curr_pkt = &pkt_obj;
-	curr_bd = rxch->active_queue_head;
-	BD_CACHE_INVALIDATE(curr_bd, EMAC_BD_LENGTH_FOR_CACHE);
-	frame_status = curr_bd->mode;
-
-	while ((curr_bd) &&
-	       ((frame_status & EMAC_CPPI_OWNERSHIP_BIT) == 0) &&
-	       (pkts_processed < budget)) {
-
-		new_buffer = emac_net_alloc_rx_buf(priv, rxch->buf_size,
-					&new_buf_token, EMAC_DEF_RX_CH);
-		if (unlikely(NULL == new_buffer)) {
-			++rxch->out_of_rx_buffers;
-			goto end_emac_rx_bdproc;
-		}
-
-		/* populate received packet data structure */
-		rx_buf_obj = &curr_pkt->buf_list[0];
-		rx_buf_obj->data_ptr = (char *)curr_bd->data_ptr;
-		rx_buf_obj->length = curr_bd->off_b_len & EMAC_RX_BD_BUF_SIZE;
-		rx_buf_obj->buf_token = curr_bd->buf_token;
-
-		dma_unmap_single(&priv->ndev->dev, curr_bd->buff_ptr,
-				curr_bd->off_b_len & EMAC_RX_BD_BUF_SIZE,
-				DMA_FROM_DEVICE);
-
-		curr_pkt->pkt_token = curr_pkt->buf_list->buf_token;
-		curr_pkt->num_bufs = 1;
-		curr_pkt->pkt_length =
-			(frame_status & EMAC_RX_BD_PKT_LENGTH_MASK);
-		emac_write(EMAC_RXCP(ch), emac_virt_to_phys(curr_bd, priv));
-		++rxch->processed_bd;
-		last_bd = curr_bd;
-		curr_bd = last_bd->next;
-		rxch->active_queue_head = curr_bd;
-
-		/* check if end of RX queue ? */
-		if (frame_status & EMAC_CPPI_EOQ_BIT) {
-			if (curr_bd) {
-				++rxch->mis_queued_packets;
-				emac_write(EMAC_RXHDP(ch),
-					   emac_virt_to_phys(curr_bd, priv));
-			} else {
-				++rxch->end_of_queue;
-				rxch->queue_active = 0;
-			}
-		}
-
-		/* recycle BD */
-		emac_addbd_to_rx_queue(priv, ch, last_bd, new_buffer,
-				       new_buf_token);
-
-		/* return the packet to the user - BD ptr passed in
-		 * last parameter for potential *future* use */
-		spin_unlock_irqrestore(&priv->rx_lock, flags);
-		emac_net_rx_cb(priv, curr_pkt);
-		spin_lock_irqsave(&priv->rx_lock, flags);
-		curr_bd = rxch->active_queue_head;
-		if (curr_bd) {
-			BD_CACHE_INVALIDATE(curr_bd, EMAC_BD_LENGTH_FOR_CACHE);
-			frame_status = curr_bd->mode;
-		}
-		++pkts_processed;
-	}
-
-end_emac_rx_bdproc:
-	spin_unlock_irqrestore(&priv->rx_lock, flags);
-	return pkts_processed;
-}
-
-/**
  * emac_hw_enable: Enable EMAC hardware for packet transmission/reception
  * @priv: The DaVinci EMAC private adapter structure
  *
@@ -2700,8 +1774,6 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 	priv->ndev = ndev;
 	priv->msg_enable = netif_msg_init(debug_level, DAVINCI_EMAC_DEBUG);
 
-	spin_lock_init(&priv->tx_lock);
-	spin_lock_init(&priv->rx_lock);
 	spin_lock_init(&priv->lock);
 
 	pdata = pdev->dev.platform_data;
@@ -2749,8 +1821,6 @@ static int __devinit davinci_emac_probe(struct platform_device *pdev)
 	ndev->base_addr = (unsigned long)priv->remap_addr;
 
 	priv->ctrl_base = priv->remap_addr + pdata->ctrl_mod_reg_offset;
-	priv->ctrl_ram_size = pdata->ctrl_ram_size;
-	priv->emac_ctrl_ram = priv->remap_addr + pdata->ctrl_ram_offset;
 
 	hw_ram_addr = pdata->hw_ram_addr;
 	if (!hw_ram_addr)
-- 
1.7.0.4

