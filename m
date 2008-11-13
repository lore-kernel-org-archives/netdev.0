From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 1/4 net-next] netdevice: safe convert to netdev_priv() #part-1
Date: Thu, 13 Nov 2008 10:43:34 +0800
Message-ID: <491B9456.6090602@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: Jeff Garzik <jgarzik@pobox.com>, NETDEV <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:56071 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750939AbYKMCnt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Nov 2008 21:43:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have some reasons to kill netdev->priv:
1. netdev->priv is equal to netdev_priv().
2. netdev_priv() wraps the calculation of netdev->priv's offset, obviously
   netdev_priv() is more flexible than netdev->priv.
But we cann't kill netdev->priv, because so many drivers reference to it
directly.

This patch is a safe convert for netdev->priv to netdev_priv(netdev).
Since all of the netdev->priv is only for read.
But it is too big to be sent in one mail.
I split it to 4 parts and make every part smaller than 100,000 bytes,
which is max size allowed by vger.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 drivers/net/3c501.c               |    2 +-
 drivers/net/3c505.c               |   45 ++++++++++++----------------
 drivers/net/3c523.c               |   29 +++++++++---------
 drivers/net/3c59x.c               |    4 +-
 drivers/net/acenic.c              |    2 +-
 drivers/net/appletalk/ipddp.c     |    6 ++--
 drivers/net/appletalk/ltpc.c      |   12 +++++--
 drivers/net/arcnet/arc-rawmode.c  |    4 +-
 drivers/net/arcnet/arc-rimi.c     |   16 +++++-----
 drivers/net/arcnet/arcnet.c       |   32 ++++++++++----------
 drivers/net/arcnet/capmode.c      |    6 ++--
 drivers/net/arcnet/com20020-isa.c |    4 +-
 drivers/net/arcnet/com20020-pci.c |    2 +-
 drivers/net/arcnet/com20020.c     |   10 +++---
 drivers/net/arcnet/com90io.c      |    4 +-
 drivers/net/arcnet/com90xx.c      |   10 +++---
 drivers/net/arcnet/rfc1051.c      |    8 ++--
 drivers/net/arcnet/rfc1201.c      |   12 ++++----
 drivers/net/atarilance.c          |   34 +++++++++++-----------
 drivers/net/atl1e/atl1e_main.c    |    6 ++--
 drivers/net/atp.c                 |    3 +-
 drivers/net/au1000_eth.c          |   48 +++++++++++++++---------------
 drivers/net/bonding/bond_3ad.c    |    7 ++--
 drivers/net/bonding/bond_alb.c    |    6 ++--
 drivers/net/bonding/bond_main.c   |   58 ++++++++++++++++++------------------
 drivers/net/bonding/bond_sysfs.c  |    2 +-
 drivers/net/bonding/bonding.h     |    4 +-
 drivers/net/iseries_veth.c        |   14 ++++----
 drivers/net/ixgbe/ixgbe_ethtool.c |    6 ++--
 drivers/net/ixgbe/ixgbe_main.c    |    6 ++--
 drivers/net/lp486e.c              |   28 +++++++++---------
 drivers/net/mace.c                |   28 +++++++++---------
 32 files changed, 229 insertions(+), 229 deletions(-)

