From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: [PATCH][ATM]: [eni] fix __iomem related warnings
Date: Thu, 23 Sep 2004 14:41:38 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409231841.i8NIfaoj018070@ginger.cmf.nrl.navy.mil>
Reply-To: chas3@users.sourceforge.net
Cc: davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

dave,

this one was quite troublesome to fix.  please apply to 2.x

thanks!

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/09/23 10:29:01-04:00 chas@relax.cmf.nrl.navy.mil 
#   [ATM]: [eni] fix __iomem related warnings
# 
diff -Nru a/drivers/atm/eni.c b/drivers/atm/eni.c
--- a/drivers/atm/eni.c	2004-09-23 14:38:34 -04:00
+++ b/drivers/atm/eni.c	2004-09-23 14:38:34 -04:00
@@ -173,7 +173,7 @@
 	int i;
 
 	for (i = 0; i < eni_dev->free_len; i++)
-		printk(KERN_DEBUG "  %d: 0x%lx %d\n",i,
+		printk(KERN_DEBUG "  %d: %p %d\n",i,
 		    eni_dev->free_list[i].start,
 		    1 << eni_dev->free_list[i].order);
 }
@@ -191,19 +191,19 @@
 	printk(KERN_NOTICE "TX buffers\n");
 	for (i = 0; i < NR_CHAN; i++)
 		if (eni_dev->tx[i].send)
