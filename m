From: chas williams <chas@cmf.nrl.navy.mil>
Subject: Re: [Linux-ATM-General] Re: [atmdrvr zatm] Remove obsolete EXACT_TS support
Date: Thu, 31 Jul 2003 10:23:58 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307311426.h6VEQgsG023826@ginger.cmf.nrl.navy.mil>
References: <20030730225741.GA57991@gaz.sfgoth.com>
Reply-To: chas3@users.sourceforge.net
Cc: davem@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitchell Blank Jr <mitch@sfgoth.com>
In-reply-to: Your message of "Wed, 30 Jul 2003 15:57:42 PDT."
             <20030730225741.GA57991@gaz.sfgoth.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

please apply to 2.6.  zatm will now compile on smp.  it might 
actually work if someone had some hardware to test it.


[atm]: [zatm] convert cli() to spinlock

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1597  -> 1.1598 
#	  drivers/atm/zatm.c	1.13    -> 1.14   
#	drivers/atm/uPD98402.c	1.4     -> 1.5    
#	  drivers/atm/zatm.h	1.2     -> 1.3    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/07/31	chas@relax.cmf.nrl.navy.mil	1.1598
# [zatm] convert cli() to spinlock
# --------------------------------------------
#
diff -Nru a/drivers/atm/uPD98402.c b/drivers/atm/uPD98402.c
--- a/drivers/atm/uPD98402.c	Thu Jul 31 10:25:25 2003
+++ b/drivers/atm/uPD98402.c	Thu Jul 31 10:25:25 2003
@@ -27,6 +27,7 @@
 	struct k_sonet_stats sonet_stats;/* link diagnostics */
 	unsigned char framing;		/* SONET/SDH framing */
 	int loop_mode;			/* loopback mode */
+	spinlock_t lock;
 };
 
 
@@ -71,14 +72,13 @@
 		default:
 			return -EINVAL;
 	}
-	save_flags(flags);
-	cli();
+	spin_lock_irqsave(&PRIV(dev)->lock, flags);
 	PUT(set[0],C11T);
 	PUT(set[1],C12T);
 	PUT(set[2],C13T);
 	PUT((GET(MDR) & ~uPD98402_MDR_SS_MASK) | (set[3] <<
 	    uPD98402_MDR_SS_SHIFT),MDR);
-	restore_flags(flags);
+	spin_unlock_irqrestore(&PRIV(dev)->lock, flags);
 	return 0;
 }
 
@@ -88,12 +88,11 @@
 	unsigned long flags;
 	unsigned char s[3];
 
-	save_flags(flags);
-	cli();
+	spin_lock_irqsave(&PRIV(dev)->lock, flags);
 	s[0] = GET(C11R);
 	s[1] = GET(C12R);
 	s[2] = GET(C13R);
-	restore_flags(flags);
+	spin_unlock_irqrestore(&PRIV(dev)->lock, flags);
 	return (put_user(s[0], arg) || put_user(s[1], arg+1) ||
 	    put_user(s[2], arg+2) || put_user(0xff, arg+3) ||
 	    put_user(0xff, arg+4) || put_user(0xff, arg+5)) ? -EFAULT : 0;
@@ -214,6 +213,7 @@
 	DPRINTK("phy_start\n");
 	if (!(PRIV(dev) = kmalloc(sizeof(struct uPD98402_priv),GFP_KERNEL)))
 		return -ENOMEM;
+	spin_lock_init(&PRIV(dev)->lock);
 	memset(&PRIV(dev)->sonet_stats,0,sizeof(struct k_sonet_stats));
 	(void) GET(PCR); /* clear performance events */
 	PUT(uPD98402_PFM_FJ,PCMR); /* ignore frequency adj */
diff -Nru a/drivers/atm/zatm.c b/drivers/atm/zatm.c
--- a/drivers/atm/zatm.c	Thu Jul 31 10:25:25 2003
+++ b/drivers/atm/zatm.c	Thu Jul 31 10:25:25 2003
@@ -195,11 +195,10 @@
 		    sizeof(struct rx_buffer_head);
 	}
 	size += align;
-	save_flags(flags);
-	cli();
+	spin_lock_irqsave(&zatm_dev->lock, flags);
 	free = zpeekl(zatm_dev,zatm_dev->pool_base+2*pool) &
 	    uPD98401_RXFP_REMAIN;
