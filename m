From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 1/15] netdevice: safe convert to netdev_priv() #part-1
Date: Tue, 26 Aug 2008 22:18:12 +0800
Message-ID: <48B410A4.5000703@cn.fujitsu.com>
References: <48B3D717.7070706@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61129 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754161AbYHZOUs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Aug 2008 10:20:48 -0400
In-Reply-To: <48B3D717.7070706@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch is too big to be sent in one mail.
I split it to 18 parts.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
diff --git a/drivers/net/3c501.c b/drivers/net/3c501.c
index 5ba4bab..bf2f409 100644
--- a/drivers/net/3c501.c
+++ b/drivers/net/3c501.c
@@ -297,8 +297,8 @@ static int __init el1_probe1(struct net_device *dev, int ioaddr)
 	if (el_debug)
 		printk(KERN_DEBUG "%s", version);
 
-	memset(dev->priv, 0, sizeof(struct net_local));
 	lp = netdev_priv(dev);
+	memset(lp, 0, sizeof(struct net_local));
 	spin_lock_init(&lp->lock);
 
 	/*
diff --git a/drivers/net/3c505.c b/drivers/net/3c505.c
index fdfb2b2..23e2125 100644
--- a/drivers/net/3c505.c
+++ b/drivers/net/3c505.c
@@ -203,10 +203,10 @@ static inline int inb_command(unsigned int base_addr)
 static inline void outb_control(unsigned char val, struct net_device *dev)
 {
 	outb(val, dev->base_addr + PORT_CONTROL);
-	((elp_device *)(dev->priv))->hcr_val = val;
+	((elp_device *)(netdev_priv(dev)))->hcr_val = val;
 }
 
-#define HCR_VAL(x)   (((elp_device *)((x)->priv))->hcr_val)
+#define HCR_VAL(x)   (((elp_device *)(netdev_priv(x)))->hcr_val)
 
 static inline void outb_command(unsigned char val, unsigned int base_addr)
 {
@@ -247,7 +247,7 @@ static inline int get_status(unsigned int base_addr)
 
 static inline void set_hsf(struct net_device *dev, int hsf)
 {
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	unsigned long flags;
 
 	spin_lock_irqsave(&adapter->lock, flags);
@@ -260,7 +260,7 @@ static bool start_receive(struct net_device *, pcb_struct *);
 static inline void adapter_reset(struct net_device *dev)
 {
 	unsigned long timeout;
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	unsigned char orig_hcr = adapter->hcr_val;
 
 	outb_control(0, dev);
@@ -293,7 +293,7 @@ static inline void adapter_reset(struct net_device *dev)
  */
 static inline void check_3c505_dma(struct net_device *dev)
 {
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	if (adapter->dmaing && time_after(jiffies, adapter->current_dma.start_time + 10)) {
 		unsigned long flags, f;
 		printk(KERN_ERR "%s: DMA %s timed out, %d bytes left\n", dev->name, adapter->current_dma.direction ? "download" : "upload", get_dma_residue(dev->dma));
@@ -340,7 +340,7 @@ static inline bool send_pcb_fast(unsigned int base_addr, unsigned char byte)
 /* Check to see if the receiver needs restarting, and kick it if so */
 static inline void prime_rx(struct net_device *dev)
 {
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	while (adapter->rx_active < ELP_RX_PCBS && netif_running(dev)) {
 		if (!start_receive(dev, &adapter->itx_pcb))
 			break;
@@ -375,7 +375,7 @@ static bool send_pcb(struct net_device *dev, pcb_struct * pcb)
 {
 	int i;
 	unsigned long timeout;
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	unsigned long flags;
 
 	check_3c505_dma(dev);
@@ -463,7 +463,7 @@ static bool receive_pcb(struct net_device *dev, pcb_struct * pcb)
 	unsigned long timeout;
 	unsigned long flags;
 
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 
 	set_hsf(dev, 0);
 
@@ -543,7 +543,7 @@ static bool receive_pcb(struct net_device *dev, pcb_struct * pcb)
 static bool start_receive(struct net_device *dev, pcb_struct * tx_pcb)
 {
 	bool status;
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 
 	if (elp_debug >= 3)
 		printk(KERN_DEBUG "%s: restarting receiver\n", dev->name);
@@ -571,7 +571,7 @@ static bool start_receive(struct net_device *dev, pcb_struct * tx_pcb)
 static void receive_packet(struct net_device *dev, int len)
 {
 	int rlen;
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	void *target;
 	struct sk_buff *skb;
 	unsigned long flags;
@@ -638,13 +638,10 @@ static irqreturn_t elp_interrupt(int irq, void *dev_id)
 	int len;
 	int dlen;
 	int icount = 0;
-	struct net_device *dev;
-	elp_device *adapter;
+	struct net_device *dev = dev_id;
+	elp_device *adapter = netdev_priv(dev);
 	unsigned long timeout;
 
-	dev = dev_id;
-	adapter = (elp_device *) dev->priv;
-
 	spin_lock(&adapter->lock);
 
 	do {
@@ -838,11 +835,9 @@ static irqreturn_t elp_interrupt(int irq, void *dev_id)
 
 static int elp_open(struct net_device *dev)
 {
-	elp_device *adapter;
+	elp_device *adapter = netdev_priv(dev);
 	int retval;
 
-	adapter = dev->priv;
-
 	if (elp_debug >= 3)
 		printk(KERN_DEBUG "%s: request to open device\n", dev->name);
 
@@ -971,7 +966,7 @@ static int elp_open(struct net_device *dev)
 
 static bool send_packet(struct net_device *dev, struct sk_buff *skb)
 {
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	unsigned long target;
 	unsigned long flags;
 
@@ -1062,7 +1057,7 @@ static void elp_timeout(struct net_device *dev)
 static int elp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned long flags;
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 
 	spin_lock_irqsave(&adapter->lock, flags);
 	check_3c505_dma(dev);
@@ -1104,7 +1099,7 @@ static int elp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 static struct net_device_stats *elp_get_stats(struct net_device *dev)
 {
-	elp_device *adapter = (elp_device *) dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 
 	if (elp_debug >= 3)
 		printk(KERN_DEBUG "%s: request for stats\n", dev->name);
@@ -1166,9 +1161,7 @@ static const struct ethtool_ops netdev_ethtool_ops = {
 
 static int elp_close(struct net_device *dev)
 {
-	elp_device *adapter;
-
-	adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 
 	if (elp_debug >= 3)
 		printk(KERN_DEBUG "%s: request to close device\n", dev->name);
@@ -1209,7 +1202,7 @@ static int elp_close(struct net_device *dev)
 
 static void elp_set_mc_list(struct net_device *dev)
 {
-	elp_device *adapter = (elp_device *) dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	struct dev_mc_list *dmi = dev->mc_list;
 	int i;
 	unsigned long flags;
@@ -1380,7 +1373,7 @@ static int __init elp_autodetect(struct net_device *dev)
 
 static int __init elplus_setup(struct net_device *dev)
 {
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	int i, tries, tries1, okay;
 	unsigned long timeout;
 	unsigned long cookie = 0;
diff --git a/drivers/net/3c523.c b/drivers/net/3c523.c
index e2ce41d..0fdac5f 100644
--- a/drivers/net/3c523.c
+++ b/drivers/net/3c523.c
@@ -308,7 +308,7 @@ static int elmc_open(struct net_device *dev)
 
 static int __init check586(struct net_device *dev, unsigned long where, unsigned size)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 	char *iscp_addrs[2];
 	int i = 0;
 
@@ -349,7 +349,7 @@ static int __init check586(struct net_device *dev, unsigned long where, unsigned
 
 void alloc586(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	elmc_id_reset586();
 	DELAY(2);
@@ -416,7 +416,7 @@ static int __init do_elmc_probe(struct net_device *dev)
 	int i = 0;
 	unsigned int size = 0;
 	int retval;
-	struct priv *pr = dev->priv;
+	struct priv *pr = netdev_priv(dev);
 	DECLARE_MAC_BUF(mac);
 
 	if (MCA_bus == 0) {
@@ -580,7 +580,8 @@ err_out:
 
 static void cleanup_card(struct net_device *dev)
 {
-	mca_set_adapter_procfn(((struct priv *) (dev->priv))->slot, NULL, NULL);
+	mca_set_adapter_procfn(((struct priv *)netdev_priv(dev))->slot,
+				NULL, NULL);
 	release_region(dev->base_addr, ELMC_IO_EXTENT);
 }
 
@@ -616,7 +617,7 @@ static int init586(struct net_device *dev)
 	void *ptr;
 	unsigned long s;
 	int i, result = 0;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 	volatile struct configure_cmd_struct *cfg_cmd;
 	volatile struct iasetup_cmd_struct *ias_cmd;
 	volatile struct tdr_cmd_struct *tdr_cmd;
@@ -852,7 +853,7 @@ static void *alloc_rfa(struct net_device *dev, void *ptr)
 	volatile struct rfd_struct *rfd = (struct rfd_struct *) ptr;
 	volatile struct rbd_struct *rbd;
 	int i;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	memset((char *) rfd, 0, sizeof(struct rfd_struct) * p->num_recv_buffs);
 	p->rfd_first = rfd;
@@ -913,7 +914,7 @@ elmc_interrupt(int irq, void *dev_id)
 	}
 	/* reading ELMC_CTRL also clears the INT bit. */
 
-	p = (struct priv *) dev->priv;
+	p = netdev_priv(dev);
 
 	while ((stat = p->scb->status & STAT_MASK))
 	{
@@ -969,7 +970,7 @@ static void elmc_rcv_int(struct net_device *dev)
 	unsigned short totlen;
 	struct sk_buff *skb;
 	struct rbd_struct *rbd;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	for (; (status = p->rfd_top->status) & STAT_COMPL;) {
 		rbd = (struct rbd_struct *) make32(p->rfd_top->rbd_offset);
@@ -1013,7 +1014,7 @@ static void elmc_rcv_int(struct net_device *dev)
 
 static void elmc_rnr_int(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	dev->stats.rx_errors++;
 
@@ -1036,7 +1037,7 @@ static void elmc_rnr_int(struct net_device *dev)
 static void elmc_xmt_int(struct net_device *dev)
 {
 	int status;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	status = p->xmit_cmds[p->xmit_last]->cmd_status;
 	if (!(status & STAT_COMPL)) {
@@ -1079,7 +1080,7 @@ static void elmc_xmt_int(struct net_device *dev)
 
 static void startrecv586(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	p->scb->rfa_offset = make16(p->rfd_first);
 	p->scb->cmd = RUC_START;
@@ -1093,7 +1094,7 @@ static void startrecv586(struct net_device *dev)
 
 static void elmc_timeout(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 	/* COMMAND-UNIT active? */
 	if (p->scb->status & CU_ACTIVE) {
 #ifdef DEBUG
@@ -1129,7 +1130,7 @@ static int elmc_send_packet(struct sk_buff *skb, struct net_device *dev)
 #ifndef NO_NOPCOMMANDS
 	int next_nop;
 #endif
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	netif_stop_queue(dev);
 
@@ -1200,7 +1201,7 @@ static int elmc_send_packet(struct sk_buff *skb, struct net_device *dev)
 
 static struct net_device_stats *elmc_get_stats(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 	unsigned short crc, aln, rsc, ovrn;
 
 	crc = p->scb->crc_errs;	/* get error-statistic from the ni82586 */
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 491ee16..da01975 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -803,7 +803,7 @@ static int vortex_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 
-	if (dev && dev->priv) {
+	if (dev && netdev_priv(dev)) {
 		if (netif_running(dev)) {
 			netif_device_detach(dev);
 			vortex_down(dev, 1);
@@ -3217,7 +3217,7 @@ static void __exit vortex_eisa_cleanup(void)
 #endif
 
 	if (compaq_net_device) {
-		vp = compaq_net_device->priv;
+		vp = netdev_priv(compaq_net_device);
 		ioaddr = ioport_map(compaq_net_device->base_addr,
 		                    VORTEX_TOTAL_SIZE);
 
diff --git a/drivers/net/iseries_veth.c b/drivers/net/iseries_veth.c
index c46864d..c7457f9 100644
--- a/drivers/net/iseries_veth.c
+++ b/drivers/net/iseries_veth.c
@@ -952,7 +952,7 @@ static int veth_change_mtu(struct net_device *dev, int new_mtu)
 
 static void veth_set_multicast_list(struct net_device *dev)
 {
-	struct veth_port *port = (struct veth_port *) dev->priv;
+	struct veth_port *port = netdev_priv(dev);
 	unsigned long flags;
 
 	write_lock_irqsave(&port->mcast_gate, flags);
@@ -1044,7 +1044,7 @@ static struct net_device *veth_probe_one(int vlan,
 		return NULL;
 	}
 
-	port = (struct veth_port *) dev->priv;
+	port = netdev_priv(dev);
 
 	spin_lock_init(&port->queue_lock);
 	rwlock_init(&port->mcast_gate);
@@ -1102,7 +1102,7 @@ static int veth_transmit_to_one(struct sk_buff *skb, HvLpIndex rlp,
 				struct net_device *dev)
 {
 	struct veth_lpar_connection *cnx = veth_cnx[rlp];
-	struct veth_port *port = (struct veth_port *) dev->priv;
+	struct veth_port *port = netdev_priv(dev);
 	HvLpEvent_Rc rc;
 	struct veth_msg *msg = NULL;
 	unsigned long flags;
@@ -1191,7 +1191,7 @@ static void veth_transmit_to_many(struct sk_buff *skb,
 static int veth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned char *frame = skb->data;
-	struct veth_port *port = (struct veth_port *) dev->priv;
+	struct veth_port *port = netdev_priv(dev);
 	HvLpIndexMap lpmask;
 
 	if (! (frame[0] & 0x01)) {
@@ -1255,7 +1255,7 @@ static void veth_wake_queues(struct veth_lpar_connection *cnx)
 		if (! dev)
 			continue;
 
-		port = (struct veth_port *)dev->priv;
+		port = netdev_priv(dev);
 
 		if (! (port->lpar_map & (1<<cnx->remote_lp)))
 			continue;
@@ -1284,7 +1284,7 @@ static void veth_stop_queues(struct veth_lpar_connection *cnx)
 		if (! dev)
 			continue;
 
-		port = (struct veth_port *)dev->priv;
+		port = netdev_priv(dev);
 
 		/* If this cnx is not on the vlan for this port, continue */
 		if (! (port->lpar_map & (1 << cnx->remote_lp)))
@@ -1506,7 +1506,7 @@ static void veth_receive(struct veth_lpar_connection *cnx,
 			continue;
 		}
 
-		port = (struct veth_port *)dev->priv;
+		port = netdev_priv(dev);
 		dest = *((u64 *) skb->data) & 0xFFFFFFFFFFFF0000;
 
 		if ((vlan > HVMAXARCHITECTEDVIRTUALLANS) || !port) {