-			printk(KERN_NOTICE "  TX %d @ 0x%lx: %ld\n",i,
+			printk(KERN_NOTICE "  TX %d @ %p: %ld\n",i,
 			    eni_dev->tx[i].send,eni_dev->tx[i].words*4);
 	printk(KERN_NOTICE "RX buffers\n");
 	for (i = 0; i < 1024; i++)
 		if (eni_dev->rx_map[i] && ENI_VCC(eni_dev->rx_map[i])->rx)
-			printk(KERN_NOTICE "  RX %d @ 0x%lx: %ld\n",i,
+			printk(KERN_NOTICE "  RX %d @ %p: %ld\n",i,
 			    ENI_VCC(eni_dev->rx_map[i])->recv,
 			    ENI_VCC(eni_dev->rx_map[i])->words*4);
 	printk(KERN_NOTICE "----\n");
 }
 
 
-static void eni_put_free(struct eni_dev *eni_dev,unsigned long start,
+static void eni_put_free(struct eni_dev *eni_dev, void __iomem *start,
     unsigned long size)
 {
 	struct eni_free *list;
@@ -215,17 +215,17 @@
 	len = eni_dev->free_len;
 	while (size) {
 		if (len >= eni_dev->free_list_size) {
-			printk(KERN_CRIT "eni_put_free overflow (0x%lx,%ld)\n",
+			printk(KERN_CRIT "eni_put_free overflow (%p,%ld)\n",
 			    start,size);
 			break;
 		}
-		for (order = 0; !((start | size) & (1 << order)); order++);
+		for (order = 0; !(((unsigned long)start | size) & (1 << order)); order++);
 		if (MID_MIN_BUF_SIZE > (1 << order)) {
 			printk(KERN_CRIT "eni_put_free: order %d too small\n",
 			    order);
 			break;
 		}
-		list[len].start = start;
+		list[len].start = (void __iomem *) start;
 		list[len].order = order;
 		len++;
 		start += 1 << order;
@@ -236,10 +236,10 @@
 }
 
 
-static unsigned long eni_alloc_mem(struct eni_dev *eni_dev,unsigned long *size)
+static void __iomem *eni_alloc_mem(struct eni_dev *eni_dev, unsigned long *size)
 {
 	struct eni_free *list;
-	unsigned long start;
+	void __iomem *start;
 	int len,i,order,best_order,index;
 
 	list = eni_dev->free_list;
@@ -273,7 +273,7 @@
 }
 
 
-static void eni_free_mem(struct eni_dev *eni_dev,unsigned long start,
+static void eni_free_mem(struct eni_dev *eni_dev, void __iomem *start,
     unsigned long size)
 {
 	struct eni_free *list;
@@ -283,20 +283,20 @@
 	list = eni_dev->free_list;
 	len = eni_dev->free_len;
 	for (order = -1; size; order++) size >>= 1;
-	DPRINTK("eni_free_mem: 0x%lx+0x%lx (order %d)\n",start,size,order);
+	DPRINTK("eni_free_mem: %p+0x%lx (order %d)\n",start,size,order);
 	for (i = 0; i < len; i++)
-		if (list[i].start == (start^(1 << order)) &&
+		if (((unsigned long) list[i].start) == ((unsigned long)start^(1 << order)) &&
 		    list[i].order == order) {
 			DPRINTK("match[%d]: 0x%lx/0x%lx(0x%x), %d/%d\n",i,
 			    list[i].start,start,1 << order,list[i].order,order);
 			list[i] = list[--len];
-			start &= ~(unsigned long) (1 << order);
+			start = (void __iomem *) ((unsigned long) start & ~(unsigned long) (1 << order));
 			order++;
 			i = -1;
 			continue;
 		}
 	if (len >= eni_dev->free_list_size) {
-		printk(KERN_ALERT "eni_free_mem overflow (0x%lx,%d)\n",start,
+		printk(KERN_ALERT "eni_free_mem overflow (%p,%d)\n",start,
 		    order);
 		return;
 	}
@@ -333,7 +333,7 @@
 	printk(KERN_ALERT "  host descr 0x%lx, rx pos 0x%lx, descr value "
 	    "0x%x\n",eni_vcc->descr,eni_vcc->rx_pos,
 	    (unsigned) readl(eni_vcc->recv+eni_vcc->descr*4));
-	printk(KERN_ALERT "  last 0x%p, servicing %d\n",eni_vcc->last,
+	printk(KERN_ALERT "  last %p, servicing %d\n",eni_vcc->last,
 	    eni_vcc->servicing);
 	EVENT("---dump ends here---\n",0,0);
 	printk(KERN_NOTICE "---recent events---\n");
@@ -617,7 +617,8 @@
 
 static inline int rx_vcc(struct atm_vcc *vcc)
 {
-	unsigned long vci_dsc,tmp;
+	void __iomem *vci_dsc;
+	unsigned long tmp;
 	struct eni_vcc *eni_vcc;
 
 	eni_vcc = ENI_VCC(vcc);
@@ -728,7 +729,7 @@
 	struct eni_vcc *eni_vcc;
 	struct atm_vcc *vcc;
 	struct sk_buff *skb;
-	unsigned long vci_dsc;
+	void __iomem *vci_dsc;
 	int first;
 
 	eni_dev = ENI_DEV(dev);
@@ -808,7 +809,7 @@
 
 static int open_rx_second(struct atm_vcc *vcc)
 {
-	unsigned long here;
+	void __iomem *here;
 	struct eni_dev *eni_dev;
 	struct eni_vcc *eni_vcc;
 	unsigned long size;
@@ -840,7 +841,7 @@
 static void close_rx(struct atm_vcc *vcc)
 {
 	DECLARE_WAITQUEUE(wait,current);
-	unsigned long here;
+	void __iomem *here;
 	struct eni_dev *eni_dev;
 	struct eni_vcc *eni_vcc;
 
@@ -1289,7 +1290,8 @@
 	struct eni_dev *eni_dev = ENI_DEV(vcc->dev);
 	struct eni_vcc *eni_vcc = ENI_VCC(vcc);
 	struct eni_tx *tx;
-	unsigned long size,mem;
+	unsigned long size;
+	void __iomem *mem;
 	int rate,ubr,unlimited,new_tx;
 	int pre,res,order;
 	int error;
@@ -1687,9 +1689,9 @@
 #undef GET_SEPROM
 
 
-static int __devinit get_esi_fpga(struct atm_dev *dev,unsigned long base)
+static int __devinit get_esi_fpga(struct atm_dev *dev, void __iomem *base)
 {
-	unsigned long mac_base;
+	void __iomem *mac_base;
 	int i;
 
 	mac_base = base+EPROM_SIZE-sizeof(struct midway_eprom);
@@ -1703,7 +1705,8 @@
 	struct midway_eprom *eprom;
 	struct eni_dev *eni_dev;
 	struct pci_dev *pci_dev;
-	unsigned long real_base,base;
+	unsigned long real_base;
+	void __iomem *base;
 	unsigned char revision;
 	int error,i,last;
 
@@ -1730,13 +1733,13 @@
 	}
 	printk(KERN_NOTICE DEV_LABEL "(itf %d): rev.%d,base=0x%lx,irq=%d,",
 	    dev->number,revision,real_base,eni_dev->irq);
-	if (!(base = (unsigned long) ioremap_nocache(real_base,MAP_MAX_SIZE))) {
+	if (!(base = ioremap_nocache(real_base,MAP_MAX_SIZE))) {
 		printk("\n");
 		printk(KERN_ERR DEV_LABEL "(itf %d): can't set up page "
 		    "mapping\n",dev->number);
 		return error;
 	}
-	eni_dev->base_diff = real_base-base;
+	eni_dev->base_diff = real_base - (unsigned long) base;
 	/* id may not be present in ASIC Tonga boards - check this @@@ */
 	if (!eni_dev->asic) {
 		eprom = (struct midway_eprom *) (base+EPROM_SIZE-sizeof(struct
@@ -1790,7 +1793,9 @@
 static int __devinit eni_start(struct atm_dev *dev)
 {
 	struct eni_dev *eni_dev;
-	unsigned long buf,buffer_mem;
+	
+	void __iomem *buf;
+	unsigned long buffer_mem;
 	int error;
 
 	DPRINTK(">eni_start\n");
@@ -1828,7 +1833,7 @@
 	tasklet_init(&eni_dev->task,eni_tasklet,(unsigned long) dev);
 	eni_dev->events = 0;
 	/* initialize memory management */
-	buffer_mem = eni_dev->mem-(buf-eni_dev->ram);
+	buffer_mem = eni_dev->mem - (buf - eni_dev->ram);
 	eni_dev->free_list_size = buffer_mem/MID_MIN_BUF_SIZE/2;
 	eni_dev->free_list = (struct eni_free *) kmalloc(
 	    sizeof(struct eni_free)*(eni_dev->free_list_size+1),GFP_KERNEL);
@@ -1955,7 +1960,7 @@
 	 */
 	tasklet_disable(&eni_dev->task);
 	skb_queue_walk(&eni_dev->tx_queue, skb) {
-		unsigned long dsc;
+		void __iomem *dsc;
 
 		if (ATM_SKB(skb)->vcc != vcc) continue;
 		dsc = tx->send+ENI_PRV_POS(skb)*4;
@@ -2136,9 +2141,9 @@
 
 		if (!tx->send) continue;
 		if (!--left) {
-			return sprintf(page,"tx[%d]:    0x%06lx-0x%06lx "
+			return sprintf(page,"tx[%d]:    0x%ld-0x%ld "
 			    "(%6ld bytes), rsv %d cps, shp %d cps%s\n",i,
-			    tx->send-eni_dev->ram,
+			    (unsigned long) (tx->send - eni_dev->ram),
 			    tx->send-eni_dev->ram+tx->words*4-1,tx->words*4,
 			    tx->reserved,tx->shaping,
 			    tx == eni_dev->ubr ? " (UBR)" : "");
@@ -2162,9 +2167,9 @@
 			if (--left) continue;
 			length = sprintf(page,"vcc %4d: ",vcc->vci);
 			if (eni_vcc->rx) {
-				length += sprintf(page+length,"0x%06lx-0x%06lx "
+				length += sprintf(page+length,"0x%ld-0x%ld "
 				    "(%6ld bytes)",
-				    eni_vcc->recv-eni_dev->ram,
+				    (unsigned long) (eni_vcc->recv - eni_dev->ram),
 				    eni_vcc->recv-eni_dev->ram+eni_vcc->words*4-1,
 				    eni_vcc->words*4);
 				if (eni_vcc->tx) length += sprintf(page+length,", ");
@@ -2183,8 +2188,8 @@
 		unsigned long offset;
 
 		if (--left) continue;
-		offset = eni_dev->ram+eni_dev->base_diff;
-		return sprintf(page,"free      0x%06lx-0x%06lx (%6d bytes)\n",
+		offset = (unsigned long) eni_dev->ram+eni_dev->base_diff;
+		return sprintf(page,"free      %p-%p (%6d bytes)\n",
 		    fe->start-offset,fe->start-offset+(1 << fe->order)-1,
 		    1 << fe->order);
 	}
diff -Nru a/drivers/atm/eni.h b/drivers/atm/eni.h
--- a/drivers/atm/eni.h	2004-09-23 14:38:34 -04:00
+++ b/drivers/atm/eni.h	2004-09-23 14:38:34 -04:00
@@ -33,12 +33,12 @@
 
 
 struct eni_free {
-	unsigned long start;		/* counting in bytes */
+	void __iomem *start;		/* counting in bytes */
 	int order;
 };
 
 struct eni_tx {
-	unsigned long send;		/* base, 0 if unused */
+	void __iomem *send;		/* base, 0 if unused */
 	int prescaler;			/* shaping prescaler */
 	int resolution;			/* shaping divider */
 	unsigned long tx_pos;		/* current TX write position */
@@ -51,7 +51,7 @@
 
 struct eni_vcc {
 	int (*rx)(struct atm_vcc *vcc);	/* RX function, NULL if none */
-	unsigned long recv;		/* receive buffer */
+	void __iomem *recv;		/* receive buffer */
 	unsigned long words;		/* its size in words */
 	unsigned long descr;		/* next descriptor (RX) */
 	unsigned long rx_pos;		/* current RX descriptor pos */
@@ -72,13 +72,13 @@
 	u32 events;			/* pending events */
 	/*-------------------------------- base pointers into Midway address
 					   space */
-	unsigned long phy;		/* PHY interface chip registers */
-	unsigned long reg;		/* register base */
-	unsigned long ram;		/* RAM base */
-	unsigned long vci;		/* VCI table */
-	unsigned long rx_dma;		/* RX DMA queue */
-	unsigned long tx_dma;		/* TX DMA queue */
-	unsigned long service;		/* service list */
+	void __iomem *phy;		/* PHY interface chip registers */
+	void __iomem *reg;		/* register base */
+	void __iomem *ram;		/* RAM base */
+	void __iomem *vci;		/* VCI table */
+	void __iomem *rx_dma;		/* RX DMA queue */
+	void __iomem *tx_dma;		/* TX DMA queue */
+	void __iomem *service;		/* service list */
 	/*-------------------------------- TX part */
 	struct eni_tx tx[NR_CHAN];	/* TX channels */
 	struct eni_tx *ubr;		/* UBR channel */
