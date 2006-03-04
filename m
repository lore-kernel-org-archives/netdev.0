From: Eric Sesterhenn <snakebyte@gmx.de>
Subject: [KJ] [Patch] kzalloc() conversion in drivers/net
Date: Sat, 04 Mar 2006 18:56:53 +0100
Message-ID: <1141495013.20870.2.camel@alice>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============27799367002343778=="
Cc: netdev@vger.kernel.org
Return-path: <kernel-janitors-bounces@lists.osdl.org>
To: kernel-janitors@lists.osdl.org
List-Unsubscribe: <https://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/kernel-janitors>
List-Post: <mailto:kernel-janitors@lists.osdl.org>
List-Help: <mailto:kernel-janitors-request@lists.osdl.org?subject=help>
List-Subscribe: <https://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=subscribe>
Sender: kernel-janitors-bounces@lists.osdl.org
Errors-To: kernel-janitors-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============27799367002343778==
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

hi,

this patch converts drivers/net to kzalloc usage.
Compile tested with allyes config.

It also fixes a bug in drivers/net/chelsio/espi.c, because
it called the memset() before checking if kmalloc failed.

Signed-off-by: Eric Sesterhenn <snakebyte@gmx.de>

--- linux-2.6.16-rc5-mm1/drivers/net/e1000/e1000_ethtool.c.orig	2006-03-02 14:24:18.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/e1000/e1000_ethtool.c	2006-03-02 14:24:59.000000000 +0100
@@ -638,20 +638,18 @@ e1000_set_ringparam(struct net_device *n
 	tx_old = adapter->tx_ring;
 	rx_old = adapter->rx_ring;
 
-	adapter->tx_ring = kmalloc(tx_ring_size, GFP_KERNEL);
+	adapter->tx_ring = kzalloc(tx_ring_size, GFP_KERNEL);
 	if (!adapter->tx_ring) {
 		err = -ENOMEM;
 		goto err_setup_rx;
 	}
-	memset(adapter->tx_ring, 0, tx_ring_size);
 
-	adapter->rx_ring = kmalloc(rx_ring_size, GFP_KERNEL);
+	adapter->rx_ring = kzalloc(rx_ring_size, GFP_KERNEL);
 	if (!adapter->rx_ring) {
 		kfree(adapter->tx_ring);
 		err = -ENOMEM;
 		goto err_setup_rx;
 	}
-	memset(adapter->rx_ring, 0, rx_ring_size);
 
 	txdr = adapter->tx_ring;
 	rxdr = adapter->rx_ring;
@@ -1017,11 +1015,10 @@ e1000_setup_desc_rings(struct e1000_adap
 		txdr->count = E1000_DEFAULT_TXD;
 
 	size = txdr->count * sizeof(struct e1000_buffer);
-	if (!(txdr->buffer_info = kmalloc(size, GFP_KERNEL))) {
+	if (!(txdr->buffer_info = kzalloc(size, GFP_KERNEL))) {
 		ret_val = 1;
 		goto err_nomem;
 	}
-	memset(txdr->buffer_info, 0, size);
 
 	txdr->size = txdr->count * sizeof(struct e1000_tx_desc);
 	E1000_ROUNDUP(txdr->size, 4096);
@@ -1073,11 +1070,10 @@ e1000_setup_desc_rings(struct e1000_adap
 		rxdr->count = E1000_DEFAULT_RXD;
 
 	size = rxdr->count * sizeof(struct e1000_buffer);
-	if (!(rxdr->buffer_info = kmalloc(size, GFP_KERNEL))) {
+	if (!(rxdr->buffer_info = kzalloc(size, GFP_KERNEL))) {
 		ret_val = 4;
 		goto err_nomem;
 	}
-	memset(rxdr->buffer_info, 0, size);
 
 	rxdr->size = rxdr->count * sizeof(struct e1000_rx_desc);
 	if (!(rxdr->desc = pci_alloc_consistent(pdev, rxdr->size, &rxdr->dma))) {
--- linux-2.6.16-rc5-mm1/drivers/net/e1000/e1000_main.c.orig	2006-03-02 14:25:05.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/e1000/e1000_main.c	2006-03-02 14:26:09.000000000 +0100
@@ -1114,28 +1114,25 @@ e1000_alloc_queues(struct e1000_adapter 
 	int size;
 
 	size = sizeof(struct e1000_tx_ring) * adapter->num_tx_queues;
-	adapter->tx_ring = kmalloc(size, GFP_KERNEL);
+	adapter->tx_ring = kzalloc(size, GFP_KERNEL);
 	if (!adapter->tx_ring)
 		return -ENOMEM;
-	memset(adapter->tx_ring, 0, size);
 
 	size = sizeof(struct e1000_rx_ring) * adapter->num_rx_queues;
-	adapter->rx_ring = kmalloc(size, GFP_KERNEL);
+	adapter->rx_ring = kzalloc(size, GFP_KERNEL);
 	if (!adapter->rx_ring) {
 		kfree(adapter->tx_ring);
 		return -ENOMEM;
 	}
-	memset(adapter->rx_ring, 0, size);
 
 #ifdef CONFIG_E1000_NAPI
 	size = sizeof(struct net_device) * adapter->num_rx_queues;
-	adapter->polling_netdev = kmalloc(size, GFP_KERNEL);
+	adapter->polling_netdev = kzalloc(size, GFP_KERNEL);
 	if (!adapter->polling_netdev) {
 		kfree(adapter->tx_ring);
 		kfree(adapter->rx_ring);
 		return -ENOMEM;
 	}
-	memset(adapter->polling_netdev, 0, size);
 #endif
 
 #ifdef CONFIG_E1000_MQ
@@ -1544,17 +1541,16 @@ e1000_setup_rx_resources(struct e1000_ad
 	memset(rxdr->buffer_info, 0, size);
 
 	size = sizeof(struct e1000_ps_page) * rxdr->count;
-	rxdr->ps_page = kmalloc(size, GFP_KERNEL);
+	rxdr->ps_page = kzalloc(size, GFP_KERNEL);
 	if (!rxdr->ps_page) {
 		vfree(rxdr->buffer_info);
 		DPRINTK(PROBE, ERR,
 		"Unable to allocate memory for the receive descriptor ring\n");
 		return -ENOMEM;
 	}
-	memset(rxdr->ps_page, 0, size);
 
 	size = sizeof(struct e1000_ps_page_dma) * rxdr->count;
-	rxdr->ps_page_dma = kmalloc(size, GFP_KERNEL);
+	rxdr->ps_page_dma = kzalloc(size, GFP_KERNEL);
 	if (!rxdr->ps_page_dma) {
 		vfree(rxdr->buffer_info);
 		kfree(rxdr->ps_page);
@@ -1562,7 +1558,6 @@ e1000_setup_rx_resources(struct e1000_ad
 		"Unable to allocate memory for the receive descriptor ring\n");
 		return -ENOMEM;
 	}
-	memset(rxdr->ps_page_dma, 0, size);
 
 	if (adapter->hw.mac_type <= e1000_82547_rev_2)
 		desc_len = sizeof(struct e1000_rx_desc);
--- linux-2.6.16-rc5-mm1/drivers/net/pcmcia/ibmtr_cs.c.orig	2006-03-02 14:26:19.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/pcmcia/ibmtr_cs.c	2006-03-02 14:26:28.000000000 +0100
@@ -146,9 +146,8 @@ static int ibmtr_attach(struct pcmcia_de
     DEBUG(0, "ibmtr_attach()\n");
 
     /* Create new token-ring device */
-    info = kmalloc(sizeof(*info), GFP_KERNEL); 
+    info = kzalloc(sizeof(*info), GFP_KERNEL); 
     if (!info) return -ENOMEM;
-    memset(info,0,sizeof(*info));
     dev = alloc_trdev(sizeof(struct tok_info));
     if (!dev) {
 	kfree(info);
--- linux-2.6.16-rc5-mm1/drivers/net/slhc.c.orig	2006-03-02 14:26:39.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/slhc.c	2006-03-02 14:27:11.000000000 +0100
@@ -95,27 +95,23 @@ slhc_init(int rslots, int tslots)
 	register struct cstate *ts;
 	struct slcompress *comp;
 
-	comp = (struct slcompress *)kmalloc(sizeof(struct slcompress),
-					    GFP_KERNEL);
+	comp = kzalloc(sizeof(struct slcompress), GFP_KERNEL);
 	if (! comp)
 		goto out_fail;
-	memset(comp, 0, sizeof(struct slcompress));
 
 	if ( rslots > 0  &&  rslots < 256 ) {
 		size_t rsize = rslots * sizeof(struct cstate);
-		comp->rstate = (struct cstate *) kmalloc(rsize, GFP_KERNEL);
+		comp->rstate = kzalloc(rsize, GFP_KERNEL);
 		if (! comp->rstate)
 			goto out_free;
-		memset(comp->rstate, 0, rsize);
 		comp->rslot_limit = rslots - 1;
 	}
 
 	if ( tslots > 0  &&  tslots < 256 ) {
 		size_t tsize = tslots * sizeof(struct cstate);
-		comp->tstate = (struct cstate *) kmalloc(tsize, GFP_KERNEL);
+		comp->tstate = kzalloc(tsize, GFP_KERNEL);
 		if (! comp->tstate)
 			goto out_free2;
-		memset(comp->tstate, 0, tsize);
 		comp->tslot_limit = tslots - 1;
 	}
 
--- linux-2.6.16-rc5-mm1/drivers/net/sb1250-mac.c.orig	2006-03-02 14:27:18.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/sb1250-mac.c	2006-03-02 14:27:35.000000000 +0100
@@ -743,9 +743,7 @@ static void sbdma_initctx(sbmacdma_t *d,
 	 */
 
 	d->sbdma_ctxtable = (struct sk_buff **)
-		kmalloc(d->sbdma_maxdescr*sizeof(struct sk_buff *), GFP_KERNEL);
-
-	memset(d->sbdma_ctxtable,0,d->sbdma_maxdescr*sizeof(struct sk_buff *));
+		kzalloc(d->sbdma_maxdescr*sizeof(struct sk_buff *), GFP_KERNEL);
 
 #ifdef CONFIG_SBMAC_COALESCE
 	/*
--- linux-2.6.16-rc5-mm1/drivers/net/ppp_async.c.orig	2006-03-02 14:27:44.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/ppp_async.c	2006-03-02 14:27:52.000000000 +0100
@@ -159,12 +159,11 @@ ppp_asynctty_open(struct tty_struct *tty
 	int err;
 
 	err = -ENOMEM;
-	ap = kmalloc(sizeof(*ap), GFP_KERNEL);
+	ap = kzalloc(sizeof(*ap), GFP_KERNEL);
 	if (ap == 0)
 		goto out;
 
 	/* initialize the asyncppp structure */
-	memset(ap, 0, sizeof(*ap));
 	ap->tty = tty;
 	ap->mru = PPP_MRU;
 	spin_lock_init(&ap->xmit_lock);
--- linux-2.6.16-rc5-mm1/drivers/net/loopback.c.orig	2006-03-02 14:28:00.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/loopback.c	2006-03-02 14:28:13.000000000 +0100
@@ -224,9 +224,8 @@ int __init loopback_init(void)
 	struct net_device_stats *stats;
 
 	/* Can survive without statistics */
-	stats = kmalloc(sizeof(struct net_device_stats), GFP_KERNEL);
+	stats = kzalloc(sizeof(struct net_device_stats), GFP_KERNEL);
 	if (stats) {
-		memset(stats, 0, sizeof(struct net_device_stats));
 		loopback_dev.priv = stats;
 		loopback_dev.get_stats = &get_stats;
 	}
--- linux-2.6.16-rc5-mm1/drivers/net/bnx2.c.orig	2006-03-02 14:28:26.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/bnx2.c	2006-03-02 14:29:22.000000000 +0100
@@ -397,12 +397,11 @@ bnx2_alloc_mem(struct bnx2 *bp)
 {
 	int i;
 
-	bp->tx_buf_ring = kmalloc(sizeof(struct sw_bd) * TX_DESC_CNT,
+	bp->tx_buf_ring = kzalloc(sizeof(struct sw_bd) * TX_DESC_CNT,
 				     GFP_KERNEL);
 	if (bp->tx_buf_ring == NULL)
 		return -ENOMEM;
 
-	memset(bp->tx_buf_ring, 0, sizeof(struct sw_bd) * TX_DESC_CNT);
 	bp->tx_desc_ring = pci_alloc_consistent(bp->pdev,
 					        sizeof(struct tx_bd) *
 						TX_DESC_CNT,
--- linux-2.6.16-rc5-mm1/drivers/net/ppp_deflate.c.orig	2006-03-02 14:29:33.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/ppp_deflate.c	2006-03-02 14:30:00.000000000 +0100
@@ -121,12 +121,10 @@ static void *z_comp_alloc(unsigned char 
 	if (w_size < DEFLATE_MIN_SIZE || w_size > DEFLATE_MAX_SIZE)
 		return NULL;
 
-	state = (struct ppp_deflate_state *) kmalloc(sizeof(*state),
-						     GFP_KERNEL);
+	state = kzalloc(sizeof(*state), GFP_KERNEL);
 	if (state == NULL)
 		return NULL;
 
-	memset (state, 0, sizeof (struct ppp_deflate_state));
 	state->strm.next_in   = NULL;
 	state->w_size         = w_size;
 	state->strm.workspace = vmalloc(zlib_deflate_workspacesize());
@@ -341,11 +339,10 @@ static void *z_decomp_alloc(unsigned cha
 	if (w_size < DEFLATE_MIN_SIZE || w_size > DEFLATE_MAX_SIZE)
 		return NULL;
 
-	state = (struct ppp_deflate_state *) kmalloc(sizeof(*state), GFP_KERNEL);
+	state = kzalloc(sizeof(*state), GFP_KERNEL);
 	if (state == NULL)
 		return NULL;
 
-	memset (state, 0, sizeof (struct ppp_deflate_state));
 	state->w_size         = w_size;
 	state->strm.next_out  = NULL;
 	state->strm.workspace = kmalloc(zlib_inflate_workspacesize(),
--- linux-2.6.16-rc5-mm1/drivers/net/iseries_veth.c.orig	2006-03-02 14:30:09.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/iseries_veth.c	2006-03-02 14:30:43.000000000 +0100
@@ -820,10 +820,9 @@ static int veth_init_connection(u8 rlp)
 	     || ! HvLpConfig_doLpsCommunicateOnVirtualLan(this_lp, rlp) )
 		return 0;
 
-	cnx = kmalloc(sizeof(*cnx), GFP_KERNEL);
+	cnx = kzalloc(sizeof(*cnx), GFP_KERNEL);
 	if (! cnx)
 		return -ENOMEM;
-	memset(cnx, 0, sizeof(*cnx));
 
 	cnx->remote_lp = rlp;
 	spin_lock_init(&cnx->lock);
@@ -850,14 +849,13 @@ static int veth_init_connection(u8 rlp)
 	if (rc != 0)
 		return rc;
 
-	msgs = kmalloc(VETH_NUMBUFFERS * sizeof(struct veth_msg), GFP_KERNEL);
+	msgs = kzalloc(VETH_NUMBUFFERS * sizeof(struct veth_msg), GFP_KERNEL);
 	if (! msgs) {
 		veth_error("Can't allocate buffers for LPAR %d.\n", rlp);
 		return -ENOMEM;
 	}
 
 	cnx->msgs = msgs;
-	memset(msgs, 0, VETH_NUMBUFFERS * sizeof(struct veth_msg));
 
 	for (i = 0; i < VETH_NUMBUFFERS; i++) {
 		msgs[i].token = i;
--- linux-2.6.16-rc5-mm1/drivers/net/via-velocity.c.orig	2006-03-02 14:30:54.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/via-velocity.c	2006-03-02 14:31:24.000000000 +0100
@@ -1072,10 +1072,9 @@ static int velocity_init_rd_ring(struct 
 	unsigned int rsize = sizeof(struct velocity_rd_info) * 
 					vptr->options.numrx;
 
-	vptr->rd_info = kmalloc(rsize, GFP_KERNEL);
+	vptr->rd_info = kzalloc(rsize, GFP_KERNEL);
 	if(vptr->rd_info == NULL)
 		goto out;
-	memset(vptr->rd_info, 0, rsize);
 
 	vptr->rd_filled = vptr->rd_dirty = vptr->rd_curr = 0;
 
@@ -1146,14 +1145,13 @@ static int velocity_init_td_ring(struct 
 	for (j = 0; j < vptr->num_txq; j++) {
 		curr = vptr->td_pool_dma[j];
 
-		vptr->td_infos[j] = kmalloc(tsize, GFP_KERNEL);
+		vptr->td_infos[j] = kzalloc(tsize, GFP_KERNEL);
 		if(vptr->td_infos[j] == NULL)
 		{
 			while(--j >= 0)
 				kfree(vptr->td_infos[j]);
 			return -ENOMEM;
 		}
-		memset(vptr->td_infos[j], 0, tsize);
 
 		for (i = 0; i < vptr->options.numtx; i++, curr += sizeof(struct tx_desc)) {
 			td = &(vptr->td_rings[j][i]);
--- linux-2.6.16-rc5-mm1/drivers/net/pcnet32.c.orig	2006-03-02 14:31:32.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/pcnet32.c	2006-03-02 15:04:10.000000000 +0100
@@ -1480,41 +1480,37 @@ static int pcnet32_alloc_ring(struct net
 	return -ENOMEM;
     }
 
-    lp->tx_dma_addr = kmalloc(sizeof(dma_addr_t) * lp->tx_ring_size,
+    lp->tx_dma_addr = kcalloc(lp->tx_ring_size, sizeof(dma_addr_t),
 	    GFP_ATOMIC);
     if (!lp->tx_dma_addr) {
 	if (pcnet32_debug & NETIF_MSG_DRV)
 	    printk("\n" KERN_ERR PFX "%s: Memory allocation failed.\n", name);
 	return -ENOMEM;
     }
-    memset(lp->tx_dma_addr, 0, sizeof(dma_addr_t) * lp->tx_ring_size);
 
-    lp->rx_dma_addr = kmalloc(sizeof(dma_addr_t) * lp->rx_ring_size,
+    lp->rx_dma_addr = kcalloc(lp->rx_ring_size, sizeof(dma_addr_t),
 	    GFP_ATOMIC);
     if (!lp->rx_dma_addr) {
 	if (pcnet32_debug & NETIF_MSG_DRV)
 	    printk("\n" KERN_ERR PFX "%s: Memory allocation failed.\n", name);
 	return -ENOMEM;
     }
-    memset(lp->rx_dma_addr, 0, sizeof(dma_addr_t) * lp->rx_ring_size);
 
-    lp->tx_skbuff = kmalloc(sizeof(struct sk_buff *) * lp->tx_ring_size,
+    lp->tx_skbuff = kcalloc(lp->tx_ring_size, sizeof(struct sk_buff *),
 	    GFP_ATOMIC);
     if (!lp->tx_skbuff) {
 	if (pcnet32_debug & NETIF_MSG_DRV)
 	    printk("\n" KERN_ERR PFX "%s: Memory allocation failed.\n", name);
 	return -ENOMEM;
     }
-    memset(lp->tx_skbuff, 0, sizeof(struct sk_buff *) * lp->tx_ring_size);
 
-    lp->rx_skbuff = kmalloc(sizeof(struct sk_buff *) * lp->rx_ring_size,
+    lp->rx_skbuff = kcalloc(lp->rx_ring_size, sizeof(struct sk_buff *),
 	    GFP_ATOMIC);
     if (!lp->rx_skbuff) {
 	if (pcnet32_debug & NETIF_MSG_DRV)
 	    printk("\n" KERN_ERR PFX "%s: Memory allocation failed.\n", name);
 	return -ENOMEM;
     }
-    memset(lp->rx_skbuff, 0, sizeof(struct sk_buff *) * lp->rx_ring_size);
 
     return 0;
 }
--- linux-2.6.16-rc5-mm1/drivers/net/fs_enet/fs_enet-mii.c.orig	2006-03-02 14:33:53.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/fs_enet/fs_enet-mii.c	2006-03-02 14:34:01.000000000 +0100
@@ -389,12 +389,11 @@ static struct fs_enet_mii_bus *create_bu
 	struct fs_enet_mii_bus *bus;
 	int ret = 0;
 
-	bus = kmalloc(sizeof(*bus), GFP_KERNEL);
+	bus = kzalloc(sizeof(*bus), GFP_KERNEL);
 	if (bus == NULL) {
 		ret = -ENOMEM;
 		goto err;
 	}
-	memset(bus, 0, sizeof(*bus));
 	spin_lock_init(&bus->mii_lock);
 	bus->bus_info = bi;
 	bus->refs = 0;
--- linux-2.6.16-rc5-mm1/drivers/net/ppp_mppe.c.orig	2006-03-02 14:34:21.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/ppp_mppe.c	2006-03-02 14:34:35.000000000 +0100
@@ -191,12 +191,10 @@ static void *mppe_alloc(unsigned char *o
 	    || options[0] != CI_MPPE || options[1] != CILEN_MPPE)
 		goto out;
 
-	state = (struct ppp_mppe_state *) kmalloc(sizeof(*state), GFP_KERNEL);
+	state = kzalloc(sizeof(*state), GFP_KERNEL);
 	if (state == NULL)
 		goto out;
 
-	memset(state, 0, sizeof(*state));
-
 	state->arc4 = crypto_alloc_tfm("arc4", 0);
 	if (!state->arc4)
 		goto out_free;
--- linux-2.6.16-rc5-mm1/drivers/net/irda/irtty-sir.c.orig	2006-03-02 14:34:51.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/irda/irtty-sir.c	2006-03-02 14:35:01.000000000 +0100
@@ -505,10 +505,9 @@ static int irtty_open(struct tty_struct 
 	}
 
 	/* allocate private device info block */
-	priv = kmalloc(sizeof(*priv), GFP_KERNEL);
+	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
 	if (!priv)
 		goto out_put;
-	memset(priv, 0, sizeof(*priv));
 
 	priv->magic = IRTTY_MAGIC;
 	priv->tty = tty;
--- linux-2.6.16-rc5-mm1/drivers/net/irda/irda-usb.c.orig	2006-03-02 14:35:49.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/irda/irda-usb.c	2006-03-02 14:36:12.000000000 +0100
@@ -1343,10 +1343,9 @@ static inline struct irda_class_desc *ir
 	struct irda_class_desc *desc;
 	int ret;
 
-	desc = kmalloc(sizeof (*desc), GFP_KERNEL);
+	desc = kzalloc(sizeof (*desc), GFP_KERNEL);
 	if (desc == NULL) 
 		return NULL;
-	memset(desc, 0, sizeof(*desc));
 
 	/* USB-IrDA class spec 1.0:
 	 *	6.1.3: Standard "Get Descriptor" Device Request is not
@@ -1495,12 +1494,10 @@ static int irda_usb_probe(struct usb_int
 	/* Don't change this buffer size and allocation without doing
 	 * some heavy and complete testing. Don't ask why :-(
 	 * Jean II */
-	self->speed_buff = (char *) kmalloc(IRDA_USB_SPEED_MTU, GFP_KERNEL);
+	self->speed_buff = kzalloc(IRDA_USB_SPEED_MTU, GFP_KERNEL);
 	if (self->speed_buff == NULL) 
 		goto err_out_3;
 
-	memset(self->speed_buff, 0, IRDA_USB_SPEED_MTU);
-
 	ret = irda_usb_open(self);
 	if (ret) 
 		goto err_out_4;
--- linux-2.6.16-rc5-mm1/drivers/net/chelsio/sge.c.orig	2006-03-02 14:36:45.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/chelsio/sge.c	2006-03-02 14:37:23.000000000 +0100
@@ -336,10 +336,9 @@ static int alloc_rx_resources(struct sge
 			goto err_no_mem;
 		memset(q->entries, 0, size);
 		size = sizeof(struct freelQ_ce) * q->size;
-		q->centries = kmalloc(size, GFP_KERNEL);
+		q->centries = kzalloc(size, GFP_KERNEL);
 		if (!q->centries)
 			goto err_no_mem;
-		memset(q->centries, 0, size);
 	}
 
 	/*
@@ -464,10 +463,9 @@ static int alloc_tx_resources(struct sge
 			goto err_no_mem;
 		memset(q->entries, 0, size);
 		size = sizeof(struct cmdQ_ce) * q->size;
-		q->centries = kmalloc(size, GFP_KERNEL);
+		q->centries = kzalloc(size, GFP_KERNEL);
 		if (!q->centries)
 			goto err_no_mem;
-		memset(q->centries, 0, size);
 	}
 
 	/*
@@ -1649,11 +1647,10 @@ static void espibug_workaround(void *dat
 struct sge * __devinit t1_sge_create(struct adapter *adapter,
 				     struct sge_params *p)
 {
-	struct sge *sge = kmalloc(sizeof(*sge), GFP_KERNEL);
+	struct sge *sge = kzalloc(sizeof(*sge), GFP_KERNEL);
 
 	if (!sge)
 		return NULL;
-	memset(sge, 0, sizeof(*sge));
 
 	sge->adapter = adapter;
 	sge->netdev = adapter->port[0].dev;
--- linux-2.6.16-rc5-mm1/drivers/net/chelsio/espi.c.orig	2006-03-02 14:37:51.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/chelsio/espi.c	2006-03-02 14:38:49.000000000 +0100
@@ -296,9 +296,7 @@ void t1_espi_destroy(struct peespi *espi
 
 struct peespi *t1_espi_create(adapter_t *adapter)
 {
-	struct peespi *espi = kmalloc(sizeof(*espi), GFP_KERNEL);
-
-	memset(espi, 0, sizeof(*espi));
+	struct peespi *espi = kzalloc(sizeof(*espi), GFP_KERNEL);
 
 	if (espi)
 		espi->adapter = adapter;
--- linux-2.6.16-rc5-mm1/drivers/net/chelsio/mv88x201x.c.orig	2006-03-02 14:38:57.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/chelsio/mv88x201x.c	2006-03-02 14:39:07.000000000 +0100
@@ -205,11 +205,10 @@ static struct cphy *mv88x201x_phy_create
 					 struct mdio_ops *mdio_ops)
 {
 	u32 val;
-	struct cphy *cphy = kmalloc(sizeof(*cphy), GFP_KERNEL);
+	struct cphy *cphy = kzalloc(sizeof(*cphy), GFP_KERNEL);
 
 	if (!cphy)
 		return NULL;
-	memset(cphy, 0, sizeof(*cphy));
 	cphy_init(cphy, adapter, phy_addr, &mv88x201x_ops, mdio_ops);
 
 	/* Commands the PHY to enable XFP's clock. */
--- linux-2.6.16-rc5-mm1/drivers/net/mipsnet.c.orig	2006-03-02 14:39:19.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/mipsnet.c	2006-03-02 14:39:28.000000000 +0100
@@ -323,12 +323,11 @@ static int __init mipsnet_init_module(vo
 		goto out;
 	}
 
-        if (!(pldev = kmalloc (sizeof (*pldev), GFP_KERNEL))) {
+        if (!(pldev = kzalloc (sizeof (*pldev), GFP_KERNEL))) {
 		err = -ENOMEM;
 		goto out_unregister_driver;
 	}
 
-	memset (pldev, 0, sizeof (*pldev));
 	pldev->name		= mipsnet_string;
 	pldev->id		= 0;
 	pldev->dev.release	= mipsnet_platform_release;
--- linux-2.6.16-rc5-mm1/drivers/net/wan/hdlc_fr.c.orig	2006-03-02 14:40:08.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/wan/hdlc_fr.c	2006-03-02 14:40:23.000000000 +0100
@@ -159,11 +159,10 @@ static inline pvc_device* add_pvc(struct
 		pvc_p = &(*pvc_p)->next;
 	}
 
-	pvc = kmalloc(sizeof(pvc_device), GFP_ATOMIC);
+	pvc = kzalloc(sizeof(pvc_device), GFP_ATOMIC);
 	if (!pvc)
 		return NULL;
 
-	memset(pvc, 0, sizeof(pvc_device));
 	pvc->dlci = dlci;
 	pvc->master = dev;
 	pvc->next = *pvc_p;	/* Put it in the chain */
--- linux-2.6.16-rc5-mm1/drivers/net/wan/sdla_chdlc.c.orig	2006-03-02 14:40:32.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/wan/sdla_chdlc.c	2006-03-02 14:40:52.000000000 +0100
@@ -679,13 +679,11 @@ static int new_if(struct wan_device* wan
 	}
 		
 	/* allocate and initialize private data */
-	chdlc_priv_area = kmalloc(sizeof(chdlc_private_area_t), GFP_KERNEL);
+	chdlc_priv_area = kzalloc(sizeof(chdlc_private_area_t), GFP_KERNEL);
 	
 	if(chdlc_priv_area == NULL) 
 		return -ENOMEM;
 
-	memset(chdlc_priv_area, 0, sizeof(chdlc_private_area_t));
-
 	chdlc_priv_area->card = card; 
 	chdlc_priv_area->common.sk = NULL;
 	chdlc_priv_area->common.func = NULL;	
--- linux-2.6.16-rc5-mm1/drivers/net/wan/hostess_sv11.c.orig	2006-03-02 14:41:05.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/wan/hostess_sv11.c	2006-03-02 14:41:27.000000000 +0100
@@ -231,11 +231,10 @@ static struct sv11_device *sv11_init(int
 		return NULL;
 	}
 	
-	sv=(struct sv11_device *)kmalloc(sizeof(struct sv11_device), GFP_KERNEL);
+	sv=kzalloc(sizeof(struct sv11_device), GFP_KERNEL);
 	if(!sv)
 		goto fail3;
 			
-	memset(sv, 0, sizeof(*sv));
 	sv->if_ptr=&sv->netdev;
 	
 	sv->netdev.dev = alloc_netdev(0, "hdlc%d", sv11_setup);
--- linux-2.6.16-rc5-mm1/drivers/net/wan/sealevel.c.orig	2006-03-02 14:41:34.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/wan/sealevel.c	2006-03-02 14:41:45.000000000 +0100
@@ -270,11 +270,10 @@ static __init struct slvl_board *slvl_in
 		return NULL;
 	}
 	
-	b = kmalloc(sizeof(struct slvl_board), GFP_KERNEL);
+	b = kzalloc(sizeof(struct slvl_board), GFP_KERNEL);
 	if(!b)
 		goto fail3;
 
-	memset(b, 0, sizeof(*b));
 	if (!(b->dev[0]= slvl_alloc(iobase, irq)))
 		goto fail2;
 
--- linux-2.6.16-rc5-mm1/drivers/net/wan/sdla_x25.c.orig	2006-03-02 14:41:55.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/wan/sdla_x25.c	2006-03-02 14:42:43.000000000 +0100
@@ -926,13 +926,11 @@ static int new_if(struct wan_device* wan
 	}
 
 	/* allocate and initialize private data */
-	chan = kmalloc(sizeof(x25_channel_t), GFP_ATOMIC);
+	chan = kzalloc(sizeof(x25_channel_t), GFP_ATOMIC);
 	if (chan == NULL){
 		return -ENOMEM;
 	}
 	
-	memset(chan, 0, sizeof(x25_channel_t));
-
 	/* Bug Fix: Seg Err on PVC startup
 	 * It must be here since bind_lcn_to_dev expects 
 	 * it bellow */
@@ -1194,7 +1192,7 @@ static int if_open(struct net_device* de
 
 	/* Allocate and initialize BH circular buffer */
 	/* Add 1 to MAX_BH_BUFF so we don't have test with (MAX_BH_BUFF-1) */
-	chan->bh_head = kmalloc((sizeof(bh_data_t)*(MAX_BH_BUFF+1)),GFP_ATOMIC);
+	chan->bh_head = kzalloc((sizeof(bh_data_t)*(MAX_BH_BUFF+1)),GFP_ATOMIC);
 
 	if (chan->bh_head == NULL){
 		printk(KERN_INFO "%s: ERROR, failed to allocate memory ! BH_BUFFERS !\n",
@@ -1202,7 +1200,6 @@ static int if_open(struct net_device* de
 
 		return -ENOBUFS;
 	}
-	memset(chan->bh_head,0,(sizeof(bh_data_t)*(MAX_BH_BUFF+1)));
 	atomic_set(&chan->bh_buff_used, 0);
 
 	/* Increment the number of interfaces */
--- linux-2.6.16-rc5-mm1/drivers/net/wan/sdla.c.orig	2006-03-02 14:42:53.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/wan/sdla.c	2006-03-02 14:43:21.000000000 +0100
@@ -1203,10 +1203,9 @@ static int sdla_xfer(struct net_device *
 		
 	if (read)
 	{	
-		temp = kmalloc(mem.len, GFP_KERNEL);
+		temp = kzalloc(mem.len, GFP_KERNEL);
 		if (!temp)
 			return(-ENOMEM);
-		memset(temp, 0, mem.len);
 		sdla_read(dev, mem.addr, temp, mem.len);
 		if(copy_to_user(mem.data, temp, mem.len))
 		{
--- linux-2.6.16-rc5-mm1/drivers/net/wan/cycx_x25.c.orig	2006-03-02 14:43:41.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/wan/cycx_x25.c	2006-03-02 14:44:01.000000000 +0100
@@ -376,11 +376,10 @@ static int cycx_wan_new_if(struct wan_de
 	}
 
 	/* allocate and initialize private data */
-	chan = kmalloc(sizeof(struct cycx_x25_channel), GFP_KERNEL);
+	chan = kzalloc(sizeof(struct cycx_x25_channel), GFP_KERNEL);
 	if (!chan)
 		return -ENOMEM;
 
-	memset(chan, 0, sizeof(*chan));
 	strcpy(chan->name, conf->name);
 	chan->card = card;
 	chan->link = conf->port;
--- linux-2.6.16-rc5-mm1/drivers/net/wan/c101.c.orig	2006-03-02 14:44:08.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/wan/c101.c	2006-03-02 14:44:17.000000000 +0100
@@ -309,12 +309,11 @@ static int __init c101_run(unsigned long
 		return -ENODEV;
 	}
 
-	card = kmalloc(sizeof(card_t), GFP_KERNEL);
+	card = kzalloc(sizeof(card_t), GFP_KERNEL);
 	if (card == NULL) {
 		printk(KERN_ERR "c101: unable to allocate memory\n");
 		return -ENOBUFS;
 	}
-	memset(card, 0, sizeof(card_t));
 
 	card->dev = alloc_hdlcdev(card);
 	if (!card->dev) {
--- linux-2.6.16-rc5-mm1/drivers/net/wan/wanpipe_multppp.c.orig	2006-03-02 14:44:24.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/wan/wanpipe_multppp.c	2006-03-02 14:44:36.000000000 +0100
@@ -539,13 +539,11 @@ static int new_if(struct wan_device* wan
 	}
 		
 	/* allocate and initialize private data */
-	chdlc_priv_area = kmalloc(sizeof(chdlc_private_area_t), GFP_KERNEL);
+	chdlc_priv_area = kzalloc(sizeof(chdlc_private_area_t), GFP_KERNEL);
 	
 	if(chdlc_priv_area == NULL) 
 		return -ENOMEM;
 
-	memset(chdlc_priv_area, 0, sizeof(chdlc_private_area_t));
-
 	chdlc_priv_area->card = card; 
 
 	/* initialize data */
--- linux-2.6.16-rc5-mm1/drivers/net/wan/sdla_ppp.c.orig	2006-03-02 14:44:51.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/wan/sdla_ppp.c	2006-03-02 14:45:02.000000000 +0100
@@ -528,13 +528,11 @@ static int new_if(struct wan_device *wan
 	}
 
 	/* allocate and initialize private data */
-	ppp_priv_area = kmalloc(sizeof(ppp_private_area_t), GFP_KERNEL);
+	ppp_priv_area = kzalloc(sizeof(ppp_private_area_t), GFP_KERNEL);
 	
 	if( ppp_priv_area == NULL )
 		return	-ENOMEM;
 	
-	memset(ppp_priv_area, 0, sizeof(ppp_private_area_t));
-	
 	ppp_priv_area->card = card; 
 	
 	/* initialize data */
--- linux-2.6.16-rc5-mm1/drivers/net/wan/cycx_main.c.orig	2006-03-02 14:45:12.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/wan/cycx_main.c	2006-03-02 14:45:35.000000000 +0100
@@ -114,13 +114,11 @@ static int __init cycx_init(void)
 	/* Verify number of cards and allocate adapter data space */
 	cycx_ncards = min_t(int, cycx_ncards, CYCX_MAX_CARDS);
 	cycx_ncards = max_t(int, cycx_ncards, 1);
-	cycx_card_array = kmalloc(sizeof(struct cycx_device) * cycx_ncards,
+	cycx_card_array = kcalloc(cycx_ncards, sizeof(struct cycx_device),
 				  GFP_KERNEL);
 	if (!cycx_card_array)
 		goto out;
 
-	memset(cycx_card_array, 0, sizeof(struct cycx_device) * cycx_ncards);
-
 	/* Register adapters with WAN router */
 	for (cnt = 0; cnt < cycx_ncards; ++cnt) {
 		struct cycx_device *card = &cycx_card_array[cnt];
--- linux-2.6.16-rc5-mm1/drivers/net/wan/dscc4.c.orig	2006-03-02 14:45:45.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/wan/dscc4.c	2006-03-02 14:46:12.000000000 +0100
@@ -890,12 +890,11 @@ static int dscc4_found1(struct pci_dev *
 	struct dscc4_dev_priv *root;
 	int i, ret = -ENOMEM;
 
-	root = kmalloc(dev_per_card*sizeof(*root), GFP_KERNEL);
+	root = kcalloc(dev_per_card, sizeof(*root), GFP_KERNEL);
 	if (!root) {
 		printk(KERN_ERR "%s: can't allocate data\n", DRV_NAME);
 		goto err_out;
 	}
-	memset(root, 0, dev_per_card*sizeof(*root));
 
 	for (i = 0; i < dev_per_card; i++) {
 		root[i].dev = alloc_hdlcdev(root + i);
@@ -903,12 +902,11 @@ static int dscc4_found1(struct pci_dev *
 			goto err_free_dev;
 	}
 
-	ppriv = kmalloc(sizeof(*ppriv), GFP_KERNEL);
+	ppriv = kzalloc(sizeof(*ppriv), GFP_KERNEL);
 	if (!ppriv) {
 		printk(KERN_ERR "%s: can't allocate private data\n", DRV_NAME);
 		goto err_free_dev;
 	}
-	memset(ppriv, 0, sizeof(struct dscc4_pci_priv));
 
 	ppriv->root = root;
 	spin_lock_init(&ppriv->lock);
--- linux-2.6.16-rc5-mm1/drivers/net/wan/n2.c.orig	2006-03-02 14:46:20.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/wan/n2.c	2006-03-02 14:46:27.000000000 +0100
@@ -351,12 +351,11 @@ static int __init n2_run(unsigned long i
 		return -ENODEV;
 	}
 
-	card = kmalloc(sizeof(card_t), GFP_KERNEL);
+	card = kzalloc(sizeof(card_t), GFP_KERNEL);
 	if (card == NULL) {
 		printk(KERN_ERR "n2: unable to allocate memory\n");
 		return -ENOBUFS;
 	}
-	memset(card, 0, sizeof(card_t));
 
 	card->ports[0].dev = alloc_hdlcdev(&card->ports[0]);
 	card->ports[1].dev = alloc_hdlcdev(&card->ports[1]);
--- linux-2.6.16-rc5-mm1/drivers/net/wan/sdla_fr.c.orig	2006-03-02 14:46:37.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/wan/sdla_fr.c	2006-03-02 14:47:11.000000000 +0100
@@ -812,12 +812,11 @@ static int new_if(struct wan_device* wan
 	}
 
 	/* allocate and initialize private data */
-	chan = kmalloc(sizeof(fr_channel_t), GFP_KERNEL);
+	chan = kzalloc(sizeof(fr_channel_t), GFP_KERNEL);
 
 	if (chan == NULL)
 		return -ENOMEM;
 
-	memset(chan, 0, sizeof(fr_channel_t));
 	strcpy(chan->name, conf->name);
 	chan->card = card;
 
@@ -1214,8 +1213,7 @@ static int if_open(struct net_device* de
 	INIT_WORK(&chan->common.wanpipe_work, (void *)fr_bh, dev);
 
 	/* Allocate and initialize BH circular buffer */
-	chan->bh_head = kmalloc((sizeof(bh_data_t)*MAX_BH_BUFF),GFP_ATOMIC);
-	memset(chan->bh_head,0,(sizeof(bh_data_t)*MAX_BH_BUFF));
+	chan->bh_head = kzalloc((sizeof(bh_data_t)*MAX_BH_BUFF),GFP_ATOMIC);
 	atomic_set(&chan->bh_buff_used, 0);
 
 	netif_start_queue(dev);
--- linux-2.6.16-rc5-mm1/drivers/net/shaper.c.orig	2006-03-02 14:47:27.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/shaper.c	2006-03-02 14:47:44.000000000 +0100
@@ -601,10 +601,9 @@ static int __init shaper_init(void)
 		return -ENODEV;
 
 	alloc_size = sizeof(*dev) * shapers;
-	devs = kmalloc(alloc_size, GFP_KERNEL);
+	devs = kzalloc(alloc_size, GFP_KERNEL);
 	if (!devs)
 		return -ENOMEM;
-	memset(devs, 0, alloc_size);
 
 	for (i = 0; i < shapers; i++) {
 
--- linux-2.6.16-rc5-mm1/drivers/net/ppp_generic.c.orig	2006-03-02 14:47:52.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/ppp_generic.c	2006-03-02 14:48:22.000000000 +0100
@@ -2006,10 +2006,9 @@ ppp_register_channel(struct ppp_channel 
 {
 	struct channel *pch;
 
-	pch = kmalloc(sizeof(struct channel), GFP_KERNEL);
+	pch = kzalloc(sizeof(struct channel), GFP_KERNEL);
 	if (pch == 0)
 		return -ENOMEM;
-	memset(pch, 0, sizeof(struct channel));
 	pch->ppp = NULL;
 	pch->chan = chan;
 	chan->ppp = pch;
@@ -2717,8 +2716,7 @@ static void cardmap_set(struct cardmap *
 	if (p == NULL || (nr >> p->shift) >= CARDMAP_WIDTH) {
 		do {
 			/* need a new top level */
-			struct cardmap *np = kmalloc(sizeof(*np), GFP_KERNEL);
-			memset(np, 0, sizeof(*np));
+			struct cardmap *np = kzalloc(sizeof(*np), GFP_KERNEL);
 			np->ptr[0] = p;
 			if (p != NULL) {
 				np->shift = p->shift + CARDMAP_ORDER;
@@ -2732,8 +2730,7 @@ static void cardmap_set(struct cardmap *
 	while (p->shift > 0) {
 		i = (nr >> p->shift) & CARDMAP_MASK;
 		if (p->ptr[i] == NULL) {
-			struct cardmap *np = kmalloc(sizeof(*np), GFP_KERNEL);
-			memset(np, 0, sizeof(*np));
+			struct cardmap *np = kzalloc(sizeof(*np), GFP_KERNEL);
 			np->shift = p->shift - CARDMAP_ORDER;
 			np->parent = p;
 			p->ptr[i] = np;
--- linux-2.6.16-rc5-mm1/drivers/net/lance.c.orig	2006-03-02 14:48:31.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/lance.c	2006-03-02 14:48:47.000000000 +0100
@@ -532,11 +532,10 @@ static int __init lance_probe1(struct ne
 	dev->base_addr = ioaddr;
 	/* Make certain the data structures used by the LANCE are aligned and DMAble. */
 		
-	lp = kmalloc(sizeof(*lp), GFP_DMA | GFP_KERNEL);
+	lp = kzalloc(sizeof(*lp), GFP_DMA | GFP_KERNEL);
 	if(lp==NULL)
 		return -ENODEV;
 	if (lance_debug > 6) printk(" (#0x%05lx)", (unsigned long)lp);
-	memset(lp, 0, sizeof(*lp));
 	dev->priv = lp;
 	lp->name = chipname;
 	lp->rx_buffs = (unsigned long)kmalloc(PKT_BUF_SZ*RX_RING_SIZE,
--- linux-2.6.16-rc5-mm1/drivers/net/wireless/prism54/oid_mgt.c.orig	2006-03-02 14:49:34.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/wireless/prism54/oid_mgt.c	2006-03-02 14:50:29.000000000 +0100
@@ -235,12 +235,10 @@ mgt_init(islpci_private *priv)
 {
 	int i;
 
-	priv->mib = kmalloc(OID_NUM_LAST * sizeof (void *), GFP_KERNEL);
+	priv->mib = kzalloc(OID_NUM_LAST * sizeof(void *), GFP_KERNEL);
 	if (!priv->mib)
 		return -ENOMEM;
 
-	memset(priv->mib, 0, OID_NUM_LAST * sizeof (void *));
-
 	/* Alloc the cache */
 	for (i = 0; i < OID_NUM_LAST; i++) {
 		if (isl_oid[i].flags & OID_FLAG_CACHED) {
@@ -564,11 +562,9 @@ mgt_get_request(islpci_private *priv, en
 	if ((isl_oid[n].flags & OID_FLAG_TYPE) == OID_TYPE_U32)
 		res->u = ret ? 0 : le32_to_cpu(*(u32 *) _res);
 	else {
-		res->ptr = kmalloc(reslen, GFP_KERNEL);
+		res->ptr = kzalloc(reslen, GFP_KERNEL);
 		BUG_ON(res->ptr == NULL);
-		if (ret)
-			memset(res->ptr, 0, reslen);
-		else {
+		if (!ret) {
 			memcpy(res->ptr, _res, reslen);
 			mgt_le_to_cpu(isl_oid[n].flags & OID_FLAG_TYPE,
 				      res->ptr);
--- linux-2.6.16-rc5-mm1/drivers/net/wireless/prism54/isl_ioctl.c.orig	2006-03-02 14:50:39.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/wireless/prism54/isl_ioctl.c	2006-03-02 14:51:16.000000000 +0100
@@ -1621,11 +1621,9 @@ prism54_wpa_ie_add(islpci_private *priv,
 					 struct islpci_bss_wpa_ie, list);
 			list_del(&bss->list);
 		} else {
-			bss = kmalloc(sizeof (*bss), GFP_ATOMIC);
-			if (bss != NULL) {
+			bss = kzalloc(sizeof (*bss), GFP_ATOMIC);
+			if (bss != NULL)
 				priv->num_bss_wpa++;
-				memset(bss, 0, sizeof (*bss));
-			}
 		}
 		if (bss != NULL) {
 			memcpy(bss->bssid, bssid, ETH_ALEN);
@@ -2165,11 +2163,10 @@ prism2_ioctl_set_generic_element(struct 
                return -EINVAL;
 
        alen = sizeof(*attach) + len;
-       attach = kmalloc(alen, GFP_KERNEL);
+       attach = kzalloc(alen, GFP_KERNEL);
        if (attach == NULL)
                return -ENOMEM;
 
-       memset(attach, 0, alen);
 #define WLAN_FC_TYPE_MGMT 0
 #define WLAN_FC_STYPE_ASSOC_REQ 0
 #define WLAN_FC_STYPE_REASSOC_REQ 2
--- linux-2.6.16-rc5-mm1/drivers/net/wireless/hostap/hostap_ioctl.c.orig	2006-03-02 14:51:35.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/wireless/hostap/hostap_ioctl.c	2006-03-02 14:53:22.000000000 +0100
@@ -181,12 +181,10 @@ static int prism2_ioctl_siwencode(struct
 		struct ieee80211_crypt_data *new_crypt;
 
 		/* take WEP into use */
-		new_crypt = (struct ieee80211_crypt_data *)
-			kmalloc(sizeof(struct ieee80211_crypt_data),
+		new_crypt = kzalloc(sizeof(struct ieee80211_crypt_data),
 				GFP_KERNEL);
 		if (new_crypt == NULL)
 			return -ENOMEM;
-		memset(new_crypt, 0, sizeof(struct ieee80211_crypt_data));
 		new_crypt->ops = ieee80211_get_crypto_ops("WEP");
 		if (!new_crypt->ops) {
 			request_module("ieee80211_crypt_wep");
@@ -3320,14 +3318,12 @@ static int prism2_ioctl_siwencodeext(str
 
 		prism2_crypt_delayed_deinit(local, crypt);
 
-		new_crypt = (struct ieee80211_crypt_data *)
-			kmalloc(sizeof(struct ieee80211_crypt_data),
+		new_crypt = kzalloc(sizeof(struct ieee80211_crypt_data),
 				GFP_KERNEL);
 		if (new_crypt == NULL) {
 			ret = -ENOMEM;
 			goto done;
 		}
-		memset(new_crypt, 0, sizeof(struct ieee80211_crypt_data));
 		new_crypt->ops = ops;
 		new_crypt->priv = new_crypt->ops->init(i);
 		if (new_crypt->priv == NULL) {
@@ -3542,14 +3538,12 @@ static int prism2_ioctl_set_encryption(l
 
 		prism2_crypt_delayed_deinit(local, crypt);
 
-		new_crypt = (struct ieee80211_crypt_data *)
-			kmalloc(sizeof(struct ieee80211_crypt_data),
+		new_crypt = kzalloc(sizeof(struct ieee80211_crypt_data),
 				GFP_KERNEL);
 		if (new_crypt == NULL) {
 			ret = -ENOMEM;
 			goto done;
 		}
-		memset(new_crypt, 0, sizeof(struct ieee80211_crypt_data));
 		new_crypt->ops = ops;
 		new_crypt->priv = new_crypt->ops->init(param->u.crypt.idx);
 		if (new_crypt->priv == NULL) {
--- linux-2.6.16-rc5-mm1/drivers/net/wireless/hostap/hostap_ap.c.orig	2006-03-02 14:53:34.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/wireless/hostap/hostap_ap.c	2006-03-02 14:54:13.000000000 +0100
@@ -1099,15 +1099,13 @@ static struct sta_info * ap_add_sta(stru
 {
 	struct sta_info *sta;
 
-	sta = (struct sta_info *)
-		kmalloc(sizeof(struct sta_info), GFP_ATOMIC);
+	sta = kzalloc(sizeof(struct sta_info), GFP_ATOMIC);
 	if (sta == NULL) {
 		PDEBUG(DEBUG_AP, "AP: kmalloc failed\n");
 		return NULL;
 	}
 
 	/* initialize STA info data */
-	memset(sta, 0, sizeof(struct sta_info));
 	sta->local = ap->local;
 	skb_queue_head_init(&sta->tx_buf);
 	memcpy(sta->addr, addr, ETH_ALEN);
--- linux-2.6.16-rc5-mm1/drivers/net/wireless/hostap/hostap_cs.c.orig	2006-03-02 14:54:19.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/wireless/hostap/hostap_cs.c	2006-03-02 14:54:35.000000000 +0100
@@ -567,14 +567,13 @@ static int prism2_config(struct pcmcia_d
 	PDEBUG(DEBUG_FLOW, "prism2_config()\n");
 
 	parse = kmalloc(sizeof(cisparse_t), GFP_KERNEL);
-	hw_priv = kmalloc(sizeof(*hw_priv), GFP_KERNEL);
+	hw_priv = kzalloc(sizeof(*hw_priv), GFP_KERNEL);
 	if (parse == NULL || hw_priv == NULL) {
 		kfree(parse);
 		kfree(hw_priv);
 		ret = -ENOMEM;
 		goto failed;
 	}
-	memset(hw_priv, 0, sizeof(*hw_priv));
 
 	tuple.DesiredTuple = CISTPL_CONFIG;
 	tuple.Attributes = 0;
--- linux-2.6.16-rc5-mm1/drivers/net/wireless/hostap/hostap_info.c.orig	2006-03-02 14:54:42.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/wireless/hostap/hostap_info.c	2006-03-02 14:54:59.000000000 +0100
@@ -327,11 +327,10 @@ static void prism2_info_hostscanresults(
 	ptr = (u8 *) pos;
 
 	new_count = left / result_size;
-	results = kmalloc(new_count * sizeof(struct hfa384x_hostscan_result),
+	results = kcalloc(new_count, sizeof(struct hfa384x_hostscan_result),
 			  GFP_ATOMIC);
 	if (results == NULL)
 		return;
-	memset(results, 0, new_count * sizeof(struct hfa384x_hostscan_result));
 
 	for (i = 0; i < new_count; i++) {
 		memcpy(&results[i], ptr, copy_len);
--- linux-2.6.16-rc5-mm1/drivers/net/wireless/hostap/hostap_pci.c.orig	2006-03-02 14:55:47.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/wireless/hostap/hostap_pci.c	2006-03-02 14:55:58.000000000 +0100
@@ -301,10 +301,9 @@ static int prism2_pci_probe(struct pci_d
 	struct hostap_interface *iface;
 	struct hostap_pci_priv *hw_priv;
 
-	hw_priv = kmalloc(sizeof(*hw_priv), GFP_KERNEL);
+	hw_priv = kzalloc(sizeof(*hw_priv), GFP_KERNEL);
 	if (hw_priv == NULL)
 		return -ENOMEM;
-	memset(hw_priv, 0, sizeof(*hw_priv));
 
 	if (pci_enable_device(pdev))
 		return -EIO;
--- linux-2.6.16-rc5-mm1/drivers/net/wireless/hostap/hostap_hw.c.orig	2006-03-02 14:56:05.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/wireless/hostap/hostap_hw.c	2006-03-02 14:56:54.000000000 +0100
@@ -348,14 +348,12 @@ static int hfa384x_cmd(struct net_device
 	if (signal_pending(current))
 		return -EINTR;
 
-	entry = (struct hostap_cmd_queue *)
-		kmalloc(sizeof(*entry), GFP_ATOMIC);
+	entry = kzalloc(sizeof(*entry), GFP_ATOMIC);
 	if (entry == NULL) {
 		printk(KERN_DEBUG "%s: hfa384x_cmd - kmalloc failed\n",
 		       dev->name);
 		return -ENOMEM;
 	}
-	memset(entry, 0, sizeof(*entry));
 	atomic_set(&entry->usecnt, 1);
 	entry->type = CMD_SLEEP;
 	entry->cmd = cmd;
@@ -518,14 +516,12 @@ static int hfa384x_cmd_callback(struct n
 		return -1;
 	}
 
-	entry = (struct hostap_cmd_queue *)
-		kmalloc(sizeof(*entry), GFP_ATOMIC);
+	entry = kzalloc(sizeof(*entry), GFP_ATOMIC);
 	if (entry == NULL) {
 		printk(KERN_DEBUG "%s: hfa384x_cmd_callback - kmalloc "
 		       "failed\n", dev->name);
 		return -ENOMEM;
 	}
-	memset(entry, 0, sizeof(*entry));
 	atomic_set(&entry->usecnt, 1);
 	entry->type = CMD_CALLBACK;
 	entry->cmd = cmd;
@@ -3013,14 +3009,12 @@ static int prism2_set_tim(struct net_dev
 	iface = netdev_priv(dev);
 	local = iface->local;
 
-	new_entry = (struct set_tim_data *)
-		kmalloc(sizeof(*new_entry), GFP_ATOMIC);
+	new_entry = kzalloc(sizeof(*new_entry), GFP_ATOMIC);
 	if (new_entry == NULL) {
 		printk(KERN_DEBUG "%s: prism2_set_tim: kmalloc failed\n",
 		       local->dev->name);
 		return -ENOMEM;
 	}
-	memset(new_entry, 0, sizeof(*new_entry));
 	new_entry->aid = aid;
 	new_entry->set = set;
 
--- linux-2.6.16-rc5-mm1/drivers/net/wireless/hostap/hostap_plx.c.orig	2006-03-02 14:57:02.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/wireless/hostap/hostap_plx.c	2006-03-02 14:57:11.000000000 +0100
@@ -446,10 +446,9 @@ static int prism2_plx_probe(struct pci_d
 	int tmd7160;
 	struct hostap_plx_priv *hw_priv;
 
-	hw_priv = kmalloc(sizeof(*hw_priv), GFP_KERNEL);
+	hw_priv = kzalloc(sizeof(*hw_priv), GFP_KERNEL);
 	if (hw_priv == NULL)
 		return -ENOMEM;
-	memset(hw_priv, 0, sizeof(*hw_priv));
 
 	if (pci_enable_device(pdev))
 		return -EIO;
--- linux-2.6.16-rc5-mm1/drivers/net/e100.c.orig	2006-03-02 14:57:25.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/e100.c	2006-03-02 14:57:41.000000000 +0100
@@ -1882,9 +1882,8 @@ static int e100_rx_alloc_list(struct nic
 
 	nic->rx_to_use = nic->rx_to_clean = NULL;
 
-	if(!(nic->rxs = kmalloc(sizeof(struct rx) * count, GFP_ATOMIC)))
+	if(!(nic->rxs = kcalloc(count, sizeof(struct rx), GFP_ATOMIC)))
 		return -ENOMEM;
-	memset(nic->rxs, 0, sizeof(struct rx) * count);
 
 	for(rx = nic->rxs, i = 0; i < count; rx++, i++) {
 		rx->next = (i + 1 < count) ? rx + 1 : nic->rxs;
--- linux-2.6.16-rc5-mm1/drivers/net/s2io.c.orig	2006-03-02 14:57:50.000000000 +0100
+++ linux-2.6.16-rc5-mm1/drivers/net/s2io.c	2006-03-02 14:58:42.000000000 +0100
@@ -407,14 +407,13 @@ static int init_shared_mem(struct s2io_n
 	for (i = 0; i < config->tx_fifo_num; i++) {
 		int fifo_len = config->tx_cfg[i].fifo_len;
 		int list_holder_size = fifo_len * sizeof(list_info_hold_t);
-		mac_control->fifos[i].list_info = kmalloc(list_holder_size,
+		mac_control->fifos[i].list_info = kzalloc(list_holder_size,
 							  GFP_KERNEL);
 		if (!mac_control->fifos[i].list_info) {
 			DBG_PRINT(ERR_DBG,
 				  "Malloc failed for list_info\n");
 			return -ENOMEM;
 		}
-		memset(mac_control->fifos[i].list_info, 0, list_holder_size);
 	}
 	for (i = 0; i < config->tx_fifo_num; i++) {
 		int page_num = TXD_MEM_PAGE_CNT(config->tx_cfg[i].fifo_len,
@@ -3229,24 +3228,21 @@ static int s2io_enable_msi_x(nic_t *nic)
 	u16 msi_control; /* Temp variable */
 	int ret, i, j, msix_indx = 1;
 
-	nic->entries = kmalloc(MAX_REQUESTED_MSI_X * sizeof(struct msix_entry),
+	nic->entries = kzalloc(MAX_REQUESTED_MSI_X * sizeof(struct msix_entry),
 			       GFP_KERNEL);
 	if (nic->entries == NULL) {
 		DBG_PRINT(ERR_DBG, "%s: Memory allocation failed\n", __FUNCTION__);
 		return -ENOMEM;
 	}
-	memset(nic->entries, 0, MAX_REQUESTED_MSI_X * sizeof(struct msix_entry));
 
 	nic->s2io_entries =
-		kmalloc(MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry),
+		kzalloc(MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry),
 				   GFP_KERNEL);
 	if (nic->s2io_entries == NULL) {
 		DBG_PRINT(ERR_DBG, "%s: Memory allocation failed\n", __FUNCTION__);
 		kfree(nic->entries);
 		return -ENOMEM;
 	}
-	memset(nic->s2io_entries, 0,
-	       MAX_REQUESTED_MSI_X * sizeof(struct s2io_msix_entry));
 
 	for (i=0; i< MAX_REQUESTED_MSI_X; i++) {
 		nic->entries[i].entry = i;



--===============27799367002343778==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Kernel-janitors mailing list
Kernel-janitors@lists.osdl.org
https://lists.osdl.org/mailman/listinfo/kernel-janitors

--===============27799367002343778==--