-	restore_flags(flags);
+	spin_unlock_irqrestore(&zatm_dev->lock, flags);
 	if (free >= zatm_dev->pool_info[pool].low_water) return;
 	EVENT("starting ... POOL: 0x%x, 0x%x\n",
 	    zpeekl(zatm_dev,zatm_dev->pool_base+2*pool),
@@ -228,22 +227,22 @@
 		head->skb = skb;
 		EVENT("enq skb 0x%08lx/0x%08lx\n",(unsigned long) skb,
 		    (unsigned long) head);
-		cli();
+		spin_lock_irqsave(&zatm_dev->lock, flags);
 		if (zatm_dev->last_free[pool])
 			((struct rx_buffer_head *) (zatm_dev->last_free[pool]->
 			    data))[-1].link = virt_to_bus(head);
 		zatm_dev->last_free[pool] = skb;
 		skb_queue_tail(&zatm_dev->pool[pool],skb);
-		restore_flags(flags);
+		spin_unlock_irqrestore(&zatm_dev->lock, flags);
 		free++;
 	}
 	if (first) {
-		cli();
+		spin_lock_irqsave(&zatm_dev->lock, flags);
 		zwait;
 		zout(virt_to_bus(first),CER);
 		zout(uPD98401_ADD_BAT | (pool << uPD98401_POOL_SHIFT) | count,
 		    CMR);
-		restore_flags(flags);
+		spin_unlock_irqrestore(&zatm_dev->lock, flags);
 		EVENT ("POOL: 0x%x, 0x%x\n",
 		    zpeekl(zatm_dev,zatm_dev->pool_base+2*pool),
 		    zpeekl(zatm_dev,zatm_dev->pool_base+2*pool+1));
@@ -286,8 +285,7 @@
 		size = pool-ZATM_AAL5_POOL_BASE;
 		if (size < 0) size = 0; /* 64B... */
 		else if (size > 10) size = 10; /* ... 64kB */
-		save_flags(flags);
-		cli();
+		spin_lock_irqsave(&zatm_dev->lock, flags);
 		zpokel(zatm_dev,((zatm_dev->pool_info[pool].low_water/4) <<
 		    uPD98401_RXFP_ALERT_SHIFT) |
 		    (1 << uPD98401_RXFP_BTSZ_SHIFT) |
@@ -295,7 +293,7 @@
 		    zatm_dev->pool_base+pool*2);
 		zpokel(zatm_dev,(unsigned long) dummy,zatm_dev->pool_base+
 		    pool*2+1);
-		restore_flags(flags);
+		spin_unlock_irqrestore(&zatm_dev->lock, flags);
 		zatm_dev->last_free[pool] = NULL;
 		refill_pool(dev,pool);
 	}
@@ -315,29 +313,29 @@
 {
 	struct zatm_pool_info *pool;
 	unsigned long offset,flags;
+	struct zatm_dev *zatm_dev = ZATM_DEV(vcc->dev);
 
 	DPRINTK("start 0x%08lx dest 0x%08lx len %d\n",start,dest,len);
 	if (len < PAGE_SIZE) return;
-	pool = &ZATM_DEV(vcc->dev)->pool_info[ZATM_VCC(vcc)->pool];
+	pool = &zatm_dev->pool_info[ZATM_VCC(vcc)->pool];
 	offset = (dest-start) & (PAGE_SIZE-1);
-	save_flags(flags);
-	cli();
+	spin_lock_irqsave(&zatm_dev->lock, flags);
 	if (!offset || pool->offset == offset) {
 		pool->next_cnt = 0;
-		restore_flags(flags);
+		spin_unlock_irqrestore(&zatm_dev->lock, flags);
 		return;
 	}
 	if (offset != pool->next_off) {
 		pool->next_off = offset;
 		pool->next_cnt = 0;
-		restore_flags(flags);
+		spin_unlock_irqrestore(&zatm_dev->lock, flags);
 		return;
 	}
 	if (++pool->next_cnt >= pool->next_thres) {
 		pool->offset = pool->next_off;
 		pool->next_cnt = 0;
 	}
-	restore_flags(flags);
+	spin_unlock_irqrestore(&zatm_dev->lock, flags);
 }
 
 /*----------------------------------- RX ------------------------------------*/
@@ -535,20 +533,19 @@
 		zatm_vcc->pool = ZATM_AAL0_POOL;
 	}
 	if (zatm_vcc->pool < 0) return -EMSGSIZE;
