From: Yoann Padioleau <padator@wanadoo.fr>
Subject: [PATCH 01/13] dev->priv to netdev_priv(dev), for drivers/net
Date: Fri, 3 Aug 2007 19:33:12 +0200 (MEST)
Message-ID: <200708031733.TAA00724@ifs.emn.fr>
Cc: jeff@garzik.org, netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763498AbXHCRfa@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Replacing accesses to dev->priv to netdev_priv(dev). The replacment
is safe when netdev_priv is used to access a private structure that is
right next to the net_device structure in memory. Cf
http://groups.google.com/group/comp.os.linux.development.system/browse_thread/thread/de19321bcd94dbb8/0d74a4adcd6177bd
This is the case when the net_device structure was allocated with
a call to alloc_netdev or one of its derivative.

Here is an excerpt of the semantic patch that performs the transformation

@ rule1 @
type T;
struct net_device *dev;
@@

 dev = 
(
        alloc_netdev
|         
        alloc_etherdev
|
        alloc_trdev
)
   (sizeof(T), ...)

@ rule1bis @
struct net_device *dev;
expression E;
@@
 dev->priv = E

@ rule2 depends on rule1 && !rule1bis  @
struct net_device *dev;
type rule1.T;
@@

- (T*) dev->priv
+ netdev_priv(dev)

Signed-off-by: Yoann Padioleau <padator@wanadoo.fr>
Cc: jeff@garzik.org
Cc: netdev@vger.kernel.org
Cc: akpm@linux-foundation.org
---

 drivers/net/3c501.c        |    2 -
 drivers/net/3c505.c        |   36 +++++++++---------
 drivers/net/3c523.c        |   28 +++++++-------
 drivers/net/3c59x.c        |    4 +-
 drivers/net/acenic.c       |    2 -
 drivers/net/atarilance.c   |   22 +++++------
 drivers/net/atp.c          |    2 -
 drivers/net/au1000_eth.c   |   50 +++++++++++++-------------
 drivers/net/de600.c        |    8 ++--
 drivers/net/de620.c        |   14 +++----
 drivers/net/declance.c     |    2 -
 drivers/net/depca.c        |   42 ++++++++++-----------
 drivers/net/dgrs.c         |   32 ++++++++--------
 drivers/net/dm9000.c       |   32 ++++++++--------
 drivers/net/eepro.c        |    4 +-
 drivers/net/epic100.c      |   44 +++++++++++------------
 drivers/net/eth16i.c       |    2 -
 drivers/net/fec.c          |    2 -
 drivers/net/ibmveth.c      |   24 ++++++------
 drivers/net/iseries_veth.c |   20 +++++-----
 drivers/net/lp486e.c       |   30 +++++++--------
 drivers/net/mv643xx_eth.c  |    2 -
 drivers/net/mvme147.c      |    4 +-
 drivers/net/myri_sbus.c    |   14 +++----
 drivers/net/ne2k-pci.c     |    2 -
 drivers/net/ni5010.c       |    2 -
 drivers/net/ni52.c         |   32 ++++++++--------
 drivers/net/pci-skeleton.c |   38 +++++++++----------
 drivers/net/plip.c         |    8 ++--
 drivers/net/qla3xxx.c      |    2 -
 drivers/net/rionet.c       |   28 +++++++-------
 drivers/net/s2io.c         |   74 +++++++++++++++++++-------------------
 drivers/net/sgiseeq.c      |    2 -
 drivers/net/shaper.c       |   16 ++++----
 drivers/net/sis900.c       |   66 +++++++++++++++++-----------------
 drivers/net/smc9194.c      |    6 +--
 drivers/net/sonic.h        |   20 +++++-----
 drivers/net/sun3_82586.c   |   32 ++++++++--------
 drivers/net/sunbmac.c      |   18 ++++-----
 drivers/net/sungem.c       |   54 ++++++++++++++--------------
 drivers/net/sunhme.c       |   26 ++++++-------
 drivers/net/sunqe.c        |   16 ++++----
 drivers/net/tc35815.c      |   86 ++++++++++++++++++++++-----------------------
 drivers/net/typhoon.c      |    2 -
 drivers/net/znet.c         |   24 ++++++------
 45 files changed, 488 insertions(+), 488 deletions(-)

diff --git a/drivers/net/3c501.c b/drivers/net/3c501.c
index 4bee99b..2461688 100644
--- a/drivers/net/3c501.c
+++ b/drivers/net/3c501.c
@@ -304,7 +304,7 @@ #endif
 	if (el_debug)
 		printk(KERN_DEBUG "%s", version);
 
-	memset(dev->priv, 0, sizeof(struct net_local));
+	memset(netdev_priv(dev), 0, sizeof(struct net_local));
 	lp = netdev_priv(dev);
 	spin_lock_init(&lp->lock);
 
