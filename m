From: Yoann Padioleau <padator@wanadoo.fr>
Subject: [PATCH 09/13] dev->priv to netdev_priv(dev), for drivers/net/tokenring
Date: Fri, 3 Aug 2007 19:36:27 +0200 (MEST)
Message-ID: <200708031736.TAA00854@ifs.emn.fr>
Cc: jeff@garzik.org, netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764213AbXHCRiS@vger.kernel.org>
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

 drivers/net/tokenring/3c359.c       |   58 ++++++++++++++++++------------------
 drivers/net/tokenring/ibmtr.c       |   38 +++++++++++------------
 drivers/net/tokenring/lanstreamer.c |   32 +++++++++----------
 drivers/net/tokenring/madgemc.c     |    4 +-
 drivers/net/tokenring/olympic.c     |   36 +++++++++++-----------
 drivers/net/tokenring/tmspci.c      |    4 +-
 6 files changed, 86 insertions(+), 86 deletions(-)

diff --git a/drivers/net/tokenring/3c359.c b/drivers/net/tokenring/3c359.c
index 9f1b6ab..a8573da 100644
--- a/drivers/net/tokenring/3c359.c
+++ b/drivers/net/tokenring/3c359.c
@@ -156,7 +156,7 @@ static void print_rx_state(struct net_de
 static void print_tx_state(struct net_device *dev)
 {
 
-	struct xl_private *xl_priv = (struct xl_private *)dev->priv ; 
+	struct xl_private *xl_priv = netdev_priv(dev) ; 
 	struct xl_tx_desc *txd ; 
 	u8 __iomem *xl_mmio = xl_priv->xl_mmio ; 
 	int i ; 
@@ -179,7 +179,7 @@ static void print_tx_state(struct net_de
 static void print_rx_state(struct net_device *dev)
 {
 
-	struct xl_private *xl_priv = (struct xl_private *)dev->priv ; 
+	struct xl_private *xl_priv = netdev_priv(dev) ; 
 	struct xl_rx_desc *rxd ; 
 	u8 __iomem *xl_mmio = xl_priv->xl_mmio ; 
 	int i ; 
@@ -213,7 +213,7 @@ #endif
 
 static u16 xl_ee_read(struct net_device *dev, int ee_addr)
 { 
-    	struct xl_private *xl_priv = (struct xl_private *)dev->priv ;
+    	struct xl_private *xl_priv = netdev_priv(dev) ;
 	u8 __iomem *xl_mmio = xl_priv->xl_mmio ; 
 
 	/* Wait for EEProm to not be busy */
@@ -245,7 +245,7 @@ static u16 xl_ee_read(struct net_device 
 
 static void  xl_ee_write(struct net_device *dev, int ee_addr, u16 ee_value) 
 {
-    	struct xl_private *xl_priv = (struct xl_private *)dev->priv ;
+    	struct xl_private *xl_priv = netdev_priv(dev) ;
 	u8 __iomem *xl_mmio = xl_priv->xl_mmio ; 
 
 	/* Wait for EEProm to not be busy */
@@ -305,11 +305,11 @@ static int __devinit xl_probe(struct pci
 		pci_release_regions(pdev) ; 
 		return -ENOMEM ; 
 	} 
-	xl_priv = dev->priv ; 
+	xl_priv = netdev_priv(dev) ; 
 
 #if XL_DEBUG  
 	printk("pci_device: %p, dev:%p, dev->priv: %p, ba[0]: %10x, ba[1]:%10x\n", 
-		pdev, dev, dev->priv, (unsigned int)pdev->resource[0].start, (unsigned int)pdev->resource[1].start) ;  
+		pdev, dev, netdev_priv(dev), (unsigned int)pdev->resource[0].start, (unsigned int)pdev->resource[1].start) ;  
 #endif 
 
 	dev->irq=pdev->irq;
@@ -365,7 +365,7 @@ #endif 
 
 static int __devinit xl_init(struct net_device *dev) 
 {
-    	struct xl_private *xl_priv = (struct xl_private *)dev->priv ;
+    	struct xl_private *xl_priv = netdev_priv(dev) ;
 
 	printk(KERN_INFO "%s \n", version);
 	printk(KERN_INFO "%s: I/O at %hx, MMIO at %p, using irq %d\n",
@@ -385,7 +385,7 @@ static int __devinit xl_init(struct net_
 
 static int xl_hw_reset(struct net_device *dev) 
 { 
-    	struct xl_private *xl_priv = (struct xl_private *)dev->priv ;
+    	struct xl_private *xl_priv = netdev_priv(dev) ;
 	u8 __iomem *xl_mmio = xl_priv->xl_mmio ; 
 	unsigned long t ; 
 	u16 i ; 
@@ -568,7 +568,7 @@ #endif
 
 static int xl_open(struct net_device *dev) 
 {
-	struct xl_private *xl_priv=(struct xl_private *)dev->priv;
+	struct xl_private *xl_priv=netdev_priv(dev);
 	u8 __iomem *xl_mmio = xl_priv->xl_mmio ; 
 	u8 i ; 
 	u16 hwaddr[3] ; /* Should be u8[6] but we get word return values */
@@ -726,7 +726,7 @@ static int xl_open(struct net_device *de
 
 static int xl_open_hw(struct net_device *dev) 
 { 
-	struct xl_private *xl_priv=(struct xl_private *)dev->priv;
+	struct xl_private *xl_priv=netdev_priv(dev);
 	u8 __iomem *xl_mmio = xl_priv->xl_mmio ; 
 	u16 vsoff ;
 	char ver_str[33];  
@@ -875,7 +875,7 @@ static int xl_open_hw(struct net_device 
 
 static void adv_rx_ring(struct net_device *dev) /* Advance rx_ring, cut down on bloat in xl_rx */ 
 {
-	struct xl_private *xl_priv=(struct xl_private *)dev->priv;
+	struct xl_private *xl_priv=netdev_priv(dev);
 	int prev_ring_loc ; 
 
 	prev_ring_loc = (xl_priv->rx_ring_tail + XL_RX_RING_SIZE - 1) & (XL_RX_RING_SIZE - 1);
@@ -890,7 +890,7 @@ static void adv_rx_ring(struct net_devic
 
 static void xl_rx(struct net_device *dev)
 {
-	struct xl_private *xl_priv=(struct xl_private *)dev->priv;
+	struct xl_private *xl_priv=netdev_priv(dev);
 	u8 __iomem * xl_mmio = xl_priv->xl_mmio ; 
 	struct sk_buff *skb, *skb2 ; 
 	int frame_length = 0, copy_len = 0  ; 	
@@ -997,7 +997,7 @@ static void xl_rx(struct net_device *dev
 
 static void xl_reset(struct net_device *dev) 
 {
-	struct xl_private *xl_priv=(struct xl_private *)dev->priv;
+	struct xl_private *xl_priv=netdev_priv(dev);
 	u8 __iomem * xl_mmio = xl_priv->xl_mmio ; 
 	unsigned long t; 
 
@@ -1020,7 +1020,7 @@ static void xl_reset(struct net_device *
 
 static void xl_freemem(struct net_device *dev) 
 {
-	struct xl_private *xl_priv=(struct xl_private *)dev->priv ; 
+	struct xl_private *xl_priv=netdev_priv(dev) ; 
 	int i ; 
 
 	for (i=0;i<XL_RX_RING_SIZE;i++) {
@@ -1044,7 +1044,7 @@ static void xl_freemem(struct net_device
 static irqreturn_t xl_interrupt(int irq, void *dev_id) 
 {
 	struct net_device *dev = (struct net_device *)dev_id;
- 	struct xl_private *xl_priv =(struct xl_private *)dev->priv;
+ 	struct xl_private *xl_priv =netdev_priv(dev);
 	u8 __iomem * xl_mmio = xl_priv->xl_mmio ; 
 	u16 intstatus, macstatus  ;
 
@@ -1171,7 +1171,7 @@ static irqreturn_t xl_interrupt(int irq,
 	
 static int xl_xmit(struct sk_buff *skb, struct net_device *dev) 
 {
-	struct xl_private *xl_priv=(struct xl_private *)dev->priv;
+	struct xl_private *xl_priv=netdev_priv(dev);
 	struct xl_tx_desc *txd ; 
 	int tx_head, tx_tail, tx_prev ; 
 	unsigned long flags ; 	
@@ -1232,7 +1232,7 @@ static int xl_xmit(struct sk_buff *skb, 
 
 static void xl_dn_comp(struct net_device *dev) 
 {
-	struct xl_private *xl_priv=(struct xl_private *)dev->priv;
+	struct xl_private *xl_priv=netdev_priv(dev);
 	u8 __iomem * xl_mmio = xl_priv->xl_mmio ; 
 	struct xl_tx_desc *txd ; 
 
@@ -1268,7 +1268,7 @@ static void xl_dn_comp(struct net_device
 
 static int xl_close(struct net_device *dev) 
 {
-	struct xl_private *xl_priv = (struct xl_private *) dev->priv ; 
+	struct xl_private *xl_priv = netdev_priv(dev) ; 
 	u8 __iomem * xl_mmio = xl_priv->xl_mmio ; 
 	unsigned long t ; 
 
@@ -1366,7 +1366,7 @@ static int xl_close(struct net_device *d
 
 static void xl_set_rx_mode(struct net_device *dev) 
 {
-	struct xl_private *xl_priv = (struct xl_private *) dev->priv ; 
+	struct xl_private *xl_priv = netdev_priv(dev) ; 
 	struct dev_mc_list *dmi ; 
 	unsigned char dev_mc_address[4] ; 
 	u16 options ; 
@@ -1407,7 +1407,7 @@ static void xl_set_rx_mode(struct net_de
 
 static void xl_srb_bh(struct net_device *dev) 
 { 
-	struct xl_private *xl_priv = (struct xl_private *) dev->priv ; 
+	struct xl_private *xl_priv = netdev_priv(dev) ; 
 	u8 __iomem * xl_mmio = xl_priv->xl_mmio ; 
 	u8 srb_cmd, ret_code ; 
 	int i ; 
@@ -1476,14 +1476,14 @@ static void xl_srb_bh(struct net_device 
 
 static struct net_device_stats * xl_get_stats(struct net_device *dev)
 {
-	struct xl_private *xl_priv = (struct xl_private *) dev->priv ;
+	struct xl_private *xl_priv = netdev_priv(dev) ;
 	return (struct net_device_stats *) &xl_priv->xl_stats; 
 }
 
 static int xl_set_mac_address (struct net_device *dev, void *addr) 
 {
 	struct sockaddr *saddr = addr ; 
-	struct xl_private *xl_priv = (struct xl_private *)dev->priv ; 
+	struct xl_private *xl_priv = netdev_priv(dev) ; 
 
 	if (netif_running(dev)) { 
 		printk(KERN_WARNING "%s: Cannot set mac/laa address while card is open\n", dev->name) ; 
@@ -1504,7 +1504,7 @@ static int xl_set_mac_address (struct ne
 
 static void xl_arb_cmd(struct net_device *dev)
 {
-	struct xl_private *xl_priv = (struct xl_private *) dev->priv;
+	struct xl_private *xl_priv = netdev_priv(dev);
 	u8 __iomem * xl_mmio = xl_priv->xl_mmio ; 
 	u8 arb_cmd ; 
 	u16 lan_status, lan_status_diff ; 
@@ -1632,7 +1632,7 @@ #endif 		
 
 static void xl_asb_cmd(struct net_device *dev)
 {
-	struct xl_private *xl_priv = (struct xl_private *) dev->priv ; 
+	struct xl_private *xl_priv = netdev_priv(dev) ; 
 	u8 __iomem * xl_mmio = xl_priv->xl_mmio ; 
 
 	if (xl_priv->asb_queued == 1) 
@@ -1663,7 +1663,7 @@ static void xl_asb_cmd(struct net_device
  */
 static void xl_asb_bh(struct net_device *dev) 
 {
-	struct xl_private *xl_priv = (struct xl_private *) dev->priv ; 
+	struct xl_private *xl_priv = netdev_priv(dev) ; 
 	u8 __iomem * xl_mmio = xl_priv->xl_mmio ; 
 	u8 ret_code ; 
 
@@ -1691,7 +1691,7 @@ static void xl_asb_bh(struct net_device 
 
 static void xl_srb_cmd(struct net_device *dev, int srb_cmd) 
 {
-	struct xl_private *xl_priv = (struct xl_private *) dev->priv ; 
+	struct xl_private *xl_priv = netdev_priv(dev) ; 
 	u8 __iomem * xl_mmio = xl_priv->xl_mmio ; 
 
 	switch (srb_cmd) { 
@@ -1748,7 +1748,7 @@ static void xl_srb_cmd(struct net_device
 
 static void xl_wait_misr_flags(struct net_device *dev) 
 {
-	struct xl_private *xl_priv = (struct xl_private *) dev->priv ; 
+	struct xl_private *xl_priv = netdev_priv(dev) ; 
 	u8 __iomem * xl_mmio = xl_priv->xl_mmio ; 
 	
 	int i  ; 
@@ -1773,7 +1773,7 @@ static void xl_wait_misr_flags(struct ne
 
 static int xl_change_mtu(struct net_device *dev, int mtu) 
 {
-	struct xl_private *xl_priv = (struct xl_private *) dev->priv;
+	struct xl_private *xl_priv = netdev_priv(dev);
 	u16 max_mtu ; 
 
 	if (xl_priv->xl_ring_speed == 4)
@@ -1795,7 +1795,7 @@ static int xl_change_mtu(struct net_devi
 static void __devexit xl_remove_one (struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
-	struct xl_private *xl_priv=(struct xl_private *)dev->priv;
+	struct xl_private *xl_priv=netdev_priv(dev);
 	
 	unregister_netdev(dev);
 	iounmap(xl_priv->xl_mmio) ; 
diff --git a/drivers/net/tokenring/ibmtr.c b/drivers/net/tokenring/ibmtr.c
index 1e8958e..5140969 100644
--- a/drivers/net/tokenring/ibmtr.c
+++ b/drivers/net/tokenring/ibmtr.c
@@ -327,7 +327,7 @@ #ifndef PCMCIA
 	release_region(dev->base_addr, IBMTR_IO_EXTENT);
 
 	{ 
-		struct tok_info *ti = (struct tok_info *) dev->priv;
+		struct tok_info *ti = netdev_priv(dev);
 		iounmap(ti->mmio);
 		iounmap(ti->sram_virt);
 	}
@@ -384,7 +384,7 @@ static int __devinit ibmtr_probe1(struct
 
 	unsigned char segment, intr=0, irq=0, i, j, cardpresent=NOTOK, temp=0;
 	void __iomem * t_mmio = NULL;
-	struct tok_info *ti = dev->priv;
+	struct tok_info *ti = netdev_priv(dev);
 	void __iomem *cd_chanid;
 	unsigned char *tchanid, ctemp;
 #ifndef PCMCIA
@@ -823,7 +823,7 @@ static unsigned char __devinit get_sram_
 
 static int __devinit trdev_init(struct net_device *dev)
 {
-	struct tok_info *ti = (struct tok_info *) dev->priv;
+	struct tok_info *ti = netdev_priv(dev);
 
 	SET_PAGE(ti->srb_page);
         ti->open_failure = NO    ;
@@ -846,7 +846,7 @@ static int tok_init_card(struct net_devi
 	unsigned long i;
 
 	PIOaddr = dev->base_addr;
-	ti = (struct tok_info *) dev->priv;
+	ti = netdev_priv(dev);
 	/* Special processing for first interrupt after reset */
 	ti->do_tok_int = FIRST_INT;
 	/* Reset adapter */
@@ -868,7 +868,7 @@ #endif
 /*****************************************************************************/
 static int tok_open(struct net_device *dev)
 {
-	struct tok_info *ti = (struct tok_info *) dev->priv;
+	struct tok_info *ti = netdev_priv(dev);
 	int i;
 
 	/*the case we were left in a failure state during a previous open */
@@ -927,7 +927,7 @@ static void tok_open_adapter(unsigned lo
 	struct tok_info *ti;
 	int i;
 
-	ti = (struct tok_info *) dev->priv;
+	ti = netdev_priv(dev);
 	SET_PAGE(ti->init_srb_page); 
 	writeb(~SRB_RESP_INT, ti->mmio + ACA_OFFSET + ACA_RESET + ISRP_ODD);
 	for (i = 0; i < sizeof(struct dir_open_adapter); i++)
@@ -962,7 +962,7 @@ static void tok_open_adapter(unsigned lo
 static void open_sap(unsigned char type, struct net_device *dev)
 {
 	int i;
-	struct tok_info *ti = (struct tok_info *) dev->priv;
+	struct tok_info *ti = netdev_priv(dev);
 
 	SET_PAGE(ti->srb_page);
 	for (i = 0; i < sizeof(struct dlc_open_sap); i++)
@@ -986,7 +986,7 @@ #define STATION_COUNT_OFST      18
 
 static void tok_set_multicast_list(struct net_device *dev)
 {
-	struct tok_info *ti = (struct tok_info *) dev->priv;
+	struct tok_info *ti = netdev_priv(dev);
 	struct dev_mc_list *mclist;
 	unsigned char address[4];
 
@@ -1029,7 +1029,7 @@ static int tok_send_packet(struct sk_buf
 {
 	struct tok_info *ti;
 	unsigned long flags;
-	ti = (struct tok_info *) dev->priv;
+	ti = netdev_priv(dev);
 
         netif_stop_queue(dev);
 
@@ -1051,7 +1051,7 @@ static int tok_send_packet(struct sk_buf
 
 static int tok_close(struct net_device *dev)
 {
-	struct tok_info *ti = (struct tok_info *) dev->priv;
+	struct tok_info *ti = netdev_priv(dev);
 
 	/* Important for PCMCIA hot unplug, otherwise, we'll pull the card, */
 	/* unloading the module from memory, and then if a timer pops, ouch */
@@ -1094,7 +1094,7 @@ static void __iomem *map_address(struct 
 
 static void dir_open_adapter (struct net_device *dev)
 {
-        struct tok_info *ti = (struct tok_info *) dev->priv;
+        struct tok_info *ti = netdev_priv(dev);
         unsigned char ret_code;
         __u16 err;
 
@@ -1179,7 +1179,7 @@ #endif
 #if TR_VERBOSE
 	DPRINTK("Int from tok_driver, dev : %p irq%d\n", dev,irq);
 #endif
-	ti = (struct tok_info *) dev->priv;
+	ti = netdev_priv(dev);
 	if (ti->sram_phys & 1)
 		return IRQ_NONE;         /* PCMCIA card extraction flag */
 	spin_lock(&(ti->lock));
@@ -1498,7 +1498,7 @@ static void initial_tok_int(struct net_d
 	struct tok_info *ti;
         unsigned char init_status; /*BMS 12/2000*/
 
-	ti = (struct tok_info *) dev->priv;
+	ti = netdev_priv(dev);
 
 	ti->do_tok_int = NOT_FIRST;
 
@@ -1560,7 +1560,7 @@ #define RSAP_VALUE_OFST         9
 
 static void tr_tx(struct net_device *dev)
 {
-	struct tok_info *ti = (struct tok_info *) dev->priv;
+	struct tok_info *ti = netdev_priv(dev);
 	struct trh_hdr *trhdr = (struct trh_hdr *) ti->current_skb->data;
 	unsigned int hdr_len;
 	__u32 dhb=0,dhb_base;
@@ -1674,7 +1674,7 @@ #define ETHERTYPE_OFST          6
 
 static void tr_rx(struct net_device *dev)
 {
-	struct tok_info *ti = (struct tok_info *) dev->priv;
+	struct tok_info *ti = netdev_priv(dev);
 	__u32 rbuffer;
 	void __iomem *rbuf, *rbufdata, *llc;
 	__u8 rbuffer_page = 0;
@@ -1846,7 +1846,7 @@ static void ibmtr_reset_timer(struct tim
 void tok_rerun(unsigned long dev_addr){
 
 	struct net_device *dev = (struct net_device *)dev_addr;
-	struct tok_info *ti = (struct tok_info *) dev->priv;
+	struct tok_info *ti = netdev_priv(dev);
 
 	if ( ti->open_action == RESTART){
 		ti->do_tok_int = FIRST_INT;
@@ -1868,7 +1868,7 @@ static void ibmtr_readlog(struct net_dev
 {
 	struct tok_info *ti;
 
-	ti = (struct tok_info *) dev->priv;
+	ti = netdev_priv(dev);
 
 	ti->readlog_pending = 0;
 	SET_PAGE(ti->srb_page);
@@ -1891,7 +1891,7 @@ static struct net_device_stats *tok_get_
 {
 
 	struct tok_info *toki;
-	toki = (struct tok_info *) dev->priv;
+	toki = netdev_priv(dev);
 	return (struct net_device_stats *) &toki->tr_stats;
 }
 
@@ -1899,7 +1899,7 @@ static struct net_device_stats *tok_get_
 
 static int ibmtr_change_mtu(struct net_device *dev, int mtu)
 {
-	struct tok_info *ti = (struct tok_info *) dev->priv;
+	struct tok_info *ti = netdev_priv(dev);
 
 	if (ti->ring_speed == 16 && mtu > ti->maxmtu16)
 		return -EINVAL;
diff --git a/drivers/net/tokenring/lanstreamer.c b/drivers/net/tokenring/lanstreamer.c
index 5d849c0..3448634 100644
--- a/drivers/net/tokenring/lanstreamer.c
+++ b/drivers/net/tokenring/lanstreamer.c
@@ -245,7 +245,7 @@ #endif
 	}
 
 	SET_MODULE_OWNER(dev);
-	streamer_priv = dev->priv;
+	streamer_priv = netdev_priv(dev);
 
 #if STREAMER_NETWORK_MONITOR
 #ifdef CONFIG_PROC_FS
@@ -404,7 +404,7 @@ #endif
 		return;
 	}
 
-	streamer_priv=dev->priv;
+	streamer_priv=netdev_priv(dev);
 	if (streamer_priv == NULL) {
 		printk(KERN_ERR "lanstreamer::streamer_remove_one, ERROR dev->priv is NULL\n");
 		return;
@@ -448,7 +448,7 @@ static int streamer_reset(struct net_dev
 	struct sk_buff *skb = NULL;
 	__u16 misr;
 
-	streamer_priv = (struct streamer_private *) dev->priv;
+	streamer_priv = netdev_priv(dev);
 	streamer_mmio = streamer_priv->streamer_mmio;
 
 	writew(readw(streamer_mmio + BCTL) | BCTL_SOFTRESET, streamer_mmio + BCTL);
@@ -587,7 +587,7 @@ #endif
 
 static int streamer_open(struct net_device *dev)
 {
-	struct streamer_private *streamer_priv = (struct streamer_private *) dev->priv;
+	struct streamer_private *streamer_priv = netdev_priv(dev);
 	__u8 __iomem *streamer_mmio = streamer_priv->streamer_mmio;
 	unsigned long flags;
 	char open_error[255];
@@ -904,7 +904,7 @@ #endif
 static void streamer_rx(struct net_device *dev)
 {
 	struct streamer_private *streamer_priv =
-	    (struct streamer_private *) dev->priv;
+	    netdev_priv(dev);
 	__u8 __iomem *streamer_mmio = streamer_priv->streamer_mmio;
 	struct streamer_rx_desc *rx_desc;
 	int rx_ring_last_received, length, frame_length, buffer_cnt = 0;
@@ -1029,7 +1029,7 @@ static irqreturn_t streamer_interrupt(in
 {
 	struct net_device *dev = (struct net_device *) dev_id;
 	struct streamer_private *streamer_priv =
-	    (struct streamer_private *) dev->priv;
+	    netdev_priv(dev);
 	__u8 __iomem *streamer_mmio = streamer_priv->streamer_mmio;
 	__u16 sisr;
 	__u16 misr;
@@ -1152,7 +1152,7 @@ static irqreturn_t streamer_interrupt(in
 static int streamer_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct streamer_private *streamer_priv =
-	    (struct streamer_private *) dev->priv;
+	    netdev_priv(dev);
 	__u8 __iomem *streamer_mmio = streamer_priv->streamer_mmio;
 	unsigned long flags ;
 
@@ -1203,7 +1203,7 @@ #endif
 static int streamer_close(struct net_device *dev)
 {
 	struct streamer_private *streamer_priv =
-	    (struct streamer_private *) dev->priv;
+	    netdev_priv(dev);
 	__u8 __iomem *streamer_mmio = streamer_priv->streamer_mmio;
 	unsigned long flags;
 	int i;
@@ -1269,7 +1269,7 @@ #endif
 static void streamer_set_rx_mode(struct net_device *dev)
 {
 	struct streamer_private *streamer_priv =
-	    (struct streamer_private *) dev->priv;
+	    netdev_priv(dev);
 	__u8 __iomem *streamer_mmio = streamer_priv->streamer_mmio;
 	__u8 options = 0;
 	struct dev_mc_list *dmi;
@@ -1328,7 +1328,7 @@ static void streamer_set_rx_mode(struct 
 
 static void streamer_srb_bh(struct net_device *dev)
 {
-	struct streamer_private *streamer_priv = (struct streamer_private *) dev->priv;
+	struct streamer_private *streamer_priv = netdev_priv(dev);
 	__u8 __iomem *streamer_mmio = streamer_priv->streamer_mmio;
 	__u16 srb_word;
 
@@ -1493,14 +1493,14 @@ static void streamer_srb_bh(struct net_d
 static struct net_device_stats *streamer_get_stats(struct net_device *dev)
 {
 	struct streamer_private *streamer_priv;
-	streamer_priv = (struct streamer_private *) dev->priv;
+	streamer_priv = netdev_priv(dev);
 	return (struct net_device_stats *) &streamer_priv->streamer_stats;
 }
 
 static int streamer_set_mac_address(struct net_device *dev, void *addr)
 {
 	struct sockaddr *saddr = addr;
-	struct streamer_private *streamer_priv = (struct streamer_private *) dev->priv;
+	struct streamer_private *streamer_priv = netdev_priv(dev);
 
 	if (netif_running(dev)) 
 	{
@@ -1525,7 +1525,7 @@ static int streamer_set_mac_address(stru
 static void streamer_arb_cmd(struct net_device *dev)
 {
 	struct streamer_private *streamer_priv =
-	    (struct streamer_private *) dev->priv;
+	    netdev_priv(dev);
 	__u8 __iomem *streamer_mmio = streamer_priv->streamer_mmio;
 	__u8 header_len;
 	__u16 frame_len, buffer_len;
@@ -1740,7 +1740,7 @@ drop_frame:
 static void streamer_asb_bh(struct net_device *dev)
 {
 	struct streamer_private *streamer_priv =
-	    (struct streamer_private *) dev->priv;
+	    netdev_priv(dev);
 	__u8 __iomem *streamer_mmio = streamer_priv->streamer_mmio;
 
 	if (streamer_priv->asb_queued == 1) 
@@ -1784,7 +1784,7 @@ static void streamer_asb_bh(struct net_d
 static int streamer_change_mtu(struct net_device *dev, int mtu)
 {
 	struct streamer_private *streamer_priv =
-	    (struct streamer_private *) dev->priv;
+	    netdev_priv(dev);
 	__u16 max_mtu;
 
 	if (streamer_priv->streamer_ring_speed == 4)
@@ -1848,7 +1848,7 @@ static int streamer_proc_info(char *buff
 static int sprintf_info(char *buffer, struct net_device *dev)
 {
 	struct streamer_private *streamer_priv =
-	    (struct streamer_private *) dev->priv;
+	    netdev_priv(dev);
 	__u8 __iomem *streamer_mmio = streamer_priv->streamer_mmio;
 	struct streamer_adapter_addr_table sat;
 	struct streamer_parameters_table spt;
diff --git a/drivers/net/tokenring/madgemc.c b/drivers/net/tokenring/madgemc.c
index f8f4d74..9eafc2e 100644
--- a/drivers/net/tokenring/madgemc.c
+++ b/drivers/net/tokenring/madgemc.c
@@ -690,7 +690,7 @@ static int madgemc_close(struct net_devi
 static int madgemc_mcaproc(char *buf, int slot, void *d) 
 {	
 	struct net_device *dev = (struct net_device *)d;
-	struct net_local *tp = dev->priv;
+	struct net_local *tp = netdev_priv(dev);
 	struct card_info *curcard = tp->tmspriv;
 	int len = 0;
 	
@@ -736,7 +736,7 @@ static int __devexit madgemc_remove(stru
 
 	BUG_ON(!dev);
 
-	tp = dev->priv;
+	tp = netdev_priv(dev);
 	card = tp->tmspriv;
 	kfree(card);
 	tp->tmspriv = NULL;
diff --git a/drivers/net/tokenring/olympic.c b/drivers/net/tokenring/olympic.c
index 09b3cfb..a96784e 100644
--- a/drivers/net/tokenring/olympic.c
+++ b/drivers/net/tokenring/olympic.c
@@ -219,14 +219,14 @@ static int __devinit olympic_probe(struc
 		goto op_release_dev;
 	}
 
-	olympic_priv = dev->priv ;
+	olympic_priv = netdev_priv(dev) ;
 	
 	spin_lock_init(&olympic_priv->olympic_lock) ; 
 
 	init_waitqueue_head(&olympic_priv->srb_wait);
 	init_waitqueue_head(&olympic_priv->trb_wait);
 #if OLYMPIC_DEBUG  
-	printk(KERN_INFO "pci_device: %p, dev:%p, dev->priv: %p\n", pdev, dev, dev->priv);
+	printk(KERN_INFO "pci_device: %p, dev:%p, dev->priv: %p\n", pdev, dev, netdev_priv(dev));
 #endif
 	dev->irq=pdev->irq;
 	dev->base_addr=pci_resource_start(pdev, 0);
@@ -297,7 +297,7 @@ static int __devinit olympic_init(struct
 	unsigned long t; 
 	unsigned int uaa_addr;
 
-    	olympic_priv=(struct olympic_private *)dev->priv;
+    	olympic_priv=netdev_priv(dev);
 	olympic_mmio=olympic_priv->olympic_mmio;
 
 	printk("%s \n", version);
@@ -435,7 +435,7 @@ #endif
 
 static int olympic_open(struct net_device *dev) 
 {
-	struct olympic_private *olympic_priv=(struct olympic_private *)dev->priv;
+	struct olympic_private *olympic_priv=netdev_priv(dev);
 	u8 __iomem *olympic_mmio=olympic_priv->olympic_mmio,*init_srb;
 	unsigned long flags, t;
 	int i, open_finished = 1 ;
@@ -755,7 +755,7 @@ out:
  */
 static void olympic_rx(struct net_device *dev)
 {
-	struct olympic_private *olympic_priv=(struct olympic_private *)dev->priv;
+	struct olympic_private *olympic_priv=netdev_priv(dev);
 	u8 __iomem *olympic_mmio=olympic_priv->olympic_mmio;
 	struct olympic_rx_status *rx_status;
 	struct olympic_rx_desc *rx_desc ; 
@@ -897,7 +897,7 @@ #endif
 
 static void olympic_freemem(struct net_device *dev) 
 { 
-	struct olympic_private *olympic_priv=(struct olympic_private *)dev->priv;
+	struct olympic_private *olympic_priv=netdev_priv(dev);
 	int i;
 			
 	for(i=0;i<OLYMPIC_RX_RING_SIZE;i++) {
@@ -930,7 +930,7 @@ static void olympic_freemem(struct net_d
 static irqreturn_t olympic_interrupt(int irq, void *dev_id) 
 {
 	struct net_device *dev= (struct net_device *)dev_id;
-	struct olympic_private *olympic_priv=(struct olympic_private *)dev->priv;
+	struct olympic_private *olympic_priv=netdev_priv(dev);
 	u8 __iomem *olympic_mmio=olympic_priv->olympic_mmio;
 	u32 sisr;
 	u8 __iomem *adapter_check_area ; 
@@ -1046,7 +1046,7 @@ static irqreturn_t olympic_interrupt(int
 
 static int olympic_xmit(struct sk_buff *skb, struct net_device *dev) 
 {
-	struct olympic_private *olympic_priv=(struct olympic_private *)dev->priv;
+	struct olympic_private *olympic_priv=netdev_priv(dev);
 	u8 __iomem *olympic_mmio=olympic_priv->olympic_mmio;
 	unsigned long flags ; 
 
@@ -1077,7 +1077,7 @@ static int olympic_xmit(struct sk_buff *
 
 static int olympic_close(struct net_device *dev) 
 {
-	struct olympic_private *olympic_priv=(struct olympic_private *)dev->priv;
+	struct olympic_private *olympic_priv=netdev_priv(dev);
 	u8 __iomem *olympic_mmio=olympic_priv->olympic_mmio,*srb;
 	unsigned long t,flags;
 
@@ -1147,7 +1147,7 @@ #endif
 
 static void olympic_set_rx_mode(struct net_device *dev) 
 {
-	struct olympic_private *olympic_priv = (struct olympic_private *) dev->priv ; 
+	struct olympic_private *olympic_priv = netdev_priv(dev) ; 
    	u8 __iomem *olympic_mmio = olympic_priv->olympic_mmio ; 
 	u8 options = 0; 
 	u8 __iomem *srb;
@@ -1215,7 +1215,7 @@ static void olympic_set_rx_mode(struct n
 
 static void olympic_srb_bh(struct net_device *dev) 
 { 
-	struct olympic_private *olympic_priv = (struct olympic_private *) dev->priv ; 
+	struct olympic_private *olympic_priv = netdev_priv(dev) ; 
    	u8 __iomem *olympic_mmio = olympic_priv->olympic_mmio ; 
 	u8 __iomem *srb;
 
@@ -1361,14 +1361,14 @@ static void olympic_srb_bh(struct net_de
 static struct net_device_stats * olympic_get_stats(struct net_device *dev)
 {
 	struct olympic_private *olympic_priv ;
-	olympic_priv=(struct olympic_private *) dev->priv;
+	olympic_priv=netdev_priv(dev);
 	return (struct net_device_stats *) &olympic_priv->olympic_stats; 
 }
 
 static int olympic_set_mac_address (struct net_device *dev, void *addr) 
 {
 	struct sockaddr *saddr = addr ; 
-	struct olympic_private *olympic_priv = (struct olympic_private *)dev->priv ; 
+	struct olympic_private *olympic_priv = netdev_priv(dev) ; 
 
 	if (netif_running(dev)) { 
 		printk(KERN_WARNING "%s: Cannot set mac/laa address while card is open\n", dev->name) ; 
@@ -1389,7 +1389,7 @@ static int olympic_set_mac_address (stru
 
 static void olympic_arb_cmd(struct net_device *dev)
 {
-	struct olympic_private *olympic_priv = (struct olympic_private *) dev->priv;
+	struct olympic_private *olympic_priv = netdev_priv(dev);
 	u8 __iomem *olympic_mmio=olympic_priv->olympic_mmio;
 	u8 __iomem *arb_block, *asb_block, *srb  ; 
 	u8 header_len ; 
@@ -1575,7 +1575,7 @@ drop_frame:
 
 static void olympic_asb_bh(struct net_device *dev) 
 {
-	struct olympic_private *olympic_priv = (struct olympic_private *) dev->priv ; 
+	struct olympic_private *olympic_priv = netdev_priv(dev) ; 
 	u8 __iomem *arb_block, *asb_block ; 
 
 	arb_block = (olympic_priv->olympic_lap + olympic_priv->arb) ; 
@@ -1615,7 +1615,7 @@ static void olympic_asb_bh(struct net_de
  
 static int olympic_change_mtu(struct net_device *dev, int mtu) 
 {
-	struct olympic_private *olympic_priv = (struct olympic_private *) dev->priv;
+	struct olympic_private *olympic_priv = netdev_priv(dev);
 	u16 max_mtu ; 
 
 	if (olympic_priv->olympic_ring_speed == 4)
@@ -1637,7 +1637,7 @@ static int olympic_change_mtu(struct net
 static int olympic_proc_info(char *buffer, char **start, off_t offset, int length, int *eof, void *data)
 {
 	struct net_device *dev = (struct net_device *)data ; 
-	struct olympic_private *olympic_priv=(struct olympic_private *)dev->priv;
+	struct olympic_private *olympic_priv=netdev_priv(dev);
 	u8 __iomem *oat = (olympic_priv->olympic_lap + olympic_priv->olympic_addr_table_addr) ; 
 	u8 __iomem *opt = (olympic_priv->olympic_lap + olympic_priv->olympic_parms_addr) ; 
 	int size = 0 ; 
@@ -1748,7 +1748,7 @@ static int olympic_proc_info(char *buffe
 static void __devexit olympic_remove_one(struct pci_dev *pdev) 
 {
 	struct net_device *dev = pci_get_drvdata(pdev) ; 
-	struct olympic_private *olympic_priv=(struct olympic_private *)dev->priv;
+	struct olympic_private *olympic_priv=netdev_priv(dev);
 
 	if (olympic_priv->olympic_network_monitor) { 
 		char proc_name[20] ; 
diff --git a/drivers/net/tokenring/tmspci.c b/drivers/net/tokenring/tmspci.c
index 3b2f00b..aec75c9 100644
--- a/drivers/net/tokenring/tmspci.c
+++ b/drivers/net/tokenring/tmspci.c
@@ -149,7 +149,7 @@ static int __devinit tms_pci_attach(stru
 		goto err_out_irq;
 	}
 
-	tp = dev->priv;
+	tp = netdev_priv(dev);
 	tp->setnselout = tms_pci_setnselout_pins;
 		
 	tp->sifreadb = tms_pci_sifreadb;
@@ -210,7 +210,7 @@ static void tms_pci_read_eeprom(struct n
 static unsigned short tms_pci_setnselout_pins(struct net_device *dev)
 {
 	unsigned short val = 0;
-	struct net_local *tp = dev->priv;
+	struct net_local *tp = netdev_priv(dev);
 	struct card_info *cardinfo = tp->tmspriv;
   
 	if(tp->DataRate == SPEED_4)