-	save_flags(flags);
-	cli();
+	spin_lock_irqsave(&zatm_dev->lock, flags);
 	zwait;
 	zout(uPD98401_OPEN_CHAN,CMR);
 	zwait;
 	DPRINTK("0x%x 0x%x\n",zin(CMR),zin(CER));
 	chan = (zin(CMR) & uPD98401_CHAN_ADDR) >> uPD98401_CHAN_ADDR_SHIFT;
-	restore_flags(flags);
+	spin_unlock_irqrestore(&zatm_dev->lock, flags);
 	DPRINTK("chan is %d\n",chan);
 	if (!chan) return -EAGAIN;
 	use_pool(vcc->dev,zatm_vcc->pool);
 	DPRINTK("pool %d\n",zatm_vcc->pool);
 	/* set up VC descriptor */
-	cli();
+	spin_lock_irqsave(&zatm_dev->lock, flags);
 	zpokel(zatm_dev,zatm_vcc->pool << uPD98401_RXVC_POOL_SHIFT,
 	    chan*VC_SIZE/4);
 	zpokel(zatm_dev,uPD98401_RXVC_OD | (vcc->qos.aal == ATM_AAL5 ?
@@ -556,7 +553,7 @@
 	zpokel(zatm_dev,0,chan*VC_SIZE/4+2);
 	zatm_vcc->rx_chan = chan;
 	zatm_dev->rx_map[chan] = vcc;
-	restore_flags(flags);
+	spin_unlock_irqrestore(&zatm_dev->lock, flags);
 	return 0;
 }
 
@@ -572,14 +569,13 @@
 	zatm_dev = ZATM_DEV(vcc->dev);
 	zatm_vcc = ZATM_VCC(vcc);
 	if (!zatm_vcc->rx_chan) return 0;
-	save_flags(flags);
-	cli();
+	spin_lock_irqsave(&zatm_dev->lock, flags);
 	/* should also handle VPI @@@ */
 	pos = vcc->vci >> 1;
 	shift = (1-(vcc->vci & 1)) << 4;
 	zpokel(zatm_dev,(zpeekl(zatm_dev,pos) & ~(0xffff << shift)) |
 	    ((zatm_vcc->rx_chan | uPD98401_RXLT_ENBL) << shift),pos);
-	restore_flags(flags);
+	spin_unlock_irqrestore(&zatm_dev->lock, flags);
 	return 0;
 }
 
@@ -596,9 +592,8 @@
 	if (!zatm_vcc->rx_chan) return;
 	DPRINTK("close_rx\n");
 	/* disable receiver */
-	save_flags(flags);
 	if (vcc->vpi != ATM_VPI_UNSPEC && vcc->vci != ATM_VCI_UNSPEC) {
-		cli();
+		spin_lock_irqsave(&zatm_dev->lock, flags);
 		pos = vcc->vci >> 1;
 		shift = (1-(vcc->vci & 1)) << 4;
 		zpokel(zatm_dev,zpeekl(zatm_dev,pos) & ~(0xffff << shift),pos);
@@ -606,9 +601,9 @@
 		zout(uPD98401_NOP,CMR);
 		zwait;
 		zout(uPD98401_NOP,CMR);
-		restore_flags(flags);
+		spin_unlock_irqrestore(&zatm_dev->lock, flags);
 	}
-	cli();
+	spin_lock_irqsave(&zatm_dev->lock, flags);
 	zwait;
 	zout(uPD98401_DEACT_CHAN | uPD98401_CHAN_RT | (zatm_vcc->rx_chan <<
 	    uPD98401_CHAN_ADDR_SHIFT),CMR);
@@ -620,7 +615,7 @@
 	if (!(zin(CMR) & uPD98401_CHAN_ADDR))
 		printk(KERN_CRIT DEV_LABEL "(itf %d): can't close RX channel "
 		    "%d\n",vcc->dev->number,zatm_vcc->rx_chan);
-	restore_flags(flags);
+	spin_unlock_irqrestore(&zatm_dev->lock, flags);
 	zatm_dev->rx_map[zatm_vcc->rx_chan] = NULL;
 	zatm_vcc->rx_chan = 0;
 	unuse_pool(vcc->dev,zatm_vcc->pool);
@@ -673,11 +668,10 @@
 	zatm_dev = ZATM_DEV(vcc->dev);
 	zatm_vcc = ZATM_VCC(vcc);
 	EVENT("iovcnt=%d\n",skb_shinfo(skb)->nr_frags,0);