diff --git a/drivers/net/3c505.c b/drivers/net/3c505.c
index e985a85..4cf3dde 100644
--- a/drivers/net/3c505.c
+++ b/drivers/net/3c505.c
@@ -218,7 +218,7 @@ static inline int inb_command(unsigned i
 static inline void outb_control(unsigned char val, struct net_device *dev)
 {
 	outb(val, dev->base_addr + PORT_CONTROL);
-	((elp_device *)(dev->priv))->hcr_val = val;
+	((elp_device *)(netdev_priv(dev)))->hcr_val = val;
 }
 
 #define HCR_VAL(x)   (((elp_device *)((x)->priv))->hcr_val)
@@ -262,7 +262,7 @@ static inline int get_status(unsigned in
 
 static inline void set_hsf(struct net_device *dev, int hsf)
 {
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	unsigned long flags;
 
 	spin_lock_irqsave(&adapter->lock, flags);
@@ -275,7 +275,7 @@ static int start_receive(struct net_devi
 static inline void adapter_reset(struct net_device *dev)
 {
 	unsigned long timeout;
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	unsigned char orig_hcr = adapter->hcr_val;
 
 	outb_control(0, dev);
@@ -308,7 +308,7 @@ static inline void adapter_reset(struct 
  */
 static inline void check_3c505_dma(struct net_device *dev)
 {
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	if (adapter->dmaing && time_after(jiffies, adapter->current_dma.start_time + 10)) {
 		unsigned long flags, f;
 		printk(KERN_ERR "%s: DMA %s timed out, %d bytes left\n", dev->name, adapter->current_dma.direction ? "download" : "upload", get_dma_residue(dev->dma));
@@ -355,7 +355,7 @@ static inline unsigned int send_pcb_fast
 /* Check to see if the receiver needs restarting, and kick it if so */
 static inline void prime_rx(struct net_device *dev)
 {
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	while (adapter->rx_active < ELP_RX_PCBS && netif_running(dev)) {
 		if (!start_receive(dev, &adapter->itx_pcb))
 			break;
@@ -390,7 +390,7 @@ static int send_pcb(struct net_device *d
 {
 	int i;
 	unsigned long timeout;
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	unsigned long flags;
 
 	check_3c505_dma(dev);
@@ -478,7 +478,7 @@ static int receive_pcb(struct net_device
 	unsigned long timeout;
 	unsigned long flags;
 
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 
 	set_hsf(dev, 0);
 
@@ -558,7 +558,7 @@ static int receive_pcb(struct net_device
 static int start_receive(struct net_device *dev, pcb_struct * tx_pcb)
 {
 	int status;
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 
 	if (elp_debug >= 3)
 		printk(KERN_DEBUG "%s: restarting receiver\n", dev->name);
@@ -586,7 +586,7 @@ static int start_receive(struct net_devi
 static void receive_packet(struct net_device *dev, int len)
 {
 	int rlen;
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	void *target;
 	struct sk_buff *skb;
 	unsigned long flags;
@@ -658,7 +658,7 @@ static irqreturn_t elp_interrupt(int irq
 	unsigned long timeout;
 
 	dev = dev_id;
-	adapter = (elp_device *) dev->priv;
+	adapter = netdev_priv(dev);
 
 	spin_lock(&adapter->lock);
 
@@ -856,7 +856,7 @@ static int elp_open(struct net_device *d
 	elp_device *adapter;
 	int retval;
 
-	adapter = dev->priv;
+	adapter = netdev_priv(dev);
 
 	if (elp_debug >= 3)
 		printk(KERN_DEBUG "%s: request to open device\n", dev->name);
@@ -986,7 +986,7 @@ static int elp_open(struct net_device *d
 
 static int send_packet(struct net_device *dev, struct sk_buff *skb)
 {
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	unsigned long target;
 	unsigned long flags;
 
@@ -1056,7 +1056,7 @@ static int send_packet(struct net_device
 
 static void elp_timeout(struct net_device *dev)
 {
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	int stat;
 
 	stat = inb_status(dev->base_addr);
@@ -1078,7 +1078,7 @@ static void elp_timeout(struct net_devic
 static int elp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned long flags;
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 
 	spin_lock_irqsave(&adapter->lock, flags);
 	check_3c505_dma(dev);
@@ -1120,7 +1120,7 @@ static int elp_start_xmit(struct sk_buff
 
 static struct net_device_stats *elp_get_stats(struct net_device *dev)
 {
-	elp_device *adapter = (elp_device *) dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 
 	if (elp_debug >= 3)
 		printk(KERN_DEBUG "%s: request for stats\n", dev->name);
@@ -1184,7 +1184,7 @@ static int elp_close(struct net_device *
 {
 	elp_device *adapter;
 
-	adapter = dev->priv;
+	adapter = netdev_priv(dev);
 
 	if (elp_debug >= 3)
 		printk(KERN_DEBUG "%s: request to close device\n", dev->name);
@@ -1225,7 +1225,7 @@ static int elp_close(struct net_device *
 
 static void elp_set_mc_list(struct net_device *dev)
 {
-	elp_device *adapter = (elp_device *) dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	struct dev_mc_list *dmi = dev->mc_list;
 	int i;
 	unsigned long flags;
@@ -1396,7 +1396,7 @@ static int __init elp_autodetect(struct 
 
 static int __init elplus_setup(struct net_device *dev)
 {
-	elp_device *adapter = dev->priv;
+	elp_device *adapter = netdev_priv(dev);
 	int i, tries, tries1, okay;
 	unsigned long timeout;
 	unsigned long cookie = 0;
diff --git a/drivers/net/3c523.c b/drivers/net/3c523.c
index ab18343..98fef26 100644
--- a/drivers/net/3c523.c
+++ b/drivers/net/3c523.c
@@ -309,7 +309,7 @@ static int elmc_open(struct net_device *
 
 static int __init check586(struct net_device *dev, unsigned long where, unsigned size)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 	char *iscp_addrs[2];
 	int i = 0;
 
@@ -350,7 +350,7 @@ static int __init check586(struct net_de
 
 void alloc586(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	elmc_id_reset586();
 	DELAY(2);
@@ -421,7 +421,7 @@ static int __init do_elmc_probe(struct n
 	int i = 0;
 	unsigned int size = 0;
 	int retval;
-	struct priv *pr = dev->priv;
+	struct priv *pr = netdev_priv(dev);
 
 	SET_MODULE_OWNER(dev);
 	if (MCA_bus == 0) {
@@ -586,7 +586,7 @@ err_out:
 
 static void cleanup_card(struct net_device *dev)
 {
-	mca_set_adapter_procfn(((struct priv *) (dev->priv))->slot, NULL, NULL);
+	mca_set_adapter_procfn(((struct priv *) (netdev_priv(dev)))->slot, NULL, NULL);
 	release_region(dev->base_addr, ELMC_IO_EXTENT);
 }
 
@@ -622,7 +622,7 @@ static int init586(struct net_device *de
 	void *ptr;
 	unsigned long s;
 	int i, result = 0;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 	volatile struct configure_cmd_struct *cfg_cmd;
 	volatile struct iasetup_cmd_struct *ias_cmd;
 	volatile struct tdr_cmd_struct *tdr_cmd;
@@ -860,7 +860,7 @@ static void *alloc_rfa(struct net_device
 	volatile struct rfd_struct *rfd = (struct rfd_struct *) ptr;
 	volatile struct rbd_struct *rbd;
 	int i;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	memset((char *) rfd, 0, sizeof(struct rfd_struct) * p->num_recv_buffs);
 	p->rfd_first = rfd;
@@ -921,7 +921,7 @@ elmc_interrupt(int irq, void *dev_id)
 	}
 	/* reading ELMC_CTRL also clears the INT bit. */
 
-	p = (struct priv *) dev->priv;
+	p = netdev_priv(dev);
 
 	while ((stat = p->scb->status & STAT_MASK))
 	{
@@ -977,7 +977,7 @@ static void elmc_rcv_int(struct net_devi
 	unsigned short totlen;
 	struct sk_buff *skb;
 	struct rbd_struct *rbd;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	for (; (status = p->rfd_top->status) & STAT_COMPL;) {
 		rbd = (struct rbd_struct *) make32(p->rfd_top->rbd_offset);
@@ -1021,7 +1021,7 @@ static void elmc_rcv_int(struct net_devi
 
 static void elmc_rnr_int(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	p->stats.rx_errors++;
 
@@ -1044,7 +1044,7 @@ static void elmc_rnr_int(struct net_devi
 static void elmc_xmt_int(struct net_device *dev)
 {
 	int status;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	status = p->xmit_cmds[p->xmit_last]->cmd_status;
 	if (!(status & STAT_COMPL)) {
@@ -1087,7 +1087,7 @@ #endif
 
 static void startrecv586(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	p->scb->rfa_offset = make16(p->rfd_first);
 	p->scb->cmd = RUC_START;
@@ -1101,7 +1101,7 @@ static void startrecv586(struct net_devi
 
 static void elmc_timeout(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 	/* COMMAND-UNIT active? */
 	if (p->scb->status & CU_ACTIVE) {
 #ifdef DEBUG
@@ -1137,7 +1137,7 @@ static int elmc_send_packet(struct sk_bu
 #ifndef NO_NOPCOMMANDS
 	int next_nop;
 #endif
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	netif_stop_queue(dev);
 
@@ -1208,7 +1208,7 @@ #endif
 
 static struct net_device_stats *elmc_get_stats(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 	unsigned short crc, aln, rsc, ovrn;
 
 	crc = p->scb->crc_errs;	/* get error-statistic from the ni82586 */
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 001c66d..a70fe56 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -804,7 +804,7 @@ static int vortex_suspend(struct pci_dev
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 
-	if (dev && dev->priv) {
+	if (dev && netdev_priv(dev)) {
 		if (netif_running(dev)) {
 			netif_device_detach(dev);
 			vortex_down(dev, 1);
@@ -3193,7 +3193,7 @@ #ifdef CONFIG_EISA
 #endif
 
 	if (compaq_net_device) {
-		vp = compaq_net_device->priv;
+		vp = netdev_priv(compaq_net_device);
 		ioaddr = ioport_map(compaq_net_device->base_addr,
 		                    VORTEX_TOTAL_SIZE);
 
diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index 62e660a..dcfa951 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -468,7 +468,7 @@ static int __devinit acenic_probe_one(st
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	ap = dev->priv;
+	ap = netdev_priv(dev);
 	ap->pdev = pdev;
 	ap->name = pci_name(pdev);
 
diff --git a/drivers/net/atarilance.c b/drivers/net/atarilance.c
index dfa8b9b..223df93 100644
--- a/drivers/net/atarilance.c
+++ b/drivers/net/atarilance.c
@@ -524,7 +524,7 @@ static unsigned long __init lance_probe1
 	return( 0 );
 
   probe_ok:
-	lp = (struct lance_private *)dev->priv;
+	lp = netdev_priv(dev);
 	MEM = (struct lance_memory *)memaddr;
 	IO = lp->iobase = (struct lance_ioreg *)ioaddr;
 	dev->base_addr = (unsigned long)ioaddr; /* informational only */
@@ -653,7 +653,7 @@ #endif
 
 static int lance_open( struct net_device *dev )
 
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+{	struct lance_private *lp = netdev_priv(dev);
 	struct lance_ioreg	 *IO = lp->iobase;
 	int i;
 
@@ -694,7 +694,7 @@ static int lance_open( struct net_device
 
 static void lance_init_ring( struct net_device *dev )
 
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+{	struct lance_private *lp = netdev_priv(dev);
 	int i;
 	unsigned offset;
 
@@ -742,7 +742,7 @@ #define	CHECK_OFFSET(o)														 \
 
 static void lance_tx_timeout (struct net_device *dev)
 {
-	struct lance_private *lp = (struct lance_private *) dev->priv;
+	struct lance_private *lp = netdev_priv(dev);
 	struct lance_ioreg	 *IO = lp->iobase;
 
 	AREG = CSR0;
@@ -785,7 +785,7 @@ #endif
 
 static int lance_start_xmit( struct sk_buff *skb, struct net_device *dev )
 
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+{	struct lance_private *lp = netdev_priv(dev);
 	struct lance_ioreg	 *IO = lp->iobase;
 	int entry, len;
 	struct lance_tx_head *head;
@@ -879,7 +879,7 @@ static irqreturn_t lance_interrupt( int 
 		return IRQ_NONE;
 	}
 
-	lp = (struct lance_private *)dev->priv;
+	lp = netdev_priv(dev);
 	IO = lp->iobase;
 	spin_lock (&lp->devlock);
 
@@ -980,7 +980,7 @@ #endif
 
 static int lance_rx( struct net_device *dev )
 
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+{	struct lance_private *lp = netdev_priv(dev);
 	int entry = lp->cur_rx & RX_RING_MOD_MASK;
 	int i;
 
@@ -1073,7 +1073,7 @@ static int lance_rx( struct net_device *
 
 static int lance_close( struct net_device *dev )
 
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+{	struct lance_private *lp = netdev_priv(dev);
 	struct lance_ioreg	 *IO = lp->iobase;
 
 	netif_stop_queue (dev);
@@ -1093,7 +1093,7 @@ static int lance_close( struct net_devic
 
 static struct net_device_stats *lance_get_stats( struct net_device *dev )
 
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+{	struct lance_private *lp = netdev_priv(dev);
 
 	return &lp->stats;
 }
@@ -1108,7 +1108,7 @@ static struct net_device_stats *lance_ge
 
 static void set_multicast_list( struct net_device *dev )
 
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+{	struct lance_private *lp = netdev_priv(dev);
 	struct lance_ioreg	 *IO = lp->iobase;
 
 	if (netif_running(dev))
@@ -1150,7 +1150,7 @@ static void set_multicast_list( struct n
 
 static int lance_set_mac_address( struct net_device *dev, void *addr )
 
-{	struct lance_private *lp = (struct lance_private *)dev->priv;
+{	struct lance_private *lp = netdev_priv(dev);
 	struct sockaddr *saddr = addr;
 	int i;
 
diff --git a/drivers/net/atp.c b/drivers/net/atp.c
index 82d78ff..96a9855 100644
--- a/drivers/net/atp.c
+++ b/drivers/net/atp.c
@@ -932,7 +932,7 @@ static void __exit atp_cleanup_module(vo
 	struct net_device *next_dev;
 
 	while (root_atp_dev) {
-		next_dev = ((struct net_local *)root_atp_dev->priv)->next_module;
+		next_dev = ((struct net_local *)netdev_priv(root_atp_dev))->next_module;
 		unregister_netdev(root_atp_dev);
 		/* No need to release_region(), since we never snarf it. */
 		free_netdev(root_atp_dev);
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index e86b369..21713fe 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -196,7 +196,7 @@ #endif
  */
 static int mdio_read(struct net_device *dev, int phy_addr, int reg)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 	volatile u32 *const mii_control_reg = &aup->mac->mii_control;
 	volatile u32 *const mii_data_reg = &aup->mac->mii_data;
 	u32 timedout = 20;
@@ -230,7 +230,7 @@ static int mdio_read(struct net_device *
 
 static void mdio_write(struct net_device *dev, int phy_addr, int reg, u16 value)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 	volatile u32 *const mii_control_reg = &aup->mac->mii_control;
 	volatile u32 *const mii_data_reg = &aup->mac->mii_data;
 	u32 timedout = 20;
@@ -285,7 +285,7 @@ static int mdiobus_reset(struct mii_bus 
 
 static int mii_probe (struct net_device *dev)
 {
-	struct au1000_private *const aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 	struct phy_device *phydev = NULL;
 
 #if defined(AU1XXX_PHY_STATIC_CONFIG)
@@ -417,7 +417,7 @@ void ReleaseDB(struct au1000_private *au
 
 static void enable_rx_tx(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 
 	if (au1000_debug > 4)
 		printk(KERN_INFO "%s: enable_rx_tx\n", dev->name);
@@ -428,7 +428,7 @@ static void enable_rx_tx(struct net_devi
 
 static void hard_stop(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 
 	if (au1000_debug > 4)
 		printk(KERN_INFO "%s: hard stop\n", dev->name);
@@ -440,7 +440,7 @@ static void hard_stop(struct net_device 
 static void enable_mac(struct net_device *dev, int force_reset)
 {
 	unsigned long flags;
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 
 	spin_lock_irqsave(&aup->lock, flags);
 
@@ -459,7 +459,7 @@ static void enable_mac(struct net_device
 
 static void reset_mac_unlocked(struct net_device *dev)
 {
-	struct au1000_private *const aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 	int i;
 
 	hard_stop(dev);
@@ -485,7 +485,7 @@ static void reset_mac_unlocked(struct ne
 
 static void reset_mac(struct net_device *dev)
 {
-	struct au1000_private *const aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 	unsigned long flags;
 
 	if (au1000_debug > 4)
@@ -574,7 +574,7 @@ static int __init au1000_init_module(voi
 
 static int au1000_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct au1000_private *aup = (struct au1000_private *)dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 
 	if (aup->phy_dev)
 		return phy_ethtool_gset(aup->phy_dev, cmd);
@@ -584,7 +584,7 @@ static int au1000_get_settings(struct ne
 
 static int au1000_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct au1000_private *aup = (struct au1000_private *)dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -598,7 +598,7 @@ static int au1000_set_settings(struct ne
 static void
 au1000_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct au1000_private *aup = (struct au1000_private *)dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 
 	strcpy(info->driver, DRV_NAME);
 	strcpy(info->version, DRV_VERSION);
@@ -655,7 +655,7 @@ static struct net_device * au1000_probe(
 	printk("%s: Au1xx0 Ethernet found at 0x%x, irq %d\n",
 		dev->name, base, irq);
 
-	aup = dev->priv;
+	aup = netdev_priv(dev);
 
 	/* Allocate the data buffers */
 	/* Snooping works fine with eth on all au1xxx */
@@ -820,7 +820,7 @@ err_out:
  */
 static int au1000_init(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 	u32 flags;
 	int i;
 	u32 control;
@@ -871,7 +871,7 @@ #endif
 static void
 au1000_adjust_link(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 	struct phy_device *phydev = aup->phy_dev;
 	unsigned long flags;
 
@@ -951,7 +951,7 @@ au1000_adjust_link(struct net_device *de
 static int au1000_open(struct net_device *dev)
 {
 	int retval;
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 
 	if (au1000_debug > 4)
 		printk("%s: open: dev=%p\n", dev->name, dev);
@@ -986,7 +986,7 @@ static int au1000_open(struct net_device
 static int au1000_close(struct net_device *dev)
 {
 	unsigned long flags;
-	struct au1000_private *const aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *const aup = netdev_priv(dev);
 
 	if (au1000_debug > 4)
 		printk("%s: close: dev=%p\n", dev->name, dev);
@@ -1017,7 +1017,7 @@ static void __exit au1000_cleanup_module
 	for (i = 0; i < num_ifs; i++) {
 		dev = iflist[i].dev;
 		if (dev) {
-			aup = (struct au1000_private *) dev->priv;
+			aup = netdev_priv(dev);
 			unregister_netdev(dev);
 			for (j = 0; j < NUM_RX_DMA; j++)
 				if (aup->rx_db_inuse[j])
@@ -1037,7 +1037,7 @@ static void __exit au1000_cleanup_module
 
 static void update_tx_stats(struct net_device *dev, u32 status)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 	struct net_device_stats *ps = &aup->stats;
 
 	if (status & TX_FRAME_ABORTED) {
@@ -1066,7 +1066,7 @@ static void update_tx_stats(struct net_d
  */
 static void au1000_tx_ack(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 	volatile tx_dma_t *ptxd;
 
 	ptxd = aup->tx_dma_ring[aup->tx_tail];
@@ -1093,7 +1093,7 @@ static void au1000_tx_ack(struct net_dev
  */
 static int au1000_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 	struct net_device_stats *ps = &aup->stats;
 	volatile tx_dma_t *ptxd;
 	u32 buff_stat;
@@ -1147,7 +1147,7 @@ static int au1000_tx(struct sk_buff *skb
 
 static inline void update_rx_stats(struct net_device *dev, u32 status)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 	struct net_device_stats *ps = &aup->stats;
 
 	ps->rx_packets++;
@@ -1175,7 +1175,7 @@ static inline void update_rx_stats(struc
  */
 static int au1000_rx(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 	struct sk_buff *skb;
 	volatile rx_dma_t *prxd;
 	u32 buff_stat, status;
@@ -1283,7 +1283,7 @@ static void au1000_tx_timeout(struct net
 
 static void set_rx_mode(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 
 	if (au1000_debug > 4)
 		printk("%s: set_rx_mode: flags=%x\n", dev->name, dev->flags);
@@ -1315,7 +1315,7 @@ static void set_rx_mode(struct net_devic
 
 static int au1000_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct au1000_private *aup = (struct au1000_private *)dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 
 	if (!netif_running(dev)) return -EINVAL;
 
@@ -1326,7 +1326,7 @@ static int au1000_ioctl(struct net_devic
 
 static struct net_device_stats *au1000_get_stats(struct net_device *dev)
 {
-	struct au1000_private *aup = (struct au1000_private *) dev->priv;
+	struct au1000_private *aup = netdev_priv(dev);
 
 	if (au1000_debug > 4)
 		printk("%s: au1000_get_stats: dev=%p\n", dev->name, dev);
diff --git a/drivers/net/de600.c b/drivers/net/de600.c
index dae97b8..27cf8c7 100644
--- a/drivers/net/de600.c
+++ b/drivers/net/de600.c
@@ -156,7 +156,7 @@ static int de600_close(struct net_device
 
 static struct net_device_stats *get_stats(struct net_device *dev)
 {
-	return (struct net_device_stats *)(dev->priv);
+	return (struct net_device_stats *)(netdev_priv(dev));
 }
 
 static inline void trigger_interrupt(struct net_device *dev)
@@ -308,7 +308,7 @@ static int de600_tx_intr(struct net_devi
 	if (!(irq_status & TX_FAILED16)) {
 		tx_fifo_out = (tx_fifo_out + 1) % TX_PAGES;
 		++free_tx_pages;
-		((struct net_device_stats *)(dev->priv))->tx_packets++;
+		((struct net_device_stats *)(netdev_priv(dev)))->tx_packets++;
 		netif_wake_queue(dev);
 	}
 
@@ -375,8 +375,8 @@ static void de600_rx_intr(struct net_dev
 
 	/* update stats */
 	dev->last_rx = jiffies;
-	((struct net_device_stats *)(dev->priv))->rx_packets++; /* count all receives */
-	((struct net_device_stats *)(dev->priv))->rx_bytes += size; /* count all received bytes */
+	((struct net_device_stats *)(netdev_priv(dev)))->rx_packets++; /* count all receives */
+	((struct net_device_stats *)(netdev_priv(dev)))->rx_bytes += size; /* count all received bytes */
 
 	/*
 	 * If any worth-while packets have been received, netif_rx()
diff --git a/drivers/net/de620.c b/drivers/net/de620.c
index dc48924..e57b0f9 100644
--- a/drivers/net/de620.c
+++ b/drivers/net/de620.c
@@ -485,7 +485,7 @@ static int de620_close(struct net_device
  */
 static struct net_device_stats *get_stats(struct net_device *dev)
 {
-	return (struct net_device_stats *)(dev->priv);
+	return (struct net_device_stats *)(netdev_priv(dev));
 }
 
 /*********************************************
@@ -579,7 +579,7 @@ static int de620_start_xmit(struct sk_bu
 	if(!(using_txbuf == (TXBF0 | TXBF1)))
 		netif_wake_queue(dev);
 
-	((struct net_device_stats *)(dev->priv))->tx_packets++;
+	((struct net_device_stats *)(netdev_priv(dev)))->tx_packets++;
 	spin_unlock_irqrestore(&de620_lock, flags);
 	dev_kfree_skb (skb);
 	return 0;
@@ -660,7 +660,7 @@ static int de620_rx_intr(struct net_devi
 		/* You win some, you lose some. And sometimes plenty... */
 		adapter_init(dev);
 		netif_wake_queue(dev);
-		((struct net_device_stats *)(dev->priv))->rx_over_errors++;
+		((struct net_device_stats *)(netdev_priv(dev)))->rx_over_errors++;
 		return 0;
 	}
 
@@ -680,7 +680,7 @@ static int de620_rx_intr(struct net_devi
 		next_rx_page = header_buf.Rx_NextPage; /* at least a try... */
 		de620_send_command(dev, W_DUMMY);
 		de620_set_register(dev, W_NPRF, next_rx_page);
-		((struct net_device_stats *)(dev->priv))->rx_over_errors++;
+		((struct net_device_stats *)(netdev_priv(dev)))->rx_over_errors++;
 		return 0;
 	}
 	next_rx_page = pagelink;
@@ -693,7 +693,7 @@ static int de620_rx_intr(struct net_devi
 		skb = dev_alloc_skb(size+2);
 		if (skb == NULL) { /* Yeah, but no place to put it... */
 			printk(KERN_WARNING "%s: Couldn't allocate a sk_buff of size %d.\n", dev->name, size);
-			((struct net_device_stats *)(dev->priv))->rx_dropped++;
+			((struct net_device_stats *)(netdev_priv(dev)))->rx_dropped++;
 		}
 		else { /* Yep! Go get it! */
 			skb_reserve(skb,2);	/* Align */
@@ -706,8 +706,8 @@ static int de620_rx_intr(struct net_devi
 			netif_rx(skb); /* deliver it "upstairs" */
 			dev->last_rx = jiffies;
 			/* count all receives */
-			((struct net_device_stats *)(dev->priv))->rx_packets++;
-			((struct net_device_stats *)(dev->priv))->rx_bytes += size;
+			((struct net_device_stats *)(netdev_priv(dev)))->rx_packets++;
+			((struct net_device_stats *)(netdev_priv(dev)))->rx_bytes += size;
 		}
 	}
 
diff --git a/drivers/net/declance.c b/drivers/net/declance.c
index b2577f4..d8cb974 100644
--- a/drivers/net/declance.c
+++ b/drivers/net/declance.c
@@ -1047,7 +1047,7 @@ static int __init dec_lance_probe(struct
 		dev = root_lance_dev;
 		while (dev) {
 			i++;
-			lp = (struct lance_private *)dev->priv;
+			lp = netdev_priv(dev);
 			dev = lp->next;
 		}
 		snprintf(name, sizeof(name), fmt, i);
diff --git a/drivers/net/depca.c b/drivers/net/depca.c
index 1834970..ba32f83 100644
--- a/drivers/net/depca.c
+++ b/drivers/net/depca.c
@@ -602,7 +602,7 @@ static int __init depca_hw_init (struct 
 		return -ENXIO;
 	}
 
-	lp = (struct depca_private *) dev->priv;
+	lp = netdev_priv(dev);
 	mem_start = lp->mem_start;
 
 	if (!mem_start || lp->adapter < DEPCA || lp->adapter >=unknown)
@@ -826,7 +826,7 @@ out_priv:
 
 static int depca_open(struct net_device *dev)
 {
-	struct depca_private *lp = (struct depca_private *) dev->priv;
+	struct depca_private *lp = netdev_priv(dev);
 	u_long ioaddr = dev->base_addr;
 	s16 nicsr;
 	int status = 0;
@@ -871,7 +871,7 @@ static int depca_open(struct net_device 
 /* Initialize the lance Rx and Tx descriptor rings. */
 static void depca_init_ring(struct net_device *dev)
 {
-	struct depca_private *lp = (struct depca_private *) dev->priv;
+	struct depca_private *lp = netdev_priv(dev);
 	u_int i;
 	u_long offset;
 
@@ -929,7 +929,7 @@ static void depca_tx_timeout(struct net_
 */
 static int depca_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct depca_private *lp = (struct depca_private *) dev->priv;
+	struct depca_private *lp = netdev_priv(dev);
 	u_long ioaddr = dev->base_addr;
 	int status = 0;
 
@@ -977,7 +977,7 @@ static irqreturn_t depca_interrupt(int i
 		return IRQ_NONE;
 	}
 
-	lp = (struct depca_private *) dev->priv;
+	lp = netdev_priv(dev);
 	ioaddr = dev->base_addr;
 
 	spin_lock(&lp->lock);
@@ -1015,7 +1015,7 @@ static irqreturn_t depca_interrupt(int i
 /* Called with lp->lock held */
 static int depca_rx(struct net_device *dev)
 {
-	struct depca_private *lp = (struct depca_private *) dev->priv;
+	struct depca_private *lp = netdev_priv(dev);
 	int i, entry;
 	s32 status;
 
@@ -1113,7 +1113,7 @@ static int depca_rx(struct net_device *d
 */
 static int depca_tx(struct net_device *dev)
 {
-	struct depca_private *lp = (struct depca_private *) dev->priv;
+	struct depca_private *lp = netdev_priv(dev);
 	int entry;
 	s32 status;
 	u_long ioaddr = dev->base_addr;
@@ -1154,7 +1154,7 @@ static int depca_tx(struct net_device *d
 
 static int depca_close(struct net_device *dev)
 {
-	struct depca_private *lp = (struct depca_private *) dev->priv;
+	struct depca_private *lp = netdev_priv(dev);
 	s16 nicsr;
 	u_long ioaddr = dev->base_addr;
 
@@ -1190,7 +1190,7 @@ static int depca_close(struct net_device
 
 static void LoadCSRs(struct net_device *dev)
 {
-	struct depca_private *lp = (struct depca_private *) dev->priv;
+	struct depca_private *lp = netdev_priv(dev);
 	u_long ioaddr = dev->base_addr;
 
 	outw(CSR1, DEPCA_ADDR);	/* initialisation block address LSW */
@@ -1207,7 +1207,7 @@ static void LoadCSRs(struct net_device *
 
 static int InitRestartDepca(struct net_device *dev)
 {
-	struct depca_private *lp = (struct depca_private *) dev->priv;
+	struct depca_private *lp = netdev_priv(dev);
 	u_long ioaddr = dev->base_addr;
 	int i, status = 0;
 
@@ -1236,7 +1236,7 @@ static int InitRestartDepca(struct net_d
 
 static struct net_device_stats *depca_get_stats(struct net_device *dev)
 {
-	struct depca_private *lp = (struct depca_private *) dev->priv;
+	struct depca_private *lp = netdev_priv(dev);
 
 	/* Null body since there is no framing error counter */
 
@@ -1248,7 +1248,7 @@ static struct net_device_stats *depca_ge
 */
 static void set_multicast_list(struct net_device *dev)
 {
-	struct depca_private *lp = (struct depca_private *) dev->priv;
+	struct depca_private *lp = netdev_priv(dev);
 	u_long ioaddr = dev->base_addr;
 
 	netif_stop_queue(dev);
@@ -1277,7 +1277,7 @@ static void set_multicast_list(struct ne
 */
 static void SetMulticastFilter(struct net_device *dev)
 {
-	struct depca_private *lp = (struct depca_private *) dev->priv;
+	struct depca_private *lp = netdev_priv(dev);
 	struct dev_mc_list *dmi = dev->mc_list;
 	char *addrs;
 	int i, j, bit, byte;
@@ -1445,7 +1445,7 @@ static int __init depca_mca_probe(struct
 
 	dev->irq = irq;
 	dev->base_addr = iobase;
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	lp->depca_bus = DEPCA_BUS_MCA;
 	lp->adapter = depca_mca_adapter_type[mdev->index];
 	lp->mem_start = mem_start;
@@ -1548,7 +1548,7 @@ static int __init depca_isa_probe (struc
 	dev->base_addr = ioaddr;
 	dev->irq = irq;		/* Use whatever value the user gave
 				 * us, and 0 if he didn't. */
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	lp->depca_bus = DEPCA_BUS_ISA;
 	lp->adapter = adapter;
 	lp->mem_start = mem_start;
@@ -1594,7 +1594,7 @@ static int __init depca_eisa_probe (stru
 
 	dev->base_addr = ioaddr;
 	dev->irq = irq;
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	lp->depca_bus = DEPCA_BUS_EISA;
 	lp->adapter = edev->id.driver_data;
 	lp->mem_start = mem_start;
@@ -1619,7 +1619,7 @@ static int __devexit depca_device_remove
 	int bus;
 
 	dev  = device->driver_data;
-	lp   = dev->priv;
+	lp   = netdev_priv(dev);
 
 	unregister_netdev (dev);
 	iounmap (lp->sh_mem);
@@ -1761,7 +1761,7 @@ static int __init DevicePresent(u_long i
 static int __init get_hw_addr(struct net_device *dev)
 {
 	u_long ioaddr = dev->base_addr;
-	struct depca_private *lp = dev->priv;
+	struct depca_private *lp = netdev_priv(dev);
 	int i, k, tmp, status = 0;
 	u_short j, x, chksum;
 
@@ -1796,7 +1796,7 @@ static int __init get_hw_addr(struct net
 */
 static int load_packet(struct net_device *dev, struct sk_buff *skb)
 {
-	struct depca_private *lp = (struct depca_private *) dev->priv;
+	struct depca_private *lp = netdev_priv(dev);
 	int i, entry, end, len, status = 0;
 
 	entry = lp->tx_new;	/* Ring around buffer number. */
@@ -1851,7 +1851,7 @@ static int load_packet(struct net_device
 
 static void depca_dbg_open(struct net_device *dev)
 {
-	struct depca_private *lp = (struct depca_private *) dev->priv;
+	struct depca_private *lp = netdev_priv(dev);
 	u_long ioaddr = dev->base_addr;
 	struct depca_init *p = &lp->init_block;
 	int i;
@@ -1926,7 +1926,7 @@ static void depca_dbg_open(struct net_de
 */
 static int depca_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct depca_private *lp = (struct depca_private *) dev->priv;
+	struct depca_private *lp = netdev_priv(dev);
 	struct depca_ioctl *ioc = (struct depca_ioctl *) &rq->ifr_ifru;
 	int i, status = 0;
 	u_long ioaddr = dev->base_addr;
diff --git a/drivers/net/dgrs.c b/drivers/net/dgrs.c
index df62c02..4a2651c 100644
--- a/drivers/net/dgrs.c
+++ b/drivers/net/dgrs.c
@@ -251,7 +251,7 @@ typedef struct
 static void
 proc_reset(struct net_device *dev0, int reset)
 {
-	DGRS_PRIV	*priv0 = (DGRS_PRIV *) dev0->priv;
+	DGRS_PRIV	*priv0 = netdev_priv(dev0);
 
 	if (priv0->plxreg)
 	{
@@ -275,7 +275,7 @@ proc_reset(struct net_device *dev0, int 
 static int
 check_board_dma(struct net_device *dev0)
 {
-	DGRS_PRIV	*priv0 = (DGRS_PRIV *) dev0->priv;
+	DGRS_PRIV	*priv0 = netdev_priv(dev0);
 	ulong	x;
 
 	/*
@@ -358,7 +358,7 @@ do_plx_dma(
 {
         int     	i;
         ulong   	csr = 0;
-	DGRS_PRIV	*priv = (DGRS_PRIV *) dev->priv;
+	DGRS_PRIV	*priv = netdev_priv(dev);
 
 	if (pciaddr)
 	{
@@ -482,7 +482,7 @@ dgrs_rcv_frame(
 		 */
 		if (devN == NULL)
 			goto out;
-		privN = (DGRS_PRIV *) devN->priv;
+		privN = netdev_priv(devN);
 	}
 	else
 	{	/* Switch mode */
@@ -694,7 +694,7 @@ out:
 
 static int dgrs_start_xmit(struct sk_buff *skb, struct net_device *devN)
 {
-	DGRS_PRIV	*privN = (DGRS_PRIV *) devN->priv;
+	DGRS_PRIV	*privN = netdev_priv(devN);
 	struct net_device	*dev0;
 	DGRS_PRIV	*priv0;
 	I596_RBD	*rbdp;
@@ -707,7 +707,7 @@ static int dgrs_start_xmit(struct sk_buf
 	if (dgrs_nicmode)
 	{
 		dev0 = privN->devtbl[0];
-		priv0 = (DGRS_PRIV *) dev0->priv;
+		priv0 = netdev_priv(dev0);
 	}
 	else
 	{
@@ -810,7 +810,7 @@ static int dgrs_close( struct net_device
  */
 static struct net_device_stats *dgrs_get_stats( struct net_device *dev )
 {
-	DGRS_PRIV	*priv = (DGRS_PRIV *) dev->priv;
+	DGRS_PRIV	*priv = netdev_priv(dev);
 
 	return (&priv->stats);
 }
@@ -821,7 +821,7 @@ static struct net_device_stats *dgrs_get
 
 static void dgrs_set_multicast_list( struct net_device *dev)
 {
-	DGRS_PRIV	*priv = (DGRS_PRIV *) dev->priv;
+	DGRS_PRIV	*priv = netdev_priv(dev);
 
 	priv->port->is_promisc = (dev->flags & IFF_PROMISC) ? 1 : 0;
 }
@@ -831,7 +831,7 @@ static void dgrs_set_multicast_list( str
  */
 static int dgrs_ioctl(struct net_device *devN, struct ifreq *ifr, int cmd)
 {
-	DGRS_PRIV	*privN = (DGRS_PRIV *) devN->priv;
+	DGRS_PRIV	*privN = netdev_priv(devN);
 	DGRS_IOCTL	ioc;
 	int		i;
 
@@ -897,7 +897,7 @@ static int dgrs_ioctl(struct net_device 
 static irqreturn_t dgrs_intr(int irq, void *dev_id)
 {
 	struct net_device	*dev0 = dev_id;
-	DGRS_PRIV	*priv0 = dev0->priv;
+	DGRS_PRIV	*priv0 = netdev_priv(dev0);
 	I596_CB		*cbp;
 	int		cmd;
 	int		i;
@@ -987,7 +987,7 @@ ack_intr:
 static int __init
 dgrs_download(struct net_device *dev0)
 {
-	DGRS_PRIV	*priv0 = (DGRS_PRIV *) dev0->priv;
+	DGRS_PRIV	*priv0 = netdev_priv(dev0);
 	int		is;
 	unsigned long	i;
 
@@ -1151,7 +1151,7 @@ dgrs_download(struct net_device *dev0)
 static int __init
 dgrs_probe1(struct net_device *dev)
 {
-	DGRS_PRIV	*priv = (DGRS_PRIV *) dev->priv;
+	DGRS_PRIV	*priv = netdev_priv(dev);
 	unsigned long	i;
 	int		rc;
 
@@ -1229,7 +1229,7 @@ err_out:
 static int __init
 dgrs_initclone(struct net_device *dev)
 {
-	DGRS_PRIV	*priv = (DGRS_PRIV *) dev->priv;
+	DGRS_PRIV	*priv = netdev_priv(dev);
 	int		i;
 
 	printk("%s: Digi RightSwitch port %d ",
@@ -1259,7 +1259,7 @@ dgrs_found_device(
 	if (!dev)
 		goto err0;
 
-	priv = (DGRS_PRIV *)dev->priv;
+	priv = netdev_priv(dev);
 
 	dev->base_addr = io;
 	dev->mem_start = mem;
@@ -1305,7 +1305,7 @@ dgrs_found_device(
 		/* Don't copy the network device structure! */
 
 		/* copy the priv structure of dev[0] */
-		privN = (DGRS_PRIV *)devN->priv;
+		privN = netdev_priv(devN);
 		*privN = *priv;
 
 			/* ... and zero out VM areas */
@@ -1350,7 +1350,7 @@ dgrs_found_device(
 
 static void __devexit dgrs_remove(struct net_device *dev)
 {
-	DGRS_PRIV *priv = dev->priv;
+	DGRS_PRIV *priv = netdev_priv(dev);
 	int i;
 
 	unregister_netdev(dev);
diff --git a/drivers/net/dm9000.c b/drivers/net/dm9000.c
index c3de81b..38064df 100644
--- a/drivers/net/dm9000.c
+++ b/drivers/net/dm9000.c
@@ -328,7 +328,7 @@ static void dm9000_set_io(struct board_i
 /* Our watchdog timed out. Called by the networking layer */
 static void dm9000_timeout(struct net_device *dev)
 {
-	board_info_t *db = (board_info_t *) dev->priv;
+	board_info_t *db = (board_info_t *) netdev_priv(dev);
 	u8 reg_save;
 	unsigned long flags;
 
@@ -422,7 +422,7 @@ dm9000_probe(struct platform_device *pde
 	PRINTK2("dm9000_probe()");
 
 	/* setup board info structure */
-	db = (struct board_info *) ndev->priv;
+	db = netdev_priv(ndev);
 	memset(db, 0, sizeof (*db));
 
 	spin_lock_init(&db->lock);
@@ -625,7 +625,7 @@ #endif
 static int
 dm9000_open(struct net_device *dev)
 {
-	board_info_t *db = (board_info_t *) dev->priv;
+	board_info_t *db = (board_info_t *) netdev_priv(dev);
 
 	PRINTK2("entering dm9000_open\n");
 
@@ -658,7 +658,7 @@ dm9000_open(struct net_device *dev)
 static void
 dm9000_init_dm9000(struct net_device *dev)
 {
-	board_info_t *db = (board_info_t *) dev->priv;
+	board_info_t *db = (board_info_t *) netdev_priv(dev);
 
 	PRINTK1("entering %s\n",__FUNCTION__);
 
@@ -700,7 +700,7 @@ dm9000_init_dm9000(struct net_device *de
 static int
 dm9000_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	board_info_t *db = (board_info_t *) dev->priv;
+	board_info_t *db = (board_info_t *) netdev_priv(dev);
 
 	PRINTK3("dm9000_start_xmit\n");
 
@@ -755,7 +755,7 @@ dm9000_start_xmit(struct sk_buff *skb, s
 static void
 dm9000_shutdown(struct net_device *dev)
 {
-	board_info_t *db = (board_info_t *) dev->priv;
+	board_info_t *db = (board_info_t *) netdev_priv(dev);
 
 	/* RESET device */
 	dm9000_phy_write(dev, 0, MII_BMCR, BMCR_RESET);	/* PHY RESET */
@@ -771,7 +771,7 @@ dm9000_shutdown(struct net_device *dev)
 static int
 dm9000_stop(struct net_device *ndev)
 {
-	board_info_t *db = (board_info_t *) ndev->priv;
+	board_info_t *db = (board_info_t *) netdev_priv(ndev);
 
 	PRINTK1("entering %s\n",__FUNCTION__);
 
@@ -831,7 +831,7 @@ dm9000_interrupt(int irq, void *dev_id)
 	}
 
 	/* A real interrupt coming */
-	db = (board_info_t *) dev->priv;
+	db = (board_info_t *) netdev_priv(dev);
 	spin_lock(&db->lock);
 
 	/* Save previous register address */
@@ -869,7 +869,7 @@ dm9000_interrupt(int irq, void *dev_id)
 static struct net_device_stats *
 dm9000_get_stats(struct net_device *dev)
 {
-	board_info_t *db = (board_info_t *) dev->priv;
+	board_info_t *db = (board_info_t *) netdev_priv(dev);
 	return &db->stats;
 }
 
@@ -882,7 +882,7 @@ static void
 dm9000_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *) data;
-	board_info_t *db = (board_info_t *) dev->priv;
+	board_info_t *db = (board_info_t *) netdev_priv(dev);
 
 	PRINTK3("dm9000_timer()\n");
 
@@ -904,7 +904,7 @@ struct dm9000_rxhdr {
 static void
 dm9000_rx(struct net_device *dev)
 {
-	board_info_t *db = (board_info_t *) dev->priv;
+	board_info_t *db = (board_info_t *) netdev_priv(dev);
 	struct dm9000_rxhdr rxhdr;
 	struct sk_buff *skb;
 	u8 rxbyte, *rdptr;
@@ -1061,7 +1061,7 @@ cal_CRC(unsigned char *Data, unsigned in
 static void
 dm9000_hash_table(struct net_device *dev)
 {
-	board_info_t *db = (board_info_t *) dev->priv;
+	board_info_t *db = (board_info_t *) netdev_priv(dev);
 	struct dev_mc_list *mcptr = dev->mc_list;
 	int mc_cnt = dev->mc_count;
 	u32 hash_val;
@@ -1104,7 +1104,7 @@ dm9000_hash_table(struct net_device *dev
 static int
 dm9000_phy_read(struct net_device *dev, int phy_reg_unused, int reg)
 {
-	board_info_t *db = (board_info_t *) dev->priv;
+	board_info_t *db = (board_info_t *) netdev_priv(dev);
 	unsigned long flags;
 	unsigned int reg_save;
 	int ret;
@@ -1138,7 +1138,7 @@ dm9000_phy_read(struct net_device *dev, 
 static void
 dm9000_phy_write(struct net_device *dev, int phyaddr_unused, int reg, int value)
 {
-	board_info_t *db = (board_info_t *) dev->priv;
+	board_info_t *db = (board_info_t *) netdev_priv(dev);
 	unsigned long flags;
 	unsigned long reg_save;
 
@@ -1182,7 +1182,7 @@ static int
 dm9000_drv_resume(struct platform_device *dev)
 {
 	struct net_device *ndev = platform_get_drvdata(dev);
-	board_info_t *db = (board_info_t *) ndev->priv;
+	board_info_t *db = (board_info_t *) netdev_priv(ndev);
 
 	if (ndev) {
 
@@ -1204,7 +1204,7 @@ dm9000_drv_remove(struct platform_device
 	platform_set_drvdata(pdev, NULL);
 
 	unregister_netdev(ndev);
-	dm9000_release_board(pdev, (board_info_t *) ndev->priv);
+	dm9000_release_board(pdev, (board_info_t *) netdev_priv(ndev));
 	free_netdev(ndev);		/* free device structure */
 
 	PRINTK1("clean_module() exit\n");
diff --git a/drivers/net/eepro.c b/drivers/net/eepro.c
index 4768023..52b29b7 100644
--- a/drivers/net/eepro.c
+++ b/drivers/net/eepro.c
@@ -611,7 +611,7 @@ #endif
 
 static void __init printEEPROMInfo(struct net_device *dev)
 {
-	struct eepro_local *lp = (struct eepro_local *)dev->priv;
+	struct eepro_local *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	unsigned short Word;
 	int i,j;
@@ -1700,7 +1700,7 @@ eepro_transmit_interrupt(struct net_devi
 static int eepro_ethtool_get_settings(struct net_device *dev,
 					struct ethtool_cmd *cmd)
 {
-	struct eepro_local	*lp = (struct eepro_local *)dev->priv;
+	struct eepro_local	*lp = netdev_priv(dev);
 
 	cmd->supported = 	SUPPORTED_10baseT_Half |
 				SUPPORTED_10baseT_Full |
diff --git a/drivers/net/epic100.c b/drivers/net/epic100.c
index 1197784..3413a88 100644
--- a/drivers/net/epic100.c
+++ b/drivers/net/epic100.c
@@ -366,7 +366,7 @@ #else
 #endif
 
 	pci_set_drvdata(pdev, dev);
-	ep = dev->priv;
+	ep = netdev_priv(dev);
 	ep->mii.dev = dev;
 	ep->mii.mdio_read = mdio_read;
 	ep->mii.mdio_write = mdio_write;
@@ -652,7 +652,7 @@ static void mdio_write(struct net_device
 
 static int epic_open(struct net_device *dev)
 {
-	struct epic_private *ep = dev->priv;
+	struct epic_private *ep = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int i;
 	int retval;
@@ -760,7 +760,7 @@ #endif
 static void epic_pause(struct net_device *dev)
 {
 	long ioaddr = dev->base_addr;
-	struct epic_private *ep = dev->priv;
+	struct epic_private *ep = netdev_priv(dev);
 
 	netif_stop_queue (dev);
 
@@ -783,7 +783,7 @@ static void epic_pause(struct net_device
 static void epic_restart(struct net_device *dev)
 {
 	long ioaddr = dev->base_addr;
-	struct epic_private *ep = dev->priv;
+	struct epic_private *ep = netdev_priv(dev);
 	int i;
 
 	/* Soft reset the chip. */
@@ -835,7 +835,7 @@ #endif
 
 static void check_media(struct net_device *dev)
 {
-	struct epic_private *ep = dev->priv;
+	struct epic_private *ep = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int mii_lpa = ep->mii_phy_cnt ? mdio_read(dev, ep->phys[0], MII_LPA) : 0;
 	int negotiated = mii_lpa & ep->mii.advertising;
@@ -857,7 +857,7 @@ static void check_media(struct net_devic
 static void epic_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	struct epic_private *ep = dev->priv;
+	struct epic_private *ep = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int next_tick = 5*HZ;
 
@@ -878,7 +878,7 @@ static void epic_timer(unsigned long dat
 
 static void epic_tx_timeout(struct net_device *dev)
 {
-	struct epic_private *ep = dev->priv;
+	struct epic_private *ep = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
 	if (debug > 0) {
@@ -907,7 +907,7 @@ static void epic_tx_timeout(struct net_d
 /* Initialize the Rx and Tx rings, along with various 'dev' bits. */
 static void epic_init_ring(struct net_device *dev)
 {
-	struct epic_private *ep = dev->priv;
+	struct epic_private *ep = netdev_priv(dev);
 	int i;
 
 	ep->tx_full = 0;
@@ -953,7 +953,7 @@ static void epic_init_ring(struct net_de
 
 static int epic_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct epic_private *ep = dev->priv;
+	struct epic_private *ep = netdev_priv(dev);
 	int entry, free_count;
 	u32 ctrl_word;
 	unsigned long flags;
@@ -1081,7 +1081,7 @@ #endif
 static irqreturn_t epic_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev = dev_instance;
-	struct epic_private *ep = dev->priv;
+	struct epic_private *ep = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	unsigned int handled = 0;
 	int status;
@@ -1149,7 +1149,7 @@ out:
 
 static int epic_rx(struct net_device *dev, int budget)
 {
-	struct epic_private *ep = dev->priv;
+	struct epic_private *ep = netdev_priv(dev);
 	int entry = ep->cur_rx % RX_RING_SIZE;
 	int rx_work_limit = ep->dirty_rx + RX_RING_SIZE - ep->cur_rx;
 	int work_done = 0;
@@ -1259,7 +1259,7 @@ static void epic_rx_err(struct net_devic
 
 static int epic_poll(struct net_device *dev, int *budget)
 {
-	struct epic_private *ep = dev->priv;
+	struct epic_private *ep = netdev_priv(dev);
 	int work_done = 0, orig_budget;
 	long ioaddr = dev->base_addr;
 
@@ -1304,7 +1304,7 @@ rx_action:
 static int epic_close(struct net_device *dev)
 {
 	long ioaddr = dev->base_addr;
-	struct epic_private *ep = dev->priv;
+	struct epic_private *ep = netdev_priv(dev);
 	struct sk_buff *skb;
 	int i;
 
@@ -1353,7 +1353,7 @@ static int epic_close(struct net_device 
 
 static struct net_device_stats *epic_get_stats(struct net_device *dev)
 {
-	struct epic_private *ep = dev->priv;
+	struct epic_private *ep = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 
 	if (netif_running(dev)) {
@@ -1374,7 +1374,7 @@ static struct net_device_stats *epic_get
 static void set_rx_mode(struct net_device *dev)
 {
 	long ioaddr = dev->base_addr;
-	struct epic_private *ep = dev->priv;
+	struct epic_private *ep = netdev_priv(dev);
 	unsigned char mc_filter[8];		 /* Multicast hash filter */
 	int i;
 
@@ -1413,7 +1413,7 @@ static void set_rx_mode(struct net_devic
 
 static void netdev_get_drvinfo (struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct epic_private *np = dev->priv;
+	struct epic_private *np = netdev_priv(dev);
 
 	strcpy (info->driver, DRV_NAME);
 	strcpy (info->version, DRV_VERSION);
@@ -1422,7 +1422,7 @@ static void netdev_get_drvinfo (struct n
 
 static int netdev_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct epic_private *np = dev->priv;
+	struct epic_private *np = netdev_priv(dev);
 	int rc;
 
 	spin_lock_irq(&np->lock);
@@ -1434,7 +1434,7 @@ static int netdev_get_settings(struct ne
 
 static int netdev_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct epic_private *np = dev->priv;
+	struct epic_private *np = netdev_priv(dev);
 	int rc;
 
 	spin_lock_irq(&np->lock);
@@ -1446,13 +1446,13 @@ static int netdev_set_settings(struct ne
 
 static int netdev_nway_reset(struct net_device *dev)
 {
-	struct epic_private *np = dev->priv;
+	struct epic_private *np = netdev_priv(dev);
 	return mii_nway_restart(&np->mii);
 }
 
 static u32 netdev_get_link(struct net_device *dev)
 {
-	struct epic_private *np = dev->priv;
+	struct epic_private *np = netdev_priv(dev);
 	return mii_link_ok(&np->mii);
 }
 
@@ -1503,7 +1503,7 @@ static const struct ethtool_ops netdev_e
 
 static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct epic_private *np = dev->priv;
+	struct epic_private *np = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	struct mii_ioctl_data *data = if_mii(rq);
 	int rc;
@@ -1531,7 +1531,7 @@ static int netdev_ioctl(struct net_devic
 static void __devexit epic_remove_one (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct epic_private *ep = dev->priv;
+	struct epic_private *ep = netdev_priv(dev);
 
 	pci_free_consistent(pdev, TX_TOTAL_SIZE, ep->tx_ring, ep->tx_ring_dma);
 	pci_free_consistent(pdev, RX_TOTAL_SIZE, ep->rx_ring, ep->rx_ring_dma);
diff --git a/drivers/net/eth16i.c b/drivers/net/eth16i.c
index 04abf59..3fe913c 100644
--- a/drivers/net/eth16i.c
+++ b/drivers/net/eth16i.c
@@ -1481,7 +1481,7 @@ void __exit cleanup_module(void)
 	for(this_dev = 0; this_dev < MAX_ETH16I_CARDS; this_dev++) {
 		struct net_device *dev = dev_eth16i[this_dev];
 
-		if(dev->priv) {
+		if(netdev_priv(dev)) {
 			unregister_netdev(dev);
 			free_irq(dev->irq, dev);
 			release_region(dev->base_addr, ETH16I_IO_EXTENT);
diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 4e8df91..fdad6f8 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1165,7 +1165,7 @@ #define MII_DP8384X_PHYSTST    16  /* PH
 
 static void mii_parse_dp8384x_sr2(uint mii_reg, struct net_device *dev)
 {
-	struct fec_enet_private *fep = dev->priv;
+	struct fec_enet_private *fep = netdev_priv(dev);
 	volatile uint *s = &(fep->phy_status);
 
 	*s &= ~(PHY_STAT_SPMASK | PHY_STAT_LINK | PHY_STAT_ANC);
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index d96eb72..65fe9c5 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -470,7 +470,7 @@ retry:
 
 static int ibmveth_open(struct net_device *netdev)
 {
-	struct ibmveth_adapter *adapter = netdev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	u64 mac_address = 0;
 	int rxq_entries = 1;
 	unsigned long lpar_rc;
@@ -582,7 +582,7 @@ static int ibmveth_open(struct net_devic
 
 static int ibmveth_close(struct net_device *netdev)
 {
-	struct ibmveth_adapter *adapter = netdev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	long lpar_rc;
 
 	ibmveth_debug_printk("close starting\n");
@@ -651,7 +651,7 @@ #define page_offset(v) ((unsigned long)(
 
 static int ibmveth_start_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
-	struct ibmveth_adapter *adapter = netdev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	union ibmveth_buf_desc desc[IbmVethMaxSendFrags];
 	unsigned long lpar_rc;
 	int nfrags = 0, curfrag;
@@ -769,7 +769,7 @@ out:	spin_lock_irqsave(&adapter->stats_l
 
 static int ibmveth_poll(struct net_device *netdev, int *budget)
 {
-	struct ibmveth_adapter *adapter = netdev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	int max_frames_to_process = netdev->quota;
 	int frames_processed = 0;
 	int more_work = 1;
@@ -846,7 +846,7 @@ static int ibmveth_poll(struct net_devic
 static irqreturn_t ibmveth_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *netdev = dev_instance;
-	struct ibmveth_adapter *adapter = netdev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	unsigned long lpar_rc;
 
 	if(netif_rx_schedule_prep(netdev)) {
@@ -859,13 +859,13 @@ static irqreturn_t ibmveth_interrupt(int
 
 static struct net_device_stats *ibmveth_get_stats(struct net_device *dev)
 {
-	struct ibmveth_adapter *adapter = dev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(dev);
 	return &adapter->stats;
 }
 
 static void ibmveth_set_multicast_list(struct net_device *netdev)
 {
-	struct ibmveth_adapter *adapter = netdev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	unsigned long lpar_rc;
 
 	if((netdev->flags & IFF_PROMISC) || (netdev->mc_count > adapter->mcastFilterSize)) {
@@ -913,7 +913,7 @@ static void ibmveth_set_multicast_list(s
 
 static int ibmveth_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct ibmveth_adapter *adapter = dev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(dev);
 	int new_mtu_oh = new_mtu + IBMVETH_BUFF_OH;
 	int reinit = 0;
 	int i, rc;
@@ -954,7 +954,7 @@ static int ibmveth_change_mtu(struct net
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void ibmveth_poll_controller(struct net_device *dev)
 {
-	ibmveth_replenish_task(dev->priv);
+	ibmveth_replenish_task(netdev_priv(dev));
 	ibmveth_interrupt(dev->irq, dev);
 }
 #endif
@@ -996,7 +996,7 @@ static int __devinit ibmveth_probe(struc
 
 	SET_MODULE_OWNER(netdev);
 
-	adapter = netdev->priv;
+	adapter = netdev_priv(netdev);
 	memset(adapter, 0, sizeof(adapter));
 	dev->dev.driver_data = netdev;
 
@@ -1076,7 +1076,7 @@ #endif
 static int __devexit ibmveth_remove(struct vio_dev *dev)
 {
 	struct net_device *netdev = dev->dev.driver_data;
-	struct ibmveth_adapter *adapter = netdev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	int i;
 
 	for(i = 0; i<IbmVethNumBufferPools; i++)
@@ -1256,7 +1256,7 @@ const char * buf, size_t count)
 						      kobj);
 	struct net_device *netdev =
 	    container_of(kobj->parent, struct device, kobj)->driver_data;
-	struct ibmveth_adapter *adapter = netdev->priv;
+	struct ibmveth_adapter *adapter = netdev_priv(netdev);
 	long value = simple_strtol(buf, NULL, 10);
 	long rc;
 
diff --git a/drivers/net/iseries_veth.c b/drivers/net/iseries_veth.c
index 0433c41..ed0ffe3 100644
--- a/drivers/net/iseries_veth.c
+++ b/drivers/net/iseries_veth.c
@@ -936,7 +936,7 @@ static void veth_release_connection(stru
 
 static int veth_open(struct net_device *dev)
 {
-	struct veth_port *port = (struct veth_port *) dev->priv;
+	struct veth_port *port = netdev_priv(dev);
 
 	memset(&port->stats, 0, sizeof (port->stats));
 	netif_start_queue(dev);
@@ -951,7 +951,7 @@ static int veth_close(struct net_device 
 
 static struct net_device_stats *veth_get_stats(struct net_device *dev)
 {
-	struct veth_port *port = (struct veth_port *) dev->priv;
+	struct veth_port *port = netdev_priv(dev);
 
 	return &port->stats;
 }
@@ -966,7 +966,7 @@ static int veth_change_mtu(struct net_de
 
 static void veth_set_multicast_list(struct net_device *dev)
 {
-	struct veth_port *port = (struct veth_port *) dev->priv;
+	struct veth_port *port = netdev_priv(dev);
 	unsigned long flags;
 
 	write_lock_irqsave(&port->mcast_gate, flags);
@@ -1058,7 +1058,7 @@ static struct net_device * __init veth_p
 		return NULL;
 	}
 
-	port = (struct veth_port *) dev->priv;
+	port = netdev_priv(dev);
 
 	spin_lock_init(&port->queue_lock);
 	rwlock_init(&port->mcast_gate);
@@ -1120,7 +1120,7 @@ static int veth_transmit_to_one(struct s
 				struct net_device *dev)
 {
 	struct veth_lpar_connection *cnx = veth_cnx[rlp];
-	struct veth_port *port = (struct veth_port *) dev->priv;
+	struct veth_port *port = netdev_priv(dev);
 	HvLpEvent_Rc rc;
 	struct veth_msg *msg = NULL;
 	unsigned long flags;
@@ -1183,7 +1183,7 @@ static void veth_transmit_to_many(struct
 					  HvLpIndexMap lpmask,
 					  struct net_device *dev)
 {
-	struct veth_port *port = (struct veth_port *) dev->priv;
+	struct veth_port *port = netdev_priv(dev);
 	int i, success, error;
 
 	success = error = 0;
@@ -1210,7 +1210,7 @@ static void veth_transmit_to_many(struct
 static int veth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	unsigned char *frame = skb->data;
-	struct veth_port *port = (struct veth_port *) dev->priv;
+	struct veth_port *port = netdev_priv(dev);
 	HvLpIndexMap lpmask;
 
 	if (! (frame[0] & 0x01)) {
@@ -1274,7 +1274,7 @@ static void veth_wake_queues(struct veth
 		if (! dev)
 			continue;
 
-		port = (struct veth_port *)dev->priv;
+		port = netdev_priv(dev);
 
 		if (! (port->lpar_map & (1<<cnx->remote_lp)))
 			continue;
@@ -1303,7 +1303,7 @@ static void veth_stop_queues(struct veth
 		if (! dev)
 			continue;
 
-		port = (struct veth_port *)dev->priv;
+		port = netdev_priv(dev);
 
 		/* If this cnx is not on the vlan for this port, continue */
 		if (! (port->lpar_map & (1 << cnx->remote_lp)))
@@ -1525,7 +1525,7 @@ static void veth_receive(struct veth_lpa
 			continue;
 		}
 
-		port = (struct veth_port *)dev->priv;
+		port = netdev_priv(dev);
 		dest = *((u64 *) skb->data) & 0xFFFFFFFFFFFF0000;
 
 		if ((vlan > HVMAXARCHITECTEDVIRTUALLANS) || !port) {
diff --git a/drivers/net/lp486e.c b/drivers/net/lp486e.c
index 5fc18da..673a780 100644
--- a/drivers/net/lp486e.c
+++ b/drivers/net/lp486e.c
@@ -392,7 +392,7 @@ i596_timeout(struct net_device *dev, cha
 	struct i596_private *lp;
 	int boguscnt = ct;
 
-	lp = (struct i596_private *) dev->priv;
+	lp = netdev_priv(dev);
 	while (lp->scb.command) {
 		if (--boguscnt == 0) {
 			printk("%s: %s timed out - stat %4.4x, cmd %4.4x\n",
@@ -413,7 +413,7 @@ init_rx_bufs(struct net_device *dev, int
 	int i;
 	// struct i596_rbd *rbd;
 
-	lp = (struct i596_private *) dev->priv;
+	lp = netdev_priv(dev);
 	lp->scb.pa_rfd = I596_NULL;
 
 	for (i = 0; i < num; i++) {
@@ -470,7 +470,7 @@ remove_rx_bufs(struct net_device *dev) {
 	struct i596_private *lp;
 	struct i596_rfd *rfd;
 
-	lp = (struct i596_private *) dev->priv;
+	lp = netdev_priv(dev);
 	lp->rx_tail->pa_next = I596_NULL;
 
 	do {
@@ -545,7 +545,7 @@ #endif
 
 static int
 i596_scp_setup(struct net_device *dev) {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	int boguscnt;
 
 	/* Setup SCP, ISCP, SCB */
@@ -626,7 +626,7 @@ init_i596(struct net_device *dev) {
 	if (i596_scp_setup(dev))
 		return 1;
 
-	lp = (struct i596_private *) dev->priv;
+	lp = netdev_priv(dev);
 	lp->scb.command = 0;
 
 	memcpy ((void *)lp->i596_config, init_setup, 14);
@@ -709,7 +709,7 @@ #endif
 
 static int
 i596_rx(struct net_device *dev) {
-	struct i596_private *lp = (struct i596_private *) dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	struct i596_rfd *rfd;
 	int frames = 0;
 
@@ -742,7 +742,7 @@ i596_cleanup_cmd(struct net_device *dev)
 	struct i596_private *lp;
 	struct i596_cmd *cmd;
 
-	lp = (struct i596_private *) dev->priv;
+	lp = netdev_priv(dev);
 	while (lp->cmd_head) {
 		cmd = (struct i596_cmd *)lp->cmd_head;
 
@@ -810,7 +810,7 @@ static void i596_reset(struct net_device
 }
 
 static void i596_add_cmd(struct net_device *dev, struct i596_cmd *cmd) {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	unsigned long flags;
 
@@ -869,7 +869,7 @@ static int i596_open(struct net_device *
 }
 
 static int i596_start_xmit (struct sk_buff *skb, struct net_device *dev) {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	struct tx_cmd *tx_cmd;
 	short length;
 
@@ -917,7 +917,7 @@ static int i596_start_xmit (struct sk_bu
 
 static void
 i596_tx_timeout (struct net_device *dev) {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 
 	/* Transmitter timeout, serious problems. */
@@ -975,7 +975,7 @@ static int __init lp486e_probe(struct ne
 		return -EBUSY;
 	}
 
-	lp = (struct i596_private *) dev->priv;
+	lp = netdev_priv(dev);
 	spin_lock_init(&lp->cmd_lock);
 
 	/*
@@ -1156,7 +1156,7 @@ i596_interrupt (int irq, void *dev_insta
 	unsigned short status, ack_cmd = 0;
 	int frames_in = 0;
 
-	lp = (struct i596_private *) dev->priv;
+	lp = netdev_priv(dev);
 
 	/*
 	 * The 82596 examines the command, performs the required action,
@@ -1222,7 +1222,7 @@ #endif
 }
 
 static int i596_close(struct net_device *dev) {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 
 	netif_stop_queue(dev);
 
@@ -1245,7 +1245,7 @@ static int i596_close(struct net_device 
 }
 
 static struct net_device_stats * i596_get_stats(struct net_device *dev) {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 
 	return &lp->stats;
 }
@@ -1255,7 +1255,7 @@ static struct net_device_stats * i596_ge
 */
 
 static void set_multicast_list(struct net_device *dev) {
-	struct i596_private *lp = dev->priv;
+	struct i596_private *lp = netdev_priv(dev);
 	struct i596_cmd *cmd;
 
 	if (i596_debug > 1)
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 1799eee..85fca52 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2709,7 +2709,7 @@ static int mv643xx_get_stats_count(struc
 static void mv643xx_get_ethtool_stats(struct net_device *netdev,
 				struct ethtool_stats *stats, uint64_t *data)
 {
-	struct mv643xx_private *mp = netdev->priv;
+	struct mv643xx_private *mp = netdev_priv(netdev);
 	int i;
 
 	eth_update_mib_counters(mp);
diff --git a/drivers/net/mvme147.c b/drivers/net/mvme147.c
index e246d00..052ce2d 100644
--- a/drivers/net/mvme147.c
+++ b/drivers/net/mvme147.c
@@ -110,7 +110,7 @@ struct net_device * __init mvme147lance_
 		dev->dev_addr[3], dev->dev_addr[4],
 		dev->dev_addr[5]);
 
-	lp = (struct m147lance_private *)dev->priv;
+	lp = netdev_priv(dev);
 	lp->ram = __get_dma_pages(GFP_ATOMIC, 3);	/* 16K */
 	if (!lp->ram)
 	{
@@ -194,7 +194,7 @@ int __init init_module(void)
 
 void __exit cleanup_module(void)
 {
-	struct m147lance_private *lp = dev_mvme147_lance->priv;
+	struct m147lance_private *lp = netdev_priv(dev_mvme147_lance);
 	unregister_netdev(dev_mvme147_lance);
 	free_pages(lp->ram, 3);
 	free_netdev(dev_mvme147_lance);
diff --git a/drivers/net/myri_sbus.c b/drivers/net/myri_sbus.c
index 13444da..4f7919d 100644
--- a/drivers/net/myri_sbus.c
+++ b/drivers/net/myri_sbus.c
@@ -538,7 +538,7 @@ static void myri_rx(struct myri_eth *mp,
 static irqreturn_t myri_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev		= (struct net_device *) dev_id;
-	struct myri_eth *mp		= (struct myri_eth *) dev->priv;
+	struct myri_eth *mp		= netdev_priv(dev);
 	void __iomem *lregs		= mp->lregs;
 	struct myri_channel __iomem *chan = &mp->shmem->channel;
 	unsigned long flags;
@@ -577,14 +577,14 @@ static irqreturn_t myri_interrupt(int ir
 
 static int myri_open(struct net_device *dev)
 {
-	struct myri_eth *mp = (struct myri_eth *) dev->priv;
+	struct myri_eth *mp = netdev_priv(dev);
 
 	return myri_init(mp, in_interrupt());
 }
 
 static int myri_close(struct net_device *dev)
 {
-	struct myri_eth *mp = (struct myri_eth *) dev->priv;
+	struct myri_eth *mp = netdev_priv(dev);
 
 	myri_clean_rings(mp);
 	return 0;
@@ -592,7 +592,7 @@ static int myri_close(struct net_device 
 
 static void myri_tx_timeout(struct net_device *dev)
 {
-	struct myri_eth *mp = (struct myri_eth *) dev->priv;
+	struct myri_eth *mp = netdev_priv(dev);
 
 	printk(KERN_ERR "%s: transmit timed out, resetting\n", dev->name);
 
@@ -603,7 +603,7 @@ static void myri_tx_timeout(struct net_d
 
 static int myri_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct myri_eth *mp = (struct myri_eth *) dev->priv;
+	struct myri_eth *mp = netdev_priv(dev);
 	struct sendq __iomem *sq = mp->sq;
 	struct myri_txd __iomem *txd;
 	unsigned long flags;
@@ -807,7 +807,7 @@ static int myri_change_mtu(struct net_de
 }
 
 static struct net_device_stats *myri_get_stats(struct net_device *dev)
-{ return &(((struct myri_eth *)dev->priv)->enet_stats); }
+{ return &(((struct myri_eth *)netdev_priv(dev))->enet_stats); }
 
 static void myri_set_multicast(struct net_device *dev)
 {
@@ -911,7 +911,7 @@ static int __devinit myri_ether_init(str
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &sdev->ofdev.dev);
 
-	mp = (struct myri_eth *) dev->priv;
+	mp = netdev_priv(dev);
 	spin_lock_init(&mp->irq_lock);
 	mp->myri_sdev = sdev;
 
diff --git a/drivers/net/ne2k-pci.c b/drivers/net/ne2k-pci.c
index f81d939..40039d4 100644
--- a/drivers/net/ne2k-pci.c
+++ b/drivers/net/ne2k-pci.c
@@ -626,7 +626,7 @@ #endif
 static void ne2k_pci_get_drvinfo(struct net_device *dev,
 				 struct ethtool_drvinfo *info)
 {
-	struct ei_device *ei = dev->priv;
+	struct ei_device *ei = netdev_priv(dev);
 	struct pci_dev *pci_dev = (struct pci_dev *) ei->priv;
 
 	strcpy(info->driver, DRV_NAME);
diff --git a/drivers/net/ni5010.c b/drivers/net/ni5010.c
index 22a3b3d..a11e1a1 100644
--- a/drivers/net/ni5010.c
+++ b/drivers/net/ni5010.c
@@ -331,7 +331,7 @@ #endif	/* JUMPERED_INTERRUPTS */
         	outb(0, IE_RBUF);	/* set buffer byte 0 to 0 again */
 	}
         printk("-> bufsize rcv/xmt=%d/%d\n", bufsize_rcv, NI5010_BUFSIZE);
-	memset(dev->priv, 0, sizeof(struct ni5010_local));
+	memset(netdev_priv(dev), 0, sizeof(struct ni5010_local));
 
 	dev->open		= ni5010_open;
 	dev->stop		= ni5010_close;
diff --git a/drivers/net/ni52.c b/drivers/net/ni52.c
index 5e7999d..242ea31 100644
--- a/drivers/net/ni52.c
+++ b/drivers/net/ni52.c
@@ -324,7 +324,7 @@ static int check586(struct net_device *d
  */
 static void alloc586(struct net_device *dev)
 {
-	struct priv *p =	(struct priv *) dev->priv;
+	struct priv *p =	netdev_priv(dev);
 
 	ni_reset586();
 	DELAY(1);
@@ -495,17 +495,17 @@ #else
 	dev->mem_end = dev->mem_start + size; /* set mem_end showed by 'ifconfig' */
 #endif
 
-	memset((char *) dev->priv,0,sizeof(struct priv));
+	memset((char *) netdev_priv(dev),0,sizeof(struct priv));
 
-	((struct priv *) (dev->priv))->memtop = isa_bus_to_virt(dev->mem_start) + size;
-	((struct priv *) (dev->priv))->base =	(unsigned long) isa_bus_to_virt(dev->mem_start) + size - 0x01000000;
+	((struct priv *) (netdev_priv(dev)))->memtop = isa_bus_to_virt(dev->mem_start) + size;
+	((struct priv *) (netdev_priv(dev)))->base =	(unsigned long) isa_bus_to_virt(dev->mem_start) + size - 0x01000000;
 	alloc586(dev);
 
 	/* set number of receive-buffs according to memsize */
 	if(size == 0x2000)
-		((struct priv *) dev->priv)->num_recv_buffs = NUM_RECV_BUFFS_8;
+		((struct priv *)netdev_priv(dev))->num_recv_buffs = NUM_RECV_BUFFS_8;
 	else
-		((struct priv *) dev->priv)->num_recv_buffs = NUM_RECV_BUFFS_16;
+		((struct priv *)netdev_priv(dev))->num_recv_buffs = NUM_RECV_BUFFS_16;
 
 	printk("Memaddr: 0x%lx, Memsize: %d, ",dev->mem_start,size);
 
@@ -558,7 +558,7 @@ static int init586(struct net_device *de
 {
 	void *ptr;
 	int i,result=0;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 	volatile struct configure_cmd_struct	*cfg_cmd;
 	volatile struct iasetup_cmd_struct *ias_cmd;
 	volatile struct tdr_cmd_struct *tdr_cmd;
@@ -794,7 +794,7 @@ static void *alloc_rfa(struct net_device
 	volatile struct rfd_struct *rfd = (struct rfd_struct *)ptr;
 	volatile struct rbd_struct *rbd;
 	int i;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	memset((char *) rfd,0,sizeof(struct rfd_struct)*(p->num_recv_buffs+rfdadd));
 	p->rfd_first = rfd;
@@ -846,7 +846,7 @@ static irqreturn_t ni52_interrupt(int ir
 		printk ("ni5210-interrupt: irq %d for unknown device.\n",irq);
 		return IRQ_NONE;
 	}
-	p = (struct priv *) dev->priv;
+	p = netdev_priv(dev);
 
 	if(debuglevel > 1)
 		printk("I");
@@ -916,7 +916,7 @@ static void ni52_rcv_int(struct net_devi
 	unsigned short totlen;
 	struct sk_buff *skb;
 	struct rbd_struct *rbd;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	if(debuglevel > 0)
 		printk("R");
@@ -1036,7 +1036,7 @@ #endif
 
 static void ni52_rnr_int(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	p->stats.rx_errors++;
 
@@ -1060,7 +1060,7 @@ static void ni52_rnr_int(struct net_devi
 static void ni52_xmt_int(struct net_device *dev)
 {
 	int status;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	if(debuglevel > 0)
 		printk("X");
@@ -1110,7 +1110,7 @@ #endif
 
 static void startrecv586(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	WAIT_4_SCB_CMD();
 	WAIT_4_SCB_CMD_RUC();
@@ -1122,7 +1122,7 @@ static void startrecv586(struct net_devi
 
 static void ni52_timeout(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 #ifndef NO_NOPCOMMANDS
 	if(p->scb->cus & CU_ACTIVE) /* COMMAND-UNIT active? */
 	{
@@ -1164,7 +1164,7 @@ static int ni52_send_packet(struct sk_bu
 #ifndef NO_NOPCOMMANDS
 	int next_nop;
 #endif
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	if(skb->len > XMIT_BUFF_SIZE)
 	{
@@ -1273,7 +1273,7 @@ #endif
 
 static struct net_device_stats *ni52_get_stats(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 	unsigned short crc,aln,rsc,ovrn;
 
 	crc = p->scb->crc_errs; /* get error-statistic from the ni82586 */
diff --git a/drivers/net/pci-skeleton.c b/drivers/net/pci-skeleton.c
index 3cdbe11..ef1902f 100644
--- a/drivers/net/pci-skeleton.c
+++ b/drivers/net/pci-skeleton.c
@@ -606,7 +606,7 @@ static int __devinit netdrv_init_board (
 	}
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
-	tp = dev->priv;
+	tp = netdev_priv(dev);
 
 	/* enable device (incl. PCI PM wakeup), and bus-mastering */
 	rc = pci_enable_device (pdev);
@@ -761,7 +761,7 @@ #endif
 		return i;
 	}
 
-	tp = dev->priv;
+	tp = netdev_priv(dev);
 
 	assert (ioaddr != NULL);
 	assert (dev != NULL);
@@ -786,7 +786,7 @@ #endif
 	dev->base_addr = (unsigned long) ioaddr;
 
 	/* dev->priv/tp zeroed and aligned in alloc_etherdev */
-	tp = dev->priv;
+	tp = netdev_priv(dev);
 
 	/* note: tp->chipset set in netdrv_init_board */
 	tp->drv_flags = PCI_COMMAND_IO | PCI_COMMAND_MEMORY |
@@ -848,7 +848,7 @@ static void __devexit netdrv_remove_one 
 
 	assert (dev != NULL);
 
-	np = dev->priv;
+	np = netdev_priv(dev);
 	assert (np != NULL);
 
 	unregister_netdev (dev);
@@ -981,7 +981,7 @@ static void mdio_sync (void *mdio_addr)
 
 static int mdio_read (struct net_device *dev, int phy_id, int location)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	void *mdio_addr = tp->mmio_addr + Config4;
 	int mii_cmd = (0xf6 << 10) | (phy_id << 5) | location;
 	int retval = 0;
@@ -1024,7 +1024,7 @@ static int mdio_read (struct net_device 
 static void mdio_write (struct net_device *dev, int phy_id, int location,
 			int value)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	void *mdio_addr = tp->mmio_addr + Config4;
 	int mii_cmd =
 	    (0x5002 << 16) | (phy_id << 23) | (location << 18) | value;
@@ -1067,7 +1067,7 @@ static void mdio_write (struct net_devic
 
 static int netdrv_open (struct net_device *dev)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	int retval;
 #ifdef NETDRV_DEBUG
 	void *ioaddr = tp->mmio_addr;
@@ -1128,7 +1128,7 @@ #endif
 /* Start the hardware at open or resume. */
 static void netdrv_hw_start (struct net_device *dev)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	u32 i;
 
@@ -1198,7 +1198,7 @@ static void netdrv_hw_start (struct net_
 /* Initialize the Rx and Tx rings, along with various 'dev' bits. */
 static void netdrv_init_ring (struct net_device *dev)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	int i;
 
 	DPRINTK ("ENTER\n");
@@ -1220,7 +1220,7 @@ static void netdrv_init_ring (struct net
 static void netdrv_timer (unsigned long data)
 {
 	struct net_device *dev = (struct net_device *) data;
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	int next_tick = 60 * HZ;
 	int mii_lpa;
@@ -1285,7 +1285,7 @@ static void netdrv_tx_clear (struct netd
 
 static void netdrv_tx_timeout (struct net_device *dev)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	int i;
 	u8 tmp8;
@@ -1332,7 +1332,7 @@ static void netdrv_tx_timeout (struct ne
 
 static int netdrv_start_xmit (struct sk_buff *skb, struct net_device *dev)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	int entry;
 
@@ -1655,7 +1655,7 @@ static void netdrv_weird_interrupt (stru
 static irqreturn_t netdrv_interrupt (int irq, void *dev_instance)
 {
 	struct net_device *dev = (struct net_device *) dev_instance;
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	int boguscnt = max_interrupt_work;
 	void *ioaddr = tp->mmio_addr;
 	int status = 0, link_changed = 0; /* avoid bogus "uninit" warning */
@@ -1718,7 +1718,7 @@ static irqreturn_t netdrv_interrupt (int
 
 static int netdrv_close (struct net_device *dev)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	unsigned long flags;
 
@@ -1769,7 +1769,7 @@ static int netdrv_close (struct net_devi
 
 static int netdrv_ioctl (struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	struct mii_ioctl_data *data = if_mii(rq);
 	unsigned long flags;
 	int rc = 0;
@@ -1810,7 +1810,7 @@ static int netdrv_ioctl (struct net_devi
 
 static struct net_device_stats *netdrv_get_stats (struct net_device *dev)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 
 	DPRINTK ("ENTER\n");
@@ -1837,7 +1837,7 @@ static struct net_device_stats *netdrv_g
 
 static void netdrv_set_rx_mode (struct net_device *dev)
 {
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	u32 mc_filter[2];	/* Multicast hash filter */
 	int i, rx_mode;
@@ -1894,7 +1894,7 @@ #ifdef CONFIG_PM
 static int netdrv_suspend (struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
 	unsigned long flags;
 
@@ -1924,7 +1924,7 @@ static int netdrv_suspend (struct pci_de
 static int netdrv_resume (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
-	struct netdrv_private *tp = dev->priv;
+	struct netdrv_private *tp = netdev_priv(dev);
 
 	if (!netif_running(dev))
 		return 0;
diff --git a/drivers/net/plip.c b/drivers/net/plip.c
index 8754cf3..6a8968c 100644
--- a/drivers/net/plip.c
+++ b/drivers/net/plip.c
@@ -236,7 +236,7 @@ static inline void enable_parport_interr
 	if (dev->irq != -1)
 	{
 		struct parport *port =
-		   ((struct net_local *)dev->priv)->pardev->port;
+		   ((struct net_local *)netdev_priv(dev))->pardev->port;
 		port->ops->enable_irq (port);
 	}
 }
@@ -246,7 +246,7 @@ static inline void disable_parport_inter
 	if (dev->irq != -1)
 	{
 		struct parport *port =
-		   ((struct net_local *)dev->priv)->pardev->port;
+		   ((struct net_local *)netdev_priv(dev))->pardev->port;
 		port->ops->disable_irq (port);
 	}
 }
@@ -254,7 +254,7 @@ static inline void disable_parport_inter
 static inline void write_data (struct net_device *dev, unsigned char data)
 {
 	struct parport *port =
-	   ((struct net_local *)dev->priv)->pardev->port;
+	   ((struct net_local *)netdev_priv(dev))->pardev->port;
 
 	port->ops->write_data (port, data);
 }
@@ -262,7 +262,7 @@ static inline void write_data (struct ne
 static inline unsigned char read_status (struct net_device *dev)
 {
 	struct parport *port =
-	   ((struct net_local *)dev->priv)->pardev->port;
+	   ((struct net_local *)netdev_priv(dev))->pardev->port;
 
 	return port->ops->read_status (port);
 }
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 69da95b..b152f23 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -3753,7 +3753,7 @@ static int ql3xxx_open(struct net_device
 
 static struct net_device_stats *ql3xxx_get_stats(struct net_device *dev)
 {
-	struct ql3_adapter *qdev = (struct ql3_adapter *)dev->priv;
+	struct ql3_adapter *qdev = netdev_priv(dev);
 	return &qdev->stats;
 }
 
diff --git a/drivers/net/rionet.c b/drivers/net/rionet.c
index df6b738..1a4a37c 100644
--- a/drivers/net/rionet.c
+++ b/drivers/net/rionet.c
@@ -93,7 +93,7 @@ #define RIONET_GET_DESTID(x)	(*(u16 *)(x
 
 static struct net_device_stats *rionet_stats(struct net_device *ndev)
 {
-	struct rionet_private *rnet = ndev->priv;
+	struct rionet_private *rnet = netdev_priv(ndev);
 	return &rnet->stats;
 }
 
@@ -101,7 +101,7 @@ static int rionet_rx_clean(struct net_de
 {
 	int i;
 	int error = 0;
-	struct rionet_private *rnet = ndev->priv;
+	struct rionet_private *rnet = netdev_priv(ndev);
 	void *data;
 
 	i = rnet->rx_slot;
@@ -139,7 +139,7 @@ static int rionet_rx_clean(struct net_de
 static void rionet_rx_fill(struct net_device *ndev, int end)
 {
 	int i;
-	struct rionet_private *rnet = ndev->priv;
+	struct rionet_private *rnet = netdev_priv(ndev);
 
 	i = rnet->rx_slot;
 	do {
@@ -158,7 +158,7 @@ static void rionet_rx_fill(struct net_de
 static int rionet_queue_tx_msg(struct sk_buff *skb, struct net_device *ndev,
 			       struct rio_dev *rdev)
 {
-	struct rionet_private *rnet = ndev->priv;
+	struct rionet_private *rnet = netdev_priv(ndev);
 
 	rio_add_outb_message(rnet->mport, rdev, 0, skb->data, skb->len);
 	rnet->tx_skb[rnet->tx_slot] = skb;
@@ -182,7 +182,7 @@ static int rionet_queue_tx_msg(struct sk
 static int rionet_start_xmit(struct sk_buff *skb, struct net_device *ndev)
 {
 	int i;
-	struct rionet_private *rnet = ndev->priv;
+	struct rionet_private *rnet = netdev_priv(ndev);
 	struct ethhdr *eth = (struct ethhdr *)skb->data;
 	u16 destid;
 	unsigned long flags;
@@ -221,7 +221,7 @@ static void rionet_dbell_event(struct ri
 			       u16 info)
 {
 	struct net_device *ndev = dev_id;
-	struct rionet_private *rnet = ndev->priv;
+	struct rionet_private *rnet = netdev_priv(ndev);
 	struct rionet_peer *peer;
 
 	if (netif_msg_intr(rnet))
@@ -249,7 +249,7 @@ static void rionet_inb_msg_event(struct 
 {
 	int n;
 	struct net_device *ndev = dev_id;
-	struct rionet_private *rnet = (struct rionet_private *)ndev->priv;
+	struct rionet_private *rnet = netdev_priv(ndev);
 
 	if (netif_msg_intr(rnet))
 		printk(KERN_INFO "%s: inbound message event, mbox %d slot %d\n",
@@ -264,7 +264,7 @@ static void rionet_inb_msg_event(struct 
 static void rionet_outb_msg_event(struct rio_mport *mport, void *dev_id, int mbox, int slot)
 {
 	struct net_device *ndev = dev_id;
-	struct rionet_private *rnet = ndev->priv;
+	struct rionet_private *rnet = netdev_priv(ndev);
 
 	spin_lock(&rnet->lock);
 
@@ -293,7 +293,7 @@ static int rionet_open(struct net_device
 	int i, rc = 0;
 	struct rionet_peer *peer, *tmp;
 	u32 pwdcsr;
-	struct rionet_private *rnet = ndev->priv;
+	struct rionet_private *rnet = netdev_priv(ndev);
 
 	if (netif_msg_ifup(rnet))
 		printk(KERN_INFO "%s: open\n", DRV_NAME);
@@ -357,7 +357,7 @@ static int rionet_open(struct net_device
 
 static int rionet_close(struct net_device *ndev)
 {
-	struct rionet_private *rnet = (struct rionet_private *)ndev->priv;
+	struct rionet_private *rnet = netdev_priv(ndev);
 	struct rionet_peer *peer, *tmp;
 	int i;
 
@@ -404,7 +404,7 @@ static void rionet_remove(struct rio_dev
 static void rionet_get_drvinfo(struct net_device *ndev,
 			       struct ethtool_drvinfo *info)
 {
-	struct rionet_private *rnet = ndev->priv;
+	struct rionet_private *rnet = netdev_priv(ndev);
 
 	strcpy(info->driver, DRV_NAME);
 	strcpy(info->version, DRV_VERSION);
@@ -414,14 +414,14 @@ static void rionet_get_drvinfo(struct ne
 
 static u32 rionet_get_msglevel(struct net_device *ndev)
 {
-	struct rionet_private *rnet = ndev->priv;
+	struct rionet_private *rnet = netdev_priv(ndev);
 
 	return rnet->msg_enable;
 }
 
 static void rionet_set_msglevel(struct net_device *ndev, u32 value)
 {
-	struct rionet_private *rnet = ndev->priv;
+	struct rionet_private *rnet = netdev_priv(ndev);
 
 	rnet->msg_enable = value;
 }
@@ -450,7 +450,7 @@ static int rionet_setup_netdev(struct ri
 	}
 
 	/* Set up private area */
-	rnet = (struct rionet_private *)ndev->priv;
+	rnet = netdev_priv(ndev);
 	rnet->mport = mport;
 
 	/* Set the default MAC address */
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index 2be0a0f..7743bd2 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -330,7 +330,7 @@ #define S2IO_TIMER_CONF(timer, handle, a
 static void s2io_vlan_rx_register(struct net_device *dev,
 					struct vlan_group *grp)
 {
-	struct s2io_nic *nic = dev->priv;
+	struct s2io_nic *nic = netdev_priv(dev);
 	unsigned long flags;
 
 	spin_lock_irqsave(&nic->tx_lock, flags);
@@ -2581,7 +2581,7 @@ static void free_rx_buffers(struct s2io_
 
 static int s2io_poll(struct net_device *dev, int *budget)
 {
-	struct s2io_nic *nic = dev->priv;
+	struct s2io_nic *nic = netdev_priv(dev);
 	int pkt_cnt = 0, org_pkts_to_process;
 	struct mac_info *mac_control;
 	struct config_param *config;
@@ -2655,7 +2655,7 @@ #ifdef CONFIG_NET_POLL_CONTROLLER
  */
 static void s2io_netpoll(struct net_device *dev)
 {
-	struct s2io_nic *nic = dev->priv;
+	struct s2io_nic *nic = netdev_priv(dev);
 	struct mac_info *mac_control;
 	struct config_param *config;
 	struct XENA_dev_config __iomem *bar0 = nic->bar0;
@@ -2926,7 +2926,7 @@ static void tx_intr_handler(struct fifo_
 static void s2io_mdio_write(u32 mmd_type, u64 addr, u16 value, struct net_device *dev)
 {
 	u64 val64 = 0x0;
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 
 	//address transaction
@@ -2975,7 +2975,7 @@ static u64 s2io_mdio_read(u32 mmd_type, 
 {
 	u64 val64 = 0x0;
 	u64 rval64 = 0x0;
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 
 	/* address transaction */
@@ -3079,7 +3079,7 @@ static void s2io_updt_xpak_counter(struc
 	u64 val64 = 0x0;
 	u64 addr  = 0x0;
 
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	struct stat_block *stat_info = sp->mac_control.stats_info;
 
 	/* Check the communication with the MDIO slave */
@@ -3799,7 +3799,7 @@ static int s2io_enable_msi_x(struct s2io
 
 static int s2io_open(struct net_device *dev)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	int err = 0;
 
 	/*
@@ -3858,7 +3858,7 @@ hw_init_failed:
 
 static int s2io_close(struct net_device *dev)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 
 	netif_stop_queue(dev);
 	/* Reset card, kill tasklet and free Tx and Rx buffers. */
@@ -3882,7 +3882,7 @@ static int s2io_close(struct net_device 
 
 static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	u16 frg_cnt, frg_len, i, queue, queue_len, put_off, get_off;
 	register u64 val64;
 	struct TxD *txdp;
@@ -4194,7 +4194,7 @@ static void s2io_txpic_intr_handle(struc
 static irqreturn_t s2io_isr(int irq, void *dev_id)
 {
 	struct net_device *dev = (struct net_device *) dev_id;
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 	int i;
 	u64 reason = 0;
@@ -4323,7 +4323,7 @@ static void s2io_updt_stats(struct s2io_
 
 static struct net_device_stats *s2io_get_stats(struct net_device *dev)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	struct mac_info *mac_control;
 	struct config_param *config;
 
@@ -4365,7 +4365,7 @@ static void s2io_set_multicast(struct ne
 {
 	int i, j, prev_cnt;
 	struct dev_mc_list *mclist;
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 	u64 val64 = 0, multi_mac = 0x010203040506ULL, mask =
 	    0xfeffffffffffULL;
@@ -4537,7 +4537,7 @@ static void s2io_set_multicast(struct ne
 
 static int s2io_set_mac_addr(struct net_device *dev, u8 * addr)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 	register u64 val64, mac_addr = 0;
 	int i;
@@ -4601,7 +4601,7 @@ static int s2io_set_mac_addr(struct net_
 static int s2io_ethtool_sset(struct net_device *dev,
 			     struct ethtool_cmd *info)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	if ((info->autoneg == AUTONEG_ENABLE) ||
 	    (info->speed != SPEED_10000) || (info->duplex != DUPLEX_FULL))
 		return -EINVAL;
@@ -4627,7 +4627,7 @@ static int s2io_ethtool_sset(struct net_
 
 static int s2io_ethtool_gset(struct net_device *dev, struct ethtool_cmd *info)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	info->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
 	info->advertising = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
 	info->port = PORT_FIBRE;
@@ -4660,7 +4660,7 @@ static int s2io_ethtool_gset(struct net_
 static void s2io_ethtool_gdrvinfo(struct net_device *dev,
 				  struct ethtool_drvinfo *info)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 
 	strncpy(info->driver, s2io_driver_name, sizeof(info->driver));
 	strncpy(info->version, s2io_driver_version, sizeof(info->version));
@@ -4696,7 +4696,7 @@ static void s2io_ethtool_gregs(struct ne
 	int i;
 	u64 reg;
 	u8 *reg_space = (u8 *) space;
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 
 	regs->len = XENA_REG_SPACE;
 	regs->version = sp->pdev->subsystem_device;
@@ -4756,7 +4756,7 @@ static void s2io_phy_id(unsigned long da
 static int s2io_ethtool_idnic(struct net_device *dev, u32 data)
 {
 	u64 val64 = 0, last_gpio_ctrl_val;
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 	u16 subid;
 
@@ -4794,7 +4794,7 @@ static int s2io_ethtool_idnic(struct net
 static void s2io_ethtool_gringparam(struct net_device *dev,
                                     struct ethtool_ringparam *ering)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	int i,tx_desc_count=0,rx_desc_count=0;
 
 	if (sp->rxd_mode == RXD_MODE_1)
@@ -4837,7 +4837,7 @@ static void s2io_ethtool_getpause_data(s
 				       struct ethtool_pauseparam *ep)
 {
 	u64 val64;
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 
 	val64 = readq(&bar0->rmac_pause_cfg);
@@ -4864,7 +4864,7 @@ static int s2io_ethtool_setpause_data(st
 			       struct ethtool_pauseparam *ep)
 {
 	u64 val64;
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	struct XENA_dev_config __iomem *bar0 = sp->bar0;
 
 	val64 = readq(&bar0->rmac_pause_cfg);
@@ -5094,7 +5094,7 @@ static int s2io_ethtool_geeprom(struct n
 {
 	u32 i, valid;
 	u64 data;
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 
 	eeprom->magic = sp->pdev->vendor | (sp->pdev->device << 16);
 
@@ -5132,7 +5132,7 @@ static int s2io_ethtool_seeprom(struct n
 {
 	int len = eeprom->len, cnt = 0;
 	u64 valid = 0, data;
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 
 	if (eeprom->magic != (sp->pdev->vendor | (sp->pdev->device << 16))) {
 		DBG_PRINT(ERR_DBG,
@@ -5512,7 +5512,7 @@ static void s2io_ethtool_test(struct net
 			      struct ethtool_test *ethtest,
 			      uint64_t * data)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	int orig_state = netif_running(sp->dev);
 
 	if (ethtest->flags == ETH_TEST_FL_OFFLINE) {
@@ -5568,7 +5568,7 @@ static void s2io_get_ethtool_stats(struc
 				   u64 * tmp_stats)
 {
 	int i = 0;
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	struct stat_block *stat_info = sp->mac_control.stats_info;
 
 	s2io_updt_stats(sp);
@@ -5829,14 +5829,14 @@ static int s2io_ethtool_get_regs_len(str
 
 static u32 s2io_ethtool_get_rx_csum(struct net_device * dev)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 
 	return (sp->rx_csum);
 }
 
 static int s2io_ethtool_set_rx_csum(struct net_device *dev, u32 data)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 
 	if (data)
 		sp->rx_csum = 1;
@@ -5860,7 +5860,7 @@ static void s2io_ethtool_get_strings(str
 				     u32 stringset, u8 * data)
 {
 	int stat_size = 0;
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 
 	switch (stringset) {
 	case ETH_SS_TEST:
@@ -5882,7 +5882,7 @@ static void s2io_ethtool_get_strings(str
 }
 static int s2io_ethtool_get_stats_count(struct net_device *dev)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	int stat_count = 0;
 	switch(sp->device_type) {
 	case XFRAME_I_DEVICE:
@@ -5982,7 +5982,7 @@ static int s2io_ioctl(struct net_device 
 
 static int s2io_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 
 	if ((new_mtu < MIN_MTU) || (new_mtu > S2IO_JUMBO_SIZE)) {
 		DBG_PRINT(ERR_DBG, "%s: MTU size is invalid.\n",
@@ -6026,7 +6026,7 @@ static int s2io_change_mtu(struct net_de
 static void s2io_tasklet(unsigned long dev_addr)
 {
 	struct net_device *dev = (struct net_device *) dev_addr;
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 	int i, ret;
 	struct mac_info *mac_control;
 	struct config_param *config;
@@ -6621,7 +6621,7 @@ out_unlock:
 
 static void s2io_tx_watchdog(struct net_device *dev)
 {
-	struct s2io_nic *sp = dev->priv;
+	struct s2io_nic *sp = netdev_priv(dev);
 
 	if (netif_carrier_ok(dev)) {
 		sp->mac_control.stats_info->sw_stat.watchdog_timer_cnt++;
@@ -7077,7 +7077,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	/*  Private member variable initialized to s2io NIC structure */
-	sp = dev->priv;
+	sp = netdev_priv(dev);
 	memset(sp, 0, sizeof(struct s2io_nic));
 	sp->dev = dev;
 	sp->pdev = pdev;
@@ -7438,7 +7438,7 @@ static void __devexit s2io_rem_nic(struc
 
 	flush_scheduled_work();
 
-	sp = dev->priv;
+	sp = netdev_priv(dev);
 	unregister_netdev(dev);
 
 	free_shared_mem(sp);
@@ -7806,7 +7806,7 @@ static pci_ers_result_t s2io_io_error_de
                                                pci_channel_state_t state)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct s2io_nic *sp = netdev->priv;
+	struct s2io_nic *sp = netdev_priv(netdev);
 
 	netif_device_detach(netdev);
 
@@ -7831,7 +7831,7 @@ static pci_ers_result_t s2io_io_error_de
 static pci_ers_result_t s2io_io_slot_reset(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct s2io_nic *sp = netdev->priv;
+	struct s2io_nic *sp = netdev_priv(netdev);
 
 	if (pci_enable_device(pdev)) {
 		printk(KERN_ERR "s2io: "
@@ -7855,7 +7855,7 @@ static pci_ers_result_t s2io_io_slot_res
 static void s2io_io_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
-	struct s2io_nic *sp = netdev->priv;
+	struct s2io_nic *sp = netdev_priv(netdev);
 
 	if (netif_running(netdev)) {
 		if (s2io_card_up(sp)) {
diff --git a/drivers/net/sgiseeq.c b/drivers/net/sgiseeq.c
index 384b468..d69b2d7 100644
--- a/drivers/net/sgiseeq.c
+++ b/drivers/net/sgiseeq.c
@@ -577,7 +577,7 @@ static struct net_device_stats *sgiseeq_
 
 static void sgiseeq_set_multicast(struct net_device *dev)
 {
-	struct sgiseeq_private *sp = (struct sgiseeq_private *) dev->priv;
+	struct sgiseeq_private *sp = netdev_priv(dev);
 	unsigned char oldmode = sp->mode;
 
 	if(dev->flags & IFF_PROMISC)
diff --git a/drivers/net/shaper.c b/drivers/net/shaper.c
index 4c3d98f..14bdba0 100644
--- a/drivers/net/shaper.c
+++ b/drivers/net/shaper.c
@@ -133,7 +133,7 @@ static void shaper_setspeed(struct shape
 
 static int shaper_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct shaper *shaper = dev->priv;
+	struct shaper *shaper = netdev_priv(dev);
  	struct sk_buff *ptr;
 
 	spin_lock(&shaper->lock);
@@ -288,7 +288,7 @@ static void shaper_kick(struct shaper *s
 
 static int shaper_open(struct net_device *dev)
 {
-	struct shaper *shaper=dev->priv;
+	struct shaper *shaper=netdev_priv(dev);
 
 	/*
 	 *	Can't open until attached.
@@ -309,7 +309,7 @@ static int shaper_open(struct net_device
 
 static int shaper_close(struct net_device *dev)
 {
-	struct shaper *shaper=dev->priv;
+	struct shaper *shaper=netdev_priv(dev);
 	struct sk_buff *skb;
 
 	while ((skb = skb_dequeue(&shaper->sendq)) != NULL)
@@ -331,14 +331,14 @@ static int shaper_close(struct net_devic
 
 static struct net_device_stats *shaper_get_stats(struct net_device *dev)
 {
-     	struct shaper *sh=dev->priv;
+     	struct shaper *sh=netdev_priv(dev);
 	return &sh->stats;
 }
 
 static int shaper_header(struct sk_buff *skb, struct net_device *dev,
 	unsigned short type, void *daddr, void *saddr, unsigned len)
 {
-	struct shaper *sh=dev->priv;
+	struct shaper *sh=netdev_priv(dev);
 	int v;
 	if(sh_debug)
 		printk("Shaper header\n");
@@ -476,7 +476,7 @@ #endif
 static int shaper_ioctl(struct net_device *dev,  struct ifreq *ifr, int cmd)
 {
 	struct shaperconf *ss= (struct shaperconf *)&ifr->ifr_ifru;
-	struct shaper *sh=dev->priv;
+	struct shaper *sh=netdev_priv(dev);
 
 	if(ss->ss_cmd == SHAPER_SET_DEV || ss->ss_cmd == SHAPER_SET_SPEED)
 	{
@@ -493,7 +493,7 @@ static int shaper_ioctl(struct net_devic
 				return -ENODEV;
 			if(sh->dev)
 				return -EBUSY;
-			return shaper_attach(dev,dev->priv, them);
+			return shaper_attach(dev,netdev_priv(dev), them);
 		}
 		case SHAPER_GET_DEV:
 			if(sh->dev==NULL)
@@ -513,7 +513,7 @@ static int shaper_ioctl(struct net_devic
 
 static void shaper_init_priv(struct net_device *dev)
 {
-	struct shaper *sh = dev->priv;
+	struct shaper *sh = netdev_priv(dev);
 
 	skb_queue_head_init(&sh->sendq);
 	init_timer(&sh->timer);
diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index 7c6e480..36162d5 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -439,7 +439,7 @@ #endif
 	if (ret)
 		goto err_out;
 
-	sis_priv = net_dev->priv;
+	sis_priv = netdev_priv(net_dev);
 	net_dev->base_addr = ioaddr;
 	net_dev->irq = pci_dev->irq;
 	sis_priv->pci_dev = pci_dev;
@@ -575,7 +575,7 @@ #endif
 
 static int __devinit sis900_mii_probe(struct net_device * net_dev)
 {
-	struct sis900_private * sis_priv = net_dev->priv;
+	struct sis900_private * sis_priv = netdev_priv(net_dev);
 	const char *dev_name = pci_name(sis_priv->pci_dev);
 	u16 poll_bit = MII_STAT_LINK, status = 0;
 	unsigned long timeout = jiffies + 5 * HZ;
@@ -703,7 +703,7 @@ static int __devinit sis900_mii_probe(st
 
 static u16 sis900_default_phy(struct net_device * net_dev)
 {
-	struct sis900_private * sis_priv = net_dev->priv;
+	struct sis900_private * sis_priv = netdev_priv(net_dev);
  	struct mii_phy *phy = NULL, *phy_home = NULL,
 		*default_phy = NULL, *phy_lan = NULL;
 	u16 status;
@@ -1004,7 +1004,7 @@ #endif
 static int
 sis900_open(struct net_device *net_dev)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	long ioaddr = net_dev->base_addr;
 	int ret;
 
@@ -1060,7 +1060,7 @@ sis900_open(struct net_device *net_dev)
 static void
 sis900_init_rxfilter (struct net_device * net_dev)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	long ioaddr = net_dev->base_addr;
 	u32 rfcrSave;
 	u32 i;
@@ -1098,7 +1098,7 @@ sis900_init_rxfilter (struct net_device 
 static void
 sis900_init_tx_ring(struct net_device *net_dev)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	long ioaddr = net_dev->base_addr;
 	int i;
 
@@ -1132,7 +1132,7 @@ sis900_init_tx_ring(struct net_device *n
 static void
 sis900_init_rx_ring(struct net_device *net_dev)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	long ioaddr = net_dev->base_addr;
 	int i;
 
@@ -1203,7 +1203,7 @@ sis900_init_rx_ring(struct net_device *n
 
 static void sis630_set_eq(struct net_device *net_dev, u8 revision)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	u16 reg14h, eq_value=0, max_value=0, min_value=0;
 	int i, maxcount=10;
 
@@ -1276,7 +1276,7 @@ static void sis630_set_eq(struct net_dev
 static void sis900_timer(unsigned long data)
 {
 	struct net_device *net_dev = (struct net_device *)data;
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	struct mii_phy *mii_phy = sis_priv->mii;
 	static const int next_tick = 5*HZ;
 	u16 status;
@@ -1346,7 +1346,7 @@ static void sis900_timer(unsigned long d
 
 static void sis900_check_mode(struct net_device *net_dev, struct mii_phy *mii_phy)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	long ioaddr = net_dev->base_addr;
 	int speed, duplex;
 
@@ -1425,7 +1425,7 @@ #endif
 
 static void sis900_auto_negotiate(struct net_device *net_dev, int phy_addr)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	int i = 0;
 	u32 status;
 
@@ -1460,7 +1460,7 @@ static void sis900_auto_negotiate(struct
 
 static void sis900_read_mode(struct net_device *net_dev, int *speed, int *duplex)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	struct mii_phy *phy = sis_priv->mii;
 	int phy_addr = sis_priv->cur_phy;
 	u32 status;
@@ -1515,7 +1515,7 @@ static void sis900_read_mode(struct net_
 
 static void sis900_tx_timeout(struct net_device *net_dev)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	long ioaddr = net_dev->base_addr;
 	unsigned long flags;
 	int i;
@@ -1574,7 +1574,7 @@ static void sis900_tx_timeout(struct net
 static int
 sis900_start_xmit(struct sk_buff *skb, struct net_device *net_dev)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	long ioaddr = net_dev->base_addr;
 	unsigned int  entry;
 	unsigned long flags;
@@ -1644,7 +1644,7 @@ sis900_start_xmit(struct sk_buff *skb, s
 static irqreturn_t sis900_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *net_dev = dev_instance;
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	int boguscnt = max_interrupt_work;
 	long ioaddr = net_dev->base_addr;
 	u32 status;
@@ -1706,7 +1706,7 @@ static irqreturn_t sis900_interrupt(int 
 
 static int sis900_rx(struct net_device *net_dev)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	long ioaddr = net_dev->base_addr;
 	unsigned int entry = sis_priv->cur_rx % NUM_RX_DESC;
 	u32 rx_status = sis_priv->rx_ring[entry].cmdsts;
@@ -1856,7 +1856,7 @@ refill_rx_ring:
 
 static void sis900_finish_xmit (struct net_device *net_dev)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 
 	for (; sis_priv->dirty_tx != sis_priv->cur_tx; sis_priv->dirty_tx++) {
 		struct sk_buff *skb;
@@ -1925,7 +1925,7 @@ static void sis900_finish_xmit (struct n
 static int sis900_close(struct net_device *net_dev)
 {
 	long ioaddr = net_dev->base_addr;
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	struct sk_buff *skb;
 	int i;
 
@@ -1980,7 +1980,7 @@ static int sis900_close(struct net_devic
 static void sis900_get_drvinfo(struct net_device *net_dev,
 			       struct ethtool_drvinfo *info)
 {
- 	struct sis900_private *sis_priv = net_dev->priv;
+ 	struct sis900_private *sis_priv = netdev_priv(net_dev);
 
 	strcpy (info->driver, SIS900_MODULE_NAME);
 	strcpy (info->version, SIS900_DRV_VERSION);
@@ -1989,26 +1989,26 @@ static void sis900_get_drvinfo(struct ne
 
 static u32 sis900_get_msglevel(struct net_device *net_dev)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	return sis_priv->msg_enable;
 }
 
 static void sis900_set_msglevel(struct net_device *net_dev, u32 value)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	sis_priv->msg_enable = value;
 }
 
 static u32 sis900_get_link(struct net_device *net_dev)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	return mii_link_ok(&sis_priv->mii_info);
 }
 
 static int sis900_get_settings(struct net_device *net_dev,
 				struct ethtool_cmd *cmd)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	spin_lock_irq(&sis_priv->lock);
 	mii_ethtool_gset(&sis_priv->mii_info, cmd);
 	spin_unlock_irq(&sis_priv->lock);
@@ -2018,7 +2018,7 @@ static int sis900_get_settings(struct ne
 static int sis900_set_settings(struct net_device *net_dev,
 				struct ethtool_cmd *cmd)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	int rt;
 	spin_lock_irq(&sis_priv->lock);
 	rt = mii_ethtool_sset(&sis_priv->mii_info, cmd);
@@ -2028,7 +2028,7 @@ static int sis900_set_settings(struct ne
 
 static int sis900_nway_reset(struct net_device *net_dev)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	return mii_nway_restart(&sis_priv->mii_info);
 }
 
@@ -2045,7 +2045,7 @@ static int sis900_nway_reset(struct net_
 
 static int sis900_set_wol(struct net_device *net_dev, struct ethtool_wolinfo *wol)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	long pmctrl_addr = net_dev->base_addr + pmctrl;
 	u32 cfgpmcsr = 0, pmctrl_bits = 0;
 
@@ -2116,7 +2116,7 @@ static const struct ethtool_ops sis900_e
 
 static int mii_ioctl(struct net_device *net_dev, struct ifreq *rq, int cmd)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	struct mii_ioctl_data *data = if_mii(rq);
 
 	switch(cmd) {
@@ -2148,7 +2148,7 @@ static int mii_ioctl(struct net_device *
 static struct net_device_stats *
 sis900_get_stats(struct net_device *net_dev)
 {
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 
 	return &sis_priv->stats;
 }
@@ -2165,7 +2165,7 @@ sis900_get_stats(struct net_device *net_
 
 static int sis900_set_config(struct net_device *dev, struct ifmap *map)
 {
-	struct sis900_private *sis_priv = dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(dev);
 	struct mii_phy *mii_phy = sis_priv->mii;
 
 	u16 status;
@@ -2288,7 +2288,7 @@ static inline u16 sis900_mcast_bitnr(u8 
 static void set_rx_mode(struct net_device *net_dev)
 {
 	long ioaddr = net_dev->base_addr;
-	struct sis900_private * sis_priv = net_dev->priv;
+	struct sis900_private * sis_priv = netdev_priv(net_dev);
 	u16 mc_filter[16] = {0};	/* 256/128 bits multicast hash table */
 	int i, table_entries;
 	u32 rx_mode;
@@ -2363,7 +2363,7 @@ static void set_rx_mode(struct net_devic
 
 static void sis900_reset(struct net_device *net_dev)
 {
-	struct sis900_private * sis_priv = net_dev->priv;
+	struct sis900_private * sis_priv = netdev_priv(net_dev);
 	long ioaddr = net_dev->base_addr;
 	int i = 0;
 	u32 status = TxRCMP | RxRCMP;
@@ -2396,7 +2396,7 @@ static void sis900_reset(struct net_devi
 static void __devexit sis900_remove(struct pci_dev *pci_dev)
 {
 	struct net_device *net_dev = pci_get_drvdata(pci_dev);
-	struct sis900_private * sis_priv = net_dev->priv;
+	struct sis900_private * sis_priv = netdev_priv(net_dev);
 	struct mii_phy *phy = NULL;
 
 	while (sis_priv->first_mii) {
@@ -2440,7 +2440,7 @@ static int sis900_suspend(struct pci_dev
 static int sis900_resume(struct pci_dev *pci_dev)
 {
 	struct net_device *net_dev = pci_get_drvdata(pci_dev);
-	struct sis900_private *sis_priv = net_dev->priv;
+	struct sis900_private *sis_priv = netdev_priv(net_dev);
 	long ioaddr = net_dev->base_addr;
 
 	if(!netif_running(net_dev))
diff --git a/drivers/net/smc9194.c b/drivers/net/smc9194.c
index 36c1eba..af14f24 100644
--- a/drivers/net/smc9194.c
+++ b/drivers/net/smc9194.c
@@ -1052,7 +1052,7 @@ #endif
 	printk("%2.2x \n", dev->dev_addr[5] );
 
 	/* set the private data to zero by default */
-	memset(dev->priv, 0, sizeof(struct smc_local));
+	memset(netdev_priv(dev), 0, sizeof(struct smc_local));
 
 	/* Grab the IRQ */
       	retval = request_irq(dev->irq, &smc_interrupt, 0, DRV_NAME, dev);
@@ -1127,7 +1127,7 @@ static int smc_open(struct net_device *d
 	int	i;	/* used to set hw ethernet address */
 
 	/* clear out all the junk that was put here before... */
-	memset(dev->priv, 0, sizeof(struct smc_local));
+	memset(netdev_priv(dev), 0, sizeof(struct smc_local));
 
 	/* reset the hardware */
 
@@ -1183,7 +1183,7 @@ static void smc_timeout(struct net_devic
 	smc_enable( dev->base_addr );
 	dev->trans_start = jiffies;
 	/* clear anything saved */
-	((struct smc_local *)dev->priv)->saved_skb = NULL;
+	((struct smc_local *)netdev_priv(dev))->saved_skb = NULL;
 	netif_wake_queue(dev);
 }
 
diff --git a/drivers/net/sonic.h b/drivers/net/sonic.h
index 7db13e4..bbc0ddc 100644
--- a/drivers/net/sonic.h
+++ b/drivers/net/sonic.h
@@ -371,7 +371,7 @@ #endif
 static inline void sonic_cda_put(struct net_device* dev, int entry,
 				 int offset, __u16 val)
 {
-	struct sonic_local* lp = (struct sonic_local *) dev->priv;
+	struct sonic_local* lp = netdev_priv(dev);
 	sonic_buf_put(lp->cda, lp->dma_bitmode,
 		      (entry * SIZEOF_SONIC_CD) + offset, val);
 }
@@ -379,27 +379,27 @@ static inline void sonic_cda_put(struct 
 static inline __u16 sonic_cda_get(struct net_device* dev, int entry,
 				  int offset)
 {
-	struct sonic_local* lp = (struct sonic_local *) dev->priv;
+	struct sonic_local* lp = netdev_priv(dev);
 	return sonic_buf_get(lp->cda, lp->dma_bitmode,
 			     (entry * SIZEOF_SONIC_CD) + offset);
 }
 
 static inline void sonic_set_cam_enable(struct net_device* dev, __u16 val)
 {
-	struct sonic_local* lp = (struct sonic_local *) dev->priv;
+	struct sonic_local* lp = netdev_priv(dev);
 	sonic_buf_put(lp->cda, lp->dma_bitmode, SONIC_CDA_CAM_ENABLE, val);
 }
 
 static inline __u16 sonic_get_cam_enable(struct net_device* dev)
 {
-	struct sonic_local* lp = (struct sonic_local *) dev->priv;
+	struct sonic_local* lp = netdev_priv(dev);
 	return sonic_buf_get(lp->cda, lp->dma_bitmode, SONIC_CDA_CAM_ENABLE);
 }
 
 static inline void sonic_tda_put(struct net_device* dev, int entry,
 				 int offset, __u16 val)
 {
-	struct sonic_local* lp = (struct sonic_local *) dev->priv;
+	struct sonic_local* lp = netdev_priv(dev);
 	sonic_buf_put(lp->tda, lp->dma_bitmode,
 		      (entry * SIZEOF_SONIC_TD) + offset, val);
 }
@@ -407,7 +407,7 @@ static inline void sonic_tda_put(struct 
 static inline __u16 sonic_tda_get(struct net_device* dev, int entry,
 				  int offset)
 {
-	struct sonic_local* lp = (struct sonic_local *) dev->priv;
+	struct sonic_local* lp = netdev_priv(dev);
 	return sonic_buf_get(lp->tda, lp->dma_bitmode,
 			     (entry * SIZEOF_SONIC_TD) + offset);
 }
@@ -415,7 +415,7 @@ static inline __u16 sonic_tda_get(struct
 static inline void sonic_rda_put(struct net_device* dev, int entry,
 				 int offset, __u16 val)
 {
-	struct sonic_local* lp = (struct sonic_local *) dev->priv;
+	struct sonic_local* lp = netdev_priv(dev);
 	sonic_buf_put(lp->rda, lp->dma_bitmode,
 		      (entry * SIZEOF_SONIC_RD) + offset, val);
 }
@@ -423,7 +423,7 @@ static inline void sonic_rda_put(struct 
 static inline __u16 sonic_rda_get(struct net_device* dev, int entry,
 				  int offset)
 {
-	struct sonic_local* lp = (struct sonic_local *) dev->priv;
+	struct sonic_local* lp = netdev_priv(dev);
 	return sonic_buf_get(lp->rda, lp->dma_bitmode,
 			     (entry * SIZEOF_SONIC_RD) + offset);
 }
@@ -431,7 +431,7 @@ static inline __u16 sonic_rda_get(struct
 static inline void sonic_rra_put(struct net_device* dev, int entry,
 				 int offset, __u16 val)
 {
-	struct sonic_local* lp = (struct sonic_local *) dev->priv;
+	struct sonic_local* lp = netdev_priv(dev);
 	sonic_buf_put(lp->rra, lp->dma_bitmode,
 		      (entry * SIZEOF_SONIC_RR) + offset, val);
 }
@@ -439,7 +439,7 @@ static inline void sonic_rra_put(struct 
 static inline __u16 sonic_rra_get(struct net_device* dev, int entry,
 				  int offset)
 {
-	struct sonic_local* lp = (struct sonic_local *) dev->priv;
+	struct sonic_local* lp = netdev_priv(dev);
 	return sonic_buf_get(lp->rra, lp->dma_bitmode,
 			     (entry * SIZEOF_SONIC_RR) + offset);
 }
diff --git a/drivers/net/sun3_82586.c b/drivers/net/sun3_82586.c
index b77ab6e..a94f98c 100644
--- a/drivers/net/sun3_82586.c
+++ b/drivers/net/sun3_82586.c
@@ -247,7 +247,7 @@ static int check586(struct net_device *d
  */
 static void alloc586(struct net_device *dev)
 {
-	struct priv *p =	(struct priv *) dev->priv;
+	struct priv *p =	netdev_priv(dev);
 
 	sun3_reset586();
 	DELAY(1);
@@ -364,17 +364,17 @@ static int __init sun3_82586_probe1(stru
 		goto out;
 	}
 
-	((struct priv *) (dev->priv))->memtop = (char *)dvma_btov(dev->mem_start);
-	((struct priv *) (dev->priv))->base = (unsigned long) dvma_btov(0);
+	((struct priv *) (netdev_priv(dev)))->memtop = (char *)dvma_btov(dev->mem_start);
+	((struct priv *) (netdev_priv(dev)))->base = (unsigned long) dvma_btov(0);
 	alloc586(dev);
 
 	/* set number of receive-buffs according to memsize */
 	if(size == 0x2000)
-		((struct priv *) dev->priv)->num_recv_buffs = NUM_RECV_BUFFS_8;
+		((struct priv *)netdev_priv(dev))->num_recv_buffs = NUM_RECV_BUFFS_8;
 	else if(size == 0x4000)
-		((struct priv *) dev->priv)->num_recv_buffs = NUM_RECV_BUFFS_16;
+		((struct priv *)netdev_priv(dev))->num_recv_buffs = NUM_RECV_BUFFS_16;
 	else
-		((struct priv *) dev->priv)->num_recv_buffs = NUM_RECV_BUFFS_32;
+		((struct priv *)netdev_priv(dev))->num_recv_buffs = NUM_RECV_BUFFS_32;
 
 	printk("Memaddr: 0x%lx, Memsize: %d, IRQ %d\n",dev->mem_start,size, dev->irq);
 
@@ -398,7 +398,7 @@ static int init586(struct net_device *de
 {
 	void *ptr;
 	int i,result=0;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 	volatile struct configure_cmd_struct	*cfg_cmd;
 	volatile struct iasetup_cmd_struct *ias_cmd;
 	volatile struct tdr_cmd_struct *tdr_cmd;
@@ -635,7 +635,7 @@ static void *alloc_rfa(struct net_device
 	volatile struct rfd_struct *rfd = (struct rfd_struct *)ptr;
 	volatile struct rbd_struct *rbd;
 	int i;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	memset((char *) rfd,0,sizeof(struct rfd_struct)*(p->num_recv_buffs+rfdadd));
 	p->rfd_first = rfd;
@@ -687,7 +687,7 @@ static irqreturn_t sun3_82586_interrupt(
 		printk ("sun3_82586-interrupt: irq %d for unknown device.\n",irq);
 		return IRQ_NONE;
 	}
-	p = (struct priv *) dev->priv;
+	p = netdev_priv(dev);
 
 	if(debuglevel > 1)
 		printk("I");
@@ -757,7 +757,7 @@ static void sun3_82586_rcv_int(struct ne
 	unsigned short totlen;
 	struct sk_buff *skb;
 	struct rbd_struct *rbd;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	if(debuglevel > 0)
 		printk("R");
@@ -875,7 +875,7 @@ #endif
 
 static void sun3_82586_rnr_int(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	p->stats.rx_errors++;
 
@@ -899,7 +899,7 @@ static void sun3_82586_rnr_int(struct ne
 static void sun3_82586_xmt_int(struct net_device *dev)
 {
 	int status;
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	if(debuglevel > 0)
 		printk("X");
@@ -949,7 +949,7 @@ #endif
 
 static void startrecv586(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	WAIT_4_SCB_CMD();
 	WAIT_4_SCB_CMD_RUC();
@@ -961,7 +961,7 @@ static void startrecv586(struct net_devi
 
 static void sun3_82586_timeout(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 #ifndef NO_NOPCOMMANDS
 	if(p->scb->cus & CU_ACTIVE) /* COMMAND-UNIT active? */
 	{
@@ -1003,7 +1003,7 @@ static int sun3_82586_send_packet(struct
 #ifndef NO_NOPCOMMANDS
 	int next_nop;
 #endif
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 
 	if(skb->len > XMIT_BUFF_SIZE)
 	{
@@ -1112,7 +1112,7 @@ #endif
 
 static struct net_device_stats *sun3_82586_get_stats(struct net_device *dev)
 {
-	struct priv *p = (struct priv *) dev->priv;
+	struct priv *p = netdev_priv(dev);
 	unsigned short crc,aln,rsc,ovrn;
 
 	crc = swab16(p->scb->crc_errs); /* get error-statistic from the ni82586 */
diff --git a/drivers/net/sunbmac.c b/drivers/net/sunbmac.c
index b3e0158..376ec86 100644
--- a/drivers/net/sunbmac.c
+++ b/drivers/net/sunbmac.c
@@ -914,7 +914,7 @@ static irqreturn_t bigmac_interrupt(int 
 
 static int bigmac_open(struct net_device *dev)
 {
-	struct bigmac *bp = (struct bigmac *) dev->priv;
+	struct bigmac *bp = netdev_priv(dev);
 	int ret;
 
 	ret = request_irq(dev->irq, &bigmac_interrupt, IRQF_SHARED, dev->name, bp);
@@ -931,7 +931,7 @@ static int bigmac_open(struct net_device
 
 static int bigmac_close(struct net_device *dev)
 {
-	struct bigmac *bp = (struct bigmac *) dev->priv;
+	struct bigmac *bp = netdev_priv(dev);
 
 	del_timer(&bp->bigmac_timer);
 	bp->timer_state = asleep;
@@ -945,7 +945,7 @@ static int bigmac_close(struct net_devic
 
 static void bigmac_tx_timeout(struct net_device *dev)
 {
-	struct bigmac *bp = (struct bigmac *) dev->priv;
+	struct bigmac *bp = netdev_priv(dev);
 
 	bigmac_init_hw(bp, 0);
 	netif_wake_queue(dev);
@@ -954,7 +954,7 @@ static void bigmac_tx_timeout(struct net
 /* Put a packet on the wire. */
 static int bigmac_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct bigmac *bp = (struct bigmac *) dev->priv;
+	struct bigmac *bp = netdev_priv(dev);
 	int len, entry;
 	u32 mapping;
 
@@ -986,7 +986,7 @@ static int bigmac_start_xmit(struct sk_b
 
 static struct net_device_stats *bigmac_get_stats(struct net_device *dev)
 {
-	struct bigmac *bp = (struct bigmac *) dev->priv;
+	struct bigmac *bp = netdev_priv(dev);
 
 	bigmac_get_counters(bp, bp->bregs);
 	return &bp->enet_stats;
@@ -994,7 +994,7 @@ static struct net_device_stats *bigmac_g
 
 static void bigmac_set_multicast(struct net_device *dev)
 {
-	struct bigmac *bp = (struct bigmac *) dev->priv;
+	struct bigmac *bp = netdev_priv(dev);
 	void __iomem *bregs = bp->bregs;
 	struct dev_mc_list *dmi = dev->mc_list;
 	char *addrs;
@@ -1051,7 +1051,7 @@ static void bigmac_set_multicast(struct 
 /* Ethtool support... */
 static void bigmac_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct bigmac *bp = dev->priv;
+	struct bigmac *bp = netdev_priv(dev);
 
 	strcpy(info->driver, "sunbmac");
 	strcpy(info->version, "2.0");
@@ -1061,7 +1061,7 @@ static void bigmac_get_drvinfo(struct ne
 
 static u32 bigmac_get_link(struct net_device *dev)
 {
-	struct bigmac *bp = dev->priv;
+	struct bigmac *bp = netdev_priv(dev);
 
 	spin_lock_irq(&bp->lock);
 	bp->sw_bmsr = bigmac_tcvr_read(bp, bp->tregs, BIGMAC_BMSR);
@@ -1097,7 +1097,7 @@ static int __init bigmac_ether_init(stru
 		dev->dev_addr[i] = idprom->id_ethaddr[i];
 
 	/* Setup softc, with backpointers to QEC and BigMAC SBUS device structs. */
-	bp = dev->priv;
+	bp = netdev_priv(dev);
 	bp->qec_sdev = qec_sdev;
 	bp->bigmac_sdev = qec_sdev->child;
 
diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 4328038..1896e62 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -164,7 +164,7 @@ static u16 __phy_read(struct gem *gp, in
 
 static inline int _phy_read(struct net_device *dev, int mii_id, int reg)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	return __phy_read(gp, mii_id, reg);
 }
 
@@ -197,7 +197,7 @@ static void __phy_write(struct gem *gp, 
 
 static inline void _phy_write(struct net_device *dev, int mii_id, int reg, int val)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	__phy_write(gp, mii_id, reg, val & 0xffff);
 }
 
@@ -880,7 +880,7 @@ static int gem_rx(struct gem *gp, int wo
 
 static int gem_poll(struct net_device *dev, int *budget)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	unsigned long flags;
 
 	/*
@@ -934,7 +934,7 @@ static int gem_poll(struct net_device *d
 static irqreturn_t gem_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	unsigned long flags;
 
 	/* Swallow interrupts when shutting the chip down, though
@@ -980,7 +980,7 @@ #endif
 
 static void gem_tx_timeout(struct net_device *dev)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 
 	printk(KERN_ERR "%s: transmit timed out, resetting\n", dev->name);
 	if (!gp->running) {
@@ -1019,7 +1019,7 @@ static __inline__ int gem_intme(int entr
 
 static int gem_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	int entry;
 	u64 ctrl;
 	unsigned long flags;
@@ -2192,7 +2192,7 @@ static void gem_stop_phy(struct gem *gp,
 
 static int gem_do_start(struct net_device *dev)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	unsigned long flags;
 
 	spin_lock_irqsave(&gp->lock, flags);
@@ -2239,7 +2239,7 @@ static int gem_do_start(struct net_devic
 
 static void gem_do_stop(struct net_device *dev, int wol)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	unsigned long flags;
 
 	spin_lock_irqsave(&gp->lock, flags);
@@ -2315,7 +2315,7 @@ static void gem_reset_task(struct work_s
 
 static int gem_open(struct net_device *dev)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	int rc = 0;
 
 	mutex_lock(&gp->pm_mutex);
@@ -2332,7 +2332,7 @@ static int gem_open(struct net_device *d
 
 static int gem_close(struct net_device *dev)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 
 	/* Note: we don't need to call netif_poll_disable() here because
 	 * our caller (dev_close) already did it for us
@@ -2353,7 +2353,7 @@ #ifdef CONFIG_PM
 static int gem_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	unsigned long flags;
 
 	mutex_lock(&gp->pm_mutex);
@@ -2417,7 +2417,7 @@ static int gem_suspend(struct pci_dev *p
 static int gem_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	unsigned long flags;
 
 	printk(KERN_INFO "%s: resuming\n", dev->name);
@@ -2492,7 +2492,7 @@ #endif /* CONFIG_PM */
 
 static struct net_device_stats *gem_get_stats(struct net_device *dev)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	struct net_device_stats *stats = &gp->net_stats;
 
 	spin_lock_irq(&gp->lock);
@@ -2528,7 +2528,7 @@ static struct net_device_stats *gem_get_
 static int gem_set_mac_address(struct net_device *dev, void *addr)
 {
 	struct sockaddr *macaddr = (struct sockaddr *) addr;
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	unsigned char *e = &dev->dev_addr[0];
 
 	if (!is_valid_ether_addr(macaddr->sa_data))
@@ -2556,7 +2556,7 @@ static int gem_set_mac_address(struct ne
 
 static void gem_set_multicast(struct net_device *dev)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	u32 rxcfg, rxcfg_new;
 	int limit = 10000;
 
@@ -2605,7 +2605,7 @@ #endif
 
 static int gem_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 
 	if (new_mtu < GEM_MIN_MTU || new_mtu > GEM_MAX_MTU)
 		return -EINVAL;
@@ -2636,7 +2636,7 @@ static int gem_change_mtu(struct net_dev
 
 static void gem_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 
 	strcpy(info->driver, DRV_NAME);
 	strcpy(info->version, DRV_VERSION);
@@ -2645,7 +2645,7 @@ static void gem_get_drvinfo(struct net_d
 
 static int gem_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 
 	if (gp->phy_type == phy_mii_mdio0 ||
 	    gp->phy_type == phy_mii_mdio1) {
@@ -2691,7 +2691,7 @@ static int gem_get_settings(struct net_d
 
 static int gem_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 
 	/* Verify the settings we care about. */
 	if (cmd->autoneg != AUTONEG_ENABLE &&
@@ -2722,7 +2722,7 @@ static int gem_set_settings(struct net_d
 
 static int gem_nway_reset(struct net_device *dev)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 
 	if (!gp->want_autoneg)
 		return -EINVAL;
@@ -2739,13 +2739,13 @@ static int gem_nway_reset(struct net_dev
 
 static u32 gem_get_msglevel(struct net_device *dev)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	return gp->msg_enable;
 }
 
 static void gem_set_msglevel(struct net_device *dev, u32 value)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	gp->msg_enable = value;
 }
 
@@ -2757,7 +2757,7 @@ #define WOL_SUPPORTED_MASK	(WAKE_MAGIC)
 
 static void gem_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 
 	/* Add more when I understand how to program the chip */
 	if (gp->has_wol) {
@@ -2771,7 +2771,7 @@ static void gem_get_wol(struct net_devic
 
 static int gem_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 
 	if (!gp->has_wol)
 		return -EOPNOTSUPP;
@@ -2793,7 +2793,7 @@ static const struct ethtool_ops gem_etht
 
 static int gem_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
-	struct gem *gp = dev->priv;
+	struct gem *gp = netdev_priv(dev);
 	struct mii_ioctl_data *data = if_mii(ifr);
 	int rc = -EOPNOTSUPP;
 	unsigned long flags;
@@ -2925,7 +2925,7 @@ static void gem_remove_one(struct pci_de
 	struct net_device *dev = pci_get_drvdata(pdev);
 
 	if (dev) {
-		struct gem *gp = dev->priv;
+		struct gem *gp = netdev_priv(dev);
 
 		unregister_netdev(dev);
 
@@ -3029,7 +3029,7 @@ static int __devinit gem_init_one(struct
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
-	gp = dev->priv;
+	gp = netdev_priv(dev);
 
 	err = pci_request_regions(pdev, DRV_NAME);
 	if (err) {
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index 8b35f13..1049740 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -2136,7 +2136,7 @@ static irqreturn_t quattro_sbus_interrup
 
 	for (i = 0; i < 4; i++) {
 		struct net_device *dev = qp->happy_meals[i];
-		struct happy_meal *hp  = dev->priv;
+		struct happy_meal *hp  = netdev_priv(dev);
 		u32 happy_status       = hme_read32(hp, hp->gregs + GREG_STAT);
 
 		HMD(("quattro_interrupt: status=%08x ", happy_status));
@@ -2181,7 +2181,7 @@ #endif
 
 static int happy_meal_open(struct net_device *dev)
 {
-	struct happy_meal *hp = dev->priv;
+	struct happy_meal *hp = netdev_priv(dev);
 	int res;
 
 	HMD(("happy_meal_open: "));
@@ -2213,7 +2213,7 @@ static int happy_meal_open(struct net_de
 
 static int happy_meal_close(struct net_device *dev)
 {
-	struct happy_meal *hp = dev->priv;
+	struct happy_meal *hp = netdev_priv(dev);
 
 	spin_lock_irq(&hp->happy_lock);
 	happy_meal_stop(hp, hp->gregs);
@@ -2242,7 +2242,7 @@ #endif
 
 static void happy_meal_tx_timeout(struct net_device *dev)
 {
-	struct happy_meal *hp = dev->priv;
+	struct happy_meal *hp = netdev_priv(dev);
 
 	printk (KERN_ERR "%s: transmit timed out, resetting\n", dev->name);
 	tx_dump_log();
@@ -2260,7 +2260,7 @@ static void happy_meal_tx_timeout(struct
 
 static int happy_meal_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct happy_meal *hp = dev->priv;
+	struct happy_meal *hp = netdev_priv(dev);
  	int entry;
  	u32 tx_flags;
 
@@ -2349,7 +2349,7 @@ static int happy_meal_start_xmit(struct 
 
 static struct net_device_stats *happy_meal_get_stats(struct net_device *dev)
 {
-	struct happy_meal *hp = dev->priv;
+	struct happy_meal *hp = netdev_priv(dev);
 
 	spin_lock_irq(&hp->happy_lock);
 	happy_meal_get_counters(hp, hp->bigmacregs);
@@ -2360,7 +2360,7 @@ static struct net_device_stats *happy_me
 
 static void happy_meal_set_multicast(struct net_device *dev)
 {
-	struct happy_meal *hp = dev->priv;
+	struct happy_meal *hp = netdev_priv(dev);
 	void __iomem *bregs = hp->bigmacregs;
 	struct dev_mc_list *dmi = dev->mc_list;
 	char *addrs;
@@ -2410,7 +2410,7 @@ static void happy_meal_set_multicast(str
 /* Ethtool support... */
 static int hme_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct happy_meal *hp = dev->priv;
+	struct happy_meal *hp = netdev_priv(dev);
 
 	cmd->supported =
 		(SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
@@ -2455,7 +2455,7 @@ static int hme_get_settings(struct net_d
 
 static int hme_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct happy_meal *hp = dev->priv;
+	struct happy_meal *hp = netdev_priv(dev);
 
 	/* Verify the settings we care about. */
 	if (cmd->autoneg != AUTONEG_ENABLE &&
@@ -2479,7 +2479,7 @@ static int hme_set_settings(struct net_d
 
 static void hme_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct happy_meal *hp = dev->priv;
+	struct happy_meal *hp = netdev_priv(dev);
 
 	strcpy(info->driver, "sunhme");
 	strcpy(info->version, "2.02");
@@ -2498,7 +2498,7 @@ #endif
 
 static u32 hme_get_link(struct net_device *dev)
 {
-	struct happy_meal *hp = dev->priv;
+	struct happy_meal *hp = netdev_priv(dev);
 
 	spin_lock_irq(&hp->happy_lock);
 	hp->sw_bmcr = happy_meal_tcvr_read(hp, hp->tcvregs, MII_BMCR);
@@ -2709,7 +2709,7 @@ static int __devinit happy_meal_sbus_pro
 			memcpy(dev->dev_addr, idprom->id_ethaddr, 6);
 	}
 
-	hp = dev->priv;
+	hp = netdev_priv(dev);
 
 	hp->happy_dev = sdev;
 
@@ -3030,7 +3030,7 @@ #endif
 
 	dev->base_addr = (long) pdev;
 
-	hp = (struct happy_meal *)dev->priv;
+	hp = netdev_priv(dev);
 	memset(hp, 0, sizeof(*hp));
 
 	hp->happy_dev = pdev;
diff --git a/drivers/net/sunqe.c b/drivers/net/sunqe.c
index 1b65ae8..49498fd 100644
--- a/drivers/net/sunqe.c
+++ b/drivers/net/sunqe.c
@@ -510,7 +510,7 @@ static irqreturn_t qec_interrupt(int irq
 
 static int qe_open(struct net_device *dev)
 {
-	struct sunqe *qep = (struct sunqe *) dev->priv;
+	struct sunqe *qep = netdev_priv(dev);
 
 	qep->mconfig = (MREGS_MCONFIG_TXENAB |
 			MREGS_MCONFIG_RXENAB |
@@ -520,7 +520,7 @@ static int qe_open(struct net_device *de
 
 static int qe_close(struct net_device *dev)
 {
-	struct sunqe *qep = (struct sunqe *) dev->priv;
+	struct sunqe *qep = netdev_priv(dev);
 
 	qe_stop(qep);
 	return 0;
@@ -546,7 +546,7 @@ static void qe_tx_reclaim(struct sunqe *
 
 static void qe_tx_timeout(struct net_device *dev)
 {
-	struct sunqe *qep = (struct sunqe *) dev->priv;
+	struct sunqe *qep = netdev_priv(dev);
 	int tx_full;
 
 	spin_lock_irq(&qep->lock);
@@ -572,7 +572,7 @@ out:
 /* Get a packet queued to go onto the wire. */
 static int qe_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct sunqe *qep = (struct sunqe *) dev->priv;
+	struct sunqe *qep = netdev_priv(dev);
 	struct sunqe_buffers *qbufs = qep->buffers;
 	__u32 txbuf_dvma, qbufs_dvma = qep->buffers_dvma;
 	unsigned char *txbuf;
@@ -624,14 +624,14 @@ static int qe_start_xmit(struct sk_buff 
 
 static struct net_device_stats *qe_get_stats(struct net_device *dev)
 {
-	struct sunqe *qep = (struct sunqe *) dev->priv;
+	struct sunqe *qep = netdev_priv(dev);
 
 	return &qep->net_stats;
 }
 
 static void qe_set_multicast(struct net_device *dev)
 {
-	struct sunqe *qep = (struct sunqe *) dev->priv;
+	struct sunqe *qep = netdev_priv(dev);
 	struct dev_mc_list *dmi = dev->mc_list;
 	u8 new_mconfig = qep->mconfig;
 	char *addrs;
@@ -696,7 +696,7 @@ static void qe_set_multicast(struct net_
 /* Ethtool support... */
 static void qe_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct sunqe *qep = dev->priv;
+	struct sunqe *qep = netdev_priv(dev);
 
 	strcpy(info->driver, "sunqe");
 	strcpy(info->version, "3.0");
@@ -706,7 +706,7 @@ static void qe_get_drvinfo(struct net_de
 
 static u32 qe_get_link(struct net_device *dev)
 {
-	struct sunqe *qep = dev->priv;
+	struct sunqe *qep = netdev_priv(dev);
 	void __iomem *mregs = qep->mregs;
 	u8 phyconfig;
 
diff --git a/drivers/net/tc35815.c b/drivers/net/tc35815.c
index ec41469..e91cf34 100644
--- a/drivers/net/tc35815.c
+++ b/drivers/net/tc35815.c
@@ -614,7 +614,7 @@ static int __devinit tc35815_mac_match(s
 
 static int __devinit tc35815_read_plat_dev_addr(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	struct device *pd = bus_find_device(&platform_bus_type, NULL,
 					    lp->pci_dev, tc35815_mac_match);
 	if (pd) {
@@ -684,7 +684,7 @@ static int __devinit tc35815_init_one (s
 	}
 	SET_MODULE_OWNER(dev);
 	SET_NETDEV_DEV(dev, &pdev->dev);
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 
 	/* enable device (incl. PCI PM wakeup), and bus-mastering */
 	rc = pci_enable_device (pdev);
@@ -749,7 +749,7 @@ #endif
 	dev->base_addr = (unsigned long) ioaddr;
 
 	/* dev->priv/lp zeroed and aligned in alloc_etherdev */
-	lp = dev->priv;
+	lp = netdev_priv(dev);
 	spin_lock_init(&lp->lock);
 	lp->pci_dev = pdev;
 	lp->boardtype = ent->driver_data;
@@ -827,7 +827,7 @@ static void __devexit tc35815_remove_one
 static int
 tc35815_init_queues(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int i;
 	unsigned long fd_addr;
 
@@ -964,7 +964,7 @@ #endif
 static void
 tc35815_clear_queues(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int i;
 
 	for (i = 0; i < TX_FD_NUM; i++) {
@@ -995,7 +995,7 @@ #endif
 static void
 tc35815_free_queues(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int i;
 
 	if (lp->tfd_base) {
@@ -1109,7 +1109,7 @@ #ifdef DEBUG
 static void
 panic_queues(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int i;
 
 	printk("TxFD base %p, start %u, end %u\n",
@@ -1143,13 +1143,13 @@ static void print_eth(char *add)
 
 static int tc35815_tx_full(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	return ((lp->tfd_start + 1) % TX_FD_NUM == lp->tfd_end);
 }
 
 static void tc35815_restart(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int pid = lp->phy_addr;
 	int do_phy_reset = 1;
 	del_timer(&lp->timer);		/* Kill if running	*/
@@ -1180,7 +1180,7 @@ static void tc35815_restart(struct net_d
 
 static void tc35815_tx_timeout(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	struct tc35815_regs __iomem *tr =
 		(struct tc35815_regs __iomem *)dev->base_addr;
 
@@ -1219,7 +1219,7 @@ static void tc35815_tx_timeout(struct ne
 static int
 tc35815_open(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 
 	/*
 	 * This is used if the interrupt line can turned off (shared).
@@ -1257,7 +1257,7 @@ tc35815_open(struct net_device *dev)
  */
 static int tc35815_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	struct TxFD *txfd;
 	unsigned long flags;
 
@@ -1371,7 +1371,7 @@ #else
 static int tc35815_do_interrupt(struct net_device *dev, u32 status)
 #endif
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	struct tc35815_regs __iomem *tr =
 		(struct tc35815_regs __iomem *)dev->base_addr;
 	int ret = -1;
@@ -1456,7 +1456,7 @@ #ifdef TC35815_NAPI
 	}
 	return IRQ_NONE;
 #else
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int handled;
 	u32 status;
 
@@ -1488,7 +1488,7 @@ static void
 tc35815_rx(struct net_device *dev)
 #endif
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	unsigned int fdctl;
 	int i;
 	int buf_free_count = 0;
@@ -1729,7 +1729,7 @@ #ifdef TC35815_NAPI
 static int
 tc35815_poll(struct net_device *dev, int *budget)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	struct tc35815_regs __iomem *tr =
 		(struct tc35815_regs __iomem *)dev->base_addr;
 	int limit = min(*budget, dev->quota);
@@ -1773,7 +1773,7 @@ #endif
 static void
 tc35815_check_tx_stat(struct net_device *dev, int status)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	const char *msg = NULL;
 
 	/* count collisions */
@@ -1850,7 +1850,7 @@ #endif
 static void
 tc35815_txdone(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	struct TxFD *txfd;
 	unsigned int fdctl;
 
@@ -1948,7 +1948,7 @@ #endif
 static int
 tc35815_close(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	netif_stop_queue(dev);
 
 	/* Flush the Tx and disable Rx here. */
@@ -1969,7 +1969,7 @@ tc35815_close(struct net_device *dev)
  */
 static struct net_device_stats *tc35815_get_stats(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	struct tc35815_regs __iomem *tr =
 		(struct tc35815_regs __iomem *)dev->base_addr;
 	if (netif_running(dev)) {
@@ -1982,7 +1982,7 @@ static struct net_device_stats *tc35815_
 
 static void tc35815_set_cam_entry(struct net_device *dev, int index, unsigned char *addr)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	struct tc35815_regs __iomem *tr =
 		(struct tc35815_regs __iomem *)dev->base_addr;
 	int cam_index = index * 6;
@@ -2041,7 +2041,7 @@ tc35815_set_multicast_list(struct net_de
 #ifdef WORKAROUND_100HALF_PROMISC
 		/* With some (all?) 100MHalf HUB, controller will hang
 		 * if we enabled promiscuous mode before linkup... */
-		struct tc35815_local *lp = dev->priv;
+		struct tc35815_local *lp = netdev_priv(dev);
 		int pid = lp->phy_addr;
 		if (!(tc_mdio_read(dev, pid, MII_BMSR) & BMSR_LSTATUS))
 			return;
@@ -2081,7 +2081,7 @@ #endif
 
 static void tc35815_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	strcpy(info->driver, MODNAME);
 	strcpy(info->version, DRV_VERSION);
 	strcpy(info->bus_info, pci_name(lp->pci_dev));
@@ -2089,7 +2089,7 @@ static void tc35815_get_drvinfo(struct n
 
 static int tc35815_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	spin_lock_irq(&lp->lock);
 	mii_ethtool_gset(&lp->mii, cmd);
 	spin_unlock_irq(&lp->lock);
@@ -2098,7 +2098,7 @@ static int tc35815_get_settings(struct n
 
 static int tc35815_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int rc;
 #if 1	/* use our negotiation method... */
 	/* Verify the settings we care about. */
@@ -2128,7 +2128,7 @@ #endif
 
 static int tc35815_nway_reset(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int rc;
 	spin_lock_irq(&lp->lock);
 	rc = mii_nway_restart(&lp->mii);
@@ -2138,7 +2138,7 @@ static int tc35815_nway_reset(struct net
 
 static u32 tc35815_get_link(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int rc;
 	spin_lock_irq(&lp->lock);
 	rc = mii_link_ok(&lp->mii);
@@ -2148,25 +2148,25 @@ static u32 tc35815_get_link(struct net_d
 
 static u32 tc35815_get_msglevel(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	return lp->msg_enable;
 }
 
 static void tc35815_set_msglevel(struct net_device *dev, u32 datum)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	lp->msg_enable = datum;
 }
 
 static int tc35815_get_stats_count(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	return sizeof(lp->lstats) / sizeof(int);
 }
 
 static void tc35815_get_ethtool_stats(struct net_device *dev, struct ethtool_stats *stats, u64 *data)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	data[0] = lp->lstats.max_tx_qlen;
 	data[1] = lp->lstats.tx_ints;
 	data[2] = lp->lstats.rx_ints;
@@ -2202,7 +2202,7 @@ static const struct ethtool_ops tc35815_
 
 static int tc35815_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int rc;
 
 	if (!netif_running(dev))
@@ -2274,7 +2274,7 @@ static void tc_mdio_write(struct net_dev
 
 static int tc35815_try_next_permutation(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int pid = lp->phy_addr;
 	unsigned short bmcr;
 
@@ -2303,7 +2303,7 @@ static int tc35815_try_next_permutation(
 static void
 tc35815_display_link_mode(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int pid = lp->phy_addr;
 	unsigned short lpa, bmcr;
 	char *speed = "", *duplex = "";
@@ -2329,7 +2329,7 @@ tc35815_display_link_mode(struct net_dev
 
 static void tc35815_display_forced_link_mode(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int pid = lp->phy_addr;
 	unsigned short bmcr;
 	char *speed = "", *duplex = "";
@@ -2351,7 +2351,7 @@ static void tc35815_display_forced_link_
 
 static void tc35815_set_link_modes(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	struct tc35815_regs __iomem *tr =
 		(struct tc35815_regs __iomem *)dev->base_addr;
 	int pid = lp->phy_addr;
@@ -2418,7 +2418,7 @@ #endif
 static void tc35815_timer(unsigned long data)
 {
 	struct net_device *dev = (struct net_device *)data;
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int pid = lp->phy_addr;
 	unsigned short bmsr, bmcr, lpa;
 	int restart_timer = 0;
@@ -2626,7 +2626,7 @@ out:
 static void tc35815_start_auto_negotiation(struct net_device *dev,
 					   struct ethtool_cmd *ep)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int pid = lp->phy_addr;
 	unsigned short bmsr, bmcr, advertize;
 	int timeout;
@@ -2750,7 +2750,7 @@ force_link:
 
 static void tc35815_find_phy(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int pid = lp->phy_addr;
 	unsigned short id0;
 
@@ -2779,7 +2779,7 @@ static void tc35815_find_phy(struct net_
 
 static void tc35815_phy_chip_init(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	int pid = lp->phy_addr;
 	unsigned short bmcr;
 	struct ethtool_cmd ecmd, *ep;
@@ -2853,7 +2853,7 @@ static void tc35815_chip_reset(struct ne
 
 static void tc35815_chip_init(struct net_device *dev)
 {
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	struct tc35815_regs __iomem *tr =
 		(struct tc35815_regs __iomem *)dev->base_addr;
 	unsigned long txctl = TX_CTL_CMD;
@@ -2915,7 +2915,7 @@ #ifdef CONFIG_PM
 static int tc35815_suspend(struct pci_dev *pdev, pm_message_t state)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	unsigned long flags;
 
 	pci_save_state(pdev);
@@ -2933,7 +2933,7 @@ static int tc35815_suspend(struct pci_de
 static int tc35815_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct tc35815_local *lp = dev->priv;
+	struct tc35815_local *lp = netdev_priv(dev);
 	unsigned long flags;
 
 	pci_restore_state(pdev);
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 0358720..76ad294 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -1818,7 +1818,7 @@ static irqreturn_t
 typhoon_interrupt(int irq, void *dev_instance)
 {
 	struct net_device *dev = (struct net_device *) dev_instance;
-	struct typhoon *tp = dev->priv;
+	struct typhoon *tp = netdev_priv(dev);
 	void __iomem *ioaddr = tp->ioaddr;
 	u32 intr_status;
 
diff --git a/drivers/net/znet.c b/drivers/net/znet.c
index 4032e9f..27e060e 100644
--- a/drivers/net/znet.c
+++ b/drivers/net/znet.c
@@ -169,7 +169,7 @@ static void znet_tx_timeout (struct net_
 /* Request needed resources */
 static int znet_request_resources (struct net_device *dev)
 {
-	struct znet_private *znet = dev->priv;
+	struct znet_private *znet = netdev_priv(dev);
 	unsigned long flags;
 
 	if (request_irq (dev->irq, &znet_interrupt, 0, "ZNet", dev))
@@ -203,7 +203,7 @@ static int znet_request_resources (struc
 
 static void znet_release_resources (struct net_device *dev)
 {
-	struct znet_private *znet = dev->priv;
+	struct znet_private *znet = netdev_priv(dev);
 	unsigned long flags;
 
 	release_region (znet->sia_base, znet->sia_size);
@@ -218,7 +218,7 @@ static void znet_release_resources (stru
 /* Keep the magical SIA stuff in a single function... */
 static void znet_transceiver_power (struct net_device *dev, int on)
 {
-	struct znet_private *znet = dev->priv;
+	struct znet_private *znet = netdev_priv(dev);
 	unsigned char v;
 
 	/* Turn on/off the 82501 SIA, using zenith-specific magic. */
@@ -237,7 +237,7 @@ static void znet_transceiver_power (stru
    Also used from hardware_init. */
 static void znet_set_multicast_list (struct net_device *dev)
 {
-	struct znet_private *znet = dev->priv;
+	struct znet_private *znet = netdev_priv(dev);
 	short ioaddr = dev->base_addr;
 	struct i82593_conf_block *cfblk = &znet->i593_init;
 
@@ -390,7 +390,7 @@ static int __init znet_probe (void)
 
 	SET_MODULE_OWNER (dev);
 
-	znet = dev->priv;
+	znet = netdev_priv(dev);
 
 	netinfo = (struct netidblk *)p;
 	dev->base_addr = netinfo->iobase1;
@@ -535,7 +535,7 @@ static void znet_tx_timeout (struct net_
 static int znet_send_packet(struct sk_buff *skb, struct net_device *dev)
 {
 	int ioaddr = dev->base_addr;
-	struct znet_private *znet = dev->priv;
+	struct znet_private *znet = netdev_priv(dev);
 	unsigned long flags;
 	short length = skb->len;
 
@@ -605,7 +605,7 @@ static int znet_send_packet(struct sk_bu
 static irqreturn_t znet_interrupt(int irq, void *dev_id)
 {
 	struct net_device *dev = dev_id;
-	struct znet_private *znet = dev->priv;
+	struct znet_private *znet = netdev_priv(dev);
 	int ioaddr;
 	int boguscnt = 20;
 	int handled = 0;
@@ -683,7 +683,7 @@ static irqreturn_t znet_interrupt(int ir
 
 static void znet_rx(struct net_device *dev)
 {
-	struct znet_private *znet = dev->priv;
+	struct znet_private *znet = netdev_priv(dev);
 	int ioaddr = dev->base_addr;
 	int boguscount = 1;
 	short next_frame_end_offset = 0; 		/* Offset of next frame start. */
@@ -833,7 +833,7 @@ static int znet_close(struct net_device 
    closed. */
 static struct net_device_stats *net_get_stats(struct net_device *dev)
 {
-	struct znet_private *znet = dev->priv;
+	struct znet_private *znet = netdev_priv(dev);
 
 	return &znet->stats;
 }
@@ -842,7 +842,7 @@ static void show_dma(struct net_device *
 {
 	short ioaddr = dev->base_addr;
 	unsigned char stat = inb (ioaddr);
-	struct znet_private *znet = dev->priv;
+	struct znet_private *znet = netdev_priv(dev);
 	unsigned long flags;
 	short dma_port = ((znet->tx_dma&3)<<2) + IO_DMA2_BASE;
 	unsigned addr = inb(dma_port);
@@ -865,7 +865,7 @@ static void hardware_init(struct net_dev
 {
 	unsigned long flags;
 	short ioaddr = dev->base_addr;
-	struct znet_private *znet = dev->priv;
+	struct znet_private *znet = netdev_priv(dev);
 
 	znet->rx_cur = znet->rx_start;
 	znet->tx_cur = znet->tx_start;
@@ -927,7 +927,7 @@ static void update_stop_hit(short ioaddr
 static __exit void znet_cleanup (void)
 {
 	if (znet_dev) {
-		struct znet_private *znet = znet_dev->priv;
+		struct znet_private *znet = netdev_priv(znet_dev);
 
 		unregister_netdev (znet_dev);
 		kfree (znet->rx_start);