diff --git a/drivers/net/3c501.c b/drivers/net/3c501.c
index 3a44db1..3d1318a 100644
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
index e669da7..6124605 100644
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
@@ -837,11 +834,9 @@ static irqreturn_t elp_interrupt(int irq, void *dev_id)
 
 static int elp_open(struct net_device *dev)
 {
-	elp_device *adapter;
+	elp_device *adapter = netdev_priv(dev);
 	int retval;
 
-	adapter = dev->priv;
-
 	if (elp_debug >= 3)
 		printk(KERN_DEBUG "%s: request to open device\n", dev->name);
 
@@ -970,7 +965,7 @@ static int elp_open(struct net_device *dev)
 
 static bool send_packet(struct net_device *dev, struct sk_buff *skb)
 {
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	unsigned long target;
 	unsigned long flags;
 
@@ -1061,7 +1056,7 @@ static void elp_timeout(struct net_device *dev)
 static int elp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned long flags;
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 
 	spin_lock_irqsave(&adapter->lock, flags);
 	check_3c505_dma(dev);
@@ -1103,7 +1098,7 @@ static int elp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 static struct net_device_stats *elp_get_stats(struct net_device *dev)
 {
-	elp_device *adapter = (elp_device *) dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 
 	if (elp_debug >= 3)
 		printk(KERN_DEBUG "%s: request for stats\n", dev->name);
@@ -1165,9 +1160,7 @@ static const struct ethtool_ops netdev_ethtool_ops = {
 
 static int elp_close(struct net_device *dev)
 {
-	elp_device *adapter;
-
-	adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 
 	if (elp_debug >= 3)
 		printk(KERN_DEBUG "%s: request to close device\n", dev->name);
@@ -1208,7 +1201,7 @@ static int elp_close(struct net_device *dev)
 
 static void elp_set_mc_list(struct net_device *dev)
 {
-	elp_device *adapter = (elp_device *) dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	struct dev_mc_list *dmi = dev->mc_list;
 	int i;
 	unsigned long flags;
@@ -1379,7 +1372,7 @@ static int __init elp_autodetect(struct net_device *dev)
 
 static int __init elplus_setup(struct net_device *dev)
 {
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	int i, tries, tries1, okay;
 	unsigned long timeout;
 	unsigned long cookie = 0;
diff --git a/drivers/net/3c523.c b/drivers/net/3c523.c
index 0885aee..59ea291 100644
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
@@ -415,7 +415,7 @@ static int __init do_elmc_probe(struct net_device *dev)
 	int i = 0;
 	unsigned int size = 0;
 	int retval;
-	struct priv *pr = dev->priv;
+	struct priv *pr = netdev_priv(dev);
 
 	if (MCA_bus == 0) {
 		return -ENODEV;
@@ -578,7 +578,8 @@ err_out:
 
 static void cleanup_card(struct net_device *dev)
 {
-	mca_set_adapter_procfn(((struct priv *) (dev->priv))->slot, NULL, NULL);
+	mca_set_adapter_procfn(((struct priv *)netdev_priv(dev))->slot,
+				NULL, NULL);
 	release_region(dev->base_addr, ELMC_IO_EXTENT);
 }
 
@@ -614,7 +615,7 @@ static int init586(struct net_device *dev)
 	void *ptr;
 	unsigned long s;
 	int i, result = 0;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 	volatile struct configure_cmd_struct *cfg_cmd;
 	volatile struct iasetup_cmd_struct *ias_cmd;
 	volatile struct tdr_cmd_struct *tdr_cmd;
@@ -850,7 +851,7 @@ static void *alloc_rfa(struct net_device *dev, void *ptr)
 	volatile struct rfd_struct *rfd = (struct rfd_struct *) ptr;
 	volatile struct rbd_struct *rbd;
 	int i;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	memset((char *) rfd, 0, sizeof(struct rfd_struct) * p->num_recv_buffs);
 	p->rfd_first = rfd;
@@ -911,7 +912,7 @@ elmc_interrupt(int irq, void *dev_id)
 	}
 	/* reading ELMC_CTRL also clears the INT bit. */
 
-	p = (struct priv *) dev->priv;
+	p = netdev_priv(dev);
 
 	while ((stat = p->scb->status & STAT_MASK))
 	{
@@ -967,7 +968,7 @@ static void elmc_rcv_int(struct net_device *dev)
 	unsigned short totlen;
 	struct sk_buff *skb;
 	struct rbd_struct *rbd;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	for (; (status = p->rfd_top->status) & STAT_COMPL;) {
 		rbd = (struct rbd_struct *) make32(p->rfd_top->rbd_offset);
@@ -1010,7 +1011,7 @@ static void elmc_rcv_int(struct net_device *dev)
 
 static void elmc_rnr_int(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	dev->stats.rx_errors++;
 
@@ -1033,7 +1034,7 @@ static void elmc_rnr_int(struct net_device *dev)
 static void elmc_xmt_int(struct net_device *dev)
 {
 	int status;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	status = p->xmit_cmds[p->xmit_last]->cmd_status;
 	if (!(status & STAT_COMPL)) {
@@ -1076,7 +1077,7 @@ static void elmc_xmt_int(struct net_device *dev)
 
 static void startrecv586(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	p->scb->rfa_offset = make16(p->rfd_first);
 	p->scb->cmd = RUC_START;
@@ -1090,7 +1091,7 @@ static void startrecv586(struct net_device *dev)
 
 static void elmc_timeout(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 	/* COMMAND-UNIT active? */
 	if (p->scb->status & CU_ACTIVE) {
 #ifdef DEBUG
@@ -1126,7 +1127,7 @@ static int elmc_send_packet(struct sk_buff *skb, struct net_device *dev)
 #ifndef NO_NOPCOMMANDS
 	int next_nop;
 #endif
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	netif_stop_queue(dev);
 
@@ -1197,7 +1198,7 @@ static int elmc_send_packet(struct sk_buff *skb, struct net_device *dev)
 
 static struct net_device_stats *elmc_get_stats(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 	unsigned short crc, aln, rsc, ovrn;
 
 	crc = p->scb->crc_errs;	/* get error-statistic from the ni82586 */
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 3893f50..665e7fd 100644
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
@@ -3214,7 +3214,7 @@ static void __exit vortex_eisa_cleanup(void)
 #endif
 
 	if (compaq_net_device) {
-		vp = compaq_net_device->priv;
+		vp = netdev_priv(compaq_net_device);
 		ioaddr = ioport_map(compaq_net_device->base_addr,
 		                    VORTEX_TOTAL_SIZE);
 
diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index b9d35f6..109eb7c 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -466,7 +466,7 @@ static int __devinit acenic_probe_one(struct pci_dev *pdev,
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	ap = dev->priv;
+	ap = netdev_priv(dev);
 	ap->pdev = pdev;
 	ap->name = pci_name(pdev);
 
diff --git a/drivers/net/appletalk/ipddp.c b/drivers/net/appletalk/ipddp.c
index 1071144..9a0be9b 100644
--- a/drivers/net/appletalk/ipddp.c
+++ b/drivers/net/appletalk/ipddp.c
@@ -108,7 +108,7 @@ static struct net_device * __init ipddp_init(void)
  */
 static struct net_device_stats *ipddp_get_stats(struct net_device *dev)
 {
-        return dev->priv;
+	return netdev_priv(dev);
 }
 
 /*
@@ -170,8 +170,8 @@ static int ipddp_xmit(struct sk_buff *skb, struct net_device *dev)
 
         skb->protocol = htons(ETH_P_ATALK);     /* Protocol has changed */
 
-	((struct net_device_stats *) dev->priv)->tx_packets++;
-        ((struct net_device_stats *) dev->priv)->tx_bytes+=skb->len;
+	((struct net_device_stats *) netdev_priv(dev))->tx_packets++;
+	((struct net_device_stats *) netdev_priv(dev))->tx_bytes += skb->len;
 
         if(aarp_send_ddp(rt->dev, skb, &rt->at, NULL) < 0)
                 dev_kfree_skb(skb);
diff --git a/drivers/net/appletalk/ltpc.c b/drivers/net/appletalk/ltpc.c
index 8d109a5..dc4d496 100644
--- a/drivers/net/appletalk/ltpc.c
+++ b/drivers/net/appletalk/ltpc.c
@@ -726,7 +726,8 @@ static int sendup_buffer (struct net_device *dev)
 	int dnode, snode, llaptype, len; 
 	int sklen;
 	struct sk_buff *skb;
-	struct net_device_stats *stats = &((struct ltpc_private *)dev->priv)->stats;
+	struct ltpc_private *ltpc_priv = netdev_priv(dev);
+	struct net_device_stats *stats = &ltpc_priv->stats;
 	struct lt_rcvlap *ltc = (struct lt_rcvlap *) ltdmacbuf;
 
 	if (ltc->command != LT_RCVLAP) {
@@ -822,7 +823,8 @@ static int ltpc_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct sockaddr_at *sa = (struct sockaddr_at *) &ifr->ifr_addr;
 	/* we'll keep the localtalk node address in dev->pa_addr */
-	struct atalk_addr *aa = &((struct ltpc_private *)dev->priv)->my_addr;
+	struct ltpc_private *ltpc_priv = netdev_priv(dev);
+	struct atalk_addr *aa = &ltpc_priv->my_addr;
 	struct lt_init c;
 	int ltflags;
 
@@ -903,7 +905,8 @@ static int ltpc_xmit(struct sk_buff *skb, struct net_device *dev)
 	 * and skb->len is the length of the ddp data + ddp header
 	 */
 
-	struct net_device_stats *stats = &((struct ltpc_private *)dev->priv)->stats;
+	struct ltpc_private *ltpc_priv = netdev_priv(dev);
+	struct net_device_stats *stats = &ltpc_priv->stats;
 
 	int i;
 	struct lt_sendlap cbuf;
@@ -942,7 +945,8 @@ static int ltpc_xmit(struct sk_buff *skb, struct net_device *dev)
 
 static struct net_device_stats *ltpc_get_stats(struct net_device *dev)
 {
-	struct net_device_stats *stats = &((struct ltpc_private *) dev->priv)->stats;
+	struct ltpc_private *ltpc_priv = netdev_priv(dev);
+	struct net_device_stats *stats = &ltpc_priv->stats;
 	return stats;
 }
 
diff --git a/drivers/net/arcnet/arc-rawmode.c b/drivers/net/arcnet/arc-rawmode.c
index 60088b3..3ff9aff 100644
--- a/drivers/net/arcnet/arc-rawmode.c
+++ b/drivers/net/arcnet/arc-rawmode.c
@@ -87,7 +87,7 @@ MODULE_LICENSE("GPL");
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct sk_buff *skb;
 	struct archdr *pkt = pkthdr;
 	int ofs;
@@ -167,7 +167,7 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		      int bufnum)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct arc_hardware *hard = &pkt->hard;
 	int ofs;
 
diff --git a/drivers/net/arcnet/arc-rimi.c b/drivers/net/arcnet/arc-rimi.c
index 8c8d6c4..e3082a9 100644
--- a/drivers/net/arcnet/arc-rimi.c
+++ b/drivers/net/arcnet/arc-rimi.c
@@ -194,7 +194,7 @@ static int __init arcrimi_found(struct net_device *dev)
 
 	/* initialize the rest of the device structure. */
 
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	lp->card_name = "RIM I";
 	lp->hw.command = arcrimi_command;
 	lp->hw.status = arcrimi_status;
@@ -260,7 +260,7 @@ err_free_irq:
  */
 static int arcrimi_reset(struct net_device *dev, int really_reset)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
 	BUGMSG(D_INIT, "Resetting %s (status=%02Xh)\n", dev->name, ASTATUS());
@@ -281,7 +281,7 @@ static int arcrimi_reset(struct net_device *dev, int really_reset)
 
 static void arcrimi_setmask(struct net_device *dev, int mask)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
 	AINTMASK(mask);
@@ -289,7 +289,7 @@ static void arcrimi_setmask(struct net_device *dev, int mask)
 
 static int arcrimi_status(struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
 	return ASTATUS();
@@ -297,7 +297,7 @@ static int arcrimi_status(struct net_device *dev)
 
 static void arcrimi_command(struct net_device *dev, int cmd)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *ioaddr = lp->mem_start + 0x800;
 
 	ACOMMAND(cmd);
@@ -306,7 +306,7 @@ static void arcrimi_command(struct net_device *dev, int cmd)
 static void arcrimi_copy_to_card(struct net_device *dev, int bufnum, int offset,
 				 void *buf, int count)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *memaddr = lp->mem_start + 0x800 + bufnum * 512 + offset;
 	TIME("memcpy_toio", count, memcpy_toio(memaddr, buf, count));
 }
@@ -315,7 +315,7 @@ static void arcrimi_copy_to_card(struct net_device *dev, int bufnum, int offset,
 static void arcrimi_copy_from_card(struct net_device *dev, int bufnum, int offset,
 				   void *buf, int count)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *memaddr = lp->mem_start + 0x800 + bufnum * 512 + offset;
 	TIME("memcpy_fromio", count, memcpy_fromio(buf, memaddr, count));
 }
@@ -361,7 +361,7 @@ static int __init arc_rimi_init(void)
 static void __exit arc_rimi_exit(void)
 {
 	struct net_device *dev = my_dev;
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 
 	unregister_netdev(dev);
 	iounmap(lp->mem_start);
diff --git a/drivers/net/arcnet/arcnet.c b/drivers/net/arcnet/arcnet.c
index a5b0769..6b53e5e 100644
--- a/drivers/net/arcnet/arcnet.c
+++ b/drivers/net/arcnet/arcnet.c
@@ -181,7 +181,7 @@ EXPORT_SYMBOL(arcnet_dump_skb);
 static void arcnet_dump_packet(struct net_device *dev, int bufnum,
 			       char *desc, int take_arcnet_lock)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int i, length;
 	unsigned long flags = 0;
 	static uint8_t buf[512];
@@ -247,7 +247,7 @@ void arcnet_unregister_proto(struct ArcProto *proto)
  */
 static void release_arcbuf(struct net_device *dev, int bufnum)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int i;
 
 	lp->buf_queue[lp->first_free_buf++] = bufnum;
@@ -269,7 +269,7 @@ static void release_arcbuf(struct net_device *dev, int bufnum)
  */
 static int get_arcbuf(struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int buf = -1, i;
 
 	if (!atomic_dec_and_test(&lp->buf_lock)) {
@@ -357,7 +357,7 @@ struct net_device *alloc_arcdev(char *name)
 	dev = alloc_netdev(sizeof(struct arcnet_local),
 			   name && *name ? name : "arc%d", arcdev_setup);
 	if(dev) {
-		struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+		struct arcnet_local *lp = netdev_priv(dev);
 		spin_lock_init(&lp->lock);
 	}
 
@@ -374,7 +374,7 @@ struct net_device *alloc_arcdev(char *name)
  */
 static int arcnet_open(struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int count, newmtu, error;
 
 	BUGMSG(D_INIT,"opened.");
@@ -474,7 +474,7 @@ static int arcnet_open(struct net_device *dev)
 /* The inverse routine to arcnet_open - shuts down the card. */
 static int arcnet_close(struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 
 	netif_stop_queue(dev);
 
@@ -556,7 +556,7 @@ static int arcnet_header(struct sk_buff *skb, struct net_device *dev,
 static int arcnet_rebuild_header(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int status = 0;		/* default is failure */
 	unsigned short type;
 	uint8_t daddr=0;
@@ -603,7 +603,7 @@ static int arcnet_rebuild_header(struct sk_buff *skb)
 /* Called by the kernel in order to transmit a packet. */
 static int arcnet_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct archdr *pkt;
 	struct arc_rfc1201 *soft;
 	struct ArcProto *proto;
@@ -693,7 +693,7 @@ static int arcnet_send_packet(struct sk_buff *skb, struct net_device *dev)
  */
 static int go_tx(struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 
 	BUGMSG(D_DURING, "go_tx: status=%Xh, intmask=%Xh, next_tx=%d, cur_tx=%d\n",
 	       ASTATUS(), lp->intmask, lp->next_tx, lp->cur_tx);
@@ -723,7 +723,7 @@ static int go_tx(struct net_device *dev)
 static void arcnet_timeout(struct net_device *dev)
 {
 	unsigned long flags;
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int status = ASTATUS();
 	char *msg;
 
@@ -771,8 +771,8 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
 	BUGMSG(D_DURING, "\n");
 
 	BUGMSG(D_DURING, "in arcnet_interrupt\n");
-	
-	lp = dev->priv;
+
+	lp = netdev_priv(dev);
 	BUG_ON(!lp);
 		
 	spin_lock(&lp->lock);
@@ -1010,7 +1010,7 @@ irqreturn_t arcnet_interrupt(int irq, void *dev_id)
  */
 static void arcnet_rx(struct net_device *dev, int bufnum)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct archdr pkt;
 	struct arc_rfc1201 *soft;
 	int length, ofs;
@@ -1074,7 +1074,7 @@ static void arcnet_rx(struct net_device *dev, int bufnum)
  */
 static struct net_device_stats *arcnet_get_stats(struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	return &lp->stats;
 }
 
@@ -1091,7 +1091,7 @@ static void null_rx(struct net_device *dev, int bufnum,
 static int null_build_header(struct sk_buff *skb, struct net_device *dev,
 			     unsigned short type, uint8_t daddr)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 
 	BUGMSG(D_PROTO,
 	       "tx: can't build header for encap %02Xh; load a protocol driver.\n",
@@ -1106,7 +1106,7 @@ static int null_build_header(struct sk_buff *skb, struct net_device *dev,
 static int null_prepare_tx(struct net_device *dev, struct archdr *pkt,
 			   int length, int bufnum)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct arc_hardware newpkt;
 
 	BUGMSG(D_PROTO, "tx: no encap for this host; load a protocol driver.\n");
diff --git a/drivers/net/arcnet/capmode.c b/drivers/net/arcnet/capmode.c
index 67bc47a..e544953 100644
--- a/drivers/net/arcnet/capmode.c
+++ b/drivers/net/arcnet/capmode.c
@@ -103,7 +103,7 @@ MODULE_LICENSE("GPL");
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct sk_buff *skb;
 	struct archdr *pkt = pkthdr;
 	char *pktbuf, *pkthdrbuf;
@@ -197,7 +197,7 @@ static int build_header(struct sk_buff *skb,
 static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		      int bufnum)
 {
-	struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct arc_hardware *hard = &pkt->hard;
 	int ofs;
 
@@ -249,7 +249,7 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 
 static int ack_tx(struct net_device *dev, int acked)
 {
-  struct arcnet_local *lp = (struct arcnet_local *) dev->priv;
+  struct arcnet_local *lp = netdev_priv(dev);
   struct sk_buff *ackskb;
   struct archdr *ackpkt;
   int length=sizeof(struct arc_cap);
diff --git a/drivers/net/arcnet/com20020-isa.c b/drivers/net/arcnet/com20020-isa.c
index 9289e61..ea53a94 100644
--- a/drivers/net/arcnet/com20020-isa.c
+++ b/drivers/net/arcnet/com20020-isa.c
@@ -52,7 +52,7 @@ static int __init com20020isa_probe(struct net_device *dev)
 {
 	int ioaddr;
 	unsigned long airqmask;
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int err;
 
 	BUGLVL(D_NORMAL) printk(VERSION);
@@ -151,7 +151,7 @@ static int __init com20020_init(void)
 	if (node && node != 0xff)
 		dev->dev_addr[0] = node;
 
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	lp->backplane = backplane;
 	lp->clockp = clockp & 7;
 	lp->clockm = clockm & 3;
diff --git a/drivers/net/arcnet/com20020-pci.c b/drivers/net/arcnet/com20020-pci.c
index b8c0fa6..8b51f63 100644
--- a/drivers/net/arcnet/com20020-pci.c
+++ b/drivers/net/arcnet/com20020-pci.c
@@ -72,7 +72,7 @@ static int __devinit com20020pci_probe(struct pci_dev *pdev, const struct pci_de
 	dev = alloc_arcdev(device);
 	if (!dev)
 		return -ENOMEM;
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 
 	pci_set_drvdata(pdev, dev);
 
diff --git a/drivers/net/arcnet/com20020.c b/drivers/net/arcnet/com20020.c
index 70124a9..1036883 100644
--- a/drivers/net/arcnet/com20020.c
+++ b/drivers/net/arcnet/com20020.c
@@ -89,7 +89,7 @@ static void com20020_copy_to_card(struct net_device *dev, int bufnum,
 int com20020_check(struct net_device *dev)
 {
 	int ioaddr = dev->base_addr, status;
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 
 	ARCRESET0;
 	mdelay(RESETtime);
@@ -159,7 +159,7 @@ int com20020_found(struct net_device *dev, int shared)
 
 	/* Initialize the rest of the device structure. */
 
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 
 	lp->hw.owner = THIS_MODULE;
 	lp->hw.command = com20020_command;
@@ -233,7 +233,7 @@ int com20020_found(struct net_device *dev, int shared)
  */
 static int com20020_reset(struct net_device *dev, int really_reset)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	u_int ioaddr = dev->base_addr;
 	u_char inbyte;
 
@@ -300,7 +300,7 @@ static int com20020_status(struct net_device *dev)
 
 static void com20020_close(struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	/* disable transmitter */
@@ -317,7 +317,7 @@ static void com20020_close(struct net_device *dev)
  */
 static void com20020_set_mc_list(struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	if ((dev->flags & IFF_PROMISC) && (dev->flags & IFF_UP)) {	/* Enable promiscuous mode */
diff --git a/drivers/net/arcnet/com90io.c b/drivers/net/arcnet/com90io.c
index 6599f10..89de29b 100644
--- a/drivers/net/arcnet/com90io.c
+++ b/drivers/net/arcnet/com90io.c
@@ -248,7 +248,7 @@ static int __init com90io_found(struct net_device *dev)
 		return -EBUSY;
 	}
 
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	lp->card_name = "COM90xx I/O";
 	lp->hw.command = com90io_command;
 	lp->hw.status = com90io_status;
@@ -290,7 +290,7 @@ static int __init com90io_found(struct net_device *dev)
  */
 static int com90io_reset(struct net_device *dev, int really_reset)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	short ioaddr = dev->base_addr;
 
 	BUGMSG(D_INIT, "Resetting %s (status=%02Xh)\n", dev->name, ASTATUS());
diff --git a/drivers/net/arcnet/com90xx.c b/drivers/net/arcnet/com90xx.c
index 0d45553..f4113d2 100644
--- a/drivers/net/arcnet/com90xx.c
+++ b/drivers/net/arcnet/com90xx.c
@@ -468,7 +468,7 @@ static int __init com90xx_found(int ioaddr, int airq, u_long shmem, void __iomem
 		release_mem_region(shmem, MIRROR_SIZE);
 		return -ENOMEM;
 	}
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	/* find the real shared memory start/end points, including mirrors */
 
 	/* guess the actual size of one "memory mirror" - the number of
@@ -585,7 +585,7 @@ static void com90xx_setmask(struct net_device *dev, int mask)
  */
 int com90xx_reset(struct net_device *dev, int really_reset)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	short ioaddr = dev->base_addr;
 
 	BUGMSG(D_INIT, "Resetting (status=%02Xh)\n", ASTATUS());
@@ -621,7 +621,7 @@ int com90xx_reset(struct net_device *dev, int really_reset)
 static void com90xx_copy_to_card(struct net_device *dev, int bufnum, int offset,
 				 void *buf, int count)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *memaddr = lp->mem_start + bufnum * 512 + offset;
 	TIME("memcpy_toio", count, memcpy_toio(memaddr, buf, count));
 }
@@ -630,7 +630,7 @@ static void com90xx_copy_to_card(struct net_device *dev, int bufnum, int offset,
 static void com90xx_copy_from_card(struct net_device *dev, int bufnum, int offset,
 				   void *buf, int count)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	void __iomem *memaddr = lp->mem_start + bufnum * 512 + offset;
 	TIME("memcpy_fromio", count, memcpy_fromio(buf, memaddr, count));
 }
@@ -656,7 +656,7 @@ static void __exit com90xx_exit(void)
 
 	for (count = 0; count < numcards; count++) {
 		dev = cards[count];
-		lp = dev->priv;
+		lp = netdev_priv(dev);
 
 		unregister_netdev(dev);
 		free_irq(dev->irq, dev);
diff --git a/drivers/net/arcnet/rfc1051.c b/drivers/net/arcnet/rfc1051.c
index 994be49..49d39a9 100644
--- a/drivers/net/arcnet/rfc1051.c
+++ b/drivers/net/arcnet/rfc1051.c
@@ -88,7 +88,7 @@ MODULE_LICENSE("GPL");
  */
 static __be16 type_trans(struct sk_buff *skb, struct net_device *dev)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct archdr *pkt = (struct archdr *) skb->data;
 	struct arc_rfc1051 *soft = &pkt->soft.rfc1051;
 	int hdr_size = ARC_HDR_SIZE + RFC1051_HDR_SIZE;
@@ -125,7 +125,7 @@ static __be16 type_trans(struct sk_buff *skb, struct net_device *dev)
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct sk_buff *skb;
 	struct archdr *pkt = pkthdr;
 	int ofs;
@@ -168,7 +168,7 @@ static void rx(struct net_device *dev, int bufnum,
 static int build_header(struct sk_buff *skb, struct net_device *dev,
 			unsigned short type, uint8_t daddr)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int hdr_size = ARC_HDR_SIZE + RFC1051_HDR_SIZE;
 	struct archdr *pkt = (struct archdr *) skb_push(skb, hdr_size);
 	struct arc_rfc1051 *soft = &pkt->soft.rfc1051;
@@ -219,7 +219,7 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		      int bufnum)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct arc_hardware *hard = &pkt->hard;
 	int ofs;
 
diff --git a/drivers/net/arcnet/rfc1201.c b/drivers/net/arcnet/rfc1201.c
index 962641e..2303d3a 100644
--- a/drivers/net/arcnet/rfc1201.c
+++ b/drivers/net/arcnet/rfc1201.c
@@ -92,7 +92,7 @@ static __be16 type_trans(struct sk_buff *skb, struct net_device *dev)
 {
 	struct archdr *pkt = (struct archdr *) skb->data;
 	struct arc_rfc1201 *soft = &pkt->soft.rfc1201;
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int hdr_size = ARC_HDR_SIZE + RFC1201_HDR_SIZE;
 
 	/* Pull off the arcnet header. */
@@ -134,7 +134,7 @@ static __be16 type_trans(struct sk_buff *skb, struct net_device *dev)
 static void rx(struct net_device *dev, int bufnum,
 	       struct archdr *pkthdr, int length)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct sk_buff *skb;
 	struct archdr *pkt = pkthdr;
 	struct arc_rfc1201 *soft = &pkthdr->soft.rfc1201;
@@ -374,7 +374,7 @@ static void rx(struct net_device *dev, int bufnum,
 static int build_header(struct sk_buff *skb, struct net_device *dev,
 			unsigned short type, uint8_t daddr)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int hdr_size = ARC_HDR_SIZE + RFC1201_HDR_SIZE;
 	struct archdr *pkt = (struct archdr *) skb_push(skb, hdr_size);
 	struct arc_rfc1201 *soft = &pkt->soft.rfc1201;
@@ -441,7 +441,7 @@ static int build_header(struct sk_buff *skb, struct net_device *dev,
 static void load_pkt(struct net_device *dev, struct arc_hardware *hard,
 		     struct arc_rfc1201 *soft, int softlen, int bufnum)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	int ofs;
 
 	/* assume length <= XMTU: someone should have handled that by now. */
@@ -474,7 +474,7 @@ static void load_pkt(struct net_device *dev, struct arc_hardware *hard,
 static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 		      int bufnum)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	const int maxsegsize = XMTU - RFC1201_HDR_SIZE;
 	struct Outgoing *out;
 
@@ -509,7 +509,7 @@ static int prepare_tx(struct net_device *dev, struct archdr *pkt, int length,
 
 static int continue_tx(struct net_device *dev, int bufnum)
 {
-	struct arcnet_local *lp = dev->priv;
+	struct arcnet_local *lp = netdev_priv(dev);
 	struct Outgoing *out = &lp->outgoing;
 	struct arc_hardware *hard = &out->pkt->hard;
 	struct arc_rfc1201 *soft = &out->pkt->soft.rfc1201, *newsoft;
diff --git a/drivers/net/atarilance.c b/drivers/net/atarilance.c
index 701214b..2d81f6a 100644
--- a/drivers/net/atarilance.c
+++ b/drivers/net/atarilance.c
@@ -520,7 +520,7 @@ static unsigned long __init lance_probe1( struct net_device *dev,
 	return( 0 );
 
   probe_ok:
-	lp = (struct lance_private *)dev->priv;
+	lp = netdev_priv(dev);
 	MEM = (struct lance_memory *)memaddr;
 	IO = lp->iobase = (struct lance_ioreg *)ioaddr;
 	dev->base_addr = (unsigned long)ioaddr; /* informational only */
@@ -639,8 +639,8 @@ static unsigned long __init lance_probe1( struct net_device *dev,
 
 
 static int lance_open( struct net_device *dev )
-
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+{
+	struct lance_private *lp = netdev_priv(dev);
 	struct lance_ioreg	 *IO = lp->iobase;
 	int i;
 
@@ -680,8 +680,8 @@ static int lance_open( struct net_device *dev )
 /* Initialize the LANCE Rx and Tx rings. */
 
 static void lance_init_ring( struct net_device *dev )
-
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+{
+	struct lance_private *lp = netdev_priv(dev);
 	int i;
 	unsigned offset;
 
@@ -729,7 +729,7 @@ static void lance_init_ring( struct net_device *dev )
 
 static void lance_tx_timeout (struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	struct lance_ioreg	 *IO = lp->iobase;
 
 	AREG = CSR0;
@@ -771,8 +771,8 @@ static void lance_tx_timeout (struct net_device *dev)
 /* XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX */
 
 static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev )
-
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+{
+	struct lance_private *lp = netdev_priv(dev);
 	struct lance_ioreg	 *IO = lp->iobase;
 	int entry, len;
 	struct lance_tx_head *head;
@@ -860,7 +860,7 @@ static irqreturn_t lance_interrupt( int irq, void *dev_id )
 		return IRQ_NONE;
 	}
 
-	lp = (struct lance_private *)dev->priv;
+	lp = netdev_priv(dev);
 	IO = lp->iobase;
 	spin_lock (&lp->devlock);
 
@@ -960,8 +960,8 @@ static irqreturn_t lance_interrupt( int irq, void *dev_id )
 
 
 static int lance_rx( struct net_device *dev )
-
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+{
+	struct lance_private *lp = netdev_priv(dev);
 	int entry = lp->cur_rx & RX_RING_MOD_MASK;
 	int i;
 
@@ -1049,8 +1049,8 @@ static int lance_rx( struct net_device *dev )
 
 
 static int lance_close( struct net_device *dev )
-
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+{
+	struct lance_private *lp = netdev_priv(dev);
 	struct lance_ioreg	 *IO = lp->iobase;
 
 	netif_stop_queue (dev);
@@ -1076,8 +1076,8 @@ static int lance_close( struct net_device *dev )
  */
 
 static void set_multicast_list( struct net_device *dev )
-
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+{
+	struct lance_private *lp = netdev_priv(dev);
 	struct lance_ioreg	 *IO = lp->iobase;
 
 	if (netif_running(dev))
@@ -1118,8 +1118,8 @@ static void set_multicast_list( struct net_device *dev )
 /* This is needed for old RieblCards and possible for new RieblCards */
 
 static int lance_set_mac_address( struct net_device *dev, void *addr )
-
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+{
+	struct lance_private *lp = netdev_priv(dev);
 	struct sockaddr *saddr = addr;
 	int i;
 
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index 0f8c752..c8b7cea 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -2487,7 +2487,7 @@ static pci_ers_result_t
 atl1e_io_error_detected(struct pci_dev *pdev, pci_channel_state_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct atl1e_adapter *adapter = netdev->priv;
+	struct atl1e_adapter *adapter = netdev_priv(netdev);
 
 	netif_device_detach(netdev);
 
@@ -2510,7 +2510,7 @@ atl1e_io_error_detected(struct pci_dev *pdev, pci_channel_state_t state)
 static pci_ers_result_t atl1e_io_slot_reset(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct atl1e_adapter *adapter = netdev->priv;
+	struct atl1e_adapter *adapter = netdev_priv(netdev);
 
 	if (pci_enable_device(pdev)) {
 		dev_err(&pdev->dev,
@@ -2538,7 +2538,7 @@ static pci_ers_result_t atl1e_io_slot_reset(struct pci_dev *pdev)
 static void atl1e_io_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct atl1e_adapter *adapter = netdev->priv;
+	struct atl1e_adapter *adapter = netdev_priv(netdev);
 
 	if (netif_running(netdev)) {
 		if (atl1e_up(adapter)) {
diff --git a/drivers/net/atp.c b/drivers/net/atp.c
index 405c2dc..7028b27 100644
--- a/drivers/net/atp.c
+++ b/drivers/net/atp.c
@@ -912,7 +912,8 @@ static void __exit atp_cleanup_module(void) {
 	struct net_device *next_dev;
 
 	while (root_atp_dev) {
-		next_dev = ((struct net_local *)root_atp_dev->priv)->next_module;
+		struct net_local *atp_local = netdev_priv(root_atp_dev);
+		next_dev = atp_local->next_module;
 		unregister_netdev(root_atp_dev);
 		/* No need to release_region(), since we never snarf it. */
 		free_netdev(root_atp_dev);
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index 2b69b2b..ecc2573 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -193,7 +193,7 @@ struct au1000_private *au_macs[NUM_ETH_INTERFACES];
  */
 static int au1000_mdio_read(struct net_device *dev, int phy_addr, int reg)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 	volatile u32 *const mii_control_reg = &aup->mac->mii_control;
 	volatile u32 *const mii_data_reg = &aup->mac->mii_data;
 	u32 timedout = 20;
@@ -228,7 +228,7 @@ static int au1000_mdio_read(struct net_device *dev, int phy_addr, int reg)
 static void au1000_mdio_write(struct net_device *dev, int phy_addr,
 			      int reg, u16 value)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 	volatile u32 *const mii_control_reg = &aup->mac->mii_control;
 	volatile u32 *const mii_data_reg = &aup->mac->mii_data;
 	u32 timedout = 20;
@@ -283,7 +283,7 @@ static int au1000_mdiobus_reset(struct mii_bus *bus)
 
 static int mii_probe (struct net_device *dev)
 {
-	struct au1000_private *const aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 	struct phy_device *phydev = NULL;
 
 #if defined(AU1XXX_PHY_STATIC_CONFIG)
@@ -415,7 +415,7 @@ void ReleaseDB(struct au1000_private *aup, db_dest_t *pDB)
 
 static void enable_rx_tx(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 
 	if (au1000_debug > 4)
 		printk(KERN_INFO "%s: enable_rx_tx\n", dev->name);
@@ -426,7 +426,7 @@ static void enable_rx_tx(struct net_device *dev)
 
 static void hard_stop(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 
 	if (au1000_debug > 4)
 		printk(KERN_INFO "%s: hard stop\n", dev->name);
@@ -438,7 +438,7 @@ static void hard_stop(struct net_device *dev)
 static void enable_mac(struct net_device *dev, int force_reset)
 {
 	unsigned long flags;
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 
 	spin_lock_irqsave(&aup->lock, flags);
 
@@ -457,7 +457,7 @@ static void enable_mac(struct net_device *dev, int force_reset)
 
 static void reset_mac_unlocked(struct net_device *dev)
 {
-	struct au1000_private *const aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 	int i;
 
 	hard_stop(dev);
@@ -483,7 +483,7 @@ static void reset_mac_unlocked(struct net_device *dev)
 
 static void reset_mac(struct net_device *dev)
 {
-	struct au1000_private *const aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 	unsigned long flags;
 
 	if (au1000_debug > 4)
@@ -572,7 +572,7 @@ static int __init au1000_init_module(void)
 
 static int au1000_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct au1000_private *aup = (struct au1000_private *)dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 
 	if (aup->phy_dev)
 		return phy_ethtool_gset(aup->phy_dev, cmd);
@@ -582,7 +582,7 @@ static int au1000_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 static int au1000_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct au1000_private *aup = (struct au1000_private *)dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -596,7 +596,7 @@ static int au1000_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 static void
 au1000_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct au1000_private *aup = (struct au1000_private *)dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 
 	strcpy(info->driver, DRV_NAME);
 	strcpy(info->version, DRV_VERSION);
@@ -652,7 +652,7 @@ static struct net_device * au1000_probe(int port_num)
 	printk("%s: Au1xx0 Ethernet found at 0x%x, irq %d\n",
 		dev->name, base, irq);
 
-	aup = dev->priv;
+	aup = netdev_priv(dev);
 
 	spin_lock_init(&aup->lock);
 
@@ -817,7 +817,7 @@ err_out:
  */
 static int au1000_init(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 	unsigned long flags;
 	int i;
 	u32 control;
@@ -868,7 +868,7 @@ static int au1000_init(struct net_device *dev)
 static void
 au1000_adjust_link(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 	struct phy_device *phydev = aup->phy_dev;
 	unsigned long flags;
 
@@ -947,7 +947,7 @@ au1000_adjust_link(struct net_device *dev)
 static int au1000_open(struct net_device *dev)
 {
 	int retval;
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 
 	if (au1000_debug > 4)
 		printk("%s: open: dev=%p\n", dev->name, dev);
@@ -982,7 +982,7 @@ static int au1000_open(struct net_device *dev)
 static int au1000_close(struct net_device *dev)
 {
 	unsigned long flags;
-	struct au1000_private *const aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 
 	if (au1000_debug > 4)
 		printk("%s: close: dev=%p\n", dev->name, dev);
@@ -1013,7 +1013,7 @@ static void __exit au1000_cleanup_module(void)
 	for (i = 0; i < num_ifs; i++) {
 		dev = iflist[i].dev;
 		if (dev) {
-			aup = (struct au1000_private *) dev->priv;
+			aup = netdev_priv(dev);
 			unregister_netdev(dev);
 			mdiobus_unregister(aup->mii_bus);
 			mdiobus_free(aup->mii_bus);
@@ -1035,7 +1035,7 @@ static void __exit au1000_cleanup_module(void)
 
 static void update_tx_stats(struct net_device *dev, u32 status)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 	struct net_device_stats *ps = &dev->stats;
 
 	if (status & TX_FRAME_ABORTED) {
@@ -1064,7 +1064,7 @@ static void update_tx_stats(struct net_device *dev, u32 status)
  */
 static void au1000_tx_ack(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 	volatile tx_dma_t *ptxd;
 
 	ptxd = aup->tx_dma_ring[aup->tx_tail];
@@ -1091,7 +1091,7 @@ static void au1000_tx_ack(struct net_device *dev)
  */
 static int au1000_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 	struct net_device_stats *ps = &dev->stats;
 	volatile tx_dma_t *ptxd;
 	u32 buff_stat;
@@ -1145,7 +1145,7 @@ static int au1000_tx(struct sk_buff *skb, struct net_device *dev)
 
 static inline void update_rx_stats(struct net_device *dev, u32 status)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 	struct net_device_stats *ps = &dev->stats;
 
 	ps->rx_packets++;
@@ -1173,7 +1173,7 @@ static inline void update_rx_stats(struct net_device *dev, u32 status)
  */
 static int au1000_rx(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 	struct sk_buff *skb;
 	volatile rx_dma_t *prxd;
 	u32 buff_stat, status;
@@ -1275,7 +1275,7 @@ static void au1000_tx_timeout(struct net_device *dev)
 
 static void set_rx_mode(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 
 	if (au1000_debug > 4)
 		printk("%s: set_rx_mode: flags=%x\n", dev->name, dev->flags);
@@ -1307,7 +1307,7 @@ static void set_rx_mode(struct net_device *dev)
 
 static int au1000_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct au1000_private *aup = (struct au1000_private *)dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 
 	if (!netif_running(dev)) return -EINVAL;
 
diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index ba1372f..78f645d 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2426,7 +2426,7 @@ int bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info)
 int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 {
 	struct slave *slave, *start_at;
-	struct bonding *bond = dev->priv;
+	struct bonding *bond = netdev_priv(dev);
 	int slave_agg_no;
 	int slaves_in_agg;
 	int agg_id;
@@ -2506,7 +2506,7 @@ out:
 
 int bond_3ad_lacpdu_recv(struct sk_buff *skb, struct net_device *dev, struct packet_type* ptype, struct net_device *orig_dev)
 {
-	struct bonding *bond = dev->priv;
+	struct bonding *bond = netdev_priv(dev);
 	struct slave *slave = NULL;
 	int ret = NET_RX_DROP;
 
@@ -2517,7 +2517,8 @@ int bond_3ad_lacpdu_recv(struct sk_buff *skb, struct net_device *dev, struct pac
 		goto out;
 
 	read_lock(&bond->lock);
-	slave = bond_get_slave_by_dev((struct bonding *)dev->priv, orig_dev);
+	slave = bond_get_slave_by_dev((struct bonding *)netdev_priv(dev),
+					orig_dev);
 	if (!slave)
 		goto out_unlock;
 
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index e170fa2..073d25f 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -374,7 +374,7 @@ static int rlb_arp_recv(struct sk_buff *skb, struct net_device *bond_dev, struct
 		/* update rx hash table for this ARP */
 		printk("rar: update orig %s bond_dev %s\n", orig_dev->name,
 		       bond_dev->name);
-		bond = bond_dev->priv;
+		bond = netdev_priv(bond_dev);
 		rlb_update_entry_from_arp(bond, arp);
 		dprintk("Server received an ARP Reply from client\n");
 	}
@@ -1292,7 +1292,7 @@ void bond_alb_deinitialize(struct bonding *bond)
 
 int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct ethhdr *eth_data;
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
 	struct slave *tx_slave = NULL;
@@ -1713,7 +1713,7 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
  */
 int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct sockaddr *sa = addr;
 	struct slave *slave, *swap_slave;
 	int res;
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 02de3e0..a08ea48 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -454,7 +454,7 @@ int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_de
  */
 static void bond_vlan_rx_register(struct net_device *bond_dev, struct vlan_group *grp)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave;
 	int i;
 
@@ -477,7 +477,7 @@ static void bond_vlan_rx_register(struct net_device *bond_dev, struct vlan_group
  */
 static void bond_vlan_rx_add_vid(struct net_device *bond_dev, uint16_t vid)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave;
 	int i, res;
 
@@ -505,7 +505,7 @@ static void bond_vlan_rx_add_vid(struct net_device *bond_dev, uint16_t vid)
  */
 static void bond_vlan_rx_kill_vid(struct net_device *bond_dev, uint16_t vid)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave;
 	struct net_device *vlan_dev;
 	int i, res;
@@ -939,7 +939,7 @@ static int bond_mc_list_copy(struct dev_mc_list *mc_list, struct bonding *bond,
  */
 static void bond_mc_list_flush(struct net_device *bond_dev, struct net_device *slave_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct dev_mc_list *dmi;
 
 	for (dmi = bond_dev->mc_list; dmi; dmi = dmi->next) {
@@ -1383,7 +1383,7 @@ done:
 static void bond_setup_by_slave(struct net_device *bond_dev,
 				struct net_device *slave_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 
 	bond_dev->neigh_setup           = slave_dev->neigh_setup;
 	bond_dev->header_ops		= slave_dev->header_ops;
@@ -1400,7 +1400,7 @@ static void bond_setup_by_slave(struct net_device *bond_dev,
 /* enslave device <slave> to bond device <master> */
 int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *new_slave = NULL;
 	struct dev_mc_list *dmi;
 	struct sockaddr addr;
@@ -1802,7 +1802,7 @@ err_undo_flags:
  */
 int bond_release(struct net_device *bond_dev, struct net_device *slave_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave, *oldcurrent;
 	struct sockaddr addr;
 	int mac_addr_differ;
@@ -2013,7 +2013,7 @@ static void bond_destructor(struct net_device *bond_dev)
 */
 int  bond_release_and_destroy(struct net_device *bond_dev, struct net_device *slave_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	int ret;
 
 	ret = bond_release(bond_dev, slave_dev);
@@ -2030,7 +2030,7 @@ int  bond_release_and_destroy(struct net_device *bond_dev, struct net_device *sl
  */
 static int bond_release_all(struct net_device *bond_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave;
 	struct net_device *slave_dev;
 	struct sockaddr addr;
@@ -2161,7 +2161,7 @@ out:
  */
 static int bond_ioctl_change_active(struct net_device *bond_dev, struct net_device *slave_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *old_active = NULL;
 	struct slave *new_active = NULL;
 	int res = 0;
@@ -2210,7 +2210,7 @@ static int bond_ioctl_change_active(struct net_device *bond_dev, struct net_devi
 
 static int bond_info_query(struct net_device *bond_dev, struct ifbond *info)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 
 	info->bond_mode = bond->params.mode;
 	info->miimon = bond->params.miimon;
@@ -2224,7 +2224,7 @@ static int bond_info_query(struct net_device *bond_dev, struct ifbond *info)
 
 static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *info)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave;
 	int i, found = 0;
 
@@ -2717,7 +2717,7 @@ static int bond_arp_rcv(struct sk_buff *skb, struct net_device *dev, struct pack
 	if (!(dev->priv_flags & IFF_BONDING) || !(dev->flags & IFF_MASTER))
 		goto out;
 
-	bond = dev->priv;
+	bond = netdev_priv(dev);
 	read_lock(&bond->lock);
 
 	dprintk("bond_arp_rcv: bond %s skb->dev %s orig_dev %s\n",
@@ -3526,7 +3526,7 @@ static int bond_event_changename(struct bonding *bond)
 
 static int bond_master_netdev_event(unsigned long event, struct net_device *bond_dev)
 {
-	struct bonding *event_bond = bond_dev->priv;
+	struct bonding *event_bond = netdev_priv(bond_dev);
 
 	switch (event) {
 	case NETDEV_CHANGENAME:
@@ -3544,7 +3544,7 @@ static int bond_master_netdev_event(unsigned long event, struct net_device *bond
 static int bond_slave_netdev_event(unsigned long event, struct net_device *slave_dev)
 {
 	struct net_device *bond_dev = slave_dev->master;
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 
 	switch (event) {
 	case NETDEV_UNREGISTER:
@@ -3795,7 +3795,7 @@ static int bond_xmit_hash_policy_l2(struct sk_buff *skb,
 
 static int bond_open(struct net_device *bond_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 
 	bond->kill_timers = 0;
 
@@ -3844,7 +3844,7 @@ static int bond_open(struct net_device *bond_dev)
 
 static int bond_close(struct net_device *bond_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		/* Unregister the receive of LACPDUs */
@@ -3898,7 +3898,7 @@ static int bond_close(struct net_device *bond_dev)
 
 static struct net_device_stats *bond_get_stats(struct net_device *bond_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct net_device_stats *stats = &(bond->stats), *sstats;
 	struct net_device_stats local_stats;
 	struct slave *slave;
@@ -3976,7 +3976,7 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 		}
 
 		if (mii->reg_num == 1) {
-			struct bonding *bond = bond_dev->priv;
+			struct bonding *bond = netdev_priv(bond_dev);
 			mii->val_out = 0;
 			read_lock(&bond->lock);
 			read_lock(&bond->curr_slave_lock);
@@ -4068,7 +4068,7 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 
 static void bond_set_multicast_list(struct net_device *bond_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct dev_mc_list *dmi;
 
 	/*
@@ -4129,7 +4129,7 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
  */
 static int bond_change_mtu(struct net_device *bond_dev, int new_mtu)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave, *stop_at;
 	int res = 0;
 	int i;
@@ -4201,7 +4201,7 @@ unwind:
  */
 static int bond_set_mac_address(struct net_device *bond_dev, void *addr)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct sockaddr *sa = addr, tmp_sa;
 	struct slave *slave, *stop_at;
 	int res = 0;
@@ -4282,7 +4282,7 @@ unwind:
 
 static int bond_xmit_roundrobin(struct sk_buff *skb, struct net_device *bond_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave, *start_at;
 	int i, slave_no, res = 1;
 
@@ -4331,7 +4331,7 @@ out:
  */
 static int bond_xmit_activebackup(struct sk_buff *skb, struct net_device *bond_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	int res = 1;
 
 	read_lock(&bond->lock);
@@ -4363,7 +4363,7 @@ out:
  */
 static int bond_xmit_xor(struct sk_buff *skb, struct net_device *bond_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave, *start_at;
 	int slave_no;
 	int i;
@@ -4409,7 +4409,7 @@ out:
  */
 static int bond_xmit_broadcast(struct sk_buff *skb, struct net_device *bond_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave, *start_at;
 	struct net_device *tx_dev = NULL;
 	int i;
@@ -4552,7 +4552,7 @@ static const struct ethtool_ops bond_ethtool_ops = {
  */
 static int bond_init(struct net_device *bond_dev, struct bond_params *params)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 
 	dprintk("Begin bond_init for %s\n", bond_dev->name);
 
@@ -4657,7 +4657,7 @@ static void bond_work_cancel_all(struct bonding *bond)
  */
 static void bond_deinit(struct net_device *bond_dev)
 {
-	struct bonding *bond = bond_dev->priv;
+	struct bonding *bond = netdev_priv(bond_dev);
 
 	list_del(&bond->bond_list);
 
@@ -5149,7 +5149,7 @@ int bond_create(char *name, struct bond_params *params)
 
 	up_write(&bonding_rwsem);
 	rtnl_unlock(); /* allows sysfs registration of net device */
-	res = bond_create_sysfs_entry(bond_dev->priv);
+	res = bond_create_sysfs_entry(netdev_priv(bond_dev));
 	if (res < 0) {
 		rtnl_lock();
 		down_write(&bonding_rwsem);
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index aaf2927..fc490d8 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -39,7 +39,7 @@
 /* #define BONDING_DEBUG 1 */
 #include "bonding.h"
 #define to_dev(obj)	container_of(obj,struct device,kobj)
-#define to_bond(cd)	((struct bonding *)(to_net_dev(cd)->priv))
+#define to_bond(cd)	((struct bonding *)(netdev_priv(to_net_dev(cd))))
 
 /*---------------------------- Declarations -------------------------------*/
 
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index b5eb8e6..921abac 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -257,7 +257,7 @@ static inline struct bonding *bond_get_bond_by_slave(struct slave *slave)
 		return NULL;
 	}
 
-	return (struct bonding *)slave->dev->master->priv;
+	return (struct bonding *)netdev_priv(slave->dev->master);
 }
 
 #define BOND_FOM_NONE			0
@@ -287,7 +287,7 @@ static inline unsigned long slave_last_rx(struct bonding *bond,
 
 static inline void bond_set_slave_inactive_flags(struct slave *slave)
 {
-	struct bonding *bond = slave->dev->master->priv;
+	struct bonding *bond = netdev_priv(slave->dev->master);
 	if (bond->params.mode != BOND_MODE_TLB &&
 	    bond->params.mode != BOND_MODE_ALB)
 		slave->state = BOND_STATE_BACKUP;
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
diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index fee56a3..a610016 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -94,9 +94,9 @@ static struct ixgbe_stats ixgbe_gstrings_stats[] = {
 };
 
 #define IXGBE_QUEUE_STATS_LEN \
-                ((((struct ixgbe_adapter *)netdev->priv)->num_tx_queues + \
-                 ((struct ixgbe_adapter *)netdev->priv)->num_rx_queues) * \
-                 (sizeof(struct ixgbe_queue_stats) / sizeof(u64)))
+	((((struct ixgbe_adapter *)netdev_priv(netdev))->num_tx_queues + \
+	((struct ixgbe_adapter *)netdev_priv(netdev))->num_rx_queues) * \
+	(sizeof(struct ixgbe_queue_stats) / sizeof(u64)))
 #define IXGBE_STATS_LEN (IXGBE_GLOBAL_STATS_LEN + IXGBE_QUEUE_STATS_LEN)
 #define IXGBE_GLOBAL_STATS_LEN ARRAY_SIZE(ixgbe_gstrings_stats)
 #define IXGBE_STATS_LEN (IXGBE_GLOBAL_STATS_LEN + IXGBE_QUEUE_STATS_LEN)
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index b3be579..ae06d48 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -4041,7 +4041,7 @@ static pci_ers_result_t ixgbe_io_error_detected(struct pci_dev *pdev,
                                                 pci_channel_state_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct ixgbe_adapter *adapter = netdev->priv;
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
 	netif_device_detach(netdev);
 
@@ -4062,7 +4062,7 @@ static pci_ers_result_t ixgbe_io_error_detected(struct pci_dev *pdev,
 static pci_ers_result_t ixgbe_io_slot_reset(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct ixgbe_adapter *adapter = netdev->priv;
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
 	if (pci_enable_device(pdev)) {
 		DPRINTK(PROBE, ERR,
@@ -4090,7 +4090,7 @@ static pci_ers_result_t ixgbe_io_slot_reset(struct pci_dev *pdev)
 static void ixgbe_io_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct ixgbe_adapter *adapter = netdev->priv;
+	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
 	if (netif_running(netdev)) {
 		if (ixgbe_up(adapter)) {
diff --git a/drivers/net/lp486e.c b/drivers/net/lp486e.c
index d6b0036..4d1a059 100644
--- a/drivers/net/lp486e.c
+++ b/drivers/net/lp486e.c
@@ -390,7 +390,7 @@ i596_timeout(struct net_device *dev, char *msg, int ct) {
 	struct i596_private *lp;
 	int boguscnt = ct;
 
-	lp = (struct i596_private *) dev->priv;
+	lp = netdev_priv(dev);
 	while (lp->scb.command) {
 		if (--boguscnt == 0) {
 			printk("%s: %s timed out - stat %4.4x, cmd %4.4x\n",
@@ -411,7 +411,7 @@ init_rx_bufs(struct net_device *dev, int num) {
 	int i;
 	// struct i596_rbd *rbd;
 
-	lp = (struct i596_private *) dev->priv;
+	lp = netdev_priv(dev);
 	lp->scb.pa_rfd = I596_NULL;
 
 	for (i = 0; i < num; i++) {
@@ -468,7 +468,7 @@ remove_rx_bufs(struct net_device *dev) {
 	struct i596_private *lp;
 	struct i596_rfd *rfd;
 
-	lp = (struct i596_private *) dev->priv;
+	lp = netdev_priv(dev);
 	lp->rx_tail->pa_next = I596_NULL;
 
 	do {
@@ -517,7 +517,7 @@ CLEAR_INT(void) {
 /* selftest or dump */
 static void
 i596_port_do(struct net_device *dev, int portcmd, char *cmdname) {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	u16 *outp;
 	int i, m;
 
@@ -541,7 +541,7 @@ i596_port_do(struct net_device *dev, int portcmd, char *cmdname) {
 
 static int
 i596_scp_setup(struct net_device *dev) {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	int boguscnt;
 
 	/* Setup SCP, ISCP, SCB */
@@ -622,7 +622,7 @@ init_i596(struct net_device *dev) {
 	if (i596_scp_setup(dev))
 		return 1;
 
-	lp = (struct i596_private *) dev->priv;
+	lp = netdev_priv(dev);
 	lp->scb.command = 0;
 
 	memcpy ((void *)lp->i596_config, init_setup, 14);
@@ -704,7 +704,7 @@ i596_rx_one(struct net_device *dev, struct i596_private *lp,
 
 static int
 i596_rx(struct net_device *dev) {
-	struct i596_private *lp = (struct i596_private *) dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	struct i596_rfd *rfd;
 	int frames = 0;
 
@@ -737,7 +737,7 @@ i596_cleanup_cmd(struct net_device *dev) {
 	struct i596_private *lp;
 	struct i596_cmd *cmd;
 
-	lp = (struct i596_private *) dev->priv;
+	lp = netdev_priv(dev);
 	while (lp->cmd_head) {
 		cmd = (struct i596_cmd *)lp->cmd_head;
 
@@ -805,7 +805,7 @@ static void i596_reset(struct net_device *dev, struct i596_private *lp, int ioad
 }
 
 static void i596_add_cmd(struct net_device *dev, struct i596_cmd *cmd) {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	unsigned long flags;
 
@@ -911,7 +911,7 @@ static int i596_start_xmit (struct sk_buff *skb, struct net_device *dev) {
 
 static void
 i596_tx_timeout (struct net_device *dev) {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	/* Transmitter timeout, serious problems. */
@@ -969,7 +969,7 @@ static int __init lp486e_probe(struct net_device *dev) {
 		return -EBUSY;
 	}
 
-	lp = (struct i596_private *) dev->priv;
+	lp = netdev_priv(dev);
 	spin_lock_init(&lp->cmd_lock);
 
 	/*
@@ -1146,7 +1146,7 @@ static irqreturn_t
 i596_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev = dev_instance;
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	unsigned short status, ack_cmd = 0;
 	int frames_in = 0;
 
@@ -1214,7 +1214,7 @@ i596_interrupt(int irq, void *dev_instance)
 }
 
 static int i596_close(struct net_device *dev) {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 
 	netif_stop_queue(dev);
 
@@ -1241,7 +1241,7 @@ static int i596_close(struct net_device *dev) {
 */
 
 static void set_multicast_list(struct net_device *dev) {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	struct i596_cmd *cmd;
 
 	if (i596_debug > 1)
diff --git a/drivers/net/mace.c b/drivers/net/mace.c
index b52f050..feebbd9 100644
--- a/drivers/net/mace.c
+++ b/drivers/net/mace.c
@@ -143,7 +143,7 @@ static int __devinit mace_probe(struct macio_dev *mdev, const struct of_device_i
 	}
 	SET_NETDEV_DEV(dev, &mdev->ofdev.dev);
 
-	mp = dev->priv;
+	mp = netdev_priv(dev);
 	mp->mdev = mdev;
 	macio_set_drvdata(mdev, dev);
 
@@ -164,7 +164,7 @@ static int __devinit mace_probe(struct macio_dev *mdev, const struct of_device_i
 			in_8(&mp->mace->chipid_lo);
 
 
-	mp = (struct mace_data *) dev->priv;
+	mp = netdev_priv(dev);
 	mp->maccc = ENXMT | ENRCV;
 
 	mp->tx_dma = ioremap(macio_resource_start(mdev, 1), 0x1000);
@@ -275,7 +275,7 @@ static int __devexit mace_remove(struct macio_dev *mdev)
 
 	macio_set_drvdata(mdev, NULL);
 
-	mp = dev->priv;
+	mp = netdev_priv(dev);
 
 	unregister_netdev(dev);
 
@@ -311,7 +311,7 @@ static void dbdma_reset(volatile struct dbdma_regs __iomem *dma)
 
 static void mace_reset(struct net_device *dev)
 {
-    struct mace_data *mp = (struct mace_data *) dev->priv;
+    struct mace_data *mp = netdev_priv(dev);
     volatile struct mace __iomem *mb = mp->mace;
     int i;
 
@@ -366,7 +366,7 @@ static void mace_reset(struct net_device *dev)
 
 static void __mace_set_address(struct net_device *dev, void *addr)
 {
-    struct mace_data *mp = (struct mace_data *) dev->priv;
+    struct mace_data *mp = netdev_priv(dev);
     volatile struct mace __iomem *mb = mp->mace;
     unsigned char *p = addr;
     int i;
@@ -387,7 +387,7 @@ static void __mace_set_address(struct net_device *dev, void *addr)
 
 static int mace_set_address(struct net_device *dev, void *addr)
 {
-    struct mace_data *mp = (struct mace_data *) dev->priv;
+    struct mace_data *mp = netdev_priv(dev);
     volatile struct mace __iomem *mb = mp->mace;
     unsigned long flags;
 
@@ -422,7 +422,7 @@ static inline void mace_clean_rings(struct mace_data *mp)
 
 static int mace_open(struct net_device *dev)
 {
-    struct mace_data *mp = (struct mace_data *) dev->priv;
+    struct mace_data *mp = netdev_priv(dev);
     volatile struct mace __iomem *mb = mp->mace;
     volatile struct dbdma_regs __iomem *rd = mp->rx_dma;
     volatile struct dbdma_regs __iomem *td = mp->tx_dma;
@@ -492,7 +492,7 @@ static int mace_open(struct net_device *dev)
 
 static int mace_close(struct net_device *dev)
 {
-    struct mace_data *mp = (struct mace_data *) dev->priv;
+    struct mace_data *mp = netdev_priv(dev);
     volatile struct mace __iomem *mb = mp->mace;
     volatile struct dbdma_regs __iomem *rd = mp->rx_dma;
     volatile struct dbdma_regs __iomem *td = mp->tx_dma;
@@ -512,7 +512,7 @@ static int mace_close(struct net_device *dev)
 
 static inline void mace_set_timeout(struct net_device *dev)
 {
-    struct mace_data *mp = (struct mace_data *) dev->priv;
+    struct mace_data *mp = netdev_priv(dev);
 
     if (mp->timeout_active)
 	del_timer(&mp->tx_timeout);
@@ -525,7 +525,7 @@ static inline void mace_set_timeout(struct net_device *dev)
 
 static int mace_xmit_start(struct sk_buff *skb, struct net_device *dev)
 {
-    struct mace_data *mp = (struct mace_data *) dev->priv;
+    struct mace_data *mp = netdev_priv(dev);
     volatile struct dbdma_regs __iomem *td = mp->tx_dma;
     volatile struct dbdma_cmd *cp, *np;
     unsigned long flags;
@@ -580,7 +580,7 @@ static int mace_xmit_start(struct sk_buff *skb, struct net_device *dev)
 
 static void mace_set_multicast(struct net_device *dev)
 {
-    struct mace_data *mp = (struct mace_data *) dev->priv;
+    struct mace_data *mp = netdev_priv(dev);
     volatile struct mace __iomem *mb = mp->mace;
     int i, j;
     u32 crc;
@@ -655,7 +655,7 @@ static void mace_handle_misc_intrs(struct mace_data *mp, int intr, struct net_de
 static irqreturn_t mace_interrupt(int irq, void *dev_id)
 {
     struct net_device *dev = (struct net_device *) dev_id;
-    struct mace_data *mp = (struct mace_data *) dev->priv;
+    struct mace_data *mp = netdev_priv(dev);
     volatile struct mace __iomem *mb = mp->mace;
     volatile struct dbdma_regs __iomem *td = mp->tx_dma;
     volatile struct dbdma_cmd *cp;
@@ -801,7 +801,7 @@ static irqreturn_t mace_interrupt(int irq, void *dev_id)
 static void mace_tx_timeout(unsigned long data)
 {
     struct net_device *dev = (struct net_device *) data;
-    struct mace_data *mp = (struct mace_data *) dev->priv;
+    struct mace_data *mp = netdev_priv(dev);
     volatile struct mace __iomem *mb = mp->mace;
     volatile struct dbdma_regs __iomem *td = mp->tx_dma;
     volatile struct dbdma_regs __iomem *rd = mp->rx_dma;
@@ -872,7 +872,7 @@ static irqreturn_t mace_txdma_intr(int irq, void *dev_id)
 static irqreturn_t mace_rxdma_intr(int irq, void *dev_id)
 {
     struct net_device *dev = (struct net_device *) dev_id;
-    struct mace_data *mp = (struct mace_data *) dev->priv;
+    struct mace_data *mp = netdev_priv(dev);
     volatile struct dbdma_regs __iomem *rd = mp->rx_dma;
     volatile struct dbdma_cmd *cp, *np;
     int i, nb, stat, next;
-- 
1.5.3.4