-	save_flags(flags);
-	cli();
+	spin_lock_irqsave(&zatm_dev->lock, flags);
 	if (!skb_shinfo(skb)->nr_frags) {
 		if (zatm_vcc->txing == RING_ENTRIES-1) {
-			restore_flags(flags);
+			spin_unlock_irqrestore(&zatm_dev->lock, flags);
 			return RING_BUSY;
 		}
 		zatm_vcc->txing++;
@@ -732,7 +726,7 @@
 	zwait;
 	zout(uPD98401_TX_READY | (zatm_vcc->tx_chan <<
 	    uPD98401_CHAN_ADDR_SHIFT),CMR);
-	restore_flags(flags);
+	spin_unlock_irqrestore(&zatm_dev->lock, flags);
 	EVENT("done\n",0,0);
 	return 0;
 }
@@ -866,15 +860,14 @@
 		if (zatm_dev->tx_bw < *pcr) return -EAGAIN;
 		zatm_dev->tx_bw -= *pcr;
 	}
-	save_flags(flags);
-	cli();
+	spin_lock_irqsave(&zatm_dev->lock, flags);
 	DPRINTK("i = %d, m = %d, PCR = %d\n",i,m,*pcr);
 	zpokel(zatm_dev,(i << uPD98401_IM_I_SHIFT) | m,uPD98401_IM(shaper));
 	zpokel(zatm_dev,c << uPD98401_PC_C_SHIFT,uPD98401_PC(shaper));
 	zpokel(zatm_dev,0,uPD98401_X(shaper));
 	zpokel(zatm_dev,0,uPD98401_Y(shaper));
 	zpokel(zatm_dev,uPD98401_PS_E,uPD98401_PS(shaper));
-	restore_flags(flags);
+	spin_unlock_irqrestore(&zatm_dev->lock, flags);
 	return shaper;
 }
 
@@ -889,11 +882,10 @@
 		if (--zatm_dev->ubr_ref_cnt) return;
 		zatm_dev->ubr = -1;
 	}
-	save_flags(flags);
-	cli();
+	spin_lock_irqsave(&zatm_dev->lock, flags);
 	zpokel(zatm_dev,zpeekl(zatm_dev,uPD98401_PS(shaper)) & ~uPD98401_PS_E,
 	    uPD98401_PS(shaper));
-	restore_flags(flags);
+	spin_unlock_irqrestore(&zatm_dev->lock, flags);
 	zatm_dev->free_shapers |= 1 << shaper;
 }
 
@@ -912,8 +904,6 @@
 	chan = zatm_vcc->tx_chan;
 	if (!chan) return;
 	DPRINTK("close_tx\n");
-	save_flags(flags);
-	cli();
 	while (skb_peek(&zatm_vcc->backlog)) {
 if (once) {
 printk("waiting for backlog to drain ...\n");
@@ -932,6 +922,7 @@
 		DPRINTK("waiting for TX queue to drain ... %p\n",skb);
 		sleep_on(&zatm_vcc->tx_wait);
 	}
+	spin_lock_irqsave(&zatm_dev->lock, flags);
 #if 0
 	zwait;
 	zout(uPD98401_DEACT_CHAN | (chan << uPD98401_CHAN_ADDR_SHIFT),CMR);
@@ -942,7 +933,7 @@
 	if (!(zin(CMR) & uPD98401_CHAN_ADDR))
 		printk(KERN_CRIT DEV_LABEL "(itf %d): can't close TX channel "
 		    "%d\n",vcc->dev->number,chan);
-	restore_flags(flags);
+	spin_unlock_irqrestore(&zatm_dev->lock, flags);
 	zatm_vcc->tx_chan = 0;
 	zatm_dev->tx_map[chan] = NULL;
 	if (zatm_vcc->shaper != zatm_dev->ubr) {
@@ -967,14 +958,13 @@
 	zatm_vcc = ZATM_VCC(vcc);
 	zatm_vcc->tx_chan = 0;
 	if (vcc->qos.txtp.traffic_class == ATM_NONE) return 0;
-	save_flags(flags);
-	cli();
+	spin_lock_irqsave(&zatm_dev->lock, flags);
 	zwait;
 	zout(uPD98401_OPEN_CHAN,CMR);
 	zwait;
 	DPRINTK("0x%x 0x%x\n",zin(CMR),zin(CER));
 	chan = (zin(CMR) & uPD98401_CHAN_ADDR) >> uPD98401_CHAN_ADDR_SHIFT;
-	restore_flags(flags);
+	spin_unlock_irqrestore(&zatm_dev->lock, flags);
 	DPRINTK("chan is %d\n",chan);
 	if (!chan) return -EAGAIN;
 	unlimited = vcc->qos.txtp.traffic_class == ATM_UBR &&
@@ -1022,15 +1012,14 @@
 	zatm_dev = ZATM_DEV(vcc->dev);
 	zatm_vcc = ZATM_VCC(vcc);
 	if (!zatm_vcc->tx_chan) return 0;
-	save_flags(flags);
 	/* set up VC descriptor */
-	cli();
+	spin_lock_irqsave(&zatm_dev->lock, flags);
 	zpokel(zatm_dev,0,zatm_vcc->tx_chan*VC_SIZE/4);
 	zpokel(zatm_dev,uPD98401_TXVC_L | (zatm_vcc->shaper <<
 	    uPD98401_TXVC_SHP_SHIFT) | (vcc->vpi << uPD98401_TXVC_VPI_SHIFT) |
 	    vcc->vci,zatm_vcc->tx_chan*VC_SIZE/4+1);
 	zpokel(zatm_dev,0,zatm_vcc->tx_chan*VC_SIZE/4+2);
-	restore_flags(flags);
+	spin_unlock_irqrestore(&zatm_dev->lock, flags);
 	zatm_dev->tx_map[zatm_vcc->tx_chan] = vcc;
 	return 0;
 }
@@ -1236,6 +1225,7 @@
 
 	DPRINTK(">zatm_init\n");
 	zatm_dev = ZATM_DEV(dev);
+	spin_lock_init(&zatm_dev->lock);
 	pci_dev = zatm_dev->pci_dev;
 	zatm_dev->base = pci_resource_start(pci_dev, 0);
 	zatm_dev->irq = pci_dev->irq;
@@ -1285,14 +1275,13 @@
 	do {
 		unsigned long flags;
 
-		save_flags(flags);
-		cli();
+		spin_lock_irqsave(&zatm_dev->lock, flags);
 		t0 = zpeekl(zatm_dev,uPD98401_TSR);
 		udelay(10);
 		t1 = zpeekl(zatm_dev,uPD98401_TSR);
 		udelay(1010);
 		t2 = zpeekl(zatm_dev,uPD98401_TSR);
-		restore_flags(flags);
+		spin_unlock_irqrestore(&zatm_dev->lock, flags);
 	}
 	while (t0 > t1 || t1 > t2); /* loop if wrapping ... */
 	zatm_dev->khz = t2-2*t1+t0;
@@ -1492,14 +1481,13 @@
 					return -EFAULT;
 				if (pool < 0 || pool > ZATM_LAST_POOL)
 					return -EINVAL;
-				save_flags(flags);
-				cli();
+				spin_lock_irqsave(&zatm_dev->lock, flags);
 				info = zatm_dev->pool_info[pool];
 				if (cmd == ZATM_GETPOOLZ) {
 					zatm_dev->pool_info[pool].rqa_count = 0;
 					zatm_dev->pool_info[pool].rqu_count = 0;
 				}
-				restore_flags(flags);
+				spin_unlock_irqrestore(&zatm_dev->lock, flags);
 				return copy_to_user(
 				    &((struct zatm_pool_req *) arg)->info,
 				    &info,sizeof(info)) ? -EFAULT : 0;
@@ -1530,15 +1518,14 @@
 				if (info.low_water >= info.high_water ||
 				    info.low_water < 0)
 					return -EINVAL;
-				save_flags(flags);
-				cli();
+				spin_lock_irqsave(&zatm_dev->lock, flags);
 				zatm_dev->pool_info[pool].low_water =
 				    info.low_water;
 				zatm_dev->pool_info[pool].high_water =
 				    info.high_water;
 				zatm_dev->pool_info[pool].next_thres =
 				    info.next_thres;
-				restore_flags(flags);
+				spin_unlock_irqrestore(&zatm_dev->lock, flags);
 				return 0;
 			}
 		default:
diff -Nru a/drivers/atm/zatm.h b/drivers/atm/zatm.h
--- a/drivers/atm/zatm.h	Thu Jul 31 10:25:25 2003
+++ b/drivers/atm/zatm.h	Thu Jul 31 10:25:25 2003
@@ -85,6 +85,7 @@
 	unsigned char irq;		/* IRQ */
 	unsigned int base;		/* IO base address */
 	struct pci_dev *pci_dev;	/* PCI stuff */
+	spinlock_t lock;
 };
 
 
